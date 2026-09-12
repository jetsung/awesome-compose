# Warpgate

[Official Site][1] · [Source][2] · [Docker Image][3] · [Documentation][4]

[1]:https://warpgate.null.page/
[2]:https://github.com/warp-tech/warpgate
[3]:https://ghcr.io/warp-tech/warpgate
[4]:https://warpgate.null.page/docs

---

> **Warpgate** 是一个完全透明的代理/堡垒机，用于管理内部基础设施的访问。它支持 SSH、HTTPS、RDP、VNC、Kubernetes、PostgreSQL 和 MySQL 目标，提供 SSO、RBAC 和会话录制功能——无需安装专用客户端软件。

## 特性

### 协议支持

| 协议 | 说明 |
|------|------|
| **SSH** | 完整的 ciphers/key exchanges 支持，Tickets、2FA |
| **MySQL** | MySQL 8.x 文本协议，TLS 强制，Tickets |
| **PostgreSQL** | TLS 强制，Tickets、2FA（v0.14+） |
| **HTTP/HTTPS** | HTTP/1.1、HTTP/2、WebSocket、TLS、Tickets、2FA |
| **Kubernetes** | API 代理、`kubectl` 支持、会话录制（v0.22+） |
| **RDP** | 浏览器内桌面客户端、原生客户端、会话录制（v0.27+） |
| **VNC** | 浏览器内桌面客户端、原生客户端、会话录制（v0.27+） |

### 核心优势

- **无需客户端** — 直接暴露原生协议监听器，使用标准客户端或浏览器连接
- **非跳板机** — 透明处理认证后直连目标服务器，同时保存会话记录
- **内置安全** — 2FA、SSO（OIDC）、暴力破解保护、登录保护
- **无 SaaS** — 单一二进制文件或 Docker 镜像，完全自托管
- **无付费墙** — 100% 开源（Apache-2.0），所有功能免费
- **多节点集群** — 支持负载均衡、共享数据库、S3 存储（v0.27+）
- **凭据加密** — 静态凭据加密存储（v0.28+）

## 快速开始

### Docker

```bash
# 初始化配置
docker run --rm --user 0:0 -it -v warpgate-data:/data ghcr.io/warp-tech/warpgate setup

# 运行
docker run --rm --name warpgate \
  -p 8888:8888 \
  -p 2222:2222 \
  -it -v warpgate-data:/data \
  ghcr.io/warp-tech/warpgate
```

访问 `https://<host>:8888/` 进入管理界面。

### Docker Compose

```bash
# 下载配置文件
curl -LO https://raw.githubusercontent.com/warp-tech/warpgate/main/docker/docker-compose.yml

# 初始化并启动
docker compose run warpgate setup
docker compose up
```

### Helm（Kubernetes）

```bash
helm install warpgate oci://ghcr.io/warp-tech/helm-charts/warpgate \
  --namespace warpgate \
  --create-namespace
```

### 二进制文件

```bash
# 下载并安装
chmod +x /usr/bin/warpgate

# 初始化
warpgate setup

# 运行
warpgate run
```

## 默认端口

| 端口 | 协议 |
|------|------|
| `2222` | SSH |
| `8888` | HTTP（管理界面） |
| `33306` | MySQL |
| `55432` | PostgreSQL |

---

## 配置文件（warpgate.yaml）

### 配置文件位置与加载

- 默认路径 `/etc/warpgate.yaml`（Docker 中为数据卷内的 `warpgate.yaml`），可通过 `--config <path>` 指定；`warpgate setup` 交互生成
- 配置文件仅包含**全局设置与监听器**：用户、目标、角色、SSH 密钥等实体存储在数据库中，通过 Admin UI（或 API、Terraform）管理
- 保存后自动热重载：文件变更约 500ms 后生效，已建立的连接不受影响，新连接使用新配置
- 修改后可用 `warpgate check` 验证语法与未知字段（拼写错误会被警告并忽略）

### 顶层字段

| 字段 | 默认值 | 说明 |
|------|--------|------|
| `database_url` | `sqlite:data/db` | 数据库连接串。内置 SQLite（`sqlite:<路径>`）或外部 `mysql://…` / `postgres://…`（集群必需） |
| `external_host` | 空 | 对外访问地址（可含端口），用于生成连接指导、SSO 回调 URL 等 |

### 监听器

`ssh`、`http`、`kubernetes`、`mysql`、`postgres`、`rdp`、`vnc` 七个监听器共用以下字段：

| 字段 | 说明 |
|------|------|
| `enable` | 是否启用该监听器（`http` 无此字段，始终启用） |
| `listen` | 监听地址，如 `[::]:2222`（IPv6 兼容）或 `0.0.0.0:2222` |
| `certificate` / `key` | TLS 证书与私钥路径（`http` 必需；`ssh`/`kubernetes`/`mysql`/`postgres`/`rdp`/`vnc` 按需） |
| `external_host` / `external_port` | 对外公布地址，覆盖顶层 `external_host`，用于生成连接指导 |
| `proxy_protocol` | 是否接受 HAProxy PROXY protocol v1/v2 头（v0.27+，仅当上游四层负载均衡器确实前置时才开启） |

各监听器专用字段：

| 监听器 | 专用字段 | 说明 |
|--------|----------|------|
| `ssh` | `host_key_verification` | 主机密钥验证模式：`prompt` / `auto_accept` / `auto_reject` / `ignore`（仅在建库时写入，之后由 Admin UI 接管） |
| `ssh` | `inactivity_timeout` | 空闲超时，默认 `5m`；超时无数据活动即断开连接 |
| `ssh` | `keepalive_interval` | 保活间隔（默认关闭）。同时作用于监听端与 target 连接端，详见上文「SSH 目标」第 5 节 |
| `ssh` | `keys` | 遗留字段：SSH 客户端密钥已迁移至数据库（Admin UI > SSH keys），此处仅作首次启动导入 |
| `http` | `session_max_age` | Web 会话最大时长，默认 `30m`；超过后敏感操作需重新认证（v0.27+） |
| `http` | `cookie_max_age` | 浏览器登录 Cookie 寿命，默认 `1day` |
| `http` | `trust_x_forwarded_headers` | 反向代理场景信任 `X-Forwarded-Host` / `X-Forwarded-Proto` / `X-Forwarded-For`（代理必须转发这些头，详见「反向代理配置」） |
| `http` | `sni_certificates` | SNI 证书列表：`[{certificate, key}]`，按域名匹配，主证书兜底（v0.15+） |
| `kubernetes` | — | 端口默认 `8443` |
| `mysql` | `advertised_version` | 向客户端宣告的版本串，默认 `8.0.3-Warpgate` |
| `vnc` | `enable_ard_auth` | 启用 Apple-DH（ARD）认证（不支持 TLS） |

### 日志

```yaml
log:
  format: text          # text | json（json 供日志采集）
  retention: 7days      # 常规日志保留时长（humantime 格式）
  audit_retention: 11months 30days 3h 50m 24s   # 审计日志保留时长（约一年）
  send_to: null         # UNIX 数据报 socket 路径（如 /var/run/vector-warpgate.sock），null 为仅 stdout
```

### SSO 提供商

```yaml
sso_providers:
  - name: oidc-custom       # 唯一名称，必填
    label: ACME SSO         # 登录界面显示名
    auto_create_users: true # v0.13+：新用户首次 SSO 登录自动创建
    return_url_domain: external_host   # external_host | host_header（v0.23/0.25+ 域处理策略）
    return_url_prefix: '@'  # Azure 等不支持 @ 的提供商可用 '_'（v0.22+）
    provider:
      type: custom          # google | azure | apple | custom
      client_id: ...
      client_secret: ...
      issuer_url: https://sso.acme.inc
      scopes: [openid, email]
      role_mappings:        # 将 SSO claim 值映射到 Warpgate 角色
        'QA group': qa
      admin_role_mappings:  # 管理员角色映射
        Admins: 'warpgate:admin'
```

不同类型提供商字段差异：

- `google` — `client_id` / `client_secret`，可选 `service_account_email` / `service_account_key` / `admin_email` / `role_mappings`（Google Workspace 目录组同步，v0.22+）
- `azure` — `client_id` / `client_secret` / `tenant`
- `apple` — `client_id`（Service ID，非 App ID）/ `client_secret`（.p8 密钥的 Base64）/ `team_id` / `key_id`
- `custom` — `client_id` / `client_secret` / `issuer_url` / `scopes`，可选 `roles_claim` / `admin_roles_claim`（v0.26+ 读取 `groups` 等标准 claim）、`additional_trusted_audiences`、`trust_unknown_audiences`、`role_mappings` / `admin_role_mappings`

SSO 回调地址：`https://<external_host>/@warpgate/api/sso/return`（使用 `_` 前缀时为 `/_warpgate/api/sso/return`），需在提供商侧准确配置。

### 完整配置示例

```yaml
# ===== 全局 =====
database_url: sqlite:/var/lib/warpgate/db
external_host: warpgate.acme.inc

# ===== SSH 监听器（用户通过 ssh 连接）=====
ssh:
  enable: true
  listen: '[::]:2222'
  external_host: warpgate.acme.inc
  external_port: 2222
  host_key_verification: prompt
  inactivity_timeout: 5m
  keepalive_interval: 1m     # 防止空闲断连（必须小于 inactivity_timeout）
  proxy_protocol: false

# ===== HTTP 管理界面 =====
http:
  listen: '[::]:8888'
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem
  session_max_age: 30m
  cookie_max_age: 1day
  trust_x_forwarded_headers: true    # 前置反向代理时开启
  # sni_certificates:
  # - certificate: other.pem
  #   key: other.key.pem

# ===== 数据库监听器（按需启用）=====
mysql:
  enable: false
  listen: '[::]:33306'
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem

postgres:
  enable: false
  listen: '[::]:55432'
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem

kubernetes:
  enable: false
  listen: '[::]:8443'
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem

rdp:
  enable: false
  listen: '[::]:3389'
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem

vnc:
  enable: false
  listen: '[::]:5900'
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem

# ===== 日志 =====
log:
  format: text
  retention: 7days
  audit_retention: 11months 30days 3h 50m 24s

# ===== SSO =====
sso_providers:
  - name: google
    label: Google login
    provider:
      type: google
      client_id: 1234...
      client_secret: ABC...
```

### 注意事项

- `recordings` 配置段已废弃：会话录制的启用与存储路径已并入数据库，由 Admin UI 管理；旧配置会产生迁移警告，建议删除
- SSH 客户端密钥同样迁移至数据库，勿再依赖 `ssh.keys` 文件路径
- 内部私网 CA：原生部署自动使用宿主信任根；Docker 需将证书挂载到 `/etc/ssl/certs`
- 修改监听器端口/证书后，Warpgate 自动重载；`database_url` 等变更建议重启服务

---

## Access Control（访问控制）

### 用户认证方式

Warpgate 支持多种认证方式，可单独或组合使用：

| 认证方式 | 说明 |
|----------|------|
| 密码 | 基础认证，用户可自行管理 |
| 公钥（SSH） | 支持 Ed25519、RSA |
| TOTP（一次性密码） | 需要认证器应用（如 Google Authenticator） |
| SSO（OIDC） | 支持 Google、Azure、Apple、GitLab、Okta、Authentik 等 |
| API Token | 用于程序化访问 |
| 客户端证书（Kubernetes） | 浏览器内签发和存储 |

### 角色管理

Warpgate 有两种角色类型：

**访问角色（Access Roles）** — 用于将用户分配到目标：

```bash
# 管理界面：Config > Access roles
# 创建角色后，可在用户和目标的配置页面中分配
```

**管理员角色（Admin Roles，v0.23+）** — 授予管理界面的细粒度权限：

- 部分或完全访问管理界面
- 例如：允许管理目标但不允许管理用户

### 多因素认证（MFA）

在 `Auth policy` 中配置 SSH/HTTP 的多因素认证策略：

```bash
# 管理界面：Config > Users > [用户] > Auth policy
# 取消勾选 "Any credential"，选择需要的认证方式组合
```

### SSO 配置

在配置文件中添加 SSO 提供商：

```yaml
external_host: warpgate.acme.inc

sso_providers:
  - name: google
    label: Google login
    provider:
      type: google
      client_id: 1234...
      client_secret: ABC...
```

支持的 SSO 提供商：
- `google` — Google Accounts
- `azure` — Microsoft Azure
- `apple` — Apple ID
- `custom` — 任意 OIDC 提供商（Okta、Authentik、GitLab 等）

### 通过 SSO 同步角色

使用 `custom` 类型 OIDC 提供商时，可通过 `warpgate_roles` claim 同步用户角色：

```yaml
sso_providers:
  - name: oidc-custom
    provider:
      type: custom
      role_mappings:
        'QA group': 'qa'
        Admins: 'warpgate:admin'
```

### 浏览器内审批（Out-of-band 认证）

Warpgate 可要求用户在浏览器中批准登录请求，适用于无法交互式输入 2FA 的协议：

```bash
# SSH 连接时会显示登录 URL 和安全密钥
# 用户在浏览器中打开 URL 并批准请求
```

---

## Adding Targets（添加目标）

### SSH 目标

**1. 配置公钥认证**

查看 Warpgate 的公钥：

```bash
warpgate client-keys
```

将公钥添加到目标服务器的 `~/.ssh/authorized_keys`。

**2. 添加目标**

```bash
# 管理界面：Config > Targets > Add target
# 填写主机地址、端口、用户名、认证方式
```

**3. 连接**

```bash
ssh <用户名>:<目标名称>@<warpgate地址> -p 2222

# 示例
ssh admin:myserver@warpgate.example.com -p 2222
```

**4. Web 终端（v0.24+）**

用户可直接在浏览器中打开 Web SSH 终端，无需安装客户端。

**5. 保持 SSH 连接（防止空闲断连）**

Warpgate 不提供到 target 的 SSH 连接复用（无 ControlMaster/连接池）——每个 SSH 会话都会向 target 新建一条独立连接。长时间不操作时连接断开，是因为默认的空闲超时：在 `ssh.inactivity_timeout`（默认 `5m`）内无数据活动，用户与 Warpgate、Warpgate 与 target 两段链路都会被断开。

解决方法：设置 `ssh.keepalive_interval`。该全局参数会同时作用于监听端（用户与 Warpgate 之间）和 target 客户端端（Warpgate 连接 target 时），定期发送 SSH keepalive 请求，刷新两端的空闲计时器：

```yaml
# /etc/warpgate.yaml
ssh:
  keepalive_interval: 1m   # 每隔 1 分钟发送一次 keepalive（humantime 字符串）
  inactivity_timeout: 5m   # 默认 5 分钟；keepalive 生效后一般不会触发
```

注意：

- `keepalive_interval` 必须小于 `inactivity_timeout`，否则空闲计时器先于 keepalive 到期，连接照样断开。
- 仅在用户客户端配置 `ServerAliveInterval` 不够：OpenSSH 客户端的 keepalive 只保用户到 Warpgate 段，Warpgate 不会把它透传给 target，Warpgate 到 target 段仍会空闲断开。两端保活都依赖 Warpgate 自身的配置。
- 死连检测：连续 3 次（russh 默认 `keepalive_max`）keepalive 无响应时 Warpgate 会主动断开连接。正常 OpenSSH target 都会应答，仅网络彻底中断时触发。

### HTTP 目标

**1. 添加目标**

```bash
# 管理界面：Config > Targets > Add target
# 填写目标 URL（http:// 或 https://）
# 可选：绑定到特定子域名
```

**2. 访问方式**

```bash
# 方式一：通过 Warpgate 主页选择目标
# 方式二：直接访问带参数的 URL
https://<warpgate地址>:<端口>/?warpgate-target=<目标名称>
```

**3. 自定义请求头（v0.12+）**

Warpgate 自动添加以下头：

| 头 | 说明 |
|---|------|
| `x-warpgate-username` | 认证用户名 |
| `x-warpgate-authentication-type` | 认证方式 |

### MySQL 目标

**1. 启用 MySQL 监听器**

```yaml
# 配置文件 /etc/warpgate.yaml
mysql:
  enable: true
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem
```

**2. 添加目标**

```bash
# 管理界面：Config > Targets > Add target
# 填写主机地址、端口、数据库用户名和密码
```

**3. 连接**

```bash
# 使用 MySQL 客户端
mysql -h <warpgate地址> -P 33306 -u admin#<目标名称> -p

# 使用数据库 URL
mysql://admin#<目标名称>:<密码>@<warpgate地址>:33306?sslMode=required
```

**AWS RDS IAM 认证（v0.22+）**

如果 Warpgate 运行在 EC2 上，可使用 IAM 角色认证，无需存储密码。

### PostgreSQL 目标

**1. 启用 PostgreSQL 监听器**

```yaml
# 配置文件 /etc/warpgate.yaml
postgres:
  enable: true
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem
```

**2. 添加目标**

```bash
# 管理界面：Config > Targets > Add target
# 填写主机地址、端口、数据库用户名和密码
```

**3. 连接**

```bash
# 使用 PostgreSQL 客户端
psql "host=<warpgate地址> port=55432 user=admin#<目标名称> dbname=<数据库名> sslmode=require"

# 使用数据库 URL
postgresql://admin#<目标名称>:<密码>@<warpgate地址>:55432?sslmode=require
```

### Kubernetes 目标（v0.21+）

**1. 启用 Kubernetes 监听器**

```yaml
# 配置文件 /etc/warpgate.yaml
kubernetes:
  enable: true
  listen: '[::]:8443'
  certificate: /var/lib/warpgate/tls.certificate.pem
  key: /var/lib/warpgate/tls.key.pem
```

**2. 添加目标**

```bash
# 管理界面：Config > Targets > Add target
# 填写 Kubernetes API 地址和认证方式（证书/Token/IAM）
```

**3. 连接**

```bash
# 使用 kubectl
kubectl --server=https://<warpgate地址>:8443 --token=<API Token> get pods

# 通过 SSO 使用 kubelogin（v0.27+）
# 需要安装 kubelogin kubectl 插件
```

### RDP/VNC 目标（v0.27+）

**1. 添加目标**

```bash
# 管理界面：Config > Targets > Add target
# 填写主机地址、端口、认证信息
```

**2. 访问方式**

- 浏览器内桌面客户端
- 原生客户端（mstsc、FreeRDP、Remmina、TigerVNC 等）

### Access Tickets（访问票据）

用于非交互式会话（如数据库连接、API 访问），绕过 2FA：

```bash
# 管理界面：Config > Tickets
# 选择用户和目标，创建票据
# 使用票据连接（作为密码或连接字符串的一部分）
```

---

## Operations（运维管理）

### 会话监控

在管理界面中查看所有活跃会话：

```bash
# 管理界面：Sessions
# - 实时查看会话状态
# - 回放 SSH、Kubernetes、RDP、VNC 会话录制
# - 查看数据库查询日志
# - Shell 命令审计（v0.27+）
```

### 备份与恢复

**备份内容：**

| 项目 | 说明 |
|------|------|
| 配置文件 | `/etc/warpgate.yaml`（Docker 中在数据卷内） |
| 数据目录 | `/var/lib/warpgate`（Docker 中是 `/data` 卷） |
| 数据库 | SQLite 或外部 MySQL/PostgreSQL |
| 加密密钥 | `WARPGATE_ENCRYPTION_KEY`（如果启用） |
| 会话录制 | 默认在 `<data>/recordings` 或 S3 |

**SQLite 备份：**

```bash
sqlite3 /var/lib/warpgate/db/db.sqlite3 ".backup '/backups/warpgate-db.sqlite3'"
```

**PostgreSQL 备份：**

```bash
pg_dump "$DATABASE_URL" > warpgate.sql
```

**MySQL 备份：**

```bash
mysqldump --single-transaction warpgate > warpgate.sql
```

**恢复步骤：**

1. 安装相同版本的 Warpgate
2. 恢复配置文件和数据目录
3. 恢复数据库
4. 恢复 `WARPGATE_ENCRYPTION_KEY` 环境变量（如适用）
5. 启动并测试

### 升级

升级只需替换二进制文件或 Docker 镜像，数据库迁移自动完成：

```bash
# 二进制文件
systemctl restart warpgate

# Docker Compose
docker compose up -d

# Helm
helm upgrade warpgate . --namespace warpgate --set image.tag=<新版本>
```

**升级前注意：**
- 阅读目标版本的发布说明
- 备份配置文件、数据目录和数据库
- 建议在测试环境先验证

### 集群模式（v0.27+）

```yaml
# 所有节点共享同一数据库
database_url: postgres://user:password@dbhost/warpgate

# 节点间通信
WARPGATE_PEER_ADDRESS=host:port
```

**负载均衡：**
- 支持所有协议监听器
- 建议使用 PROXY protocol 以获取真实客户端 IP
- 在配置中启用 `proxy_protocol: true`

**会话录制存储：**
- 所有节点必须共享同一存储
- 支持 S3 兼容存储或共享文件系统

### 凭据加密（v0.28+）

```bash
# 生成加密密钥
openssl rand -base64 32

# 在所有节点设置环境变量
export WARPGATE_ENCRYPTION_KEY="<生成的密钥>"
```

**密钥轮换：**

```bash
# 1. 生成新密钥
# 2. 设置新旧密钥
export WARPGATE_ENCRYPTION_KEY="<新密钥>"
export WARPGATE_ENCRYPTION_KEY_OLD="<旧密钥>"

# 3. 滚动重启所有节点
# 4. 确认重新加密完成后移除 WARPGATE_ENCRYPTION_KEY_OLD
```

### 恢复管理员访问

```bash
warpgate recover-access
# 按提示选择用户并设置新密码
```

### 日志转发（v0.2+）

配置日志转发到 UNIX socket：

```yaml
# 配置文件
log:
  send_to: /var/run/vector-warpgate.sock
```

支持 [Vector](https://vector.dev) 等日志收集器。

### 反向代理配置

**NGINX 示例：**

```nginx
server {
    server_name warpgate.acme.inc;
    listen *:443 http2 ssl;
    ssl_certificate ...;
    ssl_certificate_key ...;

    location / {
        proxy_pass https://192.168.10.1:8888;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        proxy_read_timeout 3600s;
        proxy_http_version 1.1;
    }
}
```

配置中启用：

```yaml
http:
  trust_x_forwarded_headers: true
```

**开启后信任的头（取逗号列表第一个非空值，代理负责追加真实信息）：**

| 头 | 用途 | 代理必须转发 |
|----|------|-------------|
| `X-Forwarded-Host` | 构造外部 URL / SSO 回调（缺省回退 `Host`） | 推荐（不改写 `Host` 时可不发） |
| `X-Forwarded-Proto` | 判定 http/https，构造正确重定向（SSO 必需） | **必须**（`$scheme`） |
| `X-Forwarded-For` | 客户端真实 IP：登录保护、IP 封锁、审计 | **必须**（`$remote_addr`） |

**安全前提：** 开启后 Warpgate 无条件信任这些头，因此 `8888` 端口绝不能直接暴露给客户端——防火墙必须只允许反向代理访问；否则任何人都可伪造 `X-Forwarded-For` 绕过 IP 封锁，或伪造 `X-Forwarded-Proto` 篡改重定向。Caddy/Traefik 反向代理默认自动追加 `X-Forwarded-*` 三件套，无需额外配置。

**验证：** 开启后查看管理界面的会话列表或审计日志，客户端 IP 应显示真实公网地址而非代理地址；SSO 登录后浏览器地址栏的跳转域名应为 `external_host` 对应域名。

**PROXY protocol（v0.27+）：**

```yaml
ssh:
  listen: '[::]:2222'
  proxy_protocol: true
```

---

## Advanced Topics（高级主题）

### Terraform Provider

使用 Terraform 管理 Warpgate 配置：

```hcl
# 安装 Provider
terraform {
  required_providers {
    warpgate = {
      source = "warp-tech/warpgate"
    }
  }
}
```

详情参见：[terraform-provider-warpgate](https://github.com/warp-tech/terraform-provider-warpgate)

### 数据库迁移

从 SQLite 迁移到外部数据库：

```bash
warpgate copy-database postgres://user:password@dbhost/warpgate
```

然后更新配置文件中的 `database_url`。

### HTTP 域名绑定

将 HTTP 目标绑定到特定子域名：

```bash
# 管理界面：编辑目标 > Bind to a domain
# 设置子域名后可直接通过该域名访问目标
```

### Kubernetes SSO with kubelogin（v0.27+）

配置 OIDC 提供商以支持 kubectl SSO：

```yaml
sso_providers:
  - name: my-idp
    provider:
      type: custom
      client_id: ...
      client_secret: ...
      issuer_url: https://sso.acme.inc
      additional_trusted_audiences: ["kubernetes"]
    kubernetes:
      client_id: kubernetes
```

### AWS 集成

**EC2 Instance Connect（SSH，v0.22+）：**
- 无需在目标服务器存储密钥
- 自动推送公钥到 EC2 实例

**RDS IAM 认证（MySQL/PostgreSQL，v0.22+）：**
- 使用短期 IAM 令牌替代密码
- 需要 `rds-db:connect` 权限

**EKS IAM 认证（Kubernetes，v0.22+）：**
- 使用 IAM 角色认证到 EKS 集群
- 需要在 `aws-auth` ConfigMap 或 access entries 中配置

### 自定义登录横幅（v0.26+）

在 `Config > Global parameters > SSH banner` 设置自定义横幅，支持以下协议：

- SSH — 标准认证横幅
- HTTP — 可关闭的对话框
- PostgreSQL — 通知消息
- RDP/VNC — 确认横幅屏幕

### 限制 SSH 认证方法（v0.20+）

在 `Config > Global parameters > SSH authentication methods` 中禁用不需要的认证方式，防止网络扫描器暴力破解。

### 要求敏感操作重新认证（v0.27+）

在 `Config > Global parameters` 中设置 Web 会话最大时长，超过后需要重新认证才能打开 Web SSH 或远程桌面会话。

---

## 运维工具

- **Terraform Provider**：[warp-tech/terraform-provider-warpgate](https://github.com/warp-tech/terraform-provider-warpgate)
- **Helm Chart**：[官方 Helm Chart](https://github.com/warp-tech/warpgate/tree/main/helm/warpgate)
- **Kubernetes Operator**：社区维护

## 相关链接

- [官方文档](https://warpgate.null.page/)
- [Docker 快速开始](https://warpgate.null.page/getting-started-on-docker/)
- [Helm 部署指南](https://warpgate.null.page/getting-started-on-helm/)
- [协议支持详情](https://warpgate.null.page/protocol-support/)
- [用户认证](https://warpgate.null.page/auth/)
- [集群部署](https://warpgate.null.page/clustering/)
- [凭据加密](https://warpgate.null.page/encryption/)
- [备份恢复](https://warpgate.null.page/backup/)
- [升级指南](https://warpgate.null.page/upgrading/)
- [与 Teleport 对比](https://warpgate.null.page/warpgate-vs-teleport/)
- [与 StrongDM 对比](https://warpgate.null.page/warpgate-vs-strongdm/)
- [与 Boundary 对比](https://warpgate.null.page/warpgate-vs-boundary/)
- [企业支持](https://warpgate.null.page/for-business/)
