#!/bin/bash -xe
#
#
source envfile
source local_envs.sh

echo "PHASE 3.2 START" >> /var/log/fio_test.log
SECONDS=0

test_dir=${test_location:-/mnt/fio}

if [ ! -d "${test_dir}" ]; then
    mkdir ${test_dir}
fi

fio_defaults="--ioengine=libaio \
    --verify=crc32c \
    --size=1G \
    --numjobs=4 \
    --runtime=60 \
    --group_reporting \
    --verify_state_save=1 \
    --do_verify=1 \
    --directory=${test_dir}"

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
                $fio_defaults | tee
        done
    done
done
# I hope this bails on failure
# rm -rf ${test_dir}/*
sync

delta=$SECONDS
echo "PHASE 3.2 END: $delta" >> /var/log/fio_test.log
