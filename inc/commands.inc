.include "constants.inc"

.globl do_help

.globl do_ls

.globl do_peek

.globl do_poke

.globl do_clear

; fills a memory block with a specific byte
.globl do_fill

; copies a memory block from one location to another
.globl do_copy
; jumps to a memory address in program memory
; --> r6, r7: memmory address in program memory
.globl do_goto

.globl do_invalid

.globl do_load

.globl do_reset

.globl do_test
