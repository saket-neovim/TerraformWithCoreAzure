variable "prefix" {
  description = "Short lowercase prefix used in Lab 6 resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,10}$", var.prefix))
    error_message = "Use 3-11 lowercase letters or numbers, starting with a letter."
  }
}

variable "location" {
  description = "Region for the Lab 6 VM, network, and monitoring resources."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Lab environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test"], var.environment)
    error_message = "Environment must be dev or test."
  }
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "vm_size" {
  description = "Small VM SKU; confirm regional availability and subscription quota."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux administrator account; use SSH keys and disable password authentication."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to an existing SSH public key, never a private key."
  type        = string
}

variable "admin_source_cidr" {
  description = "Your current public IPv4 address with /32; sole allowed SSH source."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_source_cidr)) &&
      can(regex("/32$", var.admin_source_cidr))
    )
    error_message = "Provide one valid IPv4 /32, not a broad internet range."
  }
}

variable "vnet_address_space" {
  description = "Non-overlapping address space for the Lab 6 VNet."
  type        = list(string)
  default     = ["10.60.0.0/16"]
}

variable "app_subnet_prefixes" {
  description = "Address prefixes within the Lab 6 VNet for the VM subnet."
  type        = list(string)
  default     = ["10.60.1.0/24"]
}

variable "identity_resource_group_name" {
  description = "Existing Lab 5 resource group containing the identity and Key Vault."
  type        = string
}

variable "managed_identity_name" {
  description = "Existing Lab 5 user-assigned managed identity name."
  type        = string
}

variable "key_vault_name" {
  description = "Existing Lab 5 RBAC-enabled Key Vault name."
  type        = string
}

variable "secret_name" {
  description = "Existing dummy secret to read at runtime; no secret value goes into Lab 6 inputs."
  type        = string
  default     = "app-config"
}
