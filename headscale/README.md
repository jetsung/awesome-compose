# Headscale

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Headscale][1] 是 Tailscale 控制服务器的开源自托管实现。

[1]:https://headscale.net/
[2]:https://github.com/juanfont/headscale
[3]:https://hub.docker.com/r/headscale/headscale
[4]:https://headscale.net/stable/setup/install/container/

---

## 配置

1. 下载 `config.yaml` 配置文件
```bash
curl -o config/headscale.yaml https://raw.githubusercontent.com/juanfont/headscale/v0.27.1/config-example.yaml
```

2. 更新配置
```bash
# 主服务
sed -i 's#^listen_addr:.*#listen_addr: 0.0.0.0:8080#g' config/headscale.yaml

# metrics 服务
sed -i 's#^metrics_listen_addr:.*#metrics_listen_addr: 0.0.0.0:9090#g' config/headscale.yaml

# 绑定的域名
sed -i 's#^server_url:.*#server_url: https://MYHEADSCALE.EXAMPLE.COM#g' config/headscale.yaml

# 在 Tailscale 的配置中添加服务器地址（建议启用 https）
# TS_EXTRA_ARGS=--login-server=https://MYHEADSCALE.EXAMPLE.COM

# 修改基础域名。以便使用主机时可以通过 hostname.base_domain 方式访问
sed -i 's#^  base_domain:.*#  base_domain: domain.xx#g' config/headscale.yaml
```

建议使用[环境变量设置](https://github.com/juanfont/headscale/blob/main/integration/hsic/config.go#L24)
```bash
# 日志级别，可选：debug / info / warn / error / trace
HEADSCALE_LOG_LEVEL=trace

# 自定义策略文件路径（ACL 配置），留空表示默认
HEADSCALE_POLICY_PATH=

# 数据库类型，可选：sqlite / postgres / mysql
HEADSCALE_DATABASE_TYPE=sqlite

# SQLite 数据库文件路径（仅 sqlite 时有效）
HEADSCALE_DATABASE_SQLITE_PATH=/tmp/integration_test_db.sqlite3

# 数据库调试开关，0=关闭，1=开启
HEADSCALE_DATABASE_DEBUG=0

# GORM 慢查询阈值（秒），超过该值会记录慢查询
HEADSCALE_DATABASE_GORM_SLOW_THRESHOLD=1

# 临时节点（Ephemeral Node）闲置超时时间，超过该时间节点将被移除
HEADSCALE_EPHEMERAL_NODE_INACTIVITY_TIMEOUT=30m

# 分配给 Headscale / Tailscale 节点的 IPv4 网段（通常是 100.64.0.0/10）
HEADSCALE_PREFIXES_V4=100.64.0.0/10

# 分配给 Headscale / Tailscale 节点的 IPv6 网段
HEADSCALE_PREFIXES_V6=fd7a:115c:a1e0::/48

# MagicDNS 的基础域名（所有节点 hostname 将解析到此域名下）
HEADSCALE_DNS_BASE_DOMAIN=headscale.net

# 是否启用 MagicDNS（自动解析节点 hostname）
HEADSCALE_DNS_MAGIC_DNS=true

# 是否覆盖本地 DNS，false 表示本地 DNS 请求仍会正常解析
HEADSCALE_DNS_OVERRIDE_LOCAL_DNS=false

# 全局 DNS 服务器列表（空格分隔）
HEADSCALE_DNS_NAMESERVERS_GLOBAL=127.0.0.11 1.1.1.1

# Headscale 私钥路径（节点身份签名用）
HEADSCALE_PRIVATE_KEY_PATH=/tmp/private.key

# Noise 私钥路径（WireGuard 握手加密用）
HEADSCALE_NOISE_PRIVATE_KEY_PATH=/tmp/noise_private.key

# Prometheus 兼容的 metrics 监听地址
HEADSCALE_METRICS_LISTEN_ADDR=0.0.0.0:9090

# DERP 服务器 URL，用于跨 NAT / 公网节点中继
HEADSCALE_DERP_URLS=https://controlplane.tailscale.com/derpmap/default

# 是否允许自动更新 DERP 地图
HEADSCALE_DERP_AUTO_UPDATE_ENABLED=false

# DERP 自动更新频率（仅在自动更新开启时有效）
HEADSCALE_DERP_UPDATE_FREQUENCY=1m

# Debug 端口，用于调试和诊断
HEADSCALE_DEBUG_PORT=40000

# 分配节点 IP 的方式，可选：sequential（顺序）、random（随机）
HEADSCALE_PREFIXES_ALLOCATION=sequential
```

**额外提示**：
> 1. `HEADSCALE_DNS_BASE_DOMAIN` + `HEADSCALE_DNS_MAGIC_DNS=true` 可以让节点在 VPN 内用 `<hostname>.headscale.net` 互相访问
> 2. `HEADSCALE_PREFIXES_V4/V6` 决定了 Tailscale 分配给节点的 IP 地址池
> 3. `HEADSCALE_EPHEMERAL_NODE_INACTIVITY_TIMEOUT` 适合短期临时节点，如 CI/CD 测试容器
> 4. `HEADSCALE_NOISE_PRIVATE_KEY_PATH` 与 `HEADSCALE_PRIVATE_KEY_PATH` 建议挂载 volume 保持持久，否则容器重启节点会换身份

3. 查看可用性
```bash
curl http://127.0.0.1:8080/health
```

## 操作
```bash
# 创建用户（替换 myuser 为你想要的用户名）
docker exec -it headscale \
    headscale users create myuser

# 列出所有用户，找到 "myuser" 对应的 ID
docker exec -it headscale \
    headscale users list

# ID | Name | Username | Email | Created  
# 1  |      | myuser   |       | 2026-01-31 15:42:13

# 生成预授权 key（用于客户端加入，--reusable 可重复用，--expiration 设置过期时间）
docker exec -it headscale \
    headscale preauthkeys create --user 1 --reusable --expiration 90d

# # 查看用户 ID 1 预授权 key
docker exec -it headscale headscale preauthkeys list --user 1
# ID | Key                                              | Reusable | Ephemeral | Used  | Expiration          | Created             | Tags
# 1  | 75950e9c151d9d36df6a59d1be67c46c2e3fbba6a0426cd0 | true     | false     | false | 2026-05-01 15:45:33 | 2026-01-31 15:45:33 |

# 查看节点列表
docker exec -it headscale headscale nodes list

# 生成 API key（如果要用 Headplane 等 Web UI）
docker exec -it headscale headscale apikeys create --expiration 365d

# 查询 API key 相关信息
docker exec -it headscale headscale apikeys list
# ID | Prefix  | Expiration          | Created  
# 1  | zld_wI1 | 2027-01-31 15:50:01 | 2026-01-31 15:50:01

# 删除 API key
docker exec -it headscale headscale apikeys delete --prefix zld_wI1

# 查看帮助（所有命令）
docker exec -it headscale headscale --help
```

- 删除用户
```bash
docker exec -it headscale \
    headscale users destroy --name myuser

# Do you want to remove the user "myuser" (1) and any associated preauthkeys? [y/n] y
# Cannot destroy user: user not empty: node(s) found
```

- 删除节点
```bash
# 查看所有节点
docker exec -it headscale \
    headscale nodes list

# 删除节点
docker exec -it headscale \
    headscale nodes delete -i 1

# Do you want to remove the node tailscale? [y/n] y
# Node deleted
```

### Tailscale 使用
```bash
# 查看帮助
docker exec -it tailscale tailscale --help

# 查看节点
docker exec -it tailscale tailscale status

# 检测连接（只能测试 Docker 内部网络）
docker exec -it tailscale tailscale ping 100.64.0.2
```

## 使用教程
```bash
# headscale ####################
## 启动后，创建 API KEY
docker exec -it headscale headscale apikeys

## 保存至环境变量后，重新启动
HEADPLANE_OIDC__HEADSCALE_API_KEY=

## 创建用户
docker exec -it headscale headscale users create i@jetsung.com

## 列出所有用户信息（取 id）
docker exec -it headscale headscale users list

## 创建 AuthKey
docker exec -it headscale headscale preauthkeys create \
  --user 2 \
  --reusable

# tailscale ####################
## AuthKey 保存至 tailscale 环境变量
TS_AUTHKEY=

## 主机名
TS_HOSTNAME=

## Headplane 连接地址
TS_EXTRA_ARGS=--login-server=https://headscale.server --accept-routes
```

---
# Headplane

[Office Web][11] - [Source][12] - [Docker Image][13] - [Document][14]

---

> [Headplane][1] 是一个功能齐全的 Headscale 网页界面，让你轻松管理节点、网络和 ACL。

[11]:https://headplane.net/
[12]:https://github.com/tale/headplane
[13]:https://github.com/tale/headplane/pkgs/container/headplane
[14]:https://headplane.net/install/docker

---

## 配置
1. 下载 `config.yaml` 配置文件
```bash
curl -o config/headplane.yaml https://raw.githubusercontent.com/tale/headplane/refs/heads/main/config.example.yaml
```

2. 更新配置
```bash
# server.cookie_secret
openssl rand -hex 16

# cookie_secure 设置为
# false

# headscale.url 设置为
# http://headscale:8080
```

**配置：**[`.env`](https://headplane.net/configuration/)
```bash
# 使用 .env 覆盖
HEADPLANE_LOAD_ENV_OVERRIDES=true

# 服务器密钥
# openssl rand -hex 16
HEADPLANE_SERVER__COOKIE_SECRET=

# 禁用 https
HEADPLANE_SERVER__COOKIE_SECURE=false

# headscale 服务
HEADPLANE_HEADSCALE__URL=http://headscale:8080
```

## 操作

### Headscale 使用
```bash
# 创建密钥
headscale apikeys create --expiration 90d
```

### [OIDC 第三方社交登录](https://headplane.net/features/sso)（推荐）
> 1. 推荐修改 Headplane 平台的 `.env`
> 2. 不支持 GitHub、Gitea（client_id 问题）
> 3. 支持 Google
> 4. token_endpoint_auth_method 的值：`client_secret_post, client_secret_basic, client_secret_jwt`
> 5. 回调网址：`https://<URL>/admin/oidc/callback`

| 平台 | ISSUER | ENDPOINT_AUTH_METHOD |
| --- | --- | --- |
| GitLab | - | `client_secret_post` |


```bash
# OIDC
# 如果使用 OIDC，可以禁用 API Key 登录
HEADPLANE_OIDC__DISABLE_API_KEY_LOGIN=true

HEADPLANE_OIDC__HEADSCALE_API_KEY=<generated-api-key>
HEADPLANE_OIDC__ISSUER=https://your-idp.com
HEADPLANE_OIDC__CLIENT_ID=your-client-id
HEADPLANE_OIDC__CLIENT_SECRET=your-client-secret
HEADPLANE_OIDC__TOKEN_ENDPOINT_AUTH_METHOD=client_secret_basic
HEADPLANE_OIDC__SCOPE=openid email profile
```

- `config/headplane.yaml`
```yaml
oidc:
  headscale_api_key: "<generated-api-key>"
  issuer: "https://your-idp.com"
  client_id: "your-client-id"
  client_secret: "your-client-secret"
  token_endpoint_auth_method: "client_secret_basic"
  scope: "openid email profile"
```
