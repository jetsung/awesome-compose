#!/usr/bin/env bash

# 部署 acme.sh

set -euo pipefail

# 全局变量
BASE_EXEC=""
CA_SERVER=""
CA_EMAIL=""
CRON=""
DOMAIN=""
DNS_TYPE="dns_cf"
CHALLENGE=""
EXTEND=""
SSL_PATH="/srv/acme/ssl"
SSL_SAVE_PATH="/data/ssl"
MTIME=1
UPDATE_LOG="./update.log"

# 获取 base exec
get_base_exec() {
    if docker ps --filter "name=acme.sh" --quiet | grep -q .; then
        # Docker 中
        BASE_EXEC="docker exec acme.sh"
        SSL_SAVE_PATH="$SSL_PATH"
    else
        # 服务器中
        BASE_EXEC=""
    fi
    printf "BASE_EXEC: %s\n" "$BASE_EXEC"
}

# 服务器重载命令
restart_server() {
    if pgrep -f 'nginx: master' > /dev/null; then
        if [ -f "/etc/init.d/nginx" ]; then
            # BT 面板
            /etc/init.d/nginx restart
        else
            # Systemd
            systemctl reload nginx
        fi
        printf "%s nginx reload\n" "$(date -R)"
    elif pgrep -f 'angie: master' > /dev/null; then
        systemctl reload angie
        printf "%s angie reload\n" "$(date -R)"
    fi
}

# 切换 CA
set_ca() {
    local server="${CA_SERVER:-letsencrypt}"
    local email="${CA_EMAIL:-}"

    if [ -n "$email" ]; then
        "$BASE_EXEC" acme.sh --register-account --server "$server" -m "$email"
    else
        "$BASE_EXEC" acme.sh --set-default-ca --server "$server"
    fi
}

# 设置或运行计划任务
set_cron() {
    case "${CRON:-}" in
        "install")
            local script_path script_name minute hour

            script_path=$(dirname "$(realpath "$0")")
            script_name=$(basename "$0")

            # 随机生成分钟（0-59）和小时（0-23）
            minute=$((RANDOM % 60))
            hour=$((RANDOM % 24))

            # 添加定时任务
            printf "%d %d * * * root cd %s && bash ./%s -c\n" "$minute" "$hour" "$script_path" "$script_name" | tee /etc/cron.d/dockeracme > /dev/null
            systemctl restart cron
            ;;
        "run")
            if find "$SSL_PATH" -type f -mtime -"${MTIME:-1}" | grep -q .; then
                restart_server | tee -a "$UPDATE_LOG"
            fi
            ;;
        *)
            echo "error: Please specify the correct cron type (install/run)."
            exit 1
            ;;
    esac
}

# 签发和部署域名
deploy_domain() {
    local extend_args

    extend_args=()
    if [ -n "$CHALLENGE" ]; then
        extend_args+=(--challenge-alias "$CHALLENGE")
    fi

    if [ -n "$EXTEND" ]; then
        extend_args+=("$EXTEND")
    fi

    # 签发
    "$BASE_EXEC" acme.sh --issue \
        --ecc \
        --force \
        -d "$DOMAIN" \
        -d "*.$DOMAIN" \
        --dns "$DNS_TYPE" \
        --keylength ec-256 \
        "${extend_args[@]}"

    # 部署
    "$BASE_EXEC" acme.sh --install-cert \
        --ecc \
        -d "$DOMAIN" \
        --key-file "$SSL_SAVE_PATH/$DOMAIN.key" \
        --fullchain-file "$SSL_SAVE_PATH/$DOMAIN.fullchain.cer"
}

# 参数解析
judgment_parameters() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            '-a' | '--challenge')
                CHALLENGE="${2:?"error: Please specify the correct challenge."}"
                shift 2
                ;;
            '-c' | '--cron')
                CRON="${2:-run}"
                shift 2
                ;;
            '-e' | '--email')
                CA_EMAIL="${2:?"error: Please specify the correct email."}"
                shift 2
                ;;
            '-s' | '--server')
                CA_SERVER="${2:?"error: Please specify the correct server."}"
                shift 2
                ;;
            '-p' | '--path')
                SSL_PATH="${2:?"error: Please specify the correct path."}"
                shift 2
                ;;
            '-d' | '--domain')
                DOMAIN="${2:?"error: Please specify the correct domain."}"
                if [[ "$DOMAIN" != *"."* ]]; then
                    printf "\033[31mDOMAIN must be a valid domain name\033[0m\n"
                    exit 1
                fi
                shift 2
                ;;
            '-x' | '--extend')
                EXTEND="${2:?"error: Please specify the correct extend arguments."}"
                shift 2
                ;;
            '-n' | '--dns')
                DNS_TYPE="${2:?"error: Please specify the correct DNS provider."}"
                shift 2
                ;;
            '-h' | '--help')
                show_help
                ;;
            *)
                echo "$0: unknown option -- $1" >&2
                exit 1
                ;;
        esac
    done
}

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

# 主逻辑
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