; ************************************
;   Macros
; ************************************
int_SetCallbackFunc: MACRO
	ld hl, \1
	ld bc, \2
	ld a, c
	ld [hl+], a
	ld [hl], b
	ENDM
