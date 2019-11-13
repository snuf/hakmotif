#!/bin/bash -xe
#
#
echo "PHASE 1.2 START" >> /var/log/fio_test.log
SECONDS=0
. envfile
osr="/etc/os-release"
if [ -f "$osr" ]; then
    source $osr
    if [ "$ID_LIKE" == "" ]; then
        dist=$ID
    else
        dist=$ID_LIKE
    fi
fi


opwd=${PWD}
fioutil="fio-util-3.2.16.1731-1.0.el7.x86_64.rpm"
loc=rpms
if [ ! -d pkg ]; then
    mkdir pkg
fi
cd pkg
mc cp s3/$loc/$fioutil ./$fioutil

if [ "$dist" == "debian" ]; then
    sudo alien $fioutil
    fioutil=$(ls -1 | grep deb)
    sudo dpkg -i $fioutil
# hmzzz
elif [ "$dist" == "arch" ]; then
    set -e
    mv $fioutil /
    cd /
    rpmextract.sh $fioutil
    set +e
else
    rpm -i $fioutil
fi
fio-status
cd ${opwd}

delta=$SECONDS
echo "PHASE 1.2 END: $delta" >> /var/log/fio_test.log
