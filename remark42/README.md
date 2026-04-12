# Remark42

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Remark42][1] 是一个轻量级、注重隐私的评论系统，旨在为博客、文章或其他需要评论功能的网站提供简单而强大的解决方案。以下是关于 Remark42 的一些关键信息：

---

## **功能特点**
1. **隐私保护**
   - 不跟踪用户行为，不涉及第三方分析服务。
   - 用户信息（如用户ID、用户名和头像链接）仅存储必要的部分，并且经过哈希处理。
   - 支持用户请求导出其数据，并提供“删除”功能以清除所有相关活动信息[^4^]。

2. **多样的登录方式**
   - 支持通过 Google、Twitter、Facebook、GitHub、Apple 等社交媒体平台登录[^4^]。
   - 支持通过邮箱登录，以及可选的匿名访问[^4^]。

3. **评论功能**
   - 多级嵌套评论，支持树形和线性展示[^4^]。
   - 支持 Markdown 格式化，并提供友好的工具栏[^4^]。
   - 支持投票、置顶和评论排序[^4^]。
   - 支持图片上传，支持拖拽功能[^4^]。

4. **通知与集成**
   - 支持通过 RSS、Telegram、Slack、邮件等方式接收新评论通知[^4^]。
   - 支持将评论导出为 JSON 格式，并自动备份[^4^]。

5. **部署与性能**
   - 提供 Docker 容器化部署，支持单命令启动[^4^]。
   - 支持直接部署到 Linux、Windows 和 macOS[^4^]。
   - 无外部数据库，所有数据存储在一个文件中[^4^]。

6. **多站点支持**
   - 单个实例可以支持多个站点[^4^]。
   - 支持自动 SSL 集成[^4^]。

---

## **部署方式**
1. **Docker 部署**
   - 推荐使用 Docker 部署。可以通过 `docker-compose` 配置并启动服务[^3^]。
   - 示例：
     ```yaml
     services:
       remark42:
         image: umputun/remark42:latest
         ports:
           - "8080:8080"
         environment:
           REMARK_URL: http://localhost:8080
           SITE: your_site_id
           SECRET: your_secret_key
         volumes:
           - ./data:/srv/var
     ```
   - 启动命令：
     ```bash
     docker-compose pull && docker-compose up -d
     ```

2. **二进制文件部署**
   - 下载对应操作系统的二进制文件并解压[^3^]。
   - 示例启动命令：
     ```bash
     ./remark42.linux-amd64 server --secret=your_secret_key --url=http://localhost:8080 --site=your_site_id
     ```

3. **其他部署方式**
   - 支持通过 Zeabur Template 部署[^2^]。
   - 支持手动编译源代码[^3^]。

## **优势**
- **隐私友好**：注重用户隐私，不收集多余信息[^4^]。
- **轻量级**：无外部数据库，单文件存储[^4^]。
- **高度可定制**：支持多种登录方式、评论功能和通知方式[^4^]。
- **易于部署**：支持 Docker、二进制文件等多种部署方式[^3^]。

---

## **适用场景**
- 适合需要隐私保护的个人博客或小型网站。
- 适合不想依赖第三方评论服务（如 Disqus）的开发者[^4^]。

[1]:https://remark42.com/
[2]:https://github.com/umputun/remark42
[3]:https://hub.docker.com/r/umputun/remark42
[4]:https://remark42.com/docs/getting-started/installation/

---

```yaml
environment:
    - REMARK_URL
    - SECRET
    - DEBUG=true
    - AUTH_GOOGLE_CID
    - AUTH_GOOGLE_CSEC
    - AUTH_GITHUB_CID
    - AUTH_GITHUB_CSEC
    - AUTH_FACEBOOK_CID
    - AUTH_FACEBOOK_CSEC
    - AUTH_DISQUS_CID
    - AUTH_DISQUS_CSEC
    # Enable it only for the initial comment import or for manual backups.
    # Do not leave the server running with the ADMIN_PASSWD set if you don't have an intention
    # to keep creating backups manually!
    # - ADMIN_PASSWD=<your secret password>
```

## 环境变量
- https://remark42.com/docs/configuration/parameters/
- https://github.com/umputun/remark42/blob/master/site/src/docs/configuration/parameters/index.md#complete-parameters-list

### 完整参数列表

| 命令行                   | 环境变量                    | 默认值                 | 描述                                              |
|--------------------------------|--------------------------------|-------------------------|----------------------------------------------------------|
| url                            | REMARK_URL                     |                         | Remark42服务器的URL，_必填_                       |
| secret                         | SECRET                         |                         | 用于签署JWT的共享密钥，应为随机、长且难以猜测的字符串，_必填_ |
| site                           | SITE                           | `remark`                | 站点名称（可多个），_多值_                                    |
| store.type                     | STORE_TYPE                     | `bolt`                  | 存储类型，`bolt` 或 `rpc`                         |
| store.bolt.path                | STORE_BOLT_PATH                | `./var`                 | bolt文件的父目录                      |
| store.bolt.timeout             | STORE_BOLT_TIMEOUT             | `30s`                   | boltdb访问超时时间                                    |
| store.rpc.api                  | STORE_RPC_API                  |                         | rpc扩展API的URL                                    |
| store.rpc.timeout              | STORE_RPC_TIMEOUT              |                         | HTTP超时时间（默认：5秒）                               |
| store.rpc.auth_user            | STORE_RPC_AUTH_USER            |                         | 基本认证用户名                                     |
| store.rpc.auth_passwd          | STORE_RPC_AUTH_PASSWD          |                         | 基本认证用户密码                                 |
| admin.type                     | ADMIN_TYPE                     | `shared`                | 管理员存储类型，`shared` 或 `rpc`                   |
| admin.rpc.api                  | ADMIN_RPC_API                  |                         | rpc扩展API的URL                                    |
| admin.rpc.timeout              | ADMIN_RPC_TIMEOUT              |                         | HTTP超时时间（默认：5秒）                               |
| admin.rpc.auth_user            | ADMIN_RPC_AUTH_USER            |                         | 基本认证用户名                                     |
| admin.rpc.auth_passwd          | ADMIN_RPC_AUTH_PASSWD          |                         | 基本认证用户密码                                 |
| admin.rpc.secret_per_site      | ADMIN_RPC_SECRET_PER_SITE      |                         | 启用按aud（在此处为site_id）检索JWT密钥 |
| admin.shared.id                | ADMIN_SHARED_ID                |                         | 管理员ID（用户ID列表），_多值_                    |
| admin.shared.email             | ADMIN_SHARED_EMAIL             | `admin@${REMARK_URL}`   | 管理员邮箱，_多值_                                    |
| backup                         | BACKUP_PATH                    | `./var/backup`          | 备份位置                                         |
| max-back                       | MAX_BACKUP_FILES               | `10`                    | 保留的最大备份文件数                                 |
| cache.type                     | CACHE_TYPE                     | `mem`                   | 缓存类型，`redis_pub_sub` 或 `mem` 或 `none`        |
| cache.redis_addr               | CACHE_REDIS_ADDR               | `127.0.0.1:6379`        | Redis PubSub实例的地址，开启 `redis_pub_sub` 缓存以实现分布式缓存 |
| cache.max.items                | CACHE_MAX_ITEMS                | `1000`                  | 缓存项的最大数量，`0` - 无限制              |
| cache.max.value                | CACHE_MAX_VALUE                | `65536`                 | 缓存值的最大大小，`0` - 无限制            |
| cache.max.size                 | CACHE_MAX_SIZE                 | `50000000`              | 所有缓存值的最大大小，`0` - 无限制           |
| avatar.type                    | AVATAR_TYPE                    | `fs`                    | 头像存储类型，`fs`、`bolt` 或 `uri`           |
| avatar.fs.path                 | AVATAR_FS_PATH                 | `./var/avatars`         | `fs`存储的头像位置                          |
| avatar.bolt.file               | AVATAR_BOLT_FILE               | `./var/avatars.db`      | `bolt`存储头像文件的位置                             |
| avatar.uri                     | AVATAR_URI                     | `./var/avatars`         | 头像存储URI                                        |
| avatar.rsz-lmt                 | AVATAR_RESIZE                  | `0`（已禁用）          | 保存头像时调整大小的最大图像尺寸              |
| image.type                     | IMAGE_TYPE                     | `fs`                    | 图像存储类型，`fs`、`bolt` 或 `rpc`             |
| image.fs.path                  | IMAGE_FS_PATH                  | `./var/pictures`        | 图像的永久存储位置                             |
| image.fs.staging               | IMAGE_FS_STAGING               | `./var/pictures.staging` | 图像的临时存储位置                               |
| image.fs.partitions            | IMAGE_FS_PARTITIONS            | `100`                   | 图像分区数量                               |
| image.bolt.file                | IMAGE_BOLT_FILE                | `/var/pictures.db`      | 图像bolt文件位置                                |
| image.rpc.api                  | IMAGE_RPC_API                  |                         | rpc扩展API的URL                                    |
| image.rpc.timeout              | IMAGE_RPC_TIMEOUT              |                         | HTTP超时时间（默认：5秒）                               |
| image.rpc.auth_user            | IMAGE_RPC_AUTH_USER            |                         | 基本认证用户名                                     |
| image.rpc.auth_passwd          | IMAGE_RPC_AUTH_PASSWD          |                         | 基本认证用户密码                                 |
| image.max-size                 | IMAGE_MAX_SIZE                 | `5000000`               | 图像文件的最大大小                                   |
| image.resize-width             | IMAGE_RESIZE_WIDTH             | `2400`                  | 调整大小后图像的宽度                                 |
| image.resize-height            | IMAGE_RESIZE_HEIGHT            | `900`                   | 调整大小后图像的高度                                |
| auth.ttl.jwt                   | AUTH_TTL_JWT                   | `5m`                    | JWT的生存时间                                                  |
| auth.ttl.cookie                | AUTH_TTL_COOKIE                | `200h`                  |  cookie的生存时间                                               |
| auth.send-jwt-header           | AUTH_SEND_JWT_HEADER           | `false`                 | 以头部而非服务器设置的cookie形式发送JWT；启用此选项后，前端会将JWT存储在客户端cookie中。[请参阅安全注意事项](#security-considerations-for-auth.send-jwt-header)。 |
| auth.same-site                 | AUTH_SAME_SITE                 | `default`               | 设置cookie的同站策略（`default`、`none`、`lax` 或 `strict`） |
| auth.apple.cid                 | AUTH_APPLE_CID                 |                         | 苹果客户端ID（应用ID或服务ID）                  |
| auth.apple.tid                 | AUTH_APPLE_TID                 |                         | 苹果服务ID                                         |
| auth.apple.kid                 | AUTH_APPLE_KID                 |                         | 苹果私钥ID                                     |
| auth.apple.private-key-filepath | AUTH_APPLE_PRIVATE_KEY_FILEPATH | `/srv/var/apple.p8`       | 苹果私钥文件位置                          |
| auth.google.cid                | AUTH_GOOGLE_CID                |                         | 谷歌OAuth客户端ID                                   |
| auth.google.csec               | AUTH_GOOGLE_CSEC               |                         | 谷歌OAuth客户端密钥                               |
| auth.facebook.cid              | AUTH_FACEBOOK_CID              |                         | 脸书OAuth客户端ID                                 |
| auth.facebook.csec             | AUTH_FACEBOOK_CSEC             |                         | 脸书OAuth客户端密钥                             |
| auth.microsoft.cid             | AUTH_MICROSOFT_CID             |                         | 微软OAuth客户端ID                                |
| auth.microsoft.csec            | AUTH_MICROSOFT_CSEC            |                         | 微软OAuth客户端密钥                            |
| auth.microsoft.tenant          | AUTH_MICROSOFT_TENANT          | `common`                | Azure AD租户ID、域名或 “common”                  |
| auth.github.cid                | AUTH_GITHUB_CID                |                         | GitHub OAuth客户端ID                                   |
| auth.github.csec               | AUTH_GITHUB_CSEC               |                         | GitHub OAuth客户端密钥                               |
| auth.patreon.cid               | AUTH_PATREON_CID               |                         | Patreon OAuth客户端ID                                  |
| auth.patreon.csec              | AUTH_PATREON_CSEC              |                         | Patreon OAuth客户端密钥                              |
| auth.discord.cid               | AUTH_DISCORD_CID               |                         | Discord OAuth客户端ID                                  |
| auth.discord.csec              | AUTH_DISCORD_CSEC              |                         | Discord OAuth客户端密钥                              |
| auth.telegram                  | AUTH_TELEGRAM                  | `false`                 | 启用Telegram认证（必须存在telegram.token）    |
| auth.yandex.cid                | AUTH_YANDEX_CID                |                         | 雅虎OAuth客户端ID                                   |
| auth.yandex.csec               | AUTH_YANDEX_CSEC               |                         | 雅虎OAuth客户端密钥                               |
| auth.dev                       | AUTH_DEV                       | `false`                 | 本地OAuth2服务器，仅用于开发模式               |
| auth.anon                      | AUTH_ANON                      | `false`                 | 启用匿名登录                                   |
| auth.email.enable              | AUTH_EMAIL_ENABLE              | `false`                 | 启用通过电子邮件认证                                    |
| auth.email.from                | AUTH_EMAIL_FROM                |                         | 发件人邮箱（例如 `john.doe@example.com` 或 `"John Doe"<john.doe@example.com>`） |
| auth.email.subj                | AUTH_EMAIL_SUBJ                | `remark42 confirmation` | 邮件主题                                            |
| auth.email.content-type        | AUTH_EMAIL_CONTENT_TYPE        | `text/html`             | 邮件内容类型                                       |
| notify.users                   | NOTIFY_USERS                   | 无                    | 用户通知类型（`telegram`、`email`），_多值_ |
| notify.admins                  | NOTIFY_ADMINS                  | 无                    | 管理员通知类型（`telegram`、`slack`、`webhook` 和/或 `email`），_多值_ |
| notify.queue                   | NOTIFY_QUEUE                   | `100`                   | 通知队列大小                               |
| notify.telegram.chan           | NOTIFY_TELEGRAM_CHAN           |                         | 管理员通知的Telegram频道ID       |
| notify.slack.token             | NOTIFY_SLACK_TOKEN             |                         | Slack令牌                                              |
| notify.slack.chan              | NOTIFY_SLACK_CHAN              | `general`               | 管理员通知的Slack频道                    |
| notify.webhook.url             | NOTIFY_WEBHOOK_URL             |                         | 管理员通知的Webhook通知URL         |
| notify.webhook.template        | NOTIFY_WEBHOOK_TEMPLATE        | `{"text": {{.Text | escapeJSONString}}}`  | Webhook有效负载模板                 |
| notify.webhook.headers         | NOTIFY_WEBHOOK_HEADERS         |                         | 格式为Header1:Value1,Header2:Value2,... 的HTTP头部  |
| notify.webhook.timeout         | NOTIFY_WEBHOOK_TIMEOUT         | `5s`                    | Webhook连接超时时间                               |
| notify.email.from_address      | NOTIFY_EMAIL_FROM              |                         | 发件人邮箱地址（例如 `john.doe@example.com` 或 `"John Doe"<john.doe@example.com>`） |
| notify.email.verification_subj | NOTIFY_EMAIL_VERIFICATION_SUBJ | `Email verification`    | 验证消息主题                             |
| telegram.token                 | TELEGRAM_TOKEN                 |                         | Telegram令牌（用于认证和Telegram通知） |
| telegram.timeout               | TELEGRAM_TIMEOUT               | `5s`                    | Telegram连接超时时间                              |
| smtp.host                      | SMTP_HOST                      |                         | SMTP主机                                                |
| smtp.port                      | SMTP_PORT                      |                         | SMTP端口                                                |
| smtp.username                  | SMTP_USERNAME                  |                         | SMTP用户名                                           |
| smtp.password                  | SMTP_PASSWORD                  |                         | SMTP密码                                            |
| smtp.login_auth                | SMTP_LOGIN_AUTH                | `false`                  | 启用LOGIN认证而非PLAIN认证                       |
| smtp.tls                       | SMTP_TLS                       | `false`                 | 为SMTP启用TLS                                      |
| smtp.starttls                  | SMTP_STARTTLS                  | `false`                 | 为SMTP启用StartTLS                                 |
| smtp.insecure_skip_verify      | SMTP_INSECURE_SKIP_VERIFY      | `false`                 | 跳过SMTP证书验证                   |
| smtp.timeout                   | SMTP_TIMEOUT                   | `10s`                   | SMTP TCP连接超时时间                              |
| ssl.type                       | SSL_TYPE                       | 无                    | `none` - HTTP，`static` - HTTPS，`auto` - HTTPS + le           |
| ssl.port                       | SSL_PORT                       | `8443`                  | HTTPS服务器端口                                    |
| ssl.cert                       | SSL_CERT                       |                         | cert.pem文件路径                                |
| ssl.key                        | SSL_KEY                        |                         | key.pem文件路径                                 |
| ssl.acme-location              | SSL_ACME_LOCATION              | `./var/acme`            | 存储获取的le证书的目录               |
| ssl.acme-email                 | SSL_ACME_EMAIL                 |                         | 接收LE通知的管理员邮箱          |
| max-comment                    | MAX_COMMENT_SIZE               | `2048`                  | 评论大小限制                                     |
| min-comment                    | MIN_COMMENT_SIZE               | `0`                     | 评论最小大小限制，`0` - 无限制            |
| max-votes                      | MAX_VOTES                      | `-1`                    | 每条评论的投票限制，`-1` - 无限制                |
| votes-ip                       | VOTES_IP                       | `false`                 | 限制来自同一IP的投票                          |
| anon-vote                      | ANON_VOTE                      | `false`                 | 允许匿名用户投票，同时需启用VOTES_IP |
| votes-ip-time                  | VOTES_IP_TIME                  | `5m`                    | 同一IP投票限制时间，`0s` - 无限制          |
| low-score                      | LOW_SCORE                      | `-5`                    | 低分数阈值                                      |
| critical-score                 | CRITICAL_SCORE                 | `-10`                   | 关键分数阈值                                 |
| positive-score                 | POSITIVE_SCORE                 | `false`                 | 限制评论分数仅为正数            |
| restricted-words               | RESTRICTED_WORDS               |                         | 评论中禁止使用的单词（可使用 `*`），_多值_          |
| restricted-names               | RESTRICTED_NAMES               |                         | 用户禁止使用的名称，_多值_             |
| edit-time                      | EDIT_TIME                      | `5m`                    | 编辑窗口；设置为 `0` 以禁用评论编辑和临时图像清理 |
| admin-edit                     | ADMIN_EDIT                     | `false`                 | 管理员无限制编辑                                |
| read-age                       | READONLY_AGE                   |                         | 评论的只读期限，单位为天                          |
| image-proxy.http2https         | IMAGE_PROXY_HTTP2HTTPS         | `false`                 | 启用图像的HTTP -> HTTPS代理                      |
| image-proxy.cache-external     | IMAGE_PROXY_CACHE_EXTERNAL     | `false`                 | 启用将外部图像缓存到当前图像存储中  |
| emoji                          | EMOJI                          | `false`                 | 启用表情符号支持                                     |
| simple-view                    | SIMPLE_VIEW                    | `false`                 | 仅包含基本信息的最小化用户界面                        |
| proxy-cors                     | PROXY_CORS                     | `false`                 | 禁用内部CORS并将其委托给代理           |
| allowed-hosts                  | ALLOWED_HOSTS                  | 允许所有              | 通过CSP 'frame-ancestors' 限制允许嵌入评论的主机/来源 |
| address                        | REMARK_ADDRESS                 | 所有接口          |  Web服务器监听地址                             |
| port                           | REMARK_PORT                    | `8080`                  | Web服务器端口                                          |
| web-root                       | REMARK_WEB_ROOT                | `./web`                 | Web服务器根目录                                |
| update-limit                   | UPDATE_LIMIT                   | `0.5`                   | 每秒更新限制                                        |
| subscribers-only               | SUBSCRIBERS_ONLY               | `false`                 | 仅允许Patreon订阅者评论           |
| disable-signature              | DISABLE_SIGNATURE              | `false`                 | 禁用服务器头部签名                      |
| disable-fancy-text-formatting  | DISABLE_FANCY_HTML_FORMATTING  | `false`                 | 禁用花哨的评论文本格式（替换引号、破折号、分数等） |
| admin-passwd                   | ADMIN_PASSWD                   | 无（已禁用）         | `admin` 基本认证的密码                          |
| dbg                            | DEBUG                          | `false`                 | 调试模式                                               |

- AUTH 方式必须有其中一个，可以设置为匿名 `AUTH_ANON=true`，否则无法正常使用。
