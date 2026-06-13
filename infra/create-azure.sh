#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
COMPONENT="${COMPONENT:-coreaks}"
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

cd "${COMPONENT}"
run_terragrunt "${ACTION}"
