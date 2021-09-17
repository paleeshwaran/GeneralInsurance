variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create_data_factory" {
  description = "Whether to create df and use it for all resources"
  default     = false
}

variable "data_factory_name" {
  description = "A DF that holds related resources for an Azure solution"
  default     = ""
}

variable "managed_virtual_network_enabled" {
  description = "A DF that holds related resources for an Azure solution"
  default     = false
}

variable "df_kv_secret_name" {
  description = "A key vault secret that holds related token for an Azure solution"
  default     = ""
}

variable "key_vault_id" {
  description = "A key vault id in Azure solution"
  default     = ""
}