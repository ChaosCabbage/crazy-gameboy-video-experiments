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
	int_InterruptRoutine VBlankFunc
SECTION	"LCDC",ROM0[$0048]
	int_InterruptRoutine LCDCFunc
SECTION	"Timer_Overflow",ROM0[$0050]
	int_InterruptRoutine TimerOverflowFunc
SECTION	"Serial",ROM0[$0058]
	int_InterruptRoutine SerialFunc
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
	int_SetCallbackFunc VBlankFunc, int_NopFunc
	int_SetCallbackFunc LCDCFunc, int_NopFunc
    int_SetCallbackFunc TimerOverflowFunc, int_NopFunc
    int_SetCallbackFunc SerialFunc, int_NopFunc
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
VBlankFunc::
	DW 
LCDCFunc::
	DW 
TimerOverflowFunc::
    DW
SerialFunc::
    DW
