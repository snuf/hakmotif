#!/bin/bash
#
#
set -x

out=$(dmesg | \
    egrep "errors|warnings|BUG|stack_dump|OOPS|RIP|" | \
    egrep -v "RAS|Opts: errors=remount-ro|urandom warnings|pcspkr")
if [ -f "/var/log/kern.log" ]; then
  out+=$(egrep 'I/O error|superblock|Error|Aborting|Remounting filesystem read-only' \
    /var/log/kern.log | \
    grep -v RAS)
else
  out+="\nNo kern.log????"
fi

if [ "$out" != "" ]; then
    echo "Woops! : $out"
    exit 1
else
    echo "Clean"
    exit 0
fi
