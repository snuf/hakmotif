#!/bin/bash

set -x

git clone ${module_repo}/${module_project}
cd $module_project
git checkout $module_branch

# if [ "$cheat_build_file_finder" == "1" ]; then
#   cd root
#   find usr/ -type f > ../debian/${module_project}-source.install
#   find usr/share/doc -type f > ../debian/${module_project}.install
#   cd ..
# fi
# kernel version, headers and branch will be the same
if [ "$kernel_branch" != "" ]; then
    echo $kernel_branch | grep rc
    if [ "$?" == "0" ]; then
        kernel_branch=$(echo $kernel_branch | perl -ne '/(\d+.\d+)(-rc\d+)/; print $1.".0$2"')
    fi
else
  $kernel_branch=$(echo $kernel_hdrs | perl -ne '/([\d\.]+(\-\d+)?)/; print $1')
fi

if [ $kernel_branch == "" ]; then
  echo "missing kernel branch to work with"
  exit 1
fi
src_hdr=$(ls -1 /usr/src | grep $kernel_branch)
deb_kernel_version=$kernel_branch \
  KERNEL_SRC=/usr/src/$src_hdr \
  dpkg-buildpackage \
  -rfakeroot -B --no-check-builddeps -us -uc

rpmbuild -ba fio-driver.spec

## Later also upload the simple .ko
cd ../ && cp *.deb staging/ && cp *.changes staging/
