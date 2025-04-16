terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-backend-rg"
    storage_account_name  = "tfstatefaruk1234567"
    container_name        = "tfstate"
    key                   = "dev.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Declare variables
variable "app_service_name" {
  type        = string
  description = "Base name of the Web App"
  default     = "my-python-app"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "service_plan_name" {
  type    = string
  default = "my-app-service-plan"
}

variable "sku_name" {
  type    = string
  default = "S1"
}

variable "environment" {
  description = "Deployment environment like dev, staging, prod"
  type        = string
}

# Azure credentials
variable "client_id" {
  description = "The client ID for the Azure Active Directory application"
  type        = string
}

variable "client_secret" {
  description = "The client secret for the Azure Active Directory application"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The tenant ID for the Azure Active Directory"
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID for the Azure account"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

# Resource Group (Ensure it exists)
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.sku_name
}

# Linux Web App (App Service)
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
    always_on = true
  }

  app_settings = {
    WEBSITES_PORT = "8000"
  }

  identity {
    type = "SystemAssigned"
  }
}

