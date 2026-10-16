#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Produces a signed + notarized + stapled installer that opens with a plain double-click.
# Apple requires every executable inside the package to be signed with Developer ID
# Application (hardened runtime, secure timestamp) and the package itself with Developer ID
# Installer, so this rebuilds the filter with those flags, packages, signs and notarizes.
#
# One-time setup:
#   1. Certificates "Developer ID Application" and "Developer ID Installer" in the login keychain
#      (Xcode → Settings → Accounts → Manage Certificates → +).
#   2. xcrun notarytool store-credentials splix-notary   (Apple ID + app-specific password + Team ID)
# Usage: ./macos/sign-notarize.sh 2.0.1-macos2        -> build/SpliX-macOS-2.0.1-macos2.pkg
set -euo pipefail
TOP="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:?version, e.g. 2.0.1-macos2}"
APP_ID="${SPLIX_APP_IDENTITY:-Developer ID Application}"      # substring match works for codesign
INST_ID="${SPLIX_INSTALLER_IDENTITY:-$(security find-identity -v -p basic | sed -n 's/.*"\(Developer ID Installer: [^"]*\)".*/\1/p' | head -1)}"
PROFILE="${SPLIX_NOTARY_PROFILE:-splix-notary}"
[ -n "$INST_ID" ] || { echo "no Developer ID Installer certificate in keychain"; exit 1; }

echo "== building filter signed with: $APP_ID"
make -C "$TOP/macos" clean >/dev/null
make -C "$TOP/macos" SIGN_ID="$APP_ID" >/dev/null
codesign --verify --strict --verbose=2 "$TOP/build/rastertoqpdl"
"$TOP/macos/gen-ppds.sh" >/dev/null
"$TOP/macos/make-pkg.sh" "$VER" >/dev/null
UNSIGNED="$TOP/build/SpliX-macOS-$VER.pkg"; SIGNED="$TOP/build/SpliX-macOS-$VER-signed.pkg"
echo "== signing package with: $INST_ID"
productsign --sign "$INST_ID" "$UNSIGNED" "$SIGNED"
echo "== notarizing (profile $PROFILE)"
xcrun notarytool submit "$SIGNED" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$SIGNED"
spctl -a -vv -t install "$SIGNED"
mv "$SIGNED" "$UNSIGNED"
shasum -a 256 "$UNSIGNED" | tee "$TOP/build/SHA256SUMS.txt"
echo "signed, notarized and stapled: $UNSIGNED"
