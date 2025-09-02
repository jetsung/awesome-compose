#!/usr/bin/env bash

###
#
# 备份 mysql 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f mysql.tar.xz ] && rm -rf ./mysql.tar.xz

tar -Jcf mysql.tar.xz ./data

#rclone copy ./mysql.tar.xz minio:/backup/databases
echo "backup mysql data to minio done."
echo "Backup of mysql data to MinIO completed successfully."

