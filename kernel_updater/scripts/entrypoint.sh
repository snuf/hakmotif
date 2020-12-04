#!/bin/bash

set -e
set -x

arg=$1
subarg=$2
subsubarg=$3

if [ "$arg" == update ]; then
  mc config host add s3 $MC_ENDPOINT $MC_ACCESS $MC_SECRET --api $MC_APIVER && \
  mc ls s3/ && \
  mc cp s3/$src_loc/$kernel_src_tgz kernel_src.tgz

  tar -zxf kernel_src.tgz && rm kernel_src.tgz
  cd linux-stable
  git checkout master && \
    git reset --hard && \
    git clean -fd && \
    git pull
  cd /
  tar -zcf kernel_src.tgz linux-stable && \
    mc cp kernel_src.tgz  s3/$src_loc/$kernel_src_tgz && \
    rm kernel_src.tgz
elif [ "$arg" == get ]; then
  echo "not imlemented yet"
fi
