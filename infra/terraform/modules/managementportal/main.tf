data "azurerm_virtual_network" "shared" {
  name                = var.existing_vnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
}

resource "azurerm_subnet" "managementportal" {
  name                 = var.managementportal_subnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
  virtual_network_name = data.azurerm_virtual_network.shared.name
  address_prefixes     = var.managementportal_subnet_address_prefixes

  delegation {
    name = "appservice-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

resource "azurerm_resource_group" "managementportal" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "managementportal" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.managementportal.name
  location            = azurerm_resource_group.managementportal.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "managementportal" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.managementportal.name
  location            = azurerm_resource_group.managementportal.location
  service_plan_id     = azurerm_service_plan.managementportal.id
  https_only          = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on         = true
    app_command_line  = var.startup_command
    ftps_state        = "Disabled"
    minimum_tls_version = "1.2"

    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = merge(
    {
      SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
      WEBSITES_PORT                  = "8000"
      DRY_RUN                        = var.dry_run
      DEFAULT_IMAGE                  = var.default_image
    },
    var.app_settings
  )
}

resource "azurerm_app_service_virtual_network_swift_connection" "managementportal" {
  app_service_id = azurerm_linux_web_app.managementportal.id
  subnet_id      = azurerm_subnet.managementportal.id
}
