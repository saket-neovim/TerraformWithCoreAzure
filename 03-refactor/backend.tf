terraform {
  backend "azurerm" {
    resource_group_name  = "tfaz02-tfstate"
    storage_account_name = "tfstateqk1"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }
}