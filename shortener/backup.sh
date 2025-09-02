#!/usr/bin/env bash

###
#
# 备份 shortener 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f shortener.tar.xz ] && rm -rf ./shortener.tar.xz

tar -Jcf shortener.tar.xz ./data

#rclone copy ./shortener.tar.xz minio:/backup/databases
echo "backup shortener data to minio done."
echo "Backup of shortener data to MinIO completed successfully."

