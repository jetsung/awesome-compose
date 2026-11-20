# acme-dns

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [acme-dns][1] 是一款简化版 DNS 服务器，附带 RESTful HTTP API，用于自动化 ACME DNS 质询。其具备的部分功能如下：

- 简化 DNS 服务器，服务 ACME DNS 质询（TXT 记录）。
- 支持自定义记录（A、AAAA、NS 等）。
- HTTP API 自动通过 Let's Encrypt 获取 TLS 证书。
- 支持按 CIDR 限制 `/update` 端点访问。
- 支持 SQLite 与 PostgreSQL 后端。
- 双 TXT 记录滚动更新，兼容 `domain.tld` 与 `*.domain.tld` 证书。

[1]:https://github.com/acme-dns/acme-dns
[2]:https://github.com/acme-dns/acme-dns
[3]:https://hub.docker.com/r/joohoi/acme-dns
[4]:https://github.com/acme-dns/acme-dns/blob/master/README.md

---

## 部署

```bash
mkdir data
# 修改 config/config.cfg 中的 domain、nsadmin、records 等配置
docker compose up -d
```

默认配置文件为 [`config/config.cfg`](config/config.cfg)，共 4 个配置段，主要配置项：

### `[general]`

| 配置项 | 说明 | 默认值 |
| --- | --- | --- |
| `listen` | DNS 监听地址。注意 systemd-resolved 可能占用 `127.0.0.53:53`，此时需改监听地址 | `127.0.0.1:53` |
| `protocol` | DNS 协议：`both`、`both4`、`both6`、`udp`、`udp4`、`udp6`、`tcp`、`tcp4`、`tcp6` | `both` |
| `domain` | 提供服务的域名 | `auth.example.org` |
| `nsname` | 区域名（zone）的 NS 服务器名 | `auth.example.org` |
| `nsadmin` | 管理员邮箱，`@` 会替换为 `.`（如 `admin.example.org`） | `admin.example.org` |
| `records` | 除 TXT 外额外提供的预定义记录，通常为指向本机公网 IP 的 A 记录和泛解析 NS 记录 | `["auth.example.org. A 198.51.100.1", "auth.example.org. NS auth.example.org."]` |
| `debug` | 输出 CORS 等调试信息 | `false` |

### `[database]`

| 配置项 | 说明 | 默认值 |
| --- | --- | --- |
| `engine` | 数据库引擎：`sqlite` 或 `postgres` | `sqlite` |
| `connection` | 连接串：sqlite 为文件路径（Docker 镜像默认 `/var/lib/acme-dns/acme-dns.db`），postgres 为 `postgres://user:password@host/db_name` | `acme-dns.db` |

### `[api]`

| 配置项 | 说明 | 默认值 |
| --- | --- | --- |
| `ip` | API 监听 IP | `0.0.0.0` |
| `port` | API 监听端口，HTTPS 默认 `443` | `443` |
| `tls` | TLS 方式：`letsencrypt` / `letsencryptstaging` / `cert` / `none` | `none` |
| `disable_registration` | 禁用 `/register` 注册端点 | `false` |
| `tls_cert_privkey` | 仅 `tls = "cert"` 时使用，TLS 私钥路径 | `/etc/tls/example.org/privkey.pem` |
| `tls_cert_fullchain` | 仅 `tls = "cert"` 时使用，TLS 证书链路径 | `/etc/tls/example.org/fullchain.pem` |
| `acme_cache_dir` | 仅 `tls = "letsencrypt"` 时使用，证书缓存目录 | `api-certs` |
| `notification_email` | 可选邮箱，Let's Encrypt 向其发送证书到期通知 | 空 |
| `corsorigins` | CORS AllowOrigins，支持通配符 | `["*"]` |
| `use_header` | 是否从 HTTP 请求头获取客户端 IP（反代场景） | `false` |
| `header_name` | `use_header = true` 时提取 IP 的请求头名 | `X-Forwarded-For` |
| `hsts_enabled` | 启用 HSTS（HTTP 严格传输安全） | `false` |
| `hsts_max_age` | HSTS 有效期（秒），默认 1 年 | `31536000` |
| `hsts_include_subdomains` | HSTS 包含子域名指令 | `false` |
| `hsts_preload` | HSTS preload 指令 | `false` |

### `[logconfig]`

| 配置项 | 说明 | 默认值 |
| --- | --- | --- |
| `loglevel` | 日志级别：`error` / `warning` / `info` / `debug` | `info` |
| `logtype` | 日志输出：`stdout` 或 `file` | `stdout` |
| `logfile` | `logtype = "file"` 时的日志文件路径 | `./acme-dns.log` |
| `logformat` | 日志格式：`json` 或 `text` | `json` |

## Nginx 反向代理

用 Nginx 反代 API（DNS 流量 `53` 端口不走 HTTP，仍需直接映射）：

```nginx
server {
    listen 443 ssl;
    server_name auth.example.org;

    ssl_certificate     /etc/letsencrypt/live/auth.example.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/auth.example.org/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

对应将 `config.cfg` 中 API 监听改为本机端口，并启用从请求头获取客户端 IP：

```ini
[api]
ip = "127.0.0.1"
port = "8080"
tls = "none"          # TLS 由 Nginx 终结
use_header = true     # 从请求头获取客户端真实 IP
header_name = "X-Forwarded-For"
```

> 若启用了 CIDR 限制 `/update`，`use_header = true` 后校验的是请求头中的真实客户端 IP，而非 Nginx 的地址。

## RESTful API

### 注册 `/register`

`POST /register` 返回新的唯一子域名及更新记录所需的凭据。`fulldomain` 即为 `_acme-challenge` CNAME 记录的指向目标。

可选：通过 POST JSON 数据（CIDR 表示法）限制 `/update` 请求的来源网络。

```bash
curl -X POST https://auth.example.org/register
# 可选限制来源网络
curl -X POST -d '{"allowfrom": ["192.168.100.1/24"]}' https://auth.example.org/register
```

响应 `Status: 201 Created`：

```json
{
    "allowfrom": [],
    "fulldomain": "8e5700ea-a4bf-41c7-8a77-e990661dcc6a.auth.example.org",
    "password": "htB9mR9DYgcu9bX_afHF62erXaH2TS7bg9KW3F7Z",
    "subdomain": "8e5700ea-a4bf-41c7-8a77-e990661dcc6a",
    "username": "c36f50e8-4632-44f0-83fe-e070fef28a10"
}
```

### 更新 `/update`

`POST /update` 更新唯一子域名的 TXT 记录内容，通常由自动化 ACME 客户端调用。

必需请求头：

| 请求头 | 说明 |
| --- | --- |
| `X-Api-User` | 注册返回的 UUIDv4 用户名 |
| `X-Api-Key` | 注册返回的密码 |

```bash
curl -X POST \
  -H "X-Api-User: <username>" \
  -H "X-Api-Key: <password>" \
  -d '{"subdomain": "<subdomain>", "txt": "___validation_token_received_from_the_ca___"}' \
  https://auth.example.org/update
```

响应 `Status: 200 OK`：

```json
{
    "txt": "___validation_token_received_from_the_ca___"
}
```

注意：`txt` 字段长度必须恰好为 43 个字符，否则会被拒绝。

验证 TXT 记录已生效：

```bash
dig -t txt @auth.example.org <subdomain>.auth.example.org
```

### 健康检查 `/health`

`GET /health` 用于检查服务就绪/存活状态，成功返回 `Status: 200 OK`。

## DNS 记录

在主域名 DNS 服务器上添加（以 `auth.example.org` 为例，`198.51.100.1` 为 acme-dns 服务器公网 IP）：

| 记录类型 | 示例 |
| --- | --- |
| NS | `auth.example.org. NS auth.example.org.` |
| A | `auth.example.org. A 198.51.100.1` |
| AAAA | `auth.example.org. A <IPv6 地址>`（如使用 IPv6） |
| CNAME | 每个待认证域名添加 `_acme-challenge` 子域名记录 |

## 使用教程

以 `example.com` 为待签域名、`auth.example.org` 为 acme-dns 服务域名，完整走一遍证书签发流程：

### 第 1 步：部署服务

```bash
mkdir data
# 修改 config/config.cfg 中的 domain、nsname、records 等配置
docker compose up -d
# 检查服务就绪状态
curl https://auth.example.org/health
```

### 第 2 步：配置主域名 DNS

在 `example.com` 所在的 DNS 服务商处，将 `_acme-challenge` 子域名 CNAME 到 acme-dns 的注册子域名（先随便指向，注册后再改）：

```
# acme-dns 服务器自身的权威配置（在 auth.example.org 的 DNS 处）
auth.example.org.        NS    auth.example.org.
auth.example.org.        A     198.51.100.1

# 待签域名的 CNAME 转发（在 example.com 的 DNS 处，注册后填写实际值）
_acme-challenge.example.com.  CNAME  <subdomain>.auth.example.org.
```

### 第 3 步：注册获取凭据

```bash
curl -X POST https://auth.example.org/register
```

记录返回的 `username`、`password`、`subdomain`、`fulldomain`，并将第 2 步的 CNAME 改为指向 `fulldomain`。

### 第 4 步：验证 DNS 解析

```bash
# TXT 记录写入测试
curl -X POST \
  -H "X-Api-User: <username>" \
  -H "X-Api-Key: <password>" \
  -d '{"subdomain": "<subdomain>", "txt": "___validation_token_received_from_the_ca___"}' \
  https://auth.example.org/update

# 确认 TXT 已生效
dig -t txt <subdomain>.auth.example.org
```

### 第 5 步：配置 ACME 客户端签发证书

以 `acme.sh` 为例（`certbot` / `lego` 等同理，选择 `acme-dns` DNS provider 并填入第 3 步的凭据）：

```bash
acme.sh --issue --dns dns_acmedns \
  -d example.com \
  --acmedns-api-url https://auth.example.org \
  --acmedns-username <username> \
  --acmedns-password <password> \
  --acmedns-subdomain <subdomain>
```

客户端流程为自动的：调用 `/register`（或复用已有凭据）→ 通过 `/update` 写入质询 TXT → Let's Encrypt 查询 TXT 完成验证 → 签发证书。

### 第 6 步：证书续期

证书有效期为 90 天。ACME 客户端定时续期时会复用注册凭据自动更新 TXT 记录，无需人工干预；acme-dns 服务本身无状态变更，仅需保证容器持续运行、数据卷 `./data`（SQLite 数据库）持久化。
