variable "prefix" {
  description = "Short lowercase prefix used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,10}$", var.prefix))
    error_message = "Use 3-11 lowercase letters or numbers, starting with a letter."
  }
}

variable "environment" {
  description = "Environment name."
  type        = string

  validation {
    condition     = contains(["dev", "test"], var.environment)
    error_message = "Environment must be dev or test for this lab."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "extra_tags" {
  description = "Additional tags merged into common tags."
  type        = map(string)
  default     = {}
}

