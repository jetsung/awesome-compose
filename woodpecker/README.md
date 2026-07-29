# Woodpecker CI

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

[1]:https://woodpecker-ci.org/
[2]:https://github.com/woodpecker-ci/woodpecker
[3]:https://hub.docker.com/u/woodpeckerci
[4]:https://woodpecker-ci.org/docs/intro

---

> [Woodpecker CI][1] 是 "Woodpecker Continuous Integration"（持续集成）的缩写。持续集成是一种软件开发实践，它要求开发人员将代码经常性地集成到一个共享的主分支中，每次集成都通过自动化构建（包括编译、测试等）来验证，从而尽早发现集成错误。而 "Woodpecker" 是这个持续集成工具的名称，它是一个简单但功能强大的 CI/CD（持续集成/持续交付）引擎，具有很好的可扩展性。

---

## Server 环境变量参考

Woodpecker Server 提供了丰富的环境变量用于配置各项功能，包括日志、数据库、网络、TLS/SSL、gRPC、监控指标、UI 自定义、用户认证、Pipeline 设置、插件、Docker、Agent 通信、状态推送、扩展等。

完整的 Server 环境变量列表请参阅 [server-env.md](./server-env.md)。

---

## 支持的 Forge / 代码托管平台

Woodpecker 内置支持以下代码托管平台（Forge）。下表列出了各平台支持的功能：

| 功能 | GitHub | Gitea | Forgejo | GitLab | Bitbucket | Bitbucket Datacenter | AtomGit |
|------|--------|-------|---------|--------|-----------|----------------------|---------|
| 事件: Push | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 事件: Tag | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 事件: Pull-Request | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 事件: Release | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 事件: Deploy¹ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 事件: Pull-Request-Metadata | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 多工作流 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| when.path 过滤器 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

¹ Deploy 事件可以从 Woodpecker 直接触发，但只有 GitHub 可以通过 webhook 触发。

> 此外，Woodpecker 还支持[插件 Forge](../100-addons.md)，如果你的代码托管平台不符合 Woodpecker 的要求或你的配置过于特殊。

---

## Forge 配置指南

### GitHub

Woodpecker 内置支持 GitHub 和 GitHub Enterprise。需要在 Server 组件中设置以下环境变量：

```ini
WOODPECKER_GITHUB=true
WOODPECKER_GITHUB_CLIENT=YOUR_GITHUB_CLIENT_ID
WOODPECKER_GITHUB_SECRET=YOUR_GITHUB_CLIENT_SECRET
```

前往 GitHub Settings -> Developer Settings -> GitHub Apps -> New Oauth2 App 注册 OAuth 应用。

> ⚠️ 注意：请使用 **OAuth2 App** 而非 "GitHub App"，因为后者目前无法与 Woodpecker 正常工作（用户访问令牌不会自动刷新）。

#### 应用设置

- **Name**: 你的应用名称
- **Homepage URL**: Woodpecker 实例的 URL
- **Callback URL**: `https://<your-woodpecker-instance>/authorize`
- （可选）上传 Woodpecker 图标：<https://avatars.githubusercontent.com/u/84780935?s=200&v=4>

#### 配置选项

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `WOODPECKER_GITHUB` | `false` | 启用 GitHub 驱动 |
| `WOODPECKER_GITHUB_URL` | `https://github.com` | GitHub 服务器地址 |
| `WOODPECKER_GITHUB_CLIENT` | 无 | GitHub OAuth 客户端 ID |
| `WOODPECKER_GITHUB_CLIENT_FILE` | 无 | 从文件读取 `WOODPECKER_GITHUB_CLIENT` |
| `WOODPECKER_GITHUB_SECRET` | 无 | GitHub OAuth 客户端密钥 |
| `WOODPECKER_GITHUB_SECRET_FILE` | 无 | 从文件读取 `WOODPECKER_GITHUB_SECRET` |
| `WOODPECKER_GITHUB_MERGE_REF` | `true` | 是否使用合并引用 |
| `WOODPECKER_GITHUB_SKIP_VERIFY` | `false` | 是否跳过 SSL 验证 |
| `WOODPECKER_GITHUB_PUBLIC_ONLY` | `false` | 仅获取可管理公开仓库的令牌 |

---

### Gitea

Woodpecker 内置支持 Gitea。需要在 Server 组件中设置以下环境变量：

```ini
WOODPECKER_GITEA=true
WOODPECKER_GITEA_URL=YOUR_GITEA_URL
WOODPECKER_GITEA_CLIENT=YOUR_GITEA_CLIENT
WOODPECKER_GITEA_SECRET=YOUR_GITEA_CLIENT_SECRET
```

#### 与容器中的 Gitea 同主机运行

如果 Gitea 也在同一主机的容器中运行，确保 agent 可以访问它。建议将 Woodpecker agent 加入 Gitea 所在的 Docker 网络：

```yaml
services:
  woodpecker-agent:
    environment:
      - WOODPECKER_BACKEND_DOCKER_NETWORK=gitea
```

#### 注册 OAuth 应用

- **用户 OAuth 应用**: 在 `https://gitea.<host>/user/settings/` 注册应用，回调 URL 必须为 `https://<host>/authorize`
- **系统级 OAuth 应用**: 管理员可在 `https://gitea.<host>/admin/settings/applications` 创建，适用于共享 CI/CD 环境

#### 本地连接

如果 Woodpecker 与 Gitea 在同一主机运行，需要在 Gitea 配置中允许本地连接：

```ini
[webhook]
ALLOWED_HOST_LIST=external,loopback
```

> ⚠️ 确保 Gitea 配置允许 API 请求的固定页面长度为 50，否则某些 Woodpecker 功能将无法正常工作。

#### 配置选项

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `WOODPECKER_GITEA` | `false` | 启用 Gitea 驱动 |
| `WOODPECKER_GITEA_URL` | `https://try.gitea.io` | Gitea 服务器地址 |
| `WOODPECKER_GITEA_CLIENT` | 无 | Gitea OAuth 客户端 ID |
| `WOODPECKER_GITEA_CLIENT_FILE` | 无 | 从文件读取 `WOODPECKER_GITEA_CLIENT` |
| `WOODPECKER_GITEA_SECRET` | 无 | Gitea OAuth 客户端密钥 |
| `WOODPECKER_GITEA_SECRET_FILE` | 无 | 从文件读取 `WOODPECKER_GITEA_SECRET` |
| `WOODPECKER_GITEA_SKIP_VERIFY` | `false` | 是否跳过 SSL 验证 |

---

### Forgejo

Woodpecker 内置支持 Forgejo。需要在 Server 组件中设置以下环境变量：

```ini
WOODPECKER_FORGEJO=true
WOODPECKER_FORGEJO_URL=YOUR_FORGEJO_URL
WOODPECKER_FORGEJO_CLIENT=YOUR_FORGEJO_CLIENT
WOODPECKER_FORGEJO_SECRET=YOUR_FORGEJO_CLIENT_SECRET
```

Forgejo 的配置方式与 Gitea 类似，支持用户级和系统级 OAuth 应用注册，也支持本地连接配置。

#### 配置选项

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `WOODPECKER_FORGEJO` | `false` | 启用 Forgejo 驱动 |
| `WOODPECKER_FORGEJO_URL` | `https://next.forgejo.org` | Forgejo 服务器地址 |
| `WOODPECKER_FORGEJO_CLIENT` | 无 | Forgejo OAuth 客户端 ID |
| `WOODPECKER_FORGEJO_CLIENT_FILE` | 无 | 从文件读取 `WOODPECKER_FORGEJO_CLIENT` |
| `WOODPECKER_FORGEJO_SECRET` | 无 | Forgejo OAuth 客户端密钥 |
| `WOODPECKER_FORGEJO_SECRET_FILE` | 无 | 从文件读取 `WOODPECKER_FORGEJO_SECRET` |
| `WOODPECKER_FORGEJO_SKIP_VERIFY` | `false` | 是否跳过 SSL 验证 |

---

### GitLab

Woodpecker 内置支持 GitLab v12.4 及以上版本。需要在 Server 组件中设置以下环境变量：

```ini
WOODPECKER_GITLAB=true
WOODPECKER_GITLAB_URL=http://gitlab.mycompany.com
WOODPECKER_GITLAB_CLIENT=95c0282573633eb25e82
WOODPECKER_GITLAB_SECRET=30f5064039e6b359e075
```

#### 注册 OAuth 应用

在 GitLab 的 Applications 菜单中创建新应用，回调 URL 为 `http://woodpecker.mycompany.com/authorize`，授予 `api` 权限。

如果 Woodpecker 使用私有 IP，需在 GitLab Admin -> Settings -> Network -> Outbound requests 中启用 `Allow requests to the local network from web hooks and services`。

#### 配置选项

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `WOODPECKER_GITLAB` | `false` | 启用 GitLab 驱动 |
| `WOODPECKER_GITLAB_URL` | `https://gitlab.com` | GitLab 服务器地址 |
| `WOODPECKER_GITLAB_CLIENT` | 无 | GitLab OAuth 客户端 ID |
| `WOODPECKER_GITLAB_CLIENT_FILE` | 无 | 从文件读取 `WOODPECKER_GITLAB_CLIENT` |
| `WOODPECKER_GITLAB_SECRET` | 无 | GitLab OAuth 客户端密钥 |
| `WOODPECKER_GITLAB_SECRET_FILE` | 无 | 从文件读取 `WOODPECKER_GITLAB_SECRET` |
| `WOODPECKER_GITLAB_SKIP_VERIFY` | `false` | 是否跳过 SSL 验证 |

---

### Bitbucket

Woodpecker 内置支持 Bitbucket Cloud。需要在 Server 组件中设置以下环境变量：

```ini
WOODPECKER_BITBUCKET=true
WOODPECKER_BITBUCKET_CLIENT=...   # Bitbucket 中称为 "Key"
WOODPECKER_BITBUCKET_SECRET=...
```

#### 注册 OAuth 应用

在 Bitbucket workspace settings -> OAuth consumers 中注册，回调 URL 为 `https://<your-woodpecker-address>/authorize`。

需要勾选的权限：
- Account: Email, Read
- Workspace membership: Read
- Projects: Read
- Repositories: Read
- Pull requests: Read
- Webhooks: Read and Write

#### 配置选项

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `WOODPECKER_BITBUCKET` | `false` | 启用 Bitbucket 驱动 |
| `WOODPECKER_BITBUCKET_CLIENT` | 无 | Bitbucket OAuth 客户端 Key |
| `WOODPECKER_BITBUCKET_CLIENT_FILE` | 无 | 从文件读取 `WOODPECKER_BITBUCKET_CLIENT` |
| `WOODPECKER_BITBUCKET_SECRET` | 无 | Bitbucket OAuth 客户端密钥 |
| `WOODPECKER_BITBUCKET_SECRET_FILE` | 无 | 从文件读取 `WOODPECKER_BITBUCKET_SECRET` |

#### 已知问题

Bitbucket 构建密钥限制为 40 个字符（[issue #5176](https://github.com/woodpecker-ci/woodpecker/issues/5176)），可通过调整 `WOODPECKER_STATUS_CONTEXT` 或 `WOODPECKER_STATUS_CONTEXT_FORMAT` 解决。

#### 缺失功能

Pull Request 的路径过滤器暂不支持。

---

### Bitbucket Datacenter / Server

> ⚠️ Woodpecker 对 Bitbucket Datacenter / Server 的支持为实验性功能。

需要在 Server 组件中设置以下环境变量：

```yaml
services:
  woodpecker-server:
    environment:
      - WOODPECKER_BITBUCKET_DC=true
      - WOODPECKER_BITBUCKET_DC_GIT_USERNAME=foo
      - WOODPECKER_BITBUCKET_DC_GIT_PASSWORD=bar
      - WOODPECKER_BITBUCKET_DC_CLIENT_ID=xxx
      - WOODPECKER_BITBUCKET_DC_CLIENT_SECRET=yyy
      - WOODPECKER_BITBUCKET_DC_URL=http://stash.mycompany.com
```

#### 服务账号

Bitbucket Server 不支持使用 OAuth 令牌克隆仓库，因此需要创建服务账号并提供用户名和密码用于克隆私有仓库。

#### 注册

在 Bitbucket 管理后台的 "Application Links" 中创建 "Incoming" 类型的 "External Application" 链接。

#### 配置选项

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `WOODPECKER_BITBUCKET_DC` | `false` | 启用 Bitbucket Server 驱动 |
| `WOODPECKER_BITBUCKET_DC_URL` | 无 | Bitbucket Server 地址 |
| `WOODPECKER_BITBUCKET_DC_CLIENT_ID` | 无 | OAuth 2.0 客户端 ID |
| `WOODPECKER_BITBUCKET_DC_CLIENT_SECRET` | 无 | OAuth 2.0 客户端密钥 |
| `WOODPECKER_BITBUCKET_DC_GIT_USERNAME` | 无 | 用于克隆私有仓库的用户名 |
| `WOODPECKER_BITBUCKET_DC_GIT_USERNAME_FILE` | 无 | 从文件读取 Git 用户名 |
| `WOODPECKER_BITBUCKET_DC_GIT_PASSWORD` | 无 | 用于克隆私有仓库的密码 |
| `WOODPECKER_BITBUCKET_DC_GIT_PASSWORD_FILE` | 无 | 从文件读取 Git 密码 |
| `WOODPECKER_BITBUCKET_DC_SKIP_VERIFY` | `false` | 是否跳过 SSL 验证 |
| `WOODPECKER_BITBUCKET_DC_ENABLE_OAUTH2_SCOPE_PROJECT_ADMIN` | `false` | 启用 `PROJECT_ADMIN` 作用域 |

---

### AtomGit

Woodpecker 内置支持 [AtomGit](https://atomgit.com)。需要在 Server 组件中设置以下环境变量：

```ini
WOODPECKER_ATOMGIT=true
WOODPECKER_ATOMGIT_CLIENT=YOUR_ATOMGIT_CLIENT_ID
WOODPECKER_ATOMGIT_SECRET=YOUR_ATOMGIT_CLIENT_SECRET
```

前往个人设置 -> OAuth2 Applications -> Create a new OAuth2 App 注册应用。

#### 应用设置

- **Name**: 你的应用名称
- **Homepage URL**: Woodpecker 实例的 URL
- **Callback URL**: `https://<your-woodpecker-instance>/authorize`

#### 配置选项

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `WOODPECKER_ATOMGIT` | `false` | 启用 AtomGit 驱动 |
| `WOODPECKER_ATOMGIT_URL` | `https://api.atomgit.com` | AtomGit API 服务器地址 |
| `WOODPECKER_ATOMGIT_CLIENT` | 无 | AtomGit OAuth 客户端 ID |
| `WOODPECKER_ATOMGIT_CLIENT_FILE` | 无 | 从文件读取 `WOODPECKER_ATOMGIT_CLIENT` |
| `WOODPECKER_ATOMGIT_SECRET` | 无 | AtomGit OAuth 客户端密钥 |
| `WOODPECKER_ATOMGIT_SECRET_FILE` | 无 | 从文件读取 `WOODPECKER_ATOMGIT_SECRET` |
| `WOODPECKER_FORGE_SKIP_VERIFY` | `false` | 是否跳过 SSL 验证 |
| `WOODPECKER_FORGE_OAUTH_HOST` | `https://atomgit.com` | OAuth 授权端点地址 |

---

## 反向代理配置

Woodpecker Server 运行在 `:8000`（Web UI / API）和 `:9000`（gRPC）端口。在生产环境中，建议使用反向代理进行 TLS 终止和域名绑定。

### Nginx

```nginx
server {
    listen 80;
    server_name woodpecker.example.com;

    location / {
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;

        proxy_pass http://127.0.0.1:8000;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_buffering off;

        chunked_transfer_encoding off;
    }
}
```

> 必须配置 `X-Forwarded` 头信息以正确传递客户端协议和地址。

有关 Apache、Caddy、Traefik 等更多反向代理配置，请参阅 [server-env.md](./server-env.md#反向代理) 或 [官方文档](https://woodpecker-ci.org/docs/administration/configuration/server#nginx)。
