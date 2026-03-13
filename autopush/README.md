# Autopush

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Autopush][1] 是 Mozilla 推送服务的 Rust 实现。

[1]:https://forkdo.github.io/autopush-rs/
[2]:https://github.com/forkdo/autopush-rs
[3]:https://github.com/orgs/forkdo/packages?repo_name=autopush-rs
[4]:https://github.com/forkdo/autopush-rs/wiki

---

## [配置选项](https://github.com/forkdo/autopush-rs/blob/main/docs/src/config_options.md)

## Autoconnect

以下配置选项既可以在配置文件中指定，也可以通过环境变量的形式指定。

| **选项** | **环境变量** | **类型** | **默认值** | **描述** |
|---|---|---|---|---|
| <span id="AUTOCONNECT__ACTIX_MAX_CONNECTIONS" />actix_max_connections | AUTOCONNECT__ACTIX_MAX_CONNECTIONS | 数字 | _无_ | Actix Web 服务器的最大并发连接数 |
| <span id="AUTOCONNECT__ACTIX_WORKERS" />actix_workers | AUTOCONNECT__ACTIX_WORKERS | 数字 | _无_ | Actix Web 服务器每个绑定地址的工作线程数 |
| <span id="AUTOCONNECT__AUTO_PING_INTERVAL" />auto_ping_interval | AUTOCONNECT__AUTO_PING_INTERVAL | 数字 | 300 | 服务器向客户端发送 ping 消息的时间间隔（秒） |
| <span id="AUTOCONNECT__AUTO_PING_TIMEOUT" />auto_ping_timeout | AUTOCONNECT__AUTO_PING_TIMEOUT | 数字 | 4 | 等待客户端 ping 响应的时间（秒） |
| <span id="AUTOCONNECT__CRYPTO_KEY" />crypto_key | AUTOCONNECT__CRYPTO_KEY | 字符串 | _内部生成的值_ | 用于端点加密的加密密钥 |
| <span id="AUTOCONNECT__DB_DSN" />db_dsn | AUTOCONNECT__DB_DSN | 字符串 | _无_ | 后端数据库的数据源名称 |
| <span id="AUTOCONNECT__DB_SETTINGS" />db_settings | AUTOCONNECT__DB_SETTINGS | 字符串 | _无_ | 数据库设置的序列化 JSON 结构（详见每个数据存储） |
| <span id="AUTOCONNECT__ENDPOINT_HOSTNAME" />endpoint_hostname | AUTOCONNECT__ENDPOINT_HOSTNAME | 字符串 | "localhost" | 端点 URL 的主机名 |
| <span id="AUTOCONNECT__ENDPOINT_PORT" />endpoint_port | AUTOCONNECT__ENDPOINT_PORT | 数字 | 8082 | 端点 URL 的可选端口覆盖值 |
| <span id="AUTOCONNECT__ENDPOINT_SCHEME" />endpoint_scheme | AUTOCONNECT__ENDPOINT_SCHEME | 字符串 | "http" | 端点 URL 的 URL 方案（http/https） |
| <span id="AUTOCONNECT__HOSTNAME" />hostname | AUTOCONNECT__HOSTNAME | 字符串 | _无_ | 机器主机名（例如 `localhost`） |
| <span id="AUTOCONNECT__HUMAN_LOGS" />human_logs | AUTOCONNECT__HUMAN_LOGS | 布尔值 | false | 是否使用人类可读的日志格式（例如时间戳、日志级别） |
| <span id="AUTOCONNECT__MEGAPHONE_API_TOKEN" />megaphone_api_token | AUTOCONNECT__MEGAPHONE_API_TOKEN | 字符串 | _无_ | 远程设置 “Megaphone” API 服务器的访问令牌 |
| <span id="AUTOCONNECT__MEGAPHONE_API_URL" />megaphone_api_url | AUTOCONNECT__MEGAPHONE_API_URL | 字符串 | _无_ | 远程设置 “Megaphone” API 服务器的 URL |
| <span id="AUTOCONNECT__MEGAPHONE_POLL_INTERVAL" />megaphone_poll_interval | AUTOCONNECT__MEGAPHONE_POLL_INTERVAL | 字符串 | _无_ | 轮询远程设置 “Megaphone” 服务器的周期（秒） |
| <span id="AUTOCONNECT__MSG_LIMIT" />msg_limit | AUTOCONNECT__MSG_LIMIT | 数字 | 1000 | 每个客户端存储的最大消息数 |
| <span id="AUTOCONNECT__OPEN_HANDSHAKE_TIMEOUT" />open_handshake_timeout | AUTOCONNECT__OPEN_HANDSHAKE_TIMEOUT | 数字 | 5 | 等待客户端发送有效 `Hello` 消息的时间（秒） |
| <span id="AUTOCONNECT__PORT" />port | AUTOCONNECT__PORT | 数字 | 8080 | 应用程序监听的端口 |
| <span id="AUTOCONNECT__RELIABILITY_DSN" />reliability_dsn | AUTOCONNECT__RELIABILITY_DSN | 字符串 | _无_ | 可靠性数据存储的数据源名称（如果启用 `--features=reliable_report`） |
| <span id="AUTOCONNECT__RELIABILITY_RETRY_COUNT" />reliability_retry_count | AUTOCONNECT__RELIABILITY_RETRY_COUNT | 数字 | 3 | 为保证可靠性，重试 Redis 事务写入的次数（如果启用 `--features=reliable_report`） |
| <span id="AUTOCONNECT__RESOLVE_HOSTNAME" />resolve_hostname | AUTOCONNECT__RESOLVE_HOSTNAME | 布尔值 | false | 使用给定主机名的内部 IP 地址 |
| <span id="AUTOCONNECT__ROUTER_HOSTNAME" />router_hostname | AUTOCONNECT__ROUTER_HOSTNAME | 字符串 | _无_ | 用于节点间通信的主机名 |
| <span id="AUTOCONNECT__ROUTER_PORT" />router_port | AUTOCONNECT__ROUTER_PORT | 数字 | 8081 | 自动连接节点间通信的路由器端口 |
| <span id="AUTOCONNECT__STATSD_HOST" />statsd_host | AUTOCONNECT__STATSD_HOST | 字符串 | "localhost" | statsd 收集器主机的名称 |
| <span id="AUTOCONNECT__STATSD_PORT" />statsd_port | AUTOCONNECT__STATSD_PORT | 端口 | 8125 | statsd 收集器主机的端口 |
| <span id="AUTOCONNECT__STATSD_LABEL" />statsd_label | AUTOCONNECT__STATSD_LABEL | 字符串 | "autoconnect" | 用于 statsd 指标的标签 |

## Autoendpoint

以下配置选项既可以在配置文件中指定，也可以通过环境变量的形式指定。

| **选项** | **环境变量** | **类型** | **默认值** | **描述** |
|---|---|---|---|---|
| <span id="AUTOEND__SCHEME" />scheme | AUTOEND__SCHEME | 字符串 | "http" | 端点 URL 的 URL 方案（http/https） |
| <span id="AUTOEND__HOST" />host | AUTOEND__HOST | 字符串 | "127.0.0.1" | 端点 URL 的机器主机（例如 `localhost`） |
| <span id="AUTOEND__PORT" />port | AUTOEND__PORT | 数字 | 8000 | 端点 URL 的应用程序端口覆盖值 |
| <span id="AUTOEND__ENDPOINT_URL" />endpoint_url | AUTOEND__ENDPOINT_URL | 字符串 | _无_ | 端点的完整 URL（如果设置，则覆盖 `scheme`、`host` 和 `port`） |
| <span id="AUTOEND__DB_DSN" />db_dsn | AUTOEND__DB_DSN | 字符串 | _无_ | 后端数据库的数据源名称 |
| <span id="AUTOEND__DB_SETTINGS" />db_settings | AUTOEND__DB_SETTINGS | 字符串 | _无_ | 数据库设置的序列化 JSON 结构（详见每个数据存储） |
| <span id="AUTOEND__ROUTER_TABLE_NAME" />router_table_name | AUTOEND__ROUTER_TABLE_NAME | 字符串 | "router" | 用于路由器的数据库表名（注意，这是旧版设置，将在未来版本中移除） |
| <span id="AUTOEND__MESSAGE_TABLE_NAME" />message_table_name | AUTOEND__MESSAGE_TABLE_NAME | 字符串 | "message" | 用于消息的数据库表名（注意，这是旧版设置，将在未来版本中移除） |
| <span id="AUTOEND__TRACKING_KEYS" />tracking_keys | AUTOEND__TRACKING_KEYS | 字符串 | _无_ | 为保证可靠性而跟踪的 VAPID 公钥的逗号分隔列表（如果启用 `--features=reliable_report`） |
| <span id="AUTOEND__MAX_DATA_BYTES" />max_data_bytes | AUTOEND__MAX_DATA_BYTES | 数字 | 4096 | 消息 `data` 字段中允许接受的最大字节数 |
| <span id="AUTOEND__CRYPTO_KEYS" />crypto_keys | AUTOEND__CRYPTO_KEYS | 字符串 | _内部生成的值_ | 用于端点加密的加密密钥的逗号分隔列表（第一个密钥将用于加密新消息） |
| <span id="AUTOEND__AUTH_KEYS" />auth_keys | AUTOEND__AUTH_KEYS | 字符串 | _无_ | 用于客户端端点身份验证的身份验证密钥的逗号分隔列表（第一个密钥将用于验证新消息） |
| <span id="AUTOEND__HUMAN_LOGS" />human_logs | AUTOEND__HUMAN_LOGS | 布尔值 | false | 是否使用人类可读的日志格式（例如时间戳、日志级别） |
| <span id="AUTOEND__CONNECTION_TIMEOUT_MILLIS" />connection_timeout_millis | AUTOEND__CONNECTION_TIMEOUT_MILLIS | 数字 | 1000 | 等待桥接连接超时前的毫秒数 |
| <span id="AUTOEND__REQUEST_TIMEOUT_MILLIS" />request_timeout_millis | AUTOEND__REQUEST_TIMEOUT_MILLIS | 数字 | 3000 | 等待桥接请求超时前的毫秒数 |
| <span id="AUTOEND__STATSD_HOST" />statsd_host | AUTOEND__STATSD_HOST | 字符串 | "localhost" | statsd 收集器主机的名称 |
| <span id="AUTOEND__STATSD_PORT" />statsd_port | AUTOEND__STATSD_PORT | 端口 | 8125 |
| <span id="AUTOEND__STATSD_LABEL" />statsd_label | AUTOEND__STATSD_LABEL | 字符串 | "autoendpoint" | 用于 statsd 指标的标签 |
| <span id="AUTOEND__RELIABILITY_DSN" />reliability_dsn | AUTOEND__RELIABILITY_DSN | 字符串 | _无_ | 可靠性数据存储的数据源名称（如果启用 `--features=reliable_report`） |
| <span id="AUTOEND__RELIABILITY_RETRY_COUNT" />reliability_retry_count | AUTOEND__RELIABILITY_RETRY_COUNT | 数字 | 10 | 为保证可靠性，重试 Redis 事务写入的次数（如果启用 `--features=reliable_report`） |
| <span id="AUTOEND__MAX_NOTIFICATION_TTL" />max_notification_ttl | AUTOEND__MAX_NOTIFICATION_TTL | 数字 | 2592000（30 天） | 通知消息允许的最大生存时间（TTL，秒） |

> 密钥可通过 `openssl rand -base64 32` 命令行创建

## NGINX 反向代理设置

```nginx
    location / {
        # proxy_pass http://127.0.0.1:8080;
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;

        proxy_set_header Host $http_host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_connect_timeout 3m;
        proxy_send_timeout 3m;
        proxy_read_timeout 3m;

        client_max_body_size 0; # Stream request body to backend
    }
```
