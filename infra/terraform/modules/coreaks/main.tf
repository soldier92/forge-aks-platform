data "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  virtual_network_name = var.existing_vnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
}

resource "azurerm_resource_group" "coreaks" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "coreaks" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.coreaks.name
  location            = azurerm_resource_group.coreaks.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "coreaks" {
  name                = var.aks_name
  location            = azurerm_resource_group.coreaks.location
  resource_group_name = azurerm_resource_group.coreaks.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Free"
  tags                = var.tags

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = data.azurerm_subnet.aks.id
    type           = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_role_assignment" "coreaks_acr_pull" {
  scope                = azurerm_container_registry.coreaks.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.coreaks.kubelet_identity[0].object_id
}
