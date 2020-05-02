#!/bin/bas

source envfile
source local_envs.sh

set -x
set -e

exec_exit() {
  rc=$1; shift
  line=$@
}

vmDir="${test_dir}/VMs"
imageSource="https://cloud.debian.org/images/cloud/buster/daily"
imageTag="20200416-233"
imageName="debian-10-nocloud-amd64-daily-${imageTag}.qcow2"
imageUrl="$imageSource/$imageTag/$imageName"

if [ "$dist" == "debian" ]; then
  sudo apt-get install -y \
    qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils \
    virt-manager virt-install libguestfs-tools

  sudo adduser vagrant libvirt
  sudo adduser vagrant kvm
  mkdir -p $vmDir
  cd $vmDir

  curl -o ${imageName} ${imageUrl}
  virsh pool-define-as --name default --type dir --target $vmDir
  virsh pool-build default
  virsh pool-start default
  virsh pool-autostart default

  cat /dev/zero | ssh-keygen -q -N ""

  virt-sysprep -a ${vmDir}/${imageName} \
    --run-command 'useradd admin && mkdir /home/admin && chown -R admin /home/admin && adduser admin sudo' \
    --ssh-inject admin:file:/home/vagrant/.ssh/id_rsa.pub
  # This gets wiped everytime... figure out another way to get it on there
  virt-sysprep -a ${vmDir}/${imageName} \
    --run-command 'ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N "" -t rsa'
  virt-sysprep -a ${vmDir}/${imageName} \
    --run-command "echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/admin"
  virt-install \
    -v \
    -n ${imageTag} \
    --description "Debian Test VM ${imageTag}" \
    --os-type=Linux \
    --os-variant=debian10 \
    --ram=2048 \
    --vcpus=2 \
    --disk path=${vmDir}/${imageName},bus=virtio,size=10 \
    --graphics none \
    --network bridge:virbr0 \
    --boot hd \
    --noautoconsole

    #   nets=`virsh -q net-list | awk '{ print $1 }'`
    #   for net in $nets; do
    #     echo "net: $net"
    #     virsh -q net-dhcp-leases $net
    #   done
  guestIp=$(virsh -q net-dhcp-leases default | sort | tail -1 | awk '{ print $5 }' | awk -F/ '{print $1}')

  virsh destroy ${imageTag}
  virsh undefine ${imageTag}
fi
