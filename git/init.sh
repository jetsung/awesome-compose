#!/bin/sh

# 中科大源
#sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

GIT_USER=""
GIT_EMAIL=""

git config --global user.name "${GIT_USER}"
git config --global user.email "${GIT_EMAIL}"
git config --global init.defaultBranch main
