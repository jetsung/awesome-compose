# acme.sh

## 手动添加

- https://github.com/acmesh-official/acme.sh/wiki/dns-manual-mode

```bash
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

## [更多教程](https://www.jetsung.com/d/525)
