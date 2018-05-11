#!/bin/bash

echo "Initializing kubernetes master..."
sudo kubeadm init --apiserver-advertise-address 10.100.198.200
sudo kubeadm token create --print-join-command > /vagrant/nodetoken.out
sudo cp /etc/kubernetes/admin.conf /vagrant