
> OneDrive，先在本地使用 rclone config 设置后，再从 `~/.config/rclone/rclone.conf` 取数据复制到此服务的 `/config/rclone/rclone.conf` 中。

### 同步设置
- 需要设置 rclone 密码：
```bash
docker run --rm -it -v /srv/vaultwarden-backup:/config/ ttionya/vaultwarden-backup:latest   rclone config
```
