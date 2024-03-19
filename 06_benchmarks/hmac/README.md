# Memory attestation macrobenchmark on 5969

Make sure to read the instructions in the README files in the `base_attestation` (i.e., only IPE, without our software mitigation framework applied) and `translated_attestation` projects (i.e., with our MPU software mitigations applied).

Invoke the translation script to (re-)obtain the generated files in `translated_attestation/output/`:

```shell
../../05_framework/framework/translator.py base_attestation/ipe.c -ccs ~/ti/ccs1260/ccs/
```

If you want to collect timing measurements, open one CCS window (and workspace with) a `../timer/` project and another with the `*_attestation` project.
First launch the timer application, then the HMAC application.
Once 100 measurements are collected, the timer project will start printing them out to the console.
This output can be fed to the `../measurements/calculator.py` script.
