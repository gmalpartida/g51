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

msg_err:    
	.asciz "Invalid Command"

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

mem_types:
iram_str:	.asciz		"iram"
sfr_str:	.asciz		"sfr"
rom_str:	.asciz		"rom"
xram_str:	.asciz		"xram"


