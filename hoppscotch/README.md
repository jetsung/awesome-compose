# hoppscotch

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [hoppscotch][1] 一个轻量级的基于 Web 的 API 开发套件。

[1]:https://hoppscotch.com/
[2]:https://github.com/hoppscotch/hoppscotch
[3]:https://hub.docker.com/r/hoppscotch/hoppscotch
[4]:https://docs.hoppscotch.io/

---

## 端口描述
| 参数 | 端口 | 描述 |
|:---|:---|:---|
| `FRONTEND_PORT` | `3000` | 前端 |
| `ADMIN_PORT` | `3100` | 管理端 |
| `BACKEND_PORT` | `3170` | 后端 |
| `APP_PORT` | `3200` | APP端 |
| `AIO_PORT` | `8080` | All-In-One 一体化 |

## 部署教程

初始化配置信息
```bash
# 一体（若非80或443，则需含完整的路径）
./setup.sh aio hostname:8080

# 单体（不含端口）
./setup.sh one hostname

# 若为 https 协议，则第三参数必存在
./setup.sh one hostname x
```

### 初始化
1. 启动 `PostgreSQL`：
```bash
docker compose --profile init up -d
```
2. 初始化数据库
```bash
docker compose run --rm --entrypoint pnpm aio dlx prisma migrate deploy
```
3. 启动 `Hoppscotch`：
```bash
# 一体
docker compose --profile aio up -d

# 单体
docker compose --profile one up -d
```

4. 访问 `Hoppscotch` 管理端：
```bash
# 一体
http://hostname:8080 # Web
http://hostname:8080/admin # Admin
http://hostname:8080/backend # API

# 单体
http://hostname:3000 # Web
http://hostname:3100 # Admin
http://hostname:3170 # API
```

---

- 生成密钥
```bash
openssl rand -hex 16
```

- [OAuth 配置](https://docs.hoppscotch.io/documentation/self-host/community-edition/prerequisites#choosing-oauth-providers)
```bash
VITE_ALLOWED_AUTH_PROVIDERS=GOOGLE,GITHUB,MICROSOFT,EMAIL

GITHUB_CLIENT_ID=*****
GITHUB_CLIENT_SECRET=*****
GITHUB_CALLBACK_URL=http://localhost:3170/v1/auth/github/callback
GITHUB_SCOPE=user:email
```