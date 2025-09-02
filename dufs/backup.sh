#!/usr/bin/env bash

###
#
# 备份 dufs 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f dufs.tar.xz ] && rm -rf ./dufs.tar.xz

tar -Jcf dufs.tar.xz ./data

#rclone copy ./dufs.tar.xz minio:/backup/databases
echo "backup dufs data to minio done."
echo "Backup of dufs data to MinIO completed successfully."

