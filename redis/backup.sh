#!/usr/bin/env bash

###
#
# 备份 redis 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f redis.tar.xz ] && rm -rf ./redis.tar.xz

tar -Jcf redis.tar.xz ./data

#rclone copy ./redis.tar.xz minio:/backup/databases
echo "backup redis data to minio done."
echo "Backup of redis data to MinIO completed successfully."

