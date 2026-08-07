.include "commands.inc"
.include "conio.inc"
.include "bios.inc"
.include "ascii.inc"
.include "string.inc"
.include "vt102.inc"
.include "constants.inc"
.include "cmd_line_parser.inc"
.include "bios.inc"
.include "uart.inc"
;.include "math.inc"
.include "sfr.inc"
.include "cmd_dispatch.inc"

.area CSEG (CODE)

do_help:
	lcall println

	lcall cmd_dispatch_print_table

	lcall println

	ret

do_ls:
	lcall println
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_ls_err
	mov dptr, #app_table
do_ls_loop:
	clr a
	movc a, @a + dptr		; high byte of app_name
	mov r7, a				
	mov a, #1
	movc a, @a + dptr		; low byte of app_name
	mov r6, a
	orl a, r7
	jz do_ls_exit
	mov a, #TAB
	lcall sys_putc
	push dph				; save table pointer
	push dpl
	mov dph, r7				; get address of app_name
	mov dpl, r6
	lcall sys_puts		; send app_name to uart
	mov a, #TAB
	lcall sys_putc
	lcall sys_putc
	pop dpl
	pop dph
	inc dptr				; advance to app description
	inc dptr
	clr a
	movc a, @a + dptr
	mov r7, a
	mov a, #1
	movc a, @a + dptr
	mov r6, a
	push dph
	push dpl
	mov dph, r7
	mov dpl, r6
	lcall sys_puts
	lcall println
	pop dpl					; restore table pointer
	pop dph
	inc dptr				; advance to next record in table
	inc dptr
	inc dptr
	inc dptr
	sjmp do_ls_loop
do_ls_err:
	lcall do_invalid
do_ls_exit:
	ret

do_reset:
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_reset_err
	lcall sys_reset
do_reset_err:
	lcall do_invalid
	ret

do_peek:
	lcall println

	mov dptr, #mem_type
	lcall cmd_line_parser_next_token
	
	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #xram_str
	lcall strcmp
	jc do_peek_xram_lbl
	
	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #iram_str
	lcall strcmp
	jc do_peek_iram_lbl

	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #rom_str
	lcall strcmp
	jc do_peek_rom

	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #sfr_str
	lcall strcmp
	jc do_peek_sfr_lbl

	sjmp do_peek_err

do_peek_xram_lbl:
	lcall do_peek_xram
	sjmp do_peek_exit

do_peek_iram_lbl:
	lcall do_iram
	sjmp do_peek_exit

do_peek_rom_lbl:
	lcall do_peek_rom
	sjmp do_peek_exit

do_peek_sfr_lbl:
	lcall do_sfr
	sjmp do_peek_exit

do_peek_err:
	lcall do_invalid	
do_peek_exit:
	lcall println
	ret

do_peek_rom:
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #hex_word
	lcall ahex2word							; address in b:a
	push a									; save in stack because
	push 0xf0								; cmd_line_parser_next_token use the registers
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token		; get length
	pop 0x07								; restore into r7
	pop 0x06								; restore into r6
	mov dptr, #hex_word
	lcall ahex2word							; length in b:a
	mov r3, b
	mov r2, a
	lcall printtab
	mov a, #0x10
	lcall do_print_header_block
	lcall println
	mov r4, #0x10

do_peek_rom_loop:
	mov a, r2
	orl a, r3
	jz do_peek_rom_exit

	mov dph, r7
	mov dpl, r6
	clr a
	movc a, @a + dptr							; read char
	push a
	cjne r4, #0x10, dpxl_next_rom_byte
	mov b, dph
	mov a, dpl
	lcall print_hex_word
	lcall printtab
dpxl_next_rom_byte:
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop a
	lcall print_hex_byte
	djnz r4, dpxl_rom_spc
	lcall println
	mov r4, #0x10
	sjmp dpxl_rom_cont
dpxl_rom_spc:
	lcall printspc
	lcall printspc
dpxl_rom_cont:
	dec r2
	cjne r2, #0xff, do_peek_rom_loop
	dec r3
	sjmp do_peek_rom_loop

do_peek_rom_exit:
	ret

do_peek_xram:
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #hex_word
	lcall ahex2word							; address in b:a
	push a
	push 0xf0
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token		; get length
	pop 0x07
	pop 0x06
	mov dptr, #hex_word
	lcall ahex2word							; length in b:a
	mov r2, a
	mov r3, b
	lcall printtab
	mov a, #0x10
	lcall do_print_header_block
	lcall println
	mov r4, #0x10

do_peek_xram_loop:
	mov a, r2
	orl a, r3
	jz do_peek_xram_exit

	mov dph, r7
	mov dpl, r6
	movx a, @dptr							; read char
	push a
	cjne r4, #0x10, dpxl_next_byte
	mov b, dph
	mov a, dpl
	lcall print_hex_word
	lcall printtab
dpxl_next_byte:
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop a
	lcall print_hex_byte
	djnz r4, dpxl_spc
	lcall println
	mov r4, #0x10
	sjmp dpxl_cont
dpxl_spc:
	lcall printspc
	lcall printspc
dpxl_cont:
	dec r2
	cjne r2, #0xff, do_peek_xram_loop
	dec r3
	sjmp do_peek_xram_loop

do_peek_xram_exit:
	ret


do_poke:
	lcall println

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token			; get hex address
	xch a, b
	jz do_poke_invalid

	mov dptr, #hex_word
	lcall ahex2word
	push a
	push 0xf0
	mov r0, #0x00

do_poke_loop:
	mov dptr, #hex_byte
	lcall cmd_line_parser_next_token
	xch a, b									; if length = 0, then exit
	jz do_poke_exit
	mov r0, #0x01

	mov dptr, #hex_byte	
	movx a, @dptr
	xch a, b
	inc dptr
	movx a, @dptr
	;lcall ahex2byte
	lcall asc2byte

	pop dph										; pop upper byte
	pop dpl										; pop lower byte
	movx @dptr, a
	inc dptr
	push dpl
	push dph

	sjmp do_poke_loop
do_poke_invalid:
	lcall do_invalid
	ret
do_poke_exit:
	pop a
	pop a
	cjne r0, #0x01, do_poke_invalid
	ret

do_dump:
	lcall println
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_dump_err
	mov dptr, #hex_word
	lcall ahex2word								; address in b:a

	mov dph, b
	mov dpl, a

	lcall printtab
	lcall print_dump_header
	lcall println
	
	mov r1, #0x10
do_dump_loop:
	; print row address
	mov a, dph
	lcall hex2ahex

	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc

	mov a, dpl
	lcall hex2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc
	lcall printspc
	lcall printspc
	lcall printspc
	lcall printspc
	
	mov r0, #0x10
row_data_loop:
	movx a, @dptr
	lcall hex2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc
	lcall printspc
	lcall printspc
	inc dptr
	djnz r0, row_data_loop
	lcall println
	djnz r1, do_dump_loop
	sjmp do_dump_exit
do_dump_err:
	lcall do_invalid
do_dump_exit:
	ret

print_dump_header:
	mov r4, #0xff
	mov r3, #0x10
print_dump_header_loop:
	inc r4
	mov a, #'0'
	lcall sys_putc
	mov a, r4
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	mov a, #' '
	lcall sys_putc
	mov a, #' '
	lcall sys_putc
	djnz r3, print_dump_header_loop

	ret

; fills a memory block with a specific byte
do_fill:
	lcall println
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token			; read address
	mov dptr, #hex_word
	lcall ahex2word								; address in b:a
	push 0xf0									; push b = high byte of address
	push a										; push a = low byte of address

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token			; read length
	mov dptr, #hex_word
	lcall ahex2word
	push 0xf0									; push b = high byte of length
	push a										; push a = low byte of length

	mov dptr, #hex_byte
	lcall cmd_line_parser_next_token			; read fill char
	mov dptr, #hex_byte
	movx a, @dptr
	xch a, b
	inc dptr
	movx a, @dptr
	;lcall ahex2byte
	lcall asc2byte
	push a										; push a = fill char

	mov dptr, #cmd_line_input_temp				; check for trailing garbage
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_fill_err
	
	pop 0x05									; pop fill char into R5
	
	pop 0x06									; pop low byte of length
	pop 0x07									; pop high byte of length

	pop dpl										; pop low byte of address
	pop dph										; pop high byte of address

	lcall memset
	sjmp do_fill_exit
do_fill_err:
	pop a										; cleanup stack if error
	pop a
	pop a
	pop a
	pop a
	lcall do_invalid
do_fill_exit:
	ret

; copies a memory block from one location to another
do_copy:
	lcall println

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #hex_word
	lcall ahex2word
	push 0xf0
	push a

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #hex_word
	lcall ahex2word
	push 0xf0
	push a

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_copy_err

	mov dptr, #hex_word
	lcall ahex2word
	mov R5, b
	mov R4, a
	pop 0x06
	pop 0x07
	pop dpl
	pop dph

	lcall memcpy
	sjmp do_copy_exit
do_copy_err:
	lcall do_invalid
do_copy_exit:
	ret

; jumps to a memory address in program memory
do_goto:
	lcall println
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_goto_err
	mov dptr, #hex_word
	lcall ahex2word

	push a
	push 0xf0
	ret
	
	sjmp do_goto_exit

do_goto_err:
	lcall do_invalid
do_goto_exit:
	ret

do_iram:
	lcall println
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_iram_err

	mov r7, #0x01
	lcall printtab
	lcall print_dump_header
	lcall println
	mov r7, #0x08				; how many rows
	mov r0, #0x00				; starting address
do_iram_row_loop:
	mov r6, #0x10				; how many columns
	mov a, r0
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	mov a, b
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	push 0x07
	mov r7, #0x01
	lcall printtab
	pop 0x07
do_iram_col_loop:
	mov a, @r0
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	mov a, b
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	mov a, #SPC
	lcall sys_putc
	lcall sys_putc
	inc r0
	djnz r6, do_iram_col_loop
	lcall println
	djnz r7, do_iram_row_loop
	sjmp do_iram_exit
do_iram_err:
	lcall do_invalid
do_iram_exit:
	ret

do_sfr:
	lcall println
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jz do_sfr_no_err
	ljmp do_sfr_err
do_sfr_no_err:
	lcall print_sfr_table
	sjmp do_sfr_exit
do_sfr_err:
	lcall do_invalid
do_sfr_exit:
	ret

do_clear:
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_clear_err
	lcall sys_clrscrn
	sjmp do_clear_exit
do_clear_err:
	lcall do_invalid
do_clear_exit:
	ret

do_write:
	ret

do_invalid:
	lcall println
    mov dptr, #msg_err
    lcall sys_puts
	lcall println
	ret

do_load:
	lcall println
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jz dl_no_err
	ljmp dl_err
dl_no_err:

	mov dptr, #hex_word
	movx a, @dptr
	push a
	inc dptr
	movx a, @dptr
	pop 0xf0
	lcall asc2byte
	inc dptr
	push dpl
	push dph
	mov dptr, #ihex_address
	movx @dptr, a
	pop dph
	pop dpl
	movx a, @dptr
	push a
	inc dptr
	movx a, @dptr
	pop 0xf0
	lcall asc2byte
	mov dptr, #(ihex_address+1)
	movx @dptr, a
dl_loop:
	lcall sys_getc
	cjne a, #':', dl_loop			; discard start of record character ':'
	mov dptr, #ihex_checksum
	mov a, #0x00
	movx @dptr, a
dl_record_length:					; read 2 ascii characters
	lcall sys_getc					; read upper ascii nibble
	push a							; backup upper nibble
	lcall sys_getc					; read lower ascii nibble
	pop 0xf0						; restore into b
	lcall asc2byte					; convert b:a to byte
	mov dptr, #ihex_record_length	; save to ihex_byte_count
	movx @dptr, a
	lcall dl_add_to_checksum
dl_address:							; read 4 ascii characters
	lcall sys_getc
	push a
	lcall sys_getc
	pop 0xf0
	lcall asc2byte
	lcall dl_add_to_checksum
	lcall sys_getc
	push a
	lcall sys_getc
	pop 0xf0
	lcall asc2byte
	lcall dl_add_to_checksum
dl_record_type:						
	lcall sys_getc					; read 2 ascii characters
	push a
	lcall sys_getc
	pop 0xf0
	lcall asc2byte					; read record type
	lcall dl_add_to_checksum
	mov dptr, #ihex_record_type
	movx @dptr, a

	mov dptr, #ihex_record_length
	movx a, @dptr
	mov R7, a
	jz dl_checksum
dl_payload_loop:					; read 2 ascii characters on each iteration
	lcall sys_getc
	push a
	lcall sys_getc
	pop 0xf0
	lcall asc2byte
	push a							; save data byte
	mov dptr, #ihex_address
	movx a, @dptr					; read high byte of destination address
	push a
	inc dptr
	movx a, @dptr					; read low byte of destination address
	mov dpl, a
	pop dph							; dptr points to destination address
	pop a							; restore data from stack
	movx @dptr, a					; write data to destination address
	lcall dl_add_to_checksum
	inc dptr
	push dpl
	push dph
	mov dptr, #ihex_address
	pop a
	movx @dptr, a
	inc dptr
	pop a
	movx @dptr, a
	djnz R7, dl_payload_loop
dl_checksum:						; read 2 ascii characters
	lcall sys_getc
	push a
	lcall sys_getc
	pop 0xf0
	lcall asc2byte
	lcall dl_add_to_checksum
	mov dptr, #ihex_checksum
	movx a, @dptr
	jnz dl_checksum_error			; a contains the total checksum

	mov a, #'.'
	lcall sys_putc
	sjmp dl_check_eof
dl_checksum_error:
	mov a, #'x'
	lcall sys_putc
dl_check_eof:
	lcall printspc
	mov dptr, #ihex_record_type
	movx a, @dptr
	jnz dl_exit
	ljmp dl_loop
dl_err:
	lcall do_invalid
dl_exit:
	lcall println
	ret
	
dl_add_to_checksum:
	push a
	push 0xf0
	push dpl
	push dph
	mov b, a
	mov dptr, #ihex_checksum
	movx a, @dptr
	add a, b
	movx @dptr, a
	pop dph
	pop dpl
	pop 0xf0
	pop a

	ret

do_print_header_block:
	mov r0, a
	mov r1, #0x00
dphb_loop:
	mov a, r1
	lcall byte2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc
	lcall printspc
	lcall printspc
	inc r1
	djnz r0, dphb_loop

	ret

do_test_rand:
	lcall println

	mov r0, #0x55
	mov r1, #0x10
do_test_rand_loop:
	lcall sys_rand

	push a
	xch a, b
	lcall byte2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc

	pop a
	lcall byte2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc

	djnz r1, do_spc
	lcall println
	mov r1, #0x10
	sjmp do_next_number
do_spc:
	lcall printspc

do_next_number:
	djnz r0, do_test_rand_loop

	ret

do_test_goto:
	mov dph, 0x08
	mov dpl, 0xa5

	lcall do_goto

	ret

.area XSEG (XDATA)

mem_type:				.ds			0x10
hex_word:				.ds			0x10
hex_byte:				.ds			0x10
cmd_line_input_temp:	.ds			0x10
ihex_record_length:		.ds			0x01
ihex_address:			.ds			0x02
ihex_checksum:			.ds			0x01
ihex_record_type:		.ds			0x01


