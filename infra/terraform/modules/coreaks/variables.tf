variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "existing_vnet_resource_group_name" {
  type = string
}

variable "existing_vnet_name" {
  type = string
}

variable "aks_subnet_name" {
  type = string
}

variable "aks_subnet_address_prefixes" {
  type = list(string)
}

variable "node_count" {
  type    = number
  default = 1
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
