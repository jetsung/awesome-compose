#!/usr/bin/env bash

###
#
# 备份 vaultwarden-backup 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f vaultwarden-backup.tar.xz ] && rm -rf ./vaultwarden-backup.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf vaultwarden-backup.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./vaultwarden-backup.tar.xz minio:/backup/databases
echo "backup vaultwarden-backup data to minio done."
echo "Backup of vaultwarden-backup data to MinIO completed successfully."
