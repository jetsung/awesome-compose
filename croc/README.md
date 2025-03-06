# croc

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [CROC][1] 是一种工具，允许任意两台计算机简单安全地传输文件和文件夹。AFAIK，croc 是唯一可以执行以下**所有功能**的 CLI 文件传输工具：
- 允许**任意两台计算机**传输数据（使用中继）
- 提供**端到端加密**（使用 PAKE）
- 实现轻松的**跨平台**传输（Windows、Linux、Mac）
- 允许**多个文件**传输
- 允许**恢复中断**的传输
- 无需本地服务器或端口转发
- **IPv6 优先**，IPv4 回退
- 可以**使用代理**，如 Tor 

[1]:https://schollz.com/tinker/croc6
[2]:https://github.com/schollz/croc
[3]:https://hub.docker.com/r/schollz/croc
[4]:https://github.com/schollz/croc#usage

## 部署教程

```yaml
---
# 默认端口

services:
  croc:
    image: schollz/croc:latest
    container_name: croc
    restart: unless-stopped
    ports:
    - 9009-9013:9009-9013

# 指定端口
services:
  croc:
    image: schollz/croc:latest
    container_name: croc
    restart: unless-stopped
    ports:
    - 39009-39013:39009-39013
    command: ["relay", "--ports", "39009,39010,39011,39012,39013"]
```

## 使用教程

1. 发布消息
```bash
# 文件
croc send <file>

# 文字
croc send --text hello

# 使用自托管服务发送文件
croc --relay "myrelay.example.com:39009" send <file>
```
