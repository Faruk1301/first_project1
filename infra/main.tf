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

# Retrieve existing Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Create App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create Azure Linux Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = var.app_service_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }
}

# ------------------------------------
# Variables
# ------------------------------------

variable "resource_group_name" {
  type        = string
  description = "The name of the Azure resource group."
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the Azure App Service Plan."
}

variable "app_service_name" {
  type        = string
  description = "The name of the Azure Linux Web App."
}

variable "environment" {
  type        = string
  description = "The environment (e.g., dev, staging)."
}

