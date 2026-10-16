# Root cause: why Samsung printers stopped working on macOS 27

Date of analysis: 2026-10-16. Machine: Apple Silicon, macOS 27.0.1 (build 26A434), CUPS 2.3.4.

## Symptoms

* Printer appears via Bonjour, queue is created, every job ends in **"Filter failed"**.
* System Settings → Printers shows the printer idle, nothing prints.
* `lpstat -p -l` shows `Filter failed`; the CUPS log ends with
  `printer-state-reasons=com.apple.badarch-error`.

## Evidence

```
$ /usr/bin/arch -x86_64 /usr/bin/true
arch: posix_spawnp: /usr/bin/true: Bad CPU type in executable      # Rosetta is gone

$ file /Library/Printers/Samsung/UPD/Filters/rastertosec
Mach-O universal binary with 2 architectures: [x86_64] [i386]       # no arm64 slice

$ gunzip -c "/Library/Printers/PPDs/Contents/Resources/Samsung ML-2160 Series.gz" | grep cupsFilter
*cupsFilter: "application/vnd.cups-raster 0 /Library/Printers/Samsung/UPD/Filters/rastertosec"
*cupsFilter: "application/vnd.cups-command 100 /Library/Printers/Samsung/UPD/Filters/commandtosec"
```

CUPS log of a job with the vendor PPD (debug logging on):

```
cgpdftoraster: rasterWriteHeader: Unable to write raster stream header: Broken pipe
printer-state-message="Filter failed"
printer-state-reasons=com.apple.badarch-error
```

`cgpdftoraster` (Apple, arm64) produced the raster; `cupsd` could not exec the Intel-only
`rastertosec`, closed the pipe, and flagged the architecture error.

## What the printer actually speaks

Bonjour TXT record published by the AirPort Express for the USB-attached ML-2160:

```
pdl=application/SPL,application/FWV,application/PIC,application/EXT
usb_MFG=Samsung usb_MDL=ML-2160 Series usb_CMD=SPL,FWV,PIC,EXT usb_MODE=SPL5,R0STATUS:BUSY
```

`strings rastertosec` shows the job wrapper the vendor filter emits:

```
%-12345X@PJL ... @PJL ENTER LANGUAGE=QPDL
```

So the wire format is **QPDL** (Samsung Printer Language, "SPL"), exactly what the GPL
SpliX project implements in `rastertoqpdl`. SpliX 2.0.1 ships `ml2160.ppd` with
`QPDLVersion 3`, band size 128, compression 0x11 (no JBIG needed for this model).

## Why the open-source replacement works

* Apple still ships the PPD/filter machinery in macOS 27: `/usr/libexec/cups/filter/cgpdftoraster`
  turns PDF into CUPS raster using the PPD's `*Resolution` and `*ColorModel` entries.
* `rastertoqpdl` only needs `libcups` and `libcupsimage`, both present in the macOS SDK
  (`libcupsimage.tbd`), and the vendored JBIG-KIT for the colour models.
* CUPS accepts third-party filters from any absolute path as long as the binary is root-owned
  and not group/world writable. `/usr/libexec/cups` is SIP-protected, so the filter lives in
  `/Library/Printers/SpliX/` like vendor drivers do.
* The AirPort Express exposes raw port 9100 (`_pdl-datastream._tcp`) besides Apple's
  `_riousbprint._tcp`; the `socket://` backend is the simplest, `riousbprint://` works too.

## First successful job

```
job-state (enum) = completed
job-impressions-completed (integer) = 1
job-media-sheets-completed (integer) = 1
```

Job 46, 14 s from submission to completion, page printed correctly (A4, text + filled box).
