#!/usr/bin/env bash

CONTAINER_NAME="$(docker ps -q -f name=wordpress-db)"

# shellcheck disable=SC1091
. .env

docker exec -i "$CONTAINER_NAME" mysqldump -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD --databases $WORDPRESS_DB_NAME > wordpress.sql
