#!/bin/bash

source envfile
source local_envs.sh

if [ "$dist" == "debian" ]; then
  sudo apt-get install -y docker.io
fi
