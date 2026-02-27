# Forgejo

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [Forgejo][1] 是一个轻量级、自托管的软件锻造平台（software forge），主要用于代码托管和团队协作开发。它本质上是 Gitea 的一个硬分叉（hard fork），由非营利组织 Codeberg e.V. 支持，强调完全自由软件、社区治理、隐私保护以及长期可持续性。

[1]:https://codeberg.org/forgejo/forgejo
[2]:https://codeberg.org/forgejo/forgejo
[3]:https://codeberg.org/forgejo/-/packages/container/forgejo
[4]:https://forgejo.org/docs/latest/admin/installation/docker/

---

更多配置参考 [**Gitea**](../gitea/README.md)，Forgejo 是 Gitea 的一个分支，二者在使用上非常相似。

## Runner

<details>
<summary>Docker-in-Docker</summary>

```yaml
services:
  docker-in-docker:
    image: docker:dind
    container_name: 'docker_dind'
    privileged: 'true'
    command: ['dockerd', '-H', 'tcp://0.0.0.0:2375', '--tls=false']
    restart: 'unless-stopped'

  runner:
    image: 'data.forgejo.org/forgejo/runner:11'
    links:
      - docker-in-docker
    depends_on:
      docker-in-docker:
        condition: service_started
    container_name: 'runner'
    environment:
      DOCKER_HOST: tcp://docker-in-docker:2375
    # User without root privileges, but with access to `./data`.
    user: 1001:1001
    volumes:
      - ./data:/data
    restart: 'unless-stopped'

    command: '/bin/sh -c "while : ; do sleep 1 ; done ;"'
```
</details>
