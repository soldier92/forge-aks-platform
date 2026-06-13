# Terraform and Terragrunt Layout

This directory replaces the earlier one-off Azure CLI provisioning scripts with a modular Terraform design orchestrated by Terragrunt.

## Structure

- `modules/portal`: App Service plan, Linux Web App, and VNet integration for the control plane.
- `modules/aks-platform`: AKS and ACR for team workloads.
- `live/dev`: environment-specific Terragrunt configuration.

## Remote State

Remote state is configured for the existing storage account:

- Storage account: `defaultstac0231`
- Container: `default`
- Subscription: `Katona.Balint` (`39023a16-af6f-4b68-8498-e36556540d33`)

The storage account resource group is read from `TFSTATE_RESOURCE_GROUP` and defaults to `rg-01`. Adjust that if your state account lives elsewhere.

## Existing Network Dependencies

The solution intentionally reuses existing networking:

- Portal subnet: `rg-01` / `vnet01` / `subnet-2-portal`
- AKS subnet: `rg-01` / `vnet01` / `subnet-3-aks`

## Tooling

- Terraform `>= 1.6`
- Terragrunt
- Azure CLI
- zip

Authenticate with the `serviceprincipal` identity before running Terragrunt locally or in CI.
