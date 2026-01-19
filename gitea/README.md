# Gitea

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Gitea][1] 是一个轻量级的 DevOps 平台软件。从开发计划到产品成型的整个软件生命周期，他都能够高效而轻松的帮助团队和开发者。包括 Git 托管、代码审查、团队协作、软件包注册和 CI/CD。它与 GitHub、Bitbucket 和 GitLab 等比较类似。

[1]:https://gitea.com/
[2]:https://github.com/go-gitea/gitea
[3]:https://hub.docker.com/r/gitea/gitea
[4]:https://docs.gitea.com/zh-cn/installation/install-with-docker


---

本教程以 `PostgreSQL` 方式进行安装。

## 先决条件
1. 确保当前服务器的 ssh 连接端口非 22 端口。以便可以通过 ssh 方式拉取和提交代码。
2. 将此域名绑定到此服务器 IP，以便通过域名拉取和提交代码。

## 使用方法
1. 创建数据库
```bash
CREATE DATABASE gitea;
```

## 环境变量
```bash
GITEA__database__DB_TYPE=postgres
GITEA__database__HOST=db:5432
GITEA__database__NAME=gitea
GITEA__database__USER=gitea
GITEA__database__PASSWD=gitea

GITEA__mailer__ENABLED=true
GITEA__mailer__FROM=
GITEA__mailer__PROTOCOL=smtp
GITEA__mailer__HOST=
GITEA__mailer__IS_TLS_ENABLED=true
GITEA__mailer__USER=
GITEA__mailer__PASSWD=
```

## [配置](https://docs.gitea.com/zh-cn/administration/config-cheat-sheet) `app.ini`
1. 关闭注册功能
```bash
[service]
# 禁止用户注册
DISABLE_REGISTRATION = true

# 显示注册按钮
SHOW_REGISTRATION_BUTTON = false
```

## CI/CD 自动构建平台

### [Gitea Runner](https://docs.gitea.com/zh-cn/usage/actions/act-runner#%E4%BD%BF%E7%94%A8-docker-compose-%E8%BF%90%E8%A1%8C-runner)

#### 初始化配置文件
```bash
docker run --entrypoint="" --rm -it gitea/act_runner:nightly act_runner generate-config > config.yaml
```

#### 获取注册令牌
```bash
gitea --config /etc/gitea/app.ini actions generate-runner-token
```
或全局注册令牌
```bash
openssl rand -hex 24 > /some-dir/runner-token
export GITEA_RUNNER_REGISTRATION_TOKEN_FILE=/some-dir/runner-token
./gitea --config ...

# Docker 中使用时
## 1. 生成密钥文件
openssl rand -hex 24 > runner-token

## 2. 更新 .env 文件中 GITEA_RUNNER_REGISTRATION_TOKEN_FILE 的环境变量
## 若 GITEA_RUNNER_REGISTRATION_TOKEN 与 GITEA_RUNNER_REGISTRATION_TOKEN_FILE 同时设置时，优先使用 GITEA_RUNNER_REGISTRATION_TOKEN
GITEA_RUNNER_REGISTRATION_TOKEN_FILE=/runner-token

## 3. 映射至容器中
  gitea:
    ...
    volumes:
      - ./runner-token:/runner-token

  runner:
    ...
    volumes:
      - ./runner-token:/runner-token
```

### 注册 Runner
```bash
./act_runner register
# 或
./act_runner --config config.yaml register
```
非交互式
```bash
./act_runner register --no-interactive --instance <instance_url> --token <registration_token> --name <runner_name> --labels <runner_labels>
```

**Runner 镜像**
- https://github.com/catthehacker/docker_images
```bash
ghcr.io/catthehacker/ubuntu:act-22.04
ghcr.io/catthehacker/ubuntu:act-24.04
ghcr.io/catthehacker/ubuntu:act-latest
```
- 更新 `config.yaml`，使用对应的镜像
```yaml
  labels:
    - "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
    - "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
    - "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
```

### Drone 平台
首先，将此域名绑定到此服务器 IP。

#### 生成 Gitea 应用密钥
> GITEA 为 Gitea 代码托管服务的域名，DRONE 为 Drone 的访问域名。

1. 打开网址 `https://{GITEA}/user/settings/applications`。
2. 最下方 **创建新的 OAuth2 应用程序**，**应用名称**设置为`Drone`，**重定向 URI**设置为`https://{DRONE}/login`.
3. 记录下 **客户端ID**（DRONE_GITEA_CLIENT_ID）、**客户端密钥**（DRONE_GITEA_CLIENT_SECRET）。
4. 执行下述命令行：
```bash
# 安装
./run.sh drone {{DRONE_SERVER_HOST}} {{DRONE_GITEA_CLIENT_ID}} {{DRONE_GITEA_CLIENT_SECRET}}
```
> DRONE_SERVER_HOST: Drone 访问的实际域名
> DRONE_GITEA_CLIENT_ID: Gitea 应用客户端ID
> DRONE_GITEA_CLIENT_SECRET: Gitea 应用客户端密钥

### Woodpecker 平台
首先，将此域名绑定到此服务器 IP。

#### 生成 Gitea 应用密钥
> GITEA 为 Gitea 代码托管服务的域名，WOODPECKER 为 Woodpecker 的访问域名。

1. 打开网址 `https://{GITEA}/user/settings/applications`。
2. 最下方 **创建新的 OAuth2 应用程序**，**应用名称**设置为`Woodpecker`，**重定向 URI**设置为`https://{WOODPECKER}/authorize`.
3. 记录下 **客户端ID**（WOODPECKER_GITEA_CLIENT）、**客户端密钥**（WOODPECKER_GITEA_SECRET）。
4. 执行下述命令行：
```bash
# 安装
./run.sh woodpecker {{WOODPECKER_HOST}} {{WOODPECKER_GITEA_CLIENT}} {{WOODPECKER_GITEA_SECRET}}
```
> WOODPECKER_HOST: Woodpecker 访问的实际域名
> WOODPECKER_GITEA_CLIENT: Gitea 应用客户端ID
> WOODPECKER_GITEA_SECRET: Gitea 应用客户端密钥

## 教程
- **视频教程：**
> 1. 哔哩哔哩: https://www.bilibili.com/video/BV1te4y1Z7bL
> 西瓜视频: https://www.ixigua.com/7136483138939093535
