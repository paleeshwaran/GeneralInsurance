module "key-vault" {
  source  ="./module/key-vault"

  # Resource Group and Key Vault pricing tier details
  resource_group_name        = var.resourcegroup
  key_vault_name             = var.key_vault_name
  key_vault_sku_pricing_tier = var.key_vault_sku_pricing_tier

  # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted 
  # The default retention period is 90 days, possible values are from 7 to 90 days
  # use `soft_delete_retention_days` to set the retention period
  enable_purge_protection = false

  # Adding Key vault logs to Azure monitoring and Log Analytics space
  # to enable key-vault logs, either one of log_analytics_workspace_id or storage_account_id required
  #log_analytics_workspace_id = ["${module.sql-server.log_analytics_workspace_id}"]
  storage_account_id         = ["${module.sql-server.storage_account_id}"]

  # Access policies for users, you can provide list of Azure AD users and set permissions.
  # Make sure to use list of user principal names of Azure AD users.
  access_policies = [
    {
      azure_ad_user_principal_names = var.default_ad_user_principal_name_key_vault
      key_permissions               = ["get", "list"]
      secret_permissions            = ["get", "list"]
      certificate_permissions       = ["get", "import", "list"]
      storage_permissions           = ["backup", "get", "list", "recover"]
    },

  /* # Access policies for AD Groups, enable this feature to provide list of Azure AD groups and set permissions.
    {
      azure_ad_group_names = ["ADGroupName1", "ADGroupName2"]
      secret_permissions   = ["get", "list", "set"]
    },
    */
  ]

  ## adding basic sql admin secret to the vault 
  
     df_kv_secret_name = var.df_kv_secret_name
     df_kv_secret_value =  "${module.sql-server.sql_server_admin_password}"
  

  ## Access policy to add data factory
     df_id = "${module.data-factory.azurerm_data_factory_object_id}"
  # Adding TAG's to your Azure resources (Required)
  # Tags for Azure Resources
  tags = {
    name        = var.name
    environment = var.environment
    application = "KeyVault"
    owner       = "DevOps"
  }
}