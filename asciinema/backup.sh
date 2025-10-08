#!/usr/bin/env bash

#============================================================
# File: backup.sh
# Description: 备份数据库、文件夹、文件的脚本
# URL: https://fx4.cn/sWlt0d
# Author: Jetsung Chan <i@jetsung.com>
# Version: 0.1.0
# CreatedAt: 2025-09-07
# UpdatedAt: 2025-09-07
#============================================================

# 启用严格模式（根据 DEBUG 环境变量决定是否打印命令）
if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

# 带时间戳的日志函数（输出到 stderr）
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

# 显示帮助信息并退出
show_help() {
    cat <<EOF
用法: $0 [选项]

备份脚本：将指定目录/文件打包为 tar.xz，并通过 rclone 同步到远程存储。

选项:
  -h, --help              显示本帮助并退出。
  MODE                    项目名模式或字面值：
                          - 空或 2：脚本所在顶级目录名（如 /home/user/app → app）
                          - 1：当前目录名
                          - 3：父目录名
                          - 任意字符串：直接使用（如 "myapp"）
  DAYS                    保留备份的天数（默认：3）
  DELIMITER               切割项目名的分隔符（如 '-'）
  FIELD                   提取第几个字段（如 "foo-bar" + 分隔符'-' + 字段2 → "bar"）

配置文件:
  可在脚本目录下的 .env 文件中定义以下变量（命令行参数优先）：
    # project_name=your_project_name   # 覆盖 MODE（除非命令行传字面值）
    # targetdir=data                   # 云端路径名
    # backdir=./data                   # 本地要备份的路径

优先级：命令行字面值 > .env 配置 > 命令行模式 > 自动推导

示例:
  $0                    # 使用顶级目录名，保留3天，不切割
  $0 myproject 7        # 使用字面值 "myproject"，保留7天（覆盖 .env）
  $0 1 7 '-' 2          # 使用当前目录名（若无 .env 则计算），按'-'切割取第2段
  $0 -h                 # 显示帮助

EOF
    exit 0
}

# 根据模式获取项目名称（仅当未通过 .env 或 CLI 设置时使用）
get_project_name() {
    local mode="$1"
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || {
        log "错误：无法确定脚本所在目录"
        exit 1
    }

    case "${mode:-}" in
        ""|2)
            # 提取顶级目录（根目录后的第一部分）
            if [[ "$script_dir" == "/" ]]; then
                log "错误：脚本位于根目录，无法提取顶级目录名"
                exit 1
            fi
            IFS='/' read -ra parts <<<"$script_dir"
            if [[ ${#parts[@]} -lt 2 ]]; then
                log "错误：路径中无顶级目录：$script_dir"
                exit 1
            fi
            echo "${parts[1]}"
            ;;
        1)
            # 当前目录名
            basename "$script_dir"
            ;;
        3)
            # 父目录名
            basename "$(dirname "$script_dir")"
            ;;
        *)
            # 直接使用输入值（需非空）
            if [[ -z "$mode" ]]; then
                log "错误：模式值无效"
                exit 1
            fi
            echo "$mode"
            ;;
    esac
}

# 验证输入参数
validate_inputs() {
    local days="$1" delimiter="$2" field="$3"

    # 验证天数必须为正整数
    if ! [[ "$days" =~ ^[1-9][0-9]*$ ]]; then
        log "错误：天数必须是正整数"
        exit 1
    fi

    # 若提供分隔符，必须同时提供字段号
    if [[ -n "$delimiter" && -z "$field" ]]; then
        log "错误：使用分隔符时必须指定字段号"
        exit 1
    fi

    # 字段号必须为正整数
    if [[ -n "$field" && ! "$field" =~ ^[1-9][0-9]*$ ]]; then
        log "错误：字段号必须是正整数"
        exit 1
    fi
}

# 跨平台计算 N 天前的日期（兼容 GNU/Linux 和 macOS/BSD）
get_date_days_ago() {
    local days="$1"
    local result

    if command -v gdate >/dev/null 2>&1; then
        result=$(gdate -d "$days days ago" +%Y%m%d) || {
            log "错误：gdate 计算 $days 天前日期失败"
            exit 1
        }
    elif [[ "$(uname)" == "Darwin" ]] || [[ "$(uname)" == *BSD* ]]; then
        result=$(date -j -v -"${days}d" +%Y%m%d 2>/dev/null) || {
            log "错误：BSD/macOS date 计算 $days 天前日期失败"
            exit 1
        }
    else
        result=$(date -d "$days days ago" +%Y%m%d 2>/dev/null) || {
            log "错误：GNU date 计算 $days 天前日期失败"
            exit 1
        }
    fi

    echo "$result"
}

# 从 .env 文件加载配置（只读取你需要的三项：project_name, targetdir, backdir）
load_env_config() {
    local env_file="$1"
    [[ ! -f "$env_file" ]] && return 0

    # # 或 echo ""
    env_project_name=$(grep '# project_name=' "$env_file" | cut -d= -f2 | xargs 2>/dev/null || true) 
    env_targetdir=$(grep '# targetdir=' "$env_file" | cut -d= -f2 | xargs 2>/dev/null || true)
    env_backdir=$(grep '# backdir=' "$env_file" | cut -d= -f2 | xargs 2>/dev/null || true)
}

# 执行脚本
do_exec() {
    pushd "${1:-}" > /dev/null 2>&1
    local exec_file="./exec_${2:-}.sh"
    if [[ -f "$exec_file" ]]; then
        if ! "$exec_file"; then
            log "错误：执行 $exec_file 失败"
            exit 1
        fi
    fi
    popd > /dev/null 2>&1
}

# 主函数
main() {
    # 检查帮助参数
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        show_help
    fi

    local mode="${1:-}" days="${2:-3}" delimiter="${3:-}" field="${4:-1}"
    local project_name keep_days today delete_tar current_tar backdir

    # 验证输入参数
    validate_inputs "$days" "$delimiter" "$field"

    # 获取脚本目录和 .env 文件路径
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    local env_file="$script_dir/.env"

    # 前置执行
    do_exec "$script_dir" pre

    # 初始化环境变量（默认值）
    local env_project_name="" env_targetdir="data" env_backdir=""

    # 从 .env 加载配置
    load_env_config "$env_file"

    # 确定项目名：字面值 > .env > 模式 > 自动推导
    if [[ -n "$mode" ]]; then
        case "$mode" in
            1|2|3|"")
                # 是模式标识符，不直接用 —— 优先用 .env 配置
                if [[ -n "$env_project_name" ]]; then
                    project_name="$env_project_name"
                else
                    project_name=$(get_project_name "$mode") || {
                        log "错误：无法根据模式 '$mode' 获取项目名"
                        exit 1
                    }
                fi
                ;;
            *)
                # 是字面值，最高优先级，直接使用
                project_name="$mode"
                ;;
        esac
    else
        # mode 为空，优先 .env，其次自动推导
        if [[ -n "$env_project_name" ]]; then
            project_name="$env_project_name"
        else
            project_name=$(get_project_name "") || {
                log "错误：无法自动推导项目名"
                exit 1
            }
        fi
    fi

    # 如果指定了分隔符，对项目名进行切割
    if [[ -n "$delimiter" ]]; then
        local cut_result
        cut_result=$(echo "$project_name" | cut -d"$delimiter" -f"$field") || {
            log "错误：切割项目名失败（分隔符：'$delimiter'，字段：'$field'）"
            exit 1
        }
        if [[ -z "$cut_result" ]]; then
            log "错误：切割后项目名为空（原值：'$project_name'）"
            exit 1
        fi
        project_name="$cut_result"
    fi

    # 最终验证项目名非空
    if [[ -z "$project_name" ]]; then
        log "错误：项目名为空"
        exit 1
    fi

    # 计算日期
    keep_days=$(get_date_days_ago "$days") || exit 1
    today=$(date +%Y%m%d) || {
        log "错误：获取当前日期失败"
        exit 1
    }

    # 设置压缩包文件名
    delete_tar="${project_name}_${keep_days}.tar.xz"
    current_tar="${project_name}_${today}.tar.xz"

    # 确定备份目标目录：优先 .env 的 backdir，最后默认 ./data
    if [[ -n "$env_backdir" ]]; then
        backdir="$env_backdir"
    else
        backdir="./data"
    fi

    # 记录原始目录，用于最后返回
    local original_dir
    original_dir=$(pwd)

    # 切换到脚本目录
    cd "$script_dir" || {
        log "错误：无法切换到脚本目录：$script_dir"
        exit 1
    }

    # 检查备份目标是否存在
    if [[ ! -e "$backdir" ]]; then
        log "错误：备份目标不存在：$backdir"
        exit 1
    fi

    # 清理本地旧备份（忽略错误，仅记录警告）
    if rm -f "${project_name}"*.tar.xz; then 
        log "已清理本地旧备份"
    else
        log "警告：清理本地旧备份时部分失败"
    fi

    # 检查 tar 命令是否存在
    if ! command -v tar >/dev/null; then
        log "错误：未找到 tar 命令"
        exit 1
    fi

    # 创建新压缩包（统一处理目录和文件）
    local tar_source
    if [[ -d "$backdir" ]]; then
        tar_source="-C $(dirname "$backdir") $(basename "$backdir")"
    else
        tar_source="$backdir"
    fi

    # shellcheck disable=SC2086
    if tar -Jcf "$current_tar" $tar_source; then
        log "已创建压缩包：$current_tar"
    else
        log "错误：创建压缩包失败：$current_tar"
        exit 1
    fi

    # 检查 rclone 是否可用
    if ! command -v rclone >/dev/null; then
        log "错误：未找到 rclone 命令"
        exit 1
    fi

    # 验证 rclone 配置
    if ! rclone config show >/dev/null 2>&1; then
        log "错误：rclone 配置无效或缺失"
        exit 1
    fi

    : ${env_targetdir:=databases}

    # 固定远程存储路径（根据你的实际需求硬编码，不从 .env 读取）
    local remotes=(
        "qcloud:backup-1251136007/${env_targetdir}"
        "minio:/backup/${env_targetdir}"
    )

    # 遍历每个远程目标：删除旧备份，上传新备份（带重试）
    for remote_path in "${remotes[@]}"; do
        local remote_delete_tar="${remote_path}/${delete_tar}"
        # local remote_current_tar="${remote_path}/${current_tar}"

        # 删除远程旧备份（如果存在）
        if rclone lsf "$remote_path" --files-only --include "${delete_tar}" >/dev/null 2>&1; then
            if rclone delete "$remote_delete_tar" >/dev/null 2>&1; then
                log "已删除远程旧备份：$remote_delete_tar"
            else
                log "警告：删除远程旧备份失败：$remote_delete_tar，继续"
            fi
        else
            log "远程旧备份不存在，跳过：$remote_delete_tar"
        fi

        # 上传新备份（最多重试 3 次）
        local retries=3 attempt=1
        while [[ $attempt -le $retries ]]; do
            if rclone copy "$current_tar" "$remote_path" --progress; then
                log "成功上传 $current_tar 到 $remote_path"
                break
            else
                log "警告：上传失败（第 $attempt/$retries 次）：$current_tar → $remote_path"
                if [[ $attempt -eq $retries ]]; then
                    log "错误：上传失败超过 $retries 次，终止"
                    exit 1
                fi
                sleep 5
                ((attempt++))
            fi
        done
    done

    log "项目 '$project_name' 备份成功同步至所有远程存储"

    # 后置操作
    do_exec "$script_dir" post

    # 返回原始目录（失败仅记录警告）
    cd "$original_dir" 2>/dev/null || log "警告：无法返回原始目录：$original_dir"
}

# 执行主函数
main "$@"

###
#
# 执行示例：
# 备份名称使用模式 3 （父目录名）作为项目名称，保持最近 3 天数据，分隔符为 - 作为分隔符且使用第 1 部分作为项目名称
# ./backup.sh 3 3 - 1
#
# ./.env 配置示例（含 “# ”）:
# project_name=project
# targetdir=/path/to/backup
# backdir=/path/to/backup
#
# 扩展脚本：
# ./exec_?.sh （? 为 pre 或 post）
# 使之支持先打包再备份，或备份完成后发送 PUSH 通知
#
##
