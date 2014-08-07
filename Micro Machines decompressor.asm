.section "Micro Machines in-memory decompressor" free
micromachines_decompress:
; Parameters:
; hl = source
; de = dest
; Returns hc = number of bytes decompressed (i.e. output size)
; Uses afbcde
    push   de              ; 007B21 D5 
		jr     _get_next_mask_set_carry;$7b8d           ; 007B22 18 69 

_exit:
    pop    hl              ; 007B24 E1  Get original de = dest address
    ld     a,e             ; 007B25 7B 	Return hc = de - original de = number of bytes written
    sub    l               ; 007B26 95 
    ld     c,a             ; 007B27 4F 
    ld     a,d             ; 007B28 7A 
    sbc    a,h             ; 007B29 9C 
    ld     h,a             ; 007B2A 67 
    ret                    ; 007B2B C9 

_5x_use_a:
			ld     b,a             ; 007B2C 47 
_5x_use_b:
			ld     a,e             ; 007B2D 7B 		get dest low byte
			sub    (hl)            ; 007B2E 96 		subtract next byte
			inc    hl              ; 007B2F 23
			ld     c,(hl)          ; 007B30 4E 		and get the next byte as a counter
			push   hl              ; 007B31 E5 
				ld     l,a             ; 007B32 6F 		Save subtracted low byte
				ld     a,d             ; 007B33 7A 		High byte
				sbc    a,b             ; 007B34 98 		Subtract carry (from offset subtraction) and b
				ld     h,a             ; 007B35 67 		That's our offset + 1
				dec    hl              ; 007B36 2B 		
				ld     a,c             ; 007B37 79 		save c
				ldi                    ; 007B38 ED A0 	copy 3 bytes
				ldi                    ; 007B3A ED A0 
				ldi                    ; 007B3C ED A0 
				ld     c,a             ; 007B3E 4F 		restore c
				ld     b,$00           ; 007B3F 06 00 
				inc    bc              ; 007B41 03 		increment counter
				jr     _copybcbytes;$7b61           ; 007B42 18 1D 

_2x3x4x_real: ; LZ: copy x+3 bytes from offset -(*p++ + (high-2)*256 - 2)
; Examples:
; 21 ee
; de = c118
; Copy 4 bytes from $c118 - 0*256 - $ee - 2 = $c028
; 30 02
; de = c1d0
; Copy 3 bytes from $c1d0 - 1*256 - 2 - 2 = $c0cc
; 40 76
; de = c2a8
; Copy 3 bytes from $c2a8 - 2*256 - $76 - 2 = $c030
			ld     b,a             ; 007B44 47 		save value - in range 0-$2f?
			and    $0f             ; 007B45 E6 0F 	c = x+2
			add    a,$02           ; 007B47 C6 02 
			ld     c,a             ; 007B49 4F 
			ld     a,b             ; 007B4A 78 
			and    $30             ; 007B4B E6 30 	Mask to high bits
			rlca                   ; 007B4D 07 		Get high nibble (0..2)
			rlca                   ; 007B4E 07 
			rlca                   ; 007B4F 07 
			rlca                   ; 007B50 07 
			cpl                    ; 007B51 2F 		Invert (-1..-3)
			ld     b,a             ; 007B52 47 		-> B
			ld     a,(hl)          ; 007B53 7E 		Get next byte
			push   hl              ; 007B54 E5 
				cpl                    ; 007B55 2F 	Subtract from de
				add    a,e             ; 007B56 83 
				ld     l,a             ; 007B57 6F 
				ld     a,d             ; 007B58 7A 
				adc    a,b             ; 007B59 88 	Also subtract b*256
				ld     h,a             ; 007B5A 67 
				dec    hl              ; 007B5B 2B 

_copycplusonebytes:
				ld     b,$00           ; 007B5C 06 00 	; counter = c
				inc    c               ; 007B5E 0C 		
				ldi                    ; 007B5F ED A0 	; copy from hl to de
_copybcbytes:
				ldir                   ; 007B61 ED B0 	; 1-257 bytes?
			pop    hl              ; 007B63 E1 
			inc    hl              ; 007B64 23 			Next byte
		ex     af,af'          ; 007B65 08 			Restore a
		jr     _get_next_mask_7bits;$7b95           ; 007B66 18 2D 		Carry on looking through bits

_5x: ; LZ: data bytes are offset, count. 
; If x is $f, there is an extra offset-high byte first.
; Else, x is the high byte.
; Copy count+4 bytes from -(offset + 1).
; Examples:
; 5f 0f ff 06
; de = d180
; Copy 10 bytes from $d180 - $fff - 1 = $c180
; 53 26 01
; de = d1f2
; Copy 5 bytes from $d1f2 - $326 - 1 = $cecb
			cp     $0f             ; 007B68 FE 0F 	Use x unless it's $f, when the next byte is the count
			jr     nz,_5x_use_a;$7b2c        ; 007B6A 20 C0 
			ld     b,(hl)          ; 007B6C 46 		else b = next byte
			inc    hl              ; 007B6D 23 
			jr     _5x_use_b;$7b2d           ; 007B6E 18 BD 	

_2x3x4x:			
    jr     _2x3x4x_real;$7b44           ; 007B70 18 D2 

_highbitsetcompresseddata: ; %1 nn ooooo Copy n+2 bytes from offset -(n+o+2)
; e.g. $ad = %1 01 01101 = 1, 13
; de = $c120
; So 3 bytes of data is written from $c120 which is copied from $c120 - $1 - $d - $2 = c110

			cp     $ff             ; 007B72 FE FF 	All the bits set?
			jr     z,_exit;$7b24         ; 007B74 28 AE 	If so, done

			and    $60             ; 007B76 E6 60   Mask to bits %01100000
			rlca                   ; 007B78 07 		Move to LSBs = n
			rlca                   ; 007B79 07 
			rlca                   ; 007B7A 07 
			inc    a               ; 007B7B 3C 		Add 1	
			ld     c,a             ; 007B7C 4F 

			ld     a,(hl)          ; 007B7D 7E 		Get byte again
			push   hl              ; 007B7E E5 
				and    $1f             ; 007B7F E6 1F 	Mask to $00011111 = o
				add    a,c             ; 007B81 81 		Add c
				cpl                    ; 007B82 2F 		Two's complement the hard way..?
				add    a,e             ; 007B83 83 		Overall: hl = de - a - 1
				ld     l,a             ; 007B84 6F 
				ld     a,d             ; 007B85 7A 
				adc    a,-1            ; 007B86 CE FF 
				ld     h,a             ; 007B88 67 
				jr     _copycplusonebytes;$7b5c           ; 007B89 18 D1 	...

_copy_byte_and_get_next_mask_with_carry:				
		ldi                    ; 007B8B ED A0 	Copy a byte and continue bit-loop

_get_next_mask_set_carry:
		scf                    ; 007B8D 37 		Set carry, so as we shift we should not have zeroes in a even if it would otherwise
_get_next_mask:
		ld     a,(hl)          ; 007B8E 7E 		Get byte
		inc    hl              ; 007B8F 23 		Point at next

		adc    a,a             ; 007B90 8F 		High bit 1 = compressed, 0 = raw byte follows. Unrolled loop here, plus carry in
		jr     c,_compressed;$7bb6 ; 007B91 38 23 
		ldi                    ; 007B93 ED A0 	Copy raw byte
_get_next_mask_7bits:
		add    a,a             ; 007B95 87 
		jr     c,_compressed;$7bb6         ; 007B96 38 1E 
		ldi                    ; 007B98 ED A0 
_get_next_mask_6bits:
		add    a,a             ; 007B9A 87 
		jr     c,_compressed;$7bb6         ; 007B9B 38 19 
		ldi                    ; 007B9D ED A0 
_get_next_mask_5bits:
		add    a,a             ; 007B9F 87 
		jr     c,_compressed;$7bb6         ; 007BA0 38 14 
		ldi                    ; 007BA2 ED A0 
_get_next_mask_4bits:
		add    a,a             ; 007BA4 87 
		jr     c,_compressed;$7bb6         ; 007BA5 38 0F 
		ldi                    ; 007BA7 ED A0 
_get_next_mask_3bits:
		add    a,a             ; 007BA9 87 
		jr     c,_compressed;$7bb6         ; 007BAA 38 0A 
		ldi                    ; 007BAC ED A0 
_get_next_mask_2bits:
		add    a,a             ; 007BAE 87 
		jr     c,_compressed;$7bb6         ; 007BAF 38 05 
		ldi                    ; 007BB1 ED A0 
_get_next_mask_1bit:
		add    a,a             ; 007BB3 87 
		jr     nc,_copy_byte_and_get_next_mask;$7b8b        ; 007BB4 30 D5 	No carry -> loop

_compressed:
		jr     z,_get_next_mask;$7b8e         ; 007BB6 28 D6 	If no set bits left, we're done with our flags byte (we got to the terminating bit)
		ex     af,af'          ; 007BB8 08 		Save a
_compressed_real:
			ld     a,(hl)          ; 007BB9 7E 		Get next byte
			cp     $80             ; 007BBA FE 80 	Check high bit
			jr     nc,_highbitsetcompresseddata;$7b72        ; 007BBC 30 B4 	1 -> go there

_highbitnotset:
			inc    hl              ; 007BBE 23 		Point at next byte
			sub    $70             ; 007BBF D6 70 	Check our value... $7x
			jr     nc,_7x;$7bf1        ; 007BC1 30 2E   -> handler
			add    a,$10           ; 007BC3 C6 10 	$6x
			jr     c,_6x;$7c05         ; 007BC5 38 3E 	-> handler
			add    a,$10           ; 007BC7 C6 10 	$5x	
			jr     c,_5x;$7b68         ; 007BC9 38 9D 	-> handler
			add    a,$30           ; 007BCB C6 30 	$2x-$4x
			jr     c,_2x3x4x;$7b70         ; 007BCD 38 A1 
			add    a,$10           ; 007BCF C6 10 	$0x
			jr     nc,_0x;$7c1d        ; 007BD1 30 4A 

_1x: ; Repeat previous byte x+2 times
			ld     b,$00           ; 007BD3 06 00 
			sub    $0f             ; 007BD5 D6 0F 	Check for $f
			jr     z,+;$7be8         ; 007BD7 28 0F 	$f means there's another data byte
			add    a,$11           ; 007BD9 C6 11 	c = x + 2
_duplicate_previous_byte_ba_times:
			ld     c,a             ; 007BDB 4F 
			push   hl              ; 007BDC E5 
				ld     l,e             ; 007BDD 6B 		; repeat previous byte x times
				ld     h,d             ; 007BDE 62 
				dec    hl              ; 007BDF 2B 
				ldi                    ; 007BE0 ED A0 
				ldir                   ; 007BE2 ED B0 
			pop    hl              ; 007BE4 E1 
		ex     af,af'          ; 007BE5 08 
		jr     _get_next_mask_7bits;$7b95           ; 007BE6 18 AD 

+:			ld     a,(hl)          ; 007BE8 7E 		next byte
			inc    hl              ; 007BE9 23 
			add    a,$11           ; 007BEA C6 11 	add 17
			jr     nc,_duplicate_previous_byte_ba_times;$7bdb        ; 007BEC 30 ED 	check for >255
			inc    b               ; 007BEE 04 		if so, increment high counter byte
			jr     _duplicate_previous_byte_ba_times;$7bdb           ; 007BEF 18 EA 

_7x: ; run of x+2 incrementing bytes, following last byte written. x = $f -> next byte is run length - 17.
; Examples:
; 70
; Run of 2 bytes following previous value
; 7f 03
; Run of 20 bytes following previous value
		sub    $0f             ; 007BF1 D6 0F 	$f means the next byte is the run length
		jr     nz,+;$7bf7        ; 007BF3 20 02 	else it is the run length (-2) itself
		ld     a,(hl)          ; 007BF5 7E 
		inc    hl              ; 007BF6 23 
+:  	add    a,$11           ; 007BF7 C6 11 	a = x+2
		ld     b,a             ; 007BF9 47 
		dec    de              ; 007BFA 1B 		read previous byte
		ld     a,(de)          ; 007BFB 1A 
		inc    de              ; 007BFC 13 
-:  	inc    a               ; 007BFD 3C 		add 1
		ld     (de),a          ; 007BFE 12 		write
		inc    de              ; 007BFF 13 
		djnz   -;$7bfd           ; 007C00 10 FB 
    ex     af,af'          ; 007C02 08 
    jr     _get_next_mask_7bits;$7b95           ; 007C03 18 90 

_6x: ; LZ run in reverse order
; 6x oo
; Copy x+3 bytes, starting from -(o+1) and working backwards
; Examples:
; 64 0a
; de = d229
; Copy 7 bytes from $d229 - $0a - 1 = $d21e
; down to $d21e - 6 = $d218 inclusive
		add    a,$03           ; 007C05 C6 03 	; b = x+3
		ld     b,a             ; 007C07 47 
		ld     a,(hl)          ; 007C08 7E 		; get next byte o
		push   hl              ; 007C09 E5 
			cpl                    ; 007C0A 2F 	; invert bits
			scf                    ; 007C0B 37 	; set carry
			adc    a,e             ; 007C0C 8B 	; hl = de - o
			ld     l,a             ; 007C0D 6F 
			ld     a,d             ; 007C0E 7A 
			adc    a,$ff           ; 007C0F CE FF 
			ld     h,a             ; 007C11 67 
-:			dec    hl              ; 007C12 2B 		move back
			ld     a,(hl)          ; 007C13 7E 		read byte
			ld     (de),a          ; 007C14 12 		copy to de
			inc    de              ; 007C15 13 
			djnz   -;$7c12           ; 007C16 10 FA 
		pop    hl              ; 007C18 E1 
		inc    hl              ; 007C19 23 
    ex     af,af'          ; 007C1A 08 
    jr     $7c03           ; 007C1B 18 E6 

_0x: ; Raw run:
; if (x == $f)
;   x = next byte
;   if (x = $ff)
;     x = following 2 bytes
;   else
;     x += 30
; else
;   x += 8
; Copy x raw bytes
; Examples:
; 03 [data x 11]
; 0f 0c [data x 42]
; 0f ff 12 34 [data x 13330]
    ld     b,$00           ; 007C1D 06 00 
    inc    a               ; 007C1F 3C 		increment
    jr     z,_0f;$7c37         ; 007C20 28 15 	That'd be $0f originally
    add    a,$17           ; 007C22 C6 17 	a = x+8
    ld     c,a             ; 007C24 4F 		that's our count
    ldi                    ; 007C25 ED A0 
    ldi                    ; 007C27 ED A0 
    ldi                    ; 007C29 ED A0 
    ldi                    ; 007C2B ED A0 
    ldi                    ; 007C2D ED A0 
    ldi                    ; 007C2F ED A0 
    ldi                    ; 007C31 ED A0 
    ldir                   ; 007C33 ED B0 	copy c bytes total, but allow range 8..263
    jr     _compressed_real ;007C35 18 82   then consume next byte as compressed

_0f:
    ld     a,(hl)          ; 007C37 7E 		read byte
    inc    hl              ; 007C38 23 
    inc    a               ; 007C39 3C 		$ff -> double-byte length
    jr     z,_0fff;$7c5f         ; 007C3A 28 23 	
    add    a,$1d           ; 007C3C C6 1D 	add 29
    ld     c,a             ; 007C3E 4F 
    ld     a,$08           ; 007C3F 3E 08 	
    jr     nc,+;$7c44        ; 007C41 30 01 	deal with >255
    inc    b               ; 007C43 04 
-:
+:  ldi                    ; 007C44 ED A0 	copy 8 bytes at a time until bc <= 8
    ldi                    ; 007C46 ED A0 	This allows us to have bc in the range 9..65544 but that can't actually happen?
    ldi                    ; 007C48 ED A0 
    ldi                    ; 007C4A ED A0 
    ldi                    ; 007C4C ED A0 
    ldi                    ; 007C4E ED A0 
    ldi                    ; 007C50 ED A0 
    ldi                    ; 007C52 ED A0 
    cp     c               ; 007C54 B9 		compare a to c
    jr     c,-;$7c44         ; 007C55 38 ED 	loop until it's bigger or equal
    dec    b               ; 007C57 05 		check for b=0
    inc    b               ; 007C58 04 
    jr     nz,-;$7c44        ; 007C59 20 E9 loop if not
    ldir                   ; 007C5B ED B0 	then copy bc bytes
    jr     $7c35           ; 007C5D 18 D6 	done

_0fff:
    ld     c,(hl)          ; 007C5F 4E 		following 2 bytes to bc
    inc    hl              ; 007C60 23 
    ld     b,(hl)          ; 007C61 46 
    inc    hl              ; 007C62 23 
    ld     a,$08           ; 007C63 3E 08 		
    jr     -;$7c44           ; 007C65 18 DD and 

.ends