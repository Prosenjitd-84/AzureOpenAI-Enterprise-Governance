resource "azurerm_resource_group" "openai-rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}-openai-${var.resource_group_location}"
}



locals {
  account_name          = coalesce(var.account_name, "azure-openai-01")

}

resource "azurerm_cognitive_account" "this" {
  kind                               = "OpenAI"
  location                           = var.location
  name                               = local.account_name
  resource_group_name                = "${var.resource_group_name_prefix}-openai-${var.resource_group_location}"
  sku_name                           = var.sku_name
  dynamic_throttling_enabled         = var.dynamic_throttling_enabled
  local_auth_enabled                 = var.local_auth_enabled
  outbound_network_access_restricted = var.outbound_network_access_restricted
  public_network_access_enabled      = var.public_network_access_enabled
  

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  
  
  dynamic "storage" {
    for_each = var.storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = storage.value.identity_client_id
    }
}
}



resource "azurerm_cognitive_deployment" "this" {
  for_each = var.deployment

  cognitive_account_id = azurerm_cognitive_account.this.id
  name                 = each.value.name
  rai_policy_name      = each.value.rai_policy_name

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  scale {
    type = each.value.scale_type
  }
}