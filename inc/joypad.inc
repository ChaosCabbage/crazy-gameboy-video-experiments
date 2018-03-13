; These can be used with the joypad routine.
;
; Example:
;   call joypad
;   bit JOY_UP, a
;   jr nz, .upWasPressed
;

JOY_A      EQU 0
JOY_B      EQU 1
JOY_SELECT EQU 2
JOY_START  EQU 3
JOY_RIGHT  EQU 4
JOY_LEFT   EQU 5
JOY_UP     EQU 6
JOY_DOWN   EQU 7

