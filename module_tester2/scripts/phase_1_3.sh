#!/bin/bash -xe
#
#
echo "PHASE 1.3 START" >> /var/log/fio_test.log
SECONDS=0
. envfile

cd iomemory-vsl
dpkg-buildpackage \
  -rfakeroot --no-check-builddeps --no-sign

delta=$SECONDS
echo "PHASE 1.3 END: $delta" >> /var/log/fio_test.log
