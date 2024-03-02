# matomo

## 环境要求

- 已在宿主机安装 `MySQL` 或 `MariaDB`

## 安装

### 1. MySQL 配置

1. 参考 https://www.jetsung.com/d/366 教程，使容器可以访问宿主机的 MySQL。
   **配置**

```bash
ip add show docker0 | grep inet
docker network create database

docker compose up -d

# 容器访问宿主机的 IP
docker network inspect database | grep Gateway

# 容器 IP
docker network inspect mynetwork | grep IPv4Address
```

2. 宿主机创建中使用 mysql 命令行创建容器访问的数据库用户和数据库信息

```bash
# mycli -uroot -pXXX -hIP_ADDRESS
CREATE USER 'DBUSER'@'MY_NETWORK_IPADDRESS' IDENTIFIED WITH mysql_native_password BY 'DB_PASSWORD';
GRANT ALL ON DBNAME.* TO 'DBUSER'@'MY_NETWORK_IPADDRESS' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

放开防火墙

```bash
ufw allow from MY_NETWORK_IPADDRESS to any port 3306
```

**测试**

```bash
docker exec -it matomo bash

apt update -y
# mycli 是类似 mysql 的命令行
apt install mycli
mycli -umatomo -pXXX -hIP_ADDRESS
```

2. 程序安装
   安装的过程中数据库地址，修改为上述步骤取得的 IP Gateway 地址

```bash
docker network inspect database | grep Gateway
```

## 更多功能

- 邮箱与日志

```bash
# 测试邮件发送是否成功
# 需要在 docker 容器中执行
./console core:test-email "your@email.com"
```

1. 安装计划任务服务

```bash
apt update
apt install -y cron
```

2. 设置计划任务

```bash
$ cat > /etc/cron.d/matomo-archive
MAILTO="your@email.com"
46 1 * * * www-data /usr/local/bin/php /var/www/html/console core:archive --url=https://your_matomo_website/ > /tmp/matomo-archive.log
```

3. 重启计划任务使之生效

```bash
# 重启
service cron restart
# 查看状态
service cron restart
```

- 发送邮件报告
  `设置` -> `个人` -> `报表邮件` -> `创建报表和定时任务`。设置相关信息之后，点击 **现在发送报表** 发送测试邮件，查看是否接收成功。
