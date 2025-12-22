# Makefile
#
# Usage: make init n=<name|url|image_url> [p=1]

MAKEFLAGS += --no-print-directory
# NAMES = test idevsig/filetas idevsig/filetas:python ghcr.io/idev-sig/filetas:latest https://github.com/idev-sig/filetas/pkgs/container/filetas https://hub.docker.com/r/idevsig/filetas

.PHONY: help
help: ## 显示帮助信息
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@awk '/^[a-zA-Z_-]+:.*?##/ { \
		printf "  \033[36m%-20s\033[0m %s\n", $$1, substr($$0, index($$0, "##") + 3) \
	}' $(MAKEFILE_LIST)

.PHONY: create
create: ## 创建项目：create proj="" git="" image="" huburl=""
# 	proj 文件夹名称
# 	git  仓库地址
# 	image Docker 镜像地址
# 	huburl Docker 镜像仓库地址
	@if [ -z "$(proj)" ]; then \
		echo "错误：必须指定 create proj=<name>"; \
		exit 1; \
	fi

# 	判断目录是否已存在，若存在则让用户决定是否覆盖
	@if [ -d "$(proj)" ]; then \
		echo "目录 $(proj) 已存在"; \
		read -p "是否覆盖 (y/n)?" yn; \
		case $$yn in \
			[Yy]*) ;; \
			*) \
				echo "操作取消"; \
				exit 1; \
				;; \
		esac; \
	fi

	@echo
	@echo "创建项目目录: $(proj)"
	@mkdir -p "$(proj)"

    # 生成 .env 文件
	@echo "# CUSTOM" > "$(proj)/.env"
	@echo "TZ=Asia/Shanghai" >> "$(proj)/.env"
	@echo "SERV_PORT=80" >> "$(proj)/.env"

    # 生成 README.md
 @echo "# $(proj)" > "$(proj)/README.md"
 @echo "" >> "$(proj)/README.md"
 @echo "[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]" >> "$(proj)/README.md"
 @echo "" >> "$(proj)/README.md"
 @echo "---" >> "$(proj)/README.md"
 @echo "" >> "$(proj)/README.md"
 @echo "> [$(proj)][1]" >> "$(proj)/README.md"
 @echo "" >> "$(proj)/README.md"
 @echo "[1]:" >> "$(proj)/README.md"
 @echo "[2]:$(git)" >> "$(proj)/README.md"
 @echo "[3]:$(huburl)" >> "$(proj)/README.md"
 @echo "[4]:" >> "$(proj)/README.md"

    # 生成 compose.yaml
 @echo "---" > "$(proj)/compose.yaml"
	@echo "" >> "$(proj)/compose.yaml"
	@echo "# $(huburl)" >> "$(proj)/compose.yaml"
	@echo "services:" >> "$(proj)/compose.yaml"
	@echo "  $(proj):" >> "$(proj)/compose.yaml"
	@echo "    image: $(image)" >> "$(proj)/compose.yaml"
	@echo "    container_name: $(proj)" >> "$(proj)/compose.yaml"
	@echo "    hostname: $(proj)" >> "$(proj)/compose.yaml"
	@echo "    restart: unless-stopped" >> "$(proj)/compose.yaml"
	@echo "    env_file:" >> "$(proj)/compose.yaml"
	@echo "      - path: ./.env" >> "$(proj)/compose.yaml"
	@echo "        required: false" >> "$(proj)/compose.yaml"
	@echo "#     ports:" >> "$(proj)/compose.yaml"
	@echo '#       - 80:80' >> "$(proj)/compose.yaml"

    # 生成 compose.override.yaml
 @echo "---" > "$(proj)/compose.override.yaml"
	@echo "" >> "$(proj)/compose.override.yaml"
	@echo "services:" >> "$(proj)/compose.override.yaml"
	@echo "  $(proj):" >> "$(proj)/compose.override.yaml"
	@echo "#     ports: !reset []" >> "$(proj)/compose.override.yaml"
	@echo "#     ports: !override" >> "$(proj)/compose.override.yaml"
	@echo '#       - $${SERV_PORT:-80}:80' >> "$(proj)/compose.override.yaml"
	@echo "#     volumes:" >> "$(proj)/compose.override.yaml"
	@echo "#       - ./data:/data" >> "$(proj)/compose.override.yaml"

    # 生成 backup.sh
	@echo '#!/usr/bin/env bash' > "$(proj)/backup.sh"
	@echo "" >> "$(proj)/backup.sh"
	@echo "###" >> "$(proj)/backup.sh"
	@echo "#" >> "$(proj)/backup.sh"
	@echo "# 备份 $(proj) 数据" >> "$(proj)/backup.sh"
	@echo "#" >> "$(proj)/backup.sh"
	@echo "###" >> "$(proj)/backup.sh"
	@echo "" >> "$(proj)/backup.sh"
	@echo 'if [[ -n "$${DEBUG:-}" ]]; then' >> "$(proj)/backup.sh"
	@echo "    set -eux" >> "$(proj)/backup.sh"
	@echo "else" >> "$(proj)/backup.sh"
	@echo "    set -euo pipefail" >> "$(proj)/backup.sh"
	@echo "fi" >> "$(proj)/backup.sh"
	@echo "" >> "$(proj)/backup.sh"
	@echo "[[ -f $(proj).tar.xz ]] && rm -rf ./$(proj).tar.xz" >> "$(proj)/backup.sh"
	@echo "" >> "$(proj)/backup.sh"
	@echo "tar -Jcf $(proj).tar.xz ./data" >> "$(proj)/backup.sh"
	@echo "" >> "$(proj)/backup.sh"
	@echo "#rclone copy ./$(proj).tar.xz minio:/backup/databases" >> "$(proj)/backup.sh"
	@echo "echo \"backup $(proj) data to minio done.\"" >> "$(proj)/backup.sh"
	@echo "echo \"Backup of $(proj) data to MinIO completed successfully.\"" >> "$(proj)/backup.sh"
	@echo
	@echo "项目 $(proj) 已创建"

.PHONY: init
init: ## 初始化项目：n=文件夹名称、镜像名称、镜像地址，p=1 文件夹名称使用前面部分
	@if [ -z "$(n)" ]; then \
		echo "错误：必须指定 n init n=<name>"; \
		exit 1; \
	fi

	@last_part="YES" ; \
	if [ -n "$(p)" ]; then \
		last_part="NO" ; \
	fi ;\
	name="$(n)" ;\
	# 文件夹名称 \
	FOLDER="" ;\
	# 初始化环境变量 \
	TAG="latest" ;\
	REGISTRY="" ;\
	USER="" ;\
	GIT_URL="" ;\
	IMAGE_NAME="" ;\
	IMAGE_PATH="" ;\
	FULL_IMAGE="" ;\
	IMAGE_URL="" ;\
	REPO_URL="$$name"; \
	# 判断是否为 GitHub Package URL \
	if echo "$$name" | grep -q "^https://github.com/.*"; then \
		REGISTRY="ghcr.io"; \
		# 提取 user 和 image-name \
		USER=`echo "$$name" | sed 's|^https://github.com/||' | cut -d'/' -f1`; \
		IMAGE_NAME=`echo "$$name" | sed 's|.*/pkgs/container/||'`; \
		IMAGE_PATH="$$USER/$$IMAGE_NAME"; \
		FULL_IMAGE="$$REGISTRY/$$IMAGE_PATH"; \
		IMAGE_URL="$$name"; \
		GIT_URL="https://github.com/$$IMAGE_PATH"; \
	elif echo "$$name" | grep -q "^https://hub.docker.com/r/.*"; then \
		REGISTRY=""; \
		# 提取 user 和 image-name \
		USER=`echo "$$name" | sed 's|^https://hub.docker.com/r/||' | cut -d'/' -f1`; \
		IMAGE_NAME=`echo "$$name" | sed 's|^https://hub.docker.com/r/||' | cut -d'/' -f2`; \
		IMAGE_PATH="$$USER/$$IMAGE_NAME"; \
		FULL_IMAGE="$$IMAGE_PATH"; \
		IMAGE_URL="$$name"; \
	else \
		NAME="$$name" ;\
		HUB_REGISTRY="https://hub.docker.com/r/"; \
		if echo "$$name" | grep -q ":"; then \
			# 取出 TAG \
			TAG=`echo "$$name" | sed 's|.*/||' | cut -d':' -f2`; \
			# 去除 TAG 后的 URL \
			NAME=`echo "$$name" | cut -d':' -f1`; \
		fi ;\
		# 提取 user 和 image-name \
		IMAGE_NAME="$$NAME" ;\
		IMAGE_PATH="$$NAME" ;\
		FULL_IMAGE="$$NAME" ;\
		# 提取 ghcr 信息 \
		IMAGE_URL="$$HUB_REGISTRY$$IMAGE_PATH"; \
		if echo "$$NAME" | grep -q "^ghcr.io/.*"; then \
			REGISTRY="ghcr.io"; \
			# 提取 user 和 image-name \
			USER=`echo "$$NAME" | sed 's|^ghcr.io/||' | cut -d'/' -f1`; \
			IMAGE_NAME=`echo "$$NAME" | sed 's|^ghcr.io/||' | cut -d'/' -f2`; \
			IMAGE_PATH="$$USER/$$IMAGE_NAME"; \
			FULL_IMAGE="$$REGISTRY/$$IMAGE_PATH"; \
			IMAGE_URL="https://github.com/$$USER/$$IMAGE_NAME/pkgs/container/$$IMAGE_NAME"; \
			GIT_URL="https://github.com/$$USER/$$IMAGE_NAME"; \
		else \
			# 提取 user 和 image-name \
			if echo "$$NAME" | grep -q "/.*"; then \
				# 将 name 按 / 分割并提取最后两个部分 \
				USER=`echo "$$NAME" | awk -F'/' '{print $$(NF-1)}'`; \
				IMAGE_NAME=`echo "$$NAME" | awk -F'/' '{print $$NF}'`; \
				IMAGE_PATH="$$USER/$$IMAGE_NAME"; \
			fi ;\
		fi ;\
	fi ;\
	echo ;\
	echo "Registry: $$REGISTRY"; \
	echo "标签: $$TAG"; \
	echo "用户: $$USER"; \
	echo "镜像: $$IMAGE_NAME"; \
	echo "镜像路径: $$IMAGE_PATH"; \
	echo "完整镜像: $$FULL_IMAGE"; \
	echo "GitHub URL: $$GIT_URL"; \
	echo "网页地址：$$IMAGE_URL" ; \
	echo ;\
	# 使用前面部分作为文件夹名称 \
	PROJECT="$$IMAGE_NAME" ;\
	# 如果是 NO, 则使用前面部分作为文件夹名称 \
	if [ "$$last_part" = "NO" ]; then \
		PROJECT="$$USER"; \
	fi ;\
	$(MAKE) create proj="$$PROJECT" git="$$GIT_URL" image="$$FULL_IMAGE:$$TAG" huburl="$$IMAGE_URL"
