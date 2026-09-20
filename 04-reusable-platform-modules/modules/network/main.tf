resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets
  name = "${each.key}"
  resource_group_name = var.resource_group_name
  address_prefixes = "${each.value.address_prefixes}"
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_network_security_group" "this" {
  for_each = var.subnets
  name = "${each.key}-nsg"
  location = azurerm_virtual_network.this.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.inbound_rules
    content {
      name = security_rule.value.name
      priority = security_rule.value.priority
      protocol = security_rule.value.protocol
      source_address_prefix = security_rule.value.source_address_prefix
      destination_port_range = security_rule.value.destination_port_range
      destination_address_prefix = security_rule.value.destination_address_prefix
      access = security_rule.value.access
      direction = "Inbound"
      source_port_range = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets
  subnet_id = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

# TODO: Create subnets with for_each. - DONE
# TODO: Create one NSG per subnet with for_each. - DONE
# TODO: Generate inbound security rules from each subnet's inbound_rules list. - DONE
# TODO: Associate each subnet with its matching NSG. - DONE
# TODO: Keep resource addresses stable when new subnet keys are added. - DONE

