#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Removes the SpliX filter, its PPDs and any print queue that uses them.
#     sudo ./macos/uninstall.sh
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
# Locale-independent: find queues by their installed PPD, not by parsing lpstat text.
for ppd in /etc/cups/ppd/*.ppd; do
  [ -f "$ppd" ] || continue
  if grep -qs 'Printers/SpliX/rastertoqpdl' "$ppd"; then
    q="$(basename "$ppd" .ppd)"
    lpadmin -x "$q" && echo "removed queue $q"
  fi
done
rm -rf /Library/Printers/SpliX /Library/Printers/PPDs/Contents/Resources/SpliX \
       /Library/Printers/PPDs/Contents/Resources/SpliX-*.ppd.gz
launchctl kickstart -k system/org.cups.cupsd
echo "SpliX for macOS uninstalled"
