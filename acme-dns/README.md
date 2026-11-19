# acme-dns

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [acme-dns][1] 是一款简化版 DNS 服务器，附带 RESTful HTTP API，用于自动化 ACME DNS 质询。其具备的部分功能如下：

- 简化 DNS 服务器，服务 ACME DNS 质询（TXT 记录）。
- 支持自定义记录（A、AAAA、NS 等）。
- HTTP API 自动通过 Let's Encrypt 获取 TLS 证书。
- 支持按 CIDR 限制 `/update` 端点访问。
- 支持 SQLite 与 PostgreSQL 后端。
- 双 TXT 记录滚动更新，兼容 `domain.tld` 与 `*.domain.tld` 证书。

[1]:https://github.com/acme-dns/acme-dns
[2]:https://github.com/acme-dns/acme-dns
[3]:https://hub.docker.com/r/joohoi/acme-dns
[4]:https://github.com/acme-dns/acme-dns/blob/master/README.md

---

## 部署

```bash
mkdir data
# 修改 config/config.cfg 中的 domain、nsadmin、records 等配置
docker compose up -d
```

默认配置文件为 [`config/config.cfg`](config/config.cfg)，主要配置项：

| 配置项 | 说明 | 默认值 |
| --- | --- | --- |
| `listen` | DNS 监听地址 | `127.0.0.1:53` |
| `domain` | 服务域名 | `auth.example.org` |
| `records` | 预定义记录（A、NS） | 指向公网 IP |
| `database.engine` | 数据库引擎 | `sqlite` |
| `api.port` | API 监听端口 | `443` |
| `api.tls` | TLS 方式：`letsencrypt` / `letsencryptstaging` / `cert` / `none` | `none` |

## RESTful API

### 注册 `/register`

`POST /register` 返回新的唯一子域名及更新记录所需的凭据。`fulldomain` 即为 `_acme-challenge` CNAME 记录的指向目标。

可选：通过 POST JSON 数据（CIDR 表示法）限制 `/update` 请求的来源网络。

```bash
curl -X POST https://auth.example.org/register
# 可选限制来源网络
curl -X POST -d '{"allowfrom": ["192.168.100.1/24"]}' https://auth.example.org/register
```

响应 `Status: 201 Created`：

```json
{
    "allowfrom": [],
    "fulldomain": "8e5700ea-a4bf-41c7-8a77-e990661dcc6a.auth.example.org",
    "password": "htB9mR9DYgcu9bX_afHF62erXaH2TS7bg9KW3F7Z",
    "subdomain": "8e5700ea-a4bf-41c7-8a77-e990661dcc6a",
    "username": "c36f50e8-4632-44f0-83fe-e070fef28a10"
}
```

### 更新 `/update`

`POST /update` 更新唯一子域名的 TXT 记录内容，通常由自动化 ACME 客户端调用。

必需请求头：

| 请求头 | 说明 |
| --- | --- |
| `X-Api-User` | 注册返回的 UUIDv4 用户名 |
| `X-Api-Key` | 注册返回的密码 |

```bash
curl -X POST \
  -H "X-Api-User: <username>" \
  -H "X-Api-Key: <password>" \
  -d '{"subdomain": "<subdomain>", "txt": "___validation_token_received_from_the_ca___"}' \
  https://auth.example.org/update
```

响应 `Status: 200 OK`：

```json
{
    "txt": "___validation_token_received_from_the_ca___"
}
```

注意：`txt` 字段长度必须恰好为 43 个字符，否则会被拒绝。

验证 TXT 记录已生效：

```bash
dig -t txt @auth.example.org <subdomain>.auth.example.org
```

### 健康检查 `/health`

`GET /health` 用于检查服务就绪/存活状态，成功返回 `Status: 200 OK`。

## DNS 记录

在主域名 DNS 服务器上添加（以 `auth.example.org` 为例，`198.51.100.1` 为 acme-dns 服务器公网 IP）：

| 记录类型 | 示例 |
| --- | --- |
| NS | `auth.example.org. NS auth.example.org.` |
| A | `auth.example.org. A 198.51.100.1` |
| AAAA | `auth.example.org. A <IPv6 地址>`（如使用 IPv6） |
| CNAME | 每个待认证域名添加 `_acme-challenge` 子域名记录 |
