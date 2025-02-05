#!/usr/bin/env bash

# 部署 acme.sh

set -euo pipefail

BASE_EXEC=""

# CA 服务器
CA_SERVER=""

# CA Email
CA_EMAIL=""

# 运行定时任务
CRON=""

# 域名
DOMAIN=""

# DNS 类型
DNS_TYPE="dns_cf"

# 交换域名
CHALLENGE=""

# 扩展参数
EXTEND=""

# SSL 证书文件夹（按实际环境修改）
SSL_PATH="/srv/acme/ssl"

# 保存 SSL 证书的文件夹（Docker 中）
SSL_SAVE_PATH="/data/ssl"

# 最近一天内是否有文件修改
MTIME=1

# 更新日志
UPDATE_LOG="./update.log"

# 获取 base exec
get_base_exec() {
    if docker ps --filter "name=acme.sh" --quiet | grep -q .; then
        # Docker 中
        BASE_EXEC="docker exec acme.sh"
    else
        # 服务器中
        SSL_SAVE_PATH="$SSL_PATH"
    fi
    # echo "BASE_EXEC: $BASE_EXEC"
}

# 服务器重载命令（按实际环境修改）
restart_server() {
    # shellcheck disable=SC2009
    if [ "$(ps -ef | grep 'nginx: master' | grep -v "grep" | awk '{print $3}')" -eq 1 ]; then
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
    elif [ "$(ps -ef | grep 'angie: master' | grep -v "grep" | awk '{print $3}')" -eq 1 ]; then
        # 正在运行 angie
        systemctl reload angie
        
        echo -e "$(date -R) angie reload"    
    fi
}

# 切换 CA
set_ca() {
    local server="${CA_SERVER:-letsencrypt}"
    local email="${CA_EMAIL:-}"

    # 切换 CA 为 Let's Encrypt
    if [ -z "$email" ]; then
        $BASE_EXEC acme.sh --set-default-ca --server "$server"
    else
        $BASE_EXEC acme.sh --register-account --server "$server" -m "$email"
    fi
}

# 设置或运行计划任务
set_cron() {
    case "${CRON:-}" in
        # 安装定时任务
        "install")
            script_path=$(dirname "$(readlink -f "$0")")
            script_name=$(basename "$0")

            # 随机生成分钟（0-59）
            MINUTE=$((RANDOM % 60))

            # 随机生成小时（0-23）
            HOUR=$((RANDOM % 24))

            # 输出随机生成的 Cron 时间
            cat > /etc/cron.d/dockeracme <<EOF
$MINUTE $HOUR * * * root cd $script_path; /bin/bash ./$script_name -c
EOF
            systemctl restart cron
            ;;
        
        # 运行定时任务
        "run")
            if find "$SSL_PATH" -type f -mtime -"${MTIME:-1}" | grep -q .; then
                restart_server | tee -a "$UPDATE_LOG"
            fi            
            ;;

        *)
            echo "error: Please specify the correct cron type."
            exit 1
            ;;
    esac
}

# 签发和部署域名
deploy_domain() {
    # 签发
    if [ -z "$CHALLENGE" ]; then
        $BASE_EXEC acme.sh --issue \
            --ecc \
            --force \
            -d "$DOMAIN" \
            -d "*.$DOMAIN" \
            --dns "$DNS_TYPE" \
            --keylength ec-256 \
            "$EXTEND"
    else
        $BASE_EXEC acme.sh --issue \
            --ecc \
            --force \
            -d "$DOMAIN" \
            -d "*.$DOMAIN" \
            --dns "$DNS_TYPE" \
            --challenge-alias "$CHALLENGE" \
            --keylength ec-256 \
            "$EXTEND"    
    fi

    # 部署
    $BASE_EXEC acme.sh --install-cert \
        --ecc \
        -d "$DOMAIN" \
        --key-file "$SSL_SAVE_PATH/$DOMAIN.key" \
        --fullchain-file "$SSL_SAVE_PATH/$DOMAIN.fullchain.cer"
}

# 处理参数信息
judgment_parameters() {
    while [[ "$#" -gt '0' ]]; do
        case "$1" in
            '-a' | '--challenge')
                # 交换域名
                shift
                CHALLENGE="${1:?"error: Please specify the correct challenge."}"
                ;;

            '-c' | '--cron')
                # 定时任务
                CRON="run"
                if [ $# -ge 2 ] && [[ "$2" != -* ]]; then
                    CRON="install"
                    shift         
                fi
                ;;

            '-e' | '--email')
                # CA Email
                shift
                CA_EMAIL="${1:?"error: Please specify the correct email."}"
                ;;

            
            '-s' | '--server')
                # CA 服务器
                shift
                CA_SERVER="${1:?"error: Please specify the correct server."}"
                ;;
            
            '-p' | '--path')
                # SSL 证书文件夹
                shift
                SSL_PATH="${1:?"error: Please specify the correct path."}"
                ;; 

            '-d' | '--domain')
                # 记录域名
                shift
                DOMAIN="${1:?"error: Please specify the correct domain."}"
                if [[ "$DOMAIN" != *"."* ]]; then
                    echo -e "\033[31mDOMAIN must be a domain name\033[0m"
                    exit 1
                fi
                ;;
            
            '-x' | '--extend')
                # 扩展证书
                shift
                EXTEND="${1:?"error: Please specify the correct extend."}"
                ;;

            # DNS 类型
            '-n' | '--dns')
                shift
                DNS_TYPE="${1:?"error: Please specify the correct dns."}"
                ;;

            # 显示帮助
            '-h' | '--help')
                show_help
                ;;

            *)
                echo "$0: unknown option -- $1" >&2
                exit 1
                ;;
        esac
        shift
    done
}

# 显示帮助信息
# 显示帮助信息
show_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  -h, --help               Show this help message
  -a, --challenge <domain> Set challenge domain
  -c, --cron [install|run] Set or run cron job
  -e, --email <email>      Set CA email
  -s, --server <server>    Set CA server
  -p, --path <path>        Set SSL certificate path
  -d, --domain <domain>    Set domain name
  -x, --extend <args>      Add extend arguments
  -n, --dns <dns>          Set DNS provider

Example:
  $0 -c install -e user@example.com -s zerossl
  $0 -a challenge.example.com -p /srv/ssl -d example.com -n dns_cf
EOF
    exit 0
}

# 执行
do_action() {
    if [ -n "$CA_SERVER" ]; then
        set_ca
    fi

    if [ -n "${CRON:-}" ]; then
        set_cron
    fi

    if [ -n "$DOMAIN" ] && [ -n "$DNS_TYPE" ]; then
        deploy_domain
    fi
}

# 主函数
main() {
    get_base_exec

    judgment_parameters "$@"

    do_action
}

main "$@"
