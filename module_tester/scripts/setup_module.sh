#!/bin/bash -xe
#
#
echo "PHASE 1.1 START" >> /var/log/fio_test.log
SECONDS=0
source envfile
source local_envs.sh

# solve others later
running_kernel=$(uname -r)
if [ "$running_kernel" != "$kernel_branch" -a "$kernel_branch" != "" ]; then
    echo "Grub phase 1 update gone bad, or just kernel install?"
    exit 1
fi

if [ ! -d "$module_project" ]; then
    git clone $module_repo/$module_project
fi
cd $module_project
git checkout $module_branch
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
        fios=$(ls -1 /sys/block | grep fio)
        for fio in $fios; do
            echo noop > /sys/block/${fio}/queue/scheduler
        done
    fi
else
    echo "Something went wrong building!"
    exit 1
fi

delta=$SECONDS
echo "PHASE 1.1 END: $delta" >> /var/log/fio_test.log
