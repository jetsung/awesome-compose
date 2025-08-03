# bore

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [bore][1] 是一个现代、简单的 TCP 隧道，它将本地端口暴露给远程服务器，绕过标准 NAT 连接防火墙。

[1]:http://bore.pub
[2]:https://github.com/ekzhang/bore
[3]:https://hub.docker.com/r/ekzhang/bore
[4]:https://github.com/ekzhang/bore#detailed-usage

**注意：**使用大量端口时，不建议使用桥接模式（`bridge`），建议使用 `host` 模式。
