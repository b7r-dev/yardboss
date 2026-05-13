#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "$PROJECT_DIR"

echo "=== Linting yardboss ==="

# Check bash syntax
echo "Running bash -n yardboss..."
bash -n yardboss
echo "OK"

echo "Running bash -n test/smoke.sh..."
bash -n test/smoke.sh
echo "OK"

# Run shellcheck if available
if command -v shellcheck >/dev/null 2>&1; then
  echo "Running shellcheck yardboss..."
  shellcheck yardboss
  echo "OK"

  echo "Running shellcheck test/smoke.sh..."
  shellcheck test/smoke.sh
  echo "OK"
else
  echo "WARNING: shellcheck not found. Install it for additional checks."
fi

echo ""
echo "=== All lints passed ==="
