#!/bin/bash
#
#
set -x
sudo umount /mnt
sudo rmmod $module_project
set -e
cd ~
cd $module_project
loc=$(ls -1 $module_sub)
cd $module_sub/$loc
make clean
make
sudo insmod $module_project.ko
sudo mount /dev/fioa1 /mnt
cd ~
sudo bash scripts/test_page_cache.sh
sudo bash scripts/test_tgz.sh
