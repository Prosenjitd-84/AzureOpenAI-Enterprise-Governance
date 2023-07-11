
data "azurerm_client_config" "current" {}

/*
data "azuread_user" "user"{
user_principal_name = "xxxx@microsoft.com"
}
*/

locals {
  current_user_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}


module "openai" {
  source = "./modules/openai"
  resource_group_location = var.resource_group_location

}

module "apim" {
  source = "./modules/apim"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = var.resource_group_location
  eventhub_namespace_id = azurerm_eventhub_namespace.openaiehns.id
  application_insights_id = azurerm_application_insights.glbAI.id
  eh_connection_string = azurerm_eventhub_namespace_authorization_rule.APIMLoggerPolicy.primary_connection_string
  app_insight_instrumentation_key = azurerm_application_insights.glbAI.instrumentation_key
  keyvault_id = azurerm_key_vault.vault.id
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name_prefix}-glb-${var.resource_group_location}"
  location = var.resource_group_location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "la-glb-${azurerm_resource_group.rg.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}



resource "azurerm_key_vault" "vault" {
  name                       = coalesce("kv-glb-${azurerm_resource_group.rg.location}")
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.kv_sku_name
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.current_user_id

    key_permissions    = var.key_permissions
    secret_permissions = var.secret_permissions
  }
}

/*
resource "azurerm_key_vault_access_policy" "SecretGetListSet" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  object_id = "${data.azuread_user.user.object_id}"

   secret_permissions = [
    "Get",
    "List",
    "Set"
  ]

}
*/

resource "random_string" "azurerm_key_vault_key_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "random_integer" "sequence" {
  min = 1
  max = 3
  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    instance = "${timestamp()}"
  }
}

resource "azurerm_key_vault_secret" "openai-SPN-BU1-client-id" {
  name         = "openai-SPN-BU1-client-id"
  value        = ""
  key_vault_id = azurerm_key_vault.vault.id

   lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "openai-SPN-BU1-client-secret" {
  name         = "openai-SPN-BU1-client-secret"
  value        = ""
  key_vault_id = azurerm_key_vault.vault.id

   lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "openai-SPN-BU2-client-id" {
  name         = "openai-SPN-BU2-client-id"
  value        = ""
  key_vault_id = azurerm_key_vault.vault.id

   lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "openai-SPN-BU2-client-secret" {
  name         = "openai-SPN-BU2-client-secret"
  value        = ""
  key_vault_id = azurerm_key_vault.vault.id

   lifecycle {
    ignore_changes = [value]
  }
}


resource "time_sleep" "wait_30_seconds_for_kv" {
  depends_on = [azurerm_key_vault.vault]

  create_duration = "30s"
}


/*
# Create an Azure OpenAI Services resource
resource "azurerm_openai" "openai" {
name = "pd-openai-${azurerm_resource_group.rg.location}-${random_integer.sequence.result}}"
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.location
sku = "standard"
workspace_name = "openai-demo-workspace"

custom_settings = <<SETTINGS
{
"model": "text-davinci-002",
"temperature": 0.5
}
SETTINGS
} */

resource "azurerm_application_insights" "glbAI" {
  name                = "appinsights-glb-${azurerm_resource_group.rg.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
}


resource "azurerm_eventhub_namespace" "openaiehns" {
  name                = "OpenAIChargeBackEHNamespace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Development"
  }
}

resource "azurerm_eventhub" "openaieh" {
  name                = "OpenAIChargeBackEH"
  namespace_name      = azurerm_eventhub_namespace.openaiehns.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_eventhub_namespace_authorization_rule" "APIMLoggerPolicy" {
  name                = "APIMLoggerPolicy"
  namespace_name      = azurerm_eventhub_namespace.openaiehns.name
  resource_group_name = azurerm_resource_group.rg.name

  listen = true
  send   = true
  manage = false
}

resource "azurerm_container_registry" "acr" {
  name                          = "aksdemoacrpd"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                           = "Basic"
  public_network_access_enabled = true
  admin_enabled                 = true
}


/*
resource "azuread_application" "OpenAI-SPN-BU1" {
  display_name = "OpenAI-SPN-BU1"
  oauth2_permissions = [
    {
        is_enabled = true
        type       = "Admin"
        value      = "cognitiveservices.azure.com"
    },
 ]
}

resource "azuread_service_principal" "OpenAI-SPN-BU1" {
  application_id = "${azuread_application.OpenAI-SPN-BU1.application_id}"
}

resource "azuread_service_principal_password" "OpenAI-SPN-BU1" {
  service_principal_id = "${azuread_service_principal.OpenAI-SPN-BU1.id}"
  end_date             = "2024-01-01T01:02:03Z" 

   lifecycle {
    ignore_changes = [value, end_date]
  }
}
*/
