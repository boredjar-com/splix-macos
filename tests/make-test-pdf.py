#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
"""Writes a minimal one-page A4 PDF (text + filled box) to the given path."""
import sys
content = b"BT /F1 36 Tf 72 700 Td (SpliX macOS test page) Tj ET 72 72 200 200 re f"
objs = [
    b"<< /Type /Catalog /Pages 2 0 R >>",
    b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R "
    b"/Resources << /Font << /F1 5 0 R >> >> >>",
    b"<< /Length %d >>stream\n" % len(content) + content + b"\nendstream",
    b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
]
out, offs = b"%PDF-1.4\n", []
for i, o in enumerate(objs):
    offs.append(len(out))
    out += b"%d 0 obj\n" % (i + 1) + o + b"\nendobj\n"
xref = len(out)
out += b"xref\n0 %d\n0000000000 65535 f \n" % (len(objs) + 1)
for o in offs:
    out += b"%010d 00000 n \n" % o
out += b"trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (len(objs) + 1, xref)
open(sys.argv[1], "wb").write(out)
