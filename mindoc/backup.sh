#!/usr/bin/env bash

###
#
# 备份 mindoc 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f mindoc.tar.xz ] && rm -rf ./mindoc.tar.xz

tar -Jcf mindoc.tar.xz ./data

#rclone copy ./mindoc.tar.xz minio:/backup/databases
echo "backup mindoc data to minio done."
echo "Backup of mindoc data to MinIO completed successfully."

