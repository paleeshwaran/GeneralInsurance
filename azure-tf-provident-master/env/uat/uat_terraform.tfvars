#----------------------------------------------------------------
#----------------------- DEV ------------------------------
#----------------------------------------------------------------

#---------------------------------------------------------------
# Provider
#---------------------------------------------------------------
azure_region             = "australiaeast"
name                     = "Provident_Insurance"
environment              = "uat"
vnetwork_name            = "vnet-azure-australiaeast-001"
resourcegroup            = "pi-warehouse-uat-rg"



#-----------------------------------------------------------------
#    SQL Server
#-----------------------------------------------------------------
enable_private_endpoint        = false
enable_failover_group          = false 
secondary_sql_server_location  = "australiacentral"
sqlserver                      = "pi-sqldb-uat-server01"
databasename                   = ["pi-dwh","source"]
databaseedition                = "Standard"
sql_service_objective_name     = "S3"
email_addresses_for_alerts     = ["arun@nesttechnology.com", "aaron@nesttechnology.co.nz"]
ad_admin_login_name            = "ntsadmin@providentinsurance.co.nz"
log_analytics_workspace_name   = "loganalytics-Ae-shared"
firewall_rules                 = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "Arun-ip"
      start_ip_address = "151.210.145.0"
      end_ip_address   = "151.210.145.99"
    },
    {
      name             = "NestOffice"
      start_ip_address = "202.137.244.10"
      end_ip_address   = "202.137.244.10"
    },
    {
      name             = "NestTechnology"
      start_ip_address = "219.88.101.25"
      end_ip_address   = "219.88.101.25"
    },
    {
      name             = "ProvidentOffice"
      start_ip_address = "192.168.20.71"
      end_ip_address   = "192.168.20.71"
    },
    {
      name             = "SiteHost"
      start_ip_address = "223.165.79.30"
      end_ip_address   = "223.165.79.30"
    }
  ]

#---------------------------------------------------------------------------------------------------------------------------------------------
#                                                Data Factory 
#---------------------------------------------------------------------------------------------------------------------------------------------

data_factory_name    = "pi-warehouse-uat-df"
create_data_factory  = true
managed_virtual_network_enabled = true
df_kv_secret_name    = "sql-server-pi-dwh-uat"
#---------------------------------------------------------------------------------------------------------------------------------------------
#                                                Key Vault 
#---------------------------------------------------------------------------------------------------------------------------------------------

key_vault_name    = "piwarehouseuatkeyvault"
key_vault_sku_pricing_tier = "premium"
default_ad_user_principal_name_key_vault =["arun_nesttechnology.co.nz#EXT#@providentinsurance.co.nz", "aaron_nesttechnology.co.nz#EXT#@providentinsurancenz.onmicrosoft.com"]

#---------------------------------------------------------------------------------------------------------------------------------------------
#                                                storage 
#---------------------------------------------------------------------------------------------------------------------------------------------

storage_name = "pistorageuat"

containers_list = [
    { name = "xero-source-data", access_type = "blob" },
  ]

lifecycles = [
    {
      prefix_match               = ["xero-source-data/accounts"]
      tier_to_cool_after_days    = 5
      tier_to_archive_after_days = 10
      delete_after_days          = 365
      snapshot_delete_after_days = 30
    }
  ]