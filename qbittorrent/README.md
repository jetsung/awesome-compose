# qBittorrent

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [qBittorrent][1] 是一个开源的、基于Qt框架的轻量级BitTorrent客户端软件。它具有强大的功能，如支持多线程下载、下载速度限制、任务优先级设置等，同时界面简洁友好，易于使用。

[1]:https://www.qbittorrent.org/
[2]:https://github.com/qbittorrent/qBittorrent
[3]:https://hub.docker.com/r/johngong/qbittorrent
[4]:https://github.com/qbittorrent/qBittorrent/wiki/

---

## Nginx 反向代理

在 Nginx 中反向代理 qBittorrent WebUI 时，需要特别注意一个问题：

通过 WebUI 添加磁力链接时，qBittorrent 会将种子哈希和相关参数拼接在 `addtorrent.html?v=...` 后面，导致 URL 非常长。如果 URL 长度超过了 Nginx `large_client_header_buffers` 的默认限制（4 × 8KB = 32KB），Nginx 会直接切断连接，返回 `414 Request-URI Too Large` 或 `400 Bad Request` 错误。

### 解决方案

在 Nginx server 配置中增加 `large_client_header_buffers`：

```nginx
server {
    listen 443 ssl;
    server_name qbittorrent.example.com;

    # 调大请求头和 URL 缓冲区限制，避免磁力链接 URL 过长导致 414 错误
    client_header_buffer_size 16k;
    large_client_header_buffers 4 32k;

    # 调大请求体限制，避免上传种子文件时返回 413 错误
    client_max_body_size 50m;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

> **注意：** `client_header_buffer_size`、`large_client_header_buffers` 和 `client_max_body_size` 都是 server 级别指令，不能放在 `location` 块中。
