# Vaultwarden

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Vaultwarden][1] 是用 Rust 编写的非官方 Bitwarden 兼容服务器

[1]:https://github.com/dani-garcia/vaultwarden
[2]:https://github.com/dani-garcia/vaultwarden
[3]:https://hub.docker.com/r/vaultwarden/server
[4]:https://github.com/dani-garcia/vaultwarden/wiki

---

- 生成密钥
```bash
openssl rand -base64 48
```
设置环境变量
```bash
ADMIN_TOKEN
```
