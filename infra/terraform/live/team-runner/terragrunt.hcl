include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  team_name        = get_env("TEAM_NAME", "demo")
  environment_name = get_env("REQUESTED_ENVIRONMENT", "dev")
  image            = get_env("REQUESTED_IMAGE", "forgeaksdevacr01.azurecr.io/default-app:latest")
  requested_cpu    = get_env("REQUESTED_CPU", "500m")
  requested_memory = get_env("REQUESTED_MEMORY", "512Mi")
  app_version      = get_env("APP_VERSION", "manual")
}

terraform {
  source = "../../modules/requestedenvironment"
}

generate "kubernetes_provider" {
  path      = "provider.kubernetes.generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  config_path = "${get_env("KUBECONFIG", "~/.kube/config")}"
}
EOF
}

remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = get_env("TFSTATE_RESOURCE_GROUP", "rg-01")
    storage_account_name = get_env("TFSTATE_STORAGE_ACCOUNT", "defaultstac0231")
    container_name       = get_env("TFSTATE_CONTAINER", "default")
    key                  = "requestedenvironment/${local.team_name}/${local.environment_name}.terraform.tfstate"
    subscription_id      = get_env("ARM_SUBSCRIPTION_ID", "39023a16-af6f-4b68-8498-e36556540d33")
    tenant_id            = get_env("ARM_TENANT_ID", "")
    use_azuread_auth     = true
  }
}

inputs = {
  team_name        = local.team_name
  environment      = local.environment_name
  image            = local.image
  requested_cpu    = local.requested_cpu
  requested_memory = local.requested_memory
  app_version      = local.app_version
}
