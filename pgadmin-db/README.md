# 集成 postgres 和 pgadmin

## 操作

- 复制文件到当前目录

```bash
bash merge.sh
```

- 运行

```bash
docker compose up -d
```

- 登录后添加服务器
> **Add New Server** -> **General -> Name** 值`任意` -> **Connection** -> **Host name/address** / **Username** / **Password** 值都是 `postgres`
