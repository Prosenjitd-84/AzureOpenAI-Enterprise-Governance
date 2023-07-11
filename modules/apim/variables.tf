variable resource_group_name {
  description = "Resource Group name"
  type        = string
}

variable resource_group_location {
  description = "Resource Group location"
  type        = string
}

variable application_insights_id {
  description = "Application Insight Resource ID"
  type        = string
}

variable eventhub_namespace_id {
  description = "Event Hub Resource ID"
  type        = string
}

variable eh_connection_string{
  description = "Event Hub Connection String"
  type        = string
}

variable app_insight_instrumentation_key{
  description = "App Insight instrumentation_key"
  type        = string

}

variable keyvault_id{
  description = "Key Vault ID"
  type        = string
}

variable "apim_sku" {
  description = "The pricing tier of this API Management service"
  default     = "Developer"
  type        = string
  validation {
    condition     = contains(["Developer", "Standard", "Premium"], var.apim_sku)
    error_message = "The sku must be one of the following: Developer, Standard, Premium."
  }
}

variable "apim_sku_count" {
  description = "The instance size of this API Management service."
  default     = 1
  type        = number
  validation {
    condition     = contains([1, 2], var.apim_sku_count)
    error_message = "The sku_count must be one of the following: 1, 2."
  }
}


variable "publisher_email" {
  default     = "prosenjitdas@microsoft.com"
  description = "The email address of the owner of the service"
  type        = string
  validation {
    condition     = length(var.publisher_email) > 0
    error_message = "The publisher_email must contain at least one character."
  }
}

variable "publisher_name" {
  default     = "publisher"
  description = "The name of the owner of the service"
  type        = string
  validation {
    condition     = length(var.publisher_name) > 0
    error_message = "The publisher_name must contain at least one character."
  }
}