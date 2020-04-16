#!/bin/bash
#
#
source envfile
source local_envs.sh

echo "PHASE 4.2 START" >> /var/log/fio_test.log
SECONDS=0

out=$(dmesg | \
    egrep "errors|warnings|BUG|stack_dump|OOPS|RIP" | \
    egrep -v "RAS|Opts: errors=remount-ro|urandom warnings|pcspkr")
if [ -f "/var/log/kern.log" ]; then
  out+=$(egrep 'IO errors|I/O error|superblock|Error|Aborting|Remounting filesystem read-only' |
      grep -v "dev fd0" | \
      /var/log/kern.log | \
    grep -v RAS)
else
  out+="\nNo kern.log????"
fi

if [ "$out" != "" ]; then
    echo "Woops!:"
    echo "$out"
    exit 1
else
    echo "Clean"
    exit 0
fi

delta=$SECONDS
echo "PHASE 4.2 END: $delta" >> /var/log/fio_test.log
