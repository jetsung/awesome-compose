# Tailscale

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Tailscale][1] 是一个零信任基于身份的连接平台，取代了您的遗留 VPN、SASE 和 PAM，连接远程团队、多云环境、CI/CD 流水线、边缘与物联网设备以及 AI 工作负载。

[1]:https://tailscale.com/
[2]:https://github.com/tailscale/tailscale
[3]:https://hub.docker.com/r/tailscale/tailscale
[4]:https://tailscale.com/kb/1282/docker

---

## 使用
## 环境变量 [`.env`](https://tailscale.com/kb/1282/docker#parameters)
> [**更多参数**](PARAMETERS.md)

- 设置密钥 `TS_AUTHKEY`
```bash
# 使用 Headscale 通过命令行生成
docker exec -it headscale headscale preauthkeys create --user 1 --reusable --expiration 90d
```

- 设置主机名，用于区别服务器 `TS_HOSTNAME`
```bash
docker exec -it tailscale tailscale set --hostname=XXX
```

- 设置参数 [`TS_EXTRA_ARGS`](https://tailscale.com/kb/1282/docker#ts_extra_args) 值（[自定义服务器](https://tailscale.com/kb/1080/cli)）
```bash
TS_EXTRA_ARGS=--login-server=https://myheadscale.example.com --accept-routes

# 使用 Derper
TS_EXTRA_ARGS=--derpmap=https://derp.yourdomain.com/derp
```

## [CLI 参数](https://tailscale.com/kb/1080/cli)

- 官方文档：https://tailscale.com/kb/1080/cli
- 本站翻译文档：[CLI.md](CLI.md)

## 常见问题
- 提升性能
  > TS_USERSPACE=false + kernel tun 模式延迟更低、吞吐更高（需 /dev/net/tun 和 NET_ADMIN cap）。
