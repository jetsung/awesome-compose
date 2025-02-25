#!/bin/sh

## 钉钉、飞书 通知

get_vars() {
    while [ $# -gt 0 ];do
    case "${1:-}" in
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

get_dingtalk_msg() {
    printf '{"msgtype":"text","text":{"content":"消息通知： %s "},"at":{"isAtAll":false}}' "${1:-}" 
}

get_feishu_msg() {
	printf '{"msg_type":"text","content":{"text":"消息通知: %s "},"sign":"%s","timestamp":%d}' "${1:-}" "${2:-}" "${3:-}" 
}

send_msg() {
    [ -n "$TS" ] || TS="$(date +%s)"

    if echo "$URL" | grep -q oapi.dingtalk.com; then
        [ ${#TS} -lt 11 ] && TS="${TS}000"
        get_sign 2
        semd_msg=$(get_dingtalk_msg "$MESSAGE")
        URL=$(printf "$URL&timestamp=%s&sign=%s" "$TS" "$SIGN")
    elif echo "$URL" | grep -q open.feishu.cn; then
        get_sign 1
        semd_msg=$(get_feishu_msg "$MESSAGE" "$SIGN" "$TS")
    else
        printf "此方式（%s）不支持\n" "$URL"
        return
    fi

    echo "$semd_msg"
    echo "URL: $URL"
    # printf '%s\ntimestamp: %s\nsecret: %s\nsign: %s\n' ${URL} ${TS} ${SECRET} ${SIGN}
    curl -X POST -L "$URL" -H "Content-Type:application/json" -H "charset:utf-8"  -d "$semd_msg"
}

get_sign() {
    mode="${1}"
    string_to_sign="$TS\n$SECRET"

    data=""
    if [ "$mode" = "1" ]; then
        sign_str="$string_to_sign"
    elif [ "$mode" = "2" ]; then
        sign_str="$SECRET"
        data="$string_to_sign"
    else
        printf "此方式（%s）不支持\n" "$URL"
        exit 1
    fi

    # echo ${sign_str}
    # printf "${data}"
    # shellcheck disable=SC2059
    SIGN=$(printf "$data" | openssl dgst -sha256 -hmac "$sign_str" -binary | base64)
    #echo $SIGN    
}

main() {
    get_vars "$@"
    send_msg
}

main "$@"
