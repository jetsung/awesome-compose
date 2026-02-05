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
```

## [CLI 参数](https://tailscale.com/kb/1080/cli)

- 官方文档：https://tailscale.com/kb/1080/cli
- 本站翻译文档：[CLI.md](CLI.md)

## 配置

### 跨服务器配置联网
**需求：** A1,B1,C1(tailscale) 与 A2,B2,C2(tailscale) 之间联网
1. 创建共享网络
```bash
docker network create sharenet
```
2. 所有服务（A1,B1,C1,A2,B2,C2）都需要设置
```yaml
services:
  myserve:
    ...
    networks:
      sharenet:

networks:
  sharenet:  
    external: true  
```

3. 使用 HAProxy 作为反代
```yaml
---
# https://hub.docker.com/_/haproxy
services:
  haproxy:
    depends_on:
      - tailscale
    # user: 0:0 # 容器中调试安装依赖使用
    container_name: haproxy
    image: haproxy:alpine
    restart: unless-stopped
    volumes:
      - ./config:/usr/local/etc/haproxy:ro
    network_mode: service:tailscale
```
配置文件 `config/haproxy.cfg`
<details>
<summary>点击查看</summary>

```bash
###########################################
# 全局设置
###########################################
global
    log stdout format raw local0 info          # 日志输出到 stdout
    maxconn 4096                               # 最大并发连接数
    master-worker                              # 支持平滑 reload

###########################################
# 默认设置
###########################################
defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5s
    timeout client  50s
    timeout server  50s
    timeout tunnel 1h                          # 支持 WebSocket 长连接

###########################################
# HTTP 入口：80 端口
###########################################
frontend http-in
    bind *:80
    mode http

    # 统计页面
    stats uri /stats
    stats enable
    stats auth admin:admin888
    stats refresh 10s
    stats show-legends

    # 默认 ACL（脚本 deploy.sh 会在此后插入新规则）
    acl is_default hdr(host) -i localhost

    # HTTP 到 HTTPS 跳转（脚本 deploy.sh 会在此后插入新规则）
    # http-request redirect scheme https code 301 if is_default

    # 默认转发到 nginx 后端
    default_backend nginx_backend

###########################################
# HTTPS 入口：443 端口
###########################################
frontend https-in
    bind *:443 ssl crt /etc/haproxy/certs/
    mode http

    # 默认 ACL（脚本 deploy.sh 会在此后插入新规则）
    acl host_default hdr(host) -i localhost

    # 路由转发
    use_backend nginx_backend if host_default

    # 默认拒绝其他请求
    http-request deny if !host_default

###########################################
# 后端：Nginx 服务
###########################################
backend nginx_backend
    balance roundrobin
    http-check connect
    http-check send meth HEAD uri / ver HTTP/1.1
    http-check expect rstatus (2|3)[0-9][0-9]

    # 保留原始 Host 头
    http-request set-header Host %[req.hdr(Host)]

    # nginx 容器服务
    server nginx_srv nginx:8080 check inter 5s rise 2 fall 3

###########################################
# 后端：API 服务（反代到其它端口）
###########################################
backend api_backend
    balance roundrobin
    http-check connect
    http-check send meth HEAD uri / ver HTTP/1.1
    http-check expect rstatus (2|3)[0-9][0-9]

    # 保留原始 Host 头
    http-request set-header Host %[req.hdr(Host)]

    # API 服务
    server api_srv host.docker.internal:9120 check inter 5s rise 2 fall 3

###########################################
# 前端规则示例：转发到 API 后端
# 可以通过 ACL 匹配 Host 或 Path
###########################################
# frontend http-in 中可加：
# acl host_api hdr(host) -i api.example.com
# use_backend api_backend if host_api
```

</details>

4. 反代之后，其它服务器可以访问其它服务器的 IP + 端口识别入口网站，或者其它服务器的 IP + Host（域名）识别。

5. 每个 tailscale 可以配置一个 haproxy 服务，以方便管理。亦或者，只需要其中一个 tailscale 服务接入，再通过配置文件 `haproxy.cfg` 设置即可。


### 扩展配置：
1. 建议在 `tailscale` 服务中添加该宿主机的服务
```diff
services:
  tailscale:
    extra_hosts:
+     - "host.docker.internal:host-gateway"  
```

2. 绑定域名到其它服务器
```diff
services:
  tailscale:
    extra_hosts:
 +    - "api.example.com:100.64.0.9"
```

IP 通过下述命令获取：
```bash
docker exec tailscale tailscale status
```

设置环境变量
```bash
TS_ACCEPT_DNS=true
```
设置此环境变量后，可以通过 hostname 方式访问
```bash
curl host1

# 指定域名
curl host1 -H "Host: api.example.com"
```

## 常见问题
- 提升性能
  > TS_USERSPACE=false + kernel tun 模式延迟更低、吞吐更高（需 /dev/net/tun 和 NET_ADMIN cap）。
