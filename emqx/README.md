# EMQX

## 目录位置
- 配置文件：`/opt/emqx/etc/emqx.conf`

## 环境变量
- `EMQX` 作为前缀，比如用户名和密码的配置：
```bash
dashboard {
    listeners.http {
        bind = 18083
    }
    default_username = "admin"
    default_password = "admin888"
}
```
> EMQX_DASHBOARD__DEFAULT_USERNAME 和 EMQX_DASHBOARD__DEFAULT_PASSWORD

## 客户端连接密码设置
- https://www.emqx.io/docs/zh/v5.0/security/authn/mnesia.html
