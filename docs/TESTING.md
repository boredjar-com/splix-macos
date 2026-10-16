# Verification log

What was actually exercised on macOS 27.0.1 (26A434), Apple Silicon, CUPS 2.3.4, with a
Samsung ML-2160 (QPDL v3). Add your own runs via the "Printer report" issue template.

| Scenario | How | Result |
|----------|-----|--------|
| Vendor driver on macOS 27 (baseline) | queue with Samsung PPD, `lp test.pdf` | `Filter failed`, `com.apple.badarch-error` |
| Offline pipeline, all 82 PPDs | `./tests/smoke.sh` (PDF → `cgpdftoraster` → `rastertoqpdl`) | 82 / 82 pass, valid PJL/QPDL framing |
| PPD validity | `cupstestppd -W all` on every generated PPD | all pass |
| AirPort Express, raw port 9100 | `socket://AirPort-Express.local:9100` | page printed, job `completed`, 1 sheet, 14 s |
| USB direct | `usb://Samsung/ML-2160%20Series?serial=…` | page printed, job `completed`, 8 s |
| AirPort Express, Apple protocol | `dnssd://…_riousbprint._tcp.local./` (resolves to `riousbprint://AirPort-Express.local.:10000/…`) | page printed, job `completed`, 1 sheet, 10 s |
| Script install | `sudo ./macos/install.sh --add-printer …` | filter + 82 PPDs installed, queue created |
| Package install / upgrade | `installer -pkg build/SpliX-macOS-2.0.1.pkg -target /` | success, `cups-driverd` lists all 82 `(SpliX)` models |
| Uninstall | `sudo ./macos/uninstall.sh` | filter, PPDs and SpliX queues removed |
| Installer auto-setup, clean machine | no queues, printer on AirPort, `installer -pkg …macos2.pkg` | queue `Samsung_ML-2160` created with `SpliX-ml2160.ppd.gz`, A4 (es_ES locale), set as default; test page printed |
| Installer repairs vendor queue | queue created with the Samsung PPD, then install | queue switched to the SpliX PPD, logged in `/Library/Printers/SpliX/autosetup.log` |
| "Select Software…" visibility | `lpinfo -m \| grep '(SpliX)'` | 82 entries **only with the flat layout**; a `Resources/SpliX/` subfolder is ignored by Apple's `cups-driverd` |
| Add Printer auto-match | plug USB printer with Samsung driver still installed | macOS auto-picks the **vendor** PPD (broken). Choose the `(SpliX)` one manually, or uninstall the Samsung driver |
| Supply levels, AirPort and USB | raw PJL + CUPS command filter probe | not available on this engine, see `SUPPLY-LEVELS.md` |

Caveats worth knowing:

* The AirPort Express accepts a single TCP connection to port 9100 (`qtotal=1`) and resets
  back-to-back connections. CUPS copes (`printer-error-policy=retry-job`), hand-written
  tools must pace themselves (≥ 12 s between connections).
* Debug logging (`cupsctl --debug-logging`) is the only way to see the filter's `DEBUG:`
  lines in `/var/log/cups/error_log`.
