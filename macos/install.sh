#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Installs the SpliX filter + PPDs system-wide. Needs root:
#     sudo ./macos/install.sh [--add-printer NAME URI MODEL] [--no-restart]
# MODEL is the PPD base name (e.g. ml2160). Example for an AirPort-shared ML-2160:
#     sudo ./macos/install.sh --add-printer Samsung_ML-2160 socket://AirPort-Express.local:9100 ml2160
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
FILTER_DIR=/Library/Printers/SpliX
PPD_DIR=/Library/Printers/PPDs/Contents/Resources   # must be flat: Apple's cups-driverd does not scan subfolders
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
[ -x "$TOP/build/rastertoqpdl" ] || { echo "nothing built; run ./macos/build.sh first"; exit 1; }

install -d -o root -g wheel -m 755 "$FILTER_DIR"
rm -rf "$PPD_DIR/SpliX" "$PPD_DIR"/SpliX-*.ppd.gz   # drop any previous layout
# CUPS refuses filters that are not root-owned or are group/world writable.
install -o root -g wheel -m 755 "$TOP/build/rastertoqpdl" "$FILTER_DIR/rastertoqpdl"
install -o root -g wheel -m 755 "$TOP/macos/splix-autosetup.sh" "$FILTER_DIR/splix-autosetup.sh"
install -o root -g wheel -m 755 "$TOP/macos/uninstall.sh" "$FILTER_DIR/splix-uninstall.sh"
install -o root -g wheel -m 644 "$TOP/assets/SpliX.icns" "$FILTER_DIR/SpliX.icns"
for p in "$TOP/build/ppds/"*.ppd.gz; do install -o root -g wheel -m 644 "$p" "$PPD_DIR/SpliX-$(basename "$p")"; done
echo "installed $FILTER_DIR/rastertoqpdl and $(ls "$PPD_DIR"/SpliX-*.ppd.gz | wc -l | tr -d ' ') PPDs"

restart=1; add=()
while [ $# -gt 0 ]; do
  case "$1" in
    --no-restart) restart=0; shift;;
    --add-printer) add=("$2" "$3" "$4"); shift 4;;
    *) echo "unknown option $1"; exit 1;;
  esac
done
if [ $restart -eq 1 ]; then
  launchctl kickstart -k system/org.cups.cupsd && echo "cupsd restarted (PPD list refreshed)"
  sleep 1
fi
if [ ${#add[@]} -eq 3 ]; then
  name="${add[0]}"; uri="${add[1]}"; model="${add[2]}"
  ppd="$PPD_DIR/SpliX-$model.ppd.gz"
  [ -f "$ppd" ] || { echo "no PPD for model '$model' in $PPD_DIR"; exit 1; }
  lpadmin -p "$name" -E -v "$uri" -P "$ppd" -o printer-is-shared=false -o printer-error-policy=retry-job
  # A4 default outside US/CA/MX locales; Letter otherwise.
  loc="$(defaults read -g AppleLocale 2>/dev/null || echo en_US)"
  case "$loc" in *_US|*_CA|*_MX) ;; *) lpadmin -p "$name" -o PageSize=A4 -o media=iso_a4_210x297mm;; esac
  echo "queue '$name' added -> $uri using $(basename "$ppd")"
fi
