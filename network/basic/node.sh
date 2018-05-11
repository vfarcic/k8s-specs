#!/bin/bash

echo "Joining kubernetes node..."
sudo su -
joincommand=`cat /vagrant/nodetoken.out`
echo "Executing below join command..."
echo $joincommand
$joincommand
