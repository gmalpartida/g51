.globl uart_init

; receives a character via serial line
; ==> none
; <== a: character received
.globl uart_rx_char

; sends a character via serial line
; ==> a:	character to send
; <== none
.globl uart_tx_char

; sends an null-terminated string via serial line
; ==> dptr: address of string
; <== none
.globl uart_tx_asciz

; receives a null-terminated string via serial line
; ==> none
; <== dptr: address of received string
.globl uart_rx_asciz

.globl uart_rx_isr

.globl return_uart_rx_buffer

.globl uart_rx_buffer_size

.globl uart_tx_asciz_xram
