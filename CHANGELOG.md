# Changelog

## 2.0.1-macos4 — 2026-10-17

* Icon: printers added with a SpliX PPD show the SpliX icon in System Settings
  (`*APPrinterIconPath`), and the installer shows it too.
* Upgrading refreshes the PPD of queues that already use SpliX (keeps the page size).
* README rewritten around "Keep your printer. Upgrade your Mac."; PPD validation on CI now
  checks the referenced filter and icon against a staged root.

## 2.0.1-macos3 — 2026-10-17

* The package now installs `/Library/Printers/SpliX/splix-uninstall.sh`; the installer's last
  pane and the README document how to uninstall (script, Homebrew cask, or repo checkout).
* Homebrew cask: `brew install --cask boredjar-com/tap/splix-macos`.

## 2.0.1-macos2 — 2026-10-16

* Double-click installer for people who never open Terminal: welcome / license / conclusion
  panes, and a post-install step (`splix-autosetup.sh`) that detects Samsung printers over USB
  or Bonjour, creates the queue with the right SpliX PPD, picks Letter/A4 from the locale, sets
  the default printer, and repairs queues that still use the Intel-only Samsung driver.
* Release package signed with Developer ID (BORED JAR SL) and notarized by Apple: plain
  double-click install, no Gatekeeper warning. `macos/sign-notarize.sh` rebuilds the filter with
  hardened runtime + secure timestamp, signs the package and staples the notarization ticket.
* Package identifier `com.boredjar.splix-macos`; numeric Installer version derived from the tag.

## 2.0.1-macos1 — 2026-10-16

* First release. SpliX 2.0.1 `rastertoqpdl` built as a universal arm64 + x86_64 macOS binary,
  JBIG-KIT 2.1 linked statically.
* 82 PPDs rewritten for macOS: Apple `cgpdftoraster` → `rastertoqpdl`, absolute filter path,
  `(SpliX)` NickName, `*1284DeviceID` for Samsung models so Add Printer auto-matches.
* Installer scripts, `.pkg` builder, offline smoke test, CI workflow.
* PPDs installed flat as `Resources/SpliX-<model>.ppd.gz`: Apple's `cups-driverd` does not
  scan subfolders, so a subfolder layout is invisible to "Select Software…".
* Verified: Samsung ML-2160 over USB and via AirPort Express (socket://) on macOS 27.0.1
  (Apple Silicon); install, upgrade and uninstall cycles; see `docs/TESTING.md`.
* Documented: why Samsung's driver dies on macOS 27, why toner levels are unavailable.
