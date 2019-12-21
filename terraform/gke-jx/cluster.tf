variable "cluster_name" {
  type    = string
  default = "jx-cluster"
}

variable "project_id" {
  type    = string
  default = "devops-26"
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-2"
}

variable "preemptible" {
  type    = bool
  default = true
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "k8s_version" {
  type = string
}

provider "google" {
  credentials = "${file("account.json")}"
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = var.k8s_version
}

resource "google_container_node_pool" "primary_nodes" {
  name         = var.cluster_name
  location     = var.region
  cluster      = "${google_container_cluster.primary.name}"
  version      = var.k8s_version
  node_count   = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling { 
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_upgrade = false
  }
  timeouts {
    create = "15m"
    update = "1h"
  }
}

output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}

output "project_id" {
  value = var.project_id
}
