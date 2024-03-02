# rustpad

## 使用 SQLite

1. 先设置环境变量 `SQLITE_URI`。
2. 创建文件夹 `data`，并将该文件夹设置为 `777` 权限。

```bash
mkdir data
chmod -R 777 data
```

## Nginx 配置

需要支持 `WebSocket`

```nginx
location / {
    proxy_pass http://127.0.0.1:39011;

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
