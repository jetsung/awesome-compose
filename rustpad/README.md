# Rustpad

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Rustpad][1] 是一个开源的协作文本编辑器，它基于操作变换算法（operational transformation algorithm）来实现协作功能。你可以将这个编辑器的链接分享给其他人，他们可以在自己的浏览器中进行编辑，并且能够实时看到你所做的更改。

[1]:https://rustpad.io/
[2]:https://github.com/ekzhang/rustpad
[3]:https://hub.docker.com/r/ekzhang/rustpad
[4]:https://github.com/ekzhang/rustpad#deployment

---

https://github.com/forkdo/rustpad [**Forked ekzhang**](https://github.com/ekzhang/rustpad)

## 使用 SQLite

设置环境变量 `SQLITE_URI`。

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
