#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
COREAKS_DIR="$(cd "$(dirname "$0")/terraform/live/${ENVIRONMENT}/coreaks" && pwd)"

AKS_NAME="$(cd "${COREAKS_DIR}" && terragrunt output -raw aks_name)"
RESOURCE_GROUP="$(cd "${COREAKS_DIR}" && terragrunt output -raw resource_group_name)"

az aks get-credentials --resource-group "${RESOURCE_GROUP}" --name "${AKS_NAME}" --overwrite-existing
kubectl get nodes
