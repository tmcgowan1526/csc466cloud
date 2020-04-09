#!/bin/bash

echo 'NFS server isntallation'

set -x

mkdir -p /opt/keys

sudo chown nobody:nogroup /opt/keys
sudo chmod -R a+rx /opt/keys

#################

sudo apt-get install -y nfs-kernel-server

# Create the permissions file for the NFS directory.
computes=$(($1 + 1))
for i in $(seq 2 $computes)
do
  echo "/home 192.168.1.$i(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
  echo "/mpishare 192.168.1.$i(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
  echo "/opt 192.168.1.$i(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
  echo "/software 192.168.1.$i(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
done

# Let the Slurm node (head) have access to the shared directories.
slurmip=$(($2 + 1))
echo "/home 192.168.1.$slurmip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
echo "/mpishare 192.168.1.$slurmip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
echo "/opt 192.168.1.$slurmip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
echo "/software 192.168.1.$slurmip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports

## Let the login node have access to the shared directories.
#loginip=$(($3 + 1))
#echo "/home 192.168.1.$loginip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
#echo "/mpishare 192.168.1.$loginip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
#echo "/opt 192.168.1.$loginip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
#echo "/software 192.168.1.$loginip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports

sudo systemctl restart nfs-kernel-server
