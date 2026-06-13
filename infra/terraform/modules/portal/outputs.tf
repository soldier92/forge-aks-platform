output "resource_group_name" {
  value = azurerm_resource_group.portal.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.portal.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.portal.default_hostname
}

output "principal_id" {
  value = azurerm_linux_web_app.portal.identity[0].principal_id
}
