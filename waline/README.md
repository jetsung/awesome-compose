# Waline

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Waline-mini][1] 是原 Waline 评论系统的 Rust 语言高性能实现版本。它旨在为资源受限的服务器提供一个轻量级、高效率的替代方案，在保持与原版功能同步的同时，极大地降低了系统资源消耗。
>
> **特点**：内存占用极低（相比 Node.js 版本减少约 95%）、零依赖（单可执行文件）、原生支持 SQLite/MySQL/PostgreSQL。

[1]:https://github.com/JQiue/waline-mini
[2]:https://github.com/JQiue/waline-mini
[3]:https://hub.docker.com/r/jqiue/waline-mini
[4]:https://github.com/JQiue/waline-mini/blob/dev/README.zh-CN.md

---

## 设置

### 环境变量

| 环境变量 | 是否必填 | 默认值 | 描述 (参考值) |
| :--- | :---: | :--- | :--- |
| **DATABASE_URL** | ✅ | - | 数据库连接字符串，支持 SQLite, MySQL, PostgreSQL。详见下方说明。 |
| **JWT_TOKEN** | ✅ | - | 用于 JWT 签名的随机字符串，建议使用复杂随机字符。 |
| **SITE_NAME** | ✅ | - | 你的网站名称。 |
| **SITE_URL** | ✅ | - | 你的网站访问地址，例如: `https://your-blog-domain.com` |
| **SERVER_URL** | 否 | auto | 自定义 Waline 服务端地址，建议填写以防自动识别错误。 |
| **HOST** | 否 | 127.0.0.1 | 服务监听地址。 |
| **PORT** | 否 | 8360 | 服务监听端口。 |
| **WORKERS** | 否 | 1 | 工作线程数量。 |
| **SECURE_DOMAINS** | 否 | - | 安全域名白名单，若非必要不建议设置（否则可能因 Referer 不匹配导致 403 错误）。 |
| **IPQPS** | 否 | 60 | IP 发帖频率限制 (秒)，设为 0 表示无限制。 |
| **COMMENT_AUDIT** | 否 | false | 是否开启评论审核。 |
| **AKISMET_KEY** | 否 | - | Akismet 防垃圾评论服务密钥。 |
| **LOGIN** | 否 | false | 是否强制要求登录才能评论，设为 `force` 开启。 |
| **FORBIDDEN_WORDS** | 否 | - | 违禁词列表，逗号分隔。 |
| **DISALLOW_IP_LIST** | 否 | - | 禁止访问的 IP 列表，逗号分隔。 |
| **DISABLE_AUTHOR_NOTIFY** | 否 | false | 是否关闭作者通知。 |
| **DISABLE_REGION** | 否 | false | 是否隐藏评论者地区信息。 |
| **DISABLE_USERAGENT** | 否 | false | 是否隐藏评论者 User-Agent。 |
| **IP2REGION_DB** | 否 | - | 自定义 IP 查询数据库文件路径。 |
| **SMTP_SERVICE** | 否 | - | SMTP 服务商，支持 `QQ`, `GMail`, `126`, `163`。 |
| **SMTP_HOST** | 否 | - | SMTP 服务器地址。 |
| **SMTP_PORT** | 否 | - | SMTP 服务器端口。 |
| **SMTP_USER** | 否 | - | SMTP 用户名。 |
| **SMTP_PASS** | 否 | - | SMTP 密码。 |
| **AUTHOR_EMAIL** | 否 | - | 站长邮箱，匹配该邮箱的评论不触发通知。 |
| **OAUTH_URL** | 否 | https://oauth.lithub.cc | OAuth 中转服务地址，可[自建][5]。 |
...
[5]:https://github.com/walinejs/auth

### 配置示例

```bash
# 数据库连接字符串
DATABASE_URL=sqlite:////app/db/waline.sqlite?mode=rwc

# JWT 签名密钥
JWT_TOKEN=YOUR_JWT_TOKEN

# 网站信息
SITE_NAME=YOUR_SITE_NAME
SITE_URL=https://your-blog-domain.com
SERVER_URL=https://your-comment-service-domain.com

# 服务配置
HOST=127.0.0.1
PORT=8360
WORKERS=1

# 安全域名白名单
# 若非必要不建议设置，否则可能因 Referer 不匹配导致 403 错误
SECURE_DOMAINS=your-blog-domain.com,your-comment-service-domain.com

# 垃圾评论与限制
IPQPS=60
COMMENT_AUDIT=false
AKISMET_KEY=
LOGIN=false
FORBIDDEN_WORDS=
DISALLOW_IP_LIST=

# 显示设置
DISABLE_AUTHOR_NOTIFY=false
DISABLE_REGION=false
DISABLE_USERAGENT=false

# SMTP 通知
SMTP_SERVICE=
SMTP_HOST=
SMTP_PORT=
SMTP_USER=
SMTP_PASS=
AUTHOR_EMAIL=

# 其他
IP2REGION_DB=
OAUTH_URL=https://oauth.lithub.cc
```

### DATABASE_URL 配置说明

SQLite 路径配置方式：
*   **绝对路径**：使用 `sqlite:////`。例如 `sqlite:////app/db/waline.sqlite`，表示系统根目录下的路径。四个斜杠中，前两个是协议分隔符，第三个表示绝对路径根，第四个是路径起始。
*   **相对路径**：使用 `sqlite://./`。例如 `sqlite://./waline.sqlite`，表示相对于当前工作目录（CWD）的路径。
