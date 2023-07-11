terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
     azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.36.0"
    }

   azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
  }

   backend "azurerm" {
    resource_group_name  = "rg-tf-esus"
  }
  
}


/*module "openai" {
source  = "Azure/openai/azurerm"
version = "0.1.1"
#insert the 2 required variables here
} */

provider "azurerm" {
  features {}

  subscription_id   = "${var.ARM_SUBSCRIPTION_ID}"
  tenant_id         = "${var.ARM_TENANT_ID}"
  client_id         = "${var.ARM_CLIENT_ID}"
  client_secret     = "${var.ARM_CLIENT_SECRET}" 
}

provider "azuread" {
  tenant_id = "${var.ARM_TENANT_ID}"
}

provider "azapi" {
  
}

