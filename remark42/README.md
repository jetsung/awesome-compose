# Remark42

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [Remark42][1] 是一个轻量级、注重隐私的评论系统，旨在为博客、文章或其他需要评论功能的网站提供简单而强大的解决方案。以下是关于 Remark42 的一些关键信息：

---

## **功能特点**
1. **隐私保护**
   - 不跟踪用户行为，不涉及第三方分析服务。
   - 用户信息（如用户ID、用户名和头像链接）仅存储必要的部分，并且经过哈希处理。
   - 支持用户请求导出其数据，并提供“删除”功能以清除所有相关活动信息[^4^]。
   
2. **多样的登录方式**
   - 支持通过 Google、Twitter、Facebook、GitHub、Apple 等社交媒体平台登录[^4^]。
   - 支持通过邮箱登录，以及可选的匿名访问[^4^]。

3. **评论功能**
   - 多级嵌套评论，支持树形和线性展示[^4^]。
   - 支持 Markdown 格式化，并提供友好的工具栏[^4^]。
   - 支持投票、置顶和评论排序[^4^]。
   - 支持图片上传，支持拖拽功能[^4^]。

4. **通知与集成**
   - 支持通过 RSS、Telegram、Slack、邮件等方式接收新评论通知[^4^]。
   - 支持将评论导出为 JSON 格式，并自动备份[^4^]。

5. **部署与性能**
   - 提供 Docker 容器化部署，支持单命令启动[^4^]。
   - 支持直接部署到 Linux、Windows 和 macOS[^4^]。
   - 无外部数据库，所有数据存储在一个文件中[^4^]。

6. **多站点支持**
   - 单个实例可以支持多个站点[^4^]。
   - 支持自动 SSL 集成[^4^]。

---

## **部署方式**
1. **Docker 部署**
   - 推荐使用 Docker 部署。可以通过 `docker-compose` 配置并启动服务[^3^]。
   - 示例：
     ```yaml
     version: '3'
     services:
       remark42:
         image: umputun/remark42:latest
         ports:
           - "8080:8080"
         environment:
           REMARK_URL: http://localhost:8080
           SITE: your_site_id
           SECRET: your_secret_key
         volumes:
           - ./data:/srv/var
     ```
   - 启动命令：
     ```bash
     docker-compose pull && docker-compose up -d
     ```

2. **二进制文件部署**
   - 下载对应操作系统的二进制文件并解压[^3^]。
   - 示例启动命令：
     ```bash
     ./remark42.linux-amd64 server --secret=your_secret_key --url=http://localhost:8080 --site=your_site_id
     ```

3. **其他部署方式**
   - 支持通过 Zeabur Template 部署[^2^]。
   - 支持手动编译源代码[^3^]。

## **优势**
- **隐私友好**：注重用户隐私，不收集多余信息[^4^]。
- **轻量级**：无外部数据库，单文件存储[^4^]。
- **高度可定制**：支持多种登录方式、评论功能和通知方式[^4^]。
- **易于部署**：支持 Docker、二进制文件等多种部署方式[^3^]。

---

## **适用场景**
- 适合需要隐私保护的个人博客或小型网站。
- 适合不想依赖第三方评论服务（如 Disqus）的开发者[^4^]。

[1]:https://remark42.com/
[2]:https://github.com/umputun/remark42
[3]:https://hub.docker.com/r/umputun/remark42
[4]:https://remark42.com/docs/getting-started/installation/

---

```yaml
environment:
    - REMARK_URL
    - SECRET
    - DEBUG=true
    - AUTH_GOOGLE_CID
    - AUTH_GOOGLE_CSEC
    - AUTH_GITHUB_CID
    - AUTH_GITHUB_CSEC
    - AUTH_FACEBOOK_CID
    - AUTH_FACEBOOK_CSEC
    - AUTH_DISQUS_CID
    - AUTH_DISQUS_CSEC
    # Enable it only for the initial comment import or for manual backups.
    # Do not leave the server running with the ADMIN_PASSWD set if you don't have an intention
    # to keep creating backups manually!
    # - ADMIN_PASSWD=<your secret password>
```      
