#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Regenerates docs/SUPPORTED-PRINTERS.md from the generated PPDs (run ./macos/build.sh first).
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$TOP/docs/SUPPORTED-PRINTERS.md"
{
cat <<'HDR'
# Supported printers

Every printer below has a PPD in this package and prints through the same
`rastertoqpdl` filter. "Tested" means someone confirmed it on macOS 27 with this
build; please open an issue or PR to add yours. All of these are SPL / QPDL
(Samsung Printer Language) laser printers whose vendor drivers are Intel-only
and therefore dead on macOS 27 (no Rosetta).

| PPD (`Select Software…` name) | PPD file | QPDL | Colour | Tested on macOS 27 |
|---|---|---|---|---|
HDR
for gz in "$TOP"/build/ppds/*.ppd.gz; do
  f="$(basename "$gz" .ppd.gz)"
  nick="$(gunzip -c "$gz" | sed -n 's/^\*NickName:[[:space:]]*"\(.*\)"/\1/p' | head -1)"
  ver="$(gunzip -c "$gz" | sed -n 's/^\*QPDL QPDLVersion:[[:space:]]*"\(.*\)"/\1/p' | head -1)"
  col="$(gunzip -c "$gz" | sed -n 's/^\*ColorDevice:[[:space:]]*\(.*\)/\1/p' | head -1)"
  [ "$col" = "True" ] && col="yes" || col="no"
  tested=""; [ "$f" = "ml2160" ] && tested="yes (AirPort Express, socket://)"
  echo "| $nick | \`$f.ppd.gz\` | v$ver | $col | $tested |"
done
cat <<'FTR'

Rebadged models: Xerox Phaser 3117/3122/3124/3130/3140/3155/3160, Xerox WorkCentre
PE16/PE114e/3119, Dell 1100/1110, Toshiba e-STUDIO 180S, Lexmark X215 MFP
all share Samsung engines and are listed above under their own names.

Not supported (no SpliX PPD): Samsung printers that only speak the newer
"SPL-C / ULD" dialects (e.g. M2020/M2070 series, Xpress M20xx/M28xx, C4xx).
They need a different filter; contributions welcome.
FTR
} > "$OUT"
echo "wrote $OUT ($(grep -c '^| ' "$OUT") rows)"
