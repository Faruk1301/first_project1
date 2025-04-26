terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfstatefaruk1234567"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Backend resources (for storing Terraform state)
resource "azurerm_resource_group" "backend" {
  name     = "terraform-backend-rg"
  location = "East US"
}

resource "azurerm_storage_account" "backend" {
  name                     = "tfstatefaruk1234567"
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = azurerm_resource_group.backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.backend.name
  container_access_type = "private"
}

# Application Resource Group
resource "azurerm_resource_group" "app_rg" {
  name     = "webapp-rg"
  location = "East US"
}

# App Service Plan
resource "azurerm_app_service_plan" "asp" {
  name                = "webapp-asp"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Random string for unique webapp names
resource "random_string" "random" {
  length  = 6
  upper   = false
  special = false
}

# Dev Web App
resource "azurerm_linux_web_app" "dev_app" {
  name                = "dev-webapp-${random_string.random.id}"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  service_plan_id     = azurerm_app_service_plan.asp.id

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}

# Staging Web App
resource "azurerm_linux_web_app" "staging_app" {
  name                = "staging-webapp-${random_string.random.id}"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  service_plan_id     = azurerm_app_service_plan.asp.id

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}

# Outputs
output "dev_webapp_url" {
  value = "https://${azurerm_linux_web_app.dev_app.default_hostname}"
}

output "staging_webapp_url" {
  value = "https://${azurerm_linux_web_app.staging_app.default_hostname}"
}
