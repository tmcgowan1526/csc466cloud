#!/bin/bash

echo "NFS Client"
set -x

sudo apt-get update
sudo apt-get install -y nfs-common

sudo mkdir /opt/keys

sudo mount 192.168.1.1:/opt/keys /opt/keys || true
# Cycle until we can mount software.
while [ ! -d /opt/keys/flagdir ]; do
  sudo mount 192.168.1.1:/opt/keys /opt/keys || true
  sleep 60
done

# Keep the shared dirs after a reboot
echo '192.168.1.1:/opt/keys /opt/keys/ nfs' | sudo tee -a /etc/fstab

# join sawm
sleep 10
command=`sed -n '5p' /opt/keys/swarm.log`
$command
