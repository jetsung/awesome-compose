#!/usr/bin/env bash

CONTAINER_NAME="$(docker ps -q -f name=postgres-)"

# shellcheck disable=SC1091
. .env

docker exec -i "$CONTAINER_NAME" pg_dump "$DATABASE_URL" > asciinema.sql
