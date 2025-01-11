# hedgedoc

https://github.com/hedgedoc/hedgedoc

## 部署教程
1. **使用 Docker Compose 部署**
   - `.env` 配置文件
    ```bash
    # General settings
    HD_BASE_URL="https://example.com"
    # 密钥。使用 `pwgen -s 64` 生成，每行一个值
    HD_SESSION_SECRET="<HD_SESSION_SECRET>"

    # Database settings
    HD_DATABASE_TYPE="postgres"
    HD_DATABASE_HOST="db"
    HD_DATABASE_PORT="5432"
    HD_DATABASE_NAME="hedgedoc"
    HD_DATABASE_USER="hedgedoc"
    # 密钥。使用 `pwgen -s 64` 生成，每行一个值
    HD_DATABASE_PASS="<HD_DATABASE_PASS>"

    # Uploads
    HD_MEDIA_BACKEND="filesystem"
    HD_MEDIA_BACKEND_FILESYSTEM_UPLOAD_PATH="uploads/"

    # Auth
    HD_AUTH_LOCAL_ENABLE_LOGIN="true"
    HD_AUTH_LOCAL_ENABLE_REGISTER="true"
    ```    
    
    - `docker-compose.yml`
    ```yaml
    services:
      backend:
        #image: ghcr.io/hedgedoc/hedgedoc/backend:2.0.0-alpha.3
        image: ghcr.io/hedgedoc/hedgedoc/backend:develop
        volumes:
        - ./.env:/usr/src/app/backend/.env
        - ./hedgedoc_uploads:/usr/src/app/backend/uploads
        ports:
        - 39020:3000

      frontend:
        #image: ghcr.io/hedgedoc/hedgedoc/frontend:2.0.0-alpha.3
        image: ghcr.io/hedgedoc/hedgedoc/frontend:develop
        environment:
        - HD_BASE_URL: "${HD_BASE_URL}"
        - HD_INTERNAL_API_URL: http://backend:3000
        ports:
        - 39021:3001

    db:
        image: postgres:16
        environment:
        - POSTGRES_USER: "${HD_DATABASE_USER}"
        - POSTGRES_PASSWORD: "${HD_DATABASE_PASS}"
        - POSTGRES_DB: "${HD_DATABASE_NAME}"
        volumes:
        - ./hedgedoc_postgres:/var/lib/postgresql/data
    ```
   
2. **配置 Nginx**
   - `example.com.conf`
   ```bash
    map $http_upgrade $connection_upgrade {
            default upgrade;
            ''      close;
    }
    server
    {
            listen 80;
            listen [::]:80;
    
            server_name example.com.top;

            # 若是 http 则跳转至 https；若不需要跳转，则删除 if 语段即可。
            set $to_https 0;
            if ($scheme = "http") {
                set $to_https 1;
            }	
        
            include wildcard/example.conf;
            
            index index.html 
            root /data/wwwroot/proxy;

            access_log  /data/wwwlogs/example.com.top.log;
            error_log  /data/wwwlogs/example.com.top.error.log debug;

            charset utf-8;
        
            #ERROR-PAGE-START  错误页配置，可以注释、删除或修改
            #error_page 404 /404.html;
            #error_page 502 /502.html;
            #ERROR-PAGE-END
            
            #禁止访问的文件或目录
            location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md|install.php|install)
            {
                return 404;
            }
        
            location ~ ^/(api|public|uploads|media)/ {
                    proxy_pass http://127.0.0.1:39020;
                    proxy_set_header X-Forwarded-Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
            }

            location /realtime {
                    proxy_pass http://127.0.0.1:39020;
                    proxy_set_header X-Forwarded-Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection $connection_upgrade;
            }

            location / {
                    proxy_pass http://127.0.0.1:39021;
                    proxy_set_header X-Forwarded-Host $host; 
                    proxy_set_header X-Real-IP $remote_addr; 
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; 
                    proxy_set_header X-Forwarded-Proto $scheme;
            }
            
            #一键申请SSL证书验证目录相关设置
            location ~ \.well-known{
                allow all;
            }
    }
   ```
   - `example.conf`
    ```bash
    # 监听 IPv4 和 IPv6 的 443 端口，启用 SSL
    listen 443 ssl;
    listen [::]:443 ssl;

    # 指定 SSL 证书和私钥的位置
    ssl_certificate /srv/acme/ssl/example.com.fullchain.cer;
    ssl_certificate_key /srv/acme/ssl/example.com.key;

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
    ssl_stapling on;
    ssl_stapling_verify on;

    # 错误页重定向，HTTP 1.1 协议的 401 Unauthorized 状态码已被废弃，使用 403 Forbidden
    error_page 403 https://$host$request_uri;

    # HTTP 到 HTTPS 重定向
    if ($to_https = 1) {
        return 301 https://$host$request_uri;
    }
    ```
**相关教程：**
- https://docs.hedgedoc.dev/tutorials/setup/
  