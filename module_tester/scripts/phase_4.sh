#!/bin/bash -xe
#
#
umount /mnt
rmmod iomemory-vsl.ko
dmesg
count=$(lsmod | grep iomemory | wc -l)
if [ "$?" == "0" ]; then
    exit 0
else
    exit 1
fi
