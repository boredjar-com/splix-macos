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
# cupstestppd checks that the filter and icon referenced by the PPD exist; stage them under a
# fake root so the check is meaningful before anything is installed (and on CI).
ROOT="$TOP/build/testroot"; rm -rf "$ROOT"; mkdir -p "$ROOT/Library/Printers/SpliX"
cp "$TOP/build/rastertoqpdl" "$TOP/assets/SpliX.icns" "$ROOT/Library/Printers/SpliX/"
fail=0
for p in "$TOP"/build/ppds/*.ppd.gz; do
  if ! cupstestppd -R "$ROOT" -W all -q "$p" >/dev/null 2>&1; then
    echo "FAIL: $p"; cupstestppd -R "$ROOT" -W all "$p" | grep -E 'FAIL|\*\*' | head -3; fail=1
  fi
done
[ $fail -eq 0 ] && echo "all PPDs pass cupstestppd"
echo "done: $TOP/build"
