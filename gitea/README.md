# Gitea

教程以本 **README** 为准，其它渠道的教程可能无法做到及时更新。

## 前置预设
首先，确保当前服务器的 ssh 连接端口非 22 端口。以便可以通过 ssh 方式拉取和提交代码。   
其次，将此域名绑定到此服务器 IP，以便通过域名拉取和提交代码。

## 一键安装方式
```bash
# 【快速安装】
# 或者直接使用 Caddy 直接创建服务，再通过浏览器访问域名即可。不需要再进行其它操作。   
# 此方式将禁止 3000 端口对外。取消则将 docker-compose.yml 中去掉 '#- 3000' 的注释即可。
wget -qO - https://jihulab.com/jetsung/docker-compose/-/raw/main/gitea/run.sh | bash -s init xxx.com

# 默认配置，执行之后，需通过浏览器访问 IP:3000，设置 Gitea 相关信息，以便生成 app.ini 配置文件。
# 或者配置好 caddy / nginx 的 ssl 服务后，通过需要直接访问，再配置即可。
wget https://jihulab.com/jetsung/docker-compose/-/raw/main/gitea/run.sh
chmod +x run.sh
./run.sh

# 手动安装（Caddy）
./run.sh init xxx.com
```

### Caddy 
**`PostgreSQL` + `Caddy` 方式**
> 由于 Caddy 会自动获取 ssl 证书，故不需配置证书。   

**1、相关文件**   
```bash
# caddy docker-compose 文件
docker-compose.caddy.yml

# Caddy 配置文件
Caddyfile
```

**2、执行命令**  
```bash
## [使用 nginx 方式，则跳过下一步骤] ##
# 独立域名执行以下命令行（需修改下述域名）
./run.sh domain.com
```

### Nginx   
**`PostgreSQL` + `Nginx` 方式**

**1、相关文件**   
```bash
# nginx docker-compose 文件
docker-compose.nginx.yml

# nginx 配置文件
nginx.conf
```

**2、配置 ssl 证书**   
1. 创建 ssl 文件夹，并将 ssl 证书保存至该文件夹。   
2. 修改 `nginx.conf` 配置信息（域名和证书文件名）。 
```
...   
server_name localhost;   
...   
ssl_certificate    ssl/localhost.fullchain.cer;   
ssl_certificate_key    ssl/localhost.key;   
...
```
**3、执行命令**  
```bash
# 独立域名执行以下命令行（需修改下述域名）
./run.sh domain.com nginx
```

### 更多参数说明
> 仅封装了相关命令行

```bash
## 停止所有服务（caddy）
# docker compose -f docker-compose.yml -f docker-compose.caddy.yml down
./run.sh stop 

## 启动所有服务（caddy）
# docker compose -f docker-compose.yml -f docker-compose.caddy.yml up -d
./run.sh start

## 停止所有服务（nginx）
# docker compose -f docker-compose.yml -f docker-compose.nginx.yml down
./run.sh stop2

## 启动所有服务（nginx）
# docker compose -f docker-compose.yml -f docker-compose.nginx.yml up -d
./run.sh start2
```

## CI/CD 自动构建平台

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
> 1. 哔哩哔哩: https://space.bilibili.com/24643475/channel/seriesdetail?sid=2579674   
> 西瓜视频: https://www.ixigua.com/7136483138939093535
