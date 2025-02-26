# redis

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [redis][1] 是一个开源的高性能键值存储数据库，它将数据存储在内存中以实现快速读写操作，同时支持将数据持久化到磁盘，以防止数据丢失。它支持多种数据结构，如字符串（Strings）、列表（Lists）、集合（Sets）、有序集合（Sorted Sets）、哈希表（Hashes）、流（Streams）、HyperLogLogs 以及位图（Bitmaps）等，广泛应用于缓存、消息队列、排行榜等多种场景。

[1]:https://redis.io/
[2]:https://github.com/redis/redis
[3]:https://hub.docker.com/_/redis
[4]:https://redis.io/docs/latest/

## 使用

- 永久存储
  ```bash
  -v /docker/host/dir:/data
  ```

- cli 命令行
  ```bash
  docker run -it --network some-network --rm redis redis-cli -h some-redis
  ```

- 指定配置文件
  ```bash
  docker run -v /myredis/conf:/usr/local/etc/redis --name myredis redis redis-server /usr/local/etc/redis/redis.conf
  ```
