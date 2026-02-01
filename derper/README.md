# Derper

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Derper][1] （指定数据包加密中继）服务器负责管理设备连接和网络地址转换（NAT）穿越。它们主要有两个作用：
> - 协商并建立尾网（tailnet）设备之间的连接（直接连接或中继连接）。
> - 当无法建立直接连接且对等中继服务器不可用时，作为备用选项。

[1]:https://tailscale.com/kb/1232/derp-servers
[2]:https://github.com/tailscale/tailscale/tree/main/cmd/derper
[3]:https://github.com/kaaanata/derper-docker/pkgs/container/derper
[4]:https://github.com/kaaanata/derper-docker

---

> 必需：将环境变量 `DERP_DOMAIN` 设置为你的域名

```bash
docker run -e DERP_DOMAIN=derper.your-domain.com -p 80:80 -p 443:443 -p 3478:3478/udp ghcr.io/kaaanata/derper
```

| 环境变量                    | 是否必需 | 描述                                                                 | 默认值     |
| -------------------        | -------- | ----------------------------------------------------------------------| ----------------- |
| DERP_DOMAIN            | 是     | Derper 服务器主机名                                                      | your-hostname.com |
| DERP_CERT_DIR          | 否     | 存储 Let's Encrypt 证书的目录（如果地址端口是 :443）                | /app/certs        |
| DERP_CERT_MODE         | 否     | 获取证书的模式。可能的选项：manual（手动）, letsencrypt（Let's Encrypt 自动获取）| letsencrypt       |
| DERP_ADDR              | 否     | 监听服务器地址。中转端口                                                    | :443              |
| DERP_STUN              | 否     | 同时运行一个 STUN 服务器                                                      | true              |
| DERP_STUN_PORT         | 否     | 用于提供 STUN 服务的 UDP 端口。**STUN 打洞端口**                            | 3478              |
| DERP_HTTP_PORT         | 否     | 用于提供 HTTP 服务的端口。设置为 -1 可禁用                       | 80                |
| DERP_VERIFY_CLIENTS    | 否     | 通过本地运行的 Tailscale 实例验证连接到该 DERP 服务器的客户端。**验证客户端身份，防止白嫖**  | false             |
| DERP_VERIFY_CLIENT_URL | 否     | 如果非空，这是一个准入控制器 URL，用于允许客户端连接 | ""                |

# 使用方法

完整的 Derper 设置官方文档：https://tailscale.com/kb/1118/custom-derp-servers/

## 客户端验证

为了使用 `DERP_VERIFY_CLIENTS`，容器需要访问 Tailscale 的本地 API，通常可通过 `/var/run/tailscale/tailscaled.sock` 进行访问。如果你在 Linux 裸机上运行 Tailscale，将以下内容添加到 `docker run` 命令中通常就足够了：`-v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock`
