# Gitea

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Gitea][1] 是一个轻量级的 DevOps 平台软件。从开发计划到产品成型的整个软件生命周期，他都能够高效而轻松的帮助团队和开发者。包括 Git 托管、代码审查、团队协作、软件包注册和 CI/CD。它与 GitHub、Bitbucket 和 GitLab 等比较类似。

[1]:https://gitea.com/
[2]:https://github.com/go-gitea/gitea
[3]:https://hub.docker.com/r/gitea/gitea
[4]:https://docs.gitea.com/zh-cn/installation/install-with-docker


---

本教程以 `PostgreSQL` 方式进行安装。

## 先决条件
1. 确保当前服务器的 ssh 连接端口非 22 端口。以便可以通过 ssh 方式拉取和提交代码。
2. 将此域名绑定到此服务器 IP，以便通过域名拉取和提交代码。

## 使用方法
1. 创建数据库
```bash
CREATE DATABASE gitea;
```

## 环境变量
```bash
# 若主域名使用了 CDN，则必须设置此域名
GITEA__server__SSH_DOMAIN=ssh.example.com

# 去掉 repo.actions，则默认不启用 Actions
GITEA__repository__DEFAULT_REPO_UNITS=repo.code,repo.releases,repo.issues,repo.pulls,repo.wiki,repo.projects,repo.packages,repo.actions

GITEA__database__DB_TYPE=postgres
GITEA__database__HOST=db:5432
GITEA__database__NAME=gitea
GITEA__database__USER=gitea
GITEA__database__PASSWD=gitea

GITEA__mailer__ENABLED=true
GITEA__mailer__FROM=
GITEA__mailer__PROTOCOL=smtp
GITEA__mailer__HOST=
GITEA__mailer__IS_TLS_ENABLED=true
GITEA__mailer__USER=
GITEA__mailer__PASSWD=
```

## [配置](https://docs.gitea.com/zh-cn/administration/config-cheat-sheet) `app.ini`
1. 关闭注册功能
```bash
[server]
# 自定义 SSH 域名
SSH_DOMAIN = ssh.example.com

[service]
# 禁止用户注册
DISABLE_REGISTRATION = true

# 显示注册按钮
SHOW_REGISTRATION_BUTTON = false

# 默认禁用新仓库的 Actions
# https://docs.gitea.com/zh-cn/next/usage/actions/faq#%E6%98%AF%E5%90%A6%E5%8F%AF%E4%BB%A5%E5%9C%A8%E6%88%91%E7%9A%84%E5%AE%9E%E4%BE%8B%E4%B8%AD%E9%BB%98%E8%AE%A4%E7%A6%81%E7%94%A8%E6%96%B0%E4%BB%93%E5%BA%93%E7%9A%84actions
[repository]
# 去掉 repo.actions 将不会为新仓库自动启用actions
# https://docs.gitea.com/zh-cn/administration/config-cheat-sheet?_highlight=default_repo_units#%E4%BB%93%E5%BA%93-repository
DEFAULT_REPO_UNITS = ...,repo.actions
```

## Nginx 反向代理

> 参考：[官方反向代理文档](https://docs.gitea.com/zh-cn/administration/reverse-proxies)

### 通用配置

1. 在 `app.ini` 中设置 `[server] ROOT_URL = https://git.example.com/`。
2. 让反向代理将 `https://git.example.com/foo` 转发到 `http://gitea:3000/foo`。
3. 确保反向代理不解码 URI，即 `https://git.example.com/a%2Fb` 应原样转发为 `http://gitea:3000/a%2Fb`。
4. 确保 `Host` 和 `X-Forwarded-Proto` 请求头正确传递给 Gitea，使其能看到真实访问的 URL。
5. 确保 Web 服务器证书完整（含中间证书和根证书），否则 `git clone`、`git pull` 会失败。
6. Gitea 通过 `/-/ws` 的 WebSocket 连接实现实时更新（如通知计数）。反向代理必须使用 HTTP/1.1 并转发 `Upgrade`、`Connection` 请求头，否则 Gitea 会退化为周期性轮询。
7. 确保反向代理设置了 `X-Real-IP` 请求头，否则 Gitea 会使用客户端发送的值。如需在日志中记录客户端端口，还需设置 `X-Real-Port`。

### 基础配置

将以下 `server` 段添加到 `nginx.conf` 的 `http` 段中：

> 注意 `client_max_body_size` 要足够大，否则上传大文件时会报 `413 Request Entity Too Large` 错误。

```nginx
server {
    ...
    location / {
        client_max_body_size 512M;
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Connection $http_connection;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 子路径（Sub-path）部署

若已有站点，想让 Gitea 共用同一域名，可将其部署在子路径下（通常**不推荐**，部分场景可能有兼容性问题）：

```nginx
server {
    ...
    location ~ ^/(gitea|v2)($|/) {
        client_max_body_size 512M;

        # 让 nginx 使用未转义的 URI，保留 "%2F" 原样，去掉 "/gitea" 子路径前缀，"/v2" 原样透传。
        rewrite ^ $request_uri;
        rewrite ^/(gitea($|/))?(.*) /$3 break;
        proxy_pass http://127.0.0.1:3000$uri;
        proxy_http_version 1.1;

        # 其他通用请求头，见上方「基础配置」
        proxy_set_header Connection $http_connection;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

> 子路径下容器镜像仓库需要根级别的固定子路径 `/v2`，上面配置中的 `v2` 已一并处理。

然后**必须**在配置中正确设置 `[server] ROOT_URL = http://git.example.com/gitea/`。

### Nginx 直接托管静态资源（性能优化）

可将请求分为静态与动态两类：CSS、JavaScript、图片、Web 字体属于静态内容；首页、仓库视图、Issue 列表属于动态内容。Nginx 直接返回静态资源、仅将动态请求代理给 Gitea，可获得更好的性能。

下载 Gitea 源码仓库快照到 `/path/to/gitea/`，在仓库目录执行 `make frontend` 生成静态资源（需要 Node.js/npm 和 make），只需保留其中的 `public/` 目录。

**单节点单域名**：在配置中设置 `[server] STATIC_URL_PREFIX = /_/static`

```nginx
server {
    listen 80;
    server_name git.example.com;

    location /_/static/assets/ {
        alias /path/to/gitea/public/;
    }

    location / {
        # 其余指令见上方「基础配置」
        proxy_pass http://localhost:3000;
    }
}
```

**双节点双域名**：在配置中设置 `[server] STATIC_URL_PREFIX = http://cdn.example.com/gitea`

```nginx
# 运行 Gitea 的应用服务器
server {
    listen 80;
    server_name git.example.com;

    location / {
        # 其余指令见上方「基础配置」
        proxy_pass http://localhost:3000;
    }
}
```

```nginx
# 静态内容分发服务器
server {
    listen 80;
    server_name cdn.example.com;

    location /gitea/ {
        alias /path/to/gitea/public/;
    }

    location / {
        return 404;
    }
}
```

### SSH（22 端口）反向代理

适用场景：Gitea 部署在海外 VPS，国内无法直连其 22 端口，需要用一台国内 VPS 中转 SSH 流量，以便 `git clone`、`git push`、`ssh` 正常工作。

> SSH 是四层 TCP 流量，**必须使用 nginx 的 `stream` 模块**，而不是上面 `http` 模块的反向代理。
> `stream` 模块自 nginx 1.9.0 起可用，但**默认不编译**，需以 `--with-stream` 参数启用。检查是否已编译：`nginx -V 2>&1 | grep with-stream`（Debian/Ubuntu/RHEL 等发行版官方源安装的 nginx 一般已包含）。
> `stream {}` 块必须写在 `nginx.conf` 的**顶层**（与 `http {}` 平级），不能放进 `http` 或 `conf.d/*.conf` 中。

假设：海外 VPS 为 `overseas.example.com`，Gitea 容器的 SSH 端口映射为宿主机 `2222`；国内中转 VPS 监听 22 端口。

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
2. `app.ini` 中 `[server] SSH_DOMAIN` 设置为国内中转 VPS 的域名（或 IP），这样 Gitea 页面上展示的克隆地址才是国内可直连的：

```ini
[server]
SSH_DOMAIN = relay.example.com
```

使用方式：

```bash
# 对用户而言与直连完全一样，只是实际流量走了国内中转
git clone git@relay.example.com:username/repo.git
```

> 若中转 VPS 的 22 端口被占用（如自身 SSH 服务），可监听其他端口（如 `listen 2222;`），用户端改用 `ssh://git@relay.example.com:2222/username/repo.git` 形式克隆；此时若希望 Gitea 页面展示的 SSH 地址也带端口，可继续配合 `SSH_PORT` 配置。
>
> 更轻量的替代方案：中转 VPS 也可以不做任何代理，仅修改用户端 `~/.ssh/config` 走跳板：`ProxyJump` 或 `ProxyCommand`。nginx `stream` 的优点是全透明，团队所有成员无需各自配置。

## CI/CD 自动构建平台

### [Gitea Runner](https://docs.gitea.com/zh-cn/usage/actions/act-runner#%E4%BD%BF%E7%94%A8-docker-compose-%E8%BF%90%E8%A1%8C-runner)

#### 初始化配置文件
```bash
docker run --entrypoint="" --rm -it gitea/act_runner:nightly act_runner generate-config > config.yaml
```

#### 获取注册令牌
```bash
gitea --config /etc/gitea/app.ini actions generate-runner-token
```
或全局注册令牌
```bash
openssl rand -hex 24 > /some-dir/runner-token
export GITEA_RUNNER_REGISTRATION_TOKEN_FILE=/some-dir/runner-token
./gitea --config ...

# Docker 中使用时
## 1. 生成密钥文件
openssl rand -hex 24 > runner-token

## 2. 更新 .env 文件中 GITEA_RUNNER_REGISTRATION_TOKEN_FILE 的环境变量
## 若 GITEA_RUNNER_REGISTRATION_TOKEN 与 GITEA_RUNNER_REGISTRATION_TOKEN_FILE 同时设置时，优先使用 GITEA_RUNNER_REGISTRATION_TOKEN
GITEA_RUNNER_REGISTRATION_TOKEN_FILE=/runner-token

## 3. 映射至容器中
  gitea:
    ...
    volumes:
      - ./runner-token:/runner-token

  runner:
    ...
    volumes:
      - ./runner-token:/runner-token
```

### 注册 Runner
```bash
./act_runner register
# 或
./act_runner --config config.yaml register
```
非交互式
```bash
./act_runner register --no-interactive --instance <instance_url> --token <registration_token> --name <runner_name> --labels <runner_labels>
```

**Runner 镜像**
- https://github.com/catthehacker/docker_images
```bash
ghcr.io/catthehacker/ubuntu:act-22.04
ghcr.io/catthehacker/ubuntu:act-24.04
ghcr.io/catthehacker/ubuntu:act-latest
```
- 更新 `config.yaml`，使用对应的镜像
```yaml
  labels:
    - "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
    - "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
    - "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
```

### Drone 平台
首先，将此域名绑定到此服务器 IP。

#### 生成 Gitea 应用密钥
> GITEA 为 Gitea 代码托管服务的域名，DRONE 为 Drone 的访问域名。

1. 打开网址 `https://{GITEA}/user/settings/applications`。
2. 最下方 **创建新的 OAuth2 应用程序**，**应用名称**设置为`Drone`，**重定向 URI**设置为`https://{DRONE}/login`.
3. 记录下 **客户端ID**（DRONE_GITEA_CLIENT_ID）、**客户端密钥**（DRONE_GITEA_CLIENT_SECRET）。
4. 执行下述命令行：
```bash
# 安装
./run.sh drone {{DRONE_SERVER_HOST}} {{DRONE_GITEA_CLIENT_ID}} {{DRONE_GITEA_CLIENT_SECRET}}
```
> DRONE_SERVER_HOST: Drone 访问的实际域名
> DRONE_GITEA_CLIENT_ID: Gitea 应用客户端ID
> DRONE_GITEA_CLIENT_SECRET: Gitea 应用客户端密钥

### Woodpecker 平台
首先，将此域名绑定到此服务器 IP。

#### 生成 Gitea 应用密钥
> GITEA 为 Gitea 代码托管服务的域名，WOODPECKER 为 Woodpecker 的访问域名。

1. 打开网址 `https://{GITEA}/user/settings/applications`。
2. 最下方 **创建新的 OAuth2 应用程序**，**应用名称**设置为`Woodpecker`，**重定向 URI**设置为`https://{WOODPECKER}/authorize`.
3. 记录下 **客户端ID**（WOODPECKER_GITEA_CLIENT）、**客户端密钥**（WOODPECKER_GITEA_SECRET）。
4. 执行下述命令行：
```bash
# 安装
./run.sh woodpecker {{WOODPECKER_HOST}} {{WOODPECKER_GITEA_CLIENT}} {{WOODPECKER_GITEA_SECRET}}
```
> WOODPECKER_HOST: Woodpecker 访问的实际域名
> WOODPECKER_GITEA_CLIENT: Gitea 应用客户端ID
> WOODPECKER_GITEA_SECRET: Gitea 应用客户端密钥

## 教程
- **视频教程：**
> 1. 哔哩哔哩: https://www.bilibili.com/video/BV1te4y1Z7bL  
> 2. 西瓜视频: https://www.ixigua.com/7136483138939093535
