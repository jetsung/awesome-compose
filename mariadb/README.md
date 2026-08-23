# MariaDB

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [MariaDB][1] 是一种开源数据库管理系统，它是 MySQL 的一个分支。它由 MySQL 的创始人之一 Monty Widenius 发起，旨在保持与 MySQL 的兼容性，同时提供更多的功能和性能优化。MariaDB 以其高性能、可扩展性和社区支持而受到广泛欢迎，适用于各种规模的企业和项目。

[1]:https://mariadb.org/
[2]:https://github.com/MariaDB/server
[3]:https://hub.docker.com/_/mariadb
[4]:https://mariadb.org/documentation/

---

## 资源限制与内存防护优化

本栈针对 **VPS 等小内存宿主**做了资源隔离优化，避免 MariaDB 因慢查询、连接堆积或缓冲池过大而占满宿主资源，导致整台机器卡死。

优化在 `compose.override.yaml` 中完成，分为两层防护：

### 1. 容器层限制（兜底，绝不拖垮宿主机）

```yaml
mem_limit: 1g          # 内存硬上限，超出即被 OOM 终止
mem_reservation: 512m  # 内存软下限（调度参考）
cpus: "1.50"           # CPU 硬上限，最多使用 1.5 个核心
pids_limit: 200        # 限制进程/线程总数，防失控
```

- `mem_limit` 是硬天花板，超限直接杀进程，不会影响其他服务。
- `cpus` 限制 CPU 占用，避免慢查询打满所有核心。
- `pids_limit` 防连接风暴 / 线程失控引发系统雪崩。

### 2. 实例层参数（从源头压住内存增长）

通过 `command` 覆盖启动参数：

```yaml
command:
  - mysqld
  - --innodb-buffer-pool-size=320M   # 缓冲池 < mem_limit，防 OOM
  - --max-connections=100            # 限制最大连接数
  - --max-user-connections=80       # 单账号连接上限，预留管理员通道
  - --sort-buffer-size=512K         # 单连接排序缓冲，默认 2M→收紧
  - --read-buffer-size=256K
  - --read-rnd-buffer-size=512K
  - --join-buffer-size=512K
  - --tmp-table-size=32M            # 内存临时表上限，超限转磁盘
  - --max-allowed-packet=16M        # 单包上限，防大包占内存
  - --wait-timeout=300              # 非交互连接空闲 300s 回收
  - --interactive-timeout=300       # 交互连接空闲 300s 回收
```

### 参数计算与调参方法

**innodb_buffer_pool_size（缓冲池）**
核心原则：它只是 MariaDB 内存里最大的一块，容器总内存 = 缓冲池 + 每连接内存 + 临时表/排序 + 系统开销，因此必须明显小于 `mem_limit`。

```
innodb_buffer_pool_size ≈ mem_limit × 0.6   # 连接多则继续下压
```

参考对照（基于本栈 `mem_limit=1g`）：

| 容器 mem_limit | 建议 buffer pool |
| --- | --- |
| 512m | 192m~256m |
| 1g   | 256m~384m（本栈取 320M） |
| 2g   | 1g~1.4g |

**max_connections（最大连接数）**
每个连接约占用 2~4MB 常驻内存（排序/连接/读缓冲等）。最坏情况核算：

```
缓冲池 + max_connections × 每连接开销 + 临时表等 < mem_limit
```

本栈：`320M + 100 × ~2MB + 临时表 ≈ 600M < 1g`，安全。

- 连接确实多 → 可上到 `150`，但不超出 `(mem_limit - buffer_pool - 200M) / 4MB`。
- 小鸡 / 更保守 → 设 `50`。
- 若应用使用连接池，连接池上限应压在 `max-connections` 之下。

**每连接缓冲（sort / read / join buffer）**
这些是**每连接按需分配**的，默认值偏大（尤其 `sort_buffer_size` 默认 2M），并发高时会放大内存占用。统一压到 `512K` 量级，单连接常驻开销可从 ~4MB 降到 ~2MB 以内。

**空闲超时（wait_timeout / interactive_timeout）**
空闲连接自动回收，防止连接泄漏 / 池化不当导致连接数缓慢堆积吃光内存。长事务或监听类长连接场景可保持 300s，依赖连接池主动释放。

### 生效方式

修改后重启栈：

```bash
docker compose up -d
```

### 验证

```bash
# 查看实际生效参数
docker compose exec mariadb mysql -uroot -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"
docker compose exec mariadb mysql -uroot -p -e "SHOW VARIABLES LIKE 'max_connections';"

# 查看容器资源上限
docker stats --no-stream mariadb
```

