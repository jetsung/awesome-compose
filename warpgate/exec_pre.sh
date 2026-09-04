#!/usr/bin/env bash

###
#
# 备份前执行：在 warpgate 容器内对 SQLite 数据库做一致性快照
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

CONTAINER_NAME="${CONTAINER_NAME:-warpgate}"
DB_PATH="/data/db/db.sqlite3"

echo "正在备份容器 ${CONTAINER_NAME} 中的 SQLite 数据库..."

docker exec "${CONTAINER_NAME}" sh -c \
    "if [ -f '${DB_PATH}' ]; then sqlite3 '${DB_PATH}' \".backup '${DB_PATH}.bak'\"; fi"

echo "SQLite 数据库备份完成。"
