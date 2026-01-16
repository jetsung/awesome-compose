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

## 一键安装方式
```bash
# 【快速安装】
# 或者直接使用 Caddy 直接创建服务，再通过浏览器访问域名即可。不需要再进行其它操作。
# 此方式将禁止 3000 端口对外。取消则将 compose.yaml 中去掉 '#- 3000' 的注释即可。
wget -qO - https://git.jetsung.com/jetsung/awesome-compose/-/raw/main/gitea/run.sh | bash -s init xxx.com

# 默认配置，执行之后，需通过浏览器访问 IP:3000，设置 Gitea 相关信息，以便生成 app.ini 配置文件。
# 或者配置好 caddy / nginx 的 ssl 服务后，通过需要直接访问，再配置即可。
wget https://git.jetsung.com/jetsung/awesome-compose/-/raw/main/gitea/run.sh
chmod +x run.sh
./run.sh

# 手动安装
./run.sh init xxx.com
```

### 更多参数说明
> 仅封装了相关命令行

```bash
## 停止所有服务（caddy）
# docker compose --profile caddy down
./run.sh cstop

## 启动所有服务（caddy）
# docker compose --profile caddy up -d
./run.sh cstart

## 停止所有服务（nginx）
# docker compose --profile nginx down
./run.sh nstop

## 启动所有服务（nginx）
# docker compose --profile nginx up -d
./run.sh nstart
```

## CI/CD 自动构建平台

### [Gitea Runner](https://docs.gitea.com/zh-cn/usage/actions/act-runner#%E4%BD%BF%E7%94%A8-docker-compose-%E8%BF%90%E8%A1%8C-runner)

#### 初始化配置文件
```bash
docker run --entrypoint="" --rm -it gitea/act_runner:latest act_runner generate-config > config.yaml
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
