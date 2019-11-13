#!/bin/bash
#
#
sudo umount /mnt
sudo rmmod iomemory-vsl
cd ~
cd iomemory-vsl/root/usr/src/iomemory-vsl-3.2.16
make clean
make
sudo insmod iomemory-vsl.ko
