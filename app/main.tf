provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "webapp-rg"
  location = "East US"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "webapp-plan"
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
  name                = "webapp-faruk-001"
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

