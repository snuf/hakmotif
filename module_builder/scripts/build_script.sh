#!/bin/bash

set -x
#
git clone https://github.com/snuf/iomemory-vsl
cd iomemory-vsl
git checkout $module_branch
# this needs to be part of the git repo not here, build should fail here!!!

if [ "$cheat_build_file_finder" == "1" ]; then
  cd root
  find usr/ -type f > ../debian/iomemory-vsl-source.install
  find usr/share/doc -type f > ../debian/iomemory-vsl.install
  cd ..
fi
# kernel version, headers and branch will be the same
if [ ! "$kernel_branch" ]; then
  $kernel_branch=$(echo $kernel_hdrs | perl -ne '/([\d\.]+(\-\d+)?)/; print $1')
fi

echo $kernel_branch | grep rc
if [ "$?" == "0" ]; then
    kernel_branch=$(echo $kernel_branch | perl -ne '/(\d+.\d+)(-rc\d+)/; print $1.".0$2"')
fi

src_hdr=$(ls -1 /usr/src | grep $kernel_branch)
deb_kernel_version=$kernel_branch \
  KERNEL_SRC=/usr/src/$src_hdr \
  dpkg-buildpackage \
  -rfakeroot -b --no-check-builddeps -us -uc

## Later also upload the simple .ko
cd ../ && cp *.deb staging/ && cp *.changes staging/
