# listmonk

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [listmonk][1] 是一个自托管的、高性能的单向邮件列表和新闻通讯管理器。它作为独立的二进制文件提供，唯一的依赖项是 Postgres 数据库。

[1]:https://listmonk.app/
[2]:https://github.com/knadh/listmonk
[3]:https://hub.docker.com/r/listmonk/listmonk
[4]:https://listmonk.app/docs/

---

listmonk is a standalone, self-hosted, newsletter and mailing list manager. It is fast, feature-rich, and packed into a single binary. It uses a PostgreSQL (⩾ 12) database as its data store.

Visit [listmonk.app](https://listmonk.app) for more info. Check out the [**live demo**](https://demo.listmonk.app).

## Installation

### Docker

The latest image is available on DockerHub at [`listmonk/listmonk:latest`](https://hub.docker.com/r/listmonk/listmonk/tags?page=1&ordering=last_updated&name=latest).
Download and use the sample [docker-compose.yaml](https://github.com/knadh/listmonk/blob/master/docker-compose.yml).

```shell
# Download the compose file to the current directory.
curl -LO https://github.com/knadh/listmonk/raw/master/docker-compose.yml

# Run the services in the background.
docker compose up -d
```

Visit `http://localhost:9000`

See [installation docs](https://listmonk.app/docs/installation)

---

### Binary

- Download the [latest release](https://github.com/knadh/listmonk/releases) and extract the listmonk binary.
- `./listmonk --new-config` to generate config.toml. Edit it.
- `./listmonk --install` to setup the Postgres DB (or `--upgrade` to upgrade an existing DB. Upgrades are idempotent and running them multiple times have no side effects).
- Run `./listmonk` and visit `http://localhost:9000`

See [installation docs](https://listmonk.app/docs/installation)
