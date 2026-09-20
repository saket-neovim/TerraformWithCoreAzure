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

# TODO: Create a user-assigned managed identity.
# Requirements:
# - Name should identify the future app workload.
# - Tags applied.

# TODO: Create a storage account.
# Requirements:
# - Standard performance
# - Locally redundant storage
# - HTTPS traffic only
# - Public blob access disabled
# - Tags applied

# TODO: Create one private blob container named app-data.

# TODO: Create a Key Vault.
# Requirements:
# - Use the current tenant ID from azurerm_client_config.
# - Use RBAC authorization.
# - Use a low-cost SKU.
# - Keep purge protection disabled for the lab unless your subscription policy requires it.
# - Tags applied.

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

# TODO: Create a lab secret in Key Vault.
# Requirements:
# - Name: app-config
# - Value from var.lab_secret_value
# - Do not use a real secret.
# - Explain in notes.md why this still appears in Terraform state.

# TODO: Assign the managed identity a least-privilege Key Vault role.
# Suggested role:
# - Key Vault Secrets User
# Suggested scope:
# - The Key Vault resource ID

# TODO: Assign the managed identity a least-privilege storage data role.
# Suggested role:
# - Storage Blob Data Reader
# Suggested scope:
# - Storage account or container scope; document your choice.

# TODO: Optionally create Log Analytics when enable_diagnostics is true.

# TODO: Optionally create diagnostic settings for Key Vault.
# Capture at least audit events where supported by your provider/resource combination.

