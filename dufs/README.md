# dufs

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [dufs][1] 是一个独特的多功能文件服务器，支持静态文件服务、文件上传、搜索、访问控制、 WebDAV 等功能。

## 功能特点

- 提供静态文件服务
- 支持将文件夹下载为 **ZIP** 文件
- 支持文件和文件夹上传（拖放操作）
- 支持文件创建、编辑和搜索
- 支持断点续传/部分上传和下载
- 支持访问控制
- 支持 **HTTPS**
- 支持 **WebDAV**
- 使用 **curl** 命令操作简单

[1]:https://github.com/sigoden/dufs
[2]:https://github.com/sigoden/dufs
[3]:https://hub.docker.com/r/sigoden/dufs
[4]:https://github.com/sigoden/dufs#install

---

```bash
Dufs is a distinctive utility file server - https://github.com/sigoden/dufs

Usage: dufs [OPTIONS] [serve-path]

参数:
  [serve-path]  Specific path to serve [default: .]
选项:
  -c, --config <file>       指定配置文件
  -b, --bind <addrs>        指定绑定地址或 Unix 套接字
  -p, --port <port>         指定监听端口 [默认值: 5000]
      --path-prefix <path>  指定路径前缀
      --hidden <value>      隐藏目录列表中的路径，例如 tmp,*.log,*.lock
  -a, --auth <rules>        添加身份验证规则，例如 user:pass@/dir1:rw,/dir2
  -A, --allow-all           允许所有操作
      --allow-upload        允许上传文件/文件夹
      --allow-delete        允许删除文件/文件夹
      --allow-search        允许搜索文件/文件夹
      --allow-symlink       允许符号链接到根目录外的文件/文件夹
      --allow-archive       允许将文件夹下载为归档文件
      --enable-cors         启用 **CORS**，设置 `Access-Control-Allow-Origin: *`
      --render-index        请求目录时提供 **index.html**，如果未找到 **index.html** 则返回 404
      --render-try-index    请求目录时提供 **index.html**，如果未找到 **index.html** 则返回目录列表
      --render-spa          服务单页应用（**SPA**，如 **React** 或 **Vue**）
      --assets <路径>       设置用于覆盖内置资源的资源目录路径
      --log-format <格式>   自定义 **HTTP** 日志格式
      --log-file <文件>     指定保存日志的文件，而非标准输出/标准错误
      --compress <级别>     设置 **ZIP** 压缩级别 [默认值: low] [可能值: none, low, medium, high]
      --completions <shell> 打印指定 shell 的补全脚本 [可能值: bash, elvish, fish, powershell, zsh]
      --tls-cert <路径>     **HTTPS** 服务的 **SSL/TLS** 证书路径
      --tls-key <路径>      **SSL/TLS** 证书的私钥路径
  -h, --help               打印帮助信息
  -V, --version            打印版本信息
```

## 示例

以只读模式服务当前工作目录：

```bash
dufs
```

允许所有操作（如上传、删除、搜索、创建、编辑等）：

```bash
dufs -A
```

仅允许上传操作：

```bash
dufs --allow-upload
```

服务指定目录：

```bash
dufs Downloads
```

服务单个文件：

```bash
dufs linux-distro.iso
```

服务单页应用（如 **React** 或 **Vue**）：

```bash
dufs --render-spa
```

服务带有 **index.html** 的静态网站：

```bash
dufs --render-index
```

要求用户名和密码：

```bash
dufs -a admin:123@/:rw
```

监听特定主机和端口：

```bash
dufs -b 127.0.0.1 -p 80
```

监听 **Unix** 套接字：

```bash
dufs -b /tmp/dufs.socket
```

使用 **HTTPS**：

```bash
dufs --tls-cert my.crt --tls-key my.key
```

## API

上传文件：

```bash
curl -T path-to-file http://127.0.0.1:5000/new-path/path-to-file
```

下载文件：

```bash
curl http://127.0.0.1:5000/path-to-file           # 下载文件
curl http://127.0.0.1:5000/path-to-file?hash      # 获取文件的 SHA256 哈希值
```

将文件夹下载为 **ZIP** 文件：

```bash
curl -o path-to-folder.zip http://127.0.0.1:5000/path-to-folder?zip
```

删除文件或文件夹：

```bash
curl -X DELETE http://127.0.0.1:5000/path-to-file-or-folder
```

创建目录：

```bash
curl -X MKCOL http://127.0.0.1:5000/path-to-folder
```

将文件或文件夹移动到新路径：

```bash
curl -X MOVE http://127.0.0.1:5000/path -H "Destination: http://127.0.0.1:5000/new-path"
```

列出或搜索目录内容：

```bash
curl http://127.0.0.1:5000?q=Dockerfile           # 搜索文件，类似于 `find -name Dockerfile`
curl http://127.0.0.1:5000?simple                 # 仅输出名称，类似于 `ls -1`
curl http://127.0.0.1:5000?json                   # 以 JSON 格式输出路径
```

使用身份验证（支持基本认证和摘要认证）：

```bash
curl http://127.0.0.1:5000/file --user user:pass                 # 基本认证
curl http://127.0.0.1:5000/file --user user:pass --digest        # 摘要认证
```

断点续传下载：

```bash
curl -C- -o file http://127.0.0.1:5000/file
```

断点续传上传：

```bash
upload_offset=$(curl -I -s http://127.0.0.1:5000/file | tr -d '\r' | sed -n 's/content-length: //p')
dd skip=$upload_offset if=file status=none ibs=1 | \
  curl -X PATCH -H "X-Update-Range: append" --data-binary @- http://127.0.0.1:5000/file
```

健康检查：

```bash
curl http://127.0.0.1:5000/__dufs__/health
```

## 高级主题

### 访问控制

**Dufs** 支持基于账户的访问控制。您可以通过 `--auth` 或 `-a` 选项控制用户对不同路径的权限。

```bash
dufs -a admin:admin@/:rw -a guest:guest@/
dufs -a user:pass@/:rw,/dir1 -a @/
```

1. 使用 `@` 分隔账户和路径。如果没有指定账户，则表示匿名用户。
2. 使用 `:` 分隔账户的用户名和密码。
3. 使用 `,` 分隔多个路径。
4. 使用路径后缀 `:rw`（读写）或 `:ro`（只读）设置权限，`:ro` 可省略。

- `-a admin:admin@/:rw`：`admin` 对所有路径具有完全读写权限。
- `-a guest:guest@/`：`guest` 对所有路径具有只读权限。
- `-a user:pass@/:rw,/dir1`：`user` 对 `/*` 具有读写权限，对 `/dir1/*` 具有只读权限。
- `-a @/`：所有路径对所有人公开，可查看和下载。

**注意：认证权限受限于 **Dufs** 的全局权限设置。** 如果未通过 `--allow-upload` 启用上传权限，即使账户被授予 `:rw` 读写权限，也无法上传。

#### 哈希密码

**Dufs** 支持使用 **SHA-512** 哈希密码。

创建哈希密码：

```bash
$ openssl passwd -6 123456 # 或 `mkpasswd -m sha-512 123456`
$6$tWMB51u6Kb2ui3wd$5gVHP92V9kZcMwQeKTjyTRgySsYJu471Jb1I6iHQ8iZ6s07GgCIO69KcPBRuwPE5tDq05xMAzye0NxVKuJdYs/
```

使用哈希密码：

```bash
dufs -a 'admin:$6$tWMB51u6Kb2ui3wd$5gVHP92V9kZcMwQeKTjyTRgySsYJu471Jb1I6iHQ8iZ6s07GgCIO69KcPBRuwPE5tDq05xMAzye0NxVKuJdYs/@/:rw'
```

> 哈希密码包含 `$6`，在某些 **shell** 中可能被解析为变量，因此需要使用**单引号**包裹。

哈希密码的两个重要注意事项：

1. **Dufs** 仅支持 **SHA-512** 哈希密码，确保密码字符串以 `$6$` 开头。
2. 使用哈希密码时，摘要认证无法正常工作。

### 隐藏路径

**Dufs** 支持通过 `--hidden <通配符>,...` 选项隐藏目录列表中的路径。

```bash
dufs --hidden .git,.DS_Store,tmp
```

> `--hidden` 中使用的通配符仅匹配文件和目录名称，而非完整路径。因此 `--hidden dir1/file` 是无效的。

```bash
dufs --hidden '.*'                          # 隐藏点文件
dufs --hidden '*/'                          # 隐藏所有文件夹
dufs --hidden '*.log,*.lock'                # 按文件扩展名隐藏
dufs --hidden '*.log' --hidden '*.lock'
```

### 日志格式

**Dufs** 支持通过 `--log-format` 选项自定义 **HTTP** 日志格式。

日志格式支持以下变量：

| 变量          | 描述                                              |
|---------------|--------------------------------------------------|
| $remote_addr  | 客户端地址                                        |
| $remote_user  | 认证提供的用户名                                  |
| $request      | 完整的原始请求行                                  |
| $status       | 响应状态码                                        |
| $http_        | 任意请求头字段，例如 $http_user_agent, $http_referer |

默认日志格式为 `'$remote_addr "$request" $status'`：

```bash
2022-08-06T06:59:31+08:00 INFO - 127.0.0.1 "GET /" 200
```

禁用 **HTTP** 日志：

```bash
dufs --log-format=''
```

记录用户代理：

```bash
dufs --log-format '$remote_addr "$request" $status $http_user_agent'
```

```bash
2022-08-06T06:53:55+08:00 INFO - 127.0.0.1 "GET /" 200 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36
```

记录远程用户：

```bash
dufs --log-format '$remote_addr $remote_user "$request" $status' -a /@admin:admin -a /folder1@user1:pass1
```

```bash
2022-08-06T07:04:37+08:00 INFO - 127.0.0.1 admin "GET /" 200
```

## 环境变量

所有选项都可以通过以 `DUFS_` 为前缀的环境变量设置。

```bash
[serve-path]                DUFS_SERVE_PATH="."
    --config <file>         DUFS_CONFIG=config.yaml
-b, --bind <addrs>          DUFS_BIND=0.0.0.0
-p, --port <port>           DUFS_PORT=5000
    --path-prefix <path>    DUFS_PATH_PREFIX=/dufs
    --hidden <value>        DUFS_HIDDEN=tmp,*.log,*.lock
-a, --auth <rules>          DUFS_AUTH="admin:admin@/:rw|@/"
-A, --allow-all             DUFS_ALLOW_ALL=true
    --allow-upload          DUFS_ALLOW_UPLOAD=true
    --allow-delete          DUFS_ALLOW_DELETE=true
    --allow-search          DUFS_ALLOW_SEARCH=true
    --allow-symlink         DUFS_ALLOW_SYMLINK=true
    --allow-archive         DUFS_ALLOW_ARCHIVE=true
    --enable-cors           DUFS_ENABLE_CORS=true
    --render-index          DUFS_RENDER_INDEX=true
    --render-try-index      DUFS_RENDER_TRY_INDEX=true
    --render-spa            DUFS_RENDER_SPA=true
    --assets <path>         DUFS_ASSETS=./assets
    --log-format <format>   DUFS_LOG_FORMAT=""
    --log-file <file>       DUFS_LOG_FILE=./dufs.log
    --compress <compress>   DUFS_COMPRESS=low
    --tls-cert <path>       DUFS_TLS_CERT=cert.pem
    --tls-key <path>        DUFS_TLS_KEY=key.pem
```

## 配置文件

您可以通过 `--config <配置文件路径>` 选项指定并使用配置文件。

以下是配置项示例：

```yaml
serve-path: '.'
bind: 0.0.0.0
port: 5000
path-prefix: /dufs
hidden:
  - tmp
  - '*.log'
  - '*.lock'
auth:
  - admin:admin@/:rw
  - user:pass@/src:rw,/share
  - '@/'  # 根据 YAML 规范，此处需要加引号
allow-all: false
allow-upload: true
allow-delete: true
allow-search: true
allow-symlink: true
allow-archive: true
enable-cors: true
render-index: true
render-try-index: true
render-spa: true
assets: ./assets/
log-format: '$remote_addr "$request" $status $http_user_agent'
log-file: ./dufs.log
compress: low
tls-cert: tests/data/cert.pem
tls-key: tests/data/key_pkcs1.pem
```

### 自定义用户界面

**Dufs** 允许用户通过自定义资源目录来个性化用户界面。

```bash
dufs --assets my-assets-dir/
```

> 如果您只需对当前界面进行微调，可以复制 **Dufs** 的 [assets](https://github.com/sigoden/dufs/tree/main/assets) 目录并进行相应修改。当前界面不使用任何框架，仅使用纯 **HTML**/**JS**/**CSS**。只要具备基本的 Web 开发知识，修改起来并不困难。

您的资源文件夹必须包含一个 `index.html` 文件。

`index.html` 可以使用以下占位符变量来获取内部数据：

- `__INDEX_DATA__`：目录列表数据
- `__ASSETS_PREFIX__`：资源 URL 前缀
