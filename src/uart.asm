.include "uart.inc"
.include "constants.inc"
.include "vt102.inc"

.area CSEG (CODE)

uart_init:
    anl tmod, #0x0f					; Clear Timer 1 mode bits
    orl tmod, #0x20					; Set Timer 1 to Mode 2 (8-bit auto-reload)
    
    mov th1, #0xff                 ; 57600 bps at 11.0592 MHz
	;mov th1, #0xfa					; 19200 bps
	;mov th1, #0xfd					; 9600 bps
    
    orl pcon, #0x80					; Set SMOD to 1 (Doubles the baud rate generation)
    
    mov scon, #0x50					; Mode 1 (8-bit UART), ENABLE receiver (REN=1)
    setb tr1                        ; Start Timer 1
    
    ;setb ti                        ; set transmitter 'ready'

	mov a, #0x00
	mov dptr, #uart_rx_buffer_head
	movx @dptr, a
	mov dptr,#uart_rx_buffer_tail
	movx @dptr, a
	mov dptr, #uart_rx_buffer_count
	movx @dptr, a
	mov dptr, #uart_rx_xoff_sent
	movx @dptr, a

    ret

;uart_rx_char:
;	jnb ri, uart_rx_char			; wait for character to arrive
;	clr ri							; clear receiveer
;	mov a, sbuf						; get character
;	ret

uart_rx_char:
	push dpl
	push dph
	; if buffer is not empty, process char
	mov dptr, #uart_rx_buffer_head
	movx a, @dptr
	mov b, a							; save buffer head for later use
uart_rx_wait_loop:
	mov dptr, #uart_rx_buffer_tail
	movx a, @dptr						; read value of buffer tail
	cjne a, b, uart_rx_process_char		; compare to buffer head, if not the same then there is a char
	sjmp uart_rx_wait_loop				; otherwise loop back and wait for char
uart_rx_process_char:
	; process char, store in a
	mov dptr, #uart_rx_buffer
	mov a, b							; restore buffer head
	add a, dpl							; add head to buffer
	jnc uart_rx_char_skip_dph
	inc dph
uart_rx_char_skip_dph:
	mov dpl, a							; dptr contains address of char at buffer + head
	movx a, @dptr						; retrieve character from buffer
	push acc							; save char
	; advance buffer head
	mov a, b							; b still contains buffer head
	inc a
	mov dptr, #uart_rx_buffer_head
	movx @dptr, a		
	mov dptr, #uart_rx_buffer_count
	movx a, @dptr
	dec a
	movx @dptr, a
	cjne a, #64, uart_rx_char_exit
	mov dptr, #uart_rx_xoff_sent
	movx a, @dptr
	jz uart_rx_char_exit
	mov sbuf, #0x011					; send xon
	mov a, #0x00						; clear xoff sent flag
	movx @dptr, a
uart_rx_char_exit:
	pop acc								; restore retrieved char
	pop dph
	pop dpl
	ret

uart_tx_char:
	mov sbuf, a
uart_tx_char_here:
	jnb ti, uart_tx_char_here
	clr ti
	ret

uart_tx_asciz:
	mov a, #0x00	
	movc a, @a + dptr
	jz uart_tx_asciz_exit
	lcall uart_tx_char
	inc dptr
	sjmp uart_tx_asciz
uart_tx_asciz_exit:
	ret

uart_tx_asciz_xram:
	movx a, @dptr
	jz uart_tx_asciz_xram_exit
	lcall uart_tx_char
	inc dptr
	sjmp uart_tx_asciz_xram
uart_tx_asciz_xram_exit:
	ret

uart_rx_asciz:
	mov R7, dph
	mov R6, dpl									; save start of buffer for empty check later
uart_rx_asciz_loop:
	lcall uart_rx_char
	mov b, a									; make copy of it, next statements destroy char in a
	jz uart_rx_asciz_exit						; if NULL then exit
	xrl a, #0x0d
	jz uart_rx_asciz_exit						; if CR then exit
	mov a, b									; restore copy of char
	xrl a, #0x0a
	jz uart_rx_asciz_exit						; if LF then exit
	mov a, b
	xrl a, #BS									; check for BS
	jnz uart_rx_asciz_process_del
	sjmp uart_rx_asciz_process_del_or_bs
uart_rx_asciz_process_del:
	mov a, b
	xrl a, #DEL
	jnz uart_rx_asciz_process_char
uart_rx_asciz_process_del_or_bs:
	mov a, dph
	cjne a, 0x07, process_bs_or_del
	mov a, dpl
	cjne a, 0x06, process_bs_or_del
	sjmp uart_rx_asciz_loop
process_bs_or_del:
	mov a, dpl
	clr c
	subb a, #0x01
	mov dpl, a
	mov a, dph
	subb a, #0x00
	mov dph, a
	push dpl
	push dph
	lcall vt102_handle_BS
	pop dph
	pop dpl
	sjmp uart_rx_asciz_loop
uart_rx_asciz_process_char:
	mov a, b
	movx @dptr, a								; not NULL, CR or LF, keep it
	inc dptr
	lcall uart_tx_char							; echo char
	sjmp uart_rx_asciz_loop
uart_rx_asciz_exit:
	mov a, #0x00								; the last character must be NULL
	movx @dptr, a
	ret

uart_rx_isr:
	push acc
	push b
	push psw
	push dpl
	push dph
	mov a, r0
	push acc
	jb ri, uart_rx_handler
	;jbc ti, uart_rx_isr_exit
	sjmp uart_rx_isr_exit
uart_rx_handler:
	clr ri
	mov a, sbuf							; retrieve received character
	mov b, a							; save it for later
	mov dptr, #uart_rx_buffer_tail
	movx a, @dptr						; get tail position
	mov r0, a							; save buffer tail value
	inc a								; increment current buffer tail value
	movx @dptr, a						; save it back
	mov dptr, #uart_rx_buffer			; get address of rx buffer
	mov a, r0							; restore buffer tail value
	add a, dpl							; add buffer tail value to buffer address
	jnc uart_rx_isr_skip_dph
	inc dph
uart_rx_isr_skip_dph:
	mov dpl, a
	mov a, b							; restore character received
	movx @dptr, a						; copy character to buffer
	mov dptr, #uart_rx_buffer_count		; increment buffer count
	movx a, @dptr
	inc a
	movx @dptr, a
	cjne a, #192, uart_rx_isr_exit		; buffer is not quite full yet
	mov a, #0x13						; send xoff
	mov sbuf, a
	mov dptr, #uart_rx_xoff_sent		; set xoff sent flag
	mov a, #0x01
	movx @dptr, a
uart_rx_isr_exit:
	pop acc
	mov r0, a
	pop dph
	pop dpl
	pop psw
	pop b
	pop acc
	reti

return_uart_rx_buffer:
	mov dptr, #uart_rx_buffer
	ret

uart_rx_buffer_size:
	mov dptr, #uart_rx_buffer_tail
	movx a, @dptr
	mov b, a
	mov dptr, #uart_rx_buffer_head
	movx a, @dptr
	clr c
	subb a, b
	ret
	
.area XSEG_CMD_LINE_BUFFER (XDATA, PAG)
uart_rx_buffer::		.ds		0x0100

.area XSEG (XDATA)
uart_rx_buffer_head::	.ds		0x01
uart_rx_buffer_tail::	.ds		0x01
uart_rx_buffer_count:	.ds		0x01
uart_rx_xoff_sent:		.ds		0x01
