# ETCD

### Auth

```bash
etcdctl user add root
etcdctl auth enable
```

docker

```bash
docker exec -it etcd etcdctl user add root
docker exec -it etcd etcdctl auth enable
```

- https://etcd.io/docs/v3.5/op-guide/configuration/
- https://github.com/etcd-io/etcd/blob/main/etcd.conf.yml.sample
