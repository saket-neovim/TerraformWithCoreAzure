# main.tf
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-network-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
  tags                = var.tags
}

# TODO: Create subnets with for_each.
# TODO: Create one NSG per subnet with for_each.
# TODO: Generate inbound security rules from each subnet's allowed_inbound list.
# TODO: Associate each NSG to the correct subnet.
# TODO: Create route table and subnet associations.
# TODO: Optionally create public IP + NAT Gateway + subnet associations when enable_nat_gateway is true.
