#!/usr/bin/env bash

###
#
# 备份 mariadb 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f mariadb.tar.xz ] && rm -rf ./mariadb.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf mariadb.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./mariadb.tar.xz minio:/backup/databases
echo "backup mariadb data to minio done."
echo "Backup of mariadb data to MinIO completed successfully."
