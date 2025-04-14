terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Declare variables
variable "app_service_name" {
  type        = string
  description = "Base name of the Web App"
  default     = "my-python-app"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "service_plan_name" {
  type    = string
  default = "my-app-service-plan"
}

variable "sku_name" {
  type    = string
  default = "S1"
}

variable "environment" {
  description = "Deployment environment like dev, staging, prod"
  type        = string
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

# Linux Web App (App Service)
resource "azurerm_linux_web_app" "app" {
  name                = "${var.app_service_name}-${random_id.suffix.hex}"
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
