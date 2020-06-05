#!/bin/bash -xe
#
#
source envfile
source local_envs.sh

echo "PHASE 1.3 START" >> /var/log/fio_test.log
SECONDS=0

set +e
if [ "$dist" == "debian" ]; then
  cd $module_project
  make dpkg
  if [ "$?" == "2" ];
    dpkg-buildpackage -rfakeroot --no-check-builddeps --no-sign
  fi
  if [ "$?" != "0" ]; then
    echo "DPKG Build failed!!"
    exit 1
  fi
elif [ "$dist" == "rhel" ]; then
  cd $module_project
  make rpm
  # [vagrant@fio iomemory-vsl-3.2.16]$ make rpm
  # make: *** No rule to make target `rpm'.  Stop.
  # [vagrant@fio iomemory-vsl-3.2.16]$ echo $?
  # 2
  if [ "$?" == "2" ]; then
    rpmbuild -ba fio-driver.spec
  fi
  if [ "$?" != "0" ]; then
    echo "RPM Build failed!!"
    exit 2
  fi  
else
  echo "PHASE 1.3: Packaging on $dist is not suported."
fi
set -e

if [ "$?" != "0" ]; then
  echo "Something went wrong building for $dist."
  exit 1
fi

delta=$SECONDS
echo "PHASE 1.3 END: $delta" >> /var/log/fio_test.log
