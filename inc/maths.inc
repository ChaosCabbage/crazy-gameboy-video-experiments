; Negate the A register.
; This is a Z80 instruction but doesn't appear on the GameBoy processor.
; 2's complement: invert all bits then add 1.
neg: MACRO
	cpl
	inc a 
	ENDM
