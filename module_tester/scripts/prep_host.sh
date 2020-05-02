#!/bin/bash -xe
#
#
source envfile
source local_envs.sh

echo "PHASE 1 START" > /var/log/fio_test.log
SECONDS=0

if [ "$dist" == "debian" ]; then
    export DEBIAN_FRONTEND=noninteractive
    apt install debconf-utils

    echo 'libssl1.0.0:amd64 libssl1.0.0/restart-services string' | \
    sudo debconf-set-selections
    # if [ "$apt_proxy" != "" ]; then
    #    echo "Acquire::http::Proxy \"$apt_proxy\";" > /etc/apt/apt.conf.d/01proxy
    # fi
    apt-get update
    apt-get install -y sudo
    apt-get install -y gcc make dkms \
      git make fakeroot build-essential fio \
      debhelper libelf-dev python-pip rsync jq procps \
      colortail netdata \
      kexec-tools alien linux-headers-$(uname -r)

    apt -y autoremove && sudo apt -y clean
elif [[ "$dist" =~ "rhel" ]]; then
    yum upgrade -y
    yum install -y kernel-headers kernel-devel gcc git make dkms fio \
      jq rpm-build mlocate
    #  python2-pip
elif [[ "$dist" =~ "suse" ]]; then
    # hard code suse for now...
    echo "NETCONFIG_DNS_STATIC_SERVERS=8.8.8.8" >> /etc/sysconfig/network/config
    netconfig update -f
    zypper -n install gcc git make dkms fio jq python2-pip chrony vim
    rm /etc/localtime && ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime
    systemctl enable chronyd
    systemctl start chronyd
    sleep 5
    chronyc makestep
    sleep 5
    ln -s /usr/local/bin/mc /usr/bin/mc
    export PATH=$PATH:/usr/local/bin
elif [[ "$dist" =~ "arch" ]]; then
    pacman -Syyu
    pacman --noconfirm -Syu git gcc make fio jq rpmextract dkms man vim
else
    echo "unsupported os: $dist"
    exit 1
fi
curl -o /usr/local/bin/mc \
    https://dl.minio.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/local/bin/mc

mc config host add s3 $MC_ENDPOINT $MC_ACCESS $MC_SECRET --api $MC_APIVER
if [[ "$dist" =~ "arch" ]]; then
    mc cp s3/binaries/rsync /usr/local/bin/
fi
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
if [ "$running_kernel" != "$kernel_branch" -a "$kernel_branch" != "" ]; then
    if [[ "$kernel_branch" =~ "-rc" ]]; then
        kernel_branch=$(echo $kernel_branch | perl -ne '/(\d+.\d+)(-rc\d+)/; print $1.".0$2"')
    fi
    if [ "$dist" != "debian" ]; then
        echo "No custom kernel supported for $dist. leaving $running_kernel in place"
        sed -i 's/^kernel_branch=/# kernel_branch=/g' envfile
    else
        cps3 s3/$pkg_loc linux-image-${kernel_branch} .
        cps3 s3/$pkg_loc linux-headers-${kernel_branch} .
        set +e
        rm *-dbg*
        set -e
        dpkg -i *.deb
    fi
    # updateGrub $kernel_branch$
elif [ "$kernel_branch" == "" ]; then
    echo "Leaving kernel alone."
fi

delta=$SECONDS
echo "PHASE 1 END: $delta" >> /var/log/fio_test.log
