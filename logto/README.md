# Logto

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Logto][1] 是现代开源的 SaaS 和 AI 应用认证基础设施。

[1]:https://logto.io/
[2]:https://github.com/logto-io/logto
[3]:https://hub.docker.com/r/svhd/logto
[4]:https://docs.logto.io/logto-oss/get-started-with-oss

---

## 配置
1. 更新密钥
```bash
# 用于加密 Secret Vault 中数据加密密钥 (DEK) 的密钥加密密钥 (KEK)。Secret Vault 正常工作必须配置。必须为 base64 编码字符串。推荐使用 AES-256（32 字节）。示例：crypto.randomBytes(32).toString('base64')
SECRET_VAULT_KEK=
```
命令行
```bash
sed -i "s#^SECRET_VAULT_KEK=.*#SECRET_VAULT_KEK=$(openssl rand -base64 36 | tr -d '\n')#g" .env
```

2. 配置 [PostgreSQL](https://www.postgresql.org/docs/14/libpq-connect.html#id-1.7.3.8.3.6) 数据库
```bash
DB_URL=postgres://postgres:p0stgr3s@postgres:5432/logto
```

3. 配置 `TRUST_PROXY_HEADER` 值为 1
```bash
TRUST_PROXY_HEADER=1
```

**注意：** 若未启用外部域名，请注释下述两行  
```bash
ENDPOINT='protocol://localhost:3001'
ADMIN_ENDPOINT='protocol://localhost:3002'
```

[**更多配置**](https://docs.logto.io/zh-CN/concepts/core-service/configuration)
