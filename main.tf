terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random число за уникалност
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Resource Group
resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = var.resourse_group_location
}

# Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# SQL Server
resource "azurerm_mssql_server" "asqlserver" {
  name                         = substr("${lower(var.sql_server_name)}-${random_integer.ri.result}", 0, 63)
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

# Firewall Rule
resource "azurerm_mssql_firewall_rule" "fw" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.asqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Database
resource "azurerm_mssql_database" "db" {
  name                 = var.sql_database_name
  server_id            = azurerm_mssql_server.asqlserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  sku_name             = "S0"
  zone_redundant       = false
  storage_account_type = "Local"
}

# Web App
resource "azurerm_linux_web_app" "webapp" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location

  service_plan_id = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.asqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};User ID=${azurerm_mssql_server.asqlserver.administrator_login};Password=${azurerm_mssql_server.asqlserver.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
}

# GitHub deployment
resource "azurerm_app_service_source_control" "github" {
  app_id   = azurerm_linux_web_app.webapp.id
  repo_url = var.repo_URL
  branch   = "main"
}
