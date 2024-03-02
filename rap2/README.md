# rap2

## 部署教程

使用外置宿主机的 MySQL 说明

1. 先创建一个网络

```bash
docker network create mysql
```

2. 查看网络 IP 网关

```bash
docker network inspect mysql
```

3. 将上述拿到的网关 IP 填入 `.env` 中，即`MYSQL_URL=1.1.1.1`

```bash
docker network inspect mysql | grep 'Gateway' | cut -d '"' -f 4
# 或
docker network inspect mysql | grep -o '"Gateway": "[^"]*"' | awk -F'"' '{print $4}'

# 172.19.0.1 假如网关 IP，即 MYSQL_URL=172.19.0.1
```

4. 宿主机登录 MySQL 并创建数据库 `rap2`

```bash
create database rap2;
```

4. 宿主机创建 MySQL 账户

```bash
# rap 为数据库用户名，172.19.% 为 IP段，newpasswd 为账户密码
CREATE USER 'rap'@'172.19.%' IDENTIFIED BY 'newpasswd';
```

5. 赋值权限

```bash
GRANT ALL ON rap2.* TO 'rap'@'172.19.%' WITH GRANT OPTION;
```

6. 刷新权限

```bash
FLUSH PRIVILEGES;
```

## 其它问题

- 由于镜像中**[后端端口](https://github.com/thx/rap2-dolores/blob/master/docker/config.prod.ts)**已写死端口`38080`和请求协议`http`，所以 `.env` 后端 `BACKEND_PORT`(`38080`) 端口需要暴露对外开放，而且网站不得是 `https` 协议的网站。

```bash
# .env
BACKEND_PORT=38080

# 或，则需要使用 `nginx` 将 38080 转发至此 IP。避免窜所有域名端口 38080 到此服务。
BACKEND_PORT=127.0.0.1:39009
```
