# openssh-server

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [openssh-server][1] 是一个沙箱环境，允许 SSH 访问，但不向整个服务器提供密钥。通过私钥授予 ssh 访问通常意味着对服务器给予完全访问权限。该容器创建了一个有限且沙箱化的环境，其他人可以 ssh 访问。用户只能访问该容器中映射的文件夹和运行的进程。

[1]:https://github.com/linuxserver/docker-openssh-server
[2]:https://github.com/linuxserver/docker-openssh-server
[3]:https://hub.docker.com/r/linuxserver/openssh-server
[4]:https://docs.linuxserver.io/images/docker-openssh-server/

---

## 快速使用

1. 首次启动，初始化配置信息
```bash
docker compose up -d
docker compose down
```

2. 移除 `AllowTcpForwarding` 以支持转发
```bash
sed -i "/AllowTcpForwarding/d" data/sshd/sshd_config
```

3. 启动
```bash
docker compose up -d
```

4. 添加公钥以支持跳板
```bash
cat ~/.ssh/id_ed25519.pub
```
复制其值，并粘贴至 `data/.ssh/authorized_keys`
```bash
echo '$KEY' >> data/.ssh/authorized_keys
```

## 配置
1. 支持 TCP 转发：
```bash
sed -i "s#^AllowTcpForwarding.*#AllowTcpForwarding yes#g" data/sshd/sshd_config
```
建议
```bash
sed -i "/AllowTcpForwarding/d" data/sshd/sshd_config
```

2. 其它配置

```bash
# 允许 TCP 端口转发（包括本地 -L、远程 -R、动态 -D）
AllowTcpForwarding yes

# 允许 SSH Agent 转发（如果需要从跳板机进一步使用你的本地密钥）
AllowAgentForwarding yes

# 远程端口转发（-R）默认只绑定到 loopback（安全）
# 默认值就是 no，保持默认即可（不需要显式写 no）
# 如果你确实需要从外部访问远程转发端口，再改为 yes 或 clientspecified
GatewayPorts no

# 限制本地端口转发（-L）允许连接的目标地址/端口
# 默认是允许所有（any），这里示例限制只允许 localhost 的某些端口（根据需求调整）
# 如果不需要限制，可以直接删除这行或设为 any
PermitOpen localhost:80 localhost:443 any:22
# 示例含义：只允许转发到本机的 80、443 和任意主机的 22 端口
# 用 none 可以完全禁止本地转发（但通常不推荐）
# PermitOpen none
```

## 使用方式
为了协助你利用此镜像创建容器，你既可以选择使用 docker - compose，也可以使用 docker 命令行工具（cli）。

>[!注意]
>除非参数标注为“可选”，否则该参数是*必填项*，必须给出相应的值。

### docker - compose（推荐，[点击此处查看更多详情](https://docs.linuxserver.io/general/docker-compose)）

```yaml
---
服务：
  openssh - server：
    镜像：lscr.io/linuxserver/openssh - server:latest
    容器名称：openssh - server
    主机名：openssh - server  #可选
    环境变量：
      - PUID = 1000
      - PGID = 1000
      - TZ = Etc/UTC
      - PUBLIC_KEY = yourpublickey  #可选
      - PUBLIC_KEY_FILE = /path/to/file  #可选
      - PUBLIC_KEY_DIR = /path/to/directory/containing/_only_/pubkeys  #可选
      - PUBLIC_KEY_URL = https://github.com/username.keys  #可选
      - SUDO_ACCESS = false  #可选
      - PASSWORD_ACCESS = false  #可选
      - USER_PASSWORD = password  #可选
      - USER_PASSWORD_FILE = /path/to/file  #可选
      - USER_NAME = linuxserver.io  #可选
      - LOG_STDOUT =   #可选
    卷挂载：
      - /path/to/openssh - server/config:/config
    端口映射：
      - 2222:2222
    重启策略：除非手动停止，否则自动重启
```

### docker 命令行工具（[点击此处查看更多详情](https://docs.docker.com/engine/reference/commandline/cli/)）

```bash
docker run -d \
  --name = openssh - server \
  --hostname = openssh - server `#可选` \
  -e PUID = 1000 \
  -e PGID = 1000 \
  -e TZ = Etc/UTC \
  -e PUBLIC_KEY = yourpublickey `#可选` \
  -e PUBLIC_KEY_FILE = /path/to/file `#可选` \
  -e PUBLIC_KEY_DIR = /path/to/directory/containing/_only_/pubkeys `#可选` \
  -e PUBLIC_KEY_URL = https://github.com/username.keys `#可选` \
  -e SUDO_ACCESS = false `#可选` \
  -e PASSWORD_ACCESS = false `#可选` \
  -e USER_PASSWORD = password `#可选` \
  -e USER_PASSWORD_FILE = /path/to/file `#可选` \
  -e USER_NAME = linuxserver.io `#可选` \
  -e LOG_STDOUT =  `#可选` \
  -p 2222:2222 \
  -v /path/to/openssh - server/config:/config \
  --restart unless - stopped \
  lscr.io/linuxserver/openssh - server:latest
```

## 参数说明
容器是通过在运行时传递的参数来进行配置的（就像上面那些参数）。这些参数用冒号分隔，分别代表 `<外部端口>:<内部端口>` 等含义。比如说，`-p 8080:80` 这个参数，它的作用是将容器内部的 80 端口映射到容器外部主机 IP 的 8080 端口，这样就能通过主机的 8080 端口访问容器内 80 端口提供的服务。

| 参数 | 作用 |
| :----: | --- |
| `--hostname=` | 可自行选择定义主机名。 |
| `-p 2222:2222` | 这是 ssh 服务的端口映射，将容器内的 2222 端口映射到主机的 2222 端口。 |
| `-e PUID = 1000` | 用于指定用户 ID - 具体解释见下文。 |
| `-e PGID = 1000` | 用于指定组 ID - 具体解释见下文。 |
| `-e TZ = Etc/UTC` | 用于指定使用的时区，具体时区列表可查看 [这里](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)。 |
| `-e PUBLIC_KEY = yourpublickey` | 可选的 ssh 公钥，这个公钥会自动添加到授权密钥文件（authorized_keys）中。 |
| `-e PUBLIC_KEY_FILE = /path/to/file` | 可以选择指定一个包含公钥的文件（适用于 Docker 机密机制）。 |
| `-e PUBLIC_KEY_DIR = /path/to/directory/containing/_only_/pubkeys` | 可以选择指定一个只包含公钥的目录（适用于 Docker 机密机制）。 |
| `-e PUBLIC_KEY_URL = https://github.com/username.keys` | 可以选择指定一个包含公钥的 URL。 |
| `-e SUDO_ACCESS = false` | 如果设置为 `true`，那么 `linuxserver.io` 这个 ssh 用户就会拥有 sudo 权限。要是没有设置 `USER_PASSWORD`，那么该用户就可以无密码使用 sudo 权限。 |
| `-e PASSWORD_ACCESS = false` | 如果设置为 `true`，就允许通过用户名/密码的方式进行 ssh 访问。同时你可能还需要设置 `USER_PASSWORD` 或者 `USER_PASSWORD_FILE`。 |
| `-e USER_PASSWORD = password` | 可以选择为 `linuxserver.io` 这个 ssh 用户设置 sudo 密码。要是没有设置这个参数或者 `USER_PASSWORD_FILE`，但 `SUDO_ACCESS` 设置为 `true`，那么该用户就可以无密码使用 sudo 权限。 |
| `-e USER_PASSWORD_FILE = /path/to/file` | 可以选择指定一个包含密码的文件。这个设置会优先于 `USER_PASSWORD` 参数（适用于 Docker 机密机制）。 |
| `-e USER_NAME = linuxserver.io` | 可以选择指定一个用户名（默认是 `linuxserver.io`）。 |
| `-e LOG_STDOUT = ` | 如果设置为 `true`，日志就会输出到标准输出，而不是写入文件。 |
| `-v /config` | 这里挂载的目录包含了所有相关的配置文件。 |

## 通过文件设置环境变量（Docker 机密）
你可以在环境变量前加上特殊前缀 `FILE__`，从而从文件中读取变量值来设置环境变量。

举个例子：

```bash
-e FILE__MYVAR = /run/secrets/mysecretvariable
```

这样就会根据 `/run/secrets/mysecretvariable` 文件的内容来设置环境变量 `MYVAR`。

## 运行应用程序时的文件权限掩码设置
对于我们所有的镜像，你都可以通过使用可选的 `-e UMASK = 022` 设置，来修改容器内启动服务的默认文件权限掩码。
要注意，文件权限掩码和 chmod 不一样，它是根据设定值从权限中减去相应部分，而不是增加权限。在寻求技术支持之前，建议先阅读 [这里](https://en.wikipedia.org/wiki/Umask) 的相关内容。

## 用户和组标识符
当使用卷挂载（`-v` 标志）时，主机操作系统和容器之间可能会出现权限方面的问题。我们通过允许你指定用户 `PUID` 和组 `PGID`，来避免这类问题。
只要确保主机上的卷目录所有者和你指定的用户一致，权限问题就不会出现了。

在这个例子中 `PUID = 1000` 且 `PGID = 1000`，你可以使用 `id your_user` 命令来查看自己的 `PUID` 和 `PGID`，操作如下：

```bash
id your_user
```

示例输出如下：

```text
uid = 1000(your_user) gid = 1000(your_user) groups = 1000(your_user)
```
