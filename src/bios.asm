.include "bios.inc"
.include "uart.inc"
.include "vt102.inc"
.include "math.inc"

.area CSEG (CODE)

bios_jmp_table:
sys_putc:		ljmp uart_tx_char
sys_getc:		ljmp uart_rx_char
sys_puts:		ljmp uart_tx_asciz
sys_gets:		ljmp uart_rx_asciz
sys_puts_xram:	ljmp uart_tx_asciz_xram	
sys_serial_isr:	ljmp uart_rx_isr
sys_clrscrn:	ljmp vt102_clear_screen
sys_rand:		ljmp rand

sys_init:
	lcall sys_rand
	lcall uart_init
	ret

sys_reset:
	ljmp 0xfffc
	ret
