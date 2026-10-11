# TODO: Add operational outputs with descriptions:
# - resource_group_name
# - vm_name and vm_id
# - nic_name
# - public_ip_address and private_ip_address
# - vnet_name, subnet_id, and nsg_name
# - managed_identity_client_id and managed_identity_principal_id
# - key_vault_name and key_vault_uri
# - log_analytics_workspace_id (Azure resource ID)
# - log_analytics_workspace_customer_id (workspace GUID for CLI queries)
# - ssh_command and ssh_tunnel_command (no private key contents)
# - local_app_url: http://127.0.0.1:8080
#
# Do not output tokens or secret values.

output "resource_group_name" {
  description = "Lab 6 resource group name."
  value       = azurerm_resource_group.app.name
}

output "vm_name" {
  description = "Linux VM name."
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_id" {
  description = "Linux VM Azure resource ID."
  value       = azurerm_linux_virtual_machine.vm.id
}

output "nic_name" {
  description = "VM network interface name."
  value       = azurerm_network_interface.nic.name
}

output "public_ip_address" {
  description = "Public IPv4 address for SSH access."
  value       = azurerm_public_ip.static.ip_address
}

output "private_ip_address" {
  description = "VM network interface private IP address."
  value       = azurerm_network_interface.nic.private_ip_address
}

output "vnet_name" {
  description = "Lab 6 virtual network name."
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  description = "Application subnet Azure resource ID."
  value       = azurerm_subnet.snet.id
}

output "nsg_name" {
  description = "Application subnet network security group name."
  value       = azurerm_network_security_group.nsg.name
}

output "managed_identity_client_id" {
  description = "Existing Lab 5 identity client ID for runtime identity selection."
  value       = data.azurerm_user_assigned_identity.app.client_id
}

output "managed_identity_principal_id" {
  description = "Existing Lab 5 identity principal ID for RBAC checks."
  value       = data.azurerm_user_assigned_identity.app.principal_id
}

output "key_vault_name" {
  description = "Existing Lab 5 Key Vault name."
  value       = data.azurerm_key_vault.app.name
}

output "key_vault_uri" {
  description = "Existing Lab 5 Key Vault HTTPS URI."
  value       = data.azurerm_key_vault.app.vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace Azure resource ID."
  value       = azurerm_log_analytics_workspace.law.id
}

output "log_analytics_workspace_customer_id" {
  description = "Log Analytics workspace GUID for Azure CLI queries."
  value       = azurerm_log_analytics_workspace.law.workspace_id
}

output "ssh_command" {
  description = "SSH command; replace <private-key-path> with the matching private key path."
  value       = "ssh -i '~/' ${var.admin_username}@${azurerm_public_ip.static.ip_address}"
}

output "ssh_tunnel_command" {
  description = "SSH tunnel command; replace <private-key-path> and keep the session running."
  value       = "ssh -i '~/.ssh/id_ed25519' -o ExitOnForwardFailure=yes -N -L 127.0.0.1:8080:127.0.0.1:8080 ${var.admin_username}@${azurerm_public_ip.static.ip_address}"
}

output "local_app_url" {
  description = "Application URL while the SSH tunnel is running."
  value       = "http://127.0.0.1:8080"
}
