#!/usr/bin/env bash

###
#
# 备份 drone 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f drone.tar.xz ] && rm -rf ./drone.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf drone.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./drone.tar.xz minio:/backup/databases
echo "backup drone data to minio done."
echo "Backup of drone data to MinIO completed successfully."
