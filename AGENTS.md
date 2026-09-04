# awesome-compose

自托管 Docker Compose 模板集合。

[Compose 规范](https://github.com/compose-spec/compose-spec) · [Docker Compose 语法](https://docs.docker.com/reference/compose-file/)

---

## 项目初始化

```bash
# 通过镜像名称创建
make init n=filetas

# 通过 Docker Hub 地址创建（p=1 使用前部分作为文件夹名）
make init n=https://hub.docker.com/r/gotify/server p=1

# 通过 GitHub Package 地址创建
make init n=https://github.com/warp-tech/warpgate/pkgs/container/warpgate

# 通过 ghcr.io 镜像创建
make init n=ghcr.io/warp-tech/warpgate:latest
```

`make init` 支持的输入格式：

| 格式 | 示例 |
|------|------|
| 镜像名 | `filetas` |
| 带标签镜像 | `filetas:python` |
| ghcr.io 镜像 | `ghcr.io/idevsig/filetas:latest` |
| GitHub Package URL | `https://github.com/.../pkgs/container/...` |
| Docker Hub URL | `https://hub.docker.com/r/...` |

## 目录结构规范

每个服务目录遵循统一模板结构：

```
<service>/
├── .env                    # 环境变量（TZ、端口等）
├── README.md               # 服务说明文档
├── compose.yaml            # 基础 Compose 配置
├── compose.override.yaml   # 覆盖配置（端口映射、卷挂载）
└── backup.sh               # 可选：数据备份脚本
```

### .env 模板

```env
# CUSTOM
TZ=Asia/Shanghai
SERV_PORT=80
```

### compose.yaml 模板

```yaml
---
# <镜像仓库地址>
services:
  <项目名>:
    container_name: <项目名>
    env_file:
      - path: ./.env
        required: false
    image: <镜像>:<标签>
#     ports:
#       - 80:80
    restart: unless-stopped
```

### compose.override.yaml 模板

```yaml
---
services:
  <项目名>:
#     ports: !reset []
#     ports: !override
#       - ${SERV_PORT:-80}:80
#     volumes:
#       - ./data:/data
```

### README.md 模板

```markdown
# <项目名>

[Office Web][1] · [Source][2] · [Docker Image][3] · [Documentation][4]

---

> [<项目名>][1]

[1]: <官网地址>
[2]: <源码仓库>
[3]: <镜像地址>
[4]: <文档地址>
```

### backup.sh 模板

```bash
#!/usr/bin/env bash

###
#
# 备份 <项目名> 数据
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[[ -f <项目名>.tar.xz ]] && rm -rf ./<项目名>.tar.xz

[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh

tar -Jcf <项目名>.tar.xz ./data

[[ -f ./exec_post.sh ]] && bash ./exec_post.sh

#rclone copy ./<项目名>.tar.xz minio:/backup/databases
echo "backup <项目名> data to minio done."
echo "Backup of <项目名> data to MinIO completed successfully."
```

## Makefile 命令

| 命令 | 说明 |
|------|------|
| `make init n=<输入>` | 初始化项目（自动解析镜像信息） |
| `make init n=<输入> p=1` | 使用路径前部分作为文件夹名 |
| `make create proj="" git="" image="" huburl=""` | 手动创建项目 |
| `make help` | 显示帮助信息 |

## 约定

- 每个服务独立目录，互不依赖
- `compose.yaml` 放基础配置，`compose.override.yaml` 放可覆盖配置
- 端口使用环境变量 `${SERV_PORT:-80}` 格式，便于 `.env` 覆盖
- `compose.yaml` 中端口默认注释，`override` 中用 `!override` 或 `!reset` 控制
- `restart: unless-stopped` 作为默认重启策略
- 备份脚本打包 `./data` 目录为 `.tar.xz`，支持 `exec_pre.sh` / `exec_post.sh` 钩子

## 相关链接

- [Compose 规范](https://github.com/compose-spec/compose-spec)
- [Docker Compose 语法](https://docs.docker.com/reference/compose-file/)
- [Compose Override 说明](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/)
