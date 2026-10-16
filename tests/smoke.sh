#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Offline end-to-end test of the macOS print pipeline, no printer needed:
#   PDF --(Apple cgpdftoraster)--> CUPS raster --(build/rastertoqpdl)--> QPDL
# Runs against every generated PPD and checks the QPDL/PJL framing.
set -uo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
FILTER="$TOP/build/rastertoqpdl"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
[ -x "$FILTER" ] || { echo "build first: ./macos/build.sh"; exit 1; }

python3 "$TOP/tests/make-test-pdf.py" "$WORK/test.pdf"
pass=0; fail=0
for gz in "$TOP"/build/ppds/*.ppd.gz; do
  name="$(basename "$gz" .ppd.gz)"
  gunzip -c "$gz" > "$WORK/$name.ppd"
  export PPD="$WORK/$name.ppd"
  if ! /usr/libexec/cups/filter/cgpdftoraster 1 tester smoke 1 "PageSize=A4" "$WORK/test.pdf" > "$WORK/$name.ras" 2>"$WORK/$name.ras.log"; then
    echo "FAIL $name: cgpdftoraster"; fail=$((fail+1)); continue
  fi
  if ! "$FILTER" 1 tester smoke 1 "PageSize=A4" "$WORK/$name.ras" > "$WORK/$name.qpdl" 2>"$WORK/$name.log"; then
    echo "FAIL $name: rastertoqpdl exit $? :: $(grep -E 'ERROR|CRIT' "$WORK/$name.log" | head -1)"; fail=$((fail+1)); continue
  fi
  size=$(stat -f %z "$WORK/$name.qpdl")
  head -c 9 "$WORK/$name.qpdl" | grep -q $'\x1b%-12345X' && \
  grep -aq 'ENTER LANGUAGE *= *QPDL' "$WORK/$name.qpdl" && \
  tail -c 9 "$WORK/$name.qpdl" | grep -q $'\x1b%-12345X' && [ "$size" -gt 1000 ] \
    && { pass=$((pass+1)); } \
    || { echo "FAIL $name: bad QPDL framing (size=$size)"; fail=$((fail+1)); }
done
echo "smoke: $pass passed, $fail failed"
[ $fail -eq 0 ]
