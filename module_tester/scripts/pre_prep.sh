#!/bin/bash -x
#
#
source envfile
source local_envs.sh

echo "PHASE 0 START" > /var/log/fio_test.log
SECONDS=0

default_ns="192.168.86.1"
default_proxy="http://${default_ns}:8080/"

AptProxy() {
  if [ "$enable_proxy" != "true" ]; then
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

if [ "$dist" == "arch" ]; then
    ArchResolvFix $nameserver
elif [ "$dist" == "debian" ]; then
    AptProxy $apt_proxy
fi

if [ "$orig_dist" == "fedora" ]; then
    FedoraResolvFix $nameserver
fi

if [ "$orig_dist" == "rhel" -a "$VERSION_ID" == "7" ]; then
    ResolveConfFix $nameserver
fi

delta=$SECONDS
echo "PHASE 0 END: $delta" >> /var/log/fio_test.log
