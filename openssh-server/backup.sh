#!/usr/bin/env bash

###
#
# 备份 openssh-server 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f openssh-server.tar.xz ]] && rm -rf ./openssh-server.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf openssh-server.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./openssh-server.tar.xz minio:/backup/databases
echo "backup openssh-server data to minio done."
echo "Backup of openssh-server data to MinIO completed successfully."
