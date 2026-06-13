output "resource_group_name" {
  value = azurerm_resource_group.managementportal.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.managementportal.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.managementportal.default_hostname
}

output "principal_id" {
  value = azurerm_linux_web_app.managementportal.identity[0].principal_id
}
