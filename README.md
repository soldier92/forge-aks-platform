# AI-Assisted Azure AKS Platform Control Plane

This repository is a prototype internal developer platform that separates the control plane from the workload plane. A FastAPI portal runs outside AKS and accepts environment requests from developers. Platform admins review those requests, see deterministic AI-style recommendations, and approve or reject provisioning. Approved requests render Kubernetes manifests and deploy a starter FastAPI workload into AKS.

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
- `Jinja2` templates render Kubernetes YAML for approved requests.
- `kubectl` applies the rendered manifests to AKS.

## Azure Resources

- Resource group
- Azure Kubernetes Service cluster
- Azure Container Registry
- Existing virtual network integration for the portal subnet
- Existing virtual network integration for the AKS subnet
- Linux App Service plan
- Linux Web App for the portal

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
4. Approved requests trigger manifest rendering and deployment to AKS.
5. The default FastAPI app serves traffic inside the namespace through a ClusterIP service.

## Approval Flow

1. Request starts in `PENDING_APPROVAL`.
2. Admin can move it to `NEEDS_CHANGES`, `REJECTED`, or `APPROVED`.
3. Approved requests enter `PROVISIONING`.
4. A successful deployment ends in `DEPLOYED`.
5. A failed `kubectl` operation ends in `FAILED`.

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
- Portal subnet: `subnet-2-portal`
- AKS subnet: `subnet-3-aks`
- Remote state storage account: `defaultstac0231`
- Remote state container: `default`
- Deployment service principal client id: `3ebdf63b-b0bf-4c9e-b120-7d565a94239a`

Required CI secrets and variables:

- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `TFSTATE_RESOURCE_GROUP`

Runner prerequisites:

- Azure CLI
- Terraform
- Terragrunt
- Docker
- zip

## Azure Deployment Instructions

```bash
cd infra
./create-azure.sh
./build-push-default-app.sh
./deploy-portal.sh
```

By default these scripts target the `dev` Terragrunt environment. You can override the target with `ENVIRONMENT=<name>`.

Examples:

```bash
cd infra
ENVIRONMENT=dev COMPONENT=platform ACTION=plan ./create-azure.sh
ENVIRONMENT=dev COMPONENT=platform ACTION=apply ./create-azure.sh
ENVIRONMENT=dev COMPONENT=portal ACTION=apply ./create-azure.sh
ENVIRONMENT=dev ./build-push-default-app.sh
ENVIRONMENT=dev ./deploy-portal.sh
```

The GitHub Actions workflows under `.github/workflows/` are designed for a self-hosted runner and should become the primary deployment path.

## Cleanup Instructions

```bash
cd infra
ENVIRONMENT=dev ./destroy-azure.sh
```

## CV Bullet Points

- Built a prototype internal developer platform for Azure AKS with a control plane running outside the cluster.
- Implemented an approval workflow that combines platform governance and AI-assisted request review.
- Automated namespace provisioning and secure baseline Kubernetes resources with Jinja2 and `kubectl`.
- Created Azure deployment helpers for AKS, ACR, and App Service.
