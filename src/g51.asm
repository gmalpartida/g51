.include "bios.inc"
.include "constants.inc"
.include "conio.inc"
.include "commands.inc"
.include "string.inc"
.include "logo.inc"
.include "cmd_dispatch.inc"
.include "cmd_line_parser.inc"

.area VECTORS (CODE)

    ljmp main
ie0_isr:
	reti
	.blkb	0x07
tf0_isr:
	reti
	.blkb	0x07
ie1_isr:
	reti
	.blkb	0x07
tf1_isr:
	reti
	.blkb	0x07
ser_isr:
	ljmp sys_serial_isr

.area CSEG (CODE)

main:
    mov sp, #0x2f					; Initialize Stack
    lcall sys_init					; Setup system

	setb es							; enable serial interrupt
	setb ea							; enable global interrupt

	lcall sys_clrscrn

	mov dptr, #g51_logo
	lcall sys_puts

	lcall println

	mov dptr, #title_str
	lcall sys_puts
	lcall println

	mov a, #0xff
	mov dptr, #cmd
	movx @dptr, a
	inc dptr
	movx @dptr, a

cmd_prompt:

    mov dptr, #command_prompt_str
    lcall sys_puts
    
	lcall cmd_line_parser_load

	mov dptr, #cmd
	lcall cmd_line_parser_next_token

	mov dptr, #cmd
	lcall cmd_dispatcher_exec

	lcall println

	sjmp cmd_prompt

.area XSEG (XDATA)
cmd:						.ds				0x10

