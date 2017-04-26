.define PORT_VDP_STATUS $bf
.define PORT_VDP_REGISTER $bf
.define PORT_VDP_ADDRESS $bf
.define PORT_VDP_DATA $be
.define PORT_VDP_LINECOUNTER $7e
.define PORT_PSG $7e
.define PORT_CONTROL_A $dc
.define PORT_CONTROL_B $dd
.define PORT_GG_START $00 ; also region
.define PORT_GG_SERIAL_DATA $01
.define PORT_GG_SERIAL_DIRECTION $02
.define PORT_GG_LinkSend $03
.define PORT_GG_LinkReceive $04
.define PORT_GG_LinkStatus $05

.enum $80 ; VDP registers
VDP_REGISTER_MODECONTROL1 db
VDP_REGISTER_MODECONTROL2 db
VDP_REGISTER_NAMETABLEBASEADDRESS db
VDP_REGISTER_UNUSED3 db
VDP_REGISTER_UNUSED4 db
VDP_REGISTER_SPRITETABLEBASEADDRESS db
VDP_REGISTER_SPRITESET db
VDP_REGISTER_BACKDROP_COLOUR db
VDP_REGISTER_XSCROLL db
VDP_REGISTER_YSCROLL db
VDP_REGISTER_LINEINTERRUPTCOUNTER db
.ende

; Values for VDP registers
.define VDP_REGISTER_SPRITESET_LOW  0<<2
.define VDP_REGISTER_SPRITESET_HIGH 1<<2

; Control port masks
.define PORT_CONTROL_A_PLAYER1_MASK %00111111
.define PORT_GG_START_MASK %10000000

; Codemasters mapper
.define PAGING_REGISTER_Slot0 $0000
.define PAGING_REGISTER_Slot1 $4000
.define PAGING_REGISTER_Slot2 $8000
.define PAGING_REGISTER PAGING_REGISTER_Slot2

.macro SMSCOLOUR args hex
; %rr------gg------bb------
;              -> %00bbggrr
.db ((hex >> 22) & %000011) | ((hex >> 12) & %001100) | ((hex >> 2) & %110000)
.endm

.macro GGCOLOUR args hex
; %rrrr----gggg----bbbb----
;          -> %bbbbggggrrrr
.dw ((hex >> 20) & %000001111) | ((hex >> 8) & %11110000) | ((hex << 4) & %111100000000)
.endm

.define VRAM_WRITE_MASK $4000
.define VDP_REGISTER_WRITE_MASK $8000
.define PALETTE_WRITE_MASK $c000
.define NAME_TABLE_ADDRESS $3700 ; Extended height mode!
.define SPRITE_TABLE_ADDRESS $3f00

.define TILE_DATA_SIZE 8*8*4/8 ; 8x8 pixels at 4bpp
.define TILEMAP_ENTRY_SIZE 2
.define TILEMAP_WIDTH 32
.define TILEMAP_HEIGHT 28
.define TILEMAP_ROW_SIZE TILEMAP_WIDTH * TILEMAP_ENTRY_SIZE
.define TILEMAP_SIZE TILEMAP_ROW_SIZE * TILEMAP_HEIGHT

.define TILEMAP_HFLIP 1<<9
.define TILEMAP_VFLIP 1<<10
