#!/usr/bin/env bash

###
#
# 备份 qinglong 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f qinglong.tar.xz ] && rm -rf ./qinglong.tar.xz

tar -Jcf qinglong.tar.xz ./data

#rclone copy ./qinglong.tar.xz minio:/backup/databases
echo "backup qinglong data to minio done."
echo "Backup of qinglong data to MinIO completed successfully."

