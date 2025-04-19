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
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Use existing resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Dynamically select resource group name and location
locals {
  rg_name     = data.azurerm_resource_group.rg.name
  rg_location = data.azurerm_resource_group.rg.location
} 
resource "azurerm_linux_web_app" "web_app" {
  name                = var.app_service_name  # Should be "demo-app-faruk-dev-001"
  location            = local.rg_location
  resource_group_name = local.rg_name
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

# Variables
variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type    = string
  default = "East US"
}

variable "create_resource_group" {
  type    = bool
  default = false
}

variable "environment" {
  type = string
}

variable "app_service_name" {
  type = string
}

