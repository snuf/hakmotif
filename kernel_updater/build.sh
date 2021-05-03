#!/bin/bash
set -e
set -x
# for i in `cat ../envfile | awk '{ print $2 }'`
# do
#   OPTS+=" --build-arg ENV $i"
# done
# 
ver=$(grep ^kernel_branch ../envfile | awk -F= '{ print $2 }')
if [ "$ver" == "" ]; then
  ver=$(basename $(pwd))
fi
docker build $OPTS -t kernel_updater:latest .
# docker rmi $ver
