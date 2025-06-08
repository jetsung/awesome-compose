#!/usr/bin/env bash

docker exec -i wordpress-db-1 mysqldump -uexampleuser -pexamplepass --databases wordpress > wordpress.sql
