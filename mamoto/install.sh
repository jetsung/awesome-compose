#!/usr/bin/env bash

VERSION="5.6.2"

curl -o matomo.tar.gz -Lk "https://github.com/matomo-org/matomo/releases/download/$VERSION/matomo-$VERSION.tar.gz"
tar -zxvf matomo.tar.gz
