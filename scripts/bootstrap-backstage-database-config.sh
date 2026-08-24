#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${REPO_ROOT}/terraform/environments/dev"

echo "===== BACKSTAGE DATABASE CONFIG BOOTSTRAP ====="

RDS_ENDPOINT="$(
  terraform \
    -chdir="${TF_DIR}" \
    output \
    -raw \
    backstage_db_endpoint
)"

if [[ -z "${RDS_ENDPOINT}" ]]; then
  echo "ERROR: Terraform output backstage_db_endpoint is empty"
  exit 1
fi

echo "RDS endpoint discovered from Terraform."

kubectl create configmap backstage-postgres \
  -n backstage \
  --from-literal="POSTGRES_HOST=${RDS_ENDPOINT}" \
  --from-literal="POSTGRES_PORT=5432" \
  --from-literal="POSTGRES_DB=backstage" \
  --dry-run=client \
  -o yaml \
| kubectl apply -f -

echo
echo "===== LIVE CONFIGMAP ====="

kubectl get configmap backstage-postgres \
  -n backstage \
  -o json \
| jq '{
    name: .metadata.name,
    data: .data
  }'

echo
echo "PASS: Backstage database ConfigMap bootstrapped."
