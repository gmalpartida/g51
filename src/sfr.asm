.include "sfr.inc"
.include "bios.inc"
.include "conio.inc"
.include "ascii.inc"
.include "string.inc"
.include "cmd_dispatch.inc"
.include "constants.inc"

.area CSEG (CODE)

find_sfr:
	mov r6, dpl
	mov r7, dph
	mov dptr, #sfr_table
find_sfr_loop:
	push dpl
	push dph
	clr a
	movc a, @a + dptr
	jz find_sfr_no_match
	inc dptr					; skip address field
	clr a
	movc a, @a + dptr
	xch a, b
	inc dptr
	clr a
	movc a, @a + dptr
	mov dph, b
	mov dpl, a
	push 0x06					; save r7:r6, strcmp will overwrite them
	push 0x07
	lcall strcmp
	pop 0x07
	pop 0x06
	jc find_sfr_match
	pop dph						; restore address of start of record
	pop dpl
	inc dptr					; advance to start of next record
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	sjmp find_sfr_loop
find_sfr_match:
	setb c
	sjmp find_sfr_exit
find_sfr_no_match:
	clr c
find_sfr_exit:
	pop dph
	pop dpl
	ret

print_sfr_table:
	mov dptr, #sfr_table_header
	lcall sys_puts
	lcall println
	mov dptr, #sfr_table
print_sfr_table_loop:
	clr a
	movc a, @a + dptr
	mov r0, a
	inc dptr
	clr a
	movc a, @a + dptr			; sfr name
	xch a, b
	inc dptr
	clr a
	movc a, @a + dptr
	push a
	orl a, b					; last entry both bytes are 0
	jz print_sfr_table_exit
	pop a

	push dpl
	push dph
	mov dpl, a							; print sfr name
	mov dph, b
	lcall sys_puts
	lcall printtab
	mov a, r0
	lcall byte2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc
	lcall printtab

	pop dph
	pop dpl
	inc dptr							; advance to read sfr code
	push dpl
	push dph
	lcall read_sfr						; read sfr content
	lcall byte2ahex						; print it
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc
	pop dph
	pop dpl

	lcall println
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	sjmp print_sfr_table_loop
	
print_sfr_table_exit:
	pop a
	ret

read_sfr:
	clr a
	jmp @a + dptr

write_sfr:
	push a							; push param to stack
	lcall find_sfr
	jnc write_sfr_err
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	pop 0xf0						; pop param into b
	lcall read_sfr
	setb c
	sjmp write_sfr_exit
write_sfr_err:
	pop a
	clr c
write_sfr_exit:
	ret

p0_sfr: 	.asciz	"p0"
sp_sfr: 	.asciz	"sp"
dpl_sfr:	.asciz	"dpl"
dph_sfr:	.asciz	"dph"
pcon_sfr:	.asciz	"pcon"
tcon_sfr:	.asciz	"tcon"
tmod_sfr:	.asciz	"tmod"
tl0_sfr:	.asciz	"tl0"
tl1_sfr:	.asciz	"tl1"
th0_sfr:	.asciz	"th0"
th1_sfr:	.asciz	"th1"
p1_sfr:		.asciz	"p1"
scon_sfr:	.asciz	"scon"
sbuf_sfr:	.asciz	"sbuf"
p2_sfr:		.asciz	"p2"
ie_sfr:		.asciz	"ie"
p3_sfr:		.asciz	"p3"
ip_sfr:		.asciz	"ip"
psw_sfr:	.asciz	"psw"
acc_sfr:	.asciz	"acc"
b_sfr:		.asciz	"b"

sfr_table_header:
	.ascii	"SFR"
	.db		#TAB
	.ascii	"ADDR"
	.db		#TAB
	.ascii "VALUE"
	.db		#NULL

sfr_table:
	.db		0x80
	.dw		p0_sfr		
	mov a, p0 
	ret
	mov p0, b
	ret
	.db		0x81
	.dw		sp_sfr
	mov a, sp
	ret
	mov sp, b
	ret
	.db		0x82
	.dw		dpl_sfr
	mov a, dpl
	ret
	mov dpl, b
	ret
	.db		0x83
	.dw		dph_sfr
	mov a, dph
	ret
	mov dph, b
	ret
	.db		0x87
	.dw		pcon_sfr
	mov a, pcon
	ret
	mov pcon, b
	ret
	.db		0x88
	.dw		tcon_sfr
	mov a, tcon
	ret
	mov tcon, b
	ret
	.db		0x89
	.dw		tmod_sfr
	mov a, tmod
	ret
	mov tmod, b
	ret
	.db		0x8a
	.dw		tl0_sfr
	mov a, tl0
	ret
	mov tl0, b
	ret
	.db		0x8b
	.dw		tl1_sfr
	mov a, tl1
	ret
	mov tl1, b
	ret
	.db		0x8c
	.dw		th0_sfr
	mov a, th0
	ret
	mov th0, b
	ret
	.db		0x8d
	.dw		th1_sfr
	mov a, th1
	ret
	mov th1, b
	ret
	.db		0x90
	.dw		p1_sfr
	mov a, p1
	ret
	mov p1, b
	ret
	.db		0x98
	.dw		scon_sfr
	mov a, scon
	ret
	mov scon, b
	ret
	.db		0x99
	.dw		sbuf_sfr
	mov a, sbuf
	ret
	mov sbuf, b
	ret
	.db		0xa0
	.dw		p2_sfr
	mov a, p2
	ret
	mov p2, b
	ret
	.db		0xa8
	.dw		ie_sfr
	mov a, ie
	ret
	mov ie, b
	ret
	.db		0xb0
	.dw		p3_sfr
	mov a, p3
	ret
	mov p3, b
	ret
	.db		0xb8
	.dw		ip_sfr
	mov a, ip
	ret
	mov ip, b
	ret
	.db		0xd0
	.dw		psw_sfr
	mov a, psw
	ret
	mov psw, b
	ret
	.db		0xe0
	.dw		acc_sfr
	mov a, acc
	ret
	mov acc, b
	ret
	.db		0xf0
	.dw		b_sfr
	mov a, b
	ret
	mov b, b
	ret
	.db		0x00
	.dw		0x0000						; end marker

