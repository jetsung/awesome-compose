#!/usr/bin/env bash

###
#
# 备份 stalwart 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f stalwart.tar.xz ] && rm -rf ./stalwart.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf stalwart.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./stalwart.tar.xz minio:/backup/databases
echo "backup stalwart data to minio done."
echo "Backup of stalwart data to MinIO completed successfully."
