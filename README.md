# Azure Infrastructure Labs with Terraform

A collection of Azure infrastructure exercises covering networking, reusable modules, managed identity, Key Vault, and VM application hosting. The code and study notes focus on explaining resource dependencies, access boundaries, state changes, and operational tradeoffs.

**Status:** configuration and learning notes are present for Labs 1–6. No committed deployment evidence verifies completion of the full curriculum. Private connectivity and delivery automation remain curriculum goals. Treat the configuration as lab work that needs review before deployment.

## Explore the repository

| Lab | Configuration and focus |
| --- | --- |
| [01 — Starter stack](01-starter-stack/) | Resource group, storage, Log Analytics, tags, and drift |
| [02 — Core networking](02-core-networking/) | Subnets, NSGs, route-table associations, and NAT Gateway |
| [03 — State and refactoring](03-refactor/) | State ownership and refactoring practice; backend example is commented out |
| [04 — Platform modules](04-reusable-platform-modules/README.md) | Foundation, network, and diagnostics modules with dev/test roots |
| [05 — Identity and secrets](05-identity-rbac-keyvault/README.md) | User-assigned identity, scoped RBAC, Key Vault, and storage data access |
| [06 — Application hosting](06-application-hosting/README.md) | Linux VM, cloud-init, identity-backed secret access, and guest-log collection |

[Curriculum](AzureTerraformHandsOnCurriculum.md) · [Lab workflow and evidence guide](HowToUseAzureTerraformLabs.md) · [Earlier exercise set](Tasks1.md)

## Design and learning decisions

- Each numbered lab is a separate Terraform root; Lab 4 has separate environment roots and shared modules.
- Azure CLI authentication supplies operator identity. Subscription and tenant IDs belong in local environment variables rather than committed provider files.
- Lab 5 owns the identity and Key Vault consumed through data sources in Lab 6. Inspect that dependency before planning or cleaning up either lab.
- Networking exercises distinguish NSGs, route tables, and NAT Gateway. A dependency graph does not prove traffic is correctly restricted.
- Secret values marked `sensitive` can still be stored in Terraform state and saved plans. Use dummy data and protect both artifacts.

## Prerequisites and first steps

Install Git, Terraform compatible with the selected lab's `versions.tf`, and Azure CLI. The curriculum baseline is Terraform 1.6+ with AzureRM 3.x; use each root's declared constraints and committed lock file as the source of truth. Azure deployments require a disposable subscription/resource group and sufficient resource and RBAC permissions.

```bash
az login
az account set --subscription '<your-subscription-id>'
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
export ARM_TENANT_ID="$(az account show --query tenantId -o tsv)"

cd 01-starter-stack
cp terraform.tfvars.example terraform.tfvars
# Edit the ignored local file: use your own unique prefix and owner tag.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
```

Review the resource changes and cost before deciding to apply. Use the selected lab README for its deployment and inspection steps. For Lab 4, run Terraform from `envs/dev` or `envs/test`, not the module directory.

## Validation and evidence

Static formatting/validation checks configuration; a plan also depends on real credentials and resources. Deployment success, connectivity, RBAC propagation, and guest-log ingestion need separate observations.

Keep short, redacted evidence for each experiment: plan expectations, observed resource changes, a failure diagnosis and recovery, and a cleanup result. The existing `notes.md` files include working answers and unfinished sections; they are not a completion certificate. Preserve TODOs as study checkpoints.

## Cost, cleanup, and limitations

VMs, public IPs, NAT Gateway, storage, and log ingestion can incur charges. These exercises do not establish production capacity, availability, or security guarantees. Inspect NSG rule direction, address prefixes, and ports before deployment, especially in the application-hosting lab.

When finished, review `terraform plan -destroy` in the root that owns the resources before running `terraform destroy`. Clean up Lab 6 before Lab 5; verify retained backend resources and any soft-deleted Key Vault separately.

Never commit local `.tfvars`, environment files, state, saved plans, tokens, or raw secret responses. Commit sanitized examples and provider lock files. Removing a value from current files does not remove older copies from Git history.
