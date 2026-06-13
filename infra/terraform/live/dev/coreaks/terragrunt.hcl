include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/coreaks"
}

inputs = {
  location                         = local.env.locals.location
  tags                             = local.env.locals.tags
  resource_group_name              = local.env.locals.coreaks.resource_group_name
  aks_name                         = local.env.locals.coreaks.aks_name
  dns_prefix                       = local.env.locals.coreaks.dns_prefix
  acr_name                         = local.env.locals.coreaks.acr_name
  existing_vnet_resource_group_name = local.env.locals.network.resource_group_name
  existing_vnet_name               = local.env.locals.network.vnet_name
  aks_subnet_name                  = local.env.locals.network.coreaks_subnet_name
  aks_subnet_address_prefixes      = local.env.locals.network.coreaks_subnet_cidrs
}
