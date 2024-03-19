 # Memory attestation with HMAC
 
 This file can be configured to either run the attestation normally (and collect timing information), or perform  an attack chain to steal the secret attestation key. If the attack is to be performed, removed the comment from the line `#define ATTACK` (line 18).
 
 After launching the debug session, do a hard reset (to activate IPE), then run the code.
 
 To inspect the output, open the Memory Browser view.
 When running the attestation normally, the `mac_region` array will have changed.
 When performing the attack, the `buffer` array will contain the first
 few bytes (0x41, 0x41, ...) of the secret key.
