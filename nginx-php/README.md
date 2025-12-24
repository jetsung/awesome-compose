# NGINX-PHP

基于 Docker Compose 的 Nginx 和 PHP-FPM 开发环境

此项目提供了一个简单的 Nginx + PHP-FPM 环境，用于快速搭建 PHP 开发或运行环境。包含以下组件：

- **Nginx**: 使用 nginx:alpine 镜像作为 Web 服务器，监听 80 端口
- **PHP-FPM**: 使用 php:fpm-alpine 镜像处理 PHP 请求

## 特性

- 轻量级 Alpine 镜像，资源占用少
- 自动重启策略，保证服务持续运行
- 数据卷映射，方便代码开发和管理
- 支持自定义 Nginx 配置

## 使用

```bash
# 更新
docker compose -f compose.yaml pull

# 启动
docker compose -f compose.yaml up -d

# 关闭
docker compose -f compose.yaml down

# 测试
curl 127.0.0.1

# 为了方便执行，可以将 docker-compose.nginx.yml 内容合并至 docker-compose.yaml
docker compose up -d
```

## 常见问题

1. 本地启动时，可能会出现错误：

```bash
error response from daemon: driver failed programming external connectivity on endpoint nginx (xxx): Error starting userland proxy: error while calling PortManager.AddPort(): cannot expose privileged port 80, you can add 'net.ipv4.ip_unprivileged_port_start=80' to /etc/sysctl.conf (currently 1024), or set CAP_NET_BIND_SERVICE on rootlesskit binary, or choose a larger port number (>= 1024): listen tcp4 0.0.0.0:80: bind: permission denied
```

**原因**：
`nginx` 需要 `CAP_NET_BIND_SERVICE` 权限。

**解决**：

```bash
echo 'net.ipv4.ip_unprivileged_port_start=80' | tee -a /etc/sysctl.conf
sudo sysctl -p
```
