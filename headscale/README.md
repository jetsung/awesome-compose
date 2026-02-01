# Headscale

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Headscale][1] 是 Tailscale 控制服务器的开源自托管实现。

[1]:https://headscale.net/
[2]:https://github.com/juanfont/headscale
[3]:https://hub.docker.com/r/headscale/headscale
[4]:https://headscale.net/stable/setup/install/container/

---

## 配置
1. 下载 `config.yaml` 配置文件
```bash
curl -o config/headscale.yaml https://raw.githubusercontent.com/juanfont/headscale/v0.27.1/config-example.yaml
```

2. 更新配置
```bash
# 主服务
sed -i 's#^listen_addr:.*#listen_addr: 0.0.0.0:8080#g' config/headscale.yaml

# metrics 服务
sed -i 's#^metrics_listen_addr:.*#metrics_listen_addr: 0.0.0.0:9090#g' config/headscale.yaml

# 绑定的域名
sed -i 's#^server_url:.*#server_url: https://MYHEADSCALE.EXAMPLE.COM:443#g' config/headscale.yaml

# 在 Tailscale 的配置中添加服务器地址（建议启用 https）
# TS_EXTRA_ARGS=--login-server=https://MYHEADSCALE.EXAMPLE.COM
```

3. 查看可用性
```bash
curl http://127.0.0.1:8080/health
```

## 操作
```bash
# 创建用户（替换 myuser 为你想要的用户名）
docker exec -it headscale \
    headscale users create myuser

# 列出所有用户，找到 "myuser" 对应的 ID
docker exec -it headscale \
    headscale users list

# ID | Name | Username | Email | Created  
# 1  |      | myuser   |       | 2026-01-31 15:42:13

# 生成预授权 key（用于客户端加入，--reusable 可重复用，--expiration 设置过期时间）
docker exec -it headscale \
    headscale preauthkeys create --user 1 --reusable --expiration 90d

# # 查看用户 ID 1 预授权 key
docker exec -it headscale headscale preauthkeys list --user 1
# ID | Key                                              | Reusable | Ephemeral | Used  | Expiration          | Created             | Tags
# 1  | 75950e9c151d9d36df6a59d1be67c46c2e3fbba6a0426cd0 | true     | false     | false | 2026-05-01 15:45:33 | 2026-01-31 15:45:33 |

# 查看节点列表
docker exec -it headscale headscale nodes list

# 生成 API key（如果要用 Headplane 等 Web UI）
docker exec -it headscale headscale apikeys create --expiration 365d

# 查询 API key 相关信息
docker exec -it headscale headscale apikeys list
# ID | Prefix  | Expiration          | Created  
# 1  | zld_wI1 | 2027-01-31 15:50:01 | 2026-01-31 15:50:01

# 删除 API key
docker exec -it headscale headscale apikeys delete --prefix zld_wI1
ridwmYP.mcvuhdPhFX9_IrHsN2pbQSl93Wk8DB9t
# 查看帮助（所有命令）
docker exec -it headscale headscale --help
```

- 删除用户
```bash
docker exec -it headscale \
    headscale users destroy --name myuser

# Do you want to remove the user "myuser" (1) and any associated preauthkeys? [y/n] y
# Cannot destroy user: user not empty: node(s) found
```

- 删除节点
```bash
# 查看所有节点
docker exec -it headscale \
    headscale nodes list

# 删除节点
docker exec -it headscale \
    headscale nodes delete -i 1

# Do you want to remove the node tailscale? [y/n] y
# Node deleted
```

### Tailscale 使用
```bash
# 查看帮助
docker exec -it tailscale tailscale --help

# 查看节点
docker exec -it tailscale tailscale status

# 检测连接（只能测试 Docker 内部网络）
docker exec -it tailscale tailscale ping 100.64.0.2
```

# Headplane

[Office Web][11] - [Source][12] - [Docker Image][13] - [Document][14]

---

> [Headplane][1] 是一个功能齐全的 Headscale 网页界面，让你轻松管理节点、网络和 ACL。

[11]:https://headplane.net/
[12]:https://github.com/tale/headplane
[13]:https://github.com/tale/headplane/pkgs/container/headplane
[14]:https://headplane.net/install/docker

---

## 配置
1. 下载 `config.yaml` 配置文件
```bash
curl -o config/headplane.yaml https://raw.githubusercontent.com/tale/headplane/refs/heads/main/config.example.yaml
```

2. 更新配置
```bash
# server.cookie_secret
openssl rand -hex 16

# cookie_secure 设置为
# false

# headscale.url 设置为
# http://headscale:8080
```

**配置：**[`.env`](https://headplane.net/configuration/)
```bash
# 使用 .env 覆盖
HEADPLANE_LOAD_ENV_OVERRIDES=true

# 服务器密钥
# openssl rand -hex 16
HEADPLANE_SERVER__COOKIE_SECRET=

# 禁用 https
HEADPLANE_SERVER__COOKIE_SECURE=false

# headscale 服务
HEADPLANE_HEADSCALE__URL=http://headscale:8080
```

## 操作

### Headscale 使用
```bash
# 创建密钥
headscale apikeys create --expiration 90d
```
