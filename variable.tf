variable "resource_group_name" {

type = string
description = "Resource group name in Azure"

}

variable "resourse_group_location" {

type = string
description = "Location of the resource group in Azure"

}

variable "app_service_plan_name" {

type = string
description = "Name of the App Service Plan in Azure"

}

variable "app_service_name" {

type = string
description = "Name of the App Service in Azure"

}

variable "sql_server_name" {

type = string
description = "Name of the SQL Server in Azure"

}

variable "sql_database_name" {

type = string
description = "Name of the SQL Database in Azure"

}

variable "sql_admin_login" {

type = string
description = "Login for the SQL Server administrator"

}

variable "sql_admin_password" {

type = string
description = "Password for the SQL Server administrator"

}

variable "firewall_rule_name" {

type = string
description = "Name of the firewall rule in Azure"

}

variable "repo_URL" {

type = string
description = "URL of the repository"

}