# Relaydrop

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Relaydrop][1] 是一个文件中继工具，核心特性是 **支持通过 WebSocket over TLS（`wss://`）中转**，让发送方与接收方可以经过任意 TLS 终结的反向代理或隧道访问中继，而中继本身不持有证书、不占用 443。

[1]:https://relaydrop.ooos.top/
[2]:https://github.com/jetsung/relaydrop
[3]:https://hub.docker.com/r/jetsung/relaydrop
[4]:https://relaydrop.ooos.top/#compose

---

## Docker 部署

### 使用 compose 启动

直接拉取预构建镜像运行：

```bash
docker compose up -d
```

`compose.yaml` 内容（复制到自己的服务中即可）：

```yaml
services:
  relaydrop:
    container_name: relaydrop
    env_file:
      - path: ./.env
        required: false
    hostname: relaydrop
    image: ghcr.io/jetsung/relaydrop:latest
    ports:
      - 9090:9090
    restart: unless-stopped
```

`compose.yaml` 通过 `env_file` 读取宿主机 `./.env`（`required: false`）注入 `RELAYDROP_*` 环境变量；`.env` 文件写法与 `docker run -e` 用的是同一套变量，完整变量表见 [docs/env.md](docs/env.md)。

#### `.env` 文件示例

在 `compose.yaml` 同目录下新建 `.env`，一行一个 `KEY=VALUE`：

```bash
# .env
RELAYDROP_LISTEN=127.0.0.1:9090
RELAYDROP_PASSWORD=SECRET
```

- `RELAYDROP_PASSWORD`：中继口令，客户端须一致才能鉴权（必填）。
- `RELAYDROP_LISTEN`：监听地址，默认 `0.0.0.0:9090`；设为 `127.0.0.1:9090` 可仅本地监听，由前端网关代理。
- 其余变量（`RELAYDROP_TTL` 等）按需添加；完整变量表见 [docs/env.md](docs/env.md)。


| 子命令 | 参数 | 环境变量 |
| --- | --- | --- |
| `relay`   | `--listen` | `RELAYDROP_LISTEN` |
| `relay`   | `--password` | `RELAYDROP_PASSWORD` |
| `relay`   | `--ttl` | `RELAYDROP_TTL` |
| `send`    | `--relay` | `RELAYDROP_RELAY` |
| `send`    | `--code` | `RELAYDROP_CODE` |
| `send`    | `--password` | `RELAYDROP_PASSWORD` |
| `send`    | 位置参数 `path` | `RELAYDROP_PATH` |
| `receive` | `--relay` | `RELAYDROP_RELAY` |
| `receive` | `--code` | `RELAYDROP_CODE` |
| `receive` | `--password` | `RELAYDROP_PASSWORD` |
| `receive` | `--out` | `RELAYDROP_OUT` |

**优先级**：显式命令行参数 **>** 环境变量 **>** 默认值。

```bash
# 例：用环境变量提供中继口令，命令行只写必要项
export RELAYDROP_PASSWORD=SECRET
export RELAYDROP_RELAY=wss://relay.example.com
relaydrop send --code MYCODE ./big.iso        # 自动读 RELAYDROP_PASSWORD / RELAYDROP_RELAY
```

- 命令行上显式写的参数永远覆盖同名环境变量；两者都未给时才用默认值（或 `send` 的「省略 `--code` 则随机生成」）。
- 若环境里残留 `RELAYDROP_CODE`，`send` 会使用它而不是随机生成——这是预期行为，注意清理不需要的环境变量。

## 通用参数

| 参数 | 说明 |
| --- | --- |
| `--relay`   | 中继地址，支持 `tcp://host:port`、`ws://host:port/path`、`wss://host/path`；**省略协议头（`host:port`）时默认按 `tcp://` 处理** |
| `--code`    | 共享口令 / 房间名。**发送方与接收方必须一致** |
| `--password`| 中继口令，须与中继 `--password` 一致 |

## 环境变量

除命令行参数外，每个参数也都可用 `RELAYDROP_` 前缀的环境变量设置（如 `RELAYDROP_RELAY`、`RELAYDROP_PASSWORD`）。

> 环境变量的完整变量表、优先级与 systemd 集成见 [env.md](env.md)（唯一事实来源）；Docker / compose 部署中的环境变量用法见 [docker.md](docker.md)。

## 发送文件或文件夹（一条命令接收）

发送方省略 `--code` 时会**自动生成随机密钥**并打印一条可复制粘贴的接收命令；发送方先发起，
接收方后加入。中继口令 `--password` 是**事先确定的固定常量**，会原样嵌入打印命令，使接收方也能向中继鉴权。

```bash
# 发送方
relaydrop send --relay wss://relay.example.com/relay --password SECRET ./big.iso
# 终端打印：
#   On the other computer run:
#     relaydrop receive --relay wss://relay.example.com/relay --code <随机> --password SECRET --out .

# 接收方：直接粘贴上面打印的命令
```

- 流程：生成随机 `code` → 打印接收命令 → 连接 → 鉴权 → 加入房间 → 发送清单（路径/大小/逐文件哈希）
  → 逐文件分块（64KB）加密发送 → 每个文件结束发 `FileEnd` → 全部结束发 `Done`。
- 终端会显示已发送字节进度（按当前文件）。
- 若需固定 `code`（脚本/自动化），显式传 `--code` 即可，打印命令会使用它。

## 文件夹传输与多源发送

`send` 支持任意数量的源——多个文件、多个目录、或文件与目录的混合，全部在一次传输里完成：

```bash
# 多个文件 + 一个目录，混发
relaydrop send --relay wss://relay.example.com/relay --password SECRET ./a.txt ./b.log ./myfolder

# 也可用可重复的 --file 指定（与位置参数合并）
relaydrop send --relay wss://relay.example.com/relay --password SECRET --file a.txt --file b.log
```

规则：

- 每个输入项的**顶层名称会被保留**在接收方的 `--out` 下：文件 `a.txt` 直接落在 `--out/a.txt`；
  目录 `myfolder/` 展开为 `--out/myfolder/...`（目录名作为前缀）。
- 发送方把所有源**扁平化**为一份清单（相对路径、大小、逐文件 SHA-256），按路径排序后发送；
  接收方按相对路径重建目录树（自动创建子目录），逐文件解密写入并校验 SHA-256。
- **符号链接与非常规文件会被跳过**（日志中提示），不跟随、不传输。
- **同名冲突会报错**：若不同输入产生相同顶层名（如两个不同父目录下都叫 `a.txt`，或两个同名目录），
  发送方在发送前检测并报错 `duplicate entry name: ...`，不会发出任何数据。

## 接收文件

```bash
relaydrop receive \
  --relay wss://relay.example.com/relay \
  --code MYCODE \
  --password SECRET \
  --out ./downloads
```

- 接收方先启动也没关系（房间会等待另一个对等端）。
- 先收到清单（`Manifest`），再按条目流式接收并解密分块、写入本地；每文件结束时校验其 SHA-256。
- 路径穿越被阻止：仅取相对路径的正常组件，丢弃 `..`/绝对路径。
- 所有条目收齐并收到 `Done` 后报告成功；任一文件哈希不匹配即报错中止。

## 三种 `--relay` 模式

| 模式 | 场景 | 示例 |
| --- | --- | --- |
| `tcp://` | 中继可达的裸 TCP（同内网/直连） | `tcp://192.168.1.10:9090` |
| `ws://`  | 明文 WebSocket（直连中继，已绕过 TLS） | `ws://relay.example.com:9090/relay` |
| `wss://` | **经 TLS 终结的 WebSocket（生产部署）** | `wss://relay.example.com/relay` |

以 `wss://` 开头会自动走加密 WebSocket（由 tokio-tungstenite + rustls 完成 TLS）。

不带协议头时（例如 `--relay 192.168.1.10:9090` 或 `RELAYDROP_RELAY=127.0.0.1:9090`），客户端会自动补上 `tcp://` 再连接，因此裸 `host:port` 等价于 `tcp://host:port`。其它无法识别的协议头（如 `http://`）仍会报错，提示必须使用 `tcp://` / `ws://` / `wss://`。

## 完整示例（本机直连验证）

```bash
# 终端 1：中继
relaydrop relay --listen 127.0.0.1:9090 --password SECRET

# 终端 2：接收
relaydrop receive --relay tcp://127.0.0.1:9090 --code ABC --password SECRET --out ./dl

# 终端 3：发送
relaydrop send --relay tcp://127.0.0.1:9090 --code ABC --password SECRET --file ./photo.zip
```

## 跨网络拓扑示例（客户端与中继跨网络）

典型场景：客户端与中继不在同一网络（如中继在远端 VPS，发送方与其同内网，接收方在另一网络）。两端都通过 `wss://` 经前端的 TLS 终结层连到
那台 VPS 上的明文中继，文件在管道里是密文。

**中继所在 VPS**：

```bash
# 中继仅本地明文监听，TLS 由 nginx/cloudflared 在前端终结
relaydrop relay --listen 127.0.0.1:9090 --password SECRET
# 另起：nginx 反向代理 或 cloudflared 隧道，把 wss://relay.example.com 暴露出去
# （部署见 docs/nginx.md / docs/cloudflared.md，前端域名指向中继）
```

**发送方（与中继同内网/可达）**：

```bash
relaydrop send --relay tcp://127.0.0.1:9090 --password SECRET ./myfolder
# 终端打印：
#   On the other computer run:
#     relaydrop receive --relay wss://relay.example.com --code <随机> --password SECRET --out .
```

**接收方（可访问前端域名）**：直接粘贴上面打印的命令（注意 `--relay` 已是 `wss://relay.example.com`）：

```bash
relaydrop receive --relay wss://relay.example.com --code <随机> --password SECRET --out .
```

要点：

- 发送方 `--relay` 用 `tcp://` 连本地中继（不经过公网）；接收方 `--relay` 用 `wss://` 经前端 TLS 终结层。
- 同一 `--code`/`--password` 让两端进入中继同一房间；文

## nginx 反向代理配置

- 域名 `relay.example.com` 已解析到 VPS，并在 Cloudflare 设为 **Proxied（橙色云）**。
- 已获得该域名的证书（Cloudflare Origin Certificate 或 Let's Encrypt）。
- 中继已运行：`relaydrop relay --listen 127.0.0.1:9090 --password <RELAY_PASSWORD>`

## 完整配置

```nginx
# /etc/nginx/sites-available/relay.example.com
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 443 ssl;
    server_name relay.example.com;

    # Cloudflare Origin Certificate 或 Let's Encrypt
    ssl_certificate     /etc/nginx/certs/relay.example.com.pem;
    ssl_certificate_key /etc/nginx/certs/relay.example.com.key;

    # 仅允许 Cloudflare 回源 IP（可选，增强安全性）
    # 以 Cloudflare 官方 ips-v4 列表为准，变化时需同步更新：
    #   curl -s https://www.cloudflare.com/ips-v4 -o /etc/nginx/cloudflare-ips-v4.txt
    #   for ip in $(cat /etc/nginx/cloudflare-ips-v4.txt); do echo "allow $ip;"; done > /etc/nginx/conf.d/cloudflare-allow.conf
    # include /etc/nginx/conf.d/cloudflare-allow.conf;
    # deny all;

    location /relay {
        # 关键：转发 WebSocket 升级头
        proxy_pass http://127.0.0.1:9090;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 关键：Cloudflare 空闲超时约 100s，nginx 侧需更长以免提前断开
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }

    # 也可完全禁止其它路径
    location / {
        return 404;
    }
}
```

启用：

```bash
ln -sf /etc/nginx/sites-available/relay.example.com /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```
