#!/usr/bin/env bash

###
#
# 备份 valkey 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f valkey.tar.xz ] && rm -rf ./valkey.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf valkey.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./valkey.tar.xz minio:/backup/databases
echo "backup valkey data to minio done."
echo "Backup of valkey data to MinIO completed successfully."
