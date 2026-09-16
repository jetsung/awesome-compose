# Cloudflare Tunnel (cloudflared) 完整使用教程

Cloudflare Tunnel（守护程序为 `cloudflared`）提供了一种安全、无需公网 IP 与无需开放入站端口的方式，将本地或私有网络中的服务连接到 Cloudflare 全球网络。

---

## 目录
1. [工作原理与架构](#1-工作原理与架构)
2. [核心概念速查](#2-核心概念速查)
3. [远程管理隧道（Dashboard 推荐方式）](#3-远程管理隧道dashboard-推荐方式)
4. [本地管理隧道（CLI / 配置文件方式）](#4-本地管理隧道cli--配置文件方式)
5. [Docker Compose 部署与运维](#5-docker-compose-部署与运维)
6. [Systemd 系统服务管理](#6-systemd-系统服务管理)
7. [经典应用场景与示例](#7-经典应用场景与示例)
   - 场景 1：发布公网 Web 服务（HTTP / HTTPS）
   - 场景 2：安全访问 SSH 服务（Dashboard 配置 + 命令行登录）
   - 场景 3：远程桌面访问（RDP）
   - 场景 4：连接私有网络（Private Network / CIDR）
8. [Cloudflare Workers VPC 接入与绑定](#8-cloudflare-workers-vpc-接入与绑定)
   - 什么是 Workers VPC
   - 架构与接入方式（VPC Services vs VPC Networks）
   - 配置流程与示例代码
9. [进阶配置（Origin Parameters 与 Run Parameters）](#9-进阶配置origin-parameters-与-run-parameters)
10. [防火墙要求与高可用部署](#10-防火墙要求与高可用部署)
11. [常见问题与排错指南](#11-常见问题与排错指南)

---

## 1. 工作原理与架构

传统的内网穿透通常需要公网 IP、动态 DNS 或在路由器上配置端口转发，这使源站直接暴露在互联网上。

Cloudflare Tunnel 采用 **仅出站连接（Outbound-only）** 模型：
1. 本地服务器上运行守护程序 `cloudflared`。
2. `cloudflared` 主动向最近的 Cloudflare 全球网络边缘节点发起出站长连接（默认 4 条连接，连接到至少 2 个独立数据中心）。
3. 访客请求访问配置的域名时，Cloudflare 边缘节点接收请求，并通过已建立的双向通道将流量转发给 `cloudflared`。
4. `cloudflared` 将请求转发到本地服务（如 `http://localhost:8080`），并将响应返回给访客。

> **安全优势**：可以在源站服务器防火墙上**完全封禁所有入站端口（Inbound Block All）**，仅保留出站流量，杜绝源站 IP 泄露及针对源站端口的扫描和攻击。

---

## 2. 核心概念速查

| 概念 | 英文 | 说明 |
| :--- | :--- | :--- |
| **隧道** | Tunnel | 源站与 Cloudflare 网络之间的持久化安全通道，具备唯一名称和 UUID。 |
| **连接器** | Connector (`cloudflared`) | 运行在基础设施上的轻量级守护进程，建立和维护出站隧道。 |
| **副本** | Replica | 运行相同隧道的多个 `cloudflared` 实例，提供冗余与就近路由的高可用容灾。 |
| **远程管理隧道** | Remotely-managed | 规则由 Cloudflare 控制台或 API 统一托管与下发，推荐绝大多数场景使用。 |
| **本地管理隧道** | Locally-managed | 规则保存在本地 `config.yml` 文件和凭证 JSON 文件中，适合代码化配置管理。 |
| **快速隧道** | Quick Tunnel | 使用 `cloudflared tunnel --url http://localhost:8080` 临时生成的 `*.trycloudflare.com` 测试域名，无需账号。 |
| **私有网络** | Private Network | 通过隧道宣告内网网段（CIDR），配合 Cloudflare WARP 客户端实现零信任内网互通（VPN 替代方案）。 |

---

## 3. 远程管理隧道（Dashboard 推荐方式）

远程管理隧道配置简便，无需在本地频繁修改配置文件，配置变动即时生效。

### 第一步：在 Cloudflare Zero Trust 控制台创建隧道
1. 登录 [Cloudflare Zero Trust 控制台](https://one.dash.cloudflare.com/)。
2. 进入 **Networks** > **Tunnels**。
3. 点击 **Add a tunnel**，选择 **Cloudflare Managed**。
4. 输入隧道名称（例如 `my-tunnel`），点击 **Save tunnel**。

### 第二步：获取并运行 Connector Token
控制台会生成一段包含 `--token <TOKEN>` 的安装命令。复制其中的 Token 字符串，形如：
```text
eyJhIjoiY2I4OD...
```

使用 Docker 运行：
```bash
docker run -d --name cloudflared --restart unless-stopped \
  cloudflare/cloudflared:latest tunnel --no-autoupdate run --token <TOKEN>
```

或使用本目录的 `compose.yaml` 进行管理（详见第 5 节），亦可作为 systemd 服务运行（详见第 6 节）。

### 第三步：在 Dashboard 中配置公开服务路由
在控制台隧道的 **Public Hostname** 页面中点击 **Add a public hostname**：
- **Subdomain**：例如 `web`
- **Domain**：选择你的域名（例如 `example.com`）
- **Path**：可留空
- **Service Type**：选择协议（`HTTP`、`HTTPS`、`SSH`、`TCP` 等）
- **URL**：容器或局域网内服务的地址，例如 `web:80`、`192.168.1.100:8080`、`localhost:3000`

---

## 4. 本地管理隧道（CLI / 配置文件方式）

适用于喜欢将配置纳入 Git 进行版本控制，或无公网浏览器控制台访问权限的场景。

### 第一步：登录认证
```bash
cloudflared tunnel login
```
终端会输出一个授权链接，浏览器打开后选择要授权的域名，授权成功后凭据将保存在 `~/.cloudflared/cert.pem`。

### 第二步：创建隧道
```bash
cloudflared tunnel create my-tunnel
```
输出将包含生成的 Tunnel UUID（例如 `6ff42ae2-765d-4adf-8112-31c55c1551ef`），并在 `~/.cloudflared/<UUID>.json` 生成凭证文件。

### 第三步：配置 Ingress 规则文件 `config.yml`
创建 `~/.cloudflared/config.yml`：
```yaml
tunnel: 6ff42ae2-765d-4adf-8112-31c55c1551ef
credentials-file: /root/.cloudflared/6ff42ae2-765d-4adf-8112-31c55c1551ef.json

ingress:
  # 1. 映射 Web 应用
  - hostname: app.example.com
    service: http://localhost:8080

  # 2. 映射静态资源路径正则匹配
  - hostname: app.example.com
    path: ^/(static|assets)/
    service: http://localhost:8081

  # 3. 映射安全自签证书的内部 HTTPS 服务
  - hostname: secure.example.com
    service: https://localhost:8443
    originRequest:
      noTLSVerify: true

  # 4. 映射 SSH 服务
  - hostname: ssh.example.com
    service: ssh://localhost:22

  # 5. 必须包含一条兜底规则（匹配所有未命中的流量）
  - service: http_status:404
```

### 第四步：配置 DNS 记录并启动
```bash
# 绑定 DNS
cloudflared tunnel route dns my-tunnel app.example.com
cloudflared tunnel route dns my-tunnel secure.example.com
cloudflared tunnel route dns my-tunnel ssh.example.com

# 启动隧道
cloudflared tunnel run my-tunnel
```

---

## 5. Docker Compose 部署与运维

本项目已包含开箱即用的 `compose.yaml` 配置：

### `compose.yaml` 文件
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
    # 如果需要代理宿主机 localhost 服务，可启用 host 网络模式：
    # network_mode: host
```

### `.env` 环境变量配置
```bash
# 时区
TZ=Asia/Shanghai

# 隧道 Token（从 Cloudflare 远程管理页面复制）
TUNNEL_TOKEN=eyJhIjoiXXXXXX...

# 可选：日志等级 debug, info (default), warn, error, fatal
TUNNEL_LOGLEVEL=info

# 可选：指定日志输出文件
# TUNNEL_LOGFILE=/var/log/cloudflared.log

# 容器内推荐禁用自动更新
NO_AUTOUPDATE=true
```

### 常用运维命令
```bash
# 启动
docker compose up -d

# 查看运行日志与连接状态
docker compose logs -f cloudflared

# 重启服务
docker compose restart cloudflared

# 停止服务
docker compose down
```

---

## 6. Systemd 系统服务管理

在裸机或虚拟机宿主机上（非 Docker 场景），可直接将 `cloudflared` 安装为系统服务：

### 安装服务（含 Token）
```bash
# 安装服务（自动创建并启用 systemd cloudflared.service）
cloudflared service install <TOKEN>
```
此命令会自动生成 `/etc/systemd/system/cloudflared.service`，并将 Token 注入到服务启动参数中。

### 常用 Systemd 服务管理命令
```bash
# 启动服务
sudo systemctl start cloudflared

# 停止服务
sudo systemctl stop cloudflared

# 重启服务
sudo systemctl restart cloudflared

# 查看服务运行状态
sudo systemctl status cloudflared

# 查看实时日志
sudo journalctl -u cloudflared -f
```

### 卸载服务
```bash
# 卸载服务（停止并移除 systemd cloudflared.service）
cloudflared service uninstall
```

---

## 7. 经典应用场景与示例

### 场景 1：发布公网 Web 服务（HTTP / HTTPS）
无论是本地开发机器还是内网 NAS，都可以将 HTTP 容器或服务发布到公网：
- **Dashboard 操作**：
  1. 进入 **Networks** > **Tunnels** > 目标隧道 > **Public Hostname**。
  2. 点击 **Add a public hostname**：
     - **Subdomain / Domain**：例如 `web.example.com`
     - **Path**：可留空。
     - **Type**：选择 `HTTP` 或 `HTTPS`。
     - **URL**：输入宿主机内网 IP 或同一网络容器名（如 `localhost:8080`、`192.168.1.100:8080`）。
  3. 若源端为自签名证书，在 **Additional application settings** > **TLS** 勾选 `No TLS Verify`。

### 场景 2：安全访问 SSH 服务（Dashboard 配置 + 命令行登录）
无需在防火墙对外开放 22 端口，免遭爆破扫描：

#### 1. Dashboard 控制台配置
1. 访问 **Zero Trust 控制台** > **Networks** > **Tunnels** > 选择你的隧道。
2. 点击 **Public Hostname** 选项卡 > **Add a public hostname**。
3. 配置如下：
   - **Subdomain**：例如 `ssh`
   - **Domain**：选择你的域名（例如 `example.com`）
   - **Service Type**：选择 `SSH`
   - **URL**：输入目标服务器的本地地址，例如 `localhost:22`
4. 点击 **Save hostname** 保存。
5. （推荐）在 **Access** > **Applications** 中为 `ssh.example.com` 添加访问策略，限制仅授权邮箱或身份验证通过的用户可访问。

#### 2. 客户端命令行连接（单次命令）
客户端本地安装 `cloudflared` 后，可通过 `-o ProxyCommand` 单行命令直接登录：
```bash
# 命令行通过 cloudflared 代理登录 SSH
ssh -o ProxyCommand="/usr/local/bin/cloudflared access ssh --hostname %h" user@ssh.example.com
```

#### 3. 客户端配置文件配置（推荐别名方式）
在客户端 `~/.ssh/config` 中追加配置，可以自定义简短别名，指定真实 HostName 与登录用户名：
```text
Host myserver
    HostName ssh.example.com
    User root
    ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```
之后只需执行别名即可直接连接：
```bash
ssh myserver
```
*注：如果配置了 Access Policy，首次连接会弹出浏览器完成 Zero Trust 身份认证。*

### 场景 3：远程桌面访问（RDP）
将 Windows 远程桌面端口 `3389` 安全映射：
1. **Dashboard 配置**：
   - Hostname: `rdp.example.com`
   - Service: `rdp://localhost:3389`
2. **客户端本地连接**：
   - 客户端终端运行：
     ```bash
     cloudflared access rdp --hostname rdp.example.com --url localhost:3389
     ```
   - 打开 Windows 远程桌面连接软件，地址填写 `localhost:3389`。
3. **浏览器端渲染（Browser Rendering）**：
   - 在 Access Application 中开启 **Browser Rendering**，支持直接通过网页登录操作 Windows 桌面。

### 场景 4：连接私有网络（Private Network / CIDR）
充当企业内部软件定义网络（SDN / VPN 替代）：
1. 在 Zero Trust 中进入 **Networks** > **Routes** > **Create route**。
2. 选择 **Tunnel CIDR**，关联已建好的 Tunnel。
3. 输入内网 CIDR 段（如 `10.0.0.0/16` 或 `192.168.1.0/24`）。
4. 员工电脑安装 **Cloudflare WARP (One Client)** 并登录组织的 Zero Trust 团队域。
5. 员工在连接 WARP 后，即可直接无感知访问内网私有 IP（如 `http://192.168.1.50:8080`），流量自动通过隧道加密穿透。

---

## 8. Cloudflare Workers VPC 接入与绑定

Cloudflare Workers VPC 允许运行在全球边缘的 Workers Serverless 函数直接安全访问位于私有云（AWS、Azure、GCP、私有 IDC）或内网中的私有 API、内部微服务和数据库，而无需将这些服务暴露在公网上。

### 架构与接入方式对比
Workers VPC 主要通过已建立的 **Cloudflare Tunnel** 隧道建立私有打通链路，包含两种绑定模式：

| 特性 | VPC Services（特定服务绑定） | VPC Networks（整网绑定） |
| :--- | :--- | :--- |
| **作用范围** | 绑定到私网中特定的单个主机和端口 | 绑定到整条 Cloudflare Tunnel 或 Cloudflare Mesh 网络 |
| **配置项** | `service_id` | `tunnel_id` 或 `network_id: "cf1:network"` |
| **支持协议** | HTTP (`fetch()`)、TCP（通过 Hyperdrive 连接数据库） | HTTP (`fetch()`)、Raw TCP (`connect()`) 如 Redis/MQTT |
| **服务注册** | 必须在控制台逐个创建目标 Service | 无需预先注册单个服务，运行时由请求 URL 决定 |
| **适用场景** | 固定、受控的后端私有微服务或数据库 | 动态服务发现、整网打通、多集群私网互通 |

### 接入配置流程

#### 第一步：准备 Cloudflare Tunnel
确保目标私网环境内已部署 `cloudflared` 隧道，且隧道所在的机器能连通私网目标（如私有 API 或数据库）。

#### 第二步：在 Dashboard 中创建 VPC Service
1. 登录 Cloudflare 控制台，进入 **Workers & Pages** > **Workers VPC**。
2. 切换到 **VPC Services** 标签页，点击 **Create**。
3. 配置参数：
   - **Service Name**：例如 `my-internal-api`
   - **Tunnel**：选择此前建立的 Cloudflare Tunnel。
   - **Host or IP address**：内部私网服务地址（如 `10.0.1.50` 或 `internal-api.example.local`）。
   - **Ports**：选择默认端口（80/443）或自定义端口。
4. 创建成功后，记录生成的 **Service ID**。

*(亦可通过 Wrangler CLI 创建：`npx wrangler vpc service create my-internal-api --type http --tunnel-id <TUNNEL_ID> --hostname internal-api.example.local`)*

#### 第三步：Worker 项目配置绑定
在 Worker 项目的 `wrangler.jsonc` 中声明绑定：

##### 方式 A：绑定 VPC Service
```jsonc
{
  "name": "my-worker-app",
  "main": "src/index.ts",
  "compatibility_date": "2025-02-04",
  "vpc_services": [
    {
      "binding": "INTERNAL_API",
      "service_id": "<YOUR_SERVICE_ID>",
      "remote": true
    }
  ]
}
```

##### 方式 B：绑定整个 Tunnel（VPC Networks）
```jsonc
{
  "name": "my-worker-app",
  "main": "src/index.ts",
  "compatibility_date": "2025-02-04",
  "vpc_networks": [
    {
      "binding": "MY_VPC",
      "tunnel_id": "<YOUR_TUNNEL_UUID>",
      "remote": true
    }
  ]
}
```

#### 第四步：在 Worker 代码中调用私网服务
在 Worker 代码中即可直接对绑定的私网资源发起调用：

```typescript
export default {
  async fetch(request, env, ctx): Promise<Response> {
    // 1. 通过 VPC Service 绑定请求私有 API
    const res = await env.INTERNAL_API.fetch("http://internal-api.example.local/api/users");
    const data = await res.json();

    // 2. （可选）如果使用 VPC Networks，可直接动态请求该 Tunnel 覆盖的任意私网 IP
    // const vpcRes = await env.MY_VPC.fetch("http://10.0.1.50:8080/metrics");

    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" }
    });
  }
};
```

---

## 9. 进阶配置（Origin Parameters 与 Run Parameters）

### 源站连接参数（Origin Parameters）
在 Dashboard 的 **Public Hostname** > **Additional application settings** 或本地配置文件的 `originRequest` 中设置：
- `noTLSVerify`（布尔值）：当源站使用自签证书或无效证书时，设为 `true` 跳过验证。
- `httpHostHeader`（字符串）：覆写发往源站的 `Host` 头，适合源站基于虚拟主机的反向代理（如 Nginx `server_name` 匹配）。
- `originServerName`（字符串）：验证源站证书时期望的 SNI 名称。
- `connectTimeout`：连接源站的超时时间（默认 30s）。
- `tlsTimeout`：TLS 握手超时时间（默认 10s）。
- `http2Origin`（布尔值）：是否使用 HTTP/2 连接源站（默认 HTTP/1.1）。

### 运行参数（Run Parameters / 环境变量）
| 环境变量 / 参数 | CLI 选项 | 说明 |
| :--- | :--- | :--- |
| `TUNNEL_TOKEN` | `--token <TOKEN>` | 远程管理隧道的认证 Token。 |
| `TUNNEL_LOGLEVEL` | `--loglevel <LEVEL>` | 日志级别：`debug`、`info`（默认）、`warn`、`error`、`fatal`。 |
| `TUNNEL_LOGFILE` | `--logfile <PATH>` | 将日志输出到指定文件。 |
| `NO_AUTOUPDATE` | `--no-autoupdate` | 禁用自动升级（在容器中强烈推荐设置为 true）。 |
| `TUNNEL_PROTOCOL` | `--protocol <TYPE>` | 隧道通信协议：`auto`（默认）、`quic`（UDP 7844）或 `http2`（TCP 7844）。 |
| `TUNNEL_METRICS` | `--metrics <IP:PORT>` | 暴露 Prometheus 监控指标地址，例如 `localhost:2000`。 |

---

## 10. 防火墙要求与高可用部署

### 防火墙出站策略
`cloudflared` 仅发起**出站（Outbound）**连接，不需要任何外部入站端口：
- **目标端口**：`7844`（必需，支持 UDP 的 QUIC 协议或 TCP 的 HTTP/2 协议）。
- **目标域名**：`*.cfargotunnel.com` 以及相关 Cloudflare 边缘节点。
- **辅助端口**：`443`（TCP，用于认证及 API 与控制面板元数据拉取）。

### 高可用副本（Deploy Replicas）
想要避免单点故障，无需配置复杂的 Keepalived 或外部负载均衡：
- 只需在多个主机或不同的物理机上，使用**相同的 TUNNEL_TOKEN** 启动多个 `cloudflared` 容器或 systemd 服务。
- Cloudflare 会自动识别这些活跃副本，并将流量均衡分配到健康的实例上。一旦某个实例宕机，Cloudflare 会在秒级内自动剔除并故障转移。

---

## 11. 常见问题与排错指南

### 1. 隧道状态为 Inactive 或 Down
- 检查防火墙是否放行了到公网的 **UDP/TCP 7844 端口**。
- 如果网络环境屏蔽了 UDP，可以强制使用 TCP/HTTP2 协议：
  在启动参数加入 `--protocol http2`。

### 2. 访问域名返回 HTTP 502 Bad Gateway
- 502 表示 Cloudflare 已经联通了 `cloudflared`，但 `cloudflared` 无法访问你配置的本地服务。
- 检查 `URL` 配置：
  - 如果 `cloudflared` 运行在 Docker 容器中，访问宿主机不能用 `localhost`，而应该用宿主机内网 IP，或使用 `host.docker.internal`，或让服务处于同一 Docker 网络中。
- 检查本地服务是否已正常监听指定端口。

### 3. HTTPS 源站报错 x509: certificate signed by unknown authority
- 源站使用的是自签名证书。
- 在路由规则设置中启用 **No TLS Verify**（`noTLSVerify: true`），或者挂载你的私有根证书并通过 `caPool` 指定证书文件。
