# ntfy

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [ntfy][1] 是一个简单的基于 HTTP 的发布-订阅 通知服务。使用 ntfy，您可以通过任何计算机的**脚本将通知发送到您的手机或桌面 ， 无需注册或支付任何费用**。如果您想运行自己的服务实例，可以轻松实现，因为 ntfy 是开源的。

[1]:https://ntfy.sh/
[2]:https://github.com/binwiederhier/ntfy
[3]:https://hub.docker.com/r/binwiederhier/ntfy
[4]:https://docs.ntfy.sh/

---

## APP（源码）
- Android: https://github.com/binwiederhier/ntfy-android
- iOS: https://github.com/binwiederhier/ntfy-ios

## 配置

### 版本对比

| 版本 | 新增字段 | 适用场景 |
|------|---------|---------|
| **基础版** | 无 | 个人/测试，开箱即用 |
| **+缓存+附件** | `base-url`, `cache-file`, `attachment-cache-dir` | 需要消息持久化和附件上传 |
| **+自建 HTTPS** | `listen-https`, `key-file`, `cert-file` | 不使用反向代理，自建 TLS |
| **+Nginx 反向代理** | `behind-proxy` | 生产环境，Nginx 处理 HTTPS |
| **+认证** | `auth-file`, `auth-default-access`, `auth-users` | 私有实例，需要用户认证 |
| **+Web Push+iOS** | `upstream-base-url`, `web-push-*` | 浏览器推送、iOS 推送 |
| **完整版** | `firebase-key-file`, `smtp-sender-*`, `smtp-server-*` | ntfy.sh 生产配置 |

#### 各版本新增字段说明

**缓存+附件版：**
- `base-url`: 公开访问的基础 URL，用于生成附件下载链接
- `cache-file`: 消息持久化缓存，支持 `since=` 和 `poll=1` 参数
- `attachment-cache-dir`: 附件存储目录

**自建 HTTPS 版：**
- `listen-https`: HTTPS 监听地址
- `key-file`: TLS 私钥文件
- `cert-file`: TLS 证书文件

**Nginx 反向代理版：**
- `behind-proxy`: 告诉 ntfy 使用 `X-Forwarded-For` 头识别访客 IP（用于限流）

**认证版：**
- `auth-file`: 用户/权限数据库，开启认证
- `auth-default-access`: 默认权限：`read-write`/`read-only`/`write-only`/`deny-all`
- `auth-users`: 预定义用户列表 (格式: `user:hash:role`)

**Web Push+iOS 版：**
- `upstream-base-url`: iOS 推送需要将轮询请求转发到 ntfy.sh
- `web-push-public-key`: Web Push VAPID 公钥（浏览器订阅用）
- `web-push-private-key`: Web Push VAPID 私钥
- `web-push-file`: Web Push 订阅存储数据库
- `web-push-email-address`: Web Push 管理邮箱

**完整版 (ntfy.sh)：**
- `firebase-key-file`: Firebase Cloud Messaging (Android 推送)
- `smtp-sender-*`: 邮件发送 (SMTP)
- `smtp-server-*`: 邮件接收 (允许发邮件到主题)

### Docker Compose (基础)
```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    container_name: ntfy
    command:
      - serve
    environment:
      - TZ=UTC
    volumes:
      - /var/cache/ntfy:/var/cache/ntfy
      - /etc/ntfy:/etc/ntfy
    ports:
      - 80:80
    restart: unless-stopped
```

### Docker Compose ([w/ auth, cache, attachments](https://docs.ntfy.sh/config/#__tabbed_2_1))
```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    restart: unless-stopped
    environment:
      NTFY_BASE_URL: http://ntfy.example.com
      NTFY_CACHE_FILE: /var/lib/ntfy/cache.db
      NTFY_AUTH_FILE: /var/lib/ntfy/auth.db
      NTFY_AUTH_DEFAULT_ACCESS: deny-all
      NTFY_AUTH_USERS: 'phil:$$2a$$10$$YLiO8U21sX1uhZamTLJXHuxgVC0Z/GKISibrKCLohPgtG7yIxSk4C:admin' # Must escape '$' as '$$'
      NTFY_BEHIND_PROXY: true
      NTFY_ATTACHMENT_CACHE_DIR: /var/lib/ntfy/attachments
      NTFY_ENABLE_LOGIN: true
    volumes:
      - ./:/var/lib/ntfy
    ports:
      - 80:80
    command: serve
```

### Docker Compose ([w/ auth, cache, web push, iOS](https://docs.ntfy.sh/config/#__tabbed_2_2))
```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    restart: unless-stopped
    environment:
      NTFY_BASE_URL: http://ntfy.example.com
      NTFY_CACHE_FILE: /var/lib/ntfy/cache.db
      NTFY_AUTH_FILE: /var/lib/ntfy/auth.db
      NTFY_AUTH_DEFAULT_ACCESS: deny-all
      NTFY_BEHIND_PROXY: true
      NTFY_ATTACHMENT_CACHE_DIR: /var/lib/ntfy/attachments
      NTFY_ENABLE_LOGIN: true
      NTFY_UPSTREAM_BASE_URL: https://ntfy.sh
      NTFY_WEB_PUSH_PUBLIC_KEY: <public_key>
      NTFY_WEB_PUSH_PRIVATE_KEY: <private_key>
      NTFY_WEB_PUSH_FILE: /var/lib/ntfy/webpush.db
      NTFY_WEB_PUSH_EMAIL_ADDRESS: <email>
    volumes:
      - ./:/var/lib/ntfy
    ports:
      - 8093:80
    command: serve
```

[配置选项说明](https://docs.ntfy.sh/config/#config-options)：

| 环境变量 | 说明 | 默认值 |
|---------|------|-------|
| `NTFY_BASE_URL` | ntfy 服务的基础 URL | - |
| `NTFY_LISTEN_HTTP` | HTTP 监听地址 | `:80` |
| `NTFY_CACHE_FILE` | 缓存文件的路径 | - |
| `NTFY_CACHE_DURATION` | 消息缓存时间 | `12h` |
| `NTFY_AUTH_FILE` | 认证数据库文件路径 | - |
| `NTFY_AUTH_DEFAULT_ACCESS` | 默认访问权限 | `read-write` |
| `NTFY_AUTH_USERS` | 用户列表 (格式: `user:hash:role`) | - |
| `NTFY_AUTH_ACCESS` | 访问控制列表 (格式: `user:topic:permission`) | - |
| `NTFY_AUTH_TOKENS` | 访问令牌列表 (格式: `user:token[:label]`) | - |
| `NTFY_BEHIND_PROXY` | 是否在代理后面运行 | `false` |
| `NTFY_PROXY_FORWARDED_HEADER` | 代理转发的请求头 | `X-Forwarded-For` |
| `NTFY_ATTACHMENT_CACHE_DIR` | 附件缓存目录的路径 | - |
| `NTFY_ATTACHMENT_TOTAL_SIZE_LIMIT` | 附件缓存总大小限制 | `5G` |
| `NTFY_ATTACHMENT_FILE_SIZE_LIMIT` | 单个附件大小限制 | `15M` |
| `NTFY_ATTACHMENT_EXPIRY_DURATION` | 附件过期时间 | `3h` |
| `NTFY_ENABLE_LOGIN` | 是否启用登录 | `false` |
| `NTFY_ENABLE_SIGNUP` | 是否启用注册 | `false` |
| `NTFY_ENABLE_RESERVATIONS` | 是否允许预留主题 | `false` |
| `NTFY_REQUIRE_LOGIN` | 是否要求登录 | `false` |
| `NTFY_UPSTREAM_BASE_URL` | 上游 ntfy 服务的基础 URL (iOS 推送) | - |
| `NTFY_UPSTREAM_ACCESS_TOKEN` | 上游服务访问令牌 | - |
| `NTFY_WEB_PUSH_PUBLIC_KEY` | Web Push 公钥 | - |
| `NTFY_WEB_PUSH_PRIVATE_KEY` | Web Push 私钥 | - |
| `NTFY_WEB_PUSH_FILE` | Web Push 文件的路径 | - |
| `NTFY_WEB_PUSH_EMAIL_ADDRESS` | Web Push 邮箱地址 | - |
| `NTFY_SMTP_SENDER_ADDR` | SMTP 服务器地址 | - |
| `NTFY_SMTP_SENDER_USER` | SMTP 用户名 | - |
| `NTFY_SMTP_SENDER_PASS` | SMTP 密码 | - |
| `NTFY_SMTP_SENDER_FROM` | SMTP 发件人地址 | - |
| `NTFY_SMTP_SERVER_LISTEN` | SMTP 服务器监听地址 | - |
| `NTFY_SMTP_SERVER_DOMAIN` | SMTP 服务器域名 | - |
| `NTFY_SMTP_SERVER_ADDR_PREFIX` | SMTP 地址前缀 | - |
| `NTFY_TWILIO_ACCOUNT` | Twilio 账户 SID | - |
| `NTFY_TWILIO_AUTH_TOKEN` | Twilio 认证令牌 | - |
| `NTFY_TWILIO_PHONE_NUMBER` | Twilio 电话号码 | - |
| `NTFY_TWILIO_VERIFY_SERVICE` | Twilio Verify 服务 SID | - |
| `NTFY_KEEPALIVE_INTERVAL` | Keepalive 间隔 | `45s` |
| `NTFY_MANAGER_INTERVAL` | 管理器间隔 | `1m` |
| `NTFY_MESSAGE_SIZE_LIMIT` | 消息大小限制 | `4K` |
| `NTFY_MESSAGE_DELAY_LIMIT` | 消息延迟限制 | `3d` |
| `NTFY_GLOBAL_TOPIC_LIMIT` | 全局主题数量限制 | `15000` |
| `NTFY_VISITOR_SUBSCRIPTION_LIMIT` | 访客订阅数量限制 | `30` |
| `NTFY_VISITOR_MESSAGE_DAILY_LIMIT` | 访客每日消息限制 | - |
| `NTFY_VISITOR_REQUEST_LIMIT_BURST` | 访客请求突发限制 | `60` |
| `NTFY_VISITOR_REQUEST_LIMIT_REPLENISH` | 访客请求补充间隔 | `5s` |
| `NTFY_WEB_ROOT` | Web 应用根路径 | `/` |
| `NTFY_LOG_FORMAT` | 日志格式 (`text`/`json`) | `text` |
| `NTFY_LOG_FILE` | 日志文件路径 | - |
| `NTFY_LOG_LEVEL` | 日志级别 (`trace`/`debug`/`info`/`warn`/`error`) | `info` |

### SMTP 说明

SMTP 有两种用途：

#### 1. 邮件通知发送 (smtp-sender-*)
发布消息时设置 `X-Email` 头即可将通知发送到邮箱。

```bash
curl -d "hi there" -H "X-Email: phil@example.com" ntfy.sh/mytopic
```

需要配置：
- `smtp-sender-addr`: SMTP 服务器地址 (如 `email-smtp.us-east-2.amazonaws.com:587`)
- `smtp-sender-user`: SMTP 用户名
- `smtp-sender-pass`: SMTP 密码
- `smtp-sender-from`: 发件人地址 (如 `ntfy@ntfy.sh`)

#### 2. 邮件发布消息 (smtp-server-*)
允许通过发送邮件来发布消息到主题。

```
收件人: mytopic@ntfy.sh
内容: 服务器告警
```

需要配置：
- `smtp-server-listen`: 监听地址 (如 `:25`)
- `smtp-server-domain`: 邮件域名 (如 `ntfy.sh`)
- `smtp-server-addr-prefix`: 可选前缀 (如 `ntfy-`，则需发到 `ntfy-mytopic@ntfy.sh`)

**简单理解：**
- `smtp-sender-*`: ntfy **发**邮件给你
- `smtp-server-*`: 你发邮件 **给** ntfy (发布消息)

### Twilio 说明

Twilio 用于电话通知。发布消息时设置 `X-Call` 头即可收到电话通知。

```bash
curl -d "hi there" -H "X-Call: +1234567890" ntfy.sh/mytopic
```

需要配置：
- `twilio-account`: Twilio 账户 SID (如 `AC12345...`)
- `twilio-auth-token`: Twilio 认证令牌
- `twilio-phone-number`: 外呼电话号码 (如 `+18775132586`)
- `twilio-verify-service`: Twilio Verify 服务 SID (用于号码验证)

### 反向代理设置
```bash
# /etc/nginx/sites-*/ntfy
#
# This config requires the use of the -L flag in curl to redirect to HTTPS, and it keeps nginx output buffering
# enabled. While recommended, I have had issues with that in the past.
```

```nginx
server {
  listen 80;
  server_name ntfy.sh;

  location / {
    return 302 https://$http_host$request_uri$is_args$query_string;

    proxy_pass http://127.0.0.1:2586;
    proxy_http_version 1.1;

    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_connect_timeout 3m;
    proxy_send_timeout 3m;
    proxy_read_timeout 3m;

    client_max_body_size 0; # Stream request body to backend
  }
}
```

```nginx
server {
  listen 443 ssl http2;
  server_name ntfy.sh;

  # See https://ssl-config.mozilla.org/#server=nginx&version=1.18.0&config=intermediate&openssl=1.1.1k&hsts=false&ocsp=false&guideline=5.6
  ssl_session_timeout 1d;
  ssl_session_cache shared:MozSSL:10m; # about 40000 sessions
  ssl_session_tickets off;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
  ssl_prefer_server_ciphers off;

  ssl_certificate /etc/letsencrypt/live/ntfy.sh/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/ntfy.sh/privkey.pem;

  location / {
    proxy_pass http://127.0.0.1:2586;
    proxy_http_version 1.1;

    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_connect_timeout 3m;
    proxy_send_timeout 3m;
    proxy_read_timeout 3m;

    client_max_body_size 0; # Stream request body to backend
  }
}
```

### 用户管理

ntfy 支持基于用户名/密码的认证和基于访问令牌（Access Token）的认证。

#### 认证相关配置

| 环境变量 | 说明 | 默认值 |
|---------|------|-------|
| `NTFY_AUTH_FILE` | 认证数据库文件路径 | - |
| `NTFY_AUTH_DEFAULT_ACCESS` | 默认访问权限 | `read-write` |
| `NTFY_AUTH_USERS` | 用户列表 (格式: `user:hash:role`) | - |
| `NTFY_AUTH_ACCESS` | 访问控制列表 (格式: `user:topic:permission`) | - |
| `NTFY_AUTH_TOKENS` | 访问令牌列表 (格式: `user:token[:label]`) | - |

#### 用户和角色

ntfy 有两种角色：
- `user` (默认): 普通用户，需要通过 ACL 配置主题访问权限
- `admin`: 管理员，有所有主题的读写权限

**CLI 命令：**

```bash
# 添加用户
ntfy user add phil                 # 添加普通用户
ntfy user add --role=admin phil    # 添加管理员用户

# 删除用户
ntfy user del phil

# 修改密码
ntfy user change-pass phil

# 修改角色
ntfy user change-role phil admin

# 生成密码哈希（用于配置文件）
ntfy user hash
```

**配置文件方式：**

```yaml
auth-file: "/var/lib/ntfy/user.db"
auth-users:
  - "phil:$2a$10$YLiO8U21sX1uhZamTLJXHuxgVC0Z/GKISibrKCLohPgtG7yIxSk4C:admin"
  - "ben:$2a$10$NKbrNb7HPMjtQXWJ0f1pouw03LDLT/WzlO9VAv44x84bRCkh19h6m:user"
```

密码哈希可以使用 `ntfy user hash` 命令生成。

#### 访问控制列表 (ACL)

ACL 管理非管理员用户和匿名用户对主题的访问权限。

**权限类型：**
- `read-write` / `rw`: 读和写
- `read-only` / `ro`: 只读
- `write-only` / `wo`: 只写
- `deny` / `none`: 拒绝

**CLI 命令：**

```bash
# 查看 ACL
ntfy access                        # 查看所有访问控制
ntfy access phil                   # 查看用户 phil 的访问权限

# 设置访问权限
ntfy access phil mytopic rw        # 允许用户 phil 读写 mytopic
ntfy access everyone mytopic rw    # 允许匿名用户读写 mytopic
ntfy access everyone "up*" write   # 允许匿名用户写权限到 up* 主题

# 重置权限
ntfy access --reset                # 重置所有 ACL
ntfy access --reset phil          # 重置用户 phil 的所有权限
ntfy access --reset phil mytopic   # 重置用户 phil 对 mytopic 的权限
```

**配置文件方式：**

```yaml
auth-access:
  - "phil:mytopic:rw"
  - "ben:alerts-*:rw"
  - "ben:system-logs:ro"
  - "*:announcements:ro"           # 匿名用户只读访问
```

主题支持通配符 `*`，例如 `alerts-*` 匹配所有以 `alerts-` 开头的主题。

#### 访问令牌

访问令牌可以代替用户名/密码进行认证，适合在脚本中使用。

**CLI 命令：**

```bash
# 查看令牌
ntfy token list                    # 查看所有用户的令牌
ntfy token list phil               # 查看用户 phil 的令牌

# 添加令牌
ntfy token add phil                # 创建永久令牌
ntfy token add --expires=30d phil  # 创建 30 天过期的令牌

# 删除令牌
ntfy token remove phil tk_xxx...

# 生成随机令牌
ntfy token generate
```

**配置文件方式：**

```yaml
auth-tokens:
  - "phil:tk_3gd7d2yftt4b8ixyfe9mnmro88o76"
  - "backup-service:tk_f099we8uzj7xi5qshzajwp6jffvkz:Backup script"
```

令牌必须以 `tk_` 开头，共 32 个字符。

**使用令牌：**

```bash
# 发布消息
curl -H "Authorization: Bearer tk_xxx" -d "message" https://ntfy.sh/mytopic

# 订阅消息
ntfy subscribe -t tk_xxx https://ntfy.sh/mytopic
```

#### 私有实例配置示例

```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    restart: unless-stopped
    environment:
      NTFY_AUTH_FILE: /var/lib/ntfy/auth.db
      NTFY_AUTH_DEFAULT_ACCESS: deny-all      # 默认拒绝所有访问
      NTFY_AUTH_USERS: 'phil:$2a$10$YLiO8U21sX1uhZamTLJXHuxgVC0Z/GKISibrKCLohPgtG7yIxSk4C:admin'
      NTFY_AUTH_ACCESS: 'backup-script:backups:rw'
      NTFY_AUTH_TOKENS: 'phil:tk_3gd7d2yftt4b8ixyfe9mnmro88o76:My personal token'
    volumes:
      - ./data:/var/lib/ntfy
    ports:
      - 80:80
    command: serve
```

这个配置：
- 默认拒绝所有匿名访问 (`deny-all`)
- 管理员 `phil` 可以访问所有主题
- 普通用户 `backup-script` 只能访问 `backups` 主题
- 支持通过 Basic Auth 或 Access Token 进行认证

#### UnifiedPush 配置

详见 [unifiedpush.md](./unifiedpush.md)

[设置密码](https://docs.ntfy.sh/config/#users-and-roles)
```bash
docker exec -it ntfy ntfy user add --role=admin phil
```

## 测试
```bash
# CURL 无密钥
curl -d "Backup successful 😀" ntfy.sh/mytopic

# CURL 密钥
curl -u testuser:fakepassword -d "Backup successful 😀" ntfy.sh/mytopic

# CLI
ntfy publish ntfy.sh/mytopic "Backup successful 😀"

# CLI 密钥
ntfy publish -u testuser:fakepassword ntfy.sh/mytopic "Backup successful 😀"
```
