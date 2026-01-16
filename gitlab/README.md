# GitLab

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [GitLab][1] 是一个开源的端到端软件开发平台，内置版本控制、问题跟踪、代码审查、CI/CD 等功能。你可以在自己的服务器、容器或云服务商上自托管 GitLab。

[1]:https://gitlab.com/
[2]:https://gitlab.com/gitlab-org/gitlab
[3]:https://hub.docker.com/r/gitlab/gitlab-ce
[4]:https://docs.gitlab.com/install/docker/installation/#install-gitlab-by-using-docker-compose

---

- [**Docker Source**](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/docker)

## [使用 Docker Compose 安装 GitLab](https://docs.gitlab.com/install/docker/installation/#install-gitlab-by-using-docker-compose)

1. 启动
```bash
docker compose -p gitlab up -d
```

其它命令行
```bash
# 查看配置
docker compose -p gitlab config

# 停止
docker compose -p gitlab down
```

## [使用 Docker Swarm 模式安装 GitLab](https://docs.gitlab.com/install/docker/installation/#install-gitlab-by-using-docker-swarm-mode)

1. 初始化
```bash
docker swarm init
```

2. 创建目录
```bash
mkdir -p ./data/{config,data,logs}
```

3. 启动
```bash
docker stack deploy -c compose.swarm.yaml gitlab
```
> 修改密码 [`root_password.txt`](root_password.txt)

4. 查看日志
```bash
docker service logs -f gitlab_gitlab
```

5. 停止 / 移除 stack
```bash
# 要完全停止 GitLab（包括所有容器、服务、网络），用这个命令：
docker stack rm gitlab
```

其它命令行
```bash
# 列出所有已部署的 stack
docker stack ls

# 查看特定 stack 中的所有服务（推荐先用这个）
docker stack services gitlab

# 查看 stack 中所有任务/容器详细运行状态（最详细，包含错误原因）
docker stack ps gitlab

# 或更具体某个服务
docker service ps gitlab_gitlab   # 服务名通常是 stack名_服务名

# 查看日志（排查 GitLab 问题超有用）
docker service logs gitlab_gitlab   # 替换为实际服务名

# 如果只想临时缩容（不删 stack，只停服务），可以 scale 到 0，再 scale 回来：=1。
docker service scale gitlab_gitlab=0   # 把 GitLab 主服务缩到 0

# 想监控整个过程？用 watch 命令实时刷新：
watch docker stack ps gitlab

# 查看任务历史和错误原因（最重要，先跑这个）：
docker service ps gitlab_gitlab --no-trunc
# 或更详细：
docker service ps gitlab_gitlab

# 查看服务详细配置（检查端口、卷、资源限制）：
docker service inspect gitlab_gitlab --pretty

# 查看容器日志（即使 replicas=0，也可能有启动日志）：
docker service logs gitlab_gitlab

# 强制更新服务以重新加载 config
docker service update --force gitlab_gitlab

# 检查节点资源和状态（单节点 Swarm 也适用）：
docker node ls          # 确认节点 Ready
docker node inspect self --pretty   # 查看你的节点资源（CPU/Memory）
free -h                 # 检查主机内存（GitLab CE 推荐至少 8GB 空闲）
df -h                   # 磁盘空间
```

## 配置
- [设置 SMTP](https://docs.gitlab.com/omnibus/settings/smtp/)
修改 [`gitlab.rb`](gitlab.rb)
```ruby
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "xxxx@xx.com"
gitlab_rails['smtp_password'] = "password"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_from'] = 'xxxx@xx.com'
gitlab_rails['smtp_domain'] = "exmail.qq.com"
```

## 常见问题
- 账号和密码
```bash
# 超级管理员账号 root
# 密码
docker exec -it $(docker ps | grep gitlab-ce:latest | cut -d' ' -f1) grep 'Password:' /etc/gitlab/initial_root_password
```

- 更新配置
```bash

```

- 查看配置
```bash
# 默认配置
docker exec -it $(docker ps | grep gitlab-ce:latest | cut -d' ' -f1) cat /etc/gitlab/gitlab.rb

# 最新配置
docker exec -it $(docker ps | grep gitlab-ce:latest | cut -d' ' -f1) cat /omnibus_config.rb
```

- [禁止注册审批](https://docs.gitlab.com/administration/settings/sign_up_restrictions/)
```bash
Your account is pending approval from your GitLab administrator and hence blocked. Please contact your GitLab administrator if you think this is an error.
```
结合 [Rails console](https://docs.gitlab.com/administration/operations/rails_console/?tab=Docker)，在[终端执行](https://docs.gitlab.com/administration/settings/sign_up_restrictions/)
```bash
docker exec -it $(docker ps | grep gitlab-ce:latest | cut -d' ' -f1) gitlab-rails console

# 开启注册
::Gitlab::CurrentSettings.update!(signup_enabled: true)

# 禁止注册审批
::Gitlab::CurrentSettings.update!(require_admin_approval_after_user_signup: false)
```

- 内部 [Nginx](https://docs.gitlab.com/omnibus/settings/nginx/) 配置
```ruby
nginx['enable'] = false
nginx['listen_port'] = 80
```

- 使用 GitLab Runner
**Docker Compose 方式伸缩**
```bash
# 伸缩为 1 个
docker compose up -d --scale gitlab-runner=1

# 注册此 Runner

# 再伸缩为 4 个
docker compose up -d --scale gitlab-runner=4
```

- 更新 `gitlab.rb` 后重载
```bash
docker compose up -d --force-recreate gitlab
# 或
docker compose restart gitlab

# 再执行
docker compose exec gitlab gitlab-ctl reconfigure
```

- 创建的 `README.md` 文件使用的是内部的 `http://gitlab` 而非 `external_url` 设置的 URL
修改 yaml 中的 `hostname` 为 `external_url` 的域名（不含协议）
