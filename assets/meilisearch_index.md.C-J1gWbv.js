import{_ as i,o as a,c as n,aj as l}from"./chunks/framework.DpVzuYkC.js";const g=JSON.parse('{"title":"Meilisearch","description":"","frontmatter":{},"headers":[],"relativePath":"meilisearch/index.md","filePath":"meilisearch/README.md"}'),h={name:"meilisearch/index.md"};function p(k,s,t,e,E,r){return a(),n("div",null,[...s[0]||(s[0]=[l(`<h1 id="meilisearch" tabindex="-1">Meilisearch <a class="header-anchor" href="#meilisearch" aria-label="Permalink to “Meilisearch”">​</a></h1><p><a href="https://www.meilisearch.com/" target="_blank" rel="noreferrer">Office Web</a> - <a href="https://github.com/meilisearch/meilisearch" target="_blank" rel="noreferrer">Source</a> - <a href="http://hub.docker.com/r/getmeili/meilisearch" target="_blank" rel="noreferrer">Docker Image</a> - <a href="https://www.meilisearch.com/docs/guides/docker" target="_blank" rel="noreferrer">Document</a></p><hr><blockquote><p><a href="https://www.meilisearch.com/" target="_blank" rel="noreferrer">Meilisearch</a> 是一个快如闪电的搜索引擎，可轻松融入您的应用程序、网站和工作流程</p></blockquote><hr><h2 id="自托管" tabindex="-1"><a href="https://www.meilisearch.com/docs/learn/self_hosted/getting_started_with_self_hosted_meilisearch" target="_blank" rel="noreferrer">自托管</a> <a class="header-anchor" href="#自托管" aria-label="Permalink to “自托管”">​</a></h2><h3 id="配置-文件-etc-meilisearch-toml" tabindex="-1"><a href="https://www.meilisearch.com/docs/learn/self_hosted/configure_meilisearch_at_launch" target="_blank" rel="noreferrer">配置</a> 文件 <code>/etc/meilisearch.toml</code> <a class="header-anchor" href="#配置-文件-etc-meilisearch-toml" aria-label="Permalink to “配置 文件 /etc/meilisearch.toml”">​</a></h3><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">curl</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> https://raw.githubusercontent.com/meilisearch/meilisearch/latest/config.toml</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> &gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> /etc/meilisearch.toml</span></span></code></pre></div><p><code>/etc/meilisearch.toml</code></p><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">env</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> =</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;production&quot;</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">master_key</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> =</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;MASTER_KEY&quot;</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">db_path</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> =</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;/var/lib/meilisearch/data&quot;</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">dump_dir</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> =</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;/var/lib/meilisearch/dumps&quot;</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">snapshot_dir</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> =</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;/var/lib/meilisearch/snapshots&quot;</span></span></code></pre></div><p>环境变量</p><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 配置文件路径（指向 config.toml）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_CONFIG_FILE_PATH</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">./config.toml</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 数据库路径（数据存储目录）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_DB_PATH</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">data.ms/</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 运行环境：development 或 production（默认 development，production 强制要求 master key）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_ENV</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">production</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># HTTP 监听地址和端口（Docker 中建议用 0.0.0.0 以允许外部访问）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_HTTP_ADDR</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">0.0.0.0:7700</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 主密钥（生产环境必须设置，至少 16 字节强烈推荐）</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># &lt;/dev/urandom tr -dc &#39;A-Za-z0-9&#39; | fold -w 16 | head -n 16</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_MASTER_KEY</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 禁用内置遥测/分析</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_NO_ANALYTICS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">true</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：无转储升级（升级版本时手动处理）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_DUMPLESS_UPGRADE</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 转储文件目录</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_DUMP_DIR</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">dumps/</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 启动时导入的转储文件路径（.dump 文件）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_IMPORT_DUMP</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 忽略转储文件缺失错误（布尔标志）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_IGNORE_MISSING_DUMP</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 如果数据库已存在，忽略转储导入（布尔标志）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_IGNORE_DUMP_IF_DB_EXISTS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 快照存储目录</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_SNAPSHOT_DIR</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">snapshots/</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 启动时导入的快照文件路径</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_IMPORT_SNAPSHOT</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 忽略快照文件缺失错误（布尔标志）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_IGNORE_MISSING_SNAPSHOT</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 如果数据库已存在，忽略快照导入（布尔标志）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_IGNORE_SNAPSHOT_IF_DB_EXISTS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：禁用快照压缩（加快创建速度，但文件更大）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_NO_SNAPSHOT_COMPACTION</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 计划快照创建间隔（秒），不设置禁用；86400=每天一次；仅设置变量名=每天一次</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_SCHEDULE_SNAPSHOT</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">86400</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 日志级别：ERROR / WARN / INFO / DEBUG / TRACE / OFF</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_LOG_LEVEL</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">INFO</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：日志输出格式 human 或 json</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_LOGS_MODE</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">human</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 索引时最大内存使用量（字节或人类可读如 2Gb，留空使用默认 2/3 可用内存）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_MAX_INDEXING_MEMORY</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：减少索引内存使用（可能降低性能）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_REDUCE_INDEXING_MEMORY_USAGE</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 索引时最大线程数（留空使用默认一半可用线程）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_MAX_INDEXING_THREADS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># HTTP 请求体最大大小（字节，默认 ~100MB）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_HTTP_PAYLOAD_SIZE_LIMIT</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">104857600</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：搜索队列最大长度</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_SEARCH_QUEUE_SIZE</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">1000</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：搜索查询嵌入缓存条目数（0=禁用）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_EMBEDDING_CACHE_ENTRIES</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">0</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 任务 webhook URL（任务完成时通知）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_TASK_WEBHOOK_URL</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 任务 webhook 认证头（Authorization Bearer Token）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_TASK_WEBHOOK_AUTHORIZATION_HEADER</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：限制单批次任务数量（提升稳定性）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_MAX_NUMBER_OF_BATCHED_TASKS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：限制批次任务总负载大小（字节，默认一半可用内存，上限 10GiB）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_LIMIT_BATCHED_TASKS_TOTAL_SIZE</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：启用复制参数（用于集群环境）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_REPLICATION_PARAMETERS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：回退到旧设置索引器（2024 版之前）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_NO_EDITION_2024_FOR_SETTINGS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：启用搜索个性化（需 Cohere API key）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_PERSONALIZATION_API_KEY</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># S3 存储相关（用于远程快照/转储）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_S3_BUCKET_URL</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_S3_BUCKET_REGION</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_S3_BUCKET_NAME</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_S3_SNAPSHOT_PREFIX</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_S3_ACCESS_KEY</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_S3_SECRET_KEY</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：S3 并发上传部分数（默认 10）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_S3_MAX_IN_FLIGHT_PARTS</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">10</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 实验：S3 压缩（文档中提到但可能不完整）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEILI_EXPERIMENTAL_S3_COMPRESSION</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span></code></pre></div><h3 id="生成密钥" tabindex="-1">生成密钥 <a class="header-anchor" href="#生成密钥" aria-label="Permalink to “生成密钥”">​</a></h3><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&lt;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">/dev/urandom tr -dc </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&#39;A-Za-z0-9&#39;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> |</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> fold</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -w</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 16</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> |</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> head</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -n</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 16</span></span></code></pre></div><h2 id="基本教程" tabindex="-1">基本教程 <a class="header-anchor" href="#基本教程" aria-label="Permalink to “基本教程”">​</a></h2><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 设置别名（方便复制）</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">alias</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> meili</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;curl -H &#39;Authorization: Bearer 你的master-key&#39; -H &#39;Content-Type: application/json&#39;&quot;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># ------------------------------</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 1. 创建索引（相当于创建“表”）</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">meili</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -X</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> PUT</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &#39;http://localhost:7700/indexes/movies&#39;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 2. 查看所有索引</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">meili</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &#39;http://localhost:7700/indexes&#39;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 3. 添加/更新文档（支持批量）</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">meili</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -X</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> POST</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &#39;http://localhost:7700/indexes/movies/documents&#39;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> \\</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">  --data-binary</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> @movies.json</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 示例 movies.json（可以直接保存测试）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">[</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  {</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;id&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: 1, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;title&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;盗梦空间&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;year&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: 2010, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;genres&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: [</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;科幻&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;悬疑&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]},</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  {</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;id&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: 2, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;title&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;阿丽塔：战斗天使&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;year&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: 2019, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;genres&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: [</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;科幻&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;动作&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]},</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  {</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;id&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: 3, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;title&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;流浪地球&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;year&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: 2019, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;genres&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: [</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;科幻&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;冒险&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 4. 搜索（最核心）</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">meili</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &#39;http://localhost:7700/indexes/movies/search?q=地球&#39;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 5. 带过滤 + 分面</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">meili</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &#39;http://localhost:7700/indexes/movies/search?q=科幻&amp;filter=year&gt;2015&amp;facets=genres&#39;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 6. 查看任务状态（添加文档是异步的）</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">meili</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &#39;http://localhost:7700/tasks&#39;</span></span></code></pre></div>`,16)])])}const c=i(h,[["render",p]]);export{g as __pageData,c as default};
