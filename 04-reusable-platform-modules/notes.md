# Project 4 Notes

## Prediction

Before running `terraform plan`, predict:

- Which resources each module will create:
- Which values are known before apply:
- Which values are unknown until apply:
- Which resources depend on module outputs:

## Module Boundaries

Module boundaries:

Values owned by foundation:

Values owned by network:

Values kept in environment roots:

Diagnostics decision:

What would change before production:

## Troubleshooting Notes

Record at least two break/fix exercises:

- Scenario:
- Failure phase: init / validate / plan / apply
- Root cause:
- Fix:
- Lesson:

## Interview Answers

1. When should Terraform code become a module?
Terraform code should become a module when you're repeating a lot of instructions over different environments. 
2. What should a module output, and what should it hide?
A module output should be a value which you're going to be using back in the root module.
3. Why should outputs be keyed by stable names instead of list indexes?
Output should be keyed by stable names because if you remove a list index, then it'll recreate the other resources that belong to the list. stable names dont need to be sequential like list indexes 
4. Why should modules not reach into each other directly?
Because they are separate pieces of code Blocks 
5. How does `for_each` behave when a map key is renamed?
Just recreate that particular key, which has been renamed, but doesn't affect the other keys. 
6. What cost risks come with Log Analytics?Ingestion cost 

