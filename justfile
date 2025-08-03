# justfile
# 初始化 Docker Compose 项目
init SERVICE_NAME:
  @if [ -d "{{SERVICE_NAME}}" ]; then \
      read -r -p "文件夹 '{{SERVICE_NAME}}' 已存在，是否删除？[y/N] " DEL_DIR; \
      if [ "$DEL_DIR" = "y" ] || [ "$DEL_DIR" = "Y" ]; then \
          rm -rf "{{SERVICE_NAME}}"; \
          echo "已删除 {{SERVICE_NAME}}"; \
      else \
          echo "保留原有目录"; \
      fi; \
  fi

  @echo

  # 创建项目目录
  @mkdir -p "{{SERVICE_NAME}}"

  # 生成 .env 文件
  @echo "# CUSTOM" > "{{SERVICE_NAME}}/.env"
  @echo "TZ=Asia/Shanghai" >> "{{SERVICE_NAME}}/.env"
  @echo "SERV_PORT=80" >> "{{SERVICE_NAME}}/.env"

  # 生成 README.md
  @echo "# {{SERVICE_NAME}}" > "{{SERVICE_NAME}}/README.md"
  @echo "" >> "{{SERVICE_NAME}}/README.md"
  @echo "[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]" >> "{{SERVICE_NAME}}/README.md"
  @echo "" >> "{{SERVICE_NAME}}/README.md"
  @echo "---" >> "{{SERVICE_NAME}}/README.md"
  @echo "" >> "{{SERVICE_NAME}}/README.md"
  @echo "> [{{SERVICE_NAME}}][1]" >> "{{SERVICE_NAME}}/README.md"
  @echo "" >> "{{SERVICE_NAME}}/README.md"
  @echo "[1]:" >> "{{SERVICE_NAME}}/README.md"
  @echo "[2]:" >> "{{SERVICE_NAME}}/README.md"
  @echo "[3]:" >> "{{SERVICE_NAME}}/README.md"
  @echo "[4]:" >> "{{SERVICE_NAME}}/README.md"

  # 生成 compose.yml
  @echo "---" > "{{SERVICE_NAME}}/compose.yml"
  @echo "# https://hub.docker.com/r/{{SERVICE_NAME}}" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "services:" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "  {{SERVICE_NAME}}:" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "    image: {{SERVICE_NAME}}:latest" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "    container_name: {{SERVICE_NAME}}" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "    restart: unless-stopped" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     ports:" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     - \${SERV_PORT:-80}:80" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     volumes:" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     - ./data:/data" >> "{{SERVICE_NAME}}/compose.yml"

  # 生成 compose.override.yml
  @echo "---" > "{{SERVICE_NAME}}/compose.override.yml"
  @echo "services:" >> "{{SERVICE_NAME}}/compose.override.yml"
  @echo "  {{SERVICE_NAME}}:" >> "{{SERVICE_NAME}}/compose.override.yml"
  @echo "    env_file:" >> "{{SERVICE_NAME}}/compose.override.yml"
  @echo "    - ./.env" >> "{{SERVICE_NAME}}/compose.override.yml"

  @echo
  @echo "项目 {{SERVICE_NAME}} 已创建"
