#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# One-shot build: filter + PPDs + validation. Output lands in build/.
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
make -C "$TOP/macos" "$@"
"$TOP/macos/gen-ppds.sh"
echo "--- binary"
file "$TOP/build/rastertoqpdl"
echo "--- PPD validation (cupstestppd, warnings allowed)"
fail=0
for p in "$TOP"/build/ppds/*.ppd.gz; do
  if ! cupstestppd -W all -q "$p" >/dev/null 2>&1; then
    echo "FAIL: $p"; cupstestppd -W all "$p" | grep -E 'FAIL|\*\*' | head -3; fail=1
  fi
done
[ $fail -eq 0 ] && echo "all PPDs pass cupstestppd"
echo "done: $TOP/build"
