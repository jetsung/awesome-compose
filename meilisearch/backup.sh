#!/usr/bin/env bash

###
#
# 备份 meilisearch 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f meilisearch.tar.xz ] && rm -rf ./meilisearch.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf meilisearch.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./meilisearch.tar.xz minio:/backup/databases
echo "backup meilisearch data to minio done."
echo "Backup of meilisearch data to MinIO completed successfully."
