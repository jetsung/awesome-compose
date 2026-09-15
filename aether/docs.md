# Aether 使用文档

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Aether][2] 是一个面向受限网络的加密隧道客户端：自动扫描发现可达的 Cloudflare WARP 边缘节点，建立加密隧道（MASQUE / WireGuard / WARP-in-WARP），并在本地暴露一个 SOCKS5 代理给应用程序使用。**它是纯客户端，无需自建服务端**——"服务端"就是 Cloudflare 的 WARP/MASQUE 公共基础设施。

[1]:https://cluvexstudio.github.io/aether/
[2]:https://github.com/cluvexstudio/aether
[3]:https://ghcr.io/cluvexstudio/aether
[4]:https://github.com/cluvexstudio/aether/blob/main/Docs/DOCS.en.md

## 整体架构

```
你的应用 ──► 本地 SOCKS5 代理 (127.0.0.1:1819)
                │
                ▼
        Aether 客户端（扫描节点 → 建隧道 → 混淆流量）
                │
                ▼
        Cloudflare WARP 边缘节点（公共基础设施）
                │
                ▼
            互联网
```

## WARP 工作机制

WARP 对使用者来说是透明的——Aether 替你完成与 Cloudflare 的全部交互：

1. **设备注册**：Aether 向 Cloudflare 的账号 API（`api.cloudflareclient.com`）注册一个设备身份，获取访问令牌和分配的隧道地址（IPv4/IPv6）。
2. **身份保存**：身份保存到本地配置文件 `aether.toml`（或 `--config` 指定的路径），之后每次启动复用，不必重复注册。
3. **节点扫描**：自动扫描发现当前网络可达的 Cloudflare 边缘节点（ip:port），不写死任何地址。
4. **建立隧道**：用保存的身份 + 扫到的节点建立加密隧道，可选传输方式：
   - MASQUE（HTTP/3 或 HTTP/2，默认，最像普通网页流量）
   - WireGuard（经典 WG）
   - gool（WireGuard 套 WireGuard，两层）
   - mim（MASQUE 套 MASQUE，两层，可换出口 IP）
5. **本地代理**：隧道建立后，本地 SOCKS5 代理在 `127.0.0.1:1819` 可用。

## 快速开始

```bash
./aether --masque --quick-reconnect -4
# 前台运行，WARP 隧道建立后本地 SOCKS5 即 127.0.0.1:1819
# Ctrl+C 停止
```

验证隧道是否已通（**务必等日志出现 `[+] socks5 server listening on 127.0.0.1:1819` 再执行**，扫描未完成时端口尚未监听，会报 `curl: (7) Failed to connect`）：

```bash
curl -x socks5h://127.0.0.1:1819 https://www.cloudflare.com/cdn-cgi/trace
# 返回中应看到 Cloudflare colo 和 warp=on
```

实测启动耗时参考（WireGuard）：`--scan turbo` 几秒，`--scan balanced`（默认）几十秒，`--scan thorough` 约 4 分钟（扫到截止时间收手，日志出现 `scan deadline reached` 属正常，会选实测最优节点）。日常建议 `--balanced` + `--quick-reconnect`，几秒即可就绪。

## 一、获取/构建客户端

**方式 A：下载预编译二进制**（从 Releases 页面，支持 Windows / macOS / Linux / Termux / OpenWrt）

**方式 B：源码编译**（要求 Rust 1.98+、C/C++ 编译器、CMake，且 `quiche/` 目录必须与 `aether/` 并列）：

```bash
cd aether
cargo build --release
# 产物：aether/target/release/aether
```

**方式 C：Docker**

官方镜像（GHCR）基于 distroless，构建时已带 `tor` feature 并内置 `pt/`（lyrebird），Tor 相关功能开箱即用。镜像内置默认值：`AETHER_SOCKS=0.0.0.0:1819`（容器内监听所有网卡，靠 `-p` 控制暴露面）、`AETHER_CONFIG=/data/aether.toml`（身份固定在数据卷），入口为 `aether`，参数直接跟在镜像名后。

```bash
# 最简运行（交互式回答协议/扫描/IP 问题）
docker run -it -p 127.0.0.1:1819:1819 -v aether-data:/data ghcr.io/cluvexstudio/aether:latest

# 非交互式（环境变量）
docker run -it -p 127.0.0.1:1819:1819 -v aether-data:/data \
  -e AETHER_PROTOCOL=masque \
  -e AETHER_SCAN=balanced \
  ghcr.io/cluvexstudio/aether:latest

# 命令行参数（ENTRYPOINT 已是 aether，直接附在镜像名后）
docker run -d -p 127.0.0.1:1819:1819 -v aether-data:/data \
  ghcr.io/cluvexstudio/aether:latest --wg --peer 162.159.192.1:2408
```

**两个关键点：**

| 关键点 | 原因 |
| --- | --- |
| 必须挂 `-v aether-data:/data` | 身份文件 `/data/aether.toml` 持久化；不挂则每次启动重新注册设备，很快被 Cloudflare 限流（429） |
| 端口映射写 `-p 127.0.0.1:1819:1819` | 容器内监听 `0.0.0.0` 且 SOCKS5 无认证；写 `-p 1819:1819` 会绑到宿主机所有网卡，变成开放代理。给局域网用则映射 LAN IP：`-p 192.168.1.1:1819:1819` |

验证与日志：

```bash
docker logs -f <容器名>     # 等日志出现 socks5 server listening 再测
curl -x socks5h://127.0.0.1:1819 https://www.cloudflare.com/cdn-cgi/trace
```

自建镜像（可选，需 `quiche/` 与 `aether/` 并列，构建含 Go 工具链编译 `pt/`，耗时较长）：

```bash
docker build -t aether .
docker run -it -p 127.0.0.1:1819:1819 -v aether-data:/data aether
```

### Docker Compose 方式

本目录提供 `compose.yaml`（环境变量集中在 `.env`，语法已验证），适合常驻部署：

```bash
docker compose up -d        # 启动（后台常驻，restart: unless-stopped）
docker compose logs -f      # 跟踪日志，等 socks5 server listening 再用代理
docker compose down         # 停止（数据卷 aether-data 保留，身份不丢）
```

默认配置：MASQUE + balanced 扫描 + IPv4，端口只发布到宿主机 `127.0.0.1:1819`。要共享给局域网，把 `ports` 改为 `"192.168.x.x:1819:1819"`（绑定 LAN IP；绝不要写 `"1819:1819"`，会绑到所有网卡变成开放代理）。

自定义协议/扫描/固定节点等，编辑 `.env` 文件（每个变量对应一个命令行参数；设置环境变量可跳过交互式提问，配 `restart` 无人值守时务必把协议、扫描、IP 版本三项设置全）。身份持久化在命名卷 `aether-data` 中，`docker compose down` 不会删除；确要清空身份用 `docker volume rm aether-data_aether-data`（会触发重新注册，注意限流）。

### 安装到系统路径（Linux）

Release 压缩包解压后是一个主程序 `aether` 加一个 `pt/` 目录：

```
aether-linux-x86_64/
├── aether        # 主程序，单文件，动态链接但只依赖 libc/libm/libgcc（任何 Linux 自带）
└── pt/
    └── lyrebird  # Tor 网桥的可插拔传输客户端（可选组件）
```

**`pt/` 是否必需？不是。** `pt/lyrebird` 只在 Tor 直连场景（`--tor-reverse` / `--tor-only`）且 Tor 被网络封锁、需要自动获取网桥时才会被调用；`--tor`（Tor 在隧道内）及 MASQUE / WireGuard / gool / mim 等主功能完全用不到它。缺了它也不会报错，只是网桥混淆这一项不可用。

**主程序可以直接移入 `/usr/local/bin/`**：

```bash
sudo mv ~/aether-linux-x86_64/aether /usr/local/bin/aether    # mv 保留执行权限；用 cp 则补 sudo chmod +x
```

若以后可能用到 Tor 网桥，把 `lyrebird` 放到 Aether 也会扫描的系统目录（可选）：

```bash
sudo mkdir -p /usr/local/lib/tor/pluggable-transports
sudo cp ~/aether-linux-x86_64/pt/lyrebird /usr/local/lib/tor/pluggable-transports/
```

只用 MASQUE/WireGuard 的话，`pt/` 和解压目录可以直接删除。

**身份文件注意**：`aether.toml` 默认生成在运行命令时的当前目录，不在二进制旁。装入系统路径后建议固定配置路径，避免每次换目录运行都重新注册身份（会被 Cloudflare 限流）：

```bash
aether --config /etc/aether/aether.toml      # 或 ~/.config/aether/aether.toml
```

## 二、运行客户端

最简单：无参数直接运行，交互式回答问题（协议、扫描模式、IP 版本）：

```bash
./aether
```

或用参数跳过提问：

```bash
./aether --masque -4 --scan turbo          # MASQUE (HTTP/3)，IPv4，快速扫描
./aether --wg --thorough --noize aggressive # WireGuard，aggressive 混淆档，应对严格管控的网络
./aether --gool                            # WireGuard 套 WireGuard
./aether --mim                             # MASQUE 套 MASQUE（换出口 IP）
./aether --h2 --fragment                   # HTTP/2 传输 + TLS ClientHello 分片
```

每个参数都有对应环境变量（如 `AETHER_PROTOCOL=masque AETHER_SCAN=balanced`），适合脚本/服务部署，完整列表见下文第六节。

### ⚠️ 启动需要等待：扫描完成前代理不可用

Aether 启动后要先扫描节点、建立并验证隧道，**然后才开始监听 SOCKS5 端口**。扫描期间执行 `curl -x socks5h://127.0.0.1:1819 ...` 会报 `curl: (7) Failed to connect ... Could not connect to server`，这是正常现象，不是故障。

实测各扫描模式的就绪耗时（WireGuard，本机参考值）：

| 扫描模式 | 启动到代理就绪耗时 | 适用场景 |
| --- | --- | --- |
| `--scan turbo` | 通常几秒 | 只想尽快连上 |
| `--scan balanced`（默认） | 几十秒 | 日常使用 |
| `--scan thorough` | 约 4 分钟甚至更久（扫到截止时间才收手，日志出现 `scan deadline reached` 属正常） | 首次排查、要挑最佳延迟 |

判断就绪的正确姿势——看日志出现这一行再用代理：

```
[+] socks5 server listening on 127.0.0.1:1819
```

或用脚本轮询端口：

```bash
while ! ss -tln | grep -q :1819; do sleep 2; done
curl -x socks5h://127.0.0.1:1819 https://www.cloudflare.com/cdn-cgi/trace
```

日常建议用 `--balanced` + `--quick-reconnect`（复用上次可用网关，跳过扫描，几秒恢复）；`--thorough` 只留作首次排查用。

## 三、使用代理（客户端侧）

启动成功后，本地 SOCKS5 代理在 **127.0.0.1:1819**。验证：

```bash
curl -x socks5h://127.0.0.1:1819 https://www.cloudflare.com/cdn-cgi/trace
# 应显示 Cloudflare colo 和 warp=on
```

然后让应用走这个代理即可（浏览器代理插件、`proxychains`、程序内配置等）。也可加 `--http-proxy 127.0.0.1:1820` 额外暴露一个 HTTP CONNECT 代理。

## 四、路由器/局域网共享部署

虽然没有自建服务端，但你可以在 OpenWrt 路由器上运行它，把代理共享给整个局域网：

```sh
aether --config /etc/aether/aether.toml --bind 192.168.1.1:1819 --mark 0xff
```

⚠️ 注意：SOCKS5 **无认证**，绝不能暴露到公网（WAN）；配置文件放持久存储（如 `/etc/aether`），否则每次重启都要重新注册 WARP 身份，会被 Cloudflare 限流。`--mark 0xff` 用于路由器自己也有 tun 前端的场景，防止流量回环（需 root/CAP_NET_ADMIN）。

## 五、指定端口

"端口"有两类：本地代理监听端口、远端 Cloudflare 节点端口。

### 1. 本地 SOCKS5 监听地址/端口（`--bind`，默认 `127.0.0.1:1819`）

```bash
./aether --wg --bind 127.0.0.1:7890        # 本地代理改用 7890 端口
./aether --bind 0.0.0.0:1819               # 监听所有网卡（共享给局域网；⚠️ 无认证，勿暴露公网）
./aether --bind 192.168.1.1:1819           # 路由器场景绑定 LAN 地址
./aether --http-proxy 127.0.0.1:1820       # 额外开一个 HTTP CONNECT 代理（默认关闭）
```

对应环境变量：`AETHER_SOCKS`、`AETHER_HTTP_PROXY`；Tor 代理端口用 `--tor-bind`（默认 1820，变量 `AETHER_TOR_BIND`）。

### 2. 指定远端节点 ip:端口（跳过扫描）

**端口必填**——哪个端口能通过正是不同网络的差异点，工具不会假设默认端口；两层模式的两个跳必须是不同地址，只给一个时另一个由扫描补齐。手动指定的节点失效后，重连会先重试它而不是被扫描结果替换。

```bash
# MASQUE / WireGuard 单跳
./aether --wg --peer 162.159.192.1:2408            # 变量 AETHER_PEER

# gool（双层 WireGuard）
./aether --gool --wiw-outer 162.159.192.1:2408     # 只指定外层（变量 AETHER_WIW_OUTER_PEER）
./aether --gool --wiw-inner 188.114.96.1:2408      # 只指定内层（变量 AETHER_WIW_INNER_PEER）
./aether --gool --wiw-peers 162.159.192.1:2408,188.114.96.1:2408   # 两层都定，无扫描（AETHER_WIW_PEERS）

# mim（双层 MASQUE）
./aether --mim --mim-outer <ip:端口> --mim-inner <ip:端口>
# 变量 AETHER_MIM_OUTER_PEER / AETHER_MIM_INNER_PEER / AETHER_MIM_PEERS（=auto 强制扫描）

# HTTP/2 传输的节点
./aether --h2 --h2-peer <ip:端口>                  # 变量 AETHER_MASQUE_H2_PEER
```

WARP WireGuard 常见端口有 `2408`、`500`、`1701`、`4500`、`854` 等，MASQUE 常用 `443`；哪个能用取决于所在网络，`--scan thorough` 就是用来穷举端口的。

典型组合——本地 7890、固定节点 2408 端口：

```bash
./aether --wg --bind 127.0.0.1:7890 --peer 162.159.192.1:2408 --quick-reconnect
```

## 六、环境变量完整参考

每个命令行参数都有对应的环境变量（用于脚本/容器/服务部署），设置环境变量可跳过对应的交互式提问；优先级：命令行参数 > 环境变量 > 交互式提问/默认值。多值变量用 `;` 分隔。Compose 部署时写入本目录 `.env` 即可（常用项见 `.env` 注释）。

### 连接与代理

| 变量 | 对应参数 | 说明与默认值 |
| --- | --- | --- |
| `AETHER_SOCKS` | `--bind` | SOCKS5 监听地址，默认 `127.0.0.1:1819` |
| `AETHER_HTTP_PROXY` | `--http-proxy` | 额外的 HTTP CONNECT 代理地址，默认关闭 |
| `AETHER_UPSTREAM` | `--upstream` | 上游代理 URL（如 `socks5://127.0.0.1:1080`、`http://user:pass@host:8080`），先经它再出网 |
| `AETHER_MARK` | `--mark` | 防火墙标记（SO_MARK，如 `0xff`），路由器 tun 场景防回环；需 root/CAP_NET_ADMIN |
| `AETHER_QUICK_RECONNECT` | `--quick-reconnect` / `--no-quick-reconnect` | `1` 总是复用上次网关不询问，`0` 总是重新扫描不询问；未设则启动时询问 |
| `AETHER_IP` | `-4` / `-6` / `--dual` / `--ip` | 扫描使用的 IP 版本：`v4`（默认）/ `v6` / `both` |
| `AETHER_PEER` / `AETHER_WG_PEER` | `--peer` / `--wg-peer` | 固定节点 `ip:port`，跳过扫描；gool 下指外层跳 |
| `AETHER_MAX_CLIENTS` | — | 同时服务的代理客户端数上限，默认按资源自动（512–8192） |

### 协议与节点

| 变量 | 对应参数 | 说明与默认值 |
| --- | --- | --- |
| `AETHER_PROTOCOL` | `--protocol` / `--masque` / `--wg` / `--gool` / `--mim` | 传输协议：`masque`（默认）/ `wg` / `gool` / `mim` |
| `AETHER_WIW_OUTER_PEER` | `--wiw-outer` | gool 外层跳 `ip:port`（端口必填） |
| `AETHER_WIW_INNER_PEER` | `--wiw-inner` | gool 内层跳 `ip:port` |
| `AETHER_WIW_PEERS` | `--wiw-peers` / `--wiw-scan` | 两跳合写 `outer,inner`；设 `auto` 强制扫描 |
| `AETHER_MIM_OUTER_PEER` | `--mim-outer` | mim 外层跳 `ip:port`（端口必填） |
| `AETHER_MIM_INNER_PEER` | `--mim-inner` | mim 内层跳 `ip:port` |
| `AETHER_MIM_PEERS` | `--mim-peers` / `--mim-scan` | 两跳合写；设 `auto` 强制扫描 |
| `AETHER_SCAN` | `--scan` | 扫描模式：`turbo` / `balanced`（默认）/ `thorough` / `stealth` / `ironclad` |
| `AETHER_NOIZE` | `--noize` | 混淆档：`off` / `light` / `firewall`（MASQUE 默认）/ `balanced`（WG/gool 默认）/ `aggressive` |
| `AETHER_WG_NO_PROFILE_RETRY` | `--no-profile-retry` | 设 `1` 后扫描失败不再换混淆档重试 |
| `AETHER_WG_KEEPALIVE` | `--keepalive` | WireGuard 持久保活间隔秒数，默认 `5` |
| `AETHER_WG_ENDPOINT_COOLDOWN_SECS` | — | 连败 2 次的节点重扫排除时长，默认 `300` |
| `AETHER_WG_STALE_SECS` | — | WireGuard 静默多久判死，默认 `10` |

### MASQUE 细项

| 变量 | 对应参数 | 说明与默认值 |
| --- | --- | --- |
| `AETHER_MASQUE_HTTP2` | `--h2` / `--h3` | `1` 用 HTTP/2（TCP），`0` 用 HTTP/3/QUIC（默认） |
| `AETHER_QUIC_V2` | `--no-quic-v2` | 设 `0` 关闭 QUIC v2 版本协商包（默认开启，可在封 QUIC v1 放行 v2 的网络开路） |
| `AETHER_MASQUE_H2_PEER` | `--h2-peer` | HTTP/2 传输的固定节点 `ip:port` |
| `AETHER_ECH` | `--ech` | 加密 ClientHello：`auto` 或 base64 配置 |
| `AETHER_MASQUE_H2_FRAGMENT` | `--fragment` | 设 `1` 启用 TLS ClientHello 分片（仅 HTTP/2） |
| `AETHER_MASQUE_H2_FRAGMENT_SIZE` | `--fragment-size` | 分片字节大小，默认 `16-32`（可写区间） |
| `AETHER_MASQUE_H2_FRAGMENT_DELAY` | `--fragment-delay` | 分片间隔毫秒，默认 `2-10` |
| `AETHER_MASQUE_H2_KEEPALIVE_SECS` | — | HTTP/2 保活间隔，默认 `15` |
| `AETHER_MASQUE_H2_KEEPALIVE_TIMEOUT_SECS` | — | 保活无应答判死时长，默认 `20` |
| `AETHER_DNS` | `--dns` | 隧道内使用的 DNS，默认 `1.1.1.1,1.0.0.1` |
| `AETHER_TLS_GROUPS` | `--tls-groups` | TLS 密钥交换组，默认模拟 Chrome：`P-256:X25519:P-384` |

### 超时与验证

| 变量 | 对应参数 | 说明与默认值 |
| --- | --- | --- |
| `AETHER_MASQUE_NO_DATA_CHECK` / `AETHER_WG_NO_DATA_CHECK` | `--no-data-check` | 设 `1` 跳过端到端数据面验证（分协议） |
| `AETHER_MASQUE_VALIDATE_SECS` / `AETHER_WG_VALIDATE_SECS` | `--validate-secs` | 数据面验证等待秒数，默认 `10` |
| `AETHER_MASQUE_STARTUP_SECS` | `--startup-secs` | MASQUE 启动总时限，默认 `30` |
| `AETHER_MASQUE_RECONNECT_SECS` / `AETHER_WG_RECONNECT_SECS` | `--reconnect-secs` | 掉线后重连延迟秒数，默认 `2` |
| `AETHER_TCP_CONNECT_SECS` | — | 经隧道建连时限，默认 `30` |
| `AETHER_TCP_KEEPALIVE_SECS` | — | 连接空闲保活探测间隔，默认 `60`（三次无应答关闭） |
| `AETHER_HALF_CLOSE_SECS` | — | 客户端发完后静默多久关闭连接，默认 `30` |
| `AETHER_ROUTE_SNIFF` | — | 设 `0` 关闭从首包读取服务名（默认开，是分流规则在 tun 前端下生效的前提） |
| `AETHER_ROUTE_SNIFF_MS` | — | 等待首包的时长，默认 `400` |
| `AETHER_IRONCLAD_PORT` | — | ironclad 扫描发真实 HTTP 请求的端口，默认 `80` |

### 身份与配置

| 变量 | 对应参数 | 说明与默认值 |
| --- | --- | --- |
| `AETHER_CONFIG` | `--config` | 基础身份配置路径，默认 `aether.toml`（当前目录） |
| `AETHER_WG_CONFIG` | `--wg-config` | WireGuard 身份配置路径 |
| `AETHER_MASQUE_CONFIG` | `--masque-config` | MASQUE 身份配置路径；gool 会额外生成 `<config>-secondary.toml` |
| `AETHER_REPROVISION` | — | 设 `0` 禁止自动替换被 Cloudflare 拒绝的身份 |
| `AETHER_PERF_PROFILE` | `--perf` | 强制资源档：`low`（路由器）/ `medium`（桌面）/ `high`（服务器），默认按 CPU/内存自检 |
| `AETHER_LOG_LEVEL` | `--log-level` / `--verbose` | `error`/`warn`/`info`（默认）/`debug`/`trace`；`RUST_LOG` 优先级更高 |
| `AETHER_ROUTES_FILE` | `--routes` | 分流规则文件路径（`[block]`/`[direct]` 两节） |
| `AETHER_ROUTE_BLOCK` / `AETHER_ROUTE_DIRECT` | `--route-block` / `--route-direct` | 直接给分流列表（逗号或换行分隔） |

### Zero Trust（企业 WARP）

| 变量 | 对应参数 | 说明 |
| --- | --- | --- |
| `AETHER_TEAM` | `--team` | Zero Trust 组织名 |
| `AETHER_ACCESS_CLIENT_ID` | `--access-id` | 服务令牌 Client ID（无头注册） |
| `AETHER_ACCESS_CLIENT_SECRET` | `--access-secret` | 服务令牌 Client Secret |
| `AETHER_ACCESS_EMAIL` | `--access-email` | 用邮箱接收一次性登录码注册 |
| `AETHER_ACCESS_TOKEN` | `--access-token` | 已获取的注册令牌（JWT） |
| `AETHER_GATEWAY` | `--gateway` | 设 `1` 让 HTTP/HTTPS 经过组织网关（会被记录日志，默认关） |

### Tor（需 `--features tor` 构建；Docker 镜像已含）

| 变量 | 对应参数 | 说明与默认值 |
| --- | --- | --- |
| `AETHER_TOR` | `--tor` / `--tor-reverse` / `--tor-only` | 取值 `chain`（隧道内跑 Tor）/ `reverse`（经 Tor 拨隧道）/ `only`（纯 Tor） |
| `AETHER_TOR_BIND` | `--tor-bind` | Tor 代理监听地址，默认 `127.0.0.1:1820` |
| `AETHER_TOR_DIR` | `--tor-dir` | Tor 目录缓存与状态路径，默认在身份文件旁 `<config>-tor` |
| `AETHER_TOR_BRIDGES` | `--tor-bridge` 等 | 网桥行，多条用 `;` 分隔；`auto` 强制用网桥，`off` 禁用网桥 |
| `AETHER_TOR_PT` | `--tor-pt` | 可插拔传输二进制路径，多条用 `;`；可写 `名称=路径` |
| `AETHER_TOR_PT_DIR` | `--tor-pt-dir` | 额外搜索传输二进制的目录，多条用 `;` |
| `AETHER_TOR_DIRECT_SECS` | — | 直连 Tor 尝试多久后才转网桥，默认 `75` |
| `AETHER_TOR_STALL_SECS` | — | 网桥无进展多久放弃，默认 `75` |
| `AETHER_TOR_BRIDGE_SECS` | — | 单个网桥的最长连接时限，默认 `360` |
| `AETHER_TOR_COUNTRY` | — | 向 bridgedb 请求指定国家/地区的网桥（如 `ir`） |
| `AETHER_TOR_CHECK` | — | Tor 连通性检测的 `host:port`，默认 `check.torproject.org:443` |
| `AETHER_TOR_LOG` | — | Tor 自身日志级别：`info`/`debug`/`trace` |

## 七、身份文件说明（aether.toml 与 aether-lastconn.toml）

运行后会在配置路径生成两个文件：

### `aether.toml` —— WARP 设备身份（核心，必须保管好）

向 Cloudflare 注册设备后保存的凭证，字段含义（对照源码 `config.rs`/`account.rs`）：

| 字段 | 含义 |
| --- | --- |
| `device_id` | Cloudflare 侧的设备 UUID |
| `access_token` | 设备访问令牌，用于调用账号 API 刷新/查询 |
| `cert_pem` / `key_pem` / `cert_issued_at` | MASQUE 模式的 mTLS 客户端证书（空 = 还没用过 MASQUE；首次走 MASQUE 自动签发，有效期 365 天，到期自动续） |
| `ipv4` / `ipv6` | Cloudflare 分配的隧道内地址（`172.16.0.2` 是 WARP 内网段习惯值） |
| `wg_private_key` | 本设备的 WireGuard 私钥（**敏感**） |
| `wg_peer_public_key` | Cloudflare WARP 服务端公钥，全网固定，所有设备相同 |
| `client_id` | 3 字节设备标识（base64），WARP 协议用于区分同账号设备 |
| `organization` / `gateway_proxy` | Zero Trust 组织名与组织网关地址；个人注册为空/默认值 |
| `assigned_endpoint` | 注册时服务端建议的边缘节点 IP，仅参考值；实际连哪个由扫描/`--peer` 决定 |

要点：

- **隐私文件**：含私钥和令牌，不要提交 git、不要分享（`.gitignore` 已排除）。
- **删掉 = 注册新设备**：频繁重注册会触发 Cloudflare 限流（403/429）。
- **可复制到其他机器**复用同一身份，免去重复注册；两台机器不要同时高频使用。
- 正常情况**不需要手动编辑**任何字段。

### `aether-lastconn.toml` —— 上次可用网关缓存（可随意删）

```toml
peer = "162.159.195.241:7156"   # 上次真正连通的边缘节点 ip:port
profile = "aggressive"          # 当时用的混淆档
```

下次启动时先询问是否直接重连该节点（只做一次存活检查，不重新扫描），失效则自动回退全量扫描。纯缓存，删除无副作用，只是下次启动多花一次扫描时间。`--quick-reconnect` 或 `AETHER_QUICK_RECONNECT=1` 可跳过询问。

### 身份 + 节点地址，缺一不可

```
身份（aether.toml）  +  节点地址（扫描发现 或 --peer 指定）
        ↓                        ↓
   "你是谁"（认证）         "连哪里"（寻址）
```

- **只有 IP 没有身份**：握手直接被拒——WireGuard 握手要用 `wg_private_key` 认证，MASQUE 要用设备证书做 mTLS，随便拿一个 Cloudflare IP 连不上。
- **只有身份没有 IP**：这正是默认状态——启动时自动扫描发现可用节点，平时连 IP 都不用指定。
- **两者都给**（最快路径）：

```bash
aether --config aether.toml --peer 162.159.195.241:7156 --quick-reconnect
```

`--peer` 固定节点适合网络环境稳定（如家用宽带）的场景——重连时先重试它而不是换扫描结果；网络多变则交给扫描更省心。

## 八、断线重连与常见问题

### 断线重连（自动）

- **自动重连**：隧道掉线后默认 2 秒重连（`--reconnect-secs` 可调）。
- **快速重连**：最近一次成功的网关记在 `*-lastconn.toml`，下次启动询问是否直接重连，跳过扫描；缓存网关失效则自动回退全量扫描。脚本场景用 `--quick-reconnect` 跳过询问。
- **坏节点冷却**：连续失败 2 次的节点 300 秒内不参与重扫（`AETHER_WG_ENDPOINT_COOLDOWN_SECS`）。

### 常见问题：curl 报 `Failed to connect to ... 1819`

启动后立刻测试代理报 `curl: (7) Failed to connect to www.cloudflare.com port 443 via 127.0.0.1:1819 ... Could not connect to server`，绝大多数情况是**扫描/验证尚未完成，SOCKS5 端口还没开始监听**，并非隧道故障。排查顺序：

1. 查看日志是否有 `[+] socks5 server listening on 127.0.0.1:1819`——没有就继续等；
2. 等待期间日志会持续输出节点探测进度（`[+] wg candidate ok ...` 或 MASQUE 对应日志），说明扫描正常进行中；
3. 端口已监听但仍不通时，看日志有无 `identity refused`（身份被 Cloudflare 拒绝：403 通常是当前网络地址被标记，可稍后重试或更换网络；Aether 会自动用新身份替换被拒身份，可用 `AETHER_REPROVISION=0` 关闭）或反复 `dataplane verify timed out`（节点质量差，换个扫描模式或重跑）。

### 其他关键能力

| 功能 | 用法 |
| --- | --- |
| Tor 出口 | `--tor`（隧道内跑 Tor，代理在 1820 端口），需 `cargo build --release --features tor`；Docker 镜像已内置 |
| Zero Trust 企业接入 | `--team <名称>` |
| 分流规则 | `--route-direct`/`--route-block`/`--routes 文件`（按域名/IP/端口分流） |
| 上游代理 | `--upstream socks5://127.0.0.1:1080`（先过本机已有代理再出网） |
| 完整文档 | 上游仓库 `Docs/GUIDE.en.md`、`Docs/DOCS.en.md` |

**一句话总结**：客户端跑起来（`./aether`）→ 得到 `127.0.0.1:1819` SOCKS5 代理 → 应用走这个代理即完成；无需自建服务端，隧道对端是 Cloudflare WARP。
