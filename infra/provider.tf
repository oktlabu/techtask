provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test_rg" {}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-config"
    storage_account_name = "terraformconfsadev"
    container_name       = "terraform-state"
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

