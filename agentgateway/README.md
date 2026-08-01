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
