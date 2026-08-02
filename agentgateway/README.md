# Agentgateway

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Agentgateway][1] 是一款基于原生人工智能协议（[MCP](https://modelcontextprotocol.io/introduction) 与 [A2A](https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/)）构建的开源代理，可为跨任何框架和环境的代理与大语言模型（LLM）之间、代理与工具之间以及代理与代理之间的通信，提供即插即用的安全性、可观测性和治理功能。

## 主要特性

- **大语言模型网关**
  通过统一的兼容 OpenAI 的 API，将流量路由到主要的大语言模型供应商（OpenAI、Anthropic、Gemini、Bedrock 等），并具备预算与支出控制、提示词增强、负载均衡和故障转移功能。

- **MCP 网关**
  通过 MCP 将大语言模型连接到工具和外部数据源，具备工具联合、标准输入输出/HTTP/SSE/可流化 HTTP 传输、OpenAPI 集成以及 OAuth 身份验证功能。

- **A2A 网关**
  使用 A2A 实现安全的代理与代理之间的通信，具备能力发现、模态协商和任务协作功能。

- **推理路由**
  利用 Kubernetes 推理网关扩展，基于 GPU 利用率、键值缓存（KV cache）、低秩自适应（LoRA）适配器和队列深度等因素做出决策，智能地将请求路由到自托管模型。

- **防护措施**
  提供多层内容过滤，包括正则表达式、OpenAI 内容审核、AWS Bedrock 防护措施、Google 模型防护以及自定义 webhook。

- **安全性与可观测性**
  支持身份验证（JWT、API 密钥、OAuth），借助 CEL 策略引擎实现细粒度的基于角色的访问控制（RBAC）、速率限制、传输层安全（TLS）以及 OpenTelemetry 指标/日志/追踪。

[1]:https://agentgateway.dev/
[2]:https://github.com/agentgateway/agentgateway
[3]:https://ghcr.io/agentgateway/agentgateway
[4]:https://agentgateway.dev/docs/standalone/latest/deployment/docker/

---

## 配置文件说明

### 配置文件结构 `config.yaml`

Agentgateway 支持通过 YAML 或 JSON 格式的配置文件对网关策略、数据库、管理 UI、LLM 模型提供者及路由规则进行定义。配置文件示例如下：

```yaml
# yaml-language-server: $schema=https://agentgateway.dev/schema/config
config:
  database:
    url: sqlite:///config/data.db
gateways:
  default:
    port: 4000
ui:
  gateways: default
  policies:
    oidc:
      issuer: https://auth.your-domain.com
      clientId: <YOUR_OIDC_CLIENT_ID>
      clientSecret: <YOUR_OIDC_CLIENT_SECRET>
      redirectURI: https://your-domain.com/oauth/callback
    apiKey:
      keys:
      - key: <YOUR_UI_API_KEY_1>
      - key: <YOUR_UI_API_KEY_2>
llm:
  gateways: default
  policies:
    apiKey:
      keys:
      - key: <YOUR_LLM_API_KEY>
        metadata:
          name: ApiKey
      mode: strict
  models:
  - name: agnes/agnes-2.5-flash
    provider:
      reference: Agnes
    params:
      model: agnes-2.5-flash
  providers:
  - name: Agnes
    provider:
      custom:
        formats:
        - type: completions
    params:
      apiKey: <YOUR_PROVIDER_API_KEY>
      baseUrl: https://api.your-provider.com
  virtualModels: []
frontendPolicies:
  http:
    maxBufferSize: 33554432
```

#### 配置参数详解

1. **`config` (全局配置)**
   - `database.url`: 持久化 SQLite 数据库路径（如 `sqlite:///config/data.db`），用于保存控制台配置、密钥及持久化状态。

2. **`gateways` (网关监听入口)**
   - 定义服务流量的监听入口及端口。示例中定义了 `default` 网关监听 `4000` 端口。

3. **`ui` (管理控制台配置)**
   - `gateways`: 指定 UI 绑定的网关名称（`default`）。
   - `policies`: 控制台访问安全策略：
     - `oidc`: 配置 OIDC 单点登录认证（包含发行方 `issuer`、客户端 `clientId`/`clientSecret` 及回调 `redirectURI`）。
     - `apiKey`: 配置访问 UI 所需的 API 密钥列表。

4. **`llm` (大语言模型网关配置)**
   - `gateways`: 指定绑定的网关入口名称。
   - `policies.apiKey`: 客户端访问 LLM 服务时的身份验证策略，设置为 `mode: strict` 时开启严格密钥校验。
   - `models`: 声明客户端调用的模型名称映射规则（如将 `agnes/agnes-2.5-flash` 映射至 `Agnes` 提供商）。
   - `providers`: 配置后端 LLM 提供商（自定义提供商类型 `custom`，包含格式 `completions`、API 密钥与上游 `baseUrl`）。

5. **`frontendPolicies` (前端传输策略)**
   - `http.maxBufferSize`: 限制 HTTP 请求的前端最大缓冲区大小（如 `33554432` 字节，即 32MB）。

---

## 部署教程

### 环境变量 `.env`

项目包含 `.env` 文件用于设置系统时区及暴露端口：

```dotenv
# 时区设置
TZ=Asia/Shanghai

# 端口配置
MCP_PORT=3000
LLM_PORT=4000

# 可选：OIDC Cookie 密钥生成 (如：openssl rand -hex 32)
# OIDC_COOKIE_SECRET=
```

### Docker Compose 部署

1. **基础服务配置 (`compose.yaml`)**

```yaml
---
# https://ghcr.io/agentgateway/agentgateway
services:
  agentgateway:
    container_name: agentgateway
    env_file:
      - path: ./.env
        required: false
    hostname: agentgateway
    image: ghcr.io/agentgateway/agentgateway:latest
    ports:
      - "3000:3000"
      - "4000:4000"
    restart: unless-stopped
```

2. **本地覆盖配置 (`compose.override.yaml`)**

```yaml
---
services:
  agentgateway:
    user: 0:0
    ports: !override
      - "${MCP_PORT:-3000}:3000"
      - "${LLM_PORT:-4000}:4000"
    volumes:
      - ./data:/config
```

3. **启动服务**

```bash
docker compose up -d
```

---

## 使用与测试

### 1. 访问管理控制台 (Web UI)
服务启动后，可以通过浏览器访问管理 UI：
- 控制台地址：`http://localhost:15000/ui` （或访问网关端口 `http://localhost:4000/ui`）

### 2. 调用 LLM Chat Completions 接口
Agentgateway 提供了与 OpenAI 兼容的 `/v1/chat/completions` 接口，可以通过 `curl` 进行测试：

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <YOUR_LLM_API_KEY>" \
  -d '{
    "model": "agnes/agnes-2.5-flash",
    "messages": [
      {"role": "user", "content": "你好，请介绍一下你自己。"}
    ]
  }'
```
