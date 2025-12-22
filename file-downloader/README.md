# file-downloader

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [file-downloader][1] 是一个集 M3U8 视频下载、合并与上传为 MP4 为一体的视频下载工具。

[1]: https://git.jetsung.com/idev/file-downloader
[2]: https://git.jetsung.com/idev/file-downloader
[3]: https://github.com/idev-sig/file-downloader/pkgs/container/file-downloader
[4]: https://git.jetsung.com/idev/file-downloader/-/tree/main/docker

---

```bash
services:
  file-downloader:
    image: idev-sig/file-downloader:latest
    container_name: file-downloader
    restart: unless-stopped
    environment:
      - TZ=Asia/Shanghai
      - BROKER="broker.emqx.io"
      - PORT=1883
      - QOS=2
      - KEEPALIVE=60
      - TOPIC_SUBSCRIBE="file/download/request"
      - TOPIC_PUBLISH="file/download/complete"
      - CLIENT_ID="file"
      - DOWNLOAD_DIR="downloads"
      - DOWNLOAD_PREFIX_URL=""
      - USERNAME=""
      - PASSWORD=""
    volumes:
      - ./downloads:/app/downloads
```
