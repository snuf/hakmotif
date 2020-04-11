#!/bin/bash
set -e
set -x

if [ "$ver" == "" ]; then
  ver=$(basename $(pwd))
fi
docker build -t $ver . --build-arg $( grep apt_proxy ../envfile )
# docker rmi $ver
