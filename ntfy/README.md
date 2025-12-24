# ntfy

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [ntfy][1] 是一个简单的基于 HTTP 的发布-订阅 通知服务。使用 ntfy，您可以通过任何计算机的**脚本将通知发送到您的手机或桌面 ， 无需注册或支付任何费用**。如果您想运行自己的服务实例，可以轻松实现，因为 ntfy 是开源的。

[1]:https://ntfy.sh/
[2]:https://github.com/binwiederhier/ntfy
[3]:https://hub.docker.com/r/binwiederhier/ntfy
[4]:https://docs.ntfy.sh/

---

## APP（源码）
- Android: https://github.com/binwiederhier/ntfy-android
- iOS: https://github.com/binwiederhier/ntfy-ios

## [配置](https://docs.ntfy.sh/config/)

- [Docker Compose](https://docs.ntfy.sh/config/#__tabbed_2_1) (w/ auth, cache, attachments)
```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    restart: unless-stopped
    environment:
      NTFY_BASE_URL: http://ntfy.example.com
      NTFY_CACHE_FILE: /var/lib/ntfy/cache.db
      NTFY_AUTH_FILE: /var/lib/ntfy/auth.db
      NTFY_AUTH_DEFAULT_ACCESS: deny-all
      NTFY_AUTH_USERS: 'phil:$$2a$$10$$YLiO8U21sX1uhZamTLJXHuxgVC0Z/GKISibrKCLohPgtG7yIxSk4C:admin' # Must escape '$' as '$$'
      NTFY_BEHIND_PROXY: true
      NTFY_ATTACHMENT_CACHE_DIR: /var/lib/ntfy/attachments
      NTFY_ENABLE_LOGIN: true
    volumes:
      - ./:/var/lib/ntfy
    ports:
      - 80:80
    command: serve
```

- [Docker Compose](https://docs.ntfy.sh/config/#__tabbed_2_2) (w/ auth, cache, web push, iOS)
```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    restart: unless-stopped
    environment:
      NTFY_BASE_URL: http://ntfy.example.com
      NTFY_CACHE_FILE: /var/lib/ntfy/cache.db
      NTFY_AUTH_FILE: /var/lib/ntfy/auth.db
      NTFY_AUTH_DEFAULT_ACCESS: deny-all
      NTFY_BEHIND_PROXY: true
      NTFY_ATTACHMENT_CACHE_DIR: /var/lib/ntfy/attachments
      NTFY_ENABLE_LOGIN: true
      NTFY_UPSTREAM_BASE_URL: https://ntfy.sh
      NTFY_WEB_PUSH_PUBLIC_KEY: <public_key>
      NTFY_WEB_PUSH_PRIVATE_KEY: <private_key>
      NTFY_WEB_PUSH_FILE: /var/lib/ntfy/webpush.db
      NTFY_WEB_PUSH_EMAIL_ADDRESS: <email>
    volumes:
      - ./:/var/lib/ntfy
    ports:
      - 8093:80
    command: serve
```

[配置选项说明](https://docs.ntfy.sh/config/#config-options)：
- `NTFY_BASE_URL`：ntfy 服务的基础 URL。
- `NTFY_CACHE_FILE`：缓存文件的路径。
- `NTFY_AUTH_FILE`：认证文件的路径。
- `NTFY_AUTH_DEFAULT_ACCESS`：默认访问权限。
- `NTFY_BEHIND_PROXY`：是否在代理后面运行。
- `NTFY_ATTACHMENT_CACHE_DIR`：附件缓存目录的路径。
- `NTFY_ENABLE_LOGIN`：是否启用登录。
- `NTFY_UPSTREAM_BASE_URL`：上游 ntfy 服务的基础 URL。
- `NTFY_WEB_PUSH_PUBLIC_KEY`：Web Push 公钥。
- `NTFY_WEB_PUSH_PRIVATE_KEY`：Web Push 私钥。
- `NTFY_WEB_PUSH_FILE`：Web Push 文件的路径。
- `NTFY_WEB_PUSH_EMAIL_ADDRESS`：Web Push 邮箱地址。

[反向代理设置](https://docs.ntfy.sh/config/#__tabbed_11_2)
```nginx
# /etc/nginx/sites-*/ntfy
#
# This config requires the use of the -L flag in curl to redirect to HTTPS, and it keeps nginx output buffering
# enabled. While recommended, I have had issues with that in the past.

server {
  listen 80;
  server_name ntfy.sh;

  location / {
    return 302 https://$http_host$request_uri$is_args$query_string;

    proxy_pass http://127.0.0.1:2586;
    proxy_http_version 1.1;

    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_connect_timeout 3m;
    proxy_send_timeout 3m;
    proxy_read_timeout 3m;

    client_max_body_size 0; # Stream request body to backend
  }
}

server {
  listen 443 ssl http2;
  server_name ntfy.sh;

  # See https://ssl-config.mozilla.org/#server=nginx&version=1.18.0&config=intermediate&openssl=1.1.1k&hsts=false&ocsp=false&guideline=5.6
  ssl_session_timeout 1d;
  ssl_session_cache shared:MozSSL:10m; # about 40000 sessions
  ssl_session_tickets off;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
  ssl_prefer_server_ciphers off;

  ssl_certificate /etc/letsencrypt/live/ntfy.sh/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/ntfy.sh/privkey.pem;

  location / {
    proxy_pass http://127.0.0.1:2586;
    proxy_http_version 1.1;

    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_connect_timeout 3m;
    proxy_send_timeout 3m;
    proxy_read_timeout 3m;

    client_max_body_size 0; # Stream request body to backend
  }
}
```

[设置密码](https://docs.ntfy.sh/config/#users-and-roles)
```bash
docker exec -it ntfy ntfy user add --role=admin phil
```

## 测试
```bash
# CURL 无密钥
curl -d "Backup successful 😀" ntfy.sh/mytopic

# CURL 密钥
curl -u testuser:fakepassword -d "Backup successful 😀" ntfy.sh/mytopic

# CLI
ntfy publish ntfy.sh/mytopic "Backup successful 😀"

# CLI 密钥
ntfy publish -u testuser:fakepassword ntfy.sh/mytopic "Backup successful 😀"
```
