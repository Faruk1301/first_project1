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

# Local Values (Instead of Variables)
locals {
  app_service_name      = "my-python-app"
  resource_group_name   = "my-resource-group"
  location             = "East US"
  service_plan_name    = "my-app-service-plan"
  sku_name             = "S1"
  environment          = "dev"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = local.service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = local.sku_name
}

# Linux Web App (App Service)
resource "azurerm_linux_web_app" "app" {
  name                = "${local.app_service_name}-${random_id.suffix.hex}"
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

