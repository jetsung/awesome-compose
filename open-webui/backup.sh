#!/usr/bin/env bash

###
#
# 备份 open-webui 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f open-webui.tar.xz ] && rm -rf ./open-webui.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf open-webui.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./open-webui.tar.xz minio:/backup/databases
echo "backup open-webui data to minio done."
echo "Backup of open-webui data to MinIO completed successfully."
