#!/bin/bash
set -e
set -x

. ../envfile

ver=$kernel_branch
if [ "$ver" == "" ]; then
   ver=$(basename $(pwd))
fi

file=Dockerfile.ubuntu
docker build -t module_builder:$ver -f $file . $OPTS

# for file in $(ls -1 Dockerfile.*); do
#   type=$(echo $file | awk -F\. '{ print $2 }')
#   docker build -t $ver-$type -f $file . $OPTS
# done
# docker rmi $ver
