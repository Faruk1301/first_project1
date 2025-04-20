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

# Get existing Resource Group (terraform-backend-rg)
data "azurerm_resource_group" "rg" {
  name = "terraform-backend-rg"  # Fixed to the specified resource group name
}

# Get existing App Service Plan
data "azurerm_service_plan" "existing_asp" {
  name                = var.app_service_plan_name
  resource_group_name = data.azurerm_resource_group.rg.name  # Referencing the resource group dynamically
}

# Azure Linux Web App (Combined for Dev and Staging)
resource "azurerm_linux_web_app" "web_app" {
  name                = var.app_service_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = data.azurerm_service_plan.existing_asp.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }

  tags = {
    "Environment" = var.environment
  }
}

# ------------------------------------
# Variables
# ------------------------------------

variable "app_service_plan_name" {
  description = "The name of the Azure App Service Plan"
  type        = string
}

variable "app_service_name" {
  description = "The name of the Azure Web App"
  type        = string
}

variable "environment" {
  description = "The environment in which the app is deployed (e.g., dev, staging, prod)"
  type        = string
}
