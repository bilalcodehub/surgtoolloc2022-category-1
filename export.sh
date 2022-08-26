#!/usr/bin/env bash

./build.sh

docker save surgtoolloc_trial | gzip -c > TZ_surgtoolloc_algo_container.tar.gz
