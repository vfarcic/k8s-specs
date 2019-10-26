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

variable "node_count" {
  type    = number
  default = 3
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
    node_count = var.node_count
  }
}

output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}