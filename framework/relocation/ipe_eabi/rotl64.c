/*****************************************************************************/
/*  rotl64.c       							     */
/*                                                               */
/* Copyright (c) 2011 Texas Instruments Incorporated             */
/* http://www.ti.com/                                            */
/*                                                               */
/*  Redistribution and  use in source  and binary forms, with  or without */
/*  modification,  are permitted provided  that the  following conditions */
/*  are met:                                                     */
/*                                                               */
/*     Redistributions  of source  code must  retain the  above copyright */
/*     notice, this list of conditions and the following disclaimer. */
/*                                                               */
/*     Redistributions in binary form  must reproduce the above copyright */
/*     notice, this  list of conditions  and the following  disclaimer in */
/*     the  documentation  and/or   other  materials  provided  with  the */
/*     distribution.                                             */
/*                                                               */
/*     Neither the  name of Texas Instruments Incorporated  nor the names */
/*     of its  contributors may  be used to  endorse or  promote products */
/*     derived  from   this  software  without   specific  prior  written */
/*     permission.                                               */
/*                                                               */
/*  THIS SOFTWARE  IS PROVIDED BY THE COPYRIGHT  HOLDERS AND CONTRIBUTORS */
/*  "AS IS"  AND ANY  EXPRESS OR IMPLIED  WARRANTIES, INCLUDING,  BUT NOT */
/*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR */
/*  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT */
/*  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, */
/*  SPECIAL,  EXEMPLARY,  OR CONSEQUENTIAL  DAMAGES  (INCLUDING, BUT  NOT */
/*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, */
/*  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY */
/*  THEORY OF  LIABILITY, WHETHER IN CONTRACT, STRICT  LIABILITY, OR TORT */
/*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE */
/*  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */
/*                                                               */
/*****************************************************************************/

#if defined(__TI_EABI__)
#define __lslll __ipe___mspabi_sllll
#define __lsrll __ipe___mspabi_srlll
#define __rllll __ipe___mspabi_rllll
#endif

unsigned long long __lslll(unsigned long long a, int c);
unsigned long long __lsrll(unsigned long long a, int c);

/*****************************************************************************/
/*                                                                           */
/* __rllll() - logical rotate left "unsigned long long"                      */
/*                                                                           */
/*****************************************************************************/
unsigned long long __attribute__((section (".ipe_func"), retain)) __rllll(unsigned long long a, int c)
{
    return __lslll(a, c) | __lsrll(a, 64-c);
}
