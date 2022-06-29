terraform {
  required_version = ">= 0.14"
}

provider "azurerm" {
  version = "= 2.36.0"
  features {}
  skip_provider_registration = true
}