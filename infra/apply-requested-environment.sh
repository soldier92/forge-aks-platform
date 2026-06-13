#!/usr/bin/env bash
set -euo pipefail

ACTION="${ACTION:-apply}"
RUNNER_DIR="$(cd "$(dirname "$0")/terraform/live/team-runner" && pwd)"

cd "${RUNNER_DIR}"

if [[ "${ACTION}" == "apply" || "${ACTION}" == "destroy" ]]; then
  terragrunt "${ACTION}" --terragrunt-non-interactive --auto-approve
else
  terragrunt "${ACTION}" --terragrunt-non-interactive
fi
