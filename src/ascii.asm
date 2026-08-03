.include "ascii.inc"

.area CSEG (CODE)

; =============================================================================
; Function: nibble2asc
; Input:  A = Binary value to be converted (0x00 - 0x0F)
; Output: A = Lowercase ASCII character ('0'-'9', 'a'-'f')
; =============================================================================
nibble2asc:
    ; Compare A to 10. 
    ; If A < 10, the Carry Flag (C) is automatically SET.
    ; If A >= 10, the Carry Flag (C) is CLEARED.
    cjne a, #10, check_range
check_range:
    jc nibble2asc_is_digit      ; If Carry is 1 (A < 10), it's a digit!

    ; It's a letter ('a'-'f')
    add a, #0x37                ; Convert to ascii
	orl a, #0b00100000
    ret

nibble2asc_is_digit:
    add a, #0x30                ; Convert to '0'-'9'
    ret

byte2asc:
	mov b, a					; make a copy of a
	swap a						; move upper nibble to lower nibble
	anl a, #0x0f					; zero out upper nibble
	lcall nibble2asc			; convert to ascii
	xch a, b					; b contains ascii of upper nibble, a contains lower nibble
	anl a, #0x0f					; zero out upper nibble
	lcall nibble2asc
	ret							; return b:a

; converts a hex value to ascii
; --> a: hex value
; <-- b: ascii equivalent of upper nibble
; <-- a: ascii equivalent of lower nibble
hex2asc:
	mov r7, a
	swap a
	anl a, #0x0f
	lcall nibble2asc
	mov b, a
	mov a, r7
	anl a, #0x0f
	lcall nibble2asc
	ret

asc2byte:
	xch a, b						; mov high byte to a					
	lcall asc2nibble				; convert to binary
	swap a							; swap nibbles, binary value is in upper nibble
	xch a, b						; mov low byte to a
	lcall asc2nibble				; convert to binary
	orl a, b						; combine high nibble and low nibble
	ret
; =============================================================================
; Function: asc2nibble
; Input:  Accumulator (A) = Lowercase ASCII character ('0'-'9', 'a'-'f')
; Output: Accumulator (A) = Binary value (00h-0Fh)
; Uses:   No stack, no external registers.
; =============================================================================
asc2nibble:
    clr c
    subb a, #0x30       ; Subtract 30h ('0' becomes 0, 'a' becomes 31h)
    
    ; Compare intermediate result with 10
    cjne a, #10, check_alpha
check_alpha:
    jc asc2nibble_done  ; If A < 10, it is a digit '0'-'9'. Exit!

    ; If we got here, it's a lowercase letter 'a'-'f' (sitting at 31h-36h)
    clr c
	orl a, #0b00100000	; convert to lowercase
    subb a, #0x27       ; Subtract 27h to bridge the gap (31h - 27h = 0Ah)

asc2nibble_done:
    ret

