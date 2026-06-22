# AI-Assisted Azure AKS Platform Control Plane

This repository is a prototype internal developer platform that separates the control plane from the workload plane. A FastAPI portal runs outside AKS and accepts environment requests from developers. Platform admins review those requests, see deterministic AI-style recommendations, and approve or reject provisioning. Approved requests dispatch a GitHub Actions workflow that applies the requested AKS environment through Terraform.

## Project Purpose

The goal is to demonstrate a lightweight enterprise-style platform engineering workflow:

- Developers request team-specific AKS environments through a portal.
- Supervisors or platform admins review governance, cost, and risk before approval.
- The control plane provisions namespaces and baseline guardrails instead of giving every team full cluster access.
- A default workload is deployed so the namespace is immediately useful.

## Target Architecture

- `portal/` runs outside AKS and is designed for Azure App Service.
- `AKS` hosts only team workloads and their namespace-scoped resources.
- `SQLite` is used locally for a beginner-friendly demo data store.
- GitHub Actions dispatches approved requests to the `requestedenvironment-infra` workflow.
- Terraform manages requested AKS team environments with isolated state per deployment type, team, and environment.

## Azure Resources

- Resource group
- Azure Kubernetes Service cluster
- Azure Container Registry
- Terraform-created management portal subnet inside the existing shared VNet
- Terraform-created AKS subnet inside the existing shared VNet
- Linux App Service plan
- Linux Web App for the management portal, configured to run a container image

## AKS Resources

- Namespace
- ResourceQuota
- LimitRange
- ServiceAccount
- Role
- RoleBinding
- ConfigMap
- Deployment
- Service
- NetworkPolicy

## Traffic Flow

1. Developer submits a request in the portal.
2. The portal stores the request and shows an AI recommendation.
3. An admin reviews the request in the control plane.
4. Approved requests trigger the `requestedenvironment-infra` GitHub Actions workflow.
5. The default FastAPI app serves traffic inside the namespace through a ClusterIP service.

## Approval Flow

1. Request starts in `PENDING_APPROVAL`.
2. Admin can move it to `NEEDS_CHANGES`, `REJECTED`, or `APPROVED`.
3. Approved requests enter `PROVISIONING`.
4. A successful dispatch leaves the request in `PROVISIONING` while GitHub Actions applies Terraform.
5. A failed workflow dispatch ends in `FAILED`.

## Data Storage

The portal stores requests in a local SQLite database (`portal/controlplane.db`) for simplicity. In production, this should move to a managed relational database with backups and auditing.

## Permissions Model

- Demo mode uses `?role=developer` and `?role=admin`.
- Production mode should use Azure Entra ID with group-based authorization.
- The provisioning identity should use least-privilege Azure and Kubernetes RBAC.

## Cost-Control Strategy

- Use small, single-node AKS clusters for demos.
- Keep App Service and ACR on low-cost tiers.
- Use `DRY_RUN=true` during local testing.
- Destroy the resource group when you are finished.

## Local Run Instructions

### Portal

```bash
cd portal
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export DRY_RUN=true
uvicorn app.main:app --reload
```

Open:

- `http://127.0.0.1:8000/?role=developer`
- `http://127.0.0.1:8000/admin?role=admin`

### Default App

```bash
cd default-app
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8010
```

## Infrastructure Deployment

Infrastructure is managed with Terraform modules and Terragrunt environment configuration under `infra/terraform/`.

Current implementation details:

- Existing VNet resource group: `rg-01`
- Existing VNet: `vnet01`
- Management portal subnet created by Terraform: `subnet-2-portal` (`172.16.0.64/27`)
- AKS subnet created by Terraform: `subnet-3-aks` (`172.16.0.192/26`)
- Remote state storage account: `defaultstac0231`
- Remote state container: `default`
- Deployment service principal client id: `3ebdf63b-b0bf-4c9e-b120-7d565a94239a`

Required GitHub repository variables:

- `ARM_CLIENT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT` if you want to override `defaultstac0231`
- `TFSTATE_CONTAINER` if you want to override `default`

Required GitHub repository secret:

- `ARM_CLIENT_SECRET`
- `AKS_TEAM_TOKEN` fine-grained PAT or equivalent token that can dispatch the `requestedenvironment-infra.yml` workflow

Runner prerequisites:

- Azure CLI
- Terraform
- Terragrunt
- Docker

## Azure Deployment Instructions

```bash
cd infra
./create-azure.sh
./build-push-default-app.sh
```

By default these scripts target the `dev` Terragrunt environment. You can override the target with `ENVIRONMENT=<name>`.

Examples:

```bash
cd infra
ENVIRONMENT=dev COMPONENT=coreaks ACTION=plan ./create-azure.sh
ENVIRONMENT=dev COMPONENT=coreaks ACTION=apply ./create-azure.sh
ENVIRONMENT=dev ./build-push-default-app.sh
TEAM_NAME=team4 REQUESTED_ENVIRONMENT=dev REQUESTED_CPU=500m REQUESTED_MEMORY=512Mi REQUESTED_IMAGE=myacr.azurecr.io/default-app:latest APP_VERSION=v1 ACTION=apply ./apply-requested-environment.sh
```

The GitHub Actions workflows under `.github/workflows/` are designed for a self-hosted runner and are intentionally split by responsibility:

- `core-aks-infra.yml` for only shared `coreaks` Azure infrastructure
- `management-portal-app.yml` for only `managementportal` infrastructure
- `management-portal-site.yml` for building and deploying the management portal container image
- `requestedenvironment-infra.yml` for only approved team environments inside AKS

The `requestedenvironment` path is intentionally AKS-only for now. It does not create extra Azure network resources per team request. Each team/environment deployment gets its own Terraform state key so you can rerun one team safely to recreate manually deleted namespace-scoped resources.

Requested environment flow:

1. A developer submits a team environment request in the management portal.
2. An admin approves the request.
3. The portal dispatches `requestedenvironment-infra.yml` with `team_name`, `requested_environment`, CPU, memory, image, `deployment_type`, and `action=apply`.
4. The workflow maps `deployment_type=aks-namespace-app` to the current requested-environment Terraform module.
5. Terragrunt stores state under `requestedenvironment/<deployment_type>/<team>/<environment>.terraform.tfstate`, so rerunning team 4 only reconciles team 4 resources.
6. Future AKS deployment shapes can reuse the same pipeline by adding another `deployment_type` mapping to the workflow and a corresponding Terraform module.

## Cleanup Instructions

```bash
cd infra
ENVIRONMENT=dev ./destroy-azure.sh
```

## CV Bullet Points

- Built a prototype internal developer platform for Azure AKS with a control plane running outside the cluster.
- Implemented an approval workflow that combines platform governance, AI-assisted request review, and GitHub Actions dispatch.
- Automated namespace provisioning and secure baseline Kubernetes resources with Terraform.
- Created Azure deployment helpers for AKS, ACR, and App Service.
