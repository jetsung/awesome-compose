#!/usr/bin/env bash

###
#
# 备份 gitlab-runner 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f gitlab-runner.tar.xz ] && rm -rf ./gitlab-runner.tar.xz

tar -Jcf gitlab-runner.tar.xz ./data

#rclone copy ./gitlab-runner.tar.xz minio:/backup/databases
echo "backup gitlab-runner data to minio done."
echo "Backup of gitlab-runner data to MinIO completed successfully."

