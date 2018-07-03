resource "digitalocean_ssh_key" "k8s_key" {
  name       = "k8s_key"
  public_key = "${file("k8s-key.pub")}"
}

resource "digitalocean_droplet" "k8s_master" {
  name     = "k8s-master"
  image    = "${var.k8s_snapshot_id}"
  region   = "${var.region}"
  size     = "${var.k8s_master_size}"
  ssh_keys = ["${digitalocean_ssh_key.k8s_key.id}"]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("k8s-key")}"
  }

  provisioner "file" {
    source      = "s3cfg.tpl"
    destination = "~/.s3cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "sysctl net.bridge.bridge-nf-call-iptables=1",
      "kubeadm init --pod-network-cidr=\"10.244.0.0/16\" | sudo tee /opt/kube-init.log",
      "export KUBECONFIG=/etc/kubernetes/admin.conf",
      "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml",
      "kubeadm token create --print-join-command > k8s_join_cmd",
      "AWS_SECRET_ACCESS_KEY=${var.space_secret_key} AWS_ACCESS_KEY_ID=${var.space_access_key} s3cmd put k8s_join_cmd s3://${var.do_space}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "AWS_SECRET_ACCESS_KEY=${var.space_secret_key} AWS_ACCESS_KEY_ID=${var.space_access_key} s3cmd rm s3://${var.do_space}/k8s_join_cmd",
    ]

    when = "destroy"
  }
}

resource "digitalocean_droplet" "k8s_node" {
  name     = "k8s-node-${count.index + 1}"
  image    = "${var.k8s_snapshot_id}"
  region   = "${var.region}"
  size     = "${var.k8s_node_size}"
  ssh_keys = ["${digitalocean_ssh_key.k8s_key.id}"]
  count    = "${var.k8s_nodes}"

  depends_on = ["digitalocean_droplet.k8s_master"]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("k8s-key")}"
  }

  provisioner "file" {
    source      = "s3cfg.tpl"
    destination = "~/.s3cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "sysctl net.bridge.bridge-nf-call-iptables=1",
      "AWS_SECRET_ACCESS_KEY=${var.space_secret_key} AWS_ACCESS_KEY_ID=${var.space_access_key} s3cmd get s3://${var.do_space}/k8s_join_cmd",
      "sh k8s_join_cmd",
    ]
  }
}

output "master-ip" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address}"
}
