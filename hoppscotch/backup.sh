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

# tar -Jcf hoppscotch.tar.xz ./data

# #rclone copy ./hoppscotch.tar.xz minio:/backup/databases
# echo "backup hoppscotch data to minio done."
# echo "Backup of hoppscotch data to MinIO completed successfully."
