## 使用 Tailscale 与 Docker

> 此文档从[**官方 Tailscale 文档**](https://tailscale.com/kb/1282/docker)提取并转为简体中文。

Tailscale 有一个已发布的 Docker 镜像，由 Tailscale 管理并从源代码构建。它可在 [Docker Hub](https://hub.docker.com/r/tailscale/tailscale) 和 [GitHub Packages](https://github.com/orgs/tailscale/packages/container/package/tailscale) 上获取。观看下面的视频，了解使用 Docker 与 Tailscale 的快速入门指南。

### 拉取镜像
要拉取镜像，运行：
```bash
docker pull tailscale/tailscale:latest
```
或
```bash
docker pull ghcr.io/tailscale/tailscale:latest
```

### 支持的标签
容器根据 Tailscale [版本控制方案](https://tailscale.com/kb/1168/versions) 进行标记。
- 使用 `stable` 或 `latest` 获取最新的稳定版本。
    - `v1.58.2`，`v1.58` 可获取特定的稳定版本。
- 使用 `unstable` 获取最新的不稳定版本。
    - `unstable-v1.59.37`，`unstable-v1.59.44` 可获取特定的不稳定版本。

### 参数
你可以为镜像设置其他参数。所有配置都是可选的。

#### `TS_ACCEPT_DNS`
接受来自管理控制台的 [DNS 配置](https://tailscale.com/kb/1054/dns)。默认不接受。

#### `TS_AUTH_ONCE`
仅在尚未登录时尝试登录。默认值为 false，以便每次容器启动时强制登录。

#### `TS_AUTHKEY`
用于对容器进行身份验证的 [身份验证密钥](https://tailscale.com/kb/1085/auth-keys)。这相当于你传递给 [tailscale login --auth-key=](https://tailscale.com/kb/1080/cli#login) 的内容。

也可以在此处使用 [OAuth 客户端](https://tailscale.com/kb/1215/oauth-clients#register-new-nodes-using-oauth-credentials) 密钥，但必须使用 [TS_EXTRA_ARGS=--advertise-tags=tag:ci](https://tailscale.com/kb/1282/docker#ts_extra_args) 提供相关标签。

要将容器化节点标记为临时节点，请在身份验证密钥或 OAuth 客户端密钥后附加 `?ephemeral=true`。

此参数不能与 `TS_CLIENT_ID`、`TS_CLIENT_SECRET`、`TS_ID_TOKEN` 或 `TS_AUDIENCE` 一起使用。

#### `TS_CLIENT_ID`
OAuth 客户端 ID。可以单独使用（例如，在 GitHub Actions 等知名环境中自动生成 ID 令牌时），与 `TS_CLIENT_SECRET` 一起用于 OAuth 身份验证，与 `TS_ID_TOKEN` 一起用于 [工作负载身份联合](https://tailscale.com/kb/1612/workload-identity-federation)，或与 `TS_AUDIENCE` 一起在支持的环境中自动生成 ID 令牌。

如果值以 `file:` 开头，则将其视为包含客户端 ID 的文件路径。

#### `TS_CLIENT_SECRET`
用于生成身份验证密钥的 OAuth 客户端密钥。必须与 `TS_CLIENT_ID` 一起用于 OAuth 身份验证。

如果值以 `file:` 开头，则将其视为包含密钥的文件路径。

此参数不能与 `TS_ID_TOKEN` 或 `TS_AUDIENCE` 一起使用。

#### `TS_DEST_IP`
将所有传入的 Tailscale 流量代理到指定的目标 IP。

#### `TS_HEALTHCHECK_ADDR_PORT`
已弃用。从 1.78 版本开始，请改用 `TS_ENABLE_HEALTH_CHECK`（可选使用 `TS_LOCAL_ADDR_PORT`）。

#### `TS_LOCAL_ADDR_PORT`
此功能在 Tailscale 1.78 及更高版本中可用。

指定在通过 `TS_ENABLE_METRICS` 或 `TS_ENABLE_HEALTH_CHECK` 启用时，用于提供本地指标和健康检查 HTTP 端点的 `<addr>:<port>`。默认在所有可用接口上为 `[::]:9002`。

#### `TS_ENABLE_HEALTH_CHECK`
此功能在 Tailscale 1.78 及更高版本中可用。

设置为 `true` 以在 `TS_LOCAL_ADDR_PORT` 指定的地址启用未经身份验证的 `/healthz` 端点。

如果节点至少有一个 [尾网](https://tailscale.com/kb/1136/tailnet) IP 地址，健康检查返回 `200 OK`，否则返回 `503`。

#### `TS_ENABLE_METRICS`
此功能在 Tailscale 1.78 及更高版本中可用。

设置为 `true` 以在 `TS_LOCAL_ADDR_PORT` 指定的地址启用未经身份验证的 `/metrics` 端点。

有关指标的更多信息，请参阅 [客户端指标](https://tailscale.com/kb/1482/client-metrics)。

#### `TS_HOSTNAME`
为节点使用指定的主机名。这相当于 [tailscale set --hostname=](https://tailscale.com/kb/1080/cli#set)。

#### `TS_ID_TOKEN`
来自身份提供商的用于 [工作负载身份联合](https://tailscale.com/kb/1612/workload-identity-federation) 的 ID 令牌。必须与 `TS_CLIENT_ID` 一起使用。

如果值以 `file:` 开头，则将其视为包含令牌的文件路径。

此参数不能与 `TS_CLIENT_SECRET` 或 `TS_AUDIENCE` 一起使用。

#### `TS_AUDIENCE`
在向知名身份提供商请求用于 [工作负载身份联合](https://tailscale.com/kb/1612/workload-identity-federation) 的 ID 令牌时使用的受众。在支持自动生成 ID 令牌的环境（如 GitHub Actions、Google Cloud 或 AWS）中使用此参数。必须与 `TS_CLIENT_ID` 一起使用。

此参数不能与 `TS_CLIENT_SECRET` 或 `TS_ID_TOKEN` 一起使用。

#### `TS_KUBE_SECRET`
如果在 [Kubernetes 中运行](https://tailscale.com/kb/1185/kubernetes)，则为 Tailscale 状态存储的 [Kubernetes 密钥](https://kubernetes.io/docs/concepts/configuration/secret) 名称。默认值为 `tailscale`。

如果未设置 `TS_AUTHKEY`，并且 `TS_KUBE_SECRET` 包含带有 `authkey` 字段的密钥，则该密钥将用作 Tailscale 身份验证密钥。

#### `TS_OUTBOUND_HTTP_PROXY_LISTEN`
设置 [HTTP 代理](https://tailscale.com/kb/1112/userspace-networking#socks5-vs-http) 的地址和端口。这将传递给 `tailscaled --outbound-http-proxy-listen=`。例如，要将 SOCKS5 代理设置为端口 1055，此处为 `:1055`，这相当于 `tailscaled --outbound-http-proxy-listen=:1055`。

#### `TS_ROUTES`
通告 [子网路由](https://tailscale.com/kb/1019/subnets)。这相当于 [tailscale set --advertise-routes=](https://tailscale.com/kb/1080/cli#set)。要接受通告的路由，请使用 [TS_EXTRA_ARGS](https://tailscale.com/kb/1282/docker#ts_extra_args) 传入 `--accept-routes`。

#### `TS_SERVE_CONFIG`
接受一个 JSON 文件，以编程方式配置 [Serve](https://tailscale.com/kb/1242/tailscale-serve) 和 [Funnel](https://tailscale.com/kb/1311/tailscale-funnel) 功能。使用 [tailscale serve status --json](https://tailscale.com/kb/1242/tailscale-serve) 以正确格式导出当前配置。

如果使用 Docker 卷绑定挂载此文件，则必须将其挂载为目录而不是单个文件，以便正确检测配置更新。

#### `TS_SOCKET`
Tailscale 二进制文件使用的 Unix 套接字路径，`tailscaled` LocalAPI 套接字在此处创建。默认值为 `/var/run/tailscale/tailscaled.sock`。这相当于 `tailscaled tailscale --socket=`。

#### `TS_SOCKS5_SERVER`
设置 [SOCKS5 代理](https://tailscale.com/kb/1112/userspace-networking#socks5-vs-http) 的地址和端口。这将传递给 `tailscaled --socks5-server=`。例如，要将 SOCKS5 代理设置为端口 1055，此处为 `:1055`，这相当于 `tailscaled --socks5-server=:1055`。

#### `TS_STATE_DIR`
存储 `tailscaled` 状态的目录。此目录需要在容器重启时持久化。这将传递给 `tailscaled --statedir=`。

在 Kubernetes 上运行时，状态默认存储在名为 `tailscale` 的 Kubernetes 密钥中。要改为在本地磁盘上存储状态，请设置 `TS_KUBE_SECRET=""` 和 `TS_STATE_DIR=/path/to/storage/dir`。

#### `TS_USERSPACE`
启用 [用户空间网络](https://tailscale.com/kb/1112/userspace-networking)，而不是内核网络。默认启用。这相当于 `tailscaled --tun=userspace-networking`。

### 额外参数
#### `TS_EXTRA_ARGS`
要传递给 [Tailscale CLI](https://tailscale.com/kb/1080/cli) 的 [tailscale up](https://tailscale.com/kb/1080/cli#up) 命令中的任何其他标志。

#### `TS_TAILSCALED_EXTRA_ARGS`
要传递给 `tailscaled` 的任何其他 [标志](https://tailscale.com/kb/1278/tailscaled#flags-to-tailscaled)。

### 代码示例
以下是一个使用 OAuth 客户端密钥的完整 Docker Compose 代码片段。
```yaml
---
version: "3.7"
services:
  tailscale-nginx:
    image: tailscale/tailscale:latest
    hostname: tailscale-nginx
    environment:
      - TS_AUTHKEY=tskey-client-notAReal-OAuthClientSecret1Atawk
      - TS_EXTRA_ARGS=--advertise-tags=tag:container
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false
    volumes:
      - ${PWD}/tailscale-nginx/state:/var/lib/tailscale
    devices:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - net_admin
    restart: unless-stopped
  nginx:
    image: nginx
    depends_on:
      - tailscale-nginx
    network_mode: service:tailscale-nginx
```
更多示例可在 [tailscale-dev/docker-guide-code-examples](https://github.com/tailscale-dev/docker-guide-code-examples) 中找到。
