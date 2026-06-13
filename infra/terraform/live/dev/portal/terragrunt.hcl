include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "platform" {
  config_path = "../platform"

  mock_outputs = {
    default_image = "forgeaksdevacr01.azurecr.io/default-app:latest"
  }
}

terraform {
  source = "../../../modules/portal"
}

inputs = {
  location                         = local.env.locals.location
  tags                             = local.env.locals.tags
  resource_group_name              = local.env.locals.portal.resource_group_name
  service_plan_name                = local.env.locals.portal.service_plan_name
  web_app_name                     = local.env.locals.portal.web_app_name
  existing_vnet_resource_group_name = local.env.locals.network.resource_group_name
  existing_vnet_name               = local.env.locals.network.vnet_name
  portal_subnet_name               = local.env.locals.network.portal_subnet_name
  default_image                    = dependency.platform.outputs.default_image
  dry_run                          = "false"
}
