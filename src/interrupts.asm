; My interrupt system.
; Allows you to set a function pointer to handle each type of interrupt.

INCLUDE "interrupts.inc"

; ************************************
;   Macros
; ************************************
int_InterruptRoutine: MACRO
	ld  bc, \1
	call int_CallPointer
	reti
	ENDM

; ************************************
;   Interrupt routine sections
; ************************************

SECTION	"Vblank",ROM0[$0040]
	int_InterruptRoutine int_VBlankFunc
SECTION	"LCDC",ROM0[$0048]
	int_InterruptRoutine int_LCDCFunc
SECTION	"Timer_Overflow",ROM0[$0050]
	int_InterruptRoutine int_TimerOverflowFunc
SECTION	"Serial",ROM0[$0058]
	int_InterruptRoutine int_SerialFunc
SECTION	"p1thru4",ROM0[$0060]
	reti

SECTION "Interrupt Helper Code",ROM0

; ************************************
; Routines
; ************************************

; A useful function for function pointers
int_NopFunc::
	ret

; Set all the interrupts to do nothing
int_Reset::
	int_SetVBlankFunc int_NopFunc
	int_SetLCDCFunc int_NopFunc
    int_SetTimerOverflowFunc int_NopFunc
    int_SetSerialFunc int_NopFunc
    ret

; Call a function pointer.
; BC = address of function to call
int_CallPointer:
	ld  a, [bc]
	ld  l, a
	inc bc
	ld  a, [bc]
	ld  h, a

	jp hl
	; Do _not_ RET: the function we jump to is expected to RET.

; ************************************
; RAM for storing function pointers to your interrupt routines.
; ************************************
SECTION "interrupt function pointers", WRAM0
int_VBlankFunc::
	DW 
int_LCDCFunc::
	DW 
int_TimerOverflowFunc::
    DW
int_SerialFunc::
    DW
