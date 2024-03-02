# 集成 mysql / mariadb 和 phpmyadmin

## 操作

- 复制文件到当前目录

```bash
bash merge.sh
```

- 运行

```bash
docker compose -f docker-compose.yml -f docker-compose.*.yml up -d
```

## 清理当前文件

```bash
rm -v !("merge.sh"|"README.md")
rm .env
```
