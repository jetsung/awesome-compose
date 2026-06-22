# Aria2

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Aria2][1] 是行业标准的免费开源多协议下载工具。它利用先进的多连接架构，通过HTTP、FTP和BitTorrent协议实现多达16个并行传输，充分利用你的带宽，而且完全离线且安全。

[1]:https://aria2.org/
[2]:https://github.com/jetsung/sh/tree/main/dockerfile/aria2
[3]:https://ghcr.io/jetsung/aria2
[4]:https://github.com/jetsung/sh/tree/main/dockerfile/aria2

## 使用方法

你可以直接运行 `aria2c` 命令：

```bash
docker run --rm ghcr.io/jetsung/aria2:latest --help
```

下载文件示例：

```bash
docker run --rm -v $(pwd):/data -w /data ghcr.io/jetsung/aria2:latest http://example.com/file.zip
```

## 运行 RPC 服务

你可以运行 aria2 作为后台 RPC 服务，允许远程管理：

```bash
docker run -d -p 6800:6800 -v $(pwd):/data --name aria2 ghcr.io/jetsung/aria2:latest --enable-rpc --rpc-listen-all=true --rpc-allow-origin-all=true --rpc-secret='mysecret' --max-connection-per-server=16
```

注意：请将 `mysecret` 修改为你自己的密钥。

## 使用配置文件运行

如果你想通过配置文件管理 Aria2 设置，可以将 `aria2.conf` 映射到容器内：

```bash
docker run -d -p 6800:6800 \
  -v $(pwd)/aria2.conf:/root/.aria2/aria2.conf \
  -v $(pwd)/data:/data \
  --name aria2 ghcr.io/jetsung/aria2:latest
```

确保 `aria2.conf` 中包含相应的 RPC 设置：

```ini
# --- Basic Settings ---
dir=/data
continue=true
file-allocation=none

max-overall-download-limit=2048K
max-overall-upload-limit=13312K

# --- HTTP/FTP/SFTP ---
max-concurrent-downloads=11
max-connection-per-server=16
min-split-size=10M
split=10
disable-ipv6=false

# --- BitTorrent ---
bt-max-peers=55
enable-dht=true
enable-peer-exchange=true
bt-seed-unverified=true
bt-save-metadata=true
seed-ratio=1.0

# --- RPC Server (For Web UIs) ---
enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-listen-port=6800
rpc-secret=YOUR_SECRET_TOKEN

# --- Session Saving ---
save-session=~/.aria2/aria2.session
input-file=~/.aria2/aria2.session
save-session-interval=60
```

## 使用 Docker Compose

你也可以使用 `compose.yaml` 快速部署：

```yaml
services:
  aria2:
    image: ghcr.io/jetsung/aria2:latest
    container_name: aria2
    ports:
      - "6800:6800"
    volumes:
      - ./data:/data
      - ./aria2.conf:/root/.aria2/aria2.conf
    restart: unless-stopped
```

启动服务：

```bash
docker compose up -d
```

## HTTPS / SSL 配置

aria2 默认的 6800 端口使用的是 **HTTP 协议**（基于 HTTP/WebSocket 的 RPC 服务），而不是 HTTPS。

如果你的 WebUI 部署在 HTTPS 网站上（如线上的 AriaNg 托管页面），浏览器会因混合内容（Mixed Content）安全策略阻止其连接本地的 HTTP 端口。

### 方案一：开启 aria2 原生 HTTPS 支持

在 `aria2.conf` 中添加 SSL 证书配置（需要提前准备好 SSL 证书 `server.crt` 和私钥 `server.key`）：

```ini
rpc-secure=true
rpc-certificate=/path/to/server.crt
rpc-private-key=/path/to/server.key
```

开启后，端口依然是 6800，但协议变为 **HTTPS**（RPC 路径变为 `https://...` 或 `wss://...`）。

### 方案二：使用 Nginx 反向代理（推荐）

aria2 本身保持 HTTP 协议（6800 端口），Nginx 在前端提供 HTTPS 加密。这种方式证书申请与续签更方便，且可同时托管 AriaNg 前端和 aria2 后端。

#### Nginx 配置示例（标准 443 端口）

```nginx
server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;

    location /jsonrpc {
        proxy_pass http://127.0.0.1:6800/jsonrpc;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_connect_timeout 60s;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        proxy_buffering off;
    }
}
```

#### Nginx 配置示例（自定义端口）

如果希望对外暴露 6800 端口但仍通过 Nginx 加密，需要将 aria2 改为其他端口（如 6801），Nginx 监听 6800：

```nginx
server {
    listen 6800 ssl;
    server_name yourdomain.com;

    ssl_certificate /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;

    location /jsonrpc {
        proxy_pass http://127.0.0.1:6801/jsonrpc;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## WebUI 连接参数

通过 Nginx 反代后，在 AriaNg 或其他 WebUI 中的连接参数需做相应修改：

| 配置项 | 直接连接 6800 | 通过 Nginx 反代 |
| --- | --- | --- |
| **协议** | HTTP / WS | **HTTPS / WSS** |
| **主机** | `127.0.0.1` 或服务器 IP | `yourdomain.com` |
| **端口** | `6800` | `443`（或 Nginx 监听的端口） |
| **RPC 路径** | `/jsonrpc` | `/jsonrpc` |

> 使用 Nginx 反代方案时，aria2.conf 中的 `rpc-secure=true` **不需要**开启，安全加密的工作全部由 Nginx 完成。
