variable "prefix" {
  description = "Short lowercase prefix used in resource names."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "address_space" {
  description = "VNet address space."
  type        = list(string)
}

variable "subnets" {
  description = "Subnet definitions keyed by subnet name."
  type = map(object({
    address_prefixes = list(string)
    inbound_rules = optional(list(object({
      name                       = string
      priority                   = number
      protocol                   = string
      source_address_prefix      = string
      destination_port_range     = string
      destination_address_prefix = optional(string, "*")
      access                     = optional(string, "Allow")
    })), [])
  }))
}

variable "enable_diagnostics" {
  description = "Whether to enable the diagnostics module."
  type        = bool
  default     = true
}

