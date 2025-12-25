# Justfile
#
# Usage: just init n=<name|url|image_url> [p=1]

# Disable command echoing by default (similar to MAKEFLAGS += --no-print-directory)
set shell := ["bash", "-c"]

# Recipe to create project directory and files
create proj git="" image="" huburl="":
    # Check if proj is specified
    if [ -z "{{proj}}" ]; then \
        echo "错误：必须指定 create proj=<name>"; \
        exit 1; \
    fi

    # Check if directory exists and prompt for overwrite
    if [ -d "{{proj}}" ]; then \
        echo "目录 {{proj}} 已存在"; \
        read -p "是否覆盖 (y/n)?" yn; \
        case $yn in \
            [Yy]*) ;; \
            *) \
                echo "操作取消"; \
                exit 1; \
                ;; \
        esac; \
    fi

    echo
    echo "创建项目目录: {{proj}}"
    mkdir -p "{{proj}}"

    # Generate .env file
    echo "# CUSTOM" > "{{proj}}/.env"
    echo "TZ=Asia/Shanghai" >> "{{proj}}/.env"
    echo "SERV_PORT=80" >> "{{proj}}/.env"

    # Generate README.md
    echo "# {{proj}}" > "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]" >> "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "---" >> "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "> [{{proj}}][1]" >> "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "[1]:" >> "{{proj}}/README.md"
    echo "[2]:{{git}}" >> "{{proj}}/README.md"
    echo "[3]:{{huburl}}" >> "{{proj}}/README.md"
    echo "[4]:" >> "{{proj}}/README.md"

    # Generate compose.yaml
    echo "---" > "{{proj}}/compose.yaml"
    echo "# {{huburl}}" >> "{{proj}}/compose.yaml"
    echo "services:" >> "{{proj}}/compose.yaml"
    echo "  {{proj}}:" >> "{{proj}}/compose.yaml"
    echo "    image: {{image}}" >> "{{proj}}/compose.yaml"
    echo "    container_name: {{proj}}" >> "{{proj}}/compose.yaml"
    echo "    hostname: {{proj}}" >> "{{proj}}/compose.yaml"
    echo "    restart: unless-stopped" >> "{{proj}}/compose.yaml"
    echo "    env_file:" >> "{{proj}}/compose.yaml"
    echo "      - path: ./.env" >> "{{proj}}/compose.yaml"
    echo "        required: false" >> "{{proj}}/compose.yaml"
    echo "#     ports:" >> "{{proj}}/compose.yaml"
    echo "#       - 80:80" >> "{{proj}}/compose.yaml"

    # Generate compose.override.yaml
    echo "---" > "{{proj}}/compose.override.yaml"
    echo "services:" >> "{{proj}}/compose.override.yaml"
    echo "  {{proj}}:" >> "{{proj}}/compose.override.yaml"
    echo "#     ports: !reset []" >> "{{proj}}/compose.override.yaml"
    echo "#     ports: !override" >> "{{proj}}/compose.override.yaml"
    echo "#       - \${SERV_PORT:-80}:80" >> "{{proj}}/compose.override.yaml"
    echo "#     volumes:" >> "{{proj}}/compose.override.yaml"
    echo "#       - ./data:/data" >> "{{proj}}/compose.override.yaml"

    # Check if backup script should be created
    create_backup="yes"; \
    if [ -n "$NO_BACKUP" ]; then \
        create_backup="no"; \
        echo "通过环境变量禁用备份脚本"; \
    elif [ -t 0 ]; then \
        read -p "是否备份脚本 (y/n)?" yn; \
        case $yn in \
            [Yy]*) \
                echo "将创建备份脚本" ;; \
            *) \
                create_backup="no"; \
                echo "无需备份脚本" ;; \
        esac; \
    else \
        echo "非交互式环境，默认创建备份脚本"; \
    fi; \
    if [ "$create_backup" = "yes" ]; then \
        echo; \
        echo "创建 backup.sh"; \
        echo '#!/usr/bin/env bash' > "{{proj}}/backup.sh"; \
        echo "" >> "{{proj}}/backup.sh"; \
        echo "###" >> "{{proj}}/backup.sh"; \
        echo "#" >> "{{proj}}/backup.sh"; \
        echo "# 备份 {{proj}} 数据" >> "{{proj}}/backup.sh"; \
        echo "#" >> "{{proj}}/backup.sh"; \
        echo "###" >> "{{proj}}/backup.sh"; \
        echo "" >> "{{proj}}/backup.sh"; \
        echo 'if [[ -n "$${DEBUG:-}" ]]; then' >> "{{proj}}/backup.sh"; \
        echo "    set -eux" >> "{{proj}}/backup.sh"; \
        echo "else" >> "{{proj}}/backup.sh"; \
        echo "    set -euo pipefail" >> "{{proj}}/backup.sh"; \
        echo "fi" >> "{{proj}}/backup.sh"; \
        echo "" >> "{{proj}}/backup.sh"; \
        echo "[[ -f {{proj}}.tar.xz ]] && rm -rf ./{{proj}}.tar.xz" >> "{{proj}}/backup.sh"; \
        echo "" >> "{{proj}}/backup.sh"; \
        echo "tar -Jcf {{proj}}.tar.xz ./data" >> "{{proj}}/backup.sh"; \
        echo "" >> "{{proj}}/backup.sh"; \
        echo "#rclone copy ./{{proj}}.tar.xz minio:/backup/databases" >> "{{proj}}/backup.sh"; \
        echo "echo \"backup {{proj}} data to minio done.\"" >> "{{proj}}/backup.sh"; \
        echo "echo \"Backup of {{proj}} data to MinIO completed successfully.\"" >> "{{proj}}/backup.sh"; \
    else \
        if [ -f "{{proj}}/backup.sh" ]; then \
            echo "删除已存在的 backup.sh"; \
            rm -f "{{proj}}/backup.sh"; \
        fi; \
    fi; \
    echo; \
    echo "项目 {{proj}} 已创建"

# Recipe to initialize project based on name, URL, or image URL
init n p="":
    #!/usr/bin/env bash
    # Check if n is specified
    if [ -z "{{n}}" ]; then \
        echo "错误：必须指定 n init n=<name>"; \
        exit 1; \
    fi

    set -e
    last_part="YES"
    if [ -n "{{p}}" ]; then
        last_part="NO"
    fi
    name="{{n}}"
    # Initialize variables
    TAG="latest"
    REGISTRY=""
    USER=""
    GIT_URL=""
    IMAGE_NAME=""
    IMAGE_PATH=""
    FULL_IMAGE=""
    IMAGE_URL=""
    REPO_URL="$name"
    # Check if input is a GitHub Package URL
    if echo "$name" | grep -q "^https://github.com/.*"; then
        REGISTRY="ghcr.io"
        USER=$(echo "$name" | sed 's|^https://github.com/||' | cut -d'/' -f1)
        IMAGE_NAME=$(echo "$name" | sed 's|.*/pkgs/container/||')
        IMAGE_PATH="$USER/$IMAGE_NAME"
        FULL_IMAGE="$REGISTRY/$IMAGE_PATH"
        IMAGE_URL="$name"
        GIT_URL="https://github.com/$IMAGE_PATH"
    elif echo "$name" | grep -q "^https://hub.docker.com/r/.*"; then
        REGISTRY=""
        USER=$(echo "$name" | sed 's|^https://hub.docker.com/r/||' | cut -d'/' -f1)
        IMAGE_NAME=$(echo "$name" | sed 's|^https://hub.docker.com/r/||' | cut -d'/' -f2)
        IMAGE_PATH="$USER/$IMAGE_NAME"
        FULL_IMAGE="$IMAGE_PATH"
        IMAGE_URL="$name"
    else
        NAME="$name"
        HUB_REGISTRY="https://hub.docker.com/r/"
        if echo "$name" | grep -q ":"; then
            TAG=$(echo "$name" | sed 's|.*/||' | cut -d':' -f2)
            NAME=$(echo "$name" | cut -d':' -f1)
        fi
        IMAGE_NAME="$NAME"
        IMAGE_PATH="$NAME"
        FULL_IMAGE="$NAME"
        IMAGE_URL="$HUB_REGISTRY$IMAGE_PATH"
        if echo "$NAME" | grep -q "^ghcr.io/.*"; then
            REGISTRY="ghcr.io"
            USER=$(echo "$NAME" | sed 's|^ghcr.io/||' | cut -d'/' -f1)
            IMAGE_NAME=$(echo "$NAME" | sed 's|^ghcr.io/||' | cut -d'/' -f2)
            IMAGE_PATH="$USER/$IMAGE_NAME"
            FULL_IMAGE="$REGISTRY/$IMAGE_PATH"
            IMAGE_URL="https://github.com/$USER/$IMAGE_NAME/pkgs/container/$IMAGE_NAME"
            GIT_URL="https://github.com/$USER/$IMAGE_NAME"
        else
            if echo "$NAME" | grep -q "/.*"; then
                USER=$(echo "$NAME" | awk -F'/' '{print $(NF-1)}')
                IMAGE_NAME=$(echo "$NAME" | awk -F'/' '{print $NF}')
                IMAGE_PATH="$USER/$IMAGE_NAME"
            fi
        fi
    fi
    echo
    echo "Registry: $REGISTRY"
    echo "标签: $TAG"
    echo "用户: $USER"
    echo "镜像: $IMAGE_NAME"
    echo "镜像路径: $IMAGE_PATH"
    echo "完整镜像: $FULL_IMAGE"
    echo "GitHub URL: $GIT_URL"
    echo "网页地址：$IMAGE_URL"
    echo
    # Set project name
    PROJECT="$IMAGE_NAME"
    if [ "$last_part" = "NO" ]; then
        PROJECT="$USER"
    fi
    just create proj="$PROJECT" git="$GIT_URL" image="$FULL_IMAGE:$TAG" huburl="$IMAGE_URL"
