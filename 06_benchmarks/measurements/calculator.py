#!/usr/bin/env python3

import statistics
import sys

file = sys.argv[1]
data = []

# read cycle counts
with open(file) as inp:
    for line in inp.readlines():
        data.append(int(line, 16))

# calculate ms from cycle count (assume 16 MHz)
freq = 16 * (10 ** 6)

ms = [(10 ** 3) * entry / freq for entry in data]

print(f"Mean: {statistics.mean(ms):.4f} ms")
print(f"Stdv: {statistics.stdev(ms):.6f} ms")
