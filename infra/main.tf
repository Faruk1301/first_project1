
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

# Define environment-specific variables using a map
locals {
  environment_config = {
    dev = {
      resource_group_name   = "my-resource-group-dev"
      app_service_plan_name = "my-app-service-plan-dev"
      location              = "East US"
    }
    staging = {
      resource_group_name   = "my-resource-group-staging"
      app_service_plan_name = "my-app-service-plan-staging"
      location              = "East US"
    }
  }

  current_config = lookup(local.environment_config, terraform.workspace, local.environment_config["dev"])
}

# Retrieve existing Resource Group
data "azurerm_resource_group" "rg" {
  name = local.current_config.resource_group_name
}

# Create or reference App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = local.current_config.app_service_plan_name
  location            = local.current_config.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create Azure Linux Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = "${terraform.workspace}-webapp"
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
