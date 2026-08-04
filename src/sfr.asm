.include "sfr.inc"
.include "bios.inc"
.include "conio.inc"
.include "ascii.inc"

.area CSEG (CODE)

print_sfr_table:
	mov dptr, #sfr_table
print_sfr_table_loop:
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
	sjmp print_sfr_table_loop
	
print_sfr_table_exit:
	pop a
	ret

read_sfr:
	clr a
	jmp @a + dptr

	;ret									; no ret needed.

p0_sfr: 	.asciz	"P0"
sp_sfr: 	.asciz	"SP"
pcon_sfr:	.asciz	"PCON"
tcon_sfr:	.asciz	"TCON"
tmod_sfr:	.asciz	"TMOD"
tl0_sfr:	.asciz	"TL0"
tl1_sfr:	.asciz	"TL1"
th0_sfr:	.asciz	"TH0"
th1_sfr:	.asciz	"TH1"
p1_sfr:		.asciz	"P1"
scon_sfr:	.asciz	"SCON"
sbuf_sfr:	.asciz	"SBUF"
p2_sfr:		.asciz	"P2"
ie_sfr:		.asciz	"IE"
p3_sfr:		.asciz	"P3"
ip_sfr:		.asciz	"IP"
psw_sfr:	.asciz	"PSW"
acc_sfr:	.asciz	"ACC"
b_sfr:		.asciz	"B"
dpl_sfr:	.asciz	"DPL"
dph_sfr:	.asciz	"DPH"

sfr_table:
	.dw		p0_sfr		
	mov a, 0x80  
	ret
	.dw		sp_sfr
	mov a, 0x81
	ret
	.dw		dpl_sfr
	mov a, 0x82
	ret
	.dw		dph_sfr
	mov a, 0x83
	ret
	.dw		pcon_sfr
	mov a, 0x87
	ret
	.dw		tcon_sfr
	mov a, 0x88
	ret
	.dw		tmod_sfr
	mov a, 0x89
	ret
	.dw		tl0_sfr
	mov a, 0x8a
	ret
	.dw		tl1_sfr
	mov a, 0x8b
	ret
	.dw		th0_sfr
	mov a, 0x8c
	ret
	.dw		th1_sfr
	mov a, 0x8d
	ret
	.dw		p1_sfr
	mov a, 0x90
	ret
	.dw		scon_sfr
	mov a, 0x98
	ret
	.dw		sbuf_sfr
	mov a, 0x99
	ret
	.dw		p2_sfr
	mov a, 0xa0
	ret
	.dw		ie_sfr
	mov a, 0xa8
	ret
	.dw		p3_sfr
	mov a, 0xb0
	ret
	.dw		ip_sfr
	mov a, 0xb8
	ret
	.dw		psw_sfr
	mov a, 0xd0
	ret
	.dw		acc_sfr
	mov a, 0xe0
	ret
	.dw		b_sfr
	mov a, 0xf0
	ret
	.dw		0x0000						; end marker

