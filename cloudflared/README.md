# cloudflared

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [cloudflared][1] 是 Cloudflare 隧道客户端。将 Cloudflare 网络的流量代理到你的起源节点。

[1]:https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/cloudflared-parameters/
[2]:https://github.com/cloudflare/cloudflared
[3]:https://hub.docker.com/r/cloudflare/cloudflared
[4]:https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/cloudflared-parameters/run-parameters/

---

## 配置环境变量
```bash
# 日志保存文件
TUNNEL_LOGFILE=
# 日志等级 debug, info (default), warn, error, and fatal.
TUNNEL_LOGLEVEL=
# 禁用自动更新
# NO_AUTOUPDATE=true
# 密钥
TUNNEL_TOKEN=
# 密钥文件
# TUNNEL_TOKEN_FILE=
```

## 构建（使用 `alpine` 作为底座）
```dockerfile
FROM cloudflare/cloudflared:latest AS builder

FROM alpine:latest

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

COPY --from=builder /usr/local/bin/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT ["cloudflared", "--no-autoupdate"]

CMD ["version"]
```

基于 cloudflare/cloudflared:latest 构建对应的 alpine 为基础的镜像。
```bash
docker build -t cloudflared .
```
