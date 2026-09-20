# TODO: Output: DONE
# - resource group name
# - resource group ID
# - location
# - name prefix
# - common tags

output "rg_name" {
  value = azurerm_resource_group.this.name
}

output "rg_id" {
  value = azurerm_resource_group.this.id
}

output "location" {
  value = azurerm_resource_group.this.location
}

output "name_prefix" {
  value = local.name_prefix
}

output "common_tags" {
  value = local.common_tags
}