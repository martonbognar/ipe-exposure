
- `hmac/`: the project used for our macrobenchmark, HMAC code attestation
- `measurements/`: timing measurements obtained during our experiments and an evaluation script
- `software-bor/`: projects that repeatedly trigger a software brown-out reset
- `timer/`: projects to time events over GPIO



To simultaneously debug multiple devices, multiple instances of CCS need to be launched with different workspaces selected.
Import the two projects in the two separate workspaces, and launch the debug sessions from there.
For one of the projects, you will have the change the port used for debugging, this can be done via `Project > Properties > General > Connection`.
Select `TI MSP430 USB2`.