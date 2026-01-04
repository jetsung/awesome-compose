#!/usr/bin/env bash

###
#
# 备份 blinko 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f ./blinko.tar.xz ]] && rm -rf ./blinko.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf blinko.tar.xz ./data ./blinko.sql

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./blinko.tar.xz minio:/backup/databases
echo "backup blinko data to minio done."
echo "Backup of blinko data to MinIO completed successfully."
