;******************************************************************************
;* LSL32.ASM -                                                                *
;*                                                                            *
;* Copyright (c) 2003 Texas Instruments Incorporated                          *
;* http://www.ti.com/                                                         *
;*                                                                            *
;*  Redistribution and  use in source  and binary forms, with  or without     *
;*  modification,  are permitted provided  that the  following conditions     *
;*  are met:                                                                  *
;*                                                                            *
;*     Redistributions  of source  code must  retain the  above copyright     *
;*     notice, this list of conditions and the following disclaimer.          *
;*                                                                            *
;*     Redistributions in binary form  must reproduce the above copyright     *
;*     notice, this  list of conditions  and the following  disclaimer in     *
;*     the  documentation  and/or   other  materials  provided  with  the     *
;*     distribution.                                                          *
;*                                                                            *
;*     Neither the  name of Texas Instruments Incorporated  nor the names     *
;*     of its  contributors may  be used to  endorse or  promote products     *
;*     derived  from   this  software  without   specific  prior  written     *
;*     permission.                                                            *
;*                                                                            *
;*  THIS SOFTWARE  IS PROVIDED BY THE COPYRIGHT  HOLDERS AND CONTRIBUTORS     *
;*  "AS IS"  AND ANY  EXPRESS OR IMPLIED  WARRANTIES, INCLUDING,  BUT NOT     *
;*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR     *
;*  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT     *
;*  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,     *
;*  SPECIAL,  EXEMPLARY,  OR CONSEQUENTIAL  DAMAGES  (INCLUDING, BUT  NOT     *
;*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,     *
;*  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY     *
;*  THEORY OF  LIABILITY, WHETHER IN CONTRACT, STRICT  LIABILITY, OR TORT     *
;*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE     *
;*  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.      *
;*                                                                            *
;******************************************************************************
;---------------------------------------------------------------------------
;-- 32-bit left shift     
;---------------------------------------------------------------------------
     .if $DEFINED(__LARGE_CODE_MODEL__)
	.asg RETA,RET
        .asg 4,    RETADDRSZ
     .else
        .asg 2,    RETADDRSZ
     .endif

     .if __TI_EABI__
        .asg __ipe___mspabi_slll, L_LSL
        .asg __ipe___mspabi_slll_15, L_LSL_15
        .asg __ipe___mspabi_slll_14, L_LSL_14
        .asg __ipe___mspabi_slll_13, L_LSL_13
        .asg __ipe___mspabi_slll_12, L_LSL_12
        .asg __ipe___mspabi_slll_11, L_LSL_11
        .asg __ipe___mspabi_slll_10, L_LSL_10
        .asg __ipe___mspabi_slll_9, L_LSL_9
        .asg __ipe___mspabi_slll_8, L_LSL_8
        .asg __ipe___mspabi_slll_7, L_LSL_7
        .asg __ipe___mspabi_slll_6, L_LSL_6
        .asg __ipe___mspabi_slll_5, L_LSL_5
        .asg __ipe___mspabi_slll_4, L_LSL_4
        .asg __ipe___mspabi_slll_3, L_LSL_3
        .asg __ipe___mspabi_slll_2, L_LSL_2
        .asg __ipe___mspabi_slll_1, L_LSL_1
     .endif
	
            .sect  ".ipe_func"
	    .align 2
	    .clink

	    .global L_LSL

L_LSL:      .asmfunc stack_usage(RETADDRSZ)
            AND    #31,R14        ; constain range of shift
            JZ     L_LSL_RET      ; if zero, abort

L_LSL_TOP:  RLA    R12
            ADDC   R13,R13
            DEC    R14
            JNZ    L_LSL_TOP
L_LSL_RET:
	    RET
	    .endasmfunc

	    .sect  ".ipe_func"
	    .align 2
	    .clink

            .global L_LSL_15, L_LSL_14, L_LSL_13, L_LSL_12, L_LSL_11
            .global L_LSL_10, L_LSL_9,  L_LSL_8,  L_LSL_7,  L_LSL_6
            .global L_LSL_5,  L_LSL_4,  L_LSL_3,  L_LSL_2,  L_LSL_1 
	
L_LSL_15:   .asmfunc stack_usage(RETADDRSZ)
	    RLA    R12
            ADDC   R13,R13
L_LSL_14:   RLA    R12
            ADDC   R13,R13
L_LSL_13:   RLA    R12
            ADDC   R13,R13
L_LSL_12:   RLA    R12
            ADDC   R13,R13
L_LSL_11:   RLA    R12
            ADDC   R13,R13
L_LSL_10:   RLA    R12
            ADDC   R13,R13
L_LSL_9:    RLA    R12
            ADDC   R13,R13
L_LSL_8:    RLA    R12
            ADDC   R13,R13
L_LSL_7:    RLA    R12
            ADDC   R13,R13
L_LSL_6:    RLA    R12
            ADDC   R13,R13
L_LSL_5:    RLA    R12
            ADDC   R13,R13
L_LSL_4:    RLA    R12
            ADDC   R13,R13
L_LSL_3:    RLA    R12
            ADDC   R13,R13
L_LSL_2:    RLA    R12
            ADDC   R13,R13
L_LSL_1:    RLA    R12
            ADDC   R13,R13
            RET
            .endasmfunc

;******************************************************************************
;* BUILD ATTRIBUTES                                                           *
;*    HW_MPY_INLINE_INFO=1:  file does not have any inlined hw mpy            *
;*    HW_MPY_ISR_INFO   =1:  file does not have ISR's with mpy or func calls  *
;******************************************************************************
	.battr "TI", Tag_File, 1, Tag_HW_MPY_INLINE_INFO(1)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_ISR_INFO(1)
