variable "cluster_name" {
  type    = string
  default = "devops-paradox"
}

variable "region" {
  type    = string
  default = "nyc1"
}

variable "machine_type" {
  type    = string
  default = "s-1vcpu-2gb"
}

variable "min_nodes" {
  type    = number
  default = 3
}

variable "max_nodes" {
  type    = number
  default = 9
}

variable "k8s_version" {
  type = string
}

provider "digitalocean" {
  token = "${file("token")}"
}

resource "digitalocean_kubernetes_cluster" "primary" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version

  node_pool {
    name       = var.cluster_name
    size       = var.machine_type
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }
}

output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}