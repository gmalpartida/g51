; Function: asc2bin
; Input:  Accumulator (A) = ASCII character ('0'-'9', 'A'-'F')
; Output: Accumulator (A) = Binary value (00h-0Fh)
; Uses:   R0 (temporary storage)
.globl asc2nibble

; converts a binary value to an ascii character
; --> a: binary value to be converted
; <-- a: ascii character 
.globl nibble2asc

; converts a hex value to ascii
; --> a: hex value
; <-- b: ascii equivalent of upper nibble
; <-- a: ascii equivalent of lower nibble
.globl hex2asc

.globl asc2byte

.globl byte2asc
