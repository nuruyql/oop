#!/usr/bin/env python3

import sys

if len(sys.argv) < 2:
    print("Usage: ./hello.py <file>")
    sys.exit(1)

filename = sys.argv[1]

with open(filename, "rb") as f:
    data = f.read()

print("File size:", len(data), "bytes")