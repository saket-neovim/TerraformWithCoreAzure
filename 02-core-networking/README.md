# Project 2 - Core Azure Networking

Build a small Azure network foundation with Terraform.

This lab is intentionally incomplete. Use the TODOs in the Terraform files and your
notes to implement the missing resources yourself.

## Architecture Target

- One resource group.
- One virtual network.
- Three subnets: `web`, `app`, and `data`.
- One network security group per subnet.
- Inbound NSG rules based on the intended traffic flow.
- One route table associated to the subnets.
- Optional NAT Gateway and public IP when `enable_nat_gateway = true`.

## Suggested Workflow

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform state list
terraform destroy
```

Also validate the real Azure resources:

```bash
az network vnet show --name <vnet-name> --resource-group <resource-group-name>
az network vnet subnet list --vnet-name <vnet-name> --resource-group <resource-group-name> --output table
az network nsg list --resource-group <resource-group-name> --output table
az network route-table list --resource-group <resource-group-name> --output table
```

## Before You Code

Write your intended traffic flow in `notes.md` first:

- What can reach `web`?
- What can reach `app`?
- What can reach `data`?
- What traffic is intentionally not allowed?
- Are you enabling NAT Gateway, and why?

