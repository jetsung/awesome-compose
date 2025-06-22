# video-downloader

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [video-downloader][1] 是一个集 M3U8 视频下载、合并与上传为 MP4 为一体的视频下载工具。

[1]: https://git.jetsung.com/idev/video-downloader
[2]: https://git.jetsung.com/idev/video-downloader
[3]: https://github.com/idevsig/video-downloader/pkgs/container/video-downloader
[4]: https://git.jetsung.com/idev/video-downloader/-/tree/main/docker

---

```bash
services:
  video-downloader:
    image: idevsig/video-downloader:latest
    container_name: video-downloader
    restart: unless-stopped
    environment:
      - TZ=Asia/Shanghai
      - MQTT_BROKER="broker.emqx.io"
      - MQTT_PORT=1883
      - QOS_LEVEL=2
      - KEEPALIVE=60
      - MQTT_TOPIC_SUBSCRIBE="video/download/request"
      - MQTT_TOPIC_PUBLISH="video/download/complete"
      - MQTT_CLIENT_ID="video"
      - DOWNLOAD_DIR="downloads"
      - DOWNLOAD_PREFIX_URL=""
      - MQTT_USERNAME=""
      - MQTT_PASSWORD=""
    volumes:
      - ./downloads:/app/downloads
```      