# rclone

```bash
# 1. 设置 .env 参数
# CRON：计划任务参数
# DATA：需同步的目录地址

# 2. 首先，生成配置信息
docker run --rm -it -v $(pwd)/config:/config rclone/rclone:latest config
```