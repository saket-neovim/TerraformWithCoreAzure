output "rg-name" {
  value = azurerm_resource_group.tfstate.id
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.id
}

output "azurerm_storage_container" {
  value = azurerm_storage_container.this.id
}

