#!/bin/bash 
set -x

sudo apt-get install -y nfs-kernel-server
sudo mkdir -p /opt/keys
sudo chown nobody:nogroup /opt/keys
sudo chmod -R a+rwx /opt/keys

echo "/opt/keys 192.168.1.2(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
echo "/opt/keys 192.168.1.3(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports

sudo systemctl restart nfs-kernel-server
sudo mkdir /opt/keys/flagdir

kubeadm init > /opt/keys/kube.log
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
kubectl apply -f /local/repository/dashboard-adminuser.yaml
