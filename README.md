# awesome-compose

我的 `docker-compose` 仓库

[**Compose 规范**](https://github.com/compose-spec/compose-spec) ● 

[**Play With Docker**](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/jetsung/awesome-compose/refs/heads/main/filetas/compose.yml)

## 待办

- [ ] 将 `docker-compose.yml` 改名为 `compose.yml`
- [ ] 重写 `README.md`

> 审阅至 `gitea`

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
- alist
- aliyundrive
- aliyunpan
- asciinema
- bark
- chanify
- croc
- drone
- emqx
- etcd
- filetas
- frp
- gitea
- gitlab-runner
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
- pgadmin
- phpmyadmin
- postgres
- qbittorrent
- qinglong
- rclone
- redis
- remark42
- rsshub
- rustpad
- shortener
- simple-torrent
- sonic
- stalwart
- swagger
- syncthing
- transfer
- valkey
- vaultwarden
- vaultwarden-backup
- video-downloader
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
