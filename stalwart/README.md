# stalwart

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [stalwart][1] 是一款开源邮件与协作服务器，支持 JMAP、IMAP4、POP3、SMTP、CalDAV、CardDAV 和 WebDAV 以及丰富的现代功能。它用 Rust 编写，设计为安全、快速、稳健且可扩展。

[1]:https://stalw.art/
[2]:https://github.com/stalwartlabs/mail-server
[3]:https://hub.docker.com/r/stalwartlabs/mail-server
[4]:https://stalw.art/docs/install/platform/docker/

---

## 持久化
1. 从容器中提取配置文件
```bash
# 启动
docker compose --profile server1 up -d
# 提取 config.toml
docker cp stalwart:/opt/stalwart/etc/config.toml .
# 查看密码
docker logs stalwart
# 关闭服务
docker compose --profile server1 down
```

2. 将文件配置路径映射
```yaml
volumes:
  - ./config.toml:/opt/stalwart/etc/config.toml
```

## 配置

- 设置[Server Hostname](https://stalw.art/docs/server/general#server-hostname)
```toml
[server]
hostname = "mail.example.org"
```

- 设置[反向代理](https://stalw.art/docs/category/reverse-proxy)

- 设置[账号与密码](https://stalw.art/docs/auth/authorization/administrator#configuration)
