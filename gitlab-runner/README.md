# GitLab Runner

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [GitLab Runner][1] 是 GitLab CI/CD（持续集成 / 持续部署）系统的核心组件之一，它负责执行 CI/CD 流水线中的作业。

[1]:https://docs.gitlab.com/runner/install/
[2]:https://gitlab.com/gitlab-org/gitlab-runner
[3]:http://hub.docker.com/r/gitlab/gitlab-runner
[4]:https://docs.gitlab.com/runner/install/docker/

---

- [GitLab Runner Docs](https://docs.gitlab.com/runner/install/docker.html)

## 使用

- 首次使用需要[注册](https://docs.gitlab.com/runner/configuration/advanced-configuration.html)：`register.sh`

## 查看帮助
```sh
docker run --rm -t -i gitlab/gitlab-runner --help
```
