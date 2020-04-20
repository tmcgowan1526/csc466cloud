#!/bin/bash

while [ ! -f /opt/keys/kube.log ]; do
  sleep 20
done

command=`tail -n 2 /opt/keys/kube.log | tr -d '\\'`
sudo $command
