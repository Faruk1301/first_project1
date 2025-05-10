provider "azurerm" {
  features = {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-app-service-plan"
  location            = "West US"
  resource_group_name = "example-resource-group"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "dev" {
  name                    = "example-dev-webapp"
  location                = azurerm_app_service_plan.example.location
  resource_group_name     = azurerm_app_service_plan.example.resource_group_name
  app_service_plan_id     = azurerm_app_service_plan.example.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
  }
}

resource "azurerm_app_service" "staging" {
  name                    = "example-staging-webapp"
  location                = azurerm_app_service_plan.example.location
  resource_group_name     = azurerm_app_service_plan.example.resource_group_name
  app_service_plan_id     = azurerm_app_service_plan.example.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
  }
}

# Variable declarations
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
}

