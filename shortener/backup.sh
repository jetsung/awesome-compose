#!/usr/bin/env bash

###
#
# 备份 shortener 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f shortener.tar.xz ] && rm -rf ./shortener.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf shortener.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./shortener.tar.xz minio:/backup/databases
echo "backup shortener data to minio done."
echo "Backup of shortener data to MinIO completed successfully."
