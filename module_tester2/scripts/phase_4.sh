#!/bin/bash -xe
#
#
echo "PHASE 4 START" >> /var/log/fio_test.log
SECONDS=0
umount /mnt
rmmod iomemory-vsl.ko
dmesg
count=$(lsmod | grep iomemory | wc -l)
if [ "$?" == "0" ]; then
    exit 0
else
    exit 1
fi
delta=$SECONDS
echo "PHASE 4 END: $delta" >> /var/log/fio_test.log
