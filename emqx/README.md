# EMQX

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [EMQX][1] 是一款「无限连接，任意集成，随处运行」的大规模分布式物联网接入平台，同时作为一个高性能、可扩展的 MQTT 消息服务器，它可以为物联网（IoT）应用提供可靠的实时消息传输和设备连接解决方案。EMQX 累计拥有来自 50 多个国家的 20,000 多家企业用户，连接全球超过 1 亿台物联网设备，服务企业数字化、实时化、智能化转型。

[1]:https://www.emqx.com/
[2]:https://github.com/emqx/emqx
[3]:https://hub.docker.com/r/emqx/emqx
[4]:https://docs.emqx.com/

---

## 配置

- 放开端口：`1883,8883,8083,8084,18083,18084`
- 配置文件：`/opt/emqx/etc/emqx.conf`
- [环境变量](https://docs.emqx.com/zh/emqx/latest/configuration/dashboard.html)
- [首次登录](https://docs.emqx.com/zh/emqx/latest/dashboard/introduction.html#%E9%A6%96%E6%AC%A1%E7%99%BB%E5%BD%95)
    ```bash
    默认账号：admin
    默认密码：public
    ```
- [忘记密码](https://docs.emqx.com/zh/emqx/latest/dashboard/introduction.html#%E5%BF%98%E8%AE%B0%E5%AF%86%E7%A0%81)
    ```bash
    docker exec -it emqx emqx ctl admins passwd <Username> <Password>
    docker exec -it emqx emqx ctl admin <Username> <New Password>
    ```
- [TLS 配置（MQTTS）](https://docs.emqx.com/zh/emqx/latest/network/emqx-mqtt-tls.html) （**单向**）
    1. 修改 `.env` 配置文件，去除 `#` 注释
    ```bash
    EMQX_LISTENERS__SSL__DEFAULT__BIND=0.0.0.0:8883
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__KEYFILE=/etc/emqx/certs/emqx.key
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__CERTFILE=/etc/emqx/certs/emqx.cer
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__CACERTFILE=
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__VERIFY=verify_none
    EMQX_LISTENERS__SSL__DEFAULT__SSL_OPTIONS__FAIL_IF_NO_PEER_CERT=false
    ```
    2. 将以下的证书对应的 key 和 cer 路径替换为自己的证书路径
    ```yaml
    volumes:
     - /srv/acme/ssl/emqx.io.key:/etc/emqx/certs/emqx.key
     - /srv/acme/ssl/emqx.io.fullchain.cer:/etc/emqx/certs/emqx.cer
    ```

- [WSS 配置](https://docs.emqx.com/zh/emqx/latest/configuration/listener.html#%E9%85%8D%E7%BD%AE%E5%AE%89%E5%85%A8-websocket-%E7%9B%91%E5%90%AC%E5%99%A8)
    1. 修改 `.env` 配置文件，去除 `#` 注释
    ```bash
    EMQX_LISTENERS__WSS__DEFAULT__BIND=0.0.0.0:8084
    EMQX_LISTENERS__WSS__DEFAULT__MAX_CONNECTIONS=1024000
    EMQX_LISTENERS__WSS__DEFAULT__WEBSOCKET__MQTT_PATH="/mqtt"
    EMQX_LISTENERS__WSS__DEFAULT__SSL_OPTIONS__CERTFILE=/etc/emqx/certs/emqx.cer
    EMQX_LISTENERS__WSS__DEFAULT__SSL_OPTIONS__KEYFILE=/etc/emqx/certs/emqx.key
    EMQX_LISTENERS__WSS__DEFAULT__SSL_OPTIONS__CACERTFILE=
    ```

- [DASHBOARD 配置](https://docs.emqx.com/zh/emqx/latest/configuration/dashboard.html)
    1. 修改 `.env` 配置文件，去除 `#` 注释
    ```bash
    #EMQX_DASHBOARD__LISTENERS__HTTPS__BIND=0.0.0.0:18084
    #EMQX_DASHBOARD__LISTENERS__HTTPS__SSL_OPTIONS__CERTFILE=/etc/emqx/certs/emqx.cer
    #EMQX_DASHBOARD__LISTENERS__HTTPS__SSL_OPTIONS__KEYFILE=/etc/emqx/certs/emqx.key
    ```

## 运行
```bash
docker compose up -d
chmod -R 777 ./data
```

## 客户端连接密码设置
- https://docs.emqx.com/zh/emqx/latest/access-control/authn/mnesia.html
