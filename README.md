# awesome-compose

我的 `docker-compose` 仓库

[**Compose 规范**](https://github.com/compose-spec/compose-spec) ● 

[**Play With Docker**](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/jetsung/awesome-compose/refs/heads/main/filetas/compose.yml)

## 创建项目
```bash
# 创建项目，-p 则使用前面的部分，即 gotify 作为文件夹
make init n=https://hub.docker.com/r/gotify/server p=1
```

## 规范

- 每个服务都可以有一个 `.env` 文件
- 每个服务都有一个单独的 `compose.yml` 文件和 `compose.override.yml` 文件
- 每个服务都有一个单独的 `README.md` 文件

### 模板
- **README.md** 
```markdown
# 服务名

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [服务名][1] 

[1]:
[2]:
[3]:
[4]:
```

- **compose.override.yml**
```yaml
---

services:
  SERVER_NAME:
    env_file:
    - ./.env
```

- **.env**
  ```dotenv
  TZ=Asia/Shanghai
  SERV_PORT=
  ```

## 列表

- acme
- adminer
- aliyundrive
- aliyunpan
- asciinema
- bark
- bore
- chanify
- croc
- drone
- dufs
- emqx
- etcd
- ferron
- file-downloader
- filetas
- frp
- gitea
- gitlab-runner
- gotify
- hedgedoc
- joplin
- listmonk
- matomo
- mariadb
- meilisearch
- memos
- mindoc
- minio
- mysql
- nginx-php
- ntfy
- open-webui
- opengist
- openlist
- pgadmin
- pgadmin-db
- phpmyadmin
- phpmyadmin-db
- postgres
- qbittorrent
- qinglong
- rclone
- redis
- remark42
- rsshub
- rustpad
- shortener
- simple-http-server
- simple-torrent
- sonic
- stalwart
- static-web-server
- swagger
- syncthing
- transfer
- valkey
- vaultwarden
- vaultwarden-backup
- webdav
- wechat-devtools
- woodpecker
- wordpress
- xunsearch

## 提交与格式化

- 预提交工具 `pre-commit`  
  https://github.com/pre-commit/pre-commit  
  https://pre-commit.com/

  ```python
  pip install pre-commit
  # or uv
  uv tool install pre-commit

  # ever commit
  pre-commit install

  # format all files
  pre-commit run --all-files

  # format hook id
  pre-commit run <HOOK_ID>
  ```

- 格式化 `yml` 文件  
  https://github.com/jumanjihouse/pre-commit-hook-yamlfmt

## 仓库镜像

- https://git.jetsung.com/jetsung/awesome-compose
- https://framagit.org/jetsung/awesome-compose
- https://gitcode.com/jetsung/awesome-compose
- https://github.com/jetsung/awesome-compose
