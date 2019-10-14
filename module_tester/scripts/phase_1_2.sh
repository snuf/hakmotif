#!/bin/bash -xe
#
#
SECONDS=0
. envfile

opwd=${PWD}
fioutil="fio-util-3.2.16.1731-1.0.el7.x86_64.rpm"
loc=rpms
mkdir pkg
cd pkg
mc cp s3/$loc/$fioutil ./$fioutil

sudo alien $fioutil
fioutil=$(ls -1 | grep deb)
sudo dpkg -i $fioutil
sudo fio-status
cd ${opwd}

delta=$SECONDS
echo "PHASE 1.2 TIME: $delta" >> /var/log/fio_test.log

