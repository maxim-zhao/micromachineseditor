.macro VDPRegisterWriteToHL args index, value
  ld hl, VDP_REGISTER_WRITE_MASK | (index << 8) | value
.endm

.macro SetVDPRegisterImmediate args index, value
  .if value == 0
  xor a
  .else
  ld a, value
  .endif
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_WRITE_MASK >> 8 | index
  out (PORT_VDP_REGISTER), a
.endm

.macro TilemapWriteAddressToHL args x, y
  ld hl, VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TilemapWriteAddressToDE args x, y
  ld de, VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TilemapWriteAddressToBC args x, y
  ld bc, VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TilemapWriteAddressData args x, y
.dw VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TileWriteAddressToHL args index
  ld hl, VRAM_WRITE_MASK | (index * 32)
.endm

.macro TileWriteAddressToDE args index
  ld de, VRAM_WRITE_MASK | (index * 32)
.endm

.macro TileWriteAddressData args index
.dw VRAM_WRITE_MASK | (index * 32)
.endm

.macro SetVDPAddressImmediate args address
  ld a, <address
  out (PORT_VDP_ADDRESS), a
  ld a, >address
  out (PORT_VDP_ADDRESS), a
.endm

.macro SetPaletteAddressImmediateSMS args index
  SetVDPAddressImmediate index | PALETTE_WRITE_MASK
.endm

.macro SetPaletteAddressImmediateGG args index
  SetVDPAddressImmediate index*2 | PALETTE_WRITE_MASK
.endm

.macro PaletteAddressToHLSMS args index
  ld hl, index | PALETTE_WRITE_MASK
.endm

.macro PaletteAddressToHLGG args index
  ld hl, (index * 2) | PALETTE_WRITE_MASK
.endm

.macro SetTileAddressImmediate args index
  SetVDPAddressImmediate index*TILE_DATA_SIZE | VRAM_WRITE_MASK
.endm

.macro SetTilemapAddressImmediate args x, y
  SetVDPAddressImmediate VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro EmitDataToVDPImmediate8 args data
  ld a, \1
  out (PORT_VDP_DATA), a
.endm

.macro EmitDataToVDPImmediate16 args data
  EmitDataToVDPImmediate8 <\1
  EmitDataToVDPImmediate8 >\1
.endm

.macro EmitSMSColourImmediate args hex
  EmitDataToVDPImmediate8 ((hex >> 22) & %000011) | ((hex >> 12) & %001100) | ((hex >> 2) & %110000)
.endm

.macro EmitGGColourImmediate args hex
  EmitDataToVDPImmediate16 ((hex >> 20) & %000001111) | ((hex >> 8) & %001111000) | ((hex << 4) & %111100000000)
.endm
