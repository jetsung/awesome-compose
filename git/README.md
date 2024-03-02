同一 git 代码托管平台的账号，在同一台电脑上共存的解决方案

- 使用教程：https://www.cnblogs.com/jetsung/p/git-coexistence.html
- Docker-Git 项目地址：https://github.com/jetsung/docker-git

### 依赖环境
- [Docker](https://www.docker.com/)
- [docker compose](https://github.com/docker/compose) v2 （按教程方式二时需要此扩展）

## 文件
```
docker-compose.yaml
init.sh
.ssh/
```

### 文件说明
`init.sh` 文件
> GIT_USER 和 GIT_EMAIL 环境变量值在 `.env` 文件内修改
```bash
#!/bin/sh

# 中科大
#sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

git config --global user.name "${GIT_USER}"
git config --global user.email "${GIT_EMAIL}"
git config --global init.defaultBranch main
```

`docker-compose.yaml` 文件   
```
version: '3'
services:
  git:
    image: devcto/git:latest
    container_name: git
    volumes:
      - ./init.sh:/app/init.sh
      - ./.ssh:/root/.ssh
      - /work_code:/srv
    restart: unless-stopped
    command: -D
```

- `image` 为基础镜像。即 `alpine` 镜像，该镜像比较小，最适合此项目。
- `container_name` 为 `该容器` 名称。
- 文件 `/app/init.sh` 为初始化命令脚本，可自行修改。
- 文件夹 `./.ssh` 为该账号在平台的 `SSH 密钥`。必须设置，否则删除 `该容器` 再重建后，会遗失相关密钥。
- 文件夹 `/work_code` 为代码存放目录，即项目存放目录。多个项目比较分散的话，可自行在 `volumes` 添加。
- `restart` 为 `该容器` 重启的条件，防止意外终止。`unless-stopped` 的意思为 “除非本人执行停止的操作”
- 
- `GIT_USER` 为 git 用户的账号
- `GIT_EMAIL` 为 git 用户的邮箱

## 使用说明
## 方式一
1. 执行
```bash
docker run --rm --name git -itd \
	-v $(pwd)/init:/app/init.sh
	-v $(pwd)/.ssh:/root/.ssh
	-v $(pwd)/work_code:/srv
	devcto/git:latest
```
> 文件夹 `/.ssh` 为该账号在平台的 `SSH 密钥`。必须设置，否则删除 `该容器` 再重建后，会遗失相关密钥。若 `/.ssh` 目录未存在 `SSH 密钥`，需要自行生成（注意：删除容器会自动丢失）。

2. 初始化
```bash
docker exec -it git sh init.sh
```

3. 进入容器，在对应的项目工程目录下执行相关的 git 命令行，即可。
```bash
docker exec -it git sh
```

### 方式二
1. 首次使用需要执行 `docker compose up -d` 。
   
2. 在终端窗口下执行 `docker exec -it git /bin/sh` 进入该容器。

3. 首次进入容器都需要先执行 `sh /app/init.sh` 安装依赖组件和配置信息。若 `./.ssh` 目录未存在 `SSH 密钥`，则也需要自行生成。

4. 在对应的项目工程目录下执行相关的 git 命令行，即可。
