#!/bin/bash -xe
#
#

echo "PHASE 1 START" > /var/log/fio_test.log
SECONDS=0
source envfile

export DEBIAN_FRONTEND=noninteractive
apt install debconf-utils

echo 'libssl1.0.0:amd64 libssl1.0.0/restart-services string' | \
    sudo debconf-set-selections
if [ "$apt_proxy" != "" ]; then
    echo "Acquire::http::Proxy \"$apt_proxy\";" > /etc/apt/apt.conf.d/01proxy
fi
apt-get update
apt-get install -y sudo
apt-get install -y gcc make \
  git make fakeroot build-essential fio \
  debhelper libelf-dev python-pip rsync jq procps \
  kexec-tools alien linux-headers-$(uname -r)

apt -y autoremove && sudo apt -y clean
curl -o /usr/local/bin/mc \
  https://dl.minio.io/client/mc/release/linux-amd64/mc && \
  chmod +x /usr/local/bin/mc

mc config host add s3 $MC_ENDPOINT $MC_ACCESS $MC_SECRET $MC_APIVER
cps3() {
    loc=$1
    match=$2
    dest=$3
    ms=$(mc ls $loc | grep $match | awk '{ print $5 }')
    for m in $ms; do
        mc cp $loc/$m $dest
    done
}

updateGrub() {
    kernelVer=$1
    fgrep menuentry /boot/grub/grub.cfg | \
        awk -F\' '{ print $2 }' | \
        grep -v ^$ > menuOpts.tmp
    optNum=$(grep -Fn $kernelVer menuOpts.tmp | \
        grep -v recovery | \
        awk -F: '{ print $1 }')
    sed -i s/GRUB_DEFAULT=0/GRUB_DEFAULT=${optNum}/ /etc/default/grub
    update-grub
}

running_kernel=$(uname -r)
if [ "$running_kernel" != "$kernel_branch" -a -z "$kernel_branch" ]; then
    if [[ "$kernel_branch" =~ "-rc" ]]; then
        kernel_branch=$(echo $kernel_branch | perl -ne '/(\d+.\d+)(-rc\d+)/; print $1.".0$2"')
    fi

    cps3 s3/$pkg_loc linux-image-${kernel_branch} .
    cps3 s3/$pkg_loc linux-headers-${kernel_branch} .
    set +e
    rm *-dbg*
    set -e
    dpkg -i *.deb
    # updateGrub $kernel_branch$
else if [ -Z "$kernel_branch" ]; then
    echo "Leaving kernel alone."
fi
delta=$SECONDS
echo "PHASE 1 END: $delta" >> /var/log/fio_test.log
