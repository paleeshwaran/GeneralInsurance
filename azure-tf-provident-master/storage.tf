module "storage" {
  source  = "./module/storage"

  # By default, this module will not create a resource group
  # proivde a name to use an existing resource group, specify the existing resource group name, 
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG. 
  # create_resource_group = var.create_resource_group
  resource_group_name   = var.resourcegroup
  location              = var.azure_region
  storage_account_name  = var.storage_name

  # To enable advanced threat protection set argument to `true`
  enable_advanced_threat_protection = true

  # Container lists with access_type to create
  containers_list = var.containers_list
  # Lifecycle management for storage account.
  # Must specify the value to each argument and default is `0` 
  lifecycles = var.lifecycles

  # Adding TAG's to your Azure resources (Required)
  tags = {
    Organisation= var.name
    environment = var.environment
    application = "storage"
    owner       = "DevOps"
  }
}
