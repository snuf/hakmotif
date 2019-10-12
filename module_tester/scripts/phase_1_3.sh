#!/bin/bash -xe
#
#

SECONDS=0
. envfile

cd iomemory-vsl
dpkg-buildpackage \
  -rfakeroot --no-check-builddeps --no-sign

delta=$SECONDS
echo "PHASE 1.2 TIME: $delta" >> /var/log/fio_test.log
