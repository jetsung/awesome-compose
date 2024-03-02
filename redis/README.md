# Redis

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
