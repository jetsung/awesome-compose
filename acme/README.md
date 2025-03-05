# acme.sh

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

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
curl -fsSL https://s.asfd.cn/a792ec34 | bash

# 或
git clone https://framagit.org/jetsung/docker-compose
cp -r docker-compose/acme .
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
```

5. 签发证书并且部署
```bash
# 申请证书
./deploy.sh -a is -d example.com

# 或通过 challenge 别名验证（推荐，方便统一校验。比如多个域名的 NS 在不同的平台）
# 先将  _acme-challenge.example.com CNAME 记录到 _acme-challenge.challenge.com
./deploy.sh -a is -d example.com -ch challenge.com
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
```

## [更多文档说明](https://forum.idev.top/d/525)
