# justfile
# 初始化 Docker Compose 项目
init SERVICE_NAME:
  # 创建项目目录
  mkdir -p "{{SERVICE_NAME}}"

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
  @echo "---"
  @echo "# https://hub.docker.com/r/{{SERVICE_NAME}}" > "{{SERVICE_NAME}}/compose.yml"
  @echo "services:" > "{{SERVICE_NAME}}/compose.yml"
  @echo "  {{SERVICE_NAME}}:" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "    image: {{SERVICE_NAME}}:latest" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "    container_name: {{SERVICE_NAME}}" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "    restart: unless-stopped" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     ports:" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     - \${SERV_PORT:-80}:80" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     volumes:" >> "{{SERVICE_NAME}}/compose.yml"
  @echo "#     - ./data:/data" >> "{{SERVICE_NAME}}/compose.yml"

  # 生成 compose.override.yml
  @echo "services:" > "{{SERVICE_NAME}}/compose.override.yml"
  @echo "  {{SERVICE_NAME}}:" >> "{{SERVICE_NAME}}/compose.override.yml"
  @echo "    env_file:" >> "{{SERVICE_NAME}}/compose.override.yml"
  @echo "    - ./.env" >> "{{SERVICE_NAME}}/compose.override.yml"

  @echo "项目 {{SERVICE_NAME}} 已创建"
