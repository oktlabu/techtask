output "resource_group_id" {
  value = azurerm_resource_group.test_rg.id
}

output "container_app_url" {
  value       = azurerm_container_app.test_rg.latest_revision_fqdn
  description = "URL of the Container App"
}

output "container_image" {
  value = "${azurerm_container_registry.test_rg.login_server}/${var.repo_name}:${var.tag_name}"
  description = "The full image name with tag from the Azure Container Registry"
}


output "public_ip_address" {
  value       = azurerm_public_ip.test_rg.ip_address
  description = "The public IP address of the instance"
}




