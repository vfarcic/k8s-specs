variable "k8s_join_command" {
  default = ""
}

variable "k8s_nodes" {
  default = 2
}

variable "k8s_node_instance_type" {
  default = "t2.small"
}

variable "k8s_master_instance_type" {
  default = "t2.small"
}

variable "k8s_key_name" {
  default = ""
}

variable "k8s_lab_name" {
  default = "devops24"
}
