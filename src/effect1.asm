INCLUDE "gbhardware.inc" 
INCLUDE "interrupts.inc"
INCLUDE "maths.inc"
INCLUDE "joypad.inc"

; ****************************************************************************************
; RAM
; ****************************************************************************************
SECTION "Effect1Scratch", WRAM0

effect1_XOffset:
    DB ; extra X scroll, incremented every frame
effect1_Finished:
    DB 

SECTION "Effect1", ROM0

; ****************************************************************************************
; Effect1: Two-way slant and scroll
;             /////////// ->
;          <- \\\\\\\\\\\   
;             /////////// ->
; ****************************************************************************************
effect1_Run::

; Set the vblank and stat interrupt routines
	int_SetVBlankFunc effect1_VBlank
	int_SetLCDCFunc effect1_HBlank

; Enable the vblank and stat interrupts to try some video effects
	ld  a, IEF_LCDC|IEF_VBLANK
	ld  [rIE], a

; Set STAT to MODE00 which means the STAT interrupt happens after drawing every line.
	ld  a, STATF_MODE00
	ld  [rSTAT], a

; Set up some variables used by the interrupts
    ld  a, 50
	ld  [effect1_XOffset], a
    ld  a, 0
	ld  [effect1_Finished], a

; Go for it
	ei
	
; An infinite loop to spin while the interrupts happen.
.wait
	halt
	nop 

    ld  a, [effect1_Finished]
    or  a
	jr	z, .wait
    ret

effect1_VBlank:
    ld  hl, effect1_XOffset
	dec [hl]

    ; Check for an A press
	call joypad
	bit  JOY_A, a
	jr z, .done
	
    ; A was pressed: set the finish flag
    ld  a, 1
	ld  [effect1_Finished], a

.done
	ret

; This splits the screen into alternating sets of 8 lines
; Even sets get x = LY, meaning there is a 45 degree slant.
; Odd sets get x = -LY meaning there is a slant the other way.
effect1_HBlank:
    ld  a, [effect1_XOffset]
    ld  d, a         ; d := current X offset
	ld  a, [rLY]     
	inc a            ; LY is off by one. I think this is because LY is the line we just drew, not the one we're about to draw.
	ld  c, a         ; c := current LCD line number (LY)
	and %00001111
	cp  8
	ld  a, c         ; a := LY
	jr  nc, .right   ; if (LY % 16) < 8 then .left else .right
.left
	add d
	ld	[rSCX], a    ; Background x scroll := LY + XOffset
	ret
.right
	neg
	sub d
	ld	[rSCX], a   ; Background x scroll := - LY - XOffset
	ret