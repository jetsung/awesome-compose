# MinIO

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [MinIO][1] 是一个高性能的分布式对象存储服务器，通常用于存储大量非结构化数据，如图片、视频、日志文件等。它兼容 Amazon S3 云存储服务接口，可以方便地与各种应用程序集成，支持高可用性、数据冗余和自动扩展等功能，适用于需要大规模数据存储和访问的场景。

[1]:https://min.io/
[2]:https://github.com/minio/minio
[3]:https://quay.io/repository/minio/minio?tab=tags
[4]:https://min.io/docs/

---

## 版本说明
| 版本 | 说明 |
| --- | --- |
| [`RELEASE.2025-04-22T22-12-26Z`](quay.io/minio/minio:RELEASE.2022-05-26T05-48-41Z) | 单文件版，后续版本的文件将使用 “元数据” 存储（即 `meta`） |
| [`RELEASE.2025-04-22T22-12-26Z`](quay.io/minio/minio:RELEASE.2025-04-22T22-12-26Z) | 带管理页版，后续版本不再支持 WEBUI 管理，只支持命令行管理 |

**nginx 配置**
```nginx
upstream console {
    ip_hash;
    server 127.0.0.1:39008;
}

server {
    listen 80;
    listen [::]:80;

    server_name min.asfd.cn;

    index index.html;
    root /data/wwwroot/proxy;

    set $to_https 0;
    if ($scheme = "http") {
        set $to_https 1;
    }

    include wildcard/asfd.cn.conf;

    access_log /data/wwwlogs/min.asfd.cn.log;
    error_log /data/wwwlogs/min.asfd.cn_error.log;

    #禁止访问的文件或目录
    location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)
    {
        return 404;
    }

    # To allow special characters in headers
    ignore_invalid_headers off;
    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;
    # To disable buffering
    proxy_buffering off;
    proxy_request_buffering off;

    location / {
        proxy_pass http://console;
        proxy_connect_timeout 300;

        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-NginX-Proxy true;

        # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        chunked_transfer_encoding off;
        real_ip_header X-Real-IP;
    }
}
```
