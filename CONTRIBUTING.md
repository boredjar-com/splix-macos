# Contributing

## Report a tested printer

Open an issue with the template "Printer report" (or a PR editing
`docs/SUPPORTED-PRINTERS.md`). Include macOS version, Mac chip, printer model, connection
type (USB / AirPort Express / Time Capsule / raw IP), the PPD you picked and whether the
page printed correctly (margins, density, blank pages).

## Report a bug

```bash
cupsctl --debug-logging
# reproduce once, then:
grep -a "Job $(lpstat -W completed -o | tail -1 | cut -d- -f2 | awk '{print $1}')" /var/log/cups/error_log > splix-debug.log
cupsctl --no-debug-logging
```

Attach `splix-debug.log` (scrub user names if you care), `sw_vers`, `uname -m` and
`lpoptions -p <queue>`.

## Code

* `third_party/` is vendored upstream code. Do **not** patch it in place; put macOS-specific
  changes in `macos/` (build flags, PPD rewriting) so upstream can be swapped later.
* Run `./macos/build.sh && ./tests/smoke.sh` before a PR. The CI workflow does the same on a
  GitHub macOS runner.
* Shell scripts: `bash -n` clean and `set -euo pipefail` where it makes sense.
* Commits: plain English, imperative mood.

## Release process (maintainers)

1. Update `CHANGELOG.md`, commit, `git tag -a vX.Y.Z-macosN && git push origin main vX.Y.Z-macosN`.
2. CI builds, tests and publishes a GitHub release with an **unsigned** package (no signing
   secrets live in CI).
3. On a Mac with the Bored Jar Developer ID certificates and the `splix-notary` notarytool
   profile: `./macos/sign-notarize.sh X.Y.Z-macosN`, then
   `gh release upload vX.Y.Z-macosN build/SpliX-macOS-X.Y.Z-macosN.pkg build/SHA256SUMS.txt --clobber`.
   Apple requires the filter signed with Developer ID Application + hardened runtime + timestamp
   and the package with Developer ID Installer; the script does all of it and staples the ticket.

## License

By contributing you agree your changes are licensed under GPL-2.0-only, like the rest of the
repository.
