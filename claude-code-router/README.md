# claude-code-router

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [claude-code-router][1] 是一个将 OpenAPI 兼容模式请求转换为 Claude Code 模式的服务。

[1]:https://github.com/musistudio/claude-code-router
[2]:https://github.com/tinyzen/claude-code-router
[3]:https://hub.docker.com/r/jetsung/claude-code-router
[4]:https://github.com/tinyzen/claude-code-router

---

- 基础配置文件内容 `config.json`
```json
{
  "HOST": "0.0.0.0",
  "PORT": 3456,
  "APIKEY": "your-secret-key",
  "Providers": [],
  "Router": {}
}
```
