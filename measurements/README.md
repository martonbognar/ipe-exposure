# Timing measurements

The script `calculator.py` can be used to parse the console output of the `../timer/` projects, and calculate the mean and standard deviation of the timing data.

```sh
$ ./calculator.py software-bor-5969.txt
Mean: 0.3473 ms
Stdv: 0.000109 ms
```

`base_attestation.txt` and `translated_attestation.txt` contain our measurements of the end-to-end macrobenchmark.
The `software-bor-****.txt` files contain device-specific measurements of the software brown-out reset.
