#!/usr/bin/env bash
# Fail if a release version is hard-coded out of sync with VERSION.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"

check() {
  local file=$1
  local pattern=$2
  if ! grep -Fq -- "$pattern" "$ROOT/$file"; then
    printf 'version drift: %s does not contain %q\n' "$file" "$pattern" >&2
    exit 1
  fi
}

check app/config.py "default=\"$VERSION\""
check Dockerfile "ARG APP_VERSION=$VERSION"
check docker-compose.yml "APP_VERSION:-$VERSION"
check pyproject.toml "version = \"$VERSION\""
check charts/devops-task/Chart.yaml "version: $VERSION"
check charts/devops-task/Chart.yaml "appVersion: \"$VERSION\""
check charts/devops-task/values.yaml "tag: v$VERSION"
check charts/devops-task/values.yaml "APP_VERSION: \"$VERSION\""
check k8s/configmap.yaml "APP_VERSION: \"$VERSION\""
check k8s/deployment.yaml "devops-task:v$VERSION"
check terraform/envs/staging/staging.tfvars "devops-task:v$VERSION"
check terraform/envs/production/production.tfvars "devops-task:v$VERSION"
check terraform/modules/app-runtime/variables.tf "default     = \"$VERSION\""
check Makefile "\$\${APP_VERSION:-$VERSION}"
check .env.example "APP_VERSION=$VERSION"

printf 'version %s is consistent\n' "$VERSION"
