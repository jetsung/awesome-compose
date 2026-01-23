# LiteLLM

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [LiteLLM][1] 是一个非常实用的开源 Python 库（也是目前最流行的 LLM 网关/代理工具之一）。

**使用 OpenAI 的输入/输出格式，调用 100+ 个大型语言模型**

- 将输入转换为各个服务提供商的端点格式（包括 `/chat/completions`、`/responses`、`/embeddings`、`/images`、`/audio`、`/batches` 等）。
- [统一的输出格式](https://docs.litellm.ai/docs/supported_endpoints) - 无论您使用哪个服务提供商，响应格式都保持一致。
- 提供重试/回退机制，可在多个部署之间切换（例如，Azure/OpenAI）- [路由器](https://docs.litellm.ai/docs/routing)。
- 跟踪支出并为每个项目设置预算 - [LiteLLM 代理服务器](https://docs.litellm.ai/docs/simple_proxy)。

[1]:https://www.litellm.ai/
[2]:https://github.com/BerriAI/litellm
[3]:https:///ghcr.io/berriai/litellm:main-stable
[4]:https://docs.litellm.ai/docs/proxy/docker_quick_start

---

- [`.env`](https://github.com/BerriAI/litellm/blob/main/.env.example)
- [`docker-compose.yml`](https://github.com/BerriAI/litellm/blob/main/docker-compose.yml)
- [`prometheus.yml`](https://github.com/BerriAI/litellm/blob/main/prometheus.yml)

## 使用教程

### 环境变量
- [管理平台登录](https://docs.litellm.ai/docs/proxy/ui)
```bash
# 账号和密码
UI_USERNAME=ishaan-litellm   # username to sign in on UI
UI_PASSWORD=langchain        # password to sign in on UI
```

### 添加模型
注意：使用代理配合数据库时，你也可以**直接通过 UI 添加模型** （UI 可在 `/ui` 路由访问）。
文件名为 `config.yaml`，相关参数查看[模型配置](https://docs.litellm.ai/docs/proxy/docker_quick_start#understanding-model-configuration)
```yaml
model_list:
  - model_name: gpt-4o
    litellm_params:
      model: azure/my_azure_deployment
      api_base: os.environ/AZURE_API_BASE
      api_key: "os.environ/AZURE_API_KEY"
      api_version: "2025-01-01-preview" # [OPTIONAL] litellm uses the latest azure api_version by default
```
- **`model_name`** (字符串) - 此字段应包含接收到的模型名称。
- **`litellm_params`** (字典) [查看所有 LiteLLM 参数](https://github.com/BerriAI/litellm/blob/559a6ad826b5daef41565f54f06c739c8c068b28/litellm/types/router.py#L222)
    - **`model`** (字符串) - 指定要发送到 `litellm.acompletion` / `litellm.aembedding` 等的模型的名称。 这是 LiteLLM 用于在后端将请求路由到正确的模型和提供商的标识符。
    - **`api_key`** (字符串) - 身份验证所需的 API 密钥。 可以从环境变量中获取，使用 `os.environ/`。
    - **`api_base`** (字符串) - 您的 Azure 部署的 API 基础地址。
    - **`api_version`** (字符串) - 调用 Azure OpenAI API 时使用的 API 版本。 您可以从 [这里](https://learn.microsoft.com/en-us/azure/ai-services/openai/api-version-deprecation?source=recommendations#latest-preview-api-releases) 获取最新的推理 API 版本。

**关于 `litellm_params` 下的 `model` 参数的详细说明：**

```yaml
model_list:
  - model_name: gpt-4o                       # 客户端使用的名称
    litellm_params:
      model: azure/my_azure_deployment       # <提供商>/<模型名称>
             ─────  ───────────────────
               │           │
               │           └─────▶ 发送给提供商 API 的模型名称
               │
               └─────────────────▶ LiteLLM 路由到哪个提供商
```

**可视化分解：**

```
model: azure/my_azure_deployment
       └─┬─┘ └─────────┬─────────┘
         │             │
         │             └────▶ 发送给 Azure 的实际模型标识符
         │                   （例如，你的部署名称或模型名称）
         │
         └──────────────────▶ 告诉 LiteLLM 使用哪个提供商
                             （azure, openai, anthropic, bedrock 等）
```

**关键概念：**

- **`model_name`**: 客户端用于调用模型的别名。 这是你在 API 请求中发送的内容（例如，`gpt-4o`）。

- **`model` (在 `litellm_params` 中)**：格式为 `<提供商>/<模型标识符>`
  - **提供商**（`/` 之前）：用于路由到正确的 LLM 提供商（例如，`azure`、`openai`、`anthropic`、`bedrock`）。
  - **模型标识符**（`/` 之后）：发送给该提供商 API 的实际模型/部署名称。

**高级配置示例：**

对于兼容 OpenAI 的自定义端点（例如，vLLM、Ollama、自定义部署）：

```yaml
model_list:
  - model_name: my-custom-model
    litellm_params:
      model: openai/nvidia/llama-3.2-nv-embedqa-1b-v2
      api_base: http://my-service.svc.cluster.local:8000/v1
      api_key: "sk-1234"
```

设置忽略不可用的参数
```yaml
litellm_settings:
  drop_params: true          # 全局生效，所有模型自动丢弃不支持的参数
```

**分解复杂的模型路径：**

```
model: openai/nvidia/llama-3.2-nv-embedqa-1b-v2
       └─┬──┘ └────────────┬────────────────┘
         │                 │
         │                 └────▶ 发送给提供商 API 的完整模型字符串
         │                       （在本例中： "nvidia/llama-3.2-nv-embedqa-1b-v2"）
         │
         └──────────────────────▶ 提供商 (openai = OpenAI 兼容的 API)
```

关键点：`/` 之后的所有内容都会原样传递给提供商的 API。

### 触发 `/chat/completion`
LiteLLM 代理 100%兼容 OpenAI。通过 `/chat/completions` 途径测试你的 Azure 模型。
```bash
curl -X POST 'http://0.0.0.0:4000/chat/completions' \
-H 'Content-Type: application/json' \
-H 'Authorization: Bearer sk-1234' \
-d '{
    "model": "gpt-4o",
    "messages": [
      {
        "role": "system",
        "content": "You are an LLM named gpt-4o"
      },
      {
        "role": "user",
        "content": "what is your name?"
      }
    ]
}'
```

### 生成虚拟密钥

`config.yaml`
```yaml
model_list:
  - model_name: gpt-4o
    litellm_params:
      model: azure/my_azure_deployment
      api_base: os.environ/AZURE_API_BASE
      api_key: "os.environ/AZURE_API_KEY"
      api_version: "2025-01-01-preview" # [OPTIONAL] litellm uses the latest azure api_version by default

# 或者直接通过 .env 环境变量设置
general_settings:
  master_key: sk-1234 # 必须以 sk- 开头
  database_url: "postgresql://<user>:<password>@<host>:<port>/<dbname>" # 👈 KEY CHANGE
```

**什么是 `general_settings`？**

这些是 LiteLLM 代理服务器的设置。
查看所有通用设置 [在此处](http://localhost:3000/docs/proxy/configs#all-settings)。

1. **`master_key`** (字符串)
   - **描述：**
     - 设置一个 `master key`，这是您的代理管理员密钥。 您可以使用它来创建其他密钥（🚨 必须以 `sk-` 开头）。
   - **用法：**
     - **在 `config.yaml` 中设置：** 在 `general_settings:master_key` 下设置您的主密钥，例如：
       `master_key: sk-1234`
     - **设置环境变量：** 设置 `LITELLM_MASTER_KEY`。

2. **`database_url`** (字符串)
   - **描述：**
     - 设置一个 `database_url`，这是连接到您的 PostgreSQL 数据库的地址，LiteLLM 使用它来生成密钥、用户和团队。
   - **用法：**
     - **在 `config.yaml` 中设置：** 在 `general_settings:database_url` 下设置您的数据库 URL，例如：
       `database_url: "postgresql://..."`
     - 在环境变量中设置 `DATABASE_URL=postgresql://<user>:<password>@<host>:<port>/<dbname>`。

## 常见问题
- SSL 证书错误
```bash
ssl.SSLCertVerificationError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self-signed certificate in certificate chain (_ssl.c:1006)
```
```yaml
# config.yaml
litellm_settings:
    ssl_verify: false # 👈 KEY CHANGE
```

- 数据库连接失败
```bash
httpx.ConnectError: All connection attempts failed

ERROR:    Application startup failed. Exiting.
3:21:43 - LiteLLM Proxy:ERROR: utils.py:2207 - Error getting LiteLLM_SpendLogs row count: All connection attempts failed
```
```bash
# 创建数据库
STATEMENT: CREATE DATABASE "litellm"
```
若权限有问题
```bash
ERROR: permission denied to create
```
```bash
GRANT ALL PRIVILEGES ON DATABASE litellm TO your_username;
```
