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
    key                  = "dev.terraform.tfstate" # <-- change to staging.terraform.tfstate for staging
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {}
variable "environment" {}
variable "app_service_name" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# ✅ Automatically create the resource group (if doesn't exist)
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.environment}-asp"
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_app_service" "web_app" {
  name                = var.app_service_name
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "PYTHON|3.10"
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }
}
