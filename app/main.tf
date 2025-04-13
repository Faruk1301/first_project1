resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "PYTHON|3.10"
    # app_command_line = "bash startup.sh"  <-- REMOVE THIS LINE
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }
}


