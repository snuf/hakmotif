#!/bin/bash
#
#
set -e
set -x

getSyslog() {
    set +e
    tail -10 /var/log/syslog | grep error
    if [ "$?" == "0" ]; then
        echo "broken $0"
        exit 1
    fi
    set -e
}
sudo dd if=/dev/zero of=dd_test bs=1M count=2048
sync
getSyslog
sudo tar -zcvf dd_test.tgz dd_test
sync
getSyslog
sudo rm -rf dd_test*
sync
getSyslog
