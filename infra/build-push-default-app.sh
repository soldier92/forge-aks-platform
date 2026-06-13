#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
IMAGE_NAME="${IMAGE_NAME:-default-app}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
COREAKS_DIR="$(cd "$(dirname "$0")/terraform/live/${ENVIRONMENT}/coreaks" && pwd)"

ACR_NAME="${ACR_NAME:-$(cd "${COREAKS_DIR}" && terragrunt output -raw acr_name)}"
ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER:-$(cd "${COREAKS_DIR}" && terragrunt output -raw acr_login_server)}"
FULL_IMAGE="${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

pushd "$(dirname "$0")/../default-app" >/dev/null

az acr login --name "${ACR_NAME}"
docker build -t "${FULL_IMAGE}" .
docker push "${FULL_IMAGE}"

popd >/dev/null

echo "Pushed image: ${FULL_IMAGE}"
