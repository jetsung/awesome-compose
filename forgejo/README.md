# Forgejo

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Forgejo][1] 是一个轻量级、自托管的软件锻造平台（software forge），主要用于代码托管和团队协作开发。它本质上是 Gitea 的一个硬分叉（hard fork），由非营利组织 Codeberg e.V. 支持，强调完全自由软件、社区治理、隐私保护以及长期可持续性。

[1]:https://codeberg.org/forgejo/forgejo
[2]:https://codeberg.org/forgejo/forgejo
[3]:https://codeberg.org/forgejo/-/packages/container/forgejo
[4]:https://forgejo.org/docs/latest/admin/installation/docker/

---

本教程以 `PostgreSQL` 方式进行安装。

## 先决条件
1. 确保当前服务器的 ssh 连接端口非 22 端口。以便可以通过 ssh 方式拉取和提交代码。
2. 将此域名绑定到此服务器 IP，以便通过域名拉取和提交代码。

## 使用方法
1. 创建数据库
```bash
CREATE DATABASE forgejo;
```

2. 生成 Runner 配置文件
```bash
docker run --rm data.forgejo.org/forgejo/runner:13 \
  forgejo-runner generate-config > config.yaml
```

> 若 `codeberg.org` 无法访问，可将镜像地址中的 `codeberg.org` 替换为镜像站 `data.forgejo.org`。

## 环境变量
```bash
# 若主域名使用了 CDN，则必须设置此域名
FORGEJO__server__SSH_DOMAIN=ssh.example.com

# 去掉 repo.actions，则默认不启用 Actions
FORGEJO__repository__DEFAULT_REPO_UNITS=repo.code,repo.releases,repo.issues,repo.pulls,repo.wiki,repo.projects,repo.packages

FORGEJO__database__DB_TYPE=postgres
FORGEJO__database__HOST=db:5432
FORGEJO__database__NAME=forgejo
FORGEJO__database__USER=forgejo
FORGEJO__database__PASSWD=forgejo

FORGEJO__mailer__ENABLED=true
FORGEJO__mailer__FROM=
FORGEJO__mailer__PROTOCOL=smtp
FORGEJO__mailer__HOST=
FORGEJO__mailer__IS_TLS_ENABLED=true
FORGEJO__mailer__USER=
FORGEJO__mailer__PASSWD=
```

> Forgejo 容器镜像支持以 `FORGEJO__[SECTION]__[KEY]` 格式的环境变量修改 `app.ini` 配置，`DEFAULT` 段对应空字符串，如 `FORGEJO____APP_NAME=Frogejo 🐸`。
> 注意：环境变量只能新增或覆盖配置，**无法删除**已有配置项，需直接编辑 `app.ini`。

## [配置](https://forgejo.org/docs/latest/admin/config-cheat-sheet/) `app.ini`
1. 关闭注册功能
```ini
[server]
# 自定义 SSH 域名
SSH_DOMAIN = ssh.example.com

[service]
# 禁止用户注册
DISABLE_REGISTRATION = true

# 显示注册按钮
SHOW_REGISTRATION_BUTTON = false

# 默认禁用新仓库的 Actions
[repository]
# 去掉 repo.actions 将不会为新仓库自动启用 actions
DEFAULT_REPO_UNITS = ...,repo.actions
```

## Nginx 反向代理

> 参考：[官方反向代理文档](https://forgejo.org/docs/latest/admin/setup/reverse-proxy/)

### 通用配置

1. 在 `app.ini` 中设置 `[server] ROOT_URL = https://git.example.com/`。
2. 让反向代理将 `https://git.example.com/foo` 转发到 `http://forgejo:3000/foo`。
3. Forgejo 不需要反向代理即可直接提供 HTTPS：设置 `[server] PROTOCOL=https` 并指定 `CERT_FILE` / `KEY_FILE`，或启用 `ENABLE_ACME=true` 自动管理证书。
4. 确保 `Host` 和 `X-Forwarded-Proto` 请求头正确传递给 Forgejo，使其能看到真实访问的 URL。
5. 确保 Web 服务器证书完整（含中间证书和根证书），否则 `git clone`、`git pull` 会失败。
6. 确保 `client_max_body_size` 足够大，否则上传大文件时会报 `413 Request Entity Too Large` 错误。

### 基础配置

将以下 `server` 段添加到 `/etc/nginx/conf.d/forgejo.conf` 中：

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name git.example.com;
    # 正确处理 URL 编码的斜杠
    merge_slashes off;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Connection $http_connection;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        client_max_body_size 512M;
    }
}
```

### 子路径（Sub-path）部署

若已有站点，想让 Forgejo 共用同一域名，可将其部署在子路径下（通常**不推荐**，同源安全模型下存在 [CSRF 风险](https://forgejo.org/docs/latest/admin/setup/reverse-proxy/#security-of-subpath)，部分场景可能有兼容性问题）：

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name example.com;
    merge_slashes off;

    location /code/ {
        proxy_pass http://localhost:3000/;
        proxy_set_header Connection $http_connection;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        client_max_body_size 512M;
    }
}
```

然后**必须**在配置中正确设置 `[server] ROOT_URL = http://example.com/code/`，否则 Forgejo 生成的链接将是错误的。

### Docker / 容器镜像仓库

容器镜像仓库使用固定子路径 `/v2`，无法修改。即使 Forgejo 部署在其他子路径下，`docker` 客户端仍会访问 `/v2`，因此可能需要在反向代理中为此添加额外的路由。

### SSH（22 端口）反向代理

适用场景：Forgejo 部署在海外 VPS，国内无法直连其 22 端口，需要用一台国内 VPS 中转 SSH 流量，以便 `git clone`、`git push`、`ssh` 正常工作。

> SSH 是四层 TCP 流量，**必须使用 nginx 的 `stream` 模块**，而不是上面 `http` 模块的反向代理。
> `stream` 模块自 nginx 1.9.0 起可用，但**默认不编译**，需以 `--with-stream` 参数启用。检查是否已编译：`nginx -V 2>&1 | grep with-stream`（Debian/Ubuntu/RHEL 等发行版官方源安装的 nginx 一般已包含）。
> `stream {}` 块必须写在 `nginx.conf` 的**顶层**（与 `http {}` 平级），不能放进 `http` 或 `conf.d/*.conf` 中。

假设：海外 VPS 为 `overseas.example.com`，Forgejo 容器的 SSH 端口映射为宿主机 `2222`；国内中转 VPS 监听 22 端口。

**国内中转 VPS** 的 `nginx.conf` 顶层添加：

```nginx
stream {
    server {
        listen 22;
        # SSH 为长连接，超时时间设置长一些，避免大仓库传输中途断开
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
        proxy_pass overseas.example.com:2222;
    }
}
```

> `proxy_pass` 中的域名只在 nginx **启动/重载时解析一次**。若海外 VPS 的 IP 会变化，可改用变量形式并配合 `resolver`，让 nginx 按缓存的 TTL 重新解析，无需 reload：
>
> ```nginx
> stream {
>     resolver 223.5.5.5 119.29.29.29 valid=30s;
>     resolver_timeout 5s;
>     server {
>         listen 22;
>         proxy_connect_timeout 10s;
>         proxy_timeout 300s;
>         set $backend overseas.example.com:2222;
>         proxy_pass $backend;
>     }
> }
> ```
>
> 若大仓库推送/拉取长时间无数据传输导致连接被中断，可在 `listen` 上追加 `so_keepalive=on` 启用 TCP 保活：`listen 22 so_keepalive=on;`。

**海外 VPS** 上无需任何改动，只需确保：
1. 防火墙/安全组放行来自国内中转 VPS 的 `2222` 端口（更安全的做法：仅允许中转 VPS 的 IP 访问，不对公网开放）。
2. `app.ini` 中 `[server] SSH_DOMAIN` 设置为国内中转 VPS 的域名（或 IP），这样 Forgejo 页面上展示的克隆地址才是国内可直连的：

```ini
[server]
SSH_DOMAIN = relay.example.com
```

使用方式：

```bash
# 对用户而言与直连完全一样，只是实际流量走了国内中转
git clone git@relay.example.com:username/repo.git
```

> 若中转 VPS 的 22 端口被占用（如自身 SSH 服务），可监听其他端口（如 `listen 2222;`），用户端改用 `ssh://git@relay.example.com:2222/username/repo.git` 形式克隆；此时若希望 Forgejo 页面展示的 SSH 地址也带端口，可继续配合 `SSH_PORT` 配置。
>
> 更轻量的替代方案：中转 VPS 也可以不做任何代理，仅修改用户端 `~/.ssh/config` 走跳板：`ProxyJump` 或 `ProxyCommand`。nginx `stream` 的优点是全透明，团队所有成员无需各自配置。

## Runner

Forgejo Runner 需要先在 Forgejo 实例中注册才能执行任务。

### Runner 注册（交互式，推荐）

在 Forgejo 中，根据 Runner 生效范围的不同，可在以下四个位置注册新 Runner：

- 系统管理员：`/admin/actions/runners`，执行整个实例所有仓库的工作流。
- 组织管理员：`/org/{org}/settings/actions/runners`，执行该组织下所有仓库的工作流。
- 个人用户：`/user/settings/actions/runners`，执行该用户所有仓库的工作流。
- 仓库管理员：`/{owner}/{repository}/settings/actions/runners`，仅执行单个仓库的工作流。

点击 `Create new runner`，输入名称与描述后，页面会显示 **UUID** 与 **Token**，将其填入 Runner 配置文件 `config.yaml` 的 `server` 段：

```yaml
# ... 其余配置 ...
server:
  connections:
    forgejo:
      url: https://git.example.com/
      uuid: 33834eef-e758-48c4-a676-1745426747aa
      token: d4fe2db46a4c6bdc434a9ce3378d9a1489c1b30e
```

> `connections` 下可以有多个键（键名任意且必须唯一），用于将一个 Runner 同时连接到多个 Forgejo 实例或同一实例的不同组织/用户/仓库。

### 离线注册

适用于 IaC（Ansible、Kubernetes 等）部署场景，需要 Forgejo 实例的系统管理员权限：

```sh
# 在 Forgejo 机器上执行，生成 40 位十六进制密钥，前 16 位为标识符，后 24 位为密钥
forgejo forgejo-cli actions register --name runner-name --scope myorganization \
    --secret 7c31591e8b67225a116d4a4519ea8e507e08f71f
# 输出对应的 uuid，填入 config.yaml
```

### Docker-in-Docker

<details>
<summary>compose 配置</summary>

```yaml
services:
  docker-in-docker:
    image: docker:dind
    container_name: 'docker_dind'
    privileged: 'true'
    command: ['dockerd', '-H', 'tcp://0.0.0.0:2375', '--tls=false']
    restart: 'unless-stopped'

  runner:
    image: 'data.forgejo.org/forgejo/runner:13'
    links:
      - docker-in-docker
    depends_on:
      docker-in-docker:
        condition: service_started
    container_name: 'runner'
    environment:
      DOCKER_HOST: tcp://docker-in-docker:2375
    # 非 root 用户运行，但需能访问 `./data`
    user: 1001:1001
    volumes:
      - ./data:/data
    restart: 'unless-stopped'

    command: 'forgejo-runner daemon --config /config.yaml'
```
</details>

启动前需准备非 root 权限的数据目录：

```bash
#!/usr/bin/env bash
set -e

mkdir -p data/.cache

chown -R 1001:1001 data
chmod 775 data/.cache
chmod g+s data/.cache
```

Runner 镜像默认以 `uid=1000` 运行：

```shell
$ docker run --rm data.forgejo.org/forgejo/runner:13 id
uid=1000 gid=1000 groups=1000
```

## 从 Gitea 迁移

> 参考：[官方兼容性公告](https://forgejo.org/2024-12-gitea-compatibility/) - [官方 Gitea 迁移指南](https://forgejo.org/docs/v15.0/admin/upgrade/from-gitea/)

**Gitea 1.22 是最后一个支持透明升级到 Forgejo 的版本**。两个项目自 Forgejo v1.21 后已硬分叉，Gitea 1.23+ 的数据库结构（如 actions 索引、分支保护）与部分子系统（如 webhooks）在 Forgejo 中实现完全不同，无法自动转换。迁移前请务必：停服、完整备份数据库与数据卷（Git 仓库、附件等），并在非生产副本上验证。

### Gitea ≤ 1.22：官方支持的两步迁移

1. **Gitea（任意版本，≤ v1.22.x）→ Forgejo v10.0.x**：换镜像为 `codeberg.org/forgejo/forgejo:10`，数据卷 `/data` 结构完全兼容，环境变量前缀 `GITEA__section__KEY` 改为 `FORGEJO__section__KEY`（配置语义相同）。Forgejo 启动时会自动执行数据库迁移。
2. **Forgejo v10.0.x → 目标版本**：按 [升级指南](https://forgejo.org/docs/latest/admin/upgrade/) 逐个大版本升级，跨版本不能跳级。
3. 升级完成后运行 `forgejo doctor check --all --log-file /tmp/doctor.log` 确认无问题，并手动检查 Web 界面。

> 容器部署时 Forgejo v10 可作为 Gitea 1.22.x 的 drop-in 替换；rootless 容器对应 rootless 镜像，数据归属 `1000:1000`。

### Gitea > 1.22：无官方教程，谨慎操作

官方不提供迁移教程，仅支持 best-effort。可行路径按可靠性排序：

1. **降级后迁移（推荐）**：将 Gitea 降回 1.22.x（用旧版备份恢复，或手动将数据库 `version` 表改回 1.22 对应的版本号），再走上述官方两步迁移。
2. **手动修改数据库强迁（危险）**：先启动 Forgejo 读取报错中的数据库版本号，对照 Gitea 源码 `models/migrations/` 手写 SQL 回滚新增表与索引，最后 `UPDATE version SET version=<目标版本号>`。社区原话是 "very very dangerous"，可能出现部分页面 panic、隐性数据损坏。
3. **逐仓库用应用内迁移工具**：Forgejo 的仓库导入基于 Gitea API，不受实例版本限制，但只迁移仓库数据，不含用户账号密码、实例级配置与全局设置。

### 参考链接

- 官方兼容性公告：<https://forgejo.org/2024-12-gitea-compatibility/>
- 官方 Gitea 迁移指南（≤1.22）：<https://forgejo.org/docs/v15.0/admin/upgrade/from-gitea/>
- 社区实战经验帖（Gitea 1.23 / 1.25 → Forgejo）：<https://codeberg.org/forgejo/discussions/issues/397>
- 手动降级 Gitea 数据库的 gist：<https://gist.github.com/hinrikus/918a1d3ccb8daa22f5c2fa4b0ee0048f>

## 教程
- **视频教程：**
> 1. 哔哩哔哩: https://www.bilibili.com/video/BV1te4y1Z7bL  
> 2. 西瓜视频: https://www.ixigua.com/7136483138939093535
