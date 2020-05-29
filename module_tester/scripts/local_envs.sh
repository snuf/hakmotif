#!/bin/bash -x

osr="/etc/os-release"
if [ -f "$osr" ]; then
    source $osr
    if [ "$(echo $ID_LIKE | grep ' ')" != "" ]; then
        dist=$(echo $ID_LIKE | awk '{ print $1 }')
    elif [ "$ID_LIKE" == "" ]; then
        dist=$ID
    else
        dist=$ID_LIKE
    fi
    orig_dist=$dist
fi
# according to fedora convetions are for wimps
if [ -f "/etc/redhat-release" -a "$dist" == "fedora" ]; then
    dist="rhel"
fi

PATH=$PATH:/usr/local/bin
