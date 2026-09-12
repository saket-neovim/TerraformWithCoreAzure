# How To Use The Azure Terraform Labs

This guide explains how to use `AzureTerraformHandsOnCurriculum.md` as a hands-on learning system, not just as a reading document.

## Main Idea

Do not try to finish all 8 projects quickly.

Treat each project like a small work assignment:

1. Read the scenario.
2. Build the Terraform yourself.
3. Apply it in Azure.
4. Validate the real Azure resources.
5. Break or troubleshoot one thing.
6. Write notes.
7. Ask for grading before moving on.

The goal is not to memorize Terraform syntax. The goal is to become comfortable building, validating, debugging, and explaining Azure infrastructure.

## Recommended Folder Structure

Keep each project in its own folder:

```text
/Users/saketb/Documents/TerraformWork/
├── AzureTerraformHandsOnCurriculum.md
├── HowToUseAzureTerraformLabs.md
├── 01-starter-stack/
│   ├── README.md
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── notes.md
│   └── evidence.md
├── 02-core-networking/
│   ├── README.md
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── notes.md
│   └── evidence.md
└── ...
```

Use `notes.md` for your thinking and decisions.

Use `evidence.md` for command results, Azure CLI checks, and validation summaries.

## Project Workflow

For each project, follow this cycle.

### 1. Read Only The Current Project

Do not read the whole curriculum every time.

For example, if you are starting Project 1, read:

- Project 1 scenario
- Architecture target
- Starter code
- Tasks
- Validation commands
- Troubleshooting exercise
- Interview questions
- Grading rubric

Ignore later projects until you finish the current one.

### 2. Create The Project Folder

Example:

```bash
mkdir 01-starter-stack
cd 01-starter-stack
```

Then create the files listed in the project:

```text
versions.tf
providers.tf
variables.tf
main.tf
outputs.tf
terraform.tfvars.example
notes.md
evidence.md
```

### 3. Predict Before Running Terraform

Before running `terraform plan`, write a prediction in `notes.md`.

Example:

```text
Prediction:

Resources expected:
- azurerm_resource_group.this
- azurerm_storage_account.this
- azurerm_storage_container.artifacts
- azurerm_log_analytics_workspace.this

Known before apply:
- resource group name
- location
- tags

Unknown until apply:
- resource IDs
- storage endpoints
- workspace ID

Replacement risks:
- storage account name
- location
- resource group name
```

This step is important because real Terraform work is mostly about understanding the plan before applying it.

### 4. Build The Terraform Yourself

Use the starter code and TODOs.

Do not ask for the full solution immediately. First ask for hints if you are stuck:

```text
Give me a conceptual hint for Project 1 storage account naming.
```

Good learning happens when you struggle a little, inspect the docs, and then fix your own code.

### 5. Run The Standard Validation Commands

For most projects, use this pattern:

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

Save short summaries in `evidence.md`.

Example:

```text
terraform fmt -check -recursive: passed
terraform validate: passed
terraform plan: 4 to add, 0 to change, 0 to destroy
terraform apply: successful
terraform state list: 4 resources found
terraform destroy: successful
```

You do not need to paste huge command outputs unless something failed.

### 6. Validate In Azure

Terraform success is not enough.

Use Azure CLI and the Azure Portal to confirm what actually exists.

Example:

```bash
az group show --name <resource-group-name>
az storage account show --name <storage-account-name> --resource-group <resource-group-name>
az resource list --resource-group <resource-group-name> --output table
```

Write what you observed in `evidence.md`.

Example:

```text
Azure validation:

- Resource group exists in eastus.
- Storage account exists and has HTTPS-only enabled.
- Blob container exists with private access.
- Log Analytics workspace exists.
```

### 7. Do The Troubleshooting Exercise

Each project includes at least one break/fix task.

Do not skip this. Troubleshooting is the part that makes the lab work-ready.

Examples:

- Change a Terraform-owned tag manually in Azure.
- Break a storage account name.
- Duplicate NSG rule priorities.
- Rename a `for_each` key.
- Remove a required role assignment.
- Break private DNS.

Record:

```text
What I broke:

Where it failed:

How I diagnosed it:

How I fixed it:

What this would mean in production:
```

### 8. Write The Decision Note

Every project should end with a short decision note.

This is what turns the lab from "I followed steps" into "I can explain infrastructure choices."

Example:

```text
Decision:

Terraform should own resource groups, storage settings, tags, and diagnostic settings.

Operators should not manually edit Terraform-owned tags because normal plan will try to revert drift.

Before production, I would add remote state, stricter naming, private endpoints, monitoring alerts, and policy checks.
```

### 9. Ask For Grading

When you finish a project, do not copy-paste everything into chat.

Ask:

```text
Grade Project 1 from /Users/saketb/Documents/TerraformWork/01-starter-stack.
```

I can read your `.tf` files, `notes.md`, and `evidence.md` directly.

## What To Save For Grading

For each project, save these files:

| File | Purpose |
|---|---|
| `README.md` | What the project does and how to run it |
| `versions.tf` | Terraform and provider requirements |
| `providers.tf` | Azure provider setup |
| `variables.tf` | Inputs and validation |
| `main.tf` | Main infrastructure |
| `outputs.tf` | Useful outputs |
| `terraform.tfvars.example` | Safe example inputs |
| `notes.md` | Your predictions, reasoning, and decisions |
| `evidence.md` | Command results and Azure validation summary |

Do not commit or share real secrets.

Avoid saving:

- `.terraform/`
- `.terraform.lock.hcl` only if you intentionally do not want provider locks tracked
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `*.tfvars` with real values
- plan files containing sensitive values

## How Grading Works

Grading should be based on work-readiness, not just whether Terraform applied.

Each project can be graded across these areas:

| Area | What is checked |
|---|---|
| Terraform correctness | Formatting, validation, plan/apply behavior, clean destroy |
| Azure correctness | Correct services, settings, names, and relationships |
| State understanding | Ability to map code to state to Azure resource IDs |
| Troubleshooting | Ability to diagnose drift, dependency, naming, RBAC, or network issues |
| Security | Least privilege, private access, no secret leakage, sensible defaults |
| Cost control | Cheap resources, clear cleanup, no forgotten billable resources |
| Interview readiness | Clear explanation of design choices and tradeoffs |

Example grade:

```text
Score: 7.5 / 10

Strong:
- Code applies cleanly.
- Tags and outputs are well structured.
- Azure CLI validation was done.

Needs improvement:
- Naming logic could create a non-unique storage account.
- Drift explanation is incomplete.
- No production monitoring decision was written.

Next difficulty:
- Continue to Project 2.
- Add one extra troubleshooting task around NSG rule priority conflicts.
```

## When To Ask For Help

Use these prompts while working:

```text
Give me a hint, but do not show the full solution.
Explain this Terraform error.
Explain this Azure CLI error.
Review only my variables and naming approach.
Review my plan output and tell me what looks risky.
Ask me interview questions for Project 1.
Grade my Project 1 folder.
Make Project 2 slightly harder based on my Project 1 grade.
Generate the full detailed Project 3 lab based on my weak areas.
```

## When To Generate More Labs

Projects 1 and 2 are already detailed enough to start.

Do not fully generate Projects 3-8 yet unless you strongly prefer having everything upfront.

Better approach:

1. Finish Project 1.
2. Get graded.
3. Finish Project 2.
4. Get graded.
5. Generate Project 3 in full detail based on the grading feedback.

This makes the later labs better because they target your real weak spots instead of guessing.

## Suggested Pace

Since you are willing to spend 8+ hours per week, use this pace:

| Week | Focus |
|---:|---|
| 1 | Project 1 implementation and validation |
| 2 | Project 1 troubleshooting, grading, and corrections |
| 3 | Project 2 implementation |
| 4 | Project 2 troubleshooting, grading, and corrections |
| 5-6 | Project 3 full lab and state/import practice |
| 7-8 | Project 4 modules |
| 9-10 | Project 5 identity, RBAC, Key Vault |
| 11-12 | Project 6 app hosting |
| 13-14 | Project 7 private access troubleshooting |
| 15-16 | Project 8 CI/CD and capstone |

Move faster if a project is easy. Slow down if you cannot explain what Terraform and Azure are doing.

## Definition Of Done

A project is done only when:

- Terraform formats and validates.
- Terraform plan is understood before apply.
- Resources are applied successfully.
- Azure CLI or Portal validation is completed.
- Terraform state is inspected.
- Troubleshooting exercise is completed.
- `notes.md` has a decision note.
- `evidence.md` has validation summaries.
- Resources are destroyed or intentionally preserved.
- You can answer the interview questions without reading the solution.

## Best Overall Strategy

Use the curriculum like this:

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

That loop is what will turn your Terraform and Azure knowledge into actual hands-on confidence.
