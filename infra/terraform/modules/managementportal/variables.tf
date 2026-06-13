variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "service_plan_name" {
  type = string
}

variable "web_app_name" {
  type = string
}

variable "python_version" {
  type    = string
  default = "3.12"
}

variable "startup_command" {
  type    = string
  default = "./startup.sh"
}

variable "existing_vnet_resource_group_name" {
  type = string
}

variable "existing_vnet_name" {
  type = string
}

variable "managementportal_subnet_name" {
  type = string
}

variable "managementportal_subnet_address_prefixes" {
  type = list(string)
}

variable "default_image" {
  type = string
}

variable "dry_run" {
  type    = string
  default = "false"
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "sku_name" {
  type    = string
  default = "B1"
}
