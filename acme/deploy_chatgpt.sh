#!/usr/bin/env bash
set -euo pipefail

# 全局变量（默认值可以根据实际情况覆盖）
BASE_EXEC=""
CA_SERVER="${CA_SERVER:-}"
CA_EMAIL="${CA_EMAIL:-}"
CRON=""
DOMAIN=""
DNS_TYPE="${DNS_TYPE:-dns_cf}"
CHALLENGE=""
EXTEND=""
SSL_PATH="${SSL_PATH:-/srv/acme/ssl}"
SSL_SAVE_PATH="${SSL_SAVE_PATH:-/data/ssl}"
MTIME="${MTIME:-1}"
UPDATE_LOG="./update.log"

# 判断是否在 Docker 中运行，设置 BASE_EXEC
get_base_exec() {
    if docker ps --filter "name=acme.sh" --quiet | grep -q .; then
        BASE_EXEC="docker exec acme.sh"
    else
        SSL_SAVE_PATH="$SSL_PATH"
    fi
    echo "BASE_EXEC: $BASE_EXEC"
}

# 重载服务，根据进程情况重载 nginx 或 angie
restart_server() {
    if pgrep -f "nginx: master" >/dev/null; then
        if [ -x "/etc/init.d/nginx" ]; then
            /etc/init.d/nginx stop
            /etc/init.d/nginx start
        else
            systemctl reload nginx
        fi
        echo "$(date -R) nginx reloaded" | tee -a "$UPDATE_LOG"
    elif pgrep -f "angie: master" >/dev/null; then
        systemctl reload angie
        echo "$(date -R) angie reloaded" | tee -a "$UPDATE_LOG"
    fi
}

# 切换 CA，根据是否提供 Email 决定调用哪条命令
set_ca() {
    local server="${CA_SERVER:-letsencrypt}"
    if [[ -z "$CA_EMAIL" ]]; then
        $BASE_EXEC acme.sh --set-default-ca --server "$server"
    else
        $BASE_EXEC acme.sh --register-account --server "$server" -m "$CA_EMAIL"
    fi
}

# 设置或运行定时任务
set_cron() {
    local script_path script_name MINUTE HOUR
    case "$CRON" in
        install)
            script_path="$(dirname "$(readlink -f "$0")")"
            script_name="$(basename "$0")"
            MINUTE=$((RANDOM % 60))
            HOUR=$((RANDOM % 24))
            cat > /etc/cron.d/dockeracme <<EOF
$MINUTE $HOUR * * * root cd $script_path && /bin/bash ./$script_name -c
EOF
            systemctl restart cron
            ;;
        run)
            if find "$SSL_PATH" -type f -mtime -"$MTIME" | grep -q .; then
                restart_server
            fi
            ;;
        *)
            echo "error: invalid cron type." >&2
            exit 1
            ;;
    esac
}

# 签发和部署域名证书
deploy_domain() {
    if [[ -z "$CHALLENGE" ]]; then
        $BASE_EXEC acme.sh --issue --ecc --force \
            -d "$DOMAIN" -d "*.$DOMAIN" \
            --dns "$DNS_TYPE" --keylength ec-256 $EXTEND
    else
        $BASE_EXEC acme.sh --issue --ecc --force \
            -d "$DOMAIN" -d "*.$DOMAIN" \
            --dns "$DNS_TYPE" --challenge-alias "$CHALLENGE" \
            --keylength ec-256 $EXTEND
    fi

    $BASE_EXEC acme.sh --install-cert --ecc -d "$DOMAIN" \
        --key-file "$SSL_SAVE_PATH/$DOMAIN.key" \
        --fullchain-file "$SSL_SAVE_PATH/$DOMAIN.fullchain.cer"
}

# 参数解析函数，支持长短参数及错误提示
parse_parameters() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -a|--challenge)
                CHALLENGE="${2:?error: Please specify the challenge.}"
                shift 2
                ;;
            -c|--cron)
                CRON="run"
                if [[ $# -ge 2 && "$2" != -* ]]; then
                    CRON="install"
                    shift 2
                else
                    shift
                fi
                ;;
            -e|--email)
                CA_EMAIL="${2:?error: Please specify the email.}"
                shift 2
                ;;
            -s|--server)
                CA_SERVER="${2:?error: Please specify the server.}"
                shift 2
                ;;
            -p|--path)
                SSL_PATH="${2:?error: Please specify the path.}"
                shift 2
                ;;
            -d|--domain)
                DOMAIN="${2:?error: Please specify the domain.}"
                if [[ "$DOMAIN" != *.* ]]; then
                    echo -e "\033[31mDOMAIN must be a valid domain name\033[0m"
                    exit 1
                fi
                shift 2
                ;;
            -x|--extend)
                EXTEND="${2:?error: Please specify the extend parameter.}"
                shift 2
                ;;
            -n|--dns)
                DNS_TYPE="${2:?error: Please specify the dns type.}"
                shift 2
                ;;
            -h|--help)
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
  -h, --help               Show help message.
  -a, --challenge <value>  Set challenge alias.
  -d, --domain <domain>    Set domain (must contain a dot).
  -c, --cron [install]     Run or install cron job.
  -e, --email <email>      Set CA email.
  -s, --server <server>    Set CA server.
  -p, --path <path>        Set SSL certificate folder path.
  -x, --extend <params>    Additional parameters for acme.sh.
  -n, --dns <dns_type>     Set DNS type (default: dns_cf).

Examples:
  $0 -e user@example.com -s letsencrypt -d example.com -p /srv/acme/ssl -n dns_cf
  $0 -d example.com -c install
EOF
    exit 0
}

# 根据传入参数依次执行相应操作
do_action() {
    [[ -n "$CA_SERVER" ]] && set_ca
    if [[ -n "${CRON:-}" ]]; then
        set_cron
    fi
    if [[ -n "$DOMAIN" && -n "$DNS_TYPE" ]]; then
        deploy_domain
    fi
}

# 主函数
main() {
    get_base_exec
    parse_parameters "$@"
    do_action
}

main "$@"

