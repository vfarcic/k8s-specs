resource "digitalocean_ssh_key" "k8s_key" {
  name = "k8s_key"
  public_key = "${file("k8s-key.pub")}"
}

resource "digitalocean_droplet" "k8s_master" {
  name     = "k8s-master"
  image    = "${var.k8s_snapshot_id}"
  region   = "nyc3"
  size     = "s-2vcpu-2gb"
  ssh_keys = ["${digitalocean_ssh_key.k8s_key.id}"]

  provisioner "remote-exec" {
    inline = [
      "sysctl net.bridge.bridge-nf-call-iptables=1",
      "kubeadm init --pod-network-cidr=\"10.244.0.0/16\" | sudo tee /opt/kube-init.log",
      "export KUBECONFIG=/etc/kubernetes/admin.conf",
      "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("k8s-key")}"
    }
  }
}

resource "digitalocean_droplet" "k8s_node" {
  name     = "k8s-node-${count.index + 1}"
  image    = "${var.k8s_snapshot_id}"
  region   = "nyc3"
  size     = "s-2vcpu-2gb"
  ssh_keys = ["${digitalocean_ssh_key.k8s_key.id}"]
  count    = "${var.k8s_nodes}"

  provisioner "remote-exec" {
    inline = [
      "sysctl net.bridge.bridge-nf-call-iptables=1",
      "${var.k8s_join_command}",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("k8s-key")}"
    }
  }
}

output "master-ip" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address}"
}
