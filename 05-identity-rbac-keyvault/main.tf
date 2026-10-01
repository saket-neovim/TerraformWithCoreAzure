data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  name_prefix = "${var.prefix}-${var.environment}"

  common_tags = {
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    project     = "azure-terraform-hands-on"
  }

  # TODO: Make these names Azure-valid and globally unique where required.
  storage_account_name = replace("${var.prefix}${var.environment}${random_string.suffix.result}", "-", "")
  key_vault_name       = "${var.prefix}-${var.environment}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name_prefix}-identity-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "app-mi"
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

resource "azurerm_storage_account" "this" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  tags = local.common_tags
}

resource "azurerm_storage_container" "this" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_key_vault" "this" {
  name                       = "${local.key_vault_name}kv"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  enable_rbac_authorization  = true
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  tags = local.common_tags
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "this" {
  name         = "app-config"
  value        = var.lab_secret_value
  key_vault_id = azurerm_key_vault.this.id
  depends_on = [
    azurerm_role_assignment.this
  ]
}

resource "azurerm_role_assignment" "Key_Vault_role" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "storage_data_role" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_log_analytics_workspace" "law" {
  count               = var.enable_diagnostics ? 1 : 0
  name                = "${local.name_prefix}law"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "key_vault_ds" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${local.name_prefix}_key_vault_ds"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law[0].id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# TODO: Create a user-assigned managed identity.
# Requirements:
# - Name should identify the future app workload.
# - Tags applied.
# DONE

# TODO: Create a storage account.
# Requirements:
# - Standard performance
# - Locally redundant storage
# - HTTPS traffic only
# - Public blob access disabled
# - Tags applied
# DONE

# TODO: Create one private blob container named app-data. DONE

# TODO: Create a Key Vault.
# Requirements:
# - Use the current tenant ID from azurerm_client_config.
# - Use RBAC authorization.
# - Use a low-cost SKU.
# - Keep purge protection disabled for the lab unless your subscription policy requires it.
# - Tags applied.
# DONE

# TODO: Decide how the Terraform-running identity can create the lab secret.
# Option A:
# - Confirm your signed-in user or service principal already has Key Vault data-plane permissions.
# Option B:
# - Create a narrowly scoped role assignment for data.azurerm_client_config.current.object_id.
# Suggested role for this lab:
# - Key Vault Secrets Officer
# Suggested scope:
# - The Key Vault resource ID
# Note:
# - You may need to wait for RBAC propagation before the secret can be created.
# DONE

# TODO: Create a lab secret in Key Vault.
# Requirements:
# - Name: app-config
# - Value from var.lab_secret_value
# - Do not use a real secret.
# - Explain in notes.md why this still appears in Terraform state.
# DONE

# TODO: Assign the managed identity a least-privilege Key Vault role.
# Suggested role:
# - Key Vault Secrets User
# Suggested scope:
# - The Key Vault resource ID
# DONE

# TODO: Assign the managed identity a least-privilege storage data role.
# Suggested role:
# - Storage Blob Data Reader
# Suggested scope:
# - Storage account or container scope; document your choice.
# DONE

# TODO: Optionally create Log Analytics when enable_diagnostics is true. DONE

# TODO: Optionally create diagnostic settings for Key Vault.
# Capture at least audit events where supported by your provider/resource combination.

