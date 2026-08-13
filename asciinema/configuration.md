# Asciinema 服务器配置

> 参考文档：[Self-hosting Configuration](https://docs.asciinema.org/manual/server/self-hosting/configuration/)

---

## 通用配置

### 基础 URL

设置服务器公网访问地址，用于生成链接和直播 WebSocket URL。

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `URL_HOST` | 公网主机名（域名或 IP） | `localhost` |
| `URL_PORT` | 公网端口 | `4000` |
| `URL_SCHEME` | 公网 URL 协议（`http` 或 `https`） | `http` |

> `URL_PORT` 仅影响生成的 URL，不改变服务器监听端口。容器内部监听端口默认为 `4000`，可通过 `PORT` 变量覆盖。

**HTTP 示例：**
```yaml
services:
  asciinema:
    ports:
      - '80:4000'
    environment:
      - URL_HOST=asciinema.example.com
      - URL_PORT=80
```

**HTTPS 示例：**
```yaml
services:
  asciinema:
    environment:
      - URL_HOST=asciinema.example.com
      - URL_SCHEME=https
```

> 设置 `URL_SCHEME=https` 时端口自动设为 443，可通过 `URL_PORT` 覆盖。

### 密钥基础

`SECRET_KEY_BASE` 用于加密操作（签名和验证会话 Cookie），必须设置为 64 个（或更多）随机字符。

```yaml
services:
  asciinema:
    environment:
      - SECRET_KEY_BASE=...
```

生成命令：
```sh
tr -dc A-Za-z0-9 </dev/urandom | head -c 64; echo
```

> 未设置时服务器仍可启动，但登录会话在容器重启后失效。

### 注册

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `SIGN_UP_DISABLED` | 关闭公开注册，仅允许现有用户登录 | `false` |

### 头像

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DEFAULT_AVATAR` | 头像类型（`identicon` 或 `gravatar`） | `identicon` |

### 管理员联系邮箱

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `CONTACT_EMAIL_ADDRESS` | 管理员联系邮箱，显示在 `/about` 页面 | 未设置 |

### 管理面板

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `ADMIN_PANEL_ON_MAIN_ENDPOINT` | 在主端点 `/admin` 上启用管理面板 | 未设置（仅在 4002 端口可用） |

### 时区

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `TZ` | 服务器时区，如 `Europe/Berlin` | UTC |

---

## 数据库

asciinema 使用 PostgreSQL 数据库存储录制元数据和用户账户信息。

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DATABASE_URL` | 数据库连接 URL | `postgresql://postgres@postgres/postgres` |

格式：`postgresql://用户名:密码@主机名:端口/数据库名`

额外参数（拼接在 URL 末尾 `?` 后）：
- `ssl=true` — 启用连接加密，默认 `false`
- `pool_size=N` — 连接池大小，默认 10

示例：
```
DATABASE_URL=postgresql://asciinema:xxx@10.9.8.7/asciinema?ssl=true&pool_size=2
```

---

## 文件存储

上传的 asciicast 文件可存储在本地文件系统或 S3 兼容对象存储中。

### 本地文件系统

文件保存在 `/var/lib/asciinema`，需映射卷以持久化数据：

```yaml
services:
  asciinema:
    volumes:
      - asciinema_data:/var/lib/asciinema

volumes:
  asciinema_data:
```

### AWS S3

| 变量 | 说明 |
|------|------|
| `S3_BUCKET` | S3 存储桶名称 |
| `S3_ACCESS_KEY_ID` | AWS 访问密钥 ID |
| `S3_SECRET_ACCESS_KEY` | AWS 秘密访问密钥 |
| `S3_REGION` | 区域，如 `us-east-1` |

### Cloudflare R2

| 变量 | 说明 |
|------|------|
| `S3_BUCKET` | R2 存储桶名称 |
| `S3_ENDPOINT` | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` |
| `S3_ACCESS_KEY_ID` | R2 访问密钥 ID |
| `S3_SECRET_ACCESS_KEY` | R2 秘密访问密钥 |
| `S3_REGION` | `auto` |

---

## 邮件（SMTP）

未配置 SMTP 时，登录链接会写入服务器日志，仍可登录。

### SMTP 基本设置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `SMTP_HOST` | SMTP 服务器主机名（必填） | — |
| `SMTP_PORT` | SMTP 端口 | `587` |
| `SMTP_USERNAME` | SMTP 用户名 | — |
| `SMTP_PASSWORD` | SMTP 密码 | — |

### SMTP 加密与认证

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `SMTP_TLS` | TLS 加密方式：`always` / `never` / `if_available` | `if_available` |
| `SMTP_ALLOWED_TLS_VERSIONS` | 允许的 TLS 版本（逗号分隔） | `tlsv1,tlsv1.1,tlsv1.2` |
| `SMTP_AUTH` | 认证方式：`always` / `if_available` | `if_available` |
| `SMTP_NO_MX_LOOKUPS` | 禁用 MX 查找，直接连接收件人域名服务器 | `false` |

### 邮件头设置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `MAIL_FROM_ADDRESS` | 发件人地址（From 头） | `hello@$URL_HOST` |
| `MAIL_REPLY_TO_ADDRESS` | 回复地址（Reply-To 头） | `admin@$URL_HOST` |

### 测试邮件配置

```sh
docker compose exec asciinema send-test-email your@email.example.com
```

---

## 上传配置

### 上传认证

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `UPLOAD_AUTH_REQUIRED` | 上传是否需要通过 `asciinema auth` 认证 | `false` |

### 未注册上传限制

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `UNREGISTERED_UPLOAD_COUNT_LIMIT` | 未注册 CLI 的最大上传数量（`0` 表示禁止所有未注册上传） | 无限制 |

> 未设置时无限制；设为 `0` 比 `UPLOAD_AUTH_REQUIRED=true` 更严格。

### 录制可见性

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DEFAULT_RECORDING_VISIBILITY` | 新录制文件的默认可见性：`public` / `unlisted` / `private` | `unlisted` |

### 上传路径模板

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `UPLOAD_PATH_TPL` | 上传文件存储路径模板 | `recordings/{username}/{year}/{month}/{day}/{id}.{ext}` |

支持的占位符：
- `{id}` — 录制文件数字 ID
- `{username}` — 录制者用户名
- `{shard}` — 基于数字 ID 的 2 级目录分片
- `{ext}` — 文件扩展名（`cast` 或 `json`）
- `{year}`、`{month}`、`{day}` — 当前日期

> 更改此值后，服务器会自动通过后台任务迁移文件到新位置（每日运行）。

### 上传大小限制

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `UPLOAD_SIZE_LIMIT` | 上传文件大小限制（字节） | `8000000`（8 MB） |

### 未认领录制清理

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `UNCLAIMED_RECORDING_TTL` | 未认领录制文件的保留天数。支持两阶段：`"7,30"` 表示 7 天后软删除，30 天后永久删除 | 永久保留 |

---

## 直播配置

### 直播功能

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DEFAULT_STREAMING_ENABLED` | 是否默认对所有用户启用直播功能 | `true` |

> 可在管理面板中单独禁用每个用户的直播。

### 直播录制

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `STREAM_RECORDING` | 直播自动录制模式：`allowed`（用户控制）/ `forced`（强制录制）/ `disabled`（禁用） | `allowed` |

### 直播可见性

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DEFAULT_STREAM_VISIBILITY` | 新直播流的默认可见性：`public` / `unlisted` / `private` | `unlisted` |

### 直播数量限制

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DEFAULT_STREAM_LIMIT` | 用户默认最大直播流数量 | 无限制 |

> 更改此默认值仅影响新用户，已有用户需在管理面板单独修改。

---

## HTTPS 配置

### Caddy（推荐）

```yaml
services:
  asciinema:
    environment:
      - URL_HOST=asciinema.example.com
      - URL_SCHEME=https

  caddy:
    image: caddy:2
    command: caddy reverse-proxy --from https://asciinema.example.com --to http://asciinema:4000
    ports:
      - '80:80'
      - '443:443'
      - '443:443/udp'
    volumes:
      - caddy_data:/data
      - caddy_config:/config
```

### 其他反向代理

```yaml
services:
  asciinema:
    ports:
      - '4000:4000'
    environment:
      - URL_HOST=asciinema.example.com
      - URL_SCHEME=https
```

---

## 高级配置

### 自定义 Phoenix 配置

创建 `custom.exs` 文件并挂载到容器中：

```elixir
# custom.exs
import Config

config :asciinema,
  foo: 123,
  bar: "baz"
```

```yaml
services:
  asciinema:
    volumes:
      - asciinema_data:/var/lib/asciinema
      - ./custom.exs:/opt/app/etc/custom.exs
```

### 自定义 TLS 客户端证书

用于 S3 服务器使用自签名证书的场景：

```elixir
# custom.exs
import Config

config :ex_aws, :hackney_opts,
  ssl_options: [
    verify: :verify_peer,
    cacertfile: "/usr/local/share/ca-certificates/truststore.pem"
  ]
```