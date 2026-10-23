# Vikunja

[Office Web][1] · [Source][2] · [Docker Image][3] · [Documentation][4]

---

> [Vikunja][1] 是一款开源的待办事项（To-do）管理应用，支持任务列表、甘特图、看板、表格等多种视图，可自托管，提供 Web、桌面与移动端客户端。

[1]:https://vikunja.io/
[2]:https://code.vikunja.io/vikunja
[3]:https://hub.docker.com/r/vikunja/vikunja
[4]:https://vikunja.io/docs/

---

## 部署教程

Vikunja 默认使用 SQLite，单容器即可运行，无需额外的数据库服务。

### 1. 配置 `.env`

```bash
# CUSTOM
TZ=Asia/Shanghai
SERV_PORT=3456

# Vikunja
# 公开访问地址（含端口，用于邮件链接、OAuth 回调等）
VIKUNJA_SERVICE_PUBLICURL=http://localhost:3456
# JWT 认证密钥，必须修改，使用 `openssl rand -hex 32` 生成
VIKUNJA_SERVICE_JWT_SECRET=<VIKUNJA_SERVICE_JWT_SECRET>
# SQLite 数据库文件路径（存入挂载目录随 ./data 持久化）
VIKUNJA_DATABASE_PATH=/app/vikunja/files/vikunja.db
```

> 若通过 `http://<ip>:3456` 等非标准端口访问，`VIKUNJA_SERVICE_PUBLICURL` 必须带上端口，否则注册账号时会报 "unauthorized" 错误。

### 2. 启动

```bash
docker compose up -d
```

访问 `http://<host>:3456` 即可打开页面，首次使用需注册账号。

### 3. 权限说明

Vikunja 容器以用户 `1000` 运行，若上传附件或修改项目背景报 `permission denied`，需先修正数据目录属主：

```bash
mkdir -p ./data
chown -R 1000 ./data
```

> 注意：镜像基于 `scratch`，容器内**没有 shell**（`docker exec -it vikunja sh` 不可用），也不支持 `PUID`/`PGID` 环境变量；如需以其他用户运行，请使用 compose 的 `user:` 指令。

## 使用 SQLite（默认）

默认方式，单容器即可运行，无需额外的数据库服务。上方「部署教程」即基于 SQLite，完整配置如下：

`.env` 配置：

```bash
# CUSTOM
TZ=Asia/Shanghai
SERV_PORT=3456

# Vikunja
# 公开访问地址（含端口，用于邮件链接、OAuth 回调等）
VIKUNJA_SERVICE_PUBLICURL=http://localhost:3456
# JWT 认证密钥，必须修改，使用 `openssl rand -hex 32` 生成
VIKUNJA_SERVICE_JWT_SECRET=<VIKUNJA_SERVICE_JWT_SECRET>
# SQLite 数据库文件路径（存入挂载目录随 ./data 持久化）
VIKUNJA_DATABASE_PATH=/app/vikunja/files/vikunja.db
```

`compose.yaml` 配置：

```yaml
---
# https://hub.docker.com/r/vikunja/vikunja
services:
  vikunja:
    container_name: vikunja
    env_file:
      - path: ./.env
        required: false
    image: vikunja/vikunja:latest
    ports:
      - ${SERV_PORT:-3456}:3456
    volumes:
      - ./data:/app/vikunja/files
    restart: unless-stopped
```

> 注意：不可将宿主目录挂载到 `/app/vikunja` —— 可执行文件位于 `/app/vikunja/vikunja`，覆盖该目录会导致容器报 `exec: "/app/vikunja/vikunja": no such file or directory` 无法启动。
>
> 官方镜像预置了 `VIKUNJA_DATABASE_PATH=/db/vikunja.db`（数据库默认存放在 `/db`），`.env` 中的 `VIKUNJA_DATABASE_PATH=/app/vikunja/files/vikunja.db` 是对该预置值的显式覆盖，使数据库文件与上传附件统一存放在 `./data` 挂载目录中。若保持官方默认，也可将挂载改为 `./data:/db`。

SQLite 数据库文件（`vikunja.db`）与上传附件均存放在 `./data` 目录中，备份方式见[数据备份](#数据备份)。

## 使用 PostgreSQL

如需使用 PostgreSQL，在 `.env` 中追加数据库配置：

```bash
# Database (PostgreSQL)
VIKUNJA_DATABASE_TYPE=postgres
VIKUNJA_DATABASE_HOST=db
VIKUNJA_DATABASE_USER=vikunja
VIKUNJA_DATABASE_PASSWORD=<VIKUNJA_DATABASE_PASSWORD>
VIKUNJA_DATABASE_DATABASE=vikunja
```

并在 `compose.yaml` 中增加 `db` 服务：

```yaml
---
# https://hub.docker.com/r/vikunja/vikunja
services:
  vikunja:
    container_name: vikunja
    env_file:
      - path: ./.env
        required: false
    image: vikunja/vikunja:latest
#     ports:
#       - ${SERV_PORT:-3456}:3456
    volumes:
      - ./data/files:/app/vikunja/files
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
  db:
    image: postgres:18
    environment:
      POSTGRES_USER: ${VIKUNJA_DATABASE_USER}
      POSTGRES_PASSWORD: ${VIKUNJA_DATABASE_PASSWORD}
      POSTGRES_DB: ${VIKUNJA_DATABASE_DATABASE}
    volumes:
      - ./data/db:/var/lib/postgresql
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h localhost -U $$POSTGRES_USER"]
      interval: 2s
      start_period: 30s
```

> 首次启动时数据库容器就绪较慢，Vikunja 可能连接失败退出，`restart: unless-stopped` 会自动重启并恢复。

## 使用 MySQL / MariaDB

如需使用 MySQL，在 `.env` 中追加数据库配置：

```bash
# Database (MySQL)
VIKUNJA_DATABASE_TYPE=mysql
VIKUNJA_DATABASE_HOST=db
VIKUNJA_DATABASE_USER=vikunja
VIKUNJA_DATABASE_PASSWORD=<VIKUNJA_DATABASE_PASSWORD>
VIKUNJA_DATABASE_DATABASE=vikunja
```

并在 `compose.yaml` 中增加 `db` 服务：

```yaml
---
# https://hub.docker.com/r/vikunja/vikunja
services:
  vikunja:
    container_name: vikunja
    env_file:
      - path: ./.env
        required: false
    image: vikunja/vikunja:latest
#     ports:
#       - ${SERV_PORT:-3456}:3456
    volumes:
      - ./data/files:/app/vikunja/files
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
  db:
    image: mariadb:11
    environment:
      MYSQL_ROOT_PASSWORD: ${VIKUNJA_DATABASE_PASSWORD}
      MYSQL_USER: ${VIKUNJA_DATABASE_USER}
      MYSQL_PASSWORD: ${VIKUNJA_DATABASE_PASSWORD}
      MYSQL_DATABASE: ${VIKUNJA_DATABASE_DATABASE}
    volumes:
      - ./data/db:/var/lib/mysql
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 2s
      start_period: 30s
```

> 使用 MySQL 时若报 `Migration failed: commands out of sync`，需停止容器后删除 `./data/db` 目录再重新启动。

## 数据备份

> Vikunja 中删除项目是**永久且不可恢复的**，没有回收站，请确保有可靠的备份策略。

需备份两部分：数据库与附件文件。

**SQLite**：直接复制数据库文件（`./data/vikunja.db`）即可。

**PostgreSQL**：

```bash
# 备份
docker compose exec db pg_dump -U vikunja vikunja > vikunja-backup.sql
# 恢复
docker compose exec -T db psql -U vikunja vikunja < vikunja-backup.sql
```

**MySQL / MariaDB**：

```bash
# 备份
docker compose exec db sh -c 'exec mariadb-dump -uvikunja -p"$MYSQL_PASSWORD" vikunja' > vikunja-backup.sql
# 恢复
docker compose exec -T db sh -c 'exec mariadb -uvikunja -p"$MYSQL_PASSWORD" vikunja' < vikunja-backup.sql
```

**附件文件**：直接复制 `./data/files/` 目录（`files.basepath` 相对于 `service.rootpath`，即容器内 `/app/vikunja/files`）。

也可配合项目根目录的 `backup.sh` 模板，将 `./data` 打包为 `.tar.xz` 归档。

## 反向代理（NGINX）

假设 Vikunja 运行在本机 `3456` 端口，`server_name` 按实际域名调整：

```conf
# WebSocket 升级所需，映射 $connection_upgrade
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen       80;
    server_name  vikunja.example.com;

    location / {
        proxy_pass http://127.0.0.1:3456;
        # 与 Vikunja 最大上传大小保持一致，调大上传限制时需同步修改
        client_max_body_size 20M;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 支持（/api/v2/ws），缺少会导致实时更新连接失败
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_read_timeout 3600s;
    }
}
```

反向代理后 Vikunja 默认记录到的是代理的地址，若需要让日志与限流识别真实客户端 IP，在 `.env` 中追加：

```bash
# 从 X-Forwarded-For 头提取客户端 IP
VIKUNJA_SERVICE_IPEXTRACTIONMETHOD=xff
# 仅信任代理来源地址，范围越小越安全，不要写成 10.0.0.0/8 这类宽网段
VIKUNJA_SERVICE_TRUSTEDPROXIES=127.0.0.1/32
```

## 相关链接

- [官方 Docker 部署教程](https://vikunja.io/docs/docker-start-to-finish)
- [配置选项](https://vikunja.io/docs/config-options)
- [反向代理示例](https://vikunja.io/docs/reverse-proxy)
