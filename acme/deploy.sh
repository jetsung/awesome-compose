#!/usr/bin/env bash

#============================================================
# File: deploy.sh
# Description: 部署 ACME 证书
# Author: Jetsung Chan <i@jetsung.com>
# Version: 0.1.0
# CreatedAt: 
# UpdatedAt: 2025-03-05
#============================================================

if [[ -n "$DEBUG" ]]; then
    set -eux
else
    set -euo pipefail
fi

# 输出错误信息并退出
error_exit() {
    echo -e "\033[31merror: $1\033[0m" >&2
    exit 1
}

warn() {
    echo -e "\033[33m$1\033[0m"
}

tip() {
    echo -e "\033[32m$1\033[0m"
}

is_command() {
    command -v "$1" >/dev/null 2>&1
}

# 获取执行命令
get_docker_exec() {
    if docker ps --filter "name=acme.sh" --quiet | grep -q .; then
        # Docker
        DOCKER_EXEC="docker exec acme.sh acme.sh"
        SSL_PATH="/data/ssl"
    else
        # 服务器
        DOCKER_EXEC="acme.sh"
        
        if ! is_command "$DOCKER_EXEC"; then
            error_exit "未安装 acme.sh"
        fi
        
        if [[ -z "${SSL_PATH:-}" ]]; then
            SSL_PATH="$SAVE_SSL_PATH"
        fi
    fi
}

# 切换 CA 
## https://letsencrypt.org 90 days
## https://acme-v02.api.letsencrypt.org/directory
## https://acme-staging-v02.api.letsencrypt.org/directory
##
## https://zerossl.com 90 days
## https://acme.zerossl.com/v2/DV90
##
## https://cloud.google.com/certificate-manager/docs/public-ca-tutorial 90 days
## https://dv.acme-v02.api.pki.goog/directory
## https://dv.acme-v02.test-api.pki.goog/directory
##
## https://www.buypass.com 180 days
## https://api.buypass.com/acme/directory
## https://api.test4.buypass.no/acme/directory
##
do_setca() {
    $DOCKER_EXEC --set-default-ca --server "$CA_SERVER"
    
    if [[ -n "${CA_EMAIL:-}" ]]; then
        if [[ -n "${EAB_KID:-}" ]] && [[ -n "${EAB_HMAC_KEY:-}" ]]; then
            $DOCKER_EXEC --register-account --server "$CA_SERVER" --email "$CA_EMAIL" \
                --eab-kid "$EAB_KID" --eab-hmac-key "$EAB_HMAC_KEY"
        else
            $DOCKER_EXEC --register-account --server "$CA_SERVER" --email "$CA_EMAIL"
        fi
    fi    
}

# 显示帮助信息 CA
help_setca() {
    cat <<EOF
用法: $0 -a $ACTION [options]
      $(warn "设置 CA")
选项:
    -h,  --help                              显示 CA 帮助信息
    -s,  --server <server>                   设置 CA 服务器, 默认 letsencrypt
    -e,  --email <email>                     可选, 设置 CA 邮箱

    -ek, --eab-kid <eab-kid>                 可选, 设置 EAB 密钥 ID
    -eh, --eab-hmac-key <eab-hmac-key>       可选, 设置 EAB HMAC 密钥

EOF
}

# 签发证书
do_issue() {
    if [[ -z "${DOMAIN:-}" ]]; then
        error_exit "错误: 域名 (domain) 不能为空."
    fi
    if [[ -z "${DNS_TYPE:-}" ]]; then
        error_exit "错误: DNS 类型 (dns) 不能为空."
    fi

    # shellcheck disable=SC2206
    ARGS=(
        --domain "$DOMAIN"
        --domain "*.$DOMAIN"
        --dns "$DNS_TYPE"
        --keylength ec-256
        --ecc
        --force
        ${EXTEND:-}
    )

    [ -n "${CHALLENGE:-}" ] && ARGS+=(--challenge-alias "$CHALLENGE")

    # 签发并部署证书
    $DOCKER_EXEC --issue "${ARGS[@]}" && \
    do_deploy
}

help_issue() {
    cat <<EOF
用法: $0 -a $ACTION [options]
      $(warn "签发证书")
选项:
    -h,  --help                              显示帮助信息
    -d,  --domain <domain>                   记录域名
    -ns, --dns <cf,ali,dp,dpi>               NS 类型, 默认 dns_cf
            dns_cf                           Cloudflare
            dns_ali                          阿里云
            dns_dp                           DNSPod 中国版
            dns_dpi                          DNSPod 国际版
            ...                              更多请查看 acme.sh 文档
    -ch, --challenge <challenge>             可选, 交换域名
    -ex, --extend <extend>                   可选, 扩展参数

EOF
}

do_renew() {
    if [[ -z "${DOMAIN:-}" ]]; then
        RENEW="--renew-all"
    else
        RENEW="--renew --domain $DOMAIN"
    fi
    
    [[ -n "${FORCE:-}" ]] && RENEW+=" --force"

    # 签发并部署证书
    # shellcheck disable=SC2086
    $DOCKER_EXEC $RENEW ${EXTEND:-}
}

help_renew() {
    cat <<EOF
用法: $0 -a $ACTION [options]
      $(warn "续签证书")
选项:
    -h,  --help                              显示帮助信息
    -d,  --domain <domain>                   可选, 记录域名（若无此参数则为全部更新）
    -fo, --force                             可选, 强制更新
    -ex, --extend <extend>                   可选, 扩展参数

EOF
}

# 部署证书
do_deploy() {
    if [[ -z "${DOMAIN:-}" ]]; then
        error_exit "错误: 域名 (domain) 不能为空."
    fi

    $DOCKER_EXEC --install-cert \
        --ecc \
        -d "$DOMAIN" \
        --key-file "${SSL_PATH}/${DOMAIN}.key" \
        --fullchain-file "${SSL_PATH}/${DOMAIN}.fullchain.cer"
}

# 定时任务
do_cron() {
    case "${SETUP:-}" in
    "1")
        # 安装定时任务
        script_path=$(dirname "$(readlink -f "$0")")
        script_name=$(basename "$0")

        # 随机生成分钟（0-59）
        MINUTE=$((RANDOM % 60))

        # 随机生成小时（0-7）
        HOUR=$((RANDOM % 8))

        if [[ -n "${REAL_SSL_PATH:-}" ]]; then
            echo "REAL_SSL_PATH=$REAL_SSL_PATH" > ./.conf

            mkdir -p "$REAL_SSL_PATH"
            cp "${SAVE_SSL_PATH}/"* "$REAL_SSL_PATH"
        fi

        # 输出随机生成的 Cron 时间
        cat > /etc/cron.d/dockeracme <<EOF
$MINUTE $HOUR * * * root cd $script_path; /bin/bash ./$script_name --action cron
EOF
        systemctl restart cron
        ;;
        
    *)
        # 运行定时任务：如果 SSL 证书目录内文件在 $MTIME 天内修改过，则重启服务器
        if [[ -d "$SAVE_SSL_PATH" ]] && find "$SAVE_SSL_PATH" -type f -mtime -"${MTIME}" | grep -q .; then

            # 若 REAL_SSL_PATH 存在，则将证书复制到 REAL_SSL_PATH
            if [[ -f ".conf" ]]; then
                # shellcheck source=/dev/null
                source .conf

                if [[ -n "${REAL_SSL_PATH:-}" ]]; then
                    SAVE_SSL_PATH="$REAL_SSL_PATH"
                fi
            fi       

            # 重启服务器
            restart_server | tee -a "$UPDATE_LOG"
        fi
        ;;        
    esac
}

# 显示帮助信息 定时任务
help_cron() {
    cat <<EOF
用法: $0 -a $ACTION [options]
      $(warn "执行定时任务")
选项:
    -h,  --help                              显示帮助信息
    -se, --setup                             可选, 安装计划任务（无参数则运行计划任务）
    -pa, --path <path>                       可选, 证书保存路径, 比如 /usr/local/nginx/conf/ssl 
    -mt, --mtime <mtime>                     可选, 证书更新时间, 默认 1
    
EOF
}

# 服务器重载命令（按实际环境修改）
restart_server() {
    # shellcheck disable=SC2009
    if [[ "$(ps -ef | grep 'nginx: master' | grep -v "grep" | awk '{print $3}')" -eq 1 ]]; then
        # 正在运行 nginx
        if [ -f "/etc/init.d/nginx" ]; then
            # bt
            /etc/init.d/nginx stop
            /etc/init.d/nginx start
        else
            # systemd
            systemctl reload nginx
        fi
        
        echo -e "$(date -R) nginx reload"
    elif [[ "$(ps -ef | grep 'angie: master' | grep -v "grep" | awk '{print $3}')" -eq 1 ]]; then
        # 正在运行 angie
        systemctl reload angie
        
        echo -e "$(date -R) angie reload"    
    fi
}

# 备份本服务
do_backup() {
    dir_name="${PWD##*/}"
    bk_file_name="${dir_name}-$(date +%Y%m%d).tar.xz"
    if tar -caf "../${bk_file_name}" -C "${PWD%/*}" "$dir_name"; then
        mv "../${bk_file_name}" .
        echo "备份成功: $bk_file_name"
    else
        echo "备份失败"
    fi
}

# 显示帮助信息 备份
help_backup() {
    cat <<EOF
用法: $0 -a $ACTION [options]
      $(warn "备份本服务")
选项:
    -h,  --help                              显示帮助信息

EOF
}

# 处理参数信息
judgment_parameters() {
    while [[ "$#" -gt '0' ]]; do
        case "${1,,}" in
            '-h' | '--help')
                # 显示帮助
                HELP=1
                ;;

            '-a' | '--action') 
                # 操作
                shift
                ACTION="${1:?"错误: 操作类型 (action) 不能为空."}"
                ACTION="${ACTION,,}" # 转小写
                ;;    
            '-s' | '--server')
                # CA 服务器
                shift
                CA_SERVER="${1:?"错误: CA 服务器 (server) 不能为空."}"
                ;;
            '-e' | '--email')
                # CA 邮箱
                shift
                CA_EMAIL="${1:?"错误: CA 邮箱 (email) 不能为空."}"
                ;;  

            '-d' | '--domain')
                # 签发域名
                shift
                DOMAIN="${1:?"错误: 域名 (domain) 不能为空."}"
                if [[ "$DOMAIN" != *"."* ]]; then
                    error_exit "错误: 域名 (domain) 必须包含点."
                fi                
                ;;

            '-ek' | --eab-kid)
                # EAB 密钥 ID
                shift
                EAB_KID="${1:?"错误: EAB 密钥 ID (eab-kid) 不能为空."}"
                ;;
            '-eh' | --eab-hmac-key)
                # EAB HMAC 密钥
                shift
                EAB_HMAC_KEY="${1:?"错误: EAB HMAC 密钥 (eab-hmac-key) 不能为空."}"
                ;;

            '-ns' | '--dns')
                # DNS 类型
                shift
                DNS_TYPE="${1:?"错误: DNS 类型 (dns) 不能为空."}"
                DNS_TYPE="${DNS_TYPE,,}"
                if [[ "$DNS_TYPE" != "dns_"* ]]; then
                    DNS_TYPE="dns_$DNS_TYPE"
                fi
                ;;                
            '-ch' | '--challenge')
                # 交换域名
                shift
                CHALLENGE="${1:?"错误: 交换域名 (challenge) 不能为空."}"
                ;;                
            '-ex' | '--extend')
                # 扩展参数
                shift
                EXTEND="${1:?"错误: 扩展参数 (extend) 不能为空."}"
                ;;   

            '-fo' | '--force')
                # 强制更新
                FORCE="1"
                ;;

            '-se' | '--setup')
                SETUP=1
                ;;    
            '-mt' | '--mtime')
                # 最近几天内是否有文件修改
                shift
                MTIME="${1:?"错误: 最近几天内是否有文件修改 (mtime) 不能为空."}"
                ;;       
            '-pa' | '--path')
                # 证书路径
                shift
                REAL_SSL_PATH="${1:?"错误: 证书路径 (path) 不能为空."}"
                ;;  

            *)
                echo "$0: 未知选项 -- $1" >&2
                exit 1
                ;;
        esac
        shift
    done
}

# 显示帮助信息
show_top_help() {
    cat <<EOF
用法: $0 [options]
    $(warn "部署 ACME 证书")
选项:
    -h,  --help                              显示帮助信息
    -a,  --action     <ca|is>                执行操作
            ca setca                         切换 CA
            is issue                         签发证书
            re renew                         续签证书
            cr cron                          计划任务
            bk backup                        执行备份

EOF
    exit 0
}

# 显示帮助信息
show_help() {
    case "${ACTION:-}" in
        'ca' | 'setca')
            help_setca
            ;;

        'is' | 'issue')
            help_issue
            ;;

        're' | 'renew')
            help_renew
            ;;

        'cr' | 'cron')
            help_cron
            ;;

        'bk' | 'backup')
            help_backup
            ;;

        *)
            show_top_help
            ;;
    esac
    exit 0
}

main() {
    judgment_parameters "$@"    

    if [[ $# -eq 0 ]]; then
        HELP=1
    fi
    
    if [[ -n "${HELP:-}" ]]; then
        show_help
    fi

    SAVE_SSL_PATH="$(pwd)/data/ssl"

    get_docker_exec

    MTIME="${MTIME:-1}" # 最近一天内是否有文件修改
    UPDATE_LOG="update.log" # 更新日志

    DNS_TYPE="${DNS_TYPE:-dns_cf}" # DNS 类型
    CA_SERVER="${CA_SERVER:-letsencrypt}" # CA 服务器

    case "${ACTION:-}" in
        'ca' | 'setca')
            # 设置 CA
            do_setca
            ;;

        'is' | 'issue')
            # 签发
            do_issue
            ;;

        'ne' |'renew')
            # 续期
            do_renew
            ;;

        'cr' | 'cron')
            # 定时任务
            do_cron
            ;;

        'bk' | 'backup')
            # 备份
            do_backup
            ;;

        *)
            error_exit "无效的操作类型."
            ;;
    esac
}

main "$@"