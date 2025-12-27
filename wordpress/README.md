# WordPress

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [WordPress][1] 是一个基于 PHP 和 MySQL 的开源内容管理系统，用于创建网站和博客。它具有高度的灵活性和可扩展性，通过插件和主题可以实现各种功能和外观定制。

[1]:https://wordpress.org/
[2]:https://github.com/WordPress/WordPress
[3]:https://hub.docker.com/_/wordpress
[4]:https://wordpress.org/documentation/

---

## 文档

### NGINX 反向代理

- `www.domain.com.conf`
```nginx
server {
    listen 80;
    listen [::]:80;

    server_name www.domain.com domain.com;

    # 若是 http 则跳转至 https；若不需要跳转，则删除 if 语段即可。
    set $to_https 0;
    if ($scheme = "http") {
        set $to_https 1;
    }

    include wildcard/domain.com.conf;

    # Logs
    access_log /data/wwwlogs/www.domain.com.log;
    error_log /data/wwwlogs/www.domain.com.error.log warn;

    charset utf-8;

    # Proxy to WordPress
    location / {
        proxy_pass http://127.0.0.1:39007;  # Update to match SERV_PORT
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;  # Critical for HTTPS
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
    }
}
```

- `domain.com.conf`
```nginx
# 监听 IPv4 和 IPv6 的 443 端口，启用 SSL
listen 443 ssl;
listen [::]:443 ssl;
http2 on;

# 指定 SSL 证书和私钥的位置
ssl_certificate /srv/acme/ssl/domain.com.fullchain.cer;
ssl_certificate_key /srv/acme/ssl/domain.com.key;

# 仅启用 TLSv1.3
ssl_protocols TLSv1.3;

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

### 数据库操作
省略 `--databases` 仅导出表和数据，而不导出数据库创建语句。
1. 从本机导出数据库
```bash
mysqldump -u <username> -p<password> --databases <database_name> > backup.sql
```

2. 将数据库导入到容器中的 MySQL 数据库
```bash
docker exec -i wordpress-db-1 mysql -uexampleuser -pexamplepass wordpress < backup.sql
```

若导出的数据库名与容器中的数据库名不一致，可使用以下命令：
```bash
sed -i 's/exported_wordpress/wordpress/g' backup.sql
```

### 迁移插件与主题
```bash
cp -r /path/to/wordpress/wp-content/plugins ./data/wordpress/wp-content/plugins
cp -r /path/to/wordpress/wp-content/themes ./data/wordpress/wp-content/themes
```

### 主题
- [Puock](https://github.com/Licoy/wordpress-theme-puock)
```bash
  # 缩略图（NGINX 配置）
  rewrite ^/timthumb/w_([0-9]+)/h_([0-9]+)/q_([0-9]+)/zc_([0-9])/a_([a-z]+)/([0-9A-Za-z_\-]+)\.([0-9a-z]+)$ /wp-content/themes/puock/timthumb.php?w=$1&h=$2&q=$3&zc=$4&a=$5&src=$6;
```

### 备份
定时备份数据库
```bash
# 每天凌晨 0 点执行备份
0 0 * * * docker exec -i wordpress-db-1 mysqldump -uexampleuser -pexamplepass --databases wordpress > wordpress.sql
```
或者直接调用本地的脚本
```bash
# 每天凌晨 0 点执行备份
0 0 * * * /path/to/backup.sh
```

### 通过 Rest API 发布文章

1. 添加用户 robot，角色选择“作者（Author）”。
2. 为 robot 用户生成一个 API 密钥。
3. 将上述密钥添加到 [Python 脚本 `publish.py`](publish.py)对应的配置信息。
4. 执行脚本
```bash
python publish.py
```
