.ifndef STRING_INC
.define STRING_INC

; finds character c in the first n bytes of a memory buffer in program memory
; --> r6,r7: address of memory buffer
; --> r5: 	character for which to search
; --> r4:	how many bytes at which to look
; <-- r6,r7: address at which character was found, otherwise NULL
; <-- c: clear if found, otherwise set
.globl memchr_c

; finds character c in the first n bytes of a memory buffer in data memory
; --> r6,r7: address of memory buffer
; --> r5: 	character for which to search
; --> r4:	how many bytes at which to look
; <-- r6,r7: address at which character was found, otherwise NULL
.globl memchr

; compares the first n bytes of two blocks of memory, one of which is in program memory
; --> r6, r7: 	address of block of memory in program memory
; --> r4, r5: 	address of block of memory in data memory
; --> r3: 		how many bytes to compare
; <-- r7:		0 if equal, -1 if first block is less than second block, otherwise 1

.globl memcmp_c

; copies n bytes from one memory block to another, one of which resides in program memory
; --> r6, r7: address of source memory block in program memory
; --> r4, r5: address of destination memory block in data memory
; --> r3: 	  how many bytes to copy

.globl memcpy_c

; initializes a memory block with a specific byte
; --> r6, r7: address of memory block
; --> r5: length of memory block
; --> r4: byte to fill the block

.globl memset

; moves a memory block from one location to another
; --> r6, r7: address of source memory block
; --> r4, r5: address of destination memory block
; --> r3: how many bytes to move
.globl memcpy

.globl strncmp

.globl strcmp

.endif
