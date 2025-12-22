# Valkey

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Valkey][1] 是一种高性能数据结构服务器，主要为键/值工作负载提供服务。它支持各种原生结构和可扩展的插件系统，用于添加新的数据结构和访问模式。

[1]:https://valkey.io/
[2]:https://github.com/valkey-io/valkey
[3]:https://hub.docker.com/r/valkey/valkey
[4]:https://valkey.io/docs/

## 使用

- 永久存储
  ```bash
  -v /docker/host/dir:/data
  ```

- cli 命令行
  ```bash
  docker run -it --network some-network --rm valkey valkey-cli  -h some-valkey
  ```

- 指定配置文件
  ```bash
  docker run -v /myvalkey/conf:/usr/local/etc/valkey --name myvalkey valkey valkey-server /usr/local/etc/valkey/valkey.conf
  ```
