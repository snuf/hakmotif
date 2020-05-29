#!/bin/bash 
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
bastard_module=$(echo $module_project | sed -e s/-/_/)
lsmodOut=$(lsmod | awk '{ print $1 }' | egrep "^${module_project}$|^${bastard_module}$")
if [ "$?" == "0" ]; then
    echo $lsmodOut found, checking
    PCIdevs=$(ls /sys/module/${bastard_module}/drivers/pci\:${module_project}/ | grep \:)
    # should just check all PCI devices and modules irrespective of their thing thingy
    for PCIdev in PCIDevs; do
        if [ "$PCIdevs" != "" ]; then
            dev=$(echo $PCIdevs | awk -F: '{ print $2 }')
            if [ "$dev" == "${test_device_pcibusid}" ]; then
                echo "$bastard_module loaded and PCI device $dev in use, Aborting!!"
                echo "This can cause the host to kernel panic"
                lspci | egrep "^$dev|^$test_device_pcibusid"$
                exit 3
            else
                echo "$bastard_module is using PCI dev $dev, and not ${test_device_pcibusid}, safe to run"
                lspci | egrep "^$dev|^$test_device_pcibusid"
            fi
        else
            echo "Odd a driver, $lsmodOut, is loaded with no PCI Devices?! Aborting"
            exit 4
        fi
    done
fi
vagrant \
   --skip-iomodule-check \
   --box=${test_box} \
   --pcibusid=${test_device_pcibusid} \
   up | tee -a $logFile
echo "$0 - RUNTIME: ${SECONDS}s" | tee -a $logFile

# vagrant destroy --force | tee -a $start
# echo "$0 - DESTROYTIME: ${SECONDS}s" | tee -a $
