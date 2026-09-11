#!/bin/bash
# Runs the BATS suite inside a container with bash, jq, yq and bats.
# Usage: ./test/run-tests.sh [file.bats]
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-/work/test}"
docker run --rm --platform linux/amd64 -v "$REPO":/work -w /work alpine:3.20 sh -c "
  apk add --quiet bash jq yq bats >/dev/null 2>&1 || apk add --quiet bash jq yq bats
  exec bats $TARGET
"
