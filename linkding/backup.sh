#!/usr/bin/env bash

###
#
# 备份 linkding 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f linkding.tar.xz ] && rm -rf ./linkding.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf linkding.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./linkding.tar.xz minio:/backup/databases
echo "backup linkding data to minio done."
echo "Backup of linkding data to MinIO completed successfully."
