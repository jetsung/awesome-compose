# asciinema server

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [asciinema server][1] 是一个免费的开源解决方案，用于录制终端会话并在 Web 上共享它们。

[1]:https://asciinema.org/
[2]:https://github.com/asciinema/asciinema-server
[3]:https://ghcr.io/asciinema/asciinema-server
[4]:https://docs.asciinema.org/manual/server/self-hosting/

---

## 前置服务
1. 安装 `nginx` 和 `docker`
2. 需要使用到 `email` 账户的 `smtp` 服务，以提供登录

## [docker Compose 部署](compose.yaml)服务器

### ）服务全部使用 `Docker`

### ）数据库使用宿主机的 `PostgreSQL`

- 创建 `PostgreSQL` 的用户
  1. **登录 PostgreSQL**
     使用超级用户连接到 PostgreSQL：

     ```bash
     psql -U postgres
     ```

  2. **创建数据库**
     为 `asciinema` 创建数据库：

     ```sql
     CREATE DATABASE asciinema;
     ```

  3. **创建用户**
     创建一个专用用户来访问数据库，并设置密码：

     ```sql
     CREATE USER asciinema_user WITH PASSWORD 'your_password';
     ```

  4. **授予权限**
     将该用户赋予 `asciinema` 数据库的权限：

     ```sql
     GRANT ALL PRIVILEGES ON DATABASE asciinema TO asciinema_user;
     ```

  5. **测试连接**
     在服务器上运行以下命令测试连接是否成功：

      ```bash
      psql -h <external-db-host> -U asciinema_user -d asciinema
      ```

      输入密码后，应能够连接到数据库。

- 查看宿主机的网络
  ```bash
  docker network inspect bridge | grep 'Gateway' | awk -F'"' '{print $4}'
  ```
  将 `compose.yaml` 的 `hostname` 修改为上述命令查出来的 **IP**。

- [`.env`](.env) 文件添加一行数据库的信息，[**相关文档**](https://docs.asciinema.org/manual/server/self-hosting/configuration/#external-postgresql-server)。
  ```sh
  # Postgres
  DATABASE_URL=postgresql://username:password@hostname/dbname
  ```

### ）数据库使用宿主机的 `PostgreSQL` 和 `AWS S3` 对象存储

- [`.env`](.env) 文件添加 `S3` 相关的信息，[**相关文档**](https://docs.asciinema.org/manual/server/self-hosting/configuration/#cloudflare-r2)。
  ```sh
  # S3
  S3_BUCKET=<BUCKET_NAME>
  S3_ENDPOINT=<https://ENDPOINT_DOMAIN>
  S3_ACCESS_KEY_ID=<ACCESS_KEY>
  S3_SECRET_ACCESS_KEY=<SECRET_ACCESS_KEY>
  S3_REGION=<REGION>
  ```

## [**`.env`**](.env) 配置参数说明
  ```sh
  # 是否关闭注册，默认 false
  SIGN_UP_DISABLED=false

  # 管理员联系邮箱
  CONTACT_EMAIL_ADDRESS=<CONTACT_EMAIL_ADDRESS>

  # 未认领的 rec 垃圾回收时长，单位（天）
  UNCLAIMED_RECORDING_TTL=30

  # 密钥，使用命令生成:
  # tr -dc A-Za-z0-9 </dev/urandom | head -c 64; echo
  SECRET_KEY_BASE=<SECRET_KEY_BASE>

  URL_HOST=example.com # 服务器的主机名，即互联网访问域名
  URL_PORT=4000 # 内部服务端口，默认 4000
  URL_SCHEME=https # 访问协议，默认 http

  # SMTP 基本配置
  SMTP_HOST=smtp.exmail.qq.com # 必填
  SMTP_PORT=587 # 必填，默认端口
  SMTP_USERNAME=<SMTP_USERNAME> # 必填，邮箱用户名
  SMTP_PASSWORD=<SMTP_PASSWORD> # 必填，邮箱密码

  # SMTP 加密配置
  SMTP_TLS=always # 加密方式
  SMTP_ALLOWED_TLS_VERSIONS=tlsv1.2,tlsv1.3 # 允许的 TLS 版本

  # SMTP 认证配置
  SMTP_AUTH=always # 验证方式
  SMTP_NO_MX_LOOKUPS=false

  # 邮件头配置
  MAIL_FROM_ADDRESS=<MAIL_FROM_ADDRESS> # From
  MAIL_REPLY_TO_ADDRESS=<MAIL_REPLY_TO_ADDRESS> # Reply-To

  # S3
  S3_BUCKET=<BUCKET_NAME>
  S3_ENDPOINT=<https://ENDPOINT_DOMAIN>
  S3_ACCESS_KEY_ID=<ACCESS_KEY>
  S3_SECRET_ACCESS_KEY=<SECRET_ACCESS_KEY>
  S3_REGION=<REGION>
  ```

- [配置邮箱信息](https://docs.asciinema.org/manual/server/self-hosting/configuration/#email)
- 配置 NGINX 反代
  ```nginx
    location / {
        proxy_pass http://127.0.0.1:4000;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header Origin https://$host;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_read_timeout 120s;
        proxy_next_upstream error;
        proxy_redirect off;
        proxy_buffering off;
    }
  ```

- 添加管理邮箱
  ```sh
  docker compose exec asciinema admin_add admin@example.com
  ```
