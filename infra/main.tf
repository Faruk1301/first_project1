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
    key                  = "dev.terraform.tfstate"
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

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.environment}-asp"
  location            = "East US"
  resource_group_name = var.resource_group_name

  sku {
    tier = "Basic"
    size = "B1"
  }

  os_type = "Linux"
}

resource "azurerm_app_service" "web_app" {
  name                = var.app_service_name
  location            = "East US"
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "PYTHON|3.10"
  }

  app_settings = {
    "WEBSITES_PORT" = "8000"
  }
}

