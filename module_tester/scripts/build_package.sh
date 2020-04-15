#!/bin/bash -xe
#
#
source envfile
source local_envs.sh

echo "PHASE 1.3 START" >> /var/log/fio_test.log
SECONDS=0

if [ "$dist" == "debian" ]; then
  cd $module_project
  dpkg-buildpackage \
    -rfakeroot --no-check-builddeps --no-sign
elif [ "$dist" == "rhel" ]; then
  cd $module_project
  rpmbuild -ba fio-driver.spec
else
  echo "PHASE 1.3: Packaging on $dist is not suported."
fi

if [ "$?" != "0" ]; then
  echo "Something went wrong building for $dist."
  exit 1
fi

delta=$SECONDS
echo "PHASE 1.3 END: $delta" >> /var/log/fio_test.log
