#!/bin/bash
#
#
set -x
sudo umount /mnt
sudo rmmod iomemory-vsl
set -e
cd ~
cd iomemory-vsl/root/usr/src/iomemory-vsl-3.2.16
make clean
make
sudo insmod iomemory-vsl.ko
sudo mount /dev/fioa1 /mnt
sudo bash scripts/test_page_cache.sh
sudo bash scripts/test_tgz.sh

