#!/usr/bin/env bash
#
source envfile
source local_envs.sh

echo "PHASE 4 START" >> /var/log/fio_test.log
SECONDS=0

umount $test_mnt

blkid | grep ${dev} | grep "LVM2_member"
if [ "$?" == "0" ]; then
  vg=$(pvs | grep ${dev} | awk '{print $2}')
  if [ "$vg" != "" ]; then
    vgchange --activate n $vg
    if [ "$?" != "0" ]; then
      echo "failed to deactivate $vg"
      exit 1
    fi
  else
    echo "no Logical Volume found on $vg"
    exit 2
  fi
else
  echo "leave other FS alone..."
fi

echo "PHASE 4 START" >> /var/log/fio_test.log
SECONDS=0
