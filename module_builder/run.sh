#!/bin/bash
#
. ../envfile

ver=$kernel_branch
if [ "$ver" == "" ]; then
   ver=$(basename $(pwd))
fi

time docker run --env-file ../envfile module_builder:$ver
