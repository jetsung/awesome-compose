#!/usr/bin/env bash

#============================================================
# File: deploy.sh
# Description: 部署 HAProxy 反向代理服务脚本
# Author: Jetsung Chan <i@jetsung.com>
# Version: 0.1.0
# CreatedAt: 2026-01-26
# UpdatedAt: 2026-01-26
#============================================================

if [[ -n "$DEBUG" ]]; then
    set -eux
else
    set -euo pipefail
fi

# 获取脚本所在的实际目录
# SCRIPT_DIR="$(cd "$(dirname \"$0\")" && pwd)"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"

CONFIG="config/haproxy.cfg"
ENV_FILE=".env"
ACTION="add"
DOMAIN=""
GENERATE_PEM=false
CONTAINER_NAME="haproxy"

# 从 .env 中提取路径（支持被注释掉的情况）
extract_env_var() {
    local val
    local var_name=$1
    local default_val=$2
    val=$(grep "^#\?[[:space:]]*${var_name}=" "$ENV_FILE" | head -n 1 | cut -d'=' -f2- | sed 's/^["'\'']//;s/["'\'']$//')
    if [ -z "$val" ]; then
        echo "$default_val"
    else
        echo "$val"
    fi
}

# 初始化变量
SOURCE_DIR=$(extract_env_var "SOURCE_DIR" "")
DEST_DIR=$(extract_env_var "DEST_DIR" "$SCRIPT_DIR/certs")

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -g|--generate)
            GENERATE_PEM=true
            shift
            ;;
        *)
            DOMAIN="$1"
            shift
            ;;
    esac
done

# Function to reload HAProxy
reload_haproxy() {
    if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
        echo "Reloading HAProxy (SIGHUP)..."
        docker kill -s HUP "$CONTAINER_NAME"
    else
        echo "Warning: HAProxy container not running, skip reload."
    fi
}

# Function to generate PEM files
generate_pems() {
    if [ -z "$SOURCE_DIR" ]; then
        echo "Error: SOURCE_DIR is not set in .env"
        exit 1
    fi
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Error: SOURCE_DIR ($SOURCE_DIR) does not exist."
        exit 1
    fi

    echo "Starting PEM generation from $SOURCE_DIR..."
    mkdir -p "$DEST_DIR"

    # 清理旧的 pem 文件
    rm -f "$DEST_DIR"/*.pem

    for key_file in "$SOURCE_DIR"/*.key; do
        [ -e "$key_file" ] || continue
        local d
        d=$(basename "$key_file" .key)
        local fullchain="$SOURCE_DIR/$d.fullchain.cer"
        if [ -f "$fullchain" ]; then
            echo "Generating PEM for $d"
            cat "$fullchain" "$key_file" > "$DEST_DIR/$d.pem"
        else
            echo "Warning: No fullchain found for $d. Skipping."
        fi
    done
    echo "PEM generation complete. Files in $DEST_DIR"
}

# Function to insert after the last matching pattern
insert_after_last() {
    local pattern=$1
    local content=$2
    local last_line
    last_line=$(grep -n "$pattern" "$CONFIG" | tail -n 1 | cut -d: -f1)
    if [ -n "$last_line" ]; then
        local tmp_file
        tmp_file=$(mktemp)
        echo "$content" > "$tmp_file"
        sed "${last_line}r $tmp_file" "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
        rm "$tmp_file"
    fi
}

# Check if domain is needed
if [[ "$ACTION" =~ ^(add|rm)$ ]] && [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain> [-a add|rm|ssl|reload|up|down] [-g]"
    exit 1
fi

SLUG=${DOMAIN%%.*}

case "$ACTION" in
    add)
        if grep -q " -i $DOMAIN" "$CONFIG"; then
            echo "Error: Domain $DOMAIN already exists in $CONFIG"
        else
            insert_after_last "acl is_.* hdr(host) -i" "    acl is_$SLUG hdr(host) -i $DOMAIN"
            insert_after_last "http-request redirect scheme https code 301 if is_" "    http-request redirect scheme https code 301 if is_$SLUG"
            insert_after_last "acl host_.* hdr(host) -i" "    acl host_$SLUG hdr(host) -i $DOMAIN"
            insert_after_last "use_backend .* if host_" "    use_backend nginx_backend if host_$SLUG"
            echo "Successfully added $DOMAIN configuration."
        fi
        [ "$GENERATE_PEM" = true ] && generate_pems
        reload_haproxy
        ;;

    rm)
        if ! grep -q " -i $DOMAIN" "$CONFIG"; then
            echo "Error: Domain $DOMAIN not found in $CONFIG"
            exit 1
        fi
        sed -i "/is_$SLUG/d" "$CONFIG"
        sed -i "/host_$SLUG/d" "$CONFIG"
        echo "Successfully removed $DOMAIN configuration."
        reload_haproxy
        ;;

    ssl)
        generate_pems
        reload_haproxy
        ;;

    reload)
        reload_haproxy
        ;;

    up)
        echo "Starting HAProxy..."
        docker compose -p haproxy up -d
        ;;

    down)
        echo "Stopping HAProxy..."
        docker compose -p haproxy down
        ;;

    *)
        echo "Error: Invalid action '$ACTION'."
        exit 1
        ;;
esac
