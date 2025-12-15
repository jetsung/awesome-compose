# komodo-core

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [komodo][1] 是一款网页应用，用于提供管理服务器、构建、部署和自动化流程的结构。

[1]:https://komo.do/
[2]:https://github.com/moghtech/komodo
[3]:https://github.com/moghtech/komodo/pkgs/container/komodo-core
[4]:https://komo.do/docs/intro

---

文档：https://komo.do/docs/setup/ferretdb

## 安装

### 快速安装
```bash
curl -L fx4.cn/komo | bash -s -- -d komodo -h https://my.kodo.io
```
> 参数 -d 为保存的目标文件夹
> 参数 -h 为本项目启动的域名
> 此脚本会默认创建一些密钥和登录官僚等信息

### 官方教程安装
1. 下载配置文件
```bash
wget -P komodo https://raw.githubusercontent.com/moghtech/komodo/main/compose/ferretdb.compose.yaml && \
  wget -P komodo https://raw.githubusercontent.com/moghtech/komodo/main/compose/compose.env
```

2. 启动
```bash
docker compose -p komodo -f komodo/ferretdb.compose.yaml --env-file komodo/compose.env up -d
```
