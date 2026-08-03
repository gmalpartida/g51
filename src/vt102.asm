.include "vt102.inc"
.include "bios.inc"
.include "constants.inc"

.area CSEG (CODE);

vt102_clear_screen:
	mov dptr, #VT102_CLEAR_SCREEN
	lcall sys_puts
	ret

; draws a line from the current position to a destination
; --> r7: row of end of line
; --> r6: col of end of line
vt102_line_to:
	ret

vt102_send_bs:
	mov dptr, #VT102_BS_SEQ
	lcall sys_puts
	ret

vt102_send_spc:
	 mov dptr, #VT102_SPC
	 lcall sys_puts
	ret

vt102_handle_BS:
	mov dptr, #VT102_BS_SEQ
	lcall sys_puts
	ret

VT102_UP:			.db		VT102_ESC, '[', 'A', 0
VT102_DOWN:			.db		VT102_ESC, '[', 'B', 0
VT102_RIGHT:		.db		VT102_ESC, '[', 'C', 0
VT102_LEFT:			.db		VT102_ESC, '[', 'D', 0
VT102_CLEAR_SCREEN:	.db		VT102_ESC, '[', 'H', VT102_ESC, '[', '2', 'J', 0
VT102_BS_SEQ:		.db		#BS, #SPC, #BS, 0
VT102_SPC:			.db		VT102_ESC, #SPC, 0

