resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_targets
  name = "${each.key}"
  target_resource_id = "${each.value}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

 metric {
    category = "AllMetrics"
    enabled  = true
  }
}


# TODO: Add diagnostic settings only for resource types you verify support
# the chosen log and metric categories.

