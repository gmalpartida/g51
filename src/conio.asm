.include "conio.inc"
.include "constants.inc"
.include "ascii.inc"
.include "bios.inc"

.area CSEG (CODE)

ahex2byte:
	movx a, @dptr						; read upper nibble
	lcall asc2nibble
	mov b, a							; save it
	inc dptr
	movx a, @dptr						; read lower nibble
	lcall asc2nibble
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

byte2ahex:
	

	ret

puthexnibble:
	
	ret

puthexbyte:
	

	ret

get_hex_address:
	mov a, @r0
	lcall asc2nibble
	inc r0
	mov b, a
	mov a, @r0
	lcall asc2nibble
	swap a
	anl a, #0xf0
	orl a, b
	swap a
	ret

skip_blanks:
	movx a, @dptr
	jz skip_blanks_exit
	cjne a, #' ', skip_blanks_exit
	inc dptr
	sjmp skip_blanks
skip_blanks_exit:
	ret

println:
	mov a, #CR
	lcall sys_putc
	mov a, #LF
	lcall sys_putc
	ret

; prints tab(s)
printtab:
	mov a, #TAB
	lcall sys_putc
	ret

; prints space(s)
printspc:
	mov a, #' '
	lcall sys_putc
	ret

