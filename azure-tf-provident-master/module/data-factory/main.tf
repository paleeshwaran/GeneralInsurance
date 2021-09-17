locals {
  resource_group_name                = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location                           = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

resource "azurerm_data_factory" "df" {
  count               = var.create_data_factory == true ? 1 : 0
  name                = var.data_factory_name 
  location            = var.location
  resource_group_name = local.resource_group_name
  identity {
    type = "SystemAssigned"
  }
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
}

/*
resource "azurerm_data_factory_integration_runtime_self_hosted" "dfir" {
  name                = format("run-time-%s",var.data_factory_name )
  data_factory_name   = var.data_factory_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_data_factory_linked_service_key_vault" "linkedkeyvault" {
  name                = format("linked-key-vault-%s",var.data_factory_name )
  resource_group_name = local.resource_group_name
  data_factory_name   = var.data_factory_name
  key_vault_id        = var.key_vault_id
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "linkedsqldb" {
  name                = format("linked-sql-database-%s",var.data_factory_name )
  resource_group_name = local.resource_group_name
  data_factory_name   = var.data_factory_name
  connection_string = "Integrated Security=False;Data Source=test;Initial Catalog=pi_dwh;User ID=sqladmin;"
  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.linkedkeyvault.name
    secret_name         = var.df_kv_secret_name
  }
 } */ 