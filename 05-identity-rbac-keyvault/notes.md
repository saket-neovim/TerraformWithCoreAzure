# Project 5 Notes

## Prediction

Before running `terraform plan`, predict:

- Which resources Terraform will create: Basically, all the resources that we have mentioned in our config 
- Which values are known before apply: The precomputed values will be known before apply. 
- Which values are unknown until apply: Values like resource IDs will be known after creation. 
- Which role assignments depend on generated IDs: Key Vault 

## Identity And RBAC Decisions

Identity decision: Role-based access control. 

Key Vault authorization model: enable_rbac_authorization

Key Vault secret handling: Low-risk, one-time-use dummy password 

RBAC scopes chosen: Key Vault And storage container 

Storage data access decision: Storage blob data access reader 

Terraform-running identity permission path:  Grant the identity running
  Terraform Key Vault Secrets Officer on the lab Key Vault so Terraform can
  create the app-config secret.

Terraform state risks: The password will be there in the state, and it won't be in an encrypted format. Hence, state files and plan files must not be committed. 

What operators may change manually: Avoid manual changes through the console and always use Terraform config. 

Production changes: Use remote encrypted state, stricter RBAC, diagnostics,
  purge protection, private networking where needed, and avoid storing real
  secret values in Terraform.

## Troubleshooting Notes

Record at least one break/fix exercise:

- Scenario:
- Failure phase: validate / plan / apply / Azure CLI validation
- Error or symptom:
- Root cause:
- Fix:
- Production lesson:

## Interview Answers

1. What is a user-assigned managed identity? User-assigned managed identity is an identity which is a resource on its own and can then be attached to other resources to perform specific actions. Without attaching passwords 
2. How is a user-assigned managed identity different from a system-assigned managed identity?User-assigned managed identity lives a life cycle of its own, while the system-assigned managed identity is attached to a resource. When the resource is deleted, the system-assigned managed identity is also deleted. 
3. What is the difference between Azure RBAC and Key Vault access policies?Azure role-based access control is the standard way of granting access in Azure for Azure resources. Key Vault access policies are the older, deprecated way. 
4. Why does Key Vault have both management-plane and data-plane permissions?Keyvault has both management plane and data plane permissions because the management plane allows who can access the Keyvault, and the data plane allows who can access the data within the Keyvault. 
5. Why is `Reader` not enough to read Key Vault secrets?Reader role is not enough to access key vault secrets because it comes under data plane management and requires a separate permission or role. 
6. What is an RBAC scope?And RBAC scope is the scope at which the permission applies or the role applies. 
7. Why should role assignments use the narrowest practical scope?The role assignment should use the narrowest practical scope to keep in line with the least privilege principle. 
8. What is RBAC propagation delay, and how would you troubleshoot it?RBAC propagation delay is basically that the RBAC is created, but before that, it has to create the resource itself, so it's attaching the RBAC to all the necessary resources. 
9. Why can Terraform state contain secrets even when variables are marked sensitive? Terraform needs to know the actual values of the secrets before it can put them into the Azure console via the config. Hence, even if it's marked as sensitive, it can still show it. Only the CLI is blocked. It's hidden. 
10. Should Terraform create production secret values? Why or why not?No, Terraform should not create production secret values because it'll always be there in the config. It's better to have a separate secret management tool. 
11. What does `principal_id` represent for a managed identity? Principal ID is the entra-object ID of the managed identity service principal's 
12. Why might a role assignment need an explicit dependency? A role assignment needs an explicit dependency because sometimes it would create the role assignment before it can create the resource.
13. What storage role allows reading blob data?
14. How would Lab 6 prove the managed identity can actually read a secret at runtime?

