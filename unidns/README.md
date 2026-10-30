# UniDNS

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [UniDNS][1] 是多平台 DNS 记录统一管理系统：把阿里云、DNSPod（国内/国际）、EdgeOne（国内/国际）、CloudFlare、火山引擎的域名与解析记录聚合到一个界面，统一查看与增删改，并支持手动/定时全量同步。提供带会话鉴权的 REST API，前端在编译期嵌入二进制，单文件 + SQLite 即可运行。

[1]:https://unidns.gcli.cn/
[2]:https://github.com/jetsung/unidns
[3]:https://github.com/jetsung/unidns/pkgs/container/unidns
[4]:https://unidns.gcli.cn/02-getting-started/#__tabbed_1_3

---

## 部署教程

官方镜像 `ghcr.io/jetsung/unidns:latest`（多架构 amd64/arm64），单容器 + SQLite 即可运行，无需额外数据库。

### 1. 配置 `.env`

```bash
# CUSTOM
TZ=Asia/Shanghai
SERV_PORT=18686

# UniDNS
# 凭据加密主密钥（64 位 hex），使用 `openssl rand -hex 32` 生成；
# 留空则首次启动自动生成 data/secret.key
UNIDNS_MASTER_KEY=
# 预置管理员口令（仅首次设置口令时生效）
UNIDNS_ADMIN_PASSWORD=
# 定时全量同步间隔（分钟）；0 停用自动同步，启用时至少 30
UNIDNS_SYNC_INTERVAL=0
# 日志级别（RUST_LOG 语法）
UNIDNS_LOG=info
```

> 容器内已默认监听 `0.0.0.0:18686`、数据目录 `/app/data`，无需设置 `UNIDNS_LISTEN` / `UNIDNS_DATA_DIR`，空值视为未设置。

### 2. 修正数据目录权限

容器以非 root 用户 `65532` 运行（基于 distroless/static），首次启动前需先创建并授权数据目录，否则数据库无法写入：

```bash
mkdir -p ./data
chown -R 65532:65532 ./data
```

### 3. 启动

```bash
docker compose up -d
docker compose logs -f
```

访问 `http://<host>:18686`，首次进入 `/setup` 设置管理员口令。之后添加平台账户并同步域名即可。

> `compose.yaml` 中 `env_file` 的 `path` / `required` 写法需要 Docker Compose v2.24+；旧版本可改为 `env_file: ./.env` 并确保文件存在。

## 添加 DNS 平台账户

登录后进入「账户管理」→「新建账户」，选择平台类型并粘贴凭据 JSON，点「验证」确认连通后保存：

| 平台（`provider_type`） | 凭据字段 | 建议权限 |
| --- | --- | --- |
| 阿里云（`aliyun`） | `access_key_id`、`access_key_secret` | RAM 子账户，`AliyunDNSFullAccess` |
| DNSPod 国内（`dnspod`） | `secret_id`、`secret_key` | 腾讯云 CAM 密钥，`QcloudDNSPodFullAccess` |
| DNSPod 国际（`dnspod_intl`） | `secret_id`、`secret_key` | DNSPod 国际站 API 密钥 |
| EdgeOne 国内（`edgeone`） | `secret_id`、`secret_key` | EdgeOne（teo）读写权限，站点需 NS 接入 |
| EdgeOne 国际（`edgeone_intl`） | `secret_id`、`secret_key` | EdgeOne 国际站（edgeone.ai）密钥 |
| CloudFlare（`cloudflare`） | `api_token` | Token 限定 Zone，`Zone / DNS / Edit` |
| 火山引擎（`volcengine`） | `access_key_id`、`access_key_secret` | IAM 子用户，云解析 DNS 读写 |

```json
{"access_key_id": "LTAI...", "access_key_secret": "..."}
{"secret_id": "AKID...", "secret_key": "..."}
{"api_token": "..."}
```

> 腾讯云国内站与国际站账号体系独立、密钥不通用，请按账户实际所属选择对应类型。建议始终为 UniDNS 创建独立子账号/Token，不要使用主账号全局密钥。

保存后点「同步」即可把平台侧域名与解析记录拉取到本地，在「域名管理」中统一查看与编辑。

## 配置项

配置优先级：**环境变量 > `config.toml` > 默认值**。容器化部署通常只用环境变量。

| 配置项 | 环境变量 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `listen` | `UNIDNS_LISTEN` | `0.0.0.0:18686` | HTTP 监听地址 |
| `data_dir` | `UNIDNS_DATA_DIR` | `./data` | 数据目录（SQLite、`secret.key`） |
| `sync_interval_minutes` | `UNIDNS_SYNC_INTERVAL` | `0` | 定时全量同步间隔；`0` 停用，启用时至少 30 |
| `admin_password` | `UNIDNS_ADMIN_PASSWORD` | 无 | 预置管理员口令，仅首次设置时生效 |
| `master_key` | `UNIDNS_MASTER_KEY` | 自动生成 | 凭据加密主密钥，64 位 hex |
| — | `UNIDNS_CONFIG` | `./config.toml` | 配置文件路径 |
| — | `UNIDNS_LOG` | `info` | 日志级别（RUST_LOG 语法） |

> 环境变量中的同步间隔只是初始默认值；登录后在界面「同步设置」修改的值优先（存于数据库）。域名级同步开关同样在界面操作。

## 数据备份

需备份的只有数据目录 `./data`：

| 文件 | 内容 |
| --- | --- |
| `unidns.db` | SQLite 数据库（账户/域名/记录/同步历史） |
| `secret.key` | 凭据加密主密钥 |
| `config.toml` | 自动生成的示例配置（可修改） |

```bash
# 数据库为 WAL 模式，热备份建议用 sqlite3 .backup
sqlite3 ./data/unidns.db ".backup ./data/backup-unidns.db"
```

> `secret.key`（或 `UNIDNS_MASTER_KEY`）丢失后，已保存的平台凭据无法解密，只能删除账户重新录入。请将密钥与数据库一起备份。

## 常见运维

### 忘记管理员口令

```bash
# 先停止服务，避免写冲突；执行后按提示输入新口令
docker compose stop unidns
docker compose run --rm unidns reset-password
docker compose start unidns
```

`reset-password` 不校验旧口令，直接覆盖口令哈希，不影响已存账户凭据（凭据由主密钥加密），但要求 `secret.key` 仍在。

### 升级

```bash
docker compose pull
docker compose up -d
```

数据库迁移在启动时自动执行。静态资源（页面/图标/manifest）由 Service Worker 缓存，升级后随内置缓存版本号自动更新。

## 反向代理与 PWA

UniDNS 自身只提供 HTTP，公网部署建议置于 TLS 反向代理之后：

```nginx
server {
    listen 443 ssl;
    server_name dns.example.com;

    location / {
        proxy_pass http://127.0.0.1:18686;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

内置 Web App Manifest 与 Service Worker，可安装到桌面/主屏，但安装依赖安全上下文：仅 `localhost` 或 HTTPS 可用；通过 `http://<主机IP>:18686` 访问时自动降级为普通网页，其余功能不受影响。

## 安全说明

- 单管理员设计，请勿在无防护的公网直接暴露；建议内网部署或反代 + TLS
- 管理员口令以 Argon2id 哈希存储；平台凭据以 AES-256-GCM 加密落库，界面/API 仅显示打码串
- 会话 Cookie 为 HttpOnly，24 小时不活动过期
- 删除账户只清理本地数据，不调用平台写接口

## 相关链接

- [快速开始](https://unidns.gcli.cn/02-getting-started/)
- [配置参考](https://unidns.gcli.cn/03-configuration/)
- [DNS 提供商与凭据格式](https://unidns.gcli.cn/04-providers/)
- [REST API](https://unidns.gcli.cn/05-api/)
- [本地开发](https://unidns.gcli.cn/06-development/)
