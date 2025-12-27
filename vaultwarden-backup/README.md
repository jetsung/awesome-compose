# vaultwarden-backup

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [vaultwarden-backup][1] 是一个使用 rclone 备份 Vaultwarden 的开源项目

[1]:https://github.com/ttionya/vaultwarden-backup
[2]:https://github.com/ttionya/vaultwarden-backup
[3]:https://hub.docker.com/r/ttionya/vaultwarden-backup
[4]:https://github.com/ttionya/vaultwarden-backup/blob/master/README_zh.md

---

## 配置 Rclone（⚠️ 必读 ⚠️）

> **对于备份，你需要先配置 Rclone，否则备份工具不会工作。**
> **对于还原，它不是必要的。**

### 配置远程存储
```shell
docker run --rm -it \
--mount type=volume,source=vaultwarden-rclone-data,target=/config/ \
ttionya/vaultwarden-backup:latest \
rclone config

# 或
docker run --rm -it -v $(pwd)/data:/config/ ttionya/vaultwarden-backup:latest rclone config
```

> **建议将远程名称设置为 `BitwardenBackup`**，否则需通过环境变量 `RCLONE_REMOTE_NAME` 指定。
> OneDrive，先在本地使用 rclone config 设置后，再从 `~/.config/rclone/rclone.conf` 取数据复制到此服务的 `/config/rclone/rclone.conf`。

### 检查配置
```shell
docker run --rm -it \
--mount type=volume,source=vaultwarden-rclone-data,target=/config/ \
ttionya/vaultwarden-backup:latest \
rclone config show
```

---

## 备份

### 方法一：使用 Docker Compose（推荐）

1. 下载项目中的 `docker-compose.yml`
2. 根据实际情况编辑环境变量
3. 在 `docker-compose.yml` 所在目录执行：

```shell
# 启动
docker-compose up -d
# 停止
docker-compose stop
# 重启
docker-compose restart
# 删除
docker-compose down
```

### 方法二：自动备份（已有运行中的 vaultwarden）

确保你的 vaultwarden 容器名为 `vaultwarden`，数据目录为 `/data`：

```shell
docker run -d \
--restart=always \
--name vaultwarden_backup \
--volumes-from=vaultwarden \
--mount type=volume,source=vaultwarden-rclone-data,target=/config/ \
-e DATA_DIR="/data" \
ttionya/vaultwarden-backup:latest
```

---

## 还原备份

> **重要：还原会覆盖已有文件。操作前请停止 vaultwarden 容器，并将备份文件下载到本地。**

### 若使用项目 `docker-compose.yml`：

```shell
docker run --rm -it \
--mount type=volume,source=vaultwarden-data,target=/bitwarden/data/ \
--mount type=bind,source=$(pwd),target=/bitwarden/restore/ \
ttionya/vaultwarden-backup:latest restore [OPTIONS]
```

### 若使用“自动备份”方式：

```shell
docker run --rm -it \
--mount type=volume,source="Docker卷名称",target=/data/ \
--mount type=bind,source=$(pwd),target=/bitwarden/restore/ \
-e DATA_DIR="/data" \
ttionya/vaultwarden-backup:latest restore [OPTIONS]
```

> 或使用本地目录映射（将 `source` 改为本地绝对路径）：

```shell
--mount type=bind,source="/your/local/backup/dir",target=/data/
```

### 还原选项

| 选项 | 说明 |
|------|------|
| `-f` / `--force-restore` | 强制还原（无交互确认） |
| `--zip-file` | 指定压缩包（如 `backup.zip`） |
| `-p` / `--password` | **不安全！** 直接指定压缩包密码（建议交互输入） |
| `--db-file` | 指定数据库文件（如 `db.sqlite3`） |
| `--config-file` | 指定 `config.json` |
| `--rsakey-file` | 指定 `rsakey.tar` |
| `--attachments-file` | 指定 `attachments.tar` |
| `--sends-file` | 指定 `sends.tar` |

---

## 环境变量

> 所有变量均有默认值，可按需覆盖。

### 核心变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `RCLONE_REMOTE_NAME` | `BitwardenBackup` | Rclone 远程名称 |
| `RCLONE_REMOTE_DIR` | `/BitwardenBackup/` | 远程备份目录 |
| `RCLONE_GLOBAL_FLAG` | `''` | Rclone 全局参数（勿用 `-P` 等影响输出的参数） |
| `CRON` | `5 * * * *` | 备份计划（每小时 05 分） |
| `ZIP_ENABLE` | `TRUE` | 是否打包为压缩文件 |
| `ZIP_PASSWORD` | `WHEREISMYPASSWORD?` | 压缩包密码（始终加密） |
| `ZIP_TYPE` | `zip` | 压缩格式（`zip` 或 `7z`） |
| `BACKUP_KEEP_DAYS` | `0` | 保留最近 N 天备份（`0` 表示永久保留） |
| `BACKUP_FILE_SUFFIX` | `%Y%m%d` | 备份文件后缀（支持 `date` 格式，如 `%Y%m%d-%H%M`） |
| `TIMEZONE` | `UTC` | 时区（如 `Asia/Shanghai`） |
| `DISPLAY_NAME` | `vaultwarden` | 实例显示名称（仅用于日志/通知） |
| `DATA_DIR` | `/bitwarden/data` | vaultwarden 数据目录（自动备份时通常为 `/data`） |

### 数据路径变量（一般无需修改）

| 变量 | 默认值 |
|------|--------|
| `DATA_DB` | `${DATA_DIR}/db.sqlite3` |
| `DATA_RSAKEY` | `${DATA_DIR}/rsa_key` |
| `DATA_ATTACHMENTS` | `${DATA_DIR}/attachments` |
| `DATA_SENDS` | `${DATA_DIR}/sends` |

> 注：`DATA_DB` 也支持 PostgreSQL (`db.dump`) 和 MySQL (`db.sql`)。

---

## 通知配置

### Ping 通知（推荐搭配 [healthchecks.io](https://healthchecks.io/)）

| 环境变量 | 触发时机 |
|--------|--------|
| `PING_URL` | 完成（无论成功/失败） |
| `PING_URL_WHEN_START` | 开始 |
| `PING_URL_WHEN_SUCCESS` | 成功 |
| `PING_URL_WHEN_FAILURE` | 失败 |

> 可搭配 `_CURL_OPTIONS` 后缀变量传入 `curl` 参数（如 `-H`, `-X` 等）。
> 支持占位符 `%{subject}` 和 `%{content}`。

#### 测试 Ping
```shell
docker run --rm -it \
-e PING_URL_WHEN_SUCCESS='https://hc-ping.com/your-uuid' \
ttionya/vaultwarden-backup:latest ping
```

### 邮件通知（基于 SMTP）

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MAIL_SMTP_ENABLE` | `FALSE` | 启用邮件 |
| `MAIL_SMTP_VARIABLES` | — | SMTP 配置（**勿用 `-s`**） |
| `MAIL_TO` | — | 收件人邮箱 |
| `MAIL_WHEN_SUCCESS` | `TRUE` | 成功时发邮件 |
| `MAIL_WHEN_FAILURE` | `TRUE` | 失败时发邮件 |
| `MAIL_FORCE_THREAD` | `FALSE` | 强制邮件线程聚合 |

#### 示例 `MAIL_SMTP_VARIABLES`（Zoho）：
```text
-S smtp-use-starttls \
-S smtp=smtp://smtp.zoho.com:587 \
-S smtp-auth=login \
-S smtp-auth-user=user@example.com \
-S smtp-auth-password=yourpassword \
-S from=user@example.com
```

#### 测试邮件
```shell
docker run --rm -it \
-e MAIL_SMTP_VARIABLES='...' \
-e MAIL_TO='you@example.com' \
ttionya/vaultwarden-backup:latest mail
```

---

## 环境变量加载方式

### 1. 使用 `.env` 文件（推荐挂载）

```shell
docker run -d \
--mount type=bind,source=/path/to/.env,target=/.env \
ttionya/vaultwarden-backup:latest
```

> **不要用 `--env-file`**，会因引号处理错误导致配置失效。

### 2. Docker Secrets（敏感信息）

在变量名后加 `_FILE`，从文件读取值：

```shell
-e ZIP_PASSWORD_FILE=/run/secrets/zip-password
```

### 优先级顺序（高 → 低）：
1. 直接环境变量（如 `ZIP_PASSWORD`）
2. `_FILE` 环境变量指向的文件内容
3. `.env` 中的 `_FILE` 指向的文件
4. `.env` 中的普通变量值
