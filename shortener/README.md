# Shortener

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Shortener][1] 是一个使用 Rust 编写的高性能 URL 短链接服务。

[1]: https://github.com/jetsung/shortener
[2]: https://github.com/jetsung/shortener
[3]: https://hub.docker.com/r/jetsung/shortener
[4]: https://shortener.ooos.top/

---

## 架构说明

**统一镜像、单进程**（对齐上游 acmecast 形态）：`shortener-server` 一个进程直接托管
前端静态资源并对外提供 API，无内嵌 nginx。

```
浏览器 ──→ nginx(80，HTTPS 终结) ──→ shortener:8080（单进程）
                                       ├─ /                → 前端页面（未命中回退 index.html）
                                       ├─ /api/*           → 业务 API
                                       └─ /go/{short_code} → 短码跳转（健康检查用 /go/ 纯路径）
```

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `compose.yaml` | 编排：`shortener`（统一镜像）+ `valkey`（缓存）+ `nginx`（外层反代） |
| `compose.override.yaml` | 本地覆盖：数据卷与对外端口（`SERV_PORT`，默认 80） |
| `config.toml` | 服务端配置（环境变量优先于本文件） |
| `nginx.conf` | 外层 nginx 配置（含专用短域名可选配置） |
| `.env` | 环境变量（`TZ`、`SERV_PORT`） |
| `backup.sh` | 备份 `./data` 数据目录 |

## 使用

1. **必改安全配置**（`config.toml`）

   ```bash
   # API 密钥（必填）
   # 生成: openssl rand -base64 32
   api_key = "apikey_for_shortener"

   # 管理员口令哈希（必填，不落明文）
   # 生成: docker run --rm jetsung/shortener:latest hash-password --password "your-secure-password"
   password_hash = ""
   ```

2. **缓存**（默认启用，连接 compose 中的 `valkey` 服务）

   `config.toml` 中 `cache.enabled = true`、`cache.url = "valkey://valkey:6379/1"`。
   不需要缓存时将 `enabled` 改为 `false` 并删除 `compose.yaml` 中的 `valkey` 服务与
   `shortener` 的 `depends_on`。

3. **IP 归属地**（默认启用）

   下载 [ip2region.xdb](https://github.com/lionsoul2014/ip2region/raw/master/data/ip2region_v4.xdb)
   保存至 `./data/ip2region.xdb`（挂载为容器内 `/app/data/ip2region.xdb`，配置使用相对路径
   `./data/ip2region.xdb`）。不需要时将 `geoip.enabled` 改为 `false`。

4. **启动**

   ```bash
   docker compose up -d
   ```

   启动后访问 `http://localhost:${SERV_PORT:-80}`，健康探针：`curl http://localhost:8080/go/`
   返回 `{"message":"pong"}`。

5. **外层 Nginx 反向代理**

   目录内 `nginx.conf` 已是完整可用配置：上游 `shortener:8080`，任意路径**原样转发，
   无需路径改写**。要点：

   - **必设透传头**（后端据此推导 OIDC 回调地址与真实客户端 IP）：

     ```nginx
     proxy_set_header Host              $http_host;
     proxy_set_header X-Real-IP         $remote_addr;
     proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
     proxy_set_header X-Forwarded-Proto $scheme;
     ```

   - **HTTPS 终结**：在 server 块加 `listen 443 ssl` 与证书，`X-Forwarded-Proto $scheme`
     会自动透传 `https`；80 端口可 `return 301 https://$host$request_uri` 全站跳转。

   - **专用短域名**（可选，链接形如 `https://s.example.com/<code>`，无 `/go/` 前缀）：
     1. `config.toml` 设置 `short_url = "https://s.example.com"`；
     2. 启用 `nginx.conf` 中注释的短域名 server 块（`server_name s.example.com`）——
        使用 `proxy_pass http://shortener/go/` 直写，任意路径在服务端内部一次映射
        为后端 `/go/<code>` 并直接 308，无需客户端 301 回环；
     3. 该域名同样原样转发到 `shortener:8080`。

6. **备份**：`./backup.sh` 打包 `./data`（SQLite 数据库与 ip2region 文件）。
