#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
COMPONENT="${COMPONENT:-all}"

cd "$(dirname "$0")/terraform/live/${ENVIRONMENT}"

if [[ "${COMPONENT}" == "all" ]]; then
  terragrunt run-all destroy --terragrunt-non-interactive --auto-approve
else
  cd "${COMPONENT}"
  terragrunt destroy --auto-approve
fi
