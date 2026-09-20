# TODO: Output: DONE
# - VNet name
# - VNet ID
# - subnet IDs as a map keyed by subnet name
# - NSG IDs as a map keyed by subnet name

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = {
    for key,resource in azurerm_subnet.this :
    key => resource.id
  }
}

output "nsg_ids" {
  value = {
    for key,resource in azurerm_network_security_group.this :
    key => resource.id
  }
}