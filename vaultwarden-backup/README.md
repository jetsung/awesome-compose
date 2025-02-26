# vaultwarden-backup

[Source][2] - [Docker Image][3]

---

> [vaultwarden-backup][1] 通过 rclone 备份 vaultwarden

[1]:https://github.com/ttionya/vaultwarden-backup
[2]:https://github.com/ttionya/vaultwarden-backup
[3]:https://hub.docker.com/r/ttionya/vaultwarden-backup

> OneDrive，先在本地使用 rclone config 设置后，再从 `~/.config/rclone/rclone.conf` 取数据复制到此服务的 `/config/rclone/rclone.conf`。

### 同步设置
- 需要设置 rclone 密码：
```bash
docker run --rm -it -v $(pwd)/data:/config/ ttionya/vaultwarden-backup:latest rclone config
```
