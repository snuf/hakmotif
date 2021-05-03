#!/bin/bash
#
# Small script that tests te use case of #52
#  Where the main problem is that non-directio can corrupt
#  if the segments are larger than the max queue segments
#  see kblock.c KFIOC_HAS_BLK_QUEUE_SPLIT2 where >= is important
#
source envfile
source local_envs.sh

echo "PHASE 3.1 START" >> /var/log/fio_test.log
SECONDS=0

test_dir=${test_location:-/mnt/fio}

if [ ! -d "${test_dir}" ]; then
    mkdir ${test_dir}
fi

set -x
set -e

fio_defaults=" \
    --verify=crc32c \
    --size=8G \
    --numjobs=8 \
    --runtime=60 \
    --warnings-fatal \
    --group_reporting \
    --verify_state_save=1 \
    --do_verify=1 \
    --directory=${test_dir}"

if [ "$(uname)" == "Linux" ]; then
    fio_defaults="--ioengine=libaio $fio_defaults"
fi
# not direct is the most important thing here....
#  DirectIO bypasses the page cache
direct=0
name=fio_bio_error_test
rw=write
size=16k
sudo fio \
    --name=$name \
    --iodepth=32 \
    --rw=$rw \
    --bs=${size}k \
    --direct=$direct \
    $fio_defaults
echo $?

delta=$SECONDS
echo "PHASE 3.1 END: $delta" >> /var/log/fio_test.log
