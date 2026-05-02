# Apprise

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Apprise][1] 是一款开源的通知服务集合平台，通过统一的 URL 语法，支持向全球 100+ 种主流推送服务（如 Discord, Slack, Telegram, Email, Ntfy 等）发送消息。

[1]:https://appriseit.com/
[2]:https://github.com/caronc/apprise
[3]:https://hub.docker.com/r/caronc/apprise
[4]:https://appriseit.com/api/deployment/#quick-start

## 1. 快速部署 (Docker)

使用 Docker Compose 快速运行您的 Apprise API 实例：

```yaml
services:
  apprise:
    image: caronc/apprise
    ports:
      - "8000:8000"
    environment:
      - TZ=Asia/Shanghai
      - APPRISE_API_ONLY=yes
    volumes:
      - ./config:/config
```

:::warning
原生服务无状态且缺乏鉴权，生产环境建议配合 Nginx 反向代理增加 basic auth，或设置 `STRICT_MODE=yes` 并结合 fail2ban。
:::

## 2. 核心能力：多平台推送

Apprise 最大的优势在于**统一接口**。您无需为每个服务编写不同的 API 调用代码，只需构造对应的 URL：

### 支持平台示例
- **Telegram**: `tgram://bot_token/chat_id`
- **Discord**: `discord://webhook_id/webhook_token`
- **Ntfy**: `ntfys://username:password@ntfy.sh/topic`
- **Matrix**:
    - Token 模式 (推荐): `matrixs://{token}@{host}/{targets}`
    - 用户名/密码模式: `matrixs://{user}:{password}@{host}/{targets}`
- **邮件 (SMTP)**: `mailto://user:pass@smtp.host:587/to_address`
- **Bark**: `bark://device_key/`

> 查看 [完整支持平台列表](https://appriseit.com/services/) 或使用 [URL 构建器](https://appriseit.com/url-builder/) 生成您的专属链接。

## 3. 推送指南

### 方式 A：本地 CLI 直接推送
适用于脚本或本地服务器任务，无需预设配置文件：
```bash
# 单通道推送
apprise -t "标题" -b "内容" "discord://webhook_id/webhook_token"

# 多通道直接推送（一次性发送给多个不同平台）
apprise -t "标题" -b "内容" \
    "tgram://bot_token/chat_id" \
    "mailto://user:pass@smtp.host:587/to_address" \
    "bark://device_key/"
```

### 方式 B：向自建 Apprise 服务推送 (API)
如果您部署了上述 Docker 实例，可以通过调用 API 统一管理推送：

**1. 简单推送（无需配置文件）**
通过 `urls` 参数直接传入多个 URL 数组：
```bash
curl -X POST http://localhost:8000/notify/ \
  -d 'urls=["discord://...", "tgram://..."]' \
  -d 'title=警报' \
  -d 'body=服务器状态异常！'
```

**2. 高级推送 (配置文件模式 - 推荐)**
如果您在服务器上定义了 `config/apprise.yaml`：
```yaml
urls:
  - discord://webhook_id/webhook_token:
      tag: ops
  - mailto://admin@example.com:
      tag: ops
```
只需调用标签，即可触发配置中所有绑定的服务：
```bash
# 触发 ops 标签下的所有服务
curl -X POST http://localhost:8000/notify/ \
  -d 'tags=ops' \
  -d 'title=监控告警' \
  -d 'body=服务已恢复'
```

## 4. 进阶配置参考

| 变量 | 说明 |
| :--- | :--- |
| `APPRISE_CONFIG_LOCK` | `yes` 开启配置只读，防止 API 修改配置 |
| `APPRISE_ALLOW_SERVICES` | 逗号分隔，仅允许白名单内的服务推送 |
| `APPRISE_DENY_SERVICES` | 禁止特定服务（如 `syslog`, `windows` 等） |
| `APPRISE_ATTACH_SIZE` | 附件最大限制 (MB) |

---
*更多详细配置请查阅 [官方文档](https://appriseit.com/api/reference/environment/)*
