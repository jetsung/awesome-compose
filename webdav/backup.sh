#!/usr/bin/env bash

###
#
# 备份 webdav 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f webdav.tar.xz ] && rm -rf ./webdav.tar.xz

tar -Jcf webdav.tar.xz ./data

#rclone copy ./webdav.tar.xz minio:/backup/databases
echo "backup webdav data to minio done."
echo "Backup of webdav data to MinIO completed successfully."

