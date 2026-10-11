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
| 6 | Application hosting | Linux VM, managed identity, Key Vault, AMA/Log Analytics; optional storage | cloud-init, existing-resource lookups, DCR, operational outputs |
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
**Cost:** Low to moderate. VNets, NSGs, resource groups, and Log Analytics are low cost, but diagnostics can create ingestion charges. Destroy after validation.

### Scenario

Your team has repeated the same Terraform patterns across multiple labs: resource groups, names, tags, VNets, subnets, NSGs, and optional diagnostics. The next step is to turn those patterns into reusable modules while keeping important Azure design choices visible at the environment layer.

The goal is not to hide complexity. The goal is to create modules with clear inputs, stable outputs, validation, and predictable behavior across `dev` and `test`.

### Architecture Target

Create:

- A `foundation` module for the resource group, standardized name prefix, and common tags.
- A `network` module for one VNet, multiple subnets, one NSG per subnet, and NSG associations.
- An optional `diagnostics` module for Log Analytics and diagnostic settings where supported.
- Two environment roots: `dev` and `test`.
- Environment-specific variable files so `dev` and `test` use the same modules with different inputs.
- Stable outputs keyed by logical names, such as subnet name and NSG name.

Module dependency rule:

```text
env root -> foundation module
env root -> network module
env root -> diagnostics module
```

Modules must not reach into each other directly. Pass values through the environment root module.

### Azure Services Practiced

- Resource groups
- Virtual Networks
- Subnets
- Network Security Groups
- NSG security rules
- Log Analytics workspace
- Azure Monitor diagnostic settings
- Tags

### Terraform Skills Practiced

- Local modules
- Module inputs and outputs
- Input validation
- `for_each` with stable keys
- Maps and objects
- Optional module creation with `count`
- Environment-specific `.tfvars`
- Stable output contracts
- Refactoring repeated code into modules

### Starting Repository Shape

```text
04-reusable-platform-modules/
├── README.md
├── notes.md
├── modules/
│   ├── foundation/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── network/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   └── diagnostics/
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
└── envs/
    ├── dev/
    │   ├── versions.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars.example
    └── test/
        ├── versions.tf
        ├── providers.tf
        ├── variables.tf
        ├── main.tf
        ├── outputs.tf
        └── terraform.tfvars.example
```

### Starter Code

Create the files yourself from this starter. Some pieces are intentionally incomplete.

```hcl
# envs/dev/versions.tf and envs/test/versions.tf
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
# envs/dev/providers.tf and envs/test/providers.tf
provider "azurerm" {
  features {}
}
```

```hcl
# modules/foundation/variables.tf
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
```

```hcl
# modules/foundation/main.tf
locals {
  name_prefix = "${var.prefix}-${var.environment}"

  common_tags = merge(
    {
      environment = var.environment
      owner       = var.owner
      managed_by  = "terraform"
      project     = "azure-terraform-hands-on"
    },
    var.extra_tags
  )
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}
```

```hcl
# modules/foundation/outputs.tf
# TODO: Output:
# - resource group name
# - resource group ID
# - location
# - name prefix
# - common tags
```

```hcl
# modules/network/variables.tf
variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "Provide at least one VNet address space."
  }
}

variable "subnets" {
  description = "Subnet definitions keyed by subnet name."
  type = map(object({
    address_prefixes = list(string)
    inbound_rules = optional(list(object({
      name                       = string
      priority                   = number
      protocol                   = string
      source_address_prefix      = string
      destination_port_range     = string
      destination_address_prefix = optional(string, "*")
      access                     = optional(string, "Allow")
    })), [])
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

```hcl
# modules/network/main.tf
resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# TODO: Create subnets with for_each.
# TODO: Create one NSG per subnet with for_each.
# TODO: Generate inbound security rules from each subnet's inbound_rules list.
# TODO: Associate each subnet with its matching NSG.
# TODO: Keep resource addresses stable when new subnet keys are added.
```

```hcl
# modules/network/outputs.tf
# TODO: Output:
# - VNet name
# - VNet ID
# - subnet IDs as a map keyed by subnet name
# - NSG IDs as a map keyed by subnet name
```

```hcl
# modules/diagnostics/variables.tf
variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "diagnostic_targets" {
  description = "Map of diagnostic target name to Azure resource ID."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

```hcl
# modules/diagnostics/main.tf
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

# TODO: Add diagnostic settings only for resource types you verify support
# the chosen log and metric categories.
```

```hcl
# envs/dev/main.tf
module "foundation" {
  source = "../../modules/foundation"

  prefix      = var.prefix
  environment = "dev"
  location    = var.location
  owner       = var.owner
}

module "network" {
  source = "../../modules/network"

  name_prefix         = module.foundation.name_prefix
  resource_group_name = module.foundation.resource_group_name
  location            = module.foundation.location
  address_space       = var.address_space
  subnets             = var.subnets
  tags                = module.foundation.tags
}

# TODO: Optionally call diagnostics with count when enable_diagnostics is true.
```

```hcl
# envs/dev/terraform.tfvars.example
prefix        = "tfaz04"
location      = "eastus"
owner         = "your-name"
address_space = ["10.44.0.0/16"]

subnets = {
  web = {
    address_prefixes = ["10.44.1.0/24"]
    inbound_rules = [
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
    address_prefixes = ["10.44.2.0/24"]
    inbound_rules = [
      {
        name                   = "AllowAppFromWeb"
        priority               = 100
        protocol               = "Tcp"
        source_address_prefix  = "10.44.1.0/24"
        destination_port_range = "8080"
      }
    ]
  }
}

enable_diagnostics = true
```

Create `envs/test` with the same root module shape, but use `environment = "test"`, a different address space such as `10.45.0.0/16`, and at least one additional subnet such as `data`.

### Core Tasks

1. Design the `foundation`, `network`, and `diagnostics` module APIs before writing resources.
2. Implement the foundation module and confirm outputs can be consumed by the root module.
3. Implement the network module using `for_each` for subnets and NSGs.
4. Generate NSG rules from subnet input data.
5. Add validation for prefix, environment, address space, and diagnostics retention.
6. Create `dev` and `test` environment roots using the same modules.
7. Keep all environment-specific CIDRs and NSG rules in `.tfvars` files.
8. Add the optional diagnostics module and enable it in `dev`.
9. Keep diagnostics disabled in `test` first, then enable it and compare the plan.
10. Add a new subnet to `test` and confirm existing subnet addresses are not replaced.
11. Rename a subnet key and explain the destroy/create behavior.
12. Document module limitations and production changes in `notes.md`.

### Validation Commands

Run from `envs/dev`, then repeat from `envs/test`:

```bash
terraform init
terraform fmt -check -recursive ../..
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output
terraform state list
terraform state show module.foundation.azurerm_resource_group.this
az group show --name <resource-group-name>
az network vnet show --name <vnet-name> --resource-group <resource-group-name>
az network vnet subnet list --vnet-name <vnet-name> --resource-group <resource-group-name> --output table
az network nsg list --resource-group <resource-group-name> --output table
az monitor log-analytics workspace list --resource-group <resource-group-name> --output table
terraform destroy
```

### Troubleshooting Exercise

Choose two break/fix scenarios:

- Remove one required module output and observe how the root module fails.
- Pass a subnet map with duplicate NSG rule priorities and explain the Azure or provider error.
- Rename a subnet key and explain why Terraform plans a replacement.
- Enable diagnostics for a resource with unsupported categories and diagnose the failure.
- Change the module source path to a wrong relative path and explain the init error.

Then answer:

- Did the failure happen during init, validate, plan, or apply?
- Was the problem in module wiring, Terraform type validation, Azure rules, or provider behavior?
- What would make the module safer for other teams?

### Interview Questions

1. When should Terraform code become a module?
2. What should a module output, and what should it hide?
3. Why should outputs be keyed by stable names instead of list indexes?
4. What is the risk of putting too much logic inside a module?
5. How do root modules and child modules differ?
6. Why should modules not reach into each other directly?
7. How does `for_each` behave when a map key is renamed?
8. How do `.tfvars` files help separate environment configuration from reusable logic?
9. What makes a module interface hard to change later?
10. How would you version a module in a real team?
11. What diagnostics would you enable in production, and why?
12. What cost risks come with Log Analytics?

### Decision Note

Write a short note in `notes.md`:

```text
Module boundaries:

Values owned by foundation:

Values owned by network:

Values kept in environment roots:

Diagnostics decision:

What would change before production:
```

### Cleanup

Destroy both environments:

```bash
cd envs/dev
terraform destroy

cd ../test
terraform destroy
```

Then verify no resources remain:

```bash
az group show --name <dev-resource-group-name>
az group show --name <test-resource-group-name>
```

If either resource group still exists, list remaining resources before manual cleanup.

### Grading Rubric

| Area | Strong evidence |
|---|---|
| Module design | Inputs are explicit, outputs are stable, and modules have clear ownership |
| Terraform modeling | Subnets and NSGs use `for_each` with stable keys |
| Environment separation | Dev and test differ through variables, not copied module logic |
| Validation | Bad inputs fail early with useful validation messages |
| Azure understanding | You can explain VNet, subnet, NSG, and diagnostics choices |
| Refactor safety | Adding keys does not replace unrelated resources |
| Cost control | Diagnostics and Log Analytics choices are intentional |
| Documentation | `notes.md` explains module limitations and production changes |

### Hidden Solution Policy

Do not ask for a full solution first. Ask for hints, review, or grading before asking for the complete answer.

## Project 5 - Identity, RBAC, and Key Vault Project

**Difficulty:** Advanced  
**Estimated time:** 8-14 hours  
**Cost:** Low. Key Vault, managed identity, role assignments, storage, and Log Analytics are low cost, but diagnostics can create ingestion charges. Destroy after validation.

### Scenario

A workload team is preparing to deploy an application. The application needs an identity that can read secrets from Key Vault and read blobs from a storage account. The team has been assigning broad roles at resource group scope because access failures are hard to diagnose and RBAC propagation is confusing.

Your job is to build a small identity and secrets foundation with Terraform, prove the role assignments exist at the correct scopes, and explain what Terraform state does and does not safely protect.

### Architecture Target

Create:

- One resource group.
- One user-assigned managed identity for a future application.
- One storage account and one private blob container.
- One Key Vault using Azure RBAC authorization, not the legacy access policy model.
- One lab secret in Key Vault.
- A documented permission path for the Terraform-running identity to create the lab secret.
- A role assignment that lets the managed identity read Key Vault secrets.
- A role assignment that lets the managed identity read blobs from the storage account or container.
- Optional Log Analytics workspace.
- Diagnostic settings for Key Vault when diagnostics are enabled.

Important boundary:

```text
Terraform creates the identity and assignments.
Lab 6 will attach an identity to compute and test runtime access from an application host.
```

In this lab, you validate the RBAC model, scopes, and Azure resources. You do not need to build a VM or app just to use the managed identity.

### Azure Services Practiced

- Microsoft Entra ID managed identities
- Azure RBAC role assignments
- Key Vault with RBAC authorization
- Key Vault secrets
- Storage accounts
- Blob containers
- Log Analytics workspace
- Azure Monitor diagnostic settings

### Terraform Skills Practiced

- Identity resources and `principal_id`
- Role assignment scopes
- Data sources such as `azurerm_client_config`
- Sensitive variables and sensitive outputs
- Understanding secret values in Terraform state
- Dependency timing and RBAC propagation
- Optional resources with `count`
- Validation for Azure naming constraints

### Starting Repository Shape

```text
05-identity-rbac-keyvault/
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
├── notes.md
└── evidence.md
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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

```hcl
# providers.tf
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
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
```

```hcl
# terraform.tfvars.example
prefix           = "tfaz05"
location         = "eastus"
environment      = "dev"
owner            = "your-name"
lab_secret_value = "example-lab-secret-do-not-use-real-secrets"

enable_diagnostics = true
```

```hcl
# main.tf
data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  name_prefix = "${var.prefix}-${var.environment}"

  common_tags = {
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    project     = "azure-terraform-hands-on"
  }

  # TODO: Make these names Azure-valid and globally unique where required.
  storage_account_name = replace("${var.prefix}${var.environment}${random_string.suffix.result}", "-", "")
  key_vault_name       = "${var.prefix}-${var.environment}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name_prefix}-identity-rg"
  location = var.location
  tags     = local.common_tags
}

# TODO: Create a user-assigned managed identity.
# Requirements:
# - Name should identify the future app workload.
# - Tags applied.

# TODO: Create a storage account.
# Requirements:
# - Standard performance
# - Locally redundant storage
# - HTTPS traffic only
# - Public blob access disabled
# - Tags applied

# TODO: Create one private blob container named app-data.

# TODO: Create a Key Vault.
# Requirements:
# - Use the current tenant ID from azurerm_client_config.
# - Use RBAC authorization.
# - Use a low-cost SKU.
# - Keep purge protection disabled for the lab unless your subscription policy requires it.
# - Tags applied.

# TODO: Decide how the Terraform-running identity can create the lab secret.
# Option A:
# - Confirm your signed-in user or service principal already has Key Vault data-plane permissions.
# Option B:
# - Create a narrowly scoped role assignment for data.azurerm_client_config.current.object_id.
# Suggested role for this lab:
# - Key Vault Secrets Officer
# Suggested scope:
# - The Key Vault resource ID
# Note:
# - You may need to wait for RBAC propagation before the secret can be created.

# TODO: Create a lab secret in Key Vault.
# Requirements:
# - Name: app-config
# - Value from var.lab_secret_value
# - Do not use a real secret.
# - Explain in notes.md why this still appears in Terraform state.

# TODO: Assign the managed identity a least-privilege Key Vault role.
# Suggested role:
# - Key Vault Secrets User
# Suggested scope:
# - The Key Vault resource ID

# TODO: Assign the managed identity a least-privilege storage data role.
# Suggested role:
# - Storage Blob Data Reader
# Suggested scope:
# - Storage account or container scope; document your choice.

# TODO: Optionally create Log Analytics when enable_diagnostics is true.

# TODO: Optionally create diagnostic settings for Key Vault.
# Capture at least audit events where supported by your provider/resource combination.
```

```hcl
# outputs.tf
# TODO: Output:
# - resource group name
# - managed identity name
# - managed identity principal ID
# - Key Vault name
# - Key Vault ID
# - storage account name
# - storage account ID
# - blob container name
# - role assignment IDs
#
# Do not output secret values.
```

### Core Tasks

1. Before writing resources, create a prediction table in `notes.md`.
2. Predict which values are known before apply and which are unknown until apply.
3. Write down the intended RBAC scopes before creating the role assignments.
4. Implement the resource group and common tags.
5. Implement the managed identity.
6. Implement the storage account and private blob container.
7. Implement Key Vault with RBAC authorization enabled.
8. Decide how the Terraform-running identity is allowed to create the lab secret.
9. Add one low-risk lab secret and explain the state risk.
10. Assign `Key Vault Secrets User` to the managed identity at the narrowest practical scope.
11. Assign `Storage Blob Data Reader` to the managed identity at the narrowest practical scope.
12. Add diagnostics for Key Vault if enabled.
13. Run `terraform plan -out=tfplan` and compare the plan with your prediction table.
14. Apply the plan.
15. Validate the identity, Key Vault, storage account, and role assignments with Azure CLI.
16. Wait for RBAC propagation if role assignments do not appear immediately.
17. Inspect Terraform state and identify which values would be dangerous in a real project.
18. Run one troubleshooting exercise.
19. Destroy the resources and confirm the resource group is gone.

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
terraform state show azurerm_user_assigned_identity.<name>
terraform state show azurerm_key_vault.<name>
terraform state show azurerm_key_vault_secret.<name>
az group show --name <resource-group-name>
az identity show --name <identity-name> --resource-group <resource-group-name>
az keyvault show --name <key-vault-name> --resource-group <resource-group-name>
az keyvault secret show --vault-name <key-vault-name> --name app-config
az storage account show --name <storage-account-name> --resource-group <resource-group-name>
az storage container show --name app-data --account-name <storage-account-name> --auth-mode login
az role assignment list --assignee <terraform-runner-object-id> --scope <key-vault-id> --output table
az role assignment list --assignee <managed-identity-principal-id> --scope <key-vault-id> --output table
az role assignment list --assignee <managed-identity-principal-id> --scope <storage-scope-id> --output table
az monitor diagnostic-settings list --resource <key-vault-id>
terraform destroy
```

If `az keyvault secret show` fails for your own signed-in user, diagnose whether your current user has Key Vault data-plane permissions. Do not solve that by granting broad subscription Owner or Contributor access. Explain the correct minimum role and scope.

### Troubleshooting Exercise

Choose at least one break/fix scenario:

- Assign the Key Vault role at the resource group scope, then move it to the Key Vault scope and explain least privilege.
- Assign `Reader` instead of `Key Vault Secrets User` and explain why management-plane read is not the same as secret read.
- Disable Key Vault RBAC authorization and observe how the access model changes.
- Remove the storage data role assignment and explain why control-plane access to the storage account is not enough to read blobs.
- Change the Key Vault name to an invalid value and identify whether Terraform catches the issue before Azure rejects it.
- Create the role assignment and immediately test access, then document any RBAC propagation delay.

Record:

```text
What I broke:

Where it failed: validate / plan / apply / Azure CLI validation

Error or symptom:

Root cause:

Fix:

Production lesson:
```

### Interview Questions

1. What is a user-assigned managed identity?
2. How is a user-assigned managed identity different from a system-assigned managed identity?
3. What is the difference between Azure RBAC and Key Vault access policies?
4. Why does Key Vault have both management-plane and data-plane permissions?
5. Why is `Reader` not enough to read Key Vault secrets?
6. What is an RBAC scope?
7. Why should role assignments use the narrowest practical scope?
8. What is RBAC propagation delay, and how would you troubleshoot it?
9. Why can Terraform state contain secrets even when variables are marked sensitive?
10. Should Terraform create production secret values? Why or why not?
11. What does `principal_id` represent for a managed identity?
12. Why might a role assignment need an explicit dependency?
13. What storage role allows reading blob data?
14. How would Lab 6 prove the managed identity can actually read a secret at runtime?

### Decision Note

Write a short note in `notes.md`:

```text
Identity decision:

Key Vault authorization model:

Key Vault secret handling:

RBAC scopes chosen:

Storage data access decision:

Terraform state risks:

What operators may change manually:

Production changes:
```

### Cleanup

Run:

```bash
terraform destroy
az group show --name <resource-group-name>
```

If the resource group still exists, list remaining resources:

```bash
az resource list --resource-group <resource-group-name> --output table
```

If Key Vault deletion or purge behavior causes cleanup problems, document what happened before taking manual action.

### Grading Rubric

| Area | Strong evidence |
|---|---|
| Identity understanding | You can explain managed identity purpose, `principal_id`, and future runtime usage |
| RBAC correctness | Roles are least-privilege and scoped narrowly |
| Key Vault model | RBAC authorization is used intentionally and contrasted with access policies |
| State safety | You can show where secret material appears in state and explain the risk |
| Terraform modeling | Names are valid, dependencies are clear, outputs avoid secret values |
| Azure validation | CLI evidence confirms identity, Key Vault, storage, diagnostics, and role assignments |
| Troubleshooting | You diagnose permission failures without adding broad roles |
| Cost and cleanup | Resources are low-cost and destroyed after validation |
| Interview readiness | You can explain control plane vs data plane without reading from notes |

### Hidden Solution Policy

Do not ask for a full solution first. Ask for hints, review, or grading before asking for the complete answer.

## Project 6 - Application Hosting Project

**Difficulty:** Advanced  
**Estimated time:** 10-18 hours  
**Cost:** Low to moderate; VM compute, managed disks, a Standard public IP, and log ingestion are billable. Check current regional pricing before apply and destroy after validation.

### Scenario

Your team needs a small internal web service and an operational handoff. Build a Linux VM with Terraform, bootstrap the application, and prove that operators can reach it only through the intended path. Use the managed identity from Lab 5 to read its dummy Key Vault secret from the running application. Send guest logs to Log Analytics and diagnose failures using evidence.

The default path is a Linux VM, as specified in the curriculum. App Service is an optional comparison after completing the VM path. The Terraform and application files are intentionally incomplete; completing TODOs is the assignment.

### Architecture Target

```text
Operator public IPv4 /32
    | SSH TCP/22 with public-key authentication
    v
Standard public IP -> NSG -> NIC -> Ubuntu Linux VM
                                      |
                                      +-- app listens on 127.0.0.1:8080
                                      |   reached through an SSH local tunnel
                                      |
                                      +-- Lab 5 user-assigned managed identity
                                      |       -> IMDS token -> Key Vault dummy secret
                                      |
                                      +-- rsyslog -> Azure Monitor Agent
                                              -> DCR + association -> Log Analytics
```

Create these resources in a separate Lab 6 resource group:

- One VNet and one app subnet with non-overlapping address ranges.
- One subnet NSG permitting SSH only from your current public IPv4 `/32`.
- One Standard, Static IPv4 public IP and one NIC with a private IP.
- One small Ubuntu LTS VM with SSH-key authentication and a Standard_LRS managed OS disk.
- Cloud-init bootstrap, an unprivileged application service, and Azure-managed boot diagnostics.
- One Log Analytics workspace with 30-day retention, the Azure Monitor Linux Agent extension, a Linux data collection rule (DCR), and a VM association.
- Read-only Terraform metadata lookups for the existing Lab 5 managed identity and Key Vault.

Attach the existing identity to the VM. Lab 5 continues to own its identity, vault, secret, storage, and RBAC assignments. Lab 6 owns its new network, VM, and monitoring resources. Do not import the same resources into a second state.

The baseline uses public-IP egress for package downloads, Key Vault's public endpoint, and monitoring. Microsoft documents a NIC-associated public IP as an explicit outbound method. New VNet defaults depend on API version, including the change for APIs released after March 31, 2026; do not rely on implicit outbound access. See [Azure outbound connectivity](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access).

This is a restricted SSH access lab. The VM has a public IP; the app binds to loopback and has no public HTTP allow rule. Key Vault private endpoints and private DNS are reserved for Lab 7.

### Azure Services Practiced

- Azure VM, NIC, Standard public IP, and managed OS disk.
- VNet, subnet, NSG association, effective security rules, and explicit egress.
- User-assigned managed identity, IMDS, Key Vault data-plane RBAC.
- Azure Monitor, Log Analytics, Azure Monitor Agent (AMA), DCR, and syslog.
- Optional managed data disk and managed-identity Blob Storage access.

### Terraform Skills Practiced

- Referencing existing resources with data sources without changing ownership.
- Mapping identity resource ID, client ID, and principal ID to their uses.
- Modeling dependencies and distinguishing ordering from propagation delays.
- Rendering cloud-init with `templatefile`, `yamlencode`, and `base64encode`.
- Reviewing replacement behavior and separating infrastructure from guest health.
- Creating useful operational outputs and comparing config, state, and Azure.

### Prerequisites and Ownership

1. Read Lab 5's `README.md`, `notes.md`, and `evidence.md`.
2. Confirm its managed identity, RBAC-enabled Key Vault, and enabled dummy secret still exist. If destroyed, recreate them from Lab 5 before starting. A working Lab 5 plan does not prove runtime access.
3. Confirm `Key Vault Secrets User` is granted to the managed identity at the intended vault or narrower secret scope. Use `principal_id` for RBAC, identity resource ID for VM attachment, and `client_id` for selecting the identity in IMDS.
4. Confirm the Terraform runner can create the Lab 6 resources and attach the existing identity. This management-plane permission is separate from the app's secret-read permission.
5. Check Azure subscription context, VM quota, and image/SKU availability in `eastus`. Default to `Standard_B1s`; if unavailable or memory is insufficient for the app and AMA, choose another small SKU and record the cost decision.
6. Have an existing SSH key pair. Pass only the public-key path to Terraform. Find your current public IPv4 address and supply `/32`; the example address will not allow real access.
7. Key Vault networking must permit the VM's chosen outbound path. A token and correct RBAC cannot bypass a firewall. Keep only dummy data in this temporary lab.

Do not read the secret value with a Terraform data source or pass it through cloud-init. Lab 6 needs only the vault URI, secret name, and identity metadata. Destroy Lab 6 before destroying Lab 5.

### Starting Repository Shape

```text
06-application-hosting/
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
├── cloud-init.yaml.tftpl
├── app/
│   └── app.py
├── notes.md
└── evidence.md
```

### Starter Code

The checked-in files provide provider requirements, typed inputs, naming and tag locals, Lab 5 metadata lookups, and TODOs for resources, cloud-init, outputs, and the application. Use Terraform `>= 1.6` and AzureRM `~> 3.0` for consistency with this workspace. Read documentation for the locked provider version when implementing resources.

Copy `terraform.tfvars.example` to a local `terraform.tfvars`. Replace the documentation-only source address, SSH public-key path, owner, and Lab 5 names. Commit only the example file. Fill in `notes.md` before running a plan.

Formatting and validation can succeed on an incomplete scaffold. A successful plan with only data-source reads is not a completed lab.

#### `versions.tf`

```hcl
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

#### `providers.tf`

```hcl
provider "azurerm" {
  features {}
}

# Use Azure CLI authentication and the intended subscription context.
# Do not put credentials in this file.
```

#### `variables.tf`

```hcl
variable "prefix" {
  description = "Short lowercase prefix used in Lab 6 resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,10}$", var.prefix))
    error_message = "Use 3-11 lowercase letters or numbers, starting with a letter."
  }
}

variable "location" {
  description = "Region for the Lab 6 VM, network, and monitoring resources."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Lab environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test"], var.environment)
    error_message = "Environment must be dev or test."
  }
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "vm_size" {
  description = "Small VM SKU; confirm regional availability and subscription quota."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux administrator account; use SSH keys and disable password authentication."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to an existing SSH public key, never a private key."
  type        = string
}

variable "admin_source_cidr" {
  description = "Your current public IPv4 address with /32; sole allowed SSH source."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_source_cidr)) &&
      can(regex("/32$", var.admin_source_cidr))
    )
    error_message = "Provide one valid IPv4 /32, not a broad internet range."
  }
}

variable "vnet_address_space" {
  description = "Non-overlapping address space for the Lab 6 VNet."
  type        = list(string)
  default     = ["10.60.0.0/16"]
}

variable "app_subnet_prefixes" {
  description = "Address prefixes within the Lab 6 VNet for the VM subnet."
  type        = list(string)
  default     = ["10.60.1.0/24"]
}

variable "identity_resource_group_name" {
  description = "Existing Lab 5 resource group containing the identity and Key Vault."
  type        = string
}

variable "managed_identity_name" {
  description = "Existing Lab 5 user-assigned managed identity name."
  type        = string
}

variable "key_vault_name" {
  description = "Existing Lab 5 RBAC-enabled Key Vault name."
  type        = string
}

variable "secret_name" {
  description = "Existing dummy secret to read at runtime; no secret value goes into Lab 6 inputs."
  type        = string
  default     = "app-config"
}
```

#### `main.tf`

```hcl
locals {
  name_prefix = "${var.prefix}-${var.environment}"

  common_tags = {
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    project     = "azure-terraform-hands-on"
    lab         = "06"
  }
}

# Read metadata only. Lab 5 remains the owner of these resources and RBAC grants.
data "azurerm_user_assigned_identity" "app" {
  name                = var.managed_identity_name
  resource_group_name = var.identity_resource_group_name
}

data "azurerm_key_vault" "app" {
  name                = var.key_vault_name
  resource_group_name = var.identity_resource_group_name
}

# TODO: Create a separate Lab 6 resource group with common tags.

# TODO: Create a VNet, one app subnet, and one NSG.
# - SSH TCP/22 allowed only from var.admin_source_cidr.
# - No inbound allow rules for TCP/80, TCP/443, or TCP/8080.
# - Associate the NSG with the app subnet.
# - Explain default NSG rules and the actual app listening address.

# TODO: Create one Standard, Static public IPv4 address and one NIC.
# - NIC references the subnet and public IP; private IP allocation is Dynamic.
# - The public IP provides explicit egress and restricted SSH ingress.
# - No NAT Gateway, Bastion, or load balancer in the baseline.

# TODO: Create azurerm_linux_virtual_machine.app.
# - Small SKU from var.vm_size; Ubuntu LTS image verified for this region.
# - SSH public key via file(pathexpand(var.ssh_public_key_path)).
# - Password authentication disabled; managed OS disk using Standard_LRS.
# - Attach data.azurerm_user_assigned_identity.app.id as UserAssigned identity.
# - Enable boot diagnostics with Azure-managed storage.
# - Base64-encode templatefile("${path.module}/cloud-init.yaml.tftpl", {...}).
# - Supply metadata only: identity client ID, vault URI, secret name, app source.
# - Ensure subnet NSG association exists before VM bootstrap starts.

# TODO: Create a PerGB2018 Log Analytics workspace with 30-day retention.

# TODO: Install AzureMonitorLinuxAgent via azurerm_virtual_machine_extension.
# - Publisher: Microsoft.Azure.Monitor; type: AzureMonitorLinuxAgent.
# - Configure its authentication to use the attached user-assigned identity.
# - Verify the current supported extension version in the Azure region.

# TODO: Create a Linux azurerm_monitor_data_collection_rule.
# - Collect user-facility syslog at Info and more severe levels.
# - Route Microsoft-Syslog to the Log Analytics destination.
# - Create azurerm_monitor_data_collection_rule_association for the VM.
# - Enable rsyslog in the guest and verify an actual event reaches Syslog.

# TODO (stretch): Add a small Standard_LRS managed data disk and attachment.
# Mount by UUID and explain persistence across VM rebuilds; never use the temp disk.
```

#### `outputs.tf`

```hcl
# TODO: Add operational outputs with descriptions:
# - resource_group_name
# - vm_name and vm_id
# - nic_name
# - public_ip_address and private_ip_address
# - vnet_name, subnet_id, and nsg_name
# - managed_identity_client_id and managed_identity_principal_id
# - key_vault_name and key_vault_uri
# - log_analytics_workspace_id (Azure resource ID)
# - log_analytics_workspace_customer_id (workspace GUID for CLI queries)
# - ssh_command and ssh_tunnel_command (no private key contents)
# - local_app_url: http://127.0.0.1:8080
#
# Do not output tokens or secret values.
```

#### `terraform.tfvars.example`

```hcl
prefix              = "tfaz06"
location            = "eastus"
environment         = "dev"
owner               = "your-name"
vm_size             = "Standard_B1s"
admin_username      = "azureuser"
ssh_public_key_path = "~/.ssh/id_ed25519.pub"

# Documentation-only address. Replace with your current public IPv4 /32.
admin_source_cidr = "203.0.113.10/32"

vnet_address_space  = ["10.60.0.0/16"]
app_subnet_prefixes = ["10.60.1.0/24"]

# Replace with metadata from your existing Lab 5 resources.
identity_resource_group_name = "your-lab-05-resource-group"
managed_identity_name        = "your-lab-05-managed-identity"
key_vault_name               = "your-lab-05-key-vault"
secret_name                  = "app-config"
```

#### `cloud-init.yaml.tftpl`

```yaml
#cloud-config
# TODO: Install python3 and rsyslog; enable the syslog daemon.
# TODO: Create a dedicated unprivileged service account for the app.
# TODO: Use write_files to place app_source at /opt/lab06/app.py.
# TODO: Write a non-secret configuration file containing only:
# - managed_identity_client_id
# - key_vault_uri
# - secret_name
# TODO: Write a systemd unit that starts the app after network-online.target,
# runs as the dedicated account, restarts on failure, and sends logs to syslog.
# TODO: Use runcmd to reload systemd, enable and start the unit.
# TODO: Emit a user.info syslog marker tagged lab06 after bootstrap completes.
#
# Hint: yamlencode() can serialize multiline file content in a Terraform template.
# Keep tokens, secret values, and private SSH keys out of custom_data.
```

#### `app/app.py`

```python
"""Lab 6 app exercise. Implement the runtime behavior described in README.md."""

# TODO: Serve HTTP on 127.0.0.1:8080 as an unprivileged service account.
# TODO: GET / returns a simple lab/version response.
# TODO: GET /health returns HTTP 200 without calling Key Vault.
# TODO: GET /ready obtains a token from IMDS using the UAMI client ID,
# reads the dummy secret from Key Vault, discards its value, and returns
# only {"secret_read": true} on success (HTTP 200), false on failure (HTTP 503).
# TODO: Use finite network timeouts and bounded retries for transient failures.
# TODO: Log a sanitized status and correlation ID to user-facility syslog.
# Never log tokens, authorization headers, or Key Vault response bodies.
# Do not use developer credentials, az login, or a stored client secret.


if __name__ == "__main__":
    raise SystemExit("Implement the Lab 6 app TODOs before deployment.")
```

### Application Contract

Implement a tiny Python service; the standard library is sufficient. Run it as a dedicated unprivileged account and bind to `127.0.0.1:8080`.

| Endpoint | Required behavior | Evidence |
|---|---|---|
| `GET /` | HTTP 200 with a lab/version response | Confirms the deployed app version |
| `GET /health` | HTTP 200 when the process is alive; no dependency calls | Separates app health from Key Vault failures |
| `GET /ready` | Acquire an IMDS token, read the dummy secret, discard its value; HTTP 200 with `{"secret_read": true}` on success, HTTP 503 with `{"secret_read": false}` on failure | Proves the attached identity can access the data plane |

For `/ready`, use the VM-local IMDS endpoint `http://169.254.169.254/metadata/identity/oauth2/token`, `Metadata: true`, API version `2018-02-01`, the attached UAMI client ID, and the Key Vault token resource `https://vault.azure.net`. Bypass HTTP proxies for IMDS. Call the vault's HTTPS secret endpoint with the bearer token and a supported Key Vault API version. Keep tokens and secret values in process memory only. See [VM managed identities and IMDS](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-managed-identities-work-vm).

Use finite timeouts and bounded retries for transient failures. Log sanitized success/failure, status codes, and a correlation ID to the syslog `user` facility. Do not log response bodies, tokens, authorization headers, or secret values. Do not use `az login`, your laptop's credentials, storage account keys, or a saved client secret inside the service.

### Core Tasks

#### Part A - Predict and Build the Network

1. Predict all created resources and external metadata reads in `notes.md`. Identify known values, computed IDs/IPs, and replacement risks.
2. Describe the access path, expected NSG behavior, egress path, and Lab 5 ownership boundary.
3. Create the Lab 6 resource group, VNet, subnet, NSG, and association. Use stable names and common tags.
4. Permit inbound TCP/22 only from `admin_source_cidr`. Do not add inbound HTTP/HTTPS/8080 allow rules. Explain default NSG rules, including the default VNet allowance.
5. Create the Standard Static public IP and NIC. Explain why a private NIC address alone does not guarantee outbound connectivity.

#### Part B - Bootstrap and Prove Runtime Identity

1. Implement the VM with an Ubuntu LTS image available in the chosen region, a small SKU, SSH public key, disabled password authentication, and a managed OS disk.
2. Attach the Lab 5 UAMI and enable Azure-managed boot diagnostics.
3. Complete `app/app.py` and `cloud-init.yaml.tftpl`. Render the app source and non-secret metadata into guest files with safe YAML serialization. Enable `rsyslog`, install the app's systemd unit, start it on boot, and emit a sanitized bootstrap marker.
4. Ensure Terraform establishes the intended NSG association before VM bootstrap. Prefer resource references; document any extra explicit dependency.
5. Review the complete saved plan before apply. It must create only Lab 6 resources; investigate any proposed change to Lab 5 resources.
6. Validate cloud-init and systemd independently of Azure's VM provisioning status.
7. Use an SSH local tunnel to test `/`, `/health`, and `/ready`. Prove a direct public TCP/8080 request cannot reach the app.
8. Explain why your own successful Azure CLI secret read would not prove that the VM's managed identity works.

Changing `custom_data` forces VM replacement in AzureRM 3.117.1. Inspect the plan before applying a bootstrap edit and explain the difference between cloud-init first-boot execution and editing a file in a running guest. See [AzureRM Linux VM reference](https://github.com/hashicorp/terraform-provider-azurerm/blob/v3.117.1/website/docs/r/linux_virtual_machine.html.markdown).

#### Part C - Monitor the Guest

1. Create the Log Analytics workspace with 30-day retention.
2. Install `AzureMonitorLinuxAgent` using the VM extension resource. Configure AMA to authenticate using the attached UAMI; verify supported extension versions in your region. See [installing and managing AMA](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage).
3. Create a Linux DCR with a `Microsoft-Syslog` source, a Log Analytics destination, and a matching data flow. Collect `user` facility events at `Info`, `Notice`, `Warning`, `Error`, `Critical`, `Alert`, and `Emergency` levels. Associate the DCR with the VM.
4. Ensure guest `rsyslog` receives the app's events. Emit a unique `lab06` marker using `logger` and verify it reaches Log Analytics, allowing for ingestion delay.
5. Explain why boot diagnostics, platform metrics, an installed AMA extension, and collected guest logs are different evidence. See [collecting syslog with AMA](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/data-collection-syslog).

Do not substitute the retired legacy Log Analytics agent. A VM diagnostic setting alone does not complete the required guest syslog pipeline.

#### Part D - Handoff, Break/Fix, and Cleanup

1. Complete operational outputs in `outputs.tf`, including both the workspace resource ID and workspace customer GUID.
2. Inspect state for selected resources and match their IDs to Azure. Avoid dumping unrelated state or secrets.
3. Complete one access/bootstrap troubleshooting case and one identity/monitoring case below.
4. Write a decision note, save sanitized evidence, restore the working configuration, and check the final plan.
5. Review a destroy plan, destroy Lab 6, and confirm no Lab 6 VM, disk, or public IP is left. Then decide whether to destroy Lab 5.

### Validation Commands

Run from `06-application-hosting` after completing the TODOs:

```bash
az account show --query '{name:name,id:id}' --output table
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output
terraform state list
terraform state show azurerm_linux_virtual_machine.app
```

Use the resource address you chose if it differs from `azurerm_linux_virtual_machine.app`. The shell examples below assume the output names requested in `outputs.tf`.

```bash
LAB_RG=$(terraform output -raw resource_group_name)
LAB_VM=$(terraform output -raw vm_name)
LAB_NIC=$(terraform output -raw nic_name)
LAB_PUBLIC_IP=$(terraform output -raw public_ip_address)
LAB_WORKSPACE_GUID=$(terraform output -raw log_analytics_workspace_customer_id)

az group show --name "$LAB_RG" --query '{name:name,location:location}'
az resource list --resource-group "$LAB_RG" --output table
az vm get-instance-view --name "$LAB_VM" --resource-group "$LAB_RG" --query instanceView.statuses --output table
az vm show --name "$LAB_VM" --resource-group "$LAB_RG" --query '{identity:identity,osDisk:storageProfile.osDisk}'
az network nic show --name "$LAB_NIC" --resource-group "$LAB_RG" --query ipConfigurations
az network nic list-effective-nsg --name "$LAB_NIC" --resource-group "$LAB_RG"
az vm extension list --vm-name "$LAB_VM" --resource-group "$LAB_RG" --output table
```

Check inherited and direct Key Vault permissions using the existing identity's **principal ID**:

```bash
LAB_MI_PRINCIPAL=$(terraform output -raw managed_identity_principal_id)
LAB_VAULT_ID=$(az keyvault show --name "$(terraform output -raw key_vault_name)" --query id --output tsv)
az role assignment list --assignee "$LAB_MI_PRINCIPAL" --scope "$LAB_VAULT_ID" --include-inherited --output table
```

If you chose a secret-level role scope, inspect that scope as well. Listing vault-scope assignments alone will not show a grant at a child secret scope.

In a second terminal, open the tunnel and keep it running; replace the example user/key path if you selected different inputs:

```bash
ssh -i ~/.ssh/id_ed25519 -o ExitOnForwardFailure=yes -N \
  -L 127.0.0.1:8080:127.0.0.1:8080 azureuser@<vm-public-ip>
```

In the original terminal:

```bash
curl --fail --max-time 10 http://127.0.0.1:8080/
curl --fail --max-time 10 http://127.0.0.1:8080/health
curl --fail --max-time 20 http://127.0.0.1:8080/ready
curl --connect-timeout 5 --max-time 10 "http://$LAB_PUBLIC_IP:8080/health"
```

The first three requests must succeed. The final direct request must fail to connect; save that as expected evidence. Inspect the listening socket and NSG to establish why it fails. Stop the tunnel with Ctrl-C when finished.

Inside the VM, inspect only sanitized logs:

```bash
sudo cloud-init status --wait
sudo systemctl status lab06-app --no-pager
sudo journalctl -u lab06-app -n 30 --no-pager
sudo ss -lntp
logger -p user.info -t lab06 "lab06-validation-$(date -u +%Y%m%dT%H%M%SZ)"
```

For bootstrap failures inspect `/var/log/cloud-init.log` and `/var/log/cloud-init-output.log`. Inspect the DCR and its VM association in Azure Portal or CLI, then query the workspace:

```bash
az monitor log-analytics query --workspace "$LAB_WORKSPACE_GUID" \
  --analytics-query "Syslog | where TimeGenerated > ago(30m) | where ProcessName == 'lab06' | project TimeGenerated, Computer, SeverityLevel, SyslogMessage | order by TimeGenerated desc | take 20" \
  --output table
terraform plan -detailed-exitcode
```

The query command may require the Azure CLI `log-analytics` extension and workspace query permissions for your operator identity. Resolve those separately from the VM's identity permissions. A no-change plan exits `0`; pending changes exit `2`; an error exits `1`. A clean plan does not establish app health or log delivery.

### Troubleshooting Exercise

Complete at least **two** cases: one from each group. Make controlled changes to your lab, predict the symptom, gather evidence, and restore the working configuration.

| Group | Controlled change | Diagnose using |
|---|---|---|
| Access/bootstrap | Replace SSH source `/32` with a different documentation address | Client timeout, current source IP, effective NSG; restore through Terraform from your laptop |
| Access/bootstrap | Break the systemd command or omit unit enable/start | `/health`, cloud-init status, systemd status, journal, listening socket |
| Access/bootstrap | Introduce a bad cloud-init command | VM provisioning vs cloud-init exit status and boot logs |
| Identity/monitoring | Configure the app with a client ID that is not attached to the VM | IMDS status vs Key Vault status; resource/client/principal ID distinctions |
| Identity/monitoring | Temporarily replace the UAMI's vault role with `Reader` in Lab 5 | IMDS token success, Key Vault 403, effective data-plane grants; restore in the owning Lab 5 state |
| Identity/monitoring | Omit the DCR association or exclude the `user` facility | AMA extension status, local marker, DCR source/data flow/association, missing workspace event |

For a permission test, account for token caching, inherited assignments, and RBAC propagation; revoking a grant is not guaranteed to produce an immediate 403. Terraform dependency ordering does not force Azure RBAC caches to refresh. Retry within a bounded window, record timestamps, and investigate the scope rather than adding broad privileges.

Record the change, failure phase, sanitized symptom, commands used, root cause, fix, and production lesson. Repeat the required health, readiness, and log checks after recovery.

### Interview Questions

1. Why choose a VM rather than App Service for this application? Who owns patching and guest operations?
2. What roles do the VM, NIC, private IP, public IP, subnet, and NSG play?
3. Why is the app unreachable directly but reachable through the SSH tunnel?
4. What does the NSG's default VNet allowance mean, and how does loopback binding affect it?
5. How does this VM get outbound access, and what would change without the public IP?
6. What is the difference between VM provisioning success and successful cloud-init completion?
7. What happens when you change `custom_data`, and how would you deploy app changes in production?
8. When do you use a managed identity's resource ID, client ID, and principal ID?
9. How does IMDS obtain credentials without your application storing a password?
10. Why can token acquisition succeed while the Key Vault request fails?
11. Why do `depends_on` and a successful role-assignment apply not guarantee immediate authorization?
12. How do `/health` and `/ready` help isolate failures?
13. What is the difference between boot diagnostics, platform metrics, and AMA/DCR guest logs?
14. How would you diagnose an installed AMA extension with no Syslog events?
15. Why is a no-change Terraform plan insufficient evidence of a working application?
16. What remains billable after deallocating a VM, and how do you verify complete cleanup?

### Decision Note

Explain your hosting choice, access path, explicit egress, least-privilege identity, runtime secret handling, log pipeline, and remaining blind spots. Compare at least one resource across Terraform configuration, Terraform state, and actual Azure/guest observations. State what changes you would make for production: deployment pipeline, patching, availability, private access, alerting, TLS/authentication, and state access control.

### Optional Stretch Tasks

- Add one small Standard_LRS managed data disk, attach it with a stable LUN, mount by UUID, and explain OS disk vs temporary disk vs managed data disk lifecycle. Review a replacement plan before risking persisted data.
- Add a runtime blob-read check using the Lab 5 `Storage Blob Data Reader` grant. Seed a harmless blob as an authorized operator; prove the VM's identity can read it without account keys and record how its token audience differs from Key Vault.
- Compare a minimal App Service design: what moves to platform ownership, how runtime identity is attached, and why VNet integration controls outbound access rather than making inbound requests private. Private endpoint implementation belongs in Lab 7. See [App Service VNet integration](https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration).

### Cleanup

```bash
terraform plan -destroy -out=destroy.tfplan
terraform show destroy.tfplan
terraform apply destroy.tfplan
az group exists --name "$LAB_RG"
```

Expect `false` for the Lab 6 resource group. If it remains, list its resources and diagnose cleanup. Lab 5 data sources must not appear as resources to destroy. Destroy Lab 5 afterward if it is no longer needed; document any intentional preservation. Deallocation stops compute billing but is not full cleanup of disks and public IP resources.

### Grading Rubric

| Area | Points | Strong evidence |
|---|---:|---|
| Terraform correctness and ownership | 2 | Formatted and valid HCL, reviewed plan, clear dependencies, stable outputs, Lab 5 ownership preserved |
| Azure networking and security | 2 | Verified NIC/subnet/NSG, restricted SSH, direct HTTP blocked, working tunnel, explicit egress |
| Runtime identity and app operation | 2 | Working bootstrap/service, health vs readiness, real UAMI secret read, no credential leakage |
| Monitoring and troubleshooting | 2 | AMA/DCR/association verified, actual Syslog marker, two diagnosed and recovered failures |
| State, cost, and interview readiness | 2 | Config/state/Azure comparison, decision note, cleanup evidence, clear explanations |
| **Total** | **10** | |

The lab is complete when all required runtime checks pass, the break/fix exercises are restored, evidence and decisions are recorded, and cleanup is verified or preservation is explicitly justified. Starter validation alone earns no completion claim.

Ask for grading before moving to Lab 7:

```text
Grade Project 6 from /home/example/Documents/TerraformWork/06-application-hosting.
```

### Hidden Solution Policy

Build from the TODOs yourself. Ask for conceptual hints, targeted review, or help with a specific error before requesting a full solution.

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

## Detailed Project 3 - Terraform State And Refactor Workflow

**Difficulty:** Intermediate to Advanced  
**Estimated time:** 8-12 hours  
**Cost:** Low. Uses Azure Storage for backend state plus a small imported resource group and simple resources. Destroy lab resources after validation, but decide whether to keep or delete the backend storage.

### Scenario

Your team is moving from solo Terraform practice to team-style Terraform operations. Local state is no longer enough. You need to create a remote backend, migrate workload state to Azure Storage, import a manually created Azure resource group, and safely refactor Terraform resource addresses without recreating real infrastructure.

This project is less about creating many Azure resources and more about learning the workflows that protect production infrastructure.

### Architecture Target

Create or manage:

- One backend resource group.
- One backend storage account.
- One backend blob container named `tfstate`.
- One manually created/imported workload resource group.
- One Terraform-managed storage account inside the imported resource group.
- One Terraform-managed blob container.
- A refactor from rough Terraform resource addresses to better names using `moved` blocks.

### Azure Services Practiced

- Resource groups
- Storage accounts
- Blob containers
- Azure Storage backend for Terraform state
- Azure CLI resource inspection

### Terraform Skills Practiced

- Local state vs remote state
- Backend bootstrapping
- `terraform init -migrate-state`
- Backend configuration limitations
- `terraform import`
- Terraform resource addresses
- State inspection
- Safe refactoring with `moved` blocks
- Drift inspection with refresh-only plans

### Starting Repository Shape

```text
03-state-refactor-workflow/
├── README.md
├── bootstrap-backend/
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── workload/
    ├── versions.tf
    ├── backend.tf
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    ├── moved.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── notes.md
    └── evidence.md
```

Use `bootstrap-backend` to create the remote state storage. Use `workload` for the imported resource group and refactor workflow.

### Part A - Bootstrap The Backend

In `bootstrap-backend`, create:

- Resource group: `<prefix>-backend-rg`
- Storage account: globally unique, Azure-valid name
- Blob container: `tfstate`
- Tags:
  - `environment`
  - `managed_by = terraform`
  - `project = azure-terraform-hands-on`
  - `purpose = terraform-state`

Use local state for this bootstrap project.

Before coding, write this prediction in `workload/notes.md`:

```text
Backend prediction:

Why does the backend need to exist before workload init?

Which values are needed in backend.tf?

Which backend values are globally unique?

Should backend resources be destroyed after the lab?
```

### Part B - Configure Remote State

In `workload/backend.tf`, configure the AzureRM backend manually.

Example shape:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "..."
    storage_account_name = "..."
    container_name       = "tfstate"
    key                  = "03-state-refactor-workflow.tfstate"
  }
}
```

Backend blocks cannot use normal Terraform variables. Fill in the backend values directly or use backend config during `terraform init`.

Run:

```bash
terraform init
terraform providers
```

Record in `evidence.md`:

```text
Remote backend initialized:
Backend resource group:
Backend storage account:
Backend container:
State key:
```

### Part C - Import An Existing Resource Group

Create a workload resource group manually with Azure CLI:

```bash
az group create \
  --name <prefix>-imported-rg \
  --location eastus \
  --tags environment=dev managed_by=manual project=azure-terraform-hands-on
```

In `workload/main.tf`, define the matching Terraform resource:

```hcl
resource "azurerm_resource_group" "imported" {
  name     = var.imported_resource_group_name
  location = var.location
  tags     = local.common_tags
}
```

Then import it:

```bash
terraform import azurerm_resource_group.imported /subscriptions/<subscription-id>/resourceGroups/<prefix>-imported-rg
```

After import, run:

```bash
terraform state list
terraform state show azurerm_resource_group.imported
terraform plan
```

Your goal is to make the plan clean or explain exactly why Terraform wants to update tags.

### Part D - Add A Small Managed Workload

Inside the imported resource group, add:

- One storage account.
- One private blob container named `artifacts`.
- Outputs for:
  - imported resource group name
  - storage account name
  - storage account ID
  - backend state key

Use names that make the first version intentionally a little rough, for example:

```hcl
resource "azurerm_storage_account" "this" {
  # Implement this yourself.
}
```

Apply successfully.

Then inspect:

```bash
terraform output
terraform state list
az resource list --resource-group <prefix>-imported-rg --output table
```

### Part E - Safe Refactor With `moved`

Refactor Terraform resource addresses without replacing Azure resources.

Rename Terraform addresses like this:

```text
azurerm_resource_group.imported -> azurerm_resource_group.workload
azurerm_storage_account.this    -> azurerm_storage_account.artifacts
azurerm_storage_container.this  -> azurerm_storage_container.artifacts
```

Add `moved` blocks in `moved.tf`.

Then run:

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
terraform state list
```

Expected result: Terraform should understand the address move and should not destroy or recreate resources just because Terraform labels changed.

### Tasks

1. Create the `03-state-refactor-workflow` folder structure.
2. Build and apply the backend storage resources from `bootstrap-backend`.
3. Configure the `workload` root module to use the AzureRM backend.
4. Initialize the workload backend.
5. Manually create the workload resource group with Azure CLI.
6. Write matching Terraform configuration for the manually created resource group.
7. Import the resource group into Terraform state.
8. Run `terraform plan` and reconcile or explain tag drift.
9. Add a Terraform-managed storage account and private blob container.
10. Apply and validate the workload resources.
11. Rename rough Terraform addresses to clearer names.
12. Add `moved` blocks and prove the refactor does not recreate resources.
13. Run the troubleshooting exercise.
14. Write the final decision note.
15. Destroy workload resources when finished.
16. Decide whether to keep or destroy the backend resources.

### Validation Commands

Backend:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output
```

Workload:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform import azurerm_resource_group.imported /subscriptions/<subscription-id>/resourceGroups/<prefix>-imported-rg
terraform state list
terraform state show azurerm_resource_group.imported
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output
terraform plan -refresh-only
terraform plan
```

Azure CLI:

```bash
az group show --name <prefix>-imported-rg
az resource list --resource-group <prefix>-imported-rg --output table
az storage blob list \
  --account-name <backend-storage-account> \
  --container-name tfstate \
  --output table
```

### Troubleshooting Exercise

Choose one:

- Remove one `moved` block and observe the plan.
- Change the actual storage account name and observe replacement behavior.
- Manually edit a tag in Azure and compare `terraform plan -refresh-only` with normal `terraform plan`.
- Try importing the resource group to the wrong Terraform address, then fix the state safely.

Answer in `notes.md`:

```text
What I broke:

Where Terraform detected it:

Was this a config issue, state issue, Azure issue, or drift?

How I fixed it:

What would be risky in production:
```

### Interview Questions

1. Why does Terraform state need to be protected?
2. What is the difference between local state and remote state?
3. Why can normal Terraform variables not be used inside a backend block?
4. What does `terraform init -migrate-state` do?
5. What does `terraform import` do and what does it not do?
6. Why can an imported resource still show changes in `terraform plan`?
7. What is the difference between renaming a Terraform resource address and renaming the Azure resource itself?
8. What problem do `moved` blocks solve?
9. When would `terraform state mv` be useful, and why should it be used carefully?
10. What should you check before applying a plan that shows destroy/create after a refactor?

### Decision Note

Write a short note in `notes.md`:

```text
Decision:

Where should Terraform state live for team use?

Who should have access to the backend storage account?

When should resources be imported instead of recreated?

When should moved blocks be used?

What I would change before production:
```

### Cleanup

Destroy workload resources first:

```bash
cd workload
terraform destroy
az resource list --resource-group <prefix>-imported-rg --output table
```

If the imported resource group remains because it was created outside Terraform or because you intentionally kept it, document why.

Then decide whether to keep or destroy backend resources:

```bash
cd ../bootstrap-backend
terraform destroy
```

Do not destroy the backend until you are sure you no longer need the workload state file.

### Grading Rubric

| Area | Strong evidence |
|---|---|
| Backend understanding | You can explain why backend storage must exist before workload initialization |
| State safety | Remote state is used and validated in Azure Storage |
| Import workflow | Imported resource group maps cleanly to Terraform configuration |
| Refactor safety | `moved` blocks prevent unwanted destroy/create during address renames |
| Drift understanding | You can explain refresh-only vs normal plan after manual Azure changes |
| Production judgment | You can explain access control, state sensitivity, and cleanup decisions |

### Hidden Solution Policy

Do not ask for the full solution first. Build the files yourself. Ask for conceptual hints, review, or grading when stuck.
