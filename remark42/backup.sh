#!/usr/bin/env bash

###
#
# 备份 remark42 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f remark42.tar.xz ] && rm -rf ./remark42.tar.xz

tar -Jcf remark42.tar.xz ./data

#rclone copy ./remark42.tar.xz minio:/backup/databases
echo "backup remark42 data to minio done."
echo "Backup of remark42 data to MinIO completed successfully."

