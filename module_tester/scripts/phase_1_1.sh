#!/bin/bash -xe
#
#

SECONDS=0
. envfile

if [ ! -d "iomemory-vsl" ]; then
    git clone https://github.com/snuf/iomemory-vsl
fi
cd iomemory-vsl
git checkout $module_branch
cd root/usr/src/iomemory-vsl-3.2.16
make
if [ "$?" == "0" ]; then
    set +e
    lsmod | grep iomemory_vsl
    if [ "$?" == "0" ]; then
        set -e
        echo "Module already loaded, assuming trial"
    else
        set -e
        insmod iomemory-vsl.ko
    fi
else
    echo "Something went wrong building!"
    exit 1
fi

delta=$SECONDS
echo "PHASE 1.1 TIME: $delta" >> /var/log/fio_test.log
