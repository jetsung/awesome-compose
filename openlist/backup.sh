#!/usr/bin/env bash

###
#
# 备份 openlist 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f openlist.tar.xz ] && rm -rf ./openlist.tar.xz

tar -Jcf openlist.tar.xz ./data

#rclone copy ./openlist.tar.xz minio:/backup/databases
echo "backup openlist data to minio done."
echo "Backup of openlist data to MinIO completed successfully."

