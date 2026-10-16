#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Removes the SpliX filter, its PPDs and any print queue that uses them.
#     sudo ./macos/uninstall.sh
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
for q in $(lpstat -p 2>/dev/null | awk '{print $2}'); do
  if grep -qs 'Printers/SpliX/rastertoqpdl' "/etc/cups/ppd/$q.ppd"; then
    lpadmin -x "$q" && echo "removed queue $q"
  fi
done
rm -rf /Library/Printers/SpliX /Library/Printers/PPDs/Contents/Resources/SpliX
launchctl kickstart -k system/org.cups.cupsd
echo "SpliX for macOS uninstalled"
