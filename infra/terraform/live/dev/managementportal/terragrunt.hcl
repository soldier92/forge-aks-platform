include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  subscription_id = get_env("ARM_SUBSCRIPTION_ID", "39023a16-af6f-4b68-8498-e36556540d33")
  container_registry_id = "/subscriptions/${local.subscription_id}/resourceGroups/${local.env.locals.coreaks.resource_group_name}/providers/Microsoft.ContainerRegistry/registries/${local.env.locals.coreaks.acr_name}"
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
  managementportal_subnet_address_prefixes = local.env.locals.network.managementportal_subnet_cidrs
  default_image                    = dependency.coreaks.outputs.default_image
  container_registry_id            = local.container_registry_id
  dry_run                          = "false"
  app_settings = {
    GITHUB_API_URL                        = "https://api.github.com"
    GITHUB_REPOSITORY                     = get_env("GITHUB_REPOSITORY", "")
    GITHUB_WORKFLOW_FILE                  = "requestedenvironment-infra.yml"
    GITHUB_WORKFLOW_REF                   = get_env("GITHUB_REF_NAME", "main")
    REQUESTED_ENVIRONMENT_DEPLOYMENT_TYPE = "aks-namespace-app"
  }
}
