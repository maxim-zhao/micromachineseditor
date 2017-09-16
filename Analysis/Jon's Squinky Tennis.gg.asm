; Compilation options, disable all to be original
;.define COMPILE_TO_ROM ; comment to compile to $c000+
;.define FORCE_GAMEPLAY
;.define PLAYER2_WALL
;
; Game constants
.define WINNING_SCORE 15
.define BAT_MIN_Y $17
.define BAT_MAX_Y $98
.define BALL_START_X_PLAYER1 $38
.define BALL_START_X_PLAYER2 $BA
.define BALL_MIN_X $30
.define BALL_PADDLEHIT_X_PLAYER1 $38
.define BALL_PADDLEHIT_X_PLAYER2 $c6
.define BALL_MAX_X $c8
.define BALL_MIN_Y $18
.define BALL_MAX_Y $A0

.ifdef COMPILE_TO_ROM
.memorymap
  slotsize $2000
  slot 0 $0000
  defaultslot 0
.endme
.rombankmap
  bankstotal 1
  banksize $2000
  banks 1
.endro
.sdsctag 1.0, "Jon's Squinky Tennis", "Extracted from Micro Machines (SMS)", "Jon the Programmer, Maxim"
.else
.memorymap
  slotsize 5923
  slot 0 $c000
  defaultslot 0
.endme
.rombankmap
  bankstotal 1
  banksize 5923
  banks 1
.endro
.endif

.struct YStruct
  y db
.endst
.struct XNStruct
  x db
  n db
.endst
.struct SpriteTable
  ys instanceof YStruct 64
  xns instanceof XNStruct 64
.endst

; RAM stuff here
; It was probably originally done as labels but we avoid that here

.enum $d653 export
RAM_IAmPlayer1 db ; $ff for true, $00 for false
RAM_ButtonsPressed db ; Active low, 000021DU
RAM_OtherPlayerButtonsPressed db ; Same as RAM_ButtonsPressed
RAM_ db ; Unused
RAM_VRAMAddress dw ; Used while drawing the tilemap
RAM_Score_Player1 db
RAM_Score_Player2 db
RAM_BatY_Player1 db
RAM_BatY_Player2 db
RAM_PaddleSpeed_Player1 db
RAM_PaddleSpeed_Player2 db
RAM_BallX db
RAM_BallY db
RAM_BallXSpeed db ; Always -2 or +2
RAM_BallYSpeed db ; Always -2, -1, +1 or +2
RAM_SpriteTable instanceof SpriteTable
.ende

; Tile indices
.enum $00
  Tiles_ASCII   dsb 64
  Tile_Bat      dw
  Tile_Ball     dw
  Tile_Digits   dsw 10
  Tile_White    dsb 8
  Tile_Top      db
  Tile_LineTop1 db
  Tile_LineTop2 db
  Tile_Line     db
.ende

; Sprite indexes
.enum 0
  Sprite_Player1Bat             db
  Sprite_Player2Bat             db
  Sprite_Ball                   db
  Sprite_Player1Score_Main      db ; "Main" sprites are used for 1-dgit scores
  Sprite_Player2Score_Main      db
  Sprite_Player1Score_Secondary db ; "Secondary" sprites are used for 2-digit scores.
  Sprite_Player2Score_Secondary db ; The tens digit is then the secondary for player 1, main for player 2.
.ende

; Macros for manipulating the sprites
.macro GetSpriteX args index
  ld a, (RAM_SpriteTable + 64 + index * 2)
.endm
.macro SetSpriteX args index
  ld (RAM_SpriteTable + 64 + index * 2), a
.endm
.macro GetSpriteY args index
  ld a, (RAM_SpriteTable + index)
.endm
.macro SetSpriteY args index
  ld (RAM_SpriteTable + index), a
.endm
.macro SetSpriteN args index
  ld (RAM_SpriteTable + 64 + index * 2 + 1), a
.endm

; A macro for drawing text to the screen
.macro DrawText args x, y, pointer
  TilemapWriteAddressToHL x, y
  call SetVRAMAddress
  ld hl, pointer
  call EmitASCII
.endm


.redefine NAME_TABLE_ADDRESS $3800 ; Not extended height mode!
.define SPRITE_TABLE_ADDRESS $3f00
.include "System definitions.inc"

.include "VDP macros.inc"

.bank 0 slot 0
.org $0000
    call InitialiseVDP
    call InitialiseSprites
    call LoadPalette
    call LoadTiles
        
    ; Draw title screen text
    DrawText 6,  4, Text_JonTheProgrammers
    DrawText 6,  5, Text_SquinkyTennis
    DrawText 6, 20, Text_ItsLinkTastic
    DrawText 6, 14, Text_ConnectOtherGear
    
    call CheckIfIAmPlayer1
    call ScreenOn
    
    ; Wait for start button
-:  in a, (PORT_GG_START)
    add a, a
    jr nc, -

ReadyToStartGame:
    ld a, (RAM_IAmPlayer1)
    and a
    jp z, ReadyToStartGame_Player2

_ReadyToStartGame_Player1
    ; I am player 1
    call InitialiseSprites
    call WaitForLine208
    DrawText 6, 12, Text_IAmPlayer1

.ifndef FORCE_GAMEPLAY
    ; Wait for the other end to send ---1--01 which we receive as --1-01--
-:  in a, (PORT_GG_SERIAL_DATA)
    and RECEIVED_BITS_MASK
    cp  %00100100 ; $24 ; Sent was ---1--01
    jr nz, -
.endif

    call WaitForLine208
    DrawText 6, 14, Text_PressStartToPlay

    ; Wait for Start
-:  in a, (PORT_GG_START)
    add a, a
    jr c, -

    call SyncSerialConnection
    call WaitForLine208    
    DrawText 6, 14, Text_Pl1StartsGame

    call SyncSerialConnection
    call PlayGame

    ld a, (RAM_Score_Player1)
    cp 15
    jr z, Win
    jr Lose

; Unreachable code
    ret

Win:
    call WaitForLine208
    DrawText 6, 8, Text_YouWin
    jp +

; Executed in RAM at c0b0
Lose:
    call WaitForLine208
    DrawText 6, 8, Text_YouLose
    ; Unnecessary jump
    jp +

+:  call WaitForLine208

    ; Draw some credits
    DrawText 6,  4, Text_JonTheProgrammers
    DrawText 6,  5, Text_SquinkyTennis
    DrawText 6, 18, Text_AProductionOfThe
    DrawText 6, 19, Text_BigRedSoftwareCo

    jp ReadyToStartGame

ReadyToStartGame_Player2:
    ; I am player 2
    call InitialiseSprites
    call SendPlayer2Ready
    call WaitForLine208
    
    DrawText 6, 12, Text_IAmPlayer2
    DrawText 6, 14, Text_Pl1IsInControl

    call SyncSerialConnection
    call WaitForLine208
    
    DrawText 6, 14, Text_Pl1StartsGame

    call SyncSerialConnection
    call PlayGame
    ld a, (RAM_Score_Player2)
    cp 15
    jp z, Win
    jp Lose

; Unreachable code
    ret

PlayGame:
    call ScreenOff
    call LoadCourtTilemap
    call ScreenOn

    ; Zero scores
    xor a
    ld (RAM_Score_Player1), a
    ld (RAM_Score_Player2), a

    ld a, $60
    ld (RAM_BatY_Player1), a
    ld (RAM_BatY_Player2), a
    ld (RAM_BallY), a

    ; Set up sprites and game state
    ; Bats
    ld a, $30
    SetSpriteX Sprite_Player1Bat
    add a, $08
    SetSpriteN Sprite_Player2Bat ; Mistake, overwritten shortly
    ld (RAM_BallX), a
    ld a, $C2
    SetSpriteX Sprite_Player2Bat
    ld a, Tile_Bat
    SetSpriteN Sprite_Player1Bat
    SetSpriteN Sprite_Player2Bat
    ; Ball
    add a, Tile_Ball - Tile_Bat ; Could just ld a, Tile_Bat
    SetSpriteN Sprite_Ball
    ld a, -1
    ld (RAM_BallYSpeed), a
    ld a, +2
    ld (RAM_BallXSpeed), a
    ld a, $74
    SetSpriteX Sprite_Player1Score_Main
    ld a, $84
    SetSpriteX Sprite_Player2Score_Main
    ld a, $20
    SetSpriteY Sprite_Player1Score_Main
    SetSpriteY Sprite_Player2Score_Main
    
    call SyncSerialConnection
    ; Fall through

MainLoop:
    call MoveBall
    call CheckForPaddleHit
    ; Update sprite table from bat/ball positions
    ld a, (RAM_BatY_Player1)
    SetSpriteY Sprite_Player1Bat
    ld a, (RAM_BatY_Player2)
    SetSpriteY Sprite_Player2Bat
    ld a, (RAM_BallY)
    SetSpriteY Sprite_Ball
    ld a, (RAM_BallX)
    SetSpriteX Sprite_Ball

    ; Update score sprites
    ; Player 1  - right aligned
    ld a, (RAM_Score_Player1)
    cp 10
    jr c, +
    ; Two digit score
    ; Draw a 1 in the secondary sprite
    ld a, Tile_Digits + 2 ; Digit 1
    SetSpriteN Sprite_Player1Score_Secondary
    GetSpriteX Sprite_Player1Score_Main
    sub $08 ; Secondary sprite is 8px to the left
    SetSpriteX Sprite_Player1Score_Secondary
    GetSpriteY Sprite_Player1Score_Main ; is a constant anyway...
    SetSpriteY Sprite_Player1Score_Secondary
    ; Then the remainder in the main sprite
    ld a, (RAM_Score_Player1)
    sub 10
+:  add a, a
    add a, Tile_Digits
    SetSpriteN Sprite_Player1Score_Main

    ; Player 2 - left aligned
    ld a, (RAM_Score_Player2)
    cp 10
    jr c, +
    ; Two digit score
    ; Draw the remainder in the secondary sprite
    sub 10
    add a, a
    add a, Tile_Digits
    SetSpriteN Sprite_Player2Score_Secondary
    GetSpriteX Sprite_Player2Score_Main
    add a, $08 ; Secondary sprite is 8px to the right
    SetSpriteX Sprite_Player2Score_Secondary
    GetSpriteY Sprite_Player2Score_Main
    SetSpriteY Sprite_Player2Score_Secondary
    ld a, $01 ; Draw a 1 in the main sprite
+:  add a, a
    add a, Tile_Digits
    SetSpriteN Sprite_Player2Score_Main
    
    ; Then upload the sprite table
    call WaitForLine208
    ld hl, SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK
    call SetVRAMAddress
    ld hl, RAM_SpriteTable.ys
    ld bc, 64 << 8 | PORT_VDP_DATA
    otir
    ld hl, SPRITE_TABLE_ADDRESS + $80 | VRAM_WRITE_MASK
    call SetVRAMAddress
    ld hl, RAM_SpriteTable.xns
    ld bc, (64 * 2) << 8 | PORT_VDP_DATA
    otir
    
    ; Check for a win
    ; This loop only ends when someone wins...
    ld a, (RAM_Score_Player1)
    cp WINNING_SCORE
    ret z
    ld a, (RAM_Score_Player2)
    cp WINNING_SCORE
    ret z
    
    ; Not a winning score
    ; Get inputs
    in a, (PORT_CONTROL_A)
    and %00110011 ; U, D, 1, 2
    ; Compress them together in the low 4 bits
    ld b, a
    and %00000011
    sra b 
    sra b
    or b
    ; Save to RAM
    ld (RAM_ButtonsPressed), a
    ; Update other player
    call ExchangeControlsData
    
    ; Invert player 1 flag temporarily so code operates on the "other player's" bat
    ld a, (RAM_IAmPlayer1)
    cpl
    ld (RAM_IAmPlayer1), a
    
      ; Process other player's buttons into paddle movement
      ld a, (RAM_OtherPlayerButtonsPressed)
      ld b, a
      call _GetPaddleSpeed
      bit 0, b ; Check U/D bits
      call z, MoveBatUp
      bit 1, b
      call z, MoveBatDown
      
    ; Restore player 1 flag
    ld a, (RAM_IAmPlayer1)
    cpl
    ld (RAM_IAmPlayer1), a

    ; Repeat for this player
    ld a, (RAM_ButtonsPressed)
    ld b, a
    call _GetPaddleSpeed
    bit 0, b ; Check U/D bits
    call z, MoveBatUp
    bit 1, b
    call z, MoveBatDown
    
    ; All done
    jp MainLoop

_GetPaddleSpeed:
    ld hl, RAM_PaddleSpeed_Player1
    ld a, (RAM_IAmPlayer1)
    and a
    jr nz, +
    inc l ; Point to RAM_PaddleSpeed_Player2
+:  ld a, b
    and %00001100 ; Buttons 1 and 2
    jr z, ++      ; Both buttons held ->  normal speed
    cp %00001100
    jr z, ++      ; No buttons held -> normal speed
    cp %00001000
    jr z, +       ; Button 2 held -> fast
    ld a, 1    ; Else it is button 1 held, slow
    ld (hl), a
    ; Note that the value is never read back, the game processes it from register a
    ret

+:  ld a, 4
    ld (hl), a
    ret

++: ld a, 2
    ld (hl), a
    ret

MoveBatUp:
    ; Get bat Y position
    ld hl, RAM_BatY_Player1
    ld a, (RAM_IAmPlayer1)
    and a
    jr nz, +
    inc l
+:  ; Read from two bytes further on (paddle speed)
    ld d, h
    ld e, l
    inc de
    inc de
    ld a, (de)
-:  ; Decrement Y position by that many pixels (could subtract?)
    dec (hl)
    dec a
    jr nz, -
    ; Apply a minimum
    ld a, (hl)
    cp BAT_MIN_Y
    ret nc
    ld a, BAT_MIN_Y
    ld (hl), a
    ret

MoveBatDown:
    ; Get bay Y position
    ld hl, RAM_BatY_Player1
    ld a, (RAM_IAmPlayer1)
    and a
    jr nz, +
    inc l
+:  ; Read from two bytes further on (paddle speed)
    ld d, h
    ld e, l
    inc de
    inc de
    ld a, (de)
-:  ; Increment Y position by that many pixels (could add?)
    inc (hl)
    dec a
    jr nz, -
    ; Apply a maximum
    ld a, (hl)
    cp BAT_MAX_Y
    ret c
    ld a, BAT_MAX_Y
    ld (hl), a
    ret
    
MoveBall:
    ; Add the X speed
    ld hl, RAM_BallXSpeed
    ld b, (hl)
    ld a, (RAM_BallX)
    add a, b
    ld (RAM_BallX), a
    cp BALL_MAX_X
    call z, ++
    cp BALL_MIN_X
    call z, +++
    ; Add the Y speed
    ld hl, RAM_BallYSpeed
    ld b, (hl)
    ld a, (RAM_BallY)
    add a, b
    ld (RAM_BallY), a
    cp BALL_MAX_Y
    jp c, +
    ; Reached max Y, if the ball going down then bounce it
    bit 7, b
    jp z, NegateSpeed
    ret

+:  cp BALL_MIN_Y
    ret nc
    ; Reached min Y, if the ball is going up then bounce it
    bit 7, b
    jp nz, NegateSpeed
    ret

++: ; Ball reached the right, player 1 gets a point
    ld a, (RAM_Score_Player1)
    inc a
    ld (RAM_Score_Player1), a
    ld a, BALL_START_X_PLAYER1 ; $38
    ld (RAM_BallX), a
    ret

+++:; Ball reached the left, player 2 gets a point
    ld a, (RAM_Score_Player2)
    inc a
    ld (RAM_Score_Player2), a
    ld a, BALL_START_X_PLAYER2 ; $BA
    ld (RAM_BallX), a
    ret

CheckForPaddleHit:
    ld hl, RAM_BallXSpeed
    ld a, (RAM_BallX)
    cp BALL_PADDLEHIT_X_PLAYER1
    jr z, +
    cp BALL_PADDLEHIT_X_PLAYER2
    jr z, ++
    ret

    ; Ball hit thresholds are:
    ; dy = BatY - BallY
    ; dy + 14 >= 20: miss
    ; dy + 14 <   0: Miss (negative treated as unsigned -> looks like way more than 20)
    ; dy + 14 <   7: hit, y speed = 2
    ; dy + 14 >= 13: hit, y speed = -2
    ; else: hit, y speed halved if not +/-1
    ; So:
    ; dy range    Effect
    ;     .. -15  Miss (below bat)
    ; -14 ..  -8  Hit (bottom of bat) (7px)
    ;  -7 ..  -2  Hit (middle of bat) (5px)
    ;  -1 ..   5  Hit (top of bat)    (7px)
    ;   6 ..      Miss (above bat)
    
+:  ; Ball may be hitting the player 1 paddle
    ; Check if the ball is moving to the left
    ld a, (RAM_BallXSpeed)
    add a, a
    ret nc ; Do nothing if not
    ; Compare the ball position to the bat
    ld a, (RAM_BallY)
    ld b, a
    ld a, (RAM_BatY_Player1)
    sub b
    add a, 14 ; $0E ; Shift the number so we can discard the miss values with a single cp
    cp 20 ; $14
    ret nc ; >=20 means no hit
    jp +++

++: ; Same as above for player 2
.ifdef PLAYER2_WALL
    ; Always bounce the ball
    jr NegateSpeed
.else
    ; Check if the ball is moving to the right this time
    ld a, (RAM_BallXSpeed)
    add a, a
    ret c ; Do nothing if not
    ; Compare the ball position to the bat
    ld a, (RAM_BallY)
    ld b, a
    ld a, (RAM_BatY_Player2)
    ; (Could have made the common code start here...)
    sub b
    add a, 14 ; $0E
    cp 20 ; $14
    ret nc
    ; Unnecessary jump
    jp +++
.endif

+++:cp 7
    jr nc, +
    ld a, +2
    ld (RAM_BallYSpeed), a
    jr NegateSpeed

+:  cp 13
    jr c, +
    ld a, -2
    ld (RAM_BallYSpeed), a
    jr NegateSpeed

+:  ld a, (RAM_BallYSpeed)
    cp +1
    jr z, NegateSpeed
    cp -1
    jr z, NegateSpeed
    sra a
    ld (RAM_BallYSpeed), a
    ; fall through

NegateSpeed:
    ; hl points to the speed byte
    ld a, (hl)
    and a
    jr nz, +
    ; We increase 0 to 1 else the ball won't move
    ld a, $01
+:  neg ; And then simply negate it
    ld (hl), a
    ret

.define VDP_REGISTER_MODECONTROL2_SCREENOFF %00100010
.define VDP_REGISTER_MODECONTROL2_SCREENON  %01100010
; D7 - No effect ____________________________||||||||
; D6 - (BLK) 1= Display visible, 0= display   |||||||
;      blanked. ______________________________|||||||
; D5 - (IE0) 1= Frame interrupt enable. _______||||||
; D4 - (M1) Selects 224-line screen for Mode 4  |||||
;      if M2=1, else has no effect. ____________|||||
; D3 - (M3) Selects 240-line screen for Mode 4   ||||
;      if M2=1, else has no effect. _____________||||
; D2 - No effect _________________________________|||
; D1 - Sprites are 1=16x16,0=8x8 (TMS9918),        ||
;      Sprites are 1=8x16,0=8x8 (Mode 4) __________||
; D0 - Sprite pixels are doubled in size. __________|

ScreenOn:
    ld hl, $8100 | VDP_REGISTER_MODECONTROL2_SCREENON
    jp SetVRAMAddress

ScreenOff:
    ld hl, $8100 | VDP_REGISTER_MODECONTROL2_SCREENOFF
    jp SetVRAMAddress

LoadCourtTilemap:
    TilemapWriteAddressToHL 6, 3
    call SetVRAMAddress
    ; Save start address for row
    ld (RAM_VRAMAddress), hl
    ld c, PORT_VDP_DATA
    ; Read dimensions to de
    ld hl, Tilemap
    ld d, (hl) ; Width
    inc hl
    ld e, (hl) ; Height
    inc hl
-:  ; Byte count per row = width * 2
    ld a, d
    add a, a
    ld b, a
    otir
    ; Move VRAM pointer on to next row
    exx
      ld hl, (RAM_VRAMAddress)
      ld de, TILEMAP_ROW_SIZE
      add hl, de
      call SetVRAMAddress
      ld (RAM_VRAMAddress), hl
    exx
    ; Loop over height
    dec e
    jr nz, -
    ret

LoadTiles:
    TileWriteAddressToHL 0
    call SetVRAMAddress
    ld hl, Tiles
    ; Get tile count
    ld e, (hl)
    inc hl
-:  ; Load one tile
.repeat 32
    outi
.endr
    dec e
    jr nz, -
    ret

WaitForLine208:
-:  in a, (PORT_VDP_LINECOUNTER)
    cp $C1
    jr c, -
    cp $D0
    jr nc, -
    ret

; Executed in RAM at c40e
InitialiseVDP:
    ; Set registers
    .macro SetVDPRegister args index, value
    VDPRegisterWriteToHL index, value
    call SetVRAMAddress
    .endm

    SetVDPRegister VDP_REGISTER_MODECONTROL1            %00100100
    SetVDPRegister VDP_REGISTER_MODECONTROL2            %00000010
    SetVDPRegister VDP_REGISTER_NAMETABLEBASEADDRESS    %00001110 ; $3800
    SetVDPRegister VDP_REGISTER_UNUSED3                 $ff
    SetVDPRegister VDP_REGISTER_UNUSED4                 $ff
    SetVDPRegister VDP_REGISTER_SPRITETABLEBASEADDRESS  $7F ; $3f00
    SetVDPRegister VDP_REGISTER_SPRITESET               0 ; low tiles for sprites
    SetVDPRegister VDP_REGISTER_BACKDROP_COLOUR         $0C
    SetVDPRegister VDP_REGISTER_XSCROLL                 0 ; No scrolling
    SetVDPRegister VDP_REGISTER_YSCROLL                 0
    SetVDPRegister VDP_REGISTER_LINEINTERRUPTCOUNTER    $ff ; No line interrupts
    
    ; Blank tilemap
    TilemapWriteAddressToHL 0,0
    call SetVRAMAddress
    ld c, 25 ; row count
--: ld b, 32 ; row size
-:  xor a
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    djnz -
    dec c
    jr nz, --
    ret

; Executed in RAM at c466
InitialiseSprites:
    ; Clear RAM sprite table
    ld hl, RAM_SpriteTable
    ld de, RAM_SpriteTable + 1
    xor a
    ld (hl), a
    ld bc, 64 * 2 - 1 ; Zero Ys and XNs
    ldir
    
    ; Emit to VRAM
    ld hl, SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK
    call SetVRAMAddress
    ld hl, RAM_SpriteTable.ys
    ld bc, 64 << 8 | PORT_VDP_DATA
    otir
    
    ld hl, SPRITE_TABLE_ADDRESS + $80 | VRAM_WRITE_MASK
    call SetVRAMAddress
    ld hl, RAM_SpriteTable.xns
    ld bc, 64*2 << 8 | PORT_VDP_DATA
    otir
    ret

.define STRING_TERMINATOR $ff

EmitASCII:
    ; Get byte
-:  ld a, (hl)
    cp STRING_TERMINATOR
    ret z
    ; Convert to tile index
    sub ' '
    ; Emit it
    out (PORT_VDP_DATA), a
    xor a
    out (PORT_VDP_DATA), a
    inc hl
    jp -

LoadPalette:
    PaletteAddressToHLGG 0
    call SetVRAMAddress
    ld hl, Palette
    ld b, 16*2
    ld c, PORT_VDP_DATA
    otir
    ld hl, Palette
    ld b, 16*2
    ld c, PORT_VDP_DATA
    otir
    ret

SetVRAMAddress:
    ld a, l
    out (PORT_VDP_ADDRESS), a
    ld a, h
    out (PORT_VDP_ADDRESS), a
    ret

Palette:
  GGCOLOUR $008800 ; Dark green
  GGCOLOUR $002200 ; Shades of green (unused)
  GGCOLOUR $004400
  GGCOLOUR $006600
  GGCOLOUR $008800 ; (duplicate)
  GGCOLOUR $00CC00
  GGCOLOUR $00EE00
  GGCOLOUR $00EE00 ; (duplicate)
  GGCOLOUR $882244 ; Dark red (font shadow)
  GGCOLOUR $0088EE ; Light blue (unused)
  GGCOLOUR $0000CC ; Dark blue (unused)
  GGCOLOUR $EE8822 ; Orange (unused)
  GGCOLOUR $EE6666 ; Pale red (unused)
  GGCOLOUR $EE66EE ; Pink (unused)
  GGCOLOUR $EEEE66 ; Yellow (court dots)
  GGCOLOUR $EEEEEE ; Light grey (font, sprites)

Tiles:
.db 100 ; Tile count (too many, doesn't matter)
.incbin "Assets/Jon's Squinky Tennis/Font.4bpp" ; 64 tiles, ASCII from $20
.incbin "Assets/Jon's Squinky Tennis/Sprites.4bpp" ; 12 tiles:
; - Bat (2 tiles)
; - Ball (2 tiles)
; - Digits (2 tiles * 10)
.incbin "Assets/Jon's Squinky Tennis/Blank.4bpp"
; - All white tiles (8 tiles, unused)
.incbin "Assets/Jon's Squinky Tennis/Court.4bpp"
; - Court yellow dotted lines (4 tiles)

Tilemap:
.db $14 ; Width
.db $12 ; Height
; We define some macros so we can "draw" it in ASCII
; This is a bit ugly
.define TT Tile_Top
.define TB Tile_Top | TILEMAP_FLAG_VFLIP
.define TL Tile_Line
.define TR Tile_Line | TILEMAP_FLAG_HFLIP
.define TD Tile_LineTop1
.define TE Tile_LineTop2
.define TF Tile_LineTop1 | TILEMAP_FLAG_VFLIP
.define TG Tile_LineTop2 | TILEMAP_FLAG_VFLIP

.dw TT TT TT TT TT TT TT TT TT TD TE TT TT TT TT TT TT TT TT TT
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw  0  0  0  0  0  0  0  0  0 TL TR  0  0  0  0  0  0  0  0  0
.dw TB TB TB TB TB TB TB TB TB TF TG TB TB TB TB TB TB TB TB TB

.undefine TT TB TL TR TD TE TF TG

ExchangeControlsData:
; PORT_GG_SERIAL_DIRECTION is a direction control. 0 = send.
; Writes to PORT_GG_SERIAL_DATA are received with the bits shuffled:
; Sent:     -ABCDEFG
; Received: -ACBFGDE
; Bits are used as follows:
; A = unused (set to input)
; B = unused (set to input)
; C = send "clock"
; D = unused (set to input)
; E = unused (set to input)
; F = data
; G = data
; This allows us to maintain constant in/out controls (PORT_GG_SERIAL_DIRECTION) and 
; make use of the bit swapping to be able to receive the other side's sent bits
; withut ever needing to change it:
.define PORT_GG_SERIAL_DIRECTION_VALUE %11101100 ; Send on bits 0-1, 4
; Notes:
; - This is set all over the code even though presumably it only needs to be set once.
; - Bit B could also be used this way, to get 3 bits per transfer, but it wouldn't
;   be useful here.
.define RECEIVED_BITS_MASK %00101100 ; $2C

    ld a, (RAM_IAmPlayer1)
    and a
    jr z, +

.ifndef FORCE_GAMEPLAY
    ; I am player 1
    ; Send my up/down controls
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
    ld a, (RAM_ButtonsPressed)
    and %00000011 ; $03
    out (PORT_GG_SERIAL_DATA), a ; Once with a zero bit 4
    or %00010000 ; $10
    out (PORT_GG_SERIAL_DATA), a ; Once with a set bit 4
-:  ; Then wait to get the other end's data
    in a, (PORT_GG_SERIAL_DATA)
    bit 5, a
    jr z, -
    ; We got it - move the bits back
    rra
    rra
    and %00000011 ; $03
    ; Save it
    ld b, a
    ; Then we send our buttons pressed data, with bit 4 set then zero
    ld a, (RAM_ButtonsPressed)
    rra
    rra
    and %00000011 ; $03
    or  %00010000 ; $10
    out (PORT_GG_SERIAL_DATA), a
    and %00000011 ; $03
    out (PORT_GG_SERIAL_DATA), a
    ; Then wait to get the other end's data again
-:  in a, (PORT_GG_SERIAL_DATA)
    bit 5, a
    jr nz, -
    and %00001100 ; $0C
    or b ; Add in the saved bits
    ld (RAM_OtherPlayerButtonsPressed), a
.endif
    ret

+:  ; I am player 2
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
    ; Read player 1's controls
-:  in a, (PORT_GG_SERIAL_DATA)
    bit 5, a
    jr z, -
    rra
    rra
    and $03
    ld b, a
    ld a, (RAM_ButtonsPressed)
    and $03
    out (PORT_GG_SERIAL_DATA), a
    or $10
    out (PORT_GG_SERIAL_DATA), a
-:  in a, (PORT_GG_SERIAL_DATA)
    bit 5, a
    jr nz, -
    and $0C
    or b
    ld (RAM_OtherPlayerButtonsPressed), a
    ld a, (RAM_ButtonsPressed)
    rra
    rra
    and $03
    or $10
    out (PORT_GG_SERIAL_DATA), a
    and $03
    out (PORT_GG_SERIAL_DATA), a
    ret

SyncSerialConnection:
.ifdef FORCE_GAMEPLAY
    ; Do not sync
    ret
.endif

    ld a, (RAM_IAmPlayer1)
    and a
    jr z, +
    ; Player 1
    call _SyncSerialConnection_PLayer1_1s
    call _SyncSerialConnection_PLayer1_0s
    ret
+:  ; PLayer 2
    call _SyncSerialConnection_PLayer2_1s
    call _SyncSerialConnection_PLayer2_0s
    ret

_SyncSerialConnection_PLayer1_1s:
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
-:  ; Send all 1s
    ld a, %11111111
    out (PORT_GG_SERIAL_DATA), a
    ; Wait for the other side to do the same
    in a, (PORT_GG_SERIAL_DATA)
    and RECEIVED_BITS_MASK
    cp RECEIVED_BITS_MASK ; sent was all 1s
    jr nz, -
    ret

_SyncSerialConnection_PLayer2_1s
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
-:  ; Wait for other side to sent all 1s
    in a, (PORT_GG_SERIAL_DATA)
    and RECEIVED_BITS_MASK
    cp RECEIVED_BITS_MASK
    jr nz, -
    ; The we do the same
    ld a, %11111111
    out (PORT_GG_SERIAL_DATA), a
    ret

_SyncSerialConnection_PLayer2_0s:
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
-:  ; Send all zeroes
    xor a
    out (PORT_GG_SERIAL_DATA), a
    ; Wait for other side to send all zeroes
    in a, (PORT_GG_SERIAL_DATA)
    and RECEIVED_BITS_MASK
    jr nz, -
    ret

_SyncSerialConnection_PLayer1_0s:
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
    ; Wait for the other side to send all zeroes
-:  in a, (PORT_GG_SERIAL_DATA)
    and RECEIVED_BITS_MASK
    jr nz, -
    ; Then we do the same
    xor a
    out (PORT_GG_SERIAL_DATA), a
    ret

; Unreachable code
; Sends all zeroes
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
    xor a
    out (PORT_GG_SERIAL_DATA), a
    ret

SendPlayer2Ready:
    ld a, (RAM_IAmPlayer1)
    and a
    ret nz
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
    ld a, %01010101 ; Send "Player 2 ready"
    ;         ^--^^- sent bits
    out (PORT_GG_SERIAL_DATA), a
    ret

CheckIfIAmPlayer1:
    ; Read serial port
    ld a, PORT_GG_SERIAL_DIRECTION_VALUE
    out (PORT_GG_SERIAL_DIRECTION), a
    in a, (PORT_GG_SERIAL_DATA)
    ; If it looks like the other end is not there (?), we will be player 1.
    and RECEIVED_BITS_MASK
    jr z, +               ; Sent was all 0s
    cp RECEIVED_BITS_MASK ; Sent was all 1s
    jr z, +
    cp  %00100100 ; $24 ; Or sent was ---1--01
    jr z, +
    xor a
    ld (RAM_IAmPlayer1), a
    ret
    
+:  ld a, $FF
    ld (RAM_IAmPlayer1), a
    ld a, %10101010 ; Send the inverse of the "you are player 1" message
    out (PORT_GG_SERIAL_DATA), a
    ret

Text_JonTheProgrammers:
.db "JON THE PROGRAMMERS'", STRING_TERMINATOR
Text_SquinkyTennis:
.db " - SQUINKY TENNIS - ", STRING_TERMINATOR
Text_ItsLinkTastic:
.db "-*IT'S LINK-TASTIC*-", STRING_TERMINATOR
Text_AProductionOfThe:
.db "A PRODUCTION OF THE ", STRING_TERMINATOR
Text_BigRedSoftwareCo:
.db "BIG RED SOFTWARE CO.", STRING_TERMINATOR
Text_IAmPlayer1:
.db "-* I AM PLAYER 1! *-", STRING_TERMINATOR
Text_IAmPlayer2:
.db "-* I AM PLAYER 2! *-", STRING_TERMINATOR
Text_PressStartToPlay:
.db "PRESS START TO PLAY!", STRING_TERMINATOR
Text_Pl1IsInControl:
.db " PL1 IS IN CONTROL. ", STRING_TERMINATOR
Text_Pl1StartsGame:
.db "  PL1 STARTS GAME!  ", STRING_TERMINATOR
Text_YouWin:
.db "     YOU WIN !      ", STRING_TERMINATOR
Text_YouLose:
.db "     YOU LOSE!      ", STRING_TERMINATOR
Text_Blank: ; Unused
.db "                    ", STRING_TERMINATOR
Text_ConnectOtherGear:
.db "*CONNECT OTHER GEAR*", STRING_TERMINATOR

; zero fill what's left
.emptyfill $00
