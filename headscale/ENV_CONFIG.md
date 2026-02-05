- https://github.com/juanfont/headscale/blob/main/integration/hsic/config.go#L24

```bash
# 日志级别，可选：debug / info / warn / error / trace
HEADSCALE_LOG_LEVEL=trace

# 自定义策略文件路径（ACL 配置），留空表示默认
HEADSCALE_POLICY_PATH=

# 数据库类型，可选：sqlite / postgres / mysql
HEADSCALE_DATABASE_TYPE=sqlite

# SQLite 数据库文件路径（仅 sqlite 时有效）
HEADSCALE_DATABASE_SQLITE_PATH=/tmp/integration_test_db.sqlite3

# 数据库调试开关，0=关闭，1=开启
HEADSCALE_DATABASE_DEBUG=0

# GORM 慢查询阈值（秒），超过该值会记录慢查询
HEADSCALE_DATABASE_GORM_SLOW_THRESHOLD=1

# 临时节点（Ephemeral Node）闲置超时时间，超过该时间节点将被移除
HEADSCALE_EPHEMERAL_NODE_INACTIVITY_TIMEOUT=30m

# 分配给 Headscale / Tailscale 节点的 IPv4 网段（通常是 100.64.0.0/10）
HEADSCALE_PREFIXES_V4=100.64.0.0/10

# 分配给 Headscale / Tailscale 节点的 IPv6 网段
HEADSCALE_PREFIXES_V6=fd7a:115c:a1e0::/48

# MagicDNS 的基础域名（所有节点 hostname 将解析到此域名下）
HEADSCALE_DNS_BASE_DOMAIN=headscale.net

# 是否启用 MagicDNS（自动解析节点 hostname）
HEADSCALE_DNS_MAGIC_DNS=true

# 是否覆盖本地 DNS，false 表示本地 DNS 请求仍会正常解析
HEADSCALE_DNS_OVERRIDE_LOCAL_DNS=false

# 全局 DNS 服务器列表（空格分隔）
HEADSCALE_DNS_NAMESERVERS_GLOBAL=127.0.0.11 1.1.1.1

# Headscale 私钥路径（节点身份签名用）
HEADSCALE_PRIVATE_KEY_PATH=/tmp/private.key

# Noise 私钥路径（WireGuard 握手加密用）
HEADSCALE_NOISE_PRIVATE_KEY_PATH=/tmp/noise_private.key

# Prometheus 兼容的 metrics 监听地址
HEADSCALE_METRICS_LISTEN_ADDR=0.0.0.0:9090

# DERP 服务器 URL，用于跨 NAT / 公网节点中继
HEADSCALE_DERP_URLS=https://controlplane.tailscale.com/derpmap/default

# 是否允许自动更新 DERP 地图
HEADSCALE_DERP_AUTO_UPDATE_ENABLED=false

# DERP 自动更新频率（仅在自动更新开启时有效）
HEADSCALE_DERP_UPDATE_FREQUENCY=1m

# Debug 端口，用于调试和诊断
HEADSCALE_DEBUG_PORT=40000

# 分配节点 IP 的方式，可选：sequential（顺序）、random（随机）
HEADSCALE_PREFIXES_ALLOCATION=sequential
```
