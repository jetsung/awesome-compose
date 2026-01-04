#!/usr/bin/env bash

###
#
# 备份 memos 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f memos.tar.xz ] && rm -rf ./memos.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf memos.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./memos.tar.xz minio:/backup/databases
echo "backup memos data to minio done."
echo "Backup of memos data to MinIO completed successfully."
