# Meilisearch

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Meilisearch][1] 是一个快如闪电的搜索引擎，可轻松融入您的应用程序、网站和工作流程

[1]:https://www.meilisearch.com/
[2]:https://github.com/meilisearch/meilisearch
[3]:http://hub.docker.com/r/getmeili/meilisearch
[4]:https://www.meilisearch.com/docs/guides/docker

---

## [自托管](https://www.meilisearch.com/docs/learn/self_hosted/getting_started_with_self_hosted_meilisearch)
### [配置](https://www.meilisearch.com/docs/learn/self_hosted/configure_meilisearch_at_launch) 文件 `/etc/meilisearch.toml`
```bash
curl https://raw.githubusercontent.com/meilisearch/meilisearch/latest/config.toml > /etc/meilisearch.toml
```
`/etc/meilisearch.toml`
```bash
env = "production"
master_key = "MASTER_KEY"
db_path = "/var/lib/meilisearch/data"
dump_dir = "/var/lib/meilisearch/dumps"
snapshot_dir = "/var/lib/meilisearch/snapshots"
```
环境变量
```bash
# 配置文件路径（指向 config.toml）
MEILI_CONFIG_FILE_PATH=./config.toml

# 数据库路径（数据存储目录）
MEILI_DB_PATH=data.ms/

# 运行环境：development 或 production（默认 development，production 强制要求 master key）
MEILI_ENV=production

# HTTP 监听地址和端口（Docker 中建议用 0.0.0.0 以允许外部访问）
MEILI_HTTP_ADDR=0.0.0.0:7700

# 主密钥（生产环境必须设置，至少 16 字节强烈推荐）
# </dev/urandom tr -dc 'A-Za-z0-9' | fold -w 16 | head -n 16
MEILI_MASTER_KEY=

# 禁用内置遥测/分析
MEILI_NO_ANALYTICS=true

# 实验：无转储升级（升级版本时手动处理）
MEILI_EXPERIMENTAL_DUMPLESS_UPGRADE=

# 转储文件目录
MEILI_DUMP_DIR=dumps/

# 启动时导入的转储文件路径（.dump 文件）
MEILI_IMPORT_DUMP=

# 忽略转储文件缺失错误（布尔标志）
MEILI_IGNORE_MISSING_DUMP=

# 如果数据库已存在，忽略转储导入（布尔标志）
MEILI_IGNORE_DUMP_IF_DB_EXISTS=

# 快照存储目录
MEILI_SNAPSHOT_DIR=snapshots/

# 启动时导入的快照文件路径
MEILI_IMPORT_SNAPSHOT=

# 忽略快照文件缺失错误（布尔标志）
MEILI_IGNORE_MISSING_SNAPSHOT=

# 如果数据库已存在，忽略快照导入（布尔标志）
MEILI_IGNORE_SNAPSHOT_IF_DB_EXISTS=

# 实验：禁用快照压缩（加快创建速度，但文件更大）
MEILI_EXPERIMENTAL_NO_SNAPSHOT_COMPACTION=

# 计划快照创建间隔（秒），不设置禁用；86400=每天一次；仅设置变量名=每天一次
MEILI_SCHEDULE_SNAPSHOT=86400

# 日志级别：ERROR / WARN / INFO / DEBUG / TRACE / OFF
MEILI_LOG_LEVEL=INFO

# 实验：日志输出格式 human 或 json
MEILI_EXPERIMENTAL_LOGS_MODE=human

# 索引时最大内存使用量（字节或人类可读如 2Gb，留空使用默认 2/3 可用内存）
MEILI_MAX_INDEXING_MEMORY=

# 实验：减少索引内存使用（可能降低性能）
MEILI_EXPERIMENTAL_REDUCE_INDEXING_MEMORY_USAGE=

# 索引时最大线程数（留空使用默认一半可用线程）
MEILI_MAX_INDEXING_THREADS=

# HTTP 请求体最大大小（字节，默认 ~100MB）
MEILI_HTTP_PAYLOAD_SIZE_LIMIT=104857600

# 实验：搜索队列最大长度
MEILI_EXPERIMENTAL_SEARCH_QUEUE_SIZE=1000

# 实验：搜索查询嵌入缓存条目数（0=禁用）
MEILI_EXPERIMENTAL_EMBEDDING_CACHE_ENTRIES=0

# 任务 webhook URL（任务完成时通知）
MEILI_TASK_WEBHOOK_URL=

# 任务 webhook 认证头（Authorization Bearer Token）
MEILI_TASK_WEBHOOK_AUTHORIZATION_HEADER=

# 实验：限制单批次任务数量（提升稳定性）
MEILI_EXPERIMENTAL_MAX_NUMBER_OF_BATCHED_TASKS=

# 实验：限制批次任务总负载大小（字节，默认一半可用内存，上限 10GiB）
MEILI_EXPERIMENTAL_LIMIT_BATCHED_TASKS_TOTAL_SIZE=

# 实验：启用复制参数（用于集群环境）
MEILI_EXPERIMENTAL_REPLICATION_PARAMETERS=

# 实验：回退到旧设置索引器（2024 版之前）
MEILI_EXPERIMENTAL_NO_EDITION_2024_FOR_SETTINGS=

# 实验：启用搜索个性化（需 Cohere API key）
MEILI_EXPERIMENTAL_PERSONALIZATION_API_KEY=

# S3 存储相关（用于远程快照/转储）
MEILI_S3_BUCKET_URL=
MEILI_S3_BUCKET_REGION=
MEILI_S3_BUCKET_NAME=
MEILI_S3_SNAPSHOT_PREFIX=
MEILI_S3_ACCESS_KEY=
MEILI_S3_SECRET_KEY=
# 实验：S3 并发上传部分数（默认 10）
MEILI_EXPERIMENTAL_S3_MAX_IN_FLIGHT_PARTS=10
# 实验：S3 压缩（文档中提到但可能不完整）
MEILI_EXPERIMENTAL_S3_COMPRESSION=
```

### 生成密钥
```bash
</dev/urandom tr -dc 'A-Za-z0-9' | fold -w 16 | head -n 16
```

## 基本教程
```bash
# 设置别名（方便复制）
alias meili="curl -H 'Authorization: Bearer 你的master-key' -H 'Content-Type: application/json'"

# ------------------------------
# 1. 创建索引（相当于创建“表”）
meili -X PUT 'http://localhost:7700/indexes/movies'

# 2. 查看所有索引
meili 'http://localhost:7700/indexes'

# 3. 添加/更新文档（支持批量）
meili -X POST 'http://localhost:7700/indexes/movies/documents' \
  --data-binary @movies.json

# 示例 movies.json（可以直接保存测试）
[
  {"id": 1, "title": "盗梦空间", "year": 2010, "genres": ["科幻","悬疑"]},
  {"id": 2, "title": "阿丽塔：战斗天使", "year": 2019, "genres": ["科幻","动作"]},
  {"id": 3, "title": "流浪地球", "year": 2019, "genres": ["科幻","冒险"]}
]

# 4. 搜索（最核心）
meili 'http://localhost:7700/indexes/movies/search?q=地球'

# 5. 带过滤 + 分面
meili 'http://localhost:7700/indexes/movies/search?q=科幻&filter=year>2015&facets=genres'

# 6. 查看任务状态（添加文档是异步的）
meili 'http://localhost:7700/tasks'
```
