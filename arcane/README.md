# Arcane

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Arcane][1] 是一个美观直观的界面，用于管理你的 Docker 容器、镜像、网络和卷。 不需要终端。

[1]:https://getarcane.app/
[2]:https://github.com/getarcaneapp/arcane
[3]:https://github.com/getarcaneapp/arcane/pkgs/container/arcane
[4]:https://getarcane.app/docs/setup/installation

---

## [环境变量设置](https://getarcane.app/docs/configuration/environment)
### 项目目录
```yaml
services:
  arcane:
    volumes:
      - /opt/docker:/opt/docker
```
环境变量设置为
```bash
PROJECTS_DIRECTORY=/opt/docker
```

### 数据库
```bash
# SQLite
DATABASE_URL=file:data/arcane.db?_pragma=journal_mode(WAL)&_pragma=busy_timeout(2500)&_txlock=immediate

# PostgreSQL
DATABASE_URL=postgresql://arcane:changeme@postgres:5432/arcane
```

## 使用教程
### 1. 生成密钥
```bash
docker run --rm ghcr.io/getarcaneapp/arcane:latest /app/arcane generate secret
```

### 2. 启动服务
```bash
docker compose up -d
```

### 3. 登录密码
```bash
# 用户名：arcane
# 密码：arcane-admin
docker logs -f arcane
```

## 常见问题
### [Nginx + Websocket 配置](https://getarcane.app/docs/configuration/websockets-reverse-proxies)
```conf
server {
    ...
    add_header X-Frame-Options "*";
    location / {
        add_header X-Robots-Tag "noindex, nofollow";
        proxy_pass http://127.0.0.1:3552;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Rootless 模式的 Docker Socket 设置
```yaml
services:
  arcane:
    ...
    volumes:
      - /run/user/1000/docker.sock:/var/run/docker.sock
```
