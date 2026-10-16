# Supply levels (toner) — investigation

Goal: make System Settings → Printers → *Supply Levels* show toner for a Samsung ML-2160
shared by an AirPort Express. Result: **not possible through the AirPort**. Here is why,
so nobody has to redo this.

## How the vendor driver did it

`strings /Library/Printers/Samsung/UPD/Filters/commandtosec` reveals two mechanisms:

* **Network printers:** SNMP (embedded net-snmp 5.4.1), OIDs `1.3.6.1.2.1.25.3.5.1.2.1`
  (hrPrinterDetectedErrorState) and the Samsung private `1.3.6.1.4.1.236.11.5.1.1.9.15.0`.
  The ML-2160 has no network interface, and an AirPort does not proxy SNMP.
* **USB printers:** vendor-specific USB device requests (`IOSecUSB`, `usbDeviceRequest`,
  `getXMLSpec`) plus `@PJL GETDEVICEID` / `@PJL LITESMSTATUS` on the bulk pipe. The filter
  then printed the CUPS attribute line
  `ATTR: marker-colors=#000000 marker-levels=%d marker-names=Black marker-types=ink`.

A print server only relays the bulk data pipe, never USB control requests.

## What the ML-2160 answers over the data channel

Raw PJL sent to `AirPort-Express.local:9100` (one connection per query, ≥ 12 s apart — the
AirPort accepts a single connection, `qtotal=1`, and resets back-to-back connections):

| Query | Reply |
|-------|-------|
| `@PJL INFO STATUS` | `@PJL INFO STATUS\r\n\x0c` (header only, **no** `CODE=` / `DISPLAY=`) |
| `@PJL INFO CONFIG` | `@PJL INFO CONFIG\r\n\x0c` (empty) |
| `@PJL INFO ID`, `INFO VARIABLES`, `INFO USTATUS`, `INFO PAGECOUNT`, `INFO MEMORY` | nothing |
| `@PJL GETDEVICEID`, `@PJL LITESMSTATUS`, `@PJL USTATUS DEVICE=ON` | nothing |

The engine's PJL implementation is a stub that echoes the two most common requests and ignores
everything else. The `R0STATUS:BUSY` seen in the IEEE 1284 device ID is a constant string, not
live status (also observed on Linux: `MODE:SPL5,R0STATUS:BUSY`).

Reproduce with:

```bash
python3 - <<'EOF2'
import socket
s = socket.create_connection(("AirPort-Express.local", 9100), timeout=5)
s.sendall(b"\x1b%-12345X@PJL \r\n@PJL INFO STATUS\r\n"); s.settimeout(3)
try: print(repr(s.recv(4096)))
except socket.timeout: print("no reply")
s.sendall(b"\x1b%-12345X"); s.close()
EOF2
```

## Options left

1. **Direct USB to the Mac** + reverse-engineering the Samsung control requests (a USB capture of
   *Samsung Printer Status* on an Intel Mac or Windows would be the starting point). Then a
   `commandtoqpdl` CUPS command filter could answer `ReportLevels`. Untested, undocumented.
2. **Printer report page.** The printer prints its own configuration/supplies report (see the
   model's user manual, usually a long press on the front button). Toner remaining is on it.
3. Accept "Information not available". This is what the PPDs here do: they declare no
   `*cupsCommands`, so macOS shows the message instead of a failing command job.

If you have a Samsung model that *does* answer `@PJL INFO STATUS` with `CODE=`, open an issue
with the reply: mapping those codes to CUPS `STATE:` reasons (media-empty, cover-open,
toner-low) is a small, self-contained contribution.
