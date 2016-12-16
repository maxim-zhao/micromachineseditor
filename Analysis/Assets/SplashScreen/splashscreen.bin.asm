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
_RAM_D7D3_ db
_RAM_D7D4_ db
_RAM_D7D5_ db
_RAM_D7D6_ db
_RAM_D7D7_SpriteX db
_RAM_D7D8_Checksum_CalculatedValue dw
_RAM_D7DA_Checksum_PageNumber db
_RAM_D7DB_Checksum_BadFinalBytePageNumber db
_RAM_D7DC_Checksum_Result db
_RAM_D7DD_ dw
_RAM_D7DF_ dw
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

    di                  ; 00C000 F3
    call _LABEL_c0bf_InitaliseAndChecksum           ; 00C001 CD BF C0
    ; Initialise state
    xor a               ; 00C004 AF
    ld (_RAM_D7E1_MuteSound), a       ; 00C005 32 E1 D7
    ld (_RAM_D7D0_Unused), a       ; 00C008 32 D0 D7
    ld (_RAM_D7D1_AnimationCounter), a       ; 00C00B 32 D1 D7
---:ld c, $00           ; 00C00E 0E 00
--: ld a, (_RAM_D7D1_AnimationCounter)       ; 00C010 3A D1 D7
    sub c               ; 00C013 91 ; Subtract between 0 and 33
    sub c               ; 00C014 91
    sub c               ; 00C015 91
    cp $09             ; 00C016 FE 09
    jr nc, + ;$c023        ; 00C018 30 09
    push bc              ; 00C01A C5
      ld b, a             ; 00C01B 47
      call _LABEL_c05e_UpdateTiles           ; 00C01C CD 5E C0 ; Update tile data?
      call _LABEL_ca74_UpdateSound           ; 00C01F CD 74 CA
    pop bc              ; 00C022 C1
+:  inc c               ; 00C023 0C
    ld a, c             ; 00C024 79
    cp 11             ; 00C025 FE 0B ; Range 0..10 -> loop here
    jr nz, -- ;$c010        ; 00C027 20 E7
    ; When c = 11, increment _RAM_D7D1_AnimationCounter
    ld hl, _RAM_D7D1_AnimationCounter        ; 00C029 21 D1 D7
    inc (hl)            ; 00C02C 34
    ; Loop until it's $98 = 152
    ld a, (hl)          ; 00C02D 7E
    cp $98             ; 00C02E FE 98
    ; Then start all over again
    jr nz, --- ;$c00e        ; 00C030 20 DC

    call _LABEL_c051_WaitForVBlank           ; 00C032 CD 51 C0

    ; Tilemap 25, 9
    ld a, $72           ; 00C035 3E 72
    out (PORT_VDP_ADDRESS), a         ; 00C037 D3 BF
    ld a, $7a           ; 00C039 3E 7A
    out (PORT_VDP_ADDRESS), a         ; 00C03B D3 BF
    ; "TM"
    ld a, $29           ; 00C03D 3E 29
    out (PORT_VDP_DATA), a         ; 00C03F D3 BE
    xor a               ; 00C041 AF
    out (PORT_VDP_DATA), a         ; 00C042 D3 BE

    ; Wait for 150 frames = 3s
    ld b, 150           ; 00C044 06 96
--: call _LABEL_c051_WaitForVBlank           ; 00C046 CD 51 C0
-:  in a, (PORT_VDP_LINECOUNTER)         ; 00C049 DB 7E ; Then wait for line 0
    and a               ; 00C04B A7
    jr nz, - ;$c049        ; 00C04C 20 FB
    djnz -- ;$c046           ; 00C04E 10 F6
_LABEL_C050_ret: ; Jumped to from elsewhere
    ret ; 00C050 C9

_LABEL_c051_WaitForVBlank:
    push af              ; 00C051 F5
-:    in a, (PORT_VDP_LINECOUNTER)         ; 00C052 DB 7E
      cp $c0             ; 00C054 FE C0
      jr c, - ;$c052         ; 00C056 38 FA
      cp $d0             ; 00C058 FE D0
      jr nc, - ;$c052        ; 00C05A 30 F6
    pop af              ; 00C05C F1
    ret ; 00C05D C9

_LABEL_c05e_UpdateTiles:
; c = index in range 0..11
    ld e, c             ; 00C05E 59
    ld d, $00           ; 00C05F 16 00
    ld hl, _DATA_C9C6_ ;$c9c6        ; 00C061 21 C6 C9
    add hl, de           ; 00C064 19
    ld a, b             ; 00C065 78
    ld (_RAM_D7D2_AnimationIndex), a       ; 00C066 32 D2 D7
    ld a, (hl)          ; 00C069 7E
    inc hl              ; 00C06A 23
    ld (_RAM_D7D3_), a       ; 00C06B 32 D3 D7 ; Value
    ld c, a             ; 00C06E 4F
    ld a, (hl)          ; 00C06F 7E
    ld (_RAM_D7D4_), a       ; `00C070 32 D4 D7 ; Next value
    sub c               ; 00C073 91
    ld c, a             ; 00C074 4F ; Delta
    ld a, $12           ; 00C075 3E 12 ; Compute (12-n)*2
    sub c               ; 00C077 91
    srl a               ; 00C078 CB 3F
    ld (_RAM_D7D5_), a       ; 00C07A 32 D5 D7
    add a, c             ; 00C07D 81  ; +n
    ld (_RAM_D7D6_), a       ; 00C07E 32 D6 D7
    ; No use to split?
    jp _LABEL_C3B6_UpdateTiles_Part2           ; 00C081 C3 B6 C3

_LABEL_C084_PrintSpaceThenHexNumber:
    ex af, af'          ; 00C084 08
      ; Leading space
      ld a, $28           ; 00C085 3E 28
      out (PORT_VDP_DATA), a         ; 00C087 D3 BE
      ld a, $10           ; 00C089 3E 10
      out (PORT_VDP_DATA), a         ; 00C08B D3 BE
    ex af, af'          ; 00C08D 08
_LABEL_C08E_PrintHexNumber:
    ld c, a             ; 00C08E 4F
    ; High digit
    and $f0             ; 00C08F E6 F0
    rra ; 00C091 1F
    rra ; 00C092 1F
    rra ; 00C093 1F
    rra ; 00C094 1F
    ; Offset by index of '0'
    add a, $7c           ; 00C095 C6 7C
    out (PORT_VDP_DATA), a         ; 00C097 D3 BE
    ld a, $10           ; 00C099 3E 10
    out (PORT_VDP_DATA), a         ; 00C09B D3 BE
    ; Low digit
    ld a, c             ; 00C09D 79
    and $0f             ; 00C09E E6 0F
    ; Same again
    add a, $7c           ; 00C0A0 C6 7C
    out (PORT_VDP_DATA), a         ; 00C0A2 D3 BE
    ld a, $10           ; 00C0A4 3E 10
    out (PORT_VDP_DATA), a         ; 00C0A6 D3 BE
    ret ; 00C0A8 C9

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
    ; Initialise music engine stuff
    ld hl, _DATA_CAEE_Notes        ; 00C0BF 21 EE CA
    ld (_RAM_D7DD_), hl      ; 00C0C2 22 DD D7
    ld hl, _DATA_CB4F_        ; 00C0C5 21 4F CB
    ld (_RAM_D7DF_), hl      ; 00C0C8 22 DF D7
    xor a               ; 00C0CB AF
    ld (_RAM_D7DC_Checksum_Result), a       ; 00C0CC 32 DC D7
    ; Set up VDP registers
    ld hl, _DATA_C0A9_VDPRegisters        ; 00C0CF 21 A9 C0
    ld bc, $16bf        ; 00C0D2 01 BF 16
    otir ; 00C0D5 ED B3
    ; Load palette into both halves
    xor a               ; 00C0D7 AF
    out (PORT_VDP_ADDRESS), a         ; 00C0D8 D3 BF
    ld a, $c0           ; 00C0DA 3E C0
    out (PORT_VDP_ADDRESS), a         ; 00C0DC D3 BF
    ld hl, _DATA_C9C2_Palette        ; 00C0DE 21 C2 C9
    ld bc, $04be        ; 00C0E1 01 BE 04
    otir ; 00C0E4 ED B3
    ld a, $10           ; 00C0E6 3E 10
    out (PORT_VDP_ADDRESS), a         ; 00C0E8 D3 BF
    ld a, $c0           ; 00C0EA 3E C0
    out (PORT_VDP_ADDRESS), a         ; 00C0EC D3 BF
    ld hl, _DATA_C9C2_Palette        ; 00C0EE 21 C2 C9
    ld bc, $04be        ; 00C0F1 01 BE 04
    otir ; 00C0F4 ED B3

    ; Set up sprites
    ; Address $7f00 = Y coordinates
    xor a               ; 00C0F6 AF
    out (PORT_VDP_ADDRESS), a         ; 00C0F7 D3 BF
    ld a, $7f           ; 00C0F9 3E 7F
    out (PORT_VDP_ADDRESS), a         ; 00C0FB D3 BF
    ; Data for two sprites, 8px apart vertically
    ld a, $6f           ; 00C0FD 3E 6F
    out (PORT_VDP_DATA), a         ; 00C0FF D3 BE
    ld a, $77           ; 00C101 3E 77
    out (PORT_VDP_DATA), a         ; 00C103 D3 BE
    ; Zeroes for the rest
    ld b, $7e           ; 00C105 06 7E
    xor a               ; 00C107 AF
-:  out (PORT_VDP_DATA), a         ; 00C108 D3 BE
    djnz - ;$c108           ; 00C10A 10 FC
    ; Next the X coordinates, tile indices
    ld a, $1e           ; 00C10C 3E 1E
    ld (_RAM_D7D7_SpriteX), a       ; 00C10E 32 D7 D7
    out (PORT_VDP_DATA), a         ; 00C111 D3 BE
    ld a, $5c           ; 00C113 3E 5C
    out (PORT_VDP_DATA), a         ; 00C115 D3 BE
    ld a, $28           ; 00C117 3E 28
    out (PORT_VDP_DATA), a         ; 00C119 D3 BE
    ld a, $5c           ; 00C11B 3E 5C
    out (PORT_VDP_DATA), a         ; 00C11D D3 BE
    ; Zeroes for the rest
    ld b, $7f           ; 00C11F 06 7F
-:  xor a               ; 00C121 AF
    out (PORT_VDP_DATA), a         ; 00C122 D3 BE
    djnz - ;$c121           ; 00C124 10 FB
    ; VRAM address $0000
    xor a               ; 00C126 AF
    out (PORT_VDP_ADDRESS), a         ; 00C127 D3 BF
    ld a, $40           ; 00C129 3E 40
    out (PORT_VDP_ADDRESS), a         ; 00C12B D3 BF
    xor a               ; 00C12D AF

    ; Emit 41 blank tiles (Codemasters logo, not animated in yet)
    ld c, $29           ; 00C12E 0E 29
--: ld b, $08           ; 00C130 06 08
-:  ld a, $ff           ; 00C132 3E FF
    out (PORT_VDP_DATA), a         ; 00C134 D3 BE
    xor a               ; 00C136 AF
    out (PORT_VDP_DATA), a         ; 00C137 D3 BE
    out (PORT_VDP_DATA), a         ; 00C139 D3 BE
    out (PORT_VDP_DATA), a         ; 00C13B D3 BE
    djnz - ;$c132           ; 00C13D 10 F3
    dec c               ; 00C13F 0D
    jr nz, -- ;$c130        ; 00C140 20 EE

    ; Then 51 real tiles at 2bpp (Absolutely Brilliant, plus faces)
    ld hl, _DATA_C512_Tiles        ; 00C142 21 12 C5
    ld a, $33           ; 00C145 3E 33 ; Tile count = 51
    ld d, $00           ; 00C147 16 00 ; Unused bitplanes
--: ld bc, $18be        ; 00C149 01 BE 18 ; Counter $18 will count down three times per loop -> 8 rows = 1 tile
-:  outi                   ; 00C14C ED A3
    outi                  ; 00C14E ED A3
    out (c), d           ; 00C150 ED 51
    out (c), d           ; 00C152 ED 51
    djnz -; $c14c           ; 00C154 10 F6
    dec a               ; 00C156 3D
    jr nz, -- ;$c149        ; 00C157 20 F0
    ; Then 48 at 1bpp, assume they come after the previous data (sprite tiles, text)
    ld a, $30           ; 00C159 3E 30
    ld de, $ff00        ; 00C15B 11 00 FF
--: ld bc, $10be        ; 00C15E 01 BE 10
-:  out (c), d           ; 00C161 ED 51
    outi ; 00C163 ED A3
    out (c), e           ; 00C165 ED 59
    out (c), e           ; 00C167 ED 59
    djnz - ;$c161           ; 00C169 10 F6
    dec a               ; 00C16B 3D
    jr nz, -- ;$c15e        ; 00C16C 20 F0

    ; Next the tilemap
    xor a               ; 00C16E AF
    out (PORT_VDP_ADDRESS), a         ; 00C16F D3 BF
    ld a, $78           ; 00C171 3E 78
    out (PORT_VDP_ADDRESS), a         ; 00C173 D3 BF
    ; Set it all to tile index $28 at high priority
    ld c, 24 ;$18           ; 00C175 0E 18 ; Rows
--: ld b, 32 ;$20           ; 00C177 06 20 ; Bytes per row
-:  ld a, $28           ; 00C179 3E 28 ; Value
    out (PORT_VDP_DATA), a         ; 00C17B D3 BE
    ld a, $10           ; 00C17D 3E 10
    out (PORT_VDP_DATA), a         ; 00C17F D3 BE
    djnz - ;$c179           ; 00C181 10 F6
    dec c               ; 00C183 0D
    jr nz, -- ;$c177        ; 00C184 20 F1
    ; Check buttons pressed includes 1+2
    in a, ($dc)         ; 00C186 DB DC
    and $30             ; 00C188 E6 30
    jp z, _LABEL_C26A_Checksum         ; 00C18A CA 6A C2

    ; If not, carry on...
    ; Draw stuff
    ; Tilemap 6, 9 = top row of CODEMASTERS logo
    ld a, $4c           ; 00C18D 3E 4C
    out (PORT_VDP_ADDRESS), a         ; 00C18F D3 BF
    ld a, $7a           ; 00C191 3E 7A
    out (PORT_VDP_ADDRESS), a         ; 00C193 D3 BF
    ; Emit tile indices 0, 2, ... $24
    ld bc, $1300        ; 00C195 01 00 13
-:  ld a, c             ; 00C198 79
    out (PORT_VDP_DATA), a         ; 00C199 D3 BE
    xor a               ; 00C19B AF
    out (PORT_VDP_DATA), a         ; 00C19C D3 BE
    inc c               ; 00C19E 0C
    inc c               ; 00C19F 0C
    djnz - ;$c198           ; 00C1A0 10 F6
    ; Tilemap 6, 19 = bottom row of CODEMASTERS logo
    ld a, $8c           ; 00C1A2 3E 8C
    out (PORT_VDP_ADDRESS), a         ; 00C1A4 D3 BF
    ld a, $7a           ; 00C1A6 3E 7A
    out (PORT_VDP_ADDRESS), a         ; 00C1A8 D3 BF
    ; Emit tile indices 1, 3, ... $25
    ld bc, $1301        ; 00C1AA 01 01 13
-:  ld a, c             ; 00C1AD 79
    out (PORT_VDP_DATA), a         ; 00C1AE D3 BE
    xor a               ; 00C1B0 AF
    out (PORT_VDP_DATA), a         ; 00C1B1 D3 BE
    inc c               ; 00C1B3 0C
    inc c               ; 00C1B4 0C
    djnz - ;$c1ad           ; 00C1B5 10 F6
    ; Tilemap 6, 14 = top row of Absolutely Brilliant slogan
    ld a, $8c           ; 00C1B7 3E 8C
    out (PORT_VDP_ADDRESS), a         ; 00C1B9 D3 BF
    ld a, $7b           ; 00C1BB 3E 7B
    out (PORT_VDP_ADDRESS), a         ; 00C1BD D3 BF
    ; Emit $2a, $2b, ... $3d
    ld bc, $142a        ; 00C1BF 01 2A 14
-:  ld a, c             ; 00C1C2 79
    out (PORT_VDP_DATA), a         ; 00C1C3 D3 BE
    ld a, $10           ; 00C1C5 3E 10 ; High priority
    out (PORT_VDP_DATA), a         ; 00C1C7 D3 BE
    inc c               ; 00C1C9 0C
    djnz - ;$c1c2           ; 00C1CA 10 F6
    ; Tilemap 6, 15 = bottom row of Absolutely Brilliant slogan
    ld a, $cc           ; 00C1CC 3E CC
    out (PORT_VDP_ADDRESS), a         ; 00C1CE D3 BF
    ld a, $7b           ; 00C1D0 3E 7B
    out (PORT_VDP_ADDRESS), a         ; 00C1D2 D3 BF
    ; Emit $3e, $3f, ... $51
    ld b, $14           ; 00C1D4 06 14
-:  ld a, c             ; 00C1D6 79
    out (PORT_VDP_DATA), a         ; 00C1D7 D3 BE
    ld a, $10           ; 00C1D9 3E 10
    out (PORT_VDP_DATA), a         ; 00C1DB D3 BE
    inc c               ; 00C1DD 0C
    djnz - ;$c1d6           ; 00C1DE 10 F6
    ; Tilemap 15, 16 = descender of Absolutely Brilliant slogan
    ld a, $1e           ; 00C1E0 3E 1E
    out (PORT_VDP_ADDRESS), a         ; 00C1E2 D3 BF
    ld a, $7c           ; 00C1E4 3E 7C
    out (PORT_VDP_ADDRESS), a         ; 00C1E6 D3 BF
    ; Emit $52, $53
    ld a, c             ; 00C1E8 79
    inc c               ; 00C1E9 0C
    out (PORT_VDP_DATA), a         ; 00C1EA D3 BE
    ld a, $10           ; 00C1EC 3E 10
    out (PORT_VDP_DATA), a         ; 00C1EE D3 BE
    ld a, c             ; 00C1F0 79
    inc c               ; 00C1F1 0C
    out (PORT_VDP_DATA), a         ; 00C1F2 D3 BE
    ld a, $10           ; 00C1F4 3E 10
    out (PORT_VDP_DATA), a         ; 00C1F6 D3 BE
    ; Emit tiles from $5e...
    ld c, $5e           ; 00C1F8 0E 5E
    ; Tilemap 6, 22 = copyright text
    ld a, $8c           ; 00C1FA 3E 8C
    out (PORT_VDP_ADDRESS), a         ; 00C1FC D3 BF
    ld a, $7d           ; 00C1FE 3E 7D
    out (PORT_VDP_ADDRESS), a         ; 00C200 D3 BF
    ; Emit 20 tiles "(c) CODEMASTERS SOFTWARE"
    ld b, $14           ; 00C202 06 14
-:  ld a, c             ; 00C204 79
    inc c               ; 00C205 0C
    out (PORT_VDP_DATA), a         ; 00C206 D3 BE
    xor a               ; 00C208 AF
    out (PORT_VDP_DATA), a         ; 00C209 D3 BE
    djnz - ;$c204           ; 00C20B 10 F7
    ; Tilemap 9, 23 = copyright text
    ld a, $d2           ; 00C20D 3E D2
    out (PORT_VDP_ADDRESS), a         ; 00C20F D3 BF
    ld a, $7d           ; 00C211 3E 7D
    out (PORT_VDP_ADDRESS), a         ; 00C213 D3 BF
    ; Emit 10 tiles "COMPANY LTD"
    ld b, $0a           ; 00C215 06 0A
-:  ld a, c             ; 00C217 79
    inc c               ; 00C218 0C
    out (PORT_VDP_DATA), a         ; 00C219 D3 BE
    xor a               ; 00C21B AF
    out (PORT_VDP_DATA), a         ; 00C21C D3 BE
    djnz - ;$c217           ; 00C21E 10 F7
    ; Emit year using the number tiles
    ; First the 19...
    ld hl, _DATA_C510_CenturyDigits        ; 00C220 21 10 C5
    ld b, $02           ; 00C223 06 02
-:  ld a, (hl)          ; 00C225 7E
    inc hl              ; 00C226 23
    add a, c             ; 00C227 81 ; Points at the digit 0 now
    out (PORT_VDP_DATA), a         ; 00C228 D3 BE
    xor a               ; 00C22A AF
    out (PORT_VDP_DATA), a         ; 00C22B D3 BE
    djnz - ;$c225           ; 00C22D 10 F6
    ; Read the rest of the year out of the Codemasters header
    ld a, (Header.Year)       ; 00C22F 3A E3 7F
    ld b, a             ; 00C232 47
    srl a               ; 00C233 CB 3F
    srl a               ; 00C235 CB 3F
    srl a               ; 00C237 CB 3F
    srl a               ; 00C239 CB 3F
    add a, c             ; 00C23B 81
    out (PORT_VDP_DATA), a         ; 00C23C D3 BE
    xor a               ; 00C23E AF
    out (PORT_VDP_DATA), a         ; 00C23F D3 BE
    ld a, b             ; 00C241 78
    and $0f             ; 00C242 E6 0F
    add a, c             ; 00C244 81
    out (PORT_VDP_DATA), a         ; 00C245 D3 BE
    xor a               ; 00C247 AF
    out (PORT_VDP_DATA), a         ; 00C248 D3 BE
    ; Generate the animated tiles source in its initial state
    ld hl, _RAM_D000_AnimatedTiles        ; 00C24A 21 00 D0
    ld bc, $0130        ; 00C24D 01 30 01 ; = 38 tiles
    ; Emit one row
-:  ld (hl), $ff        ; 00C250 36 FF
    inc hl              ; 00C252 23
    ld (hl), $00        ; 00C253 36 00
    inc hl              ; 00C255 23
    ld (hl), $00        ; 00C256 36 00
    inc hl              ; 00C258 23
    ld (hl), $00        ; 00C259 36 00
    inc hl              ; 00C25B 23
    dec bc              ; 00C25C 0B
    ld a, b             ; 00C25D 78
    or c               ; 00C25E B1
    jr nz, - ;$c250        ; 00C25F 20 EF
    ; Screen on
    ld a, $62           ; 00C261 3E 62
    out (PORT_VDP_REGISTER), a         ; 00C263 D3 BF
    ld a, $81           ; 00C265 3E 81
    out (PORT_VDP_REGISTER), a         ; 00C267 D3 BF
    ret ; 00C269 C9

_LABEL_C26A_Checksum:
; Checksums the data and draws to the screen if it's bad
    xor a               ; 00C26A AF
    ld (_RAM_D7DA_Checksum_PageNumber), a       ; 00C26B 32 DA D7
    ld (_RAM_D7DB_Checksum_BadFinalBytePageNumber), a       ; 00C26E 32 DB D7
    ld hl, $0000        ; 00C271 21 00 00
    ld (_RAM_D7D8_Checksum_CalculatedValue), hl      ; 00C274 22 D8 D7
-:  ld a, (_RAM_D7DA_Checksum_PageNumber)       ; 00C277 3A DA D7
    ld ($8000), a       ; 00C27A 32 00 80
    call _LABEL_c4dd_AddPageToChecksum           ; 00C27D CD DD C4
    ; Check last byte of page matches the page number, for pages >=2
    ld hl, _RAM_D7DA_Checksum_PageNumber        ; 00C280 21 DA D7
    ld a, (hl)          ; 00C283 7E
    cp $02             ; 00C284 FE 02
    jr c, + ;$c297         ; 00C286 38 0F
    ld a, ($bfff)       ; 00C288 3A FF BF
    cp (hl)            ; 00C28B BE
    jr z, + ;$c297         ; 00C28C 28 09
    ; Save the offending value to RAM
    ld a, (hl)          ; 00C28E 7E
    ld (_RAM_D7DB_Checksum_BadFinalBytePageNumber), a       ; 00C28F 32 DB D7
    ; Set the result to >1
    ld a, $ff           ; 00C292 3E FF
    ld (_RAM_D7DC_Checksum_Result), a       ; 00C294 32 DC D7
+:  inc (hl)            ; 00C297 34 ; Next page
    ; check if we have reached the page count (stored in the Codemasters header)
    ld b, (hl)          ; 00C298 46
    ld a, (Header.PageCount)       ; 00C299 3A E0 7F
    cp b               ; 00C29C B8
    jr nz, - ;$c277        ; 00C29D 20 D8 ; loop until we do

    ; Now time to draw stuff
    ; VRAM address 8, 5
    ld a, $50           ; 00C29F 3E 50
    out (PORT_VDP_ADDRESS), a         ; 00C2A1 D3 BF
    ld a, $79           ; 00C2A3 3E 79
    out (PORT_VDP_ADDRESS), a         ; 00C2A5 D3 BF
    ; "C"
    ld a, $88           ; 00C2A7 3E 88
    out (PORT_VDP_DATA), a         ; 00C2A9 D3 BE
    xor a               ; 00C2AB AF
    out (PORT_VDP_DATA), a         ; 00C2AC D3 BE
    ; The calculated checksum
    ld a, (_RAM_D7D8_Checksum_CalculatedValue+1)       ; 00C2AE 3A D9 D7
    call _LABEL_C084_PrintSpaceThenHexNumber           ; 00C2B1 CD 84 C0
    ld a, (_RAM_D7D8_Checksum_CalculatedValue)       ; 00C2B4 3A D8 D7
    call _LABEL_C08E_PrintHexNumber           ; 00C2B7 CD 8E C0
    ; Check if it's right
    ld hl, (_RAM_D7D8_Checksum_CalculatedValue)      ; 00C2BA 2A D8 D7
    ld bc, (Header.Checksum)      ; 00C2BD ED 4B E6 7F
    and a               ; 00C2C1 A7
    sbc hl, bc           ; 00C2C2 ED 42
    jr z, + ;$c2cb         ; 00C2C4 28 05
    ; Set the result to 1
    ld a, $01           ; 00C2C6 3E 01
    ld (_RAM_D7DC_Checksum_Result), a       ; 00C2C8 32 DC D7
+:  ; VRAM address 8, 7
    ld a, $d0           ; 00C2CB 3E D0
    out (PORT_VDP_ADDRESS), a         ; 00C2CD D3 BF
    ld a, $79           ; 00C2CF 3E 79
    out (PORT_VDP_ADDRESS), a         ; 00C2D1 D3 BF
    ; "D"
    ld a, $89           ; 00C2D3 3E 89
    out (PORT_VDP_DATA), a         ; 00C2D5 D3 BE
    xor a               ; 00C2D7 AF
    out (PORT_VDP_DATA), a         ; 00C2D8 D3 BE
    ; The timestamp
    ld a, (Header.Day)       ; 00C2DA 3A E1 7F
    call _LABEL_C084_PrintSpaceThenHexNumber           ; 00C2DD CD 84 C0
    ld a, (Header.Month)       ; 00C2E0 3A E2 7F
    call _LABEL_C084_PrintSpaceThenHexNumber           ; 00C2E3 CD 84 C0
    ld a, (Header.Year)       ; 00C2E6 3A E3 7F
    call _LABEL_C084_PrintSpaceThenHexNumber           ; 00C2E9 CD 84 C0
    ld a, (Header.Hour)       ; 00C2EC 3A E4 7F
    call _LABEL_C084_PrintSpaceThenHexNumber           ; 00C2EF CD 84 C0
    ld a, (Header.Minute)       ; 00C2F2 3A E5 7F
    call _LABEL_C084_PrintSpaceThenHexNumber           ; 00C2F5 CD 84 C0
    ; Print the detected bad page number if non-zero
    ld a, (_RAM_D7DB_Checksum_BadFinalBytePageNumber)       ; 00C2F8 3A DB D7
    and a               ; 00C2FB A7
    jr z, + ;$c313         ; 00C2FC 28 15
    ; Tilemap address 8, 9
    ld a, $50           ; 00C2FE 3E 50
    out (PORT_VDP_ADDRESS), a         ; 00C300 D3 BF
    ld a, $7a           ; 00C302 3E 7A
    out (PORT_VDP_ADDRESS), a         ; 00C304 D3 BF
    ; "B"
    ld a, $87           ; 00C306 3E 87
    out (PORT_VDP_DATA), a         ; 00C308 D3 BE
    xor a               ; 00C30A AF
    out (PORT_VDP_DATA), a         ; 00C30B D3 BE
    ld a, (_RAM_D7DB_Checksum_BadFinalBytePageNumber)       ; 00C30D 3A DB D7
    call _LABEL_C084_PrintSpaceThenHexNumber           ; 00C310 CD 84 C0
+:  ; VRAM address 15, 12
    ld a, $1e           ; 00C313 3E 1E
    out (PORT_VDP_ADDRESS), a         ; 00C315 D3 BF
    ld a, $7b           ; 00C317 3E 7B
    out (PORT_VDP_ADDRESS), a         ; 00C319 D3 BF
    ; Tile index of happy face
    ld c, $54           ; 00C31B 0E 54
    ld a, (_RAM_D7DC_Checksum_Result)       ; 00C31D 3A DC D7
    and a               ; 00C320 A7
    jr z, + ;$c327         ; 00C321 28 04
    ; Increment to point at the sad/sick face
    inc c               ; 00C323 0C
    inc c               ; 00C324 0C
    inc c               ; 00C325 0C
    inc c               ; 00C326 0C
+:  ; Emit two tiles
    ld a, c             ; 00C327 79
    inc c               ; 00C328 0C
    out (PORT_VDP_DATA), a         ; 00C329 D3 BE
    xor a               ; 00C32B AF
    out (PORT_VDP_DATA), a         ; 00C32C D3 BE
    ld a, c             ; 00C32E 79
    inc c               ; 00C32F 0C
    out (PORT_VDP_DATA), a         ; 00C330 D3 BE
    xor a               ; 00C332 AF
    out (PORT_VDP_DATA), a         ; 00C333 D3 BE
    ; VRAM address 15, 13
    ld a, $5e           ; 00C335 3E 5E
    out (PORT_VDP_ADDRESS), a         ; 00C337 D3 BF
    ld a, $7b           ; 00C339 3E 7B
    out (PORT_VDP_ADDRESS), a         ; 00C33B D3 BF
    ; Emit two more tiles
    ld a, c             ; 00C33D 79
    inc c               ; 00C33E 0C
    out (PORT_VDP_DATA), a         ; 00C33F D3 BE
    xor a               ; 00C341 AF
    out (PORT_VDP_DATA), a         ; 00C342 D3 BE
    ld a, c             ; 00C344 79
    out (PORT_VDP_DATA), a         ; 00C345 D3 BE
    xor a               ; 00C347 AF
    out (PORT_VDP_DATA), a         ; 00C348 D3 BE
    ; Change the palette to match the result
    ld a, (_RAM_D7DC_Checksum_Result)       ; 00C34A 3A DC D7
    and a               ; 00C34D A7
    jr nz, + ;$c388        ; 00C34E 20 38
    ; Palette index 1
    ld a, $01           ; 00C350 3E 01
    out (PORT_VDP_ADDRESS), a         ; 00C352 D3 BF
    ld a, $c0           ; 00C354 3E C0
    out (PORT_VDP_ADDRESS), a         ; 00C356 D3 BF
    ; Green
    ld a, %001100           ; 00C358 3E 0C
    ; PAlette index $11
    out (PORT_VDP_DATA), a         ; 00C35A D3 BE
    ld a, $11           ; 00C35C 3E 11
    out (PORT_VDP_ADDRESS), a         ; 00C35E D3 BF
    ld a, $c0           ; 00C360 3E C0
    out (PORT_VDP_ADDRESS), a         ; 00C362 D3 BF
    ; Green
    ld a, %001100       ; 00C364 3E 0C
    out (PORT_VDP_DATA), a         ; 00C366 D3 BE
    ; Turn on screen
    ld a, $62           ; 00C368 3E 62
    out (PORT_VDP_REGISTER), a         ; 00C36A D3 BF
    ld a, $81           ; 00C36C 3E 81
    out (PORT_VDP_REGISTER), a         ; 00C36E D3 BF
    ; Leave it showing while a button is pressed
-:  in a, ($dc)         ; 00C370 DB DC ; Player 1 controls
    or $c0             ; 00C372 F6 C0
    cp $ff             ; 00C374 FE FF
    jr nz, - ;$c370        ; 00C376 20 F8 ; Loop while anything pressed - delays starting the timeout
    ; Then wait 256 frames = ~5s
    ld b, $00           ; 00C378 06 00
--: call _LABEL_c051_WaitForVBlank           ; 00C37A CD 51 C0
-:  in a, (PORT_VDP_LINECOUNTER)         ; 00C37D DB 7E
    and a               ; 00C37F A7
    jr nz, - ;$c37d        ; 00C380 20 FB
    djnz -- ;$c37a           ; 00C382 10 F6
    ; Not sure why this is - trying to discard the return address? This stops it returning to the normal intro
    pop bc              ; 00C384 C1
    ; Then return to the next address up the stack - probably the caller of $c000.
    ; This doesn't work when the caller was in paged code - because we do not restore the page.
    ; In Micro Machines, this ends up in some code that gets stuck doing nothing much.
    jp _LABEL_C050_ret           ; 00C385 C3 50 C0
    
    
+:  ; Bad result
    ; Palette index 1
    ld a, $01           ; 00C388 3E 01
    out (PORT_VDP_ADDRESS), a         ; 00C38A D3 BF
    ld a, $c0           ; 00C38C 3E C0
    out (PORT_VDP_ADDRESS), a         ; 00C38E D3 BF
    ; Red
    ld a, %000011          ; 00C390 3E 03
    out (PORT_VDP_DATA), a         ; 00C392 D3 BE
    ; Palette index $11
    ld a, $11           ; 00C394 3E 11
    out (PORT_VDP_ADDRESS), a         ; 00C396 D3 BF
    ld a, $c0           ; 00C398 3E C0
    out (PORT_VDP_ADDRESS), a         ; 00C39A D3 BF
    ; Red
    ld a, %000011           ; 00C39C 3E 03
    out (PORT_VDP_DATA), a         ; 00C39E D3 BE
    ; Screen on
    ld a, $62           ; 00C3A0 3E 62
    out (PORT_VDP_ADDRESS), a         ; 00C3A2 D3 BF
    ld a, $81           ; 00C3A4 3E 81
    out (PORT_VDP_ADDRESS), a         ; 00C3A6 D3 BF
    ; Play a sound
    ld a, $8f           ; 00C3A8 3E 8F
    out (PORT_PSG), a         ; 00C3AA D3 7E
    ld a, $3f           ; 00C3AC 3E 3F
    out (PORT_PSG), a         ; 00C3AE D3 7E
    ld a, $90           ; 00C3B0 3E 90
    out (PORT_PSG), a         ; 00C3B2 D3 7E
    ; Hang forever
-:  jr - ;$c3b4           ; 00C3B4 18 FE

_LABEL_C3B6_UpdateTiles_Part2:
    ld a, (_RAM_D7D2_AnimationIndex)       ; 00C3B6 3A D2 D7 ; Get value
    ld e, a             ; 00C3B9 5F ; -> de
    ld d, $00           ; 00C3BA 16 00
    ld h, d             ; 00C3BC 62 ; -> hl
    ld l, e             ; 00C3BD 6B
    add hl, hl           ; 00C3BE 29 ; Multiply by 18
    add hl, hl           ; 00C3BF 29
    add hl, hl           ; 00C3C0 29
    add hl, de           ; 00C3C1 19
    add hl, hl           ; 00C3C2 29
    ld de, _DATA_C9D2_AnimationXValues        ; 00C3C3 11 D2 C9
    add hl, de           ; 00C3C6 19
    ; Now pointing at the 18 bytes for _RAM_D7D2_AnimationIndex
    ; Move on by _RAM_D7D5_
    ld a, (_RAM_D7D5_)       ; 00C3C7 3A D5 D7
    ld c, a             ; 00C3CA 4F
    ld b, $00           ; 00C3CB 06 00
    add hl, bc           ; 00C3CD 09
    ld b, h             ; 00C3CE 44 ; -> bc
    ld c, l             ; 00C3CF 4D
    
    ld a, (_RAM_D7D3_)       ; 00C3D0 3A D3 D7
    ld l, a             ; 00C3D3 6F
-:  ld a, (bc)          ; 00C3D4 0A
    ld h, a             ; 00C3D5 67
    ld a, h             ; 00C3D6 7C
    inc a               ; 00C3D7 3C
    jr z, + ;$c3fd         ; 00C3D8 28 23
    ld a, (_RAM_D7D5_)       ; 00C3DA 3A D5 D7
    ld d, a             ; 00C3DD 57
    ld a, h             ; 00C3DE 7C
    cp d               ; 00C3DF BA
    jr c, + ;$c3fd         ; 00C3E0 38 1B
    ld a, (_RAM_D7D6_)       ; 00C3E2 3A D6 D7
    ld d, a             ; 00C3E5 57
    ld a, h             ; 00C3E6 7C
    cp d               ; 00C3E7 BA
    jr nc, + ;$c3fd        ; 00C3E8 30 13
    ld a, (_RAM_D7D3_)       ; 00C3EA 3A D3 D7
    add a, h             ; 00C3ED 84
    ld h, a             ; 00C3EE 67
    ld a, (_RAM_D7D5_)       ; 00C3EF 3A D5 D7
    cpl ; 00C3F2 2F
    inc a               ; 00C3F3 3C
    add a, h             ; 00C3F4 84
    ld h, a             ; 00C3F5 67
    push bc              ; 00C3F6 C5
    push hl              ; 00C3F7 E5
      call _LABEL_C442_           ; 00C3F8 CD 42 C4
    pop hl              ; 00C3FB E1
    pop bc              ; 00C3FC C1
+:  inc bc              ; 00C3FD 03
    inc l               ; 00C3FE 2C
    ld a, (_RAM_D7D4_)       ; 00C3FF 3A D4 D7
    cp l               ; 00C402 BD
    jr nz, - ;$c3d4        ; 00C403 20 CF
    ld a, (_RAM_D7D3_)       ; 00C405 3A D3 D7
    and $f8             ; 00C408 E6 F8
    ld l, a             ; 00C40A 6F
    ld h, $1a           ; 00C40B 26 1A
    add hl, hl           ; 00C40D 29
    add hl, hl           ; 00C40E 29
    add hl, hl           ; 00C40F 29
    ld e, l             ; 00C410 5D
    ld a, h             ; 00C411 7C
    sub $d0             ; 00C412 D6 D0
    add a, $40           ; 00C414 C6 40
    ld d, a             ; 00C416 57

    call _LABEL_c051_WaitForVBlank           ; 00C417 CD 51 C0

    ; Sprite table
    ld a, $80           ; 00C41A 3E 80
    out (PORT_VDP_ADDRESS), a         ; 00C41C D3 BF
    ld a, $7f           ; 00C41E 3E 7F
    out (PORT_VDP_ADDRESS), a         ; 00C420 D3 BF
    ; Move sprite right by 2px
    ld a, (_RAM_D7D7_SpriteX)       ; 00C422 3A D7 D7
    add a, $02           ; 00C425 C6 02
    ld (_RAM_D7D7_SpriteX), a       ; 00C427 32 D7 D7
    ld b, a             ; 00C42A 47
    out (PORT_VDP_DATA), a         ; 00C42B D3 BE
    ; Sprite index
    ld a, $5c           ; 00C42D 3E 5C
    out (PORT_VDP_DATA), a         ; 00C42F D3 BE
    ; Next sprite X is -2
    ld a, b             ; 00C431 78
    sub $02             ; 00C432 D6 02
    out (PORT_VDP_DATA), a         ; 00C434 D3 BE
    ; Leave index as written
    ; Set VRAM address for tile upload
    ld a, e             ; 00C436 7B
    out (PORT_VDP_ADDRESS), a         ; 00C437 D3 BF
    ld a, d             ; 00C439 7A
    out (PORT_VDP_ADDRESS), a         ; 00C43A D3 BF
    ; Emit $c0 bytes = 6 tiles from hl
    ld bc, $c0be        ; 00C43C 01 BE C0
    otir ; 00C43F ED B3
    ret ; 00C441 C9

_LABEL_C442_:
    ld a, l             ; 00C442 7D
    and $07             ; 00C443 E6 07
    add a, $08           ; 00C445 C6 08
    ld c, a             ; 00C447 4F
    ld b, $c5           ; 00C448 06 C5
    ld a, (bc)          ; 00C44A 0A
    ld b, a             ; 00C44B 47
    ld e, h             ; 00C44C 5C
    xor a               ; 00C44D AF
    sla e               ; 00C44E CB 23
    rla ; 00C450 17
    sla e               ; 00C451 CB 23
    rla ; 00C453 17
    add a, $cc           ; 00C454 C6 CC
    ld d, a             ; 00C456 57
    ld a, l             ; 00C457 7D
    and $f8             ; 00C458 E6 F8
    ld l, a             ; 00C45A 6F
    ld h, $1a           ; 00C45B 26 1A
    add hl, hl           ; 00C45D 29
    add hl, hl           ; 00C45E 29
    add hl, hl           ; 00C45F 29
    call _LABEL_C469_           ; 00C460 CD 69 C4
    call _LABEL_C469_           ; 00C463 CD 69 C4
    call _LABEL_C469_           ; 00C466 CD 69 C4
_LABEL_C469_:
    ld a, (de)          ; 00C469 1A
    ld c, a             ; 00C46A 4F
    inc de              ; 00C46B 13
    rl c               ; 00C46C CB 11
    jr nc, + ;$c474        ; 00C46E 30 04
    ld a, (hl)          ; 00C470 7E
    or b               ; 00C471 B0
    jr ++ ;$c477           ; 00C472 18 03
+:  ld a, b             ; 00C474 78
    cpl ; 00C475 2F
    and (hl)            ; 00C476 A6
++: ld (hl), a          ; 00C477 77
    inc hl              ; 00C478 23
    rl c               ; 00C479 CB 11
    jr nc, + ;$c481        ; 00C47B 30 04
    ld a, (hl)          ; 00C47D 7E
    or b               ; 00C47E B0
    jr ++ ;$c484           ; 00C47F 18 03
+:  ld a, b             ; 00C481 78
    cpl ; 00C482 2F
    and (hl)            ; 00C483 A6
++: ld (hl), a          ; 00C484 77
    inc hl              ; 00C485 23
    inc hl              ; 00C486 23
    inc hl              ; 00C487 23
    rl c               ; 00C488 CB 11
    jr nc, + ;$c490        ; 00C48A 30 04
    ld a, (hl)          ; 00C48C 7E
    or b               ; 00C48D B0
    jr ++ ;$c493           ; 00C48E 18 03
+:  ld a, b             ; 00C490 78
    cpl ; 00C491 2F
    and (hl)            ; 00C492 A6
++: ld (hl), a          ; 00C493 77
    inc hl              ; 00C494 23
    rl c               ; 00C495 CB 11
    jr nc, + ;$c49d        ; 00C497 30 04
    ld a, (hl)          ; 00C499 7E
    or b               ; 00C49A B0
    jr ++ ;$c4a0           ; 00C49B 18 03
+:  ld a, b             ; 00C49D 78
    cpl ; 00C49E 2F
    and (hl)            ; 00C49F A6
++: ld (hl), a          ; 00C4A0 77
    inc hl              ; 00C4A1 23
    inc hl              ; 00C4A2 23
    inc hl              ; 00C4A3 23
    rl c               ; 00C4A4 CB 11
    jr nc, + ;$c4ac        ; 00C4A6 30 04
    ld a, (hl)          ; 00C4A8 7E
    or b               ; 00C4A9 B0
    jr ++ ;$c4af           ; 00C4AA 18 03
+:  ld a, b             ; 00C4AC 78
    cpl ; 00C4AD 2F
    and (hl)            ; 00C4AE A6
++: ld (hl), a          ; 00C4AF 77
    inc hl              ; 00C4B0 23
    rl c               ; 00C4B1 CB 11
    jr nc, + ;$c4b9        ; 00C4B3 30 04
    ld a, (hl)          ; 00C4B5 7E
    or b               ; 00C4B6 B0
    jr ++ ;$c4bc           ; 00C4B7 18 03
+:  ld a, b             ; 00C4B9 78
    cpl ; 00C4BA 2F
    and (hl)            ; 00C4BB A6
++: ld (hl), a          ; 00C4BC 77
    inc hl              ; 00C4BD 23
    inc hl              ; 00C4BE 23
    inc hl              ; 00C4BF 23
    rl c               ; 00C4C0 CB 11
    jr nc, + ;$c4c8        ; 00C4C2 30 04
    ld a, (hl)          ; 00C4C4 7E
    or b               ; 00C4C5 B0
    jr ++ ;$c4cb           ; 00C4C6 18 03
+:  ld a, b             ; 00C4C8 78
    cpl               ; 00C4C9 2F
    and (hl)            ; 00C4CA A6
++: ld (hl), a          ; 00C4CB 77
    inc hl              ; 00C4CC 23
    rl c               ; 00C4CD CB 11
    jr nc, + ;$c4d5        ; 00C4CF 30 04
    ld a, (hl)          ; 00C4D1 7E
    or b               ; 00C4D2 B0
    jr ++ ;$c4d8           ; 00C4D3 18 03
+:  ld a, b             ; 00C4D5 78
    cpl ; 00C4D6 2F
    and (hl)            ; 00C4D7 A6
++: ld (hl), a          ; 00C4D8 77
    inc hl              ; 00C4D9 23
    inc hl              ; 00C4DA 23
    inc hl              ; 00C4DB 23
    ret ; 00C4DC C9

_LABEL_c4dd_AddPageToChecksum:
    ld de, $8000        ; 00C4DD 11 00 80 ; Start address
    ld bc, $2000        ; 00C4E0 01 00 20 ; Byte count - only 8K?
    ld a, (_RAM_D7DA_Checksum_PageNumber)       ; 00C4E3 3A DA D7
    cp $01             ; 00C4E6 FE 01
    jr nz, + ;$c4ed        ; 00C4E8 20 03
    ld bc, $1ff8        ; 00C4EA 01 F8 1F ; Reduced for page 1?
+:  exx ; 00C4ED D9
      ld hl, (_RAM_D7D8_Checksum_CalculatedValue)      ; 00C4EE 2A D8 D7
    exx ; 00C4F1 D9
-:  ld a, (de)          ; 00C4F2 1A ; Get byte
    inc de              ; 00C4F3 13
    exx ; 00C4F4 D9
      ld e, a             ; 00C4F5 5F
    exx ; 00C4F6 D9
    ld a, (de)          ; 00C4F7 1A
    inc de              ; 00C4F8 13
    exx ; 00C4F9 D9
      ld d, a             ; 00C4FA 57
      add hl, de           ; 00C4FB 19
    exx ; 00C4FC D9
    dec bc              ; 00C4FD 0B
    ld a, b             ; 00C4FE 78
    or c               ; 00C4FF B1
    jr nz, - ;$c4f2        ; 00C500 20 F0
    exx ; 00C502 D9
      ld (_RAM_D7D8_Checksum_CalculatedValue), hl      ; 00C503 22 D8 D7
    exx ; 00C506 D9
    ret ; 00C507 C9

_DATA_c508_Unused: ; Unused? Single-bit lookups
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
;.incbin "Tiles.1bpp"
.incbin "Sprites.1bpp"
.incbin "Copyright.1bpp"
.incbin "HexCharacters.1bpp"

_DATA_C9C2_Palette:
  SMSCOLOUR $000000
  SMSCOLOUR $aa00aa
  SMSCOLOUR $ffaaff
  SMSCOLOUR $ffffff

_DATA_C9C6_: ; Incrementing but not linearly..? Maps 0..11 to 0..151
.db $00 $0E $1D $2B $39 $4B $59 $63 $71 $7E $8D $97

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
    ld a, (_RAM_D7E1_MuteSound)       ; 00CA74 3A E1 D7
    or a               ; 00CA77 B7
    jr nz, + ;+$1f ;$ca99        ; 00CA78 20 1F
    ; Zero
    ; Increment _RAM_D7DD_
    ld hl, (_RAM_D7DD_)      ; 00CA7A 2A DD D7
    ld a, (hl)          ; 00CA7D 7E
    inc hl              ; 00CA7E 23
    ld (_RAM_D7DD_), hl      ; 00CA7F 22 DD D7

    ld e, $80           ; 00CA82 1E 80
    sub $0a             ; 00CA84 D6 0A
    call _LABEL_CACA_SetPSGFrequency           ; 00CA86 CD CA CA
    ld a, (hl)          ; 00CA89 7E
    sub $08             ; 00CA8A D6 08
    ld e, $a0           ; 00CA8C 1E A0
    call _LABEL_CACA_SetPSGFrequency           ; 00CA8E CD CA CA
    ld a, (hl)          ; 00CA91 7E
    cp $80             ; 00CA92 FE 80
    jr nz, ++ ;$caaa        ; 00CA94 20 14
    
    ld (_RAM_D7E1_MuteSound), a       ; 00CA96 32 E1 D7
+:  ; Silence PSG
    ld a, $9f           ; 00CA99 3E 9F
    out (PORT_PSG), a         ; 00CA9B D3 7E
    ld a, $bf           ; 00CA9D 3E BF
    out (PORT_PSG), a         ; 00CA9F D3 7E
    ld a, $df           ; 00CAA1 3E DF
    out (PORT_PSG), a         ; 00CAA3 D3 7E
    ld a, $ff           ; 00CAA5 3E FF
    out (PORT_PSG), a         ; 00CAA7 D3 7E
    ret ; 00CAA9 C9

++: ld e, $c0           ; 00CAAA 1E C0
    sub $06             ; 00CAAC D6 06
    call _LABEL_CACA_SetPSGFrequency           ; 00CAAE CD CA CA
    ld hl, (_RAM_D7DF_)      ; 00CAB1 2A DF D7
    ld a, (hl)          ; 00CAB4 7E
    or $90             ; 00CAB5 F6 90
    out (PORT_PSG), a         ; 00CAB7 D3 7E
    inc hl              ; 00CAB9 23
    ld (_RAM_D7DF_), hl      ; 00CABA 22 DF D7
    ld a, (hl)          ; 00CABD 7E
    or $b0             ; 00CABE F6 B0
    out (PORT_PSG), a         ; 00CAC0 D3 7E
    inc hl              ; 00CAC2 23
    ld a, (hl)          ; 00CAC3 7E
    or $d0             ; 00CAC4 F6 D0
    out (PORT_PSG), a         ; 00CAC6 D3 7E
    inc hl              ; 00CAC8 23
    ret ; 00CAC9 C9

_LABEL_CACA_SetPSGFrequency:
; a = note index
; e = channel mask
    push hl              ; 00CACA E5
      ; Look up wavelength from a
      add a, a             ; 00CACB 87
      ld c, a             ; 00CACC 4F
      ld b, $00           ; 00CACD 06 00
      ld hl, _DATA_CBB1_ ;$cbb1        ; 00CACF 21 B1 CB
      add hl, bc           ; 00CAD2 09
      ld a, (hl)          ; 00CAD3 7E ; LSB
      ld b, a             ; 00CAD4 47
      inc hl              ; 00CAD5 23
      ld c, (hl)          ; 00CAD6 4E ; MSB
      ; Shift data into the right place
      rla ; 00CAD7 17
      rl c               ; 00CAD8 CB 11
      rla ; 00CADA 17
      rl c               ; 00CADB CB 11
      rla ; 00CADD 17
      rl c               ; 00CADE CB 11
      rla ; 00CAE0 17
      rl c               ; 00CAE1 CB 11
      ld a, b             ; 00CAE3 78
      and $0f             ; 00CAE4 E6 0F
      ; Select channel
      or e               ; 00CAE6 B3
      ; Emit
      out (PORT_PSG), a         ; 00CAE7 D3 7E
      ld a, c             ; 00CAE9 79
      out (PORT_PSG), a         ; 00CAEA D3 7E
    pop hl              ; 00CAEC E1
    ret ; 00CAED C9

_DATA_CAEE_Notes: ; PSG notes?
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

_DATA_CB4F_: ; Note durations?
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

_DATA_CBB1_: ; PSG frequency lookup
.dw $02A7 $0281 $025D $023B $021B $01FC $01E0 $01C5 $01AC $0194 $017D $0168 
.dw $0153 $0140 $012E $011D $010D $00FE $00F0 $00E2 $00D6 $00CA $00BE $00B4 
.dw $00AA $00A0 $0097 $008F $0087 $007F 

_DATA_CBED_: ; Unused?
.db $3D $3D
.db $3D $3D $3D $3D $3D $3D $3D $3D
.db $3D $3D $3D $3D $3D $3D $3D $3D
.db $3D $AA $9F $F6 $AA $AB $FF $FF
.db $6A $AF $FF $FF $DA $BD $AA $A9
.db $FA $50 $00 $00 $1C $C2 $AA $AA
.db $AC $4A $AA $AA $AC $4A $AA $AA
.db $AC $CA $AA $AA $AC $7A $AA $AA
.db $98 $BE $AA $AA $B0 $7F $EA $AA
.db $42 $AA $82 $AA $0A $80 $0A $AA
.db $AA $AA $7F $D6 $AA $AB $FF $FF
.db $AA $AF $FF $FF $EA $BD $AA $A9
.db $FA $50 $00 $00 $14 $C2 $AA $AA
.db $AC $4A $AA $AA $A4 $CA $AA $AA
.db $AC $DA $AA $AA $9C $BE $AA $A9
.db $F8 $9F $FF $FF $D0 $A7 $FF $FF
.db $42 $AA $7F $F6 $0A $AA $25 $A0
.db $2A $AA $A0 $02 $AA $EA $AA $AA
.db $AC $FF $FF $FF $FC $FF $FF $FF
.db $FC $FF $FF $FF $FC $C0 $00 $00
.db $0C $CA $AA $AA $AC $CA $AA $AA
.db $AC $EA $AA $AA $9C $7E $AA $A9
.db $F8 $BF $FF $FF $D0 $AF $FF $FF
.db $42 $A9 $FF $F6 $0A $AA $0A $80
.db $2A $AA $A8 $0A $AA $EA $AA $AA
.db $AC $FF $FF $FF $FC $FF $FF $FF
.db $FC $FF $FF $FF $FC $C0 $06 $00
.db $0C $CA $A6 $2A $AC $CA $AF $2A
.db $AC $CA $7F $EA $AC $EA $AA $A0
.db $AC $F6 $80 $02 $BC $55 $AA $A9
.db $F4 $80 $0A $AA $00 $AA $AA $A8
.db $2A $AA $AA $AA $AA $EA $AA $AA
.db $AC $FD $55 $55 $7C $FF $A0 $00
.db $2C $FF $F6 $AA $A8 $BF $FF $DA
.db $A8 $89 $FF $FD $AA $AA $27 $FF
.db $FA $AA $A0 $9F $D8 $AA $AA $AD
.db $00 $AA $A9 $D8 $2A $AA $96 $00
.db $AA $A7 $60 $2A $A6 $7F $55 $55
.db $7C $FF $FF $FF $FC $FF $FF $FF
.db $FC $DA $AA $AA $9C $40 $00 $00
.db $04 $8A $AA $AA $A8 $AA $AA $AA
.db $AC $AA $AA $AA $5C $AA $AA $9D
.db $84 $AA $A9 $6E $08 $AA $58 $0E
.db $2A $A7 $E0 $AE $2A $7F $FF $6E
.db $2A $89 $FF $FD $A4 $A8 $27 $FF
.db $FC $AA $A0 $9F $FC $AA $AA $82
.db $7C $AA $AA $AA $0C $AA $AA $AA
.db $A8 $AA $AA $AA $A8 $A7 $FA $A9
.db $F4 $BF $FE $A8 $B4 $E0 $FF $AA
.db $AC $C2 $BF $6A $A4 $4A $BF $EA
.db $AC $CA $9F $DA $AC $7A $AF $FD
.db $78 $BD $AB $FF $D0 $AA $88 $95
.db $82 $80 $0A $80 $0A $55 $AA $AA
.db $AA $F6 $0A $AA $AA $E0 $2A $AA
.db $AA $C2 $AA $AA $AA $EA $AA $AA
.db $AC $FF $FF $FF $FC $FF $FF $FF
.db $FC $FF $FF $FF $FC $C0 $00 $00
.db $2C $CA $AA $AA $A8 $DA $AA $AA
.db $A8 $FE $AA $AA $AA $AA $AA $AA
.db $AA $80 $0A $AA $AA $EA $AA $AA
.db $AC $FF $FF $FF $FC $FF $FF $FF
.db $FC $FF $FF $FF $FC $C0 $06 $00
.db $0C $CA $A6 $2A $AC $CA $AF $2A
.db $AC $CA $7F $EA $AC $EA $AA $A0
.db $AC $F6 $80 $02 $BC $55 $AA $A9
.db $F4 $80 $0A $AA $00 $AA $AA $A8
.db $2A $EA $AA $AA $AC $FF $FF $FF
.db $FC $FF $FF $FF $FC $FF $FF $FF
.db $FC $C0 $0B $00 $2C $CA $AB $6A
.db $A8 $CA $A7 $FE $A8 $FA $9F $FF
.db $6A $BF $FC $BF $F6 $BF $F8 $87
.db $FC $A7 $60 $AA $FC $A8 $02 $AA
.db $1C $AA $AA $AA $A8 $AA $AA $AA
.db $A8 $AA $AA $AA $A8 $A7 $FA $A9
.db $F4 $BF $FE $A8 $B4 $E0 $FF $AA
.db $AC $C2 $BF $6A $A4 $4A $BF $EA
.db $AC $CA $9F $DA $AC $7A $AF $FD
.db $78 $BD $AB $FF $D0 $AA $88 $95
.db $82 $80 $0A $80 $0A $AA $AA $AA
.db $AA
