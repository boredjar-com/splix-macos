# Third-party sources

| Component | Version | License | Origin | SHA-256 |
|-----------|---------|---------|--------|---------|
| SpliX (rastertoqpdl, PPDs) | 2.0.1 | GPL-2.0 | https://deb.debian.org/debian/pool/main/s/splix/splix_2.0.1.orig.tar.gz | b672501f16f07f3c43543708248b789d15467eacfe18f25ab8f83f0209da1f8a |
| JBIG-KIT (libjbig85 only) | 2.1 | GPL-2.0-or-later | https://www.cl.cam.ac.uk/~mgk25/jbigkit/download/jbigkit-2.1.tar.gz | de7106b6bfaf495d6865c7dd7ac6ca1381bd12e0d81405ea81e7f2167263d932 |

Both trees are vendored unmodified. All macOS-specific changes live in `macos/`
and are applied at build time (compiler flags, PPD rewriting). Upstream SpliX:
http://splix.ap2c.org — Aurélien Croc (AP²C).
