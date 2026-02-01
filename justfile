# Justfile
#
# Usage: just init n=<name|url|image_url> [p=1]

# Disable command echoing by default
set shell := ["bash", "-c"]

# Recipe to create project directory and files
create proj git="" image="" huburl="":
    #!/usr/bin/env bash
    if [ -z "{{proj}}" ]; then
        echo "错误：必须指定 create proj=<name>"
        exit 1
    fi

    if [ -d "{{proj}}" ]; then
        echo "目录 {{proj}} 已存在"
        read -p "是否覆盖 (y/n)?" yn
        case $yn in
            [Yy]*) ;;
            *)
                echo "操作取消"
                exit 1
                ;;
        esac
    fi

    echo
    echo "创建项目目录: {{proj}}"
    mkdir -p "{{proj}}"

    # 生成 .env 文件
    echo "# CUSTOM" > "{{proj}}/.env"
    echo "TZ=Asia/Shanghai" >> "{{proj}}/.env"
    echo "SERV_PORT=80" >> "{{proj}}/.env"

    # 生成 README.md (首字母大写)
    PROJ_UPPER=$(echo "{{proj}}" | awk '{print toupper(substr($0,1,1))substr($0,2)}')
    echo "# $PROJ_UPPER" > "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]" >> "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "---" >> "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "> [$PROJ_UPPER][1]" >> "{{proj}}/README.md"
    echo "" >> "{{proj}}/README.md"
    echo "[1]:" >> "{{proj}}/README.md"
    echo "[2]:{{git}}" >> "{{proj}}/README.md"
    echo "[3]:{{huburl}}" >> "{{proj}}/README.md"
    echo "[4]:" >> "{{proj}}/README.md"

    # 生成 compose.yaml
    echo "---" > "{{proj}}/compose.yaml"
    echo "# {{huburl}}" >> "{{proj}}/compose.yaml"
    echo "services:" >> "{{proj}}/compose.yaml"
    echo "  {{proj}}:" >> "{{proj}}/compose.yaml"
    echo "    container_name: {{proj}}" >> "{{proj}}/compose.yaml"
    echo "    env_file:" >> "{{proj}}/compose.yaml"
    echo "      - path: ./.env" >> "{{proj}}/compose.yaml"
    echo "        required: false" >> "{{proj}}/compose.yaml"
    echo "    hostname: {{proj}}" >> "{{proj}}/compose.yaml"
    echo "    image: {{image}}" >> "{{proj}}/compose.yaml"
    echo "#     ports:" >> "{{proj}}/compose.yaml"
    echo "#       - 80:80" >> "{{proj}}/compose.yaml"
    echo "    restart: unless-stopped" >> "{{proj}}/compose.yaml"

    # 生成 compose.override.yaml
    echo "---" > "{{proj}}/compose.override.yaml"
    echo "services:" >> "{{proj}}/compose.override.yaml"
    echo "  {{proj}}:" >> "{{proj}}/compose.override.yaml"
    echo "#     ports: !reset []" >> "{{proj}}/compose.override.yaml"
    echo "#     ports: !override" >> "{{proj}}/compose.override.yaml"
    echo '#       - ${SERV_PORT:-80}:80' >> "{{proj}}/compose.override.yaml"
    echo "#     volumes:" >> "{{proj}}/compose.override.yaml"
    echo "#       - ./data:/data" >> "{{proj}}/compose.override.yaml"

    create_backup="yes"
    if [ -n "$NO_BACKUP" ]; then
        create_backup="no"
        echo "通过环境变量禁用备份脚本"
    elif [ -t 0 ]; then
        read -p "是否备份脚本 (y/n)?" yn
        case $yn in
            [Yy]*)
                echo "将创建备份脚本" ;;
            *)
                create_backup="no"
                echo "无需备份脚本" ;;
        esac;
    else
        echo "非交互式环境，默认创建备份脚本"
    fi;
    if [ "$create_backup" = "yes" ]; then
        echo
        echo "创建 backup.sh"
        echo '#!/usr/bin/env bash' > "{{proj}}/backup.sh"
        echo "" >> "{{proj}}/backup.sh"
        echo "###" >> "{{proj}}/backup.sh"
        echo "#" >> "{{proj}}/backup.sh"
        echo "# 备份 {{proj}} 数据" >> "{{proj}}/backup.sh"
        echo "#" >> "{{proj}}/backup.sh"
        echo "###" >> "{{proj}}/backup.sh"
        echo "" >> "{{proj}}/backup.sh"
        echo 'if [[ -n "${DEBUG:-}" ]]; then' >> "{{proj}}/backup.sh"
        echo "    set -eux" >> "{{proj}}/backup.sh"
        echo "else" >> "{{proj}}/backup.sh"
        echo "    set -euo pipefail" >> "{{proj}}/backup.sh"
        echo "fi" >> "{{proj}}/backup.sh"
        echo "" >> "{{proj}}/backup.sh"
        echo "[[ -f {{proj}}.tar.xz ]] && rm -rf ./{{proj}}.tar.xz" >> "{{proj}}/backup.sh"
        echo "" >> "{{proj}}/backup.sh"
        echo "[[ -f ./exec_pre.sh ]] && bash ./exec_pre.sh" >> "{{proj}}/backup.sh"
        echo "" >> "{{proj}}/backup.sh"
        echo "tar -Jcf {{proj}}.tar.xz ./data" >> "{{proj}}/backup.sh"
        echo "" >> "{{proj}}/backup.sh"
        echo "[[ -f ./exec_post.sh ]] && bash ./exec_post.sh" >> "{{proj}}/backup.sh"
        echo "" >> "{{proj}}/backup.sh"
        echo "#rclone copy ./{{proj}}.tar.xz minio:/backup/databases" >> "{{proj}}/backup.sh"
        echo "echo \"backup {{proj}} data to minio done.\"" >> "{{proj}}/backup.sh"
        echo "echo \"Backup of {{proj}} data to MinIO completed successfully.\"" >> "{{proj}}/backup.sh"
        chmod +x "{{proj}}/backup.sh"
    else
        if [ -f "{{proj}}/backup.sh" ]; then
            echo "删除已存在的 backup.sh";
            rm -f "{{proj}}/backup.sh";
        fi;
    fi;
    echo
    echo "项目 {{proj}} 已创建"

# Recipe to initialize project based on name, URL, or image URL
init n p="":
    #!/usr/bin/env bash
    if [ -z "{{n}}" ]; then
        echo "错误：必须指定 n init n=<name>"
        exit 1
    fi
    set -e
    last_part="YES"
    if [ -n "{{p}}" ]; then last_part="NO"; fi
    name="{{n}}"
    TAG="latest"
    REGISTRY=""
    USER=""
    GIT_URL=""
    IMAGE_NAME=""
    IMAGE_PATH=""
    FULL_IMAGE=""
    IMAGE_URL=""
    REPO_URL="$name"
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
            TAG=$(echo "$name" | sed 's|.*||' | cut -d':' -f2)
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
    PROJECT="$IMAGE_NAME"
    if [ "$last_part" = "NO" ]; then PROJECT="$USER"; fi
    just create proj="$PROJECT" git="$GIT_URL" image="$FULL_IMAGE:$TAG" huburl="$IMAGE_URL"

# 初始化 Arcane 模板 (schema.json, registry.json)
arcane-init:
    curl -LO https://raw.githubusercontent.com/getarcaneapp/templates/refs/heads/main/schema.json
    curl -LO https://raw.githubusercontent.com/getarcaneapp/templates/refs/heads/main/registry.json && \
    jq '.templates=[] | .name="Jetsung Arcane Templates" | .description="Jetsung Docker Compose Templates for Arcane" | .author="jetsung" | .url="https://github.com/jetsung/awesome-compose" | .version="1.0.0"' registry.json > tmp.json && mv tmp.json registry.json

# 更新 registry.json 模板列表
update-registry prefix="https://raw.githubusercontent.com/jetsung/awesome-compose/refs/heads/main" v="1.0.0":
    #!/usr/bin/env bash
    URL_PREFIX="{{prefix}}"
    VERSION="{{v}}"
    echo "Updating registry.json with prefix: $URL_PREFIX, version: $VERSION"
    echo "[]" > registry_templates.json
    find . -name "compose.yaml" -not -path "*/.*" | sort > paths.tmp.txt
    while read -r compose_path; do
        dir=$(dirname "$compose_path" | sed 's|^\./||')
        folder_name=$(basename "$dir")
        if [ "$folder_name" = "distributed" ]; then continue; fi
        if [ "$folder_name" = "single" ]; then
            parent_dir=$(dirname "$dir")
            id=$(basename "$parent_dir")
            readme_path="$parent_dir/README.md"
        else
            id=$(echo "$dir" | tr '/' '-')
            readme_path="$dir/README.md"
        fi
        if [ ! -f "$readme_path" ]; then
            echo "提示：项目 $dir 不添加，因为缺少 $readme_path"
            continue
        fi
        name=$(head -n 1 "$readme_path" | sed 's/^# //')
        description=$(grep "^> " "$readme_path" | head -n 1 | sed 's/^> //' | sed 's/\[[^]]*\]\[[^]]*\] //g' | sed 's/^[[:space:]]*//' | sed 's/^是//')
        if [ -z "$description" ]; then description="$name"; fi
        compose_url="$URL_PREFIX/$dir/compose.yaml"
        documentation_url="$URL_PREFIX/$readme_path"
        env_url=""
        if [ -f "$dir/.env" ]; then env_url="$URL_PREFIX/$dir/.env"; fi
        jq --arg id "$id" \
           --arg name "$name" \
           --arg desc "$description" \
           --arg ver "$VERSION" \
           --arg compose "$compose_url" \
           --arg doc "$documentation_url" \
           --arg env "$env_url" \
           '. += [({id: $id, name: $name, description: $desc, version: $ver, author: "jetsung", compose_url: $compose} + (if $env != "" then {env_url: $env} else {} end) + {documentation_url: $doc, tags: [$id]})]' \
           registry_templates.json > registry_templates.json.new && mv registry_templates.json.new registry_templates.json
    done < paths.tmp.txt
    jq --slurpfile t registry_templates.json '.templates = $t[0]' registry.json > registry.json.new && mv registry.json.new registry.json
    rm registry_templates.json paths.tmp.txt
    echo "registry.json updated successfully."

# 更新单个模板
update-template id prefix="https://raw.githubusercontent.com/jetsung/awesome-compose/refs/heads/main" v="1.0.0":
    #!/usr/bin/env bash
    input_dir=$(echo "{{id}}" | sed 's|/$$||')
    work_dir="$input_dir"
    if [ -d "$input_dir/single" ] && [ -f "$input_dir/single/compose.yaml" ]; then
        work_dir="$input_dir/single"
    fi
    if [ ! -f "$work_dir/compose.yaml" ]; then
        echo "错误：项目 $work_dir 缺少 compose.yaml"
        exit 1
    fi
    folder_name=$(basename "$work_dir")
    if [ "$folder_name" = "single" ]; then
        parent_dir=$(dirname "$work_dir")
        real_id=$(basename "$parent_dir")
        readme_path="$parent_dir/README.md"
    else
        real_id=$(echo "$work_dir" | tr '/' '-')
        readme_path="$work_dir/README.md"
    fi
    if [ ! -f "$readme_path" ]; then
        echo "提示：项目 $work_dir 不添加，因为缺少 $readme_path"
        exit 1
    fi
    URL_PREFIX="{{prefix}}"
    VERSION="{{v}}"
    name=$(head -n 1 "$readme_path" | sed 's/^# //')
    description=$(grep "^> " "$readme_path" | head -n 1 | sed 's/^> //' | sed 's/\[[^]]*\]\[[^]]*\] //g' | sed 's/^[[:space:]]*//' | sed 's/^是//')
    if [ -z "$description" ]; then description="$name"; fi
    compose_url="$URL_PREFIX/$work_dir/compose.yaml"
    documentation_url="$URL_PREFIX/$readme_path"
    env_url=""
    if [ -f "$work_dir/.env" ]; then env_url="$URL_PREFIX/$work_dir/.env"; fi
    template=$(jq -n --arg id "$real_id" \
           --arg name "$name" \
           --arg desc "$description" \
           --arg ver "$VERSION" \
           --arg compose "$compose_url" \
           --arg doc "$documentation_url" \
           --arg env "$env_url" \
           '{id: $id, name: $name, description: $desc, version: $ver, author: "jetsung", compose_url: $compose} + (if $env != "" then {env_url: $env} else {} end) + {documentation_url: $doc, tags: [$id]}')

    FILTER='(.templates | map(.id) | index($id)) as $idx | if $idx then .templates[$idx] = $t else .templates += [$t] end | .templates |= sort_by(.id)'
    jq --arg id "$real_id" --argjson t "$template" "$FILTER" registry.json > registry.json.new && mv registry.json.new registry.json
    echo "Template $real_id updated (version $VERSION) in registry.json."
