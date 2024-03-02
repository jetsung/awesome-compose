#!/usr/bin/env bash

# 初装步骤说明

BASE_EXEC="docker exec acme.sh"

# 启动
docker compose up -d

# 切换 CA 为 Let's Encrypt
$BASE_EXEC acme.sh --set-default-ca --server letsencrypt

# 安装定时器
./cron.sh install
