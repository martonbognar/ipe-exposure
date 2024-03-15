#define IPE_ENTRY __attribute__((section (".ipe_entry"), retain))
#define IPE_FUNC __attribute__((section (".ipe_func"), retain))
#define IPE_VAR __attribute__((section (".ipe_vars"), retain))
#define IPE_CONST __attribute__((section (".ipe_const"), retain))
#define IPE_ISR __attribute__((section (".ipe:_isr"), retain))

#undef always_inline
#define always_inline static inline __attribute__((always_inline))

int outside_IPE_segment(void* ptr);
int constant_time_cmp(const unsigned char *x_, const unsigned char *y_, const unsigned int n);
