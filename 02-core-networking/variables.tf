# variables.tf
variable "prefix" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "address_space" {
  type    = list(string)
  default = ["10.40.0.0/16"]
}

variable "subnets" {
  description = "Subnet definitions keyed by subnet role."
  type = map(object({
    address_prefixes = list(string)
    allowed_inbound = list(object({
      name                       = string
      priority                   = number
      protocol                   = string
      source_address_prefix      = string
      destination_port_range     = string
      destination_address_prefix = optional(string, "*")
    }))
  }))
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
