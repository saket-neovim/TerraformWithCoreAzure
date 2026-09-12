# outputs.tf
# TODO: Output:
# - resource group name
# - storage account name
# - storage account ID
# - primary blob endpoint
# - Log Analytics workspace ID

output "rg" {
  value       = azurerm_resource_group.this.name
  description = "name of the resource group"
}

output "storage-id" {
  value       = azurerm_storage_account.this.id
  description = "ID of the storage account"
}

output "storage-name" {
  value = azurerm_storage_account.this.name
}

output "blob-endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "the blob endpoint"
}

output "logwid" {
  value       = azurerm_log_analytics_workspace.logw.id
  description = "the log analytics worskpace ID"
}
