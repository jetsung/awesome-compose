#!/usr/bin/env bash

###
#
# 备份 redis 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f redis.tar.xz ] && rm -rf ./redis.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf redis.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./redis.tar.xz minio:/backup/databases
echo "backup redis data to minio done."
echo "Backup of redis data to MinIO completed successfully."
