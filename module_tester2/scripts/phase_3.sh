#!/bin/bash -xe
#
#
echo "PHASE 3 START" >> /var/log/fio_test.log
SECONDS=0
. envfile

if [ ! -d "/mnt/fio" ]; then
    mkdir /mnt/fio
fi

fio_defaults="--ioengine=libaio \
    --verify=crc32c \
    --size=1G \
    --numjobs=4 \
    --runtime=60 \
    --group_reporting \
    --verify_state_save=1 \
    --do_verify=1 \
    --directory=/mnt/fio"

for size in 4 8 16 256; do
    for rw in randwrite write; do
        for direct in 0 1; do
            echo "Running s: $size, rw: $rw, direct: $direct"
            fio \
                --name=$rw \
                --iodepth=32 \
                --rw=$rw \
                --bs=${size}k \
                --direct=$direct \
                $fio_defaults
        done
    done
done


delta=$SECONDS
echo "PHASE 3 END: $delta" >> /var/log/fio_test.log
