# Woodpecker Server 环境变量参考

> 本文档基于 [Woodpecker 官方文档 - Server 配置](https://woodpecker-ci.org/docs/administration/server) 整理，涵盖了 Woodpecker Server 端的所有环境变量配置项。

---

## 目录

- [通用日志](#通用日志)
- [数据库](#数据库)
- [服务器网络](#服务器网络)
- [TLS/SSL](#tlsssl)
- [gRPC](#grpc)
- [监控指标 (Prometheus)](#监控指标-prometheus)
- [UI 自定义](#ui-自定义)
- [用户与认证](#用户与认证)
- [仓库](#仓库)
- [Pipeline 设置](#pipeline-设置)
- [插件](#插件)
- [Docker](#docker)
- [Agent 通信](#agent-通信)
- [状态推送](#状态推送)
- [配置扩展](#配置扩展)
- [密钥扩展](#密钥扩展)
- [注册表扩展](#注册表扩展)
- [扩展网络限制](#扩展网络限制)
- [Forge 相关](#forge-相关)
- [其他](#其他)
- [Forge 专属变量](#forge-专属变量)

---

## 通用日志

### WOODPECKER_LOG_LEVEL

- **默认值**: `info`
- **说明**: 配置日志级别。可选值：`trace`、`debug`、`info`、`warn`、`error`、`fatal`、`panic`、`disabled`、空字符串。

### WOODPECKER_LOG_FILE

- **默认值**: `stderr`
- **说明**: 日志输出目标。可使用 `stdout` 和 `stderr` 作为特殊关键词。

### WOODPECKER_DATABASE_LOG

- **默认值**: `false`
- **说明**: 启用数据库引擎日志（当前为 xorm）。

### WOODPECKER_DATABASE_LOG_SQL

- **默认值**: `false`
- **说明**: 启用 SQL 命令日志。

### WOODPECKER_DEBUG_PRETTY

- **默认值**: `false`
- **说明**: 启用格式化输出调试信息。

### WOODPECKER_DEBUG_NOCOLOR

- **默认值**: `true`
- **说明**: 禁用彩色调试输出。

---

## 数据库

### WOODPECKER_DATABASE_DRIVER

- **默认值**: `sqlite3`
- **说明**: 数据库驱动名称。可选值：`sqlite3`、`mysql`、`postgres`。

### WOODPECKER_DATABASE_DATASOURCE

- **默认值**: `woodpecker.sqlite`（非容器环境）/ `/var/lib/woodpecker/woodpecker.sqlite`（容器环境）
- **说明**: 数据库连接字符串。
- **示例**:
  ```bash
  # MySQL
  WOODPECKER_DATABASE_DATASOURCE=root:password@tcp(1.2.3.4:3306)/woodpecker?parseTime=true

  # PostgreSQL (要求版本 >= 11)
  WOODPECKER_DATABASE_DATASOURCE=postgres://root:password@1.2.3.4:5432/woodpecker?sslmode=disable
  ```

### WOODPECKER_DATABASE_DATASOURCE_FILE

- **默认值**: 无
- **说明**: 从指定文件路径读取 `WOODPECKER_DATABASE_DATASOURCE` 的值。

### WOODPECKER_DATABASE_MAX_CONNECTIONS

- **默认值**: `100`
- **说明**: xorm 允许创建的最大数据库连接数。

### WOODPECKER_DATABASE_IDLE_CONNECTIONS

- **默认值**: `2`
- **说明**: xorm 保持打开的空闲数据库连接数。

### WOODPECKER_DATABASE_CONNECTION_TIMEOUT

- **默认值**: `3` 秒
- **说明**: 活跃数据库连接允许保持打开的时间。

> **注意**: 默认数据库引擎为嵌入式 SQLite，无需额外安装配置。若使用 MySQL/MariaDB 或 PostgreSQL，需手动创建数据库（`CREATE DATABASE`）。Woodpecker 会自动处理数据库迁移（包括初始建表和索引升级），但**不会自动备份数据库**，需使用第三方工具。

---

## 服务器网络

### WOODPECKER_HOST

- **默认值**: 无
- **说明**: 服务器面向用户的完整 URL，包括主机名、端口（若非 HTTP/HTTPS 默认端口）和路径前缀。
- **示例**:
  ```
  WOODPECKER_HOST=http://woodpecker.example.org
  WOODPECKER_HOST=http://example.org/woodpecker
  WOODPECKER_HOST=http://example.org:1234/woodpecker
  ```

### WOODPECKER_SERVER_ADDR

- **默认值**: `:8000`
- **说明**: HTTP 监听地址。支持通过 `unix://` 前缀使用 Unix Socket。
- **示例**: `unix:///var/run/woodpecker.sock`

### WOODPECKER_SERVER_ADDR_TLS

- **默认值**: `:443`
- **说明**: 启用 SSL 时的 HTTPS 监听端口。

### WOODPECKER_GRPC_ADDR

- **默认值**: `:9000`
- **说明**: gRPC 监听地址。可使用 `localhost:9000` 或 IP 地址绑定到特定接口。支持 `unix://` 前缀。
- **示例**: `unix:///run/woodpecker-grcp.sock`

---

## TLS/SSL

### WOODPECKER_SERVER_CERT

- **默认值**: 无
- **说明**: 服务器用于接受 HTTPS 请求的 SSL 证书路径。
- **示例**: `WOODPECKER_SERVER_CERT=/path/to/cert.pem`

### WOODPECKER_SERVER_KEY

- **默认值**: 无
- **说明**: 服务器用于接受 HTTPS 请求的 SSL 证书密钥路径。
- **示例**: `WOODPECKER_SERVER_KEY=/path/to/key.pem`

---

## gRPC

### WOODPECKER_GRPC_SECRET

- **默认值**: 无
- **说明**: 用于签名 gRPC 连接 JWT 的密钥。
- **说明**: 若未设置，服务器会生成一个临时密钥，每次重启都会变更。**高可用 (HA) 部署时必须显式设置**，确保多个 Server 副本使用相同密钥。
- **生成方法**: `openssl rand -hex 32`

### WOODPECKER_GRPC_SECRET_FILE

- **默认值**: 无
- **说明**: 从指定文件路径读取 `WOODPECKER_GRPC_SECRET` 的值。文件应持久化存储且仅 Woodpecker 服务器可读。

---

## 监控指标 (Prometheus)

### WOODPECKER_PROMETHEUS_AUTH_TOKEN

- **默认值**: 无
- **说明**: 保护 Prometheus 指标端点的令牌。**必须设置才能启用 `/metrics` 端点**。

### WOODPECKER_PROMETHEUS_AUTH_TOKEN_FILE

- **默认值**: 无
- **说明**: 从指定文件路径读取 `WOODPECKER_PROMETHEUS_AUTH_TOKEN` 的值。

### WOODPECKER_METRICS_SERVER_ADDR

- **默认值**: 无
- **说明**: 配置一个不受保护的 Metrics 端点。值为空时完全禁用 Metrics 端点。
- **示例**: `:9001`

### WOODPECKER_STEP_LEVEL_METRICS

- **默认值**: `true`
- **说明**: 启用步骤级指标，包括失败步骤计数器和步骤持续时间直方图。

---

## UI 自定义

### WOODPECKER_CUSTOM_CSS_FILE

- **默认值**: 无
- **说明**: 自定义 CSS 文件路径，用于定制 UI（横幅消息、Logo、环境提示等）。文件必须为 UTF-8 编码。
- **示例**: `WOODPECKER_CUSTOM_CSS_FILE=/usr/local/www/woodpecker.css`

### WOODPECKER_CUSTOM_JS_FILE

- **默认值**: 无
- **说明**: 自定义 JS 文件路径，用于定制 UI。文件必须为 UTF-8 编码。
- **示例**: `WOODPECKER_CUSTOM_JS_FILE=/usr/local/www/woodpecker.js`

---

## 用户与认证

### WOODPECKER_OPEN

- **默认值**: `false`
- **说明**: 是否允许用户注册。默认关闭，用户由 Forge（通过 OAuth2）提供。

### WOODPECKER_ADMIN

- **默认值**: 无
- **说明**: 管理员账号列表（逗号分隔）。
- **示例**: `WOODPECKER_ADMIN=user1,user2`

### WOODPECKER_ORGS

- **默认值**: 无
- **说明**: 允许的组织列表（逗号分隔）。需要配合 `WOODPECKER_OPEN=true` 使用。
- **示例**: `WOODPECKER_ORGS=org1,org2`

### WOODPECKER_REPO_OWNERS

- **默认值**: 无
- **说明**: 仅同步指定所有者的仓库。通常设置为公司 GitHub 组织名称。
- **示例**: `WOODPECKER_REPO_OWNERS=my_company,my_company_oss_github_user`

### WOODPECKER_AUTHENTICATE_PUBLIC_REPOS

- **默认值**: `false`
- **说明**: 即使仓库是公有的，也始终使用认证来克隆。当 Forge 要求始终认证时使用。

### WOODPECKER_SESSION_EXPIRES

- **默认值**: `72h`
- **说明**: 会话过期时间。用户在有效期内无需重新认证即可登录 Woodpecker。

---

## 仓库

### WOODPECKER_ASYNC_REPOSITORY_UPDATE

- **默认值**: `false`
- **说明**: 启用异步获取用户仓库权限。可显著提升组织有大量 Git 仓库时的登录速度。
  - **禁用**（默认）：用户需等待所有仓库访问信息同步完成，强一致性。
  - **启用**：用户立即跳转首页，但可能看到过时信息，最终一致性。

### WOODPECKER_DEFAULT_ALLOW_PULL_REQUESTS

- **默认值**: `true`
- **说明**: 仓库默认是否允许 Pull Request 触发流水线。

### WOODPECKER_DEFAULT_APPROVAL_MODE

- **默认值**: `forks`
- **说明**: 仓库默认审批模式。可选值：`none`、`forks`、`pull_requests`、`all_events`。

### WOODPECKER_DEFAULT_CANCEL_PREVIOUS_PIPELINE_EVENTS

- **默认值**: `pull_request, push`
- **说明**: 当相同上下文（标签、分支）创建新流水线时，将取消之前流水线的事件列表。

### WOODPECKER_DISABLE_USER_AGENT_REGISTRATION

- **默认值**: `false`
- **说明**: 禁止用户为其拥有管理员权限的仓库创建新 Agent。如果有全局密钥且不信任用户创建恶意 Agent 提取密钥，应启用此选项。

---

## Pipeline 设置

### WOODPECKER_DEFAULT_CLONE_PLUGIN

- **默认值**: `docker.io/woodpeckerci/plugin-git`
- **说明**: 克隆仓库时使用的默认 Docker 镜像。同时会被添加到受信任的克隆插件列表中。

### WOODPECKER_DEFAULT_WORKFLOW_LABELS

- **默认值**: 无
- **说明**: 为没有设置标签条件的工作流指定默认标签/平台条件，用于 Agent 选择。
- **示例**: `platform=linux/amd64,backend=docker`

### WOODPECKER_DEFAULT_PIPELINE_TIMEOUT

- **默认值**: `60` 分钟
- **说明**: 仓库流水线默认超时时间（分钟）。

### WOODPECKER_MAX_PIPELINE_TIMEOUT

- **默认值**: `120` 分钟
- **说明**: 仓库设置中可设置的最大流水线超时时间（分钟）。

### WOODPECKER_DEFAULT_PIPELINE_CONFIGS

- **默认值**: `.woodpecker/`, `.woodpecker.yaml`, `.woodpecker.yml`
- **说明**: 默认流水线配置文件路径。

### WOODPECKER_DEFAULT_PIPELINE_CONFIG_EXTENSIONS

- **默认值**: `.yaml`, `.yml`
- **说明**: 扫描流水线配置目录时的默认配置文件扩展名。

---

## 插件

### WOODPECKER_PLUGINS_PRIVILEGED

- **默认值**: 无
- **说明**: 以特权模式运行的 Docker 镜像列表。建议指定镜像标签以确保精确匹配。

### WOODPECKER_PLUGINS_TRUSTED_CLONE

- **默认值**: `docker.io/woodpeckerci/plugin-git,docker.io/woodpeckerci/plugin-git,quay.io/woodpeckerci/plugin-git`
- **说明**: 受信任处理 Git 凭证信息的克隆插件列表。不在列表中的镜像将不会注入 Git 凭证。

---

## Docker

### WOODPECKER_DOCKER_CONFIG

- **默认值**: 无
- **说明**: 为所有流水线配置特定的私有仓库配置。
- **示例**: `WOODPECKER_DOCKER_CONFIG=/home/user/.docker/config.json`

### WOODPECKER_ENVIRONMENT

- **默认值**: 无
- **说明**: 在所有流水线中可用的全局环境变量。不能覆盖已有的内置变量。
- **示例**: `WOODPECKER_ENVIRONMENT=first_var:value1,second_var:value2`

---

## Agent 通信

### WOODPECKER_AGENT_SECRET

- **默认值**: 无
- **说明**: Server 和 Agent 之间用于认证通信的共享密钥。可通过 `openssl rand -hex 32` 生成。

### WOODPECKER_AGENT_SECRET_FILE

- **默认值**: 无
- **说明**: 从指定文件路径读取 `WOODPECKER_AGENT_SECRET` 的值。

### WOODPECKER_KEEPALIVE_MIN_TIME

- **默认值**: 无
- **说明**: 服务端强制策略，规定客户端在发送 keepalive ping 前的最短等待时间。
- **示例**: `WOODPECKER_KEEPALIVE_MIN_TIME=10s`

---

## 状态推送

### WOODPECKER_STATUS_CONTEXT

- **默认值**: `ci/woodpecker`
- **说明**: Woodpecker 向 SCM 发布状态消息时使用的上下文前缀。运行多个 Woodpecker 实例时可能需要修改。

### WOODPECKER_STATUS_CONTEXT_FORMAT

- **默认值**: `{{ .context }}/{{ .event }}/{{ .workflow }}{{if not (eq .axis_id 0)}}/{{.axis_id}}{{end}}`
- **说明**: 推送到 Forge 的状态消息模板，使用 Go templates。支持的变量：
  - `context`: Woodpecker 上下文
  - `event`: 触发流水线的事件
  - `workflow`: 工作流名称
  - `owner`: 仓库所有者
  - `repo`: 仓库名称

---

## 配置扩展

### WOODPECKER_CONFIG_EXTENSION_ENDPOINT

- **默认值**: 无
- **说明**: 配置扩展端点 URL。详见 [Configuration Extension](https://woodpecker-ci.org/docs/usage/extensions/config-extension)。

### WOODPECKER_DEFAULT_PIPELINE_CONFIGS

- **默认值**: `.woodpecker/`, `.woodpecker.yaml`, `.woodpecker.yml`
- **说明**: 默认流水线配置文件路径。

### WOODPECKER_DEFAULT_PIPELINE_CONFIG_EXTENSIONS

- **默认值**: `.yaml`, `.yml`
- **说明**: 扫描流水线配置目录时的默认配置文件扩展名。

### WOODPECKER_CONFIG_EXTENSION_EXCLUSIVE

- **默认值**: `false`
- **说明**: 是否跳过 Forge 请求，全局配置端点独占。
- **警告**: 启用后所有仓库将仅使用全局配置服务端点，无法直接在 Forge 中定义流水线。

### WOODPECKER_CONFIG_EXTENSION_NETRC

- **默认值**: `false`
- **说明**: 将 `netrc` 数据发送到配置扩展端点。
- **警告**: `netrc` 包含仓库访问凭据，功能强大，请谨慎使用。

---

## 密钥扩展

### WOODPECKER_SECRET_EXTENSION_ENDPOINT

- **默认值**: 无
- **说明**: 密钥扩展端点 URL。详见 [Secret Extension](https://woodpecker-ci.org/docs/usage/extensions/secret-extension)。

### WOODPECKER_SECRET_EXTENSION_NETRC

- **默认值**: `false`
- **说明**: 将 `netrc` 数据发送到密钥扩展端点。

---

## 注册表扩展

### WOODPECKER_REGISTRY_EXTENSION_ENDPOINT

- **默认值**: 无
- **说明**: 注册表扩展端点 URL。详见 [Registry Extension](https://woodpecker-ci.org/docs/usage/extensions/registry-extension)。

### WOODPECKER_REGISTRY_EXTENSION_NETRC

- **默认值**: `false`
- **说明**: 将 `netrc` 数据发送到注册表扩展端点。

---

## 扩展网络限制

### WOODPECKER_EXTENSIONS_ALLOWED_HOSTS

- **默认值**: `external`
- **说明**: 允许扩展访问的主机列表（逗号分隔）。可选值：`loopback`、`private`、`external`、`*` 或 CIDR 列表。

---

## Forge 相关

### WOODPECKER_FORGE_TIMEOUT

- **默认值**: `5s`
- **说明**: 从 Forge 获取 Woodpecker 配置时的超时时间。语法参考 [time.ParseDuration](https://pkg.go.dev/time#ParseDuration)。

### WOODPECKER_FORGE_RETRY

- **默认值**: `3`
- **说明**: 从 Forge 获取配置失败时的重试次数。

---

## 其他

### WOODPECKER_ENABLE_SWAGGER

- **默认值**: `true`
- **说明**: 启用 Swagger UI 用于 API 文档。

### WOODPECKER_DISABLE_VERSION_CHECK

- **默认值**: `false`
- **说明**: 在管理 Web UI 中禁用版本检查。

### WOODPECKER_LOG_STORE

- **默认值**: `database`
- **说明**: 日志存储方式。可选值：
  - `database`: 日志存储在数据库中
  - `file`: 日志以 JSON 文件存储在文件系统中
  - `addon`: 使用[扩展](./100-addons.md#log)存储日志

### WOODPECKER_LOG_STORE_FILE_PATH

- **默认值**: 无
- **说明**: 根据 `WOODPECKER_LOG_STORE` 的值：
  - `file`: 日志存储目录
  - `addon`: 扩展可执行文件路径

### WOODPECKER_EXPERT_WEBHOOK_HOST

- **默认值**: 无
- **说明**: ⚠️ 专家选项，大部分情况无需设置。Forge 调用 webhook 时使用的完整 Woodpecker 服务器 URL。格式: `<scheme>://<host>[/<prefix path>]`

### WOODPECKER_EXPERT_FORGE_OAUTH_HOST

- **默认值**: 无
- **说明**: ⚠️ 专家选项，大部分情况无需设置。Forge URL 非公网地址时使用的完整公网 Forge URL。格式: `<scheme>://<host>[/<prefix path>]`

### WOODPECKER_FORCE_IGNORE_SERVICE_FAILURE

- **默认值**: `true`
- **说明**: ⚠️ 自 v3.14.0 起，Woodpecker 可报告服务和分离步骤的状态。为了向后兼容，默认忽略服务失败。建议禁用此选项并更新流水线配置。

---

## Forge 专属变量

各 Forge 平台的专属环境变量配置，请参阅对应的 Forge 配置文档：

| Forge 平台 | 文档 |
|-----------|------|
| GitHub | [Server 环境变量 - WOODPECKER_GITHUB_\*](./README.md#github) |
| Gitea | [Server 环境变量 - WOODPECKER_GITEA_\*](./README.md#gitea) |
| Forgejo | [Server 环境变量 - WOODPECKER_FORGEJO_\*](./README.md#forgejo) |
| GitLab | [Server 环境变量 - WOODPECKER_GITLAB_\*](./README.md#gitlab) |
| Bitbucket | [Server 环境变量 - WOODPECKER_BITBUCKET_\*](./README.md#bitbucket) |
| Bitbucket Datacenter | [Server 环境变量 - WOODPECKER_BITBUCKET_DC_\*](./README.md#bitbucket-datacenter--server) |
| AtomGit | [Server 环境变量 - WOODPECKER_ATOMGIT_\*](./README.md#atomgit) |
