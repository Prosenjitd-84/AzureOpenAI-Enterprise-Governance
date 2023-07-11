data "azurerm_client_config" "current" {}

resource "azurerm_api_management" "api" {
  //name                = "apiservice${random_string.azurerm_api_management_name.result}"
  name                = "apim-glb-${var.resource_group_location}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = "${var.apim_sku}_${var.apim_sku_count}"

  identity {
    type = "SystemAssigned"
  }
}


resource "time_sleep" "wait_30_seconds_for_apim" {
  depends_on = [azurerm_api_management.api]

  create_duration = "30s"
}


resource "azurerm_key_vault_access_policy" "APIM-MI-Secret-GET" {
  key_vault_id = var.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_api_management.api.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "time_sleep" "wait_30_seconds_for_kv_access_to_apim" {
  depends_on = [azurerm_key_vault_access_policy.APIM-MI-Secret-GET]

  create_duration = "30s"
}

resource "azurerm_api_management_named_value" "OpenAI-token-endpoint" {
  name                = "svc_token_endpoint"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "svc_token_endpoint"
  value               = join("",["https://login.microsoftonline.com/",data.azurerm_client_config.current.tenant_id,"/oauth2/v2.0/token"])
}

resource "azurerm_api_management_named_value" "OAuth-Token-Timeout" {
  name                = "svc_token_acquisition_timeout"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "svc_token_acquisition_timeout"
  value               = "30"
}

resource "azurerm_api_management_named_value" "Backend-URL" {
  name                = "svc_base_url"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "svc_base_url"
  value               = "https://openai-esus.openai.azure.com/openai"
}

resource "azurerm_api_management_named_value" "Backend2-URL" {
  name                = "svc2_base_url"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "svc2_base_url"
  value               = "https://openai-esus-2.openai.azure.com/openai"
}


resource "azurerm_api_management_named_value" "Client-Cred-OAuth-Scope" {
  name                = "scope"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "scope"
  value               = "https://cognitiveservices.azure.com/.default"
}



resource "azurerm_api_management_named_value" "OpenAI-SPN-BU1-ID" {
  name                = "OpenAI-SPN-BU1-ID"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "OpenAI-SPN-BU1-ID"
  secret              = true

  value_from_key_vault {
    secret_id = "https://kv-glb-eastus.vault.azure.net/secrets/openai-SPN-BU1-client-id"
    //identity_client_id = azurerm_api_management.api.identity[0].principal_id
  }

}

resource "azurerm_api_management_named_value" "OpenAI-SPN-BU1-Secret" {
  name                = "OpenAI-SPN-BU1-Secret"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "OpenAI-SPN-BU1-Secret"
  secret              = true

  value_from_key_vault {
    secret_id = "https://kv-glb-eastus.vault.azure.net/secrets/openai-SPN-BU1-client-secret"
    //identity_client_id = azurerm_api_management.api.identity[0].principal_id
  }
}

resource "azurerm_api_management_named_value" "OpenAI-SPN-BU2-ID" {
  name                = "OpenAI-SPN-BU2-ID"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "OpenAI-SPN-BU2-ID"
  secret              = true

  value_from_key_vault {
    secret_id = "https://kv-glb-eastus.vault.azure.net/secrets/openai-SPN-BU2-client-id"
  
  }

}

resource "azurerm_api_management_named_value" "OpenAI-SPN-BU2-Secret" {
  name                = "OpenAI-SPN-BU2-Secret"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api.name
  display_name        = "OpenAI-SPN-BU2-Secret"
  secret              = true

  value_from_key_vault {
    secret_id = "https://kv-glb-eastus.vault.azure.net/secrets/openai-SPN-BU2-client-secret"

  }
}


resource "azurerm_api_management_logger" "ehlogger" {
  name                = "EH-logger"
  api_management_name = azurerm_api_management.api.name
  resource_group_name = var.resource_group_name
  resource_id         = var.eventhub_namespace_id

  eventhub {
    name              = "OpenAIChargeBackEH"
    connection_string = var.eh_connection_string
  }
}

resource "azurerm_api_management_logger" "ailogger" {
  name                = "AI-logger"
  api_management_name = azurerm_api_management.api.name
  resource_group_name = var.resource_group_name
  resource_id         = var.application_insights_id

 application_insights {
    instrumentation_key = var.app_insight_instrumentation_key
  }
}
