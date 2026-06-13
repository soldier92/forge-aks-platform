variable "team_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "image" {
  type = string
}

variable "requested_cpu" {
  type = string
}

variable "requested_memory" {
  type = string
}

variable "app_name" {
  type    = string
  default = "starter-api"
}

variable "service_account_name" {
  type    = string
  default = "starter-api-sa"
}

variable "app_version" {
  type    = string
  default = "latest"
}
