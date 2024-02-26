# Security evaluation

As the console detaches on resets, the values of `buffer`, `public`, `expected_public` need to be examined in the Memory Browser at the end of executions.

Invoke the translation script to (re-)obtain the generated files:

```shell
../../framework/translator.py ../demo_all/victim.c -ccs /home/user/ti/ccs1230/ccs
```
