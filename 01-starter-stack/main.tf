# main.tf
locals {
  common_tags = {
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    project     = "azure-terraform-hands-on"
  }

  # TODO: Make this storage account name globally unique and Azure-valid.
  storage_account_name = "${var.prefix}${random_string.storage_suffix.result}"
}

resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper = false
}
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "this" {
  name                          = local.storage_account_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  https_traffic_only_enabled    = true
  public_network_access_enabled = true

  tags = local.common_tags
}

resource "azurerm_storage_container" "container" {
  name                  = "artifacts"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_log_analytics_workspace" "logw" {
  name                = "primarylog"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30

  tags = local.common_tags
}