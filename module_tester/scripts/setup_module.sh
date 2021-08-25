#!/bin/bash -xe
#
#
source envfile
source local_envs.sh

echo "PHASE 1.1 START" >> /var/log/fio_test.log
SECONDS=0

# solve others later
running_kernel=$(uname -r)
if [[ "$kernel_branch" =~ "-rc" ]]; then
    kernel_branch=$(echo $kernel_branch | perl -ne '/(\d+.\d+)(-rc\d+)/; print $1.".0$2"')
fi
if [ "$running_kernel" != "$kernel_branch" -a "$kernel_branch" != "" ]; then
    echo "Grub phase 1 update gone bad, or just kernel install?"
    exit 1
fi

## Should do a chekck if it already exists and do appropriate stuff then...
if [ -d "$module_project" ]; then
  rm -rf $module_project
fi
git clone $module_repo/$module_project
cd $module_project
git checkout $module_branch
if [ "$module_commit_hash" ]; then
  echo 'Checking out $module_commit_hash'
  git checkout $module_commit_hash
fi
loc=$(ls -1 $module_sub)
cd $module_sub/$loc
make
if [ "$?" == "0" ]; then
    set +e
    lsmod | grep $module_project
    if [ "$?" == "0" ]; then
        set -e
        echo "Module already loaded, assuming trial"
    else
        set -e
        insmod $module_project.ko
    fi
else
    echo "Something went wrong building!"
    exit 1
fi

if [ "$test_user" != "" ]; then
    chown -R $test_user /home/$test_user
fi
delta=$SECONDS
echo "PHASE 1.1 END: $delta" >> /var/log/fio_test.log
