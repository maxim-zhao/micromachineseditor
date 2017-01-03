.memorymap
slotsize 3680
slot 0 $c000
defaultslot 0
.endme
.rombankmap
bankstotal 1
banksize 3680
banks 1
.endro

.include "../../System definitions.inc"

.enum $c000
_RAM_C000_Code dsb $1000
_RAM_D000_AnimatedTiles dsb $07d0
_RAM_D7D0_Unused db
_RAM_D7D1_AnimationCounter db
_RAM_D7D2_AnimationIndex db
_RAM_D7D3_Animation_CharLeft db
_RAM_D7D4_Animation_CharRight db
_RAM_D7D5_Animation_CharLeftIn18 db
_RAM_D7D6_Animation_CharRightIn18 db
_RAM_D7D7_SpriteX db
_RAM_D7D8_Checksum_CalculatedValue dw
_RAM_D7DA_Checksum_PageNumber db
_RAM_D7DB_Checksum_BadFinalBytePageNumber db
_RAM_D7DC_Checksum_Result db
_RAM_D7DD_NoteDataPointer dw
_RAM_D7DF_AttenuationDataPointer dw
_RAM_D7E1_MuteSound db
.ende

.struct CodemastersHeader
PageCount db
Day db
Month db
Year db
Hour db
Minute db
Checksum dw
ChecksumComplement dw
Unused dsb 6
.endst

.enum $7fe0
Header instanceof CodemastersHeader
.ende

    di
    call _LABEL_c0bf_InitaliseAndChecksum
    ; Initialise state
    xor a
    ld (_RAM_D7E1_MuteSound), a
    ld (_RAM_D7D0_Unused), a
    ld (_RAM_D7D1_AnimationCounter), a
    
    ; Animation loop
    ; We loop over 10 things using c...
---:ld c, $00
--: ; The condition for updating stuff seems weird...
    ld a, (_RAM_D7D1_AnimationCounter)
    sub c               ; Subtract between 0 and 30
    sub c
    sub c
    cp $09             ; and check for being less than 10
    jr nc, + ;$c023
    ; This means that when _RAM_D7D1_AnimationCounter is low, we only get here for
    ; low values of c, ut as it gets bigger, we come in here more, and with bigger 
    ; values in a. This gives the sweep effect of the animation?
    push bc
      ; Capture the value (0-9) in b
      ; c is used too
      ld b, a
      call _LABEL_c05e_UpdateTiles           ; Update tile data?
      call _LABEL_ca74_UpdateSound
    pop bc
+:  inc c
    ld a, c
    cp 11             ; Range 0..10 -> loop here
    jr nz, -- ;$c010
    
    ; When c = 11, increment _RAM_D7D1_AnimationCounter
    ld hl, _RAM_D7D1_AnimationCounter
    inc (hl)
    ; Loop until it's $98 = 152
    ld a, (hl)
    cp $98
    jr nz, --- ;$c00e

    call _LABEL_c051_WaitForVBlank

    ; Tilemap 25, 9
    ld a, $72
    out (PORT_VDP_ADDRESS), a
    ld a, $7a
    out (PORT_VDP_ADDRESS), a
    ; "TM"
    ld a, $29
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a

    ; Wait for 150 frames = 3s
    ld b, 150
--: call _LABEL_c051_WaitForVBlank
-:  in a, (PORT_VDP_LINECOUNTER)         ; Then wait for line 0
    and a
    jr nz, - ;$c049
    djnz -- ;$c046
_LABEL_C050_ret: ; Jumped to from elsewhere
    ret

_LABEL_c051_WaitForVBlank:
    push af
-:    in a, (PORT_VDP_LINECOUNTER)
      cp $c0
      jr c, - ;$c052
      cp $d0
      jr nc, - ;$c052
    pop af
    ret

_LABEL_c05e_UpdateTiles:
; b = index in range 0..9 (animation state)
; c = index in range 0..10 (character index)

    ; Look up left edge coordinate for character
    ld e, c
    ld d, $00
    ld hl, _DATA_C9C6_CharacterLeftXs ;$c9c6
    add hl, de

    ; Save animation index
    ld a, b
    ld (_RAM_D7D2_AnimationIndex), a
    
    ; Get character left
    ld a, (hl)
    inc hl
    ld (_RAM_D7D3_Animation_CharLeft), a       ; Value
    ld c, a
    ; Get following value
    ld a, (hl)
    ld (_RAM_D7D4_Animation_CharRight), a       ; `00C070 32 D4 D7 ; Next value
    sub c
    ; Store width in c
    ld c, a
    ; Compute (18 - width)/2 = where char starts in a 18px width
    ld a, 18            ; Compute (18-n)/2
    sub c
    srl a
    ld (_RAM_D7D5_Animation_CharLeftIn18), a
    ; And add the width to get where the char ends in an 18px width
    add a, c             ; +n
    ld (_RAM_D7D6_Animation_CharRightIn18), a
    ; This jump seems unneccessary
    jp _LABEL_C3B6_UpdateTiles_Part2

_LABEL_C084_PrintSpaceThenHexNumber:
    ex af, af'
      ; Leading space
      ld a, $28
      out (PORT_VDP_DATA), a
      ld a, $10
      out (PORT_VDP_DATA), a
    ex af, af'
_LABEL_C08E_PrintHexNumber:
    ld c, a
    ; High digit
    and $f0
    rra
    rra
    rra
    rra
    ; Offset by index of '0'
    add a, $7c
    out (PORT_VDP_DATA), a
    ld a, $10
    out (PORT_VDP_DATA), a
    ; Low digit
    ld a, c
    and $0f
    ; Same again
    add a, $7c
    out (PORT_VDP_DATA), a
    ld a, $10
    out (PORT_VDP_DATA), a
    ret

_DATA_C0A9_VDPRegisters:
.db $36 $80
.db $22 $81
.db $0E $82
.db $FF $83
.db $FF $84
.db $7F $85
.db $00 $86
.db $01 $87
.db $00 $88
.db $00 $89
.db $FF $8A

_LABEL_c0bf_InitaliseAndChecksum:
    ; Initialise music engine data pointers
    ld hl, _DATA_CAEE_NoteData
    ld (_RAM_D7DD_NoteDataPointer), hl
    ld hl, _DATA_CB4F_AttenuationData
    ld (_RAM_D7DF_AttenuationDataPointer), hl
    xor a
    ld (_RAM_D7DC_Checksum_Result), a
    ; Set up VDP registers
    ld hl, _DATA_C0A9_VDPRegisters
    ld bc, $16bf
    otir
    ; Load palette into both halves
    xor a
    out (PORT_VDP_ADDRESS), a
    ld a, $c0
    out (PORT_VDP_ADDRESS), a
    ld hl, _DATA_C9C2_Palette
    ld bc, $04be
    otir
    ld a, $10
    out (PORT_VDP_ADDRESS), a
    ld a, $c0
    out (PORT_VDP_ADDRESS), a
    ld hl, _DATA_C9C2_Palette
    ld bc, $04be
    otir

    ; Set up sprites
    ; Address $7f00 = Y coordinates
    xor a
    out (PORT_VDP_ADDRESS), a
    ld a, $7f
    out (PORT_VDP_ADDRESS), a
    ; Data for two sprites, 8px apart vertically
    ld a, $6f
    out (PORT_VDP_DATA), a
    ld a, $77
    out (PORT_VDP_DATA), a
    ; Zeroes for the rest
    ld b, $7e
    xor a
-:  out (PORT_VDP_DATA), a
    djnz - ;$c108
    ; Next the X coordinates, tile indices
    ld a, $1e
    ld (_RAM_D7D7_SpriteX), a
    out (PORT_VDP_DATA), a
    ld a, $5c
    out (PORT_VDP_DATA), a
    ld a, $28
    out (PORT_VDP_DATA), a
    ld a, $5c
    out (PORT_VDP_DATA), a
    ; Zeroes for the rest
    ld b, $7f
-:  xor a
    out (PORT_VDP_DATA), a
    djnz - ;$c121
    ; VRAM address $0000
    xor a
    out (PORT_VDP_ADDRESS), a
    ld a, $40
    out (PORT_VDP_ADDRESS), a
    xor a

    ; Emit 41 blank tiles (Codemasters logo, not animated in yet)
    ld c, $29
--: ld b, $08
-:  ld a, $ff
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    out (PORT_VDP_DATA), a
    out (PORT_VDP_DATA), a
    djnz - ;$c132
    dec c
    jr nz, -- ;$c130

    ; Then 51 real tiles at 2bpp (Absolutely Brilliant, plus faces)
    ld hl, _DATA_C512_Tiles
    ld a, $33           ; Tile count = 51
    ld d, $00           ; Unused bitplanes
--: ld bc, $18be        ; Counter $18 will count down three times per loop -> 8 rows = 1 tile
-:  outi
    outi
    out (c), d
    out (c), d
    djnz -; $c14c
    dec a
    jr nz, -- ;$c149
    ; Then 48 at 1bpp, assume they come after the previous data (sprite tiles, text)
    ld a, $30
    ld de, $ff00
--: ld bc, $10be
-:  out (c), d
    outi
    out (c), e
    out (c), e
    djnz - ;$c161
    dec a
    jr nz, -- ;$c15e

    ; Next the tilemap
    xor a
    out (PORT_VDP_ADDRESS), a
    ld a, $78
    out (PORT_VDP_ADDRESS), a
    ; Set it all to tile index $28 at high priority
    ld c, 24 ;$18           ; Rows
--: ld b, 32 ;$20           ; Bytes per row
-:  ld a, $28           ; Value
    out (PORT_VDP_DATA), a
    ld a, $10
    out (PORT_VDP_DATA), a
    djnz - ;$c179
    dec c
    jr nz, -- ;$c177
    ; Check buttons pressed includes 1+2
    in a, ($dc)
    and $30
    jp z, _LABEL_C26A_Checksum

    ; If not, carry on...
    ; Draw stuff
    ; Tilemap 6, 9 = top row of CODEMASTERS logo
    ld a, $4c
    out (PORT_VDP_ADDRESS), a
    ld a, $7a
    out (PORT_VDP_ADDRESS), a
    ; Emit tile indices 0, 2, ... $24
    ld bc, $1300
-:  ld a, c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    inc c
    inc c
    djnz - ;$c198
    ; Tilemap 6, 19 = bottom row of CODEMASTERS logo
    ld a, $8c
    out (PORT_VDP_ADDRESS), a
    ld a, $7a
    out (PORT_VDP_ADDRESS), a
    ; Emit tile indices 1, 3, ... $25
    ld bc, $1301
-:  ld a, c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    inc c
    inc c
    djnz - ;$c1ad
    ; Tilemap 6, 14 = top row of Absolutely Brilliant slogan
    ld a, $8c
    out (PORT_VDP_ADDRESS), a
    ld a, $7b
    out (PORT_VDP_ADDRESS), a
    ; Emit $2a, $2b, ... $3d
    ld bc, $142a
-:  ld a, c
    out (PORT_VDP_DATA), a
    ld a, $10           ; High priority
    out (PORT_VDP_DATA), a
    inc c
    djnz - ;$c1c2
    ; Tilemap 6, 15 = bottom row of Absolutely Brilliant slogan
    ld a, $cc
    out (PORT_VDP_ADDRESS), a
    ld a, $7b
    out (PORT_VDP_ADDRESS), a
    ; Emit $3e, $3f, ... $51
    ld b, $14
-:  ld a, c
    out (PORT_VDP_DATA), a
    ld a, $10
    out (PORT_VDP_DATA), a
    inc c
    djnz - ;$c1d6
    ; Tilemap 15, 16 = descender of Absolutely Brilliant slogan
    ld a, $1e
    out (PORT_VDP_ADDRESS), a
    ld a, $7c
    out (PORT_VDP_ADDRESS), a
    ; Emit $52, $53
    ld a, c
    inc c
    out (PORT_VDP_DATA), a
    ld a, $10
    out (PORT_VDP_DATA), a
    ld a, c
    inc c
    out (PORT_VDP_DATA), a
    ld a, $10
    out (PORT_VDP_DATA), a
    ; Emit tiles from $5e...
    ld c, $5e
    ; Tilemap 6, 22 = copyright text
    ld a, $8c
    out (PORT_VDP_ADDRESS), a
    ld a, $7d
    out (PORT_VDP_ADDRESS), a
    ; Emit 20 tiles "(c) CODEMASTERS SOFTWARE"
    ld b, $14
-:  ld a, c
    inc c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    djnz - ;$c204
    ; Tilemap 9, 23 = copyright text
    ld a, $d2
    out (PORT_VDP_ADDRESS), a
    ld a, $7d
    out (PORT_VDP_ADDRESS), a
    ; Emit 10 tiles "COMPANY LTD"
    ld b, $0a
-:  ld a, c
    inc c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    djnz - ;$c217
    ; Emit year using the number tiles
    ; First the 19...
    ld hl, _DATA_C510_CenturyDigits
    ld b, $02
-:  ld a, (hl)
    inc hl
    add a, c             ; Points at the digit 0 now
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    djnz - ;$c225
    ; Read the rest of the year out of the Codemasters header
    ld a, (Header.Year)
    ld b, a
    srl a
    srl a
    srl a
    srl a
    add a, c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ld a, b
    and $0f
    add a, c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ; Generate the animated tiles source in its initial state
    ld hl, _RAM_D000_AnimatedTiles
    ld bc, $0130        ; = 38 tiles
    ; Emit one row
-:  ld (hl), $ff
    inc hl
    ld (hl), $00
    inc hl
    ld (hl), $00
    inc hl
    ld (hl), $00
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, - ;$c250
    ; Screen on
    ld a, $62
    out (PORT_VDP_REGISTER), a
    ld a, $81
    out (PORT_VDP_REGISTER), a
    ret

_LABEL_C26A_Checksum:
; Checksums the data and draws to the screen if it's bad
    xor a
    ld (_RAM_D7DA_Checksum_PageNumber), a
    ld (_RAM_D7DB_Checksum_BadFinalBytePageNumber), a
    ld hl, $0000
    ld (_RAM_D7D8_Checksum_CalculatedValue), hl
-:  ld a, (_RAM_D7DA_Checksum_PageNumber)
    ld ($8000), a
    call _LABEL_c4dd_AddPageToChecksum
    ; Check last byte of page matches the page number, for pages >=2
    ld hl, _RAM_D7DA_Checksum_PageNumber
    ld a, (hl)
    cp $02
    jr c, + ;$c297
    ld a, ($bfff)
    cp (hl)
    jr z, + ;$c297
    ; Save the offending value to RAM
    ld a, (hl)
    ld (_RAM_D7DB_Checksum_BadFinalBytePageNumber), a
    ; Set the result to >1
    ld a, $ff
    ld (_RAM_D7DC_Checksum_Result), a
+:  inc (hl)            ; Next page
    ; check if we have reached the page count (stored in the Codemasters header)
    ld b, (hl)
    ld a, (Header.PageCount)
    cp b
    jr nz, - ;$c277        ; loop until we do

    ; Now time to draw stuff
    ; VRAM address 8, 5
    ld a, $50
    out (PORT_VDP_ADDRESS), a
    ld a, $79
    out (PORT_VDP_ADDRESS), a
    ; "C"
    ld a, $88
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ; The calculated checksum
    ld a, (_RAM_D7D8_Checksum_CalculatedValue+1)
    call _LABEL_C084_PrintSpaceThenHexNumber
    ld a, (_RAM_D7D8_Checksum_CalculatedValue)
    call _LABEL_C08E_PrintHexNumber
    ; Check if it's right
    ld hl, (_RAM_D7D8_Checksum_CalculatedValue)
    ld bc, (Header.Checksum)
    and a
    sbc hl, bc
    jr z, + ;$c2cb
    ; Set the result to 1
    ld a, $01
    ld (_RAM_D7DC_Checksum_Result), a
+:  ; VRAM address 8, 7
    ld a, $d0
    out (PORT_VDP_ADDRESS), a
    ld a, $79
    out (PORT_VDP_ADDRESS), a
    ; "D"
    ld a, $89
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ; The timestamp
    ld a, (Header.Day)
    call _LABEL_C084_PrintSpaceThenHexNumber
    ld a, (Header.Month)
    call _LABEL_C084_PrintSpaceThenHexNumber
    ld a, (Header.Year)
    call _LABEL_C084_PrintSpaceThenHexNumber
    ld a, (Header.Hour)
    call _LABEL_C084_PrintSpaceThenHexNumber
    ld a, (Header.Minute)
    call _LABEL_C084_PrintSpaceThenHexNumber
    ; Print the detected bad page number if non-zero
    ld a, (_RAM_D7DB_Checksum_BadFinalBytePageNumber)
    and a
    jr z, + ;$c313
    ; Tilemap address 8, 9
    ld a, $50
    out (PORT_VDP_ADDRESS), a
    ld a, $7a
    out (PORT_VDP_ADDRESS), a
    ; "B"
    ld a, $87
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ld a, (_RAM_D7DB_Checksum_BadFinalBytePageNumber)
    call _LABEL_C084_PrintSpaceThenHexNumber
+:  ; VRAM address 15, 12
    ld a, $1e
    out (PORT_VDP_ADDRESS), a
    ld a, $7b
    out (PORT_VDP_ADDRESS), a
    ; Tile index of happy face
    ld c, $54
    ld a, (_RAM_D7DC_Checksum_Result)
    and a
    jr z, + ;$c327
    ; Increment to point at the sad/sick face
    inc c
    inc c
    inc c
    inc c
+:  ; Emit two tiles
    ld a, c
    inc c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ld a, c
    inc c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ; VRAM address 15, 13
    ld a, $5e
    out (PORT_VDP_ADDRESS), a
    ld a, $7b
    out (PORT_VDP_ADDRESS), a
    ; Emit two more tiles
    ld a, c
    inc c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ld a, c
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    ; Change the palette to match the result
    ld a, (_RAM_D7DC_Checksum_Result)
    and a
    jr nz, + ;$c388
    ; Palette index 1
    ld a, $01
    out (PORT_VDP_ADDRESS), a
    ld a, $c0
    out (PORT_VDP_ADDRESS), a
    ; Green
    ld a, %001100
    ; Palette index $11
    out (PORT_VDP_DATA), a
    ld a, $11
    out (PORT_VDP_ADDRESS), a
    ld a, $c0
    out (PORT_VDP_ADDRESS), a
    ; Green
    ld a, %001100
    out (PORT_VDP_DATA), a
    ; Turn on screen
    ld a, $62
    out (PORT_VDP_REGISTER), a
    ld a, $81
    out (PORT_VDP_REGISTER), a
    ; Leave it showing while a button is pressed
-:  in a, ($dc)         ; Player 1 controls
    or $c0
    cp $ff
    jr nz, - ;$c370        ; Loop while anything pressed - delays starting the timeout
    ; Then wait 256 frames = ~5s
    ld b, $00
--: call _LABEL_c051_WaitForVBlank
-:  in a, (PORT_VDP_LINECOUNTER)
    and a
    jr nz, - ;$c37d
    djnz -- ;$c37a
    ; Not sure why this is - trying to discard the return address? This stops it returning to the normal intro
    pop bc
    ; Then return to the next address up the stack - probably the caller of $c000.
    ; This doesn't work when the caller was in paged code - because we do not restore the page.
    ; In Micro Machines, this ends up in some code that gets stuck doing nothing much.
    jp _LABEL_C050_ret
    
    
+:  ; Bad result
    ; Palette index 1
    ld a, $01
    out (PORT_VDP_ADDRESS), a
    ld a, $c0
    out (PORT_VDP_ADDRESS), a
    ; Red
    ld a, %000011
    out (PORT_VDP_DATA), a
    ; Palette index $11
    ld a, $11
    out (PORT_VDP_ADDRESS), a
    ld a, $c0
    out (PORT_VDP_ADDRESS), a
    ; Red
    ld a, %000011
    out (PORT_VDP_DATA), a
    ; Screen on
    ld a, $62
    out (PORT_VDP_ADDRESS), a
    ld a, $81
    out (PORT_VDP_ADDRESS), a
    ; Play a sound
    ld a, $8f
    out (PORT_PSG), a
    ld a, $3f
    out (PORT_PSG), a
    ld a, $90
    out (PORT_PSG), a
    ; Hang forever
-:  jr - ;$c3b4

_LABEL_C3B6_UpdateTiles_Part2:
    ; Look up row in animation table
    ld a, (_RAM_D7D2_AnimationIndex)       ; Get value
    ld e, a             ; -> de
    ld d, $00
    ld h, d             ; -> hl
    ld l, e
    add hl, hl           ; Multiply by 18
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld de, _DATA_C9D2_AnimationXValues
    add hl, de
    ; Now pointing at the 18 bytes for _RAM_D7D2_AnimationIndex
    ; Move on by _RAM_D7D5_Animation_CharLeftIn18
    ld a, (_RAM_D7D5_Animation_CharLeftIn18)
    ld c, a
    ld b, $00
    add hl, bc
    ld b, h             ; -> bc
    ld c, l
    
    ; Get character left X (saved in l)
    ld a, (_RAM_D7D3_Animation_CharLeft)
    ld l, a
-:  ; Read animation value -> h
    ld a, (bc)
    ld h, a
    ld a, h
    ; Check for $ff
    inc a
    jr z, + ;$c3fd
    ; If not $ff, compare to _RAM_D7D5_Animation_CharLeftIn18
    ld a, (_RAM_D7D5_Animation_CharLeftIn18)
    ld d, a
    ld a, h
    cp d
    jr c, + ;$c3fd
    ; If larger or equal, compare to _RAM_D7D6_Animation_CharRightIn18
    ld a, (_RAM_D7D6_Animation_CharRightIn18)
    ld d, a
    ld a, h
    cp d
    jr nc, + ;$c3fd
    ; If smaller or equal, add on the animation value to offset it
    ld a, (_RAM_D7D3_Animation_CharLeft)
    add a, h
    ld h, a
    ; Then subtract the char left
    ; This is a wacky way to do it...
    ld a, (_RAM_D7D5_Animation_CharLeftIn18)
    cpl
    inc a
    add a, h
    ld h, a
    ; Now it's selected the column, let's draw it
    push bc
    push hl
      call _LABEL_C442_UpdateTileAnimation
    pop hl
    pop bc
+:  ; Move on to next column
    inc bc
    ; And next source column
    inc l
    ; Loop until we get to the end
    ld a, (_RAM_D7D4_Animation_CharRight)
    cp l
    jr nz, - ;$c3d4
    
    ; Round the X value down to a multiple of 8 (to get a tile X)
    ld a, (_RAM_D7D3_Animation_CharLeft)
    and $f8
    ; Then add $1a00 and multiply by 8 to get a tile index + $d000
    ; This is the address in _RAM_D000_AnimatedTiles
    ld l, a
    ld h, $1a
    add hl, hl
    add hl, hl
    add hl, hl
    ; Then put it in de and adjust to $4xxx to be the destination VRAM address
    ld e, l
    ld a, h
    sub $d0
    add a, $40
    ld d, a

    call _LABEL_c051_WaitForVBlank

    ; Sprite table
    ld a, $80
    out (PORT_VDP_ADDRESS), a
    ld a, $7f
    out (PORT_VDP_ADDRESS), a
    ; Move sprite right by 2px
    ld a, (_RAM_D7D7_SpriteX)
    add a, $02
    ld (_RAM_D7D7_SpriteX), a
    ld b, a
    out (PORT_VDP_DATA), a
    ; Sprite index
    ld a, $5c
    out (PORT_VDP_DATA), a
    ; Next sprite X is -2
    ld a, b
    sub $02
    out (PORT_VDP_DATA), a
    ; Leave index as written

    ; Set VRAM address for tile animation upload
    ld a, e
    out (PORT_VDP_ADDRESS), a
    ld a, d
    out (PORT_VDP_ADDRESS), a
    ; Emit $c0 bytes = 6 tiles from hl
    ld bc, $c0be
    otir
    ret

_LABEL_C442_UpdateTileAnimation:
; h = index in tile width (18px) to draw from
; l = source column number (0-151)
    ; Convert to bitmask for bit in source byte
    ld a, l
    and $07
    add a, <_DATA_c508_IndexToBitFromLeft
    ld c, a
    ld b, >_DATA_c508_IndexToBitFromLeft
    ld a, (bc)
    ld b, a

    ; de = h * 8 + _DATA_CC00_CodemastersLogo
    ld e, h
    xor a
    sla e
    rla
    sla e
    rla
    add a, >_DATA_CC00_CodemastersLogo ;$cc
    ld d, a
    
    ; hl = location of tile in _RAM_D000_AnimatedTiles for l
    ld a, l
    and $f8             ; Round down to multiple of 8
    ld l, a
    ld h, $1a           ; $d0 / 8
    add hl, hl
    add hl, hl
    add hl, hl
    call _LABEL_C469_EmitDataForOneSourceByte
    call _LABEL_C469_EmitDataForOneSourceByte
    call _LABEL_C469_EmitDataForOneSourceByte
_LABEL_C469_EmitDataForOneSourceByte:
    ; read source byte
    ld a, (de)
    ld c, a
    inc de
    rl c
    jr nc, + ;$c474
    ; 1 -> 
    ld a, (hl)
    or b
    jr ++ ;$c477
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    rl c
    jr nc, + ;$c481
    ld a, (hl)
    or b
    jr ++ ;$c484
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    inc hl
    inc hl
    rl c
    jr nc, + ;$c490
    ld a, (hl)
    or b
    jr ++ ;$c493
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    rl c
    jr nc, + ;$c49d
    ld a, (hl)
    or b
    jr ++ ;$c4a0
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    inc hl
    inc hl
    rl c
    jr nc, + ;$c4ac
    ld a, (hl)
    or b
    jr ++ ;$c4af
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    rl c
    jr nc, + ;$c4b9
    ld a, (hl)
    or b
    jr ++ ;$c4bc
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    inc hl
    inc hl
    rl c
    jr nc, + ;$c4c8
    ld a, (hl)
    or b
    jr ++ ;$c4cb
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    rl c
    jr nc, + ;$c4d5
    ld a, (hl)
    or b
    jr ++ ;$c4d8
+:  ld a, b
    cpl
    and (hl)
++: ld (hl), a
    inc hl
    inc hl
    inc hl
    ret

_LABEL_c4dd_AddPageToChecksum:
    ld de, $8000        ; Start address
    ld bc, $2000        ; Byte count - only 8K?
    ld a, (_RAM_D7DA_Checksum_PageNumber)
    cp $01
    jr nz, + ;$c4ed
    ld bc, $1ff8        ; Reduced for page 1?
+:  exx
      ld hl, (_RAM_D7D8_Checksum_CalculatedValue)
    exx
-:  ld a, (de)          ; Get byte
    inc de
    exx
      ld e, a
    exx
    ld a, (de)
    inc de
    exx
      ld d, a
      add hl, de
    exx
    dec bc
    ld a, b
    or c
    jr nz, - ;$c4f2
    exx
      ld (_RAM_D7D8_Checksum_CalculatedValue), hl
    exx
    ret

_DATA_c508_IndexToBitFromLeft: ; Maps 0 -> bit 7, 1 -> bit 6, ...
.db $80 $40 $20 $10 $08 $04 $02 $01

_DATA_C510_CenturyDigits: ; Used to draw the copyright date
.db $01 $09

_DATA_C512_Tiles: 
; 2bpp -> 16 bytes per tile
.incbin "TM.2bpp"
.incbin "AbsolutelyBrilliantPart1.2bpp"
.incbin "AbsolutelyBrilliantPart2.2bpp"
.incbin "Faces.2bpp"
; 1bpp -> 8 bytes per tile
.incbin "Sprites.1bpp"
.incbin "Copyright.1bpp"
.incbin "HexCharacters.1bpp"

_DATA_C9C2_Palette:
  SMSCOLOUR $000000
  SMSCOLOUR $aa00aa
  SMSCOLOUR $ffaaff
  SMSCOLOUR $ffffff

_DATA_C9C6_CharacterLeftXs:
.db $00 $0E $1D $2B $39 $4B $59 $63 $71 $7E $8D $97 ; 151px total
;   C   O   D   E   M   A   S   T   E   R   S   (end)
; Widths (decimal):
;   14  15  14  14  18  14  10  14  13  15  10

_DATA_C9D2_AnimationXValues: ; 18 bytes per entry
; Corresponds to the x-coordinates within an 18px bitmap to select for animation purposes?
.db $FF $FF $FF $FF $FF $FF $FF $FF $05 $FF $FF $FF $FF $FF $FF $FF $FF $FF 
.db $FF $FF $FF $FF $FF $FF $FF $03 $05 $0C $0E $FF $FF $FF $FF $FF $FF $FF 
.db $FF $FF $FF $FF $00 $02 $04 $06 $07 $0A $0B $0D $0F $11 $FF $FF $FF $FF 
.db $FF $FF $FF $00 $01 $03 $04 $06 $07 $0A $0B $0D $0E $10 $11 $FF $FF $FF 
.db $FF $FF $00 $01 $03 $04 $06 $07 $08 $09 $0A $0B $0C $0E $0F $11 $FF $FF 
.db $FF $00 $01 $02 $03 $05 $06 $07 $08 $09 $0A $0B $0C $0E $0F $10 $11 $FF 
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 ; Last three are the same
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11


_LABEL_ca74_UpdateSound:
    ld a, (_RAM_D7E1_MuteSound)
    or a
    jr nz, + ;+$1f ;$ca99

    ; Zero - play sound

    ; Get next note
    ld hl, (_RAM_D7DD_NoteDataPointer)
    ld a, (hl)
    inc hl
    ld (_RAM_D7DD_NoteDataPointer), hl

    ; Play note - 10 on channel 0
    ld e, $80
    sub $0a
    call _LABEL_CACA_SetPSGFrequency
    ; Next value
    ld a, (hl)
    ; Play note - 8 on channel 1
    sub $08
    ld e, $a0
    call _LABEL_CACA_SetPSGFrequency
    ; Check if it was $80
    ld a, (hl)
    cp $80
    jr nz, ++ ;$caaa
    
    ; If so, stop sound
    
    ld (_RAM_D7E1_MuteSound), a
+:  ; Silence PSG
    ld a, $9f
    out (PORT_PSG), a
    ld a, $bf
    out (PORT_PSG), a
    ld a, $df
    out (PORT_PSG), a
    ld a, $ff
    out (PORT_PSG), a
    ret

++: ; Else, play note - 6 on channel 2
    ld e, $c0
    sub $06
    call _LABEL_CACA_SetPSGFrequency
    
    ; Then get volume data
    ; Set volumes at positions n, n+1, n+2 to channels 0-2
    ; but only increment the pointer by 1 each time
    ld hl, (_RAM_D7DF_AttenuationDataPointer)
    ld a, (hl)
    or $90
    out (PORT_PSG), a
    inc hl
    ld (_RAM_D7DF_AttenuationDataPointer), hl
    ld a, (hl)
    or $b0
    out (PORT_PSG), a
    inc hl
    ld a, (hl)
    or $d0
    out (PORT_PSG), a
    inc hl
    ret

_LABEL_CACA_SetPSGFrequency:
; a = note index
; e = channel mask
    push hl
      ; Look up wavelength from a
      add a, a
      ld c, a
      ld b, $00
      ld hl, _DATA_CBB1_PSGFrequencyLookup ;$cbb1
      add hl, bc
      ld a, (hl)          ; LSB
      ld b, a
      inc hl
      ld c, (hl)          ; MSB
      ; Shift data into the right place
      rla
      rl c
      rla
      rl c
      rla
      rl c
      rla
      rl c
      ld a, b
      and $0f
      ; Select channel
      or e
      ; Emit
      out (PORT_PSG), a
      ld a, c
      out (PORT_PSG), a
    pop hl
    ret

_DATA_CAEE_NoteData:
; PSG notes, 12TET
; Higher values are higher notes
; Approximately a ramp from 10 to 25, then flat, overlaid by some funny shaped vibrato.
.db $0A $0B $0C $0D $0C $0B $0A $0C
.db $0E $10 $0E $0C $0E $0F $10 $11
.db $10 $0F $0E $10 $12 $14 $12 $10
.db $12 $13 $14 $15 $14 $13 $12 $14
.db $16 $18 $16 $14 $16 $17 $18 $19
.db $18 $17 $16 $18 $1A $1C $1A $18
.db $16 $17 $18 $19 $18 $17 $16 $18
.db $1A $1C $1A $18 $16 $17 $18 $19
.db $18 $17 $16 $18 $1A $1C $1A $18
.db $16 $17 $18 $19 $18 $17 $16 $18
.db $1A $1C $1A $18 $16 $17 $18 $19
.db $18 $17 $16 $18 $1A $1C $1A $18
.db $80

_DATA_CB4F_AttenuationData:
; Note attenuations (F = quiet)
; This describes a volume envelope with a fast attack and then exponential decay.
.db $0F $0F $0B $0A $09 $08 $07 $06
.db $05 $04 $03 $02 $01 $00 $00 $00
.db $00 $00 $00 $00 $01 $01 $01 $01
.db $01 $01 $02 $02 $02 $02 $02 $02
.db $03 $03 $03 $03 $03 $03 $04 $04
.db $04 $04 $04 $04 $05 $05 $05 $05
.db $05 $05 $06 $06 $06 $06 $06 $06
.db $07 $07 $07 $07 $07 $07 $08 $08
.db $08 $08 $08 $08 $09 $09 $09 $09
.db $09 $09 $0A $0A $0A $0A $0A $0A
.db $0B $0B $0B $0B $0B $0B $0C $0C
.db $0C $0D $0D $0D $0E $0E $0E $0F
.db $0F $0F 

_DATA_CBB1_PSGFrequencyLookup:
; Values from A3 (220Hz)
;      A    G#     G    F#     F     E    D#     D    C#     C     B    A# 
.dw                                           $02A7 $0281 $025D $023B $021B 
.dw $01FC $01E0 $01C5 $01AC $0194 $017D $0168 $0153 $0140 $012E $011D $010D 
.dw $00FE $00F0 $00E2 $00D6 $00CA $00BE $00B4 $00AA $00A0 $0097 $008F $0087 
.dw $007F 

_DATA_CBED_: ; Unused? Filling gap up to an aligned table
.dsb 19 $3D

_DATA_CC00_CodemastersLogo:
; 2bpp data for a 252x16 bitmap
; Each four bytes include data for one column, from left to right.
; Within each four bytes, the bits read left to right in pairs give the
; values for each pixel from bottom to top in the colummn.
; However, indexes 1 (%01) and 2 (%10) seem to be swapped?
.db $AA $9F $F6 $AA
.db $AB $FF $FF $6A
.db $AF $FF $FF $DA
.db $BD $AA $A9 $FA
.db $50 $00 $00 $1C
.db $C2 $AA $AA $AC
.db $4A $AA $AA $AC
.db $4A $AA $AA $AC
.db $CA $AA $AA $AC
.db $7A $AA $AA $98
.db $BE $AA $AA $B0
.db $7F $EA $AA $42
.db $AA $82 $AA $0A
.db $80 $0A $AA $AA
.db $AA $7F $D6 $AA
.db $AB $FF $FF $AA
.db $AF $FF $FF $EA
.db $BD $AA $A9 $FA
.db $50 $00 $00 $14
.db $C2 $AA $AA $AC
.db $4A $AA $AA $A4
.db $CA $AA $AA $AC
.db $DA $AA $AA $9C
.db $BE $AA $A9 $F8
.db $9F $FF $FF $D0
.db $A7 $FF $FF $42
.db $AA $7F $F6 $0A
.db $AA $25 $A0 $2A
.db $AA $A0 $02 $AA
.db $EA $AA $AA $AC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $C0 $00 $00 $0C
.db $CA $AA $AA $AC
.db $CA $AA $AA $AC
.db $EA $AA $AA $9C
.db $7E $AA $A9 $F8
.db $BF $FF $FF $D0
.db $AF $FF $FF $42
.db $A9 $FF $F6 $0A
.db $AA $0A $80 $2A
.db $AA $A8 $0A $AA
.db $EA $AA $AA $AC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $C0 $06 $00 $0C
.db $CA $A6 $2A $AC
.db $CA $AF $2A $AC
.db $CA $7F $EA $AC
.db $EA $AA $A0 $AC
.db $F6 $80 $02 $BC
.db $55 $AA $A9 $F4
.db $80 $0A $AA $00
.db $AA $AA $A8 $2A
.db $AA $AA $AA $AA
.db $EA $AA $AA $AC
.db $FD $55 $55 $7C
.db $FF $A0 $00 $2C
.db $FF $F6 $AA $A8
.db $BF $FF $DA $A8
.db $89 $FF $FD $AA
.db $AA $27 $FF $FA
.db $AA $A0 $9F $D8
.db $AA $AA $AD $00
.db $AA $A9 $D8 $2A
.db $AA $96 $00 $AA
.db $A7 $60 $2A $A6
.db $7F $55 $55 $7C
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $DA $AA $AA $9C
.db $40 $00 $00 $04
.db $8A $AA $AA $A8
.db $AA $AA $AA $AC
.db $AA $AA $AA $5C
.db $AA $AA $9D $84
.db $AA $A9 $6E $08
.db $AA $58 $0E $2A
.db $A7 $E0 $AE $2A
.db $7F $FF $6E $2A
.db $89 $FF $FD $A4
.db $A8 $27 $FF $FC
.db $AA $A0 $9F $FC
.db $AA $AA $82 $7C
.db $AA $AA $AA $0C
.db $AA $AA $AA $A8
.db $AA $AA $AA $A8
.db $A7 $FA $A9 $F4
.db $BF $FE $A8 $B4
.db $E0 $FF $AA $AC
.db $C2 $BF $6A $A4
.db $4A $BF $EA $AC
.db $CA $9F $DA $AC
.db $7A $AF $FD $78
.db $BD $AB $FF $D0
.db $AA $88 $95 $82
.db $80 $0A $80 $0A
.db $55 $AA $AA $AA
.db $F6 $0A $AA $AA
.db $E0 $2A $AA $AA
.db $C2 $AA $AA $AA
.db $EA $AA $AA $AC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $C0 $00 $00 $2C
.db $CA $AA $AA $A8
.db $DA $AA $AA $A8
.db $FE $AA $AA $AA
.db $AA $AA $AA $AA
.db $80 $0A $AA $AA
.db $EA $AA $AA $AC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $C0 $06 $00 $0C
.db $CA $A6 $2A $AC
.db $CA $AF $2A $AC
.db $CA $7F $EA $AC
.db $EA $AA $A0 $AC
.db $F6 $80 $02 $BC
.db $55 $AA $A9 $F4
.db $80 $0A $AA $00
.db $AA $AA $A8 $2A
.db $EA $AA $AA $AC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $FF $FF $FF $FC
.db $C0 $0B $00 $2C
.db $CA $AB $6A $A8
.db $CA $A7 $FE $A8
.db $FA $9F $FF $6A
.db $BF $FC $BF $F6
.db $BF $F8 $87 $FC
.db $A7 $60 $AA $FC
.db $A8 $02 $AA $1C
.db $AA $AA $AA $A8
.db $AA $AA $AA $A8
.db $AA $AA $AA $A8
.db $A7 $FA $A9 $F4
.db $BF $FE $A8 $B4
.db $E0 $FF $AA $AC
.db $C2 $BF $6A $A4
.db $4A $BF $EA $AC
.db $CA $9F $DA $AC
.db $7A $AF $FD $78
.db $BD $AB $FF $D0
.db $AA $88 $95 $82
.db $80 $0A $80 $0A
.db $AA $AA $AA $AA ; Last column is blank, unused