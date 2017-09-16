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

.define PALETTE_ENTRY_SIZE_SMS 1
.define PALETTE_ENTRY_SIZE_GG 2

.define VRAM_WRITE_MASK $4000
.define VDP_REGISTER_WRITE_MASK $8000
.define PALETTE_WRITE_MASK $c000

.define TILE_HEIGHT 8
.define TILE_WIDTH 8
.define BYTES_PER_ROW TILE_WIDTH * 4 / 8 ; 4 bits per pixel
.define TILE_DATA_SIZE TILE_HEIGHT*BYTES_PER_ROW
.define TILEMAP_ENTRY_SIZE 2
.define TILEMAP_WIDTH 32
.define TILEMAP_HEIGHT 28
.define TILEMAP_ROW_SIZE TILEMAP_WIDTH * TILEMAP_ENTRY_SIZE
.define TILEMAP_SIZE TILEMAP_ROW_SIZE * TILEMAP_HEIGHT

; ---psvhn nnnnnnnn
.define TILEMAP_FLAG_HFLIP 1<<9
.define TILEMAP_FLAG_VFLIP 1<<10
.define TILEMAP_FLAG_SPRITE_PALETTE 1<<11
.define TILEMAP_FLAG_PRIORITY 1<<12

; SN76489 notes, assuming NTSC timings
.macro PSGNote args index
; index = 0.. where 0 = A2
; frequency = 2^(index / 12 - 2) * 440
; PSG half-wavelength = 3579545 / 16 / frequency / 2
; We add 0.5 so the truncation to int rounds to the nearest
.dw 3579545 / 16 / (2^(index / 12 - 2)) / 440 / 2 + 0.5
.endm

.macro PSGNotes args startIndex, count
.define x startIndex
.repeat count
  PSGNote x
  .redefine x x+1
.endr
.undefine x
.endm

.define PSG_TONE_CONTROL_MASK         %10000000
.define PSG_ATTENUATION_CONTROL_MASK  %10010000
.define PSG_CHANNEL_SHIFT 5 ; channel is shifted left 5
.define PSG_TONE_LO_MASK              %00001111
.define PSG_TONE_HI_MASK              %00111111
.define PSG_NOISE_MODE_MASK           %00000111
.define PSG_ATTENUATION_MASK          %00001111
.define PSG_ATTENUATION_SILENCE       %00001111

.enum 0
  PSG_NOISE_PERIODIC_SLOWEST db ; 0 -> freq 0x10
  PSG_NOISE_PERIODIC_SLOW    db ; 1 -> freq 0x20
  PSG_NOISE_PERIODIC_FAST    db ; 2 -> freq 0x40
  PSG_NOISE_PERIODIC_TONE2   db ; 3 -> freq from tone2
  PSG_NOISE_SLOW             db ; 4 -> freq 0x10
  PSG_NOISE_MEDIUM           db ; 5 -> freq 0x20
  PSG_NOISE_FAST             db ; 6 -> freq 0x40
  PSG_NOISE_TONE2            db ; 7 -> freq from tone2
.ende

.enum 0
  PSG_CHANNEL_TONE0 db ; 0
  PSG_CHANNEL_TONE1 db ; 1
  PSG_CHANNEL_TONE2 db ; 2
  PSG_CHANNEL_NOISE db ; 3
.ende

.macro SetPSGAttenuationImmediate args channel, attenuation
  ld a, PSG_ATTENUATION_CONTROL_MASK | (channel << PSG_CHANNEL_SHIFT) | ((attenuation & PSG_ATTENUATION_MASK) ~ PSG_ATTENUATION_MASK)
  out (PORT_PSG), a
.endm

.macro SetPSGNoiseImmediate args type
  ld a, PSG_TONE_CONTROL_MASK | (PSG_CHANNEL_NOISE << PSG_CHANNEL_SHIFT) | type
  out (PORT_PSG), a
.endm
