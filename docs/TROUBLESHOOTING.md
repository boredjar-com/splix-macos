# Troubleshooting

## Read the real error

```bash
cupsctl --debug-logging
lp -d <queue> somefile.pdf        # or print anything from any app
grep -a "Job $(lpstat -W completed -o | tail -1 | awk '{print $1}' | sed 's/.*-//')" /var/log/cups/error_log | grep -iE 'SpliX|rastertoqpdl|ERROR|CRIT|badarch|insecure'
cupsctl --no-debug-logging
```

## Symptoms and fixes

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Filter failed`, `com.apple.badarch-error` | Queue still uses the Samsung (Intel) PPD | Delete the queue, re-add it choosing a **(SpliX)** PPD |
| `File ... has insecure permissions` | Filter not root-owned or group/world writable | `sudo chown root:wheel /Library/Printers/SpliX/rastertoqpdl && sudo chmod 755 ...` |
| `Unable to locate printer` / `Connecting to printer…` forever | Hostname or port wrong | `lpinfo -v`; for AirPort use `socket://AirPort-Express.local:9100` or the `dnssd://...riousbprint...` URI |
| Printer busy for one job, next job stuck | AirPort allows a single connection (`qtotal=1`) | Wait; CUPS retries. `lpadmin -p Q -o printer-error-policy=retry-job` |
| Page cut on one side / shifted | Paper size mismatch | Set `PageSize` in the queue to match the tray: `lpadmin -p Q -o PageSize=A4` |
| Black page or garbage | Wrong QPDL version for the model | Try the sibling PPD (e.g. `ml2165` vs `ml2160`); report it |
| SpliX model missing in *Select Software…* | cupsd PPD cache stale | `sudo launchctl kickstart -k system/org.cups.cupsd` |
| Supply Levels: "Information not available" | Expected, see `docs/SUPPLY-LEVELS.md` | — |

## Offline test without a printer

```bash
./tests/smoke.sh
```

Runs PDF → `cgpdftoraster` → `rastertoqpdl` for every PPD and checks the PJL/QPDL framing.

## Manually run the filter on a file

```bash
export PPD=/tmp/ml2160.ppd; gunzip -c /Library/Printers/PPDs/Contents/Resources/SpliX/ml2160.ppd.gz > $PPD
/usr/libexec/cups/filter/cgpdftoraster 1 me test 1 "PageSize=A4" file.pdf > /tmp/job.ras
/Library/Printers/SpliX/rastertoqpdl 1 me test 1 "PageSize=A4" /tmp/job.ras > /tmp/job.qpdl
nc AirPort-Express.local 9100 < /tmp/job.qpdl        # sends the raw job to the printer
```
