variable "prefix" {
  description = "Short lowercase prefix used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,10}$", var.prefix))
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

  validation {
    condition     = contains(["dev", "test"], var.environment)
    error_message = "Environment must be dev or test for this lab."
  }
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "lab_secret_value" {
  description = "Low-risk lab secret value. Do not use a real password, token, or production secret."
  type        = string
  sensitive   = true
}

variable "enable_diagnostics" {
  description = "Whether to create Log Analytics and Key Vault diagnostics."
  type        = bool
  default     = true
}

