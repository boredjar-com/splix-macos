#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Builds an installer package (unsigned) from build/: build/SpliX-macOS-<ver>.pkg
# Users open it with right-click > Open (Gatekeeper) or: sudo installer -pkg X.pkg -target /
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-2.0.1}"          # file name, e.g. 2.0.1-macos1
PKGVER="${VER%%-*}"        # Installer wants a numeric version, e.g. 2.0.1
STAGE="$TOP/build/pkgroot"; SCRIPTS="$TOP/build/pkgscripts"
rm -rf "$STAGE" "$SCRIPTS"
mkdir -p "$STAGE/Library/Printers/SpliX" "$STAGE/Library/Printers/PPDs/Contents/Resources" "$SCRIPTS"
# cp -X: do not carry extended attributes. Note: when the build runs under a process with
# com.apple.provenance tracking (apps launched from Finder/LaunchServices) macOS re-adds that
# xattr to every new file and pkgbuild stores it as harmless AppleDouble ._ entries. Builds from
# a plain Terminal or CI produce a clean payload.
cp -X "$TOP/build/rastertoqpdl" "$STAGE/Library/Printers/SpliX/rastertoqpdl"; chmod 755 "$STAGE/Library/Printers/SpliX/rastertoqpdl"
# Flat layout: Apple's cups-driverd ignores subfolders, so "Select Software…" would not list them.
for p in "$TOP/build/ppds/"*.ppd.gz; do cp -X "$p" "$STAGE/Library/Printers/PPDs/Contents/Resources/SpliX-$(basename "$p")"; done
chmod 644 "$STAGE/Library/Printers/PPDs/Contents/Resources/"SpliX-*.ppd.gz
cat > "$SCRIPTS/postinstall" <<'POST'
#!/bin/bash
chown -R root:wheel /Library/Printers/SpliX /Library/Printers/PPDs/Contents/Resources/SpliX-*.ppd.gz
rm -rf /Library/Printers/PPDs/Contents/Resources/SpliX   # legacy subfolder layout
chmod 755 /Library/Printers/SpliX/rastertoqpdl
launchctl kickstart -k system/org.cups.cupsd || true
exit 0
POST
chmod 755 "$SCRIPTS/postinstall"
pkgbuild --root "$STAGE" --scripts "$SCRIPTS" --identifier com.boredjar.splix-macos --version "$PKGVER" \
  --install-location / --ownership recommended "$TOP/build/SpliX-macOS-$VER.pkg"
echo "built $TOP/build/SpliX-macOS-$VER.pkg"
