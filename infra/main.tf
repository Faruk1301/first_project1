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

# Get existing Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Get existing App Service Plan
data "azurerm_service_plan" "existing_asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
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
}

# ------------------------------------
# Variables
# ------------------------------------

variable "resource_group_name" {
  type = string
}

variable "app_service_plan_name" {
  type = string
}

variable "app_service_name" {
  type = string
}

variable "environment" {
  type = string
}


