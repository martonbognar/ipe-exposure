# Memory attestation with HMAC, hardened with our software framework

This file can be configured to either run the
attestation normally (and collect timing information), or perform an attack chain to steal the secret attestation key.
If the attack is to be performed, removed the comment from the line `#define ATTACK` (line 19).

After launching the debug session, do a hardset (to finish the setup), then run the code.

To inspect the output, open the Memory Browser view.
When running the attestation normally, the `mac_region` array will have changed.
When performing the attack, the device will get into an infinite loop due to the attack code triggering a reset, but the `buffer` array will never contain the secret key.
