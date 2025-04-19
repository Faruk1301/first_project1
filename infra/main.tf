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
    key                  = "${var.environment}.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Conditionally create resource group for staging only
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group && var.environment == "staging" ? 1 : 0
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Use existing resource group for dev or when not creating new
data "azurerm_resource_group" "rg" {
  count = var.create_resource_group && var.environment == "staging" ? 0 : 1
  name  = var.resource_group_name
}

# Dynamically select resource group name and location
locals {
  rg_name     = var.create_resource_group && var.environment == "staging" ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  rg_location = var.create_resource_group && var.environment == "staging" ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
}

# App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.environment}-asp"
  location            = local.rg_location
  resource_group_name = local.rg_name
  os_type             = "Linux"
  sku_name            = "S1"
}

# Linux Web App with application_stack
resource "azurerm_linux_web_app" "web_app" {
  name                = var.app_service_name
  location            = local.rg_location
  resource_group_name = local.rg_name
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

# Variables
variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type    = string
  default = "East US"
}

variable "create_resource_group" {
  type    = bool
  default = false
}

variable "environment" {
  type = string
}

variable "app_service_name" {
  type = string
}
