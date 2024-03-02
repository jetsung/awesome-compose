#!/usr/bin/env bash

###
# 参数一：请求类型 m1(泛解析, 90days), m2(单域名, 90days), m3(单域名, 170days)
# 参数二：域名
# 参数三：DNS类型 dns_ali / dns_cf 等等
# 参数四：CA类型 letsencrypt / zerossl / buypass
# 参数五：非空则为新注，需要注册CA
#
# https://github.com/acmesh-official/acme.sh/wiki/Run-acme.sh-in-docker
#
###

init() {
  ACTION="$1"
  DOMAIN="$2"

  if [[ "$ACTION" = "-h" ]]; then
    printf "domain.sh m1 domain.com dns_ali zerossl new  \n"
    exit 1
  fi

  if [[ $# -lt 2 ]]; then
    printf "params must be more than 3 \n"
    exit 1
  fi

  if [[ -z "$DOMAIN" ]]; then
    printf "\e[1;31mPlease input domain\e[0m\n"
    exit 1
  fi

  if [[ -z "$EMAIL" ]]; then
    EMAIL="jetsung@outlook.com"
  fi

  #COMMAND=acme.sh
  COMMAND="docker exec acme.sh"
  DNS_TYPE="dns_cf"
  CA_TYPE=""

  if [[ -n "$3" ]] && [[ "no" != "$3" ]]; then
    DNS_TYPE="$3"
  fi

  if [[ -n "$4" ]]; then
    CA_TYPE="$4"
  fi

  CA_STR=""
  case "$CA_TYPE" in
  "letsencrypt")
    CA_STR="--server letsencrypt"
    ;;

  "zerossl")
    CA_STR="--server zerossl"
    ;;

  "buypass")
    CA_STR="--server https://api.buypass.com/acme/directory"
    ;;

  "--server")
    if [ -z "$5" ]; then
      echo "Miss server url"
      exit 1
    fi

    CA_STR="--server $5"
    shift 1
    ;;
  esac

  # 新注
  if [[ -n "$5" ]]; then
    if [[ "$ACTION" = "m3" ]]; then
      $COMMAND acme.sh --server https://api.buypass.com/acme/directory --register-account --accountemail "$EMAIL"
    else
      if [[ -n "$CA_STR" ]]; then
        if [[ "$CA_TYPE" = "letsencrypt" ]]; then
          $COMMAND acme.sh --set-default-ca --server letsencrypt
        else
          $COMMAND acme.sh --register-account -m "$EMAIL" "$CA_STR"
        fi
      fi
    fi
  fi
}

main() {
  set -ex

  init "$@"

  case "$ACTION" in
  # 泛解析
  "m1")
    $COMMAND --issue --dns "$DNS_TYPE" -d "$DOMAIN" -d *."$DOMAIN" --keylength ec-256 --ecc --force "$CA_STR"
    ;;

  # 非泛解析
  "m2")
    $COMMAND --issue --dns "$DNS_TYPE" -d "$DOMAIN" --keylength ec-256 --ecc --force "$CA_STR"
    ;;

  # 非泛解析，170天，Wildcard not supported
  "m3")
    $COMMAND acme.sh --issue --dns "$DNS_TYPE" -d "$DOMAIN" --keylength ec-256 --ecc --force "$CA_STR" --days 170
    ;;
  esac

  ./setup.sh "$DOMAIN"
  # list files
  ls /srv/acme/ssl/"$DOMAIN".* -l
}

main "$@"

##
# demo:
#   切换 CA：acme.sh --set-default-ca --server letsencrypt
#   泛解析、新建：domain.sh m1 domain.com dns_ali zerossl new
#   自定义、单域：domain.sh m2 domain.com dns_ali --server https://xxx.com new
##
