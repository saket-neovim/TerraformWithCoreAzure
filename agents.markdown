# Repository Guidelines

## Workspace Purpose

This repository is an Azure + Terraform hands-on learning workspace. Treat each lab as a practical infrastructure assignment: read the scenario, predict the plan, implement, validate in Azure, troubleshoot, document evidence, and ask for grading before moving on.

## Always Read First

When a new chat starts, use this file as baseline context. For task-specific work, also inspect the active lab's `README.md`, `notes.md`, and `evidence.md` before changing code or grading. Root context lives in:

- `README.md`
- `HowToUseAzureTerraformLabs.md`
- `AzureTerraformHandsOnCurriculum.md`

## Project Structure

Each numbered directory is an independently runnable Terraform lab:

```text
01-starter-stack/
02-core-networking/
```

Typical lab files are `versions.tf`, `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `terraform.tfvars.example`, `README.md`, `notes.md`, and `evidence.md`. Use `notes.md` for predictions, decisions, troubleshooting notes, and interview answers. Use `evidence.md` for concise command results and Azure validation.

## Development Commands

Run from the active lab directory:

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

Validate real Azure resources:

```bash
az group show --name <resource-group-name>
az resource list --resource-group <resource-group-name> --output table
az network vnet show --name <vnet-name> --resource-group <resource-group-name>
```

## Terraform Style

Use Terraform `>= 1.6` and AzureRM provider `~> 3.x` unless a lab says otherwise. Keep HCL formatted with `terraform fmt`. Prefer stable names from inputs, meaningful `for_each` keys, explicit variable types, and useful outputs. Do not edit `.tfstate`, use broad `ignore_changes`, or use `-target` unless the lab asks for that tradeoff.

## Learning And Solution Policy

Do not provide complete lab solutions unless the user explicitly asks. Prefer conceptual hints, code review, grading, or targeted fixes. Preserve intentionally incomplete starter code and TODOs when relevant.

## Testing And Validation

There is no separate unit test framework. Validation means `terraform fmt`, `terraform validate`, a reviewed plan, Azure CLI checks, state inspection, and evidence. Each completed lab needs a decision note comparing Terraform config, state, and actual Azure resources.

## Security And Cost

Never commit real `.tfvars`, state files, plan files, secrets, or Azure credentials. Prefer cheap SKUs, `eastus`, short-lived resources, and `terraform destroy` after validation unless a lab says to preserve resources.

## Commits And Reviews

Keep commits small and descriptive, following the existing concise style: `lab-02 complete`, `nat-gw added`. Reviews and grading should focus on Terraform correctness, Azure correctness, security, cost control, state understanding, troubleshooting quality, and interview readiness.
