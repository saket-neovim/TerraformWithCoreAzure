# Project 4 - Reusable Platform Modules

Turn repeated Terraform patterns into reusable modules without hiding important Azure decisions.

## Architecture Target

- `foundation` module for resource group, standardized name prefix, and common tags.
- `network` module for one VNet, multiple subnets, one NSG per subnet, and NSG associations.
- Optional `diagnostics` module for Log Analytics and diagnostic settings where supported.
- Environment roots for `dev` and `test`.
- Environment-specific variable files so the same modules can produce different environments.

## Suggested Workflow

Run commands from an environment folder, such as `envs/dev`:

```bash
terraform init
terraform fmt -check -recursive ../..
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output
terraform state list
terraform destroy
```

Repeat from `envs/test` and compare the plan differences.

## Before You Code

Use `notes.md` to decide:

- What belongs in each module?
- Which values should stay in `dev` and `test` inputs?
- Which outputs must remain stable for callers?
- Whether diagnostics should be enabled in each environment.

## Azure Validation

After apply, validate real Azure resources:

```bash
az group show --name <resource-group-name>
az network vnet show --name <vnet-name> --resource-group <resource-group-name>
az network vnet subnet list --vnet-name <vnet-name> --resource-group <resource-group-name> --output table
az network nsg list --resource-group <resource-group-name> --output table
az monitor log-analytics workspace list --resource-group <resource-group-name> --output table
```

Save concise results in `evidence.md`.

