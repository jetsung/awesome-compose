# Tuwunel

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Tuwunel][1] 是一个功能强大的 Matrix 自建服务器。

[1]:https://tuwunel.chat/
[2]:https://github.com/matrix-construct/tuwunel
[3]:https://hub.docker.com/r/jevolk/tuwunel
[4]:https://matrix-construct.github.io/tuwunel/deploying/docker.html

---

- [docker-compose.yml](https://github.com/matrix-construct/tuwunel/blob/main/docs/deploying/docker-compose.yml)

| 环境变量                                                                 | 默认值                              | 描述                                                                 |
|--------------------------------------------------------------------------|-------------------------------------|----------------------------------------------------------------------|
| TUWUNEL_SERVER_NAME                                                      | (必须手动设置，无默认)              | 服务器名称（域名），例如 `matrix.example.com`。**必须修改**，设置后不可更改（除非重置数据库）。用于用户ID、房间ID后缀。 |
| TUWUNEL_DATABASE_PATH                                                    | /var/lib/tuwunel                    | 数据存储目录（包含数据库、媒体文件等）。建议映射为持久化卷。          |
| TUWUNEL_PORT                                                             | 8008                                | tuwunel 监听的 HTTP 端口（客户端API和联邦端口）。Docker 中常映射为 8008 或其他端口如 6167。 |
| TUWUNEL_ADDRESS                                                          | ["127.0.0.1", "::1"]                | 监听的 IP 地址。公网/Docker 部署通常改为 `0.0.0.0` 以允许外部访问。   |
| TUWUNEL_MAX_REQUEST_SIZE                                                 | 25165824 (≈24 MiB)                  | 最大文件上传大小（字节）。示例中设置为 20000000（≈20 MB）。           |
| TUWUNEL_ALLOW_REGISTRATION                                               | false                               | 是否允许新用户注册。建议开启时必须配合注册令牌使用。                  |
| TUWUNEL_REGISTRATION_TOKEN                                               | (无默认，必须设置)                  | 注册时用户必须输入的令牌（字符串）。开启注册时强烈推荐设置。          |
| TUWUNEL_YES_I_AM_VERY_VERY_SURE_I_WANT_AN_OPEN_REGISTRATION_SERVER_PRONE_TO_ABUSE | false                               | **极度危险**：设为 true 允许完全开放、无令牌注册，极易被机器人/垃圾账号滥用，仅在明确了解风险时使用。 |
| TUWUNEL_ALLOW_FEDERATION                                                | true                                | 是否允许联邦（与其他 Matrix 服务器互通）。关闭后成为纯私有服务器。    |
| TUWUNEL_TRUSTED_SERVERS                                                  | ["matrix.org"]                      | 信任的密钥服务器列表，用于验证其他服务器的签名。通常保留 matrix.org。 |
| TUWUNEL_LOG                                                              | info                                | 日志级别（可选项：trace / debug / info / warn / error）。可附加过滤器，如 `warn,state_res=warn`。 |
