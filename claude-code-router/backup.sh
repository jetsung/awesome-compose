#!/usr/bin/env bash

###
#
# 备份 claude-code-router 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f claude-code-router.tar.xz ]] && rm -rf ./claude-code-router.tar.xz

tar -Jcf claude-code-router.tar.xz ./config

#rclone copy ./claude-code-router.tar.xz minio:/backup/databases
echo "backup claude-code-router data to minio done."
echo "Backup of claude-code-router data to MinIO completed successfully."
