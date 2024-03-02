#!/usr/bin/env bash

# copy files with postgres
cp ../postgres/{*.yml,.env} ./

# copy files with pgadmin
cp ../pgadmin/docker-compose.yml ./docker-compose.pgadmin.yml
sed "/TZ=/d" ../pgadmin/.env >> .env
