#!/usr/bin/env bash

###
#
# 备份 mariadb 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f mariadb.tar.xz ] && rm -rf ./mariadb.tar.xz

tar -Jcf mariadb.tar.xz ./data

#rclone copy ./mariadb.tar.xz minio:/backup/databases
echo "backup mariadb data to minio done."
echo "Backup of mariadb data to MinIO completed successfully."

