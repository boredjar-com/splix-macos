#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Finds connected Samsung SPL printers (USB, AirPort/Bonjour, raw IP already known to CUPS)
# and creates a print queue for each one with the matching SpliX PPD. Repairs queues that
# still point at the Intel-only vendor driver. Safe to run again at any time:
#     sudo /Library/Printers/SpliX/splix-autosetup.sh [--dry-run]
set -uo pipefail
PPD_DIR=/Library/Printers/PPDs/Contents/Resources
LOG=/Library/Printers/SpliX/autosetup.log
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
say() { echo "$*"; [ $DRY -eq 1 ] || echo "$(date '+%F %T') $*" >> "$LOG" 2>/dev/null; }

# Console user's locale decides Letter vs A4 (the script runs as root from the installer).
user="$(stat -f %Su /dev/console 2>/dev/null || echo root)"
loc="$(sudo -u "$user" defaults read -g AppleLocale 2>/dev/null || echo en_US)"
case "$loc" in *_US|*_CA|*_MX|*_PH) pagesize=Letter;; *) pagesize=A4;; esac

# Map an IEEE 1284 MDL string ("ML-2160 Series") to an installed SpliX PPD via its 1284DeviceID.
ppd_for_model() {
  local mdl="$1" f
  for f in "$PPD_DIR"/SpliX-*.ppd.gz; do
    if gunzip -c "$f" | grep -q "^\*1284DeviceID:.*MDL:$mdl;"; then echo "$f"; return 0; fi
  done
  local short="${mdl% Series}"
  for f in "$PPD_DIR"/SpliX-*.ppd.gz; do
    if gunzip -c "$f" | grep -q "^\*ModelName:[[:space:]]*\"Samsung $short\""; then echo "$f"; return 0; fi
  done
  return 1
}

# Upgrade path: re-apply the freshly installed PPD to a queue that already uses SpliX, keeping
# the page size the user had (lpadmin -P resets PPD defaults).
refresh_queue() {
  local q="$1" ppd="$2" size
  size="$(sed -n 's/^\*DefaultPageSize:[[:space:]]*//p' "/etc/cups/ppd/$q.ppd" | head -1)"
  say "queue $q already uses SpliX; refreshing its PPD (PageSize=${size:-$pagesize})"
  [ $DRY -eq 1 ] || lpadmin -p "$q" -P "$ppd" -o "PageSize=${size:-$pagesize}"
}

found=0; added=0; repaired=0
# lpinfo output is localized; only the "key = value" lines are parsed.
while IFS= read -r line; do
  case "$line" in
    *"uri = "*) uri="${line#*uri = }";;
    *"device-id = "*)
      devid="${line#*device-id = }"
      mfg="$(echo "$devid" | sed -n 's/.*MFG:\([^;]*\);.*/\1/p')"
      mdl="$(echo "$devid" | sed -n 's/.*MDL:\([^;]*\);.*/\1/p')"
      [ "$mfg" = "Samsung" ] || continue
      found=$((found+1))
      ppd="$(ppd_for_model "$mdl")" || { say "no SpliX PPD for Samsung '$mdl' ($uri)"; continue; }
      name="Samsung_$(printf '%s' "${mdl% Series}" | tr -c 'A-Za-z0-9_.-' '_')"
      if [ -f "/etc/cups/ppd/$name.ppd" ]; then
        if grep -q 'Printers/SpliX/rastertoqpdl' "/etc/cups/ppd/$name.ppd"; then
          refresh_queue "$name" "$ppd"
        else
          say "queue $name uses the vendor driver; switching it to $(basename "$ppd")"
          [ $DRY -eq 1 ] || lpadmin -p "$name" -P "$ppd" -o PageSize=$pagesize && repaired=$((repaired+1))
        fi
        continue
      fi
      say "adding queue $name -> $uri with $(basename "$ppd") ($pagesize)"
      if [ $DRY -eq 0 ]; then
        lpadmin -p "$name" -E -v "$uri" -P "$ppd" -o PageSize=$pagesize \
                -o printer-is-shared=false -o printer-error-policy=retry-job && added=$((added+1))
        [ -z "$(LC_ALL=C lpstat -d 2>/dev/null | grep -v 'no system default')" ] && lpadmin -d "$name"
      fi
      ;;
  esac
done < <(LC_ALL=C lpinfo -l -v --timeout 8 2>/dev/null)

# Queues created earlier by macOS auto-setup with the vendor PPD (any name) get repaired too.
for p in /etc/cups/ppd/*.ppd; do
  [ -f "$p" ] || continue
  grep -q 'Printers/Samsung/UPD/Filters/rastertosec' "$p" || continue
  q="$(basename "$p" .ppd)"
  mdl="$(sed -n 's/^\*ModelName:[[:space:]]*"Samsung \(.*\)"/\1/p' "$p" | head -1)"
  ppd="$(ppd_for_model "$mdl")" || { say "queue $q: vendor driver, no SpliX PPD for '$mdl'"; continue; }
  say "queue $q uses the vendor driver; switching it to $(basename "$ppd")"
  [ $DRY -eq 1 ] || lpadmin -p "$q" -P "$ppd" -o PageSize=$pagesize && repaired=$((repaired+1))
done
say "done: $found Samsung printer(s) detected, $added queue(s) added, $repaired repaired"
exit 0
