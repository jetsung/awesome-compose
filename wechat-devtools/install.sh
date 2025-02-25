#!/usr/bin/env bash

GHPROXY="${GHPROXY:-https://fastfile.asfd.cn/}"

git clone "${GHPROXY}https://github.com/msojocs/wechat-web-devtools-linux.git" .

sed -i "s#wget https://github.com#wget ${GHPROXY}https://github.com#g" tools/rebuild-node-modules.sh

sed -i "s#https://github.com#${GHPROXY}https://github.com#g" .gitmodules

ln -s "$(pwd)"/package.nw "$(pwd)"/nwjs/package.nw

docker compose up -d

SHPATH="$SHELL"
ENV=$(basename "$SHPATH")

if [[ "$ENV" = "bash" ]]; then
    echo "export PATH=\"$(pwd)/bin:\$PATH\"" >>~/.bashrc
elif [[ "$ENV" = "zsh" ]]; then
    echo "export PATH=\"$(pwd)/bin:\$PATH\"" >>~/.zshrc
else
    printf "# please put context into your env file: \n\e[1;33m%s\e[0m" "export PATH=\"$(pwd)/bin:\$PATH\""
fi
