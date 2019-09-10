#!/bin/bash -xe

if [ ! -d "/mnt/fio" ]; then
    mkdir /mnt/fio
fi

fio_defaults="--ioengine=libaio \
    --verify=crc32c \
    --size=1G \
    --numjobs=4 \
    --runtime=60 \
    --group_reporting \
    --direct=1 \
    --verify_state_save=1 \
    --do_verify=1 \
    --directory=/mnt/fio"

# RandWrite
fio \
    --name=randwrite \
    --iodepth=32 \
    --rw=randwrite \
    --bs=4k \
    $fio_defaults

fio \
    --name=randwrite \
    --iodepth=16 \
    --rw=randwrite \
    --bs=8k \
    $fio_defaults

fio \
    --name=randwrite \
    --iodepth=4 \
    --rw=randwrite \
    --bs=256k \
    $fio_defaults

echo "PHASE 3 DONE" >> /var/log/fio_test.log
