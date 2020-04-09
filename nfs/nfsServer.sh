#!/bin/bash

echo 'NFS server isntallation'

set -x

mkdir -p /opt/keys

sudo chown nobody:nogroup /opt/keys
sudo chmod -R a+rx /opt/keys

#################

sudo apt-get install -y nfs-kernel-server

# Create the permissions file for the NFS directory.
echo "/opt/keys 192.168.1.2(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
echo "/opt/keys 192.168.1.3(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports

sudo systemctl restart nfs-kernel-server
mkdir -p /opt/keys/flagdir
