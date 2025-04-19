terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfstatefaruk1234567"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"  # Change this in pipeline for staging
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# ✅ Conditionally create resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.resource_group_location
}

# ✅ Use existing resource group if already created
data "azurerm_resource_group" "rg" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# ✅ Local values to dynamically choose resource group name and location
locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
}

# ✅ App Service Plan using local values
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.environment}-asp"
  location            = local.rg_location
  resource_group_name = local.rg_name
  os_type             = "Linux"
  sku_name            = "S1"
}

# ✅ App Service using local values
resource "azurerm_app_service" "web_app" {
  name                = var.app_service_name
  location            = local.rg_location
  resource_group_name = local.rg_name
  app_service_plan_id = azurerm_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "PYTHON|3.10"
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }
}

# ✅ Variable Declarations
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group (existing or new)"
  type        = string
}

variable "resource_group_location" {
  description = "Azure location to use if resource group is created"
  type        = string
  default     = "East US"
}

variable "create_resource_group" {
  description = "Whether to create the resource group (true = create, false = use existing)"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging)"
  type        = string
}

variable "app_service_name" {
  description = "Name of the Azure App Service"
  type        = string
}
