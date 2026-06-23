#!/usr/bin/env bash

###
#
# 备份 WordPress 数据（数据库 + 文件）
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

BACKUP_NAME="wordpress"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_NAME}_${TIMESTAMP}.tar.xz"

mkdir -p "$BACKUP_DIR"

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始备份 WordPress 数据..."
tar -Jcf "$BACKUP_FILE" ./data ./wordpress.sql

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

if [[ -n "${RCLONE_REMOTE:-}" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 上传备份到 MinIO..."
    rclone copy "$BACKUP_FILE" "${RCLONE_REMOTE}/${BACKUP_NAME}/"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 上传完成"
fi

# 清理 7 天前的本地备份
find "$BACKUP_DIR" -name "${BACKUP_NAME}_*.tar.xz" -mtime +7 -delete 2>/dev/null || true

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份完成: $BACKUP_FILE"
