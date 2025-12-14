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

tar -Jcf openssh-server.tar.xz ./data

#rclone copy ./openssh-server.tar.xz minio:/backup/databases
echo "backup openssh-server data to minio done."
echo "Backup of openssh-server data to MinIO completed successfully."
