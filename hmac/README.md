# Memory attestation macrobenchmark on 5969

Make sure to read the instructions in `untrusted.c`.

Invoke the translation script to (re-)obtain the generated files:

```shell
../../framework/translator.py ../base_attestation/ipe.c -ccs /home/user/ti/ccs1230/ccs
```

If you want to collect timing measurements, open one CCS window (and workspace with) a `timer/` project and another with the `*_attestation` project.
First launch the timer application, then the HMAC application.
Once 100 measurements are collected, the timer project will start printing them out to the console.
This output can be fed to the `measurements/calculator.py` script.
