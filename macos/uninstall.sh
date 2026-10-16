#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Removes SpliX for macOS completely: print queues that use it, the filter, the PPDs and the
# installer receipt. Works both from the repo and as the installed copy:
#     sudo /Library/Printers/SpliX/splix-uninstall.sh
set -uo pipefail
main() {
  [ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
  # Locale-independent: find queues by their installed PPD, not by parsing lpstat text.
  for ppd in /etc/cups/ppd/*.ppd; do
    [ -f "$ppd" ] || continue
    if grep -qs 'Printers/SpliX/rastertoqpdl' "$ppd"; then
      q="$(basename "$ppd" .ppd)"
      lpadmin -x "$q" && echo "removed print queue $q"
    fi
  done
  rm -rf /Library/Printers/SpliX /Library/Printers/PPDs/Contents/Resources/SpliX \
         /Library/Printers/PPDs/Contents/Resources/SpliX-*.ppd.gz
  pkgutil --forget com.boredjar.splix-macos >/dev/null 2>&1 || true
  launchctl kickstart -k system/org.cups.cupsd
  echo "SpliX for macOS uninstalled"
}
main "$@"
