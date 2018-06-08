#!/bin/bash
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo ${join_command}
