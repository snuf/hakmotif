#!/bin/bash
set -e
set -x
for i in `cat ../envfile | awk '{ print $2 }'`
do
  OPTS+=" --build-arg $i"
done

ver=$(grep kernel_branch envfile | awk -F= '{ print $2 }')
if [ "$ver" == "" ]; then
  ver=$(basename $(pwd))
fi

file=Dockerfile.ubuntu
docker build -t $ver -f $file . $OPTS

# for file in $(ls -1 Dockerfile.*); do
#   type=$(echo $file | awk -F\. '{ print $2 }')
#   docker build -t $ver-$type -f $file . $OPTS
# done
# docker rmi $ver
