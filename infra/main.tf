terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Conditionally create resource group for dev or staging stage
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group && (var.environment == "dev" || var.environment == "staging") ? 1 : 0
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Use existing resource group if already created
data "azurerm_resource_group" "rg" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# Dynamically select resource group name and location
locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
}

# App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.environment}-asp"
  location            = local.rg_location
  resource_group_name = local.rg_name
  os_type             = "Linux"
  sku_name            = "S1"
}

# Azure Linux Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = var.app_service_name
  location            = local.rg_location
  resource_group_name = local.rg_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "PYTHON|3.10"
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
