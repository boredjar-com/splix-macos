# Changelog

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
