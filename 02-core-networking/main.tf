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

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "this" {
  for_each            = var.subnets
  name                = "${each.key}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  dynamic "security_rule" {
    for_each = each.value.allowed_inbound

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_port_range     = security_rule.value.destination_port_range
      destination_address_prefix = security_rule.value.destination_address_prefix
      access                     = "Allow"
      direction                  = "Inbound"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_route_table" "this" {
  name                = "main-route-table"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  route {
    name           = "default-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = var.subnets
  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this.id
}


# TODO: Optionally create public IP + NAT Gateway + subnet associations when enable_nat_gateway is true.
