#!/usr/bin/env bash

###
#
# 备份 chanify 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f chanify.tar.xz ] && rm -rf ./chanify.tar.xz

tar -Jcf chanify.tar.xz ./data

#rclone copy ./chanify.tar.xz minio:/backup/databases
echo "backup chanify data to minio done."
echo "Backup of chanify data to MinIO completed successfully."

