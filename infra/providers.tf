terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }
  required_version = "~> 1.7.4"
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}
