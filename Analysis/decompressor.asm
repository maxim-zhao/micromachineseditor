; Parameters:
; hl = source
; de = dest
; Returns hc = number of bytes decompressed (i.e. output size)
; Uses afbcde
; Relocatable (no absolute addresses used), but in the end there's another copy
; which gets relocated to RAM - this one executes in place.
  push de
    jr _get_next_mask_set_carry

_exit:
  pop hl    ; Get original de = dest address
  ld a, e   ; Return hc = de - original de = number of bytes written
  sub l
  ld c, a
  ld a, d
  sbc a, h
  ld h, a
  ret

_5x_use_a:
      ld b, a
_5x_use_b:
      ld a, e     ; get dest low byte
      sub (hl)    ; subtract next byte
      inc hl
      ld c, (hl)  ; and get the next byte as a counter
      push hl
        ld l, a   ; Save subtracted low byte
        ld a, d   ; High byte
        sbc a, b  ; Subtract carry (from offset subtraction) and b
        ld h, a   ; That's our offset + 1
        dec hl
        ld a, c   ; save c
        ldi       ; copy 3 bytes
        ldi
        ldi
        ld c, a   ; restore c
        ld b, $00
        inc bc    ; increment counter
        jr _copybcbytes

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

      ld b, a     ; save value - in range 0-$2f?
      and $0F     ; c = x+2
      add a, $02
      ld c, a
      ld a, b
      and $30     ; Mask to high bits
      rlca        ; Get high nibble (0..2)
      rlca
      rlca
      rlca
      cpl         ; Invert (-1..-3)
      ld b, a     ; -> B
      ld a, (hl)  ; Get next byte
      push hl
        cpl         ; Subtract from de
        add a, e
        ld l, a
        ld a, d
        adc a, b    ; Also subtract b*256
        ld h, a
        dec hl

_copycplusonebytes:
        ld b, $00 ; counter = c
        inc c
        ldi       ; copy from hl to de
_copybcbytes:
        ldir      ; 1-257 bytes?
      pop hl
      inc hl      ; Next byte
    ex af, af'
    jr _get_next_mask_7bits

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
      cp $0F              ; Use x unless it's $f, when the next byte is the count
      jr nz, _5x_use_a
      ld b, (hl)          ; else b = next byte
      inc hl
      jr _5x_use_b

_2x3x4x:
      jr _2x3x4x_real

_highbitsetcompresseddata: ; %1 nn ooooo Copy n+2 bytes from offset -(n+o+2)
; e.g. $ad = %1 01 01101 = 1, 13
; de = $c120
; So 3 bytes of data is written from $c120 which is copied from $c120 - $1 - $d - $2 = c110
      cp $FF        ; All the bits set?
      jr z, _exit   ; If so, done

      and $60       ; Mask to bits %01100000
      rlca          ; Move to LSBs = n
      rlca
      rlca
      inc a         ; Add 1
      ld c, a

      ld a, (hl)    ; Get byte again
      push hl
        and $1F     ; Mask to $00011111 = o
        add a, c    ; Add c
        cpl         ; Two's complement the hard way..?
        add a, e    ; Overall: hl = de - a - 1
        ld l, a
        ld a, d
        adc a, -1
        ld h, a
        jr _copycplusonebytes

_copy_byte_and_get_next_mask_with_carry:
    ldi
_get_next_mask_set_carry:
    scf           ; Set carry, so as we shift we should not have zeroes in a even if it would otherwise
_get_next_mask:
    ld a, (hl)    ; Get byte
    inc hl        ; Point at next

    adc a, a      ; High bit 1 = compressed, 0 = raw  $byte follows. Unrolled loop here, plus carry in
    jr c, _compressed
    ldi
_get_next_mask_7bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_6bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_5bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_4bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_3bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_2bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_1bit:
    add a, a
    jr nc, _copy_byte_and_get_next_mask_with_carry

_compressed:
    jr z, _get_next_mask      ; If no set bits left, we're done with our flags byte (we got to the terminating bit)
    ex af, af'                ; Save a
_compressed_real:
      ld a, (hl)
      cp $80
      jr nc, _highbitsetcompresseddata

_highbitnotset:
      inc hl                  ; Point at next byte
      sub $70
      jr nc, _7x
      add a, $10
      jr c, _6x
      add a, $10
      jr c, _5x
      add a, $30
      jr c, _2x3x4x
      add a, $10
      jr nc, _0x

_1x: ; Repeat previous byte x+2 times
      ld b, $00
      sub $0F                 ; Check for $f
      jr z, +                 ; $f means there's another data byte
      add a, $11              ; c = x + 2
_duplicate_previous_byte_ba_times:
      ld c, a
      push hl
        ld l, e               ; repeat previous byte x times
        ld h, d
        dec hl
        ldi
        ldir
      pop hl
    ex af, af'
    jr _get_next_mask_7bits

+:    ld a, (hl)              ; next byte
      inc hl
      add a, $11              ; add 17
      jr nc, _duplicate_previous_byte_ba_times ; check for >255
      inc b                   ; if so, increment high counter byte
      jr _duplicate_previous_byte_ba_times

_7x: ; run of x+2 incrementing bytes, following last byte written. x = $f -> next byte is run length - 17.
; Examples:
; 70
; Run of 2 bytes following previous value
; 7f 03
; Run of 20 bytes following previous value
      sub $0F           ; $f means the next byte is the run length
      jr nz, +          ; else it is the run length (-2) itself
      ld a, (hl)
      inc hl
+:    add a, $11        ; a = x+2
      ld b, a
      dec de
      ld a, (de)        ; read previous byte
      inc de
-:    inc a             ; add 1
      ld (de), a        ; write
      inc de
      djnz -
    ex af, af'
--: jr _get_next_mask_7bits

_6x: ; LZ run in reverse order
; 6x oo
; Copy x+3 bytes, starting from -(o+1) and working backwards
; Examples:
; 64 0a
; de = d229
; Copy 7 bytes from $d229 - $0a - 1 = $d21e
; down to $d21e - 6 = $d218 inclusive
      add a, $03            ; b = x+3
      ld b, a
      ld a, (hl)            ; get next byte o
      push hl
        cpl                 ; invert bits
        scf                 ; set carry
        adc a, e            ; hl = de - o
        ld l, a
        ld a, d
        adc a, $FF
        ld h, a
-:      dec hl              ; move back
        ld a, (hl)          ; read byte
        ld (de), a          ; copy to de
        inc de
        djnz -
      pop hl
      inc hl
    ex af, af'
    jr --

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
      ld b, $00
      inc a                 ; increment
      jr z, _0f             ; That'd be $0f originally
      add a, $17            ; a = x+8
      ld c, a               ; that's our count
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldir                  ; copy c bytes total, but allow range 8..263
-:    jr _compressed_real

_0f:
      ld a, (hl)            ; read byte
      inc hl
      inc a                 ; $ff -> double-byte length
      jr z, _0fff
      add a, $1D            ; add 29
      ld c, a
      ld a, $08
      jr nc, _f             ; deal with >255
      inc b
__:   ldi                   ; copy 8 bytes at a time until bc <= 8
      ldi                   ; This allows us to have bc in the range 9..65544 but that can't actually happen?
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      cp c                  ; compare a to c
      jr c, _b
      dec b
      inc b
      jr nz, _b
      ldir
      jr -

_0fff:
      ld c, (hl)
      inc hl
      ld b, (hl)
      inc hl
      ld a, $08
      jr _b

; end of decompress code
