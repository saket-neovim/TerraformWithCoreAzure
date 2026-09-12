Values known before apply -
name of the azure resource group
location of the azure resource group
tags

name of the storage account
name of the storage container
name of the log analytics workspace

basically things that are already precomputed will be known

Values known after apply -
resource group id
storage id
blob endpoint
log analytics workspace id

Interview Questions

1. What is the difference between `terraform validate`, `terraform plan`, and `terraform apply`?
2. Why are storage account names harder than resource group names?
3. What kinds of Terraform values are unknown until apply?
4. What does `terraform plan -refresh-only` do?
5. Why should Terraform-owned tags not be edited manually in the portal?
6. What information is stored in Terraform state?
7. Why can Terraform state contain sensitive data?
8. What would you monitor for a storage account in production?

Terraform validate will just validate the syntax or check the syntax. Terraform plan will compare the config against the refreshed state of the resources on Azure and see what changes are to be done, but it will not actually make the changes. Apply will actually make the changes. 

The Terraform variables that are not known until apply are mostly IDs of the resources. After creation, they'll be known. 
 
Terraform plan refresh only just refreshes the resources on the console to the latest values in the state, but it It doesn't apply it. If you do `terraform apply refresh-only`, it refreshes and applies the values of the console to the state. 

Storage account names are harder than resource group names because storage account names should be globally unique. 

Terraform-owned tags should not be manually edited in the portal because if they are manually edited in the portal, then there'll be a drift. 

The information that's stored in the Terraform state is basically the resources that Terraform state knows about. Or is managing 
 
Terraform state should not contain sensitive data because it's not encrypted, and hence anyone can read it. 

In a storage account in production, you'd monitor:
- the size
- how fast it's ingesting data
- how fast the storage containers are growing Also, you'd monitor the security to make sure that it's not publicly accessible and That blob-level access is not set to containers. Some other attributes that you can specify are:
- the type of redundancy (locally redundant or zonal redundant storage)
- the speed or the storage type