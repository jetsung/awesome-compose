#!/usr/bin/env bash

set -euo pipefail

# remove files
rm -rf .env ./*.yml

# copy files with postgres
cp ../postgres/{*.yml,.env} ./

# copy files from pgadmin
sed '/^TZ=/d' ../pgadmin/.env >> ./.env
sed '1,4d' ../pgadmin/compose.yml >> ./compose.yml
sed '1,2d' ../pgadmin/compose.override.yml >> ./compose.override.yml