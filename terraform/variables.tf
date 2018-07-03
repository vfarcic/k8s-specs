variable "token" {
  default = ""
}

variable "region" {
  default = "nyc3"
}

variable "k8s_master_size" {
  default = "s-2vcpu-2gb"
}

variable "k8s_node_size" {
  default = "s-2vcpu-2gb"
}

variable "k8s_nodes" {
  default = "2"
}

variable "k8s_snapshot_id" {}

variable "do_space" {}

variable "space_access_key" {}

variable "space_secret_key" {}
