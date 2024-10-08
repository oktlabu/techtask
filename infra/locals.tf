locals {
  rg_name                           = "${var.project_name}-rg-${var.env}"
  vnet_name                         = "${var.project_name}-vnet-${var.env}"
  subnet_name_app                   = "${var.project_name}-subnet-${var.env}"
  subnet_name_agw                   = "${var.project_name}-agw-subnet-${var.env}"
  kv_name                           = "${var.project_name}-kv-${var.env}"
  container_registry_name           = "${var.project_name}conreg${var.env}"
  container_app_env_name            = "${var.project_name}-con-app-env-${var.env}"
  container_app                     = "${var.project_name}-con-app-${var.env}"
  application_gate_name             = "${var.project_name}-con-app-${var.env}"
  gate_ip_configuration_name        = "${var.project_name}-gate-ip-config-${var.env}"
  back_address_pool_name            = "${var.project_name}-back-address-pool-${var.env}"
  http_listener_name                = "${var.project_name}-listener-${var.env}"
  front_ip_config_name              = "${var.project_name}-front-config-${var.env}"
  front_port_name                   = "${var.project_name}-front-port-${var.env}"
  routing_rule                      = "${var.project_name}-route-rule-${var.env}"
  back_http_setting_name            = "${var.project_name}-back-hhtp-setting-${var.env}"
  acr_username                      = "acr-username-${var.env}"
  acr_password                      = "acr-password-${var.env}"
  log_name                          = "${var.project_name}-log-${var.env}"
  public_ip_name                    = "${var.project_name}-pip-${var.env}"
  vnet_link                         = "${var.project_name}-vnet-link-${var.env}"
  private_link                      = "${var.project_name}-private-link-${var.env}"
}

