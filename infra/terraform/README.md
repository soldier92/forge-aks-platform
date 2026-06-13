# Terraform and Terragrunt Layout

This directory replaces the earlier one-off Azure CLI provisioning scripts with a modular Terraform design orchestrated by Terragrunt.

## Structure

- `modules/managementportal`: App Service plan, Linux Web App, and VNet integration for the control plane.
- `modules/coreaks`: AKS and ACR for shared workload foundations.
- `modules/requestedenvironment`: Terraform-managed namespace-scoped AKS resources for approved team requests.
- `live/dev`: environment-specific Terragrunt configuration for `coreaks` and `managementportal`.
- `live/team-runner`: generic Terragrunt runner for request-driven team environments.

## Remote State

Remote state is configured for the existing storage account:

- Storage account: `defaultstac0231`
- Container: `default`
- Subscription: `Katona.Balint` (`39023a16-af6f-4b68-8498-e36556540d33`)

The storage account resource group is read from `TFSTATE_RESOURCE_GROUP` and defaults to `rg-01`. Adjust that if your state account lives elsewhere.

## Existing Network Dependencies

The solution intentionally reuses existing networking:

- Management portal subnet: `rg-01` / `vnet01` / `subnet-2-portal`
- Core AKS subnet: `rg-01` / `vnet01` / `subnet-3-aks`

## Tooling

- Terraform `>= 1.6`
- Terragrunt
- Azure CLI
- zip

Authenticate with the `serviceprincipal` identity before running Terragrunt locally or in CI. For the `requestedenvironment` stack, the runner also needs `kubectl` access to the shared AKS cluster because this stack intentionally manages only namespace-scoped resources inside AKS.
