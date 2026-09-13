# Project 2 Notes

## Traffic Flow Prediction

Write the intended traffic flow before implementing resources.

Web subnet: The traffic flow for the web subnet can be reached only from the internet. 

App subnet: The traffic flow for the app subnet can be reached only from the web subnet. 

Data subnet: The traffic flow for the data subnet can be reached only from the app subnet. 

Denied or intentionally omitted traffic:

## Terraform Plan Prediction

Expected resources: The expected resources are:
- Azure resource group
- virtual network
- subnets
- nsgs
- route table
- nat gawteway
- public ip

Values known before apply: The values are unknown before apply, mostly precomputed values like tags or names.

Values unknown until apply: The values until apply are mostly IDs of resources. 

Expected dependency/order notes:The dependency order is 1. The resource group is created.
2. The VNet resource is created.
3. The subnet resource is created.The Azure public IP and the NAT gateway both depend on the resource group. Then there's a NAT gateway with public IP association. Then there's an Azure NAT gateway and subnet association. Which waits for the subnet and NAT gateway to be created The NSG waits for the resource group to be created. Then there is the Azure subnet with network security group association. And finally, this is the Azure route table which waits for the resource group to be created. After which there's a route table association which waits for both the route table to be created and then the subnet also to be created. 

## NAT Gateway Decision

Decision: I've implemented the NAT gateway. This is so that the VMs in the private subnet can access the internet. 

Reason:

Cost concern:There would be a cost attached to the public IP as well as the NAT gateway, if I remember correctly. 

## Troubleshooting Exercise

Chosen break/fix scenario:

What broke:

Where it failed:

Root cause:

Fix:

## Interview Questions

1. What is the difference between a VNet address space and subnet address prefixes?A VNet address space is for the whole network. Subnet address spaces are for individual subnetworks or smaller portions of the network, where you can utilize private or public subnets with different VMs and allow traffic flow from only the private to public subnets. 
2. Why are NSGs usually associated with subnets or NICs?Because the subnet is a smaller portion of a network, it needs to be attached to the subnet so it can allow or deny incoming traffic based on the NSG rules. 
3. What is the difference between inbound and outbound NSG rules?Inbound NSG rules are incoming from outside to the inside of the subnet, and outbound NSG rules are from inside the subnet to the public internet. 
4. Why is `for_each` safer than `count` for named subnets?For each is safer because it gives a stable key, whereas `count` just gives the index. 
5. What happens when a `for_each` key changes?When a key changes, the key which has been deleted, for instance, would be removed from that without impacting other keys. 
6. What is a route table used for?A route table is used for incoming or outgoing routes from one VNet to another VNet or from one VNet to the internet.
7. What does NAT Gateway solve?Nat gateway solves the issue of instances on a private subnet accessing the internet. For updates, for example 
8. How would you troubleshoot a VM that cannot reach the internet?You check for the security NSG outbound rule. 
9. How would you validate effective security rules in Azure?The security rules in Azure are validated in lower priority to higher priority, and the moment it finds a match, it accepts or denies the traffic.
10. What parts of this design would change for production?The parts of the design that would change for production would definitely include having a NAT gateway with a public IP so that instances can get updates on the internet. There would also maybe be a load balancer so instances can hit the web subnet. 

## Decision Note

Network segmentation decision:

Allowed traffic:

Denied or intentionally omitted traffic:

NAT Gateway decision:

Production changes:

