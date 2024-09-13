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



