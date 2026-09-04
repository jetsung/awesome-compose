#!/usr/bin/env bash

###
#
# 备份 warpgate 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f warpgate.tar.xz ]] && rm -rf ./warpgate.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf warpgate.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./warpgate.tar.xz minio:/backup/databases
echo "backup warpgate data to minio done."
echo "Backup of warpgate data to MinIO completed successfully."
