#include <string.h>

void __attribute__((section (".ipe_func"), retain)) *ipe_memset(void *mem, int ch, size_t length)
{
     char *m = (char *)mem;

     while (length--) *m++ = ch;
     return mem;
}
