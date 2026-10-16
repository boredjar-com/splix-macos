# Supported printers

Every printer below has a PPD in this package and prints through the same
`rastertoqpdl` filter. "Tested" means someone confirmed it on macOS 27 with this
build; please open an issue or PR to add yours. All of these are SPL / QPDL
(Samsung Printer Language) laser printers whose vendor drivers are Intel-only
and therefore dead on macOS 27 (no Rosetta).

| PPD (`Select Software…` name) | PPD file | QPDL | Colour | Tested on macOS 27 |
|---|---|---|---|---|
| Dell 1100 (SpliX) | `1100.ppd.gz` | v1 | no |  |
| Dell 1110 (SpliX) | `1110.ppd.gz` | v1 | no |  |
| Samsung CLP-200 (SpliX) | `clp200.ppd.gz` | v1 | yes |  |
| Samsung CLP-300 (SpliX) | `clp300.ppd.gz` | v2 | yes |  |
| Samsung CLP-310 (SpliX) | `clp310.ppd.gz` | v5 | yes |  |
| Samsung CLP-310N (SpliX) | `clp310n.ppd.gz` | v2 | yes |  |
| Samsung CLP-315 (SpliX) | `clp315.ppd.gz` | v5 | yes |  |
| Samsung CLP-500 (SpliX) | `clp500.ppd.gz` | v1 | yes |  |
| Samsung CLP-510 (SpliX) | `clp510.ppd.gz` | v1 | yes |  |
| Samsung CLP-550 (SpliX) | `clp550.ppd.gz` | v1 | yes |  |
| Samsung CLP-600 (SpliX) | `clp600.ppd.gz` | v1 | yes |  |
| Samsung CLX-216X (SpliX) | `clx216x.ppd.gz` | v2 | yes |  |
| Samsung CLX-2170 (SpliX) | `clx2170.ppd.gz` | v2 | yes |  |
| Samsung CLX-3160 (SpliX) | `clx3160.ppd.gz` | v2 | yes |  |
| Toshiba eSTUDIO180S (SpliX) | `es180s.ppd.gz` | v1 | no |  |
| Samsung ML-1510 (SpliX) | `ml1510.ppd.gz` | v1 | no |  |
| Samsung ML-1520 (SpliX) | `ml1520.ppd.gz` | v1 | no |  |
| Samsung ML-1610 (SpliX) | `ml1610.ppd.gz` | v1 | no |  |
| Samsung ML-1630 (SpliX) | `ml1630.ppd.gz` | v2 | no |  |
| Samsung ML-1640 (SpliX) | `ml1640.ppd.gz` | v2 | no |  |
| Samsung ML-1660 (SpliX) | `ml1660.ppd.gz` | v3 | no |  |
| Samsung ML-1710 (SpliX) | `ml1710.ppd.gz` | v1 | no |  |
| Samsung ML-1740 (SpliX) | `ml1740.ppd.gz` | v1 | no |  |
| Samsung ML-1750 (SpliX) | `ml1750.ppd.gz` | v1 | no |  |
| Samsung ML-1910 (SpliX) | `ml1910.ppd.gz` | v3 | no |  |
| Samsung ML-1915 (SpliX) | `ml1915.ppd.gz` | v3 | no |  |
| Samsung ML-2010 (SpliX) | `ml2010.ppd.gz` | v2 | no |  |
| Samsung ML-2015 (SpliX) | `ml2015.ppd.gz` | v2 | no |  |
| Samsung ML-2150 (SpliX) | `ml2150.ppd.gz` | v1 | no |  |
| Samsung ML-2160 (SpliX) | `ml2160.ppd.gz` | v3 | no | yes (AirPort Express, socket://) |
| Samsung ML-2165 (SpliX) | `ml2165.ppd.gz` | v3 | no |  |
| Samsung ML-2240 (SpliX) | `ml2240.ppd.gz` | v2 | no |  |
| Samsung ML-2250 (SpliX) | `ml2250.ppd.gz` | v1 | no |  |
| Samsung ML-2251 (SpliX) | `ml2251.ppd.gz` | v1 | no |  |
| Samsung ML-2510 (SpliX) | `ml2510.ppd.gz` | v2 | no |  |
| Samsung ML-2525 (SpliX) | `ml2525.ppd.gz` | v3 | no |  |
| Samsung ML-2525W (SpliX) | `ml2525w.ppd.gz` | v3 | no |  |
| Samsung ML-2550 (SpliX) | `ml2550.ppd.gz` | v1 | no |  |
| Samsung ML-2571 (SpliX) | `ml2571.ppd.gz` | v1 | no |  |
| Samsung ML-2580 (SpliX) | `ml2580.ppd.gz` | v3 | no |  |
| Samsung ML-2580N (SpliX) | `ml2580n.ppd.gz` | v3 | no |  |
| Samsung ML-3050 (SpliX) | `ml3050.ppd.gz` | v3 | no |  |
| Samsung ML-3051 (SpliX) | `ml3051.ppd.gz` | v3 | no |  |
| Samsung ML-3051ND (SpliX) | `ml3051nd.ppd.gz` | v3 | no |  |
| Samsung ML-3310 (SpliX) | `ml3310.ppd.gz` | v3 | no |  |
| Samsung ML-3310ND (SpliX) | `ml3310nd.ppd.gz` | v3 | no |  |
| Samsung ML-3471ND (SpliX) | `ml3471nd.ppd.gz` | v1 | no |  |
| Samsung ML-3560 (SpliX) | `ml3560.ppd.gz` | v1 | no |  |
| Xerox Phaser 3115 (SpliX) | `ph3115.ppd.gz` | v1 | no |  |
| Xerox Phaser 3116 (SpliX) | `ph3116.ppd.gz` | v1 | no |  |
| Xerox Phaser 3117 (SpliX) | `ph3117.ppd.gz` | v2 | no |  |
| Xerox Phaser 3120 (SpliX) | `ph3120.ppd.gz` | v1 | no |  |
| Xerox Phaser 3121 (SpliX) | `ph3121.ppd.gz` | v1 | no |  |
| Xerox Phaser 3122 (SpliX) | `ph3122.ppd.gz` | v2 | no |  |
| Xerox Phaser 3124 (SpliX) | `ph3124.ppd.gz` | v2 | no |  |
| Xerox Phaser 3130 (SpliX) | `ph3130.ppd.gz` | v1 | no |  |
| Xerox Phaser 3140 (SpliX) | `ph3140.ppd.gz` | v3 | no |  |
| Xerox Phaser 3150 (SpliX) | `ph3150.ppd.gz` | v1 | no |  |
| Xerox Phaser 3155 (SpliX) | `ph3155.ppd.gz` | v3 | no |  |
| Xerox Phaser 3160 (SpliX) | `ph3160.ppd.gz` | v1 | no |  |
| Xerox Phaser 3420 (SpliX) | `ph3420.ppd.gz` | v1 | no |  |
| Xerox Phaser 3425 (SpliX) | `ph3425.ppd.gz` | v1 | no |  |
| Xerox Phaser 5500 (SpliX) | `ph5500.ppd.gz` | v1 | no |  |
| Xerox Phaser 6100 (SpliX) | `ph6100.ppd.gz` | v1 | yes |  |
| Xerox Phaser 6110 (SpliX) | `ph6110.ppd.gz` | v2 | yes |  |
| Samsung SCX-3200 (SpliX) | `scx3200.ppd.gz` | v3 | no |  |
| Samsung SCX-4100 (SpliX) | `scx4100.ppd.gz` | v1 | no |  |
| Samsung SCX-4200 (SpliX) | `scx4200.ppd.gz` | v1 | no |  |
| Samsung SCX-4216F (SpliX) | `scx4216f.ppd.gz` | v1 | no |  |
| Samsung SCX-4300 (SpliX) | `scx4300.ppd.gz` | v1 | no |  |
| Samsung SCX-4500 (SpliX) | `scx4500.ppd.gz` | v1 | no |  |
| Samsung SCX-4521F (SpliX) | `scx4521f.ppd.gz` | v1 | no |  |
| Samsung SCX-4600 (SpliX) | `scx4600.ppd.gz` | v3 | no |  |
| Samsung SCX-4623f (SpliX) | `scx4623f.ppd.gz` | v3 | no |  |
| Samsung SCX-4623fw (SpliX) | `scx4623fw.ppd.gz` | v3 | no |  |
| Samsung SCX-5330N (SpliX) | `scx5330n.ppd.gz` | v3 | no |  |
| Samsung SCX-5530FN (SpliX) | `scx5530fn.ppd.gz` | v3 | no |  |
| Samsung SF-565P (SpliX) | `sf565p.ppd.gz` | v1 | no |  |
| Xerox WorkCentre 3119 (SpliX) | `wc3119.ppd.gz` | v1 | no |  |
| Xerox WorkCentre PE114e (SpliX) | `wcpe114e.ppd.gz` | v1 | no |  |
| Xerox WorkCentre PE16 (SpliX) | `wcpe16.ppd.gz` | v1 | no |  |
| Lexmark X215 MFP (SpliX) | `x215mfp.ppd.gz` | v1 | no |  |

Rebadged models: Xerox Phaser 3117/3122/3124/3130/3140/3155/3160, Xerox WorkCentre
PE16/PE114e/3119, Dell 1100/1110, Toshiba e-STUDIO 180S, Lexmark X215 MFP
all share Samsung engines and are listed above under their own names.

Not supported (no SpliX PPD): Samsung printers that only speak the newer
"SPL-C / ULD" dialects (e.g. M2020/M2070 series, Xpress M20xx/M28xx, C4xx).
They need a different filter; contributions welcome.
