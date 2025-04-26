provider "azurerm" {
  features {}
}

# Resource Group for Backend
resource "azurerm_resource_group" "terraform_backend_rg" {
  name     = "terraform-backend-rg"
  location = "East US"
}

# Storage Account for Remote Backend
resource "azurerm_storage_account" "tfstate_storage" {
  name                     = "tfstatefaruk1234567"
  resource_group_name       = azurerm_resource_group.terraform_backend_rg.name
  location                 = azurerm_resource_group.terraform_backend_rg.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

# Storage Container for Terraform State
resource "azurerm_storage_container" "tfstate_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate_storage.name
  container_access_type = "private"
}

# Azure Storage Backend Configuration
terraform {
  backend "azurerm" {
    resource_group_name   = azurerm_resource_group.terraform_backend_rg.name
    storage_account_name  = azurerm_storage_account.tfstate_storage.name
    container_name        = azurerm_storage_container.tfstate_container.name
    key                    = "dev.terraform.tfstate"
  }
}

# Azure Resource Group for App Service (Dev and Staging)
resource "azurerm_resource_group" "dev_rg" {
  name     = "my-resource-group-dev"
  location = "East US"
}

resource "azurerm_resource_group" "staging_rg" {
  name     = "my-resource-group-staging"
  location = "East US"
}

# App Service Plan for Dev and Staging
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "my-app-service-plan"
  location            = azurerm_resource_group.dev_rg.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Dev Web App
resource "azurerm_web_app" "dev_web_app" {
  name                = "demo-app-faruk-dev-001"
  location            = azurerm_resource_group.dev_rg.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "SOME_APP_SETTING" = "value"
  }
}

# Staging Web App
resource "azurerm_web_app" "staging_web_app" {
  name                = "webapp-faruk-staging-001"
  location            = azurerm_resource_group.staging_rg.location
  resource_group_name = azurerm_resource_group.staging_rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "SOME_APP_SETTING" = "value"
  }
}

output "dev_web_app_url" {
  value = azurerm_web_app.dev_web_app.default_site_hostname
}

output "staging_web_app_url" {
  value = azurerm_web_app.staging_web_app.default_site_hostname
}

