# cloudflared

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [cloudflared][1] 是 Cloudflare 隧道客户端。通过建立安全的仅出站（Outbound-only）连接，将 Cloudflare 全球网络的流量代理到你的本地或私有起源节点，无需公网 IP 和开放入站端口。

[1]:https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/
[2]:https://github.com/cloudflare/cloudflared
[3]:https://hub.docker.com/r/cloudflare/cloudflared
[4]:https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/run-parameters/

---

## 快速入门教程

### 1. 准备工作与获取 Token
1. 访问 [Cloudflare Zero Trust 控制台](https://one.dash.cloudflare.com/)。
2. 导航至 **Networks** > **Tunnels**，点击 **Add a tunnel**。
3. 选择 **Cloudflare Managed**（远程托管模式），输入隧道名称。
4. 在随后生成的安装命令中复制对应的 `token` 字符串（以 `eyJh...` 开头）。

### 2. 配置环境变量
在当前目录下创建并配置 `.env` 文件：
```bash
# 时区
TZ=Asia/Shanghai

# 隧道密钥 Token（必须）
TUNNEL_TOKEN=eyJhIjoiXXXXXX...

# 日志级别：debug, info (default), warn, error, fatal
TUNNEL_LOGLEVEL=info

# 禁用自动更新（容器环境建议设置为 true）
NO_AUTOUPDATE=true

# 可选：日志保存文件
# TUNNEL_LOGFILE=/var/log/cloudflared.log
```

### 3. 使用 Docker Compose 启动
编辑或使用自带的 `compose.yaml`：
```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: ["tunnel", "run"]
    hostname: cloudflared
    env_file:
      - path: ./.env
        required: false
```

启动隧道服务：
```bash
# 启动容器
docker compose up -d

# 查看运行状态与连接日志
docker compose logs -f cloudflared
```

### 4. Systemd 服务管理（裸机/虚拟机场景）
若不在 Docker 中运行，可通过 systemd 进行服务托管：

```bash
# 安装服务（自动创建并启用 systemd cloudflared.service）
cloudflared service install <TOKEN>

# 卸载服务（systemd cloudflared.service）
cloudflared service uninstall
```

常用管理命令：
```bash
sudo systemctl start cloudflared    # 启动
sudo systemctl restart cloudflared  # 重启
sudo systemctl status cloudflared   # 状态
```

### 5. 添加公开服务路由（Dashboard 方式）
在 Zero Trust 控制台的 Tunnel 详情中切换到 **Public Hostname**，添加路由规则：
- **Public Hostname**：填写域名与子域（例如 `app.example.com`）。
- **Service Type**：选择 `HTTP` 或 `HTTPS`。
- **URL**：输入本地服务地址（如内网 IP `192.168.1.100:8080`，或同 Docker 网络下的服务名 `web:80`）。
- 保存后即可通过 `https://app.example.com` 安全访问本地服务。

### 6. 安全访问 SSH（Dashboard 配置 + 命令行登录）
1. **Dashboard 配置**：在 Public Hostname 中添加一条记录，Service Type 选择 `SSH`，URL 填写 `localhost:22`（域名例如 `ssh.example.com`）。
2. **命令行直接登录**：客户端本地安装 `cloudflared` 后，执行以下命令直接连接：
```bash
# 命令行登录
ssh -o ProxyCommand="/usr/local/bin/cloudflared access ssh --hostname %h" user@ssh.example.com
```
3. **SSH 配置文件方式（推荐）**：在客户端 `~/.ssh/config` 中配置别名：
```text
Host myserver
    HostName ssh.example.com
    User root
    ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```
配置完成后，即可通过简写命令一键登录：
```bash
ssh myserver
```

---

## 进阶构建（使用 `alpine` 作为基础镜像）
如果希望使用更加轻量的 Alpine 基础镜像构建：
```dockerfile
FROM cloudflare/cloudflared:latest AS builder

FROM alpine:latest

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

COPY --from=builder /usr/local/bin/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT ["cloudflared", "--no-autoupdate"]

CMD ["version"]
```

执行构建命令：
```bash
docker build -t cloudflared .
```
