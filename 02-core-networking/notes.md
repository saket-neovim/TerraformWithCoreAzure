# Project 2 Notes

## Traffic Flow Prediction

Write the intended traffic flow before implementing resources.

Web subnet:

App subnet:

Data subnet:

Denied or intentionally omitted traffic:

## Terraform Plan Prediction

Expected resources:

Values known before apply:

Values unknown until apply:

Expected dependency/order notes:

## NAT Gateway Decision

Decision:

Reason:

Cost concern:

## Troubleshooting Exercise

Chosen break/fix scenario:

What broke:

Where it failed:

Root cause:

Fix:

## Interview Questions

1. What is the difference between a VNet address space and subnet address prefixes?
2. Why are NSGs usually associated with subnets or NICs?
3. What is the difference between inbound and outbound NSG rules?
4. Why is `for_each` safer than `count` for named subnets?
5. What happens when a `for_each` key changes?
6. What is a route table used for?
7. What does NAT Gateway solve?
8. How would you troubleshoot a VM that cannot reach the internet?
9. How would you validate effective security rules in Azure?
10. What parts of this design would change for production?

## Decision Note

Network segmentation decision:

Allowed traffic:

Denied or intentionally omitted traffic:

NAT Gateway decision:

Production changes:

