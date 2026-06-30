# rclone-backup

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [rclone-backup][1] 是基于 rclone 的 Docker 定时备份解决方案，支持多目标备份和灵活的配置管理。

[1]:https://github.com/jetsung/rclone-backup
[2]:https://github.com/jetsung/rclone-backup
[3]:https://hub.docker.com/r/jetsung/rclone-backup
[4]:https://github.com/jetsung/rclone-backup

---

## 使用教程

### 常用 cron 表达式

- `0 2 * * *` - 每天凌晨2点
- `0 3 * * 0` - 每周日凌晨3点
- `0 1 1 * *` - 每月1号凌晨1点
- `*/30 * * * *` - 每30分钟

### 查看日志

```bash
# 测试日志功能（首次使用建议运行）
docker exec rclone-backup /app/scripts/test-logging.sh

# 查看备份日志
docker exec rclone-backup tail -f /var/log/backup/backup.log

# 查看同步日志
docker exec rclone-backup tail -f /var/log/backup/sync.log

# 查看 cron 日志
docker exec rclone-backup tail -f /var/log/backup/cron.log

# 查看容器日志
docker logs -f rclone-backup

# 查看所有日志文件
docker exec rclone-backup ls -la /var/log/backup/
```

### 手动执行任务

```bash
# 执行特定的备份任务
docker exec rclone-backup /app/scripts/backup-job.sh "documents_backup"

# 执行特定的同步任务
docker exec rclone-backup /app/scripts/sync-job.sh "documents_sync"

# 创建自定义 Hook
docker exec rclone-backup /app/scripts/create-hook.sh pre-backup compress-photos

# 测试 Hook 功能
docker exec rclone-backup /app/scripts/test-hooks.sh
```

### 管理 rclone 配置

```bash
# 查看已配置的远程
docker exec rclone-backup rclone listremotes

# 测试连接
docker exec rclone-backup rclone lsd gdrive:

# 重新配置
docker exec rclone-backup rclone config
```

## 配置参数说明

### 备份任务 (backup_jobs)
- `name`: 备份任务名称
- `enabled`: 是否启用此任务
- `source_path`: 源目录路径
- `backup_mode`: 备份模式
  - `copy`: 只复制新文件和更新的文件 (推荐，默认)
  - `sync`: 完全同步，会删除目标中不存在于源的文件
- `targets`: 备份目标列表
  - `remote`: rclone 配置的远程名称
  - `path`: 远程路径
  - `enabled`: 是否启用此目标
- `schedule`: cron 表达式 (分 时 日 月 周)
- `options`: rclone 命令选项 (推荐使用 `--update`，只复制更新的文件)
- `hooks`: Hook 脚本配置（可选）
  - `pre_backup`: 备份前执行的脚本
  - `post_backup`: 备份后执行的脚本
  - Hook 配置参数：
    - `enabled`: 是否启用此 Hook
    - `script`: Hook 脚本路径
    - `timeout`: 脚本执行超时时间（秒）
    - `fail_on_error`: 脚本失败时是否终止备份任务
    - `description`: Hook 描述（可选）

### 同步任务 (sync_jobs)
- `name`: 同步任务名称
- `enabled`: 是否启用此任务
- `destination_path`: 本地目标目录路径
- `sources`: 同步源列表
  - `remote`: rclone 配置的远程名称
  - `path`: 远程路径
  - `enabled`: 是否启用此源
- `schedule`: cron 表达式 (分 时 日 月 周)
- `sync_mode`: 同步模式
  - `copy`: 只复制新文件和更新的文件 (推荐)
  - `sync`: 完全同步，会删除目标中不存在于源的文件
- `options`: rclone 命令选项 (推荐使用 `--update`，只复制更新的文件)

## 配置文件 `config.json`

```json
{
  "backup_jobs": [
    {
      "name": "documents_backup",
      "enabled": true,
      "source_path": "/data/documents",
      "backup_mode": "copy",
      "targets": [
        {
          "remote": "gdrive",
          "path": "backup/documents",
          "enabled": true
        }
      ],
      "schedule": "0 2 * * *",
      "options": [
        "--progress",
        "--transfers=4",
        "--checkers=8",
        "--update"
      ],
      "hooks": {
        "pre_backup": {
          "enabled": true,
          "script": "/app/hooks/compress-backup.sh",
          "timeout": 1800,
          "fail_on_error": true,
          "description": "压缩备份目录为 tar.xz 格式"
        },
        "post_backup": {
          "enabled": true,
          "script": "/app/hooks/cleanup-compressed.sh",
          "timeout": 60,
          "fail_on_error": false,
          "description": "清理临时压缩文件"
        }
      }
    }
  ],
  "sync_jobs": [
    {
      "name": "documents_sync",
      "enabled": true,
      "destination_path": "/data/synced/documents",
      "sources": [
        {
          "remote": "gdrive",
          "path": "shared/documents",
          "enabled": true
        }
      ],
      "schedule": "0 1 * * *",
      "sync_mode": "copy",
      "options": [
        "--progress",
        "--transfers=4",
        "--checkers=8",
        "--update"
      ]
    }
  ]
}
```
