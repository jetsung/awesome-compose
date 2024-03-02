#!/usr/bin/env bash

# 手动安装证书到容器中的 /data/ssl

set -eu

BASE_EXEC="docker exec acme.sh"

DOMAIN="${1}"

# 默认为 dns_cf
DNS=${DNS:-dns_cf}

# 交换域名
CHALLENGE=${CA:-}
if [[ -n "$CHALLENGE" ]]; then
  # _acme-challenge.
  CHALLENGE="--challenge-alias $CHALLENGE"
fi

# 签发
# shellcheck disable=SC2086
$BASE_EXEC acme.sh --issue -d "$DOMAIN" --dns "$DNS" $CHALLENGE -d "*.$DOMAIN" --keylength ec-256 --ecc --force

# 部署
$BASE_EXEC acme.sh --install-cert --ecc -d "$DOMAIN" --key-file /data/ssl/"$DOMAIN".key --fullchain-file /data/ssl/"$DOMAIN".fullchain.cer

# ./issue_deploy.sh domain.com
# DNS=dns_ali ./issue_deploy.sh domain.com
# CA=x.com DNS=dns_ali ./issue_deploy.sh domain.com
