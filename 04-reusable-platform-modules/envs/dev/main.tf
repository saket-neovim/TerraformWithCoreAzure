module "foundation" {
  source = "../../modules/foundation"

  prefix      = var.prefix
  environment = "dev"
  location    = var.location
  owner       = var.owner
}

module "network" {
  source = "../../modules/network"

  name_prefix         = module.foundation.name_prefix
  resource_group_name = module.foundation.rg_name
  location            = module.foundation.location
  address_space       = var.address_space
  subnets             = var.subnets
  tags                = module.foundation.common_tags
}

module "diagnostics" {
  count = var.enable_diagnostics ? 1 : 0

  source = "../../modules/diagnostics"

  name_prefix         = module.foundation.name_prefix
  resource_group_name = module.foundation.rg_name
  location            = module.foundation.location
  diagnostic_targets = {
    vnet = module.network.vnet_id
  }
}

# TODO: Optionally call diagnostics with count when enable_diagnostics is true. - DONE
