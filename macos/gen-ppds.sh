#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Generates macOS-ready PPDs from the vendored SpliX PPDs.
#   - every filter chain becomes: CUPS raster -> /Library/Printers/SpliX/rastertoqpdl
#     (macOS has no pstoraster/ghostscript; Apple's cgpdftoraster feeds the raster)
#   - NickName gets a " (SpliX)" suffix so it is distinguishable from vendor drivers
#   - *APPrinterIconPath points at the SpliX icon so Printers & Scanners shows it
#   - Samsung models get a *1284DeviceID and a "(Samsung X Series)" *Product so the
#     "Add Printer" dialog auto-selects them for Bonjour/USB printers
# Output: build/ppds/*.ppd.gz
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
SPLIX="$TOP/third_party/splix-2.0.1"
OUT="$TOP/build/ppds"
FILTER_PATH="${FILTER_PATH:-/Library/Printers/SpliX/rastertoqpdl}"
ICON_PATH="${ICON_PATH:-/Library/Printers/SpliX/SpliX.icns}"
rm -rf "$OUT"; mkdir -p "$OUT"

count=0
for src in "$SPLIX"/*.ppd "$SPLIX"/ppd/*.ppd; do
  base="$(basename "$src" .ppd)"
  case "$base" in *fr|*pt) continue;; esac   # translations: CUPS localizes the base PPD
  model="$(sed -n 's/^\*ModelName:[[:space:]]*"\(.*\)"/\1/p' "$src" | head -1)"
  dst="$OUT/$base.ppd"
  awk -v filter="$FILTER_PATH" -v icon="$ICON_PATH" -v model="$model" '
    /^\*cupsFilter:/ { if (!done) { print "*cupsFilter: \"application/vnd.cups-raster 0 " filter "\""; print "*APPrinterIconPath: \"" icon "\""; done=1 } ; next }
    /^\*NickName:/   { sub(/, 2\.0\.0"$/, "\""); sub(/"$/, " (SpliX)\""); print; next }
    /^\*Product:/    { print;
                       if (model ~ /^Samsung /) {
                         m = model; sub(/^Samsung /, "", m);
                         print "*Product: \"(Samsung " m " Series)\"";
                         print "*1284DeviceID: \"MFG:Samsung;CMD:SPL;MDL:" m " Series;CLS:PRINTER;\"";
                       }
                       next }
    { print }
  ' "$src" > "$dst"
  gzip -9 -n -f "$dst"
  count=$((count+1))
done
echo "generated $count PPDs in $OUT"
