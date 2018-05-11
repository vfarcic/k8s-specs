mkdir -p /etc/cni/net.d
echo $NODE_SUBNET
sudo cat >/etc/cni/net.d/10-mynet.conf <<EOF
{
	"cniVersion": "0.3.1",
	"name": "mynet",
	"type": "bridge",
	"bridge": "cni0",
	"isGateway": true,
	"ipMasq": true,
	"ipam": {
		"type": "host-local",
		"subnet": "${NODE_SUBNET}",
		"routes": [
			{ "dst": "0.0.0.0/0" }
		]
	}
}
EOF