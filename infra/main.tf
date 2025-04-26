provider "azurerm" {
  features {}
}

# Remote Backend Configuration (Azure Storage Account for State File)
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-backend-rg"
    storage_account_name  = "tfstatefaruk1234567"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

# Define variables
variable "location" {
  default = "East US"
}

variable "app_service_plan_name" {
  default = "my-app-service-plan"
}

# Resource Group for Dev and Staging environments
resource "azurerm_resource_group" "dev_rg" {
  name     = "my-resource-group-dev"
  location = var.location
}

resource "azurerm_resource_group" "staging_rg" {
  name     = "my-resource-group-staging"
  location = var.location
}

# App Service Plan
resource "azurerm_app_service_plan" "dev_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service_plan" "staging_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = azurerm_resource_group.staging_rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Dev Web App
resource "azurerm_web_app" "dev_web_app" {
  name                = "my-dev-webapp"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  app_service_plan_id = azurerm_app_service_plan.dev_plan.id
}

# Staging Web App
resource "azurerm_web_app" "staging_web_app" {
  name                = "my-staging-webapp"
  location            = var.location
  resource_group_name = azurerm_resource_group.staging_rg.name
  app_service_plan_id = azurerm_app_service_plan.staging_plan.id
}

output "dev_web_app_url" {
  value = azurerm_web_app.dev_web_app.default_site_hostname
}

output "staging_web_app_url" {
  value = azurerm_web_app.staging_web_app.default_site_hostname
}
