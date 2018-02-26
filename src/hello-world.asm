
INCLUDE "gbhardware.inc" ; standard hardware definitions from devrs.com
INCLUDE "ibmpc1.inc" ; ASCII character set from devrs.com

lcd_WaitVBlank: MACRO
	ld      a,[rLY]
	cp      145           ; Is display on scan line 145 yet?
	jr      nz,@-4        ; no, keep waiting
	ENDM

SECTION	"Vblank",ROM0[$0040]
	call VBlankSlant
	reti
SECTION	"LCDC",ROM0[$0048]
	call HBlankSlant
	reti
SECTION	"Timer_Overflow",ROM0[$0050]
	reti
SECTION	"Serial",ROM0[$0058]
	reti
SECTION	"p1thru4",ROM0[$0060]
	reti

; ROM location $0100 is also the code execution starting point
SECTION	"start",ROM0[$0100]
    nop
    jp	begin

; ROM header
	ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

; ****************************************************************************************
begin:
	di                  ; disable interrupts
	ld	sp, $ffff		; set the stack pointer to highest mem location we can use + 1

init:
	ld	a, %11100100 	; Set window palette colors, from darkest to lightest
	ld	[rBGP], a		

	ld	a, 0			; Set the background scroll to (0,0)
	ld	[rSCX], a
	ld	[rSCY], a

; Next we shall turn the LCD off so that we can safely copy data to video RAM. 

	call	StopLCD		
	
	ld	hl, TileData
	ld	de, _VRAM		
	ld	bc, 8*256 		; the ASCII character set: 256 characters, each with 8 bytes of display data
	call	mem_CopyMono	; load tile data
	
; Turn the LCD back on. 
; Parameters are explained in the I/O registers section of The GameBoy reference under I/O register LCDC
	ld	a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJOFF 
	ld	[rLCDC], a	
	
; Clear the background to all white by setting every tile to whitespace.

	ld	a, 186		; ASCII FOR BLANK SPACE
	ld	hl, _SCRN0
	ld	bc, SCRN_VX_B * SCRN_VY_B
	call	mem_SetVRAM

	
; ****************************************************************************************
; Main code:
; Print a character string in the middle of the screen
; ****************************************************************************************
; Now we need to paint the message
; " Hello World !" onto our 'canvas'. We do this with
; one final memory copy routine call.

	ld	hl, Title
	ld	de, _SCRN0 + 3 + (SCRN_VY_B*7) ; 
	ld	bc, TitleEnd-Title
	call	mem_CopyVRAM

	ld	hl, Title
	ld	de, _SCRN0 + 3 + (SCRN_VY_B*11) ; 
	ld	bc, TitleEnd-Title
	call	mem_CopyVRAM

; Enable the vblank and stat interrupts to try some video effects
	ld  a, IEF_LCDC|IEF_VBLANK
	ld  [rIE], a
	ld  a, STATF_MODE00
	ld  [rSTAT], a
	ld  d, 50
	ld  c, 0
	ei
	
; ****************************************************************************************
; Prologue
; Wait patiently 'til somebody kills you
; ****************************************************************************************
; Since we have accomplished our goal, we now have nothing
; else to do. As a result, we just Jump to a label that
; causes an infinite loop condition to occur.
;
; We are still waiting for 
wait:
	halt
	nop 
	jr	wait

VBlankSlant:
	inc d
	ld	a,d
	ld	[rSCX], a
	ld  c, 0
	ret

HBlankSlant:
	inc c        ; c++
	ld  a, c     
	and %00001111
	ld  c, a     ; c = c % 16
	cp  8
	ld  a, [rLY]
	jr  nc, .right ; if c <= 8 then .left else .right
.left
	add d
	ld	[rSCX], a 
	;ld	[rSCY], a 
	ret
.right
	ld  b, a
	xor a
	sub b
	sub d
;	ld	[rSCX], a 
	ld	[rSCY], a 
	ret
	
; ****************************************************************************************
; StopLCD:
; turn off LCD if it is on
; and wait until the LCD is off
; ****************************************************************************************
StopLCD:
	ld  a,[rLCDC]
	rlca                    ; Put the high bit of LCDC into the Carry flag
	ret  nc                 ; Screen is off already. Exit.
	lcd_WaitVBlank
; Turn off the LCD
	ld      a,[rLCDC]
	res     7,a             ; Reset bit 7 of LCDC
	ld      [rLCDC],a

	ret

; ****************************************************************************************
; hard-coded data
; ****************************************************************************************
Title:
	DB	"Scroll, mofo."
TitleEnd:
    nop

TileData:
    chr_IBMPC1  1,8 ; LOAD ENTIRE CHARACTER SET