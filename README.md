# Intellectual Property Exposure: Subverting and Securing Intellectual Property Encapsulation in Texas Instruments Microcontrollers

This repository contains the code associated with our [IPE Exposure paper](https://mici.hu/papers/bognar24exposure.pdf).

```tex
@inproceedings{bognar24exposure,
  author    = {Bognar, Marton and Magnus, Cas and Piessens, Frank and Van Bulck, Jo},
  title     = {Intellectual Property Exposure: Subverting and Securing {Intellectual Property Encapsulation} in {Texas Instruments} Microcontrollers},
  booktitle = {33rd {USENIX} Security Symposium ({USENIX} Security 24)},
  year      = 2024,
}
```

The repository is structured as follows:

- `covert/`: projects showcasing the covert channels on the 5969
- `end-to-end/`: end-to-end attack scenarios
- `framework/`: our software framework to improve the security of IPE-protected programs
- `hmac/`: the project used for our macrobenchmark, HMAC code attestation
- `measurements/`: timing measurements obtained during our experiments and an evaluation script
- `negatives/`: selected negative results (where demonstration makes sense)
- `primitives/`: demonstrations of our attack primitives
- `sancus-core/`: Sancus repository submodule
- `sancus-exploit/`: files and scripts for Sancus experiments
- `security-eval/`: projects showcasing the security of our framework
- `software-bor/`: projects that repeatedly trigger a software brown-out reset
- `timer/`: projects to time events over GPIO

## Running the projects

If you want to run the Sancus evaluation, make sure the clone the repository with `git clone --recurse-submodules https://github.com/martonbognar/ipe-exposure`.

Projects can be imported to CCS via `File > Open Projects from File System...`.
If you get an error about data verification, make sure that "Target > MSP43x Options > On connect, erase main, information, and IP protected area" is enabled in the debug configuration.
Always read the main source file (usually `main.c`) before running the code, it often contains instructions.
