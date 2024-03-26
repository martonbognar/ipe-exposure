# IPE attack primitives

This directory contains minimal, standalone proof-of-concept programs to showcase the different attack primitives described in Section 3 of the paper and summarized in Table 1.

![table1](table1.png)

## Subdirectory structure

Attack primitives are organized in hierarchical subdirectories as per Table 1 and MSP430 device number.

The subdirectory for the novel _controlled call corruption_ primitive also includes relevant negative results discussed in the paper.

## Running the programs

Refer to the top-level [README](../README.md#3-running-a-sample-ccs-project) on how to import and run the CCS projects with IPE enabled.

Every project contains a README with the expected output. For the architectural attack primitives, this should print the secret value `0x1337` (whereas reading directly yields the dummy value `0x3fff`):

```
Secret directly: 3fff, storage: 1337
```

For the side-channel attack primitives, the expected output shows that different behaviors can be distinguished.
