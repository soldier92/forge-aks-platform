# Infrastructure Deployment

The infrastructure deployment approach uses Terraform modules plus Terragrunt environment configuration instead of one-shot Azure CLI creation scripts.

## Why This Approach

- It is easier to add new environments later.
- Shared Azure patterns stay in reusable modules.
- GitHub Actions can run plans and applies through a self-hosted agent.
- Remote state is stored centrally in Azure Storage.

## Current Environment Inputs

- Deployment identity display name: `serviceprincipal`
- Deployment identity client id: `3ebdf63b-b0bf-4c9e-b120-7d565a94239a`
- Subscription: `Katona.Balint`
- Subscription id: `39023a16-af6f-4b68-8498-e36556540d33`
- Remote state storage account: `defaultstac0231`
- Remote state container: `default`
- Existing VNet resource group: `rg-01`
- Existing VNet: `vnet01`
- Portal subnet: `subnet-2-portal` (`172.16.0.64/27`)
- AKS subnet: `subnet-3-aks` (`172.16.0.192/26`)

## Pipeline Model

- `terraform-infra.yml` handles infrastructure plan, apply, and destroy.
- `deploy-portal-app.yml` deploys the FastAPI portal code to the App Service created by Terraform.
- Both workflows are designed for a GitHub self-hosted runner with Azure CLI, Terraform, Terragrunt, Docker, and zip installed.

## Required GitHub Secrets and Variables

- Secret: `ARM_CLIENT_SECRET`
- Secret: `ARM_TENANT_ID`
- Variable: `TFSTATE_RESOURCE_GROUP`

## Recommended Expansion Path

When new environments are needed, copy `infra/terraform/live/dev` to another environment folder such as `test` or `prod`, then adjust names, tags, and sizing values there without changing the shared modules.
