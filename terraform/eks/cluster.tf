variable "cluster_name" {
  type    = string
  default = "devops-paradox"
}

# variable "project_id" {
#   type    = string
#   default = "devops-26"
# }

# variable "region" {
#   type    = string
#   default = "us-east1"
# }

# variable "machine_type" {
#   type    = string
#   default = "g1-small"
# }

# variable "preemptible" {
#   type    = bool
#   default = true
# }

# variable "min_node_count" {
#   type    = number
#   default = 1
# }

# variable "max_node_count" {
#   type    = number
#   default = 3
# }

# variable "k8s_version" {
#   type = string
# }

data "aws_availability_zones" "available" {}

resource "aws_vpc" "primary" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", var.cluster-name,
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "primary" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.demo.id}"

  tags = "${
    map(
     "Name", var.cluster-name ,
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "primary" {
  vpc_id = "${aws_vpc.demo.id}"

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_route_table" "primary" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo.id}"
  }
}

resource "aws_route_table_association" "primary" {
  count = 2

  subnet_id      = "${aws_subnet.demo.*.id[count.index]}"
  route_table_id = "${aws_route_table.demo.id}"
}

resource "aws_iam_role" "demo-cluster" {
  name = "terraform-eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


# provider "google" {
#   credentials = "${file("account.json")}"
#   project     = var.project_id
#   region      = var.region
# }

# resource "google_container_cluster" "primary" {
#   name                     = var.cluster_name
#   location                 = var.region
#   remove_default_node_pool = true
#   initial_node_count       = 1
#   min_master_version       = var.k8s_version
# }

# resource "google_container_node_pool" "primary_nodes" {
#   name         = var.cluster_name
#   location     = var.region
#   cluster      = "${google_container_cluster.primary.name}"
#   version      = var.k8s_version
#   node_count   = 1
#   node_config {
#     preemptible  = var.preemptible
#     machine_type = var.machine_type
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]
#   }
#   autoscaling { 
#     min_node_count = var.min_node_count
#     max_node_count = var.max_node_count
#   }
#   management {
#     auto_upgrade = false
#   }
#   timeouts {
#     create = "15m"
#     update = "1h"
#   }
# }

output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}