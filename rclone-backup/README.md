# rclone-backup

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [rclone-backup][1] 是基于 rclone 的 Docker 定时备份解决方案，支持多目标备份和灵活的配置管理。

[1]:https://github.com/jetsung/rclone-backup
[2]:https://github.com/jetsung/rclone-backup
[3]:https://hub.docker.com/r/jetsung/rclone-backup
[4]:https://github.com/jetsung/rclone-backup

---

- 配置文件 `config/config.json`
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
