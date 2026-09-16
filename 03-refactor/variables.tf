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

variable "tags" {
  type    = map(string)
  default = {}
}
