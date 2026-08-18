.include "ascii.inc"

.area CSEG (CODE)

ahex2byte:
	movx a, @dptr						; read upper nibble
	lcall ahex2nibble
	mov b, a							; save it
	inc dptr
	movx a, @dptr						; read lower nibble
	lcall ahex2nibble
	swap a								
	anl a, #0xf0						; clear lower nibble
	orl a, b							; merge both nibbles
	swap a								
	ret

ahex2word:
	lcall ahex2byte
	push a								; store upper byte in stack
	inc dptr
	lcall ahex2byte
	pop 0xf0							; pop upper byte onto b
	ret									; return b:a

; =============================================================================
; Function: nibble2asc
; Input:  A = Binary value to be converted (0x00 - 0x0F)
; Output: A = Lowercase ASCII character ('0'-'9', 'a'-'f')
; =============================================================================
nibble2ahex:
    ; Compare A to 10. 
    ; If A < 10, the Carry Flag (C) is automatically SET.
    ; If A >= 10, the Carry Flag (C) is CLEARED.
    cjne a, #10, check_range
check_range:
    jc nibble2ahex_is_digit      ; If Carry is 1 (A < 10), it's a digit!

    ; It's a letter ('a'-'f')
    add a, #0x37                ; Convert to ascii
	orl a, #0b00100000
    ret

nibble2ahex_is_digit:
    add a, #0x30                ; Convert to '0'-'9'
    ret

byte2ahex:
	mov b, a					; make a copy of a
	swap a						; move upper nibble to lower nibble
	anl a, #0x0f					; zero out upper nibble
	lcall nibble2ahex			; convert to ascii
	xch a, b					; b contains ascii of upper nibble, a contains lower nibble
	anl a, #0x0f					; zero out upper nibble
	lcall nibble2ahex
	ret							; return b:a

; converts a hex value to ascii
; --> a: hex value
; <-- b: ascii equivalent of upper nibble
; <-- a: ascii equivalent of lower nibble
hex2ahex:
	mov r7, a
	swap a
	anl a, #0x0f
	lcall nibble2ahex
	mov b, a
	mov a, r7
	anl a, #0x0f
	lcall nibble2ahex
	ret

asc2byte:
	xch a, b						; mov high byte to a					
	lcall ahex2nibble				; convert to binary
	swap a							; swap nibbles, binary value is in upper nibble
	xch a, b						; mov low byte to a
	lcall ahex2nibble				; convert to binary
	orl a, b						; combine high nibble and low nibble
	ret

; =============================================================================
; Function: asc2nibble
; Input:  Accumulator (A) = Lowercase ASCII character ('0'-'9', 'a'-'f')
; Output: Accumulator (A) = Binary value (00h-0Fh)
; Uses:   No stack, no external registers.
; =============================================================================
ahex2nibble:
    clr c
    subb a, #0x30       ; Subtract 30h ('0' becomes 0, 'a' becomes 31h)
    
    ; Compare intermediate result with 10
    cjne a, #10, check_alpha
check_alpha:
    jc ahex2nibble_done  ; If A < 10, it is a digit '0'-'9'. Exit!

    ; If we got here, it's a lowercase letter 'a'-'f' (sitting at 31h-36h)
    clr c
	orl a, #0b00100000	; convert to lowercase
    subb a, #0x27       ; Subtract 27h to bridge the gap (31h - 27h = 0Ah)

ahex2nibble_done:
    ret

valid_ahex:
	
valid_ahex_loop:
	movx a, @dptr
	jz valid_ahex_exit
	clr c
	subb a, #0x30							
	cjne a, #10, valid_ahex_check_alpha		; i
valid_ahex_check_alpha:
	jc valid_ahex_exit
	clr c
	orl a, #0b00100000
	subb a, #0x27

	inc dptr
	sjmp valid_ahex_loop
valid_ahex_exit:

	ret




