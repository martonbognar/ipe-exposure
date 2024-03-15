 __attribute__((section(".ipe_entry"), retain)) void protected_internal(void)
{
  int temp = key[0];
  temp += key[0];
  temp -= 42;
  public = temp;
}

