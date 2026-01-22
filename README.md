# awesome-compose

我的 `Docker Compose` 自托管服务

[**Compose 规范**](https://github.com/compose-spec/compose-spec) ● [**Docker Compose 语法**](https://docs.docker.com/reference/compose-file/)

[**Play With Docker**](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/jetsung/awesome-compose/refs/heads/main/filetas/compose.yaml)

## 创建项目
```bash
# 创建项目，-p 则使用前面的部分，即 gotify 作为文件夹
make init n=https://hub.docker.com/r/gotify/server p=1
```

## 规范

- 每个服务都可以有一个 `.env` 文件
- 每个服务都有一个单独的 `compose.yaml` 文件和 `compose.override.yaml` 文件
- 每个服务都有一个单独的 `README.md` 文件

### 模板
- **README.md**
```markdown
# 服务名

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [服务名][1]

[1]:
[2]:
[3]:
[4]:
```

- **`compose.override.yaml`**
```yaml
---

services:
  SERVER_NAME:
    # ports: ! reset []
    ports: !override
      - ${SERV_PORT:-8080}:8080
    volumes:
      - data:/data
```

- **`.env`**
```dotenv
TZ=Asia/Shanghai
SERV_PORT=
```

## 列表

| 状态 | 项目名称 | 描述 |
| --- | --- | --- |
| 在用 | [acme](./acme/) | 自动化证书管理环境，用于自动获取和续期 SSL/TLS 证书 |
| | [adminer](./adminer/) | 开源数据库管理工具，允许用户通过Web界面管理数据库，如MySQL、SQLite等 |
| | [aliyundrive](./aliyundrive/) | 阿里云盘 WebDAV 服务，将阿里云盘挂载为标准 WebDAV 文件系统 |
| 在用 | [asciinema](./asciinema/) | 用于录制和分享终端会话的工具，将终端操作录制成可播放的动画 |
| | [bark](./bark/) | 注重隐私、安全可控的自定义通知推送工具 |
| 在用 | [bore](./bore/) | 简单易用的内网穿透工具，用于将本地服务暴露到公网 |
| | [blinko](./blinko/) | 下一代开源 AI 驱动的卡片笔记，旨在帮助你快速捕捉和整理灵感，确保创意永不枯竭 |
| | [chanify](./chanify/) | 安全的消息推送服务，支持多平台通知推送 |
| 在用 | [claude-code-router](./claude-code-router/) | 代码路由工具 |
| | [cloudflared](./cloudflared/) | cloudflared 是 Cloudflare 隧道客户端。将 Cloudflare 网络的流量代理到你的起源节点。 |
| 在用 | [croc](./croc/) | 跨平台文件传输工具，可在两台计算机之间安全地传输文件 |
| | [drone](./drone/) | 基于容器技术的持续集成和持续部署(CI/CD)平台 |
| 在用 | [dufs](./dufs/) | 基于 HTTP 的文件服务器，支持文件上传、下载和目录浏览 |
| 在用 | [emqx](./emqx/) | 大规模分布式物联网接入平台，高性能、可扩展的 MQTT 消息服务器 |
| | [etcd](./etcd/) | 高可用的分布式键值存储系统，常用于配置共享和服务发现 |
| 在用 | [ferron](./ferron/) | 基于 Zola 的静态网站生成器 |
| 在用 | [file-downloader](./file-downloader/) | 文件下载工具 |
| 在用 | [filetas](./filetas/) | 文件管理和分享服务 |
| | [frp](./frp/) | 专注内网穿透的高性能反向代理应用 |
| 在用 | [gitea](./gitea/) | 轻量级的 DevOps 平台软件，提供 Git 托管、代码审查、团队协作等功能 |
| 在用 | [gitlab](./gitlab/) | 完整的企业级 DevOps 平台，提供代码托管、CI/CD、项目管理等完整开发流程 |
| 在用 | [gitlab-runner](./gitlab-runner/) | GitLab CI/CD 的执行器，用于运行 CI/CD 任务 |
| 在用 | [gotify](./gotify/) | 简单的发送和接收消息的服务器，用于实时消息推送 |
| | [hedgedoc](./hedgedoc/) | 开源的协作文档编辑器，支持 Markdown 编辑 |
| | [hoppscotch](./hoppscotch/) | 轻量级的 API 开发生态系统，用于测试和调试 API |
| | [joplin](./joplin/) | 开源的笔记和待办事项应用程序，支持端到端加密 |
| 在用 | [komodo](./komodo/) | 现代化的代码编辑器 |
| 在用 | [linkding](./linkding/) | 简单、快速的自托管书签服务 |
| | [litellm](./litellm/) | 非常实用的开源 Python 库，使用 OpenAI 的输入/输出格式，调用 100+ 个大型语言模型 |
| | [listmonk](./listmonk/) | 高性能、可自托管的邮件通讯和营销自动化工具 |
| | [mamoto](./mamoto/) | 提供网站分析服务的开源平台 |
| | [mariadb](./mariadb/) | 社区开发的 MySQL 关系型数据库管理系统分支 |
| 在用 | [meilisearch](./meilisearch/) | 快速、易于使用的搜索引擎 |
| 在用 | [memos](./memos/) | 隐私优先、自托管的知识库 |
| 在用 | [mindoc](./mindoc/) | 基于 Go 的简约文档管理系统 |
| 在用 | [minio](./minio/) | 高性能的对象存储服务，兼容 Amazon S3 API |
| | [mysql](./mysql/) | 世界最流行的开源关系型数据库管理系统之一 |
| | [nginx-php](./nginx-php/) | 集成 Nginx 和 PHP-FPM 的 Web 服务器环境 |
| | [ntfy](./ntfy/) | 简单易用的自托管通知服务，用于推送消息到手机或桌面 |
| 在用 | [ollama](./ollama/) | 轻量级、可扩展的大语言模型运行时，支持本地运行和 GPU 加速 |
| 在用 | [open-webui](./open-webui/) | 现代化的 Web UI 界面 |
| 在用 | [opengist](./opengist/) | 自托管的代码片段管理服务 |
| 在用 | [openlist](./openlist/) | 网盘列表管理工具 |
| 在用 | [openssh-server](./openssh-server/) | SSH 服务器，用于远程安全连接 |
| | [pgadmin](./pgadmin/) | PostgreSQL 数据库的开源管理和开发平台 |
| | [pgadmin-db](./pgadmin-db/) | 为 pgAdmin 提供数据库支持的服务 |
| | [phpmyadmin](./phpmyadmin/) | 以 Web 为基础的 MySQL 数据库管理工具 |
| | [phpmyadmin-db](./phpmyadmin-db/) | 为 phpMyAdmin 提供数据库支持的服务 |
| 在用 | [postgres](./postgres/) | 强大的开源对象关系数据库系统 |
| 在用 | [qbittorrent](./qbittorrent/) | 跨平台的 BitTorrent 客户端 |
| | [qinglong](./qinglong/) | 定时任务管理平台 |
| | [rclone](./rclone/) | 命令行程序，用于管理云存储上的文件 |
| 在用 | [rclone-backup](./rclone-backup/) | 基于 rclone 的备份解决方案 |
| | [redis](./redis/) | 开源的内存数据结构存储，用作数据库、缓存和消息中间件 |
| | [remark42](./remark42/) | 自托管的评论引擎，用于博客和其他出版物 |
| | [rsshub](./rsshub/) | 轻量级、易于扩展的 RSS 生成器 |
| 在用 | [rustpad](./rustpad/) | 受 Google Docs 启发的协作文本编辑器 |
| 在用 | [shortener](./shortener/) | URL 缩短服务 |
| | [simple-http-server](./simple-http-server/) | 简单的 HTTP 服务器 |
| | [simple-torrent](./simple-torrent/) | 简单的 Torrent 客户端 |
| | [sonic](./sonic/) | 快速、轻量级的搜索引擎 |
| | [stalwart](./stalwart/) | 一套完整的邮件套件 |
| 在用 | [static-web-server](./static-web-server/) | 高性能的静态 Web 服务器 |
| 在用 | [swagger](./swagger/) | 用于设计、构建和文档化 RESTful API 的工具 |
| | [syncthing](./syncthing/) | 连续的文件同步程序，用于在不同设备间同步文件 |
| | [transfer](./transfer/) | 文件传输服务 |
| | [valkey](./valkey/) | 开源的、内存中的数据存储，用于高速数据处理 |
| 在用 | [vaultwarden](./vaultwarden/) | Bitwarden 密码管理器的非官方服务器实现 |
| 在用 | [vaultwarden-backup](./vaultwarden-backup/) | 为 Vaultwarden 提供备份功能的服务 |
| | [wingetty](./wingetty/) | Windows 终端工具 |
| | [woodpecker](./woodpecker/) | 简单、强大、轻量级的 CI/CD 引擎 |
| 在用 | [wordpress](./wordpress/) | 功能强大的开源内容管理系统 |
| | [xunsearch](./xunsearch/) | 免费开源的中文全文检索解决方案 |

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

[MyCode](https://git.jetsung.com/jetsung/awesome-compose) ● [Framagit](https://framagit.org/jetsung/awesome-compose) ● [GitCode](https://gitcode.com/jetsung/awesome-compose) ● [GitHub](https://github.com/jetsung/awesome-compose)
