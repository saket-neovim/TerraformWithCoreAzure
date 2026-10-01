provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }

  subscription_id = "f494677c-c695-4fff-9d7f-160c71b88534"
  tenant_id       = "9cea19bd-2e23-4c23-ada0-46f6f8f4def4"
}

