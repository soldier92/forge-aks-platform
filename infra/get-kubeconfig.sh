#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
PLATFORM_DIR="$(cd "$(dirname "$0")/terraform/live/${ENVIRONMENT}/platform" && pwd)"

AKS_NAME="$(cd "${PLATFORM_DIR}" && terragrunt output -raw aks_name)"
RESOURCE_GROUP="$(cd "${PLATFORM_DIR}" && terragrunt output -raw resource_group_name)"

az aks get-credentials --resource-group "${RESOURCE_GROUP}" --name "${AKS_NAME}" --overwrite-existing
kubectl get nodes
