# Remark42

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Remark42][1] 是一款可自行托管的、轻量级且简洁（却功能完备）的评论引擎，不会窥探用户信息。它可以嵌入到博客、文章或读者发表评论的任何其他地方。

* 支持通过谷歌、脸书、微软、GitHub、苹果、雅虎、Patreon、Discord和Telegram进行社交登录
* 支持通过电子邮件登录
* 可选匿名访问
* 支持多级嵌套评论，有树形和纯文本两种展示方式
* 支持从Disqus和WordPress导入评论
* 支持Markdown格式，配备友好的格式化工具栏
* 版主可以删除评论并封禁用户
* 具备投票、置顶和验证系统
* 评论可排序
* 支持拖放上传图片
* 可提取近期评论、进行交叉发布
* 支持为所有评论及每篇文章生成RSS订阅
* 支持向管理员发送Telegram、Slack、Webhook和电子邮件通知（有新评论时获得通知）
* 支持向用户发送电子邮件和Telegram通知（有人回复您的评论时获得通知）
* 可将数据导出为JSON格式，并自动备份
* 无需外部数据库，所有内容都嵌入到单个数据文件中
* 完全容器化，可通过一条命令完成部署
* 自包含的可执行文件可直接部署到Linux、Windows和macOS系统上
* 界面简洁、轻量且可定制，有白色和深色主题
* 单个实例支持多站点模式
* 支持自动SSL集成（直接集成以及通过[nginx-le](https://github.com/nginx-le/nginx-le)）
* [注重隐私](https://remark42.com/#privacy)

[1]:https://remark42.com/
[2]:https://github.com/umputun/remark42
[3]:https://hub.docker.com/r/umputun/remark42
[4]:https://remark42.com/docs/getting-started/installation/

---

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
| notify.webhook.template        | NOTIFY_WEBHOOK_TEMPLATE        | {"text": &#123;&#123;.Text | escapeJSONString&#125;&#125;}  | Webhook有效负载模板                 |
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
