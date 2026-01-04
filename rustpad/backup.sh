#!/usr/bin/env bash

###
#
# 备份 rustpad 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f rustpad.tar.xz ] && rm -rf ./rustpad.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf rustpad.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./rustpad.tar.xz minio:/backup/databases
echo "backup rustpad data to minio done."
echo "Backup of rustpad data to MinIO completed successfully."
