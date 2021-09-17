
module "sql-server" {
  source  = "./module/sql-server"


  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  resource_group_name   = var.resourcegroup
  location              = var.azure_region
  virtual_network_name  = var.vnetwork_name
  private_subnet_address_prefix = ["10.1.5.0/29"]
  # SQL Server and Database details
  # The valid service objective name for the database include S0, S1, S2, S3, P1, P2, P4, P6, P11 
  sqlserver_name               = var.sqlserver
  database_name                = var.databasename
  sql_database_edition         = var.databaseedition
  sqldb_service_objective_name = var.sql_service_objective_name

  # SQL server extended auditing policy defaults to `true`. 
  # To turn off set enable_sql_server_extended_auditing_policy to `false`  
  # DB extended auditing policy defaults to `false`. 
  # to tun on set the variable `enable_database_extended_auditing_policy` to `true` 
  # To enable Azure Defender for database set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = var.enable_threat_detection_policy
  log_retention_days             = var.log_retention_days

  # schedule scan notifications to the subscription administrators
  # Manage Vulnerability Assessment set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = var.enable_vulnerability_assessment
  email_addresses_for_alerts      = var.email_addresses_for_alerts

   # Sql failover group creation. required secondary locaiton input. 
  enable_failover_group         = var.enable_failover_group
  secondary_sql_server_location = var.secondary_sql_server_location

   # enabling the Private Endpoints for Sql servers
  enable_private_endpoint = var.enable_private_endpoint

  # AD administrator for an Azure SQL server
  # Allows you to set a user or group as the AD administrator for an Azure SQL server
  ad_admin_login_name = var.ad_admin_login_name

  # (Optional) To enable Azure Monitoring for Azure SQL database including audit logs
  # log analytic workspace name required
  enable_log_monitoring        = var.enable_log_monitoring
  log_analytics_workspace_name = var.log_analytics_workspace_name

  # Firewall Rules to allow azure and external clients and specific Ip address/ranges. 
  enable_firewall_rules = var.enable_firewall_rules
  firewall_rules = var.firewall_rules 

  # Create and initialize a database with custom SQL script
  # need sqlcmd utility to run this command
  # your desktop public IP must be added firewall rules to run this command 
  initialize_sql_script_execution = var.initialize_sql_script_execution
  sqldb_init_script_file          = "../artifacts/initial_setup_db.sql"

  # Tags for Azure Resources
  tags = {
    Organisation= var.name
    environment = var.environment
    application = "SQLServer"
    owner       = "DevOps"
  }
}
