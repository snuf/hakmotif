#!/bin/bash
#
#
set -e
set -x

sudo dd if=/dev/zero of=dd_test bs=1M count=2048
sync
sudo tar -zcvf dd_test.tgz dd_test
sync
sudo rm -rf dd_test*
sync
