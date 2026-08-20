# Flarum

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Flarum][1] 是一个设计简洁、优雅的开源论坛软件，让在线社区讨论变得简单愉悦。

[1]:https://flarum.org/
[2]:https://github.com/forkdo/docker-flarum
[3]:https://hub.docker.com/r/forkdo/flarum
[4]:https://docker-flarum.ooos.top/

---

> 本文档基于本站实际环境编写：Flarum 运行在 Docker（Komodo 管理），数据库使用外部 mysql 栈，缓存/会话/队列使用 valkey 栈，与旧版「宿主机直接部署」相比改用了容器化方式。

## 目录

1. [架构总览](#1-架构总览)
2. [快速开始](#2-快速开始)
3. [文件与目录结构](#3-文件与目录结构)
4. [服务配置详解](#4-服务配置详解)
5. [国内镜像源配置（腾讯云）](#5-国内镜像源配置腾讯云)
6. [扩展管理](#6-扩展管理)
7. [自定义配置](#7-自定义配置)
8. [日常运维](#8-日常运维)
9. [常见问题与踩坑记录](#9-常见问题与踩坑记录)

---

## 1. 架构总览

```
                    宿主机 (腾讯云)
┌────────────────────────────────────────────────────────────┐
│                                                             │
│  ┌──────────────┐   sharenet (172.19.0.0/16)  ┌──────────┐ │
│  │   flarum     │◄────────────────────────────►│  valkey  │ │
│  │ 172.19.0.243 │     扩展/会话/缓存/队列      │ .0.247   │ │
│  │ (本栈)       │                              │ (外部栈)  │ │
│  └──────┬───────┘                              └──────────┘ │
│         │ host.docker.internal:3306 (宿主机端口映射)          │
│         ▼                                                  │
│  ┌──────────────┐                                          │
│  │    mysql     │  数据库 flarum，表前缀 bbs_               │
│  │  (外部栈)    │                                          │
│  └──────────────┘                                          │
└────────────────────────────────────────────────────────────┘
```

- **flarum**：本站目录 `/etc/komodo/stacks/flarum`，镜像 `ghcr.io/forkdo/flarum:edge`（Flarum v2.0）。
- **mysql**：外部栈 `/etc/komodo/stacks/mysql`，通过宿主机 `3306` 端口映射访问（不在 sharenet 上），故 flarum 用 `host.docker.internal` + `extra_hosts: host-gateway` 连接。
- **valkey**：外部栈 `/etc/komodo/stacks/valkey`，在 sharenet 上（172.19.0.247），flarum 直接以服务名 `valkey` 访问，用于 fof/redis（cache/queue/session/settings）。
- 反向代理（外部，未在本教程范围）：将 `https://forum.example.com` 指向 sharenet 上的 flarum（172.19.0.243）。

## 2. 快速开始

以下步骤适用于**从零部署**本栈；若为旧站迁移/恢复场景，请直接参考 [9. 常见问题与踩坑记录](#9-常见问题与踩坑记录) 的 9.1（误判全新安装）与 9.5（备份恢复）。

### 2.1 前置条件

- 宿主机已安装 Docker，并存在外部 **mysql 栈**：已创建 `flarum` 数据库（表前缀 `bbs_`），通过宿主机 `3306` 端口映射对外提供服务，容器可经 `host.docker.internal` 访问（本栈已用 `extra_hosts: host-gateway` 打通）。
- 存在外部 **valkey 栈**（sharenet 网络，服务名 `valkey`，172.19.0.247），提供缓存/会话/队列/设置。
- 反向代理（nginx/caddy 等，未在本教程范围）已将 `https://forum.example.com` 转发到本栈容器（172.19.0.243）。

### 2.2 部署步骤

```bash
cd /etc/komodo/stacks/flarum   # 或本仓库的 flarum 目录

# 1. 编辑 .env，将占位符替换为实际值（变量说明见 4.3）
vim .env

# 2. 启动（首次启动会自动 composer 安装扩展，耗时较长）
docker compose up -d

# 3. 观察日志确认安装完成
docker compose logs -f flarum
```

### 2.3 验证

- 浏览器访问 `https://forum.example.com` 能正常打开论坛首页。
- `docker compose ps` 状态为 `Up`，日志中无 fatal 报错。
- 首次启动若出现一次 `Class "FoF\Redis\Extend\Redis" not found`，属预期现象（见 [9.2](#92-重建后首次启动报-class-fofredisextendredis-not-found)），composer 装完扩展后恢复正常。

> :warning: **安全提示**：仓库中的 `.env` 为占位模板（如 `DB_PASS=<DB_PASS>`），请勿提交真实密码与域名。部署时在服务器上填入实际值即可，`compose.yaml` 通过 `env_file` 读取。

## 3. 文件与目录结构

本仓库仅包含编排文件（下侧树的上半部分）；`/srv/flarum/` 为部署时宿主机上的持久化数据目录（下半部分），由 `compose.override.yaml` 挂载进容器，不在仓库内。

```
flarum/                             # 本仓库目录
├── compose.yaml                    # 服务基础定义（镜像、env_file、重启策略）
├── compose.override.yaml           # 端口/卷/网络覆盖（Komodo 惯例）
├── .env                            # 环境变量（env_file 引用；占位模板，部署时填真实值）
└── README.md                       # 本教程

/srv/flarum/                        # 宿主机数据目录（部署时创建，不在本仓库）
├── apk-repositories                # 腾讯云 Alpine apk 源（→ /etc/apk/repositories）
├── conf/                           # 自定义 PHP 配置（→ /flarum/app/conf）
│   ├── extend.php                  # Flarum 扩展入口（→ /flarum/app/extend.php）
│   ├── redis-config.php            # fof/redis 指向 valkey 的配置
│   └── asciinema-bbcode.php        # [recode] BBCode 自定义扩展
├── assets/                         # 静态资源（→ /flarum/app/public/assets）
├── extensions/                     # 扩展目录（→ /flarum/app/extensions）
│   ├── list                        # 要安装的扩展清单（启动时自动 composer 安装）
│   ├── composer.repositories.txt   # 腾讯云 composer 镜像配置
│   └── .cache/                     # composer 缓存（持久化）
├── logs/                           # Flarum 日志（→ /flarum/app/storage/logs）
└── nginx/                          # nginx 自定义 location（→ /etc/nginx/flarum）
```

## 4. 服务配置详解

### 4.1 compose.yaml（基础定义）

```yaml
services:
  flarum:
    image: ghcr.io/forkdo/flarum:edge
    container_name: flarum
    restart: unless-stopped
    env_file:
      - path: ./.env
        required: false
```

### 4.2 compose.override.yaml（端口/卷/网络）

```yaml
---
services:
  flarum:
    extra_hosts:
      - host.docker.internal:host-gateway   # 访问宿主机上 mysql 的 3306 端口
    volumes:
      - /etc/localtime:/etc/localtime:ro
      # 腾讯云 Alpine 源（apk 安装 PHP 扩展时使用，避免访问国外源）
      - /srv/flarum/apk-repositories:/etc/apk/repositories:ro
      # 自定义配置文件夹（redis / asciinema，可写挂载，重建容器不丢）
      - /srv/flarum/conf:/flarum/app/conf
      # extend.php 入口（可写挂载，startup 会对 /flarum 执行 chown，只读会报错）
      - /srv/flarum/conf/extend.php:/flarum/app/extend.php
      - /srv/flarum/assets:/flarum/app/public/assets
      - /srv/flarum/extensions:/flarum/app/extensions
      - /srv/flarum/logs:/flarum/app/storage/logs
      - /srv/flarum/nginx:/etc/nginx/flarum
    networks:
      sharenet:
        ipv4_address: 172.19.0.243

networks:
  sharenet:
    external: true
```

> :warning: 数据卷里的 **conf 相关挂载必须可写**（不要加 `:ro`）。镜像 startup 脚本启动时会对 `/flarum` 全目录执行 `chown`，只读挂载会报 `Read-only file system` 警告（虽不影响功能，但不干净）。

### 4.3 环境变量（.env）

| 变量 | 值 | 说明 |
| ---- | ---- | ---- |
| `TZ` | `Asia/Shanghai` | 时区 |
| `FORUM_URL` | `https://forum.example.com` | 论坛访问地址（必填，写入 config.php） |
| `DEBUG` | `false` | 调试模式（排查时临时开 `true`） |
| `GITHUB_TOKEN_AUTH` | `false` | 设为 false，避免 startup 写入空 token 导致 github 认证失败 |
| `PHP_EXTENSIONS` | `simplexml` | 额外 PHP 扩展（aws-sdk 依赖） |
| `DB_HOST` | `host.docker.internal` | 数据库地址（外部 mysql 栈） |
| `DB_PORT` | `3306` | 数据库端口 |
| `DB_NAME` | `flarum` | 数据库名 |
| `DB_USER` | `root` | 数据库账号 |
| `DB_PASS` | `<DB_PASS>`（mysql 栈 root 密码） | 数据库密码 |
| `DB_PREF` | `bbs_` | 表前缀（与已有数据一致） |

> 已有数据库时**不要**设置 `FLARUM_ADMIN_*`（会被误判为全新安装）。若确为全新安装，需补充 `FLARUM_ADMIN_USER` / `FLARUM_ADMIN_PASS`（≥8 位）/ `FLARUM_ADMIN_MAIL`。

## 5. 国内镜像源配置（腾讯云）

本站部署在腾讯云，所有拉取/安装均走腾讯云镜像，避免访问国外源导致的超时或失败。

### 5.1 Alpine apk 源（PHP 扩展安装）

镜像内 apk 默认指向 `dl-cdn.alpinelinux.org`（国外）。通过宿主机文件 `/srv/flarum/apk-repositories` 覆盖容器内 `/etc/apk/repositories`：

```
https://mirrors.cloud.tencent.com/alpine/v3.24/main
https://mirrors.cloud.tencent.com/alpine/v3.24/community
```

- 版本号 `v3.24` 需与容器内 Alpine 版本一致（`docker exec flarum cat /etc/alpine-release`）。
- 覆盖后，`PHP_EXTENSIONS=simplexml` 等 apk 安装会从腾讯云源拉包。

### 5.2 Composer 镜像（扩展安装）

通过宿主机文件 `/srv/flarum/extensions/composer.repositories.txt` 配置：

```
packagist|{"type":"composer","url":"https://mirrors.cloud.tencent.com/repository/composer/","canonical":false}
```

- `canonical:false` 表示腾讯云镜像与官方 packagist.org 并行：腾讯云有的版本用腾讯云，缺失的（如某些 beta/dev 版本）自动回退 packagist.org。
- startup 启动时会自动执行 `composer config repositories.packagist ...` 应用此配置。
- 国内镜像的替代方案（如需更换）：阿里云 `https://mirrors.aliyun.com/composer/`。阿里云同步不全（部分 beta/dev 版本缺失、dist 404），故本站选用腾讯云。

## 6. 扩展管理

### 6.1 安装机制（重要）

镜像 startup 启动时读取 `/flarum/app/extensions/list`（持久化在 `/srv/flarum/extensions/list`），对每一行执行 `composer require`：

```
包名:版本号
```

- 每行一个扩展，`包名:精确版本`（如 `fof/best-answer:2.0.0-beta.7`）。
- **容器每次启动都会执行**（vendor 不在卷里，重建后需重新 composer 安装；包会命中持久化的 `.cache`，不会重复下载）。
- 修改 `list` 后 `docker compose up -d` 重建（或 `restart`）即可自动安装。

### 6.2 新增/移除扩展

推荐在运行中的容器里用官方 `extension` 脚本（自动处理权限与缓存）：

```bash
# 安装（会同时写入 extensions/list，重建后自动恢复）
docker exec -ti flarum extension require vendor/package:版本

# 移除
docker exec -ti flarum extension remove vendor/package

# 查看已安装扩展
docker exec -ti flarum extension list
docker exec -ti flarum extension show
```

> `extension` 脚本的操作会持久化到 `extensions/list`，容器重建后 startup 会自动重装，无需手动维护清单。也可直接编辑 `/srv/flarum/extensions/list` 后重建容器，效果相同。

### 6.3 本站已安装扩展

共 32 个第三方扩展（来自旧站迁移，版本与旧站 `composer.lock` 一致）：

| 类别 | 扩展 |
| ---- | ---- |
| 语言 | `flarum-lang/chinese-simplified` |
| fof 系列 | `best-answer` `byobu` `doorman` `drafts` `forum-statistics-widget` `frontpage` `gamification` `links` `merge-discussions` `moderator-notes` `pages` `redis` `share-social` `sitemap` `socialprofile` `split` `upload` |
| 其他 | `darkle/fancybox` `datlechin/flarum-scroll-buttons` `ekumanov/flarum-ext-markdown-tables` `ganuonglachanh/flarum-ext-search` `ganuonglachanh/sonic` `ianm/boring-avatars` `idevsig/flarum-asciinema` `league/flysystem-aws-s3-v3` `michaelbelgium/flarum-discussion-views` `overtrue/flysystem-qiniu` `ralkage/flarum-hcaptcha` `ramon/colored` `walsgit/external-links-in-new-tab` `walsgit/recycle-bin` |

> 完整清单见 `/srv/flarum/extensions/list`。注：旧站曾用的 `flarum/pusher` 已移除——镜像内置的 `flarum/realtime`（v2.0 rc.5 取代 pusher 的扩展）与其冲突。

### 6.4 扩展启用状态

- **安装**（composer 层面）≠ **启用**（Flarum 后台层面）。
- 启用的扩展记录在数据库 `bbs_settings.extensions_enabled`（JSON 数组）。迁移过来的库当前只启用了 5 个官方扩展（tags/sticky/markdown/emoji/bbcode）。
- 其他已安装扩展需在后台（`/admin`）逐个启用，或命令行：

```bash
docker exec -ti flarum php flarum extension:enable <extension-id>
```

> 启用部分扩展会触发数据库迁移（`migrate`），属正常行为。

## 7. 自定义配置（/srv/flarum/conf/）

容器镜像自带的 `/flarum/app/extend.php` 是空模板，本站通过挂载 `conf/` 目录注入自定义扩展。

### 7.1 文件说明

| 文件 | 挂载位置 | 作用 |
| ---- | ---- | ---- |
| `extend.php` | `/flarum/app/extend.php` | Flarum 扩展入口，引用下面两个文件 |
| `redis-config.php` | `/flarum/app/conf/` | fof/redis 配置，指向 valkey |
| `asciinema-bbcode.php` | `/flarum/app/conf/` | 自定义 `[recode]` BBCode（旧站迁移） |

`extend.php` 内容：

```php
<?php
use Flarum\Extend;

$asciinema = require __DIR__ . '/conf/asciinema-bbcode.php';
$redis     = require __DIR__ . '/conf/redis-config.php';

return [
    $asciinema,
    $redis,
];
```

> 注意：引用路径带 `conf/` 前缀，因为辅助文件位于 `/flarum/app/conf/`（由 `conf` 目录挂载提供），而 extend.php 本身挂载在 `/flarum/app/extend.php`。

### 7.2 Redis（valkey）配置

`redis-config.php` 核心内容：

```php
return (new FoF\Redis\Extend\Redis([
    'host' => 'valkey',          // sharenet 上 valkey 服务名（172.19.0.247）
    'password' => null,          // valkey 栈未设密码
    'port' => 6379,
    'database' => 1,
    'persistent' => true,
    'persistent_id' => 'flarum',
]))
->useDatabaseWith('cache', 1)     // db1 缓存
->useDatabaseWith('queue', 2)     // db2 队列
->useDatabaseWith('session', 3)   // db3 会话
->useDatabaseWith('settings', 4); // db4 设置
```

- fof/redis 需要 **ext-redis 或 predis 二者之一**：镜像未装 ext-redis，但 composer 依赖已含 `predis/predis`，自动兜底，无需额外配置。
- 容器内没有 PHP `Redis` 类属正常（predis 纯 PHP 实现），可通过 `valkey-cli` 验证数据是否写入（db1 应有 `flarum:*` 缓存 key，db4 应有 `flarum:settings`）。

### 7.3 新增自定义扩展（extender）

在 `/srv/flarum/conf/` 新建 PHP 文件，返回 `Flarum\Extend\*` 实例数组，然后在 `extend.php` 中 `require` 并加入 `return` 数组，最后 `docker compose up -d` 重建生效。

## 8. 日常运维

```bash
cd /etc/komodo/stacks/flarum

# 查看状态
docker compose ps

# 查看日志（startup 安装过程 + 运行日志）
docker compose logs -f flarum

# 重建容器（.env / 挂载 / list 变更后使用；restart 不会重新读取 .env）
docker compose up -d flarum

# 仅重启（不重新读取 .env，vendor 保留在可写层）
docker compose restart flarum

# 进入容器
docker exec -ti flarum sh

# 清缓存（改配置后常用）
docker exec flarum php /flarum/app/flarum cache:clear

# 数据库迁移（启用扩展后如报错可手动执行）
docker exec flarum php /flarum/app/flarum migrate
```

## 9. 常见问题与踩坑记录

### 9.1 容器反复重启，日志报 `User admin info of flarum must be set`

**原因**：startup 通过检查 `/flarum/app/public/assets/rev-manifest.json` 或 `._flarum-installed.lock` 判断是否已安装。挂载的 `/srv/flarum/assets` 若是空目录（迁移/恢复备份场景），标记文件缺失 → 误判为首次安装 → 要求 `FLARUM_ADMIN_*` → 缺失则 exit 1。

**解决**（已有数据库时）：

```bash
touch /srv/flarum/assets/._flarum-installed.lock
docker compose up -d flarum
```

> 该标记文件需一直保留，删掉后容器会再次误判。

### 9.2 重建后首次启动报 `Class "FoF\Redis\Extend\Redis" not found`

**原因**：镜像 startup 顺序是「先 `cache:clear`（加载 extend.php，此时 fof/redis 尚未安装）→ 后 `composer update`（才安装扩展）」，重建后首次启动必现一次 fatal。

**结论**：属预期现象，composer 装完扩展后服务正常运行，后续重启不再出现。

### 9.3 挂载只读导致 `chown: ... Read-only file system`

**原因**：startup 会对 `/flarum` 全目录 chown，`:ro` 挂载的文件无法 chown。

**解决**：`conf` 相关挂载保持可写（不加 `:ro`）。`/etc/localtime` 和 `apk-repositories` 是只读源文件，chown 警告仅影响自定义 PHP 文件，故后两者保持 `:ro` 无妨。

### 9.4 composer 安装慢 / 失败

- 确认 `/srv/flarum/extensions/composer.repositories.txt` 指向腾讯云且带 `canonical:false`（见 [5.2](#52-composer-镜像扩展安装)）。
- 若某版本在腾讯云缺失，composer 会自动回退 packagist.org；仍失败时检查网络或换用相近版本。
- 扩展冲突（如 `flarum/pusher` 与 `flarum/realtime`）会直接报错并回滚 composer.json，需从 `list` 移除冲突项。

### 9.5 备份与恢复

- 数据库：由 mysql 栈的 `backup.sh` 负责（`/etc/komodo/stacks/mysql/`）。
- 数据目录：备份 `/srv/flarum/`（assets、extensions、logs、nginx、conf 均在卷内，恢复后 `docker compose up -d` 即可）。
- 恢复后若 assets 为空，按 [9.1](#91-容器反复重启日志报-user-admin-info-of-flarum-must-be-set) 创建标记文件。
