# Project 6 Notes

## Prediction Before Plan

| Resource or data source | Expected action | Known before apply | Unknown until apply | Replacement risks |
|---|---|---|---|---|
| Lab 5 metadata lookups | | | | |
| Resource group and network | | | | |
| Public IP and NIC | | | | |
| VM and managed OS disk | | | | |
| Log Analytics, AMA, DCR, association | | | | |

## Design Decisions

- Why the VM path:
- Intended operator access path:
- Explicit outbound connectivity:
- NSG default rules and listening address:
- Lab 5 resource ownership and cleanup order:
- UAMI resource ID vs client ID vs principal ID:
- Runtime token audience and permission scope:
- Terraform ordering vs RBAC propagation:
- Cloud-init completion vs VM provisioning success:
- Platform metrics vs guest logs:
- Expected costs and shutdown/cleanup plan:

## Troubleshooting

- VM creation failed with `SkuNotAvailable` for `Standard_B1s` in `eastus`.
- On 2026-10-07, the subscription SKU lookup showed location restrictions for
  `Standard_B1s`, `Standard_B1ms`, and `Standard_B2s`. `Standard_D2as_v4` had no
  listed restrictions and supports x64, matching the current Ubuntu image.
- Changed the local `terraform.tfvars` VM size to `Standard_D2as_v4`, keeping
  existing resources in `eastus`. This is a larger, higher-cost lab alternative;
  keep it short-lived and destroy after validation. Deployment capacity remains
  unconfirmed until a successful apply.

Complete one access/bootstrap case and one identity/monitoring case.

| Case | Change made | Symptom and failure phase | Diagnostic evidence | Root cause | Fix | Production lesson |
|---|---|---|---|---|---|---|
| Access or bootstrap | | | | | | |
| Identity or monitoring | | | | | | |

## Config, State, and Azure Comparison

- Terraform resource address and expected settings:
- State resource ID and relevant non-sensitive attributes:
- Matching Azure resource and guest observations:
- Drift detected and how ownership was restored:
- What a no-change plan proves and what it cannot prove:

## Decision Note

- Hosting choice and tradeoffs:
- Networking and least privilege:
- Runtime secret handling and state risks:
- Monitoring evidence and blind spots:
- What operators may change manually:
- Production changes:
- Resources destroyed or intentionally preserved, with reason:

## Interview Answers

Answer the numbered questions in README.md here after completing the lab.
