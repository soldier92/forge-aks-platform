#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
COMPONENT="${COMPONENT:-coreaks}"

cd "$(dirname "$0")/terraform/live/${ENVIRONMENT}"
cd "${COMPONENT}"
terragrunt destroy --auto-approve
