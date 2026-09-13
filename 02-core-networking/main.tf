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

  tags = var.tags
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
  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = var.subnets
  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this.id
}

resource "azurerm_public_ip" "public" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "natgw-public-ip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "nat-gw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.public[0].id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each       = var.enable_nat_gateway ? var.subnets : {}
  subnet_id      = azurerm_subnet.this[each.key].id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}