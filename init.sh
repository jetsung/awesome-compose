#!/usr/bin/env bash

###
#
# 根据 compose.yaml 是否存在 ./data 判断创建 backup.sh 文件的文件
#
###

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

create_backup() {
    local _project="${1:-}"
    if [[ -z "${_project}" ]]; then
        return 0
    fi

    local _override="${2:-}"
    if [[ -f "./backup.sh" ]]; then
        if [[ -z "${_override}" ]]; then
            echo "backup.sh already exists."
            return 0
        fi

        echo "override backup.sh"
    fi

    cat > "backup.sh" <<EOF
#!/usr/bin/env bash

###
#
# 备份 ${_project} 数据
#
###

if [[ -n "\${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

[ -f ${_project}.tar.xz ] && rm -rf ./${_project}.tar.xz

tar -Jcf ${_project}.tar.xz ./data

#rclone copy ./${_project}.tar.xz minio:/backup/databases
echo "backup ${_project} data to minio done."
echo "Backup of ${_project} data to MinIO completed successfully."

EOF
}

find_project() {
    local _override="${1:-}"
    find . -mindepth 2 -maxdepth 2 -type f -name "compose.yaml" -exec grep -q " - ./data:/" {} \; -print0 | sort -u -z |
        while IFS= read -r -d '' file; do
            _project=$(awk -F'/' '{print $2}' <<< "${file}")
            pushd "${_project}" > /dev/null || exit
            echo "Project: ${_project}"
            create_backup "${_project}" "${_override}"
            echo
            popd > /dev/null || exit
        done
}

main() {
    find_project "$@"
}

main "$@"
