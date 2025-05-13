provider "azurerm" {
  features = {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan
resource "azurerm_app_service_plan" "main" {
  name                = "example-app-service-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Dev Web App
resource "azurerm_app_service" "dev" {
  name                    = var.dev_app_name
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  app_service_plan_id     = azurerm_app_service_plan.main.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
  }
}

# Staging Web App
resource "azurerm_app_service" "staging" {
  name                    = var.staging_app_name
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  app_service_plan_id     = azurerm_app_service_plan.main.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
  }
}

# Variables
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

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "example-resource-group"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West US"
}

variable "dev_app_name" {
  description = "Name of the Dev App Service"
  type        = string
  default     = "example-dev-webapp"
}

variable "staging_app_name" {
  description = "Name of the Staging App Service"
  type        = string
  default     = "example-staging-webapp"
}

# Outputs for Web App URLs
output "dev_webapp_url" {
  value = "https://${azurerm_app_service.dev.default_site_hostname}"
  description = "URL for the Dev environment web app"
}

output "staging_webapp_url" {
  value = "https://${azurerm_app_service.staging.default_site_hostname}"
  description = "URL for the Staging environment web app"
}

