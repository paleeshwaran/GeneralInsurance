output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = local.location
}

output "azurerm_data_factory_object_id" {
  description = "Principal/object"
  value = azurerm_data_factory.df[0].identity[0].principal_id
}  

/*output "df_run_time_id" {
  description = "id of the run time in the df"
  value       = azurerm_data_factory_integration_runtime_self_hosted.dfir[*].id
}
*/