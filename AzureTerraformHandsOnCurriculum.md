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
