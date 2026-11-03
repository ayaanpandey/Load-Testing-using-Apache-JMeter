#!/usr/bin/env bash
# Run the BlazeDemo load test in non-GUI mode and generate an HTML dashboard.
# Usage: ./scripts/run_test.sh [smoke|load|stress]
set -euo pipefail

PROFILE="${1:-smoke}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAN="$ROOT/test-plans/blazedemo_load_test.jmx"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$ROOT/results/${PROFILE}_${STAMP}"

case "$PROFILE" in
  smoke)  USERS=5;   RAMPUP=10;  DURATION=60  ;;   # sanity check the script
  load)   USERS=50;  RAMPUP=60;  DURATION=300 ;;   # expected normal/peak traffic
  stress) USERS=150; RAMPUP=120; DURATION=300 ;;   # push beyond expected load
  *) echo "Unknown profile '$PROFILE'. Use: smoke | load | stress"; exit 1 ;;
esac

# Optional override, e.g. USERS_OVERRIDE=100 ./scripts/run_test.sh load
USERS="${USERS_OVERRIDE:-$USERS}"

command -v jmeter >/dev/null 2>&1 || { echo "jmeter not found on PATH. See README for install steps."; exit 1; }

mkdir -p "$OUT"
echo ">> Profile: $PROFILE | users=$USERS ramp-up=${RAMPUP}s duration=${DURATION}s"
echo ">> Output : $OUT"

jmeter -n -t "$PLAN" \
  -Jusers="$USERS" -Jrampup="$RAMPUP" -Jduration="$DURATION" \
  -Jdata_dir="$ROOT/data" \
  -l "$OUT/results.jtl" \
  -j "$OUT/jmeter.log" \
  -e -o "$OUT/report"

echo ">> Done. Open $OUT/report/index.html"
python3 "$ROOT/scripts/summarize_results.py" "$OUT/results.jtl" --markdown "$OUT/summary.md" || true
