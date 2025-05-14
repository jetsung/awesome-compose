# Shortener

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [Shortener][1] 是一个使用 Go 语言开发的短网址生成器。后端使用 Gin 框架，前端使用 React 框架。

[1]: https://github.com/idevsig/shortener-server
[2]: https://github.com/idevsig/shortener-server
[3]: https://hub.docker.com/r/idevsig/shortener-server
[4]: https://github.com/idevsig/shortener-server#文档

## 使用
1. 配置文件 `config.toml`
2. 若需要使用缓存，需要配置 `valkey` 缓存
    1. 取消 `compose.yml` 中的 `valkey` 配置的注释。
    2. 修改配置文件 `config.toml` 中的 `cache.enabled` 字段为 `true`。
    3. 修改配置文件 `config.toml` 中的 `cache.type` 字段为 `valkey`。
3. 若需要 IP 数据，需要配置 `ip2region` 数据库
    1. 下载 [ip2region.xdb](https://github.com/lionsoul2014/ip2region/blob/master/data/ip2region.xdb) ，保存至 `./data/ip2region.xdb`。
    2. 修改配置文件 `config.toml` 中的 `geoip.enabled` 字段为 `true`。
4. 启动
    ```bash
    docker compose up -d
    ```
5. 配置 Nginx 反向代理
    ```nginx
    # 前端配置
    location / {
        proxy_pass   http://127.0.0.1:8080;

        client_max_body_size  1024m;
        proxy_set_header Host $host:$server_port;

        proxy_set_header X-Real-Ip $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;  # 透传 HTTPS 协议标识
        proxy_set_header X-Forwarded-Ssl on;         # 明确 SSL 启用状态

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_connect_timeout 99999;
    }

    # 对接 API
    location /api/ {
        proxy_pass   http://127.0.0.1:8081/api/v1/;

        client_max_body_size  1024m;
        proxy_set_header Host $host:$server_port;

        proxy_set_header X-Real-Ip $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;  # 透传 HTTPS 协议标识
        proxy_set_header X-Forwarded-Ssl on;         # 明确 SSL 启用状态

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_connect_timeout 99999;
    }
    ```
