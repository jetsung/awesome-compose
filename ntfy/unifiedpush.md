# UnifiedPush 配置指南

## 什么是 UnifiedPush？

[UnifiedPush](https://unifiedpush.org) 是一个开源的推送通知标准，允许用户在不依赖 Google 服务的情况下接收推送通知。ntfy 可以作为 UnifiedPush 分发商，将消息转发给支持 UnifiedPush 的应用。

## 私有实例配置

在私有实例中使用 UnifiedPush，需要解决一个关键问题：**应用服务器（如 Matrix/Synapse、Fediverse 服务器）需要能够向主题发送消息，但它们无法持有用户凭证**。

解决方案是通过 ACL 配置**匿名读写访问权限**。

### 配置步骤

#### 1. 创建 .env 文件

```env
#=============== 基础配置 ===============
NTFY_BASE_URL=http://ntfy.example.com
NTFY_LISTEN_HTTP=:80

#=============== 认证配置 ===============
NTFY_AUTH_FILE=/var/lib/ntfy/auth.db
NTFY_AUTH_DEFAULT_ACCESS=deny-all

# 用户配置 (可选，根据需要添加)
# 格式: username:password_hash:role
# 密码哈希可使用 docker exec -it ntfy ntfy user hash 命令生成
NTFY_AUTH_USERS=phil:$2a$10$YLiO8U21sX1uhZamTLJXHuxgVC0Z/GKISibrKCLohPgtG7yIxSk4C:admin

#=============== UnifiedPush 匿名访问权限 ===============
# UnifiedPush 既需要发送消息(write)，也需要接收消息(read)
# 方式一：通配符 (匹配所有 up* 开头的主题)
NTFY_AUTH_ACCESS=*:up*:read-write

# 方式二：精确主题 (更安全，只允许特定主题)
# NTFY_AUTH_ACCESS=*:up随机ID:read-write

#=============== 缓存配置 ===============
NTFY_CACHE_FILE=/var/lib/ntfy/cache.db
NTFY_CACHE_DURATION=12h

#=============== 附件配置 ===============
NTFY_ATTACHMENT_CACHE_DIR=/var/lib/ntfy/attachments

#=============== 反向代理配置 ===============
NTFY_BEHIND_PROXY=true

#=============== 其他配置 ===============
NTFY_ENABLE_LOGIN=true
```

#### 2. 创建 docker-compose.yml

```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    container_name: ntfy
    restart: unless-stopped
    env_file:
      - .env
    volumes:
      - ./data:/var/lib/ntfy
    ports:
      - 80:80
    command: serve
```

#### 3. 启动服务

```bash
docker-compose up -d
```

### 配置说明

| 环境变量 | 说明 |
|---------|------|
| `NTFY_AUTH_FILE` | 认证数据库文件路径 |
| `NTFY_AUTH_DEFAULT_ACCESS` | 默认访问权限，`deny-all` 表示默认拒绝所有访问 |
| `NTFY_AUTH_USERS` | 用户列表，格式：`username:password_hash:role` |
| `NTFY_AUTH_ACCESS` | 访问控制列表，格式：`username:topic:permission` |

### ACL 格式说明

```
username:topic:permission
```

- **username**: 用户名或 `*` (表示匿名用户)
- **topic**: 主题名，支持通配符 `*`
- **permission**: 权限类型
  - `read-write` / `rw`: 读和写
  - `read-only` / `ro` / `read`: 只读
  - `write-only` / `wo` / `write`: 只写
  - `deny` / `none`: 拒绝

### 两种配置方式对比

#### 方式一：通配符方式

```env
NTFY_AUTH_ACCESS=*:up*:read-write
```

- 优点：简单，一次配置所有 UnifiedPush 主题
- 缺点：任何知道主题名的人都可以发送和接收消息

#### 方式二：精确主题方式

```env
NTFY_AUTH_ACCESS=*:up1234567890abc:read-write
```

- 优点：更安全，只有知道精确主题名的应用才能发送
- 缺点：需要为每个 UnifiedPush 应用单独配置

## 安全建议

### 1. 使用随机主题名

UnifiedPush 主题名应该是随机的、不可预测的字符串。这相当于一个"密码"，只有知道主题名的人才能发送消息。

例如：
- `upabc123def456` - 好
- `upmytopic` - 不好（容易被猜到）

### 2. 精确主题优于通配符

在生产环境中，建议使用精确主题而非通配符：

```env
# 不推荐
NTFY_AUTH_ACCESS=*:up*:read-write

# 推荐
NTFY_AUTH_ACCESS=*:upabc123def456:read-write
```

### 3. 限制主题数量

如果使用通配符，可以通过 rate limiting 限制单个主题的消息频率：

```env
NTFY_VISITOR_MESSAGE_DAILY_LIMIT=1000
```

## 常见问题

### Q: 设置后仍然无法接收通知？

检查 ACL 配置是否正确：

```bash
# 进入容器查看 ACL
docker exec -it ntfy ntfy access
```

确保 `*` 用户对 `up*` 主题有 read-write 权限。

### Q: 如何查看 UnifiedPush 主题？

在手机上的 ntfy/Android 应用中，订阅 UnifiedPush 后可以在设置中查看主题名。

### Q: 支持哪些 UnifiedPush 应用？

详见 [UnifiedPush 应用列表](https://unifiedpush.org/users/apps/)。

## 参考链接

- [ntfy 官方文档 - UnifiedPush](https://docs.ntfy.sh/config/#example-unifiedpush)
- [UnifiedPush 官方文档](https://unifiedpush.org)
- [UnifiedPush ntfy 分发商指南](https://unifiedpush.org/users/distributors/ntfy/)
