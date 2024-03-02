#!/bin/sh

add_crond() {
    DEVPATH=$(pwd)

    if [ -n "${CRON}" ]; then
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

    cd /app

    # 过滤一些文件的缓存
    #cp -r /data/!(*~) /rsync
    # rsync: https://zhuanlan.zhihu.com/p/441161884
    #     --include="*.php" --exclude="*"
    rsync -a -f ". ./rsync.rules" /data/* /rsync/

    # 需要自行修改
    # aliyun:/rclone 需要修改为你第二步的配置
    rclone copy -P /rsync aliyun:rclone1

    notify | tee -a /app/rclone.log
}

apk_add() {
    RSYNC_CMD=$(which rsync)
    
    if [ -z "${RSYNC_CMD}" ]; then
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
        apk update
        apk add rsync
    fi
}

notify() {
    CURL_CMD=$(which curl)
    if [ -z "${CURL_CMD}" ]; then
        apk add curl
    fi

    OPENSSL_CMD=$(which openssl)
    if [ -z "${OPENSSL_CMD}" ]; then
        apk add openssl
    fi

    if [ -f "./notify.sh" ] && [ -f "./.env" ]; then
        . ./.env
        sh ./notify.sh -u "${URL}" -s "${SECRET}" -m "rclone 同步成功"
    fi
}

run_loop() {
    while true; do date -R; sleep 360; done
}

main() {
    copy_files

    if [ "${1}" = "cron" ]; then
        add_crond
        run_loop
    fi
}

main "$@"
