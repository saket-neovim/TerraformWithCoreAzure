# Project 6 - Application Hosting Project

**Difficulty:** Advanced  
**Estimated time:** 10-18 hours  
**Cost:** Low to moderate; VM compute, managed disks, a Standard public IP, and log ingestion are billable. Check current regional pricing before apply and destroy after validation.

## Scenario

Your team needs a small internal web service and an operational handoff. Build a Linux VM with Terraform, bootstrap the application, and prove that operators can reach it only through the intended path. Use the managed identity from Lab 5 to read its dummy Key Vault secret from the running application. Send guest logs to Log Analytics and diagnose failures using evidence.

The default path is a Linux VM, as specified in the curriculum. App Service is an optional comparison after completing the VM path. The Terraform and application files are intentionally incomplete; completing TODOs is the assignment.

## Architecture Target

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

## Azure Services Practiced

- Azure VM, NIC, Standard public IP, and managed OS disk.
- VNet, subnet, NSG association, effective security rules, and explicit egress.
- User-assigned managed identity, IMDS, Key Vault data-plane RBAC.
- Azure Monitor, Log Analytics, Azure Monitor Agent (AMA), DCR, and syslog.
- Optional managed data disk and managed-identity Blob Storage access.

## Terraform Skills Practiced

- Referencing existing resources with data sources without changing ownership.
- Mapping identity resource ID, client ID, and principal ID to their uses.
- Modeling dependencies and distinguishing ordering from propagation delays.
- Rendering cloud-init with `templatefile`, `yamlencode`, and `base64encode`.
- Reviewing replacement behavior and separating infrastructure from guest health.
- Creating useful operational outputs and comparing config, state, and Azure.

## Prerequisites and Ownership

1. Read Lab 5's `README.md`, `notes.md`, and `evidence.md`.
2. Confirm its managed identity, RBAC-enabled Key Vault, and enabled dummy secret still exist. If destroyed, recreate them from Lab 5 before starting. A working Lab 5 plan does not prove runtime access.
3. Confirm `Key Vault Secrets User` is granted to the managed identity at the intended vault or narrower secret scope. Use `principal_id` for RBAC, identity resource ID for VM attachment, and `client_id` for selecting the identity in IMDS.
4. Confirm the Terraform runner can create the Lab 6 resources and attach the existing identity. This management-plane permission is separate from the app's secret-read permission.
5. Check Azure subscription context, VM quota, and image/SKU availability in `eastus`. Default to `Standard_B1s`; if unavailable or memory is insufficient for the app and AMA, choose another small SKU and record the cost decision.
6. Have an existing SSH key pair. Pass only the public-key path to Terraform. Find your current public IPv4 address and supply `/32`; the example address will not allow real access.
7. Key Vault networking must permit the VM's chosen outbound path. A token and correct RBAC cannot bypass a firewall. Keep only dummy data in this temporary lab.

Do not read the secret value with a Terraform data source or pass it through cloud-init. Lab 6 needs only the vault URI, secret name, and identity metadata. Destroy Lab 6 before destroying Lab 5.

## Starting Repository Shape

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

## Starter Code

The checked-in files provide provider requirements, typed inputs, naming and tag locals, Lab 5 metadata lookups, and TODOs for resources, cloud-init, outputs, and the application. Use Terraform `>= 1.6` and AzureRM `~> 3.0` for consistency with this workspace. Read documentation for the locked provider version when implementing resources.

Copy `terraform.tfvars.example` to a local `terraform.tfvars`. Replace the documentation-only source address, SSH public-key path, owner, and Lab 5 names. Commit only the example file. Fill in `notes.md` before running a plan.

Formatting and validation can succeed on an incomplete scaffold. A successful plan with only data-source reads is not a completed lab.

## Application Contract

Implement a tiny Python service; the standard library is sufficient. Run it as a dedicated unprivileged account and bind to `127.0.0.1:8080`.

| Endpoint | Required behavior | Evidence |
|---|---|---|
| `GET /` | HTTP 200 with a lab/version response | Confirms the deployed app version |
| `GET /health` | HTTP 200 when the process is alive; no dependency calls | Separates app health from Key Vault failures |
| `GET /ready` | Acquire an IMDS token, read the dummy secret, discard its value; HTTP 200 with `{"secret_read": true}` on success, HTTP 503 with `{"secret_read": false}` on failure | Proves the attached identity can access the data plane |

For `/ready`, use the VM-local IMDS endpoint `http://169.254.169.254/metadata/identity/oauth2/token`, `Metadata: true`, API version `2018-02-01`, the attached UAMI client ID, and the Key Vault token resource `https://vault.azure.net`. Bypass HTTP proxies for IMDS. Call the vault's HTTPS secret endpoint with the bearer token and a supported Key Vault API version. Keep tokens and secret values in process memory only. See [VM managed identities and IMDS](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-managed-identities-work-vm).

Use finite timeouts and bounded retries for transient failures. Log sanitized success/failure, status codes, and a correlation ID to the syslog `user` facility. Do not log response bodies, tokens, authorization headers, or secret values. Do not use `az login`, your laptop's credentials, storage account keys, or a saved client secret inside the service.

## Core Tasks

### Part A - Predict and Build the Network

1. Predict all created resources and external metadata reads in `notes.md`. Identify known values, computed IDs/IPs, and replacement risks.
2. Describe the access path, expected NSG behavior, egress path, and Lab 5 ownership boundary.
3. Create the Lab 6 resource group, VNet, subnet, NSG, and association. Use stable names and common tags.
4. Permit inbound TCP/22 only from `admin_source_cidr`. Do not add inbound HTTP/HTTPS/8080 allow rules. Explain default NSG rules, including the default VNet allowance.
5. Create the Standard Static public IP and NIC. Explain why a private NIC address alone does not guarantee outbound connectivity.

### Part B - Bootstrap and Prove Runtime Identity

1. Implement the VM with an Ubuntu LTS image available in the chosen region, a small SKU, SSH public key, disabled password authentication, and a managed OS disk.
2. Attach the Lab 5 UAMI and enable Azure-managed boot diagnostics.
3. Complete `app/app.py` and `cloud-init.yaml.tftpl`. Render the app source and non-secret metadata into guest files with safe YAML serialization. Enable `rsyslog`, install the app's systemd unit, start it on boot, and emit a sanitized bootstrap marker.
4. Ensure Terraform establishes the intended NSG association before VM bootstrap. Prefer resource references; document any extra explicit dependency.
5. Review the complete saved plan before apply. It must create only Lab 6 resources; investigate any proposed change to Lab 5 resources.
6. Validate cloud-init and systemd independently of Azure's VM provisioning status.
7. Use an SSH local tunnel to test `/`, `/health`, and `/ready`. Prove a direct public TCP/8080 request cannot reach the app.
8. Explain why your own successful Azure CLI secret read would not prove that the VM's managed identity works.

Changing `custom_data` forces VM replacement in AzureRM 3.117.1. Inspect the plan before applying a bootstrap edit and explain the difference between cloud-init first-boot execution and editing a file in a running guest. See [AzureRM Linux VM reference](https://github.com/hashicorp/terraform-provider-azurerm/blob/v3.117.1/website/docs/r/linux_virtual_machine.html.markdown).

### Part C - Monitor the Guest

1. Create the Log Analytics workspace with 30-day retention.
2. Install `AzureMonitorLinuxAgent` using the VM extension resource. Configure AMA to authenticate using the attached UAMI; verify supported extension versions in your region. See [installing and managing AMA](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage).
3. Create a Linux DCR with a `Microsoft-Syslog` source, a Log Analytics destination, and a matching data flow. Collect `user` facility events at `Info`, `Notice`, `Warning`, `Error`, `Critical`, `Alert`, and `Emergency` levels. Associate the DCR with the VM.
4. Ensure guest `rsyslog` receives the app's events. Emit a unique `lab06` marker using `logger` and verify it reaches Log Analytics, allowing for ingestion delay.
5. Explain why boot diagnostics, platform metrics, an installed AMA extension, and collected guest logs are different evidence. See [collecting syslog with AMA](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/data-collection-syslog).

Do not substitute the retired legacy Log Analytics agent. A VM diagnostic setting alone does not complete the required guest syslog pipeline.

### Part D - Handoff, Break/Fix, and Cleanup

1. Complete operational outputs in `outputs.tf`, including both the workspace resource ID and workspace customer GUID.
2. Inspect state for selected resources and match their IDs to Azure. Avoid dumping unrelated state or secrets.
3. Complete one access/bootstrap troubleshooting case and one identity/monitoring case below.
4. Write a decision note, save sanitized evidence, restore the working configuration, and check the final plan.
5. Review a destroy plan, destroy Lab 6, and confirm no Lab 6 VM, disk, or public IP is left. Then decide whether to destroy Lab 5.

## Validation Commands

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

## Troubleshooting Exercise

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

## Interview Questions

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

## Decision Note

Explain your hosting choice, access path, explicit egress, least-privilege identity, runtime secret handling, log pipeline, and remaining blind spots. Compare at least one resource across Terraform configuration, Terraform state, and actual Azure/guest observations. State what changes you would make for production: deployment pipeline, patching, availability, private access, alerting, TLS/authentication, and state access control.

## Optional Stretch Tasks

- Add one small Standard_LRS managed data disk, attach it with a stable LUN, mount by UUID, and explain OS disk vs temporary disk vs managed data disk lifecycle. Review a replacement plan before risking persisted data.
- Add a runtime blob-read check using the Lab 5 `Storage Blob Data Reader` grant. Seed a harmless blob as an authorized operator; prove the VM's identity can read it without account keys and record how its token audience differs from Key Vault.
- Compare a minimal App Service design: what moves to platform ownership, how runtime identity is attached, and why VNet integration controls outbound access rather than making inbound requests private. Private endpoint implementation belongs in Lab 7. See [App Service VNet integration](https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration).

## Cleanup

```bash
terraform plan -destroy -out=destroy.tfplan
terraform show destroy.tfplan
terraform apply destroy.tfplan
az group exists --name "$LAB_RG"
```

Expect `false` for the Lab 6 resource group. If it remains, list its resources and diagnose cleanup. Lab 5 data sources must not appear as resources to destroy. Destroy Lab 5 afterward if it is no longer needed; document any intentional preservation. Deallocation stops compute billing but is not full cleanup of disks and public IP resources.

## Grading Rubric

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

## Hidden Solution Policy

Build from the TODOs yourself. Ask for conceptual hints, targeted review, or help with a specific error before requesting a full solution.
