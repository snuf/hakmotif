#!/bin/bash

set -x

kb() {
  if [[ $kernel_branch =~ -rc\d+ ]]; then
    echo $kernel_branch | sed -e s/-rc/.0-rc/
  elif [[ $kernel_branch =~ linux-.*.y$ ]]; then
   # need to rethink for this scenario...
   mm=$(echo $kernel_branch | sed -e s/linux-//)
   echo $mm
  else
   echo $kernel_branch
 fi
}

# some distributions do multiple part headers
# e.g. ubuntu, the base and their specifics
check_headers() {
  if [ "$kernel_hdrs" ]; then
    for khdr in $kernel_hdrs; do
      hdr+="$(mc ls s3/$pkg_loc/$khdr --json | jq -r ".key") "
    done
  ## deduce kernel_here if full header is given
  elif [ "$kernel_branch" ]; then
    hdr+=$(mc ls s3/$pkg_loc --json | grep linux-headers-$(kb) | jq -r ".key")
  fi
  echo $hdr
}

install_headers() {
  headers=$(check_headers)
  for hdr in $headers; do
    if [ "$kernel_hdrs" == "" ]; then
      kernel_hdrs=$hdr
    fi
    mc cp s3/$pkg_loc/$hdr $kernel_hdrs
    if [[ $kernel_hdrs =~ \.deb$ ]]; then
      dpkg -i $kernel_hdrs
    elif [[ $kernel_hdrs =~ \.rmp$ ]]; then
      alien -k $kernel_hdrs
      hdr=$( echo $kernel_hdrs | sed -e s/.rpm/.deb/)
      dpkg -i $kernel_hdrs
    else
      echo "Unkown package format: $kernel_hdrs"
      exit 1
    fi
    rm $kernel_hdrs
  done
}

mc config host add s3 $MC_ENDPOINT $MC_ACCESS $MC_SECRET $MC_APIVER
install_headers

mkdir -p staging
# everything from staging 
# build script should be injectable
if [ "$build_script" == "" ]; then
  ./build_script.sh
else
  if [[ $build_script =~ ^http:// ]]; then
    echo "wget?"
  fi
fi

## Later also upload the simple .ko
mc cp staging/* s3/$module_loc/
