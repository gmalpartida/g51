.ifndef VT102_INC
.define VT102_INC

VT102_ESC			.equ		0x1b

.globl vt102_clear_screen

; draws a line from the current position to a destination
; --> r7: row of end of line
; --> r6: col of end of line
.globl vt102_line_to

.globl vt102_send_bs

.globl vt102_send_spc

.globl vt102_handle_BS

.endif
