# Tagging

variable "name" {
  description = "Name tag"
}

variable "azure_region" {
  description = "Resource deployment region"
  default = "Australia East"
}

variable "environment" {
  default = null
}

variable "resourcegroup" {
  default = null
}

#--------------------------------  VIRTUAL PRIVATE NETWORK  -----------------------------------------------------------
variable "vnetwork_name" {
  default = null
}
#--------------------------------  SQL SERVER VARIABLES -----------------------------------------------------------
variable "enable_private_endpoint" {
  default = true
}

variable "enable_failover_group" {
  default = false
}

variable "secondary_sql_server_location" {
  default = "australiacentral"
}

variable "sqlserver" {
  default = null
}

variable "databasename" {
  description = "The name of the databases"
  type = list(string)
  default = [] 
}
variable "databaseedition" {
  default = null
}

variable "sql_service_objective_name" {
  default = null
}

variable "email_addresses_for_alerts"  {
  type = list(string)
  default = [] 
}

variable "ad_admin_login_name"  {
  default = null 
}

variable "enable_threat_detection_policy"  {
  default = true 
}

variable "log_retention_days"  {
  default = 30 
}

variable "enable_vulnerability_assessment"  {
  default = false 
}

variable "enable_log_monitoring"  {
  default = true 
}

variable "log_analytics_workspace_name"  {
  default = null 
}

variable "enable_firewall_rules"  {
  default = true 
}

variable "firewall_rules" {
  description = "Range of IP addresses to allow firewall connections."
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}


variable "initialize_sql_script_execution"  {
  default = false
}


#------------------------------------------------------- Data Factory ---------------------------------------------------------------------------------

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

#-------------------------------------------------------Key Valut ----------------------------------------------------------------------------------------
variable "key_vault_name" {
  description = "The Name of the key vault"
  default     = ""
}

variable "key_vault_sku_pricing_tier" {
  description = "The name of the SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}
variable "default_ad_user_principal_name_key_vault"  {
  type = list(string)
  default = [] 
}

#--------------------------------------------------------Storage----------------------------------------------------------------------------------------------

variable "storage_name" {
  description = "The Name of the storage account to be created"
  default     = ""
}

variable "containers_list" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, access_type = string }))
  default     = []
}

variable "lifecycles" {
  description = "Configure Azure Storage firewalls and virtual networks"
  type        = list(object({ prefix_match = set(string), tier_to_cool_after_days = number, tier_to_archive_after_days = number, delete_after_days = number, snapshot_delete_after_days = number }))
  default     = []
}