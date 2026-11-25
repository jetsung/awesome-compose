# linklist

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [linklist][1] 是一个自托管书签管理服务（Rust 重写的 linkding 替代品），单二进制交付，支持 SQLite（默认）/ PostgreSQL / MySQL 三种数据库。

[1]:https://github.com/jetsung/linklist
[2]:https://github.com/jetsung/linklist
[3]:https://ghcr.io/jetsung/linklist
[4]:https://github.com/jetsung/linklist/tree/main/docs

**功能概述**：
 - 书签 CRUD、全文搜索（FTS5）、表达式搜索（`tag:rust`、`is:unread` 等）、标签管理
 - 自动抓取网页元数据（标题/描述）、Archive.today 快照、web archive 查询
 - 页面快照与资产上传
 - 批量操作（加/删标签、已读/未读、删除）、归档与隔离视图
 - Netscape 格式导入/导出、RSS 订阅源
 - 多用户：注册（首个用户自动管理员）、会话 + API Token
 - 共享书签：共享视图 + 可关闭的匿名公开共享（`guest_sharing`）
 - 管理端：用户管理、任务队列、全局设置、审计日志

## 首次使用

```bash
mkdir -p data && chown -R 65532:65532 ./data   # 容器以 uid 65532 运行
docker compose up -d
```

打开 `http://localhost:9090/login` 完成首次初始化/登录。

## 配置

容器内使用默认端口 `9090` 与数据目录 `/app/data`，其余配置通过 `LINKLIST_*` 环境变量注入（优先级高于 `config.toml`）：

| 环境变量 | 默认值 | 说明 |
| --- | --- | --- |
| `LINKLIST_LISTEN` | `0.0.0.0:9090` | 监听地址 |
| `LINKLIST_DATA_DIR` | `./data` | 数据目录 |
| `LINKLIST_DATABASE_URL` | （空） | 数据库连接串，留空使用 SQLite；`postgres://` / `mysql://` 前缀自动选择后端 |
| `LINKLIST_GUEST_SHARING` | `false` | 是否允许匿名访客查看公开共享书签 |
| `LINKLIST_LOG` | `info` | 日志级别（RUST_LOG 语法） |
| `LINKLIST_SESSION_TTL_SECS` | `604800` | 会话有效期（秒） |
| `LINKLIST_TOKEN_TTL_DAYS` | `0` | API Token 有效期（天，0 = 永不过期） |

## OIDC 单点登录（SSO）

LinkList 支持 OIDC（OpenID Connect）单点登录：授权码流程 + PKCE（S256），回调校验通过后按 claim **自动创建账号并登录**。

### 前置条件

- IdP（Keycloak / Authentik / Casdoor / Auth0 / Logto 等）支持授权码流程 + PKCE；
- 在 IdP 注册客户端，重定向 URI 填 `http(s)://<服务地址>/oidc/callback/`（**带尾部斜杠**；不一致时可用 `LINKLIST_OIDC_REDIRECT_URI` 显式指定）。

### 配置（compose.yaml 的 environment）

```yaml
services:
  linklist:
    environment:
      - LINKLIST_ENABLE_OIDC=true
      - LINKLIST_OIDC_ISSUER=https://idp.example.com/realms/master
      - LINKLIST_OIDC_CLIENT_ID=linklist
      - LINKLIST_OIDC_CLIENT_SECRET=your-client-secret
      # 可选：签发算法（默认 RS256，走 JWKS；HS256 的 IdP 设为 HS256）
      # - LINKLIST_OIDC_SIGN_ALGO=HS256
      # 可选：用户名字段（默认 email；建出随机 ID 用户名时改用 preferred_username）
      # - LINKLIST_OIDC_USERNAME_CLAIM=preferred_username
```

- **Issuer 自动发现（推荐）**：配置 `LINKLIST_OIDC_ISSUER` 后，各端点从 `{issuer}/.well-known/openid-configuration` 自动获取。
- **手动配置端点**：IdP 无发现文档时，逐项配置 `LINKLIST_OIDC_AUTHORIZATION_ENDPOINT` / `LINKLIST_OIDC_TOKEN_ENDPOINT` / `LINKLIST_OIDC_JWKS_ENDPOINT` / `LINKLIST_OIDC_USER_ENDPOINT`（显式端点优先）。

重启后打开登录页即出现「OIDC 登录」按钮。纯 SSO 部署可再加 `LINKLIST_DISABLE_LOGIN_FORM=true` 隐藏密码表单。

### 注意事项

- 首个经 OIDC 建号的账号自动成为超级用户（单管理员模型）；其后均为普通用户。
- 置于 Nginx/Caddy 反代之后时，需正确转发 `Host` 与 `X-Forwarded-Proto`，否则回调地址推导与 IdP 注册值不一致会导致授权失败。
- 更多排查项见官方文档 [OIDC 单点登录][5]。

[5]:https://github.com/jetsung/linklist/blob/main/docs/07-oidc.md
