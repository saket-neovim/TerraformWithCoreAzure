# Azure + Terraform Hands-On Curriculum

A practical, project-based curriculum for building Azure infrastructure with Terraform. This is designed for someone who already understands cloud and Terraform theory, has passed AZ-104, and now needs hands-on workplace practice.

This curriculum uses the attached AWS task matrix only as a structure reference: categories, services, core tasks, and additional hands-on scenarios. It is not a set of instructions for an AI assistant to execute.

## Learning Position

You should learn Azure and Terraform together, not as two long separate tracks.

Use Terraform as the main way to create infrastructure. Use the Azure Portal and Azure CLI to inspect, validate, troubleshoot, and understand what Terraform actually created.

Kubernetes and AKS are intentionally deferred. First build confidence with Azure infrastructure and Terraform operations. Then learn Kubernetes basics. After that, return to AKS with Terraform.

## How To Use This Curriculum

Do not generate all labs in complete detail at once.

Use this workflow:

1. Complete Project 1.
2. Ask for review, grading, and difficulty assessment.
3. Complete Project 2.
4. Ask for review, grading, and difficulty assessment.
5. Generate the detailed version of Project 3 based on your actual mistakes and confidence level.

Recommended prompts:

```text
Give me a conceptual hint for Project 1.
Review my Project 1 Terraform code.
Grade my Project 1 submission using the rubric.
Increase the difficulty of Project 2 by 20 percent.
Generate the full starter files for Project 3 based on my Project 1 and 2 performance.
Ask me interview questions from this project.
Give me a broken version of this lab for troubleshooting practice.
```

## Ground Rules

- Keep every environment short-lived unless the project explicitly says otherwise.
- Prefer cheap SKUs and small regions.
- Destroy resources after validation.
- Use a naming prefix such as `tfazlab`.
- Never edit `.tfstate` by hand.
- Never use broad `ignore_changes` as a shortcut.
- Do not use `-target` unless the project explicitly asks you to explain the tradeoff.
- Always compare Terraform configuration, Terraform state, and Azure actual state.
- Every project must end with a short decision note.

## Baseline Tooling

Install and use:

```bash
terraform version
az version
az account show
az configure --defaults location=eastus
```

Core Terraform commands:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform destroy
terraform state list
terraform state show <address>
terraform output
terraform console
terraform import
terraform providers
```

Core Azure CLI commands:

```bash
az account show
az group show
az resource list
az resource show
az network vnet show
az network nsg show
az storage account show
az monitor diagnostic-settings list
az role assignment list
az keyvault show
```

## Core Azure Services Matrix

| Category | Core services | Hands-on tasks | Additional practice |
|---|---|---|---|
| Governance | Resource groups, tags, locks, budgets, Azure Policy awareness | Create resource groups, enforce naming and tags, inspect activity logs | Add delete locks, test policy denial in a sandbox if available, document cost cleanup |
| Identity and access | Microsoft Entra ID concepts, managed identities, RBAC, role assignments | Assign least-privilege roles to managed identities and users | Debug missing RBAC propagation, compare Reader vs Contributor vs scoped roles |
| Networking | VNet, subnets, NSG, route table, NAT Gateway, private DNS, private endpoints | Build segmented networks and validate effective routes/security rules | Add egress control, private endpoint DNS troubleshooting, hub-spoke concepts |
| Compute | Azure VMs, managed disks, NICs, VM extensions/cloud-init | Provision a small Linux VM and bootstrap a web service | Validate boot logs, NSG access, disk attachment, diagnostic settings |
| App hosting | App Service or Container Apps | Deploy a simple app platform with Terraform-managed settings | Add private integration conceptually or as a stretch task |
| Storage | Storage accounts, Blob Storage, Azure Files, lifecycle rules | Create secure storage with containers, lifecycle rules, diagnostics | Block public access, test private endpoint access, explain redundancy choices |
| Secrets and security | Key Vault, RBAC model, secrets, Defender for Cloud awareness | Store and retrieve secrets using managed identity | Debug forbidden errors, document secret rotation and Terraform state risks |
| Monitoring | Azure Monitor, Log Analytics, diagnostic settings, alerts, Activity Log | Send resource diagnostics to Log Analytics and create basic alerts | Query logs, inspect metrics, explain ingestion cost controls |
| Delivery | Azure Storage backend, CI/CD plan review, security scans | Store remote state, run fmt/validate/plan in a pipeline | Add plan artifact review, drift detection, policy/security gates |

## Project Roadmap

| Project | Main outcome | Azure services | Terraform skills |
|---:|---|---|---|
| 1 | Starter Azure platform slice | Resource group, storage account, Log Analytics, tags | Provider setup, variables, outputs, plan prediction, drift |
| 2 | Core network foundation | VNet, subnets, NSG, route table, NAT Gateway option | `for_each`, maps, dependencies, validation |
| 3 | State and refactor workflow | Azure Storage backend, imported resource group | remote state, import, moved blocks, safe renames |
| 4 | Reusable platform modules | Resource group, network, diagnostics | module APIs, validation, stable outputs |
| 5 | Identity and secrets | Managed identity, RBAC, Key Vault | role assignments, dependency timing, state safety |
| 6 | Application hosting | VM or App Service, diagnostics, storage integration | cloud-init/extensions, app settings, outputs |
| 7 | Private access troubleshooting | Private endpoint, private DNS, storage or Key Vault | broken infrastructure debugging, DNS/RBAC diagnosis |
| 8 | CI/CD and capstone | Pipeline, plan artifact, policy scan, inherited platform | environment promotion, review workflow, operational documentation |

## Project 1 - Terraform + Azure Starter Stack

**Difficulty:** Intermediate  
**Estimated time:** 6-10 hours  
**Cost:** Low. Uses one resource group, one storage account, one blob container, and one Log Analytics workspace. Destroy after completion.

### Scenario

You have joined a team that wants a small Azure landing area starter. They need consistent names, tags, a storage account, and a Log Analytics workspace. Before you are trusted with larger changes, you must prove that you can predict Terraform plans, inspect state, validate Azure resources, and explain drift.

### Architecture Target

Create:

- One resource group.
- One storage account.
- One private blob container.
- One Log Analytics workspace.
- Diagnostic settings where practical.
- Outputs for important names, IDs, and endpoints.

### Azure Services Practiced

- Resource groups
- Storage accounts
- Blob containers
- Log Analytics workspace
- Tags
- Azure Monitor diagnostic settings
- Activity Log inspection

### Terraform Skills Practiced

- Provider configuration
- Variables and validation
- Locals
- Naming rules
- Outputs
- Plan prediction
- State inspection
- Drift detection

### Starting Repository Shape

```text
01-starter-stack/
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
└── notes.md
```

### Starter Code

Create the files yourself from this starter. Some pieces are intentionally incomplete.

```hcl
# versions.tf
terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
```

```hcl
# providers.tf
provider "azurerm" {
  features {}
}
```

```hcl
# variables.tf
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
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}
```

```hcl
# main.tf
locals {
  common_tags = {
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    project     = "azure-terraform-hands-on"
  }

  # TODO: Make this storage account name globally unique and Azure-valid.
  storage_account_name = "${var.prefix}st"
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}

# TODO: Add an azurerm_storage_account.
# Requirements:
# - Standard performance
# - Locally redundant storage
# - HTTPS traffic only
# - Public network access decision documented in notes.md
# - Tags applied

# TODO: Add an azurerm_storage_container.
# Requirements:
# - Name: artifacts
# - Private access

# TODO: Add an azurerm_log_analytics_workspace.
# Requirements:
# - Low-cost retention setting
# - Tags applied

# TODO: Add diagnostic settings if supported by the resource/provider combination.
```

```hcl
# outputs.tf
# TODO: Output:
# - resource group name
# - storage account name
# - storage account ID
# - primary blob endpoint
# - Log Analytics workspace ID
```

```hcl
# terraform.tfvars.example
prefix      = "tfaz01"
location    = "eastus"
environment = "dev"
owner       = "your-name"
```

### Tasks

1. Before writing the missing resources, create a prediction table in `notes.md`.
2. Predict which values will be known before apply and which will be unknown until apply.
3. Implement the missing storage account, blob container, workspace, and outputs.
4. Run `terraform fmt -check -recursive` and fix formatting if needed.
5. Run `terraform validate`.
6. Run `terraform plan -out=tfplan`.
7. Compare the actual plan with your prediction table.
8. Apply the plan.
9. Use Azure CLI to inspect each created resource.
10. Use `terraform state list` and `terraform state show` to inspect state.
11. Manually change one tag in the Azure Portal.
12. Run `terraform plan -refresh-only`.
13. Run a normal `terraform plan`.
14. Explain the difference between configuration, state, and Azure actual state.
15. Destroy the resources.

### Validation Commands

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output
terraform state list
terraform state show azurerm_resource_group.this
az group show --name <resource-group-name>
az storage account show --name <storage-account-name> --resource-group <resource-group-name>
az monitor log-analytics workspace show --workspace-name <workspace-name> --resource-group <resource-group-name>
terraform plan -refresh-only
terraform plan
terraform destroy
```

### Troubleshooting Exercise

Break one thing intentionally after your first successful apply:

- Change the storage account name to include an invalid character.
- Or change a storage account setting that forces replacement.
- Or manually edit a Terraform-owned tag in Azure.

Then answer:

- Did Terraform fail during validate, plan, or apply?
- Was the problem in Terraform syntax, Azure rules, provider behavior, or drift?
- What would be risky about applying this in a shared environment?

### Interview Questions

1. What is the difference between `terraform validate`, `terraform plan`, and `terraform apply`?
2. Why are storage account names harder than resource group names?
3. What kinds of Terraform values are unknown until apply?
4. What does `terraform plan -refresh-only` do?
5. Why should Terraform-owned tags not be edited manually in the portal?
6. What information is stored in Terraform state?
7. Why can Terraform state contain sensitive data?
8. What would you monitor for a storage account in production?

### Decision Note

Write a short note in `notes.md`:

```text
Decision:

What Terraform owns:

What Azure users/operators may change manually:

How drift should be handled:

What I would change before production:
```

### Cleanup

Run:

```bash
terraform destroy
az resource list --resource-group <resource-group-name> --output table
```

If any resources remain, identify why before deleting them manually.

### Grading Rubric

| Area | Strong evidence |
|---|---|
| Terraform basics | Code is formatted, validated, and uses variables/locals cleanly |
| Azure understanding | You can explain each Azure service created and its purpose |
| Plan prediction | Prediction table matches the plan closely |
| State understanding | You can map config address, state address, and Azure resource ID |
| Drift handling | You can explain refresh-only vs normal plan |
| Cost hygiene | Resources are destroyed and checked afterward |

### Hidden Solution Policy

Do not ask for a full solution first. Ask for hints, review, or grading before asking for the complete answer.

## Project 2 - Core Azure Networking Project

**Difficulty:** Intermediate to Advanced  
**Estimated time:** 8-14 hours  
**Cost:** Low to moderate. VNets, subnets, NSGs, route tables, and public IP/NAT Gateway can incur cost. Use NAT Gateway only if you are comfortable with the cost; otherwise document the design and skip apply for that component.

### Scenario

A team needs a small network foundation for application workloads. The current design is inconsistent: subnets are created manually, NSG rules are not documented, and no one can clearly explain routing or egress. Your job is to build the network foundation with Terraform and prove it works through Azure inspection.

### Architecture Target

Create:

- One resource group.
- One VNet.
- Three subnets: `web`, `app`, and `data`.
- One NSG per subnet.
- NSG rules that allow only the traffic you intentionally choose.
- One route table for outbound routing practice, not for normal subnet-to-subnet traffic inside the VNet.
- Optional NAT Gateway with public IP for outbound egress.
- Optional diagnostics to Log Analytics if reusing Project 1 patterns.

Traffic model:

```text
Internet -> web subnet -> app subnet -> data subnet
```

Use NSG rules to decide whether `web` can reach `app` and whether `app` can reach `data`. Do not create custom route table entries for normal `web` to `app` or `app` to `data` traffic; Azure system routes already know how to route between subnets in the same VNet. Use the route table only to practice outbound routing decisions, such as internet egress or a future firewall/NVA path.

### Azure Services Practiced

- Virtual Network
- Subnets
- Network Security Groups
- NSG security rules
- Route tables
- NAT Gateway
- Public IP
- Network Watcher awareness
- Diagnostic settings

### Terraform Skills Practiced

- Maps and objects
- `for_each`
- Dynamic or repeated resources
- Input validation
- Explicit vs implicit dependencies
- Resource associations
- Stable addressing
- Outputs by key

### Starting Repository Shape

```text
02-core-networking/
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
└── notes.md
```

### Starter Code

```hcl
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

variable "subnets" {
  description = "Subnet definitions keyed by subnet role."
  type = map(object({
    address_prefixes = list(string)
    allowed_inbound = list(object({
      name                       = string
      priority                   = number
      protocol                   = string
      source_address_prefix      = string
      destination_port_range     = string
      destination_address_prefix = optional(string, "*")
    }))
  }))
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

```hcl
# terraform.tfvars.example
prefix        = "tfaz02"
location      = "eastus"
address_space = ["10.40.0.0/16"]

subnets = {
  web = {
    address_prefixes = ["10.40.1.0/24"]
    allowed_inbound = [
      {
        name                   = "AllowHttpsFromInternet"
        priority               = 100
        protocol               = "Tcp"
        source_address_prefix  = "Internet"
        destination_port_range = "443"
      }
    ]
  }

  app = {
    address_prefixes = ["10.40.2.0/24"]
    allowed_inbound = [
      {
        name                   = "AllowAppFromWeb"
        priority               = 100
        protocol               = "Tcp"
        source_address_prefix  = "10.40.1.0/24"
        destination_port_range = "8080"
      }
    ]
  }

  data = {
    address_prefixes = ["10.40.3.0/24"]
    allowed_inbound = [
      {
        name                   = "AllowDbFromApp"
        priority               = 100
        protocol               = "Tcp"
        source_address_prefix  = "10.40.2.0/24"
        destination_port_range = "5432"
      }
    ]
  }
}

enable_nat_gateway = false

tags = {
  environment = "dev"
  managed_by  = "terraform"
}
```

```hcl
# main.tf
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-network-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
  tags                = var.tags
}

# TODO: Create subnets with for_each.
# TODO: Create one NSG per subnet with for_each.
# TODO: Generate inbound security rules from each subnet's allowed_inbound list.
# TODO: Associate each NSG to the correct subnet.
# TODO: Create one route table for outbound routing practice.
# TODO: Associate it only with the subnet or subnets whose outbound path you want to control.
# TODO: Do not add custom routes for normal web -> app or app -> data traffic inside the same VNet.
# TODO: Optionally create public IP + NAT Gateway + subnet associations when enable_nat_gateway is true.
```

```hcl
# outputs.tf
# TODO: Output:
# - VNet ID
# - subnet IDs as a map keyed by subnet name
# - NSG IDs as a map keyed by subnet name
# - route table ID
# - NAT Gateway ID if enabled
```

### Tasks

1. Draw the intended traffic flow before writing Terraform.
2. Decide what should be allowed into `web`, `app`, and `data`.
3. Implement subnets using `for_each`, not `count`.
4. Implement NSGs using stable keys.
5. Generate NSG rules from input data.
6. Associate every subnet with exactly one NSG.
7. Add a route table for outbound routing practice and explain what outbound path it controls.
8. Decide whether to enable NAT Gateway. If skipping it, document the cost reason.
9. Run `terraform plan` and predict resource creation order.
10. Apply and inspect the VNet, subnets, NSGs, and routes using Azure CLI.
11. Add a new subnet named `ops` and confirm Terraform does not replace existing subnets.
12. Rename one subnet key and observe why stable keys matter.
13. Restore the correct key and destroy the lab.

### Validation Commands

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform state list
az network vnet show --name <vnet-name> --resource-group <resource-group-name>
az network vnet subnet list --vnet-name <vnet-name> --resource-group <resource-group-name> --output table
az network nsg list --resource-group <resource-group-name> --output table
az network route-table list --resource-group <resource-group-name> --output table
terraform plan
terraform destroy
```

### Troubleshooting Exercise

Choose one break/fix scenario:

- Duplicate two NSG rule priorities and explain the Azure or Terraform error.
- Point the app subnet rule to the wrong CIDR and diagnose the design mistake.
- Rename a `for_each` key and explain the planned destroy/create behavior.
- Enable NAT Gateway, then forget a subnet association and explain why egress is not controlled.

### Interview Questions

1. What is the difference between a VNet address space and subnet address prefixes?
2. Why are NSGs usually associated with subnets or NICs?
3. What is the difference between inbound and outbound NSG rules?
4. Why is `for_each` safer than `count` for named subnets?
5. What happens when a `for_each` key changes?
6. What is a route table used for?
7. What does NAT Gateway solve?
8. How would you troubleshoot a VM that cannot reach the internet?
9. How would you validate effective security rules in Azure?
10. Why does normal subnet-to-subnet traffic inside one VNet not need a custom route?
11. What parts of this design would change for production?

### Decision Note

Write a short note in `notes.md`:

```text
Network segmentation decision:

Allowed traffic:

Denied or intentionally omitted traffic:

NAT Gateway decision:

Production changes:
```

### Cleanup

Run:

```bash
terraform destroy
az resource list --resource-group <resource-group-name> --output table
```

If NAT Gateway was enabled, confirm public IP and NAT resources were also removed.

### Grading Rubric

| Area | Strong evidence |
|---|---|
| Azure networking | You can explain subnet, NSG, route table, and NAT purpose |
| Terraform modeling | Resources use stable keys and maps instead of fragile indexes |
| Troubleshooting | You can diagnose a failed or risky network plan |
| Validation | You inspect real Azure objects with CLI, not just Terraform output |
| Cost control | NAT Gateway and public IP choices are intentional |
| Interview readiness | You can explain tradeoffs clearly without reading notes |

### Hidden Solution Policy

Do not ask for a full solution first. Ask for hints, review, or grading before asking for the complete answer.

## Project 3 - Terraform State and Refactor Project

**Difficulty:** Advanced  
**Estimated time:** 8-12 hours  
**Cost:** Low. Uses a storage account for remote backend and one or two small imported resources.

### Scenario

Your team has Azure resources that were created manually. You need to bring them under Terraform without deleting or recreating them. You also need to move local state to an Azure Storage backend and practice safe refactoring.

### Architecture Target

- Azure Storage backend for Terraform state.
- Backend resource group, storage account, and container.
- One manually created resource imported into Terraform.
- One resource renamed using a moved block.
- One small refactor into a module without replacing Azure resources.

### Core Tasks

- Bootstrap backend resources.
- Configure remote state.
- Create a resource outside Terraform with Azure CLI.
- Write matching Terraform configuration.
- Import the resource.
- Verify state bindings.
- Rename Terraform addresses safely.
- Use `moved` blocks where appropriate.
- Document what would be dangerous in production.

### Services Covered

- Azure Storage
- Blob containers
- Resource groups
- Terraform backend locking

### Generate Later

After Projects 1-2, generate this project in full detail using your actual pain points: state, imports, naming, or modules.

## Project 4 - Reusable Platform Modules

**Difficulty:** Advanced  
**Estimated time:** 10-16 hours  
**Cost:** Low to moderate.

### Scenario

You need to turn repeated Terraform into reusable modules without hiding important Azure decisions.

### Architecture Target

- Foundation module for resource group, names, and tags.
- Network module for VNet, subnets, NSGs, and outputs.
- Optional diagnostics module.
- Environment folders for `dev` and `test`.

### Core Tasks

- Design module inputs and outputs.
- Add input validation.
- Keep outputs stable and keyed by names.
- Avoid modules reaching into each other directly.
- Use environment-specific variable files.
- Document module usage and limitations.

### Services Covered

- Resource groups
- VNets
- Subnets
- NSGs
- Log Analytics
- Diagnostic settings

### Generate Later

Generate this project after reviewing whether Projects 1-3 show enough comfort with locals, variables, and state.

## Project 5 - Identity, RBAC, and Key Vault Project

**Difficulty:** Advanced  
**Estimated time:** 8-14 hours  
**Cost:** Low.

### Scenario

An application identity needs least-privilege access to secrets and storage. Access is failing intermittently because the team does not understand managed identities, RBAC scopes, or propagation delay.

### Architecture Target

- User-assigned managed identity.
- Key Vault using RBAC authorization.
- One or more secrets.
- Storage account access through scoped role assignment.
- Diagnostic settings for Key Vault.

### Core Tasks

- Create managed identity.
- Assign least-privilege roles.
- Store and reference secrets safely.
- Debug forbidden access.
- Compare Key Vault access policy model vs RBAC model conceptually.
- Explain why secrets in Terraform state are risky.

### Services Covered

- Managed identities
- Azure RBAC
- Key Vault
- Storage account roles
- Diagnostic settings

### Generate Later

Generate in detail after you are comfortable with Terraform dependencies and Azure CLI inspection.

## Project 6 - Application Hosting Project

**Difficulty:** Advanced  
**Estimated time:** 10-18 hours  
**Cost:** Low to moderate.

### Scenario

You need to deploy a small internal application platform and prove that it is reachable only through the intended path, monitored, and documented.

### Architecture Target

Choose one implementation path:

- Low-cost VM path: Linux VM, NIC, NSG, cloud-init, managed disk, diagnostics.
- PaaS path: App Service or Container Apps, app settings, diagnostics, managed identity.

Default path: Linux VM, because it teaches networking, compute, identity, and diagnostics clearly.

### Core Tasks

- Deploy a tiny web service.
- Bootstrap it using cloud-init or VM extension.
- Attach diagnostics to Log Analytics.
- Validate access path and NSG behavior.
- Add outputs for operational handoff.
- Document how production hosting would differ.

### Services Covered

- Azure VM
- NIC
- Managed disk
- NSG
- Log Analytics
- Azure Monitor
- Optional App Service or Container Apps

### Generate Later

Generate after deciding whether your work is more VM-heavy or PaaS-heavy.

## Project 7 - Private Access and Operational Troubleshooting Project

**Difficulty:** Advanced to Expert  
**Estimated time:** 10-18 hours  
**Cost:** Low to moderate.

### Scenario

Security requires private access to a platform service. The team created a private endpoint, but DNS and permissions are broken. You need to diagnose and fix it.

### Architecture Target

- VNet and private subnet.
- Storage account or Key Vault.
- Private endpoint.
- Private DNS zone.
- VNet link.
- Diagnostic settings.
- A deliberate broken configuration for troubleshooting.

### Core Tasks

- Create private endpoint.
- Configure private DNS.
- Validate name resolution.
- Diagnose broken DNS link or missing record.
- Diagnose RBAC failure separately from network failure.
- Write a production troubleshooting runbook.

### Services Covered

- Private endpoints
- Private DNS zones
- VNets
- Storage or Key Vault
- RBAC
- Azure Monitor

### Generate Later

Generate after Project 5 so identity and access troubleshooting can be mixed with networking troubleshooting.

## Project 8 - CI/CD and Capstone Project

**Difficulty:** Expert  
**Estimated time:** 16-30 hours  
**Cost:** Low if resources are short-lived.

### Scenario

You inherit a messy Azure environment and need to rebuild a clean, reviewable Terraform workflow. The final deliverable should look like something you could discuss at work or in an interview.

### Architecture Target

- Environment folder structure.
- Remote state.
- Reusable modules.
- Network, storage, identity, and monitoring.
- Terraform validation pipeline.
- Plan artifact review.
- Optional security scan.
- Capstone documentation.

### Core Tasks

- Build `dev` and `test` environment layouts.
- Run `terraform fmt`, `validate`, and `plan` in CI.
- Publish or store plan output.
- Add policy or security scan step.
- Simulate drift.
- Create a final handoff document.

### Services Covered

- Azure Storage backend
- Resource groups
- Networking
- Storage
- Managed identity
- Key Vault
- Log Analytics
- Azure Monitor
- CI/CD platform of choice

### Generate Later

Generate only after Projects 1-7. This should adapt to your actual weak spots.

## Checkpoints

Use these checkpoints after every two projects.

### Checkpoint 1 - After Projects 1 and 2

You should be able to:

- Predict simple Terraform plans.
- Explain Azure resource naming constraints.
- Inspect Terraform state.
- Build a segmented VNet.
- Explain NSGs and route tables.
- Use Azure CLI for validation.

### Checkpoint 2 - After Projects 3 and 4

You should be able to:

- Use remote state safely.
- Import resources without replacement.
- Refactor Terraform addresses safely.
- Design small reusable modules.
- Explain module input/output tradeoffs.

### Checkpoint 3 - After Projects 5 and 6

You should be able to:

- Explain managed identity and RBAC scopes.
- Debug Key Vault access issues.
- Deploy a small compute/app workload.
- Connect diagnostics to Log Analytics.
- Separate network failures from identity failures.

### Checkpoint 4 - After Projects 7 and 8

You should be able to:

- Troubleshoot private endpoint DNS.
- Review Terraform plans in a delivery workflow.
- Explain drift and remediation.
- Present a complete Azure/Terraform project in an interview.
- Identify what should come next before AKS.

## Submission Package For Each Project

For every project, keep:

- Terraform code.
- `README.md`.
- `notes.md`.
- Plan prediction notes.
- Validation command outputs or summarized observations.
- Screenshots only when they prove something useful.
- Cost and cleanup note.
- Interview answer notes.

## Overall Grading Rubric

| Level | Evidence |
|---|---|
| Basic pass | Code applies and destroys successfully |
| Solid | You can validate resources in Azure and explain what Terraform created |
| Work-ready | You can debug a broken plan, state issue, Azure permission issue, or networking issue |
| Interview-ready | You can explain tradeoffs, risks, production changes, and operational checks |
| Strong | You can turn the project into reusable patterns without hiding important decisions |

## What Comes After This Curriculum

After the 8 projects:

1. Learn Kubernetes basics separately: pods, deployments, services, ingress, config maps, secrets, volumes, probes, namespaces, RBAC.
2. Build local Kubernetes labs with `kind` or `minikube`.
3. Then start AKS with Terraform.
4. AKS labs should cover cluster creation, node pools, networking, identity, ingress, monitoring, upgrades, and troubleshooting.

Do not rush to AKS before you can confidently explain Azure networking, identity, monitoring, and Terraform state.
