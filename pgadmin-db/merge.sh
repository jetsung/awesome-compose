#!/usr/bin/env bash

set -euo pipefail

# remove files
rm -rf .env ./*.yaml

# copy files with postgres
cp ../postgres/{*.yaml,.env} ./

# copy files from pgadmin
sed '/^TZ=/d' ../pgadmin/.env >> ./.env
sed '1,4d' ../pgadmin/compose.yaml >> ./compose.yaml
sed '1,2d' ../pgadmin/compose.override.yaml >> ./compose.override.yaml
