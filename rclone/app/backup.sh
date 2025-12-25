#!/bin/sh

set -eux

add_crond() {
    DEVPATH=$(pwd)

    if [ -n "${CRON:-}" ]; then
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
        apk update

        echo "${CRON} cd ${DEVPATH}; /bin/sh /app/backup.sh" >> /var/spool/cron/crontabs/root
        crond
    fi
}

copy_files() {
    apk_add

    # 创建缓存文件夹
    [ -d /rsync ] || mkdir /rsync

    cd /app || exit 1

    # 过滤一些文件的缓存
    #cp -r /data/!(*~) /rsync
    # rsync: https://zhuanlan.zhihu.com/p/441161884
    #     --include="*.php" --exclude="*"
    # Use /data/ to sync directory contents, avoiding shell glob expansion issues with empty dirs
    rsync -a -f ". ./rsync.rules" /data/ /rsync/

    # 需要自行修改
    # aliyun:/rclone 需要修改为你第二步的配置
    rclone copy -P /rsync aliyun:rclone

    notify | tee -a /data/rclone.log
}

apk_add() {
    # Check for rsync without triggering set -e if missing
    if ! command -v rsync >/dev/null 2>&1; then
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
        apk update
        apk add rsync
    fi
}

notify() {
    # Check for curl
    if ! command -v curl >/dev/null 2>&1; then
        apk add curl
    fi

    # Check for openssl
    if ! command -v openssl >/dev/null 2>&1; then
        apk add openssl
    fi

    if [ -f "./notify.sh" ] && [ -f "./.env" ]; then
        # shellcheck disable=SC1091
        . ./.env
        sh ./notify.sh -u "${URL:-}" -s "${SECRET:-}" -m "rclone 同步成功"
    fi
}

run_loop() {
    while true; do date -R; sleep 360; done
}

main() {
    copy_files

    if [ "${1:-}" = "cron" ]; then
        add_crond
        run_loop
    fi
}

main "$@"
