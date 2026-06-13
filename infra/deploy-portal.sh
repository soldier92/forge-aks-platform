#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
APP_DIR="$(cd "$(dirname "$0")/../portal" && pwd)"
INFRA_DIR="$(cd "$(dirname "$0")/terraform/live/${ENVIRONMENT}/portal" && pwd)"
PACKAGE_PATH="${PACKAGE_PATH:-/tmp/forge-portal.zip}"

WEBAPP_NAME="$(cd "${INFRA_DIR}" && terragrunt output -raw web_app_name)"
RESOURCE_GROUP="$(cd "${INFRA_DIR}" && terragrunt output -raw resource_group_name)"

rm -f "${PACKAGE_PATH}"
pushd "${APP_DIR}" >/dev/null
zip -r "${PACKAGE_PATH}" . -x "*.venv*" "__pycache__/*" "*.pyc"
popd >/dev/null

az webapp deploy \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${WEBAPP_NAME}" \
  --src-path "${PACKAGE_PATH}" \
  --type zip

echo "Portal package deployed to ${WEBAPP_NAME}."
