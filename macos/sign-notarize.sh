#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Signs and notarizes an installer package so it opens with a plain double-click (no Gatekeeper
# warning). One-time setup:
#   1. Developer ID *Installer* certificate: Xcode → Settings → Accounts → Manage Certificates → +
#   2. xcrun notarytool store-credentials splix-notary --apple-id <id> --team-id <TEAM> --password <app-specific>
# Usage: ./macos/sign-notarize.sh build/SpliX-macOS-2.0.1-macos2.pkg
set -euo pipefail
IN="$1"; OUT="${IN%.pkg}-signed.pkg"
IDENTITY="${SPLIX_SIGN_IDENTITY:-Developer ID Installer}"      # substring match is fine
PROFILE="${SPLIX_NOTARY_PROFILE:-splix-notary}"
productsign --sign "$IDENTITY" "$IN" "$OUT"
xcrun notarytool submit "$OUT" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$OUT"
spctl -a -vv -t install "$OUT"
mv "$OUT" "$IN"
echo "signed, notarized and stapled: $IN"
