;******************************************************************************
;* ASR32.ASM -                                                                *
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

;------------------------------------------------------------------------------
;-- 32-bit arithmetic right shift     
;------------------------------------------------------------------------------
     .if $DEFINED(__LARGE_CODE_MODEL__)
	.asg RETA, RET
        .asg 4,    RETADDRSZ
     .else
        .asg 2,    RETADDRSZ
     .endif
     .if __TI_EABI__
        .asg __ipe___mspabi_sral, L_ASR
        .asg __ipe___mspabi_sral_15, L_ASR_15
        .asg __ipe___mspabi_sral_14, L_ASR_14
        .asg __ipe___mspabi_sral_13, L_ASR_13
        .asg __ipe___mspabi_sral_12, L_ASR_12
        .asg __ipe___mspabi_sral_11, L_ASR_11
        .asg __ipe___mspabi_sral_10, L_ASR_10
        .asg __ipe___mspabi_sral_9, L_ASR_9
        .asg __ipe___mspabi_sral_8, L_ASR_8
        .asg __ipe___mspabi_sral_7, L_ASR_7
        .asg __ipe___mspabi_sral_6, L_ASR_6
        .asg __ipe___mspabi_sral_5, L_ASR_5
        .asg __ipe___mspabi_sral_4, L_ASR_4
        .asg __ipe___mspabi_sral_3, L_ASR_3
        .asg __ipe___mspabi_sral_2, L_ASR_2
        .asg __ipe___mspabi_sral_1, L_ASR_1
     .endif
	
            .sect  ".ipe_func"
	    .align 2
	    .clink

            .global L_ASR 

L_ASR:      .asmfunc stack_usage(RETADDRSZ)
            AND    #31,R14        ; constain range of shift
            JZ     L_ASR_RET      ; if zero, abort

L_ASR_TOP:  RRA    R13
            RRC    R12
            DEC    R14
            JNZ    L_ASR_TOP
L_ASR_RET:  RET
	    .endasmfunc

	    .sect ".ipe_func"
	    .align 2
	    .clink

            .global L_ASR_15, L_ASR_14, L_ASR_13, L_ASR_12, L_ASR_11
            .global L_ASR_10, L_ASR_9,  L_ASR_8,  L_ASR_7,  L_ASR_6
            .global L_ASR_5,  L_ASR_4,  L_ASR_3,  L_ASR_2,  L_ASR_1 	
            
L_ASR_15:   .asmfunc stack_usage(RETADDRSZ)
	    RRA    R13
            RRC    R12
L_ASR_14:   RRA    R13
            RRC    R12
L_ASR_13:   RRA    R13
            RRC    R12
L_ASR_12:   RRA    R13
            RRC    R12
L_ASR_11:   RRA    R13
            RRC    R12
L_ASR_10:   RRA    R13
            RRC    R12
L_ASR_9:    RRA    R13
            RRC    R12
L_ASR_8:    RRA    R13
            RRC    R12
L_ASR_7:    RRA    R13
            RRC    R12
L_ASR_6:    RRA    R13
            RRC    R12
L_ASR_5:    RRA    R13
            RRC    R12
L_ASR_4:    RRA    R13
            RRC    R12
L_ASR_3:    RRA    R13
            RRC    R12
L_ASR_2:    RRA    R13
            RRC    R12
L_ASR_1:    RRA    R13
            RRC    R12
            RET
            .endasmfunc

;******************************************************************************
;* BUILD ATTRIBUTES                                                           *
;*    HW_MPY_INLINE_INFO=1:  file does not have any inlined hw mpy            *
;*    HW_MPY_ISR_INFO   =1:  file does not have ISR's with mpy or func calls  *
;******************************************************************************
	.battr "TI", Tag_File, 1, Tag_HW_MPY_INLINE_INFO(1)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_ISR_INFO(1)
