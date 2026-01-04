#!/usr/bin/env bash

###
#
# 备份 mindoc 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f mindoc.tar.xz ] && rm -rf ./mindoc.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf mindoc.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./mindoc.tar.xz minio:/backup/databases
echo "backup mindoc data to minio done."
echo "Backup of mindoc data to MinIO completed successfully."
