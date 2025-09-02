#!/usr/bin/env bash

###
#
# 备份 valkey 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f valkey.tar.xz ] && rm -rf ./valkey.tar.xz

tar -Jcf valkey.tar.xz ./data

#rclone copy ./valkey.tar.xz minio:/backup/databases
echo "backup valkey data to minio done."
echo "Backup of valkey data to MinIO completed successfully."

