# Configure Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables
variable "app_service_name" {
  type        = string
  description = "Name of the Web App"
}

variable "resource_group_name" {
  type        = string
  default     = "my-resource-group"
}

variable "location" {
  type        = string
  default     = "East US"
}

variable "service_plan_name" {
  type        = string
  default     = "my-app-service-plan"
}

variable "sku_name" {
  type        = string
  default     = "S1"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.sku_name
}

# Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
    always_on = true
  }

  app_settings = {
    WEBSITES_PORT = "8000"
  }

  identity {
    type = "SystemAssigned"
  }
}
