# transfer.sh

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [transfer.sh][1] 从命令行共享简单快速的文件。此代码包含服务器，其中包含创建自己实例所需的一切。当前支持S3（Amazon S3），GDRIVE（Google Drive），Storj（Storj）提供商和本地文件系统（本地）。

[1]:https://github.com/dutchcoders/transfer.sh
[2]:https://github.com/dutchcoders/transfer.sh
[3]:https://hub.docker.com/r/dutchcoders/transfer.sh
[4]:https://github.com/dutchcoders/transfer.sh#usage

---

## 服务端配置参数

| 参数（Parameter）     | 说明（Description）            | 默认值 / 示例值（Value）     | 环境变量（Env）         |
|--------------|--------------------------|-------------|----------------------|
| `listener`           | HTTP 监听端口（格式：`host:port`）              | `:80`        | `LISTENER`            |
| `profile-listener`   | pprof 性能分析监听端口                           | `:6060`      | `PROFILE_LISTENER`    |
| `force-https`        | 是否将 HTTP 请求重定向到 HTTPS                  | `false`      | `FORCE_HTTPS`         |
| `tls-listener`       | HTTPS/TLS 监听端口                              | `:443`       | `TLS_LISTENER`        |
| `tls-listener-only`  | 仅启用 TLS 监听（禁用纯 HTTP）                    | （无默认值）  | `TLS_LISTENER_ONLY`   |
| `tls-cert-file`      | TLS 证书文件路径                                 | （无默认值）  | `TLS_CERT_FILE`       |
| `tls-private-key`    | TLS 私钥文件路径                                 | （无默认值）  | `TLS_PRIVATE_KEY`     |
| `http-auth-user`     | 上传时 HTTP 基本身份验证的用户名                  | （无默认值）  | `HTTP_AUTH_USER`      |
| `http-auth-pass`     | 上传时 HTTP 基本身份验证的密码                    | （无默认值）  | `HTTP_AUTH_PASS`      |
| `http-auth-htpasswd`             | 上传时使用的 htpasswd 文件路径（用于多用户认证）   | （无默认值）  | `HTTP_AUTH_HTPASSWD`  |
| `http-auth-ip-whitelist`         | 免身份验证的 IP 白名单（逗号分隔）                | （无默认值）  | `HTTP_AUTH_IP_WHITELIST`          |
| `virustotal-key`     | VirusTotal API 密钥（用于 `/virustotal` 端点）    | （无默认值）  | `VIRUSTOTAL_KEY`      |
| `ip-whitelist`       | 允许连接服务的 IP 白名单（逗号分隔）              | （无默认值）  | `IP_WHITELIST`        |
| `ip-blacklist`       | 禁止连接服务的 IP 黑名单（逗号分隔）              | （无默认值）  | `IP_BLACKLIST`        |
| `temp-path`          | 临时文件存储目录                                  | 系统默认临时目录                        | `TEMP_PATH`           |
| `web-path`           | 静态 Web 文件路径（用于自定义前端或开发）          | （无默认值）  | `WEB_PATH`            |
| `proxy-path`         | 反向代理路径前缀（如服务运行在 `/transfer/` 下；开头的 `/` 会被自动去除）  | （无默认值）  | `PROXY_PATH`          |
| `proxy-port`         | 反向代理端口（当服务运行在代理后时使用）           | （无默认值）  | `PROXY_PORT`          |
| `email-contact`      | 前端页面显示的联系邮箱                              | （无默认值）  | `EMAIL_CONTACT`       |
| `ga-key`             | Google Analytics 跟踪 ID（用于前端统计）           | （无默认值）  | `GA_KEY`              |
| `provider`           | 存储后端类型                                       | `local`（可选：`s3`, `storj`, `gdrive`, `local`） | （无对应环境变量）     |
| `uservoice-key`      | UserVoice 反馈服务密钥（用于前端）                 | （无默认值）  | `USERVOICE_KEY`       |
| `aws-access-key`     | AWS S3 访问密钥                                    | （无默认值）  | `AWS_ACCESS_KEY`      |
| `aws-secret-key`     | AWS S3 私密密钥                                    | （无默认值）  | `AWS_SECRET_KEY`      |
| `bucket`             | S3 存储桶名称                                      | （无默认值）  | `BUCKET`              |
| `s3-endpoint`        | 自定义 S3 兼容服务 endpoint（如 MinIO）            | （无默认值）  | `S3_ENDPOINT`         |
| `s3-region`          | S3 存储桶所在区域                                  | `eu-west-1`  | `S3_REGION`           |
| `s3-no-multipart`    | 禁用 S3 多部分上传                                  | `false`      | `S3_NO_MULTIPART`     |
| `s3-path-style`      | 强制使用路径式 S3 URL（MinIO 等兼容服务必需）       | `false`      | `S3_PATH_STYLE`       |
| `storj-access`       | Storj 项目访问密钥                                  | （无默认值）  | `STORJ_ACCESS`        |
| `storj-bucket`       | Storj 项目内使用的存储桶                            | （无默认值）  | `STORJ_BUCKET`        |
| `basedir`            | local 或 gdrive 存储后端的根目录                    | （无默认值）  | `BASEDIR`             |
| `gdrive-client-json-filepath`    | Google Drive OAuth 客户端凭据 JSON 文件路径        | （无默认值）  | `GDRIVE_CLIENT_JSON_FILEPATH`     |
| `gdrive-local-config-path`       | Google Drive 本地缓存配置路径                       | （无默认值）  | `GDRIVE_LOCAL_CONFIG_PATH`        |
| `gdrive-chunk-size`  | Google Drive 上传分块大小（单位：MB，需小于可用内存，默认 8 MB）            | `8`          | `GDRIVE_CHUNK_SIZE`   |
| `lets-encrypt-hosts`             | 用于 Let’s Encrypt 证书申请的域名列表（逗号分隔）   | （无默认值）  | `HOSTS`               |
| `log`                | 日志文件路径（留空则输出到 stdout）                | （无默认值）  | `LOG`                 |
| `cors-domains`       | CORS 允许的域名列表（逗号分隔）；设置后将启用 CORS 支持                     | （无默认值）  | `CORS_DOMAINS`        |
| `clamav-host`        | ClamAV 病毒扫描服务地址                             | （无默认值）  | `CLAMAV_HOST`         |
| `perform-clamav-prescan`         | 是否对每个上传文件进行 ClamAV 预扫描（需 `clamav-host` 指向本地 Unix socket）            | （无默认值）  | `PERFORM_CLAMAV_PRESCAN`          |
| `rate-limit`         | 每分钟允许的最大请求数                              | （无默认值）  | `RATE_LIMIT`          |
| `max-upload-size`    | 最大上传文件大小（单位：**KB**）                    | （无默认值）  | `MAX_UPLOAD_SIZE`     |
| `purge-days`         | 上传文件自动删除前保留的天数                        | （无默认值）  | `PURGE_DAYS`          |
| `purge-interval`     | 自动清理任务执行间隔（单位：**小时**，S3 和 Storj 不适用）                  | （无默认值）  | `PURGE_INTERVAL`      |
| `random-token-length`            | 上传路径中随机令牌长度（删除路径令牌长度为该值的两倍）                       | `6`          | `RANDOM_TOKEN_LENGTH`             |

### 使用提示

- **启用 Let’s Encrypt TLS**：
  设置 `lets-encrypt-hosts=your.domain.com`，`tls-listener=:443`，并启用 `force-https=true`。
- **使用自有 TLS 证书**：
  设置 `tls-listener=:443`、`force-https=true`、`tls-cert-file` 和 `tls-private-key`。
- 所有参数既可通过命令行传入（如 `--listener :8080`），也可通过对应的**环境变量**配置。
- 安全建议：生产环境应配置 `ip-whitelist`、`http-auth-*`、`rate-limit` 和 `max-upload-size`。

## 一、命令行上传函数（适用于 Bash/Zsh）

你可以将以下函数添加到 `~/.bashrc` 或 `~/.zshrc` 中，以方便使用：

```bash
transfer()
{
  local file
  declare -a file_array
  file_array=("${@}")

  # 帮助信息
  if [[ "${file_array[@]}" == "" || "${1}" == "--help" || "${1}" == "-h" ]]; then
    echo "${0} - 将任意文件上传到 \"transfer.sh\"。"
    echo ""
    echo "用法: ${0} [选项] [文件]..."
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  上传当前目录下的单个文件："
    echo "      ${0} \"image.img\""
    echo ""
    echo "  上传多个文件："
    echo "      ${0} \"image.img\" \"image2.img\""
    echo ""
    echo "  从其他目录上传文件："
    echo "      ${0} \"/tmp/some_file\""
    echo ""
    echo "  上传当前目录所有文件（注意服务器限速）："
    echo "      ${0} *"
    echo ""
    echo "  上传单个文件并仅显示下载链接和删除令牌："
    echo "      ${0} \"image.img\" | awk -F': ' '/Delete token:/ { print \$2 } /Download link:/ { print \$2 }'"
    echo ""
    echo "  显示 transfer.sh 的帮助信息："
    echo "      curl --request GET \"https://transfer.sh\""
    return 0
  fi

  # 检查所有文件是否存在
  for file in "${file_array[@]}"; do
    if [[ ! -f "${file}" ]]; then
      echo -e "\e[01;31m'${file}' 未找到或不是一个文件。\e[0m" >&2
      return 1
    fi
  done

  # 显示文件总大小
  du -c -k -L "${file_array[@]}" >&2

  # 询问是否确认上传
  local upload_files
  if [[ "${ZSH_NAME}" == "zsh" ]]; then
    read $'upload_files?\e[01;31m确定要上传以上 ${#file_array[@]} 个文件到 \"transfer.sh\" 吗？(Y/n): \e[0m'
  elif [[ "${BASH}" == *"bash"* ]]; then
    read -p $'\e[01;31m确定要上传以上 ${#file_array[@]} 个文件到 \"transfer.sh\" 吗？(Y/n): \e[0m' upload_files
  fi

  case "${upload_files:-y}" in
    "y"|"Y")
      for file in "${file_array[@]}"; do
        # 逐个上传并解析返回头信息
        local curl_output=$(curl --request PUT --progress-bar --dump-header - --upload-file "${file}" "https://transfer.sh/")
        local awk_output=$(awk '
          gsub("\r", "", $0) && tolower($1) ~ /x-url-delete/ {
            delete_link=$2;
            print "删除命令: curl --request DELETE \"" delete_link "\"";
            gsub(".*/", "", delete_link);
            delete_token=delete_link;
            print "删除令牌: " delete_token;
          }
          END {
            print "下载链接: " $0;
          }
        ' <<< "${curl_output}")
        echo -e "${awk_output}\n"

        # 多文件上传时防限速
        if (( ${#file_array[@]} > 4 )); then
          sleep 5
        fi
      done
      ;;
    "n"|"N")
      return 1
      ;;
    *)
      echo -e "\e[01;31m输入错误: '${upload_files}'。\e[0m" >&2
      return 1
      ;;
  esac
}
```

---

## 二、使用别名快速上传（适用于 Bash/Zsh/Fish/Windows）

### Bash/Zsh（使用 curl）

```bash
transfer() {
  curl --progress-bar --upload-file "$1" https://transfer.sh/$(basename "$1") | tee /dev/null;
  echo
}
alias transfer=transfer
```

### Bash/Zsh（使用 wget）

```bash
transfer() {
  wget -t 1 -qO - --method=PUT --body-file="$1" --header="Content-Type: $(file -b --mime-type "$1")" https://transfer.sh/$(basename "$1");
  echo
}
```

### Fish Shell（使用 curl）

```fish
function transfer --description '上传文件到 transfer.sh'
  if [ $argv[1] ]
    set -l tmpfile (mktemp -t transferXXXXXX)
    curl --progress-bar --upload-file "$argv[1]" https://transfer.sh/(basename $argv[1]) >> $tmpfile
    cat $tmpfile
    command rm -f $tmpfile
  else
    echo '用法: transfer 要上传的文件'
  end
end
funcsave transfer
```

### Windows（创建 `transfer.cmd` 放入 PATH）

```cmd
@echo off
setlocal
set FN=%~nx1
set FULL=%1
powershell -noprofile -command "$(Invoke-Webrequest -Method put -Infile $Env:FULL https://transfer.sh/$Env:FN).Content"
```

使用方式：

```bash
$ transfer test.txt
```

---

## 三、上传与下载示例

### 上传文件

- **使用 wget：**
  ```bash
  wget --method PUT --body-file=/tmp/file.tar https://transfer.sh/file.tar -O - -nv
  ```

- **使用 PowerShell：**
  ```powershell
  invoke-webrequest -method put -infile .\file.txt https://transfer.sh/file.txt
  ```

- **使用 HTTPie：**
  ```bash
  http https://transfer.sh/ -vv < /tmp/test.log
  ```

- **上传管道过滤后的内容：**
  ```bash
  grep 'pound' /var/log/syslog | curl --upload-file - https://transfer.sh/pound.log
  ```

### 下载文件

- **使用 curl：**
  ```bash
  curl https://transfer.sh/1lDau/test.txt -o test.txt
  ```

- **使用 wget：**
  ```bash
  wget https://transfer.sh/1lDau/test.txt
  ```

---

## 四、归档与备份

### 备份并加密 MySQL 数据库并上传

```bash
mysqldump --all-databases | gzip | gpg -ac -o- | curl -X PUT --upload-file "-" https://transfer.sh/test.txt
```

### 压缩目录并上传

```bash
tar -czf - /var/log/journal | curl --upload-file - https://transfer.sh/journal.tar.gz
```

### 一次上传多个文件

```bash
curl -i -F filedata=@/tmp/hello.txt -F filedata=@/tmp/hello2.txt https://transfer.sh/
```

### 合并多个文件为 zip 或 tar.gz 下载

```bash
curl https://transfer.sh/(15HKz/hello.txt,15HKz/hello.txt).tar.gz
curl https://transfer.sh/(15HKz/hello.txt,15HKz/hello.txt).zip
```

### 上传后通过邮件发送链接

```bash
transfer /tmp/hello.txt | mail -s "Hello World" user@yourmaildomain.com
```

---

## 五、加密与解密

### 用 GPG 密码加密上传

```bash
gpg --armor --symmetric --output - /tmp/hello.txt | curl --upload-file - https://transfer.sh/test.txt
```

### 下载并解密

```bash
curl https://transfer.sh/1lDau/test.txt | gpg --decrypt --output /tmp/hello.txt
```

### 使用 Keybase 加密

- **加密并上传：**
  ```bash
  cat somebackupfile.tar.gz | keybase encrypt [对方用户名] | curl --upload-file '-' https://transfer.sh/test.txt
  ```

- **下载并解密：**
  ```bash
  curl https://transfer.sh/sqUFi/test.md | keybase decrypt
  ```

---

## 六、病毒扫描

### 使用 ClamAV 扫描（上传到支持扫描的 endpoint）

```bash
curl -X PUT --upload-file ./eicar.com https://transfer.sh/eicar.com/scan
```

### 上传到 VirusTotal 并获取永久链接

```bash
curl -X PUT --upload-file nhgbhhj https://transfer.sh/test.txt/virustotal
```

---

## 七、上传加密文件（AES-256）

### 添加 `transfer-encrypted` 函数（支持目录打包）

```bash
transfer-encrypted() {
  if [ $# -eq 0 ]; then
    echo "未指定参数。
用法：
transfer-encrypted [-D 下载次数] 文件或目录" >&2
    return 1
  fi

  local max_downloads=""
  while getopts ":D:" opt; do
    case $opt in
      D) max_downloads=$OPTARG ;;
      \?) echo "无效选项: -$OPTARG" >&2 ;;
    esac
  done
  shift "$((OPTIND - 1))"
  local file="$1"
  local file_name=$(basename "$file")

  if [ ! -e "$file" ]; then
    echo "$file: 文件或目录不存在" >&2
    return 1
  fi

  if [ -d "$file" ]; then
    file_name="$file_name.zip"
    (cd "$file" && zip -r -q - .) | openssl aes-256-cbc -pbkdf2 -e > "tmp-$file_name"
    curl -H "Max-Downloads: $max_downloads" -w '\n' --upload-file "tmp-$file_name" "https://transfer.sh/$file_name" | tee /dev/null
    rm "tmp-$file_name"
  else
    openssl aes-256-cbc -pbkdf2 -e -in "$file" > "tmp-$file"
    curl -H "Max-Downloads: $max_downloads" -w '\n' --upload-file "tmp-$file" "https://transfer.sh/$file_name" | tee /dev/null
    rm "tmp-$file"
  fi
}
```

### 下载并解密

```bash
curl -s https://transfer.sh/some/file | openssl aes-256-cbc -pbkdf2 -d > output_filename
```

---

## 八、上传后自动复制下载命令到剪贴板（Linux/macOS）

### 步骤 1：安装剪贴板工具

- **Linux：** 安装 `xclip` 或 `xsel`
  ```bash
  # xclip
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'

  # xsel
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
  ```

- **macOS：** 系统自带 `pbcopy`/`pbpaste`，无需额外设置。

### 步骤 2：添加增强版 `transfer` 函数

```bash
transfer() {
  curl --progress-bar --upload-file "$1" https://transfer.sh/$(basename "$1") | pbcopy;
  echo "1) 下载链接："
  echo "$(pbpaste)"
  echo
  echo "2) Linux 或 macOS 下载命令："
  linux_macos_download_command="wget $(pbpaste)"
  echo $linux_macos_download_command
  echo
  echo "3) Windows 下载命令："
  windows_download_command="Invoke-WebRequest -Uri \"$(pbpaste)\" -OutFile $(basename $1)"
  echo $windows_download_command

  case $2 in
    l|m) echo $linux_macos_download_command | pbcopy ;;
    w)   echo $windows_download_command | pbcopy ;;
  esac
}
```

### 使用方式

```bash
# 上传并自动复制 Windows 下载命令到剪贴板
transfer ~/temp/a.log w
```

---

## 九、上传时指定下载次数和保存天数，并显示删除令牌

```bash
# 临时文件路径
URLFILE=$HOME/temp/transfersh.url

if [ -f "$1" ]; then
  read -p "允许下载次数: " num_down
  read -p "服务器保存天数: " num_save

  # 上传并保存响应头
  curl -sD - -H "Max-Downloads: $num_down" -H "Max-Days: $num_save" --progress-bar --upload-file "$1" "https://transfer.sh/$(basename "$1")" | grep -i -E 'transfer\.sh|x-url-delete' &> "$URLFILE"

  if [ -f "$URLFILE" ]; then
    URL=$(tail -n1 "$URLFILE")
    TOKEN=$(grep delete "$URLFILE" | awk -F "/" '{print $NF}')
    echo "*********************************"
    echo "数据已保存至 $URLFILE"
    echo "**********************************"
    echo "下载链接: $URL"
    echo "删除令牌: $TOKEN"
    echo "**********************************"
  else
    echo "未生成 URL 文件！"
  fi
else
  echo "!!!!!!"
  echo "\"$1\" 未找到！"
  echo "!!!!!!"
fi
```
