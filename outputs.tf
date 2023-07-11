output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

/*output "api_management_service_name" {
  value = azurerm_api_management.api.name
} */

output "azurerm_key_vault_name" {
  value = azurerm_key_vault.vault.name
}

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.vault.id
}

output "current_user_id" {
  value = local.current_user_id
}

output "instrumentation_key" {
  value = azurerm_application_insights.glbAI.instrumentation_key

  sensitive = true
}

output "azurerm_storage_account_name" {
  value = module.aks.azurerm_storage_account_name
}

output "azurerm_storage_account_access_key" {
  value = module.aks.azurerm_storage_account_access_key
  sensitive = true
}

/*
# Output the endpoint and API key for the Azure OpenAI Services resource
output "openai_endpoint" {
value = azurerm_openai.model.endpoint
}

output "openai_api_key" {
value = azurerm_openai.model.api_key
}
*/