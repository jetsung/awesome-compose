#!/usr/bin/env bash

set -euo pipefail

# remove files
rm -rf .env ./*.yml

if [[ -z "${1:-}" ]]; then
  # copy files with mysql
  cp ../mysql/{*.yml,.env} ./
else
  # copy files with mariadb
  cp ../mariadb/{*.yml,.env} ./
fi

# copy files from phpmyadmin
sed '/^TZ=/d' ../phpmyadmin/.env >> ./.env
sed '1,4d' ../phpmyadmin/compose.yml >> ./compose.yml
sed '1,2d' ../phpmyadmin/compose.override.yml >> ./compose.override.yml