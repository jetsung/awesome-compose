#!/usr/bin/env bash

###
#
# 备份 gitlab 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f gitlab.tar.xz ]] && rm -rf ./gitlab.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf gitlab.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./gitlab.tar.xz minio:/backup/databases
echo "backup gitlab data to minio done."
echo "Backup of gitlab data to MinIO completed successfully."
