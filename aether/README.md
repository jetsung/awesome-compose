# Aether

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Aether][2] 是一个面向受限网络的加密隧道客户端：自动扫描发现可达的 Cloudflare WARP 边缘节点，建立加密隧道（MASQUE / WireGuard / WARP-in-WARP），并在本地暴露一个 SOCKS5 代理给应用程序使用。**纯客户端，无需自建服务端**。

[1]:https://cluvexstudio.github.io/aether/
[2]:https://github.com/cluvexstudio/aether
[3]:https://ghcr.io/cluvexstudio/aether
[4]:./docs.md

## 用法

```bash
docker compose up -d      # 启动（后台常驻）
docker compose logs -f    # 跟踪日志，等 socks5 server listening 再用代理
docker compose down       # 停止（数据卷保留，身份不丢）
```

验证：

```bash
curl -x socks5h://127.0.0.1:1819 https://www.cloudflare.com/cdn-cgi/trace
# 应显示 Cloudflare colo 和 warp=on
```

## 配置环境变量

配置写入本目录 `.env`（每个变量对应一个 aether 命令行参数，完整列表见 [docs.md][4]）：

```bash
# 传输协议 masque (default) | wg | gool | mim
#AETHER_PROTOCOL=masque
# 扫描模式 turbo | balanced (default) | thorough | stealth | ironclad
#AETHER_SCAN=balanced
# 扫描 IP 版本 v4 (default) | v6 | both
#AETHER_IP=v4
# 混淆档 off | light | firewall | balanced | aggressive
#AETHER_NOIZE=
# 固定节点 ip:port，跳过扫描（端口必填）
#AETHER_PEER=
```

## 注意

- **身份持久化**：身份文件在数据卷 `/data/aether.toml`，删掉 = 重新注册设备，频繁重注册会被 Cloudflare 限流。
- **端口安全**：SOCKS5 无认证，`compose.yaml` 中端口默认只发布到 `127.0.0.1`；共享局域网改为绑定 LAN IP，绝不要写 `1819:1819`（绑所有网卡，变成开放代理）。
- **启动等待**：扫描/验证完成前端口不监听，curl 报 `Failed to connect` 属正常，等日志出现 `socks5 server listening`。

详细说明（二进制安装、端口指定、68 个环境变量、身份文件字段、常见问题排查）见 **[docs.md][4]**。
