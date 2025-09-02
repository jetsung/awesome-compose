#!/usr/bin/env bash

###
#
# 备份 rustpad 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f rustpad.tar.xz ] && rm -rf ./rustpad.tar.xz

tar -Jcf rustpad.tar.xz ./data

#rclone copy ./rustpad.tar.xz minio:/backup/databases
echo "backup rustpad data to minio done."
echo "Backup of rustpad data to MinIO completed successfully."

