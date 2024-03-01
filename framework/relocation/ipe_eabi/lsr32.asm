;******************************************************************************
;* LSR32.ASM -                                                                *
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
;-- 32-bit logical right shift     
;---------------------------------------------------------------------------
     .if $DEFINED(__LARGE_CODE_MODEL__)
	.asg RETA,RET
        .asg 4,    RETADDRSZ
     .else
        .asg 2,    RETADDRSZ
     .endif

     .if __TI_EABI__
        .asg __ipe___mspabi_srll, L_LSR
        .asg __ipe___mspabi_srll_15, L_LSR_15
        .asg __ipe___mspabi_srll_14, L_LSR_14
        .asg __ipe___mspabi_srll_13, L_LSR_13
        .asg __ipe___mspabi_srll_12, L_LSR_12
        .asg __ipe___mspabi_srll_11, L_LSR_11
        .asg __ipe___mspabi_srll_10, L_LSR_10
        .asg __ipe___mspabi_srll_9, L_LSR_9
        .asg __ipe___mspabi_srll_8, L_LSR_8
        .asg __ipe___mspabi_srll_7, L_LSR_7
        .asg __ipe___mspabi_srll_6, L_LSR_6
        .asg __ipe___mspabi_srll_5, L_LSR_5
        .asg __ipe___mspabi_srll_4, L_LSR_4
        .asg __ipe___mspabi_srll_3, L_LSR_3
        .asg __ipe___mspabi_srll_2, L_LSR_2
        .asg __ipe___mspabi_srll_1, L_LSR_1
     .endif
	
     .if $DEFINED(.MSP430X)
LLSR1   .macro P1, P2
	RRUM.W #1, P1
	RRCM.W #1, P2
	.endm
     .else
LLSR1   .macro P1, P2
	CLRC
	RRC    P1
	RRC    P2
	.endm
     .endif	
	
            .sect ".ipe_func"
	    .align 2
	    .clink

            .global L_LSR

L_LSR:      .asmfunc stack_usage(RETADDRSZ)
            AND    #31,R14        ; constain range of shift
            JZ     L_LSR_RET      ; if zero, abort

L_LSR_TOP:  LLSR1  R13, R12
            DEC    R14
            JNZ    L_LSR_TOP
L_LSR_RET:  
	    RET
	    .endasmfunc

	    .sect ".ipe_func"
	    .align 2
	    .clink

            .global L_LSR_15, L_LSR_14, L_LSR_13, L_LSR_12, L_LSR_11
            .global L_LSR_10, L_LSR_9,  L_LSR_8,  L_LSR_7,  L_LSR_6
            .global L_LSR_5,  L_LSR_4,  L_LSR_3,  L_LSR_2,  L_LSR_1 	
            
L_LSR_15:   .asmfunc stack_usage(RETADDRSZ)
            LLSR1  R13, R12
L_LSR_14:   LLSR1  R13, R12
L_LSR_13:   LLSR1  R13, R12
L_LSR_12:   LLSR1  R13, R12
L_LSR_11:   LLSR1  R13, R12
L_LSR_10:   LLSR1  R13, R12
L_LSR_9:    LLSR1  R13, R12
L_LSR_8:    LLSR1  R13, R12
L_LSR_7:    LLSR1  R13, R12
L_LSR_6:    LLSR1  R13, R12
L_LSR_5:    LLSR1  R13, R12
L_LSR_4:    LLSR1  R13, R12
L_LSR_3:    LLSR1  R13, R12
L_LSR_2:    LLSR1  R13, R12
L_LSR_1:    LLSR1  R13, R12
	    RET
            .endasmfunc

;******************************************************************************
;* BUILD ATTRIBUTES                                                           *
;*    HW_MPY_INLINE_INFO=1:  file does not have any inlined hw mpy            *
;*    HW_MPY_ISR_INFO   =1:  file does not have ISR's with mpy or func calls  *
;******************************************************************************
	.battr "TI", Tag_File, 1, Tag_HW_MPY_INLINE_INFO(1)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_ISR_INFO(1)
