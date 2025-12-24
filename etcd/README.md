# ETCD

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [ETCD][1] 是分布式、可靠的键值存储，用于分布式系统中最关键的数据

[1]:https://etcd.io/
[2]:https://github.com/etcd-io/etcd
[3]:https://quay.io/coreos/etcd
[4]:https://etcd.io/docs/

---

## Auth

```bash
etcdctl user add root
etcdctl auth enable
```

docker

```bash
docker exec -it etcd etcdctl user add root
docker exec -it etcd etcdctl auth enable
```

- https://etcd.io/docs/v3.6/op-guide/configuration/
- https://github.com/etcd-io/etcd/blob/main/etcd.conf.yml.sample
