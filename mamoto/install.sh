#!/usr/bin/env bash

VERSION="4.14.2"

curl -o matomo.tar.gz -Lk "https://github.com/matomo-org/matomo/releases/download/$VERSION/matomo-$VERSION.tar.gz"
tar -zxvf matomo.tar.gz
