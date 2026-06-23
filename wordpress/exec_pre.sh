#!/usr/bin/env bash

CONTAINER_NAME="$(docker ps -q -f name=mysql)"

# shellcheck disable=SC1091
. .env

# 1. 加载环境变量
# shellcheck disable=SC1091
. .env

# 2. 执行备份（将密码作为容器内的临时环境变量传递）
docker exec -i "$CONTAINER_NAME" sh -c "
    export MYSQL_PWD='$WORDPRESS_DB_PASSWORD';
    mysqldump -u'$WORDPRESS_DB_USER' --single-transaction --set-gtid-purged=OFF --databases '$WORDPRESS_DB_NAME'
" >wordpress.sql
