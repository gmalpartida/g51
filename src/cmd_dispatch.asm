.include "cmd_dispatch.inc"
.include "string.inc"
.include "commands.inc"
.include "bios.inc"
.include "conio.inc"
.include "ascii.inc"

.area CSEG (CODE)

; executes handler for command if found, otherwise executes invalid command handler
; --> dptr			address of command string to find
; <-- None
cmd_dispatch_exec:
	mov R7, dph						; save address of command
	mov R6, dpl
	lcall cmd_dispatch_find			; find it in command table
	inc dptr						; dptr contains address of entry of command or entry of invalid command
	inc dptr						; advance 5 bytes to address of handler
	inc dptr
	inc dptr
	inc dptr

	clr a
	movc a, @a + dptr
	mov R1, a
	mov a, #0x01
	movc a, @a + dptr
	push a							; push low byte first
	push 0x01						; push R1, high byte next
	ret								; dispatch command

	ret

; finds the entry for the specified command
; --> R7:R6		address of command to find
; <-- dptr		address of entry for found command, otherwise address of unknow command entry
; <-- C			set if found, otherwise clear
cmd_dispatch_find:
	mov dptr, #cmd_dispatch_table
cmd_dispatch_find_loop:
	clr a
	movc a, @a + dptr					; get id of command
	xrl a, #0xff						; compare to ff which is id of invalid command handler
	jz cmd_dispatch_find_exit			; dptr points to invalid cmd entry, exit
	mov R1, dph							; save start of entry in table
	mov R0, dpl
	inc dptr							; points to command name in table
	mov a, R7							; save address, strcmp will destroy it
	mov R3, a
	mov a, R6
	mov R2, a
	clr a								; get address of command name entry
	movc a, @a + dptr
	mov R5, a							; get higher byte
	mov a, #0x01
	movc a, @a + dptr					; get lower byte
	mov dpl, a
	mov dph, R5
	lcall strcmp						; compare to command we are looking for
	mov a, R3							; restore R7:R6
	mov R7, a
	mov a, R2
	mov R6, a
	jc cmd_dispatch_find_match			; match found
	mov dph, R1							; restore start of entry address
	mov dpl, R0
	inc dptr							; move forward to next entry
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr
	sjmp cmd_dispatch_find_loop			; repeat
cmd_dispatch_find_match:
	setb c
	mov dph, R1							; restore address of entry, C is already set
	mov dpl, R0
	ret
cmd_dispatch_find_exit:
	clr c								; command not found, set C.  dptr points to unknown cmd entry
	ret

cmd_dispatch_print_table:
	mov dptr, #cmd_dispatch_table
cdpt_loop:
	clr a
	movc a, @a + dptr					; read command id
	cjne a, #0xff, cdpt_continue
	sjmp cdpt_exit
cdpt_continue:
	lcall byte2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc
	lcall printtab

	inc dptr
	clr a
	movc a, @a + dptr
	xch a, b
	inc dptr
	clr a
	movc a, @a + dptr
	push dpl
	push dph

	mov dph, b
	mov dpl, a
	
	lcall sys_puts
	lcall println
	pop dph
	pop dpl

	inc dptr
	inc dptr
	inc dptr
	inc dptr
	inc dptr

	sjmp cdpt_loop

cdpt_exit:
	ret

cmd_help:		.asciz			"help"
cmd_peek:		.asciz			"peek"
cmd_poke:		.asciz			"poke"
cmd_reset:		.asciz			"reset"
cmd_clear:		.asciz			"clear"
cmd_dump:		.asciz			"dump"
cmd_load:		.asciz			"load"
cmd_ls:		.asciz			"ls"
cmd_fill:		.asciz			"fill"
cmd_copy:		.asciz			"copy"
cmd_goto:		.asciz			"goto"
cmd_iram:		.asciz			"iram"
cmd_sfr:		.asciz			"sfr"
cmd_write:		.asciz			"write"
cmd_test_rand:	.asciz			"test_rand"
cmd_test_goto:	.asciz			"test_goto"

	help_cmd_descr:		.asciz	"displays list of available commands."
	ls_cmd_descr:		.asciz	"displays available applications."
	peek_cmd_descr:		.asciz	"examines memory ( iram, rom, xram, sfr )."
	poke_cmd_descr:		.asciz	"modifies memory ( iram, xram, sfr )."
	dump_cmd_descr:		.asciz	"displays a 256 memory block."
	clear_cmd_descr:	.asciz	"clear screen and homes the cursor."
	reset_cmd_descr:	.asciz	"perform a soft-reset of the system."
	fill_cmd_descr:		.asciz	"initializes a memory block with a specific byte."
	copy_cmd_descr:		.asciz	"copies a block of data from one memory location to another."
	goto_cmd_descr:		.asciz	"jumps to a location in program memory to execute code."
	iram_cmd_descr:		.asciz	"displays the contents of the internal memory area."
	sfr_cmd_descr:		.asciz	"displays the special function registers."
	write_cmd_descr:	.asciz	"modify an sfr register."
	load_cmd_descr:		.asciz	"loads a hex file into xram."
	test_cmd_descr:		.asciz	"test a function."

cmd_dispatch_table:
	.db			#0x00
	.dw			cmd_help
	.dw			help_cmd_descr
	.dw			do_help	

	.db			#0x01
	.dw			cmd_peek
	.dw			peek_cmd_descr
	.dw			do_peek	

	.db			#0x02
	.dw			cmd_poke
	.dw			poke_cmd_descr
	.dw			do_poke

	.db			#0x03
	.dw			cmd_reset
	.dw			reset_cmd_descr
	.dw			do_reset

	.db			#0x04
	.dw			cmd_clear
	.dw			clear_cmd_descr
	.dw			do_clear

	.db			#0x06
	.dw			cmd_load
	.dw			load_cmd_descr
	.dw			do_load

	.db			#0x07
	.dw			cmd_ls
	.dw			ls_cmd_descr
	.dw			do_ls

	.db			#0x08
	.dw			cmd_fill
	.dw			fill_cmd_descr
	.dw			do_fill

	.db			#0x09
	.dw			cmd_copy
	.dw			copy_cmd_descr
	.dw			do_copy

	.db			#0x0a
	.dw			cmd_goto
	.dw			goto_cmd_descr
	.dw			do_goto

	.db			#0x0d
	.dw			cmd_write
	.dw			write_cmd_descr
	.dw			do_write

	.db			#0x0e
	.dw			cmd_test_rand
	.dw			test_cmd_descr
	.dw			do_test_rand

	.db			#0xff
	.dw			#0x00
	.dw			#0x00
	.dw			do_invalid

