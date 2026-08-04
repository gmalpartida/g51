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

