#!/usr/bin/env python3

import statistics
import sys
import csv

file = sys.argv[1]

# read cycle counts
if file.endswith('.csv'):
    with open(file) as f:
        data = list(csv.reader(f))[0]
        data = [int(d, 16) for d in data[:-1]]
else:
    data = []
    with open(file) as inp:
        for line in inp.readlines():
            data.append(int(line, 16))
#print(data)

# calculate ms from cycle count (assume 16 MHz)
freq = 16 * (10 ** 6)

ms = [(10 ** 3) * entry / freq for entry in data]

print(f"Mean: {statistics.mean(ms):.4f} ms")
print(f"Stdv: {statistics.stdev(ms):.6f} ms")
