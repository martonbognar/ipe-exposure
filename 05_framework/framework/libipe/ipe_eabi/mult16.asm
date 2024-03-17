;******************************************************************************
;* MPY16.ASM -                                                                *
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
;****************************************************************************
;* __ipe___mpyi  (int16 = int16 * int16)
;*  
;*   - Operand 1 is in R12
;*   - Operand 2 is in R13
;*   - Result is in R12
;*
;*   Registers used:  R12,R13,R14
;* 
;*   Algorithm:
;*
;*    for(; OP1 != 0; OP2 <<= 1, (unsigned) OP1 >>= 1)
;*       if (OP1 & 1) prod += OP2;
;****************************************************************************
     .if $DEFINED(__LARGE_CODE_MODEL__)
	.asg RETA,RET
        .asg 4,    RETADDRSZ
     .else
        .asg 2,    RETADDRSZ
     .endif

     .if __TI_EABI__
        .asg __ipe___mspabi_mpyi, __ipe___mpyi
        .asg __ipe___mspabi_mpyi_sw, __ipe___mpyi_sw
     .endif
	
	.global __ipe___mpyi
	.global __ipe___mpyi_sw

	.sect ".ipe_func"
        .clink
	.align 2

__ipe___mpyi_sw:
__ipe___mpyi:	.asmfunc stack_usage(RETADDRSZ)
	CLR.W	R14		; Initialize product to 0

mpyi_add_loop:
	CLRC			
	RRC.W	R12		; Get LSB of OP1, rotate in 0 to cap MSB
	JNC     shift_test_mpyi	; If LSB of OP1 is zero, no add into product
	ADD.W	R13,R14		; If LSB of OP1 is 1, add OP2 into product

shift_test_mpyi:
	RLA.W	R13		; Prepare OP2 for next iteration, if needed
	TST.W	R12		; If OP1 == 0, done
	JNE	mpyi_add_loop	; Otherwise, continue add loop
	MOV.W	R14,R12		; Move product into result register
 	RET
	.endasmfunc


;******************************************************************************
;* BUILD ATTRIBUTES                                                           *
;*    HW_MPY_INLINE_INFO=1:  file does not have any inlined hw mpy            *
;*    HW_MPY_ISR_INFO   =1:  file does not have ISR's with mpy or func calls  *
;******************************************************************************
	.battr "TI", Tag_File, 1, Tag_HW_MPY_INLINE_INFO(1)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_ISR_INFO(1)
