variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "Provide at least one VNet address space."
  }
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

variable "tags" {
  type    = map(string)
  default = {}
}

