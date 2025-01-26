# azure-databricks-private-network

## Description

This is a set of templates for deploying Azure Databricks using Terraform.

## Features

- Deploy Databricks workspace under your own virtual network

## How to use

First, rename `terraform.tfvars.sample` to `terraform.tfvars` and modify its contents as needed.

Next, deploy using the following example commands.

```sh
export ARM_SUBSCRIPTION_ID="your subscription id"
az login -t <your tenant id>
az account set -s $ARM_SUBSCRIPTION_ID
terraform plan
terraform apply
```

## ToDo

- Use serverless compute via private link
- Verify that the Databricks workspace is accessible only from a private network
