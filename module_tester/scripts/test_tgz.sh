#!/bin/bash
#
#
source envfile
source local_envs.sh

echo "PHASE 3 START" >> /var/log/fio_test.log
SECONDS=0

test_dir=${test_location:-/mnt/fio}

if [ ! -d "${test_dir}" ]; then
    mkdir ${test_dir}
fi

set -e
set -x

#
# add journalctl here for arch
#
getSyslog() {
    set +e
    tail -100 /var/log/syslog | grep error | grep -v libvirtd
    if [ "$?" == "0" ]; then
        echo "broken $0"
        exit 1
    fi
    set -e
}
cd ${test_dir}
sudo dd if=/dev/zero of=dd_test bs=1M count=2048
sync
getSyslog
sudo tar -zcvf dd_test.tgz dd_test
sync
getSyslog
sudo rm -rf dd_test*
sync
getSyslog

delta=$SECONDS
echo "PHASE 3 END: $delta" >> /var/log/fio_test.log
