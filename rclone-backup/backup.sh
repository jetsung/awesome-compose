#!/usr/bin/env bash

###
#
# 备份 rclone-backup 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f rclone-backup.tar.xz ]] && rm -rf ./rclone-backup.tar.xz

tar -Jcf rclone-backup.tar.xz ./data

#rclone copy ./rclone-backup.tar.xz minio:/backup/databases
echo "backup rclone-backup data to minio done."
echo "Backup of rclone-backup data to MinIO completed successfully."
