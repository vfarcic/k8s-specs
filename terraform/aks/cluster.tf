variable "cluster_name" {
  type    = string
  default = "devopsparadox"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "dns_prefix" {
  type    = string
  default = "dop"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_count" {
  type    = number
  default = 3
}

variable "min_count" {
  type    = number
  default = 3
}

variable "max_count" {
  type    = number
  default = 9
}

variable "k8s_version" {
  type = string
}

variable "auto_scaling" {
  type    = bool
  default = true
}

resource "azurerm_resource_group" "primary" {
  name     = var.cluster_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "primary" {
  name                = var.cluster_name
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.k8s_version

  agent_pool_profile {
    name                = "primary"
    enable_auto_scaling = var.auto_scaling
    count               = var.vm_count
    min_count           = var.min_count
    max_count           = var.max_count
    vm_size             = var.vm_size
    type                = "VirtualMachineScaleSets"
  }
  service_principal {
    client_id     = "${file("client_id")}"
    client_secret = "${file("client_secret")}"
  }
}

output "cluster_name" {
  value = var.cluster_name
}

output "location" {
  value = var.location
}

output "min_count" {
  value = var.min_count
}

output "max_count" {
  value = var.max_count
}
