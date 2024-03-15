# Security evaluation

As the console detaches on resets, the values of `buffer`, `public`, `expected_public` need to be examined in the Memory Browser at the end of executions.

Invoke the translation script to (re-)obtain the generated files:

```shell
../framework/translator.py demo_all/victim.c -ccs ~/ti/ccs*/ccs
```

NOTES:

* For convenience, we provide a `demo_all` program that includes all attack primitives.
* `demo_all_translated` contains the translated version after running translator.py for reference


TODO:
* remove the duplicated demo_all_translated dir?
* add support for compiler-generated stub interception