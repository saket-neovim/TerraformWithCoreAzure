# TODO: Output:
# - Log Analytics workspace name
# - Log Analytics workspace ID
# - diagnostic setting IDs keyed by target name, if implemented

output "law_name" {
  value = azurerm_log_analytics_workspace.this.name
}

output "law_id" {
  value = azurerm_log_analytics_workspace.this.id
}