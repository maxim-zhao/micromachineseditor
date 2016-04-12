; This disassembly was created using Emulicious (http://www.emulicious.net)
.MEMORYMAP
SLOTSIZE $4000
SLOT 0 $0000
SLOT 1 $4000
SLOT 2 $8000
DEFAULTSLOT 2
.ENDME
.ROMBANKMAP
BANKSTOTAL 16
BANKSIZE $4000
BANKS 16
.ENDRO


.BANK 0 SLOT 0
.ORG $0000

_LABEL_0_:
	di
	ld hl, $DFFF
	ld sp, hl
	call _LABEL_100_
	xor a
	ld ($DC41), a
	ld a, $02
	ld ($8000), a
	jp _LABEL_8000_

; Data from 14 to 37 (36 bytes)
.db $F3 $3E $02 $32 $00 $80 $3E $01 $32 $3E $DC $21 $FF $DF $F9 $C3
.db $21 $80 $50 $20 $48 $4C $0D $0A $09 $49 $4E $43 $20 $48 $4C $0D
.db $0A $09 $4C $44

_LABEL_38_:
	push af
	ld a, ($DC3E)
	or a
	jr z, ++
	cp $01
	jr z, +
	in a, ($BF)
	pop af
	ei
	reti

+:
	pop af
	jp $D931	; Possibly invalid

++:
	pop af
	call _LABEL_199_
	ei
	reti

; Data from 54 to 65 (18 bytes)
.db $20 $28 $43 $48 $32 $4D $41 $50 $32 $2B $39 $29 $2C $41 $0D $0A
.db $09 $4C

_LABEL_66_:
	push af
	ld a, ($DC3C)
	or a
	jp nz, _LABEL_9BF_
	jp _LABEL_517F_

; Data from 71 to FF (143 bytes)
.db $39 $29 $2C $41 $3E $00 $32 $00 $00 $3E $01 $32 $00 $40 $C3 $73
.db $75 $00 $01 $01 $00 $03 $02 $50 $50 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $11 $00 $02 $04 $0E $1A $1B $B5 $F3 $3E $02
.db $32 $00 $80 $3E $01 $32 $3E $DC $21 $FF $DF $F9 $C3 $00 $80 $00
.db $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00 $00
.db $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

_LABEL_100_:
	ld hl, $C000
	ld bc, $1F9A
-:
	xor a
	ld (hl), a
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, -
	ld hl, $DBC0
	ld de, $0075
	ld bc, $0039
-:
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
	call _LABEL_173_
	ld hl, $DC59
	ld de, $00C0
	ld bc, $0040
-:
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
	call _LABEL_186_
	ld a, $01
	ld ($DBA8), a
	ld a, $20
	ld ($DB9C), a
	ld ($DB9E), a
	ld hl, $DB22
	ld ($DB62), hl
	ld hl, $DB42
	ld ($DB64), hl
	ld a, $1A
	ld ($DC39), a
	ld a, $00
	ld ($DC54), a
	or a
	jr z, +
	ld a, $05
	ld ($DC56), a
	ld a, $28
	ld ($DC57), a
	jp ++

+:
	xor a
	ld ($DC56), a
	ld ($DC57), a
++:
	ret

_LABEL_173_:
	ld hl, $DC99
	ld de, $00AE
	ld bc, $0012
-:
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

_LABEL_186_:
	ld hl, $D94C
	ld de, $650C
	ld bc, $0034
-:
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

_LABEL_199_:
	push af
	ld a, ($DC42)
	or a
	jr nz, _LABEL_1E0_
	push hl
	push bc
	push de
	push ix
	push iy
	ld a, ($BFFF)
	push af
	ld a, ($D5B5)
	or a
	jr z, +
	xor a
	ld ($D580), a
	call _LABEL_33A_
	ld a, ($DC41)
	or a
	jr nz, +
	ld a, ($D599)
	or a
	jr nz, +
	call _LABEL_5169_
	call _LABEL_5174_
	ld a, $0A
	ld ($8000), a
	call _LABEL_2B5D2_
	call _LABEL_AFD_
+:
	pop af
	ld ($8000), a
	pop iy
	pop ix
	pop de
	pop bc
	pop hl
_LABEL_1E0_:
	in a, ($BF)
	pop af
	ret

; Data from 1E4 to 334 (337 bytes)
.db $CD $9D $51 $3A $99 $D5 $B7 $C2 $9D $02 $3A $7F $DF $B7 $C4 $B1
.db $0A $CD $D5 $12 $CD $BF $12 $CD $BA $11 $CD $CA $12 $3A $B6 $D5
.db $B7 $C4 $C7 $65 $3A $B7 $D5 $B7 $C4 $04 $0B $CD $9B $0F $CD $CD
.db $22 $CD $5F $26 $CD $3A $5E $CD $8E $64 $CD $C9 $49 $CD $65 $44
.db $CD $C3 $44 $CD $22 $46 $CD $9E $47 $CD $56 $67 $CD $97 $6A $CD
.db $6C $6A $CD $8C $6A $3A $40 $D9 $FE $02 $CC $9D $0A $3A $45 $D9
.db $FE $02 $CC $A7 $0A $AF $32 $9B $DD $32 $CB $DD $32 $FB $DD $32
.db $2B $DE $CD $B1 $27 $CD $F2 $1D $CD $64 $31 $CD $7C $31 $CD $3A
.db $34 $CD $45 $34 $CD $3F $3F $CD $3B $52 $CD $59 $3D $CD $BD $3D
.db $CD $C5 $0A $CD $57 $28 $CD $BB $0A $CD $88 $5A $CD $F5 $0A $CD
.db $93 $15 $CD $C0 $16 $CD $18 $03 $CD $27 $49 $3E $0D $32 $00 $80
.db $CD $F1 $B1 $CD $FD $0A $CD $18 $03 $CD $50 $34 $CD $E0 $35 $CD
.db $18 $03 $CD $D4 $73 $CD $18 $03 $CD $4A $08 $CD $18 $03 $CD $23
.db $3A $CD $40 $65 $3A $CB $D5 $B7 $C4 $0B $7B $3A $41 $DC $B7 $20
.db $06 $DB $7E $FE $B8 $30 $4A $CD $C9 $64 $CD $63 $2D $CD $18 $03
.db $3A $99 $D5 $B7 $20 $26 $3A $41 $DC $B7 $28 $17 $CD $69 $51 $CD
.db $74 $51 $CD $18 $03 $3E $0A $32 $00 $80 $CD $D2 $B5 $CD $FD $0A
.db $CD $18 $03 $CD $F0 $0B $CD $E1 $0A $CD $18 $03 $3A $6A $DF $B7
.db $28 $0E $3D $32 $6A $DF $B7 $20 $07 $3C $32 $6A $DF $32 $D6 $D5
.db $C9 $C3 $00 $03 $3A $42 $DC $B7 $C8 $3A $D7 $D5 $B7 $C0 $DB $7E
.db $FE $B8 $38 $0C $FE $F0 $30 $08 $CD $3A $03 $3E $01 $32 $D7 $D5
.db $C9

-:
	xor a
	ld ($DBA8), a
	ret

_LABEL_33A_:
	ld a, ($DBA8)
	cp $01
	jr z, -
	call _LABEL_7795_
	call _LABEL_78CE_
	call _LABEL_7916_
	ld a, ($DED4)
	out ($BF), a
	ld a, $89
	out ($BF), a
	ld a, ($DED3)
	out ($BF), a
	ld a, $88
	out ($BF), a
	call _LABEL_31F1_
	call _LABEL_324C_
	ld a, ($D5CC)
	or a
	jr z, +
	ld a, $05
	ld ($8000), a
	call _LABEL_17E95_
	call _LABEL_AFD_
	xor a
	ld ($D5CC), a
+:
	call _LABEL_BC5_
	call _LABEL_2D07_
	call _LABEL_3FB4_
	jp _LABEL_778C_

; Data from 383 to 9BE (1596 bytes)
.incbin "Micro Machines_383.inc"

_LABEL_9BF_:
	ld a, ($DC42)
	or a
	jr nz, +
	in a, ($05)
	in a, ($04)
	ld ($DC48), a
	pop af
	retn

+:
	in a, ($05)
	in a, ($04)
	ld ($DC47), a
	ld a, ($DC3E)
	or a
	jr nz, +
	in a, ($DC)
	and $3F
	ld ($DC48), a
	ld a, $01
	ld ($D5D8), a
+:
	pop af
	retn

; Data from 9EB to AFC (274 bytes)
.db $00 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40
.db $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40
.db $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40
.db $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40
.db $80 $C0 $77 $77 $77 $77 $78 $78 $78 $78 $79 $79 $79 $79 $7A $7A
.db $7A $7A $7B $7B $7B $7B $7C $7C $7C $7C $7D $7D $7D $7D $7E $7E
.db $7E $7E $77 $77 $77 $77 $78 $78 $78 $78 $79 $79 $79 $79 $7A $7A
.db $7A $7A $7B $7B $7B $7B $7C $7C $7C $7C $7D $7D $7D $7D $7E $7E
.db $7E $7E $14 $10 $10 $10 $10 $18 $18 $18 $18 $08 $10 $18 $20 $28
.db $10 $18 $20 $28 $3C $38 $38 $38 $38 $40 $40 $40 $40 $30 $38 $40
.db $48 $50 $38 $40 $48 $50 $04 $05 $00 $00 $04 $08 $00 $00 $05 $05
.db $00 $00 $3E $0D $32 $00 $80 $CD $07 $AD $18 $56 $3E $0D $32 $00
.db $80 $CD $A5 $AC $18 $4C $3E $0D $32 $00 $80 $CD $DE $A6 $18 $42
.db $3E $0D $32 $00 $80 $CD $B9 $A0 $18 $38 $3A $3D $DC $FE $01 $20
.db $0A $3E $0D $32 $00 $80 $CD $6B $A1 $18 $27 $C9 $3E $06 $32 $00
.db $80 $CD $CB $BC $18 $1C $3E $07 $32 $00 $80 $CD $D8 $B8 $18 $12
.db $3E $06 $32 $00 $80 $CD $B3 $BA $18 $08 $3E $06 $32 $00 $80 $CD
.db $FD $BA

_LABEL_AFD_:
	ld a, ($DE8E)
	ld ($8000), a
	ret

; Data from B04 to BC4 (193 bytes)
.db $3A $3D $DC $B7 $C8 $3E $0D $32 $00 $80 $CD $D0 $A3 $18 $EA $3A
.db $47 $D9 $B7 $20 $0A $3A $7B $DB $FE $01 $28 $03 $C3 $43 $0B $3E
.db $12 $32 $63 $D9 $C3 $3D $0B $3A $47 $D9 $B7 $20 $07 $3A $7B $DB
.db $FE $07 $20 $0B $3E $12 $32 $74 $D9 $21 $B9 $0B $C3 $46 $0B $21
.db $AD $0B $DD $21 $F3 $DA $11 $86 $DA $0E $0C $7E $12 $3E $50 $DD
.db $77 $00 $DD $23 $23 $13 $0D $20 $F2 $3E $02 $32 $81 $D5 $C9 $3A
.db $81 $D5 $FE $A0 $30 $42 $3A $7B $DB $FE $01 $28 $04 $FE $07 $20
.db $07 $DD $21 $B9 $0B $C3 $80 $0B $DD $21 $AD $0B $11 $86 $DA $FD
.db $21 $F3 $DA $0E $06 $3A $81 $D5 $6F $DD $7E $00 $85 $12 $FE $50
.db $30 $05 $AF $12 $FD $77 $00 $13 $13 $DD $23 $DD $23 $FD $23 $3E
.db $02 $85 $32 $81 $D5 $0D $20 $DD $C9 $70 $9C $78 $9D $80 $9E $88
.db $9F $90 $A4 $98 $A5 $70 $96 $78 $97 $80 $98 $88 $99 $90 $9A $98
.db $9B

_LABEL_BC5_:
	ld a, ($DF17)
	or a
	jr z, +
	ld hl, ($DF18)
	ld a, l
	out ($BF), a
	ld a, h
	out ($BF), a
	ld hl, $DC59
	ld b, $40
	ld c, $BE
	otir
	ld hl, $DC79
	ld b, $20
	ld c, $BE
	otir
	ld hl, $DC59
	ld b, $20
	ld c, $BE
	otir
+:
	ret

; Data from BF0 to 2D06 (8471 bytes)
.incbin "Micro Machines_bf0.inc"

_LABEL_2D07_:
	ld a, ($DC54)
	or a
	jr z, ++
	ld a, ($DB97)
	cp $07
	jr nz, +
	call _LABEL_3F22_
	ld a, ($DF74)
	sla a
	ld hl, $2D36
	ld e, a
	ld d, $00
	add hl, de
	ld a, $26
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld a, (hl)
	out ($BE), a
	inc hl
	ld a, (hl)
	out ($BE), a
	call _LABEL_3F36_
+:
	ret

; Data from 2D36 to 2D3F (10 bytes)
.db $00 $00 $00 $08 $40 $08 $80 $0E $00 $00

++:
	ld a, ($DB97)
	cp $07
	jr nz, +
	call _LABEL_3F22_
	ld a, ($DF74)
	ld hl, $2FB7
	ld e, a
	ld d, $00
	add hl, de
	ld a, $13
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld a, (hl)
	out ($BE), a
	call _LABEL_3F36_
+:
	ret

; Data from 2D63 to 31F0 (1166 bytes)
.incbin "Micro Machines_2d63.inc"

_LABEL_31F1_:
	ld a, $00
	out ($BF), a
	ld a, $7F
	out ($BF), a
	ld hl, $DAE0
	ld b, $40
	ld c, $BE
	otir
	ld a, $80
	out ($BF), a
	ld a, $7F
	out ($BF), a
	ld hl, $DA60
	ld b, $80
	ld c, $BE
	otir
	ret

; Data from 3214 to 324B (56 bytes)
.db $21 $E0 $DA $01 $40 $00 $AF $77 $23 $0B $78 $B1 $20 $F8 $21 $60
.db $DA $01 $80 $00 $AF $77 $23 $0B $78 $B1 $20 $F8 $C9 $3A $97 $DB
.db $FE $07 $28 $13 $3E $00 $D3 $BF $3E $72 $D3 $BF $01 $80 $00 $AF
.db $D3 $BE $0B $78 $B1 $20 $F8 $C9

_LABEL_324C_:
	ld c, $BE
	ld d, $00
	ld a, ($DB97)
	cp $07
	jp z, _LABEL_746B_
	ld a, ($DE91)
	or a
	rl a
	rl a
	rl a
	ld e, a
	ld hl, $D980
	add hl, de
	ld a, $00
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $04
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $08
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $0C
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $10
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $14
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $18
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $1C
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	call _LABEL_336A_
	ld a, ($DC3D)
	cp $01
	jr z, +
	call _LABEL_3302_
	jp _LABEL_33D2_

+:
	ld a, $C0
	out ($BF), a
	ld a, $74
	out ($BF), a
	ld a, ($DF24)
	sub $01
	cp $04
	jr nc, +
	sla a
	sla a
	sla a
	sla a
	sla a
	ld e, a
	ld d, $00
	ld a, $0C
	ld ($8000), a
	ld hl, $8C68
	add hl, de
	ld b, $20
	ld c, $BE
	otir
--:
	jp _LABEL_AFD_

+:
	ld b, $20
	xor a
-:
	out ($BE), a
	dec b
	jr nz, -
	jp --

_LABEL_3302_:
	ld c, $BE
	ld ix, $DCAB
	ld d, $00
	ld a, (ix+13)
	or a
	rl a
	rl a
	rl a
	ld e, a
	ld hl, $D980
	add hl, de
	ld a, $21
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $25
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $29
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $2D
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $31
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $35
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $39
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $3D
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ret

_LABEL_336A_:
	ld c, $BE
	ld ix, $DCEC
	ld d, $00
	ld a, (ix+13)
	or a
	rl a
	rl a
	rl a
	ld e, a
	ld hl, $D980
	add hl, de
	ld a, $42
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $46
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $4A
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $4E
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $52
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $56
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $5A
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $5E
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ret

_LABEL_33D2_:
	ld c, $BE
	ld ix, $DD2D
	ld d, $00
	ld a, (ix+13)
	or a
	rl a
	rl a
	rl a
	ld e, a
	ld hl, $D980
	add hl, de
	ld a, $63
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $67
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $6B
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $6F
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $73
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $77
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $7B
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $7F
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ret

; Data from 343A to 3F21 (2792 bytes)
.incbin "Micro Machines_343a.inc"

_LABEL_3F22_:
	ld a, $10
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

; Data from 3F2B to 3F35 (11 bytes)
.db $3E $08 $32 $00 $80 $CD $98 $BB $C3 $FD $0A

_LABEL_3F36_:
	ld a, $70
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

; Data from 3F3F to 3FB3 (117 bytes)
.db $3A $3D $DC $B7 $20 $0E $3E $0D $32 $00 $80 $CD $D3 $A2 $3A $8E
.db $DE $32 $00 $80 $C9 $01 $EF $02 $21 $AB $DC $09 $AF $77 $0B $78
.db $B1 $20 $F5 $C9 $68 $68 $68 $68 $68 $68 $68 $68 $68 $68 $68 $68
.db $68 $6B $68 $68 $68 $68 $6B $68 $6B $68 $78 $68 $6B $68 $6B $78
.db $6B $78 $6B $7B $6B $78 $6B $78 $7B $78 $7B $78 $68 $78 $7B $78
.db $7B $68 $7B $68 $7B $6B $7B $68 $7B $68 $68 $68 $68 $68 $78 $68
.db $68 $68 $68 $68 $68 $68 $68 $7B $68 $68 $68 $68 $68 $68 $68 $68
.db $68 $68 $68 $68 $68

_LABEL_3FB4_:
	ld a, $08
	ld ($8000), a
	call _LABEL_23CE6_
	ld a, ($DE8E)
	ld ($8000), a
	ret

; Data from 3FC3 to 3FFF (61 bytes)
.db $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06
.db $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12
.db $44 $09 $41 $2C $28 $42 $55 $4C $4C $4F $4E $32 $29 $0D $0A $09
.db $4F $52 $09 $41 $0D $0A $09 $4A $52 $09 $5A $2C $00

.BANK 1 SLOT 1
.ORG $0000

; Data from 4000 to 5168 (4457 bytes)
.incbin "Micro Machines_4000.inc"

_LABEL_5169_:
	ld a, $0D
	ld ($8000), a
	call _LABEL_37292_
	jp _LABEL_AFD_

_LABEL_5174_:
	ld a, $0D
	ld ($8000), a
	call _LABEL_3730C_
	jp _LABEL_AFD_

_LABEL_517F_:
	ld a, ($D599)
	xor $01
	ld ($D599), a
	or a
	jr z, +
	ld a, $FF
	out ($7E), a
	ld a, $9F
	out ($7E), a
	ld a, $BF
	out ($7E), a
	ld a, $DF
	out ($7E), a
+:
	pop af
	retn

; Data from 519D to 746A (8910 bytes)
.incbin "Micro Machines_519d.inc"

_LABEL_746B_:
	ld a, $0D
	ld ($8000), a
	call _LABEL_36D52_
	jp _LABEL_AFD_

; Data from 7476 to 778B (790 bytes)
.db $F3 $3E $0A $32 $00 $80 $CD $D5 $B5 $3A $8E $DE $32 $00 $80 $CD
.db $64 $75 $3A $3B $DC $FE $01 $CA $19 $75 $3A $3D $DC $FE $01 $28
.db $4F $3A $55 $DC $FE $00 $CA $45 $75 $FE $1A $CA $20 $75 $FE $1B
.db $CA $20 $75 $FE $1C $CA $20 $75 $3A $4C $DC $B7 $20 $20 $3A $2A
.db $DF $32 $CF $DB $3A $2B $DF $32 $D0 $DB $3A $2C $DF $32 $D2 $DB
.db $3A $2D $DF $32 $D1 $DB $3E $02 $32 $CD $DB $C3 $14 $00 $AF $32
.db $CF $DB $3C $32 $D0 $DB $3C $32 $D1 $DB $3C $32 $D2 $DB $18 $E6
.db $3A $2A $DF $32 $CF $DB $3A $2B $DF $32 $D0 $DB $3A $3F $DC $B7
.db $28 $19 $3A $55 $DC $B7 $20 $0B $3A $80 $DF $FE $01 $28 $08 $AF
.db $32 $CE $DB $3E $05 $18 $06 $3E $01 $18 $F5 $3E $04 $32 $CD $DB
.db $C3 $14 $00 $AF $32 $CD $DB $C3 $14 $00 $3A $39 $DC $C6 $01 $32
.db $39 $DC $AF $32 $0A $DC $3E $03 $32 $CD $DB $3A $8C $DF $FE $01
.db $28 $05 $3E $02 $C3 $3F $75 $3E $03 $32 $38 $DC $C3 $14 $00 $3E
.db $01 $32 $CD $DB $3A $2A $DF $FE $00 $28 $04 $FE $01 $20 $0B $3E
.db $01 $32 $CE $DB $CD $73 $01 $C3 $14 $00 $AF $C3 $57 $75 $3E $3F
.db $32 $47 $DC $32 $48 $DC $32 $20 $DB $32 $21 $DB $C9 $F3 $3A $54
.db $DC $B7 $28 $03 $AF $D3 $05 $3E $20 $D3 $BF $3E $C0 $D3 $BF $AF
.db $D3 $BE $D3 $BE $CD $9F $7A $CD $56 $01 $CD $14 $32 $CD $F1 $31
.db $3A $4B $DC $B7 $28 $05 $3E $05 $32 $09 $DC $3A $3F $DC $B7 $28
.db $05 $3E $01 $32 $3D $DC $3A $0A $DC $E6 $0F $FE $03 $20 $06 $3A
.db $39 $DC $C3 $BE $75 $3A $D8 $DB $32 $55 $DC $21 $6A $76 $16 $00
.db $5F $19 $7E $32 $97 $DB $21 $87 $76 $19 $7E $32 $96 $DB $3A $54
.db $DC $FE $00 $28 $05 $21 $18 $77 $18 $03 $21 $A4 $76 $19 $7E $32
.db $98 $DB $3A $54 $DC $FE $00 $28 $05 $21 $35 $77 $18 $03 $21 $C1
.db $76 $19 $7E $32 $99 $DB $3A $54 $DC $FE $00 $28 $05 $21 $52 $77
.db $18 $03 $21 $DE $76 $19 $7E $32 $9A $DB $3A $54 $DC $FE $00 $28
.db $05 $21 $6F $77 $18 $03 $21 $FB $76 $19 $7E $32 $9B $DB $3E $08
.db $32 $00 $80 $3A $54 $DC $FE $00 $28 $05 $21 $CF $BE $18 $03 $21
.db $E7 $BD $7B $CB $27 $CB $27 $CB $27 $E6 $F8 $5F $16 $00 $19 $11
.db $86 $DB $01 $08 $00 $7E $CB $3F $CB $3F $CB $3F $CB $3F $12 $13
.db $7E $E6 $0F $12 $13 $23 $0B $78 $B1 $20 $EA $3A $8E $DE $32 $00
.db $80 $C3 $83 $03 $02 $01 $00 $05 $03 $01 $04 $05 $02 $03 $08 $01
.db $02 $06 $04 $00 $03 $08 $05 $06 $00 $02 $08 $04 $06 $00 $07 $07
.db $07 $00 $01 $00 $00 $01 $00 $00 $01 $01 $00 $00 $02 $03 $00 $01
.db $01 $02 $01 $02 $01 $02 $02 $02 $02 $02 $02 $00 $01 $02 $09 $08
.db $0B $0A $0B $09 $0B $0A $09 $0B $08 $09 $09 $07 $0B $0B $0B $08
.db $0A $07 $0B $09 $08 $0B $07 $0B $08 $08 $08 $10 $12 $09 $12 $0D
.db $12 $0F $12 $10 $0E $12 $12 $10 $06 $0F $09 $0D $12 $12 $06 $09
.db $10 $12 $0F $06 $09 $13 $13 $13 $12 $05 $16 $27 $19 $12 $1A $27
.db $12 $19 $12 $12 $12 $06 $1A $16 $19 $12 $27 $06 $16 $12 $12 $1A
.db $06 $16 $15 $15 $15 $07 $06 $07 $07 $06 $06 $06 $06 $07 $06 $06
.db $06 $07 $09 $06 $06 $06 $06 $06 $09 $06 $07 $06 $06 $09 $06 $06
.db $06 $06 $07 $06 $0A $08 $09 $07 $09 $08 $07 $09 $06 $07 $07 $05
.db $09 $0A $09 $06 $08 $05 $0A $07 $06 $09 $05 $0A $06 $06 $06 $14
.db $14 $09 $17 $0D $14 $11 $17 $14 $10 $14 $14 $14 $08 $11 $09 $0D
.db $14 $17 $08 $09 $14 $14 $11 $08 $09 $15 $15 $15 $14 $07 $18 $29
.db $1B $14 $1C $29 $14 $1B $14 $14 $14 $08 $1C $18 $1B $14 $29 $08
.db $18 $14 $14 $1C $08 $18 $17 $17 $17 $08 $07 $08 $08 $07 $07 $07
.db $07 $08 $07 $07 $07 $08 $0A $07 $07 $07 $07 $07 $0A $07 $08 $07
.db $07 $0A $07 $07 $07 $07

_LABEL_778C_:
	ld a, $70
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_7795_:
	ld a, $10
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

; Data from 779E to 78CD (304 bytes)
.db $3A $54 $DC $FE $00 $28 $15 $3A $D3 $DE $E6 $F8 $CB $1F $CB $1F
.db $6F $3E $40 $95 $C6 $0A $E6 $3F $32 $BF $DE $C9 $3A $D3 $DE $E6
.db $F8 $CB $1F $CB $1F $6F $3E $40 $95 $E6 $3F $32 $BF $DE $C9 $CD
.db $9E $77 $3A $54 $DC $FE $00 $28 $05 $0E $17 $C3 $DE $77 $0E $1C
.db $3A $D4 $DE $E6 $F8 $CB $1F $CB $1F $CB $1F $81 $47 $21 $ED $09
.db $85 $6F $3E $00 $8C $67 $5E $21 $2D $0A $78 $85 $6F $3E $00 $8C
.db $67 $56 $2A $BF $DE $19 $7D $32 $C3 $DE $7C $32 $C4 $DE $C9 $CD
.db $9E $77 $3A $54 $DC $FE $00 $28 $05 $0E $04 $C3 $1E $78 $0E $1F
.db $3A $D4 $DE $E6 $F8 $CB $1F $CB $1F $CB $1F $81 $47 $21 $ED $09
.db $85 $6F $3E $00 $8C $67 $5E $21 $2D $0A $78 $85 $6F $3E $00 $8C
.db $67 $56 $2A $BF $DE $19 $7D $32 $C3 $DE $7C $32 $C4 $DE $C9 $3A
.db $54 $DC $FE $01 $28 $2C $3A $D4 $DE $E6 $F8 $CB $1F $CB $1F $CB
.db $1F $47 $21 $ED $09 $85 $6F $3E $00 $8C $67 $5E $21 $2D $0A $78
.db $85 $6F $3E $00 $8C $67 $56 $7B $32 $BD $DE $7A $32 $BE $DE $C3
.db $9E $77 $3A $B0 $DE $FE $00 $28 $05 $3E $34 $C3 $8E $78 $3E $0A
.db $4F $3A $D4 $DE $E6 $F8 $CB $1F $CB $1F $CB $1F $C6 $05 $47 $21
.db $ED $09 $85 $6F $3E $00 $8C $67 $5E $21 $2D $0A $78 $85 $6F $3E
.db $00 $8C $67 $56 $7B $32 $BD $DE $7A $32 $BE $DE $3A $D3 $DE $E6
.db $F8 $CB $1F $CB $1F $6F $3E $40 $95 $81 $E6 $3F $32 $BF $DE $C9

_LABEL_78CE_:
	ld a, ($DECB)
	or a
	ret z
	ld a, ($DC54)
	ld b, $20
	or a
	jr z, +
	ld b, $16
+:
	xor a
	ld ($DECB), a
	ld de, $DB22
	ld h, $D8
	ld c, $BE
	exx
	ld hl, ($DEC3)
	ld a, l
	and $C0
	ld b, a
	ld a, l
	srl a
	or $E0
	ld d, a
	ld c, $BF
	out (c), l
	out (c), h
	exx
-:
	ld a, (de)
	out (c), a
	ld l, a
	ld a, (hl)
	out (c), a
	inc de
	exx
	inc d
	jr nz, +
	out (c), b
	out (c), h
+:
	exx
	djnz -
	exx
	ld ($DEC3), hl
	exx
	ret

_LABEL_7916_:
	ld a, ($DECA)
	or a
	ret z
	ld a, ($DC54)
	ld b, $1D
	or a
	jr z, +
	ld b, $13
+:
	xor a
	ld ($DECA), a
	ld de, $DB42
	ld h, $D8
	exx
	ld hl, ($DEC1)
	ld c, $BF
	ld b, $40
	ld d, $7F
	ld e, $77
	exx
	ld c, $BE
-:
	exx
	out (c), l
	out (c), h
	ld a, b
	add a, l
	ld l, a
	jr nc, +
	inc h
	ld a, h
	cp d
	jr nz, +
	ld h, e
+:
	exx
	ld a, (de)
	out (c), a
	ld l, a
	ld a, (hl)
	out (c), a
	inc de
	djnz -
	exx
	ld ($DEC1), hl
	exx
	ret

; Data from 795E to 7FFF (1698 bytes)
.incbin "Micro Machines_795e.inc"

.BANK 2
.ORG $0000

_LABEL_8000_:
	di
	ld hl, $DFFF
	ld sp, hl
	ld a, $00
	ld ($DC3C), a
	call _LABEL_AFAE_
	ld a, $0F
	ld ($D741), a
	ld hl, $AD49
	call $D7BD	; Possibly invalid
	call $C000	; Possibly invalid
	call _LABEL_AFAE_
	call _LABEL_B01D_
	call _LABEL_AFAE_
	ld a, $01
	ld ($DC3E), a
	xor a
	ld ($D6D5), a
	call _LABEL_BD00_
	call _LABEL_BB6C_
	call _LABEL_BB49_
	call _LABEL_B44E_
	call _LABEL_BB5B_
	call _LABEL_BF2E_
	ld a, ($DC3C)
	or a
	jr z, +
	ld a, $38
	out ($05), a
+:
	ld a, ($DBCD)
	or a
	jr nz, +
	call _LABEL_8114_
	jp ++

+:
	dec a
	jr nz, +
	call _LABEL_82DF_
	jp ++

+:
	dec a
	jr nz, +
	call _LABEL_8507_
	jp ++

+:
	dec a
	jr nz, +
	call _LABEL_866C_
	jp ++

+:
	dec a
	jr nz, +
	call _LABEL_8A38_
	jp ++

+:
	dec a
	jr nz, ++
	ld a, ($DBD8)
	or a
	jr nz, +
	call _LABEL_82DF_
	jp ++

+:
	call _LABEL_84AA_
++:
	im 1
	ei
-:
	ld a, ($D6D3)
	dec a
	jr nz, -
	ld a, $00
	ld ($D6D3), a
	call _LABEL_90FF_
	call _LABEL_80E6_
	ld a, ($D6D5)
	dec a
	jr z, +
	ld a, ($D6D4)
	or a
	call z, $D966	; Possibly invalid
	nop
	nop
	nop
	call _LABEL_B45D_
	jp -

+:
	di
	ld a, $00
	ld ($DC3E), a
	jp $DBC0	; Possibly invalid

; Jump Table from 80BE to 80E5 (20 entries, indexed by $D699)
.dw _LABEL_80FC_ _LABEL_8BAB_ _LABEL_8C35_ _LABEL_8CE7_ _LABEL_8D2B_ _LABEL_80FC_ _LABEL_8D79_ _LABEL_8DCC_
.dw _LABEL_8E15_ _LABEL_8E97_ _LABEL_8EF0_ _LABEL_8F93_ _LABEL_8FC4_ _LABEL_9074_ _LABEL_B09F_ _LABEL_8C35_
.dw _LABEL_B56D_ _LABEL_B6B1_ _LABEL_B84D_ _LABEL_B06C_

_LABEL_80E6_:
	call _LABEL_9167_
	ld a, ($D699)
	sla a
	ld c, a
	ld b, $00
	ld hl, $80BE
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	call _LABEL_8100_
; 1st entry of Jump Table from 80BE (indexed by $D699)
_LABEL_80FC_:
	call _LABEL_915E_
	ret

_LABEL_8100_:
	jp (hl)

; Data from 8101 to 8113 (19 bytes)
.db $3A $80 $D6 $E6 $30 $20 $0B $CD $F4 $B1 $3E $8E $32 $41 $D7 $C3
.db $2F $DB $C9

_LABEL_8114_:
	call _LABEL_BB85_
	call _LABEL_B44E_
	ld a, $01
	ld ($D699), a
	ld ($D7B3), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_B337_
	call _LABEL_9400_
	call _LABEL_BAFF_
	call _LABEL_BAD5_
	call _LABEL_BDED_
	call _LABEL_BB13_
	call _LABEL_B323_
	call _LABEL_8CDB_
	ld a, $59
	ld ($DBD4), a
	ld ($DBD5), a
	ld ($DBD6), a
	ld ($DBD7), a
	ld a, $02
	ld ($DC3A), a
	xor a
	ld ($D7B7), a
	ld ($D7B8), a
	ld ($D7B9), a
	ld ($D7B4), a
	ld ($DC3F), a
	ld ($DC3D), a
	ld ($DBD8), a
	ld ($DC3B), a
	ld ($D6D1), a
	ld ($D6D0), a
	ld ($D6C8), a
	ld ($D6C6), a
	ld ($D6C0), a
	ld ($DC0A), a
	ld ($DC34), a
	ld ($DC36), a
	ld ($DC37), a
	call _LABEL_A778_
	call _LABEL_B9B3_
	ld hl, $DC21
	ld bc, $000B
-:
	ld a, $00
	ld (hl), a
	inc hl
	dec bc
	ld a, c
	or a
	jr nz, -
	ld a, $FF
	ld ($D6C4), a
	ld a, $18
	ld ($D6AB), a
	ld a, $01
	ld ($DC35), a
	ld a, $1A
	ld ($DC39), a
	call _LABEL_BF2E_
	ld a, ($DC3C)
	ld ($DC40), a
	ld c, $01
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_81C1_:
	call _LABEL_BB85_
	ld a, $02
	ld ($D699), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_BAFF_
	call _LABEL_BAD5_
	call _LABEL_BDED_
	ld c, $07
	call _LABEL_B1EC_
	ld a, $00
	ld ($D6C7), a
	call _LABEL_BB95_
	call _LABEL_BC0C_
	call _LABEL_A4B7_
	call _LABEL_9317_
	call _LABEL_BDB8_
	ld a, $00
	ld ($D6A0), a
	ld ($D6AB), a
	ld ($D6AC), a
	call _LABEL_A673_
	call _LABEL_BB75_
	ret

_LABEL_8205_:
	call _LABEL_BB85_
	ld a, $03
	ld ($D699), a
	ld a, $00
	ld ($D6C8), a
	call _LABEL_B2DC_
	call _LABEL_B2F3_
	call _LABEL_987B_
	call _LABEL_9434_
	call _LABEL_988D_
	xor a
	ld ($D6B1), a
	ld ($D6B8), a
	ld ($D6B7), a
	ld ($D6B9), a
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DBD4)
	call _LABEL_9F40_
	call _LABEL_B375_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $791A
	jr ++

+:
	ld hl, $7952
++:
	call _LABEL_BCCF_
	ld a, $60
	ld ($D6AF), a
	xor a
	ld ($D6A4), a
	ld ($D6B4), a
	ld ($D6B0), a
	call _LABEL_BDA6_
	ld c, $02
	call _LABEL_B1EC_
	call _LABEL_A67C_
	call _LABEL_97EA_
	call _LABEL_B3AE_
	call _LABEL_BB75_
	ret

_LABEL_8272_:
	call _LABEL_BB85_
	ld a, $04
	ld ($D699), a
	call _LABEL_B2DC_
	ld hl, $7840
	call _LABEL_B35A_
	call _LABEL_95AF_
	ld a, $02
	call _LABEL_B478_
	ld hl, $B3E4
	call $D7BD	; Possibly invalid
	ld hl, $4480
	ld de, $0280
	call _LABEL_AFA5_
	ld a, $24
	ld ($D68A), a
	ld hl, $7A96
	ld a, $08
	ld ($D69B), a
	ld a, $0A
	ld ($D69A), a
	xor a
	ld ($D69C), a
	call _LABEL_BCCF_
	ld c, $05
	call _LABEL_B1EC_
	ld a, $0F
	ld ($D741), a
	ld hl, $7C90
	call _LABEL_B35A_
	ld bc, $0010
	ld hl, $ACC9
	call $DAAA	; Possibly invalid
	ld a, $60
	ld ($D6AF), a
	ld hl, $0170
	ld ($D6AB), hl
	xor a
	ld ($D6C1), a
	call _LABEL_BB75_
	ret

_LABEL_82DF_:
	ld a, $06
	ld ($D699), a
	ld a, $FF
	ld ($D6C4), a
	ld a, ($DBCE)
	or a
	jr z, +
	jp _LABEL_8360_

+:
	call _LABEL_BB85_
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld ($D6B8), a
	ld a, $0B
	ld ($D6B7), a
	ld a, $01
	ld ($D6B4), a
	ld a, $07
	ld ($D6B1), a
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DBD4)
	ld ($DBD3), a
	add a, $01
	call _LABEL_9F40_
	ld hl, $7A1A
	call _LABEL_B8C9_
	ld hl, $7C0E
	call _LABEL_B35A_
	ld bc, $0012
	ld hl, $834E
	call _LABEL_A5B0_
	ld c, $08
	call _LABEL_B1EC_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $01C4
	jr ++

+:
	ld hl, $0200
++:
	ld ($D6AB), hl
	call _LABEL_BB75_
	ret

; Data from 834E to 835F (18 bytes)
.db $05 $00 $08 $0B $04 $03 $0E $13 $1A $0E $10 $14 $00 $0B $08 $05
.db $18 $B4

_LABEL_8360_:
	call _LABEL_BB85_
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld ($D6B8), a
	ld a, $03
	ld ($DC09), a
	ld a, ($DC3F)
	dec a
	jr z, +
	ld a, ($DBD8)
	add a, $01
	ld ($DBD8), a
+:
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DBD4)
	call _LABEL_9F40_
	ld hl, $7A9A
	call _LABEL_B8C9_
	ld hl, $7996
	call _LABEL_B35A_
	ld bc, $0009
	ld hl, $83ED
	call _LABEL_A5B0_
	ld hl, $79D2
	call _LABEL_B35A_
	ld bc, $000E
	ld hl, $83F6
	call _LABEL_A5B0_
	ld a, ($D7B4)
	or a
	jr z, +
	ld hl, $79CE
	call _LABEL_B35A_
	ld bc, $0012
	ld hl, $8404
	call _LABEL_A5B0_
+:
	ld hl, $7C98
	call _LABEL_B35A_
	ld bc, $0006
	ld hl, $8416
	call _LABEL_A5B0_
	ld a, ($DC09)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld c, $06
	call _LABEL_B1EC_
	ld hl, $0190
	ld ($D6AB), hl
	call _LABEL_BB75_
	ret

; Data from 83ED to 841B (47 bytes)
.db $10 $14 $00 $0B $08 $05 $08 $04 $03 $05 $1A $11 $0E $02 $07 $00
.db $0B $0B $04 $0D $06 $04 $B4 $05 $1A $11 $0E $07 $04 $00 $03 $0E
.db $13 $1A $0E $07 $04 $00 $03 $0E $B4 $0B $08 $15 $04 $12 $0E

_LABEL_841C_:
	call _LABEL_BB85_
	ld a, $07
	ld ($D699), a
	call _LABEL_B337_
	call _LABEL_B2DC_
	call _LABEL_A673_
	call _LABEL_B2F3_
	call _LABEL_987B_
	call _LABEL_9434_
	call _LABEL_988D_
	xor a
	ld ($D6B1), a
	ld ($D6C0), a
	ld ($D6B8), a
	ld ($D6B7), a
	ld ($D6C1), a
	xor a
	ld ($D6C3), a
	call _LABEL_AC1E_
	ld a, $60
	ld ($D6AF), a
	xor a
	ld ($D697), a
	ld ($D6B4), a
	ld ($D6AB), a
	ld ($D6B0), a
	ld a, ($DBFC)
	ld ($D6AD), a
	ld a, ($DBFD)
	ld ($D6AE), a
	call _LABEL_B3AE_
	ld c, $02
	call _LABEL_B1EC_
	ld a, ($DBFB)
	ld ($D6A2), a
	ld c, a
	ld b, $00
	call _LABEL_97EA_
	call _LABEL_BB75_
	ret

_LABEL_8486_:
	call _LABEL_BB85_
	ld a, $08
	ld ($D699), a
	call _LABEL_B2BB_
	ld c, $07
	call _LABEL_B1EC_
	call _LABEL_A787_
	call _LABEL_AD42_
	call _LABEL_B230_
	xor a
	ld ($D6AB), a
	ld ($D6AC), a
	call _LABEL_BB75_
	ret

_LABEL_84AA_:
	call _LABEL_BB85_
	ld a, ($DC3F)
	or a
	jr z, _LABEL_84C7_
	ld a, ($DBCF)
	or a
	jp nz, _LABEL_8F73_
	call _LABEL_B269_
	cp $1A
	jr nz, _LABEL_84C7_
	call _LABEL_B877_
	jp _LABEL_80FC_

_LABEL_84C7_:
	ld a, $09
	ld ($D699), a
	call _LABEL_B2BB_
	ld a, ($DC3F)
	dec a
	jr z, +
	call _LABEL_A7B3_
+:
	ld a, $01
	ld ($D6C3), a
	call _LABEL_AC1E_
	call _LABEL_ACEE_
	call _LABEL_AB5B_
	call _LABEL_AB86_
	call _LABEL_ABB0_
	call _LABEL_BA3C_
	ld a, $40
	ld ($D6AF), a
	xor a
	ld ($D6C1), a
	ld ($D6AB), a
	ld ($D6AC), a
	ld c, $05
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_8507_:
	call _LABEL_BB85_
	ld a, $0A
	ld ($D699), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	call _LABEL_9448_
	ld a, ($DC3C)
	dec a
	jr z, +
	call _LABEL_94AD_
	jr ++

+:
	call _LABEL_94F0_
++:
	call _LABEL_B305_
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DC3A)
	ld c, a
	ld a, ($DBCF)
	cp c
	jr nc, +
	ld c, $00
	jp ++

+:
	ld c, $01
++:
	ld a, ($DBD4)
	add a, c
	call _LABEL_9F40_
	ld hl, $4840
	call _LABEL_B35A_
	ld a, ($DC3A)
	ld c, a
	ld a, ($DBD0)
	cp c
	jr nc, +
	ld c, $00
	jp ++

+:
	ld c, $01
++:
	ld a, ($DBD5)
	add a, c
	call _LABEL_9F40_
	ld hl, $4C00
	call _LABEL_B35A_
	ld a, ($DC3A)
	ld c, a
	ld a, ($DBD1)
	cp c
	jr nc, +
	ld c, $00
	jp ++

+:
	ld c, $01
++:
	ld a, ($DBD6)
	add a, c
	call _LABEL_9F40_
	ld hl, $4FC0
	call _LABEL_B35A_
	ld a, ($DC3A)
	ld c, a
	ld a, ($DBD2)
	cp c
	jr nc, +
	ld c, $00
	jp ++

+:
	ld c, $01
++:
	ld a, ($DBD7)
	add a, c
	call _LABEL_9F40_
	call _LABEL_A877_
	ld hl, $78D8
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $85EC
	call _LABEL_A5B0_
	xor a
	ld ($D69C), a
	ld ($D6AB), a
	ld ($D6C1), a
	ld c, $06
	call _LABEL_B1EC_
	ld a, ($DBCF)
	or a
	jr nz, +
	ld a, ($DC39)
	cp $1D
	jr z, +
	ld a, ($DC0A)
	add a, $01
	ld ($DC0A), a
	jr ++

+:
	xor a
	ld ($DC0A), a
++:
	call _LABEL_BB75_
	ret

; Data from 85EC to 85F3 (8 bytes)
.db $11 $04 $12 $14 $0B $13 $12 $B5

_LABEL_85F4_:
	call _LABEL_BB85_
	ld a, $0B
	ld ($D699), a
	ld e, $0E
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld ($D6B8), a
	ld a, $0B
	ld ($D6B7), a
	ld a, $01
	ld ($D6B4), a
	ld a, $07
	ld ($D6B1), a
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($D6C4)
	ld c, a
	ld b, $00
	ld hl, $DBD5
	add hl, bc
	ld a, (hl)
	ld ($DBD3), a
	ld a, $59
	ld (hl), a
	ld a, ($DBD3)
	add a, $01
	call _LABEL_9F40_
	ld hl, $7A1A
	call _LABEL_B8C9_
	ld a, ($DBD3)
	srl a
	srl a
	srl a
	ld c, a
	ld b, $00
	ld hl, $DBFE
	add hl, bc
	ld a, $5A
	ld (hl), a
	ld a, ($D6C4)
	add a, $01
	ld ($D6B9), a
	ld a, $60
	ld ($D6AF), a
	xor a
	ld ($D6AB), a
	ld ($D6AC), a
	ld c, $09
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_866C_:
	call _LABEL_BB85_
	ld a, $0C
	ld ($D699), a
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld ($D6B8), a
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DC38)
	cp $02
	jr nz, +
	ld c, $00
	jp ++

+:
	ld c, $01
++:
	ld a, ($DBD4)
	add a, c
	call _LABEL_9F40_
	ld hl, $7A9A
	call _LABEL_B8C9_
	ld a, ($DC38)
	dec a
	jr z, _LABEL_8717_
	dec a
	jp z, _LABEL_876B_
	dec a
	jp z, _LABEL_87E9_
	ld hl, $7992
	call _LABEL_B35A_
	ld bc, $000E
	ld hl, $882E
	call _LABEL_A5B0_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_
	ld bc, $0006
	ld hl, $884A
	call _LABEL_A5B0_
	ld a, ($DC09)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	call _LABEL_A673_
	ld a, ($DC09)
	add a, $1B
	ld ($D701), a
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, $96
	ld ($D6E1), a
	ld a, $B0
	ld ($D721), a
	jr ++

+:
	ld a, $90
	ld ($D6E1), a
	ld a, $A8
	ld ($D721), a
++:
	call _LABEL_93CE_
	ld c, $0A
	call _LABEL_B1EC_
	ld a, $80
	ld ($D6AB), a
	jp _LABEL_8826_

_LABEL_8717_:
	ld hl, $7992
	call _LABEL_B35A_
	ld bc, $000E
	ld hl, $883C
	call _LABEL_A5B0_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_
	ld bc, $0006
	ld hl, $8850
	call _LABEL_A5B0_
	ld a, ($DBF6)
	cp $0E
	jr z, +
	out ($BE), a
	xor a
	out ($BE), a
+:
	ld a, ($DBF7)
	out ($BE), a
	xor a
	out ($BE), a
	ld c, $08
	call _LABEL_B1EC_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, $E2
	jr ++

+:
	ld a, $FF
++:
	ld ($D6AB), a
	jp _LABEL_8826_

_LABEL_876B_:
	ld hl, $7994
	call _LABEL_B35A_
	ld bc, $000C
	ld hl, $8856
	call _LABEL_A5B0_
	ld hl, $7A14
	call _LABEL_B35A_
	ld bc, $000C
	ld hl, $8862
	call _LABEL_A5B0_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_
	ld bc, $0006
	ld hl, $884A
	call _LABEL_A5B0_
	ld a, ($DC09)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld a, ($DC09)
	cp $09
	jr z, +
	add a, $01
+:
	ld ($DC09), a
	call _LABEL_A673_
	ld a, ($DC09)
	add a, $1A
	ld ($D701), a
	ld a, ($DC3C)
	or a
	jr nz, +
	ld a, $96
	jp ++

+:
	ld a, $90
++:
	ld ($D6E1), a
	ld a, $E0
	ld ($D721), a
	call _LABEL_93CE_
	ld c, $06
	call _LABEL_B1EC_
	ld a, $C8
	ld ($D6AB), a
	jp _LABEL_8826_

_LABEL_87E9_:
	ld hl, $79D6
	call _LABEL_B35A_
	ld bc, $0009
	ld hl, $886E
	call _LABEL_A5B0_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_
	ld bc, $0006
	ld hl, $884A
	call _LABEL_A5B0_
	ld a, ($DC09)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld c, $0A
	call _LABEL_B1EC_
	ld a, $80
	ld ($D6AB), a
_LABEL_8826_:
	xor a
	ld ($D6AC), a
	call _LABEL_BB75_
	ret

; Data from 882E to 8876 (73 bytes)
.db $1A $0D $04 $0E $0B $08 $05 $04 $0E $0B $1A $12 $13 $B4 $0E $0E
.db $06 $00 $0C $04 $0E $1A $15 $04 $11 $B4 $0E $0E $0B $08 $15 $04
.db $12 $0E $0B $04 $15 $04 $0B $0E $18 $1A $14 $0E $0C $00 $03 $04
.db $0E $08 $13 $B4 $0E $04 $17 $13 $11 $00 $0E $0B $08 $05 $04 $0E
.db $0D $1A $0E $0E $01 $1A $0D $14 $12

_LABEL_8877_:
	call _LABEL_BB85_
	ld a, $0D
	ld ($D699), a
	call _LABEL_B2DC_
	call _LABEL_B305_
	ld a, $09
	call _LABEL_B478_
	ld hl, $AB4D
	call $D7BD	; Possibly invalid
	ld hl, $6000
	ld de, $0280
	call _LABEL_AFA5_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7B96
	jr ++

+:
	ld hl, $7A96
++:
	xor a
	ld ($D68A), a
	ld a, $08
	ld ($D69B), a
	ld a, $0A
	ld ($D69A), a
	ld a, $01
	ld ($D69C), a
	call _LABEL_BCCF_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7D90
	jr ++

+:
	ld hl, $7C90
++:
	call _LABEL_B35A_
	ld a, $0F
	ld ($D741), a
	ld bc, $0010
	ld hl, $AD39
	call $DAAA	; Possibly invalid
	ld a, ($DC3C)
	dec a
	jr z, +
	ld de, $7952
	ld hl, $8929
	call _LABEL_B3A4_
	ld de, $79D2
	ld hl, $8937
	call _LABEL_B3A4_
	jr ++

+:
	ld de, $7992
	ld hl, $8929
	call _LABEL_B3A4_
	ld de, $7A12
	ld hl, $8937
	call _LABEL_B3A4_
++:
	ld de, $7A52
	ld hl, $8945
	call _LABEL_B3A4_
	ld a, $40
	ld ($D6AF), a
	xor a
	ld ($D6AB), a
	ld ($D6AC), a
	ld ($D6C1), a
	ld c, $05
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

; Data from 8929 to 8952 (42 bytes)
.db $13 $11 $08 $0F $0B $04 $0E $16 $08 $0D $0E $B4 $B4 $B4 $0E $0E
.db $01 $1A $0D $14 $12 $0E $11 $00 $02 $04 $0E $0E $01 $04 $00 $13
.db $0E $13 $07 $04 $0E $02 $0B $1A $02 $0A

_LABEL_8953_:
	call _LABEL_BB85_
	ld a, $0E
	ld ($D699), a
	ld a, $01
	ld ($D7B4), a
	xor a
	ld ($D6C8), a
	call _LABEL_B2DC_
	call _LABEL_B2F3_
	call _LABEL_987B_
	call _LABEL_9434_
	call _LABEL_988D_
	call _LABEL_A673_
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DBD4)
	call _LABEL_9F40_
	ld a, ($DBD5)
	call _LABEL_9F40_
	ld hl, $7954
	call _LABEL_B8C9_
	ld a, $42
	ld ($D68A), a
	ld a, $06
	ld ($D69B), a
	ld hl, $7962
	call _LABEL_BCCF_
	ld a, $30
	ld ($D6AF), a
	xor a
	ld ($D6CD), a
	ld ($D6AC), a
	ld ($D6C6), a
	ld ($D6B9), a
	ld ($D697), a
	ld ($D6B4), a
	ld ($D6B0), a
	ld ($D6B1), a
	ld ($D6C0), a
	ld ($D6B8), a
	ld ($D6B7), a
	ld ($D6C1), a
	call _LABEL_BDA6_
	ld a, $02
	ld ($D688), a
	call _LABEL_A67C_
	call _LABEL_97EA_
	call _LABEL_B3AE_
	ld c, $02
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_89E2_:
	call _LABEL_BB85_
	ld a, $0F
	ld ($D699), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	ld a, $B2
	ld ($D6C8), a
	call _LABEL_9448_
	call _LABEL_94AD_
	call _LABEL_B305_
	ld a, $01
	ld ($D6C7), a
	ld ($D7B3), a
	call _LABEL_BB95_
	call _LABEL_BC0C_
	call _LABEL_A530_
	ld c, $07
	call _LABEL_B1EC_
	call _LABEL_9317_
	xor a
	ld ($D6A0), a
	ld ($D6AC), a
	call _LABEL_A673_
	call _LABEL_BB75_
	ret

_LABEL_8A30_:
	call _LABEL_BB85_
	ld a, $10
	jp +

_LABEL_8A38_:
	call _LABEL_BB85_
	ld a, $11
+:
	ld ($D699), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	call _LABEL_A296_
	call _LABEL_BA3C_
	call _LABEL_BA4F_
	ld a, ($DC3C)
	or a
	jr z, +
	ld a, ($D699)
	cp $10
	jr z, ++
+:
	ld a, $B2
	ld ($D6C8), a
	call _LABEL_9448_
	call _LABEL_94AD_
	call _LABEL_B305_
++:
	ld a, ($D699)
	cp $11
	jr nz, +
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DBCF)
	ld c, a
	ld a, ($DBD4)
	add a, c
	call _LABEL_9F40_
	ld a, ($DBD0)
	ld c, a
	ld a, ($DBD5)
	add a, c
	call _LABEL_9F40_
	jp ++

+:
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DBD4)
	call _LABEL_9F40_
	ld a, ($DBD5)
	call _LABEL_9F40_
++:
	call _LABEL_B375_
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $7852
	jp ++

+:
	ld hl, $7AD2
++:
	ld a, ($DC3C)
	cp $01
	jr z, +
	ld bc, $0080
	add hl, bc
+:
	call _LABEL_BCCF_
	ld a, $42
	ld ($D68A), a
	ld a, $06
	ld ($D69B), a
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $7864
	jp ++

+:
	ld hl, $7AE4
++:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld bc, $0080
	add hl, bc
+:
	call _LABEL_BCCF_
	call _LABEL_A355_
	call _LABEL_B9ED_
	ld a, $60
	ld ($D6AF), a
	xor a
	ld ($D6AB), a
	ld ($D6AC), a
	ld ($D6C1), a
	ld ($D693), a
	ld ($D6CC), a
	ld ($D6CE), a
	ld a, ($D699)
	cp $11
	jp z, _LABEL_8B89_
	ld a, ($DC34)
	cp $01
	jr z, +
	call _LABEL_A673_
	ld c, $05
	call _LABEL_B1EC_
	call _LABEL_9317_
	ld hl, $B356
	call $D9F5	; Possibly invalid
	jp _LABEL_8B9D_

+:
	call _LABEL_B785_
	ld a, ($DC41)
	or a
	jr z, +
	ld a, ($DC42)
	or a
	jr z, _LABEL_8B55_
-:
	ld a, $CC
	out ($03), a
	ld a, ($DC47)
	cp $3F
	jr z, -
	ld ($D6CF), a
	jr +

_LABEL_8B55_:
	ld a, ($DC48)
	cp $CC
	jr nz, _LABEL_8B55_
	ld a, ($D6CF)
	out ($03), a
+:
	call _LABEL_AF5D_
	ld a, ($D6CF)
	ld c, a
	ld b, $00
	ld hl, $DC2C
	add hl, bc
	ld a, $01
	ld (hl), a
	ld a, c
	call _LABEL_B213_
	ld a, c
	add a, $01
	call _LABEL_AB68_
	call _LABEL_AB9B_
	call _LABEL_ABB0_
	ld c, $05
	call _LABEL_B1EC_
	jp _LABEL_8B9D_

_LABEL_8B89_:
	ld c, $0B
	call _LABEL_B1EC_
	call _LABEL_A0B4_
	call _LABEL_B7FF_
	ld a, ($DC34)
	dec a
	jr nz, _LABEL_8B9D_
	call _LABEL_B785_
_LABEL_8B9D_:
	call _LABEL_A14F_
	xor a
	ld ($D6CB), a
	call _LABEL_BF2E_
	call _LABEL_BB75_
	ret

; 2nd entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8BAB_:
	call _LABEL_AF10_
	ld a, ($D7BB)
	or a
	jr nz, _LABEL_8C2C_
	call _LABEL_BE1A_
	call _LABEL_918B_
	call _LABEL_92CB_
	call _LABEL_B9C4_
	call _LABEL_B484_
	ld a, ($D6D0)
	cp $09
	jr z, _LABEL_8C23_
	ld a, ($DC45)
	cp $07
	jr nz, +
	ld a, $01
	ld ($DC46), a
	jr ++

+:
	cp $0A
	jr nz, ++
	ld a, $02
	ld ($DC46), a
++:
	call _LABEL_B505_
	ld a, ($D6AB)
	or a
	jr z, +
	sub $01
	ld ($D6AB), a
	jp +++

+:
	ld a, ($D680)
	and $10
	jr z, ++
	ld a, ($DC3C)
	or a
	jr z, +++
	ld a, ($DC41)
	or a
	jr z, +
	ld a, ($D681)
	and $10
	jr z, ++
	jr +++

+:
	in a, ($00)
	and $80
	jr nz, +++
++:
	ld a, ($DC41)
	or a
	jr nz, _LABEL_8C2C_
	call _LABEL_B1F4_
	call _LABEL_81C1_
+++:
	jp _LABEL_80FC_

_LABEL_8C23_:
	call _LABEL_B1F4_
	call _LABEL_B70B_
	jp _LABEL_80FC_

_LABEL_8C2C_:
	call _LABEL_B1F4_
	call _LABEL_8953_
	jp _LABEL_80FC_

; 3rd entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8C35_:
	call _LABEL_B9C4_
	ld a, ($D699)
	cp $0F
	jr z, +
	call _LABEL_B433_
	ld hl, ($D6AB)
	inc hl
	ld ($D6AB), hl
	ld a, h
	cp $03
	jr nz, +
	call _LABEL_B1F4_
	call _LABEL_8114_
	jp _LABEL_80FC_

+:
	call _LABEL_8CA2_
	jp +

; Data from 8C5D to 8C5F (3 bytes)
.db $CD $B1 $8C

+:
	ld a, ($D6A0)
	or a
	jp z, _LABEL_80FC_
	ld a, ($D6C9)
	and $10
	jp nz, _LABEL_80FC_
	call _LABEL_B1F4_
	ld a, ($D699)
	cp $0F
	jr z, ++
	ld a, ($D6A0)
	dec a
	jr nz, +
	call _LABEL_AFCD_
	jp _LABEL_80FC_

+:
	call _LABEL_8953_
	jp _LABEL_80FC_

++:
	ld a, ($D6A0)
	dec a
	jr nz, +
	ld a, $01
	ld ($DC34), a
	call _LABEL_8A30_
	jp _LABEL_80FC_

+:
	call _LABEL_8A30_
	jp _LABEL_80FC_

_LABEL_8CA2_:
	ld a, ($D680)
	and $1C
	cp $1C
	jr nz, +
	call _LABEL_B9A3_
	jp ++

+:
	ld a, ($D680)
	ld ($D6C9), a
++:
	and $04
	jr z, +
	ld a, ($D6C9)
	and $08
	jr z, ++
	ret

+:
	ld hl, $B356
	call $D9F5	; Possibly invalid
	ld a, $01
	ld ($D6A0), a
	ret

++:
	ld hl, $B36E
	call $D9F5	; Possibly invalid
	ld a, $02
	ld ($D6A0), a
	ret

_LABEL_8CDB_:
	ld hl, $DC49
	xor a
	ld c, $08
-:
	ld (hl), a
	inc hl
	dec c
	jr nz, -
	ret

; 4th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8CE7_:
	call _LABEL_996E_
	call _LABEL_95C3_
	call _LABEL_9B87_
	call _LABEL_9D4E_
	ld a, ($D6B8)
	or a
	jr z, ++
	ld a, ($D6B8)
	sub $01
	ld ($D6B8), a
	cp $10
	jr z, +
	cp $D0
	jr nc, ++
	ld a, ($D680)
	and $10
	jr nz, ++
+:
	ld a, ($D6A2)
	ld ($DBFB), a
	ld a, ($D6AD)
	ld ($DBFC), a
	ld a, ($D6AE)
	ld ($DBFD), a
	call _LABEL_B1F4_
	call _LABEL_8272_
++:
	jp _LABEL_80FC_

; 5th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8D2B_:
	ld a, ($D6C1)
	dec a
	jr z, ++
	call _LABEL_BA63_
	ld hl, ($D6AB)
	dec hl
	ld ($D6AB), hl
	ld a, h
	or a
	jr nz, +++
	ld a, l
	or a
	jr z, +
	cp $FF
	jr nc, +++
	ld a, ($D680)
	and $10
	jr nz, +++
+:
	call _LABEL_B368_
++:
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
	cp $04
	jr nz, +++
	xor a
	ld ($D6AB), a
	ld a, ($D6C5)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_

+:
	call _LABEL_B1F4_
	ld a, $01
	ld ($D6D5), a
+++:
	jp _LABEL_80FC_

; 7th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8D79_:
	ld a, ($DBCE)
	or a
	jr z, ++++
	ld hl, ($D6AB)
	dec hl
	ld ($D6AB), hl
	ld a, h
	or a
	jr nz, ++
	ld a, l
	or a
	jr z, +
	ld a, l
	cp $FF
	jr nc, ++
	ld a, ($D680)
	and $10
	jr nz, ++
+:
	ld a, $01
	ld ($D6B9), a
	call _LABEL_B1F4_
	ld a, ($DC3F)
	dec a
	jr z, +++
	call _LABEL_841C_
++:
	jp _LABEL_80FC_

+++:
	call _LABEL_84AA_
	jp _LABEL_80FC_

++++:
	call _LABEL_9D4E_
	ld hl, ($D6AB)
	dec hl
	ld ($D6AB), hl
	ld a, l
	or h
	or a
	jr nz, +
	call _LABEL_B1F4_
	call _LABEL_8114_
+:
	jp _LABEL_80FC_

; 8th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8DCC_:
	call _LABEL_996E_
	call _LABEL_95C3_
	call _LABEL_9B87_
	call _LABEL_9D4E_
	call _LABEL_9E70_
	ld a, ($D6C0)
	cp $00
	jr z, +
	ld a, ($DC3C)
	or a
	jr z, +
	in a, ($00)
	and $80
	jr nz, +
	ld a, $01
	ld ($D6C1), a
+:
	ld a, ($D6C1)
	cp $01
	jr nz, +
	ld a, ($D6A2)
	ld ($DBFB), a
	ld a, ($D6AD)
	ld ($DBFC), a
	ld a, ($D6AE)
	ld ($DBFD), a
	call _LABEL_B1F4_
	call _LABEL_8486_
+:
	jp _LABEL_80FC_

; 9th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8E15_:
	ld b, $00
	ld a, ($D6C2)
	ld c, a
	ld a, ($D6AC)
	xor $01
	ld ($D6AC), a
	dec a
	jr z, +
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
+:
	ld a, ($D6AB)
	cp $37
	jr nc, +
	and $04
	cp $04
	jr z, +
	ld a, ($DC0A)
	cp $03
	jp z, _LABEL_B22A_
	call _LABEL_AE46_
	jp _LABEL_8E54_

+:
	ld a, ($DC0A)
	cp $03
	jp z, _LABEL_B254_
	call _LABEL_AE94_
_LABEL_8E54_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld c, $60
	jp ++

+:
	ld c, $72
++:
	ld a, ($D6AB)
	cp c
	jr z, +
	cp $37
	jr c, ++
	ld a, ($D680)
	and $10
	jr nz, ++
	ld a, $01
	ld ($D697), a
+:
	call _LABEL_B1F4_
	ld a, ($DC0A)
	cp $03
	jr nz, +
	xor a
	ld ($DBE8), a
	ld ($DBEC), a
	ld ($DBF0), a
	call _LABEL_8877_
	jp _LABEL_80FC_

+:
	call _LABEL_84AA_
++:
	jp _LABEL_80FC_

; 10th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8E97_:
	ld a, ($D6C1)
	dec a
	jr z, ++
	call _LABEL_A9EB_
	ld a, ($D6AC)
	xor $01
	ld ($D6AC), a
	dec a
	jr z, +
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
+:
	ld a, ($D6AB)
	cp $B8
	jr z, +
	cp $30
	jr c, +++
	ld a, ($D680)
	and $10
	jr nz, +++
+:
	call _LABEL_B368_
++:
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
	cp $04
	jr nz, +++
	xor a
	ld ($D6AB), a
	ld a, ($D6C5)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_

+:
	call _LABEL_B1F4_
	ld a, $01
	ld ($D6D5), a
+++:
	jp _LABEL_80FC_

; 11th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8EF0_:
	ld a, ($D6AB)
	cp $A0
	jr z, +
	add a, $01
	ld ($D6AB), a
	cp $08
	jp z, _LABEL_A8ED_
	cp $28
	jp z, _LABEL_A8F2_
	cp $48
	jp z, _LABEL_A8F7_
	cp $68
	jp z, _LABEL_A8FC_
_LABEL_8F10_:
	call _LABEL_A7ED_
	jp _LABEL_80FC_

+:
	ld a, ($D6C1)
	add a, $01
	ld ($D6C1), a
	cp $F0
	jr z, +
	ld a, ($D680)
	and $10
	jr nz, ++
+:
	call _LABEL_B1F4_
	ld a, ($DBCF)
	cp $02
	jr nc, _LABEL_8F73_
	call _LABEL_B269_
	cp $19
	jr z, +++
	cp $1A
	jr z, ++++
	call _LABEL_A74F_
	cp $FF
	jr z, +
	call _LABEL_85F4_
	jp _LABEL_80FC_

+:
	call _LABEL_8486_
++:
	jp _LABEL_80FC_

+++:
	ld a, $01
	ld ($DC3A), a
	call _LABEL_84AA_
	jp _LABEL_80FC_

++++:
	ld a, ($DBCF)
	or a
	jr z, +
	ld a, ($DBD8)
	sub $01
	ld ($DBD8), a
	jp _LABEL_8F73_

+:
	call _LABEL_B877_
	jp _LABEL_80FC_

_LABEL_8F73_:
	ld a, ($DC09)
	sub $01
	ld ($DC09), a
	or a
	jr z, +
	xor a
	ld ($DC38), a
	call _LABEL_866C_
	jp _LABEL_80FC_

+:
	ld a, $01
	ld ($DC38), a
	call _LABEL_866C_
	jp _LABEL_80FC_

; 12th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8F93_:
	call _LABEL_A692_
	ld a, ($D6AC)
	xor $01
	ld ($D6AC), a
	dec a
	jr z, +
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
+:
	ld a, ($D6AB)
	cp $90
	jr z, +
	cp $37
	jr c, ++
	ld a, ($D680)
	and $10
	jr nz, ++
+:
	call _LABEL_B1F4_
	call _LABEL_841C_
++:
	jp _LABEL_80FC_

; 13th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_8FC4_:
	ld a, ($DC38)
	or a
	jr nz, +
	ld a, ($D721)
	cp $E0
	jr z, _LABEL_902E_
	add a, $01
	ld ($D721), a
	call _LABEL_93CE_
	jp _LABEL_902E_

+:
	ld a, ($D721)
	cp $E1
	jr z, _LABEL_902E_
	ld a, ($DC38)
	cp $02
	jr nz, _LABEL_902E_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, ($D721)
	cp $B0
	jr z, +++
	jr ++

+:
	ld a, ($D721)
	cp $A8
	jr z, +++
++:
	sub $01
	ld ($D721), a
	call _LABEL_93CE_
	jp _LABEL_902E_

+++:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7CA4
	jr ++

+:
	ld hl, $7C64
++:
	call _LABEL_B35A_
	ld a, ($DC09)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld a, $E1
	ld ($D721), a
	call _LABEL_93CE_
_LABEL_902E_:
	ld a, ($D6AC)
	xor $01
	ld ($D6AC), a
	dec a
	jr z, +
	ld a, ($D6AB)
	sub $01
	ld ($D6AB), a
+:
	ld a, ($D6AB)
	cp $00
	jr z, +
	cp $60
	jr nc, +++
	ld a, ($D680)
	and $10
	jr nz, +++
+:
	call _LABEL_B1F4_
	ld a, ($DC38)
	dec a
	jr z, ++
	ld a, ($DC3F)
	dec a
	jr z, +
	call _LABEL_8486_
	jp _LABEL_80FC_

+:
	call _LABEL_84C7_
	jp _LABEL_80FC_

++:
	call _LABEL_8114_
+++:
	jp _LABEL_80FC_

; 14th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_9074_:
	ld a, ($D6C1)
	dec a
	jr z, ++
	ld a, ($D6AC)
	xor $01
	ld ($D6AC), a
	dec a
	jr z, +
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
+:
	ld a, ($D6AB)
	cp $B8
	jr z, +
	cp $37
	jr c, +++
	ld a, ($D680)
	and $10
	jr nz, +++
+:
	call _LABEL_B368_
++:
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
	cp $04
	jr nz, +++
	xor a
	ld ($D6AB), a
	ld a, ($D6C5)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_

+:
	call _LABEL_B1F4_
	ld a, $01
	ld ($D6D5), a
+++:
	jp _LABEL_80FC_

_LABEL_90CA_:
	ld hl, $4000
	call _LABEL_B35A_
	ld de, $3700
-:
	xor a
	out ($BE), a
	dec de
	ld a, d
	or e
	jr nz, -
	ld a, $3F
	ld ($D680), a
	ld ($D681), a
	ld ($D687), a
	ret

_LABEL_90E7_:
	xor a
	ld ($D691), a
	ld ($D692), a
	ld ($D693), a
	ld a, $01
	ld ($D694), a
	ld a, $24
	ld ($D690), a
	call _LABEL_918B_
	ret

_LABEL_90FF_:
	ld a, ($DC3C)
	or a
	jr nz, ++
-:
	in a, ($DC)
	ld b, a
	and $3F
	ld ($D680), a
	ld a, ($DC3C)
	or a
	jr nz, +
	in a, ($DD)
	sla a
	sla a
	and $3C
	ld c, a
	ld a, b
	and $C0
	rl a
	rl a
	rl a
	or c
	ld ($D681), a
+:
	ret

++:
	ld a, ($DC41)
	or a
	jr z, -
	ld a, ($DC42)
	or a
	jr nz, +
	in a, ($DC)
	and $3F
	ld ($D680), a
	out ($03), a
	ld a, ($DC48)
	ld ($D681), a
	ret

+:
	ld a, ($D687)
	ld b, a
	in a, ($DC)
	and $3F
	ld ($D687), a
	out ($03), a
	ld a, b
	ld ($D681), a
	ld a, ($DC47)
	ld ($D680), a
	ret

_LABEL_915E_:
	ld a, $70
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_9167_:
	ld a, $10
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_9170_:
	ld hl, $7700
	call _LABEL_B35A_
	ld d, $00
	ld bc, $0380
-:
	ld a, e
	out ($BE), a
	ld a, $00
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	call _LABEL_AF5D_
	ret

_LABEL_918B_:
	ld a, ($D694)
	or a
	jr z, _LABEL_91E7_
	ld a, ($D690)
	ld ($D68A), a
	ld a, ($D691)
	cp $00
	jr nz, +
	ld hl, $7AD6
	jp ++

+:
	ld hl, $7A96
++:
	xor a
	ld ($D68B), a
--:
	call _LABEL_B35A_
	ld e, $0A
-:
	ld a, ($D691)
	or a
	jr nz, +
	ld a, $0E
	jp ++

+:
	ld a, ($D68A)
++:
	out ($BE), a
	xor a
	out ($BE), a
	ld a, ($D68A)
	add a, $01
	ld ($D68A), a
	dec e
	jr nz, -
	ld a, ($D68B)
	cp $07
	jr z, +
	add a, $01
	ld ($D68B), a
	ld de, $0040
	add hl, de
	jp --

+:
	call _LABEL_9276_
	call _LABEL_91E8_
_LABEL_91E7_:
	ret

_LABEL_91E8_:
	ld a, ($D691)
	add a, $01
	ld ($D691), a
	cp $06
	jr z, _LABEL_91E8_
	cp $0A
	jr nz, +
	xor a
	ld ($D691), a
+:
	add a, $07
	ld ($D6D6), a
	ld a, $01
	ld ($D6D4), a
	xor a
	ld ($D68D), a
	ld a, $C0
	ld ($D68C), a
	ld a, ($D691)
	sla a
	ld d, $00
	ld e, a
	ld hl, $9254
	add hl, de
	ld a, (hl)
	ld ($D7B5), a
	inc hl
	ld a, (hl)
	ld ($D7B6), a
	ld a, ($D692)
	xor $02
	ld ($D692), a
	ld d, $00
	ld hl, $9268
	ld e, a
	add hl, de
	ld a, (hl)
	ld ($D68F), a
	inc hl
	ld a, (hl)
	ld ($D68E), a
	ld a, ($D690)
	xor $50
	ld ($D690), a
	xor a
	ld ($D695), a
	ld ($D696), a
	ld ($D694), a
	ld a, $01
	ld ($D693), a
	ret

; Data from 9254 to 9275 (34 bytes)
.db $4D $AB $A5 $BA $E4 $B3 $2B $AF $5D $B3 $65 $B7 $4D $AB $C8 $AA
.db $6E $B3 $4D $AB $80 $44 $80 $4E $0A $03 $07 $05 $03 $03 $04 $05
.db $05 $0A

_LABEL_9276_:
	ld a, $0F
	ld ($D741), a
	call _LABEL_BEF5_
	ld a, ($D691)
	or a
	rl a
	rl a
	rl a
	rl a
	ld hl, $ACA9
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, ($D691)
	cp $00
	jr z, +++
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, ($D699)
	cp $09
	jr nc, ++
+:
	ld de, $7C90
	jp ++++

++:
	ld de, $7DD0
	jp ++++

+++:
	ld de, $7A90
++++:
	call _LABEL_B361_
	ld bc, $0010
	call $DAAA	; Possibly invalid
	ld a, ($D691)
	or a
	jr nz, +
	ld a, $01
	ld ($D6CB), a
+:
	ret

_LABEL_92CB_:
	ld a, ($D6D4)
	cp $01
	jr z, _LABEL_9316_
	ld a, ($D693)
	or a
	jr z, _LABEL_9316_
	ld a, ($D68C)
	ld h, a
	ld a, ($D68D)
	ld l, a
	ld a, ($D68E)
	ld d, a
	ld a, ($D68F)
	ld e, a
	call _LABEL_B361_
	call $D9D3	; Possibly invalid
	ld a, h
	ld ($D68C), a
	ld a, l
	ld ($D68D), a
	ld a, d
	ld ($D68E), a
	ld a, e
	ld ($D68F), a
	ld hl, ($D695)
	inc hl
	ld ($D695), hl
	dec h
	jr nz, _LABEL_9316_
	ld a, l
	cp $40
	jr nz, _LABEL_9316_
	xor a
	ld ($D693), a
	ld a, $01
	ld ($D694), a
_LABEL_9316_:
	ret

_LABEL_9317_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $936E
	ld de, $9386
	jr ++

+:
	ld hl, $939E
	ld de, $93B6
++:
	ld ix, $D6E1
	ld iy, $D721
	ld bc, $0018
-:
	ld a, ($D699)
	cp $10
	jr z, +
	jp ++

+:
	ld a, (hl)
	add a, $43
	ld (ix+0), a
	ld a, ($DC3C)
	dec a
	jr z, +++
	ld a, (de)
	add a, $18
	ld (iy+0), a
	jp ++++

++:
	ld a, (hl)
	ld (ix+0), a
+++:
	ld a, (de)
	ld (iy+0), a
++++:
	inc hl
	inc de
	inc ix
	inc iy
	dec c
	ld a, c
	or a
	jr nz, -
	ld hl, $B33E
	jp $D9F5	; Possibly invalid

; Data from 936E to 93CD (96 bytes)
.db $6E $76 $7E $86 $8E $96 $6E $76 $7E $86 $8E $96 $6E $76 $7E $86
.db $8E $96 $6E $76 $7E $86 $8E $96 $90 $90 $90 $90 $90 $90 $98 $98
.db $98 $98 $98 $98 $A0 $A0 $A0 $A0 $A0 $A0 $A8 $A8 $A8 $A8 $A8 $A8
.db $65 $6D $75 $7D $85 $8D $65 $6D $75 $7D $85 $8D $65 $6D $75 $7D
.db $85 $8D $65 $6D $75 $7D $85 $8D $78 $78 $78 $78 $78 $78 $80 $80
.db $80 $80 $80 $80 $88 $88 $88 $88 $88 $88 $90 $90 $90 $90 $90 $90

_LABEL_93CE_:
	ld hl, $7F80
	call _LABEL_B35A_
	ld bc, $0020
	ld hl, $D6E1
	ld de, $D701
-:
	ld a, (hl)
	out ($BE), a
	ld a, (de)
	out ($BE), a
	inc hl
	inc de
	dec c
	ld a, c
	or a
	jr nz, -
	ld hl, $7F00
	call _LABEL_B35A_
	ld bc, $0020
	ld hl, $D721
-:
	ld a, (hl)
	out ($BE), a
	inc hl
	dec c
	ld a, c
	or a
	jr nz, -
	ret

_LABEL_9400_:
	ld hl, $7F80
	call _LABEL_B35A_
	ld bc, $0040
-:
	xor a
	out ($BE), a
	xor a
	out ($BE), a
	dec bc
	ld a, c
	or a
	jr nz, -
	ld hl, $7F00
	call _LABEL_B35A_
	ld bc, $0040
-:
	xor a
	out ($BE), a
	dec bc
	ld a, c
	or a
	jr nz, -
	ld bc, $0060
	ld hl, $D6E1
-:
	xor a
	ld (hl), a
	inc hl
	dec bc
	ld a, c
	or a
	jr nz, -
	ret

_LABEL_9434_:
	ld a, $08
	ld ($D741), a
	ld hl, $ABEC
	call $D7BD	; Possibly invalid
	ld de, $0040
	ld hl, $5740
	jp _LABEL_AFA5_

_LABEL_9448_:
	ld a, ($D699)
	cp $0F
	jr c, +
	ld hl, $6200
	jp ++

+:
	ld hl, $5840
++:
	call _LABEL_B35A_
	ld a, $0B
	ld ($D741), a
	ld hl, $BDE0
	call $D7BD	; Possibly invalid
	ld de, $00B0
	call _LABEL_AFA8_
	ld a, $04
	ld ($D741), a
	ld hl, $BD7F
	call $D7BD	; Possibly invalid
	ld de, $00C0
	call _LABEL_AFA8_
	ld a, ($D699)
	cp $13
	jr z, +
	ld a, ($D7B4)
	or a
	jr nz, _LABEL_949B_
_LABEL_948A_:
	ld a, $0A
	ld ($D741), a
	ld hl, $B386
	call $D7BD	; Possibly invalid
	ld de, $0080
	jp _LABEL_AFA8_

_LABEL_949B_:
	ld a, $0A
	ld ($D741), a
	ld hl, $B4CA
	call $D7BD	; Possibly invalid
	ld de, $0070
	jp _LABEL_AFA8_

+:
	ret

_LABEL_94AD_:
	ld a, $04
	ld ($D741), a
	ld a, ($D699)
	cp $0F
	jr c, +
	ld a, $01
	ld ($D69C), a
	jp ++

+:
	xor a
	ld ($D69C), a
++:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld de, $7742
	jr ++

+:
	ld de, $784C
++:
	call _LABEL_B361_
	ld hl, $BF38
	ld a, $08
	ld ($D69D), a
	ld a, $03
	ld ($D69E), a
	ld a, ($D6C8)
	ld c, a
	ld a, $C2
	sub c
	ld ($D69F), a
	call $D997	; Possibly invalid
_LABEL_94F0_:
	ld a, $04
	ld ($D741), a
	ld a, ($DC3C)
	dec a
	jr z, ++
	ld a, ($D7B4)
	or a
	jr nz, +
	ld de, $7794
	jp +++

+:
	ld de, $7792
	jp +++

++:
	ld de, $785C
	ld a, ($D699)
	cp $0A
	jr nz, +++
	ld de, $784C
+++:
	call _LABEL_B361_
	ld hl, $BF50
	ld a, $0C
	ld ($D69D), a
	ld a, $02
	ld ($D69E), a
	ld a, ($D6C8)
	ld c, a
	ld a, $D8
	sub c
	ld ($D69F), a
	call $D997	; Possibly invalid
	ld a, $0A
	ld ($D741), a
	ld a, ($DC3C)
	dec a
	jr z, ++
	ld a, ($D7B4)
	or a
	jr nz, +
	ld de, $77AC
	jp +++

+:
	ld de, $77AA
	jp +++

++:
	ld a, ($D699)
	cp $0A
	jr z, +
	ld a, ($D7B4)
	or a
	jr nz, ++
	ld de, $78E2
	jp +++

+:
	ld de, $7864
	jp +++

++:
	ld de, $78DE
+++:
	call _LABEL_B361_
	ld a, ($D7B4)
	or a
	jr nz, +
	ld hl, $B4BA
	ld a, $08
	jp ++

+:
	ld hl, $B5BE
	ld a, $0A
++:
	ld ($D69D), a
	ld a, $02
	ld ($D69E), a
	ld a, ($D6C8)
	ld c, a
	ld a, $F0
	sub c
	ld ($D69F), a
	call $D997	; Possibly invalid
	ret

_LABEL_959C_:
	ld a, $08
	ld ($D741), a
	ld hl, $7680
	call _LABEL_B35A_
	ld e, $20
	ld hl, $AB2C
	jp $D985	; Possibly invalid

_LABEL_95AF_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld e, $20
-:
	ld a, $B7
	out ($BE), a
	ld a, $01
	out ($BE), a
	dec e
	jr nz, -
+:
	ret

_LABEL_95C3_:
	ld a, ($D6B4)
	cp $01
	jr z, +
	ld a, ($D6BA)
	cp $00
	jr nz, +
	ld a, ($D6B0)
	cp $00
	jr nz, +
	ld a, ($D6AB)
	cp $00
	jr z, ++
	sub $01
	ld ($D6AB), a
+:
	ret

++:
	ld a, ($D6A4)
	cp $00
	jp nz, _LABEL_96F6_
	ld a, ($D6A3)
	cp $01
	jr z, _LABEL_9636_
	cp $02
	jp z, _LABEL_96A3_
	ld a, ($D6C6)
	dec a
	jr z, +
-:
	ld a, ($D680)
	jp ++

+:
	ld a, ($DC3F)
	cp $01
	jr z, +++
	ld a, ($DC3C)
	or a
	jr z, +
	ld a, ($DC41)
	or a
	jr z, -
+:
	ld a, ($D681)
++:
	ld c, a
	and $08
	jr z, +++
	ld a, c
	and $04
	jr z, _LABEL_9693_
	ret

+++:
	ld a, $01
	ld ($D6A3), a
	ld a, $02
	ld ($D6A4), a
	call _LABEL_97AF_
	jp _LABEL_96F6_

_LABEL_9636_:
	ld a, ($D6A4)
	cp $00
	jp nz, _LABEL_96F6_
	ld a, ($DC3C)
	dec a
	jr z, ++
	ld a, ($D6A2)
	add a, $01
	cp $30
	jr nz, +
	xor a
+:
	ld ($D6A2), a
	sub $03
	and $07
	jp nz, _LABEL_96EC_
	jp +++

++:
	ld a, ($D6A2)
	add a, $01
	cp $1E
	jr nz, +
	xor a
+:
	ld ($D6A2), a
	ld hl, $9817
	ld b, $00
	ld a, ($D6A2)
	ld c, a
	add hl, bc
	ld a, (hl)
	or a
	jr z, _LABEL_96EC_
+++:
	xor a
	ld ($D6A3), a
	ld a, $08
	ld ($D6AB), a
	ld a, ($DC3F)
	or a
	jr z, +
	ld a, ($D7B3)
	or a
	jr z, +
	sub $01
	ld ($D7B3), a
+:
	jp _LABEL_96EC_

_LABEL_9693_:
	ld a, $02
	ld ($D6A3), a
	ld a, $02
	ld ($D6A4), a
	call _LABEL_977F_
	jp _LABEL_96F6_

_LABEL_96A3_:
	ld a, ($D6A4)
	cp $00
	jr nz, _LABEL_96F6_
	ld a, ($DC3C)
	dec a
	jr z, ++
	ld a, ($D6A2)
	sub $01
	cp $FF
	jr nz, +
	ld a, $2F
+:
	ld ($D6A2), a
	sub $03
	and $07
	jr nz, _LABEL_96EC_
	jp +++

++:
	ld a, ($D6A2)
	sub $01
	cp $FF
	jr nz, +
	ld a, $1D
+:
	ld ($D6A2), a
	ld hl, $9817
	ld b, $00
	ld a, ($D6A2)
	ld c, a
	add hl, bc
	ld a, (hl)
	or a
	jr z, _LABEL_96EC_
+++:
	xor a
	ld ($D6A3), a
	ld a, $08
	ld ($D6AB), a
_LABEL_96EC_:
	ld b, $00
	ld a, ($D6A2)
	ld c, a
	call _LABEL_97EA_
	ret

_LABEL_96F6_:
	ld a, ($D6A4)
	cp $01
	jr z, _LABEL_973C_
	ld hl, $9773
_LABEL_9700_:
	ld a, ($DC3C)
	cp $01
	jr z, +
	ld a, ($D6A2)
	sub $03
	sra a
	sra a
	jr ++

+:
	push hl
	ld a, ($D6A2)
	ld c, a
	ld b, $00
	ld hl, $9849
	add hl, bc
	ld a, (hl)
	pop hl
++:
	ld b, $00
	ld c, a
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld ($D6A8), de
	call _LABEL_B361_
	ld a, ($D6AA)
	call _LABEL_9F81_
	ld a, ($D6A4)
	sub $01
	ld ($D6A4), a
	ret

_LABEL_973C_:
	ld hl, ($D6A8)
	ld bc, $01E0
	add hl, bc
	call _LABEL_B35A_
	ld hl, ($D6A6)
	ld a, ($D6AA)
	call _LABEL_9FB8_
	ld a, ($D6A4)
	sub $01
	ld ($D6A4), a
	call _LABEL_AECD_
	ret

; Data from 975B to 977E (36 bytes)
.db $80 $67 $40 $6B $00 $6F $C0 $72 $00 $60 $C0 $63 $C0 $63 $80 $67
.db $40 $6B $00 $6F $C0 $72 $00 $60 $C0 $72 $00 $60 $C0 $63 $80 $67
.db $40 $6B $00 $6F

_LABEL_977F_:
	ld a, ($D6AE)
	sub $01
	cp $FF
	jr nz, +
	ld a, $0A
+:
	ld ($D6AE), a
	ld a, ($D6AD)
	sub $01
	cp $FF
	jr nz, +
	ld a, $0A
+:
	ld ($D6AD), a
	ld c, a
	ld b, $00
	ld hl, $DBFE
	add hl, bc
	ld a, (hl)
	ld ($D6AA), a
	ld hl, $97DF
	add hl, bc
	ld a, (hl)
	ld ($D6BB), a
	ret

_LABEL_97AF_:
	ld a, ($D6AD)
	add a, $01
	cp $0B
	jr nz, +
	ld a, $00
+:
	ld ($D6AD), a
	ld a, ($D6AE)
	add a, $01
	cp $0B
	jr nz, +
	ld a, $00
+:
	ld ($D6AE), a
	ld c, a
	ld b, $00
	ld hl, $DBFE
	add hl, bc
	ld a, (hl)
	ld ($D6AA), a
	ld hl, $97DF
	add hl, bc
	ld a, (hl)
	ld ($D6BB), a
	ret

; Data from 97DF to 97E9 (11 bytes)
.db $00 $08 $10 $18 $20 $28 $30 $38 $40 $48 $50

_LABEL_97EA_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, $06
	ld ($D741), a
	ld hl, $7C00
	call _LABEL_B35A_
	ld hl, $B7A7
	add hl, bc
	ld e, $C0
	jp $DA18	; Possibly invalid

+:
	ld a, $06
	ld ($D741), a
	ld hl, $B987
	add hl, bc
	ld b, $42
	ld c, $0B
	ld de, $7B0C
	jp $DA38	; Possibly invalid

; Data from 9817 to 987A (100 bytes)
.db $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00
.db $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00
.db $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01
.db $00 $00 $00 $00 $00 $00 $00 $02 $02 $02 $02 $02 $04 $04 $04 $04
.db $04 $06 $06 $06 $06 $06 $08 $08 $08 $08 $08 $0A $0A $0A $0A $0A
.db $0C $0C $0C $0C $0C $0E $0E $0E $0E $0E $10 $10 $10 $10 $10 $12
.db $12 $12 $12 $12

_LABEL_987B_:
	ld hl, $7680
	call _LABEL_B35A_
	ld bc, $0020
-:
	xor a
	out ($BE), a
	dec bc
	ld a, c
	or a
	jr nz, -
	ret

_LABEL_988D_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $98AE
	jp ++

+:
	ld hl, $990E
++:
	ld de, $D6E1
	ld bc, $0060
-:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
	dec c
	ld a, c
	or a
	jr nz, -
	jp _LABEL_93CE_

; Data from 98AE to 996D (192 bytes)
.db $62 $6A $72 $7A $82 $8A $92 $9A $62 $62 $62 $62 $62 $62 $62 $62
.db $9A $9A $9A $9A $9A $9A $9A $9A $62 $6A $72 $7A $82 $8A $92 $9A
.db $BA $BB $BB $BB $BB $BB $BB $BC $BD $BD $BD $BD $BD $BD $BD $BD
.db $BE $BE $BE $BE $BE $BE $BE $BE $BF $C0 $C0 $C0 $C0 $C0 $C0 $C1
.db $8F $8F $8F $8F $8F $8F $8F $8F $97 $9F $A7 $AF $B7 $BF $C7 $CF
.db $97 $9F $A7 $AF $B7 $BF $C7 $CF $D7 $D7 $D7 $D7 $D7 $D7 $D7 $D7
.db $40 $48 $50 $58 $60 $68 $70 $FF $40 $40 $40 $40 $40 $40 $FF $FF
.db $70 $70 $70 $70 $70 $70 $FF $FF $40 $48 $50 $58 $60 $68 $70 $FF
.db $BA $BB $BB $BB $BB $BB $BC $FF $BD $BD $BD $BD $BD $BD $BD $BD
.db $BE $BE $BE $BE $BE $BE $BE $BE $BF $C0 $C0 $C0 $C0 $C0 $C1 $FF
.db $77 $77 $77 $77 $77 $77 $77 $FF $7F $87 $8F $97 $9F $A7 $FF $FF
.db $7F $87 $8F $97 $9F $A7 $FF $FF $AF $AF $AF $AF $AF $AF $AF $FF

_LABEL_996E_:
	ld a, ($D6C6)
	dec a
	jr nz, +
	ld a, ($DC3F)
	dec a
	jp z, _LABEL_9A0E_
+:
	ld a, ($D6AF)
	cp $00
	jr z, _LABEL_99D2_
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	and $01
	jp nz, _LABEL_9A0E_
	ld a, ($DC3C)
	dec a
	jp z, _LABEL_9A6D_
	ld hl, $7B08
	call _LABEL_B35A_
	ld a, ($D6C0)
	dec a
	jr z, +++
	ld a, ($D6CA)
	dec a
	jr z, ++++
	ld a, ($D699)
	cp $07
	jr z, +
	jp ++

+:
	ld bc, $0018
	ld hl, $9A3D
	call _LABEL_A5B0_
	ret

++:
	ld bc, $0018
	ld hl, $9A25
	call _LABEL_A5B0_
	ret

+++:
	ld bc, $0018
	ld hl, $9A55
	call _LABEL_A5B0_
_LABEL_99D2_:
	ret

++++:
	ld hl, $7B1A
	call _LABEL_B35A_
	ld a, ($DBD3)
	ld c, a
	ld b, $00
	ld hl, $A6EF
	add hl, bc
	ld bc, $0007
	call _LABEL_A5B0_
	ld a, $B6
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld a, ($DBD3)
	cp $10
	jr z, +
	ld hl, $7B0E
	jp ++

+:
	ld hl, $7B0A
++:
	call _LABEL_B35A_
	ld bc, $0009
	ld hl, $9B7E
	call _LABEL_A5B0_
	ret

_LABEL_9A0E_:
	ld a, ($DC3C)
	dec a
	jp z, _LABEL_9B18_
	ld hl, $7B08
	call _LABEL_B35A_
	ld bc, $0018
	ld hl, $AAAE
	call _LABEL_A5B0_
	ret

; Data from 9A25 to 9A6C (72 bytes)
.db $0E $16 $07 $1A $0E $03 $1A $0E $18 $1A $14 $0E $16 $00 $0D $13
.db $0E $13 $1A $0E $01 $04 $B6 $0E $16 $07 $1A $0E $03 $1A $0E $18
.db $1A $14 $0E $16 $00 $0D $13 $0E $13 $1A $0E $11 $00 $02 $04 $B6
.db $0E $0F $14 $12 $07 $0E $12 $13 $00 $11 $13 $0E $13 $1A $0E $02
.db $1A $0D $13 $08 $0D $14 $04 $0E

_LABEL_9A6D_:
	ld a, ($D6C0)
	dec a
	jr z, _LABEL_9ABB_
	ld a, ($D6CA)
	dec a
	jp z, _LABEL_9AE9_
	ld hl, $7B64
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $9B46
	call _LABEL_A5B0_
	ld hl, $7BE4
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $9B4E
	call _LABEL_A5B0_
	ld hl, $7C64
	call _LABEL_B35A_
	ld bc, $0008
	ld a, ($D699)
	cp $07
	jr z, +
	jp ++

+:
	ld hl, $9B5E
	call _LABEL_A5B0_
	jp _LABEL_99D2_

++:
	ld hl, $9B56
	call _LABEL_A5B0_
	ret

_LABEL_9ABB_:
	ld hl, $7B64
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $9B66
	call _LABEL_A5B0_
	ld hl, $7BE4
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $9B6E
	call _LABEL_A5B0_
	ld hl, $7C64
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $9B76
	call _LABEL_A5B0_
	ret

_LABEL_9AE9_:
	ld hl, $7B64
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $9B7E
	call _LABEL_A5B0_
	ld hl, $7BE6
	call _LABEL_B35A_
	ld a, ($DBD3)
	ld c, a
	ld b, $00
	ld hl, $A6EF
	add hl, bc
	inc hl
	ld bc, $0006
	call _LABEL_A5B0_
	ld a, $B6
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_9B18_:
	ld hl, $7B64
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $AAAE
	call _LABEL_A5B0_
	ld hl, $7BE4
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $AAAE
	call _LABEL_A5B0_
	ld hl, $7C64
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $AAAE
	call _LABEL_A5B0_
	ret

; Data from 9B46 to 9B86 (65 bytes)
.db $16 $07 $1A $0E $03 $1A $0E $0E $18 $1A $14 $0E $16 $00 $0D $13
.db $13 $1A $0E $01 $04 $0E $B6 $0E $13 $1A $0E $11 $00 $02 $04 $B6
.db $0F $14 $12 $07 $0E $0E $0E $0E $12 $13 $00 $11 $13 $0E $13 $1A
.db $02 $1A $0D $13 $08 $0D $14 $04 $07 $00 $0D $03 $08 $02 $00 $0F
.db $0E

_LABEL_9B87_:
	ld a, ($D6BA)
	cp $00
	jp nz, _LABEL_9C5D_
	ld a, ($D6A3)
	cp $00
	jp nz, _LABEL_9C5D_
	ld a, ($D6AB)
	cp $08
	jp z, _LABEL_9C5D_
	ld a, ($D6B0)
	cp $01
	jp z, _LABEL_9C64_
	ld a, ($D6B4)
	cp $01
	jp z, _LABEL_9C5D_
	ld a, ($D6C6)
	cp $01
	jr z, +
-:
	ld a, ($D680)
	jp ++

+:
	ld a, ($D7B3)
	cp $00
	jr z, +++
	ld a, ($DC3C)
	or a
	jr z, +
	ld a, ($DC41)
	or a
	jr z, -
+:
	ld a, ($D681)
++:
	and $10
	jp nz, _LABEL_9C5D_
+++:
	ld a, ($D6C4)
	cp $FF
	jr z, +
	add a, $02
	ld c, a
	ld a, ($D6B9)
	cp c
	jr nz, +
	jp _LABEL_9C5E_

+:
	ld a, ($D6B9)
	cp $04
	jr z, _LABEL_9C5E_
	ld e, a
	ld d, $00
	ld a, ($DC3C)
	xor $01
	add a, $01
	ld c, a
	ld a, ($D6AD)
	add a, c
	cp $0B
	jr c, +
	sub $0B
+:
	ld c, a
	ld b, $00
	ld hl, $DBFE
	add hl, bc
	ld a, (hl)
	cp $58
	jr z, _LABEL_9C5D_
	cp $5A
	jr z, _LABEL_9C5D_
	ld a, $58
	ld (hl), a
	ld ($D6AA), a
	ld hl, $97DF
	add hl, bc
	ld a, (hl)
	ld ($DBD3), a
	ld ($D6BB), a
	ld hl, $DBD4
	add hl, de
	ld (hl), a
	ld a, $01
	ld ($D6B4), a
	ld ($D6B0), a
	ld a, $02
	ld ($D6A4), a
	ld a, $07
	ld ($D6B1), a
	ld a, ($D6C4)
	cp $FF
	jr z, +
	add a, $01
	ld c, a
	ld a, ($D6B9)
	cp c
	call z, _LABEL_B30E_
	jp _LABEL_9C64_

+:
	ld a, ($D6B9)
	cp $03
	call z, _LABEL_B30E_
	jp _LABEL_9C64_

_LABEL_9C5D_:
	ret

_LABEL_9C5E_:
	ld a, $01
	ld ($D6C1), a
	ret

_LABEL_9C64_:
	ld a, ($D6A4)
	cp $01
	jp z, _LABEL_973C_
	ld a, ($DC3C)
	cp $01
	jr z, +
	ld hl, $975B
	jp _LABEL_9700_

+:
	ld hl, $9767
	jp _LABEL_9700_

; Data from 9C7F to 9D4D (207 bytes)
.db $40 $8B $10 $8E $40 $8B $00 $10 $40 $8B $10 $8E $10 $8E $00 $10
.db $A0 $B2 $70 $B5 $A0 $B2 $00 $10 $A0 $B2 $70 $B5 $70 $B5 $00 $10
.db $40 $B8 $10 $BB $40 $B8 $00 $10 $40 $B8 $10 $BB $10 $BB $00 $10
.db $80 $96 $50 $99 $80 $96 $00 $10 $80 $96 $50 $99 $50 $99 $00 $10
.db $60 $A7 $30 $AA $60 $A7 $00 $10 $60 $A7 $30 $AA $30 $AA $00 $10
.db $A0 $85 $70 $88 $A0 $85 $00 $10 $A0 $85 $70 $88 $70 $88 $00 $10
.db $00 $AD $D0 $AF $00 $AD $00 $10 $00 $AD $D0 $AF $D0 $AF $00 $10
.db $20 $9C $F0 $9E $20 $9C $00 $10 $20 $9C $F0 $9E $F0 $9E $00 $10
.db $C0 $A1 $90 $A4 $C0 $A1 $00 $10 $C0 $A1 $90 $A4 $90 $A4 $00 $10
.db $00 $80 $D0 $82 $00 $80 $00 $10 $00 $80 $D0 $82 $D0 $82 $00 $10
.db $E0 $90 $B0 $93 $E0 $90 $00 $10 $E0 $90 $B0 $93 $B0 $93 $00 $10
.db $3C $B9 $6C $B6 $3C $B9 $00 $10 $0B $0B $0B $0B $0B $0B $0B $0B
.db $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $05

_LABEL_9D4E_:
	ld a, ($D6B1)
	cp $00
	jr z, ++
	sub $01
	cp $01
	jr nz, +
	ld a, $04
+:
	ld ($D6B1), a
	cp $04
	jr z, _LABEL_9DBD_
	cp $03
	jr z, +++
	cp $02
	jr z, ++++
++:
	ret

+++:
	ld a, ($D6B9)
	sla a
	ld c, a
	ld b, $00
	ld hl, $9DAD
	add hl, bc
	ld a, (hl)
	out ($BF), a
	inc hl
	ld a, (hl)
	out ($BF), a
	ld a, ($D6B6)
	jp _LABEL_9F81_

++++:
	ld a, ($D6B9)
	sla a
	ld c, a
	ld b, $00
	ld hl, $9DB5
	add hl, bc
	ld a, (hl)
	out ($BF), a
	inc hl
	ld a, (hl)
	out ($BF), a
	ld hl, ($D6A6)
	ld a, ($D6B6)
	call _LABEL_9FAB_
	ld a, ($D6BA)
	cp $00
	jr z, +
	call _LABEL_9E29_
+:
	ret

; Data from 9DAD to 9DBC (16 bytes)
.db $80 $44 $40 $48 $00 $4C $C0 $4F $60 $46 $20 $4A $E0 $4D $A0 $51

_LABEL_9DBD_:
	ld a, ($DBD3)
	ld e, a
	ld a, ($D6BA)
	cp $00
	jr nz, +
	ld hl, $9E13
	ld a, ($D6B7)
	ld c, a
	ld b, $00
	add hl, bc
	ld a, ($D6B5)
	ld c, a
	add hl, bc
	ld a, (hl)
	cp $FF
	jr z, ++
	add a, e
+:
	ld ($D6B6), a
	ld a, ($D6B5)
	add a, $01
	ld ($D6B5), a
	ret

++:
	ld a, $00
	ld ($D6B1), a
	ld ($D6B5), a
	ld a, $F0
	ld ($D6B8), a
	ld a, ($D699)
	cp $03
	jr z, +
	cp $0E
	jr z, ++
	ld a, $00
	ld ($D6B4), a
	ld a, ($D6B9)
	cp $04
	jr z, +
	add a, $01
	ld ($D6B9), a
+:
	ret

; Data from 9E13 to 9E28 (22 bytes)
.db $04 $02 $04 $02 $04 $00 $FF $FF $FF $FF $FF $06 $05 $06 $05 $06
.db $05 $06 $05 $06 $01 $FF

_LABEL_9E29_:
	ld a, $00
	ld ($D6B1), a
	ld ($D6B5), a
	ld ($D6BA), a
	ld ($D6B4), a
	ld a, $F0
	ld ($D6B8), a
	ret

++:
	ld a, ($DBD3)
	srl a
	srl a
	srl a
	cp $02
	jr z, +
	cp $06
	jr z, +
	cp $09
	jr z, +
_LABEL_9E52_:
	xor a
	ld ($D6CD), a
	ld ($D6B4), a
	ld a, ($D6B9)
	add a, $01
	ld ($D6B9), a
	call _LABEL_A5BE_
	ret

+:
	ld a, $01
	ld ($D6CA), a
	ld a, $40
	ld ($D6AF), a
	ret

_LABEL_9E70_:
	ld a, ($D6B4)
	cp $01
	jp z, _LABEL_9F3F_
	ld a, ($D6A3)
	cp $00
	jp nz, _LABEL_9F3F_
	ld a, ($D6AB)
	cp $08
	jp z, _LABEL_9F3F_
	ld a, ($D6B0)
	cp $01
	jp z, _LABEL_9C64_
	ld a, ($D699)
	cp $0E
	jr z, +
	ld a, ($D6B9)
	cp $01
	jp z, _LABEL_9F3F_
+:
	ld a, ($D6B9)
	cp $00
	jp z, _LABEL_9F3F_
	ld a, ($D6C4)
	cp $FF
	jr z, +
	add a, $01
	ld c, a
	ld a, ($D6B9)
	cp c
	jp z, _LABEL_9F3F_
+:
	ld a, ($D697)
	cp $00
	jr z, +
	ld a, ($D680)
	and $20
	jr z, _LABEL_9F3F_
	ld a, $00
	ld ($D697), a
+:
	ld a, ($D680)
	and $20
	jr nz, _LABEL_9F3F_
	ld a, $01
	ld ($D697), a
	ld a, ($D6B9)
	sub $01
	ld e, a
	ld d, $00
	ld hl, $DBD4
	add hl, de
	ld e, (hl)
	ld a, ($DC3C)
	xor $01
	add a, $01
	ld c, a
	ld a, ($D6AD)
	add a, c
	cp $0B
	jr c, +
	sub $0B
+:
	ld c, a
	ld b, $00
	ld hl, $97DF
	add hl, bc
	ld a, (hl)
	ld ($D6BB), a
	cp e
	jr nz, _LABEL_9F3F_
	ld hl, $DBFE
	add hl, bc
	add a, $01
	ld (hl), a
	ld ($D6AA), a
	ld a, $59
	ld ($D6BA), a
	ld a, $01
	ld ($D6B0), a
	ld a, $02
	ld ($D6A4), a
	ld a, $07
	ld ($D6B1), a
	ld a, ($D6C4)
	cp $FF
	jr z, +
	call _LABEL_B31C_
	jp ++

+:
	ld a, ($D6B9)
	cp $04
	call z, _LABEL_B31C_
++:
	sub $01
	ld ($D6B9), a
	jp _LABEL_9C64_

_LABEL_9F3F_:
	ret

_LABEL_9F40_:
	ld ($D6A1), a
	ld hl, $9D37
	ld a, ($D6A1)
	sra a
	sra a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld ($D741), a
	ld d, $00
	ld hl, $9C7F
	ld a, ($D6A1)
	sla a
	ld e, a
	add hl, de
	ld a, (hl)
	ld c, a
	inc hl
	ld a, (hl)
	ld h, a
	ld l, c
	ld de, $003C
	ld a, ($D6A1)
	cp $58
	jr z, _LABEL_9F74_
	jp $DA67	; Possibly invalid

_LABEL_9F74_:
	ld hl, $BD6C
	ld b, $10
	ld c, $BE
	otir
	dec e
	jr nz, _LABEL_9F74_
	ret

_LABEL_9F81_:
	ld ($D6A1), a
	ld hl, $9D37
	ld a, ($D6A1)
	sra a
	sra a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld ($D6A5), a
	ld ($D741), a
	ld d, $00
	ld hl, $9C7F
	ld a, ($D6A1)
	sla a
	ld e, a
	add hl, de
	ld a, (hl)
	ld c, a
	inc hl
	ld a, (hl)
	ld h, a
	ld l, c
_LABEL_9FAB_:
	ld de, $001E
	ld a, ($D6A1)
	cp $58
	jr z, _LABEL_9F74_
	jp $DA7C	; Possibly invalid

_LABEL_9FB8_:
	ld de, $0014
	ld a, ($D6A1)
	cp $58
	jr z, _LABEL_9F74_
	jp $DA93	; Possibly invalid

_LABEL_9FC5_:
	ld a, ($DC3B)
	or a
	jr z, +
	jp _LABEL_AA02_

+:
	ld bc, $0000
	ld a, ($DC3C)
	dec a
	jr z, +
	ld bc, $0140
+:
	ld a, ($D6CE)
	or a
	jr z, +++
	ld a, ($D6AF)
	sra a
	sra a
	and $01
	jp nz, +++
	ld a, ($D6CE)
	cp $80
	jr z, +
	ld hl, $7C8C
	jp ++

+:
	ld hl, $7C8E
++:
	add hl, bc
	call _LABEL_B35A_
	ld bc, $0003
	ld hl, $A019
	jp _LABEL_A5B0_

+++:
	ld hl, $7C8C
	add hl, bc
	call _LABEL_B35A_
	ld bc, $0004
	ld hl, $AAAE
	jp _LABEL_A5B0_

; Data from A019 to A01B (3 bytes)
.db $0F $11 $1A

_LABEL_A01C_:
	ld c, a
	ld b, $00
	ld hl, $A02E
	add hl, bc
	ld a, (hl)
	ld c, a
	and $C0
	ld ($D6CE), a
	ld a, c
	and $3F
	ret

; Data from A02E to A038 (11 bytes)
.db $FF $01 $81 $03 $43 $08 $07 $05 $02 $04 $06

_LABEL_A039_:
	ld de, $0000
	ld a, ($DC3C)
	dec a
	jr z, +
	ld e, $40
+:
	ld a, ($D6AF)
	cp $00
	jr z, _LABEL_A0A3_
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	and $01
	jp nz, +++
	ld hl, $7A90
	add hl, de
	call _LABEL_B35A_
	ld bc, $0008
	ld a, ($DBCF)
	or a
	jr z, +
	ld hl, $A0AC
	jp ++

+:
	ld hl, $A0A4
++:
	call _LABEL_A5B0_
	ld hl, $7AA2
	add hl, de
	call _LABEL_B35A_
	ld bc, $0008
	ld a, ($DBD0)
	or a
	jr z, +
	ld hl, $A0AC
	jp ++

+:
	ld hl, $A0A4
++:
	jp _LABEL_A5B0_

+++:
	ld hl, $7A90
	add hl, de
	call _LABEL_B35A_
	ld bc, $0019
	ld hl, $AAAE
	jp _LABEL_A5B0_

_LABEL_A0A3_:
	ret

; Data from A0A4 to A0B3 (16 bytes)
.db $16 $08 $0D $0D $04 $11 $B4 $B4 $0E $0B $1A $12 $04 $11 $B4 $0E

_LABEL_A0B4_:
	ld hl, $7998
	call _LABEL_B35A_
	ld bc, $0007
	ld hl, $A0DB
	call _LABEL_A5B0_
	ld hl, $79CE
	call _LABEL_B35A_
	ld a, ($DC34)
	dec a
	jr z, +
	ld bc, $000E
	ld hl, $A0E2
	jp _LABEL_A5B0_

+:
	jp _LABEL_A302_

; Data from A0DB to A0EF (21 bytes)
.db $11 $04 $12 $14 $0B $13 $12 $0E $0E $0E $12 $08 $0D $06 $0B $04
.db $0E $11 $00 $02 $04

_LABEL_A0F0_:
	ld bc, $0000
	ld a, ($DC3C)
	dec a
	jr z, +
	ld bc, $0140
+:
	ld hl, $7A94
	add hl, bc
	ld bc, $000C
	ld de, $0009
--:
	call _LABEL_B35A_
-:
	ld a, $0E
	out ($BE), a
	xor a
	out ($BE), a
	dec bc
	ld a, c
	or a
	jr nz, -
	ld bc, $000C
	dec de
	ld a, e
	or a
	jr z, +
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	jp --

+:
	ret

_LABEL_A129_:
	ld de, ($D6A8)
	call _LABEL_B361_
	exx
	ld hl, ($D6A6)
	ld e, $50
	call $D985	; Possibly invalid
	ld ($D6A6), hl
	exx
	ld hl, $0140
	add hl, de
	ld ($D6A8), hl
	ld a, ($D693)
	sub $01
	ld ($D693), a
	jp _LABEL_80FC_

_LABEL_A14F_:
	ld a, ($DC3C)
	xor $01
	rrca
	ld e, a
	ld d, $00
	ld a, ($DBD4)
	srl a
	srl a
	srl a
	ld c, a
	ld b, $00
	call _LABEL_A1EC_
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $79CE
	add hl, de
	jp ++

+:
	ld hl, $7C8E
	add hl, de
++:
	call _LABEL_B35A_
	ld hl, $DC21
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	call _LABEL_A1CA_
	jp ++

+:
	call _LABEL_A1D3_
++:
	ld a, ($DBD5)
	srl a
	srl a
	srl a
	ld c, a
	ld b, $00
	call _LABEL_A225_
	ld a, ($DC3C)
	xor $01
	rrca
	ld e, a
	ld d, $00
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $79E2
	add hl, de
	jp ++

+:
	ld hl, $7CA2
	add hl, de
++:
	call _LABEL_B35A_
	ld hl, $DC21
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	call _LABEL_A1CA_
	ret

+:
	call _LABEL_A1D3_
	ret

_LABEL_A1CA_:
	ld bc, $0008
	ld hl, $A1DC
	jp _LABEL_A5B0_

_LABEL_A1D3_:
	ld bc, $0008
	ld hl, $A1E4
	jp _LABEL_A5B0_

; Data from A1DC to A1EB (16 bytes)
.db $07 $00 $0D $03 $08 $02 $00 $0F $1A $11 $03 $08 $0D $00 $11 $18

_LABEL_A1EC_:
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $788E
	add hl, de
	jp ++

+:
	ld hl, $7B0E
	add hl, de
++:
	call _LABEL_B35A_
	ld hl, $DC0B
	add hl, bc
	call _LABEL_A272_
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $790E
	add hl, de
	jp ++

+:
	ld hl, $7B8E
	add hl, de
++:
	call _LABEL_B35A_
	ld hl, $DC16
	add hl, bc
	call _LABEL_A272_
	ret

_LABEL_A225_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, e
	add a, $04
	ld e, a
+:
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $78B0
	add hl, de
	jp ++

+:
	ld hl, $7B30
	add hl, de
++:
	call _LABEL_B35A_
	ld hl, $DC0B
	add hl, bc
	call _LABEL_A272_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, e
	add a, $02
	ld e, a
+:
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $7930
	add hl, de
	jp ++

+:
	ld hl, $7BB0
	add hl, de
++:
	call _LABEL_B35A_
	ld hl, $DC16
	add hl, bc
	call _LABEL_A272_
	ret

_LABEL_A272_:
	ld a, (hl)
	and $F0
	srl a
	srl a
	srl a
	srl a
	jr nz, +
	ld a, $B5
	jp ++

+:
	add a, $1A
++:
	out ($BE), a
	rlc a
	and $01
	out ($BE), a
	ld a, (hl)
	and $0F
	add a, $1A
	out ($BE), a
	ret

_LABEL_A296_:
	ld a, $0A
	ld ($D741), a
	ld hl, $B151
	call $D7BD	; Possibly invalid
	ld de, $0138
	ld hl, $5760
	jp _LABEL_AFA5_

_LABEL_A2AA_:
	ld a, ($DC3B)
	dec a
	jr z, +++
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7B0E
	jr ++

+:
	ld hl, $7A4E
++:
	call _LABEL_B35A_
	jp ++++

+++:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $79CE
	jr ++

+:
	ld hl, $798E
++:
	call _LABEL_B35A_
	jp ++++

++++:
	ld a, ($D6AF)
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	sra a
	and $01
	jp nz, ++
	ld a, ($DC34)
	dec a
	jr z, _LABEL_A302_
	ld a, ($DC3B)
	dec a
	jr z, +
	ld hl, $A325
	ld bc, $0010
	jp _LABEL_A5B0_

_LABEL_A302_:
	ld hl, $A335
	ld bc, $0010
	call _LABEL_A5B0_
	ld a, ($DC35)
	add a, $1A
	out ($BE), a
	ret

+:
	ld hl, $A345
	ld bc, $0010
	jp _LABEL_A5B0_

++:
	ld bc, $0011
	ld hl, $AAAE
	jp _LABEL_A5B0_

; Data from A325 to A354 (48 bytes)
.db $0E $0E $12 $04 $0B $04 $02 $13 $0E $15 $04 $07 $08 $02 $0B $04
.db $13 $1A $14 $11 $0D $00 $0C $04 $0D $13 $0E $11 $00 $02 $04 $0E
.db $0E $0E $12 $04 $0B $04 $02 $13 $0E $00 $0E $13 $11 $00 $02 $0A

_LABEL_A355_:
	ld a, ($DBD4)
	srl a
	srl a
	srl a
	ld de, $0000
	ld a, ($DC3C)
	dec a
	jr z, +
	ld e, $7C
+:
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $788C
	add hl, de
	jp ++

+:
	ld hl, $7B0C
	add hl, de
++:
	call _LABEL_B35A_
	call _LABEL_A3EA_
	ld de, $0000
	ld a, ($DC3C)
	dec a
	jr z, +
	ld e, $7A
+:
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $790C
	add hl, de
	jp ++

+:
	ld hl, $7B8C
	add hl, de
++:
	call _LABEL_B35A_
	call _LABEL_A402_
	ld de, $0000
	ld a, ($DC3C)
	dec a
	jr z, +
	ld e, $80
+:
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $78AE
	add hl, de
	jp ++

+:
	ld hl, $7B2E
	add hl, de
++:
	call _LABEL_B35A_
	call _LABEL_A3EA_
	ld de, $0000
	ld a, ($DC3C)
	dec a
	jr z, +
	ld e, $80
+:
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $792E
	add hl, de
	jp ++

+:
	ld hl, $7BAE
	add hl, de
++:
	call _LABEL_B35A_
	jp _LABEL_A402_

_LABEL_A3EA_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld bc, $0005
	ld hl, $A41E
	jp _LABEL_A5B0_

+:
	ld bc, $0002
	ld hl, $A41A
	jp _LABEL_A5B0_

_LABEL_A402_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld bc, $0005
	ld hl, $A423
	jp _LABEL_A5B0_

+:
	ld bc, $0002
	ld hl, $A41C
	jp _LABEL_A5B0_

; Data from A41A to A4B6 (157 bytes)
.db $16 $B5 $0B $B5 $16 $1A $0D $B5 $0E $0B $1A $12 $13 $B5 $3A $3C
.db $DC $3D $28 $05 $11 $08 $7D $18 $03 $11 $0C $7C $CD $61 $B3 $01
.db $08 $00 $21 $9D $A4 $CD $B0 $A5 $21 $46 $00 $19 $CD $5A $B3 $01
.db $02 $00 $21 $B5 $A4 $CD $B0 $A5 $21 $80 $00 $19 $CD $5A $B3 $01
.db $08 $00 $21 $A5 $A4 $CD $B0 $A5 $3A $3C $DC $3D $28 $05 $11 $28
.db $7D $18 $03 $11 $24 $7C $CD $61 $B3 $01 $08 $00 $21 $9D $A4 $CD
.db $B0 $A5 $21 $46 $00 $19 $CD $5A $B3 $01 $02 $00 $21 $B5 $A4 $CD
.db $B0 $A5 $21 $80 $00 $19 $CD $5A $B3 $01 $08 $00 $21 $AD $A4 $CD
.db $B0 $A5 $C9 $0F $0B $00 $18 $04 $11 $0E $1B $0F $0B $00 $18 $04
.db $11 $0E $1C $02 $1A $0C $0F $14 $13 $04 $11 $15 $12

_LABEL_A4B7_:
	ld hl, $7A54
	call _LABEL_A500_
	ld a, ($D699)
	cp $13
	jr z, +
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7B06
	call _LABEL_B35A_
	ld bc, $001A
	ld hl, $A4E6
	call _LABEL_A5B0_
+:
	ret

; Data from A4DA to A4FF (38 bytes)
.db $12 $04 $0B $04 $02 $13 $0E $0E $06 $00 $0C $04 $1A $0D $04 $0E
.db $0F $0B $00 $18 $04 $11 $0E $0E $0E $0E $0E $0E $13 $16 $1A $0E
.db $0F $0B $00 $18 $04 $11

_LABEL_A500_:
	call _LABEL_B35A_
	ld bc, $000C
	ld hl, $A4DA
	jp _LABEL_A5B0_

_LABEL_A50C_:
	ld hl, $7990
	call _LABEL_B35A_
	ld bc, $000F
	ld hl, $A521
	call _LABEL_A5B0_
	ld hl, $7A14
	jp _LABEL_A500_

; Data from A521 to A52F (15 bytes)
.db $1A $0D $04 $0E $0F $0B $00 $18 $04 $11 $0E $06 $00 $0C $04

_LABEL_A530_:
	ld hl, $79D4
	call _LABEL_B35A_
	ld bc, $000C
	ld hl, $A574
	call _LABEL_A5B0_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7D86
	call _LABEL_B35A_
	ld bc, $001A
	ld hl, $A580
	call _LABEL_A5B0_
	ret

+:
	ld hl, $7C4C
	call _LABEL_B35A_
	ld bc, $0012
	ld hl, $A59A
	call _LABEL_A5B0_
	ld hl, $7CAC
	call _LABEL_B35A_
	ld bc, $0004
	ld hl, $A5AC
	call _LABEL_A5B0_
	ret

; Data from A574 to A5AF (60 bytes)
.db $02 $07 $1A $1A $12 $04 $0E $06 $00 $0C $04 $B4 $13 $1A $14 $11
.db $0D $00 $0C $04 $0D $13 $0E $0E $0E $0E $0E $12 $08 $0D $06 $0B
.db $04 $0E $11 $00 $02 $04 $13 $1A $14 $11 $0D $00 $0C $04 $0D $13
.db $0E $0E $12 $08 $0D $06 $0B $04 $11 $00 $02 $04

_LABEL_A5B0_:
	ld a, (hl)
	out ($BE), a
	rlc a
	and $01
	out ($BE), a
	inc hl
	dec c
	jr nz, _LABEL_A5B0_
	ret

_LABEL_A5BE_:
	ld a, $30
	ld ($D6AF), a
	ld a, $01
	ld ($D6C6), a
	ret

_LABEL_A5C9_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld de, $7986
	ld bc, $0006
	ld hl, $A664
	jr ++

+:
	ld de, $798C
	ld bc, $0003
	ld hl, $A66A
++:
	call _LABEL_B361_
	call _LABEL_A5B0_
	ld hl, $7A0C
	call _LABEL_B35A_
	ld bc, $0003
	ld hl, $A66D
	call _LABEL_A5B0_
	ret

_LABEL_A5F9_:
	ld hl, $7986
	call _LABEL_B35A_
	ld bc, $0006
	ld hl, $AAAE
	call _LABEL_A5B0_
	ld hl, $7A0C
	call _LABEL_B35A_
	ld bc, $0003
	ld hl, $AAAE
	call _LABEL_A5B0_
	ret

_LABEL_A618_:
	ld de, $79AE
	ld a, ($DC3C)
	dec a
	jr z, +
	ld bc, $0006
	ld hl, $A664
	jr ++

+:
	ld bc, $0003
	ld hl, $A66A
++:
	call _LABEL_B361_
	call _LABEL_A5B0_
	ld hl, $7A2E
	call _LABEL_B35A_
	ld bc, $0003
	ld hl, $A670
	call _LABEL_A5B0_
	ret

_LABEL_A645_:
	ld hl, $79AE
	call _LABEL_B35A_
	ld bc, $0006
	ld hl, $AAAE
	call _LABEL_A5B0_
	ld hl, $7A2E
	call _LABEL_B35A_
	ld bc, $0003
	ld hl, $AAAE
	call _LABEL_A5B0_
	ret

; Data from A664 to A672 (15 bytes)
.db $0F $0B $00 $18 $04 $11 $0F $0B $11 $1A $0D $04 $13 $16 $1A

_LABEL_A673_:
	ld a, $00
	out ($BF), a
	ld a, $86
	out ($BF), a
	ret

_LABEL_A67C_:
	ld a, $00
	ld ($D6AD), a
	ld a, $04
	ld ($D6AE), a
	ld a, $03
	ld ($D6A2), a
	ld ($DBFB), a
	ld bc, $0003
	ret

_LABEL_A692_:
	ld a, ($D6AF)
	cp $00
	jr z, ++
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	and $01
	jp nz, +++
	ld hl, $7C10
	call _LABEL_B35A_
	ld a, ($DBD3)
	and $F8
	ld c, a
	ld b, $00
	ld hl, $A6EF
	add hl, bc
	ld a, (hl)
	inc hl
	or a
	jr z, +
	ld de, $7C12
	call _LABEL_B361_
+:
	ld bc, $0007
	call _LABEL_A5B0_
	ld bc, $0008
	ld hl, $A747
	call _LABEL_A5B0_
++:
	ret

+++:
	ld hl, $7C0E
	call _LABEL_B35A_
	ld bc, $0008
	ld hl, $AAAE
	call _LABEL_A5B0_
	ld bc, $0008
	ld hl, $AAAE
	call _LABEL_A5B0_
	ret

; Data from A6EF to A74E (96 bytes)
.db $00 $0E $0E $02 $07 $04 $0D $0E $01 $12 $0F $08 $03 $04 $11 $0E
.db $01 $16 $00 $0B $13 $04 $11 $0E $01 $03 $16 $00 $18 $0D $04 $0E
.db $00 $0E $0E $09 $1A $04 $0B $0E $01 $01 $1A $0D $0D $08 $04 $0E
.db $00 $0E $0E $0C $08 $0A $04 $0E $01 $04 $0C $08 $0B $08 $1A $0E
.db $01 $09 $04 $13 $07 $11 $1A $0E $00 $0E $0E $00 $0D $0D $04 $0E
.db $01 $02 $07 $04 $11 $11 $18 $0E $08 $12 $0E $1A $14 $13 $B4 $0E

_LABEL_A74F_:
	ld a, ($DBD8)
	ld c, a
	ld b, $00
	ld hl, $A75E
	add hl, bc
	ld a, (hl)
	ld ($D6C4), a
	ret

; Data from A75E to A777 (26 bytes)
.db $FF $FF $FF $00 $FF $FF $01 $FF $FF $02 $FF $FF $FF $00 $FF $FF
.db $01 $FF $FF $FF $02 $FF $FF $FF $00 $FF

_LABEL_A778_:
	ld bc, $0018
	ld hl, $DBD9
-:
	xor a
	ld (hl), a
	inc hl
	dec bc
	ld a, c
	or a
	jr nz, -
	ret

_LABEL_A787_:
	ld a, ($DC0A)
	cp $03
	jr nz, +
	ld a, $02
	ld ($DBE8), a
	ld ($DBEC), a
	ld ($DBF0), a
	ret

+:
	ld a, ($DBD8)
	sub $01
	sla a
	ld c, a
	ld b, $00
	ld hl, $A7BB
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, $02
	ld (de), a
	ld ($DBF9), de
	ret

_LABEL_A7B3_:
	ld de, ($DBF9)
	ld a, $01
	ld (de), a
	ret

; Data from A7BB to A7EC (50 bytes)
.db $E7 $DB $D9 $DB $E5 $DB $DC $DB $EB $DB $DA $DB $E9 $DB $E6 $DB
.db $E0 $DB $E7 $DB $EF $DB $EA $DB $DB $DB $DE $DB $DD $DB $E4 $DB
.db $EB $DB $ED $DB $DF $DB $E1 $DB $EE $DB $EF $DB $E2 $DB $E3 $DB
.db $E1 $DB

_LABEL_A7ED_:
	ld a, ($D6AF)
	cp $00
	jr z, +++
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	and $01
	jr nz, ++++
	call _LABEL_A859_
	ld a, ($DC3A)
	dec a
	jr nz, +
	ld a, ($DBCF)
	dec a
	jr nz, +
	ld c, $08
	jp ++

+:
	ld a, ($DBCF)
	and $02
	sla a
	sla a
	ld c, a
++:
	ld b, $00
	ld hl, $A84A
	add hl, bc
	ld bc, $0007
	call _LABEL_A5B0_
+++:
	ret

++++:
	call _LABEL_A859_
	ld hl, $AAAE
	ld bc, $0007
	jp _LABEL_A5B0_

; Data from A83A to A858 (31 bytes)
.db $90 $7A $A2 $7A $90 $7C $A4 $7C $82 $7A $B0 $7A $04 $7D $30 $7D
.db $10 $14 $00 $0B $08 $05 $18 $FF $05 $00 $08 $0B $04 $03 $0E

_LABEL_A859_:
	ld a, ($DBCF)
	sla a
	ld c, a
	ld b, $00
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $A842
	jr ++

+:
	ld hl, $A83A
++:
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	call _LABEL_B361_
	ret

_LABEL_A877_:
	ld a, $04
	ld ($D741), a
	ld hl, $BC42
	call $D7BD	; Possibly invalid
	ld de, $00C0
	ld hl, $6000
	call _LABEL_AFA5_
	call _LABEL_BA42_
	ld a, ($DC3C)
	xor $01
	rrca
	ld c, a
	ld b, $00
	xor a
	ld ($D68A), a
	ld hl, $790C
	add hl, bc
	ld a, $03
	ld ($D69B), a
	ld a, $02
	ld ($D69A), a
	ld a, $01
	ld ($D69C), a
	call _LABEL_BCCF_
	ld a, $06
	ld ($D68A), a
	ld hl, $7930
	add hl, bc
	ld a, $03
	ld ($D69B), a
	call _LABEL_BCCF_
	ld a, ($DC3C)
	xor $01
	ld b, a
	ld c, $00
	ld a, $0C
	ld ($D68A), a
	ld hl, $7B0C
	add hl, bc
	ld a, $03
	ld ($D69B), a
	call _LABEL_BCCF_
	ld a, $12
	ld ($D68A), a
	ld hl, $7B30
	add hl, bc
	ld a, $03
	ld ($D69B), a
	call _LABEL_BCCF_
	ret

_LABEL_A8ED_:
	ld c, $00
	jp +

_LABEL_A8F2_:
	ld c, $01
	jp +

_LABEL_A8F7_:
	ld c, $02
	jp +

_LABEL_A8FC_:
	ld c, $03
	jp +

+:
	ld a, ($DBCF)
	cp c
	jp z, +
	ld a, ($DBD0)
	cp c
	jp z, +++
	ld a, ($DBD1)
	cp c
	jp z, _LABEL_A95D_
	ld a, ($DBD2)
	cp c
	jp z, _LABEL_A97B_
	ret

+:
	ld a, $80
	ld ($D6AF), a
	ld b, $00
	call _LABEL_A9C6_
	call _LABEL_B375_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $A9AE
	jr ++

+:
	ld hl, $A9A6
++:
	ld a, ($DBCF)
	jp _LABEL_A996_

+++:
	ld b, $01
	call _LABEL_A9C6_
	ld a, $42
	call _LABEL_B377_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $A9AE
	jr ++

+:
	ld hl, $A9A6
++:
	ld a, ($DBD0)
	jp _LABEL_A996_

_LABEL_A95D_:
	ld b, $02
	call _LABEL_A9C6_
	ld a, $60
	call _LABEL_B377_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $A9AE
	jr ++

+:
	ld hl, $A9A6
++:
	ld a, ($DBD1)
	jp _LABEL_A996_

_LABEL_A97B_:
	ld b, $03
	call _LABEL_A9C6_
	ld a, $7E
	call _LABEL_B377_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $A9AE
	jr ++

+:
	ld hl, $A9A6
++:
	ld a, ($DBD2)
_LABEL_A996_:
	sla a
	ld c, a
	ld b, $00
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	call _LABEL_BCCF_
	jp _LABEL_8F10_

; Data from A9A6 to A9C5 (32 bytes)
.db $12 $79 $24 $79 $12 $7B $24 $7B $92 $79 $A4 $79 $12 $7C $24 $7C
.db $0E $7A $30 $7A $0E $7C $30 $7C $16 $7B $28 $7B $96 $7D $A8 $7D

_LABEL_A9C6_:
	ld a, c
	sla a
	ld e, a
	ld d, $00
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $A9BE
	jr ++

+:
	ld hl, $A9B6
++:
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	call _LABEL_B361_
	ld a, b
	add a, $18
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_A9EB_:
	ld a, ($D6AF)
	cp $00
	jr z, _LABEL_AA5D_
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	and $01
	jp nz, _LABEL_AA8B_
_LABEL_AA02_:
	ld a, ($DBD8)
	sub $01
	sla a
	ld c, a
	ld b, $00
	ld hl, $AB06
	add hl, bc
	ld a, (hl)
	ld ($DBF6), a
	inc hl
	ld a, (hl)
	ld ($DBF7), a
	ld hl, $AACE
	add hl, bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, b
	ld l, c
	ld a, $03
	ld ($D741), a
	ld a, ($DBD8)
	cp $19
	jr z, +++
	ld a, ($DC3C)
	dec a
	jr z, +
	ld de, $7B16
	call _LABEL_B361_
	ld bc, $0014
	ld de, $7B04
	jr ++

+:
	ld de, $7A4C
	call _LABEL_B361_
	ld bc, $0014
	ld de, $7A18
++:
	call $DAAA	; Possibly invalid
	call _LABEL_B361_
	ld bc, $0008
	ld hl, $DBF1
	call $DAAA	; Possibly invalid
_LABEL_AA5D_:
	ret

+++:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7B00
	ld bc, $001E
	jr ++

+:
	ld hl, $7A52
	call _LABEL_B35A_
	ld bc, $000F
	ld hl, $BFB0
	call $DAAA	; Possibly invalid
	ld hl, $7A12
	ld bc, $000F
++:
	call _LABEL_B35A_
	ld hl, $BFA1
	call $DAAA	; Possibly invalid
	ret

_LABEL_AA8B_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7AC0
	jr ++

+:
	ld hl, $7A00
++:
	call _LABEL_B35A_
	ld bc, $0020
	ld hl, $AAAE
	call _LABEL_A5B0_
	ld bc, $0020
	ld hl, $AAAE
	jp _LABEL_A5B0_

; Data from AAAE to AB5A (173 bytes)
.db $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E
.db $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E
.db $C1 $BD $D5 $BD $E9 $BD $FD $BD $11 $BE $25 $BE $39 $BE $4D $BE
.db $61 $BE $75 $BE $89 $BE $9D $BE $B1 $BE $C5 $BE $D9 $BE $ED $BE
.db $01 $BF $15 $BF $29 $BF $3D $BF $51 $BF $65 $BF $79 $BF $8D $BF
.db $BF $BF $BF $BF $BF $BF $BF $BF $0E $1B $0E $1C $0E $1D $0E $1E
.db $0E $1F $0E $20 $0E $21 $0E $22 $0E $23 $00 $00 $1B $1A $1B $1B
.db $1B $1C $1B $1D $1B $1E $1B $1F $00 $00 $1B $20 $1B $21 $1B $22
.db $1B $23 $00 $00 $1C $1A $1C $1B $1C $1C $1C $1D $1C $1E $1C $1F
.db $04 $01 $05 $07 $04 $03 $05 $02 $07 $06 $04 $02 $08 $03 $01 $07
.db $06 $05 $08 $01 $02 $06 $03 $08 $01 $09 $09 $09 $02

_LABEL_AB5B_:
	ld a, ($DBD8)
	sub $01
	ld c, a
	ld b, $00
	ld hl, $AB3E
	add hl, bc
	ld a, (hl)
_LABEL_AB68_:
	ld ($D691), a
	sla a
	ld de, $9254
	add a, e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, (de)
	ld ($D7B5), a
	inc de
	ld a, (de)
	ld ($D7B6), a
	ld hl, $C000
	ld ($D6A6), hl
	ret

_LABEL_AB86_:
	ld a, ($D691)
	call _LABEL_B478_
	ld hl, ($D7B5)
	call $D7BD	; Possibly invalid
	ld hl, $6000
	ld de, $0280
	jp _LABEL_AFA5_

_LABEL_AB9B_:
	ld a, ($D691)
	call _LABEL_B478_
	ld hl, ($D7B5)
	call $D7BD	; Possibly invalid
	ld hl, $6C00
	ld de, $0280
	jp _LABEL_AFA5_

_LABEL_ABB0_:
	jp _LABEL_ABB3_

_LABEL_ABB3_:
	xor a
	ld ($D692), a
	ld ($D693), a
	ld a, $01
	ld ($D694), a
	xor a
	ld ($D690), a
	ld a, ($D699)
	cp $10
	jr nz, +
	ld a, $60
	ld ($D690), a
+:
	call _LABEL_ABD3_
	ret

_LABEL_ABD3_:
	ld a, ($D690)
	ld ($D68A), a
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7BD6
	jr ++

+:
	ld hl, $7A96
++:
	xor a
	ld ($D68B), a
--:
	call _LABEL_B35A_
	ld de, $000A
-:
	ld a, ($D68A)
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld a, ($D68A)
	add a, $01
	ld ($D68A), a
	dec de
	ld a, d
	or e
	jr nz, -
	ld a, ($D68B)
	cp $07
	jr z, +
	add a, $01
	ld ($D68B), a
	ld de, $0040
	add hl, de
	jp --

+:
	call _LABEL_9276_
	ret

_LABEL_AC1E_:
	ld a, ($DC3F)
	dec a
	jr z, +++
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DBD4)
	ld ($D6BB), a
	call _LABEL_9F40_
	call _LABEL_B375_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7902
	jr ++

+:
	ld hl, $794C
	call _LABEL_B2B3_
++:
	call _LABEL_BCCF_
+++:
	ld hl, $4840
	call _LABEL_B35A_
	ld a, ($DC3F)
	or a
	jr z, +
	ld a, ($DBD4)
	call _LABEL_9F40_
	ld de, $0004
	jp ++

+:
	ld a, ($DBD5)
	call _LABEL_9F40_
	ld de, $0000
++:
	ld a, $42
	call _LABEL_B377_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7912
	jr ++

+:
	ld hl, $7956
	call _LABEL_B2B3_
++:
	or a
	sbc hl, de
	call _LABEL_BCCF_
	ld hl, $4C00
	call _LABEL_B35A_
	ld a, ($DC3F)
	or a
	jr z, +
	ld a, ($DBD5)
	call _LABEL_9F40_
	ld de, $0004
	jp ++

+:
	ld a, ($DBD6)
	call _LABEL_9F40_
	ld de, $0000
++:
	ld a, $60
	call _LABEL_B377_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7922
	jr ++

+:
	ld hl, $7960
	call _LABEL_B2B3_
++:
	add hl, de
	call _LABEL_BCCF_
	ld a, ($DC3F)
	dec a
	jr z, +++
	ld hl, $4FC0
	call _LABEL_B35A_
	ld a, ($DBD7)
	call _LABEL_9F40_
	ld a, $7E
	call _LABEL_B377_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7932
	jr ++

+:
	ld hl, $796A
	call _LABEL_B2B3_
++:
	call _LABEL_BCCF_
+++:
	ret

_LABEL_ACEE_:
	ld a, ($DC3F)
	dec a
	jr z, +
	ld hl, $7A86
	call _LABEL_B35A_
	ld hl, $7A96
	ld bc, $7AA6
	ld de, $7AB6
	jr ++

+:
	ld hl, $7A92
	call _LABEL_B35A_
	ld de, $7AAA
	jr ++

++:
	ld a, $50
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld a, ($DC3F)
	dec a
	jr z, +
	call _LABEL_B35A_
	ld a, $51
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld h, b
	ld l, c
	call _LABEL_B35A_
	ld a, $52
	out ($BE), a
	ld a, $01
	out ($BE), a
+:
	call _LABEL_B361_
	ld a, $53
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_AD42_:
	ld a, $0E
	ld ($D741), a
	ld hl, $B37F
	call $D7BD	; Possibly invalid
	ld hl, $6000
	ld de, $03D8
	call _LABEL_AFA5_
	ld a, $0E
	ld ($D741), a
	ld hl, $B32F
	call $D7BD	; Possibly invalid
	ld a, ($DC3C)
	dec a
	jr z, +
	ld de, $790A
	jr ++

+:
	ld de, $780A
++:
	call _LABEL_B361_
	ld hl, $C000
	ld a, $16
	ld ($D69D), a
	ld a, $14
	ld ($D69E), a
	ld a, $01
	ld ($D69C), a
	xor a
	ld ($D69F), a
	call $D997	; Possibly invalid
	ld bc, $0000
-:
	ld hl, $DBD9
	add hl, bc
	ld a, (hl)
	dec a
	jr z, _LABEL_AD9C_
	dec a
	jr z, +
	call _LABEL_AE46_
_LABEL_AD9C_:
	inc bc
	ld a, c
	cp $18
	jr nz, -
	ret

+:
	ld a, c
	ld ($D6C2), a
	jp _LABEL_AD9C_

; Data from ADAA to AE45 (156 bytes)
.db $17 $C0 $1C $C0 $21 $C0 $26 $C0 $59 $C0 $5E $C0 $63 $C0 $68 $C0
.db $9B $C0 $A0 $C0 $A5 $C0 $AA $C0 $DD $C0 $E2 $C0 $E7 $C0 $EC $C0
.db $1F $C1 $24 $C1 $29 $C1 $2E $C1 $61 $C1 $66 $C1 $6B $C1 $70 $C1
.db $4C $78 $56 $78 $60 $78 $6A $78 $0C $79 $16 $79 $20 $79 $2A $79
.db $CC $79 $D6 $79 $E0 $79 $EA $79 $8C $7A $96 $7A $A0 $7A $AA $7A
.db $4C $7B $56 $7B $60 $7B $6A $7B $0C $7C $16 $7C $20 $7C $2A $7C
.db $04 $05 $05 $05 $06 $4C $4D $4D $4D $19 $4C $4D $4D $4D $19 $4C
.db $4D $4D $4D $19 $4C $4D $4D $4D $19 $4C $4D $4D $4D $19 $4C $4D
.db $4D $4D $19 $4C $4D $4D $4D $19 $76 $77 $77 $77 $57 $04 $05 $05
.db $05 $06 $4C $4D $4D $4D $19 $76 $77 $77 $77 $57

_LABEL_AE46_:
	ld ($D6BC), bc
	ld hl, $AE37
	ld ($D6A6), hl
_LABEL_AE50_:
	ld a, $02
	ld ($D741), a
	ld ($D6BC), bc
	ld a, c
	sla a
	ld e, a
	ld d, $00
	ld hl, $ADDA
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld h, d
	ld l, e
	ld a, ($DC3C)
	xor $01
	ld d, a
	ld e, $00
	add hl, de
	call _LABEL_B35A_
	ld d, h
	ld e, l
	ld hl, ($D6A6)
	ld a, $05
	ld ($D69D), a
	ld a, $03
	ld ($D69E), a
	ld a, $01
	ld ($D69C), a
	xor a
	ld ($D69F), a
	call $D997	; Possibly invalid
	ld bc, ($D6BC)
	ret

_LABEL_AE94_:
	ld a, $0D
	ld ($D741), a
	ld a, c
	sla a
	ld e, a
	ld d, $00
	ld hl, $ADDA
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld a, ($DC3C)
	xor $01
	ld d, a
	ld e, $00
	add hl, de
	call _LABEL_B35A_
	ex de, hl
	ld a, c
	sla a
	ld c, a
	ld b, $00
	ld hl, $ADAA
	add hl, bc
	ld a, (hl)
	ld c, a
	inc hl
	ld a, (hl)
	ld h, a
	ld a, c
	ld l, a
	ld a, $03
	ld ($D69E), a
	jp $DABD	; Possibly invalid

_LABEL_AECD_:
	ld hl, ($D6A8)
	ld bc, $0320
	add hl, bc
	call _LABEL_B35A_
	ld hl, $9D37
	ld a, ($D6BB)
	sra a
	sra a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld ($D6A5), a
	ld ($D741), a
	ld d, $00
	ld hl, $9C7F
	ld a, ($D6BB)
	sla a
	ld e, a
	add hl, de
	ld a, (hl)
	ld c, a
	inc hl
	ld a, (hl)
	ld h, a
	ld l, c
	ld bc, $0258
	add hl, bc
	ld e, $28
	call $DAEF	; Possibly invalid
	ld a, $00
	ld ($D6A4), a
	ld ($D6B0), a
	ret

_LABEL_AF10_:
	ld a, ($DC3C)
	or a
	ret z
	in a, ($05)
	and $04
	jr nz, +++
	ld a, ($DC41)
	or a
	jr nz, _LABEL_AF6F_
	ld a, ($DC48)
	cp $CA
	jr z, +
	cp $55
	jr z, ++
	ld a, $CA
	out ($03), a
	ret

+:
	ld a, $01
	ld ($DC42), a
	ld ($DC41), a
	ld a, $55
	out ($03), a
	jr _LABEL_AF5D_

++:
	xor a
	ld ($DC42), a
	ld a, $01
	ld ($DC41), a
	ld c, $01
	call _LABEL_B1EC_
	jr _LABEL_AF5D_

; Data from AF4F to AF4F (1 bytes)
.db $C9

+++:
	call _LABEL_AF92_
	xor a
	ld ($DC41), a
	ld a, $00
	ld ($DC42), a
	ret

_LABEL_AF5D_:
	ld a, $3F
	ld ($DC47), a
	ld ($DC48), a
	ld ($D680), a
	ld ($D681), a
	ld ($D687), a
	ret

_LABEL_AF6F_:
	ld a, ($D7BA)
	inc a
	and $0F
	ld ($D7BA), a
	and $08
	jr z, _LABEL_AF92_
	ld hl, $7A5A
	call _LABEL_B35A_
	ld c, $05
	ld hl, $AFA0
	call _LABEL_A5B0_
	ld a, ($DC42)
	add a, $1B
	out ($BE), a
	ret

_LABEL_AF92_:
	ld hl, $7A5A
	call _LABEL_B35A_
	ld c, $06
	ld hl, $AAAE
	jp _LABEL_A5B0_

; Data from AFA0 to AFA4 (5 bytes)
.db $0B $08 $0D $0A $0E

_LABEL_AFA5_:
	call _LABEL_B35A_
_LABEL_AFA8_:
	ld hl, $C000
	jp $D971	; Possibly invalid

_LABEL_AFAE_:
	ld hl, $AFBC
	ld de, $D640
	ld bc, $0011
	ldir
	jp $D640	; Possibly invalid

; Data from AFBC to AFCC (17 bytes)
.db $3E $0E $32 $41 $D7 $32 $00 $80 $CD $71 $B9 $3E $02 $32 $00 $80
.db $C9

_LABEL_AFCD_:
	call _LABEL_BB85_
	ld a, $13
	ld ($D699), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_B337_
	call _LABEL_9400_
	call _LABEL_BAFF_
	call _LABEL_959C_
	ld a, $B2
	ld ($D6C8), a
	call _LABEL_9448_
	call _LABEL_94AD_
	call _LABEL_B305_
	ld c, $07
	call _LABEL_B1EC_
	xor a
	ld ($D6C7), a
	call _LABEL_BB95_
	call _LABEL_BC0C_
	call _LABEL_B034_
	call _LABEL_A50C_
	call _LABEL_9317_
	xor a
	ld ($D6A0), a
	ld ($D6AB), a
	ld ($D6AC), a
	call _LABEL_A673_
	call _LABEL_BB75_
	ret

_LABEL_B01D_:
	ld a, ($DC3C)
	or a
	ret z
	in a, ($00)
	add a, a
	ret c
	ld a, $0F
	ld ($D741), a
	ld hl, $B753
	call $D7BD	; Possibly invalid
	jp $C000	; Possibly invalid

_LABEL_B034_:
	ld a, $08
	ld ($D741), a
	ld hl, $B656
	call $D7BD	; Possibly invalid
	ld hl, $7000
	ld de, $0120
	call _LABEL_AFA5_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7B6C
	jr ++

+:
	ld hl, $7AA8
++:
	ld a, $80
	ld ($D68A), a
	ld a, $06
	ld ($D69A), a
	ld ($D69B), a
	ld a, $01
	ld ($D69C), a
	call _LABEL_BCCF_
	ret

; 20th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_B06C_:
	call _LABEL_B9C4_
	call _LABEL_8CA2_
	ld a, ($D6A0)
	or a
	jp z, _LABEL_80FC_
	ld a, ($D6C9)
	and $10
	jp nz, _LABEL_80FC_
	call _LABEL_B1F4_
	ld a, ($D6A0)
	dec a
	jr nz, +
	xor a
	ld ($DC3F), a
	call _LABEL_8205_
	jp _LABEL_80FC_

+:
	ld a, $01
	ld ($DC3F), a
	call _LABEL_8953_
	jp _LABEL_80FC_

; 15th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_B09F_:
	ld a, ($D688)
	or a
	jr z, +
	dec a
	ld ($D688), a
	jp _LABEL_80FC_

+:
	ld a, ($D6B9)
	cp $02
	jr z, +
	call _LABEL_996E_
	ld a, ($D6CA)
	or a
	jp nz, _LABEL_B154_
	call _LABEL_95C3_
	call _LABEL_9B87_
	call _LABEL_9D4E_
	ld a, ($D6B9)
	or a
	jr z, _LABEL_B110_
	dec a
	jr z, _LABEL_B132_
	jp _LABEL_80FC_

+:
	ld a, ($D6AC)
	add a, $01
	ld ($D6AC), a
	cp $30
	jr z, +
	dec a
	call z, _LABEL_A645_
	jp _LABEL_80FC_

+:
	call _LABEL_B1F4_
	ld a, ($DC3F)
	dec a
	jr z, +
	call _LABEL_89E2_
	jp _LABEL_80FC_

+:
	ld a, ($DBD8)
	or a
	jr nz, +
	ld ($D6AB), a
	ld a, $09
	ld ($D699), a
	ld a, $01
	ld ($D6C1), a
	call _LABEL_9400_
	jp _LABEL_80FC_

+:
	jp _LABEL_84AA_

_LABEL_B110_:
	ld a, ($D6CD)
	cp $02
	jp z, _LABEL_80FC_
	add a, $01
	ld ($D6CD), a
	dec a
	jr z, +
	dec a
	jr z, ++
	jp _LABEL_80FC_

+:
	call _LABEL_A645_
	jp _LABEL_80FC_

++:
	call _LABEL_A5C9_
	jp _LABEL_80FC_

_LABEL_B132_:
	ld a, ($D6CD)
	cp $02
	jp z, _LABEL_80FC_
	add a, $01
	ld ($D6CD), a
	dec a
	jr z, +
	dec a
	jr z, ++
	jp _LABEL_80FC_

+:
	call _LABEL_A5F9_
	jp _LABEL_80FC_

++:
	call _LABEL_A618_
	jp _LABEL_80FC_

_LABEL_B154_:
	ld a, ($DC3F)
	or a
	jr z, +
	xor a
	ld ($D6CB), a
	jp +++

+:
	ld a, ($D6AF)
	cp $08
	jr z, _LABEL_B1B9_
	or a
	jr nz, _LABEL_B1B6_
	ld a, ($D6C6)
	dec a
	jr z, +
-:
	ld a, ($D680)
	jp ++

+:
	ld a, ($DC3C)
	or a
	jr z, +
	ld a, ($DC41)
	or a
	jr z, -
+:
	ld a, ($D681)
++:
	ld ($D6C9), a
	and $04
	jr z, _LABEL_B1B9_
	ld a, ($D6C9)
	and $08
	jr z, ++++
	ld a, ($D6C9)
	and $10
	jr nz, _LABEL_B1B6_
+++:
	xor a
	ld ($D6CA), a
	ld a, ($DBD3)
	srl a
	srl a
	srl a
	ld c, a
	ld b, $00
	ld hl, $DC21
	add hl, bc
	ld a, ($D6CB)
	ld (hl), a
	call _LABEL_9E52_
_LABEL_B1B6_:
	jp _LABEL_80FC_

_LABEL_B1B9_:
	xor a
	ld ($D6CB), a
	call _LABEL_B389_
	ld bc, $0005
	call _LABEL_A5B0_
	jp _LABEL_80FC_

++++:
	ld a, $01
	ld ($D6CB), a
	call _LABEL_B389_
	ld hl, $B1E7
	ld bc, $0005
	call _LABEL_A5B0_
	jp _LABEL_80FC_

; Data from B1DD to B1EB (15 bytes)
.db $B5 $0D $1A $B5 $0E $0E $B5 $0D $1A $B5 $B5 $18 $04 $12 $B5

_LABEL_B1EC_:
	ld a, $0C
	ld ($D741), a
	jp $DB1C	; Possibly invalid

_LABEL_B1F4_:
	ld a, $0C
	ld ($D741), a
	jp $DB26	; Possibly invalid

_LABEL_B1FC_:
	ld a, ($DC34)
	dec a
	jr z, +
	ld hl, $B219
	ld a, ($D6CC)
	sub $01
-:
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld ($DBD8), a
+:
	ret

_LABEL_B213_:
	ld hl, $B222
	jp -

; Data from B219 to B229 (17 bytes)
.db $02 $14 $0E $17 $0D $04 $07 $15 $05 $02 $15 $0E $05 $07 $00 $04
.db $0D

_LABEL_B22A_:
	call _LABEL_B230_
	jp _LABEL_8E54_

_LABEL_B230_:
	ld bc, $000F
	ld hl, $AE0A
	ld ($D6A6), hl
	call _LABEL_AE50_
	ld bc, $0013
	ld hl, $AE19
	ld ($D6A6), hl
	call _LABEL_AE50_
	ld bc, $0017
	ld hl, $AE28
	ld ($D6A6), hl
	jp _LABEL_AE50_

_LABEL_B254_:
	ld bc, $000F
	call _LABEL_AE94_
	ld bc, $0013
	call _LABEL_AE94_
	ld bc, $0017
	call _LABEL_AE94_
	jp _LABEL_8E54_

_LABEL_B269_:
	ld a, ($DBD8)
	add a, $01
	ld ($DBD8), a
	cp $0A
	jr z, _LABEL_B269_
	cp $11
	jr z, _LABEL_B269_
	cp $16
	jr z, _LABEL_B269_
	ret

_LABEL_B27E_:
	ld a, ($DBD8)
	sub $01
	or a
	jr nz, +
	ld a, $1C
+:
	ld ($DBD8), a
	cp $0A
	jr z, _LABEL_B27E_
	cp $11
	jr z, _LABEL_B27E_
	cp $16
	jr z, _LABEL_B27E_
	ret

_LABEL_B298_:
	ld a, ($DBD8)
	add a, $01
	cp $1D
	jr nz, +
	ld a, $01
+:
	ld ($DBD8), a
	cp $0A
	jr z, _LABEL_B298_
	cp $11
	jr z, _LABEL_B298_
	cp $16
	jr z, _LABEL_B298_
	ret

_LABEL_B2B3_:
	ld a, ($D6C3)
	ld c, a
	ld a, h
	sub c
	ld h, a
	ret

_LABEL_B2BB_:
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	ld a, ($DC3C)
	dec a
	jr z, +
	call _LABEL_9448_
	call _LABEL_94AD_
	call _LABEL_B305_
+:
	ret

_LABEL_B2DC_:
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	call _LABEL_9448_
	jp _LABEL_94AD_

_LABEL_B2F3_:
	ld hl, $7BC0
	call _LABEL_B35A_
	call _LABEL_95AF_
	ld hl, $7D80
	call _LABEL_B35A_
	call _LABEL_95AF_
_LABEL_B305_:
	ld hl, $7840
	call _LABEL_B35A_
	jp _LABEL_95AF_

_LABEL_B30E_:
	ld a, $01
	ld ($D6C0), a
-:
	ld a, $40
	ld ($D6AF), a
	ld a, ($D6B9)
	ret

_LABEL_B31C_:
	xor a
	ld ($D6C0), a
	jp -

_LABEL_B323_:
	ld hl, $97DF
	ld de, $DBFE
	ld bc, $0000
-:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
	inc bc
	ld a, c
	cp $0B
	jr nz, -
	ret

_LABEL_B337_:
	ld hl, $4000
	call _LABEL_B35A_
	ld bc, $2000
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	ld hl, $6000
	call _LABEL_B35A_
	ld bc, $1700
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

_LABEL_B35A_:
	ld a, l
	out ($BF), a
	ld a, h
	out ($BF), a
	ret

_LABEL_B361_:
	ld a, e
	out ($BF), a
	ld a, d
	out ($BF), a
	ret

_LABEL_B368_:
	ld a, $01
	ld ($D6C1), a
	xor a
	ld ($D6AB), a
	ld ($D6C5), a
	ret

_LABEL_B375_:
	ld a, $24
_LABEL_B377_:
	ld ($D68A), a
	ld a, $05
	ld ($D69A), a
	ld a, $06
	ld ($D69B), a
	xor a
	ld ($D69C), a
	ret

_LABEL_B389_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7B2C
	call _LABEL_B35A_
	ld hl, $B1DD
	jr ++

+:
	ld hl, $7C6A
	call _LABEL_B35A_
	ld hl, $B1E2
++:
	ret

_LABEL_B3A4_:
	call _LABEL_B361_
	ld bc, $000E
	call _LABEL_A5B0_
	ret

_LABEL_B3AE_:
	ld a, $06
	ld ($D6AB), a
	ld a, ($D6AD)
	sub $01
	cp $FF
	jr nz, +
	ld a, $0A
+:
	ld c, a
	ld b, $00
	call _LABEL_B412_
_LABEL_B3C4_:
	ld hl, $9773
	add hl, de
	ld ($D6BE), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	call _LABEL_B361_
	ld ($D6A8), de
	ld hl, $97DF
	add hl, bc
	ld a, (hl)
	ld ($D6BB), a
	ld hl, $DBFE
	add hl, bc
	ld a, (hl)
	ld ($D6BC), bc
	call _LABEL_9F40_
	call _LABEL_AECD_
	ld bc, ($D6BC)
	ld de, ($D6BE)
	ld a, e
	add a, $02
	cp $0C
	jr nz, +
	xor a
+:
	ld e, a
	inc bc
	ld a, c
	cp $0B
	jr nz, +
	xor a
+:
	ld c, a
	ld a, ($D6AB)
	sub $01
	ld ($D6AB), a
	or a
	jr nz, _LABEL_B3C4_
	ret

_LABEL_B412_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, ($DBFB)
	sub $03
	sra a
	sra a
	ld d, $00
	ld e, a
	ret

+:
	ld a, ($DBFB)
	ld e, a
	ld d, $00
	ld hl, $9849
	add hl, de
	ld e, (hl)
	ld d, $00
	ret

_LABEL_B433_:
	ld a, ($D680)
	and $1C
	cp $1C
	jr nz, +
	ld a, ($D681)
	and $1C
	cp $1C
	jr nz, +
	ret

+:
	xor a
	ld ($D6AB), a
	ld ($D6AC), a
	ret

_LABEL_B44E_:
	ld bc, $013C
	ld hl, $D680
-:
	xor a
	ld (hl), a
	dec bc
	inc hl
	ld a, b
	or c
	jr nz, -
	ret

_LABEL_B45D_:
	ld a, ($D6D4)
	or a
	jp z, +
	ld a, ($D691)
	call _LABEL_B478_
	ld hl, ($D7B5)
	call $D7BD	; Possibly invalid
	xor a
	ld ($D6D4), a
	ld ($D6D3), a
+:
	ret

_LABEL_B478_:
	ld e, a
	ld d, $00
	ld hl, $926C
	add hl, de
	ld a, (hl)
	ld ($D741), a
	ret

_LABEL_B484_:
	ld a, ($DC41)
	or a
	jr nz, ++
	ld a, ($D6D1)
	or a
	jr z, +
	ld a, ($D680)
	cp $3F
	jr nz, ++
	xor a
	ld ($D6D1), a
	ret

+:
	ld a, ($D680)
	cp $3F
	jr z, ++
	ld e, a
	call _LABEL_B4C0_
	call _LABEL_B4E1_
++:
	ret

; Data from B4AB to B4BF (21 bytes)
.db $3E $1F $3D $1F $1F $3B $1F $1F $1F $00 $3E $3D $3B $37 $3B $1F
.db $3E $3E $1F $3E $00

_LABEL_B4C0_:
	ld a, ($D6D0)
	ld c, a
	ld b, $00
	ld hl, $B4AB
	add hl, bc
	ld a, (hl)
	cp e
	jr nz, +
	ld a, ($D6D0)
	add a, $01
	ld ($D6D0), a
	ld a, $01
	ld ($D6D1), a
	ret

+:
	xor a
	ld ($D6D0), a
	ret

_LABEL_B4E1_:
	ld a, ($DC45)
	ld c, a
	ld b, $00
	ld hl, $B4B5
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	cp e
	jr nz, +
	ld a, ($DC45)
	add a, $01
	ld ($DC45), a
	ld a, $01
	ld ($D6D1), a
	ret

+:
	xor a
	ld ($DC45), a
	ret

_LABEL_B505_:
	ld a, ($DC46)
	or a
	ret z
	ld hl, $7A52
	call _LABEL_B35A_
	ld a, ($D7BA)
	inc a
	and $0F
	ld ($D7BA), a
	and $08
	jr z, +++
	ld a, ($DC46)
	cp $01
	jr z, +
	cp $02
	jr z, ++
	ret

+:
	ld c, $0C
	ld hl, $B541
	jp _LABEL_A5B0_

++:
	ld c, $0E
	ld hl, $B54D
	jp _LABEL_A5B0_

+++:
	ld c, $0E
	ld hl, $AAAE
	jp _LABEL_A5B0_

; Data from B541 to B56C (44 bytes)
.db $0E $0E $07 $00 $11 $03 $0E $0E $0C $1A $03 $04 $11 $1A $02 $0A
.db $0E $07 $00 $11 $03 $0E $0C $1A $03 $04 $AF $32 $46 $DC $32 $D0
.db $D6 $32 $45 $DC $21 $52 $7A $CD $5A $B3 $18 $CC

; 17th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_B56D_:
	call _LABEL_B9C4_
	call _LABEL_A2AA_
	call _LABEL_9FC5_
	ld a, ($D6C1)
	cp $01
	jr z, _LABEL_B5E7_
	ld a, ($DC34)
	cp $01
	jr nz, ++
	call _LABEL_B9A3_
	ld a, ($D6CB)
	xor $01
	ld ($D6CB), a
	cp $01
	jr z, +
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
+:
	ld a, ($D6AB)
	cp $B8
	jr z, ++++
	cp $40
	jr nc, +++
	jp _LABEL_B618_

++:
	ld a, ($D693)
	cp $01
	jp z, _LABEL_B6AB_
	cp $00
	jp nz, _LABEL_A129_
	call _LABEL_B98E_
	ld a, ($D697)
	cp $01
	jr z, _LABEL_B623_
	ld a, ($D6C9)
	and $04
	jp z, _LABEL_B640_
	ld a, ($D6C9)
	and $08
	jp z, _LABEL_B666_
	ld a, ($D6CC)
	cp $00
	jr z, _LABEL_B618_
+++:
	ld a, ($D6C9)
	and $10
	jr nz, _LABEL_B618_
++++:
	call _LABEL_B368_
	call _LABEL_9400_
	jp _LABEL_B618_

_LABEL_B5E7_:
	ld a, ($D6AB)
	add a, $01
	ld ($D6AB), a
	cp $04
	jr nz, _LABEL_B618_
	xor a
	ld ($D6AB), a
	ld a, ($D6C5)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_

+:
	call _LABEL_B1F4_
	ld a, ($DC3B)
	dec a
	jr z, +
	call _LABEL_B1FC_
	ld a, $01
	ld ($DC3D), a
	ld ($D6D5), a
_LABEL_B618_:
	jp _LABEL_80FC_

+:
	ld a, $01
	ld ($D6D5), a
	jp _LABEL_80FC_

_LABEL_B623_:
	ld a, ($D6C9)
	and $1C
	cp $1C
	jr nz, _LABEL_B618_
	ld a, ($DC3C)
	or a
	jr nz, +
	ld a, ($D681)
	and $1C
	cp $1C
	jr nz, _LABEL_B618_
+:
	xor a
	ld ($D697), a
	ret

_LABEL_B640_:
	ld a, ($DC3B)
	dec a
	jr z, +++
	ld a, ($D6CC)
	sub $01
	cp $FF
	jr z, +
	or a
	jr nz, ++
+:
	ld a, $09
++:
	ld ($D6CC), a
	jp ++++

+++:
	call _LABEL_B27E_
	call _LABEL_AB5B_
	call _LABEL_AA8B_
	jp +++++

_LABEL_B666_:
	ld a, ($DC3B)
	dec a
	jr z, ++
	ld a, ($D6CC)
	add a, $01
	cp $0A
	jr nz, +
	ld a, $01
+:
	ld ($D6CC), a
	jp ++++

++:
	call _LABEL_B298_
	call _LABEL_AB5B_
	call _LABEL_AA8B_
	jp +++++

++++:
	call _LABEL_A01C_
	call _LABEL_AB68_
+++++:
	call _LABEL_A0F0_
	ld a, $01
	ld ($D6D4), a
	ld a, $09
	ld ($D693), a
	ld de, $6C00
	ld ($D6A8), de
	ld a, $01
	ld ($D697), a
	jp _LABEL_80FC_

_LABEL_B6AB_:
	call _LABEL_ABB3_
	jp _LABEL_80FC_

; 18th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_B6B1_:
	call _LABEL_B9C4_
	call _LABEL_A039_
	ld hl, ($D6AB)
	inc hl
	ld ($D6AB), hl
	ld a, h
	cp $01
	jr z, +
	ld a, l
	cp $80
	jr c, ++
	ld a, ($D680)
	and $10
	jr z, +
	ld a, ($D681)
	and $10
	jr nz, ++
+:
	call _LABEL_B1F4_
	ld a, ($DC34)
	dec a
	jr z, +++
	call _LABEL_8114_
++:
	jp _LABEL_80FC_

+++:
	ld a, ($DC36)
	cp $04
	jr z, +
	ld a, ($DC37)
	cp $04
	jr z, +
	ld a, ($DC35)
	cp $07
	jr z, +
	add a, $01
	ld ($DC35), a
	call _LABEL_8A30_
	jp _LABEL_80FC_

+:
	call _LABEL_B877_
	jp _LABEL_80FC_

_LABEL_B70B_:
	call _LABEL_BB85_
	ld a, $10
	ld ($D699), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	call _LABEL_A296_
	ld a, $01
	ld ($DC3B), a
	ld ($D6CC), a
	ld ($DBD8), a
	ld a, $B2
	ld ($D6C8), a
	call _LABEL_9448_
	call _LABEL_94AD_
	ld hl, $7840
	call _LABEL_B35A_
	call _LABEL_95AF_
	ld a, $60
	ld ($D6AF), a
	xor a
	ld ($D6AB), a
	ld ($D6AC), a
	ld ($D6C1), a
	ld ($D693), a
	ld ($D6CE), a
	call _LABEL_AB5B_
	call _LABEL_AB9B_
	call _LABEL_ABB0_
	ld c, $07
	call _LABEL_B1EC_
	call _LABEL_A673_
	call _LABEL_9317_
	ld hl, $B356
	call $D9F5	; Possibly invalid
	call _LABEL_BF2E_
	call _LABEL_BB75_
	ret

_LABEL_B77C_:
	ld hl, $DC36
	add hl, de
	ld a, (hl)
	add a, $01
	ld (hl), a
	ret

_LABEL_B785_:
	ld a, ($DC3C)
	xor $01
	rrca
	ld e, a
	ld d, $00
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $78DC
	add hl, de
	call _LABEL_B35A_
	ld a, ($DC36)
	call _LABEL_B7F1_
	ld hl, $791C
	add hl, de
	call _LABEL_B35A_
	call _LABEL_B7F9_
	ld hl, $78E2
	add hl, de
	call _LABEL_B35A_
	ld a, ($DC37)
	call _LABEL_B7F1_
	ld hl, $7922
	add hl, de
	call _LABEL_B35A_
	jp _LABEL_B7F9_

+:
	ld hl, $7B5C
	add hl, de
	call _LABEL_B35A_
	ld a, ($DC36)
	call _LABEL_B7F1_
	ld hl, $7B9C
	add hl, de
	call _LABEL_B35A_
	call _LABEL_B7F9_
	ld hl, $7B62
	add hl, de
	call _LABEL_B35A_
	ld a, ($DC37)
	call _LABEL_B7F1_
	ld hl, $7BA2
	add hl, de
	call _LABEL_B35A_
	jp _LABEL_B7F9_

_LABEL_B7F1_:
	sla a
	add a, $60
	ld c, a
	out ($BE), a
	ret

_LABEL_B7F9_:
	ld a, c
	add a, $01
	out ($BE), a
	ret

_LABEL_B7FF_:
	ld de, $0000
	ld a, ($DBD4)
	ld c, a
	ld a, ($DBCF)
	call _LABEL_B819_
	ld de, $0001
	ld a, ($DBD5)
	ld c, a
	ld a, ($DBD0)
	jp _LABEL_B819_

_LABEL_B819_:
	or a
	jr z, +
	ld hl, $DC16
	jp ++

+:
	call _LABEL_B77C_
	ld hl, $DC0B
++:
	ld a, c
	srl a
	srl a
	srl a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, (hl)
	and $0F
	cp $09
	jr z, +
	ld a, (hl)
	add a, $01
	ld (hl), a
	ret

+:
	ld a, (hl)
	and $F0
	cp $90
	jr z, +
	add a, $10
	ld (hl), a
	ret

+:
	xor a
	ld (hl), a
	ret

; 19th entry of Jump Table from 80BE (indexed by $D699)
_LABEL_B84D_:
	call _LABEL_B911_
	ld a, ($D6AB)
	cp $FF
	jr z, +
	add a, $01
	ld ($D6AB), a
	cp $80
	jr c, ++
+:
	ld a, ($D680)
	and $10
	jr z, +
	ld a, ($D681)
	and $10
	jr nz, ++
+:
	call _LABEL_B1F4_
	call _LABEL_8114_
++:
	jp _LABEL_80FC_

_LABEL_B877_:
	call _LABEL_BB85_
	ld a, $12
	ld ($D699), a
	ld a, $B2
	ld ($D6C8), a
	call _LABEL_B2DC_
	call _LABEL_B305_
	call _LABEL_B8CF_
	call _LABEL_B8E3_
	ld hl, $4480
	call _LABEL_B35A_
	ld a, ($DC34)
	or a
	jr nz, +
	ld c, $03
	call _LABEL_B1EC_
	jp ++

+:
	ld c, $0C
	call _LABEL_B1EC_
	ld a, ($DBCF)
	or a
	jr z, ++
	ld a, ($DBD5)
	jp +++

++:
	ld a, ($DBD4)
+++:
	call _LABEL_9F40_
	ld hl, $7B26
	call _LABEL_B8C9_
	xor a
	ld ($D6AB), a
	call _LABEL_BB75_
	ret

_LABEL_B8C9_:
	call _LABEL_B375_
	jp _LABEL_BCCF_

_LABEL_B8CF_:
	ld a, $06
	ld ($D741), a
	ld hl, $B2C3
	call $D7BD	; Possibly invalid
	ld hl, $6C00
	ld de, $0290
	jp _LABEL_AFA5_

_LABEL_B8E3_:
	ld a, $09
	ld ($D741), a
	ld hl, $B9F0
	call $D7BD	; Possibly invalid
	ld hl, $7A8E
	call _LABEL_B35A_
	ld de, $7A8E
	ld hl, $C000
	ld a, $0C
	ld ($D69D), a
	ld a, $09
	ld ($D69E), a
	ld a, $60
	ld ($D69F), a
	ld a, $01
	ld ($D69C), a
	jp $D997	; Possibly invalid

_LABEL_B911_:
	ld a, ($D6AF)
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	and $01
	jp nz, +++
	ld a, ($DC3F)
	dec a
	jr z, ++
	ld hl, $79CC
	call _LABEL_B35A_
	ld a, ($DC34)
	or a
	jr z, +
	ld hl, $B966
	ld bc, $0014
	jp _LABEL_A5B0_

+:
	ld hl, $B97A
	ld bc, $0014
	jp _LABEL_A5B0_

++:
	ld hl, $79D6
	call _LABEL_B35A_
	ld hl, $B984
	ld bc, $000A
	jp _LABEL_A5B0_

+++:
	ld hl, $79CC
	call _LABEL_B35A_
	ld hl, $AAAE
	ld bc, $0014
	jp _LABEL_A5B0_

; Data from B966 to B98D (40 bytes)
.db $13 $1A $14 $11 $0D $00 $0C $04 $0D $13 $0E $02 $07 $00 $0C $0F
.db $08 $1A $0D $B4 $02 $07 $00 $0B $0B $04 $0D $06 $04 $0E $02 $07
.db $00 $0C $0F $08 $1A $0D $0E $B4

_LABEL_B98E_:
	ld a, ($DC3C)
	or a
	jr z, _LABEL_B9A3_
	ld a, ($DC41)
	or a
	jr nz, _LABEL_B9A3_
	ld a, ($D680)
	and $1C
	ld ($D6C9), a
	ret

_LABEL_B9A3_:
	ld a, ($D680)
	and $1C
	ld c, a
	ld a, ($D681)
	and $1C
	and c
	ld ($D6C9), a
	ret

_LABEL_B9B3_:
	ld hl, $DC2C
	ld c, $08
-:
	xor a
	ld (hl), a
	inc hl
	dec c
	jr nz, -
	ld a, $01
	ld ($DC31), a
	ret

_LABEL_B9C4_:
	ld e, $08
-:
	ld a, ($D6CF)
	add a, $01
	and $07
	ld ($D6CF), a
	ld c, a
	ld b, $00
	ld hl, $DC2C
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	dec e
	jr nz, -
+:
	ld a, ($D7B3)
	add a, $01
	cp $0B
	jr nz, +
	ld a, $01
+:
	ld ($D7B3), a
	ret

_LABEL_B9ED_:
	ld a, ($DC3C)
	xor $01
	rrca
	rrca
	ld e, a
	ld d, $00
	ld a, ($D699)
	cp $11
	jr z, +
	ld hl, $7990
	add hl, de
	call _LABEL_B35A_
	ld a, $50
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld hl, $79AE
	add hl, de
	call _LABEL_B35A_
	ld a, $53
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

+:
	ld hl, $7C10
	add hl, de
	call _LABEL_B35A_
	ld a, $50
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld hl, $7C2E
	add hl, de
	call _LABEL_B35A_
	ld a, $53
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_BA3C_:
	ld hl, $6A00
	call _LABEL_B35A_
_LABEL_BA42_:
	ld a, $08
	ld ($D741), a
	ld e, $20
	ld hl, $AB8C
	jp $D985	; Possibly invalid

_LABEL_BA4F_:
	ld a, $09
	ld ($D741), a
	ld hl, $B94C
	call $D7BD	; Possibly invalid
	ld de, $0050
	ld hl, $4C00
	jp _LABEL_AFA5_

_LABEL_BA63_:
	ld a, ($D6AF)
	cp $00
	jr z, +
	sub $01
	ld ($D6AF), a
	sra a
	sra a
	sra a
	and $01
	jr nz, ++
	ld hl, $79D6
	call _LABEL_B35A_
	ld bc, $000A
	ld hl, $BAB7
	call _LABEL_A5B0_
	ld hl, $7A16
	call _LABEL_B35A_
	ld bc, $000A
	ld hl, $BAC1
	call _LABEL_A5B0_
+:
	ret

++:
	ld hl, $79D6
	call _LABEL_B35A_
	ld bc, $000A
	ld hl, $BACB
	call _LABEL_A5B0_
	ld hl, $7A16
	call _LABEL_B35A_
	ld bc, $000A
	ld hl, $BACB
	call _LABEL_A5B0_
	ret

; Data from BAB7 to BAD4 (30 bytes)
.db $10 $14 $00 $0B $08 $05 $18 $08 $0D $06 $0E $0E $0E $11 $00 $02
.db $04 $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E

_LABEL_BAD5_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, $08
	ld ($D741), a
	ld hl, $AC4E
	call $D7BD	; Possibly invalid
	ld de, $0588
	jr ++

+:
	ld a, $0F
	ld ($D741), a
	ld hl, $A5D7
	call $D7BD	; Possibly invalid
	ld de, $0380
++:
	ld hl, $6000
	jp _LABEL_AFA5_

_LABEL_BAFF_:
	ld a, $0A
	ld ($D741), a
	ld hl, $B02D
	call $D7BD	; Possibly invalid
	ld hl, $4000
	ld de, $0120
	jp _LABEL_AFA5_

_LABEL_BB13_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, $03
	ld ($D741), a
	ld hl, $BAA5
	call $D7BD	; Possibly invalid
	ld hl, $4480
	ld de, $0280
	call _LABEL_AFA5_
	jr ++

+:
	ld bc, $0A00
	ld hl, $4480
	call _LABEL_B35A_
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
++:
	ld a, $01
	ld ($D6CB), a
	call _LABEL_90E7_
	ret

_LABEL_BB49_:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld a, $06
	jr ++

+:
	xor a
++:
	out ($BF), a
	ld a, $88
	out ($BF), a
	ret

_LABEL_BB5B_:
	xor a
	out ($BF), a
	ld a, $87
	out ($BF), a
	ret

; Data from BB63 to BB6B (9 bytes)
.db $3E $70 $D3 $BF $3E $81 $D3 $BF $C9

_LABEL_BB6C_:
	ld a, $10
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_BB75_:
	in a, ($7E)
	cp $FF
	jr nz, _LABEL_BB75_
	ld a, $70
	out ($BF), a
	ld a, $81
	out ($BF), a
	ei
	ret

_LABEL_BB85_:
	di
	in a, ($7E)
	cp $FF
	jr nz, _LABEL_BB85_
	ld a, $10
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_BB95_:
	ld a, ($D6C7)
	dec a
	jr z, _LABEL_BBE0_
	ld a, $09
	ld ($D741), a
	ld hl, $AC52
	call $D7BD	; Possibly invalid
	ld hl, $4480
	ld de, $01E0
	call _LABEL_AFA5_
	ld a, ($DC3C)
	or a
	jr z, +
	ld a, ($D699)
	cp $02
	jr z, ++
+:
	ld hl, $AFC6
	call $D7BD	; Possibly invalid
	ld hl, $4E80
	ld de, $01E0
	call _LABEL_AFA5_
	jp +++

++:
	ld hl, $BA12
	call $D7BD	; Possibly invalid
	ld hl, $4E80
	ld de, $01E0
	call _LABEL_BD94_
	jp +++

_LABEL_BBE0_:
	ld a, $09
	ld ($D741), a
	ld hl, $B391
	call $D7BD	; Possibly invalid
	ld hl, $4480
	ld de, $01B0
	call _LABEL_AFA5_
	ld hl, $B674
	call $D7BD	; Possibly invalid
	ld hl, $4E80
	ld de, $01B0
	call _LABEL_AFA5_
+++:
	call _LABEL_A296_
	call _LABEL_949B_
	jp _LABEL_948A_

_LABEL_BC0C_:
	ld a, ($D6C7)
	or a
	jr z, +
	ld a, $09
	ld ($D69A), a
	jp ++

+:
	ld a, $0A
	ld ($D69A), a
++:
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7B88
	jr ++

+:
	ld hl, $7ACC
++:
	ld a, ($D699)
	cp $13
	jr nz, +
	ld de, $0040
	or a
	sbc hl, de
+:
	ld a, $24
	ld ($D68A), a
	ld a, $06
	ld ($D69B), a
	xor a
	ld ($D69C), a
	call _LABEL_BCCF_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld hl, $7BA4
	jr ++

+:
	ld hl, $7AE0
++:
	ld a, ($D6C7)
	or a
	jr z, +
	inc hl
	inc hl
+:
	ld a, ($D699)
	cp $13
	jr nz, +
	ld de, $0040
	or a
	sbc hl, de
+:
	ld a, $74
	ld ($D68A), a
	ld a, $06
	ld ($D69B), a
	call _LABEL_BCCF_
	ld a, ($D699)
	cp $0F
	jr z, _LABEL_BCCE_
	ld a, ($DC3C)
	dec a
	jr z, +
	ld de, $7D48
	jr ++

+:
	ld de, $7C4C
++:
	call _LABEL_B361_
	ld hl, $B4BA
	ld a, $08
	ld ($D69D), a
	ld a, $02
	ld ($D69E), a
	ld a, $F0
	ld ($D69F), a
	call $D997	; Possibly invalid
	ld a, ($DC3C)
	dec a
	jr z, +
	ld de, $7D64
	jr ++

+:
	ld de, $7C60
++:
	call _LABEL_B361_
	ld hl, $B5BE
	ld a, $0A
	ld ($D69D), a
	ld a, $02
	ld ($D69E), a
	ld a, $E2
	ld ($D69F), a
	call $D997	; Possibly invalid
_LABEL_BCCE_:
	ret

_LABEL_BCCF_:
	call _LABEL_B35A_
	ld de, ($D69A)
-:
	ld a, ($D68A)
	out ($BE), a
	ld a, ($D69C)
	out ($BE), a
	ld a, ($D68A)
	add a, $01
	ld ($D68A), a
	dec de
	ld a, e
	or a
	jr nz, -
	ld a, ($D69B)
	sub $01
	ld ($D69B), a
	or a
	jr z, +
	ld de, $0040
	add hl, de
	jp _LABEL_BCCF_

+:
	ret

_LABEL_BD00_:
	ld a, $26
	out ($BF), a
	ld a, $80
	out ($BF), a
	ld a, $0E
	out ($BF), a
	ld a, $82
	out ($BF), a
	ld a, $7F
	out ($BF), a
	ld a, $85
	out ($BF), a
	ld a, $04
	out ($BF), a
	ld a, $86
	out ($BF), a
	xor a
	out ($BF), a
	ld a, $88
	out ($BF), a
	xor a
	out ($BF), a
	ld a, $89
	out ($BF), a
	ret

_LABEL_BD2F_:
	ld a, ($D6C5)
	cp $06
	jr z, _LABEL_BD7C_
	cp $03
	jr nc, +
	ld hl, $BD58
	call _LABEL_BD82_
	ld b, $07
	ld c, $BE
	otir
	ld hl, $C010
	call $DB07	; Possibly invalid
	ld a, (de)
	out ($BE), a
+:
	ld a, ($D6C5)
	add a, $01
	ld ($D6C5), a
	ret

; Data from BD58 to BD7B (36 bytes)
.db $5E $BD $65 $BD $6C $BD $10 $2A $04 $01 $02 $06 $20 $00 $15 $00
.db $00 $01 $01 $10 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00

_LABEL_BD7C_:
	ld a, $FF
	ld ($D6C5), a
	ret

_LABEL_BD82_:
	sla a
	ld c, a
	ld b, $00
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, $C000
	call $DB07	; Possibly invalid
	ld h, d
	ld l, e
	ret

_LABEL_BD94_:
	call _LABEL_B35A_
	ld hl, $C000
-:
	ld b, $04
	ld c, $BE
	otir
	dec de
	ld a, d
	or e
	jr nz, -
	ret

_LABEL_BDA6_:
	ld ($D6AB), a
	ld ($D6A3), a
	ld a, $3F
	ld ($D680), a
	ld ($D681), a
	ld ($D687), a
	ret

_LABEL_BDB8_:
	ld a, ($DC3C)
	or a
	jr z, +
	ld a, $05
	ld ($D741), a
	ld hl, $BC0C
	call $D7BD	; Possibly invalid
	ld hl, $6E00
	ld de, $00A0
	call _LABEL_BD94_
	ld hl, $7C60
	ld a, $70
	ld ($D68A), a
	ld a, $02
	ld ($D69B), a
	ld a, $0A
	ld ($D69A), a
	ld a, $01
	ld ($D69C), a
	call _LABEL_BCCF_
+:
	ret

_LABEL_BDED_:
	ld a, $0B
	ld ($D741), a
	ld hl, $BF6F
	call $D7BD	; Possibly invalid
	ld hl, $7700
	call _LABEL_B35A_
	ld de, $7700
	ld hl, $C000
	ld a, $20
	ld ($D69D), a
	ld a, $0B
	ld ($D69E), a
	ld a, $01
	ld ($D69C), a
	xor a
	ld ($D69F), a
	jp $D997	; Possibly invalid

_LABEL_BE1A_:
	ld a, ($D6CB)
	or a
	ret z
	xor a
	ld ($D6CB), a
	ld hl, $7D80
	call _LABEL_B35A_
	ld c, $1A
	ld hl, $BE77
	call _LABEL_A5B0_
	ld hl, $7DC0
	call _LABEL_B35A_
	ld c, $1C
	ld hl, $BE91
	call _LABEL_A5B0_
	ld hl, $7B08
	call _LABEL_B35A_
	ld hl, $BEAD
	ld c, $18
	call _LABEL_A5B0_
	ld hl, $7B8C
	call _LABEL_B35A_
	ld hl, $BEC5
	ld c, $14
	call _LABEL_A5B0_
	ld hl, $7BCC
	call _LABEL_B35A_
	ld hl, $BED9
	ld c, $0D
	call _LABEL_A5B0_
	ld hl, $7C0C
	call _LABEL_B35A_
	ld hl, $BEE4
	ld c, $11
	jp _LABEL_A5B0_

; Data from BE77 to BEF4 (126 bytes)
.db $0E $0E $0E $0E $0E $02 $1A $0F $18 $11 $08 $06 $07 $13 $0E $02
.db $1A $03 $04 $0C $00 $12 $13 $04 $11 $12 $0E $0E $0E $12 $1A $05
.db $13 $16 $00 $11 $04 $0E $02 $1A $0C $0F $00 $0D $18 $0E $0B $13
.db $03 $0E $1B $23 $23 $1D $0C $00 $12 $13 $04 $11 $0E $12 $18 $12
.db $13 $04 $0C $0E $15 $04 $11 $12 $08 $1A $0D $0E $01 $18 $0E $0E
.db $00 $12 $07 $0B $04 $18 $0E $11 $1A $14 $13 $0B $04 $03 $06 $04
.db $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $00 $0D $03 $0E $0E $0E
.db $03 $00 $15 $08 $03 $0E $12 $00 $14 $0D $03 $04 $11 $12

_LABEL_BEF5_:
	ld a, ($D699)
	cp $01
	ret nz
	ld hl, $7B08
	call _LABEL_BF1E_
	ld hl, $7B88
	call _LABEL_BF1E_
	ld hl, $7C08
	call _LABEL_BF1E_
	ld hl, $7B2A
	call _LABEL_BF1E_
	ld hl, $7BAA
	call _LABEL_BF1E_
	ld hl, $7C2A
	jr _LABEL_BF1E_

_LABEL_BF1E_:
	call _LABEL_B35A_
	ld c, $07
-:
	ld a, $0E
	out ($BE), a
	xor a
	out ($BE), a
	dec c
	jr nz, -
	ret

_LABEL_BF2E_:
	ld hl, $C000
	call _LABEL_B35A_
	ld hl, $BF3E
	ld b, $20
	ld c, $BE
	otir
	ret

; Data from BF3E to BFFF (194 bytes)
.db $21 $3F $08 $02 $17 $0B $35 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $21 $3F $08 $02 $17 $0B $3A $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $18 $00 $CD $58 $B3 $0E $05 $3E $0E $D3 $BE $AF $D3 $BE $0D $20
.db $F6 $C9 $21 $00 $C0 $CD $58 $B3 $21 $80 $BF $06 $40 $0E $BE $ED
.db $B3 $C9 $04 $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $44 $0E
.db $00 $00 $22 $02 $44 $04 $88 $08 $40 $00 $C0 $00 $E0 $00 $AE $0A
.db $00 $00 $04 $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $88 $0E
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $FE $FF $EE $FF $FE $EF $EF $EE $FF $FF $EF $EF $FA $EF
.db $FF $7F $EA $EF $EE $FF $FA $FF $EB $FF $FF $FE $7F $EF $BA $FE
.db $EF $EE $FE $FB $EF $EB $FB $EF $AE $BD $FE $FF $EF $EE $AF $BF
.db $FF $FF $FF $FF $FE $BB $EE $FB $EF $EE $FE $FF $FF $BA $FE $FF
.db $EF $02

.BANK 3
.ORG $0000

; Data from C000 to FFFF (16384 bytes)
.incbin "Micro Machines_c000.inc"

.BANK 4
.ORG $0000

; Data from 10000 to 13FFF (16384 bytes)
.incbin "Micro Machines_10000.inc"

.BANK 5
.ORG $0000

; Data from 14000 to 17E94 (16021 bytes)
.incbin "Micro Machines_14000.inc"

_LABEL_17E95_:
	ld a, $80
	out ($BF), a
	ld a, $73
	out ($BF), a
	ld bc, $0020
	ld hl, $BDD5
	call _LABEL_17EB4_
	ld a, $80
	out ($BF), a
	ld a, $74
	out ($BF), a
	ld bc, $0010
	ld hl, $BE55
_LABEL_17EB4_:
	push bc
	ld b, $04
	ld c, $BE
	otir
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, _LABEL_17EB4_
	ret

; Data from 17EC2 to 17FFF (318 bytes)
.db $D2 $BE $F2 $BE $12 $BF $32 $BF $52 $BF $72 $BF $92 $BF $B2 $BF
.db $00 $05 $06 $3F $2A $15 $02 $24 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $00 $06 $05 $3F $2A $24 $39 $0B $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $25 $00 $3F $0F $05 $0A $14 $29 $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $00 $2A $3F $0B $06 $05 $35 $02 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $00 $08 $04 $3F $2A $05 $0B $03 $30 $35 $3A $3F $30 $35 $3A $3F
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $00 $15 $2A $3F $02 $04 $06 $0B $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $00 $30 $35 $3A $3F $01 $02 $08 $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $00 $3F $1A $04 $38 $06 $05 $01 $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00
.db $FF $FF $FF $FF $FF $FF $FF $DF $FF $FF $FF $DF $FF $FF $FF $7F
.db $FF $7F $FF $FF $FF $7F $FF $FF $FF $7F $FE $FF $FF $FF $FF $FF
.db $FF $F7 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $05

.BANK 6
.ORG $0000

; Data from 18000 to 1BFFF (16384 bytes)
.incbin "Micro Machines_18000.inc"

.BANK 7
.ORG $0000

; Data from 1C000 to 1FFFF (16384 bytes)
.incbin "Micro Machines_1c000.inc"

.BANK 8
.ORG $0000

; Data from 20000 to 23CE5 (15590 bytes)
.incbin "Micro Machines_20000.inc"

_LABEL_23CE6_:
	ld a, ($DC54)
	or a
	jr z, _LABEL_23D4B_
	ld a, ($DB97)
	cp $08
	jr z, +
	cp $02
	jr z, ++
	ret

+:
	ld hl, $1D25
	ld ($DF77), hl
	jp +++

++:
	ld hl, $1D35
	ld ($DF77), hl
+++:
	ld a, ($DF76)
	add a, $01
	and $03
	ld ($DF76), a
	jr z, +
	ret

+:
	ld de, $C01E
-:
	ld a, e
	out ($BF), a
	ld a, d
	out ($BF), a
	ld hl, ($DF77)
	ld a, ($DF75)
	ld c, a
	ld b, $00
	add hl, bc
	ld a, (hl)
	out ($BE), a
	inc hl
	ld a, (hl)
	out ($BE), a
	ld a, ($DF75)
	add a, $02
	and $0F
	ld ($DF75), a
	ld a, e
	sub $02
	ld e, a
	cp $0E
	jr nz, -
	ld a, ($DF75)
	add a, $02
	and $0F
	ld ($DF75), a
	ret

_LABEL_23D4B_:
	ld a, ($DB97)
	cp $08
	jr z, +
	cp $02
	jr z, ++
	ret

+:
	ld hl, $BDA6
	ld ($DF77), hl
	jp +++

++:
	ld hl, $BDAE
	ld ($DF77), hl
+++:
	ld a, ($DF76)
	add a, $01
	and $03
	ld ($DF76), a
	jr z, +
	ret

+:
	ld de, $C00F
-:
	ld a, e
	out ($BF), a
	ld a, d
	out ($BF), a
	ld hl, ($DF77)
	ld a, ($DF75)
	ld c, a
	ld b, $00
	add hl, bc
	ld a, (hl)
	out ($BE), a
	ld a, ($DF75)
	add a, $01
	and $07
	ld ($DF75), a
	ld a, e
	sub $01
	ld e, a
	cp $07
	jr nz, -
	ld a, ($DF75)
	add a, $01
	and $07
	ld ($DF75), a
	ret

; Data from 23DA6 to 23FFF (602 bytes)
.db $30 $35 $3A $3F $30 $35 $3A $3F $21 $25 $3A $3F $3A $25 $21 $10
.db $3E $00 $D3 $BF $3E $77 $D3 $BF $01 $80 $03 $3E $00 $D3 $BE $3E
.db $00 $D3 $BE $0B $78 $B1 $20 $F3 $3E $00 $D3 $BF $3E $7E $D3 $BF
.db $01 $80 $00 $3E $14 $D3 $BE $3E $00 $D3 $BE $0B $78 $B1 $20 $F3
.db $C9 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $24 $66 $66 $66
.db $66 $11 $11 $11 $14 $69 $CD $DD $DD $11 $11 $45 $79 $BD $DD $DD
.db $DD $11 $11 $11 $47 $AC $DD $DD $DD $11 $11 $11 $24 $66 $66 $66
.db $66 $11 $11 $11 $24 $68 $99 $99 $99 $11 $11 $45 $79 $BD $DD $DD
.db $DD $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $47 $AC $DD $DD
.db $DD $11 $14 $8B $DF $FF $FF $FF $FF $11 $11 $11 $24 $66 $66 $66
.db $66 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $24 $68 $99 $99 $99 $11 $11 $11 $14 $69 $CD $DD
.db $DD $11 $11 $11 $47 $AC $DD $DD $DD $11 $14 $8B $DF $FF $FF $FF
.db $FF $11 $11 $45 $79 $BD $DD $DD $DD $11 $11 $11 $11 $12 $33 $33
.db $33 $11 $11 $11 $14 $69 $CD $DD $DD $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $14 $8B $DF $FF $FF $FF $FF $11 $11 $11 $24 $68 $99 $99
.db $99 $11 $11 $11 $11 $12 $33 $33 $33 $11 $11 $11 $14 $69 $CD $DD
.db $DD $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $12 $46 $66 $66 $66 $66 $11 $11 $11 $46 $9C $DD $DD
.db $DD $11 $14 $57 $9B $DD $DD $DD $DD $11 $11 $14 $7A $CD $DD $DD
.db $DD $11 $11 $12 $46 $66 $66 $66 $66 $11 $11 $12 $46 $89 $99 $99
.db $99 $11 $14 $57 $9B $DD $DD $DD $DD $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $14 $7A $CD $DD $DD $DD $11 $48 $BD $FF $FF $FF $FF
.db $FF $11 $11 $12 $46 $66 $66 $66 $66 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $12 $46 $89 $99 $99
.db $99 $11 $11 $11 $46 $9C $DD $DD $DD $11 $11 $14 $7A $CD $DD $DD
.db $DD $11 $48 $BD $FF $FF $FF $FF $FF $11 $14 $57 $9B $DD $DD $DD
.db $DD $11 $11 $11 $11 $23 $33 $33 $33 $11 $11 $11 $46 $9C $DD $DD
.db $DD $11 $11 $11 $11 $11 $11 $11 $11 $11 $48 $BD $FF $FF $FF $FF
.db $FF $11 $11 $12 $46 $89 $99 $99 $99 $11 $11 $11 $11 $23 $33 $33
.db $33 $11 $11 $11 $46 $9C $DD $DD $DD $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $08

.BANK 9
.ORG $0000

; Data from 24000 to 27FFF (16384 bytes)
.incbin "Micro Machines_24000.inc"

.BANK 10
.ORG $0000

; Data from 28000 to 2B5D1 (13778 bytes)
.incbin "Micro Machines_28000.inc"

_LABEL_2B5D2_:
	jp _LABEL_2B616_

; Data from 2B5D5 to 2B615 (65 bytes)
.db $3E $FF $D3 $7E $3E $9F $D3 $7E $3E $BF $D3 $7E $3E $DF $D3 $7E
.db $C9 $3A $7E $D9 $32 $63 $D9 $C9 $3A $7F $D9 $32 $74 $D9 $C9 $2A
.db $5B $D9 $01 $04 $00 $A7 $ED $42 $22 $5B $D9 $C9 $2A $6C $D9 $01
.db $04 $00 $A7 $ED $42 $22 $6C $D9 $C9 $2A $5B $D9 $23 $22 $5B $D9
.db $C9

_LABEL_2B616_:
	ld a, ($D957)
	ld c, a
	inc a
	and $07
	ld ($D957), a
	ld a, c
	and $03
	ld ($D956), a
	ld ix, $D963
	ld bc, $D94C
	call _LABEL_2B7A1_
	call _LABEL_2B64F_
	ld ix, $D974
	ld bc, $D94F
	call _LABEL_2B7A1_
	call _LABEL_2B674_
	ld a, ($D95A)
	or a
	jr nz, _LABEL_2B699_
	call _LABEL_2B6C9_
	call _LABEL_2B70D_
	jp _LABEL_2B751_

_LABEL_2B64F_:
	ld a, ($D964)
	or a
	ret z
	ld a, ($D94C)
	and $0F
	or $90
	out ($7E), a
	ld a, ($D94D)
	or $80
	out ($7E), a
	ld a, ($D94E)
	out ($7E), a
	ld a, ($D964)
	cp $02
	ret nz
	xor a
	ld ($D964), a
	ret

_LABEL_2B674_:
	ld a, ($D975)
	or a
	ret z
	ld a, ($D94F)
	and $0F
	or $B0
	out ($7E), a
	ld a, ($D950)
	or $A0
	out ($7E), a
	ld a, ($D951)
	out ($7E), a
	ld a, ($D975)
	cp $02
	ret nz
	xor a
	ld ($D975), a
	ret

_LABEL_2B699_:
	ld a, ($D96B)
	ld c, a
	ld a, ($D97C)
	or c
	ret nz
	ld a, ($D957)
	add a, a
	ld c, a
	ld b, $00
	ld hl, $B791
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	ld a, $E0
	out ($7E), a
	ld a, (hl)
	out ($7E), a
+:
	inc hl
	ld a, (hl)
	cpl
	and $0F
	or $F0
	out ($7E), a
	ld a, $C0
	out ($7E), a
	xor a
	out ($7E), a
	ret

_LABEL_2B6C9_:
	ld hl, $D95B
	ld a, ($D964)
	or a
	ret nz
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	inc hl
	ld a, (hl)
	cpl
	and $0F
	or $90
	out ($7E), a
	inc hl
	ld a, ($D956)
	ld c, a
	ld b, $00
	add hl, bc
	ld l, (hl)
	ld h, $00
	add hl, de
	ld a, l
	rl l
	rl h
	rl l
	rl h
	rl l
	rl h
	rl l
	rl h
	and $0F
	ld ($D953), a
	ld a, $80
	out ($7E), a
	ld a, h
	and $3F
	ld ($D952), a
	out ($7E), a
	ret

_LABEL_2B70D_:
	ld hl, $D96C
	ld a, ($D975)
	or a
	ret nz
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	inc hl
	ld a, (hl)
	cpl
	and $0F
	or $B0
	out ($7E), a
	inc hl
	ld a, ($D956)
	ld c, a
	ld b, $00
	add hl, bc
	ld l, (hl)
	ld h, $00
	add hl, de
	ld a, l
	rl l
	rl h
	rl l
	rl h
	rl l
	rl h
	rl l
	rl h
	and $0F
	ld ($D955), a
	ld a, $A0
	out ($7E), a
	ld a, h
	and $3F
	ld ($D954), a
	out ($7E), a
	ret

_LABEL_2B751_:
	ld a, ($D956)
	and $01
	jp z, +
	ld a, ($D964)
	or a
	ret nz
	ld a, r
	and $07
	ld c, a
	ld a, ($D953)
	add a, c
	and $0F
	or $C0
	out ($7E), a
	ld a, ($D952)
	and $3F
	out ($7E), a
	ret

+:
	ld a, ($D975)
	or a
	ret nz
	ld a, r
	and $07
	ld c, a
	ld a, ($D955)
	add a, c
	and $0F
	or $C0
	out ($7E), a
	ld a, ($D954)
	and $3F
	out ($7E), a
	ret

; Data from 2B791 to 2B7A0 (16 bytes)
.db $02 $0F $07 $0B $00 $07 $00 $03 $02 $0F $07 $0B $00 $07 $00 $03

_LABEL_2B7A1_:
	ld a, (ix+0)
	or a
	jr z, +
	dec a
	add a, a
	ld e, a
	add a, a
	add a, e
	ld e, a
	ld d, $00
	ld hl, $B911
	add hl, de
	push ix
	pop de
	inc de
	inc de
	push bc
	ldi
	ldi
	ldi
	ldi
	ldi
	pop bc
	ld a, (hl)
	ld (de), a
	xor a
	ld (ix+0), a
	inc a
	ld (ix+1), a
+:
	ld a, (ix+1)
	or a
	ret z
	ld l, (ix+2)
	ld h, (ix+3)
	ld a, (hl)
	inc hl
	ld (ix+2), l
	ld (ix+3), h
	cpl
	and $0F
	ld (bc), a
	ld ($D958), a
	ld l, (ix+4)
	ld h, (ix+5)
	ld a, (hl)
	inc hl
	cp $FF
	jr nz, +
	ld a, $0F
	ld (bc), a
	inc bc
	ld (bc), a
	inc bc
	ld (bc), a
	ld a, $02
	ld (ix+1), a
	jp +++

+:
	or a
	jr nz, +
	ld a, $0F
	ld (bc), a
	jr ++

+:
	inc bc
	push hl
	add a, a
	ld e, a
	ld d, $00
	ld hl, $B87B
	add hl, de
	ld e, (hl)
	ld a, e
	and $3F
	inc hl
	ld d, (hl)
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	and $0F
	ld (bc), a
	inc bc
	ld a, d
	ld (bc), a
	pop hl
++:
	ld (ix+4), l
	ld (ix+5), h
+++:
	ld l, (ix+6)
	ld h, (ix+7)
	ld a, (hl)
	cp $FF
	jr nz, +
	inc a
	ld (ix+8), a
	ld a, ($D96B)
	ld c, a
	ld a, ($D97C)
	or c
	ret nz
	ld a, $FF
	out ($7E), a
	ld a, $E0
	out ($7E), a
	xor a
	out ($7E), a
	ret

+:
	inc hl
	or a
	jr z, +
	ex af, af'
	ld a, ($D958)
	or $F0
	out ($7E), a
	ld a, $E3
	out ($7E), a
	ex af, af'
	out ($7E), a
	ld a, $01
	ld (ix+8), a
+:
	ld (ix+6), l
	ld (ix+7), h
	ret

; Data from 2B87B to 2BFFF (1925 bytes)
.incbin "Micro Machines_2b87b.inc"

.BANK 11
.ORG $0000

; Data from 2C000 to 2FFFF (16384 bytes)
.incbin "Micro Machines_2c000.inc"

.BANK 12
.ORG $0000

; Data from 30000 to 33FFF (16384 bytes)
.incbin "Micro Machines_30000.inc"

.BANK 13
.ORG $0000

; Data from 34000 to 36D51 (11602 bytes)
.incbin "Micro Machines_34000.inc"

_LABEL_36D52_:
	call _LABEL_36DFF_
	ld d, $00
	ld a, ($DF6F)
	sla a
	sla a
	sla a
	ld hl, $ADAF
	ld e, a
	add hl, de
	ld de, $5162
	call _LABEL_36D94_
	ld d, $00
	ld a, ($DF70)
	sla a
	sla a
	sla a
	ld hl, $ADAF
	ld e, a
	add hl, de
	ld de, $5302
	call _LABEL_36D94_
	ld d, $00
	ld a, ($DF71)
	sla a
	sla a
	sla a
	ld hl, $ADAF
	ld e, a
	add hl, de
	ld de, $5D02
_LABEL_36D94_:
	ld bc, $0008
-:
	ld a, e
	out ($BF), a
	ld a, d
	out ($BF), a
	ld a, (hl)
	out ($BE), a
	dec bc
	inc hl
	ld a, e
	add a, $04
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, b
	or c
	jr nz, -
	ret

; Data from 36DAF to 36DFE (80 bytes)
.db $00 $00 $1C $36 $36 $36 $1C $00 $00 $00 $0C $1C $0C $0C $1E $00
.db $00 $00 $1C $36 $0C $18 $3E $00 $00 $00 $3C $06 $1C $06 $3C $00
.db $00 $00 $36 $36 $1E $06 $06 $00 $00 $00 $3E $30 $3C $06 $3C $00
.db $00 $00 $1C $30 $3C $36 $1C $00 $00 $00 $3E $06 $0C $18 $18 $00
.db $00 $00 $1C $36 $1C $36 $1C $00 $00 $00 $1C $36 $1E $06 $3C $00

_LABEL_36DFF_:
	ld a, ($D599)
	or a
	jr nz, _LABEL_36E6A_
	ld a, ($DF65)
	cp $01
	jr z, _LABEL_36E6A_
	ld a, ($DE4F)
	cp $80
	jr nz, _LABEL_36E6A_
	ld a, ($DF72)
	add a, $01
	ld ($DF72), a
	cp $0A
	jr nz, _LABEL_36E6A_
	ld a, $00
	ld ($DF72), a
	ld a, ($DF71)
	sub $01
	ld ($DF71), a
	cp $FF
	jr nz, _LABEL_36E6A_
	ld a, $09
	ld ($DF71), a
	ld a, ($DF70)
	sub $01
	ld ($DF70), a
	cp $FF
	jr nz, _LABEL_36E6A_
	ld a, $09
	ld ($DF70), a
	ld a, ($DF6F)
	sub $01
	ld ($DF6F), a
	cp $FF
	jr nz, _LABEL_36E6A_
	ld a, $01
	ld ($DF65), a
	ld ($DF8C), a
	ld a, $F0
	ld ($DF6A), a
	ld a, $00
	ld ($DF6F), a
	ld ($DF70), a
	ld ($DF71), a
_LABEL_36E6A_:
	ret

; Data from 36E6B to 37291 (1063 bytes)
.incbin "Micro Machines_36e6b.inc"

_LABEL_37292_:
	ld a, ($DE92)
	sla a
	ld e, a
	ld d, $00
	ld hl, $B272
	add hl, de
	ld a, (hl)
	ld ($D58A), a
	inc hl
	ld a, (hl)
	ld ($D58B), a
	ld l, a
	ld bc, $0010
	ld hl, ($D58A)
	or a
	sbc hl, bc
	ld ($D58A), hl
	ld a, ($D58B)
	ld l, a
	ld a, ($DF00)
	or a
	jr nz, ++
	ld a, ($D95C)
	cp l
	jr z, +
	jr c, _LABEL_372D3_
-:
	ld de, $0004
	ld hl, ($D95B)
	or a
	sbc hl, de
	ld ($D95B), hl
	ret

_LABEL_372D3_:
	ld hl, ($D95B)
	ld de, $0002
	add hl, de
	ld ($D95B), hl
	ret

+:
	ld a, ($D58A)
	ld l, a
	ld a, ($D95B)
	cp l
	jr z, +
	jr c, _LABEL_372D3_
	jp -

+:
	ret

++:
	ld a, ($D95C)
	cp $01
	jr z, +
--:
	ld de, $0004
	ld hl, ($D95B)
	or a
	sbc hl, de
	ld ($D95B), hl
-:
	ret

+:
	ld a, ($D95B)
	cp $90
	jr c, -
	jp --

_LABEL_3730C_:
	ld a, ($DC3D)
	or a
	jr z, +
	ld a, ($D96F)
	ld ($D595), a
	jp _LABEL_37408_

+:
	xor a
	ld ($D594), a
	ld ($D595), a
	ld ($D596), a
	ld a, ($DBA0)
	ld l, a
	ld a, ($DE79)
	add a, l
	sub $05
	jr nc, +
	xor a
+:
	ld ($D592), a
	ld a, ($DBA2)
	ld l, a
	ld a, ($DE7B)
	add a, l
	sub $05
	jr nc, +
	xor a
+:
	ld ($D593), a
	ld l, a
	ld a, ($DCB0)
	sub l
	jr c, +
	cp $0A
	jr nc, +
	ld e, a
	ld d, $00
	ld hl, $B51E
	add hl, de
	ld a, ($D592)
	ld c, a
	ld a, ($DCAF)
	sub c
	jr c, +
	cp $0A
	jr nc, +
	ld e, a
	ld a, (hl)
	add a, e
	ld e, a
	ld d, $00
	ld hl, $B4A5
	add hl, de
	ld a, (hl)
	ld ($D594), a
+:
	ld a, ($D593)
	ld l, a
	ld a, ($DCF1)
	sub l
	jr c, +
	cp $0A
	jr nc, +
	ld e, a
	ld d, $00
	ld hl, $B51E
	add hl, de
	ld a, ($D592)
	ld c, a
	ld a, ($DCF0)
	sub c
	jr c, +
	cp $0A
	jr nc, +
	ld e, a
	ld a, (hl)
	add a, e
	ld e, a
	ld d, $00
	ld hl, $B4A5
	add hl, de
	ld a, (hl)
	ld ($D595), a
+:
	ld a, ($D593)
	ld l, a
	ld a, ($DD32)
	sub l
	jr c, +
	cp $0A
	jr nc, +
	ld e, a
	ld d, $00
	ld hl, $B51E
	add hl, de
	ld a, ($D592)
	ld c, a
	ld a, ($DD31)
	sub c
	jr c, +
	cp $0A
	jr nc, +
	ld e, a
	ld a, (hl)
	add a, e
	ld e, a
	ld d, $00
	ld hl, $B4A5
	add hl, de
	ld a, (hl)
	ld ($D596), a
+:
	ld a, ($D594)
	ld l, a
	ld a, ($D595)
	cp l
	jr nc, +
	ld a, ($D596)
	cp l
	jr nc, _LABEL_373F3_
	ld a, ($DCBF)
	ld b, a
	ld a, ($DCB6)
	ex af, af'
	ld a, ($D594)
	jp ++

_LABEL_373F3_:
	ld a, ($DD41)
	ld b, a
	ld a, ($DD38)
	ex af, af'
	ld a, ($D596)
	jp ++

+:
	ld l, a
	ld a, ($D596)
	cp l
	jr nc, _LABEL_373F3_
_LABEL_37408_:
	ld a, ($DD00)
	ld b, a
	ld a, ($DCF7)
	ex af, af'
	ld a, ($D595)
++:
	ld ($D597), a
	or a
	jr z, +++
	ld l, a
	ld a, ($D96F)
	cp l
	jr z, ++
	jr nc, +
	inc a
	ld ($D96F), a
	jp ++

+:
	dec a
	ld ($D96F), a
++:
	ex af, af'
	sla a
	ld e, a
	ld d, $00
	ld hl, $B272
	add hl, de
	ld a, (hl)
	ld ($D58E), a
	inc hl
	ld a, (hl)
	ld ($D58F), a
	jp ++++

+++:
	ex af, af'
	xor a
	ld ($D96F), a
	ret

++++:
	ld a, b
	or a
	jr nz, ++
	ld a, ($D58F)
	ld l, a
	ld a, ($D96D)
	cp l
	jr z, +
	jr c, _LABEL_37466_
-:
	ld de, $0004
	ld hl, ($D96C)
	or a
	sbc hl, de
	ld ($D96C), hl
	ret

_LABEL_37466_:
	ld hl, ($D96C)
	ld de, $0002
	add hl, de
	ld ($D96C), hl
	ret

+:
	ld a, ($D58E)
	ld l, a
	ld a, ($D96C)
	cp l
	jr z, +
	jr c, _LABEL_37466_
	jp -

+:
	ret

++:
	ld a, ($DF7F)
	or a
	jr nz, _LABEL_3749A_
	ld a, ($D96D)
	cp $01
	jr z, +
-:
	ld de, $0004
	ld hl, ($D96C)
	or a
	sbc hl, de
	ld ($D96C), hl
_LABEL_3749A_:
	ret

+:
	ld a, ($D96C)
	cp $90
	jr c, _LABEL_3749A_
	jp -

; Data from 374A5 to 37FFF (2907 bytes)
.incbin "Micro Machines_374a5.inc"

.BANK 14
.ORG $0000

; Data from 38000 to 3BFFF (16384 bytes)
.incbin "Micro Machines_38000.inc"

.BANK 15
.ORG $0000

; Data from 3C000 to 3FFFF (16384 bytes)
.incbin "Micro Machines_3c000.inc"

