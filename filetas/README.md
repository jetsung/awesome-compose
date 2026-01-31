# filetas

# 待重构（项目将转移至 `jetsung`）

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [filetas][1] 是一个文件传输加速服务。

[1]:https://github.com/idev-sig/filetas
[2]:https://github.com/idev-sig/filetas
[3]:https://hub.docker.com/r/idevsig/filetas
[4]:https://github.com/idev-sig/filetas

## 使用

```bash
# docker.io
docker run -p 8000:8000 -d idevsig/filetas:latest

# ghcr.io
docker run -p 8000:8000 -d ghcr.io/idev-sig/filetas:latest
```

## 配置

```ini
TITLE=文件加速下载 # 网站标题
```
