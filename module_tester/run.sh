#!/bin/bash -v
#
SECONDS=0
resultDir="results"
. ../envfile

logFile="${resultDir}/$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$resultDir" ];then
    mkdir $resultDir
fi
if [ -z ${test_device_pcibusid} ]; then
    echo "test_device_pcibusid not set in envfile"
    exit 1
fi
if [ -z ${test_box} ]; then
    echo "test_box not set in envfile"
    exit 2
fi
vagrant \
    --box=${test_box} \
    --pcibusid=${test_device_pcibusid} \
    up | tee -a $logFile
echo "$0 - RUNTIME: ${SECONDS}s" | tee -a $logFile

# vagrant destroy --force | tee -a $start
# echo "$0 - DESTROYTIME: ${SECONDS}s" | tee -a $
