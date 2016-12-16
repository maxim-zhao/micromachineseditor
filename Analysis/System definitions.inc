.define PORT_VDP_STATUS $bf
.define PORT_VDP_REGISTER $bf
.define PORT_VDP_ADDRESS $bf
.define PORT_VDP_DATA $be
.define PORT_VDP_LINECOUNTER $7e
.define PORT_PSG $7e

.enum $80 ; VDP registers
VDP_REGISTER_MODECONTROL1 db
VDP_REGISTER_MODECONTROL2 db
VDP_REGISTER_NAMETABLEBASEADDRESS db
VDP_REGISTER_UNUSED3 db
VDP_REGISTER_UNUSED4 db
VDP_REGISTER_SPRITETABLEBASEADDRESS db
VDP_REGISTER_UNUSED6 db
VDP_REGISTER_BACKDROP_COLOUR db
VDP_REGISTER_XSCROLL db
VDP_REGISTER_YSCROLL db
VDP_REGISTER_LINEINTERRUPTCOUNTER db
.ende

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
; %rrr-----ggg-----bbb-----
;          -> %0bbb0ggg0rrr
.dw ((hex >> 21) & %000000111) | ((hex >> 9) & %000111000) | ((hex << 3) & %111000000)
.endm
