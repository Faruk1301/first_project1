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

# Create modern App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.sku_name
}

# Create Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
    always_on = true
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Outputs
output "app_service_name" {
  value = azurerm_linux_web_app.app.name
}
