# komodo-core

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [komodo][1] 是一款网页应用，用于提供管理服务器、构建、部署和自动化流程的结构。

[1]:https://komo.do/
[2]:https://github.com/moghtech/komodo
[3]:https://github.com/moghtech/komodo/pkgs/container/komodo-core
[4]:https://komo.do/docs/intro

---

文档：https://komo.do/docs/setup/ferretdb

## 备份与恢复

[备份与恢复文档][5]

### 恢复

1. 执行恢复（还原最近的备份，或取消注释 `--restore-folder` 指定某次备份）：
```bash
docker compose -f restore.yaml up
```

2. 恢复完成后，**所有服务都需要重新设置**：
   进入 **Config** -> **Server** -> **`Local`**，对每个服务重新配置后方可启动。

[5]:https://komo.do/docs/setup/backup#restore

## 安装

### 快速安装
1. 创建保存的文件夹 `/etc/komodo/stacks`
```bash
mkdir -p /etc/komodo/stacks
cd /etc/komodo/stacks
```

2. 执行下载与安装配置
```bash
curl -L fx4.cn/komodo | bash -s -- -d komodo -h https://domain.kodo
```
> 参数 -d 为保存的目标文件夹。参数不存在则直接在当前文件夹创建
> 参数 -h 为本项目启动的域名
> 此脚本会默认创建一些密钥和登录密钥等信息

3. 启动服务
```bash
cd komodo
docker compose -p komodo up -d
```

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

[**更多教程请查阅：爱开发社区**](https://forum.idev.top/d/1036)
