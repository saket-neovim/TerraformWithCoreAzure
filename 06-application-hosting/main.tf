locals {
  name_prefix = "${var.prefix}-${var.environment}"

  common_tags = {
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    project     = "azure-terraform-hands-on"
    lab         = "06"
  }
}

# Read metadata only. Lab 5 remains the owner of these resources and RBAC grants.
data "azurerm_user_assigned_identity" "app" {
  name                = var.managed_identity_name
  resource_group_name = var.identity_resource_group_name
}

data "azurerm_key_vault" "app" {
  name                = var.key_vault_name
  resource_group_name = var.identity_resource_group_name
}

resource "azurerm_resource_group" "app" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "snet" {
  name                 = "${local.name_prefix}-snet"
  resource_group_name  = azurerm_resource_group.app.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.app_subnet_prefixes
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  security_rule {
    name                       = "allowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = var.admin_source_cidr
  }
  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_asso" {
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "static" {
  name                = "staticIPv4"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"

  tags = local.common_tags
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.name_prefix}-nic"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${local.name_prefix}-machine"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
  disable_password_authentication = true

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.app.id]
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  boot_diagnostics {
  }

  custom_data = base64encode(templatefile(
    "${path.module}/cloud-init.yaml.tftpl",
    {
      identity_client_id = data.azurerm_user_assigned_identity.app.client_id
      vault_uri          = data.azurerm_key_vault.app.vault_uri
      secret_name        = var.secret_name
    }
  ))

  depends_on = [azurerm_subnet_network_security_group_association.nsg_asso]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name_prefix}-law"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_machine_extension" "extension" {
  name                 = "extension"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.45"

  tags = local.common_tags

  settings = jsonencode({
    authentication = {
      managedIdentity = {
        "identifier-name"  = "mi_res_id"
        "identifier-value" = data.azurerm_user_assigned_identity.app.id
      }
    }
  })

}

resource "azurerm_monitor_data_collection_rule" "syslog" {
  name                = "${local.name_prefix}-syslog-dcr"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  kind                = "Linux"

  data_sources {
    syslog {
      name           = "user-syslog"
      facility_names = ["user"]
      log_levels = [
        "Info",
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency",
      ]
      streams = ["Microsoft-Syslog"]
    }
  }

  destinations {
    log_analytics {
      name                  = "lab-workspace"
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["lab-workspace"]
  }

  tags = local.common_tags
}

resource "azurerm_monitor_data_collection_rule_association" "vm_syslog" {
  name                    = "${local.name_prefix}-syslog-association"
  target_resource_id      = azurerm_linux_virtual_machine.vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog.id
}


# TODO: Create a separate Lab 6 resource group with common tags.

# TODO: Create a VNet, one app subnet, and one NSG.
# - SSH TCP/22 allowed only from var.admin_source_cidr.
# - No inbound allow rules for TCP/80, TCP/443, or TCP/8080.
# - Associate the NSG with the app subnet.
# - Explain default NSG rules and the actual app listening address.

# TODO: Create one Standard, Static public IPv4 address and one NIC.
# - NIC references the subnet and public IP; private IP allocation is Dynamic.
# - The public IP provides explicit egress and restricted SSH ingress.
# - No NAT Gateway, Bastion, or load balancer in the baseline.

# TODO: Create azurerm_linux_virtual_machine.app.
# - Small SKU from var.vm_size; Ubuntu LTS image verified for this region.
# - SSH public key via file(pathexpand(var.ssh_public_key_path)).
# - Password authentication disabled; managed OS disk using Standard_LRS.
# - Attach data.azurerm_user_assigned_identity.app.id as UserAssigned identity.
# - Enable boot diagnostics with Azure-managed storage.
# - Base64-encode templatefile("${path.module}/cloud-init.yaml.tftpl", {...}).
# - Supply metadata only: identity client ID, vault URI, secret name, app source.
# - Ensure subnet NSG association exists before VM bootstrap starts.

# TODO: Create a PerGB2018 Log Analytics workspace with 30-day retention.

# TODO: Install AzureMonitorLinuxAgent via azurerm_virtual_machine_extension.
# - Publisher: Microsoft.Azure.Monitor; type: AzureMonitorLinuxAgent.
# - Configure its authentication to use the attached user-assigned identity.
# - Verify the current supported extension version in the Azure region.

# TODO: Create a Linux azurerm_monitor_data_collection_rule.
# - Collect user-facility syslog at Info and more severe levels.
# - Route Microsoft-Syslog to the Log Analytics destination.
# - Create azurerm_monitor_data_collection_rule_association for the VM.
# - Enable rsyslog in the guest and verify an actual event reaches Syslog.

# TODO (stretch): Add a small Standard_LRS managed data disk and attachment.
# Mount by UUID and explain persistence across VM rebuilds; never use the temp disk.
