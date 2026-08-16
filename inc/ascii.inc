.ifndef ASCII_INC
.define ASCII_INC

; Function: asc2bin
; Input:  Accumulator (A) = ASCII character ('0'-'9', 'A'-'F')
; Output: Accumulator (A) = Binary value (00h-0Fh)
; Uses:   R0 (temporary storage)
.globl ahex2nibble

; converts a binary value to an ascii character
; --> a: binary value to be converted
; <-- a: ascii character 
.globl nibble2ahex

; converts a hex value to ascii
; --> a: hex value
; <-- b: ascii equivalent of upper nibble
; <-- a: ascii equivalent of lower nibble
.globl hex2ahex

.globl asc2byte

.globl byte2ahex

.globl ahex2byte

.globl ahex2word

.endif
