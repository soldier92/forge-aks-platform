output "resource_group_name" {
  value = azurerm_resource_group.coreaks.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.coreaks.name
}

output "acr_name" {
  value = azurerm_container_registry.coreaks.name
}

output "acr_id" {
  value = azurerm_container_registry.coreaks.id
}

output "acr_login_server" {
  value = azurerm_container_registry.coreaks.login_server
}

output "default_image" {
  value = "${azurerm_container_registry.coreaks.login_server}/default-app:latest"
}
