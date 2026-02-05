# Memos

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Memos][1] 是一个现代、开源、自托管的知识管理和笔记平台，专为注重隐私的用户和组织而设计。Memos 提供了一个轻量级但功能强大的解决方案，用于捕获、组织和共享想法，具有全面的 Markdown 支持和跨平台可访问性。

[1]:https://www.usememos.com/
[2]:https://github.com/usememos/memos
[3]:https://hub.docker.com/r/neosmemo/memos
[4]:https://www.usememos.com/docs

---

## 设置

### 环境变量
```bash
# 启用演示模式
MEMOS_DEMO=false

# 绑定地址
MEMOS_ADDR=

# 绑定端口
MEMOS_PORT=8081

# Unix 套接字路径
MEMOS_UNIX_SOCK=

# 数据目录
MEMOS_DATA=auto

# 数据库驱动
MEMOS_DRIVER=sqlite

# 数据库 DSN
MEMOS_DSN=

# 公共实例 URL
# Host, X-Forwarded-Proto, X-Forwarded-For
MEMOS_INSTANCE_URL=
```

若启用 OIDC 方式登录，则需要配置
| 名称 | 映射字段 | 描述
| --- | --- | --- |
| 标识符（Identifier）| preferred_username | 用户名 |
| 显示名称 | nickname | 显示名称 |
| 邮箱 | email | 邮箱 |
