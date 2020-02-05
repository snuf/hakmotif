#!/bin/bash -xe
#
#
echo "PHASE 2 START" >> /var/log/fio_test.log
SECONDS=0
source envfile
source local_envs.sh

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

# fioa   252:0    0  298G  0 disk
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
mount /dev/${dev}1 /mnt

delta=$SECONDS
echo "PHASE 2 END: $delta" >> /var/log/fio_test.log
