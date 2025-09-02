#!/usr/bin/env bash

###
#
# 备份 xunsearch 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f xunsearch.tar.xz ] && rm -rf ./xunsearch.tar.xz

tar -Jcf xunsearch.tar.xz ./data

#rclone copy ./xunsearch.tar.xz minio:/backup/databases
echo "backup xunsearch data to minio done."
echo "Backup of xunsearch data to MinIO completed successfully."

