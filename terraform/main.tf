data "aws_ami" "k8s" {
  filter {
    name   = "name"
    values = ["ami-kubernetes-*"]
  }
  most_recent = true

  owners = ["self"]
}

data "template_file" "init" {
  template = "${file("init.tpl")}"

  vars {
    pod_network_cidr = "10.244.0.0/16"
  }
}

data "template_file" "join" {
  template = "${file("join.tpl")}"

  vars {
    join_command = "${var.k8s_join_command}"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.kube-master.id}"
  allocation_id = "${aws_eip.master-ip.id}"
}

resource "aws_instance" "kube-master" {
  ami                    = "${data.aws_ami.k8s.id}"
  instance_type          = "${var.k8s_master_instance_type}"
  user_data              = "${data.template_file.init.rendered}"
  key_name               = "${var.k8s_key_name}"
  vpc_security_group_ids = ["${aws_security_group.kube-sg.id}"]

  tags {
    Name    = "k8s-master-${var.k8s_lab_name}"
    LabName = "${var.k8s_lab_name}"
  }
}

resource "aws_instance" "kube-node" {
  ami                    = "${data.aws_ami.k8s.id}"
  instance_type          = "${var.k8s_node_instance_type}"
  user_data              = "${data.template_file.join.rendered}"
  key_name               = "${var.k8s_key_name}"
  vpc_security_group_ids = ["${aws_security_group.kube-sg.id}"]
  count                  = "${var.k8s_nodes}"

  tags {
    Name    = "k8s-node-${var.k8s_lab_name}"
    LabName = "${var.k8s_lab_name}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "aws_eip" "master-ip" {}

resource "aws_security_group" "kube-sg" {
  name = "k8s"

  // SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  K8S API SERVER 
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self = true
  }

  // etcd Sever client API
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self = true
  }

  //  K8S kubelet API 
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self = true
  }

  //  K8S kubelet API 
  ingress {
    from_port   = 10251
    to_port     = 10251
    protocol    = "tcp"
    self = true
  }

  //  K8S kubelet API 
  ingress {
    from_port   = 10252
    to_port     = 10252
    protocol    = "tcp"
    self = true
  }

  //  K8S kubelet API READ ONLY  
  ingress {
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    self = true
  }

  //  K8S Node Port Services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "master-ip" {
  value = "${aws_eip.master-ip.public_ip}"
}
