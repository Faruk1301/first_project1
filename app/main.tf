variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "webapp-rg-dev" # Default value for dev
}

variable "app_service_name" {
  description = "Name of the app service"
  default     = "webapp-faruk-dev-001" # Default value for dev
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "East US"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.app_service_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "PYTHON|3.10"
    app_command_line = "bash startup.sh"
  }

  app_settings = {
    "WEBSITES_PORT" = "5000"
  }
}


