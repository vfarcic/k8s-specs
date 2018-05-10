echo "configuring route..."
sudo ip route add ${CROSS_NODE_SUBNET} via ${CROSS_NODE_IP} dev enp0s8
ip route list ${CROSS_NODE_SUBNET}