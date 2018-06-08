#!/bin/bash
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo kubeadm init --pod-network-cidr="${pod_network_cidr}" | sudo tee /opt/kube-init.log
sudo mkdir /home/ubuntu/.kube
sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu -R /home/ubuntu
