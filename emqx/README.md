# EMQX

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [EMQX][1] 是一款「无限连接，任意集成，随处运行」的大规模分布式物联网接入平台，同时作为一个高性能、可扩展的 MQTT 消息服务器，它可以为物联网（IoT）应用提供可靠的实时消息传输和设备连接解决方案。EMQX 累计拥有来自 50 多个国家的 20,000 多家企业用户，连接全球超过 1 亿台物联网设备，服务企业数字化、实时化、智能化转型。

[1]:https://www.emqx.com/
[2]:https://github.com/emqx/emqx
[3]:https://hub.docker.com/r/emqx/emqx
[4]:https://docs.emqx.com/

---

## 配置

- 放开端口：`1883,8883,8083,8084,18083,18084`
- 配置文件：`/opt/emqx/etc/emqx.conf`
- [环境变量](https://docs.emqx.com/zh/emqx/latest/configuration/dashboard.html)
- [首次登录](https://docs.emqx.com/zh/emqx/latest/dashboard/introduction.html#%E9%A6%96%E6%AC%A1%E7%99%BB%E5%BD%95)
    ```bash
    默认账号：admin
    默认密码：public
    ```
- [忘记密码](https://docs.emqx.com/zh/emqx/latest/dashboard/introduction.html#%E5%BF%98%E8%AE%B0%E5%AF%86%E7%A0%81)
    ```bash
    docker exec -it emqx emqx ctl admins passwd <Username> <Password>
    docker exec -it emqx emqx ctl admin <Username> <New Password>
    ```
- [TLS 配置（MQTTS）](https://docs.emqx.com/zh/emqx/latest/network/emqx-mqtt-tls.html) （**单向**）
    1. 修改 `.env` 配置文件，去除 `#` 注释
    ```bash
    EMQX_LISTENERS__SSL__DEFAULT__BIND=0.0.0.0:8883
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__KEYFILE=/etc/emqx/certs/emqx.key
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__CERTFILE=/etc/emqx/certs/emqx.cer
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__CACERTFILE=
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__VERIFY=verify_none
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__FAIL_IF_NO_PEER_CERT=false
    ```
    2. 将以下的证书对应的 key 和 cer 路径替换为自己的证书路径
    ```yaml
    volumes:
     - /path/to/ssl/emqx.key:/etc/emqx/certs/emqx.key
     - /path/to/ssl/emqx.fullchain.cer:/etc/emqx/certs/emqx.cer
    ```

- [WSS 配置](https://docs.emqx.com/zh/emqx/latest/configuration/listener.html#%E9%85%8D%E7%BD%AE%E5%AE%89%E5%85%A8-websocket-%E7%9B%91%E5%90%AC%E5%99%A8)
    1. 修改 `.env` 配置文件，去除 `#` 注释
    ```bash
    EMQX_LISTENERS__WSS__DEFAULT__BIND=0.0.0.0:8084
    EMQX_LISTENERS__WSS__DEFAULT__MAX_CONNECTIONS=1024000
    EMQX_LISTENERS__WSS__DEFAULT__WEBSOCKET__MQTT_PATH="/mqtt"
    EMQX_LISTENERS__WSS__DEFAULT__SSL_OPTIONS__CERTFILE=/etc/emqx/certs/emqx.cer
    EMQX_LISTENERS__WSS__DEFAULT__SSL_OPTIONS__KEYFILE=/etc/emqx/certs/emqx.key
    EMQX_LISTENERS__WSS__DEFAULT__SSL_OPTIONS__CACERTFILE=
    ```

- [DASHBOARD 配置](https://docs.emqx.com/zh/emqx/latest/configuration/dashboard.html)
    1. 修改 `.env` 配置文件，去除 `#` 注释
    ```bash
    #EMQX_DASHBOARD__LISTENERS__HTTPS__BIND=0.0.0.0:18084
    #EMQX_DASHBOARD__LISTENERS__HTTPS__SSL_OPTIONS__CERTFILE=/etc/emqx/certs/emqx.cer
    #EMQX_DASHBOARD__LISTENERS__HTTPS__SSL_OPTIONS__KEYFILE=/etc/emqx/certs/emqx.key
    ```

## Nginx 反向代理（推荐）

使用外置 Nginx 反向代理 EMQX，可以获得更好的性能、更灵活的 SSL 证书管理，以及统一的流量控制。主要分为两种场景：

1. **反代 Dashboard（HTTP/HTTPS 协议）**：通过域名访问 EMQX 的管理后台
2. **反代 MQTT WebSocket（WS/WSS 协议）**：让前端通过 Web 端口连接 MQTT

如果你还需要反代传统的 **TCP (1883/8883)** 流量，Nginx 需要启用 `stream` 模块。

### 1. 反代 Dashboard (管理后台)

通常在内网中，Nginx 到 EMQX 走 HTTP (`18083`) 即可，外网访问 Nginx 再加 SSL：

```nginx
server {
    listen 80;
    listen 443 ssl;
    server_name emqx-admin.example.com; # 你的后台域名

    # SSL 证书配置
    ssl_certificate /path/to/ssl/fullchain.cer;
    ssl_certificate_key /path/to/ssl/key.key;

    # 强制 HTTP 跳转 HTTPS
    if ($scheme = http) {
        return 301 https://$host$request_uri;
    }

    location / {
        # 转发到 EMQX 的 HTTP 端口 (18083)
        proxy_pass http://127.0.0.1:18083;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

> **注意**：你的 `docker-compose` 中注释掉了 `18083` 端口。如果 Nginx 和 EMQX **不在同一个 Docker 网络**中，你需要把 `# - ${HTTP_PORT:-18083}:18083` 的注释取消，否则宿主机的 Nginx 无法通过 `127.0.0.1:18083` 连上它。

### 2. 反代 WebSocket (WS/WSS)

MQTT 的 WebSocket 连接需要支持协议升级（Upgrade Header）：

```nginx
server {
    listen 80;
    listen 443 ssl;
    server_name iot.example.com; # 你的 MQTT WS/WSS 域名

    ssl_certificate /path/to/ssl/fullchain.cer;
    ssl_certificate_key /path/to/ssl/key.key;

    location /mqtt {
        # 转发到 EMQX 的 WS 端口 (8083)
        proxy_pass http://127.0.0.1:8083;

        # 关键配置：支持 WebSocket 反代
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 调大超时时间，防止 MQTT 长连接被 Nginx 误杀断开
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
    }
}
```

### 3. 反代 TCP 流量（可选）

如果你想通过 Nginx 来卸载 SSL 证书，让客户端连接 Nginx 的 `8883` 端口，然后 Nginx 以 TCP 方式转发给 EMQX 的 `1883`，需要在 `nginx.conf` 的 **顶层（与 http 块同级）** 添加 `stream` 块：

```nginx
# 注意：此块与 http 块同级，不要写在 http 里面
stream {
    upstream emqx_tcp {
        server 127.0.0.1:1883; # EMQX 的 TCP 端口
    }

    server {
        listen 8883 ssl;

        ssl_certificate /path/to/ssl/fullchain.cer;
        ssl_certificate_key /path/to/ssl/key.key;

        ssl_handshake_timeout 15s;

        proxy_pass emqx_tcp;
        proxy_timeout 5m;
        proxy_connect_timeout 5s;
    }
}
```

### 优化后的 docker-compose.yml

既然用了 Nginx 反代，EMQX 容器内就可以只跑非 SSL 端口，**证书挂载可以完全删除**：

```yaml
services:
  emqx:
    container_name: emqx
    env_file:
    - ../files/.env
    user: 0:0
    ports:
    - ${TCP_PORT:-1883}:1883      # 用于硬件/App 的原生 MQTT 流量（可选）
    - ${WS_PORT:-8083}:8083        # 用于前端网页的 WebSocket 流量
    - ${HTTP_PORT:-18083}:18083    # 用于 Dashboard 管理后台
    image: emqx/emqx:latest
    restart: unless-stopped
    volumes:
    - /srv/emqx/data:/opt/emqx/data
    - /srv/emqx/log:/opt/emqx/log
    # 证书挂载已移至 Nginx 侧管理
```

### 客户端连接方式

使用 Nginx 反代后，客户端**必须使用加密协议（HTTPS / WSS / MQTTS）和域名**连接：

#### 访问管理后台 (Dashboard)
在浏览器中直接输入你在 Nginx 中配置的后台域名：
- **URL**: `https://emqx-admin.example.com`
- **默认账号**: `admin`
- **默认密码**: `public`

#### 前端网页 / 小程序连接 (WebSocket)
```javascript
const options = {
    connectTimeout: 4000,
    clientId: 'web_client_' + Math.random().toString(16).substr(2, 8),
    username: 'your_username',
    password: 'your_password',
}

// 注意：端口是 443，路径是 /mqtt
const client = mqtt.connect('wss://iot.example.com:443/mqtt', options)
```

#### 硬件设备 / 后端服务连接 (原生 MQTT TCP)
- **方案 A（推荐）**：通过 Nginx `stream` 模块转发到 `8883`（加密）
- **方案 B（简单）**：直接连接 EMQX 的 `1883` 端口（不加密）

### 最佳实践建议

1. **证书全权交给 Nginx**：证书更新时只需重启/重载 Nginx 即可，运维更简单
2. **连接超时**：MQTT 是长连接，如果客户端 `Keep Alive` 设置超过 60s，请在 Nginx 中调大 `proxy_read_timeout`
3. **连接测试**：推荐使用 [MQTTX](https://mqttx.app/)（EMQX 官方的可视化客户端工具）进行测试

## 运行
```bash
docker compose up -d
chmod -R 777 ./data
```

## 客户端连接密码设置
- https://docs.emqx.com/zh/emqx/latest/access-control/authn/mnesia.html
