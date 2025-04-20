
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    # These will be set by the pipeline
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfstatefaruk1234567"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate" # Will be overridden per workspace
  }
}

provider "azurerm" {
  features {}
}

# Define environment-specific variables using a map
locals {
  environment_config = {
    dev = {
      resource_group_name    = "my-resource-group-dev"
      app_service_plan_name  = "my-app-service-plan-dev"
      app_service_name       = "demo-app-faruk-dev-001"
      location               = "East US"
    }
    staging = {
      resource_group_name    = "my-resource-group-staging"
      app_service_plan_name  = "my-app-service-plan-staging"
      app_service_name       = "webapp-faruk-staging-001"
      location               = "East US"
    }
  }

  current_config = lookup(local.environment_config, terraform.workspace, local.environment_config["dev"])
}

# Retrieve existing Resource Group
data "azurerm_resource_group" "rg" {
  name = local.current_config.resource_group_name
}

# Create App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = local.current_config.app_service_plan_name
  location            = local.current_config.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create Azure Linux Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = local.current_config.app_service_name # Matches pipeline exactly
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      python_version = "3.10" # Matches pipeline
    }
    
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }
}

output "web_app_name" {
  value = azurerm_linux_web_app.web_app.name
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.web_app.default_hostname}"
}
