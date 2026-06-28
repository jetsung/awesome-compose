# Static Web Server

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Static Web Server][1]（或 SWS 缩写）是一种小型且快速的生产就绪型 Web 服务器，适用于提供静态 Web 文件或资产。

它专注于轻量级和易于使用的原则，同时保持由 Rust 编程语言提供支持的高性能和安全性。

它基于 Hyper 和 Tokio 运行时编写，提供并发和异步网络功能以及最新的 HTTP/1 - HTTP/2 实现。

跨平台，适用于 Linux、macOS、Windows、FreeBSD、NetBSD、Android、Docker 和 Wasm（通过 Wasmer）。

## 环境变量

> [!TIP]
> 环境变量与命令行参数等效，命令行参数优先级更高。
> 完整文档请参考 [官方文档][4]

### 自定义变量

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `TZ` | 时区设置 | `Asia/Shanghai` |
| `SERV_PORT` | 宿主机端口映射 | `80` |

### 服务器基础

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_HOST` | 监听地址 (如 `127.0.0.1` 或 `::1`) | `[::]` |
| `SERVER_PORT` | 监听端口 | `80` |
| `SERVER_ROOT` | 静态文件根目录 | `./public` |
| `SERVER_INDEX_FILES` | 索引文件列表，按顺序匹配 | `index.html` |
| `SERVER_GRACE_PERIOD` | 优雅关闭等待时间 (秒，最大 255) | `0` |
| `SERVER_CONFIG_FILE` | TOML 配置文件路径 | `./sws.toml` |

### Unix Socket

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_UNIX_SOCKET` | Unix Domain Socket 路径 (替代 TCP) | 空 (禁用) |
| `SERVER_UNIX_SOCKET_MODE` | Socket 文件权限 (八进制，如 `660`) | umask |
| `SERVER_UNIX_SOCKET_FORCE` | 强制覆盖已有 Socket 文件 | `false` |

### 工作线程

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_THREADS_MULTIPLIER` | 工作线程倍数 (CPU 数 × n) | `1` |
| `SERVER_MAX_BLOCKING_THREADS` | 最大阻塞线程数 | `512` |

### 日志

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_LOG_LEVEL` | 日志级别 (`error`, `warn`, `info`, `debug`, `trace`) | `error` |
| `SERVER_LOG_FORMAT` | 日志格式 (`json`, `pretty`) | `json` |
| `SERVER_LOG_WITH_ANSI` | 启用 ANSI 颜色 (仅 `pretty` 格式) | `false` |
| `SERVER_LOG_FILE` | 日志文件路径 (追加写入) | 空 (禁用) |
| `SERVER_LOG_REMOTE_ADDRESS` | 记录远程地址 | `false` |
| `SERVER_LOG_X_REAL_IP` | 记录 X-Real-IP 头 | `false` |
| `SERVER_LOG_FORWARDED_FOR` | 记录 X-Forwarded-For 头 | `false` |
| `SERVER_TRUSTED_PROXIES` | 信任的代理 IP 列表 (逗号分隔) | `""` |

### 错误页面

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_ERROR_PAGE_404` | 404 错误页面路径 | `./404.html` |
| `SERVER_ERROR_PAGE_50X` | 50x 错误页面路径 | `./50x.html` |
| `SERVER_FALLBACK_PAGE` | 回退页面路径 (用于客户端路由) | 空 (禁用) |

### TLS / HTTP2

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_TLS` | 启用 TLS/HTTPS | `false` |
| `SERVER_TLS_CERT` | TLS 证书路径 | 空 (禁用) |
| `SERVER_TLS_KEY` | TLS 私钥路径 | 空 (禁用) |
| `SERVER_HTTP2` | 启用 HTTP/2 (需先启用 TLS) | `false` |

### HTTPS 重定向

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_HTTPS_REDIRECT` | HTTP 重定向到 HTTPS (需启用 TLS) | `false` |
| `SERVER_HTTPS_REDIRECT_HOST` | HTTPS 主机名或 IP | `localhost` |
| `SERVER_HTTPS_REDIRECT_FROM_PORT` | HTTP 重定向监听端口 | `80` |
| `SERVER_HTTPS_REDIRECT_FROM_HOSTS` | 允许重定向的主机列表 | `localhost` |

### CORS

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_CORS_ALLOW_ORIGINS` | 允许的来源列表 (`*` 表示全部) | 空 (禁用) |
| `SERVER_CORS_ALLOW_HEADERS` | 允许的请求头 | `origin, content-type, authorization` |
| `SERVER_CORS_EXPOSE_HEADERS` | 暴露的响应头 | `origin, content-type` |

### 压缩

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_COMPRESSION` | 启用 Gzip/Deflate/Brotli/Zstd 压缩 | `true` |
| `SERVER_COMPRESSION_LEVEL` | 压缩级别 (`fastest`, `default`, `best`) | `default` |
| `SERVER_COMPRESSION_STATIC` | 直接提供预压缩文件 (.gz/.br/.zst) | `true` |

### 目录列表

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_DIRECTORY_LISTING` | 启用目录列表 | `false` |
| `SERVER_DIRECTORY_LISTING_ORDER` | 排序方式 (0-5，见下方说明) | `6` |
| `SERVER_DIRECTORY_LISTING_FORMAT` | 列表格式 (`html`, `json`) | `html` |
| `SERVER_DIRECTORY_LISTING_DOWNLOAD` | 启用下载格式 (`targz`) | 空 (禁用) |

> 排序代码：`0` Name升序, `1` Name降序, `2` 时间升序, `3` 时间降序, `4` 大小升序, `5` 大小降序, `6` 无序

### 安全与缓存

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_SECURITY_HEADERS` | 启用安全头 (需启用 TLS) | `true` |
| `SERVER_CACHE_CONTROL_HEADERS` | 启用缓存控制头 | `true` |
| `SERVER_ETAG` | 启用 ETag 和条件请求 | `true` |
| `SERVER_BASIC_AUTH` | Basic 认证 (`user-id:password`，BCrypt) | 空 (禁用) |

### 行为控制

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_REDIRECT_TRAILING_SLASH` | 目录 URI 尾斜杠重定向 (308) | `true` |
| `SERVER_INCLUDE_HIDDEN` | 包含隐藏文件 (dotfiles) | `false` |
| `SERVER_FOLLOW_SYMLINKS` | 跟随符号链接 | `false` |
| `SERVER_ACCEPT_MARKDOWN` | Markdown 内容协商 | `false` |
| `SERVER_TEXT_CHARSET` | 文本响应默认 charset | `true` |

### 健康检查与指标

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_HEALTH` | 启用 `/health` 端点 | `false` |
| `SERVER_METRICS` | 启用 Prometheus `/metrics` 端点 | `false` |

### 维护模式

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_MAINTENANCE_MODE` | 启用维护模式 | `false` |
| `SERVER_MAINTENANCE_MODE_STATUS` | 维护模式 HTTP 状态码 | `503` |
| `SERVER_MAINTENANCE_MODE_FILE` | 维护模式 HTML 文件 | 空 (默认消息) |

### Windows

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SERVER_WINDOWS_SERVICE` | 以 Windows 服务运行 | `false` |

[1]:https://static-web-server.net/
[2]:https://github.com/static-web-server/static-web-server/
[3]:https://ghcr.io/static-web-server/static-web-server
[4]:https://static-web-server.net/configuration/environment-variables/
