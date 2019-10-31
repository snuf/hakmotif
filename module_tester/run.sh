#!/bin/bash -v
#
SECONDS=0
resultDir="results"
. ../envfile

logFile="${resultDir}/$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$resultDir" ];then
    mkdir $resultDir
fi
vagrant up | tee -a $logFile
echo "$0 - RUNTIME: ${SECONDS}s" | tee -a $logFile

# vagrant destroy --force | tee -a $start
# echo "$0 - DESTROYTIME: ${SECONDS}s" | tee -a $
