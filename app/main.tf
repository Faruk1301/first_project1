# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "my-resource-group"
}

variable "location" {
  description = "Azure region"
  default     = "East US"
}

variable "app_service_name" {
  description = "Name of the App Service"
  default     = "my-python-app-service"
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  default     = "my-app-service-plan"
}

variable "sku_name" {
  description = "SKU for the App Service Plan"
  default     = "S1"
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create App Service Plan
resource "azurerm_app_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true  # Required for Linux plans

  sku {
    tier = "Standard"
    size = var.sku_name
  }
}

# Create App Service
resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "PYTHON|3.10"
    always_on        = "true"
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }

  identity {
    type = "SystemAssigned"
  }
}
