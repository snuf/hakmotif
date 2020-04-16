#!/bin/bash
#

set -x
set -e

# local later
unpack_kernel() {
  mc cp s3/$src_loc/$kernel_src_tgz kernel_src.tgz
  tar -zxvf kernel_src.tgz
}

branch() {
  local kernel_branch=$1
  # z.x-rcY gets translated to z.x.0-rcY with debian package build
  if [[ $kernel_branch =~ .y ]]; then
    if [[ $kernel_branch =~ ^linux- ]]; then
      kb=$kernel_branch
    else
      kb=linux-$kernel_branch
    fi
  else
    kb=v$kernel_branch
  fi
  gc=$( git checkout $kb )

  # translate .y to the real branch
  if [[ $kernel_branch =~ -rc ]]; then
    kb=v$( echo $kernel_branch | sed -e s/-rc/.0-rc/ )
  elif [[ $kernel_branch =~ ^linux-.*.y$ ]]; then
    kb=$( git branch -vv | awk '{ print $6 }' | head -1 )
  fi
  echo $kb
}

get_config() {
  if [ "$conf" == "0" ]; then
    mc cp s3/$cfg_loc/config .config
  else
    mc ls s3/$cfg_loc/config-$kb
  fi
}

code_ver() {
  ver=$1
  a=${ver%%.*}; ver=${ver#*.}
  b=${ver%%.*}; ver=${ver#*.}
  c=${ver%%.*}; c=${ver%%-*}; ver=${ver#*.}
  (( x=$a*65536+$b*256+$c ))
  echo $x
}

# Check if package exists, if so exit...
#
mc config host add s3 $MC_ENDPOINT $MC_ACCESS $MC_SECRET $MC_APIVER
unpack_kernel
cd linux-stable
kb=$(branch $kernel_branch)
branch_info=$(git branch -v | grep '*')
branch_ver=$(echo "$branch_info" | awk '{ print $5 }')

[ "$(mc ls s3/$pkg_loc | grep $branch_ver | egrep "headers|image" | wc -l)" -ge "2" ] && kern=1 || kern=0
[ "$(mc ls s3/$cfg_loc | grep $branch_ver | wc -l)" == "1" ] && conf=1 || conf=0

# now for the true insanity check here...

ver=$(code_ver $kb)
# 264704
# if [[ $ver < $(code_ver 4.10.0) ]]; then
#   export KAFLAGS="-fno-pie -no-pie -fno-stack-protector"
#   export KCFLAGS="-fno-pie -no-pie -fno-stack-protector"
#   export KCPPFLAGS="-fno-pie -no-pie -fno-stack-protector"
#   export EXTRA_CFLAGS="-fno-pie -fno-stack-protector"
#   export CC=/usr/bin/gcc-5
# fi

# Swap these two, first conf and then kernel itself oh well
j=$(getconf _NPROCESSORS_ONLN)
if [ "$kern" == "0" ]; then
  # if [[ $ver < $(code_ver 4.8.0) ]]; then
  #   make -j$j x86_64_defconfig
  # else
    get_config
    make -j$j olddefconfig
  # fi
  [ "$conf" == "0" ] && mc cp .config s3/$cfg_loc/config-$kb
  make -j$j prepare
  make -j$j deb-pkg
  set +e
  cd ../ && mc cp *.deb s3/$pkg_loc/
  if [ "$?" == "0" ]; then
    mc cp *.changes s3/$pkg_loc/
  fi
  # linux-stable/tools/perf$ CFLAGS=-I/usr/lib/jvm/java-8-openjdk-amd64/include make


# elif [ "$kern" == "1" ]; then
#  if [ "$conf" == "1" ]; then
#     get_config
#     make -j$(getconf _NPROCESSORS_ONLN) olddefconfig
#     # make -j$(getconf _NPROCESSORS_ONLN) x86_64_defconfig
#     [ "$conf" == "0" ] && mc cp .config s3/$cfg_loc/config-$kb
#   fi
fi
echo "$branch_info"
