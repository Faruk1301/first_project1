terraform {
  required_version = ">= 1.5.7"

  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfstatefaruk1234567"
    container_name       = "tfstate"
    key                  = "${terraform.workspace}.terraform.tfstate"
    use_azuread_auth     = true
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

# Common variables
variable "location" {
  type    = string
  default = "East US"
}

variable "app_service_plan_name" {
  type    = string
  default = "my-app-service-plan"
}

# Dev variables
variable "dev_resource_group_name" {
  type    = string
  default = "my-resource-group-dev"
}

variable "dev_app_service_name" {
  type    = string
  default = "demo-app-faruk-dev-1301"
}

# Staging variables
variable "staging_resource_group_name" {
  type    = string
  default = "my-resource-group-staging"
}

variable "staging_app_service_name" {
  type    = string
  default = "webapp-faruk-staging-001"
}

# Create Resource Group for Dev
resource "azurerm_resource_group" "dev" {
  name     = var.dev_resource_group_name
  location = var.location
}

# Create Resource Group for Staging
resource "azurerm_resource_group" "staging" {
  name     = var.staging_resource_group_name
  location = var.location
}

# Select names depending on workspace
locals {
  resource_group_name = terraform.workspace == "dev" ? azurerm_resource_group.dev.name : azurerm_resource_group.staging.name
  app_service_name    = terraform.workspace == "dev" ? var.dev_app_service_name : var.staging_app_service_name
}

# Create App Service Plan
resource "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = terraform.workspace == "dev" ? azurerm_resource_group.dev.location : azurerm_resource_group.staging.location
  resource_group_name = terraform.workspace == "dev" ? azurerm_resource_group.dev.name : azurerm_resource_group.staging.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Create Web App
resource "azurerm_linux_web_app" "webapp" {
  name                = local.app_service_name
  location            = terraform.workspace == "dev" ? azurerm_resource_group.dev.location : azurerm_resource_group.staging.location
  resource_group_name = terraform.workspace == "dev" ? azurerm_resource_group.dev.name : azurerm_resource_group.staging.name
  service_plan_id     = azurerm_app_service_plan.asp.id

    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "true"
  }
}

# Outputs
output "web_app_url" {
  value = azurerm_linux_web_app.webapp.default_hostname
}

