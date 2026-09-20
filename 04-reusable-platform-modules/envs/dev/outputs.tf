# TODO: Output:
# - resource group name
# - VNet name
# - subnet IDs
# - NSG IDs
# - Log Analytics workspace ID if diagnostics are enabled

output "rg_name" {
  value = module.foundation.rg_name
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "nsg_ids" {
  value = module.network.nsg_ids
}

output "law_id" {
  value = var.enable_diagnostics ? module.diagnostics[0].law_id : null
}

output "VNet_id" {
  value = module.network.vnet_id
}