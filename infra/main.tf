#------------------------------Resource Group------------------------------------
resource "azurerm_resource_group" "test_rg" {
  name     = local.rg_name
  location = var.location

  tags = {
    Environment = var.env
    Owner       = "Abu"
    Project     = "Risktec"
  }
}
#----------------------------------VNET--------------------------------------------
resource "azurerm_virtual_network" "test_rg" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_subnet" "app" {
  name                 = local.subnet_name_app
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.test_rg.name
  address_prefixes     = ["10.0.0.0/23"]
}

resource "azurerm_subnet" "agw" {
  name                 = local.subnet_name_agw
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.test_rg.name
  address_prefixes     = ["10.0.2.0/24"]
}
#--------------------------------Key Vault--------------------------------------
resource "azurerm_key_vault" "test_rg" {
  name                = local.kv_name
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
  sku_name            = "standard"

  tenant_id = data.azurerm_client_config.test_rg.tenant_id
  access_policy {
    tenant_id = data.azurerm_client_config.test_rg.tenant_id
    object_id = data.azurerm_client_config.test_rg.object_id
    key_permissions = ["Get", "List"]
    secret_permissions = ["Set", "Get", "List"]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.test_rg.tenant_id
    object_id = "b9fe7ab7-a77c-4a8d-99a9-5f7f7fbcd70a"
    key_permissions = ["Get", "List"]
    secret_permissions = ["Set", "Get", "List"]
  }
  depends_on = [azurerm_resource_group.test_rg]
}
#------------------------------Container Registry-----------------------------------
resource "azurerm_container_registry" "test_rg" {
  name                = local.container_registry_name
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location
  sku                 = "Basic"
  admin_enabled       = true

  depends_on = [azurerm_key_vault.test_rg]
}

data "azurerm_container_registry" "test_rg" {
  name                = azurerm_container_registry.test_rg.name
  resource_group_name = azurerm_resource_group.test_rg.name
}
#------------------------------------Key Vault--------------------------------------
data "azurerm_key_vault_secret" "acr_username" {
  name         = local.acr_username
  key_vault_id = azurerm_key_vault.test_rg.id
}

data "azurerm_key_vault_secret" "acr_password" {
  name         = local.acr_password
  key_vault_id = azurerm_key_vault.test_rg.id
}

resource "azurerm_key_vault_secret" "acr_username" {
  count = data.azurerm_key_vault_secret.acr_username.value == "" ? 1 : 0
  name         = local.acr_username
  value        = data.azurerm_container_registry.test_rg.admin_username
  key_vault_id = azurerm_key_vault.test_rg.id
}

resource "azurerm_key_vault_secret" "acr_password" {
  count = data.azurerm_key_vault_secret.acr_password.value == "" ? 1 : 0
  name         = local.acr_password
  value        = data.azurerm_container_registry.test_rg.admin_password
  key_vault_id = azurerm_key_vault.test_rg.id
}

#--------------------------------Log Analytic Workspace---------------------------------
resource "azurerm_log_analytics_workspace" "test_rg" {
  name                = local.log_name
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
#--------------------------------Container App------------------------------------------------
resource "azurerm_container_app_environment" "test_rg" {
  name                            = local.container_app_env_name
  resource_group_name             = azurerm_resource_group.test_rg.name
  location                        = azurerm_resource_group.test_rg.location
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.test_rg.id
  infrastructure_subnet_id        = azurerm_subnet.app.id
  internal_load_balancer_enabled  = true
}

resource "azurerm_container_app" "test_rg" {
  name                          = local.container_app
  resource_group_name           = azurerm_resource_group.test_rg.name
  container_app_environment_id  = azurerm_container_app_environment.test_rg.id
  revision_mode                 = "Single"

  registry {
    server               = data.azurerm_container_registry.test_rg.login_server
    username             = data.azurerm_container_registry.test_rg.admin_username
    password_secret_name = local.acr_password
  }

  secret { 
    name  = local.acr_password 
    value = data.azurerm_container_registry.test_rg.admin_password
  }

  template {
    container {
      name   = local.container_app
      image  = "${azurerm_container_registry.test_rg.login_server}/${var.repo_name}:${var.tag_name}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    min_replicas = 1
    max_replicas = 10
  }
    ingress {
      external_enabled           = true
      allow_insecure_connections = true
      target_port                = var.container_port
      traffic_weight {
        percentage = 100 
        latest_revision = true
    }
  }
}
#------------------------------Private DNS Zone------------------------------------------
resource "azurerm_private_dns_zone" "test_rg" {
  name                = azurerm_container_app.test_rg.latest_revision_fqdn
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_private_dns_a_record" "all" {
  name                = "*" 
  resource_group_name = azurerm_resource_group.test_rg.name
  zone_name           = azurerm_private_dns_zone.test_rg.name
  ttl                 = 3600
  records             = [azurerm_container_app_environment.test_rg.static_ip_address]
}

resource "azurerm_private_dns_a_record" "dog" {
  name                = "@" 
  resource_group_name = azurerm_resource_group.test_rg.name
  zone_name           = azurerm_private_dns_zone.test_rg.name
  ttl                 = 3600
  records             = [azurerm_container_app_environment.test_rg.static_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "test_rg" {
  name                  = local.vnet_link
  resource_group_name   = azurerm_resource_group.test_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.test_rg.name
  virtual_network_id    = azurerm_virtual_network.test_rg.id
}
#-------------------------------------PublicIP Adress------------------------------------------
resource "azurerm_public_ip" "test_rg" {
  name                = local.public_ip_name
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
#-----------------------------------Application Gateway WAF--------------------------------------
resource "azurerm_application_gateway" "test_rg" {
  name                = local.application_gate_name
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  waf_configuration {
    firewall_mode    = "Detection" 
    enabled          = true
    rule_set_version = 3.2
  }

  gateway_ip_configuration {
    name      = local.gate_ip_configuration_name
    subnet_id = azurerm_subnet.agw.id
  }

  frontend_port {
    name = local.front_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.front_ip_config_name
    public_ip_address_id = azurerm_public_ip.test_rg.id
  }

  backend_address_pool {
    name    = local.back_address_pool_name
    fqdns   = [azurerm_container_app.test_rg.latest_revision_fqdn]
  }

  backend_http_settings {
    name                                = local.back_http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    host_name                           = azurerm_container_app.test_rg.latest_revision_fqdn
    probe_name                          = "health-probe"
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.front_ip_config_name
    frontend_port_name             = local.front_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.routing_rule
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.back_address_pool_name
    backend_http_settings_name = local.back_http_setting_name
  }
  probe {
    name                                        = "health-probe"
    protocol                                    = "Https"
    path                                        = "/api/data" 
    port                                        = 443
    interval                                    = 30
    timeout                                     = 30
    unhealthy_threshold                         = 3
    pick_host_name_from_backend_http_settings   = true
    
    match {
            body        = null
            status_code = ["200-399"]
        }
  }
}
