#!/bin/bash -x
#
#
source envfile
source local_envs.sh

echo "PHASE 2 START" >> /var/log/fio_test.log
SECONDS=0


# 00:04.0 Mass storage controller: SanDisk ioDimm3 (rev 01)
lspci | grep SanDisk
if [ "$?" != "0" ]; then
    echo "No FIO device found in lspci"
    exit 1
fi

# iomemory_vsl         1277952  0
lsmod | grep iomemory_vsl
if [ "$?" != "0" ]; then
    echo "Module loaded, but not there"
    exit 2
fi

# [ 1159.244106] <6>fioinf ioDrive 0000:00:04.0: Found device fct0 (Fusion-io ioDrive Duo 640GB 0000:00:04.0) on pipeline 0
# [ 1162.702570] <6>fioinf Fusion-io ioDrive Duo 640GB 0000:00:04.0: Creating device of size 320000000000 bytes with 625000000 sectors of 512 bytes (74005632 mapped).
# [ 1162.716449] <6>fioinf Fusion-io ioDrive Duo 640GB 0000:00:04.0: Attach succeeded.
created=$(dmesg | grep fioinf | egrep "Found device|Creating|Attach succeeded")
dev=$(echo $created | perl -ne '/device (fio(\w+)):/; print $1')
if [ "$dev" == "" ]; then
    echo "No device found"
    exit 3
fi

# check if there is an active LVM partition
lvmetad=$(systemctl | grep lvm2-lvmetad)
if [ "$lvmetad" != "" ]; then
  service lvm2-lvmetad stop
  service lvm2-lvmetad start
fi
part=$(blkid | grep ${dev} | grep -v EFI | tail -1)
if [[ $part =~ .*LVM2_member.* ]]; then
  vg=$(pvs | grep ${dev} | awk '{print $2}')
  if [ "$vg" != "" ]; then
    vgchange --activate y $vg
    if [ "$?" != "0" ]; then
      echo "failed to activate $vg"
      exit 6
    fi
    lv=$(lsblk -l /dev/$dev | tail -1 | grep lvm | awk '{ print $1 }')
    if [ "$lv" != "" ]; then
      mount -o discard /dev/mapper/$lv ${test_mnt}
      if [ "$?" != "0" ];then
        echo "failed to mount $lv on ${test_mnt}"
        exit 7
      fi
    else
      echo "no Logical Volume found on $vg"
      exit 4
    fi
  else
    echo "no Volume Group found on LVM2 device $dev"
    exit 5
  fi
# check if there is an active ext4 partition, otherwise NUKE IT
elif [[ $part =~ .*ext4.* ]]; then
  dev=$(echo $part | perl -ne '/(fio(\w+\d+)):/; print $1')
  mount -o discard /dev/${dev} ${test_mnt}
else
  lsblk | grep ${dev}1
  if [ "$?" != "0" ]; then
      echo "no partition found on ${dev}1, creating"
      parted -s /dev/$dev mklabel gpt
      parted -s /dev/$dev mkpart primary 1 100%
      mkfs.ext4 /dev/${dev}1
      if [ "$?" != "0" ]; then
          echo "failed to create partiion, ${dev}1 not found"
          exit 1
      fi
  else
      echo "partition found on ${dev}1"
      file -sL /dev/${dev}1 | grep ext4
      if [ "$?" != "0" ]; then
          echo "no ext4 found, formatting"
          mkfs.ext4 /dev/${dev}1
      fi

  fi
  mount -o discard /dev/${dev}1 ${test_mnt}
fi

if [ ! -d "${test_dir}" ]; then
    mkdir ${test_dir}
fi

delta=$SECONDS
echo "PHASE 2 END: $delta" >> /var/log/fio_test.log
