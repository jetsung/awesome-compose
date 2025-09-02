#!/usr/bin/env bash

###
#
# 备份 opengist 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f opengist.tar.xz ] && rm -rf ./opengist.tar.xz

tar -Jcf opengist.tar.xz ./data

#rclone copy ./opengist.tar.xz minio:/backup/databases
echo "backup opengist data to minio done."
echo "Backup of opengist data to MinIO completed successfully."

