#!/usr/bin/env bash

if [[ -z "${1}" ]]; then
  # copy files with mysql
  cp ../mysql/{*.yml,.env} ./
else
  # copy files with mariadb
  cp ../mariadb/{*.yml,.env} ./
fi

# copy files with phpmyadmin
cp ../phpmyadmin/docker-compose.yml ./docker-compose.phpmyadmin.yml
sed "/TZ=/d" ../phpmyadmin/.env >> .env
