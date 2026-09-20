locals {
  name_prefix = "${var.prefix}-${var.environment}"

  common_tags = merge(
    {
      environment = var.environment
      owner       = var.owner
      managed_by  = "terraform"
      project     = "azure-terraform-hands-on"
    },
    var.extra_tags
  )
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

