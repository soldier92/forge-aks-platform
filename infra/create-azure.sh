#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
COMPONENT="${COMPONENT:-all}"
ACTION="${ACTION:-apply}"

cd "$(dirname "$0")/terraform/live/${ENVIRONMENT}"

run_terragrunt() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" == "apply" || "${cmd}" == "destroy" ]]; then
    terragrunt "${cmd}" --auto-approve "$@"
  else
    terragrunt "${cmd}" "$@"
  fi
}

if [[ "${COMPONENT}" == "all" ]]; then
  if [[ "${ACTION}" == "apply" || "${ACTION}" == "destroy" ]]; then
    terragrunt run-all "${ACTION}" --terragrunt-non-interactive --auto-approve
  else
    terragrunt run-all "${ACTION}" --terragrunt-non-interactive
  fi
else
  cd "${COMPONENT}"
  run_terragrunt "${ACTION}"
fi
