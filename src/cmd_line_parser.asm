.include "cmd_line_parser.inc"
.include "bios.inc"
.include "conio.inc"

.area CSEG (CODE)

cmd_line_parser_load:
	mov a, #0x00
	mov dptr, #cmd_line_buffer_pos
	movx @dptr, a
	mov dptr, #cmd_line_buffer
	lcall sys_gets
	ret

cmd_line_parser_next_token:
	mov R7, dph								; save destination address for later use
	mov R6, dpl
	mov dptr, #cmd_line_buffer
	; advance to current buffer position
	lcall cmd_line_parser_set_cur_pos
	lcall cmd_line_parser_skip_blanks
	mov b, #0x00							; initialize token length counter
clp_next_char:
	movx a, @dptr							; read character from buffer
	jz clp_next_token_exit					; if NULL then exit
	cjne a, #' ', clp_next_token_process	
	sjmp clp_next_token_exit				; if SPC then exit
clp_next_token_process:
	xch a, b								; increment length of token
	inc a
	xch a, b
	push dph								; save buffer address
	push dpl
	mov dph, R7								; restore destination address
	mov dpl, R6
	movx @dptr, a							; copy character to it
	inc dptr								; increment destination address
	mov R7, dph								; save destination address
	mov R6, dpl
	pop dpl									; restore buffer address
	pop dph
	inc dptr								; increment
	sjmp clp_next_char						; go to process next character
clp_next_token_exit:
	lcall cmd_line_parser_save_cur_pos
	mov dph, R7								; write NULL to turn it into an asciz
	mov dpl, R6
	mov a, #0x00
	movx @dptr, a
	ret

cmd_line_parser_save_cur_pos:
	push dph
	push dpl

    ; Calculate: Current DPTR - Base Buffer Address = 1-byte Offset
    clr c
    mov a, dpl
    subb a, #cmd_line_buffer
    
    mov dptr, #cmd_line_buffer_pos
    movx @dptr, a

    pop dpl
    pop dph

	ret

cmd_line_parser_set_cur_pos:
	push dph
	push dpl

	mov dptr, #cmd_line_buffer_pos
	movx a, @dptr

	pop dpl
	pop dph

	add a, dpl
	push a

	mov a, dph
	addc a, #0x00
	mov dph, a
	pop dpl

	ret

cmd_line_parser_skip_blanks:
	movx a, @dptr
	jz clp_skip_blanks_exit
	cjne a, #' ', clp_skip_blanks_exit
	inc dptr
	push dph
	push dpl
	mov dptr, #cmd_line_buffer_pos
	movx a, @dptr
	inc a
	movx @dptr, a
	pop dpl
	pop dph
	sjmp cmd_line_parser_skip_blanks
clp_skip_blanks_exit:
	ret

.area XSEG_UART_BUFFER (XDATA, PAG)

cmd_line_buffer:		.ds 0x0100

.area XSEG (XDATA)
cmd_line_buffer_pos:	.ds	0x01

