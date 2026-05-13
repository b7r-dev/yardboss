#!/usr/bin/env bash
#
# Smoke tests for yardboss
#
# Run: ./test/smoke.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
YARDBOSS="${PROJECT_DIR}/yardboss"

TMPDIR=""
cleanup() {
  if [[ -n "$TMPDIR" && -d "$TMPDIR" ]]; then
    # Kill any remaining yardboss-started processes
    if [[ -d "${TMPDIR}/.yardboss/pids" ]]; then
      for pidfile in "${TMPDIR}/.yardboss/pids/"*.pid; do
        [[ -f "$pidfile" ]] || continue
        local pid
        pid="$(cat "$pidfile" 2>/dev/null || true)"
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
          kill -TERM "$pid" 2>/dev/null || true
          sleep 1
          kill -KILL "$pid" 2>/dev/null || true
        fi
      done
    fi
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

echo "=== yardboss smoke tests ==="
echo ""

# Create temp workspace
TMPDIR="$(mktemp -d /tmp/yardboss-smoke.XXXXXX)"
echo "Using temp dir: ${TMPDIR}"

# Copy yardboss script
cp "$YARDBOSS" "${TMPDIR}/yardboss"
chmod +x "${TMPDIR}/yardboss"

cd "$TMPDIR"

# Write test config
cat > yardboss.conf <<'EOF'
PROJECT_NAME="smoke-test"

services=(sleeper quick)

sleeper_cmd="sleep 30"
sleeper_port=9999

quick_cmd="echo hello"
EOF

# ─── 1: help ──────────────────────────────────────────────────────────────────

echo "[TEST 1] help command"
output="$(./yardboss help 2>&1)"
if echo "$output" | grep -q "Usage: yardboss"; then
  echo "  PASS: help shows usage"
else
  echo "  FAIL: help output unexpected"
  exit 1
fi

# ─── 2: init generates config ──────────────────────────────────────────────────

echo "[TEST 2] init generates config when none exists"
rm -f yardboss.conf
# Create a fake Node project marker
echo '{"name":"smoke-test"}' > package.json
output="$(./yardboss init 2>&1)"
if echo "$output" | grep -q "Created yardboss.conf"; then
  echo "  PASS: init generated config"
else
  echo "  FAIL: init did not generate config"
  echo "$output"
  exit 1
fi
if grep -q 'Detected: Node.js / npm' yardboss.conf; then
  echo "  PASS: config detected Node.js project"
else
  echo "  FAIL: config did not detect Node.js"
  exit 1
fi
# Restore the test config
rm -f package.json
cat > yardboss.conf <<'EOF'
PROJECT_NAME="smoke-test"

services=(sleeper quick)

sleeper_cmd="sleep 30"
sleeper_port=9999

quick_cmd="echo hello"
EOF

# ─── 3: init refuses to overwrite existing config ──────────────────────────────

echo "[TEST 3] init refuses to overwrite existing config"
output="$(./yardboss init 2>&1 || true)"
if echo "$output" | grep -q "already exists"; then
  echo "  PASS: init refused to overwrite"
else
  echo "  FAIL: init did not refuse to overwrite"
  echo "$output"
  exit 1
fi

# ─── 4: doctor ────────────────────────────────────────────────────────────────

echo "[TEST 4] doctor command"
output="$(./yardboss doctor 2>&1)"
if echo "$output" | grep -q "doctor passed"; then
  echo "  PASS: doctor passed"
else
  echo "  FAIL: doctor did not pass"
  echo "$output"
  exit 1
fi

# ─── 5: status with nothing running ────────────────────────────────────────────

echo "[TEST 5] status with no running services"
output="$(./yardboss status 2>&1)"
if echo "$output" | grep -q "sleeper"; then
  echo "  PASS: status shows sleeper"
else
  echo "  FAIL: status missing sleeper"
  exit 1
fi

# ─── 6: start a service ────────────────────────────────────────────────────────

echo "[TEST 6] start a long-running service"
./yardboss start sleeper 2>&1
sleep 1

# Check PID file exists
if [[ -f ".yardboss/pids/sleeper.pid" ]]; then
  echo "  PASS: PID file created"
else
  echo "  FAIL: PID file not created"
  exit 1
fi

# ─── 7: status while running ───────────────────────────────────────────────────

echo "[TEST 7] status while service is running"
output="$(./yardboss status 2>&1)"
if echo "$output" | grep -q "running"; then
  echo "  PASS: status shows running"
else
  echo "  FAIL: status does not show running"
  echo "$output"
  exit 1
fi

# ─── 8: duplicate start ────────────────────────────────────────────────────────

echo "[TEST 8] duplicate start should not error"
output="$(./yardboss start sleeper 2>&1)"
if echo "$output" | grep -q "already running"; then
  echo "  PASS: duplicate start handled"
else
  echo "  FAIL: duplicate start not handled correctly"
  echo "$output"
  exit 1
fi

# ─── 9: stop a service ─────────────────────────────────────────────────────────

echo "[TEST 9] stop the service"
./yardboss stop sleeper 2>&1
sleep 1

# Check PID file removed
if [[ ! -f ".yardboss/pids/sleeper.pid" ]]; then
  echo "  PASS: PID file removed"
else
  echo "  FAIL: PID file still exists"
  exit 1
fi

# ─── 10: status after stop ─────────────────────────────────────────────────────

echo "[TEST 10] status after stop"
output="$(./yardboss status 2>&1)"
if echo "$output" | grep -q "stopped"; then
  echo "  PASS: status shows stopped"
else
  echo "  FAIL: status does not show stopped"
  echo "$output"
  exit 1
fi

# ─── 11: clean with no stale PIDs ──────────────────────────────────────────────

echo "[TEST 11] clean with no stale PIDs"
output="$(./yardboss clean 2>&1)"
if echo "$output" | grep -q "no stale PID"; then
  echo "  PASS: clean reports no stale PIDs"
else
  echo "  FAIL: clean output unexpected"
  echo "$output"
  exit 1
fi

# ─── 12: clean removes stale PID ───────────────────────────────────────────────

echo "[TEST 12] clean removes stale PID"
# Create a fake PID file with a nonexistent PID
echo "999999" > ".yardboss/pids/quick.pid"
output="$(./yardboss clean 2>&1)"
if echo "$output" | grep -q "removed stale"; then
  echo "  PASS: clean removed stale PID"
else
  echo "  FAIL: clean did not remove stale PID"
  echo "$output"
  exit 1
fi

# ─── 13: unknown service ───────────────────────────────────────────────────────

echo "[TEST 13] unknown service error"
output="$(./yardboss start nonexistent 2>&1 || true)"
if echo "$output" | grep -q "unknown service"; then
  echo "  PASS: unknown service error raised"
else
  echo "  FAIL: unknown service error not raised"
  echo "$output"
  exit 1
fi

# ─── 14: unknown command ───────────────────────────────────────────────────────

echo "[TEST 14] unknown command error"
output="$(./yardboss bogus 2>&1 || true)"
if echo "$output" | grep -q "unknown command"; then
  echo "  PASS: unknown command error raised"
else
  echo "  FAIL: unknown command error not raised"
  echo "$output"
  exit 1
fi

echo ""
echo "=== All smoke tests passed ==="
