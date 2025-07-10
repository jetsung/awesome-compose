# GitLab Runner

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [GitLab Runner][1] 是用 Go 编写的官方 GitLab Runner 的仓库。
它运行测试并将结果发送到 GitLab。
GitLab CI 是 GitLab 附带的开源持续集成服务，用于协调测试。这个项目的旧名称是 GitLab CI Multi Runner，但从现在开始请使用 “GitLab Runner” （不带 CI）。

[1]:https://docs.gitlab.com/runner/install/
[2]:https://gitlab.com/gitlab-org/gitlab-runner
[3]:http://hub.docker.com/r/gitlab/gitlab-runner
[4]:https://docs.gitlab.com/runner/install/docker/

---

> [GitLab Runner](https://docs.gitlab.com/runner/install/docker.html) 服务

## 使用

- 首次使用需要[注册](https://docs.gitlab.com/runner/configuration/advanced-configuration.html)：`register.sh`

## 查看帮助
```sh
docker run --rm -t -i gitlab/gitlab-runner --help
```
