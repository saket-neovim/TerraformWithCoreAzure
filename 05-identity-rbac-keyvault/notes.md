# Project 5 Notes

## Prediction

Before running `terraform plan`, predict:

- Which resources Terraform will create:
- Which values are known before apply:
- Which values are unknown until apply:
- Which role assignments depend on generated IDs:

## Identity And RBAC Decisions

Identity decision:

Key Vault authorization model:

Key Vault secret handling:

RBAC scopes chosen:

Storage data access decision:

Terraform-running identity permission path:

Terraform state risks:

What operators may change manually:

Production changes:

## Troubleshooting Notes

Record at least one break/fix exercise:

- Scenario:
- Failure phase: validate / plan / apply / Azure CLI validation
- Error or symptom:
- Root cause:
- Fix:
- Production lesson:

## Interview Answers

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

