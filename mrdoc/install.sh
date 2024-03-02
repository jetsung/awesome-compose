#!/usr/bin/env bash

git clone https://gitee.com/zmister/MrDoc.git

docker compose up -d

docker exec -it mrdoc python manage.py createsuperuser
