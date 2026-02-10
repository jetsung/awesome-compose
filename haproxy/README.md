# HAProxy

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [HAProxy][1] 是一款免费、非常快速且可靠的反向代理，为基于 TCP 和 HTTP 的应用提供高可用性 、 负载均衡和代理服务。

[1]:https://www.haproxy.org/
[2]:https://github.com/haproxy/haproxy
[3]:https://hub.docker.com/_/haproxy
[4]:https://docs.haproxy.org/

---

## 使用教程

本教程参考自项目内的基础配置，涵盖了从基础 HTTP 到复杂反代场景的配置说明。

### 1. 基础教程：绑定 80 端口（默认站）

这是最简化的配置，适合作为入门。它将所有 80 端口的流量转发到后端的 Web 服务。

```config
global
    log stdout format raw local0 info
    maxconn 4096

defaults
    log     global
    mode    http                        # 七层负载均衡模式
    option  httplog
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend http-in
    bind *:80
    default_backend webservers

backend webservers
    balance roundrobin                  # 轮询算法
    # 健康检查：发送 HEAD 请求
    http-check connect
    http-check send meth HEAD uri / ver HTTP/1.1 hdr Host localhost
    http-check expect status 200,301,302

    # 定义后端服务器
    server web1 web1:80 check inter 5s rise 2 fall 3
    server web2 web2:80 check inter 5s rise 2 fall 3
```

---

### 2. 添加 443 证书支持（Let's Encrypt）

HAProxy 处理 HTTPS 需要将证书和私钥合并为一个 `.pem` 文件。

#### 证书准备 (合并证书)
如果你使用 Let's Encrypt (Certbot/acme.sh)，你会得到 `fullchain.cer` 和 `private.key`。需要合并它们：
```bash
cat "example.com.fullchain.cer" "example.com.key" > "/etc/haproxy/certs/example.com.pem"
```

#### 配置更新
```config
frontend http-in
    bind *:80
    # 强制将所有特定域名的 HTTP 流量跳转到 HTTPS
    acl is_dash hdr(host) -i dash.4.fx4.cn
    http-request redirect scheme https code 301 if is_dash

frontend https-in
    # crt 后面可以指定具体的 pem 文件，也可以指定目录（自动根据域名匹配 SNI）
    bind *:443 ssl crt /etc/haproxy/certs/
    mode http

    # 统计页面
    stats uri /stats
    stats enable
    stats auth admin:admin888
    stats refresh 10s
    stats show-legends

    default_backend webservers
```

---

### 3. 添加一个 API 服务

通常 API 服务通过独立域名（如 `api.example.com`）或路径来区分。

```config
frontend https-in
    bind *:443 ssl crt /etc/haproxy/certs/

    # 定义 ACL 匹配规则
    acl host_api hdr(host) -i api.example.com

    # 分发到不同的后端
    use_backend api_backend if host_api
    default_backend webservers

backend api_backend
    balance roundrobin
    server api_srv1 arcane:3552 check
```

---

### 4. 添加 WebSocket 支持

WebSocket 是长连接，需要配置 `timeout tunnel`，否则连接会在默认的超时到期后断开。

```config
defaults
    # ... 其他配置 ...
    timeout tunnel 1h  # WebSocket 关键配置：建议设为 1h 或更大

backend arcane_backend
    balance roundrobin
    mode http

    # 确保后端感知原始 Host
    http-request set-header Host %[req.hdr(Host)]

    # 也可以在 backend 独立设置超时
    timeout tunnel 1h
    timeout client 1h
    timeout server 1h

    server arcane arcane:3552 check inter 5s rise 2 fall 3
```

---

### 5. 反代到 Nginx（8080 端口，多域名）

当 HAProxy 作为入口，后端是 Nginx 且有多个域名时，必须透传 `Host` 头。

```config
frontend https-in
    bind *:443 ssl crt /etc/haproxy/certs/

    # 定义多个域名的 ACL
    acl host_site1 hdr(host) -i site1.4.fx4.cn
    acl host_site2 hdr(host) -i site2.4.fx4.cn

    use_backend nginx_backend if host_site1 || host_site2

backend nginx_backend
    balance roundrobin

    # 【关键】保留原始 Host 头以避免 Nginx 虚拟主机识别出错
    http-request set-header Host %[req.hdr(Host)]

    # 反代到 Nginx 服务
    server nginx_srv nginx:8080 check inter 5s rise 2 fall 3
```

---

## 脚本管理 (deploy.sh)

项目提供了一个 `deploy.sh` 脚本，用于自动化管理域名配置、证书合并以及服务重启。

### 1. 环境准备

在 `.env` 文件中配置证书路径：

```bash
# 证书来源目录（包含 .key 和 .fullchain.cer）
SOURCE_DIR=/path/to/your/certificates
# PEM 存储目录（HAProxy 使用）
DEST_DIR=./certs
```

### 2. 常用操作

#### 添加域名
自动在 `haproxy.cfg` 中添加 ACL、重定向规则，并重载服务：
```bash
./deploy.sh example.com
```
*加上 `-g` 参数可同时触发证书合并：`./deploy.sh example.com -g`*

#### 删除域名
从配置文件中移除相关 ACL 规则：
```bash
./deploy.sh example.com -a rm
```

#### 证书维护 (SSL)
将 `SOURCE_DIR` 下的所有证书合并为 HAProxy 所需的 `.pem` 格式（`fullchain.cer` + `key`）：
```bash
./deploy.sh -a ssl
```

#### 服务管理
*   **重载配置 (不宕机)**：`./deploy.sh -a reload`
*   **启动容器**：`./deploy.sh -a up`
*   **停止容器**：`./deploy.sh -a down`

### 3. 证书合并逻辑
脚本会扫描 `SOURCE_DIR` 下的 `.key` 文件，寻找匹配的 `.fullchain.cer`，合并后输出到 `DEST_DIR`。
例如：`domain.com.key` + `domain.com.fullchain.cer` -> `domain.com.pem`
