#!/bin/bash
#
#
set -x

out=$(dmesg | \
    egrep "errors|warnings|BUG|stack_dump|OOPS|RIP" | \
    egrep -v "RAS|Opts: errors=remount-ro|urandom warnings|pcspkr")

if [ "$out" != "" ]; then
    echo "Woops! : $out"
    exit 1
else
    echo "Clean"
    exit 0
fi
