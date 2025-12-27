# redis

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [redis][1] 是一个开源的高性能键值存储数据库，它将数据存储在内存中以实现快速读写操作，同时支持将数据持久化到磁盘，以防止数据丢失。它支持多种数据结构，如字符串（Strings）、列表（Lists）、集合（Sets）、有序集合（Sorted Sets）、哈希表（Hashes）、流（Streams）、HyperLogLogs 以及位图（Bitmaps）等，广泛应用于缓存、消息队列、排行榜等多种场景。

[1]:https://redis.io/
[2]:https://github.com/redis/redis
[3]:https://hub.docker.com/_/redis
[4]:https://github.com/docker-library/docs/tree/master/redis

## 使用

### 启动 Redis 实例

以最简单的方式启动 Redis：

```bash
$ docker run --name some-redis -d redis
```

此命令会以默认配置启动 Redis 容器。

### 使用本地 Redis 配置文件启动

如果要使用自己的 Redis 配置文件启动容器，可以使用以下命令：

```bash
$ docker run --name some-redis -v /myredis/conf/redis.conf:/usr/local/etc/redis/redis.conf -d redis redis-server /usr/local/etc/redis/redis.conf
```

> 注意：由于 Docker 容器默认以 `redis` 用户身份运行，因此确保挂载的配置文件可被 `redis` 用户读取非常重要（通常将配置文件权限设为 `0644` 即可）。

### 将持久化数据和配置挂载为主机目录

将 Redis 数据和配置保存在主机上，以便在容器停止或重启后仍能保留：

```bash
$ docker run --name some-redis -v /myredis/conf/redis.conf:/usr/local/etc/redis/redis.conf -v /myredis/data:/data -d redis redis-server /usr/local/etc/redis/redis.conf
```

### 连接到 Redis 容器

#### 从同一主机上的其他容器

```bash
$ docker run -it --network some-network --rm redis redis-cli -h some-redis
```

#### 从主机本身

假设你已经将 Redis 容器的端口 6379（默认端口）暴露给主机：

```bash
$ docker run --name some-redis -d -p 6379:6379 redis
```

然后可以使用 `redis-cli` 连接：

```bash
$ redis-cli -h localhost
```

> 注意：官方 `redis` 镜像默认不包含 `redis-cli`，你需要在主机上安装 Redis，或者使用另一个容器来运行 `redis-cli`。例如：

```bash
$ docker run -it --network host --rm redis redis-cli -h localhost
```

### Redis 配置

Redis 有两种启用持久化的方法：RDB（快照）和 AOF（追加文件）。

对于 RDB，你可以使用 `SAVE` 或 `BGSAVE` 命令，也可以在配置文件中使用 `save` 指令。如果使用 Docker 挂载 `/data` 目录，Redis 生成的 RDB 文件（如 `dump.rdb`）将保存在该挂载点中。

对于 AOF，可以在配置文件中设置 `appendonly yes`，Redis 会将每次写操作追加到 AOF 文件（默认为 `appendonly.aof`）。

> 注意：在容器中使用 Redis 持久化时，务必将 `/data` 目录挂载到主机或持久化卷，否则数据会在容器删除时丢失。

### Docker Compose 示例

以下是一个简单的 `docker-compose.yml` 示例：

```yaml
services:
  redis:
    image: redis
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf
      - ./data:/data
    command: redis-server /usr/local/etc/redis/redis.conf
```

启动服务：

```bash
$ docker-compose up -d
```
