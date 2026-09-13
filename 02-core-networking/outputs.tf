# outputs.tf
# TODO: Output:
# - VNet name
# - VNet ID
# - subnet IDs as a map keyed by subnet name
# - NSG IDs as a map keyed by subnet name
# - route table ID
# - NAT Gateway ID if enabled

output "vnet" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_id" {
  value = {
    for name, subnet in azurerm_subnet.this :
    name => subnet.id
  }
}

output "nsgs" {
  value = {
    for key, resource in azurerm_network_security_group.this :
    key => resource.id
  }
}

output "route" {
  value = azurerm_route_table.this.id
}

output "nat_gateway_id" {
  value = var.enable_nat_gateway ? azurerm_nat_gateway.this[0].id : null
}