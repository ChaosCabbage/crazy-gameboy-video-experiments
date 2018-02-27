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

int_SetVBlankFunc: MACRO
    int_SetCallbackFunc int_VBlankFunc, \1
    ENDM

int_SetLCDCFunc: MACRO
    int_SetCallbackFunc int_LCDCFunc, \1
    ENDM

int_SetTimerOverflowFunc: MACRO
    int_SetCallbackFunc int_TimerOverflowFunc, \1
    ENDM

int_SetSerialFunc: MACRO
    int_SetCallbackFunc int_SerialFunc, \1
    ENDM
