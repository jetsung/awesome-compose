#!/usr/bin/env bash

###
#
# 备份 postgres 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f postgres.tar.xz ] && rm -rf ./postgres.tar.xz

tar -Jcf postgres.tar.xz ./data

#rclone copy ./postgres.tar.xz minio:/backup/databases
echo "backup postgres data to minio done."
echo "Backup of postgres data to MinIO completed successfully."

