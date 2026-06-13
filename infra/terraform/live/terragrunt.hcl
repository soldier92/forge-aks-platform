locals {
  subscription_id             = get_env("ARM_SUBSCRIPTION_ID", "39023a16-af6f-4b68-8498-e36556540d33")
  subscription_name           = "Katona.Balint"
  remote_state_storage        = get_env("TFSTATE_STORAGE_ACCOUNT", "defaultstac0231")
  remote_state_container      = get_env("TFSTATE_CONTAINER", "default")
  remote_state_resource_group = get_env("TFSTATE_RESOURCE_GROUP", "rg-01")
  tenant_id                   = get_env("ARM_TENANT_ID", "")
}

remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = local.remote_state_resource_group
    storage_account_name = local.remote_state_storage
    container_name       = local.remote_state_container
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    subscription_id      = local.subscription_id
    tenant_id            = local.tenant_id
    use_azuread_auth     = true
  }
}

generate "provider" {
  path      = "provider.generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
}
EOF
}
