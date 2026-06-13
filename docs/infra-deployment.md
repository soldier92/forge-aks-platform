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
- Management portal subnet: `subnet-2-portal` (`172.16.0.64/27`)
- AKS subnet: `subnet-3-aks` (`172.16.0.192/26`)

## Pipeline Model

- `core-aks-infra.yml` manages only the shared `coreaks` Azure foundation.
- `management-portal-app.yml` manages only the `managementportal` App Service infra plus portal package deployment.
- `requestedenvironment-infra.yml` manages only namespace-scoped AKS resources for an approved team request.
- All workflows are designed for a GitHub self-hosted runner with Azure CLI, Terraform, Terragrunt, Docker, kubectl, and zip installed.

## Requested Environment Scope

The `requestedenvironment` layer currently implements Option A only:

- No additional Azure networking or Azure resource creation per team request
- Only Kubernetes resources inside the shared `coreaks` cluster
- One Terraform state per `team_name` and `requested_environment`

This keeps reruns simple. If a namespace-scoped resource is manually deleted, rerunning `requestedenvironment-infra.yml` for that same team and environment will reconcile it back through Terraform.

## Required GitHub Variables and Secrets

Repository variables:

- `ARM_CLIENT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT` if you want to override the default `defaultstac0231`
- `TFSTATE_CONTAINER` if you want to override the default `default`

Repository secret:

- `ARM_CLIENT_SECRET`

## Recommended Expansion Path

When new environments are needed, copy `infra/terraform/live/dev` to another environment folder such as `test` or `prod`, then adjust names, tags, and sizing values there without changing the shared modules.
