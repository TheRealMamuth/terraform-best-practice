# Terraform Best Practices

## Table of Contents
1. [Terraform init best practices](#terraform-init-best-practices)

## Introduction
This document is a collection of best practices for using Terraform. It is based on the experience of the author and the community. The goal is to provide a set of best practices that can be used to improve the quality of Terraform code and to help avoid common pitfalls. This repository assumes you have basic knowledge of terraform.

## Terraform init best practices

To start working with our Terraform code, you need to initialize it first using the `terraform init` command. However, when using the `terraform validate` or `terraform fmt` commands, there is no need to initialize the code along with the backend.

Wrong way:
```bash
terraform init -backend-config="bucket=mybucket" 
terraform validate
```

Correct way:
```bash
terraform init -backend=false
terraform validate
```

Example of correct github actions:
```yaml
name: Terraform Validate

on:
  push:
    branches:
      - 'feature/*'
  pull_request:
    branches:
      - main

jobs:
  terraform-validate:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Set up Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0

    - name: Initialize Terraform
      run: terraform init -backend=false

    - name: Validate Terraform code
      run: terraform validate

    - name: Terraform Format Check
      run: terraform fmt -check -recursive
```

If in our GitHub Action we are only performing code validation or setting canonical formatting, there is no need to initialize our backend. This will save us a few seconds and provide results faster.

## Terraform plan and apply best practices

When running `terraform plan` or `terraform apply`, it is important to use the `-out` flag to save the plan to a file. This is useful for reviewing the plan before applying it.

Wrong way:
```bash
terraform plan
terraform apply -auto-approve
```

Using the terraform plan command without the `-out` switch creates a so-called speculative plan. It only shows what the environment might look like, what the changes will be. This command is for safe planning and reviewing the configuration and changes you are planning. Later issuing the terraform apply command will apply all the changes that occur in your state and in the code. Remember that without the `-out` switch, someone with their changes can push you. And if you use the approach without `-out` in the pipeline, for example with the `-auto-approve` switch, someone else's changes can actually go to your account. They will be executed in your pipeline.

Correct way:
```bash
terraform plan -out=tfplan
terraform apply tfplan
```
A plan made with the `-out=tfplan` switch gives you 100% that after issuing the terraform apply tfplan command, only and exclusively those changes will be executed that you have reviewed, approved and want to be made in your configuration. 

<b>REMEMBER</b> - always use the generated plan in the pipeline and work only on it. 

<b>IMPORTANT</b> - such a plan can be used only once and has an identifier in it that does not allow it to be used if, for example, another plan was used, or some changes were made in your state.

### Example
The example is to illustrate the problem of using plan and apply without the -out switch.

```bash
# Execute these commands in this order - remaber to do some changes in terraform the code
terraform plan 
terraform taint <use_resorces_address_from_state>
terraform apply
# In our terraform apply we can see that we have more changes than we expected.

# Now the right way
terraform plan -out=tfplan
terraform taint <use_resorces_address_from_state>
terraform apply tfplan 
# Now we can see that we have only the changes that we expected.
``` 

## Terraform -input=false

When running `terraform plan` in a pipeline, it is important to use the `-input=false` flag to avoid the need for user input.

This is a good practice to avoid blocking the pipeline, which may hang. This is because the `terraform plan` command requires user input to provide all used variables declerated in variable block. By using the `-input=false` flag, we can avoid this problem. Then the terraform plan command will report an error if you forget to specify any variables.




