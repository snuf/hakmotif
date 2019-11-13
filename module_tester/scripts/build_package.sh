#!/bin/bash -xe
#
#
osr="/etc/os-release"
if [ -f "$osr" ]; then
    source $osr
    if [ "$ID_LIKE" == "" ]; then
        dist=$ID
    else
        dist=$ID_LIKE
    fi
fi
if [ "$dist" != "debian" ]; then
    exit 0
fi

echo "PHASE 1.3 START" >> /var/log/fio_test.log
SECONDS=0
. envfile

cd iomemory-vsl
dpkg-buildpackage \
  -rfakeroot --no-check-builddeps --no-sign

delta=$SECONDS
echo "PHASE 1.3 END: $delta" >> /var/log/fio_test.log
