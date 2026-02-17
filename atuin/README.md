# Atuin

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Atuin][1] 使用 SQLite 数据库取代了你现有的 Shell 历史，并为你的命令记录了额外的内容。此外，它还通过 Atuin 服务器，在机器之间提供可选的、完全加密的历史记录同步功能。

[1]:https://atuin.sh/
[2]:https://github.com/atuinsh/atuin
[3]:https://github.com/atuinsh/atuin/pkgs/container/atuin
[4]:https://docs.atuin.sh/cli/self-hosting/docker/

---

**官方不推荐直接使用 `latest` / `main`**

## 客户端配置
配置文件：`~/.config/atuin/config.toml`
```toml
sync_address
```
或环境变量
```bash
ATUIN_SYNC_ADDRESS=
```

## [设置同步](https://docs.atuin.sh/cli/guide/sync/)
**注：** 如果你想用自架服务器 ，首先得先设置好 `sync_address`。

### 注册
```bash
atuin register -u <YOUR_USERNAME> -e <YOUR EMAIL>

atuin key
```

### 首次同步
```bash
atuin sync
```
完全同步
```bash
atuin sync -f
```

### 登录
```bash
atuin login -u <USERNAME>
```

## 导入历史
```bash
atuin import auto
```
或
```bash
atuin import bash
atuin import zsh # etc
```

## 删除历史
### 删除单个条目
1. 用 `Ctrl` + `R` 键或上箭头打开 TUI
2. 搜索你想删除的条目
3. 按 `Ctrl` + `O` 键打开选中的检查器
4. 核实这是正确的条目
5. 按 `Ctrl` + `D` 键删除

1. 同上
2. 同上
3. 按 `Ctrl` + `A` `D` 键删除所选条目

### 删除与查询匹配的条目
#### 先预览，然后删除
**务必先运行不带 `---delete` 的查询以验证结果**
```bash
# Step 1: preview - see what matches
atuin search "^curl https://internal"

# Step 2: delete - once you're satisfied the results are correct
atuin search --delete "^curl https://internal"
```
#### 组合滤波器
将 `--delete` 与任意搜索筛选器结合
```bash
# Delete all failed commands run from a specific directory
atuin search --delete --exit 1 --cwd /home/user/experiments

# Delete commands matching a pattern that ran before a certain date
atuin search --delete --before "2024-01-01" "^tmp-script"

# Delete successful cargo commands run after yesterday at 3pm
atuin search --delete --exit 0 --after "yesterday 3pm" cargo
```

### 删除所有历史
```bash
atuin search --delete-it-all
```

### 重新开始同步
```bash
# Delete your sync account and all server-side data
atuin account delete

# Register a new account
atuin register

# Import your shell history fresh (optional)
atuin import auto
```

### 过滤命令
```bash
# Preview what will be removed
atuin history prune --dry-run

# Perform the deletion
atuin history prune
```

### 删除重复历史
```bash
# Preview duplicates that would be removed
atuin history dedup --dry-run --before "2025-01-01" --dupkeep 1

# Delete them
atuin history dedup --before "2025-01-01" --dupkeep 1
```
| Flag | 描述 |
| --- | --- |
| --dry-run/-n | 不删除重复列表 |
| --before/-b | 仅考虑在此日期之前添加的条目（必要）|
| --dupkeep	| 需要保留的近期重复数量 |

### 删除同步账户
```bash
atuin account delete
```

## 备份数据库
```yaml
  backup:
    container_name: atuin_db_dumper
    image: prodrigestivill/postgres-backup-local
    env_file:
      - .env
    environment:
      POSTGRES_HOST: postgresql
      POSTGRES_DB: ${ATUIN_DB_NAME}
      POSTGRES_USER: ${ATUIN_DB_USERNAME}
      POSTGRES_PASSWORD: ${ATUIN_DB_PASSWORD}
      SCHEDULE: "@daily"
      BACKUP_DIR: /db_dumps
    volumes:
      - ./db_dumps:/db_dumps
    depends_on:
      - postgresql
```
