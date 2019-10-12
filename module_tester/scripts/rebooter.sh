#!/bin/bash
ver=$1

vml=$(ls /boot | grep vmlinuz-$ver)
ini=$(ls /boot | grep initrd.img-$ver)
kv=$(uname -r)
nkv=$(echo $vml | sed -e s#/boot##)
kexec -l /boot/$vml \
  --initrd=/boot/$ini \
  --command-line="$( cat /proc/cmdline | sed -e s/$kv/$nkv/ )"
