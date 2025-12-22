# acme.sh

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [acme.sh][1] 是一个纯用 Shell（Unix shell）语言编写的 ACME 协议客户端。
- 完整实现了 ACME 协议。
- 支持 ECDSA 证书。
- 支持 SAN 和通配符证书。
- 简单、强大且非常易于使用。你只需要 3 分钟就能学会。
- 兼容 Bash、dash 和 sh。
- 完全用 Shell 编写，不依赖 Python。
- 只需一个脚本即可自动签发、续期和安装你的证书。
- 不需要 root 或 sudo 权限。
- 支持 Docker。
- 支持 IPv6。
- 支持通过 cron 任务发送续期或错误通知。

[1]:https://github.com/acmesh-official/acme.sh
[2]:https://github.com/acmesh-official/acme.sh
[3]:https://hub.docker.com/r/neilpang/acme.sh
[4]:https://github.com/acmesh-official/acme.sh/wiki

## 使用教程

1. 一键下载本源码
```bash
# 推荐
# mkdir acme && cd $_
curl -fsSL https://fx4.cn/acme | bash

# 或
git clone https://framagit.org/jetsung/awesome-compose
cp -r awesome-compose/acme .
# cd acme
```

2. [设置 API 密钥](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)
```bash
# Cloudflare: dns_cf
export CF_Key="<api_key>"
export CF_Email="<email>"

# DNSPod.cn: dns_dp
export DP_Id="<id>"
export DP_Key="<key>"

# Aliyun: dns_ali
export Ali_Key="<key>"
export Ali_Secret="<secret>"

# DNSPod.com: dns_dpi
export DPI_Id="<id>"
export DPI_Key="<key>"

# TencentCloud: dns_tencent
export Tencent_SecretId="<Your SecretId>"
export Tencent_SecretKey="<Your SecretKey>"

# GCore
export GCORE_Key="<key>"

...
```

3. 先运行容器
```bash
docker compose up -d
```

4. 设置证书平台
```bash
# 切换 CA 为 Let's Encrypt，若曾有注册过，可跳过
./deploy.sh -a ca -s letsencrypt

# 或
# 切换 CA 为 Let's Encrypt，并设置邮箱
./deploy.sh -a ca -s letsencrypt -e me@example.com

# google
# zerossl
# letsencrypt
```

5. 签发证书并且部署
```bash
# 申请证书
./deploy.sh -a is -d example.com

# 或通过 challenge 别名验证（推荐，方便统一校验。比如多个域名的 NS 在不同的平台）
# 先将  _acme-challenge.example.com CNAME 记录到 _acme-challenge.challenge.com
./deploy.sh -a is -d example.com -ch challenge.com
```

5.2 续签证书并且部署
```bash
# 或 更新全部域名证书
./deploy.sh -a ne

# 续签证书
./deploy.sh -a ne -d example.com

# 强制更新证书
./deploy.sh -a ne -d example.com -fo
```

6. 安装定时任务
```bash
# 安装定时任务
./deploy.sh -a cr --setup

# 安装定时任务并指定证书路径。默认路径为 ${PWD}/data/ssl
./deploy.sh -a cr --setup --path /usr/local/nginx/conf/ssl
```

5. 执行定时任务
```bash
# 执行定时任务更新服务器与证书
./deploy.sh -a cr
```

6. 查看证书
```bash
# 查看证书
ls "${PWD}/data/ssl"
```

### 部署到 Nginx
以下以域名 `example.com` 为例

- **泛域名证书配置（多个次级域名共用）**
泛域名通用配置位于 `/usr/local/nginx/conf/wildcard/example.com.conf`
域名证书目录位于 `/usr/local/nginx/conf/ssl`
```bash
include extend/ssl.conf;

# 指定 SSL 证书和私钥的位置
ssl_certificate ssl/example.com.fullchain.cer;
ssl_certificate_key ssl/example.com.key;
```

- **通用 SSL 信息配置**
> SSL 通用配置文件位于 `/usr/local/nginx/conf/extend/ssl.conf`
>
```bash
#listen [::]:443 ssl ipv6only=off reuseport;
#listen [::]:443 quic reuseport ipv6only=off;

listen 443 ssl;
listen 443 quic;
listen [::]:443 ssl;
listen [::]:443 quic;

# 监听 IPv4 和 IPv6 的 443 端口，启用 SSL
http2 on;

# 仅启用 TLSv1.3
ssl_protocols TLSv1.2 TLSv1.3;

# 默认密码套件
ssl_ciphers DEFAULT;

# 优先使用服务器指定的密码套件
ssl_prefer_server_ciphers on;

# 启用 SSL 会话缓存，提高性能
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# 设置 SSL 缓冲区大小，优化性能
ssl_buffer_size 1400;

# 设置 HSTS 头部，强制客户端使用 HTTPS
add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload";

# 启用 OCSP  stapling，提高证书验证效率
ssl_stapling off;
ssl_stapling_verify off;

# 错误页重定向，HTTP 1.1 协议的 401 Unauthorized 状态码已被废弃，使用 403 Forbidden
error_page 403 https://$host$request_uri;

# HTTP 到 HTTPS 重定向
if ($to_https = 1) {
    return 301 https://$host$request_uri;
}
```

- **Nginx 域名配置**
> 域名配置文件位于 `/usr/local/nginx/conf/vhost/hello.example.com.conf`
```bash
server {
    listen 80;
    listen [::]:80;

    server_name hello.example.com;

    set $to_https 0;
    if ($scheme = "http") {
        set $to_https 1;
    }

    include wildcard/example.com.conf;
    # 或者 真实路径
    # include /usr/local/nginx/conf/ssl/example.com.conf;

    index  index.html index.htm;
    root   /etc/nginx/html;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy
    location / {
        proxy_pass   http://127.0.0.1:8080;

        client_max_body_size  1024m;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Real-Ip $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 99999;

        # websocket
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

- **使用 acme.sh 签发与续签 SSL 证书配置（无状态模式）**
> 配置文件于 `/usr/local/nginx/conf/extend/acme_stateless.conf`
> 配合 acme.sh 直接签发和[续签 SSL 证书](https://github.com/acmesh-official/acme.sh/wiki/Stateless-Mode)
配置方法：
1. 首先获取你的账户密钥指纹：
```bash
root@ed:~# acme.sh --register-account
[Mon Feb  6 21:40:18 CST 2017] Registering account
[Mon Feb  6 21:40:19 CST 2017] Already registered
[Mon Feb  6 21:40:21 CST 2017] Update success.
[Mon Feb  6 21:40:21 CST 2017] ACCOUNT_THUMBPRINT='6fXAG9VyG0IahirPEU2ZerUtItW2DHzDzD9wZaEKpqd'
```
2. `acme_stateless.conf` 配置文件的文本如下：
```bash
location ~ ^/\.well-known/acme-challenge/([-_a-zA-Z0-9]+)$ {
    default_type text/plain;
    return 200 "$1.6fXAG9VyG0IahirPEU2ZerUtItW2DHzDzD9wZaEKpqd";
}
```
3. 在对应域名 `server` 配置中添加以下内容，添加至上述的 `hello.example.com.conf`：
```bash
include extend/acme_stateless.conf;
```
4. 签发证书
```bash
acme.sh --issue -d hello.example.com  --stateless
```

## 官方教程

- https://github.com/acmesh-official/acme.sh/wiki/dns-manual-mode

```sh
# 切换 CA 为 Let's Encrypt
docker exec acme.sh acme.sh --set-default-ca --server letsencrypt

# 注册
docker exec acme.sh --register-account -m my@example.com

# 生成 txt 值
docker exec acme.sh --issue --dns --keylength ec-256 --ecc --force --yes-I-know-dns-manual-mode-enough-go-ahead-please -d xx.com -d *.xx.com

# 将上述值保存到 txt 记录，并执行
docker exec acme.sh --renew --dns --keylength ec-256 --ecc --force --yes-I-know-dns-manual-mode-enough-go-ahead-please -d xx.com -d *.xx.com

# 安装到指定目录 [deploy](deploy.sh)
docker exec acme.sh --install-cert --ecc --key-file /data/ssl/xx.com.key --fullchain-file /data/ssl/xx.com.fullchain.cer -d xx.com

# 设置通知
docker exec acme.sh --set-notify --notify-hook feishu --notify-hook gotify
```

### [Google Public CA](https://cloud.google.com/certificate-manager/docs/public-ca-tutorial?hl=zh-cn)
1. [GCP 控制台面板](https://console.cloud.google.com/apis/library/publicca.googleapis.com)
   ```bash
	gcloud services enable publicca.googleapis.com
	```

2. 创建项目
   ```bash
   # 若项目不存在
	gcloud projects create [project ID]

	gcloud config set project [project ID]
   ```

3. 获取 EAB 密钥 ID 和 HMAC
	```bash
	gcloud publicca external-account-keys create
	```

4. 生成
   ```bash
    Created an external account key
    [b64MacKey: xxxxxxxxxxxxxxxxxxxxxxx eab-kid
    keyId: xxxxxxxxxxxxxxx] eab-hmac-key
   ```

## [更多文档说明](https://forum.idev.top/d/525)
