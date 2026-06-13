locals {
  environment = "dev"
  location    = "germanywestcentral"
  tags = {
    project     = "forge-aks-platform"
    environment = "dev"
    managed_by  = "terraform"
  }

  network = {
    resource_group_name          = "rg-01"
    vnet_name                    = "vnet01"
    managementportal_subnet_name = "subnet-2-portal"
    managementportal_subnet_cidrs = ["172.16.0.64/27"]
    coreaks_subnet_name          = "subnet-3-aks"
    coreaks_subnet_cidrs         = ["172.16.0.192/26"]
  }

  coreaks = {
    resource_group_name = "rg-forge-dev-coreaks"
    aks_name            = "aks-forge-dev-01"
    dns_prefix          = "aks-forge-dev-01"
    acr_name            = "forgeaksdevacr01"
  }

  managementportal = {
    resource_group_name = "rg-forge-dev-managementportal"
    service_plan_name   = "asp-forge-dev-managementportal"
    web_app_name        = "app-forge-dev-managementportal"
  }
}
