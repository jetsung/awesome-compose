#!/bin／sh

## 钉钉、飞书 通知

get_vars() {
    while [ $# -gt 0 ]
    do
    case "${1}" in
        # 需要发送的消息内容
        -m | --message )
        MESSAGE="${2}"
        shift
        ;;

        # 需要发送的消息内容
        -u | --url )
        URL="${2}"
        shift
        ;;
        
        # 密钥
        -s | --secret )
        SECRET="${2}"
        shift
        ;;

        # 时间戳
        -t | --timestamp )
        TS="${2}"
        shift
        ;;
    esac
    shift
    done
}

send_msg() {
    [ -n "${TS}" ] || TS="$(date +%s)"

	sendData1='{
		"msg_type": "text",
		"content": {"text": "消息通知: %s "},
		"sign": "%s",
		"timestamp": %d
	}'

	sendData2='{
  "msgtype": "text",
  "text": {
    "content": "消息通知： %s "
  },
  "at": {
    "isAtAll": false
  }
}'    

    if [ -n $(echo "${URL}" | grep "oapi.dingtalk.com") ]; then
        [ ${#TS} -lt 11 ] && TS="${TS}000"
        get_sign 2
        semd_msg=$(printf "${sendData2}" ${MESSAGE} )
        URL=$(printf "${URL}&timestamp=%s&sign=%s" ${TS} ${SIGN})
    elif [ -n $(echo "${URL}" | grep "open.feishu.cn") ]; then
        get_sign 1
        semd_msg=$(printf "${sendData1}" ${MESSAGE} ${SIGN} ${TS})
    else
        printf "此方式（%s）不支持\n" "${URL}"
        return
    fi

    echo "${semd_msg}"
    # printf '%s\ntimestamp: %s\nsecret: %s\nsign: %s\n' ${URL} ${TS} ${SECRET} ${SIGN}
    curl -XPOST -s -L "${URL}" -H "Content-Type:application/json" -H "charset:utf-8"  -d "${semd_msg}"
}

get_sign() {
    mode="${1}"
    string_to_sign="${TS}\n${SECRET}"

    data=""
    if [ "${mode}" = "1" ]; then
        sign_str="${string_to_sign}"
    elif [ "${mode}" = "2" ]; then
        sign_str="${SECRET}"
        data="${string_to_sign}"
    else
        printf "此方式（%s）不支持\n" "${URL}"
        exit 1
    fi

    # echo ${sign_str}
    # printf "${data}"
    SIGN=$(printf "${data}" | openssl dgst -sha256 -hmac "${sign_str}" -binary | base64)
    #echo $SIGN    
}

main() {
    get_vars "$@"
    send_msg
}

main "$@"
