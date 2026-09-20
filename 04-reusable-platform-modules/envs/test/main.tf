module "foundation" {
  source = "../../modules/foundation"

  prefix      = var.prefix
  environment = "test"
  location    = var.location
  owner       = var.owner
}

module "network" {
  source = "../../modules/network"

  name_prefix         = module.foundation.name_prefix
  resource_group_name = module.foundation.resource_group_name
  location            = module.foundation.location
  address_space       = var.address_space
  subnets             = var.subnets
  tags                = module.foundation.tags
}

# TODO: Optionally call diagnostics with count when enable_diagnostics is true.

