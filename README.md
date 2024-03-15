# Intellectual Property Exposure: Subverting and Securing Intellectual Property Encapsulation in Texas Instruments Microcontrollers

This repository contains the code associated with our [IPE Exposure paper](https://mici.hu/papers/bognar24exposure.pdf) to appear at [USENIX Security '24](https://www.usenix.org/conference/usenixsecurity24).

```tex
@inproceedings{bognar24exposure,
  author    = {Bognar, Marton and Magnus, Cas and Piessens, Frank and Van Bulck, Jo},
  title     = {Intellectual Property Exposure: Subverting and Securing {Intellectual Property Encapsulation} in {Texas Instruments} Microcontrollers},
  booktitle = {33rd {USENIX} Security Symposium ({USENIX} Security 24)},
  year      = 2024,
}
```

## Artifact overview

| Claim | Paper Ref | Directory | Description |
| :-----| :-------------- | :-------- | :---------- |
| C1 | §3 (Table 1)   | [01_attack_primitives](01_attack_primitives) | Minimal, standalone proof-of-concepts for our basic attack primitives: _(1)_ controlled-call corruption; _(2)_ code-gadget reuse; _(3)_ interrupt register state; _(4)_ cache-timing side channel; _(5)_ interrupt-latency side channel; _(6)_ MPU controlled channel. |
| C2 | §3.4 (Table 4) | [02_covert_channel](02_covert_channel) |  Covert-channel evaluation on the MSP430FR5969. |
| C3 | §4             | [03_end_to_end_attacks](03_end_to_end_attacks) |  End-to-end attack scenarios: _(1)_ overwriting AES key; _(2)_ inserting a leaky gadget; _(3)_ overwriting `ipe_init_struct` to lift protection. |
| C4 | §3.1 | [04_sancus_exploit](sancus_exploit) |  Proof-of-concept controlled-call corruption exploit and mitigation on a modified version of Sancus on openMSP430. | 
| C5 | §6 | [05_framework](05_framework)| Software framework to improve the security of IPE-protected programs and mitigate our attacks. | 
| C6 | §6.4 (Tables 5,7) | [06_benchmarks](06_benchmarks) | Microbenchmark evaluation results + macrobenchmark for protected HACL* HMAC attestation. | 

## Running the projects

If you want to run the Sancus evaluation, make sure the clone the repository with `git clone --recurse-submodules https://github.com/martonbognar/ipe-exposure`.

Projects can be imported to CCS via `File > Open Projects from File System...`.
If you get an error about data verification, make sure that "Target > MSP43x Options > On connect, erase main, information, and IP protected area" is enabled in the debug configuration.
Always read the main source file (usually `main.c`) before running the code, it often contains instructions.

To simultaneously debug multiple devices, multiple instances of CCS need to be launched with different workspaces selected.
Import the two projects in the two separate workspaces, and launch the debug sessions from there.
For one of the projects, you will have the change the port used for debugging, this can be done via `Project > Properties > General > Connection`.
Select `TI MSP430 USB2`.
