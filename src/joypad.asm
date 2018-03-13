INCLUDE "gbhardware.inc" 

SECTION "Joypad", ROM0

; Get Keypad Button Status
; The following bits are set if pressed:
;   0x08 - Start    0x80 - Down
;   0x04 - Select   0x40 - Up
;   0x02 - B	    0x20 - Left
;   0x01 - A	    0x10 - Right
;
; Routine pretty much stolen from gbdk :)
;
joypad::
    push bc

    ld a, P1F_5
    ldh [rP1_LOW], a  ; Set the joypad to listen for direction presses

    ; Read from the joypad a few times.
    ; Something to do with letting the inputs stabilize.
	ldh	a, [rP1_LOW]
    ldh	a, [rP1_LOW]

    ; We now have the state of Down, Up, Left, and Right
    ; Bits are set to 0 if the corresponding button is pressed, so invert.
	cpl
	and	$0F ; Only the last 4 bits are relevant.

	swap a ; Store these 4 buttons in the top half.
	ld  b,a ; and copy to register B

	ld  a, P1F_4 
	ldh [rP1_LOW], a ; Set the joypad to listen for button presses
	ldh	a, [rP1_LOW]
    ldh	a, [rP1_LOW]
    
	cpl
	and	$0F
	or  b ; Combine with the previous result so now we have all the buttons

	ld  b, a

	ld	a, P1F_4 | P1F_5
	ldh a, [rP1_LOW] ; Turn off P14 and P15 (reset joypad)

	ld  a, b

	pop bc	; Restore registers

    ret
