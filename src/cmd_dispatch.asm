.include "cmd_dispatch.inc"
.include "string.inc"
.include "commands.inc"
.include "bios.inc"
.include "conio.inc"

.area CSEG (CODE)

; executes handler for command if found, otherwise executes invalid command handler
; --> dptr			address of command string to find
; <-- None
cmd_dispatch_exec:
	mov R7, dph						; save address of command
	mov R6, dpl
	lcall cmd_dispatch_find		; find it in command table
	inc dptr						; dptr contains address of entry of command or entry of invalid command
	inc dptr						; advance 3 bytes to address of handler
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
	movx a, @dptr					; read command id
	cjne a, #0xff, cdpt_continue
	sjmp cdpt_exit
cdpt_continue:
	

cdpt_exit:
	ret

cmd_dispatch_help:		.asciz			"help"
cmd_dispatch_peek:		.asciz			"peek"
cmd_dispatch_poke:		.asciz			"poke"
cmd_dispatch_reset:		.asciz			"reset"
cmd_dispatch_clear:		.asciz			"clear"
cmd_dispatch_dump:		.asciz			"dump"
cmd_dispatch_load:		.asciz			"load"
cmd_dispatch_ls:		.asciz			"ls"
cmd_dispatch_fill:		.asciz			"fill"
cmd_dispatch_copy:		.asciz			"copy"
cmd_dispatch_goto:		.asciz			"goto"
cmd_dispatch_iram:		.asciz			"iram"
cmd_dispatch_sfr:		.asciz			"sfr"
cmd_dispatch_write:		.asciz			"write"
cmd_dispatch_test_rand:	.asciz			"test_rand"
cmd_dispatch_test_goto:	.asciz			"test_goto"

cmd_dispatch_table:
	.db			#0x00
	.dw			cmd_dispatch_help
	.dw			do_help	

	.db			#0x01
	.dw			cmd_dispatch_peek
	.dw			do_peek	

	.db			#0x02
	.dw			cmd_dispatch_poke
	.dw			do_poke

	.db			#0x03
	.dw			cmd_dispatch_reset
	.dw			do_reset

	.db			#0x04
	.dw			cmd_dispatch_clear
	.dw			do_clear

	.db			#0x05
	.dw			cmd_dispatch_dump
	.dw			do_dump

	.db			#0x06
	.dw			cmd_dispatch_load
	.dw			do_load

	.db			#0x07
	.dw			cmd_dispatch_ls
	.dw			do_ls

	.db			#0x08
	.dw			cmd_dispatch_fill
	.dw			do_fill

	.db			#0x09
	.dw			cmd_dispatch_copy
	.dw			do_copy

	.db			#0x0a
	.dw			cmd_dispatch_goto
	.dw			do_goto

	.db			#0x0b
	.dw			cmd_dispatch_iram
	.dw			do_iram
	
	.db			#0x0c
	.dw			cmd_dispatch_sfr
	.dw			do_sfr

	.db			#0x0d
	.dw			cmd_dispatch_write
	.dw			do_write

	.db			#0x0e
	.dw			cmd_dispatch_test_rand
	.dw			do_test_rand

	.db			#0x0f
	.dw			cmd_dispatch_test_goto
	.dw			do_test_goto

	.db			#0xff
	.dw			#0x00
	.dw			do_invalid

