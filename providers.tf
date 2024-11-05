terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }



}


provider "azurerm" {
  subscription_id = "9cd9e400-b26d-4564-b7c0-490822643944"
  features {}
}