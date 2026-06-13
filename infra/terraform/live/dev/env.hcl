locals {
  environment = "dev"
  location    = "westeurope"
  tags = {
    project     = "forge-aks-platform"
    environment = "dev"
    managed_by  = "terraform"
  }

  network = {
    resource_group_name = "rg-01"
    vnet_name           = "vnet01"
    portal_subnet_name  = "subnet-2-portal"
    aks_subnet_name     = "subnet-3-aks"
  }

  platform = {
    resource_group_name = "rg-forge-dev-platform"
    aks_name            = "aks-forge-dev-01"
    dns_prefix          = "aks-forge-dev-01"
    acr_name            = "forgeaksdevacr01"
  }

  portal = {
    resource_group_name = "rg-forge-dev-portal"
    service_plan_name   = "asp-forge-dev-portal"
    web_app_name        = "app-forge-dev-portal"
  }
}
