#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Builds the double-click installer: build/SpliX-macOS-<ver>.pkg
#   component pkg (files + postinstall) wrapped by productbuild with welcome / license /
#   conclusion panes. The postinstall runs splix-autosetup.sh so users never need Terminal.
# Sign + notarize afterwards with macos/sign-notarize.sh (needs a Developer ID Installer cert).
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-2.0.1}"          # file name, e.g. 2.0.1-macos2
PKGVER="${VER%%-*}"        # Installer wants a numeric version, e.g. 2.0.1
STAGE="$TOP/build/pkgroot"; SCRIPTS="$TOP/build/pkgscripts"; RES="$TOP/build/pkgres"
rm -rf "$STAGE" "$SCRIPTS" "$RES"
mkdir -p "$STAGE/Library/Printers/SpliX" "$STAGE/Library/Printers/PPDs/Contents/Resources" "$SCRIPTS" "$RES"
# cp -X: no extended attributes. (Under a process with com.apple.provenance tracking, i.e. apps
# launched from Finder, macOS re-adds that xattr and pkgbuild stores harmless ._ entries; a plain
# Terminal or CI build is clean.)
cp -X "$TOP/build/rastertoqpdl" "$STAGE/Library/Printers/SpliX/rastertoqpdl"
cp -X "$TOP/macos/splix-autosetup.sh" "$STAGE/Library/Printers/SpliX/splix-autosetup.sh"
chmod 755 "$STAGE/Library/Printers/SpliX/"*
# Flat layout: Apple's cups-driverd ignores subfolders, "Select Software…" would not list them.
for p in "$TOP/build/ppds/"*.ppd.gz; do cp -X "$p" "$STAGE/Library/Printers/PPDs/Contents/Resources/SpliX-$(basename "$p")"; done
chmod 644 "$STAGE/Library/Printers/PPDs/Contents/Resources/"SpliX-*.ppd.gz
cat > "$SCRIPTS/postinstall" <<'POST'
#!/bin/bash
chown -R root:wheel /Library/Printers/SpliX /Library/Printers/PPDs/Contents/Resources/SpliX-*.ppd.gz
chmod 755 /Library/Printers/SpliX/rastertoqpdl /Library/Printers/SpliX/splix-autosetup.sh
rm -rf /Library/Printers/PPDs/Contents/Resources/SpliX   # legacy subfolder layout
launchctl kickstart -k system/org.cups.cupsd || true
sleep 2
/Library/Printers/SpliX/splix-autosetup.sh || true
exit 0
POST
chmod 755 "$SCRIPTS/postinstall"
pkgbuild --root "$STAGE" --scripts "$SCRIPTS" --identifier com.boredjar.splix-macos --version "$PKGVER" \
  --install-location / --ownership recommended "$TOP/build/SpliX-component.pkg"
cp -X "$TOP/macos/pkg/welcome.html" "$TOP/macos/pkg/conclusion.html" "$TOP/macos/pkg/license.txt" "$RES/"
sed "s/__VERSION__/$PKGVER/" "$TOP/macos/pkg/distribution.xml" > "$TOP/build/distribution.xml"
productbuild --distribution "$TOP/build/distribution.xml" --resources "$RES" --package-path "$TOP/build" \
  "$TOP/build/SpliX-macOS-$VER.pkg"
rm -f "$TOP/build/SpliX-component.pkg"
echo "built $TOP/build/SpliX-macOS-$VER.pkg (unsigned; run macos/sign-notarize.sh to sign + notarize)"
