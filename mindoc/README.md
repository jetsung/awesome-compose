# MinDoc

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [MinDoc][1] 是一款针对IT团队开发的简单好用的文档管理系统

[1]:https://doc.gsw945.com/docs/mindoc-docs/
[2]:https://github.com/forkdo/mindoc
[3]:https://hub.docker.com/r/forkdo/mindoc
[4]:https://github.com/forkdo/mindoc/tree/main/docker

---

## 配置

1. 若使用反向代理，则需要设置环境变量 `MINDOC_BASE_URL` 的值（含协议部分）。

2. 初始化数据库：
```bash
docker run --rm -v $(pwd)/mindoc:/mindoc forkdo/mindoc:latest install
```

3. 启动
```bash
docker compose up -d
```
