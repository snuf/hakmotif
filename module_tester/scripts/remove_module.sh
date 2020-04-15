#!/bin/bash -xe
#
#
source envfile
source local_envs.sh

echo "PHASE 4.1 START" >> /var/log/fio_test.log
SECONDS=0

rmmod $module_project.ko
# check dmesg...
count=$(lsmod | grep iomemory | wc -l)
if [ "$?" == "0" ]; then
    exit 0
else
    exit 1
fi

delta=$SECONDS
echo "PHASE 4.1 END: $delta" >> /var/log/fio_test.log
