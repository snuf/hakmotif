#!/bin/bash -v
#
epoch=$(date +%s)
export APT_PROXY=http://localhost:8080
vagrant up --provision | tee -a $epoch
delta=$(( $(date +%s) - $epoch ))
echo "$0 - RUNTIME: ${delta}s" | tee -a $epoch

# vagrant destroy --force | tee -a $epoch
delta=$(( $(date +%s) - $epoch )) 
echo "$0 - DESTROYTIME: ${delta}s" | tee -a $epoch
