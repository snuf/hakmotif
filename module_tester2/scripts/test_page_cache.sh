#!/bin/bash
#
# Small script that tests te use case of #52
#  Where the main problem is that non-directio can corrupt
#  if the segments are larger than the max queue segments
#  see kblock.c KFIOC_HAS_BLK_QUEUE_SPLIT2 where >= is important
#
set -x
set -e

fio_defaults="--ioengine=libaio \
    --verify=crc32c \
    --size=1G \
    --numjobs=8 \
    --runtime=60 \
    --group_reporting \
    --verify_state_save=1 \
    --do_verify=1 \
    --directory=/mnt/fio"
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

set -e
sudo tail -10 /var/log/syslog | grep error
if [ "$?" == "0" ]; then
    echo "broken"
    exit 1
fi
