#!/usr/bin/env bash
# Fails when the total line coverage in the luacov report is below the minimum.
# Usage: tools/check_coverage.sh <minimum-percent>
set -euo pipefail

minimum="${1:?usage: tools/check_coverage.sh <minimum-percent>}"
report="luacov.report.out"

[[ -f "$report" ]] || {
  echo "coverage: $report not found, run busted --coverage and luacov first" >&2
  exit 1
}

total="$(awk '/^Total/ { sub("%", "", $NF); print $NF }' "$report")"
[[ -n "$total" ]] || {
  echo "coverage: no Total line in $report" >&2
  exit 1
}

echo "coverage: ${total}% (minimum ${minimum}%)"
awk -v total="$total" -v minimum="$minimum" 'BEGIN { exit !(total + 0 >= minimum + 0) }' || {
  echo "coverage: below the minimum" >&2
  exit 1
}
