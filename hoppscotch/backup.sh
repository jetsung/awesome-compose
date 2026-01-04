#!/usr/bin/env bash

###
#
# 备份 hoppscotch 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f hoppscotch.tar.xz ]] && rm -rf ./hoppscotch.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf hoppscotch.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

# #rclone copy ./hoppscotch.tar.xz minio:/backup/databases
# echo "backup hoppscotch data to minio done."
# echo "Backup of hoppscotch data to MinIO completed successfully."
