#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Builds an installer package (unsigned) from build/: build/SpliX-macOS-<ver>.pkg
# Users open it with right-click > Open (Gatekeeper) or: sudo installer -pkg X.pkg -target /
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-2.0.1}"
STAGE="$TOP/build/pkgroot"; SCRIPTS="$TOP/build/pkgscripts"
rm -rf "$STAGE" "$SCRIPTS"
mkdir -p "$STAGE/Library/Printers/SpliX" "$STAGE/Library/Printers/PPDs/Contents/Resources/SpliX" "$SCRIPTS"
install -m 755 "$TOP/build/rastertoqpdl" "$STAGE/Library/Printers/SpliX/"
install -m 644 "$TOP/build/ppds/"*.ppd.gz "$STAGE/Library/Printers/PPDs/Contents/Resources/SpliX/"
cat > "$SCRIPTS/postinstall" <<'POST'
#!/bin/bash
chown -R root:wheel /Library/Printers/SpliX /Library/Printers/PPDs/Contents/Resources/SpliX
chmod 755 /Library/Printers/SpliX/rastertoqpdl
launchctl kickstart -k system/org.cups.cupsd || true
exit 0
POST
chmod 755 "$SCRIPTS/postinstall"
pkgbuild --root "$STAGE" --scripts "$SCRIPTS" --identifier org.splix.macos --version "$VER" \
  --install-location / --ownership recommended "$TOP/build/SpliX-macOS-$VER.pkg"
echo "built $TOP/build/SpliX-macOS-$VER.pkg"
