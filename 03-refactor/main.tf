# main.tf
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-network-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "tfstate" {
  name     = "${var.prefix}-tfstate"
  location = var.location
  tags     = var.tags
}

resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "this" {
  name                = "primary-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "this" {
  name                = "primary-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "linux-vm"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  size           = "Standard_D2s_v3"
  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "this" {
  name                = "public-ip-for-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_security_group" "vm" {
  name                = "linux-vm-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "223.185.132.228/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_storage_account" "main" {
  name                     = "dummyac11212"
  resource_group_name      = "tfaz02-network-rg"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

moved {
  from = azurerm_storage_account.new_import
  to = azurerm_storage_account.main
}