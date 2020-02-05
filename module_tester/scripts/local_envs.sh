#!/bin/bash -x

osr="/etc/os-release"
if [ -f "$osr" ]; then
    source $osr
    if [ "$ID_LIKE" == "" ]; then
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
