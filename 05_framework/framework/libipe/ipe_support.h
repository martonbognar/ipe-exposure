#ifndef IPE_SUPPORT_H_
#define IPE_SUPPORT_H_

#define IPE_ENTRY __attribute__((section (".ipe_entry"), retain))
#define IPE_FUNC __attribute__((section (".ipe_func"), retain))
#define IPE_VAR __attribute__((section (".ipe_vars"), retain))
#define IPE_CONST __attribute__((section (".ipe_const"), retain))
#define IPE_ISR __attribute__((section (".ipe:_isr"), retain))

#undef always_inline
#define always_inline static inline __attribute__((always_inline))

int outside_IPE_segment(void* ptr);
int constant_time_cmp(const unsigned char *x_, const unsigned char *y_, const unsigned int n);

/*
 * HACK: include this as a weak symbol here so it is included in the symbol table and we can
 * fixup any relocations, but discard this unused dummy wrapper at link time..
 */
#define __IPE_ABI(fn) \
    void __attribute__((weak)) IPE_FUNC __ipe_##fn(void); \
    void __attribute__((weak)) __attribute__((section(".discard"))) __wrapper_ipe_##fn(void) \
    { \
        __ipe_##fn(); \
    }

#define __IPE_ABI_NUM(fn) \
    __IPE_ABI(fn) \
    __IPE_ABI(fn##_15) \
    __IPE_ABI(fn##_14) \
    __IPE_ABI(fn##_13) \
    __IPE_ABI(fn##_12) \
    __IPE_ABI(fn##_11) \
    __IPE_ABI(fn##_10) \
    __IPE_ABI(fn##_9) \
    __IPE_ABI(fn##_8) \
    __IPE_ABI(fn##_7) \
    __IPE_ABI(fn##_6) \
    __IPE_ABI(fn##_5) \
    __IPE_ABI(fn##_4) \
    __IPE_ABI(fn##_3) \
    __IPE_ABI(fn##_2) \
    __IPE_ABI(fn##_1)

__IPE_ABI(memset)
__IPE_ABI(__mspabi_mpyi)
__IPE_ABI_NUM(__mspabi_sral)
__IPE_ABI_NUM(__mspabi_slll)
__IPE_ABI_NUM(__mspabi_srll)
__IPE_ABI(__mspabi_rlll)
__IPE_ABI(__mspabi_sllll)
__IPE_ABI(__mspabi_srlll)
__IPE_ABI(__mspabi_rllll)

#endif /* IPE_SUPPORT_H_ */
