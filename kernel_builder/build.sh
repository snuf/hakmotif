#!/bin/bash
set -e
set -x
for i in `cat ../envfile | awk '{ print $2 }'`
do
  OPTS+=" --build-arg ENV $i"
done

if [ "$ver" == "" ]; then
  ver=$(basename $(pwd))
fi
docker build -t $ver . $OPTS
# docker rmi $ver
