# Azure Terraform Hands-On Labs

This repository contains a practical Azure + Terraform learning path for building hands-on infrastructure experience. It is designed for learners who already know some Terraform and Azure theory, but need more real practice creating, validating, troubleshooting, and explaining Azure infrastructure.

The main curriculum is project-based. Instead of many small disconnected exercises, the repo uses fewer dense labs that feel closer to workplace tasks.

## Who This Is For

This repo is useful if you:

- Have completed one or more Terraform courses.
- Have Azure fundamentals or AZ-104 level knowledge.
- Need hands-on Azure infrastructure practice for work.
- Want to improve Terraform state, modules, networking, identity, monitoring, and troubleshooting skills.
- Plan to learn AKS later, after strengthening Azure and Terraform basics.

## Learning Approach

Learn Azure and Terraform together.

Terraform is used to create and manage infrastructure. Azure CLI and the Azure Portal are used to inspect, validate, and troubleshoot the real resources.

The recommended loop is:

```text
Read one project.
Build it.
Validate it.
Break it.
Fix it.
Explain it.
Get graded.
Adjust the next project.
```

Do not rush through all labs. The goal is work-readiness, not just finishing files.

## Repository Contents

```text
.
├── README.md
├── AzureTerraformHandsOnCurriculum.md
├── HowToUseAzureTerraformLabs.md
└── Tasks1.md
```

| File | Purpose |
|---|---|
| `AzureTerraformHandsOnCurriculum.md` | Main 8-project Azure + Terraform curriculum |
| `HowToUseAzureTerraformLabs.md` | Practical guide for using the labs, saving evidence, and requesting grading |
| `Tasks1.md` | Older generated Terraform lab set kept for reference |

## Project Roadmap

| Project | Focus |
|---:|---|
| 1 | Terraform + Azure starter stack: resource group, storage, Log Analytics, tags, drift |
| 2 | Core Azure networking: VNet, subnets, NSGs, route tables, optional NAT Gateway |
| 3 | Terraform state and refactor workflow: remote backend, imports, moved blocks |
| 4 | Reusable platform modules: foundation, network, naming, tags, validations |
| 5 | Identity, RBAC, and Key Vault: managed identity, role assignments, secrets |
| 6 | Application hosting: VM or App Service, diagnostics, private networking |
| 7 | Private access troubleshooting: private endpoint, private DNS, RBAC/DNS debugging |
| 8 | CI/CD and capstone: plan review, policy scan, environment promotion, final rebuild |

Projects 1 and 2 are detailed enough to start immediately. Projects 3-8 should be generated or expanded later based on performance in the first two projects.

## Core Azure Areas Covered

- Resource groups, naming, tags, and governance
- Azure Storage and Blob containers
- Azure Monitor and Log Analytics
- VNets, subnets, NSGs, route tables, and NAT Gateway
- Managed identities and RBAC
- Key Vault and secret handling
- Private endpoints and private DNS
- Terraform state, imports, moved blocks, modules, and CI/CD workflows

AKS is intentionally not part of the first phase. Learn Kubernetes basics separately, then return to AKS with Terraform after the Azure/Terraform foundation is strong.

## Prerequisites

Install:

- Terraform `>= 1.6`
- Azure CLI
- Git
- An editor such as VS Code

You also need access to an Azure subscription where you can create and delete lab resources.

Check your tools:

```bash
terraform version
az version
az account show
```

## How To Start

Read:

1. `HowToUseAzureTerraformLabs.md`
2. Project 1 in `AzureTerraformHandsOnCurriculum.md`

Then create your first project folder:

```bash
mkdir 01-starter-stack
cd 01-starter-stack
```

Create the files listed in Project 1:

```text
README.md
versions.tf
providers.tf
variables.tf
main.tf
outputs.tf
terraform.tfvars.example
notes.md
evidence.md
```

Build the Terraform yourself using the starter instructions.

## Validation Workflow

Most projects follow this command pattern:

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

Also validate real Azure resources with Azure CLI, for example:

```bash
az group show --name <resource-group-name>
az resource list --resource-group <resource-group-name> --output table
```

Terraform success alone is not enough. You should be able to explain what exists in Azure and how it maps back to Terraform state.

## What To Save Per Project

Each project folder should include:

- Terraform files
- `README.md`
- `notes.md`
- `evidence.md`
- Any useful command output summaries
- Your troubleshooting notes
- Your decision note

Use `notes.md` for thinking, predictions, and decisions.

Use `evidence.md` for validation summaries.

Example evidence:

```text
terraform fmt -check -recursive: passed
terraform validate: passed
terraform plan: 4 to add, 0 to change, 0 to destroy
terraform apply: successful
Azure CLI validation: resource group, storage account, and workspace found
terraform destroy: successful
```

## Grading

After completing a project, ask for review using the project folder:

```text
Grade Project 1 from /Users/saketb/Documents/TerraformWork/01-starter-stack.
```

Grading should check:

- Terraform correctness
- Azure correctness
- State understanding
- Troubleshooting ability
- Security and least privilege
- Cost control
- Interview readiness

## Cost And Cleanup

These labs are designed to stay low-cost, but Azure resources can still create charges.

Always:

- Use cheap SKUs.
- Prefer short-lived environments.
- Run `terraform destroy` after each lab unless intentionally preserving resources.
- Check the Azure Portal or CLI for leftover resources.
- Be careful with NAT Gateway, public IPs, Application Gateway, and long-running compute.

## Security Notes

Do not commit:

- Real secrets
- Real `.tfvars` files
- Terraform state files
- Plan files containing sensitive values
- Azure credentials

Keep examples safe and generic.

## Recommended Git Ignore

This repo should ignore local Terraform artifacts such as:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfplan
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

Commit `terraform.tfvars.example`, not real `terraform.tfvars`.

## Suggested Pace

If spending 8+ hours per week:

| Weeks | Focus |
|---:|---|
| 1-2 | Project 1, grading, and corrections |
| 3-4 | Project 2, grading, and corrections |
| 5-6 | Project 3 |
| 7-8 | Project 4 |
| 9-10 | Project 5 |
| 11-12 | Project 6 |
| 13-14 | Project 7 |
| 15-16 | Project 8 capstone |

Move faster if a project is easy. Slow down if you cannot explain the architecture, Terraform plan, or Azure troubleshooting steps.

## Definition Of Done

A project is complete only when:

- Terraform formats and validates.
- The plan is understood before apply.
- Azure resources are created successfully.
- Azure CLI or Portal validation is complete.
- Terraform state is inspected.
- A troubleshooting exercise is completed.
- A decision note is written.
- Resources are destroyed or intentionally preserved.
- You can answer the project interview questions.

## Next Step

Start with Project 1 in `AzureTerraformHandsOnCurriculum.md`.

Build it yourself first. Ask for hints when stuck. Ask for grading when the project folder contains Terraform code, notes, and evidence.
