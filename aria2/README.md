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
