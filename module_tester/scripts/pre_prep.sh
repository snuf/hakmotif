#!/bin/bash -x
#
#
source envfile
source local_envs.sh

echo "PHASE 0 START" > /var/log/fio_test_0.log
SECONDS=0

default_ns="192.168.86.1"
default_proxy="http://${default_ns}:8080/"

AptProxy() {
  if [ "$enable_proxy" == "true" ]; then
    proxy=${1:-$default_proxy}
    if [ "$proxy" != "" ]; then
      echo "Acquire::http::Proxy \"$proxy\";" > /etc/apt/apt.conf.d/01proxy
    fi
  fi
}

ArchResolvFix() {
  ns=${1:-$default_ns}
  echo "DNS=${ns}" >> /etc/systemd/resolved.conf
  systemctl daemon-reload
  systemctl restart systemd-resolved
}

FedoraResolvFix() {
  ns=${1:-$default_ns}
  grep dns=none /etc/NetworkManager/NetworkManager.conf
  if [ "$?" != "0" ]; then
    sed -i 's#\[main\]#\[main\]\ndns=none#' /etc/NetworkManager/NetworkManager.conf
  fi
  systemctl restart NetworkManager
  sleep 4
  ResolveConfFix $ns
}

ResolveConfFix() {
  ns=${1:-$default_ns}
  echo "DNS1=${ns}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
  echo "nameserver ${ns}" >> /etc/resolv.conf
}


DebResolveConfFix() {
  ns=${1:-$default_ns}
  echo "supersede domain-name-servers $ns;" >> /etc/dhcp/dhclient.conf
  echo "nameserver ${ns}" >> /etc/resolv.conf
}

netplanResolveConfFix() {
    ns=${1:-$default_ns}
    rm /etc/resolv.conf
    ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    netplan set ethernets.eth0.nameservers.addresses=["${ns}"]
    netplan apply
    sleep 10
    ping -c 2 www.google.com
}

if [ "$dist" == "arch" ]; then
    ArchResolvFix $nameserver
elif [ "$dist" == "debian" ]; then
    # proxmox is peculiar about its own hostname, otherwise /etc/pve 
    # is not mounted
    if [ -d "/etc/pve" ]; then
        DebResolveConfFix $nameserver
        hostsf=/etc/hosts
        cat $hostsf | egrep -v "127\.0\.1\.1|192\.168|10\.0\." > ${hostsf}.new
        ip=$(ip addr show dev eth0 | grep "inet " | awk '{ print $2 }' | awk -F\/ '{ print $1 }')
        echo "${ip} $(hostname) pvelocalhost" >> ${hostsf}.new
        mv ${hostsf}.new ${hostsf}
    elif [ -d "/etc/netplan" ]; then
        netplanResolveConfFix $nameserver
    fi
    
    AptProxy $apt_proxy
fi

if [ "$orig_dist" == "fedora" ]; then
    FedoraResolvFix $nameserver
fi

if [ "$orig_dist" == "rhel" -a "$VERSION_ID" == "7" ]; then
    ResolveConfFix $nameserver
fi

delta=$SECONDS
echo "PHASE 0 END: $delta" >> /var/log/fio_test_0.log
