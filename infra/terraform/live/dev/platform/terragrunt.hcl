include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/aks-platform"
}

inputs = {
  location                         = local.env.locals.location
  tags                             = local.env.locals.tags
  resource_group_name              = local.env.locals.platform.resource_group_name
  aks_name                         = local.env.locals.platform.aks_name
  dns_prefix                       = local.env.locals.platform.dns_prefix
  acr_name                         = local.env.locals.platform.acr_name
  existing_vnet_resource_group_name = local.env.locals.network.resource_group_name
  existing_vnet_name               = local.env.locals.network.vnet_name
  aks_subnet_name                  = local.env.locals.network.aks_subnet_name
}
