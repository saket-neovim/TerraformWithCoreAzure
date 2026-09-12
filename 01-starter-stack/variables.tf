# variables.tf
variable "prefix" {
  description = "Short lowercase prefix used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,15}$", var.prefix))
    error_message = "Use 3-11 lowercase letters or numbers, starting with a letter."
  }
}

variable "location" {
  description = "Azure region for the lab."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}
