#!/bin/bash
set -e
set -x

ver=$(grep kernel_branch envfile | awk -F= '{ print $2 }')
if [ "$ver" == "" ]; then
  ver=$(basename $(pwd))
fi

file=Dockerfile.ubuntu.test
docker build -t $ver -f $file . $OPTS

# for file in $(ls -1 Dockerfile.*); do
#   type=$(echo $file | awk -F\. '{ print $2 }')
#   docker build -t $ver-$type -f $file . $OPTS
# done
# docker rmi $ver
