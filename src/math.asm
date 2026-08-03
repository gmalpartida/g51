.include "math.inc"

.area CSEG (CODE)

rand_init:
	; get values at rand_seed address
	mov dptr, #rand_seed
	movx a, @dptr							; read high byte of rand_seed
	push a
	inc dptr
	movx a, @dptr							; read low byte of rand_seed
	push a
	; use values to form new addresses
	pop dpl
	pop dph
	movx a, @dptr							; read value at that address
	push a
	; use this value to form two new addresses
	push dph
	push dpl
	mov dph, a
	movx a, @dptr							; read high byte of new seed
	mov dptr, #rand_seed
	movx @dptr, a
	pop dpl
	pop dph
	pop dpl
	movx a, @dptr							; read low byte of new seed
	mov dptr, #(rand_seed + 1)
	movx @dptr, a
	ret

rand:
    ;; ---------------------------------------------------------
    ;; STEP 1: Multiplier 25173 (0x6255)
    ;; To compute (0x6255 * X) mod 65536 using 8-bit pieces:
    ;; Low product  = low(X) * 0x55
    ;; High product = [high(X) * 0x55] + [low(X) * 0x62]
    ;; ---------------------------------------------------------

    ;; Part A: low(X) * 0x55
	mov dptr, #(rand_seed+1)
    movx a, @dptr
    mov     b, #0x55
    mul     ab                  ; A = low byte, B = high byte
    mov     r2, a               ; R2 = temporary low accumulator
    mov     r3, b               ; R3 = temporary high accumulator

    ;; Part B: high(X) * 0x55
    mov	dptr, #(rand_seed)
	movx a, @dptr
    mov     b, #0x55
    mul     ab                  ; A = low byte, B = high byte (B is discarded due to mod 65536)
    add     a, r3               ; Add to high accumulator
    mov     r3, a

    ;; Part C: low(X) * 0x62
	mov dptr, #(rand_seed+1)
    movx a, @dptr
    mov     b, #0x62
    mul     ab                  ; A = low byte, B is discarded
    add     a, r3               ; Add to high accumulator
    mov     r3, a

    ;; ---------------------------------------------------------
    ;; STEP 2: Add Increment 13849 (0x3619)
    ;; ---------------------------------------------------------
    mov     a, r2
    add     a, #0x19				; Add low byte of increment
	mov dptr, #(rand_seed+1)
    movx @dptr, a					; Save final low byte to seed
    mov     b, a					; Set return low byte

    mov     a, r3
    addc    a, #0x36				; Add high byte + carry
	mov dptr, #(rand_seed)
	movx @dptr, a					; Save final high byte to seed

	xch a, b						; Set return high byte

    ret

get_seed:
	mov dptr, #rand_seed
	movx a, @dptr
	mov b, a
	inc dptr
	movx a, @dptr
	ret

.area XSEG (XDATA)

rand_seed:		.ds		0x02
