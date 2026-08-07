.include "conio.inc"
.include "constants.inc"
.include "ascii.inc"
.include "bios.inc"

.area CSEG (CODE)

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

print_hex_byte:
	lcall byte2ahex
	xch a, b							; print high nibble first
	lcall sys_putc
	xch a, b
	lcall sys_putc						; print low nibble
	ret

print_hex_word:
	push a								; save low byte
	xch a, b							; print high byte first
	lcall print_hex_byte
	pop a								; retreive low byte
	lcall print_hex_byte				; print low byte
	ret

print_hex_mem:
	mov r0, a	
	mov r1, dpl
	mov r2, dph
phm_loop:
	
	movx a, @dptr
	lcall print_hex_byte
	lcall printspc
	djnz r0, phm_loop

	mov dpl, r1
	mov dph, r2
	ret


