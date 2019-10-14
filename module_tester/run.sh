#!/bin/bash -v
#
SECONDS=0
resultDir=results
. envfile

logFile=""

vagrant up --provision | tee -a $start
echo "$0 - RUNTIME: ${SECONDS}s" | tee -a $start

# vagrant destroy --force | tee -a $start
echo "$0 - DESTROYTIME: ${SECONDS}s" | tee -a $start
