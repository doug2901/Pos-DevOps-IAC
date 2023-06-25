terraform {
  backend "azurerm" {
    resource_group_name  = "RG-Storage"
    storage_account_name = "dnfcorpterraform"
    container_name       = "tfstate"
    key                  = "study.terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.18.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}