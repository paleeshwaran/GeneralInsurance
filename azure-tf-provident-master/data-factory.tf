
module "data-factory" {
  source  = "./module/data-factory"


  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  resource_group_name   = var.resourcegroup
  location              = var.azure_region
  create_data_factory   = var.create_data_factory
  data_factory_name     = var.data_factory_name
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  #df_kv_secret_name     = var.df_kv_secret_name
  #key_vault_id          ="${module.key-vault.key_vault_id}"
  # Tags for Azure Resources
  tags = {
    name        = var.name
    environment = var.environment
    application = "DataFactory"
    owner       = "DevOps"
  }
}
