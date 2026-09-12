# Azure Terraform Production Labs
A progressive hands-on curriculum for becoming stronger at designing, debugging, maintaining, and operating real Azure infrastructure with Terraform. This version is aligned with `PLAN.md` and `Prompt1`: realistic labs, minimal or intentionally broken starter code, specific investigation tasks, Azure CLI validation, and hidden complete solutions.
> Treat this file as the curriculum artifact. Commands and tasks inside it are instructions for the learner working through the labs, not instructions for an AI assistant to execute automatically.
## Solution Policy
Do not ask for complete solutions first. Ask for `Give me a conceptual hint for Lab N`, `Review my Lab N implementation`, `Grade my Lab N submission`, or `Show me the solution for Lab N`. Complete solutions stay hidden until explicitly requested.
## How To Use This Curriculum
For each lab: restate the goal, sketch the architecture, predict the plan, implement from the minimal or broken starter, validate with Terraform and Azure CLI, compare configuration -> state -> Azure actual state, and write a short production decision note. Keep commits small and never apply a large unexplained plan.
## Baseline Tooling
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
terraform destroy
terraform show
terraform show -json
terraform output
terraform console
terraform graph
terraform state list
terraform state show
terraform state mv
terraform state rm
terraform import
terraform providers
az account show
az group show
az resource show
az resource list
az network
az role assignment list
az aks
az storage
az monitor
```
Use Terraform `>= 1.6`, AzureRM provider `~> 3.x` unless a lab is about upgrades, a low-cost region, a dedicated non-production Azure subscription, and a prefix such as `tfazlab`.
## Repository Shape
```text
terraform-azure-labs/
├── README.md
├── 01-predicting-terraform-plans-before-you-run-them/
├── 02-implicit-vs-explicit-dependencies/
├── 03-replacement-and-immutable-azure-properties/
├── 04-unknown-values-and-data-source-timing/
├── 05-count-vs-for-each-and-address-stability/
├── 06-local-state-forensics/
├── 07-importing-existing-infrastructure-safely/
├── 08-renaming-terraform-without-renaming-azure/
├── 09-moving-resources-into-modules-safely/
├── 10-remote-state-locking-and-recovery/
├── 11-complex-inputs-for-subnets/
├── 12-tag-governance-with-collection-functions/
├── 13-dynamic-nsg-rules-from-nested-inputs/
├── 14-private-dns-link-transformations/
├── 15-defensive-expressions-and-normalization/
├── 16-foundation-module-design/
├── 17-network-module-with-stable-outputs/
├── 18-aliased-providers-across-subscriptions/
├── 19-module-testing-docs-and-versioning/
├── 20-composable-platform-slice/
├── 21-hub-and-spoke-baseline/
├── 22-private-endpoint-dns-troubleshooting/
├── 23-egress-with-nat-routes-and-firewall-options/
├── 24-application-gateway-backend-health/
├── 25-load-balancer-and-health-probe-failure/
├── 26-managed-identity-and-rbac-timing/
├── 27-key-vault-rbac-and-secret-safety/
├── 28-service-principal-vs-oidc-authentication/
├── 29-security-scanning-and-policy-gates/
├── 30-platform-observability-and-alerts/
├── 31-aks-baseline-with-operational-awareness/
├── 32-aks-node-pools-and-replacement-risk/
├── 33-aks-networking-and-permission-failures/
├── 34-private-aks-and-operator-access/
├── 35-aks-ingress-and-platform-integration/
├── 36-terraform-pr-pipeline-with-plan-artifacts/
├── 37-drift-detection-workflow/
├── 38-plan-json-policy-gates/
├── 39-environment-promotion-and-multi-subscription-layout/
├── 40-capstone-inherited-azure-platform-rebuild/
└── docs/
```
Each lab should be independently runnable where practical. Do not make later labs depend on hidden state from earlier labs unless explicitly stated.
## Roadmap
| Labs | Level | Focus |
|---:|---|---|
| 1-5 | Terraform Deep Fundamentals | plan prediction, unknowns, graph, replacement, stable addresses |
| 6-10 | Terraform State Mastery | inspection, import, refactor, modules, remote state |
| 11-15 | Advanced Terraform Language | complex inputs, dynamic blocks, transformations, validation |
| 16-20 | Modules and Composition | module APIs, provider aliases, testing, platform slices |
| 21-25 | Azure Networking | hub/spoke, private endpoints, egress, gateways, load balancing |
| 26-30 | Identity, Security, Operations | RBAC, Key Vault, OIDC, scanning, monitoring |
| 31-35 | AKS | cluster basics, node pools, networking, private access, ingress |
| 36-40 | CI/CD, Environments, Capstone | pipelines, drift, policy, promotion, inherited platform rebuild |
---
# Level 1 - Terraform Deep Fundamentals
## Lab 1 - Predicting Terraform Plans Before You Run Them
**Difficulty:** Intermediate  
**Cost:** Low. Cost drivers: resource group, storage account, Log Analytics workspace. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Terraform lifecycle, plan prediction, unknown values, computed attributes, refresh behavior, configuration vs state vs Azure actual state.
### Scenario
You are handed a tiny monitoring bootstrap stack. Before anyone trusts you with larger changes, you need to prove that you can predict Terraform behavior before running it and explain drift after Azure-side changes.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
01-predicting-terraform-plans-before-you-run-them/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars.example
```
### Minimal or Broken Starter
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

# providers.tf
provider "azurerm" {
  features {}
}

# variables.tf
variable "prefix" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

# main.tf
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

# TODO: Add one storage account and one Log Analytics workspace.
# TODO: Names must come from stable inputs, not provider-computed values.

# outputs.tf
# TODO: Output a mix of known names and provider-computed IDs/endpoints.
```
### Tasks
1. Write a pre-plan prediction table for every resource and output.
2. Implement the missing storage account and Log Analytics workspace from documentation, not from a full copied solution.
3. Run `terraform plan -out=tfplan` and compare the actual unknown values to your prediction.
4. Apply, then inspect state for resource IDs, computed fields, and tags.
5. Change one Terraform-owned tag manually in Azure and compare `terraform plan -refresh-only` with a normal plan.
6. Write a short note deciding whether Terraform or the portal change should be authoritative.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform state list
terraform state show <address>
az group show --name <rg-name>
terraform plan -refresh-only
terraform plan
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Provider-computed values usually include IDs, endpoints, and timestamps.

**Hint 2:** Stable resource names should come from inputs, not from values Azure only knows after creation.

**Hint 3:** `refresh-only` updates Terraform state to observed reality; it does not rewrite desired configuration.

### Solution
Ask: `Show me the solution for Lab 1`
## Lab 2 - Implicit vs Explicit Dependencies
**Difficulty:** Intermediate  
**Cost:** Low. Cost drivers: resource group, VNet, subnet, NSG, NSG association, optional Log Analytics workspace. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Dependency graph, implicit references, explicit `depends_on`, `terraform graph`, Azure creation ordering.
### Scenario
A teammate added `depends_on` to almost every Azure network resource because "Azure is flaky." Your job is to build a small network stack, predict Terraform's graph, then decide which dependencies are already expressed by references.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
02-implicit-vs-explicit-dependencies/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
# main.tf
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.20.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_network_security_group" "app" {
  name                = "${var.prefix}-app-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# TODO: Add variables, outputs, and notes.md.
# Optional: add NSG diagnostics and decide whether depends_on helps readability.
```
### Tasks
1. Draw the expected graph before running Terraform.
2. Identify every expression that creates an implicit graph edge.
3. Run `terraform graph > graph.dot` and compare the graph to your prediction.
4. Add one unnecessary `depends_on`, regenerate the graph, and explain what changed.
5. Remove unnecessary `depends_on` and keep only a dependency you can justify.
6. Validate the subnet and NSG association with Azure CLI.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform graph > graph.dot
terraform state show azurerm_subnet_network_security_group_association.app
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name snet-app
az network nsg show --resource-group <rg-name> --name <nsg-name>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Any expression that reads another resource attribute usually creates an implicit graph edge.

**Hint 2:** The association depends on both the subnet and the NSG because it uses both IDs.

**Hint 3:** Before adding `depends_on`, ask what must exist in Azure that is not already referenced.

### Solution
Ask: `Show me the solution for Lab 2`
## Lab 3 - Replacement and Immutable Azure Properties
**Difficulty:** Intermediate  
**Cost:** Low. Cost drivers: storage account or public IP. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
ForceNew behavior, immutable attributes, replacement analysis, lifecycle protections, migration planning.
### Scenario
A naming standard update looks harmless in review, but Terraform proposes replacing an existing Azure resource.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
03-replacement-and-immutable-azure-properties/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_storage_account" "this" {
  name                     = "${var.prefix}stor001" # BROKEN/TODO: must be globally unique and 3-24 lowercase chars.
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# TODO: Add the resource group and variables.
# TODO: After first apply, change only the storage account name and predict replacement.
```
### Tasks
1. Create the first version and apply it once.
2. Before changing anything, inspect state and write down the Azure resource ID.
3. Change an immutable property, such as the storage account name, and predict the plan.
4. Run a plan and identify the exact `forces replacement` line.
5. Add `prevent_destroy` temporarily, rerun the plan, and explain how safety changes the failure mode.
6. Write a production migration plan that avoids surprise data loss.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
terraform show -json tfplan
terraform state show azurerm_storage_account.this
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Storage account names are a clean way to study immutability.

**Hint 2:** Search the plan output for `forces replacement`.

**Hint 3:** Preventing destroy is not a migration strategy; it is a guardrail.

### Solution
Ask: `Show me the solution for Lab 3`
## Lab 4 - Unknown Values and Data Source Timing
**Difficulty:** Intermediate  
**Cost:** Low. Cost drivers: resource group, storage account, client config data source. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Plan-time vs apply-time evaluation, data sources, computed attributes, `terraform console`, sensitive outputs.
### Scenario
You need to explain why Terraform cannot use an apply-time Azure value to construct a stable resource name.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
04-unknown-values-and-data-source-timing/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_storage_account" "this" {
  # BROKEN IDEA: do not build stable names from IDs created only after apply.
  name                     = lower(replace("${var.prefix}${azurerm_resource_group.this.id}", "/", ""))
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# TODO: Refactor the name so it is stable and valid at plan time.
```
### Tasks
1. Predict which expressions are known before apply.
2. Run `terraform console` and evaluate locals you design for naming.
3. Run `terraform validate` and observe why the starter idea is unsafe or invalid.
4. Refactor names to use variables, locals, and deterministic transformations.
5. Add outputs for tenant ID, resource group ID, and storage endpoint, then classify each as known or unknown at plan time.
6. Write a note on data source timing and provider-computed values.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform console
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Data sources can be known during plan if their inputs are known.

**Hint 2:** Resource IDs are often unknown until apply.

**Hint 3:** Names need deterministic, valid strings before Azure receives the create request.

### Solution
Ask: `Show me the solution for Lab 4`
## Lab 5 - count vs for_each and Address Stability
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: VNet and repeated subnets. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
`count`, `for_each`, resource addresses, state movement, stable identity.
### Scenario
A teammate uses `count` with a list of subnet names. Adding a new subnet in the middle creates address churn.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
05-count-vs-for-each-and-address-stability/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "subnet_names" {
  type    = list(string)
  default = ["app", "data"]
}

resource "azurerm_subnet" "this" {
  count                = length(var.subnet_names)
  name                 = "snet-${var.subnet_names[count.index]}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet("10.30.0.0/16", 8, count.index)]
}

# TODO: Apply once, then insert "api" between app and data.
# TODO: Refactor to for_each using stable keys and preserve state.
```
### Tasks
1. Apply the `count` version with two subnets.
2. Insert a new item in the middle and predict the addresses that will change.
3. Run plan and identify address churn.
4. Refactor input to a map of objects with explicit CIDRs.
5. Use `terraform state mv` or moved blocks to preserve existing subnets.
6. Confirm the final plan does not recreate long-lived subnets.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform state list
terraform plan
terraform state mv <old-address> <new-address>
terraform plan
az network vnet subnet list --resource-group <rg> --vnet-name <vnet>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** List indexes are fragile resource identities.

**Hint 2:** Good `for_each` keys usually match human meaning.

**Hint 3:** Refactor configuration and state as one deliberate operation.

### Solution
Ask: `Show me the solution for Lab 5`
---
## Checkpoint 1 - Terraform Runtime Fundamentals
**Focus:** refresh behavior, unknowns, replacement, graph edges, address stability.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
# Level 2 - Terraform State Mastery
## Lab 6 - Local State Forensics
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: small resource group and storage account stack. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Local state inspection, address mapping, provider-computed fields, state vs Azure comparison.
### Scenario
You inherit a local-state repo with no documentation. Your first job is to understand what Terraform believes it owns.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
06-local-state-forensics/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
# Seed a tiny stack yourself or reuse one from Lab 1.
# BROKEN/INCOMPLETE: notes.md is empty and outputs do not expose enough IDs.

output "resource_ids_to_investigate" {
  value = [] # TODO: replace with IDs that let you compare Terraform and Azure.
}
```
### Tasks
1. Apply or import a tiny stack so local state exists.
2. Run `terraform state list` and create an inventory table.
3. For each address, record Azure resource ID, type, name, and resource group.
4. Use `terraform show -json` to identify provider-computed fields.
5. Compare at least one resource with `az resource show`.
6. Write what information is binding data versus observed data.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform state list
terraform state show <address>
terraform show -json > state.json
az resource show --ids <resource-id>
jq .values.root_module.resources state.json
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start with addresses, then map them to Azure IDs.

**Hint 2:** State is not only a cache; it records bindings.

**Hint 3:** Inspect before you mutate.

### Solution
Ask: `Show me the solution for Lab 6`
## Lab 7 - Importing Existing Infrastructure Safely
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: manually created resource group or storage account. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Import workflow, config matching, import blocks, no-op planning.
### Scenario
A resource was created manually during an incident. It now needs Terraform ownership without downtime or surprise replacement.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
07-importing-existing-infrastructure-safely/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```bash
# Create one resource outside Terraform first. Example:
az group create --name <prefix>-manual-rg --location <location> --tags owner=portal
```
```hcl
resource "azurerm_resource_group" "manual" {
  name     = "<TODO-match-existing-name>"
  location = "<TODO-match-existing-location>"
  tags     = {} # BROKEN: intentionally incomplete. Match or explain drift.
}

# Optional for Terraform >= 1.5:
# import { to = azurerm_resource_group.manual id = "/subscriptions/.../resourceGroups/..." }
```
### Tasks
1. Create the Azure resource manually with CLI.
2. Inspect it with Azure CLI before writing Terraform.
3. Write config that matches reality as closely as possible.
4. Import the resource into the intended address.
5. Reduce the plan to no-op or explain every remaining difference.
6. Write a production adoption checklist.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
az group show --name <manual-rg>
terraform import azurerm_resource_group.manual <resource-id>
terraform plan
terraform state show azurerm_resource_group.manual
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Import binds state; it does not generate perfect configuration.

**Hint 2:** The Azure resource ID must be exact.

**Hint 3:** Watch for ForceNew attributes before applying post-import changes.

### Solution
Ask: `Show me the solution for Lab 7`
## Lab 8 - Renaming Terraform Without Renaming Azure
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: small named resource. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Resource addresses, moved blocks, state mv, safe refactoring.
### Scenario
The code needs clearer Terraform labels. The Azure resource names must not change.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
08-renaming-terraform-without-renaming-azure/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_resource_group" "rg1" {
  name     = "${var.prefix}-app-rg"
  location = var.location
}

# TODO after first apply: rename rg1 to app without changing Azure name.
# TODO: Use a moved block or terraform state mv to preserve binding.
```
### Tasks
1. Apply the starter resource.
2. Rename only the Terraform label and predict the destroy/create plan.
3. Choose moved block or `terraform state mv` and explain why.
4. Perform the binding migration.
5. Confirm the plan is no-op or only expected output changes.
6. Write a review note proving Azure was not renamed.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform state list
terraform plan
terraform state mv azurerm_resource_group.rg1 azurerm_resource_group.app
terraform plan
az group show --name <rg-name>
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Terraform labels and Azure names are separate.

**Hint 2:** Address movement preserves binding.

**Hint 3:** A safe refactor should be boring in the plan.

### Solution
Ask: `Show me the solution for Lab 8`
## Lab 9 - Moving Resources Into Modules Safely
**Difficulty:** Expert  
**Cost:** Low. Cost drivers: resource group, storage account, child module. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Module refactoring, address changes, moved blocks, blast-radius control.
### Scenario
Working root-module resources must move into a child module without recreating Azure objects.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
09-moving-resources-into-modules-safely/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
# root main.tf, before refactor
resource "azurerm_resource_group" "foundation" {
  name     = "${var.prefix}-foundation-rg"
  location = var.location
}

# TODO: Move this into modules/foundation without changing the Azure resource.
# TODO: Add module call and moved block or state mv.
```
### Tasks
1. Apply the root-only version.
2. Design the smallest useful module boundary.
3. Move the resource into `modules/foundation`.
4. Predict the plan before adding moved block or state migration.
5. Preserve binding and prove no Azure object will be recreated.
6. Document why structural refactor and behavior change should be separate PRs.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform state list
terraform plan
terraform state mv azurerm_resource_group.foundation module.foundation.azurerm_resource_group.this
terraform plan
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Address changes are the heart of this lab.

**Hint 2:** Keep the module interface tiny.

**Hint 3:** Do not combine refactor with new features.

### Solution
Ask: `Show me the solution for Lab 9`
## Lab 10 - Remote State, Locking, and Recovery
**Difficulty:** Expert  
**Cost:** Low to Medium. Cost drivers: Azure Storage backend, container, blob versioning. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
AzureRM backend, locking, backend migration, state backup, recovery runbook.
### Scenario
A team is using local state. You need to migrate to protected Azure Storage remote state and explain recovery.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
10-remote-state-locking-and-recovery/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
# backend-bootstrap/main.tf
# TODO: create resource group, storage account, and private container for state.
# BROKEN: backend config does not exist yet because the backend must be bootstrapped first.

# app/backend.tf.example
terraform {
  backend "azurerm" {
    resource_group_name  = "<TODO>"
    storage_account_name = "<TODO>"
    container_name       = "tfstate"
    key                  = "lab10.tfstate"
  }
}
```
### Tasks
1. Bootstrap backend infrastructure separately.
2. Enable protection features you can justify, such as versioning or soft delete.
3. Create a tiny app root with local state.
4. Migrate it using `terraform init -migrate-state`.
5. Observe lock behavior where practical.
6. Write a recovery runbook for bad state operations.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init -migrate-state
terraform state pull
az storage blob list --container-name <container> --account-name <account>
az storage account blob-service-properties show --account-name <account>
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Backend infrastructure is production infrastructure.

**Hint 2:** Recovery starts before disaster.

**Hint 3:** Never test recovery by making irreversible changes first.

### Solution
Ask: `Show me the solution for Lab 10`
---
## Checkpoint 2 - State Mastery
**Focus:** imports, moved blocks, remote state, recovery, state evidence.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
# Level 3 - Advanced Terraform Language
## Lab 11 - Complex Inputs for Subnets
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: VNet, subnets, optional NSGs. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Maps of objects, optional attributes, validation, normalized locals, `for_each`.
### Scenario
Design one subnet input model flexible enough for app, data, private endpoint, and delegated subnets.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
11-complex-inputs-for-subnets/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "subnets" {
  type = map(object({
    cidr              = string
    service_endpoints = optional(list(string), [])
    create_nsg        = optional(bool, false)
    delegation        = optional(object({ name = string, service = string }))
  }))
  default = {
    app = { cidr = "10.40.1.0/24", create_nsg = true }
    pe  = { cidr = "10.40.2.0/24" }
  }
}

locals {
  normalized_subnets = var.subnets # TODO: normalize optional fields once here.
}

# TODO: create subnets with for_each and output IDs by key.
```
### Tasks
1. Design the final input contract before writing resources.
2. Add validation for CIDR shape or reserved names.
3. Normalize optional fields in locals.
4. Create subnets with `for_each`, not repeated blocks.
5. Add optional NSGs only where requested.
6. Use `terraform console` to inspect your normalized value.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform validate
terraform console
terraform plan
terraform output
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Normalize once, consume many times.

**Hint 2:** Do not use `type = any` unless you can defend it.

**Hint 3:** Keys should be stable human identifiers.

### Solution
Ask: `Show me the solution for Lab 11`
## Lab 12 - Tag Governance With Collection Functions
**Difficulty:** Advanced  
**Cost:** Free to Low. Cost drivers: tagged resource group or storage account. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
`merge`, locals, validation, protected keys, precedence design.
### Scenario
Different teams pass tags differently. You need a production-friendly tag strategy that protects ownership tags.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
12-tag-governance-with-collection-functions/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "resource_tags" {
  type    = map(string)
  default = { managed_by = "portal" } # BROKEN: caller should not override this.
}

locals {
  mandatory_tags = { managed_by = "terraform", cost_center = "TODO" }
  final_tags     = merge(local.mandatory_tags, var.resource_tags) # BROKEN precedence.
}

# TODO: fix precedence and validation, then apply to at least two resources.
```
### Tasks
1. Define mandatory, environment, and resource-specific tags.
2. Choose and document precedence.
3. Prevent protected-key overrides with validation.
4. Apply final tags to multiple resources.
5. Use console to prove final maps for at least two cases.
6. Write a governance note explaining who owns each tag class.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform console
terraform validate
terraform plan
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Later `merge` arguments win.

**Hint 2:** Validation should catch bad intent early.

**Hint 3:** Tagging is finance and ownership, not cosmetic metadata.

### Solution
Ask: `Show me the solution for Lab 12`
## Lab 13 - Dynamic NSG Rules From Nested Inputs
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: NSGs and nested security rules. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Dynamic blocks, nested objects, input validation, Azure NSG constraints.
### Scenario
Application teams want to define NSG rules as data instead of duplicated resource blocks.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
13-dynamic-nsg-rules-from-nested-inputs/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "nsgs" {
  type = map(object({
    rules = list(object({
      name      = string
      priority  = number
      direction = string
      access    = string
      protocol  = string
      port      = string
    }))
  }))
  default = {
    app = { rules = [
      { name = "https", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", port = "443" },
      { name = "duplicate", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", port = "8443" } # BROKEN
    ] }
  }
}

# TODO: validate duplicate priorities and generate dynamic security_rule blocks.
```
### Tasks
1. Create one or more NSGs from the nested input.
2. Catch duplicate rule priorities before apply.
3. Generate `security_rule` dynamic blocks.
4. Break the input intentionally and record the validation error.
5. Compare inline rules with standalone rule resources.
6. Write your recommendation for production use.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform validate
terraform plan
az network nsg rule list --resource-group <rg> --nsg-name <nsg>
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Azure NSG priorities must be unique per direction.

**Hint 2:** Dynamic blocks should mirror provider schema.

**Hint 3:** Use validation for mistakes humans commonly make.

### Solution
Ask: `Show me the solution for Lab 13`
## Lab 14 - Private DNS Link Transformations
**Difficulty:** Expert  
**Cost:** Low. Cost drivers: private DNS zones and VNet links. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
`flatten`, compound keys, transformations, multi-resource `for_each`.
### Scenario
Inputs are grouped by spoke, but Terraform needs one private DNS zone link per VNet and zone pair.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
14-private-dns-link-transformations/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "spokes" {
  type = map(object({
    vnet_id = string
    zones   = list(string)
  }))
}

locals {
  zone_links = flatten([
    for spoke_name, spoke in var.spokes : [
      for zone in spoke.zones : {
        key     = "${spoke_name}-${zone}" # BROKEN: zone contains dots, think about stable keys.
        vnet_id = spoke.vnet_id
        zone    = zone
      }
    ]
  ])
}

# TODO: derive unique zones and per-spoke link maps.
```
### Tasks
1. Design caller-friendly spoke input.
2. Derive a unique set/map of private DNS zones.
3. Derive a map of VNet link objects with stable compound keys.
4. Implement resources from transformed locals.
5. Use console to inspect intermediate locals.
6. Explain why list indexes would be unsafe.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform console
terraform validate
terraform plan
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Use a list of objects first, then convert to a map.

**Hint 2:** Compound keys should be stable and readable.

**Hint 3:** Separate zone creation from VNet link creation.

### Solution
Ask: `Show me the solution for Lab 14`
## Lab 15 - Defensive Expressions and Normalization
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: locals-heavy root and optional resource inputs. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
`try`, `can`, `lookup`, `coalesce`, normalization, fail-fast design.
### Scenario
You need to support messy team input without turning the module into a silent bug factory.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
15-defensive-expressions-and-normalization/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "apps" {
  type = map(any) # BROKEN: tighten this after exploring the shape.
  default = {
    api = { subnet_key = "app", public = false }
    job = { public = null }
  }
}

locals {
  normalized_apps = {
    for k, v in var.apps : k => {
      subnet_key = try(v.subnet_key, "default") # TODO: decide if this should fail instead.
      public     = coalesce(try(v.public, null), false)
    }
  }
}
```
### Tasks
1. Identify which missing values should default and which should fail.
2. Replace `map(any)` with a safer type if possible.
3. Normalize the input once in locals.
4. Use `try` only where it improves the interface.
5. Create validation for ambiguous or unsafe input.
6. Write a note defending each default and each failure.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform console
terraform validate
terraform plan
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** `try` catches evaluation errors, not weak requirements.

**Hint 2:** Default only what you can explain to a reviewer.

**Hint 3:** Too much permissiveness makes modules hard to trust.

### Solution
Ask: `Show me the solution for Lab 15`
---
## Checkpoint 3 - HCL and Data Modeling
**Focus:** normalization, dynamic blocks, stable keys, validation, defensive expressions.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
# Level 4 - Terraform Modules and Composition
## Lab 16 - Foundation Module Design
**Difficulty:** Advanced  
**Cost:** Free to Low. Cost drivers: resource group, naming locals, tags. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Module boundaries, naming, tags, outputs, validation.
### Scenario
Build a small foundation module that standardizes naming and resource group creation without hiding too much.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
16-foundation-module-design/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
# root/main.tf
module "foundation" {
  source = "../modules/foundation"
  # TODO: pass prefix, environment, location, and tags.
}

# modules/foundation/variables.tf
variable "environment" { type = string } # TODO: validate dev/stage/prod.

# modules/foundation/main.tf
# TODO: create exactly one resource group and a normalized name local.
```
### Tasks
1. Define what the module owns and what stays in root.
2. Implement minimal inputs and validation.
3. Expose only useful outputs: name, location, ID, standard tags.
4. Write module README with design intent.
5. Use the module from an example root.
6. Reject one over-general feature and explain why.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 16`
## Lab 17 - Network Module With Stable Outputs
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: VNet, subnets, optional NSGs. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Module composition, subnet modeling, stable output maps.
### Scenario
Application teams need a reusable network module with outputs they can consume without inspecting internals.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
17-network-module-with-stable-outputs/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
module "network" {
  source = "../modules/network"
  subnets = {
    app = { cidr = "10.50.1.0/24" }
    data = { cidr = "10.50.2.0/24" }
  }
}

# BROKEN/TODO: module currently outputs a list. Replace it with a map keyed by subnet name.
output "subnet_ids" { value = [] }
```
### Tasks
1. Design the module input for address space and subnets.
2. Implement VNet and subnets with stable `for_each`.
3. Output subnet IDs by key, not by position.
4. Create one downstream resource that consumes `module.network.subnet_ids["app"]`.
5. Change subnet ordering and prove outputs remain stable.
6. Document output compatibility rules.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 17`
## Lab 18 - Aliased Providers Across Subscriptions
**Difficulty:** Expert  
**Cost:** Low. Cost drivers: two AzureRM provider aliases, shared and workload resources. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Provider aliases, module provider passing, subscription boundaries.
### Scenario
Shared security resources live in one subscription and workload resources in another. Prevent accidental deployment to the wrong place.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
18-aliased-providers-across-subscriptions/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
provider "azurerm" { features {} }

provider "azurerm" {
  alias           = "shared"
  features        {}
  subscription_id = var.shared_subscription_id
}

module "shared_rg" {
  source = "../modules/resource-group"
  # BROKEN/TODO: pass providers explicitly.
}
```
### Tasks
1. Design which resources belong in each subscription.
2. Configure default and aliased provider instances.
3. Pass provider aliases into child modules explicitly.
4. Run `terraform providers` and inspect wiring.
5. Add a deliberate missing provider mapping and observe the failure or wrong intent.
6. Write a safety note for reviewers.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 18`
## Lab 19 - Module Testing, Docs, and Versioning
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: module examples and validation roots. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Example-driven testing, versioning, documentation, compatibility.
### Scenario
A module is now used by multiple teams. It needs examples, compatibility rules, and a lightweight test workflow.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
19-module-testing-docs-and-versioning/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```text
modules/network/        # TODO: module under test
examples/minimal/       # TODO: smallest valid use
examples/with-nsg/      # TODO: second behavior path
CHANGELOG.md            # BROKEN: empty, define version rules
```
### Tasks
1. Create at least two example roots.
2. Run init, validate, and plan for each example.
3. Document inputs, outputs, assumptions, and cost.
4. Define breaking vs non-breaking changes.
5. Make one output change and classify its compatibility impact.
6. Write a release checklist.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 19`
## Lab 20 - Composable Platform Slice
**Difficulty:** Expert  
**Cost:** Low to Medium. Cost drivers: foundation, network, identity, monitoring modules. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Composition, platform boundaries, output contracts, maintainability.
### Scenario
Compose foundation, network, identity, and monitoring into a small platform root that another engineer could extend.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
20-composable-platform-slice/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```text
envs/dev/main.tf
modules/foundation/
modules/network/
modules/identity/
modules/monitoring/

# BROKEN/TODO: modules should not reach into each other directly.
# Root composition must pass outputs intentionally.
```
### Tasks
1. Sketch ownership boundaries before writing code.
2. Create or stub four small modules with narrow interfaces.
3. Compose them from `envs/dev`.
4. Avoid circular dependencies between modules.
5. Output only platform values future workloads need.
6. Write an architecture decision record.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 20`
---
## Checkpoint 4 - Module and Platform Design
**Focus:** module APIs, provider aliases, examples, composition, versioning.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
# Level 5 - Azure Networking with Terraform
## Lab 21 - Hub and Spoke Baseline
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: hub VNet, spoke VNets, peerings, route tables. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Hub/spoke design, CIDR planning, VNet peering, reusable network patterns.
### Scenario
Create a minimal hub/spoke network foundation for shared services and workloads.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
21-hub-and-spoke-baseline/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "vnets" {
  default = {
    hub   = { cidr = "10.60.0.0/16" }
    app01 = { cidr = "10.60.0.0/16" } # BROKEN: overlaps hub.
  }
}

# TODO: validate no overlaps manually in notes, then fix CIDRs and create peerings.
```
### Tasks
1. Design address space on paper first.
2. Fix overlapping CIDRs before apply.
3. Create hub and at least two spokes.
4. Create directional peerings intentionally.
5. Validate peering state with Azure CLI.
6. Explain how the design leaves room for private endpoints and AKS.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 21`
## Lab 22 - Private Endpoint DNS Troubleshooting
**Difficulty:** Expert  
**Cost:** Low to Medium. Cost drivers: storage account, private endpoint, private DNS zone, VNet link. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Private endpoints, private DNS, Azure CLI troubleshooting.
### Scenario
Terraform succeeds, but a VM or test client still resolves a storage account to a public endpoint.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
22-private-endpoint-dns-troubleshooting/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_private_endpoint" "storage" {
  # TODO: implement subnet and private service connection.
}

resource "azurerm_private_dns_zone" "blob" {
  name = "privatelink.blob.core.windows.net"
}

# BROKEN/TODO: DNS zone link or A record integration is missing.
```
### Tasks
1. Build storage, VNet, subnet, private endpoint, and DNS zone.
2. Intentionally omit or break one DNS component first.
3. Predict why private endpoint existence alone is insufficient.
4. Investigate records and links with Azure CLI.
5. Fix DNS and prove private resolution from the network path.
6. Write a troubleshooting runbook.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 22`
## Lab 23 - Egress With NAT, Routes, and Firewall Options
**Difficulty:** Advanced  
**Cost:** Medium. Cost drivers: NAT Gateway, public IP, subnet, optional route table/firewall. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
NAT Gateway, route tables, outbound design, cost-aware networking.
### Scenario
A workload subnet needs stable outbound IPs and predictable routing.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
23-egress-with-nat-routes-and-firewall-options/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_nat_gateway" "this" {
  name                = "${var.prefix}-nat"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# BROKEN/TODO: NAT without public IP association and subnet association does nothing useful.
```
### Tasks
1. Design the intended outbound path.
2. Add public IP and NAT association.
3. Attach NAT to the correct subnet.
4. Add a route table experiment and explain whether it changes egress.
5. Validate associations with Azure CLI.
6. Write cost and cleanup notes.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 23`
## Lab 24 - Application Gateway Backend Health
**Difficulty:** Expert  
**Cost:** Medium to High. Cost drivers: Application Gateway, backend, probes, NSG rules. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Application Gateway, health probes, backend pools, infrastructure vs service health.
### Scenario
Azure says the gateway exists. Users say the app is down. Distinguish provisioning success from backend health.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
24-application-gateway-backend-health/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
# TODO: create minimal Application Gateway and backend target.
# BROKEN/TODO: configure a probe path or port that you expect to fail first.

locals {
  probe_path = "/healthz-wrong"
}
```
### Tasks
1. Design the smallest gateway/backend lab you can afford.
2. Make one health probe setting intentionally wrong.
3. Predict the backend health state.
4. Inspect backend health with Azure CLI.
5. Fix probe path, host, port, or NSG rule.
6. Write a runbook separating gateway health from app health.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 24`
## Lab 25 - Load Balancer and Health Probe Failure
**Difficulty:** Advanced  
**Cost:** Low to Medium. Cost drivers: standard load balancer, backend pool, health probe, tiny backend. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Azure Load Balancer, health probes, backend pools, VM networking.
### Scenario
A load-balanced service is deployed, but the backend never becomes healthy.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
25-load-balancer-and-health-probe-failure/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "http"
  port            = 8080 # BROKEN: backend listens elsewhere.
}

# TODO: create or simulate backend NIC pool association and NSG rules.
```
### Tasks
1. Build or simulate the smallest load balancer backend.
2. Intentionally mismatch probe port or NSG rule.
3. Predict what Azure will report.
4. Inspect probes, backend pools, and NSG flow assumptions.
5. Fix the actual cause rather than bypassing the load balancer.
6. Write how this differs from Application Gateway health.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 25`
---
## Checkpoint 5 - Azure Networking
**Focus:** hub/spoke, private DNS, NAT, gateways, load balancers.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
# Level 6 - Azure Identity, Security, and Operations
## Lab 26 - Managed Identity and RBAC Timing
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: user-assigned identity, role assignment, scoped resource. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Managed identities, role assignments, propagation, least privilege.
### Scenario
Terraform creates an identity and immediately assigns access. Sometimes timing or scope is wrong. Understand why.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
26-managed-identity-and-rbac-timing/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_user_assigned_identity" "app" { # TODO }

resource "azurerm_role_assignment" "app" {
  scope                = azurerm_resource_group.this.id # BROKEN: maybe broader than needed.
  role_definition_name = "Contributor"                 # BROKEN: too broad for most cases.
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```
### Tasks
1. Define the exact operation the identity must perform.
2. Pick the narrowest role and scope that can satisfy it.
3. Create the identity and role assignment.
4. Inspect principal ID and role assignment with Azure CLI.
5. Explain propagation or permission delays if observed.
6. Replace broad permissions with least privilege.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 26`
## Lab 27 - Key Vault, RBAC, and Secret Safety
**Difficulty:** Expert  
**Cost:** Low. Cost drivers: Key Vault, secret, RBAC, sensitive variables. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Key Vault RBAC, secret handling, Terraform state risk, purge/retention.
### Scenario
Creating a Key Vault is easy. Managing secrets through Terraform safely is the real question.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
27-key-vault-rbac-and-secret-safety/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
variable "demo_secret" {
  type      = string
  sensitive = true
}

resource "azurerm_key_vault_secret" "demo" {
  name         = "demo"
  value        = var.demo_secret # RISK: inspect state implications.
  key_vault_id = azurerm_key_vault.this.id
}
```
### Tasks
1. Create a Key Vault with secure defaults.
2. Grant minimum RBAC needed for your Terraform identity.
3. Create one test secret using a non-real value.
4. Inspect state and explain where the secret exists.
5. Decide whether Terraform should manage secret values in production.
6. Document retention, purge protection, and cleanup implications.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 27`
## Lab 28 - Service Principal vs OIDC Authentication
**Difficulty:** Expert  
**Cost:** Free to Low. Cost drivers: app registration or user-assigned identity, federated credential, CI workflow. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Terraform auth, service principals, OIDC, workload identity federation.
### Scenario
Replace long-lived CI secrets with a federated identity design.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
28-service-principal-vs-oidc-authentication/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```yaml
# .github/workflows/plan.yml
permissions:
  contents: read
  # BROKEN/TODO: id-token permission missing for OIDC.

steps:
  - uses: actions/checkout@v4
  - uses: azure/login@v2
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```
### Tasks
1. Draw the old secret-based trust model.
2. Design the OIDC issuer, subject, and audience.
3. Create or document the Azure federated credential.
4. Fix the workflow permissions and login inputs.
5. Scope Azure role assignments minimally.
6. Explain what risk OIDC removes and what trust remains.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 28`
## Lab 29 - Security Scanning and Policy Gates
**Difficulty:** Advanced  
**Cost:** Free. Cost drivers: intentionally insecure Terraform and scanner workflow. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Static scanning, policy checks, secure defaults, review workflow.
### Scenario
The pipeline should reject obviously unsafe Terraform before anyone gets near apply.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
29-security-scanning-and-policy-gates/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_storage_account" "bad" {
  # BROKEN: insecure defaults for the lab. Fix after scanning.
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_0"
}
```
```yaml
# TODO: add fmt, validate, and one scanner such as tfsec or checkov.
```
### Tasks
1. Create one realistic insecure configuration.
2. Run one scanner locally or in CI.
3. Record findings and decide which are blocking.
4. Fix the insecure settings.
5. Add pipeline checks for fmt, validate, and scanning.
6. Document when suppressions are acceptable.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 29`
## Lab 30 - Platform Observability and Alerts
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: Log Analytics, diagnostic settings, metric alerts. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Diagnostics, Log Analytics, actionable alerts, runbooks.
### Scenario
A platform exists but lacks useful operator signals. Enable monitoring that someone can actually respond to.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
30-platform-observability-and-alerts/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "diag"
  target_resource_id         = "<TODO>"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  # BROKEN/TODO: choose categories intentionally, not all noise.
}
```
### Tasks
1. Pick two resources worth monitoring.
2. Send diagnostics to Log Analytics.
3. Create at least two alerts tied to response actions.
4. Avoid noisy alerts without runbooks.
5. Validate diagnostic settings and alert rules with Azure CLI.
6. Write one operator runbook.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 30`
---
## Checkpoint 6 - Identity, Security, and Operations
**Focus:** RBAC, Key Vault, OIDC, scanning, monitoring.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
# Level 8 - AKS and Terraform
## Lab 31 - AKS Baseline With Operational Awareness
**Difficulty:** Expert  
**Cost:** Medium. Cost drivers: AKS cluster, identities, node resource group, monitoring. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
AKS provisioning, managed identity, monitoring, cost awareness.
### Scenario
Deploy a small AKS cluster and inspect the Azure side effects that Terraform does not make obvious.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
31-aks-baseline-with-operational-awareness/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.prefix

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_B2s" # TODO: verify region availability and cost.
  }

  identity { type = "SystemAssigned" }
}
```
### Tasks
1. Review AKS cost before applying.
2. Deploy the smallest cluster that teaches identity and node behavior.
3. Connect with `kubectl`.
4. Inspect node resource group and identities.
5. Document Azure resources created around AKS.
6. Destroy promptly and verify cleanup.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 31`
## Lab 32 - AKS Node Pools and Replacement Risk
**Difficulty:** Expert  
**Cost:** Medium. Cost drivers: AKS user node pool. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Node pools, immutable settings, migration planning, rollout safety.
### Scenario
A node pool change looks small in code review, but Terraform says replacement. Decide how to roll safely.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
32-aks-node-pools-and-replacement-risk/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_kubernetes_cluster_node_pool" "apps" {
  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_B2s"
  node_count            = 1
  # TODO after apply: change a setting likely to force replacement.
}
```
### Tasks
1. Add a user node pool.
2. Change one property likely to force replacement.
3. Predict the plan and operational impact.
4. Inspect nodes with kubectl and Azure CLI.
5. Design an add-new-pool, drain, migrate, remove-old-pool strategy.
6. Do not casually apply replacement.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 32`
## Lab 33 - AKS Networking and Permission Failures
**Difficulty:** Expert  
**Cost:** Medium. Cost drivers: AKS, explicit subnet, managed identity, role assignment. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Azure CNI concepts, subnet RBAC, identity scope, troubleshooting.
### Scenario
AKS creation fails because the cluster identity cannot operate on the selected subnet.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
33-aks-networking-and-permission-failures/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_kubernetes_cluster" "this" {
  # TODO: use an explicit subnet_id in default_node_pool.
  identity { type = "SystemAssigned" }
}

# BROKEN/TODO: missing Network Contributor assignment on the subnet for the cluster identity.
```
### Tasks
1. Deploy or plan AKS into a subnet you control.
2. Observe or simulate the missing permission failure.
3. Identify which identity needs which permission on which scope.
4. Add least-privilege role assignment.
5. Validate role assignment and cluster readiness.
6. Explain why Terraform graph order does not solve RBAC.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 33`
## Lab 34 - Private AKS and Operator Access
**Difficulty:** Expert  
**Cost:** Medium. Cost drivers: private AKS, private DNS, runner or jump host design. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Private AKS, private DNS, access paths, operator workflow.
### Scenario
Security wants a private control plane. Engineers still need a workable operational path.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
34-private-aks-and-operator-access/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
resource "azurerm_kubernetes_cluster" "private" {
  # TODO: private_cluster_enabled = true
  # BROKEN/TODO: no operator access path is designed yet.
}
```
### Tasks
1. Design who can reach the private API server.
2. Implement or simulate private cluster settings.
3. Explain why normal laptop access may fail.
4. Design runner, VPN, bastion, or jump host access.
5. Validate private FQDN and DNS assumptions.
6. Write an operator access runbook.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 34`
## Lab 35 - AKS Ingress and Platform Integration
**Difficulty:** Expert  
**Cost:** Medium. Cost drivers: AKS ingress, gateway or ingress controller, DNS/cert boundary. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Ingress, gateway integration, DNS, certificate ownership.
### Scenario
Expose workloads through a controlled ingress path without blurring platform and app ownership.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
35-aks-ingress-and-platform-integration/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```hcl
# TODO: choose an ingress path: Application Gateway ingress concepts, NGINX ingress, or simulated design.
# BROKEN/TODO: DNS and certificate ownership are not defined.

variable "ingress_hosts" {
  type = list(string)
}
```
### Tasks
1. Choose the ingress architecture and justify it.
2. Define who owns DNS, certificates, and routing rules.
3. Implement minimal Terraform pieces or a documented simulation if cost is too high.
4. Deploy a test workload if using a live cluster.
5. Validate endpoint, DNS, and routing behavior.
6. Write a handoff contract between platform and app teams.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 35`
---
## Checkpoint 7 - AKS
**Focus:** node pools, private control plane, subnet RBAC, ingress, operational paths.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
# Level 9-11 - CI/CD, Environments, and Production Troubleshooting
## Lab 36 - Terraform PR Pipeline With Plan Artifacts
**Difficulty:** Advanced  
**Cost:** Free to Low. Cost drivers: GitHub Actions or Azure DevOps workflow, Terraform root. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
fmt, validate, plan, plan artifacts, approval boundaries.
### Scenario
Design a PR workflow that reviews Terraform changes before anything can be applied.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
36-terraform-pr-pipeline-with-plan-artifacts/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```yaml
name: terraform-pr
on: [pull_request]
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # TODO: setup Terraform and auth.
      # BROKEN: do not run apply on pull_request.
      - run: terraform apply -auto-approve
```
### Tasks
1. Remove unsafe apply from PR workflow.
2. Add fmt, validate, init, and plan stages.
3. Decide how plan artifacts are stored and protected.
4. Separate apply into a merge or environment-approved workflow.
5. Avoid leaking sensitive plan output.
6. Document reviewer responsibilities.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 36`
## Lab 37 - Drift Detection Workflow
**Difficulty:** Advanced  
**Cost:** Low. Cost drivers: scheduled workflow and small Terraform root. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Scheduled plans, `-detailed-exitcode`, drift reporting, triage.
### Scenario
Manual Azure changes are happening. You need detection without blind remediation.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
37-drift-detection-workflow/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```yaml
on:
  schedule:
    - cron: "0 6 * * *"

# TODO: run terraform plan -detailed-exitcode.
# BROKEN: any non-zero exit is currently treated as generic failure.
```
### Tasks
1. Design a scheduled drift check.
2. Use `terraform plan -detailed-exitcode` correctly.
3. Simulate drift by changing a tag manually.
4. Make exit code 2 report drift, not auto-apply.
5. Write the triage path and ownership decision.
6. Explain when Terraform should win versus Azure should be adopted.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 37`
## Lab 38 - Plan JSON Policy Gates
**Difficulty:** Expert  
**Cost:** Free. Cost drivers: tfplan JSON, jq or policy script. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Plan JSON, policy checks, change classification, approval logic.
### Scenario
Block risky infrastructure changes using machine-readable plan evidence.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
38-plan-json-policy-gates/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```
```jq
# BROKEN/TODO: write a jq query that detects delete or replace actions.
.resource_changes[].change.actions
```
### Tasks
1. Generate a saved plan and JSON.
2. Classify resource changes by action.
3. Write one policy that blocks delete or replace without approval.
4. Add one policy for public exposure or broad RBAC.
5. Fail CI on policy violation.
6. Explain why parsing human plan text is weaker.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 38`
## Lab 39 - Environment Promotion and Multi-Subscription Layout
**Difficulty:** Expert  
**Cost:** Low to Medium. Cost drivers: dev/stage/prod roots, provider aliases, pinned versions. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Environment separation, workspaces vs directories, provider aliases, promotion, rollback.
### Scenario
Design safe promotion across environments and subscriptions without gambling on hidden differences.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
39-environment-promotion-and-multi-subscription-layout/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```text
envs/dev/main.tf
envs/stage/main.tf
envs/prod/main.tf
modules/network/

# BROKEN/TODO: all environments currently point at the same backend key.
# TODO: pin provider and module versions intentionally.
```
### Tasks
1. Compare workspaces and directory-based environments.
2. Create dev, stage, and prod root layouts.
3. Ensure each environment has a distinct backend key and variables.
4. Use provider aliases for subscription boundaries where needed.
5. Define what gets promoted: code, variables, module versions, or artifacts.
6. Write rollback and promotion checklists.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 39`
## Lab 40 - Capstone: Inherited Azure Platform Rebuild
**Difficulty:** Expert  
**Cost:** Medium to High. Cost drivers: messy platform repository with networking, AKS, Key Vault, monitoring, CI/CD. Destroy with `terraform destroy` unless the lab tells you to preserve or inspect state first. Check manually for retained Azure resources that can keep billing.
### Skills Tested
Audit, state recovery, drift, imports, module redesign, security hardening, CI/CD, documentation.
### Scenario
You join a company whose Terraform repository works, but nobody trusts it. It has hardcoded values, drift, weak RBAC, poor modules, unsafe CI, and missing documentation.
### Architecture Questions
1. What is the smallest realistic architecture that teaches this scenario?
2. Which parts should Terraform own, and which are external facts to inspect?
3. What could go wrong in production if you apply without understanding the plan?
### Starting Repository
```text
40-capstone-inherited-azure-platform-rebuild/
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── notes.md
```
### Minimal or Broken Starter
```text
40-capstone-inherited-azure-platform-rebuild/
├── legacy/
│   ├── main.tf          # BROKEN: duplicated resources, hardcoded names, broad roles
│   ├── terraform.tfstate # DO NOT EDIT BY HAND
│   └── pipeline.yml     # BROKEN: apply on PR and long-lived secrets
├── envs/
├── modules/
├── docs/
└── incidents/

# TODO: create the messy seed yourself or ask for a seeded draft.
# Do not list every problem up front. Discover and classify them.
```
### Tasks
1. Inventory configuration, state, Azure actual resources, and CI/CD behavior.
2. Classify problems by risk and urgency before refactoring.
3. Stabilize backend and state safety first.
4. Resolve drift and imports intentionally.
5. Refactor into maintainable modules and environment roots.
6. Add secure authentication, policy checks, approvals, monitoring, and docs.
7. Present a staged rollout and rollback plan.
### Constraints
Do not paste a complete solution. Do not edit `.tfstate` by hand. Do not use broad `ignore_changes`, `-target`, sleeps, or over-scoped Azure permissions unless the lab explicitly asks you to test and explain that tradeoff. Keep resources cheap and destroy promptly after validation.
### Validation
```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform state list
az resource show --ids <resource-id>
terraform destroy
```
### Expected Reasoning
A strong Terraform/Azure engineer separates desired configuration, Terraform state bindings, provider behavior, Azure API behavior, and operational risk before deciding what to change. Your written note should show that separation.
### Hints
**Hint 1:** Start by collecting evidence, not by changing resources.

**Hint 2:** Compare configuration -> state -> Azure actual state before risky actions.

**Hint 3:** If a plan is surprising, classify actions and find the first cause.

### Solution
Ask: `Show me the solution for Lab 40`
---
## Checkpoint 8 - Delivery, Environments, and Capstone Readiness
**Focus:** pipelines, drift, policy, promotion, production judgment.
### Theoretical Quiz
1. What did Terraform know before apply, and why?
2. What changed in configuration, state, and Azure actual state?
3. Which changes were safe, risky, or destructive?
4. Which Azure CLI evidence mattered most?
5. What would production require beyond the lab?
### Prediction Exercise
Create a tiny change based on the last five labs. Before running plan, predict create, update, replace, destroy, or no-op for each resource. Then run the plan and grade your prediction.
### Debugging Exercise
Introduce one realistic failure from the last five labs. Collect evidence and explain the root cause before fixing it.
### Implementation Challenge
Build a small integrated pattern using at least two concepts from the last five labs. Keep it independently runnable and cheap.
### Azure Architecture Question
What would be different in a real production subscription with shared ownership, security review, cost controls, monitoring, and rollback requirements?
### Grading
Submit commands run, plan observations, Azure CLI evidence, and your decision note. Ask for grading only after including that evidence.
---
## Final Review Rubric
| Area | 0-2 | 3-5 | 6-8 | 9-10 |
|---|---|---|---|---|
| Plan prediction | guesses | reads plan after the fact | predicts most changes | predicts and explains blast radius before running |
| State safety | edits blindly | uses state commands with gaps | backs up and validates | repairs state deliberately with strong evidence |
| Azure reasoning | portal-only | basic CLI checks | compares state/config/Azure | explains provider, API, RBAC, DNS, and networking behavior clearly |
| Module design | copy/paste | generic abstractions | useful interfaces | stable, documented, versioned, maintainable modules |
| Security | broad access | partial least privilege | mostly safe | least privilege, secret-aware, reviewable, policy-backed |
| Operations | deploy-only | basic cleanup | monitoring and CI present | runbooks, rollback, drift detection, approvals, production judgment |
## Cleanup Checklist
After each applied lab:
```bash
terraform destroy
terraform state list
az group list --query "[?contains(name, 'tfaz')]" --output table
az resource list --query "[?contains(name, 'tfaz')]" --output table
```
Also check public IPs, managed disks, AKS node resource groups, NAT Gateway, Application Gateway, Azure Firewall, Log Analytics workspaces, Key Vault soft-delete retention, and backend storage accounts.
## Capstone Submission Package
For the final lab, submit an audit report, prioritized risk register, state and drift evidence, refactor plan, secure authentication design, remote-state design, CI/CD workflows, rollback plan, and production-ready documentation. Do not reveal all hidden problems up front when using this curriculum interactively; the learning value is in discovery.
