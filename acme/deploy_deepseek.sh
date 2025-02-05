#!/usr/bin/env bash

# 基于 acme.sh 的自动化证书管理工具（支持 Docker 和宿主机环境）
set -euo pipefail
IFS=$'\n\t'

# ---------------------------- 可配置常量 ----------------------------
declare -r DEFAULT_CA_SERVER="letsencrypt"      # 默认 CA 服务器
declare -r DEFAULT_SSL_PATH="/srv/acme/ssl"     # 宿主机证书存储路径
declare -r DOCKER_SSL_PATH="/data/ssl"          # Docker 容器内证书路径
declare -r UPDATE_LOG="./update.log"            # 更新日志路径
declare -ri DEFAULT_MTIME=1                     # 文件修改时间阈值（天）

# ---------------------------- 全局变量声明 ----------------------------
declare CA_SERVER=""                            # CA 服务器地址
declare CA_EMAIL=""                             # CA 账户邮箱
declare DOMAIN=""                               # 主域名
declare DNS_TYPE="dns_cf"                       # DNS 验证类型
declare CHALLENGE=""                            # DNS 挑战别名
declare SSL_PATH="$DEFAULT_SSL_PATH"            # 当前证书存储路径
declare CRON_ACTION=""                          # 定时任务动作（install/run）
declare BASE_EXEC=""                            # 执行环境前缀（docker exec）
declare EXTEND=""                               # 扩展参数

# ---------------------------- 功能函数 ----------------------------
show_help() {
  cat <<EOF
自动化 SSL 证书管理工具（基于 acme.sh）

用法: $0 [选项]

选项:
  -h, --help               显示帮助信息
  -d, --domain <域名>      需要签发证书的域名（必需）
  -n, --dns <类型>         DNS 验证类型（默认: dns_cf）
  -s, --server <CA服务商> 指定 CA 服务器（默认: letsencrypt）
  -e, --email <邮箱>       设置 CA 账户邮箱
  -a, --challenge <别名>   设置 DNS 挑战别名
  -p, --path <路径>        证书存储路径（默认: $DEFAULT_SSL_PATH）
  -c, --cron [install]     定时任务操作：
                           - 无参数：执行证书更新检查
                           - install：安装定时任务
  -x, --extend <参数>      添加扩展参数

示例:
  # 签发 example.com 的证书（使用 Cloudflare DNS）
  $0 -d example.com -n dns_cf

  # 安装每日检查更新的定时任务
  $0 -c install

  # 使用自定义 CA 服务器
  $0 -d example.com -s buypass
EOF
  exit 0
}

# 检测 Docker 环境
detect_environment() {
  if docker ps --filter "name=acme.sh" --format "{{.Names}}" | grep -q "acme.sh"; then
    BASE_EXEC="docker exec acme.sh"
    SSL_PATH="$DOCKER_SSL_PATH"
    echo "检测到 Docker 环境，使用容器内路径: $SSL_PATH"
  else
    echo "使用宿主机环境，证书存储路径: $SSL_PATH"
    mkdir -p "$SSL_PATH"
  fi
}

# 服务重载（支持 Nginx/Angie）
reload_service() {
  local service_type=""
  
  # 检测正在运行的服务
  if systemctl is-active --quiet nginx; then
    service_type="nginx"
  elif systemctl is-active --quiet angie; then
    service_type="angie"
  else
    echo "未检测到运行的 Web 服务"
    return 0
  fi

  echo "重新加载 $service_type 服务..."
  if systemctl reload "$service_type"; then
    echo "$(date -R) $service_type 重载成功" | tee -a "$UPDATE_LOG"
  else
    echo "错误: $service_type 重载失败！" >&2
    return 1
  fi
}

# 配置 CA 账户
setup_ca_account() {
  local server="${CA_SERVER:-$DEFAULT_CA_SERVER}"
  local email="${CA_EMAIL:-}"

  echo "配置 CA 服务器: $server"
  if [[ -z "$email" ]]; then
    $BASE_EXEC acme.sh --set-default-ca --server "$server"
  else
    $BASE_EXEC acme.sh --register-account --server "$server" -m "$email"
  fi
}

# 签发证书
issue_certificate() {
  local -a opts=(
    "--issue" 
    "--ecc" 
    "--force" 
    "-d" "$DOMAIN" 
    "-d" "*.$DOMAIN" 
    "--dns" "$DNS_TYPE"
  )

  [[ -n "$CHALLENGE" ]] && opts+=("--challenge-alias" "$CHALLENGE")
  [[ -n "$EXTEND" ]] && opts+=("$EXTEND")

  echo "正在为域名 $DOMAIN 签发证书..."
  if ! $BASE_EXEC acme.sh "${opts[@]}"; then
    echo "错误: 证书签发失败！" >&2
    exit 1
  fi
}

# 部署证书
deploy_certificate() {
  local -a opts=(
    "--install-cert"
    "--ecc"
    "-d" "$DOMAIN"
    "--key-file" "$SSL_PATH/$DOMAIN.key"
    "--fullchain-file" "$SSL_PATH/$DOMAIN.fullchain.cer"
  )

  echo "部署证书到 $SSL_PATH..."
  if ! $BASE_EXEC acme.sh "${opts[@]}"; then
    echo "错误: 证书部署失败！" >&2
    exit 1
  fi
}

# 管理定时任务
manage_cron() {
  case "$CRON_ACTION" in
    install)
      local script_path script_name cron_time
      script_path=$(dirname "$(realpath "$0")")
      script_name=$(basename "$0")
      cron_time="$((RANDOM % 60)) $((RANDOM % 24))"

      echo "安装定时任务到 /etc/cron.d/acme-renew"
      cat > /etc/cron.d/acme-renew <<EOF
# 自动生成的证书更新任务
$cron_time * * * root "$script_path/$script_name" -c
EOF
      systemctl restart cron || true
      ;;

    run)
      if find "$SSL_PATH" -type f -mtime -"${DEFAULT_MTIME}" -print -quit | grep -q .; then
        echo "检测到证书更新，重新加载服务..."
        reload_service
      fi
      ;;

    *)
      echo "错误: 未知的定时任务操作" >&2
      exit 1
      ;;
  esac
}

# 参数解析
parse_arguments() {
  while (( $# )); do
    case "$1" in
      -h|--help)    show_help ;;
      
      -d|--domain)
        shift
        [[ $# -ge 1 ]] || { echo "错误: 缺少域名参数" >&2; exit 1; }
        DOMAIN="$1"
        [[ "$DOMAIN" =~ \..+ ]] || {
          echo "错误: 域名格式不正确 ($DOMAIN)" >&2
          exit 1
        }
        ;;
        
      -n|--dns)
        shift
        [[ $# -ge 1 ]] || { echo "错误: 缺少DNS类型参数" >&2; exit 1; }
        DNS_TYPE="$1"
        ;;
        
      -s|--server)
        shift
        [[ $# -ge 1 ]] || { echo "错误: 缺少CA服务器参数" >&2; exit 1; }
        CA_SERVER="$1"
        ;;
        
      -e|--email)
        shift
        [[ $# -ge 1 ]] || { echo "错误: 缺少邮箱参数" >&2; exit 1; }
        CA_EMAIL="$1"
        ;;
        
      -a|--challenge)
        shift
        [[ $# -ge 1 ]] || { echo "错误: 缺少挑战别名参数" >&2; exit 1; }
        CHALLENGE="$1"
        ;;
        
      -p|--path)
        shift
        [[ $# -ge 1 ]] || { echo "错误: 缺少路径参数" >&2; exit 1; }
        SSL_PATH="$1"
        mkdir -p "$SSL_PATH"
        ;;
        
      -c|--cron)
        if [[ $# -ge 2 ]] && [[ "$2" != -* ]]; then
          CRON_ACTION="install"
          shift
        else
          CRON_ACTION="run"
        fi
        ;;

      -x|--extend)
        shift
        [[ $# -ge 1 ]] || { echo "错误: 缺少扩展参数" >&2; exit 1; }
        EXTEND="$1"
        ;;
        
      *)
        echo "错误: 未知选项 $1" >&2
        exit 1
        ;;
    esac
    shift
  done

  # 必需参数检查
  [[ -n "$DOMAIN" || -n "$CRON_ACTION" ]] || {
    echo "错误: 必须指定域名或定时任务操作" >&2
    show_help
  }
}

# ---------------------------- 主流程 ----------------------------
main() {
  detect_environment
  parse_arguments "$@"
  
  [[ -n "$CA_SERVER" || -n "$CA_EMAIL" ]] && setup_ca_account
  [[ -n "$CRON_ACTION" ]] && manage_cron
  [[ -n "$DOMAIN" ]] && {
    issue_certificate
    deploy_certificate
  }

  echo "操作完成！"
  exit 0
}

main "$@"