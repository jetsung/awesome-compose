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

# 启动（首次启动会使用镜像默认配置）
docker compose up -d

# 交互式初始化配置（生成 warpgate.yaml、设置管理员密码）
docker exec -it warpgate setup

# 配置完成后重启生效
docker compose restart
```

> **注意：** `docker exec -it` 需要容器开启交互，请确认 `compose.yaml` 中包含以下配置：
>
> ```yaml
> stdin_open: true   # 等价于 docker run -i
> tty: true          # 等价于 docker run -t
> command: setup
> ```
>
> 添加后 `docker compose up` 启动即进入 setup 交互模式，配置完成后再改为正常运行（去掉 `command: setup` 或按上方 `docker exec` 方式操作）。
>
> 另一种方式：不修改 compose 文件，直接 `docker compose run warpgate setup` 一次性初始化，然后 `docker compose up` 启动。

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

#### 排查：已删除 MFA 密钥并关闭 MFA，登录仍要求验证码

**现象：** 删除了用户的 TOTP 密钥，全局 MFA 强制策略也已设为 `Off`，但该用户登录（HTTP 与 SSH 均如此）仍被要求输入 OTP，且输入任何验证码都无法通过，形成「要求 OTP 但永远无法通过」的死锁。

**根因：** Warpgate 对 MFA 的判定有**两条相互独立的路径**，只关其一不够：

1. **全局 MFA 强制策略**（`parameters` 表 `mfa_enforcement`，取值 `Off`/`Enroll`/`Require`，见 `warpgate-db-entities/src/Parameters.rs` 的 `mfa_required_factor()`）——`Off`/`Enroll` 不强制第二因子，`Require` 才按协议强制第二因子（`Totp` 或浏览器内审批）；设为 `Off` 只是不追加全局强制，**不能移除用户级策略中已有的要求**。
2. **用户级凭证策略**（`users` 表 `credential_policy` 列，即管理界面中的 "Required credential types"，如 `{"http":["password","otp"],"ssh":["password","otp"]}`）——`credential_policy_for_user()`（`warpgate-core/src/config_providers/db.rs`）把策略中列出的每一项交给 `AllCredentialsPolicy::is_sufficient()`（`warpgate-common/src/auth/policy.rs`）判定，要求有效凭证**覆盖全部要求项**，缺哪项就继续索要哪项；残留的 `otp` 会让登录流程持续要求验证码，而 TOTP 密钥已删（`credentials_otp` 表无记录），`verify_totp()` 找不到任何可校验的密钥，输入什么都会失败 → 死锁。

**为什么会死锁：** 删除 TOTP 密钥只清空 `credentials_otp`，关闭全局 MFA 只改 `parameters.mfa_enforcement`，两者都**不会修改** `users.credential_policy`——残留的 `otp` 要求无人清理，形成「永远索要、永远失败」的死循环。

**排查步骤**（SQLite 存储，路径见 `warpgate.yaml` 的 `database_url`，数据卷内 `db/db.sqlite3`）：

```bash
# 1. 全局 MFA 设置（输出 Off|0 说明问题不在这里）
sqlite3 db/db.sqlite3 "SELECT mfa_enforcement, mfa_policy_exempt_sso_users FROM parameters;"

# 2. 各用户凭证策略 —— "otp" 出现在哪个协议列表，该协议登录就会索要验证码
sqlite3 db/db.sqlite3 "SELECT username, credential_policy FROM users;"

# 3. 确认 OTP 密钥是否已删干净
sqlite3 db/db.sqlite3 "SELECT COUNT(*) FROM credentials_otp;"
```

**解决方法：**

- 方法一（推荐）：管理界面 → 用户管理 → 对应用户 → 编辑「要求的凭证类型」，去掉对应协议（HTTP / SSH）下的 **Totp** 勾选并保存。
- 方法二（直接改库，改前备份、建议先停止服务）：

  ```bash
  cp db/db.sqlite3 db/db.sqlite3.bak-mfa
  sqlite3 db/db.sqlite3 "UPDATE users SET credential_policy='{\"http\":[\"password\"],\"ssh\":[\"password\"]}' WHERE username='admin';"

  # 验证
  sqlite3 db/db.sqlite3 "SELECT username, credential_policy FROM users WHERE username='admin';"
  sqlite3 db/db.sqlite3 "SELECT COUNT(*) FROM credentials_otp;"
  ```

  策略是登录时实时读取的，通常无需重启即可生效；若 Web 端仍有残留会话状态，重新打开登录页即可。

**预防建议：**

- 删除 TOTP 密钥**前**，先取消用户策略中对 Totp 的强制要求，避免死锁。
- 排查时全局「MFA 强制」与用户「要求的凭证类型」都要检查，两者独立生效。
- **上游改进方向**：删除 OTP 凭证时自动从受影响用户的 `credential_policy` 移除对应项，或无可用 OTP 密钥时放行降级登录，避免管理员误操作把用户完全锁死。

### SSO / OIDC 配置

Warpgate 可使用任意 OpenID Connect（OIDC）提供商，基于用户**已验证的邮箱**认证登录。OIDC 提供商包括但不限于：Google Accounts、Sign in with Apple、GitLab、Microsoft Azure、Okta、Authentik。

在提供商侧注册 Warpgate 为应用，获得 Client ID / Client Secret，并配置回调（Redirect）URL：

```
https://<external_host>/@warpgate/api/sso/return
```

> Azure 等不允许 URL 中出现 `@` 的提供商，可改用下划线前缀（v0.22+）：`return_url_prefix: _`，回调地址相应变为 `/_warpgate/api/sso/return`。

然后在配置文件中添加 SSO 提供商：

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

支持的 SSO 提供商类型：
- `google` — Google Accounts
- `azure` — Microsoft Azure（额外需要 `tenant`）
- `apple` — Apple ID（需要 `team_id` / `key_id`，`client_id` 为 Service ID）
- `custom` — 任意 OIDC 提供商（Okta、Authentik、GitLab 等），需要 `issuer_url` / `scopes`

**自动创建用户（v0.13+）：** 设置 `auto_create_users: true` 后，新用户首次 SSO 登录时自动创建账号——用户名取自 `preferred_username` claim（缺失时回退 `email`）。已有同名用户需手动在其凭据列表中添加 SSO 凭据进行关联。

**报错 `No user matching <email>`：** SSO 登录按**邮箱**匹配 Warpgate 用户；若 SSO 登录的邮箱（如 `user@example.com`）不是任何已有用户的邮箱，Warpgate 会拒绝登录。修复方式二选一：

1. **自动创建用户（推荐）**——在对应 SSO 提供商下开启 `auto_create_users: true`，该邮箱首次登录时会自动创建名为 user1（取自 `preferred_username`）的新用户；之后在管理界面 `Config` > `Users` > 新用户 > `Access roles` 给它分配角色即可访问目标：

   ```yaml
   sso_providers:
     - name: oidc-custom
       label: My SSO
       auto_create_users: true     # SSO 新邮箱自动建用户
       provider:
         type: custom
         ...
   ```

   修改的是数据卷内的 `warpgate.yaml`（Docker 中为 `/data/warpgate.yaml`），改完 `docker compose restart` 生效。

2. **手动关联已有用户**——保持 `auto_create_users` 关闭，先用 admin 登录管理界面，进入 `Config` > `Users` > 选择用户（如 user1）> 凭据区点击 `Add SSO`，绑定 `user@example.com`。注意：用户是按邮箱匹配的，若 admin 用户的邮箱就是 `user@example.com`，给 admin 添加 SSO 凭据即可；若想让 SSO 账号对应一个独立用户，需先创建该用户并确保其邮箱与 SSO 邮箱一致（或走方式 1）。

   前提：SSO 提供商侧该邮箱必须是**已验证**状态，否则 Warpgate 仍会拒绝关联。

**用户关联 SSO（Add SSO）：** 在管理界面 `Config` > `Users` > 选择用户 > **Credentials** 区域点击 `Add SSO`，弹窗包含两个字段：

| 字段 | 说明 |
|------|------|
| **E-mail**（必填） | 用于与 SSO 登录时 IdP 返回的邮箱匹配。只有该邮箱通过 SSO 登录，才能以此 Warpgate 用户身份登录。 |
| **SSO provider**（下拉，默认 `Any`） | `Any` 表示任何已配置的 SSO 提供方返回该邮箱即匹配；指定某提供方（如 `Authelia`）则仅该提供方登录时匹配。选项来自 `warpgate.yaml` 的 `sso_providers`（显示 `label`，无 `label` 则显示 `name`）。 |

保存行为（弹窗组件 `warpgate-web/src/admin/SsoCredentialModal.svelte`）：点击 `Save` 提交（E-mail 为空不提交，并触发浏览器原生 email 格式校验），`Cancel` 关闭弹窗不做修改；编辑已有凭证时弹窗自动回填 `provider` 与 `email`。保存后写入数据库 `credentials_sso` 表（`email`、`provider` 两列，provider 为空即 `Any`）。

注意事项：

- **未配置任何 SSO 提供方时**，弹窗会警告 "You don't have any SSO providers configured"——需先在配置文件中添加 `sso_providers`。
- **邮箱必须已验证**：若提供方返回 `email_verified: false`，Warpgate 会拒绝登录；邮箱不一致或未验证都会匹配失败。
- 关联后可将 SSO 设为 HTTP 连接的唯一认证方式；SSH 可改用浏览器内（out-of-band）认证，在终端打印登录 URL 由用户在浏览器中完成 SSO 登录。
- 若勾选了全局参数中的 "Exempt SSO users from MFA enforcement"，拥有 SSO 凭证的用户可豁免全局 MFA 强制（但用户级凭证策略中残留的 `otp` 要求仍独立生效，见上文「多因素认证」排查章节）。

**OIDC audience 校验（仅 `custom`）：** 若提供商签发的 token audience 不只针对 Warpgate，可用 `additional_trusted_audiences` 白名单额外 audience，或 `trust_unknown_audiences: true`（v0.13.1+）忽略多余 audience。

**通过 SSO 同步角色：** `custom` 类型提供商可通过 `warpgate_roles` / `warpgate_admin_roles` claim（v0.26+ 支持 `roles_claim: groups` 等标准 claim）同步用户角色，或用 `role_mappings` / `admin_role_mappings` 显式映射：

```yaml
sso_providers:
  - name: oidc-custom
    provider:
      type: custom
      role_mappings:
        'QA group': 'qa'
        Admins: 'warpgate:admin'
```

**Authelia 示例（custom 类型 OIDC）：**

```yaml
sso_providers:
  - name: authelia
    label: Authelia
    # return_url_domain: external_host   # external_host | host_header（v0.23/0.25+ 域处理策略）
    return_url_domain: host_header
    return_url_prefix: '@'  # Azure 等不支持 @ 的提供商可用 '_'（v0.22+）
    provider:
      type: custom
      client_id: <Client ID>          # Authelia OIDC 客户端 ID
      client_secret: <Client Secret>  # Authelia OIDC 客户端密钥
      issuer_url: https://auth.example.com
      scopes: [openid, email]
      role_mappings:        # 将 SSO claim 值映射到 Warpgate 角色
        'QA group': qa
        'user@example.com': admin
      admin_role_mappings:  # 管理员角色映射
        Admins: 'warpgate:admin'
```

> **Authentik 注意：** 必须为 provider 分配签名密钥（RSA 或 ECDSA），否则其 JWKS 端点返回空文档，Warpgate 会报 `provider discovery error: Failed to parse server response`。

若用户主要使用 SSO，可在 `Config` > `Global parameters` > `Login` 中隐藏或禁用密码登录表单。

### 浏览器内审批（Out-of-band 认证）

Warpgate 可要求用户在浏览器中批准登录请求，适用于无法交互式输入 2FA 的协议：

```bash
# SSH 连接时会显示登录 URL 和安全密钥
# 用户在浏览器中打开 URL 并批准请求
```

---

## Adding Targets（添加目标）

### SSH 目标

**1. 配置公钥认证（两侧）**

- **用户侧**：把本地主机的公钥（`~/.ssh/id_ed25519.pub` 等）添加到 Warpgate 的 **Public keys** —— 登录后进入个人资料页 `/@warpgate/#/profile/credentials`，点击 `Add public key` 粘贴保存。这样用户即可用本地私钥通过 Warpgate 认证。
- **目标主机侧**：target 主机需要信任 Warpgate 的公钥。查看 Warpgate 公钥（管理界面 `Config` > `SSH keys`，或命令行）：

```bash
warpgate client-keys
```

将公钥添加到 target 主机的 `~/.ssh/authorized_keys`（文件不存在则创建，注意属主与权限为 `600`）：

```bash
echo "<warpgate公钥>" >> ~/.ssh/authorized_keys
```

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
