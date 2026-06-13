include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "coreaks" {
  config_path = "../coreaks"

  mock_outputs = {
    default_image = "forgeaksdevacr01.azurecr.io/default-app:latest"
  }
}

terraform {
  source = "../../../modules/managementportal"
}

inputs = {
  location                         = local.env.locals.location
  tags                             = local.env.locals.tags
  resource_group_name              = local.env.locals.managementportal.resource_group_name
  service_plan_name                = local.env.locals.managementportal.service_plan_name
  web_app_name                     = local.env.locals.managementportal.web_app_name
  existing_vnet_resource_group_name = local.env.locals.network.resource_group_name
  existing_vnet_name               = local.env.locals.network.vnet_name
  managementportal_subnet_name     = local.env.locals.network.managementportal_subnet_name
  default_image                    = dependency.coreaks.outputs.default_image
  dry_run                          = "false"
}
