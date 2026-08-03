.include "constants.inc"
.include "apps.inc"
.include "bios.inc"
.include "ascii.inc"
.include "conio.inc"

.area CSEG (CODE)

title_str: 
	.db TAB, TAB, TAB
	.ascii	"Copyright 2025 Gino Malpartida"
	.db CR, LF, 0

newline_str:	
	.db CR, LF,0
command_prompt_str: 
	.asciz "g51> "

commands:
	help_cmd:			.asciz	"help"
	help_cmd_descr:		.asciz	"displays list of available commands."
	ls_cmd:				.asciz	"ls"
	ls_cmd_descr:		.asciz	"displays available applications."
	peek_cmd:			.asciz	"peek"
	peek_cmd_descr:		.asciz	"examine a single memory cell."
	peek_cmd_ex:		.asciz	"ex. peek 1b2c"
	poke_cmd:			.asciz	"poke"
	poke_cmd_descr:		.asciz	"modify a single memory cell."
	poke_cmd_ex:		.asciz	"ex. poke 1b2c 55"
	dump_cmd:			.asciz	"dump"
	dump_cmd_descr:		.asciz	"displays a 256 memory block."
	dump_cmd_ex:		.asciz	"ex. dump 12"
	clear_cmd:			.asciz	"clear"
	clear_cmd_descr:	.asciz	"clear screen and homes the cursor."
	reset_cmd:			.asciz	"reset"
	reset_cmd_descr:	.asciz	"perform a soft-reset of the system."
	fill_cmd:			.asciz	"fill"
	fill_cmd_descr:		.asciz	"initializes a memory block with a specific byte."
	fill_cmd_ex:		.asciz	"ex. fill 1ab7 ff 1a"
	copy_cmd:			.asciz	"copy"
	copy_cmd_descr:		.asciz	"copies a block of data from one memory location to another."
	copy_cmd_ex:		.asciz	"ex. copy 2d4f 83bd a5"
	goto_cmd:			.asciz	"goto"
	goto_cmd_descr:		.asciz	"jumps to a location in program memory to execute code."
	goto_cmd_ex:		.asciz	"ex. goto 8ae3"
	iram_cmd:			.asciz	"iram"
	iram_cmd_descr:		.asciz	"displays the contents of the internal memory area."
	sfr_cmd:			.asciz	"sfr"
	sfr_cmd_descr:		.asciz	"displays the special function registers."
	write_cmd:			.asciz	"write"
	write_cmd_descr:	.asciz	"modify an sfr register,"
	write_cmd_ex:		.asciz	"ex. write p1 55"

help_table:
	.dw		help_cmd, help_cmd_descr
	.dw		ls_cmd, ls_cmd_descr
	.dw		peek_cmd, peek_cmd_descr
	.dw		poke_cmd, poke_cmd_descr
	.dw		dump_cmd, dump_cmd_descr
	.dw		clear_cmd, clear_cmd_descr
	.dw		reset_cmd, reset_cmd_descr
	.dw		fill_cmd, fill_cmd_descr
	.dw		copy_cmd, copy_cmd_descr
	.dw		goto_cmd, goto_cmd_descr
	.dw		iram_cmd, iram_cmd_descr
	.dw		sfr_cmd, sfr_cmd_descr
	.dw		write_cmd, write_cmd_descr
	.dw		0, 0	

help_txt:	
	.asciz	"help"
ls_txt:		
	.asciz	"ls"
peek_txt:	
	.asciz	"peek"
poke_txt:	
	.asciz	"poke"
dump_txt:	
	.asciz	"dump"
clear_txt:	
	.asciz	"clear"
reset_txt:
	.asciz "reset"
fill_txt:
	.asciz "fill"
copy_txt:
	.asciz "copy"
goto_txt:
	.asciz "goto"
iram_txt:
	.asciz "iram"
sfr_txt:
	.asciz "sfr"
write_txt:
	.asciz "write"

msg_err:    
	.asciz "Invalid Command"

a_short_text:
	.asciz "The quick brown fox jumps over the lazy dog."

mem_test_fail_msg:
	.asciz "Memory test failed."

mem_test_success_msg:
	.asciz "Memory test succeeded."

lcd_app_name:
	.asciz "lcd"

lcd_app_descr:
	.asciz "Allows testing of the lcd screen in P1, P3"

pwm_app_name:
	.asciz "pwm"

pwm_app_descr:
	.asciz "Allows testing of the pwm application."

vt102_app_name:
	.asciz "vt102"

vt102_app_descr:
	.asciz "Allows testing the VT102 escape sequences."

app_table:
	.dw lcd_app_name, lcd_app_descr, lcd_app
	.dw pwm_app_name, pwm_app_descr, pwm_app
	.dw vt102_app_name, vt102_app_descr, vt102_app
	.dw 0, 0, 0									; end of table

