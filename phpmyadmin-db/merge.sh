#!/usr/bin/env bash

set -euo pipefail

# remove files
rm -rf .env ./*.yaml

if [[ -z "${1:-}" ]]; then
  # copy files with mysql
  cp ../mysql/{*.yaml,.env} ./
else
  # copy files with mariadb
  cp ../mariadb/{*.yaml,.env} ./
fi

# copy files from phpmyadmin
sed '/^TZ=/d' ../phpmyadmin/.env >> ./.env
sed '1,4d' ../phpmyadmin/compose.yaml >> ./compose.yaml
sed '1,2d' ../phpmyadmin/compose.override.yaml >> ./compose.override.yaml
