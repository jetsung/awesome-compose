#!/usr/bin/env bash

###
#  计划任务，每日检测证书更新，并重启 NGINX
#  SSL 更新后，需要重启 NGINX，否则无法生效
#  首次使用需先执行 ./cron.sh install 安装计划任务
###

# NGINX 重载命令（按实际环境修改）
restart_nginx() {

    if [[ -f "/etc/init.d/nginx" ]]; then
        # bt
        /etc/init.d/nginx stop
        /etc/init.d/nginx start
    else
        # systemd
        systemctl reload nginx
    fi

    echo -e "$(date -R) nginx reload"
}

# 安装计划任务
install() {
    BASEPATH=$(pwd)
    # 每天 3:15 触发一次更新
    tee /etc/cron.d/dockeracme <<-EOF
15 3 * * * root cd ${BASEPATH}; /bin/bash ./cron.sh
EOF

    systemctl restart cron
}

main() {
    # SSL 证书文件夹（按实际环境修改）
    SSL_PATH="/srv/acme/ssl"

    # 一天内被修改过的文件
    HAS_NEW=$(find "${SSL_PATH}" -type f -mtime -1)

    echo "$HAS_NEW"
    if [[ -n "$HAS_NEW" ]]; then
        restart_nginx | tee -a ./update.log
    fi

    [[ "${1}" = "install" ]] && install
}

main "$@" || exit 1

# ./cron.sh install
