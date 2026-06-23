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

variable "quota_cpu" {
  type    = string
  default = "1000m"
}

variable "quota_memory" {
  type    = string
  default = "1024Mi"
}

variable "deploy_workload" {
  type    = bool
  default = false
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
