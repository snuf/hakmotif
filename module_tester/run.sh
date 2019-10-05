#!/bin/bash -v
#
epoch=$(date +%s)

vagrant up | tee $epoch
delta=$(( $(date +%s) - $epoch ))
echo "$0 - RUNTIME: ${delta}s" | tee $epoch

vagrant destroy --force | tee $epoch
delta=$(( $(date +%s) - $epoch )) 
echo "$0 - DESTROYTIME: ${delta}s" | tee $epoch
