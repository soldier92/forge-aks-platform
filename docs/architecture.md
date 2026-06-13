# Architecture

The Forge control plane is intentionally separated from the AKS workload cluster. The portal is a FastAPI application designed to run on Azure App Service, while AKS is reserved for application namespaces created for individual teams.

## Core Components

- `portal/`: control plane UI and workflow logic.
- `default-app/`: starter FastAPI workload deployed into team namespaces.
- `k8s-templates/`: Jinja2-backed Kubernetes manifests rendered per approved request.
- `infra/terraform/`: Terraform modules and Terragrunt environment configuration for Azure infrastructure.
- `infra/`: helper scripts for Terragrunt-driven infrastructure actions and portal deployment.

## Production Direction

In production, Azure Entra ID would secure the portal, Azure Database for PostgreSQL would replace SQLite, background jobs would handle provisioning asynchronously, and audit logs would be exported to Azure Monitor or Log Analytics. Infrastructure changes would move through GitHub Actions on a self-hosted runner using Terraform remote state in Azure Storage.
