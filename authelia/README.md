# Authelia

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Authelia][1] 是一款双因素认证（2FA）与单点登录（SSO）认证服务器，专注于保障应用程序和用户的安全。它可被视为反向代理的扩展，提供特定的认证功能。其具备的部分功能如下：

- 多种双因素认证方法。
- 注册双因素认证设备时进行身份验证。
- 用户自助重置密码。
- 尝试次数过多后封禁账户（即通常所说的限制机制）。

[1]:https://www.authelia.com/
[2]:https://github.com/authelia/authelia
[3]:https://hub.docker.com/r/authelia/authelia
[4]:https://www.authelia.com/integration/deployment/docker/

---

## 配置文件

### [密码、密钥生成器](https://www.authelia.com/reference/guides/generating-secure-values/)
```bash
# 生成随机密码
docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric

# 生成随机字符串
docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric

# 生成 RSA 密钥对
docker run --rm -u "$(id -u):$(id -g)" -v "$(pwd)":/keys authelia/authelia:latest authelia crypto pair rsa generate --directory /keys

# 生成 RSA 自签名证书
docker run --rm -u "$(id -u):$(id -g)" -v "$(pwd)":/keys authelia/authelia:latest authelia crypto certificate rsa generate --common-name example.com --directory /keys
```

### 全局配置文件 `config/configuration.yml`
- 下载模板文件 [`configuration.template.yml`](configuration.template.yml)
```bash
curl -Lo config/configuration.yml https://raw.githubusercontent.com/forkdo/authelia-chinese-docs/refs/heads/master/config.template.yml
```

### 账号配置文件 `config/users_database.yml`
```yaml
users:
  authelia: # 账户名称
    disabled: false # 是否禁用
    displayname: 'Authelia User' # 显示名称
    # Password is authelia # 密码加密后的密码串
    password: '$6$rounds=50000$BpLnfgDsc2WD8F2q$Zis.ixdg9s/UOJYrs56b5QEZFiZECu0qZVNsIYxBaNJ7ucIL.nlxVCT5tqh8KHG8X4tlwCFm5r6NTOZZ5qRFN/'  # yamllint disable-line rule:line-length
    email: 'authelia@authelia.com' # 邮箱
    groups: # 账户所在组
      - 'admins'
      - 'dev'
...
```
默认账号和密码为 `authelia`，可自行创建其它用户。使用命令行生成新密码。
```bash
docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'admin888'
```

## 创建密钥

### 生成密码文件
```bash
docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric | awk -F ': ' '{print $2}'
```
```bash
mkdir secrets
pushd secrets
docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric | awk -F ': ' '{print $2}' | tee JWT_SECRET
docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric | awk -F ': ' '{print $2}' | tee SESSION_SECRET
docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric | awk -F ': ' '{print $2}' | tee STORAGE_PASSWORD
docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric | awk -F ': ' '{print $2}' | tee STORAGE_ENCRYPTION_KEY
docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric | awk -F ': ' '{print $2}' | tee OIDC_HMAC_SECRET
popd
```

### 设置 `oidc` `jwks` 密钥
- [生成 RSA 密钥对](https://www.authelia.com/reference/guides/generating-secure-values/#generating-an-rsa-keypair)
```bash
mkdir -p data/certs/oidc_jwks
pushd data/certs/oidc_jwks
docker run --rm -u "$(id -u):$(id -g)" -v "$(pwd)":/certs authelia/authelia:latest authelia crypto pair rsa generate --directory /certs
popd
```
或者使用
```bash
mkdir -p data/certs/oidc_jwks
pushd data/certs/oidc_jwks
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
popd
```

### 设置[通知模块](https://www.authelia.com/configuration/notifications/)
```yaml
notifier:
  smtp:
    username: 'test'
    # This secret can also be set using the env variables AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE
    password: 'password'
    address: 'smtp://mail.example.com:25'
    sender: 'admin@example.com'
```

### 设置 [**OpenID Connect 1.0 Provider**](https://www.authelia.com/configuration/identity-providers/openid-connect/provider/)
```yaml
identity_providers:
  oidc:
    jwks:
      - key: {{ secret "/certs/oidc_jwks/private.pem" | mindent 10 "|" | msquote }}
```
必填项密钥生成方式查看**设置 `oidc` `jwks` 密钥**

### 设置 [**OpenID Connect 1.0 Clients**](https://www.authelia.com/configuration/identity-providers/openid-connect/clients/)
```yaml
identity_providers:
  oidc:
    clients:
      - client_id: 'unique-client-identifier'
        client_name: '' # 非必填，显示名称。不填则与 client_id 一样
        client_secret: ''
        redirect_uris: # 回调地址列表
          - https://vaultwarden.yourdomain.com/oidc-callback
        key_id: # 用于匹配请求对象 JWT 头 kid 值的密钥 ID
        key: # JSON Web Key 的公钥部分
        token_endpoint_auth_method: client_secret_basic
```
- Client ID [生成器](https://www.authelia.com/integration/openid-connect/frequently-asked-questions/#client-id--identifier)（`client_id`）
```bash
docker run --rm authelia/authelia:latest authelia crypto rand --length 72 --charset rfc3986
```

- Client Secret [生成器](https://www.authelia.com/integration/openid-connect/frequently-asked-questions/#client-secret)（`client_secret`）
```bash
docker run --rm authelia/authelia:latest authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986

# Random Password: QNysIPSHGiTEwHYIedxvIB5DT~YscSsmTjQTe2B.G-6xExkdy3J3XV4TY0ig1H11hrFt6GFN
# Digest: $pbkdf2-sha512$310000$Y6NvXVmn8Fer2uYm946rTg$ogdFbCnod4/qF2pu9oZO3MBAzm3hkgZdTKFRuGnurfoGQeoK/1ZHsb4ezWm70KBZmL/FRTPZki0e5jj.8WzQxQ
```
> Random Password: 填入接入的平台  
> Digest: 填入文件 config/configuration.yml

- 回调地址参考：https://www.authelia.com/integration/openid-connect/introduction/

## 配置参数的方法
- [通过环境变量](https://www.authelia.com/configuration/methods/environment/#environment-variables)
查看 [METHODS_ENVIRONMENT.md](METHODS_ENVIRONMENT.md)

- [通过密钥文件](https://www.authelia.com/configuration/methods/secrets/#environment-variables)
查看 [SECRETS_ENVIRONMENT.md](SECRETS_ENVIRONMENT.md)

## 常见问题
### 认证方法错误
```yaml
# client_secret_basic, client_secret_post, client_secret_jwt, private_key_jwt, and none
token_endpoint_auth_method: client_secret_basic
```
- https://www.authelia.com/integration/openid-connect/introduction/#client-authentication-method
- https://www.authelia.com/configuration/identity-providers/openid-connect/clients/#token_endpoint_auth_method

### 开启[过滤器功能](https://www.authelia.com/configuration/methods/files/#file-filters)
下述写法，必须开启过滤器
```yaml
identity_providers:
  oidc:
    # AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET_FILE
    # hmac_secret: 'this_is_a_secret_abc123abc123abc'
    jwks:
      - key: {{ secret "/certs/oidc_jwks/private.pem" | mindent 10 "|" | msquote }}
```
环境变量必须设置
```bash
X_AUTHELIA_CONFIG_FILTERS=template
```
