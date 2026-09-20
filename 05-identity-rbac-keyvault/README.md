# Project 5 - Identity, RBAC, and Key Vault

Build a small identity and secrets foundation with Terraform.

This lab is intentionally incomplete. Use the TODOs in the Terraform files and your
notes to implement the missing resources yourself.

## Architecture Target

- One resource group.
- One user-assigned managed identity for a future application.
- One storage account and one private blob container.
- One Key Vault using Azure RBAC authorization.
- One low-risk lab secret in Key Vault.
- A documented permission path for the Terraform-running identity to create the lab secret.
- Role assignments for Key Vault secret read and storage blob read.
- Optional Log Analytics workspace and Key Vault diagnostic settings.

## Suggested Workflow

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output
terraform state list
terraform destroy
```

Also validate the real Azure resources:

```bash
az group show --name <resource-group-name>
az identity show --name <identity-name> --resource-group <resource-group-name>
az keyvault show --name <key-vault-name> --resource-group <resource-group-name>
az keyvault secret show --vault-name <key-vault-name> --name app-config
az storage account show --name <storage-account-name> --resource-group <resource-group-name>
az storage container show --name app-data --account-name <storage-account-name> --auth-mode login
az role assignment list --assignee <managed-identity-principal-id> --scope <key-vault-id> --output table
az role assignment list --assignee <managed-identity-principal-id> --scope <storage-scope-id> --output table
az monitor diagnostic-settings list --resource <key-vault-id>
```

## Before You Code

Write your decisions in `notes.md` first:

- What RBAC scopes will you use?
- How will the Terraform-running identity create the Key Vault secret?
- What is safe or unsafe about putting a secret value in Terraform?
- Are you enabling diagnostics, and why?

