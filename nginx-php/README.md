# NGINX-PHP

## 使用

```bash
# 更新
docker compose -f docker-compose.yml -f docker-compose.nginx.yml pull

# 启动
docker compose -f docker-compose.yml -f docker-compose.nginx.yml up -d

# 关闭
docker compose -f docker-compose.yml -f docker-compose.nginx.yml down

# 测试
curl 127.0.0.1

# 为了方便执行，可以将 docker-compose.nginx.yml 内容合并至 docker-compose.yml
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
