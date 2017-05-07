; Some options for what we want to keep identical to the original...
.define BLANK_FILL_ORIGINAL ; disable to squash blanks and blank unused bytes
.define UNNECESSARY_CODE ; disable to drop out the unreachable code and code that does nothing - BUGGY
.define JUMP_TO_RET ; disable to use conditional rets
.define TAIL_CALL ; disable to optimise calls followed by rets to jumps - INCOMPLETE
.define GAME_GEAR_CHECKS ; disable to replace runtime Game Gear handling with compile-time - INCOMPLETE
.define IS_GAME_GEAR ; Only applies when GAME_GEAR_CHECKS is disabled - INCOMPLETE

; These are computed from the above to make things easier
; Some constants
.define INFINITE_LIVES_COUNT 5 ; Number of lives we fix at
.define WINS_IN_A_ROW_FOR_RUFFTRUX 3 ; Number of wins in a row to get RuffTrux
.define RUFFTRUX_LAP_COUNT 1 ; Number of laps to complete
.define CHALLENGE_LAP_COUNT 3 ; Number of laps to complete

; This disassembly was initially created using Emulicious (http://www.emulicious.net)
.memorymap
slotsize $7fe0
slot 0 $0000
slotsize $20
slot 1 $7ff0
slotsize $4000
slot 2 $8000
defaultslot 2
.endme
.rombankmap
bankstotal 16
banksize $7fe0
banks 1
banksize $20
banks 1
banksize $4000
banks 14
.endro

; SMS stuff
.include "System definitions.inc"

; Some shorthand for the mode control registers
; These are game-specific
.define VDP_REGISTER_MODECONTROL1_VALUE    %00100110
; D7 - 1= Disable vertical scrolling for    ||||||||
;      columns 24-31 _______________________||||||||
; D6 - 1= Disable horizontal scrolling for   |||||||
;      rows 0-1 _____________________________|||||||
; D5 - 1= Mask column 0 with overscan color   ||||||
;      from register #7 ______________________||||||
; D4 - (IE1) 1= Line interrupt enable _________|||||
; D3 - (EC) 1= Shift sprites left by 8 pixels __||||
; D2 - (M4) 1= Use Mode 4, 0= Use TMS9918 modes  |||
;      (selected with M1, M2, M3) _______________|||
; D1 - (M2) Must be 1 for M1/M3 to change screen  ||
;      height in Mode 4. Otherwise has no effect._||
; D0 - 1= No sync, display is monochrome,          |
;      0= Normal display __________________________|

.define VDP_REGISTER_MODECONTROL2_SCREENOFF %00010000
.define VDP_REGISTER_MODECONTROL2_SCREENON  %01110000
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

.if NAME_TABLE_ADDRESS == $3700
.define VDP_REGISTER_NAMETABLEBASEADDRESS_VALUE %00001110 ; can't be sensibly calculated?
.endif

.define VDP_REGISTER_SPRITETABLEBASEADDRESS_VALUE (SPRITE_TABLE_ADDRESS >> 7) & %01111110 | %00000001

.enum 0 ; TrackTypes
TT_0_SportsCars   db ; 0
TT_1_FourByFour   db ; 1
TT_2_Powerboats   db ; 2
TT_3_TurboWheels  db ; 3
TT_4_FormulaOne   db ; 4
TT_5_Warriors     db ; 5
TT_6_Tanks        db ; 6
TT_7_RuffTrux     db ; 7
TT_8_Helicopters  db ; 8 - Incomplete support
TT_9_Unknown      db ; 9 - for portrait drawing only?
.ende

.enum -1 ; Car states
CarState_ff db ; 2-player reset?
CarState_0_Normal db ; Normal
CarState_1_Exploding db ; Exploding?
CarState_2_Respawning db ; Reappearing?
CarState_3_Falling db ; Falling?
CarState_4_Submerged db ; ???
.ende

; Track names to indices
.enum 0
Track_00_QualifyingRace           db
Track_01_TheBreakfastBends        db
Track_02_DesktopDropOff           db
Track_03_OilcanAlley              db
Track_04_SandyStraights           db
Track_05_OatmealInOverdrive       db
Track_06_TheCueBallCircuit        db
Track_07_HandymansCurve           db
Track_08_BermudaBathtub           db
Track_09_SaharaSandpit            db
Track_0A_ThePottedPassage         db ; Helicopter!
Track_0B_FruitJuiceFollies        db
Track_0C_FoamyFjords              db
Track_0D_BedroomBattlefield       db
Track_0E_PitfallPockets           db
Track_0F_PencilPlateaux           db
Track_10_TheDareDevilDunes        db
Track_11_TheShrubberyTwist        db ; Helicopter!
Track_12_PerilousPitStop          db
Track_13_WideAwakeWarZone         db
Track_14_CrayonCanyons            db
Track_15_SoapLakeCity             db
Track_16_TheLeafyBends            db ; Helicopter!
Track_17_ChalkDustChicane         db
Track_18_GoForIt                  db
Track_19_WinThisRaceToBeChampion  db
Track_1A_RuffTrux1                db
Track_1B_RuffTrux2                db
Track_1C_RuffTrux3                db
.ende

.define BUTTON_U_MASK %00000001
.define BUTTON_D_MASK %00000010
.define BUTTON_L_MASK %00000100
.define BUTTON_R_MASK %00001000
.define BUTTON_1_MASK %00010000
.define BUTTON_2_MASK %00100000
.define NO_BUTTONS_PRESSED %00111111
.define BUTTON_U_ONLY BUTTON_U_MASK ~ NO_BUTTONS_PRESSED
.define BUTTON_D_ONLY BUTTON_D_MASK ~ NO_BUTTONS_PRESSED
.define BUTTON_L_ONLY BUTTON_L_MASK ~ NO_BUTTONS_PRESSED
.define BUTTON_R_ONLY BUTTON_R_MASK ~ NO_BUTTONS_PRESSED
.define BUTTON_1_ONLY BUTTON_1_MASK ~ NO_BUTTONS_PRESSED
.define BUTTON_2_ONLY BUTTON_2_MASK ~ NO_BUTTONS_PRESSED

.enum 0
MenuScreen_Initialise         db ; 0 Do-nothing + initialisation
MenuScreen_Title              db ; 1 Title screen with credits, image slideshow, etc
MenuScreen_SelectPlayerCount  db ; 2 Select Game - One Player, Two Player
MenuScreen_OnePlayerSelectCharacter db ; 3 One-player Who Do You Want To Be?
MenuScreen_RaceName           db ; 4 Qualifying Race
MenuScreen_Unused5            db ; 5 Unused, same as 0?
MenuScreen_Qualify            db ; 6 Qualified for challenge!, Failed to qualify!
MenuScreen_WhoDoYouWantToRace db ; 7 Who do you want to race?
MenuScreen_DisplayCase         db ; 8 Car storage box
MenuScreen_OnePlayerTrackIntro db ; 9 1-player pre-track
MenuScreen_OnePlayerChallengeResults db ; a 1-player challenge results
MenuScreen_UnknownB           db ; b
MenuScreen_LifeWonOrLost      db ; c One life lost!, Game over!
MenuScreen_UnknownD           db ; d
MenuScreen_TwoPlayerSelectCharacter db ; e Two-player Who Do You Want To Be? (head to head)
MenuScreen_TwoPlayerGameType  db ; f Two player choose game (tournament or single race)
MenuScreen_TrackSelect        db ; 10 Track select cheat, two-player pre-track and track select
MenuScreen_TwoPlayerResult    db ; 11 Two-player win/lose
MenuScreen_TournamentChampion db ; 12 Tournament champion!
MenuScreen_OnePlayerMode      db ; 13 Challenge or Head to Head
.ende

.enum 0
MenuIndex_0_TitleScreen db
MenuIndex_1_QualificationResults db
MenuIndex_2_FourPlayerResults db
MenuIndex_3_LifeWonOrLost db
MenuIndex_4_TwoPlayerResults db
MenuIndex_5 db
MenuIndex_6 db
.ende

.enum 0
LifeWonOrLostMode_LifeLost db
LifeWonOrLostMode_GameOver db
LifeWonOrLostMode_RuffTruxWon db
LifeWonOrLostMode_RuffTruxLost db
.ende

.enum 0
SFX_00_Nothing db
SFX_01 db ; Bong (lap complete?)
SFX_02_HitGround db ; Car hits ground
SFX_03_Crash db ; Car hits wall or other player?
SFX_04_TankMiss db ; Tank shell hits floor
SFX_05 db ; Disappear (2-player cars reset)
SFX_06 db ; Sticky driving?
SFX_07_EnterSticky db
SFX_08 db ; Explode?
SFX_09_EnterPoolTableHole db ; Pool table hole
SFX_0A_TankShoot db ; Tank shoots
SFX_0B db ; Bang - unused?
SFX_0C_LeavePoolTableHole db ; Powerup?
SFX_0D db ; Hit car
SFX_0E_FallToFloor db ; Fall
SFX_0F_Skid1 db ; Skid
SFX_10_Skid2 db ; Small skid?
SFX_11 db ; Hit ground?
SFX_12_WinOrCheat db
SFX_13_HeadToHeadWinPoint db
SFX_14_Playoff db ; Playoff
SFX_15_HitFloor db ; Hit floor, explode
SFX_16_Respawn db ; Appear?
.ende

.enum 1
Music_01_TitleScreen db ; Title screen
Music_02_CharacterSelect db ; Who do you want to be?
Music_03_Ending db ; Tournament Champion!
Music_04_Silence db ; (Stop music)
Music_05_RaceStart db ; Smoke On The Water (race start)
Music_06_Results db ; Qualified, results
Music_07_Menus db ; Menus
Music_08_GameOver db ; Game Over
Music_09_PlayerOut db ; Someone is out
Music_0A_LostLife db ; One life lost
Music_0B_TwoPlayerResult db ; Tournament results
Music_0C_TwoPlayerTournamentWinner db ; Tournament champion
.ende

; Sprite indices
.struct FourPlayers_InGame
Player1 .db ; For 2-player mode
Red db
Player2 .db ; For 2-player mode
Green db
Blue db
Yellow db
.endst

; Yellow and blue are the other way round in menus
.struct FourPlayers_Menu
Red db
Green db
Yellow db
Blue db
.endst

; Tile numbers in menus

.struct FontTiles
LettersAToN dsb 14
Space       db
LettersPToZ dsb 11
Digits      dsb 10
.endst

.struct PunctuationTiles
ExclamationMark db
Hyphen          db
QuestionMark    db
Line            db
.endst

.struct PlayerPortraitTiles
Tiles dsb 5*6
.endst

.struct CarPortraitTiles
Tiles dsb 10*8
.endst

.struct BigNumberTiles
Tiles dsb 2*4
.endst

.struct CursorTiles
TopLeft     db
Top         db
TopRight    db
Left        db
Right       db
BottomLeft  db
Bottom      db
BottomRight db
.endst

; Generic one - TODO get rid of much of it
.enum 0
MenuTileIndex_Font        instanceof FontTiles
MenuTileIndex_Portraits   instanceof PlayerPortraitTiles 4
MenuTileIndex_Unused      dsb 30
MenuTileIndex_Cursor      instanceof CursorTiles
MenuTileIndex_SmallLogo   dsb 22
MenuTileIndex_Text1       dsb 24
MenuTileIndex_Text2       dsb 18
; ...
.ende

; Title screen
.enum 0
MenuTileIndex_Title_Font        instanceof FontTiles
MenuTileIndex_Title_Portraits   instanceof CarPortraitTiles 2
MenuTileIndex_Title_Unused      dsb 60
MenuTileIndex_Title_Logo        dsb 177
.ende

; "Select A or B" screens
.enum 0
MenuTileIndex_Select_Font        instanceof FontTiles
MenuTileIndex_Select_Icon1       dsb 60
MenuTileIndex_Select_Unused1     dsb 20
MenuTileIndex_Select_Icon2       dsb 60
MenuTileIndex_Select_Unused2     dsb 11
MenuTileIndex_Select_Hand        dsb 39 ; actually 36 but we pad (and load extra data) to fill the space...
MenuTileIndex_Select_Text1       dsb 14
MenuTileIndex_Select_Text2       dsb 16
MenuTileIndex_Select_Logo        dsb 112 ; $100 - 177 tiles (SMS), 112 (GG)
MenuTileIndex_Select_Icon3       dsb 60 ; $170
; No punctuation
.ende

; Character select
.enum 0
MenuTileIndex_SelectPlayers_Font                instanceof FontTiles
MenuTileIndex_SelectPlayers_SelectedPortraits   instanceof PlayerPortraitTiles 4
MenuTileIndex_SelectPlayers_Unused              dsb 30
MenuTileIndex_SelectPlayers_Cursor              instanceof CursorTiles
MenuTileIndex_SelectPlayers_Logo                dsb 22 ; small logo
MenuTileIndex_SelectPlayers_Text1               dsb 24 ; Micro Machines
MenuTileIndex_SelectPlayers_Text2               dsb 16 ; Challenge (or other?)
MenuTileIndex_SelectPlayers_AvailablePortraits  instanceof PlayerPortraitTiles 6
MenuTileIndex_SelectPlayers_Blank               db
MenuTileIndex_SelectPlayers_Punctuation         instanceof PunctuationTiles
.ende

; Results screen
.enum 0
MenuTileIndex_Results_Font        instanceof FontTiles
MenuTileIndex_Results_Portraits   instanceof PlayerPortraitTiles 4
MenuTileIndex_Results_Unused      dsb 38
MenuTileIndex_Results_Logo        dsb 22
MenuTileIndex_Results_Text1       dsb 24
MenuTileIndex_Results_Text2       dsb 18
MenuTileIndex_Results_Numbers     instanceof BigNumberTiles 4
MenuTileIndex_Results_ColouredBalls instanceof FourPlayers_Menu
.ende

; Track intro screen
.enum 0
MenuTileIndex_TrackIntro_Font        instanceof FontTiles
MenuTileIndex_TrackIntro_Portraits   instanceof PlayerPortraitTiles 4
MenuTileIndex_TrackIntro_Unused      dsb 38
MenuTileIndex_TrackIntro_Logo        dsb 22
MenuTileIndex_TrackIntro_Text1       dsb 24
MenuTileIndex_TrackIntro_Text2       dsb 18
MenuTileIndex_TrackIntro_CarPortrait instanceof CarPortraitTiles
MenuTileIndex_TrackIntro_ColouredBalls instanceof FourPlayers_Menu
.ende


.define MenuTileIndex_Hand $bb ; todo

; Small logo layout
.enum $100
MenuTileIndex_Logo            .db ; 80, 122 or 177 tiles for big logos
__todo dsb $50
MenuTileIndex_ColouredBalls   instanceof FourPlayers_Menu ; $150
MenuTileIndex_TODO            dsb 96 ; Used elsewhere?
MenuTileIndex_Punctuation     instanceof PunctuationTiles
.ende

.enum $100
ResultsMenuTileIndex_BigNumbers     dsb 4*6 ; $100 big numbers, 6 tiles each
ResultsMenuTileIndex_ColouredBalls  instanceof FourPlayers_Menu ; $118
.ende

; Tile numbers in-game
.enum $190
SpriteIndex_Decorators          instanceof FourPlayers_InGame ; $90
SpriteIndex_PositionIndicators  instanceof FourPlayers_InGame ; $94
SpriteIndex_SuffixSt            db    ; $98
SpriteIndex_SuffixNd            db    ; $99
SpriteIndex_SuffixRd            db    ; $9a
SpriteIndex_SuffixTh            db    ; $9b
SpriteIndex_FinishedIndicators  instanceof FourPlayers_InGame ; $9c
SpriteIndex_Smoke               dsb 4 ; $a0
SpriteIndex_Digit1              db    ; $a4
SpriteIndex_Digit2              db    ; $a5
SpriteIndex_HeadToHeadLapCounter .db
SpriteIndex_Digit3              db    ; $a6 
SpriteIndex_Digit4              db    ; $a7
SpriteIndex_Shadow              dsb 4 ; $a8
SpriteIndex_Blank               db    ; $ac
SpriteIndex_Dust                .db   ; $ad..$af for non-tanks
SpriteIndex_Bullet              db    ; $ad for tanks
SpriteIndex_BulletShadow        db    ; $ae for tanks
SpriteIndex_Blank_Unused        db    ; $af for tanks
SpriteIndex_Splash              dsb 3 ; $b0
SpriteIndex_FallingCar          dsb 4 ; $b3 2x2 tiles
SpriteIndex_FallingCar2         db    ; $b7 1x1 tiles
.ende

; The RuffTrux truck is 4x4 sprites, with 16 positions all held in VRAM. This would use all 256 sprite tiles, but at 45 degree angles the corner tiles are blank; so 13 of them are used for additional sprites (HUD, shadow, smoke, splash).
; The sprites are laid out in VRAM in this shape (space means blank tile):
; 00001111 22 333344445555 66 7777
; 00001111222233334444555566667777
; 00001111222233334444555566667777
; 00001111 22 333344445555 66 7777
; 88889999 aa bbbbccccdddd ee ffff
; 88889999aaaabbbbccccddddeeeeffff
; 88889999aaaabbbbccccddddeeeeffff
; 88889999 aa bbbbccccdddd ee ffff
; It's not worth an enum for this...
.define SpriteIndex_RuffTrux_Shadow1  11 ; 0B
.define SpriteIndex_RuffTrux_Shadow2  24 ; 18
.define SpriteIndex_RuffTrux_Shadow3  27 ; 1B
.define SpriteIndex_RuffTrux_Blank   104 ; 68
.define SpriteIndex_RuffTrux_Dust1   107 ; 6B
.define SpriteIndex_RuffTrux_Dust2   120 ; 78
.define SpriteIndex_RuffTrux_Dust3   123 ; 7B
.define SpriteIndex_RuffTrux_Shadow4 136 ; 88
.define SpriteIndex_RuffTrux_Digit1  139 ; 8B
.define SpriteIndex_RuffTrux_Digit2  152 ; 98
.define SpriteIndex_RuffTrux_Colon   155 ; 9B
.define SpriteIndex_RuffTrux_Digit3  232 ; E8
.define SpriteIndex_RuffTrux_Water1  235 ; EB
.define SpriteIndex_RuffTrux_Water2  248 ; F8
.define SpriteIndex_RuffTrux_Blank2  251 ; FB

.struct PlayerPortraits
Happy1  db ; default; high enough position
Sad1    db ; position too low
Happy2  db
Unused1 db
Happy3  db
Sad2    db
Sad3    db ; Some of these may have specific scenarios...
Unused2 db
.endst

.enum 0
PlayerPortrait_Chen       instanceof PlayerPortraits ; $00
PlayerPortrait_Spider     instanceof PlayerPortraits ; $08
PlayerPortrait_Walter     instanceof PlayerPortraits ; $10
PlayerPortrait_Dwayne     instanceof PlayerPortraits ; $18
PlayerPortrait_Joel       instanceof PlayerPortraits ; $20
PlayerPortrait_Bonnie     instanceof PlayerPortraits ; $28
PlayerPortrait_Mike       instanceof PlayerPortraits ; $30
PlayerPortrait_Emilio     instanceof PlayerPortraits ; $38
PlayerPortrait_Jethro     instanceof PlayerPortraits ; $40
PlayerPortrait_Anne       instanceof PlayerPortraits ; $48
PlayerPortrait_Cherry     instanceof PlayerPortraits ; $50
PlayerPortrait_OutOfGame  db ; $58
PlayerPortrait_MrQuestion db ; $59
PlayerPortrait_OutOfGame2 db ; $5a
.ende

; ASCII mapping for menu screen text
; Uses enum for tile indices, code decides on the high byte by itself
.asctable
map "A" to "N" = MenuTileIndex_Font.LettersAToN
map "O" = MenuTileIndex_Font.Digits
map "P" to "Z" = MenuTileIndex_Font.LettersPToZ
map "0" to "9" = MenuTileIndex_Font.Digits
map " " = MenuTileIndex_Font.Space
map "!" = <MenuTileIndex_Punctuation.ExclamationMark
map "-" = <MenuTileIndex_Punctuation.Hyphen
map "?" = <MenuTileIndex_Punctuation.QuestionMark
.enda

.define STACK_TOP $dfff

.include "VDP macros.inc"

.macro CallPagedFunction args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  call LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro JumpToPagedFunction args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  jp LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro JrToPagedFunction args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  jr LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro CallPagedFunction2 args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
.endm

; The original game has a bad habit of jumping to ret opcodes instead of returning in place.
; These macros let us switch behaviour.
; (A more cunning macro system would let us fold them better, but never mind...)

.macro JpRet args label
.ifdef JUMP_TO_RET
  jp label
.else
  ret
.endif
.endm

.macro JrRet args label
.ifdef JUMP_TO_RET
  jr label
.else
  ret
.endif
.endm

.macro JrZRet args label
.ifdef JUMP_TO_RET
  jr z, label
.else
  ret z
.endif
.endm

.macro JrNzRet args label
.ifdef JUMP_TO_RET
  jr nz, label
.else
  ret nz
.endif
.endm

.macro JrCRet args label
.ifdef JUMP_TO_RET
  jr c, label
.else
  ret c
.endif
.endm

.macro JrNcRet args label
.ifdef JUMP_TO_RET
  jr nc, label
.else
  ret nc
.endif
.endm

.macro JpZRet args label
.ifdef JUMP_TO_RET
  jp z, label
.else
  ret z
.endif
.endm

.macro JpNzRet args label
.ifdef JUMP_TO_RET
  jp nz, label
.else
  ret nz
.endif
.endm

.macro JpCRet args label
.ifdef JUMP_TO_RET
  jp c, label
.else
  ret c
.endif
.endm

.macro JpNcRet args label
.ifdef JUMP_TO_RET
  jp nc, label
.else
  ret nc
.endif
.endm

; There's a lot of tables for multiplication...

.macro TimesTableLo args start, step, count
.define _x start
.rept count
.db <_x
.redefine _x _x+step
.endr
.undef _x
.endm

.macro TimesTableHi args start, step, count
.define x start
.rept count
.db >x
.redefine x x+step
.endr
.undef x
.endm

.macro TimesTable16 args start, step, count
.define x start
.rept count
.dw x
.redefine x x+step
.endr
.undef x
.endm

.macro DivisionTable args divisor, count
  .define x 0
  .repeat count
    .db x/divisor
    .redefine x x+1
  .endr
  .undefine x
.endm

; The game stores some numbers as sign and magnitude bytes.
.macro SignAndMagnitude
  ; For each arg...
  .rept nargs
    ; Emit with high bit set for negative
    .if \1 < 0
      .db (-\1) | $80
    .else
      .db \1
    .endif
    .shift
  .endr
.endm

; Tail call optimisation is often possible - and often not used in the original code.
.macro TailCall args label retlabel
.ifdef TAIL_CALL
  call label
  .if nargs == 2
  jp retlabel
  .else
  ret
  .endif
.else
  jp label
.endif
.endm

; Pick the pointer either at runtime or compile time, depending on the flags
.macro GetPointerForSystem args SMSPointer, GGPointer, ComparisonType, Jump1, Jump2
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC54_IsGameGear)
.if ComparisonType == "cp"
  cp $00
.else
  or a
.endif
.if Jump1 == "jr"
  jr z, +
.else
  jp z, +
.endif
  ld hl, GGPointer
.if Jump2 == "jr"
  jr ++
.else
  jp ++
.endif
+:ld hl, SMSPointer
++:
.else
.ifdef IS_GAME_GEAR
  ld hl, GGPointer
.else
  ld hl, SMSPointer
.endif
.endif
.endm

.macro SetTileIndex_RAM_DEC1_VRAMAddress args x, y
  ld a, <(VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2)
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, >(VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2)
  ld (_RAM_DEC1_VRAMAddress.Hi), a
.endm

; Structs for RAM arrays
.struct WallDataMetaTile
bits dsb 12*12/8 ; 12*12 bits = 18 bytes
.endst

.struct BehaviourDataMetaTile
bytes dsb 6*6 ; 6*6 bytes
.endst

.struct SpriteXN
x db
n db
.endst

.struct SpriteY
y db
.endst

; Word with addressable bytes
.struct Word
Lo db
Hi db
.endst

.struct BigEndianWord
Hi db
Lo db
.endst

.enum $C000 export
_RAM_C000_StartOfRam .db
_RAM_C000_DecompressionTemporaryBuffer .db
_RAM_C000_LevelLayout dsb 32 * 32 ; 32x32 metatiles
_RAM_C400_TrackIndexes dsb 32 * 32 ; 32x32 metatile track indexes
_RAM_C800_WallData instanceof WallDataMetaTile 64 ; 64 tiles of 12x12 bits
_RAM_CC80_BehaviourData instanceof BehaviourDataMetaTile 64 ; 64 tiles of 6x6 bytes

_RAM_D580_WaitingForGameVBlank db
_RAM_D581_ db
_RAM_D582_ db
_RAM_D583_ db
_RAM_D584_ db ; unused?
_RAM_D585_ dw
_RAM_D587_ db
_RAM_D588_ db ; unused?
_RAM_D589_ db
_RAM_D58A_ instanceof Word
_RAM_D58C_ dw
_RAM_D58E_ db
_RAM_D58F_ db
_RAM_D590_ dw
_RAM_D592_ db
_RAM_D593_ db
_RAM_D594_ db
_RAM_D595_ db
_RAM_D596_ db
_RAM_D597_ db
_RAM_D598_ db ; unused?
_RAM_D599_IsPaused db
_RAM_D59A_PauseDebounce1 db
_RAM_D59B_PauseDebounce2 db
_RAM_D59C_GGStartButtonValue db
_RAM_D59D_ db
_RAM_D59E_ db
_RAM_D59F_ dw
_RAM_D5A1_ dw
_RAM_D5A3_ db
_RAM_D5A4_IsReversing db
_RAM_D5A5_ db
_RAM_D5A6_ db
_RAM_D5A7_ db
_RAM_D5A8_ db
_RAM_D5A9_ dw
_RAM_D5AB_ db
_RAM_D5AC_ dsb 4 ; unused?
_RAM_D5B0_ db
_RAM_D5B1_ dsb 4 ; unused?
_RAM_D5B5_EnableGameVBlank db
_RAM_D5B6_ db
_RAM_D5B7_ db
_RAM_D5B8_ db
_RAM_D5B9_ db
_RAM_D5BA_ db
_RAM_D5BB_ db
_RAM_D5BC_ db
_RAM_D5BD_ db
_RAM_D5BE_ db
_RAM_D5BF_ db
_RAM_D5C0_ db
_RAM_D5C1_ db
_RAM_D5C2_ db
_RAM_D5C3_ db
_RAM_D5C4_ db
_RAM_D5C5_ db
_RAM_D5C6_ db
_RAM_D5C7_ db
_RAM_D5C8_MetatileX db
_RAM_D5C9_MetatileY db
_RAM_D5CA_ db
_RAM_D5CB_ db
_RAM_D5CC_PlayoffTileLoadFlag db
_RAM_D5CD_CarIsSkidding db
_RAM_D5CE_ db ; unused?
_RAM_D5CF_Player1Handicap db
_RAM_D5D0_Player2Handicap db
_RAM_D5D1_ db ; unused?
_RAM_D5D2_ db
_RAM_D5D3_ db
_RAM_D5D4_ db
_RAM_D5D5_ db
_RAM_D5D6_ db
_RAM_D5D7_GearToGearVBlankWorkDone db
_RAM_D5D8_ db
_RAM_D5D9_ db
_RAM_D5DA_ dsb 2 ; unused?
_RAM_D5DC_ db
_RAM_D5DD_ db
_RAM_D5DE_ db
_RAM_D5DF_ db
_RAM_D5E0_ db
_RAM_D5E1_ dsb 95 ; unused?
_RAM_D640_RamCodeLoader dsb 17
_RAM_D652_ dsb 47 ; unused?
_RAM_D680_MenuRamStart .db
_RAM_D680_Player1Controls_Menus db
_RAM_D681_Player2Controls_Menus db
_RAM_D682_ dsb 5 ; unused?
_RAM_D687_Player1Controls_PreviousFrame db
_RAM_D688_ db
_RAM_D689_ db ; unused?
_RAM_D68A_TilemapRectangleSequence_TileIndex db
_RAM_D68B_TilemapRectangleSequence_Row db
_RAM_D68C_SlideshowRAMReadAddress instanceof BigEndianWord
_RAM_D68E_SlideshowVRAMWriteAddress instanceof BigEndianWord
_RAM_D690_CarPortraitTileIndex db
_RAM_D691_TitleScreenSlideshowIndex db
_RAM_D692_SlideshowPointerOffset db
_RAM_D693_SlowLoadSlideshowTiles db ; Used for other purposes elsewhere?
_RAM_D694_DrawCarPortraitTilemap db
_RAM_D695_SlideshowTileWriteCounter instanceof Word
_RAM_D697_ db
_RAM_D698_ db ; unused?
_RAM_D699_MenuScreenIndex db
_RAM_D69A_TilemapRectangleSequence_Width db
_RAM_D69B_TilemapRectangleSequence_Height db
_RAM_D69C_TilemapRectangleSequence_Flags db
_RAM_D69D_EmitTilemapRectangle_Width db
_RAM_D69E_EmitTilemapRectangle_Height db
_RAM_D69F_EmitTilemapRectangle_IndexOffset db
_RAM_D6A0_MenuSelection db
_RAM_D6A1_PortraitIndex db
_RAM_D6A2_ db
_RAM_D6A3_ db
_RAM_D6A4_ db
_RAM_D6A5_ db
_RAM_D6A6_DisplayCase_Source dw
_RAM_D6A8_DisplayCaseTileAddress dw
_RAM_D6AA_ db
_RAM_D6AB_MenuTimer instanceof Word ; Used as a byte by some screens; may count up or down
_RAM_D6AD_ db
_RAM_D6AE_ db
_RAM_D6AF_FlashingCounter db ; Used to flash text. Flashes between the text and blank every 8 frames, but stops when the counter reaches 0.
_RAM_D6B0_ db
_RAM_D6B1_ db
_RAM_D6B2_ dsb 2 ; unused?
_RAM_D6B4_ db
_RAM_D6B5_ db
_RAM_D6B6_ db
_RAM_D6B7_ db
_RAM_D6B8_ db
_RAM_D6B9_ db
_RAM_D6BA_ db
_RAM_D6BB_ db
_RAM_D6BC_DisplayCase_IndexBackup dw
_RAM_D6BE_TileWriteAddress dw
_RAM_D6C0_ db
_RAM_D6C1_ db
_RAM_D6C2_DisplayCase_FlashingCarIndex db
_RAM_D6C3_ db
_RAM_D6C4_ db ; Per-course value, usually -1, sometimes 0, 1, 2
_RAM_D6C5_PaletteFadeIndex db
_RAM_D6C6_ db
_RAM_D6C7_IsTwoPlayer db ; 0 or 1
_RAM_D6C8_HeaderTilesIndexOffset db
_RAM_D6C9_ControllingPlayersLR1Buttons db ; Combination of player 1 and 2 when applicable, else player 1
_RAM_D6CA_ db
_RAM_D6CB_MenuScreenState db ; Meaning depends on which menu screen we are on?
_RAM_D6CC_TwoPlayerTrackSelectIndex db
_RAM_D6CD_ db
_RAM_D6CE_ db
_RAM_D6CF_GearToGearTrackSelectIndex db
_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect db
_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen db ; Used for "debouncing"
_RAM_D6D2_Unused db
_RAM_D6D3_VBlankDone db
_RAM_D6D4_Slideshow_PendingLoad db
_RAM_D6D5_InGame db
_RAM_D6D6_TitleScreenSlideshowIndexPlus7_Unused db
_RAM_D6D7_ dsb 10 ; unused?
_RAM_D6E1_SpriteData .db
_RAM_D6E1_SpriteX dsb 32 ; The game uses at most 32 sprites...
_RAM_D701_SpriteN dsb 32
_RAM_D721_SpriteY dsb 32
_RAM_D741_RequestedPageIndex db
_RAM_D742_VBlankSavedPageIndex db
_RAM_D743_ReadPagedByteTemp db
_RAM_D744_ db
_RAM_D745_ dsb 8 ; unused?
_RAM_D74D_ db
_RAM_D74E_ dsb 27 ; unused?
_RAM_D769_ db
_RAM_D76A_ dsb 8 ; unused?
_RAM_D772_ db
_RAM_D773_ dsb 27 ; unused?
_RAM_D78E_ db
_RAM_D78F_ dsb 8 ; unused?
_RAM_D797_ db
_RAM_D798_ dsb 27 ; unused?
_RAM_D7B3_ db
_RAM_D7B4_IsHeadToHead db
_RAM_D7B5_DecompressorSource instanceof Word
_RAM_D7B7_ db
_RAM_D7B8_ db
_RAM_D7B9_ db
_RAM_D7BA_HardModeTextFlashCounter db
_RAM_D7BB_Unused db
_RAM_D7BB_MenuRamEnd .db
_RAM_D7BC_ db ; unused?
_RAM_D7BD_RamCode dsb $392 ; runs over the next bit
.ende

; These macros allow us to call into RAM code from the above address
.macro CallRamCode args address
  call address+_RAM_D7BD_RamCode-LABEL_3B97D_RamCodeStart
.endm
.macro JumpToRamCode args address
  jp address+_RAM_D7BD_RamCode-LABEL_3B97D_RamCodeStart
.endm
.macro CallRamCodeIfZFlag args address
  call z, address+_RAM_D7BD_RamCode-LABEL_3B97D_RamCodeStart
.endm

.enum $D800 export
_RAM_D800_TileHighBytes dsb 256
_RAM_D900_ dsb 64
.ende

.enum $D90F export
_RAM_D90F_ db
_RAM_D910_ db
_RAM_D911_ db
_RAM_D912_ db
_RAM_D913_ db
_RAM_D914_ db
_RAM_D915_ db
_RAM_D916_MenuSound_ db
_RAM_D917_MenuSound_ db
_RAM_D918_MenuSound_ db
_RAM_D919_ db
_RAM_D91A_MenuSoundData dsb 15
.ende


.enum $D920 export
_RAM_D920_ db
_RAM_D921_ db
_RAM_D922_ db
_RAM_D923_ db
_RAM_D924_ db
.ende

.enum $D929 export
_RAM_D929_MenuSound_ dw
_RAM_D92B_MenuSound_ db
_RAM_D92C_MenuSound_ db
_RAM_D92D_ dw
_RAM_D92F_ db
_RAM_D930_ db
.ende

.enum $D940 export
_RAM_D940_ db
_RAM_D941_ dw
_RAM_D943_ dw
_RAM_D945_ db
_RAM_D946_ db
_RAM_D947_ db
_RAM_D948_ db
_RAM_D949_ db
_RAM_D94A_ db
.ende

.enum $D94C export
_RAM_D94C_SoundData .db ; 51 bytes total, up to $d97f? It's initialised but not all used?
_RAM_D94C_Sound1Channel0Volume db
_RAM_D94D_Sound1Channel1Volume db
_RAM_D94E_Sound1Channel2Volume db
_RAM_D94F_Sound2Channel0Volume db
_RAM_D950_Sound2_Channel1Volume db
_RAM_D951_Sound2_Channel2Volume db
_RAM_D952_ db
_RAM_D953_ db
_RAM_D954_ db
_RAM_D955_ db
_RAM_D956_ db
_RAM_D957_SoundIndex db
_RAM_D958_ db
_RAM_D959_ db
_RAM_D95A_ db
_RAM_D95B_ db
_RAM_D95C_ db
_RAM_D95D_ db
_RAM_D95E_ db
_RAM_D95F_ dsb 4 ; unused?
_RAM_D963_SFXTrigger_Player1 db
_RAM_D964_Sound1Control db
_RAM_D965_ dsb 6 ; unused?
_RAM_D96B_SoundMask db
_RAM_D96C_ db
_RAM_D96D_ db
_RAM_D96E_ db ; unused?
_RAM_D96F_ db
_RAM_D970_ dsb 4 ; unused?
_RAM_D974_SFXTrigger_Player2 db
_RAM_D975_Sound2Control db
_RAM_D976_ dsb 6 ; unused?
_RAM_D97C_Sound db
_RAM_D97D_ db
_RAM_D97E_Player1SFX_Unused db
_RAM_D97F_Player2SFX_Unused db

_RAM_D980_CarDecoratorTileData1bpp dsb 16*8 ; 16 * 1bpp tile data

_RAM_DA00_ dsb 32

_RAM_DA20_TrackMetatileLookup dsb 64

_RAM_DA60_SpriteTableXNs instanceof SpriteXN 64 ;dsb 64*2
_RAM_DAE0_SpriteTableYs instanceof SpriteY 64 ;dsb 64

_RAM_DB20_Player1Controls db ; in-game
_RAM_DB21_Player2Controls db
_RAM_DB22_ db
.ende

.enum $DB42 export
_RAM_DB42_ db
.ende

.enum $DB62 export
_RAM_DB62_ db
_RAM_DB63_ db
_RAM_DB64_ db
_RAM_DB65_ db
_RAM_DB66_ db
_RAM_DB67_ db
_RAM_DB68_HandlingData dsb 12
_RAM_DB74_CarTileLoaderTableIndex db
_RAM_DB75_CarTileLoaderDataIndex db
_RAM_DB76_CarTileLoaderPositionIndex db
_RAM_DB77_CarTileLoaderCounter db
_RAM_DB78_CarTileLoaderTempByte db
_RAM_DB79_CarTileLoaderHFlip db
_RAM_DB7A_CarTileLoaderVFlip db
_RAM_DB7B_ db
_RAM_DB7C_ db
_RAM_DB7D_ db
_RAM_DB7E_ db
_RAM_DB7F_ db
_RAM_DB80_ db
_RAM_DB81_ db
_RAM_DB82_ db
_RAM_DB83_ db
_RAM_DB84_ db
_RAM_DB85_ db
_RAM_DB86_HandlingData dsb 16 ; ??? Related to skidding, thresholds when turning?
_RAM_DB96_TrackIndexForThisType db
_RAM_DB97_TrackType db
_RAM_DB98_TopSpeed db
_RAM_DB99_AccelerationDelay db
_RAM_DB9A_DecelerationDelay db
_RAM_DB9B_SteeringDelay db
_RAM_DB9C_MetatilemapWidth dw
_RAM_DB9E_ db
_RAM_DB9F_ db ; unused?
_RAM_DBA0_TopLeftMetatileX dw
_RAM_DBA2_TopLeftMetatileY dw
_RAM_DBA4_ db
_RAM_DBA5_ db
_RAM_DBA6_ db
_RAM_DBA7_ db
_RAM_DBA8_ db
_RAM_DBA9_ db
_RAM_DBAA_ db
_RAM_DBAB_ db
_RAM_DBAC_ db
_RAM_DBAD_ db
_RAM_DBAE_ db
_RAM_DBAF_ db
_RAM_DBB0_ db
_RAM_DBB1_ dw
_RAM_DBB3_ dw
_RAM_DBB5_ db
_RAM_DBB6_ db
_RAM_DBB7_ db
_RAM_DBB8_ db
_RAM_DBB9_ db
_RAM_DBBA_ db
_RAM_DBBB_ db
_RAM_DBBC_ db
_RAM_DBBD_ db
_RAM_DBBE_ db
_RAM_DBBF_ db ; unused?
; Block initialised from ROM ------>
_RAM_DBC0_EnterGameTrampoline dsb 13
_RAM_DBCD_MenuIndex db ; Not the same as the menu screen index!
_RAM_DBCE_Player1Qualified db ; has some other meaning for 2-player?
_RAM_DBCF_LastRacePosition db
_RAM_DBD0_LastRacePosition_Player2 db
_RAM_DBD1_LastRacePosition_Player3 db
_RAM_DBD2_LastRacePosition_Player4 db
_RAM_DBD3_PlayerPortraitBeingDrawn db
_RAM_DBD4_Player1Character db
_RAM_DBD5_Player2Character db
_RAM_DBD6_Player3Character db
_RAM_DBD7_Player4Character db
_RAM_DBD8_TrackIndex_Menus db
_RAM_DBD9_DisplayCaseData dsb 24 ; 0 = blank, 1 = filled, 2 = flashing
_RAM_DBF1_RaceNumberText dsb 8 ; "RACE xx-", xx is replaced at runtime
; ------> End block initialised from ROM
_RAM_DBF9_ dw
_RAM_DBFB_PortraitCurrentIndex db
_RAM_DBFC_ db
_RAM_DBFD_ db
_RAM_DBFE_PlayerPortraitValues dsb 11
_RAM_DC09_Lives db
_RAM_DC0A_WinsInARow db ; 3 wins in a row -> RuffTrux
_RAM_DC0B_ db
_RAM_DC0C_Player2_WonCount db
_RAM_DC0D_Player1_WonCount db
_RAM_DC0E_ db
_RAM_DC0F_ db
.ende

.enum $DC16 export
_RAM_DC16_ db
_RAM_DC17_Player2_LostCount db
_RAM_DC18_Player1_LostCount db
.ende

.enum $DC21 export
_RAM_DC21_CharacterStates dsb 11

_RAM_DC2C_GGTrackSelectFlags dsb 8 ; Seems to hold 1 for tracks that have been played, 0 otherwise

_RAM_DC34_IsTournament db
_RAM_DC35_TournamentRaceNumber db
_RAM_DC36_ db
_RAM_DC37_ db
_RAM_DC38_LifeWonOrLost_Mode db ; values from LifeWonOrLostMode_* enum
_RAM_DC39_NextRuffTruxTrack db
_RAM_DC3A_RequiredPositionForNextRace db
_RAM_DC3B_IsTrackSelect db
_RAM_DC3C_IsGameGear db ; Most code is common with the GG game
_RAM_DC3D_IsHeadToHead db
_RAM_DC3E_InMenus db ; 1 in menus, 0 otherwise
_RAM_DC3F_IsTwoPlayer db
_RAM_DC40_IsGameGear db ; Seems to be a copy of _RAM_DC3C_IsGameGear?
_RAM_DC41_GearToGearActive db
_RAM_DC42_GearToGear_IAmPlayer1 db
.ende

.enum $DC45 export
_RAM_DC45_TitleScreenCheatCodeCounter_HardMode db ; Counts up correct keypresses
_RAM_DC46_Cheat_HardMode db ; 0 = normal 1 = hard 2 = rock hard
_RAM_DC47_GearToGear_OtherPlayerControls1 db
_RAM_DC48_GearToGear_OtherPlayerControls2 db
_RAM_DC49_CheatsStart .db
_RAM_DC49_Cheat_ExplosiveOpponents db
_RAM_DC4A_Cheat_ExtraLives db
_RAM_DC4B_Cheat_InfiniteLives db
_RAM_DC4C_Cheat_AlwaysFirstPlace db
_RAM_DC4D_Cheat_NoSkidding db
_RAM_DC4E_Cheat_SuperSkids db
_RAM_DC4F_Cheat_EasierOpponents db
_RAM_DC50_Cheat_FasterVehicles db
_RAM_DC51_CheatsEnd .db
_RAM_DC51_PreviousCombinedByte db
_RAM_DC52_PreviousCombinedByte2 db
_RAM_DC52_ db ; unused?
_RAM_DC54_IsGameGear db ; GG mode if 1, SMS mode if 0
_RAM_DC55_TrackIndex_Game db
_RAM_DC56_ db
_RAM_DC57_ dw
_RAM_DC59_FloorTiles dsb 32*2 ; 1bpp tile data
_RAM_DC99_EnterMenuTrampoline dsb 18 ; Code in RAM
; Game ram starts here?
_RAM_DCAB_CarData_Green dw
_RAM_DCAD_ dw
_RAM_DCAF_ db
_RAM_DCB0_ db
_RAM_DCB1_ dsb 4 ; unused
_RAM_DCB5_ db
_RAM_DCB6_ db
_RAM_DCB7_ db
_RAM_DCB8_ db
_RAM_DCB9_ db ; unused
_RAM_DCBA_ db
_RAM_DCBB_ db
_RAM_DCBC_ db
_RAM_DCBD_ db
_RAM_DCBE_ db
_RAM_DCBF_ db
_RAM_DCC0_ db
_RAM_DCC1_ db
_RAM_DCC2_ db
_RAM_DCC3_ db
_RAM_DCC4_ db
_RAM_DCC5_ db
_RAM_DCC6_ db
.ende

.enum $DCC8 export
_RAM_DCC8_ db
.ende

.enum $DCCD export
_RAM_DCCD_ dw
_RAM_DCCF_ db
_RAM_DCD0_ db
.ende

.enum $DCD2 export
_RAM_DCD2_ dw
.ende

.enum $DCD8 export
_RAM_DCD8_ db
_RAM_DCD9_ db
_RAM_DCDA_ dw
_RAM_DCDC_ db
_RAM_DCDD_ db
_RAM_DCDE_ db
_RAM_DCDF_ db
_RAM_DCE0_ dw
_RAM_DCE2_ dw
_RAM_DCE4_ db
.ende

.enum $DCEA export
_RAM_DCEA_ db
.ende

.enum $DCEC export
_RAM_DCEC_CarData_Blue db
_RAM_DCED_ db
_RAM_DCEE_ db
_RAM_DCEF_ db
_RAM_DCF0_ db
_RAM_DCF1_ db
.ende

.enum $DCF6 export
_RAM_DCF6_ db
_RAM_DCF7_ db
_RAM_DCF8_ db
_RAM_DCF9_ db
.ende

.enum $DCFB export
_RAM_DCFB_ db
_RAM_DCFC_ db
_RAM_DCFD_ db
_RAM_DCFE_ db
_RAM_DCFF_ db
_RAM_DD00_ db
_RAM_DD01_ db
_RAM_DD02_ db
_RAM_DD03_ db
_RAM_DD04_ db
_RAM_DD05_ db
_RAM_DD06_ db
_RAM_DD07_ db
_RAM_DD08_ db
_RAM_DD09_ db
_RAM_DD0A_ db
_RAM_DD0B_ db
_RAM_DD0C_ db
_RAM_DD0D_ db
_RAM_DD0E_ dw
_RAM_DD10_ db
_RAM_DD11_ db
_RAM_DD12_ db
_RAM_DD13_ dw
.ende

.enum $DD19 export
_RAM_DD19_ db
_RAM_DD1A_ db
_RAM_DD1B_ dw
_RAM_DD1D_ db
_RAM_DD1E_ db
_RAM_DD1F_ db
_RAM_DD20_ db
_RAM_DD21_ dw
_RAM_DD23_ dw
_RAM_DD25_ db
.ende

.enum $DD28 export
_RAM_DD28_ db
.ende

.enum $DD2B export
_RAM_DD2B_ db
.ende

.enum $DD2D export
_RAM_DD2D_CarData_Yellow dw ; actually a struct?
_RAM_DD2F_ dw
_RAM_DD31_ db
_RAM_DD32_ db
.ende

.enum $DD37 export
_RAM_DD37_ db
_RAM_DD38_ db
_RAM_DD39_ db
_RAM_DD3A_ db
.ende

.enum $DD3C export
_RAM_DD3C_ db
_RAM_DD3D_ db
_RAM_DD3E_ db
_RAM_DD3F_ db
_RAM_DD40_ db
_RAM_DD41_ db
_RAM_DD42_ db
_RAM_DD43_ db
_RAM_DD44_ db
_RAM_DD45_ db
_RAM_DD46_ db
_RAM_DD47_ db
_RAM_DD48_ db
.ende

.enum $DD4A export
_RAM_DD4A_ db
.ende

.enum $DD4F export
_RAM_DD4F_ dw
_RAM_DD51_ db
_RAM_DD52_ db
.ende

.enum $DD54 export
_RAM_DD54_ dw
.ende

.enum $DD5A export
_RAM_DD5A_ db
_RAM_DD5B_ db
_RAM_DD5C_ dw
_RAM_DD5E_ db
_RAM_DD5F_ db
_RAM_DD60_ db
_RAM_DD61_ db
_RAM_DD62_ dw
_RAM_DD64_ dw
_RAM_DD66_ db
.ende

.enum $DD6C export
_RAM_DD6C_ db
.ende

.enum $DD6E export
_RAM_DD6E_ db
.ende

.enum $DD70 export
_RAM_DD70_ db
_RAM_DD71_ db
.ende

.enum $DD73 export
_RAM_DD73_ db
_RAM_DD74_ db
.ende

.enum $DD76 export
_RAM_DD76_ db
_RAM_DD77_ db
.ende

.enum $DD79 export
_RAM_DD79_ db
_RAM_DD7A_ db
.ende

.enum $DD7C export
_RAM_DD7C_ db
_RAM_DD7D_ db
.ende

.enum $DD7F export
_RAM_DD7F_ db
_RAM_DD80_ db
.ende

.enum $DD9A export
_RAM_DD9A_ db
_RAM_DD9B_ db
.ende

.enum $DD9E export
_RAM_DD9E_ db
.ende

.enum $DDA0 export
_RAM_DDA0_ db
_RAM_DDA1_ db
.ende

.enum $DDA3 export
_RAM_DDA3_ db
_RAM_DDA4_ db
.ende

.enum $DDA6 export
_RAM_DDA6_ db
_RAM_DDA7_ db
.ende

.enum $DDA9 export
_RAM_DDA9_ db
_RAM_DDAA_ db
.ende

.enum $DDAC export
_RAM_DDAC_ db
_RAM_DDAD_ db
.ende

.enum $DDAF export
_RAM_DDAF_ db
_RAM_DDB0_ db
.ende

.enum $DDCB export
_RAM_DDCB_ db
.ende

.enum $DDCE export
_RAM_DDCE_ db
.ende

.enum $DDD0 export
_RAM_DDD0_ db
_RAM_DDD1_ db
.ende

.enum $DDD3 export
_RAM_DDD3_ db
_RAM_DDD4_ db
.ende

.enum $DDD6 export
_RAM_DDD6_ db
_RAM_DDD7_ db
.ende

.enum $DDD9 export
_RAM_DDD9_ db
_RAM_DDDA_ db
.ende

.enum $DDDC export
_RAM_DDDC_ db
_RAM_DDDD_ db
.ende

.enum $DDDF export
_RAM_DDDF_ db
_RAM_DDE0_ db
.ende

.enum $DDFB export
_RAM_DDFB_ db
.ende

.enum $DDFE export
_RAM_DDFE_ db
.ende

.enum $DE00 export
_RAM_DE00_ db
_RAM_DE01_ db
.ende

.enum $DE03 export
_RAM_DE03_ db
_RAM_DE04_ db
.ende

.enum $DE06 export
_RAM_DE06_ db
_RAM_DE07_ db
.ende

.enum $DE09 export
_RAM_DE09_ db
_RAM_DE0A_ db
.ende

.enum $DE0C export
_RAM_DE0C_ db
_RAM_DE0D_ db
.ende

.enum $DE0F export
_RAM_DE0F_ db
_RAM_DE10_ db
.ende

.enum $DE2B export
_RAM_DE2B_ db
.ende

.enum $DE2E export
_RAM_DE2E_ db
_RAM_DE2F_ db
_RAM_DE30_ db
_RAM_DE31_ db
_RAM_DE32_ db
.ende

.enum $DE34 export
_RAM_DE34_ db
_RAM_DE35_ db
.ende

.enum $DE37 export
_RAM_DE37_ db
_RAM_DE38_ db
.ende

.enum $DE3D export
_RAM_DE3D_ db
.ende

.enum $DE40 export
_RAM_DE40_ db
_RAM_DE41_ db
_RAM_DE42_ db
_RAM_DE43_ db
_RAM_DE44_ db
_RAM_DE45_ db
_RAM_DE46_ db
_RAM_DE47_ db
_RAM_DE48_ db
_RAM_DE49_ db
_RAM_DE4A_ db
_RAM_DE4B_ db
_RAM_DE4C_ db
_RAM_DE4D_ db
_RAM_DE4E_ db
_RAM_DE4F_ db
_RAM_DE50_ db
_RAM_DE51_ db
_RAM_DE52_ db
_RAM_DE53_ db
_RAM_DE54_ db
_RAM_DE55_ db
_RAM_DE56_ db
_RAM_DE57_ db
.ende

.enum $DE59 export
_RAM_DE59_ db
.ende

.enum $DE5C export
_RAM_DE5C_ db
_RAM_DE5D_ db
_RAM_DE5E_ db
_RAM_DE5F_ db
_RAM_DE60_ db
_RAM_DE61_ db
_RAM_DE62_ db
.ende

.enum $DE64 export
_RAM_DE64_ db
.ende

.enum $DE66 export
_RAM_DE66_ db
_RAM_DE67_ db
_RAM_DE68_ db
_RAM_DE69_ db
_RAM_DE6A_ db
_RAM_DE6B_ db
_RAM_DE6C_ db
_RAM_DE6D_ db ; actually a dw?
_RAM_DE6E_ db
_RAM_DE6F_ db
_RAM_DE70_ db
_RAM_DE71_ dw
_RAM_DE73_ dw
_RAM_DE75_ dw
_RAM_DE77_ dw
_RAM_DE79_ dw
_RAM_DE7B_ dw
_RAM_DE7D_ db
.ende

.enum $DE7F export
_RAM_DE7F_ db
_RAM_DE80_ db
_RAM_DE81_ db
_RAM_DE82_ db
.ende

.enum $DE84 export
_RAM_DE84_ db
_RAM_DE85_ db
_RAM_DE86_ db
_RAM_DE87_ db
_RAM_DE88_ db
_RAM_DE89_ db
_RAM_DE8A_CarState2 db ; Car state?
_RAM_DE8B_ db
_RAM_DE8C_ db
_RAM_DE8D_ db
_RAM_DE8E_PageNumber db ; For restoring paging to "the one that's supposed to be there"
.ende

.enum $DE90 export
_RAM_DE90_CarDirection db
_RAM_DE91_CarDirectionPrevious db ; To detect changes
_RAM_DE92_EngineVelocity db ; Not necessarily how fast the car is going, but it is if there are no other factors.
.ende

.enum $DE94 export
_RAM_DE94_ dw
_RAM_DE96_ dw
.ende

.enum $DE99 export
_RAM_DE99_ db
_RAM_DE9A_ db
_RAM_DE9B_ db
_RAM_DE9C_ db
_RAM_DE9D_ db
_RAM_DE9E_ db
_RAM_DE9F_ db
_RAM_DEA0_ db
_RAM_DEA1_ db
_RAM_DEA2_ db
_RAM_DEA3_ db
_RAM_DEA4_ db
_RAM_DEA5_ dw
_RAM_DEA7_ db
_RAM_DEA8_ dw
_RAM_DEAA_ db
_RAM_DEAB_ db
_RAM_DEAC_ db
_RAM_DEAD_ db
_RAM_DEAE_ db
_RAM_DEAF_ db
_RAM_DEB0_ db
_RAM_DEB1_VScrollDelta db
_RAM_DEB2_ db
_RAM_DEB3_Player1AccelerationDelayCounter db
_RAM_DEB4_ db
_RAM_DEB5_ db
_RAM_DEB6_ db
_RAM_DEB7_ db
_RAM_DEB8_ db
_RAM_DEB9_ db
_RAM_DEBA_ db
_RAM_DEBB_ db
_RAM_DEBC_TileDataIndex db
_RAM_DEBD_TopRowTilemapAddress instanceof Word
_RAM_DEBF_ScreenHScrollColumn instanceof Word ; High byte is always 0
_RAM_DEC1_VRAMAddress instanceof Word
_RAM_DEC3_ScreenTilemapAddress instanceof Word
_RAM_DEC5_RectangleHeight db
_RAM_DEC6_ db
_RAM_DEC7_ db
_RAM_DEC8_ db
_RAM_DEC9_ db
_RAM_DECA_ db
_RAM_DECB_ db
_RAM_DECC_ db
_RAM_DECD_ db
_RAM_DECE_RectRowSkip db
_RAM_DECF_RectangleWidth dw ; High byte is always 0, could reduce to 8 bits on use
_RAM_DED1_MetatilemapPointer instanceof Word
_RAM_DED3_HScrollValue db
_RAM_DED4_VScrollValue db
_RAM_DED5_ db ; Metatile showing min X?
_RAM_DED6_ db
_RAM_DED7_ db ; Metatile showing max X?
_RAM_DED8_ db ; Metatile showing min Y?
_RAM_DED9_ db ; Metatile showing max Y?
_RAM_DEDA_ db
_RAM_DEDB_ db
_RAM_DEDC_ db
_RAM_DEDD_ db
_RAM_DEDE_ db
_RAM_DEDF_ dw
_RAM_DEE1_ db
.ende

.enum $DEE3 export
_RAM_DEE3_ db
.ende

.enum $DEE5 export
_RAM_DEE5_ dw
_RAM_DEE7_ db
.ende

.enum $DEE9 export
_RAM_DEE9_ db
.ende

.enum $DEEB export
_RAM_DEEB_ db
_RAM_DEEC_ db
_RAM_DEED_ db
.ende

.enum $DEF1 export
_RAM_DEF1_ db
_RAM_DEF2_ db
.ende

.enum $DEF4 export
_RAM_DEF4_ db
_RAM_DEF5_ db
_RAM_DEF6_ db
_RAM_DEF7_ db
_RAM_DEF8_FloorScrollingRateLimiter db
_RAM_DEF9_CurrentBehaviour db
_RAM_DEFA_PreviousBehaviour db
_RAM_DEFB_PreviousDifferentBehaviour db
_RAM_DEFC_TrackTypeCopy_WriteOnly db ; Seems not needed
_RAM_DEFD_TrackTypeHighBits db ; Used when we want to calculate TrackType*n, the high bits end up here
.ende

.enum $DF00 export
_RAM_DF00_ db
_RAM_DF01_ db
_RAM_DF02_ db
_RAM_DF03_ db
_RAM_DF04_ db
_RAM_DF05_ db
_RAM_DF06_ db
_RAM_DF07_ db
_RAM_DF08_ db
_RAM_DF09_ db
_RAM_DF0A_ db
_RAM_DF0B_ db
_RAM_DF0C_ db
_RAM_DF0D_ db
_RAM_DF0E_ db
_RAM_DF0F_ db
_RAM_DF10_ db
_RAM_DF11_ db
.ende

.enum $DF13 export
_RAM_DF13_RunCompressed_BitIndex db
_RAM_DF14_RunCompressed_LastWrittenByte db
_RAM_DF15_RunCompressedRawDataStartLo db
_RAM_DF16_RunCompressedRawDataStartHi db
_RAM_DF17_HaveFloorTiles db
_RAM_DF18_FloorTilesVRAMAddress dw
.ende

.enum $DF1C export
_RAM_DF1C_CopyToVRAMUpperBoundHi db
_RAM_DF1D_TileHighBytes_ConstantValue db
_RAM_DF1E_ db
_RAM_DF1F_HUDSpriteFlickerCounter db
_RAM_DF20_ db
_RAM_DF21_ db
_RAM_DF22_ db
.ende

.struct TournamentHUDSprites
LapCounter  db
FirstPlace  db
SecondPlace db
ThirdPlace  db
FourthPlace db
Digit1      db
Digit2      db
Digit3      db
Digit4      db
.endst

.enum $DF24 export
_RAM_DF24_LapsRemaining db
_RAM_DF25_ db
_RAM_DF26_ db
_RAM_DF27_ db
_RAM_DF28_ db
_RAM_DF29_ db
_RAM_DF2A_Positions instanceof FourPlayers_InGame ; Positions (0-3) for cars
_RAM_DF2E_HUDSpriteXs instanceof TournamentHUDSprites
_RAM_DF37_HUDSpriteNs instanceof TournamentHUDSprites
_RAM_DF40_HUDSpriteYs instanceof TournamentHUDSprites
.ende

.enum $DF4F export
_RAM_DF4F_ db
_RAM_DF50_ db
_RAM_DF51_ db
_RAM_DF52_ db
_RAM_DF53_ dw
_RAM_DF55_ db
_RAM_DF56_ db
_RAM_DF57_ db
_RAM_DF58_ db
_RAM_DF59_CarState db ; 3 = falling, ..?
_RAM_DF5A_CarState3 db
_RAM_DF5B_ db
_RAM_DF5C_ db
_RAM_DF5D_ db
_RAM_DF5E_ db
_RAM_DF5F_ db
_RAM_DF60_ db
_RAM_DF61_ db
_RAM_DF62_ db
_RAM_DF63_ db
_RAM_DF64_ db
_RAM_DF65_ db
_RAM_DF66_ db
_RAM_DF67_ db
_RAM_DF68_ db
_RAM_DF69_ db
_RAM_DF6A_ db
_RAM_DF6B_ db
_RAM_DF6C_ db
_RAM_DF6D_ db
_RAM_DF6E_ db
_RAM_DF6F_RuffTruxTimer_TensOfSeconds db
_RAM_DF70_RuffTruxTimer_Seconds db
_RAM_DF71_RuffTruxTimer_Tenths db
_RAM_DF72_RuffTruxTimer_Frames db
_RAM_DF73_ db
_RAM_DF74_RuffTruxSubmergedCounter db
_RAM_DF75_PaletteAnimationIndex db
_RAM_DF76_PaletteAnimationCounter db
_RAM_DF77_PaletteAnimationData dw
_RAM_DF79_CurrentCombinedByte db
_RAM_DF7A_ db
_RAM_DF7B_ db
_RAM_DF7C_ db
_RAM_DF7D_ db
_RAM_DF7E_ db
_RAM_DF7F_ db
_RAM_DF80_TwoPlayerWinPhase db
_RAM_DF81_ db
_RAM_DF82_ db
_RAM_DF83_ db
_RAM_DF84_ db
_RAM_DF85_ db
_RAM_DF86_ db
_RAM_DF87_ db
_RAM_DF88_ db
_RAM_DF89_ db
_RAM_DF8A_ dw
_RAM_DF8C_RuffTruxRanOutOfTime db
_RAM_DF8D_ db
_RAM_DF8E_ db
_RAM_DF8F_ dw
_RAM_DF91_ db
_RAM_DF92_ db
_RAM_DF93_ dw
_RAM_DF95_ db
_RAM_DF96_ db
_RAM_DF97_ db
_RAM_DF98_CarTileLoaderCounter db
_RAM_DF99_ db
_RAM_DF9A_EndOfRAM .db
.ende

.BANK 0 SLOT 0
.ORG $0000

;.section "Entry" force
  di
  ld hl, STACK_TOP
  ld sp, hl
  call LABEL_100_Startup ; Copies things to RAM and more
  xor a
  ld (_RAM_DC41_GearToGearActive), a
  ld a, :LABEL_8000_Main
  ld (PAGING_REGISTER), a
  jp LABEL_8000_Main
;.ends

;.section "Transitions"

LABEL_14_EnterMenus:
  ; Code jumps here when transitioning from game to menus
  di
  ld a, :LABEL_8021_MenuScreenEntryPoint
  ld (PAGING_REGISTER), a
  ld a, 1
  ld (_RAM_DC3E_InMenus), a
  ld hl, STACK_TOP
  ld sp, hl
  jp LABEL_8021_MenuScreenEntryPoint

.ifdef BLANK_FILL_ORIGINAL
.db "P HL", 13, 10, 9, "INC HL", 13, 10, 9, "LD" ; Source code left in RAM
.endif

;.ends

.org $0038
;.section "VBlank handler" force
LABEL_38_:
  push af
    ld a, (_RAM_DC3E_InMenus)
    or a
    jr z, ++
    cp $01
    jr z, +
.ifdef UNNECESSARY_CODE
    ; Unreachable code
    in a, (PORT_VDP_STATUS) ; Ack INT
  pop af
  ei
  reti
.endif

+:; In menus
  pop af
  JumpToRamCode LABEL_3BAF1_MenusVBlank

++:; In game
  pop af
  call LABEL_199_GameVBlank
  ei
  reti

.ifdef BLANK_FILL_ORIGINAL
.db " (CH2MAP2+9),A", 13, 10, 9, "L" ; Source code left in RAM
.endif

;.ends

.org $0066
;.section "Pause/Gear To Gear handler" force
LABEL_66_NMI:
  push af
.ifdef GAME_GEAR_CHECKS
    ld a, (_RAM_DC3C_IsGameGear)
    or a
    jp nz, LABEL_9BF_NMI_GG
    jp LABEL_517F_NMI_SMS
.else
.ifdef IS_GAME_GEAR
    jp LABEL_9BF_NMI_GG
.else
    jp LABEL_517F_NMI_SMS
.endif
.endif

.ifdef BLANK_FILL_ORIGINAL
.db "9),A" ; Source code left in RAM
.endif

;.ends

;.section "Enter game trampoline and data"
; Executed in RAM at dbc0
LABEL_75_MenuRAMSection:
LABEL_75_EnterGameTrampolineImpl:
  ld a, $00
  ld (PAGING_REGISTER_Slot0), a
  ld a, $01
  ld (PAGING_REGISTER_Slot1), a
  jp LABEL_7573_EnterGame

; Copied to $dbcd onwards
; This initialises a bunch of stuff...
; _RAM_DBCD_MenuIndex onwards
.db MenuIndex_0_TitleScreen ; _RAM_DBCD_MenuIndex
.db $01 ; _RAM_DBCE_Player1Qualified
.db $01 ; _RAM_DBCF_LastRacePosition
.db $00 ; _RAM_DBD0_LastRacePosition_Player2
.db $03 ; _RAM_DBD1_LastRacePosition_Player3
.db $02 ; _RAM_DBD2_LastRacePosition_Player4
.db $50 ; _RAM_DBD3_PlayerPortraitBeingDrawn
.db PlayerPortrait_Cherry ; _RAM_DBD4_Player1Character ; all 4 changed shortly
.db PlayerPortrait_Chen ; _RAM_DBD5_Player2Character
.db PlayerPortrait_Chen; _RAM_DBD6_Player3Character
.db PlayerPortrait_Chen ; _RAM_DBD7_Player4Character
.db $00 ; _RAM_DBD8_TrackIndex_Menus
.dsb 24 0 ; _RAM_DBD9_DisplayCaseData
.asc "RACE 01-" ; _RAM_DBF1_RaceNumberText
LABEL_75_MenuRAMSectionEnd:
; End stuff copied to RAM
;.ends

.org $00ae
;.section "Enter menu trampoline" force
; Copied to RAM $dc99..$dcaa
LABEL_AE_EnterMenuTrampolineImpl:
  di
  ld a,:LABEL_8000_Main
  ld (PAGING_REGISTER),a
  ld a, 1
  ld (_RAM_DC3E_InMenus),a
  ld hl, STACK_TOP
  ld sp, hl
  jp LABEL_8000_Main
LABEL_AE_EnterMenuTrampolineImplEnd:
;.ends

.org $00c0
;.section "Floor tiles" force
DATA_C0_FloorTilesRawTileData:
.incbin "Assets/Formula One/Floor.4bpp"
DATA_C0_FloorTilesRawTileDataEnd:
;.ends

.org $100
;.section "Startup" force
LABEL_100_Startup:
  ; Blank RAM
  ld hl, _RAM_C000_StartOfRam
  ld bc, _RAM_DF9A_EndOfRAM - _RAM_C000_StartOfRam ; $1F9A ; Not all of it - but exactly what we use
-:xor a
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -

  ; Load trampolines to RAM
  ld hl, _RAM_DBC0_EnterGameTrampoline
  ld de, LABEL_75_MenuRAMSection  ; Loading Code and data into RAM
  ld bc, LABEL_75_MenuRAMSectionEnd - LABEL_75_MenuRAMSection
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  call LABEL_173_LoadEnterMenuTrampolineToRAM

  ld hl, _RAM_DC59_FloorTiles ; Fill floor tiles buffer with data
  ld de, DATA_C0_FloorTilesRawTileData
  ld bc, DATA_C0_FloorTilesRawTileDataEnd - DATA_C0_FloorTilesRawTileData
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  call LABEL_186_InitialiseSoundData
  ; More RAM initialisation
  ld a, $01
  ld (_RAM_DBA8_), a
  ld a, 32
  ld (_RAM_DB9C_MetatilemapWidth), a
  ld (_RAM_DB9E_), a
  ld hl, _RAM_DB22_
  ld (_RAM_DB62_), hl
  ld hl, _RAM_DB42_
  ld (_RAM_DB64_), hl
  ld a, Track_1A_RuffTrux1
  ld (_RAM_DC39_NextRuffTruxTrack), a
  ; fall through
  
LABEL_156_SetSystemAndAdjustments:
.ifdef GAME_GEAR_CHECKS
  ld a, $00
  ld (_RAM_DC54_IsGameGear), a ; Set to SMS mode
  or a
  jr z, +
  ; TODO what are these?
  ld a, $05
  ld (_RAM_DC56_), a ; If GG
  ld a, $28
  ld (_RAM_DC57_), a
  JpRet ++
+:xor a
  ld (_RAM_DC56_), a ; If SMS
  ld (_RAM_DC57_), a
++:ret
.else
.ifdef IS_GAME_GEAR
  ld a, $05
  ld (_RAM_DC56_), a ; If GG
  ld a, $28
  ld (_RAM_DC57_), a
.else
  xor a
  ld (_RAM_DC56_), a ; If SMS
  ld (_RAM_DC57_), a
.endif
  ret
.endif

LABEL_173_LoadEnterMenuTrampolineToRAM:
  ; Copy some code to RAM
  ld hl, _RAM_DC99_EnterMenuTrampoline
  ld de, LABEL_AE_EnterMenuTrampolineImpl
  ld bc, LABEL_AE_EnterMenuTrampolineImplEnd - LABEL_AE_EnterMenuTrampolineImpl
  ; Could ldir?
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

LABEL_186_InitialiseSoundData:
  ld hl, _RAM_D94C_SoundData
  ld de, DATA_650C_SoundInitialisationData
  ld bc, DATA_650C_SoundInitialisationData_End - DATA_650C_SoundInitialisationData
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

LABEL_199_GameVBlank:
  push af
    ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
    or a
    jr nz, LABEL_1E0_SkipVBlank
    push hl
    push bc
    push de
    push ix
    push iy
      ld a, (DATA_BFFF_Page2PageNumber)
      push af
        ld a, (_RAM_D5B5_EnableGameVBlank)
        or a
        jr z, +
        xor a
        ld (_RAM_D580_WaitingForGameVBlank), a
        call LABEL_33A_GameVBlankVDPWork
        ld a, (_RAM_DC41_GearToGearActive)
        or a
        jr nz, +
        ld a, (_RAM_D599_IsPaused)
        or a
        jr nz, +
        call LABEL_5169_GameVBlankEngineUpdateTrampoline
        call LABEL_5174_GameVBlankPart3Trampoline
        CallPagedFunction LABEL_2B5D2_GameVBlankUpdateSoundTrampoline
+:    pop af
      ld (PAGING_REGISTER), a
    pop iy
    pop ix
    pop de
    pop bc
    pop hl
LABEL_1E0_SkipVBlank:
    in a, (PORT_VDP_STATUS) ; Ack INT
  pop af
  ret

LABEL_1E4_:
  call LABEL_519D_
  ld a, (_RAM_D599_IsPaused)
  or a
  jp nz, LABEL_29D_
  ld a, (_RAM_DF7F_)
  or a
  call nz, LABEL_AB1_
  call LABEL_12D5_
  call LABEL_12BF_
  call LABEL_11BA_
  call LABEL_12CA_
  ld a, (_RAM_D5B6_)
  or a
  call nz, LABEL_65C7_
  ld a, (_RAM_D5B7_)
  or a
  call nz, LABEL_B04_
  call LABEL_F9B_
  call LABEL_22CD_
  call LABEL_265F_
  call LABEL_5E3A_
  call LABEL_648E_
  call LABEL_49C9_
  call LABEL_4465_
  call LABEL_44C3_
  call LABEL_4622_
  call LABEL_479E_
  call LABEL_6756_
  call LABEL_6A97_
  call LABEL_6A6C_
  call LABEL_6A8C_
  ld a, (_RAM_D940_)
  cp $02
  call z, LABEL_A9D_
  ld a, (_RAM_D945_)
  cp $02
  call z, LABEL_AA7_
  xor a
  ld (_RAM_DD9B_), a
  ld (_RAM_DDCB_), a
  ld (_RAM_DDFB_), a
  ld (_RAM_DE2B_), a
  call LABEL_27B1_
  call LABEL_1DF2_
  call LABEL_3164_
  call LABEL_317C_
  call LABEL_343A_
  call LABEL_3445_
  call LABEL_3F3F_
  call LABEL_523B_
  call LABEL_3D59_
  call LABEL_3DBD_
  call LABEL_AC5_
  call LABEL_2857_
  call LABEL_ABB_
  call LABEL_5A88_
  call LABEL_AF5_
  call LABEL_1593_
  call LABEL_16C0_
  call LABEL_318_CheckForGearToGearWork
  call LABEL_4927_
  CallPagedFunction LABEL_371F1_
  call LABEL_318_CheckForGearToGearWork
LABEL_29D_:
  call LABEL_3450_
  call LABEL_35E0_
  call LABEL_318_CheckForGearToGearWork
  call LABEL_73D4_UpdateHUDSprites
  call LABEL_318_CheckForGearToGearWork
  call LABEL_84A_
  call LABEL_318_CheckForGearToGearWork
  call LABEL_3A23_
  call LABEL_6540_
  ld a, (_RAM_D5CB_)
  or a
  call nz, LABEL_7B0B_
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, +
  in a, (PORT_VDP_LINECOUNTER)
  cp $B8
  jr nc, LABEL_315_
+:
  call LABEL_64C9_
  call LABEL_2D63_
  call LABEL_318_CheckForGearToGearWork
  ld a, (_RAM_D599_IsPaused)
  or a
  jr nz, LABEL_300_
  ; Stuff we only do when not paused...
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  ; ...and not Gear to Gear...
  call LABEL_5169_GameVBlankEngineUpdateTrampoline
  call LABEL_5174_GameVBlankPart3Trampoline
  call LABEL_318_CheckForGearToGearWork
  CallPagedFunction LABEL_2B5D2_GameVBlankUpdateSoundTrampoline
  call LABEL_318_CheckForGearToGearWork
+:
  call LABEL_BF0_UpdateFloorTiles
  call LABEL_AE1_InGameCheatHandlerTrampoline
  call LABEL_318_CheckForGearToGearWork
LABEL_300_:
  ld a, (_RAM_DF6A_)
  or a
  JrZRet + ; ret
  dec a
  ld (_RAM_DF6A_), a
  or a
  JrNzRet + ; ret
  inc a
  ld (_RAM_DF6A_), a
  ld (_RAM_D5D6_), a
+:ret

LABEL_315_:
  jp LABEL_300_

LABEL_318_CheckForGearToGearWork:
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  ret z
  ; If in Gear to Gear mode and I am player 1...
  ld a, (_RAM_D5D7_GearToGearVBlankWorkDone)
  or a
  ret nz
  ; And work hasn't been done yet...
  in a, (PORT_VDP_LINECOUNTER)
  cp $B8
  JrCRet + ; ret
  cp $F0
  JrNcRet + ; ret
  ; Do the VBlank work if between these lines
  call LABEL_33A_GameVBlankVDPWork
  ld a, $01
  ld (_RAM_D5D7_GearToGearVBlankWorkDone), a
+:ret

-:xor a
  ld (_RAM_DBA8_), a
  ret

LABEL_33A_GameVBlankVDPWork:
  ld a, (_RAM_DBA8_)
  cp $01
  jr z, -
  call LABEL_7795_ScreenOff
  call LABEL_78CE_
  call LABEL_7916_

  ; Update scroll registers
  ld a, (_RAM_DED4_VScrollValue)
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_YSCROLL
  out (PORT_VDP_REGISTER), a
  ld a, (_RAM_DED3_HScrollValue)
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_XSCROLL
  out (PORT_VDP_REGISTER), a

  call LABEL_31F1_UpdateSpriteTable
  call LABEL_324C_UpdatePerFrameTiles
  ld a, (_RAM_D5CC_PlayoffTileLoadFlag)
  or a
  jr z, +
  CallPagedFunction LABEL_17E95_LoadPlayoffTiles ; Call only when flag is set, then reset it
  xor a
  ld (_RAM_D5CC_PlayoffTileLoadFlag), a
+:call LABEL_BC5_UpdateFloorTiles
  call LABEL_2D07_UpdatePalette_RuffTruxSubmerged
  call LABEL_3FB4_UpdateAnimatedPalette
  jp LABEL_778C_ScreenOn

LABEL_383_EnterGame_Part2:
  call LABEL_3ED_EnterGamePart2a
--:
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr nz, +
  call LABEL_AFD_ReadControls
  ; Wait for VBlank
-:ld a, (_RAM_D580_WaitingForGameVBlank)
  or a
  jr nz, -
  xor a
  ld (_RAM_D5B5_EnableGameVBlank), a
  call LABEL_1E4_
  ld a, (_RAM_D5D6_)
  or a
  jp nz, LABEL_7476_PrepareResultsScreen
  ld a, $01
  ld (_RAM_D580_WaitingForGameVBlank), a
  ld (_RAM_D5B5_EnableGameVBlank), a
  jp --

+:
  ld hl, $0800 ; Busy wait
-:dec hl
  ld a, h
  or l
  jr nz, -
  ld (_RAM_D5D8_), a ; Then set to 0
--:
  ld a, (_RAM_D5D6_)
  or a
  jp nz, LABEL_7476_PrepareResultsScreen
  ld a, (_RAM_D5D8_)
  or a
  jr z, --
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  out (PORT_GG_LinkSend), a
  xor a
  ld (_RAM_D5D7_GearToGearVBlankWorkDone), a
  ld (_RAM_D5D8_), a
  call LABEL_AFD_ReadControls
  call LABEL_1E4_
  ld a, (_RAM_D5D7_GearToGearVBlankWorkDone)
  or a
  jr nz, --
-:
  in a, (PORT_VDP_LINECOUNTER)
  cp $B8
  jr c, -
  cp $F0
  jr nc, -
  call LABEL_33A_GameVBlankVDPWork
  jr --

LABEL_3ED_EnterGamePart2a:
  call LABEL_318E_InitialiseVDPRegisters_Trampoline
  call LABEL_3F22_ScreenOff
  call LABEL_3F54_BlankGameRAM
  call LABEL_19EE_
  call LABEL_7C7D_LoadTrack
  call LABEL_3A2E_SetShadowSpriteIndices
  call LABEL_31B6_InitialiseFloorTiles
  call LABEL_3C54_InitialiseHUDData
  call LABEL_458_PatchForLevelTrampoline
  call LABEL_51A8_ClearTilemapTrampoline
  call LABEL_1345_DrawGameFullScreen
  call LABEL_77CD_ComputeScreenTilemapAddress
  call LABEL_1801_
  call LABEL_3231_BlankDecoratorTiles
  call LABEL_3F2B_BlankGameRAMTrampoline
  call LABEL_3199_
  call LABEL_AEB_GetPlayerHandicapsTrampoline
  call LABEL_7564_SetControlsToNoButtons
  call LABEL_186_InitialiseSoundData
  call ++
  ld a, $0A
  ld (_RAM_D96F_), a
  ld a, $01
  ld (_RAM_D5B5_EnableGameVBlank), a
  xor a
  ld (_RAM_D946_), a
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, $38
  out (PORT_GG_LinkStatus), a
  call LABEL_7564_SetControlsToNoButtons
  call LABEL_AD7_DelayIfPlayer2Trampoline
+:
.else
.ifdef IS_GAME_GEAR
  ld a, $38
  out (PORT_GG_LinkStatus), a
  call LABEL_7564_SetControlsToNoButtons
  call LABEL_AD7_DelayIfPlayer2Trampoline
.endif
.endif
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr nz, +
  call LABEL_3F36_ScreenOn
  im 1
  ei
  ret

+:
  im 1
  di
  ret

LABEL_458_PatchForLevelTrampoline:
  JumpToPagedFunction LABEL_36484_PatchForLevel

++:
  JumpToPagedFunction LABEL_2B5D5_SilencePSG

DATA_46E_: ; 4 bytes per entry * 16 entries
  SignAndMagnitude  $04,  $17,  $0C,  $17
  SignAndMagnitude -$01,  $13,  $06,  $16
  SignAndMagnitude -$04,  $0F,  $02,  $15
  SignAndMagnitude -$06,  $0B, -$03,  $12
  SignAndMagnitude -$07,  $04, -$07,  $0C
  SignAndMagnitude -$03, -$02, -$06,  $05
  SignAndMagnitude  $02, -$05, -$04,  $01
  SignAndMagnitude -$01, -$03,  $06, -$06
  SignAndMagnitude  $04, -$07,  $0C, -$07
  SignAndMagnitude  $0A, -$06,  $11, -$03
  SignAndMagnitude  $0E, -$05,  $14,  $01
  SignAndMagnitude  $13, -$02,  $16,  $05
  SignAndMagnitude  $17,  $04,  $17,  $0C
  SignAndMagnitude  $16,  $0B,  $13,  $12
  SignAndMagnitude  $14,  $0F,  $0E,  $15
  SignAndMagnitude  $11,  $13,  $0A,  $16

DATA_4AE_SixTimesTable:
  TimesTableLo 0 6 3 ; 0, 6, 12

DATA_4B1_Constant_3:
.db 3

LABEL_4B2_:
  ld a, (iy+24)
  or a
  jr z, +
  sub $01
  ld (iy+24), a
  ret

+:
  ld a, (DATA_4B1_Constant_3) ; Constant!
  ld (iy+24), a

  ld a, (iy+25)
  ld e, a
  ld d, $00
  ld hl, DATA_4AE_SixTimesTable ; (iy+25) * 6
  add hl, de
  ld a, (hl)
  ld e, a
  ld d, $00
  add ix, de ; Add that to ix
  ld a, (iy+21)
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_46E_ ; Look up DATA_46E_[(iy+21)*4]
  add hl, de
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld c, $04 ; Extra constant for RuffTrux
  jp ++
+:ld c, $00
++:
  ld a, (hl)  ; Read first byte
  ld b, a     ; -> b
  and $80     ; Check high bit
  jr z, +
  ld a, b     ; High bit set
  and $7F     ; Mask it off
  ld b, a
  ld a, (iy+22) ; Subtract value
  sub b       ; Add constant
  add a, c
  ld (ix+0), a ; ix+0 = iy+22 - b + c
  jp ++

+:; High bit unset
  ld a, (iy+22)
  add a, b    ; Add value
  add a, c    ; Add constant
  ld (ix+0), a ; ix+0 = iy+22 + b + c
++:
  inc hl      ; Next byte
  ld a, (hl)
  ld b, a
  and $80     ; High bit is sign again
  jr z, +
  ld a, b
  and $7F
  ld b, a
  ld a, (iy+23) ; ix+2 = iy+23 (+/-) b - c
  sub b
  add a, c
  ld (ix+2), a
  jp ++
+:ld a, (iy+23)
  add a, b
  add a, c
  ld (ix+2), a

++:
  inc hl      ; Next byte: ix+3 = iy+22 (+/-) b + c
  ld a, (hl)
  ld b, a
  and $80
  jr z, +
  ld a, b
  and $7F
  ld b, a
  ld a, (iy+22)
  sub b
  add a, c
  ld (ix+3), a
  jp ++
+:ld a, (iy+22)
  add a, b
  add a, c
  ld (ix+3), a
++:
  inc hl    ; Last one: ix+5 = iy+23 (+/-) b + c
  ld a, (hl)
  ld b, a
  and $80
  jr z, +
  ld a, b
  and $7F
  ld b, a
  ld a, (iy+23)
  sub b
  add a, c
  ld (ix+5), a
  jp ++
+:ld a, (iy+23)
  add a, b
  add a, c
  ld (ix+5), a
++:
  ; All done
  ; ix += 36 -> ???
  ld de, $001A
  add ix, de
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ; Powerboats only: ???
  xor a
  ld (iy+44), a
  ld a, (iy+47)
  xor $01
  ld (iy+45), a
+:
  ld a, (iy+45)
  or a
  jr z, +
  ld a, (iy+46)
  or a
  jr nz, +
  ld a, (iy+23)
  cp $F0
  jr nc, +
  cp $10
  jr c, +
  ld a, (iy+22)
  cp $10
  jr c, +
  cp $F0
  jr nc, +
  ld a, $01
  jp ++
+:xor a
++:
  ld (ix+0), a
  ld a, (iy+44)
  ld (ix+1), a
  xor a
  ld (ix+2), a
  ld (ix+3), a
  ld a, (iy+25)
  cp $02
  jr z, +
  add a, $01
-:
  ld (iy+25), a
  ret

+:
  xor a
  jp -

.ifdef JUMP_TO_RET
_LABEL_5C8_ret:
  ret
.endif

LABEL_5C9_:
  ld iy, _RAM_DD6E_
  ld ix, _RAM_DD6E_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (iy+21), a
  ld a, (_RAM_DBA4_)
  ld (iy+22), a
  ld a, (_RAM_DBA5_)
  ld (iy+23), a
  ld a, $01
  ld (iy+19), a
  ld a, (_RAM_DF00_)
  ld (iy+46), a
  ld a, (_RAM_DF58_)
  ld (iy+47), a
  call LABEL_4B2_
  jp LABEL_69C_

LABEL_5FA_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrZRet _LABEL_5C8_ret ; 7 when nz, 12+10 otherwise; ret z = 5/11 so always better(!)
  ld iy, _RAM_DD9E_
  ld ix, _RAM_DD9E_
  ld a, (_RAM_DCB8_)
  ld (iy+21), a
  ld a, (_RAM_DCBC_)
  ld (iy+22), a
  ld a, (_RAM_DCBD_)
  ld (iy+23), a
  ld a, (_RAM_DCC0_)
  ld (iy+19), a
  ld a, (_RAM_DCBF_)
  ld (iy+46), a
  ld a, (_RAM_DCD9_)
  ld (iy+47), a
  call LABEL_4B2_
  jp LABEL_69C_

LABEL_633_:
  ld iy, _RAM_DDCE_
  ld ix, _RAM_DDCE_
  ld a, (_RAM_DCF9_)
  ld (iy+21), a
  ld a, (_RAM_DCFD_)
  ld (iy+22), a
  ld a, (_RAM_DCFE_)
  ld (iy+23), a
  ld a, (_RAM_DD01_)
  ld (iy+19), a
  ld a, (_RAM_DD00_)
  ld (iy+46), a
  ld a, (_RAM_DD1A_)
  ld (iy+47), a
  call LABEL_4B2_
  jp LABEL_69C_

LABEL_665_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JpZRet _LABEL_5C8_ret

  ; Challenge
  ld iy, _RAM_DDFE_
  ld ix, _RAM_DDFE_
  ld a, (_RAM_DD3A_)
  ld (iy+21), a
  ld a, (_RAM_DD3E_)
  ld (iy+22), a
  ld a, (_RAM_DD3F_)
  ld (iy+23), a
  ld a, (_RAM_DD42_)
  ld (iy+19), a
  ld a, (_RAM_DD41_)
  ld (iy+46), a
  ld a, (_RAM_DD5B_)
  ld (iy+47), a
  call LABEL_4B2_
LABEL_69C_:
  ld a, (iy+18)
  ld c, a
  ld b, $00
  ld hl, _RAM_DA60_SpriteTableXNs
  add hl, bc
  add hl, bc
  ex de, hl
  ld hl, _RAM_DAE0_SpriteTableYs
  add hl, bc
  ld a, (iy+20)
  add a, $01
  cp $03
  jr nz, +
  xor a
+:ld (iy+20), a
  or a
  jr z, +
  cp $01
  jr z, LABEL_702_
  call LABEL_7DD_SetCarEffectSpriteIndices
  ld a, (iy+12)
  ld (de), a
  inc de
  ld a, (iy+13)
  ld (de), a
  inc de
  ld a, (iy+14)
  ld (hl), a
  inc hl
  ld a, (iy+15)
  ld (de), a
  inc de
  ld a, (iy+16)
  ld (de), a
  inc de
  ld a, (iy+17)
  ld (hl), a
  ret

+:
  call LABEL_723_SetCarEffectSpriteIndices
  ld a, (iy+0)
  ld (de), a
  inc de
  ld a, (iy+1)
  ld (de), a
  inc de
  ld a, (iy+2)
  ld (hl), a
  inc hl
  ld a, (iy+3)
  ld (de), a
  inc de
  ld a, (iy+4)
  ld (de), a
  inc de
  ld a, (iy+5)
  ld (hl), a
  ret

LABEL_702_:
  call LABEL_780_SetCarEffectSpriteIndices
  ld a, (iy+6)
  ld (de), a
  inc de
  ld a, (iy+7)
  ld (de), a
  inc de
  ld a, (iy+8)
  ld (hl), a
  inc hl
  ld a, (iy+9)
  ld (de), a
  inc de
  ld a, (iy+10)
  ld (de), a
  inc de
  ld a, (iy+11)
  ld (hl), a
  ret

LABEL_723_SetCarEffectSpriteIndices:
  ld a, (iy+19) ; Enabled 1?
  or a
  jr z, LABEL_76B_BlankCarEffects
  ld a, (iy+26) ; Enabled 2?
  or a
  jr z, LABEL_76B_BlankCarEffects
  push hl
    ld a, (iy+27) ; 0 for dust, 1 for liquid
    sla a ; -> offset by 4
    sla a
    ld c, a
    ld b, $00
    ld a, (_RAM_DB97_TrackType)
    cp TT_7_RuffTrux
    jr nz, +
    ld hl, DATA_842_EffectTileIndices_RuffTrux
    jp ++
+:  ld hl, DATA_83A_EffectTileIndices
++: add hl, bc
    ld a, (iy+28) ; Animation counter
    ld c, a
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (iy+1), a ; Set tile index
    ld (iy+4), a
    ld a, c ; Cycle counter
    cp $03
    jr z, +
    add a, $01
    ld (iy+28), a
  pop hl
  ret

+:  xor a
    ld (iy+26), a
  pop hl
  ret

LABEL_76B_BlankCarEffects:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld a, SpriteIndex_RuffTrux_Blank ; RuffTrux
  jp ++
+:ld a, <SpriteIndex_Blank ; Not RuffTrux
++:
  ld (iy+1), a
  ld (iy+4), a
  ret

; Same as LABEL_723_SetCarEffectSpriteIndices except offsets are different
LABEL_780_SetCarEffectSpriteIndices:
  ld a, (iy+19)
  or a
  jr z, _LABEL_7C8_BlankCarEffects
  ld a, (iy+32)
  or a
  jr z, _LABEL_7C8_BlankCarEffects
  push hl
    ld a, (iy+33)
    sla a
    sla a
    ld c, a
    ld b, $00
    ld a, (_RAM_DB97_TrackType)
    cp TT_7_RuffTrux
    jr nz, +
    ld hl, DATA_842_EffectTileIndices_RuffTrux
    jp ++
+:  ld hl, DATA_83A_EffectTileIndices
++: add hl, bc
    ld a, (iy+34)
    ld c, a
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (iy+7), a
    ld (iy+10), a
    ld a, c
    cp $03
    jr z, +
    add a, $01
    ld (iy+34), a
  pop hl
  ret

+:  xor a
    ld (iy+32), a
  pop hl
  ret

_LABEL_7C8_BlankCarEffects:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld a, SpriteIndex_RuffTrux_Blank ; RuffTrux
  jp ++
+:ld a, <SpriteIndex_Blank ; Not RuffTrux
++:
  ld (iy+7), a
  ld (iy+10), a
  ret

; Same as LABEL_723_SetCarEffectSpriteIndices except offsets are different
LABEL_7DD_SetCarEffectSpriteIndices:
  ld a, (iy+19)
  or a
  jr z, _LABEL_825_BlankCarEffects
  ld a, (iy+38)
  or a
  jr z, _LABEL_825_BlankCarEffects
  push hl
    ld a, (iy+39) ; Effect type: 0 = dust, 1 = liquid
    sla a
    sla a
    ld c, a
    ld b, $00
    ld a, (_RAM_DB97_TrackType)
    cp TT_7_RuffTrux
    jr nz, +
    ld hl, DATA_842_EffectTileIndices_RuffTrux
    jp ++
+:  ld hl, DATA_83A_EffectTileIndices
++: add hl, bc
    ld a, (iy+40) ; Effect counter
    ld c, a
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (iy+13), a
    ld (iy+16), a
    ld a, c ; Loop counter 0..3
    cp $03
    jr z, +
    add a, $01
    ld (iy+40), a
  pop hl
  ret

+:  xor a
    ld (iy+38), a
  pop hl
  ret

_LABEL_825_BlankCarEffects:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld a, SpriteIndex_RuffTrux_Blank ; RuffTrux
  jp ++
+:ld a, <SpriteIndex_Blank ; Not RuffTrux
++:ld (iy+13), a
  ld (iy+16), a
  ret

; Which tiles to use for dust trails (animated)
DATA_83A_EffectTileIndices:
.db <SpriteIndex_Dust + 0
.db <SpriteIndex_Dust + 1
.db <SpriteIndex_Dust + 2
.db <SpriteIndex_Blank

.db <SpriteIndex_Splash + 2 ; We play these backwards (!)
.db <SpriteIndex_Splash + 1
.db <SpriteIndex_Splash + 0
.db <SpriteIndex_Blank

DATA_842_EffectTileIndices_RuffTrux:
.db SpriteIndex_RuffTrux_Water1
.db SpriteIndex_RuffTrux_Water2
.db SpriteIndex_RuffTrux_Blank2
.db SpriteIndex_RuffTrux_Blank

.db SpriteIndex_RuffTrux_Water1
.db SpriteIndex_RuffTrux_Water2
.db SpriteIndex_RuffTrux_Blank2
.db SpriteIndex_RuffTrux_Blank

LABEL_84A_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jp z, LABEL_97C_RuffTrux

  ; Not RuffTrux
  ld a, (_RAM_DF65_)
  or a
  jr z, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DBA4_)
  ld (_RAM_DF66_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DF67_), a
  ld a, (_RAM_DF2A_Positions.Red)
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  call LABEL_97F_
  jp ++

+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  call LABEL_6611_Tanks
  jp ++
+:call LABEL_5C9_ ; Not tanks
++:ld a, (_RAM_DCC5_)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_8DC_
  ld a, (_RAM_DCBC_)
  ld (_RAM_DF66_), a
  ld a, (_RAM_DCC0_)
  cp $01
  jr z, +
  ld a, $F0
  jp ++
+:ld a, (_RAM_DCBD_)
++:ld (_RAM_DF67_), a
  ld a, (_RAM_DF2A_Positions.Green)
  ld ix, _RAM_DA60_SpriteTableXNs.59
  ld iy, _RAM_DAE0_SpriteTableYs.59
  call LABEL_97F_
  jp LABEL_8DC_
+++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_8DC_
  call LABEL_661C_
  jp LABEL_8DC_

+:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, LABEL_8DC_
  call LABEL_5FA_
LABEL_8DC_:
  ld a, (_RAM_DD06_)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_92D_
  ld a, (_RAM_DCFD_)
  ld (_RAM_DF66_), a
  ld a, (_RAM_DD01_)
  cp $01
  jr z, +
  ld a, $F0
  jp ++

+:
  ld a, (_RAM_DCFE_)
++:
  ld (_RAM_DF67_), a
  ld a, (_RAM_DF2A_Positions.Blue)
  ld ix, _RAM_DA60_SpriteTableXNs.61
  ld iy, _RAM_DAE0_SpriteTableYs.61
  call LABEL_97F_
  jp LABEL_92D_

+++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  call LABEL_6627_
  jp LABEL_92D_

+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, LABEL_92D_
+:
  call LABEL_633_
LABEL_92D_:
  ld a, (_RAM_DD47_)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet _LABEL_97B_ret
  ld a, (_RAM_DD3E_)
  ld (_RAM_DF66_), a
  ld a, (_RAM_DD42_)
  cp $01
  jr z, +
  ld a, $F0
  jp ++

+:
  ld a, (_RAM_DD3F_)
++:
  ld (_RAM_DF67_), a
  ld a, (_RAM_DF2A_Positions.Yellow)
  ld ix, _RAM_DA60_SpriteTableXNs.63
  ld iy, _RAM_DAE0_SpriteTableYs.63
  jp LABEL_97F_

+++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet _LABEL_97B_ret
  TailCall LABEL_6632_ _LABEL_97B_ret

+:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  JrNzRet _LABEL_97B_ret
  jp LABEL_665_

.ifdef JUMP_TO_RET
_LABEL_97B_ret:
  ret
.endif

LABEL_97C_RuffTrux:
  jp LABEL_5C9_

LABEL_97F_:
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_9AA_SuffixedPositionSpriteIndices
  add hl, de
  ld a, (hl)
  ld (ix+1), a
  inc hl
  ld a, (hl)
  ld (ix+3), a
  ld a, (_RAM_DF66_)
  add a, $04
  ld (ix+0), a
  add a, $08
  ld (ix+2), a
  ld a, (_RAM_DF67_)
  sub $0C
  ld (iy+0), a
  ld (iy+1), a
  ret

; Pairs of sprite indices for "1st", "2nd" etc indicator
DATA_9AA_SuffixedPositionSpriteIndices:
.db <SpriteIndex_Digit1, <SpriteIndex_SuffixSt
.db <SpriteIndex_Digit2, <SpriteIndex_SuffixNd
.db <SpriteIndex_Digit3, <SpriteIndex_SuffixRd
.db <SpriteIndex_Digit4, <SpriteIndex_SuffixTh

LABEL_9B2_ConvertMetatileIndexToDataIndex:
  ; Takes metatile index in a and converts it to the data index for this track type
  and $3F
  exx
    ld l, a
    ld h, $00
    ld bc, _RAM_DA20_TrackMetatileLookup
    add hl, bc
    ld a, (hl)
  exx
  ret

LABEL_9BF_NMI_GG:
    ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
    or a
    jr nz, +
    in a, (PORT_GG_LinkStatus)
    in a, (PORT_GG_LinkReceive)
    ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
  pop af
  retn

+:  in a, (PORT_GG_LinkStatus)
    in a, (PORT_GG_LinkReceive)
    ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
    ld a, (_RAM_DC3E_InMenus)
    or a
    jr nz, +
    in a, (PORT_CONTROL_A)
    and PORT_CONTROL_A_PLAYER1_MASK
    ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
    ld a, $01
    ld (_RAM_D5D8_), a
+:pop af
  retn

; TODO what is this for? It should be inlined?
DATA_9EB_Constant_C000_MetatilemapBaseAddress:
.dw $C000

DATA_9ED_TilemapAddressFromRowNumberLo:
; Low byte of tilemap address for different row indexes
; Table is twice as large as necessary?
  TimesTableLo NAME_TABLE_ADDRESS | VRAM_WRITE_MASK, TILEMAP_ROW_SIZE, 32
  TimesTableLo NAME_TABLE_ADDRESS | VRAM_WRITE_MASK, TILEMAP_ROW_SIZE, 32

DATA_A2D_TilemapAddressFromRowNumberHi:
; High byte of tilemap address for different row indexes
; Table is twice as large as necessary?
  TimesTableHi NAME_TABLE_ADDRESS | VRAM_WRITE_MASK, TILEMAP_ROW_SIZE, 32
  TimesTableHi NAME_TABLE_ADDRESS | VRAM_WRITE_MASK, TILEMAP_ROW_SIZE, 32

; Sprite X locations for tournament HUD sprites (SMS)
.dstruct DATA_A6D_SMS_TournamentHUDSpriteXs instanceof TournamentHUDSprites data $14 $10 $10 $10 $10 $18 $18 $18 $18

; Sprite Y locations for tournament HUD sprites (SMS)
.dstruct DATA_A76_SMS_TournamentHUDSpriteYs instanceof TournamentHUDSprites data $08 $10 $18 $20 $28 $10 $18 $20 $28

; Sprite X locations for tournament HUD sprites (GG)
.dstruct DATA_A7F_GG_TournamentHUDSpriteXs instanceof TournamentHUDSprites data $3C $38 $38 $38 $38 $40 $40 $40 $40

; Sprite Y locations for tournament HUD sprites (GG)
.dstruct DATA_A88_GG_TournamentHUDSpriteYs instanceof TournamentHUDSprites data $30 $38 $40 $48 $50 $38 $40 $48 $50

; Nibble encoded time limits to one DP
; Last byte is unused
DATA_A91_RuffTruxTimeLimits:
.macro RuffTruxTimeLimit args time
.db time / 10 # 10, time * 1 # 10, time * 10 # 10, 0
.endm
  RuffTruxTimeLimit 45.0
  RuffTruxTimeLimit 48.0
  RuffTruxTimeLimit 55.0

LABEL_A9D_:
  JrToPagedFunction LABEL_36D07_

LABEL_AA7_:
  JrToPagedFunction LABEL_36CA5_

LABEL_AB1_:
  JrToPagedFunction LABEL_366DE_

LABEL_ABB_:
  JrToPagedFunction LABEL_360B9_

LABEL_AC5_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet + ; ret
  JrToPagedFunction LABEL_3616B_
.ifdef JUMP_TO_RET
+: ret
.endif

LABEL_AD7_DelayIfPlayer2Trampoline:
  JrToPagedFunction LABEL_1BCCB_DelayIfPlayer2

LABEL_AE1_InGameCheatHandlerTrampoline:
  JrToPagedFunction LABEL_1F8D8_InGameCheatHandler

LABEL_AEB_GetPlayerHandicapsTrampoline:
  JrToPagedFunction LABEL_1BAB3_GetPlayerHandicaps

LABEL_AF5_:
  ld a, :LABEL_1BAFD_ ; $06
  ld (PAGING_REGISTER), a
  call LABEL_1BAFD_
LABEL_AFD_RestorePaging_fromDE8E:
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ret

LABEL_B04_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  ret z
  JrToPagedFunction LABEL_363D0_

LABEL_B13_:
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_)
  cp $01
  jr z, +
  jp +++
+:ld a, SFX_12_WinOrCheat
  ld (_RAM_D963_SFXTrigger_Player1), a
  jp ++

LABEL_B2B_:
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_)
  cp $07
  jr nz, +++
+:ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFXTrigger_Player2), a
++:
  ld hl, DATA_BB9_BonusSpriteData
  jp ++++

+++:
  ld hl, DATA_BAD_WinnerSpriteData
++++:
  ld ix, _RAM_DAE0_SpriteTableYs.20
  ld de, _RAM_DA60_SpriteTableXNs.20
  ld c, $0C ; Count
-:ld a, (hl)
  ld (de), a
  ld a, $50 ; y - writes too many!?
  ld (ix+0), a
  inc ix
  inc hl
  inc de
  dec c
  jr nz, -
  ld a, $02
  ld (_RAM_D581_), a
  ret

LABEL_B63_:
  ld a, (_RAM_D581_)
  cp $A0
  JrNcRet _LABEL_BAC_ret
  ld a, (_RAM_DB7B_)
  cp $01
  jr z, +
  cp $07
  jr nz, ++
+:
  ld ix, DATA_BB9_BonusSpriteData
  jp +++

++:
  ld ix, DATA_BAD_WinnerSpriteData
+++:
  ld de, _RAM_DA60_SpriteTableXNs.20
  ld iy, _RAM_DAE0_SpriteTableYs.20
  ld c, $06
-:
  ld a, (_RAM_D581_)
  ld l, a
  ld a, (ix+0)
  add a, l
  ld (de), a
  cp $50
  jr nc, +
  xor a
  ld (de), a
  ld (iy+0), a
+:
  inc de
  inc de
  inc ix
  inc ix
  inc iy
  ld a, $02
  add a, l
  ld (_RAM_D581_), a
  dec c
  jr nz, -
_LABEL_BAC_ret:
  ret

DATA_BAD_WinnerSpriteData: ; Sprite X, N for "WINNER"
.db $70 $9C ; TODO enum for head to head mode
.db $78 $9D
.db $80 $9E
.db $88 $9F
.db $90 $A4
.db $98 $A5
DATA_BB9_BonusSpriteData: ; Sprite X, N for "BONUS"
.db $70 $96
.db $78 $97
.db $80 $98
.db $88 $99
.db $90 $9A
.db $98 $9B

;;.section "Floor tiles updates" force
  ; Executed in RAM at da92 - or is it?
LABEL_BC5_UpdateFloorTiles:
  ld a, (_RAM_DF17_HaveFloorTiles)
  or a
  JrZRet + ; ret
  ld hl, (_RAM_DF18_FloorTilesVRAMAddress)
  ld a, l ; Point at them
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld hl, _RAM_DC59_FloorTiles
  ld b, $40 ; 2 tiles
  ld c, PORT_VDP_DATA
  otir
  ld hl, _RAM_DC59_FloorTiles + $20
  ld b, $20 ; The the same 2 tiles in the opposite order
  ld c, PORT_VDP_DATA
  otir
  ld hl, _RAM_DC59_FloorTiles
  ld b, $20
  ld c, PORT_VDP_DATA
  otir
+:ret

LABEL_BF0_UpdateFloorTiles:
  ; Skip for tracks without floors
  ld a, (_RAM_DB97_TrackType)
  or a
  jr z, + ; TT_0_SportsCars
  cp TT_1_FourByFour
  jr z, +
  cp TT_4_FormulaOne
  jr z, +
  ret

+:; We rotate the bitplane for plane 2 only. 
  ; This effectively means the floor tiles must be colours 0 and 4 - 
  ; or another pair of colours differing only in that bit, but no more than two.
  ; Colours 0 and 4 are the only pair stable across tracks (black and light grey).
  call LABEL_C81_UpdateFloorTiles_H
  ; Then flip the bit. This is what makes the floor scroll slower (?).
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  xor $01
  ld (_RAM_DEF8_FloorScrollingRateLimiter), a
  ; Then do vertically
  ld a, (_RAM_DEF6_)
  ld b, a
  and $80
  ld l, a
  ld a, b
  and $7F
  or a
  JrZRet _LABEL_C2F_ret
  dec a
  jr z, +
  dec a
  jr z, ++
  dec a
  jr z, +++
  dec a
  jr z, ++++
  dec a
  jr z, +++++
  dec a
  jr z, ++++++
  dec a
  jr z, +++++++
  dec a
  jr z, LABEL_C75_
_LABEL_C2F_ret:
  ret

+:
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_C2F_ret
++:
  jp LABEL_CF8_MoveFloorTilesVertically

+++:
  call LABEL_CF8_MoveFloorTilesVertically
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_C2F_ret
  jp LABEL_CF8_MoveFloorTilesVertically

++++:
  call LABEL_CF8_MoveFloorTilesVertically
  jp LABEL_CF8_MoveFloorTilesVertically

+++++:
  call LABEL_CF8_MoveFloorTilesVertically
  call LABEL_CF8_MoveFloorTilesVertically
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_C2F_ret
  jp LABEL_CF8_MoveFloorTilesVertically

++++++:
  call LABEL_CF8_MoveFloorTilesVertically
  call LABEL_CF8_MoveFloorTilesVertically
  jp LABEL_CF8_MoveFloorTilesVertically

+++++++:
  call LABEL_CF8_MoveFloorTilesVertically
  call LABEL_CF8_MoveFloorTilesVertically
  call LABEL_CF8_MoveFloorTilesVertically
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_C2F_ret
  jp LABEL_CF8_MoveFloorTilesVertically

LABEL_C75_:
  call LABEL_CF8_MoveFloorTilesVertically
  call LABEL_CF8_MoveFloorTilesVertically
  call LABEL_CF8_MoveFloorTilesVertically
  jp LABEL_CF8_MoveFloorTilesVertically

LABEL_C81_UpdateFloorTiles_H:
  ld a, (_RAM_DEF7_)
  ld b, a
  and $80
  ld l, a ; High bit -> l
  ld a, b
  and $7F
  or a
  JrZRet _LABEL_CA6_ret ; Nothing to do
  dec a
  jr z, +
  dec a
  jr z, ++
  dec a
  jr z, +++
  dec a
  jr z, ++++
  dec a
  jr z, +++++
  dec a
  jr z, ++++++
  dec a
  jr z, +++++++
  dec a
  jr z, LABEL_CEC_
_LABEL_CA6_ret:
  ret

+:; Shift if flag is set
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_CA6_ret
++:
  jp LABEL_DCF_MoveFloorTilesHorizontally

+++:
  call LABEL_DCF_MoveFloorTilesHorizontally
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_CA6_ret
  jp LABEL_DCF_MoveFloorTilesHorizontally

++++:
  call LABEL_DCF_MoveFloorTilesHorizontally
  jp LABEL_DCF_MoveFloorTilesHorizontally

+++++:
  call LABEL_DCF_MoveFloorTilesHorizontally
  call LABEL_DCF_MoveFloorTilesHorizontally
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_CA6_ret
  jp LABEL_DCF_MoveFloorTilesHorizontally

++++++:
  call LABEL_DCF_MoveFloorTilesHorizontally
  call LABEL_DCF_MoveFloorTilesHorizontally
  jp LABEL_DCF_MoveFloorTilesHorizontally

+++++++:
  call LABEL_DCF_MoveFloorTilesHorizontally
  call LABEL_DCF_MoveFloorTilesHorizontally
  call LABEL_DCF_MoveFloorTilesHorizontally
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet _LABEL_CA6_ret
  jp LABEL_DCF_MoveFloorTilesHorizontally

LABEL_CEC_:
  call LABEL_DCF_MoveFloorTilesHorizontally
  call LABEL_DCF_MoveFloorTilesHorizontally
  call LABEL_DCF_MoveFloorTilesHorizontally
  jp LABEL_DCF_MoveFloorTilesHorizontally

LABEL_CF8_MoveFloorTilesVertically:
  push hl
    ld a, l
    cp $80
    jp z, LABEL_D67_MoveFloorTilesUp
    ; Move the data down
    ld a, (_RAM_DC59_FloorTiles + 62)
    ld (_RAM_DE59_), a
    ld a, (_RAM_DC59_FloorTiles + 58)
    ld (_RAM_DC59_FloorTiles + 62), a
    ld a, (_RAM_DC59_FloorTiles + 54)
    ld (_RAM_DC59_FloorTiles + 58), a
    ld a, (_RAM_DC59_FloorTiles + 50)
    ld (_RAM_DC59_FloorTiles + 54), a
    ld a, (_RAM_DC59_FloorTiles + 46)
    ld (_RAM_DC59_FloorTiles + 50), a
    ld a, (_RAM_DC59_FloorTiles + 42)
    ld (_RAM_DC59_FloorTiles + 46), a
    ld a, (_RAM_DC59_FloorTiles + 38)
    ld (_RAM_DC59_FloorTiles + 42), a
    ld a, (_RAM_DC59_FloorTiles + 34)
    ld (_RAM_DC59_FloorTiles + 38), a
    ld a, (_RAM_DC59_FloorTiles + 30)
    ld (_RAM_DC59_FloorTiles + 34), a
    ld a, (_RAM_DC59_FloorTiles + 26)
    ld (_RAM_DC59_FloorTiles + 30), a
    ld a, (_RAM_DC59_FloorTiles + 22)
    ld (_RAM_DC59_FloorTiles + 26), a
    ld a, (_RAM_DC59_FloorTiles + 18)
    ld (_RAM_DC59_FloorTiles + 22), a
    ld a, (_RAM_DC59_FloorTiles + 14)
    ld (_RAM_DC59_FloorTiles + 18), a
    ld a, (_RAM_DC59_FloorTiles + 10)
    ld (_RAM_DC59_FloorTiles + 14), a
    ld a, (_RAM_DC59_FloorTiles + 6)
    ld (_RAM_DC59_FloorTiles + 10), a
    ld a, (_RAM_DC59_FloorTiles + 2)
    ld (_RAM_DC59_FloorTiles + 6), a
    ld a, (_RAM_DE59_)
    ld (_RAM_DC59_FloorTiles + 2), a
  pop hl
  ret

LABEL_D67_MoveFloorTilesUp:
    ld a, (_RAM_DC59_FloorTiles + 2)
    ld (_RAM_DE59_), a
    ld a, (_RAM_DC59_FloorTiles + 6)
    ld (_RAM_DC59_FloorTiles + 2), a
    ld a, (_RAM_DC59_FloorTiles + 10)
    ld (_RAM_DC59_FloorTiles + 6), a
    ld a, (_RAM_DC59_FloorTiles + 14)
    ld (_RAM_DC59_FloorTiles + 10), a
    ld a, (_RAM_DC59_FloorTiles + 18)
    ld (_RAM_DC59_FloorTiles + 14), a
    ld a, (_RAM_DC59_FloorTiles + 22)
    ld (_RAM_DC59_FloorTiles + 18), a
    ld a, (_RAM_DC59_FloorTiles + 26)
    ld (_RAM_DC59_FloorTiles + 22), a
    ld a, (_RAM_DC59_FloorTiles + 30)
    ld (_RAM_DC59_FloorTiles + 26), a
    ld a, (_RAM_DC59_FloorTiles + 34)
    ld (_RAM_DC59_FloorTiles + 30), a
    ld a, (_RAM_DC59_FloorTiles + 38)
    ld (_RAM_DC59_FloorTiles + 34), a
    ld a, (_RAM_DC59_FloorTiles + 42)
    ld (_RAM_DC59_FloorTiles + 38), a
    ld a, (_RAM_DC59_FloorTiles + 46)
    ld (_RAM_DC59_FloorTiles + 42), a
    ld a, (_RAM_DC59_FloorTiles + 50)
    ld (_RAM_DC59_FloorTiles + 46), a
    ld a, (_RAM_DC59_FloorTiles + 54)
    ld (_RAM_DC59_FloorTiles + 50), a
    ld a, (_RAM_DC59_FloorTiles + 58)
    ld (_RAM_DC59_FloorTiles + 54), a
    ld a, (_RAM_DC59_FloorTiles + 62)
    ld (_RAM_DC59_FloorTiles + 58), a
    ld a, (_RAM_DE59_)
    ld (_RAM_DC59_FloorTiles + 62), a
  pop hl
  ret

LABEL_DCF_MoveFloorTilesHorizontally:
  push hl
    ld a, l
    cp $80
    jp z, LABEL_E3C_MoveFloorTilesRight
    ; Move them left
    ld ix, _RAM_DC59_FloorTiles
    ld a, (_RAM_DC59_FloorTiles + 2)
    rla
    rl (ix+34)
    rl (ix+2)
    ld a, (_RAM_DC59_FloorTiles + 6)
    rla
    rl (ix+38)
    rl (ix+6)
    ld a, (_RAM_DC59_FloorTiles + 10)
    rla
    rl (ix+42)
    rl (ix+10)
    ld a, (_RAM_DC59_FloorTiles + 14)
    rla
    rl (ix+46)
    rl (ix+14)
    ld a, (_RAM_DC59_FloorTiles + 18)
    rla
    rl (ix+50)
    rl (ix+18)
    ld a, (_RAM_DC59_FloorTiles + 22)
    rla
    rl (ix+54)
    rl (ix+22)
    ld a, (_RAM_DC59_FloorTiles + 26)
    rla
    rl (ix+58)
    rl (ix+26)
    ld a, (_RAM_DC59_FloorTiles + 30)
    rla
    rl (ix+62)
    rl (ix+30)
  pop hl
  ret

LABEL_E3C_MoveFloorTilesRight:
    ld ix, _RAM_DC59_FloorTiles
    ld a, (_RAM_DC59_FloorTiles + 34)
    rra
    rr (ix+2)
    rr (ix+34)
    ld a, (_RAM_DC59_FloorTiles + 38)
    rra
    rr (ix+6)
    rr (ix+38)
    ld a, (_RAM_DC59_FloorTiles + 42)
    rra
    rr (ix+10)
    rr (ix+42)
    ld a, (_RAM_DC59_FloorTiles + 46)
    rra
    rr (ix+14)
    rr (ix+46)
    ld a, (_RAM_DC59_FloorTiles + 50)
    rra
    rr (ix+18)
    rr (ix+50)
    ld a, (_RAM_DC59_FloorTiles + 54)
    rra
    rr (ix+22)
    rr (ix+54)
    ld a, (_RAM_DC59_FloorTiles + 58)
    rra
    rr (ix+26)
    rr (ix+58)
    ld a, (_RAM_DC59_FloorTiles + 62)
    rra
    rr (ix+30)
    rr (ix+62)
  pop hl
  ret
;;.ends

DATA_EA2_: ; Engine velocity related?
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $01 $01 $00 $00 $01 $01 $02 $02 $01 $01 $02 $02 $03 $03 $02 $02
.db $03 $03 $04 $04 $03 $03 $04 $04 $05 $05 $04 $04 $05 $05 $06 $06
.db $05 $05 $06 $06

LABEL_EE6_:
  JumpToPagedFunction LABEL_363D9_

LABEL_EF1_:
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_D5A3_), a
  ld a, (_RAM_DF00_)
  or a
  jr z, +
  ld a, (_RAM_DF01_)
  or a
  jr nz, +
  ld a, (_RAM_DF03_)
  cp $02
  jr z, LABEL_F6F_
+:
  ld a, (_RAM_DEA3_)
  or a
  jr z, ++
  cp $01
  jr z, +
  call LABEL_6593_
+:
  ld a, (_RAM_DE99_)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_L_MASK ; $04
  jr z, LABEL_F75_
  jp ++

+:
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_R_MASK ; $08
  jr z, LABEL_F75_
++:
  ld a, (_RAM_DEA3_)
  or a
  jr z, LABEL_F75_
  ld a, (_RAM_DB20_Player1Controls)
  ld l, a
  and BUTTON_L_MASK ; $04
  jr z, +
  ld a, l
  and BUTTON_R_MASK ; $08
  jr nz, LABEL_F6F_
+:
  ld a, $01
  ld (_RAM_DEA7_), a
  ld hl, _RAM_DEA5_
  inc (hl)
  ld a, (hl)
  cp $44
  jr nz, LABEL_F58_
  ld a, $43
  ld (_RAM_DEA5_), a
LABEL_F58_:
  ld hl, DATA_EA2_
  ld de, (_RAM_DEA5_)
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE92_EngineVelocity)
  sub l
  ld l, a
  and $80
  jr nz, +
  ld a, l
  ld (_RAM_DE96_), a
LABEL_F6F_:
  ret

+:
  xor a
  ld (_RAM_DE96_), a
  ret

LABEL_F75_:
  ld a, (_RAM_DEA7_)
  or a
  jr z, +
  ld a, (_RAM_DEA5_)
  or a
  jr z, +
  cp $01
  jr z, +
  sub $02
  ld (_RAM_DEA5_), a
  jp LABEL_F58_

+:
  xor a
  ld (_RAM_DEA5_), a
  ld (_RAM_DEA7_), a
  ld a, (_RAM_DE92_EngineVelocity)
  ld (_RAM_DE96_), a
  ret

LABEL_F9B_:
  xor a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jp nz, LABEL_109B_
  ld a, (_RAM_DE4F_)
  cp $80
  jp nz, LABEL_109B_
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  jr nz, LABEL_1024_
  ld a, (_RAM_DF58_)
  or a
  jp nz, LABEL_109B_
  ld a, (_RAM_DF6A_)
  or a
  jr nz, LABEL_1011_
  ld a, (_RAM_DB20_Player1Controls)
  ld b, a
  and BUTTON_2_MASK ; $20
  jr nz, LABEL_1011_
  ld a, b
  and BUTTON_1_MASK ; $10
  jr z, LABEL_1011_
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr nz, +
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, LABEL_102B_
+:
  ld a, $02
  ld (_RAM_DE96_), a
  ld (_RAM_DE92_EngineVelocity), a
  ld a, $01
  ld (_RAM_D5A4_IsReversing), a
  ld a, (_RAM_DE90_CarDirection)
  ld d, $00
  ld e, a
  ld hl, DATA_250E_
  add hl, de
  ld a, (hl)
  ld (_RAM_D5A3_), a
  ld hl, _RAM_DEAD_
  inc (hl)
  ld a, (hl)
  cp $06
  jr nz, +
  ld a, $00
  ld (_RAM_DEAD_), a
  ld a, (_RAM_DB7D_)
  xor $01
  ld (_RAM_DB7D_), a
+:
  jp LABEL_1121_

LABEL_1011_:
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_D5A4_IsReversing), a
+:
  ld a, (_RAM_DF65_)
  or a
  jr z, +
LABEL_1024_:
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jp z, LABEL_109B_
LABEL_102B_:
  ld hl, _RAM_DEB4_
  inc (hl)
  ld a, (hl)
  cp $07
  jr c, LABEL_1081_
  ld a, $00
  ld (_RAM_DEB4_), a
  ld a, (_RAM_DF00_)
  or a
  jr nz, LABEL_1081_
  ld hl, _RAM_DE92_EngineVelocity
  dec (hl)
  jp LABEL_1081_

+:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld a, (_RAM_D59D_)
  or a
  jr z, +
  jp LABEL_10C2_

+:
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK ; $10
  jr z, LABEL_10C2_
  ld a, (_RAM_DE92_EngineVelocity)
  cp $00
  jp z, LABEL_109B_
  ld a, (_RAM_DB9A_DecelerationDelay)
  ld b, a
  ld hl, _RAM_DEB4_
  inc (hl)
  ld a, (hl)
  cp b
  jp c, LABEL_1081_
  ld a, $00
  ld (_RAM_DEB4_), a
  ld a, (_RAM_DF00_)
  or a
  jp nz, LABEL_1081_
  ld hl, _RAM_DE92_EngineVelocity
  dec (hl)
LABEL_1081_:
  ld hl, _RAM_DEAD_
  inc (hl)
  ld a, (hl)
  cp $06
  jp nz, LABEL_111E_
  ld a, $00
  ld (_RAM_DEAD_), a
  ld a, (_RAM_DB7D_)
  xor $01
  ld (_RAM_DB7D_), a
  jp LABEL_111E_

LABEL_109B_:
  ld a, (_RAM_DB9A_DecelerationDelay)
  sub $01
  ld (_RAM_DEB4_), a
  ld a, (_RAM_DB99_AccelerationDelay)
  sub $01
  ld (_RAM_DEB3_Player1AccelerationDelayCounter), a
  ld hl, _RAM_DEAD_
  inc (hl)
  ld a, (hl)
  cp $06
  JrNzRet +
  ld a, $00
  ld (_RAM_DEAD_), a
  ld a, (_RAM_DB7D_)
  xor $01
  ld (_RAM_DB7D_), a
+:ret

LABEL_10C2_:
  ld hl, _RAM_DEAD_
  inc (hl)
  ld a, (hl)
  cp $06
  jr nz, +
  ld a, $00
  ld (_RAM_DEAD_), a
  ld a, (_RAM_DB7D_)
  xor $01
  ld (_RAM_DB7D_), a
+:
  ld a, (_RAM_DE2F_)
  or a
  jr z, ++
  ; Reversing acceleration delay?
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld b, $05
  jp +++

+:
  ld b, $07
  jp +++

++:
  ld a, (_RAM_DB99_AccelerationDelay)
  ld b, a
+++:
  ; Increment the delay counter
  ld hl, _RAM_DEB3_Player1AccelerationDelayCounter
  inc (hl)
  ld a, (hl)
  cp b
  jr c, LABEL_111E_
  ; Delay has passed, reset the counter
  ld a, $00
  ld (_RAM_DEB3_Player1AccelerationDelayCounter), a
  ; Get the real top speed (after handicap)
  ld a, (_RAM_D5CF_Player1Handicap)
  ld l, a
  ld a, (_RAM_DB98_TopSpeed)
  sub l
  ld h, a
  ; And the current speed
  ld a, (_RAM_DE92_EngineVelocity)
  ld l, a
  ld a, h
  cp l
  jr nz, +
  jp LABEL_111E_

+:; Not at top speed yet
  ld a, (_RAM_DF00_)
  or a
  jr nz, LABEL_111E_
  ; Speed up!
  ld hl, _RAM_DE92_EngineVelocity
  inc (hl)
LABEL_111E_:
  call LABEL_EF1_
LABEL_1121_:
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_DE96_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_DE96_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_
  ld a, (_RAM_D5A3_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DEAF_), a
  ld hl, DATA_40E5_Sign_
  ld a, (_RAM_D5A3_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DEB0_), a
  ld hl, _RAM_DEAF_
  jp ++

+:
  ld a, $01
  ld (_RAM_DEB0_), a
  ld hl, _RAM_DEAF_
++:
  ld hl, DATA_3FD3_
  ld a, (_RAM_D5A3_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DEB1_VScrollDelta), a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_D5A3_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DEB2_), a
  ld hl, _RAM_DEB1_VScrollDelta
  ret

+:
  ld a, $01
  ld (_RAM_DEB2_), a
  ld hl, _RAM_DEB1_VScrollDelta
  ret

LABEL_11BA_:
  ld a, (_RAM_D5B6_)
  or a
  jr z, +
  dec a
  ld (_RAM_D5B6_), a
+:
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  JrNzRet +
  ld a, (_RAM_DC4D_Cheat_NoSkidding)
  or a
  jr nz, ++
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr z, LABEL_11E4_
  ld a, (_RAM_DE99_)
  or a
  JrZRet +
  cp $01
  jr z, +++
  jp LABEL_1242_

+:ret

LABEL_11E4_:
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE90_CarDirection), a
  xor a
  ld (_RAM_DEA3_), a
  ld (_RAM_DEA0_), a
  ld (_RAM_DE99_), a
  ld a, $06
  ld (_RAM_DEAC_), a
  ret

++:
  ld a, (_RAM_DF00_)
  or a
  jr z, LABEL_11E4_
  ret

+++:
  ld a, (_RAM_DF00_)
  or a
  JrNzRet +
  ld a, (_RAM_D5B6_)
  or a
  JrNzRet _LABEL_121A_ret
  ld a, (_RAM_DEA0_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA0_), a
+:ret
.ifdef JUMP_TO_RET
_LABEL_121A_ret:
  ret
.endif

++:
  ld a, (_RAM_DEA3_)
  sub $01
  ld (_RAM_DEA3_), a
  ld a, (_RAM_DEAB_)
  cp $01
  jr nz, +
  ld a, $06
  jp ++

+:
  call LABEL_1282_
++:
  ld (_RAM_DEA0_), a
  ld hl, _RAM_DE90_CarDirection ; Rotate left
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DE90_CarDirection), a
  jp LABEL_1295_

LABEL_1242_:
  ld a, (_RAM_DF00_)
  or a
  JrNzRet +
  ld a, (_RAM_D5B6_)
  or a
  JrNzRet _LABEL_121A_ret
  ld a, (_RAM_DEA0_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA0_), a
+:ret

++:
  ld a, (_RAM_DEA3_)
  sub $01
  ld (_RAM_DEA3_), a
  ld a, (_RAM_DEAB_)
  cp $01
  jr nz, +
  ld a, $06
  jp ++

+:
  call LABEL_1282_
++:
  ld (_RAM_DEA0_), a
  ld hl, _RAM_DE90_CarDirection ; Rotate right
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DE90_CarDirection), a
  jp LABEL_1295_

LABEL_1282_:
  ld a, (_RAM_DC4E_Cheat_SuperSkids)
  or a
  jr z, +
  ld a, $0E ; Always return this if cheat is enabled
  ret

+:
  ld hl, _RAM_DB86_HandlingData ; Else look something up
  ld de, (_RAM_DE96_)
  add hl, de
  ld a, (hl)
  ret

LABEL_1295_:
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld l, a
  ld a, (_RAM_DE90_CarDirection)
  cp l
  jr nz, +
  xor a
  ld (_RAM_DE99_), a
  ld (_RAM_DE9A_), a
  ld (_RAM_DEA3_), a
  ret

+:
  ld a, (_RAM_DEA3_)
  cp $04
  jr nz, +
  ld a, $01
  ld (_RAM_DEAB_), a
  JpRet ++ ; ret

.ifdef UNNECESSARY_CODE
  ret
.endif

+:xor a
  ld (_RAM_DEAB_), a
++:ret

LABEL_12BF_:
  JumpToPagedFunction LABEL_35F8A_

LABEL_12CA_:
  JumpToPagedFunction LABEL_36209_

LABEL_12D5_:
  JumpToPagedFunction LABEL_1FA3D_

LABEL_12E0_DrawTilemapRectangle:
  ; Look up tile index data pointer into de
  ld hl, DATA_4000_TileIndexPointerLow
  ld a, (_RAM_DEBC_TileDataIndex)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_4041_TileIndexPointerHigh
  ld a, (_RAM_DEBC_TileDataIndex)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld d, (hl)

  ld a, (_RAM_DEC5_RectangleHeight)
  ld l, a
--:
  ; Set VRAM address
  ld a, (_RAM_DEC1_VRAMAddress.Lo)
  out (PORT_VDP_ADDRESS), a
  ld a, (_RAM_DEC1_VRAMAddress.Hi)
  out (PORT_VDP_ADDRESS), a
  ; Load counter
  ld bc, (_RAM_DECF_RectangleWidth)
-:; Emit tile index
  ld a, (de)
  out (PORT_VDP_DATA), a
  ; Get high byte
  push hl
    ld hl, _RAM_D800_TileHighBytes
    add a, l
    ld l, a
    ld a, (hl)
  pop hl
  ; Emit it
  out (PORT_VDP_DATA), a
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -
  ; Loop over l rows (_RAM_DEC5_RectangleHeight)
  dec l
  ld a, l
  cp 0
  JrZRet + ; ret
  ; Add a row to the VRAM address
  ld a, (_RAM_DEC1_VRAMAddress.Lo)
  add a, TILEMAP_ROW_SIZE
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, (_RAM_DEC1_VRAMAddress.Hi)
  adc a, 0
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    ; Add _RAM_DECE_RectRowSkip to de
    ld hl, _RAM_DECE_RectRowSkip
    ld a, e
    add a, (hl)
    ld e, a
    ld a, d
    adc a, 0
    ld d, a
  pop hl
  jp --

+:ret

LABEL_1345_DrawGameFullScreen:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jp nz, @GG

@SMS:
  ; SMS
  ; Initialise a bunch of stuff
  ld a, $07
  ld (_RAM_DEE1_), a
  xor a
  ld (_RAM_DEDF_), a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld (_RAM_DED5_), a
  add a, $02
  ld (_RAM_DED7_), a

  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld (_RAM_DEEB_), a
  ld a, $04
  ld (_RAM_DEE3_), a
  xor a
  ld (_RAM_DEE5_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld (_RAM_DEDB_), a
  add a, $02
  ld (_RAM_DED9_), a

  xor a
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld (_RAM_DED1_MetatilemapPointer.Hi), a

  ld a, (_RAM_DBA2_TopLeftMetatileY)
  or a
  jr z, +
  ; Move down by the right number of rows
  ld bc, (_RAM_DBA2_TopLeftMetatileY)
  ld de, (_RAM_DB9C_MetatilemapWidth)
-:ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de
  ld (_RAM_DED1_MetatilemapPointer), hl
  dec bc ; Could use b and djnz
  ld a, b
  or c
  jr z, +
  jp -

+:; Then move right by X
  ld hl, (_RAM_DED1_MetatilemapPointer)
  ld de, (_RAM_DBA0_TopLeftMetatileX)
  add hl, de
  ; Then add on the base address of the metatilemap
  ld de, (DATA_9EB_Constant_C000_MetatilemapBaseAddress)
  add hl, de
  ld (_RAM_DED1_MetatilemapPointer), hl
  
  ; Now draw all the metatiles to fill the screen
  ; SMS screen is 32x28
  ; +-------+-------+------+
  ; |       |       |      |
  ; | 12x12 | 12x12 | 8x12 |
  ; |       |       |      |
  ; +-------+-------+------+
  ; |       |       |      |
  ; | 12x12 | 12x12 | 8x12 |
  ; |       |       |      |
  ; +-------+-------+------+
  ; | 12x4  | 12x4  | 8x4  |
  ; +-------+-------+------+
  
  ; Draw in a screen of 12x12 tiles
  .macro DrawNextMetatile args x, y
    ld a, (hl)
    call LABEL_9B2_ConvertMetatileIndexToDataIndex
    ld (_RAM_DEBC_TileDataIndex), a
    SetTileIndex_RAM_DEC1_VRAMAddress x, y
    push hl
      call LABEL_12E0_DrawTilemapRectangle
    pop hl
  .endm
  
  call LABEL_1583_SetDrawingParameters_FullMetatile
  DrawNextMetatile  0,  0
  inc hl
  DrawNextMetatile 12,  0
  call LABEL_64E5_SetDrawingParameters_PartialMetatile
  inc hl
  DrawNextMetatile 24,  0

  ld de, (_RAM_DB9C_MetatilemapWidth)
  ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de

  call LABEL_1583_SetDrawingParameters_FullMetatile
  DrawNextMetatile 0, 12
  inc hl
  DrawNextMetatile 12, 12
  call LABEL_64E5_SetDrawingParameters_PartialMetatile
  inc hl
  DrawNextMetatile 24, 12

  ld de, (_RAM_DB9C_MetatilemapWidth)
  ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de
  add hl, de
  
  call LABEL_1583_SetDrawingParameters_FullMetatile
  ; And modify height
  ld a, 4
  ld (_RAM_DEC5_RectangleHeight), a
  DrawNextMetatile 0, 24
  inc hl
  DrawNextMetatile 12, 24
  call LABEL_64E5_SetDrawingParameters_PartialMetatile
  ; And modify height
  ld a, 4
  ld (_RAM_DEC5_RectangleHeight), a
  inc hl
  DrawNextMetatile 24, 24
  ret

@GG:
  ; GG version of the above
  ld a, $08 ; 7 for SMS
  ld (_RAM_DEE1_), a
  xor a
  ld (_RAM_DEDF_), a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld (_RAM_DED5_), a
  add a, $01 ; 2 for SMS
  ld (_RAM_DED7_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld (_RAM_DEEB_), a
  ld a, $06 ; 4 for SMS
  ld (_RAM_DEE3_), a
  xor a
  ld (_RAM_DEE5_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld (_RAM_DEDB_), a
  add a, $01 ; 2 for SMS
  ld (_RAM_DED9_), a
  xor a
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  or a
  jr z, +
  ld bc, (_RAM_DBA2_TopLeftMetatileY)
  ld de, (_RAM_DB9C_MetatilemapWidth)
-:ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de
  ld (_RAM_DED1_MetatilemapPointer), hl
  dec bc
  ld a, b
  or c
  jr z, +
  jp -
+:ld hl, (_RAM_DED1_MetatilemapPointer)
  ld de, (_RAM_DBA0_TopLeftMetatileX)
  add hl, de
  ld de, (DATA_9EB_Constant_C000_MetatilemapBaseAddress)
  add hl, de
  ld (_RAM_DED1_MetatilemapPointer), hl
  
  ; GG screen is 32z28 but only the middle (160x144) is shown...
  ; We draw into the rects as shown:
  ; +----------------------+
  ; |        (5)           |
  ; |   +-------+------+   |
  ; |   |       |      |   |
  ; |   | 12x12 | 9x12 |   |
  ; |   |       |      |   |
  ; |(5)+-------+------+(6)|
  ; |   |       |      |   |
  ; |   | 12x6  | 9x6  |   |
  ; |   |       |      |   |
  ; |   +-------+------+   |
  ; |        (5)           |
  ; +----------------------+

  call LABEL_1583_SetDrawingParameters_FullMetatile
  ; Screen drawing
  DrawNextMetatile 5, 5
  call LABEL_64E5_SetDrawingParameters_PartialMetatile
  inc hl
  DrawNextMetatile 17, 5
  ld de, (_RAM_DB9C_MetatilemapWidth)
  ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de
  call LABEL_1583_SetDrawingParameters_FullMetatile
  ld a, 6
  ld (_RAM_DEC5_RectangleHeight), a
  DrawNextMetatile 5, 17
  call LABEL_64E5_SetDrawingParameters_PartialMetatile
  ld a, 6
  ld (_RAM_DEC5_RectangleHeight), a
  inc hl
  DrawNextMetatile 17, 17
  ret

LABEL_1583_SetDrawingParameters_FullMetatile:
  ; 12x12, no skip
  ld a, 12
  ld (_RAM_DECF_RectangleWidth), a
  ld a, 0
  ld (_RAM_DECE_RectRowSkip), a
  ld a, 12
  ld (_RAM_DEC5_RectangleHeight), a
  ret

LABEL_1593_:
  xor a
  ld (_RAM_DEF6_), a
  ld a, (_RAM_DEB2_)
  or a
  jp z, LABEL_162D_
  ld a, (_RAM_DEB8_)
  cp $01
  jr z, +
  ld a, (_RAM_DEBA_)
  cp $01
  jr z, +
  ld a, (_RAM_DEB5_)
  cp $01
  jr z, +
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, +
-:ret
+:ld a, (_RAM_DEB2_)
  cp $01
  JrNzRet - ; ret
  call LABEL_3E24_
  ld a, (_RAM_DEB1_VScrollDelta)
  ld (_RAM_DEF6_), a
  ld l, a
  ld a, (_RAM_DED4_VScrollValue)
  and $07
  add a, l
  cp $08
  jr z, +
  jr c, ++
+:ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DED4_VScrollValue)
  add a, l
  ld (_RAM_DED4_VScrollValue), a
  jp +++

++:
  ld a, (_RAM_DED4_VScrollValue)
  add a, l
  ld (_RAM_DED4_VScrollValue), a
  ret

+++:
  ld hl, _RAM_DEED_
  inc (hl)
  ld a, (_RAM_DEED_)
  cp $0C
  jr nz, +
  xor a
  ld (_RAM_DEED_), a
  ld hl, _RAM_DBA2_TopLeftMetatileY
  inc (hl)
+:
  ld hl, _RAM_DEE3_
  inc (hl)
  ld a, (_RAM_DEE3_)
  cp $0C
  jr nz, +
  xor a
  ld (_RAM_DEE3_), a
  ld hl, _RAM_DED9_
  inc (hl)
+:
  ld hl, _RAM_DEE5_
  inc (hl)
  ld a, (_RAM_DEE5_)
  cp $0C
  jr nz, +
  xor a
  ld (_RAM_DEE5_), a
  ld hl, _RAM_DEDB_
  inc (hl)
+:
  call LABEL_77CD_ComputeScreenTilemapAddress
  TailCall LABEL_1801_

LABEL_162D_:
  ld a, (_RAM_DEB8_)
  cp $01
  jr z, +
  ld a, (_RAM_DEBA_)
  cp $01
  jr z, +
  ld a, (_RAM_DEB5_)
  cp $01
  jr z, +
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, +
-:ret
+:ld a, (_RAM_DEB2_)
  or a
  JrNzRet - ; ret
  call LABEL_7C72_
  ld a, (_RAM_DEB1_VScrollDelta)
  or $80
  ld (_RAM_DEF6_), a
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DED4_VScrollValue)
  and $07
  sub l
  jr nc, +
  ; If the scroll went over an 8px boundary, we need to draw some tiles
  call ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DED4_VScrollValue)
  sub l
  ld (_RAM_DED4_VScrollValue), a
  ret
+:ld a, (_RAM_DED4_VScrollValue)
  sub l
  ld (_RAM_DED4_VScrollValue), a
  ret

++:
  ld hl, _RAM_DEED_
  dec (hl)
  ld a, (_RAM_DEED_)
  cp $FF
  jr nz, +
  ld a, $0B
  ld (_RAM_DEED_), a
  ld hl, _RAM_DBA2_TopLeftMetatileY
  dec (hl)
+:
  ld hl, _RAM_DEE3_
  dec (hl)
  ld a, (_RAM_DEE3_)
  cp $FF
  jr nz, +
  ld a, $0B
  ld (_RAM_DEE3_), a
  ld hl, _RAM_DED9_
  dec (hl)
+:
  ld hl, _RAM_DEE5_
  dec (hl)
  ld a, (_RAM_DEE5_)
  cp $FF
  jr nz, +
  ld a, $0B
  ld (_RAM_DEE5_), a
  ld hl, _RAM_DEDB_
  dec (hl)
+:
  call LABEL_780D_
  TailCall LABEL_17E6_

LABEL_16C0_:
  xor a
  ld (_RAM_DEF7_), a
  ld a, (_RAM_DEB0_)
  or a
  jr z, +
  jp LABEL_174E_

+:ld a, (_RAM_DEB9_)
  cp $01
  jr z, +
  ld a, (_RAM_DEBB_)
  cp $01
  jr z, +
  ld a, (_RAM_DEB5_)
  cp $01
  jr z, +
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, +
-:ret

+:ld a, (_RAM_DEB0_)
  or a
  JrNzRet -
  call LABEL_7C67_
  ld a, (_RAM_DEAF_)
  ld (_RAM_DEF7_), a
  ld l, a
  ld a, (_RAM_DED3_HScrollValue)
  and $07
  add a, l
  cp $08
  jr z, +
  jr c, ++
+:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DED3_HScrollValue)
  add a, l
  ld (_RAM_DED3_HScrollValue), a
  jp +++

++:
  ld a, (_RAM_DED3_HScrollValue)
  add a, l
  ld (_RAM_DED3_HScrollValue), a
  ret

+++:
  ld hl, _RAM_DEDF_
  dec (hl)
  ld a, (_RAM_DEDF_)
  cp $FF
  jr nz, +
  ld a, $0B
  ld (_RAM_DEDF_), a
  ld hl, _RAM_DED5_
  dec (hl)
  ld hl, _RAM_DBA0_TopLeftMetatileX
  dec (hl)
+:
  ld hl, _RAM_DEE1_
  dec (hl)
  ld a, (_RAM_DEE1_)
  cp $FF
  jr nz, +
  ld a, $0B
  ld (_RAM_DEE1_), a
  ld hl, _RAM_DED7_
  dec (hl)
+:
  call LABEL_17D0_
  TailCall LABEL_18E6_

LABEL_174E_:
  ld a, (_RAM_DEB9_)
  cp $01
  jr z, +
  ld a, (_RAM_DEBB_)
  cp $01
  jr z, +
  ld a, (_RAM_DEB5_)
  cp $01
  jr z, +
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, +
-:
  ret

+:
  ld a, (_RAM_DEB0_)
  cp $01
  jr nz, -
  call LABEL_3E2F_
  ld a, (_RAM_DEAF_)
  or $80
  ld (_RAM_DEF7_), a
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DED3_HScrollValue)
  and $07
  sub l
  jr nc, +
  call ++
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DED3_HScrollValue)
  sub l
  ld (_RAM_DED3_HScrollValue), a
  ret

+:
  ld a, (_RAM_DED3_HScrollValue)
  sub l
  ld (_RAM_DED3_HScrollValue), a
  ret

++:
  ld hl, _RAM_DEDF_
  inc (hl)
  ld a, (_RAM_DEDF_)
  cp $0C
  jr nz, +
  xor a
  ld (_RAM_DEDF_), a
  ld hl, _RAM_DED5_
  inc (hl)
  ld hl, _RAM_DBA0_TopLeftMetatileX
  inc (hl)
+:
  ld hl, _RAM_DEE1_
  inc (hl)
  ld a, (_RAM_DEE1_)
  cp $0C
  jr nz, +
  xor a
  ld (_RAM_DEE1_), a
  ld hl, _RAM_DED7_
  inc (hl)
+:
  call LABEL_17D0_
  TailCall LABEL_18FD_

LABEL_17D0_:
  call LABEL_784D_
  ld a, (_RAM_DEBF_ScreenHScrollColumn.Lo)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DEBD_TopRowTilemapAddress.Lo)
  add hl, de
  ld a, l
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, h
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  ret

LABEL_17E6_:
  ld a, (_RAM_DEE5_)
  ld (_RAM_DEE9_), a
  ld a, (_RAM_DEDF_)
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DEDB_)
  ld (_RAM_DEEB_), a
  ld a, (_RAM_DEDC_)
  ld (_RAM_DEEC_), a
  jp +

LABEL_1801_:
  ; Copy a buch of stuff around
  ld a, (_RAM_DEE3_)
  ld (_RAM_DEE9_), a
  ld a, (_RAM_DEDF_)
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED9_)
  ld (_RAM_DEEB_), a
  ld a, (_RAM_DEDA_)
  ld (_RAM_DEEC_), a
+:
  xor a
  ld (_RAM_DECC_), a
  ld (_RAM_DECD_), a
  ld a, (_RAM_DEDF_)
  ld (_RAM_DEC7_), a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  and $1F
  ld (_RAM_DEDD_), a
  call LABEL_188E_
  xor a
  ld (_RAM_DEC7_), a
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  ld c, a
  and $E0
  ld b, a
  ld a, c
  add a, $01
  and $1F
  or b
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  call LABEL_795E_
  ld a, (_RAM_DECD_)
  cp $01
  jr z, +
  xor a
  ld (_RAM_DEC7_), a
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  ld c, a
  and $E0
  ld b, a
  ld a, c
  add a, $01
  and $1F
  or b
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  call LABEL_795E_
  ld a, (_RAM_DECD_)
  cp $01
  JrZRet +
  xor a
  ld (_RAM_DEC7_), a
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  ld c, a
  and $E0
  ld b, a
  ld a, c
  add a, $01
  and $1F
  or b
  ld (_RAM_DED1_MetatilemapPointer.Lo), a

.ifdef JUMP_TO_RET
  call LABEL_795E_
+:ret
.else
  TailCall LABEL_795E_
.endif

LABEL_188E_:
  ld a, $22
  ld (_RAM_DB62_), a
  ld a, $DB
  ld (_RAM_DB63_), a
  xor a
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  ld a, (_RAM_DEEB_)
  and $1F
  or a
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld (_RAM_DEF4_), a
  call LABEL_30EA_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
+:
  ld hl, (_RAM_DED1_MetatilemapPointer)
  ld de, (_RAM_DEDD_)
  add hl, de
  ld de, (DATA_9EB_Constant_C000_MetatilemapBaseAddress)
  add hl, de
  ld (_RAM_DED1_MetatilemapPointer), hl
  jp LABEL_795E_

LABEL_18D2_:
  ; de += _RAM_DEE9_ * 12
  ld bc, DATA_19E2_MultiplesOf12
  ld a, (_RAM_DEE9_)
  ld l, a
  ld h, $00
  add hl, bc
  ld a, (hl)
  ld l, a
  ld a, e
  add a, l
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ret

LABEL_18E6_:
  ld a, (_RAM_DEDF_)
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED5_)
  and $1F
  ld (_RAM_DEDD_), a
  ld a, (_RAM_DED6_)
  ld (_RAM_DEDE_), a
  jp +

LABEL_18FD_:
  ld a, (_RAM_DEE1_)
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED7_)
  and $1F
  ld (_RAM_DEDD_), a
  ld a, (_RAM_DED8_)
  ld (_RAM_DEDE_), a
+:
  xor a
  ld (_RAM_DEC8_), a
  ld (_RAM_DEC9_), a
  ld a, (_RAM_DEED_)
  ld (_RAM_DEC6_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld (_RAM_DEEB_), a
  call LABEL_198A_
  xor a
  ld (_RAM_DEC6_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld l, a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, l
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld a, (_RAM_DED1_MetatilemapPointer.Hi)
  adc a, $00
  and $C3
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  call LABEL_4F1B_
  ld a, (_RAM_DEC9_)
  cp $01
  JrZRet _LABEL_1989_ret
  xor a
  ld (_RAM_DEC6_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld l, a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, l
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld a, (_RAM_DED1_MetatilemapPointer.Hi)
  adc a, $00
  and $C3
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  call LABEL_4F1B_
  ld a, (_RAM_DEC9_)
  cp $01
  JrZRet _LABEL_1989_ret
  xor a
  ld (_RAM_DEC6_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld l, a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, l
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld a, (_RAM_DED1_MetatilemapPointer.Hi)
  adc a, $00
  and $C3
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
.ifdef JUMP_TO_RET
  call LABEL_4F1B_
_LABEL_1989_ret:
  ret
.else
  TailCall LABEL_4F1B
.endif

LABEL_198A_:
  ld a, $42
  ld (_RAM_DB64_), a
  ld a, $DB
  ld (_RAM_DB65_), a
  xor a
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  ld a, (_RAM_DEEB_)
  and $1F
  or a
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld (_RAM_DEF4_), a
  call LABEL_30EA_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
+:
  ld hl, (_RAM_DED1_MetatilemapPointer)
  ld de, (_RAM_DEDD_)
  add hl, de
  ld de, (DATA_9EB_Constant_C000_MetatilemapBaseAddress)
  add hl, de
  ld (_RAM_DED1_MetatilemapPointer), hl
  jp LABEL_4F1B_

LABEL_19CE_:
  ld bc, DATA_19E2_MultiplesOf12
  ld a, (_RAM_DEC6_)
  ld l, a
  ld h, $00
  add hl, bc
  ld a, (hl)
  ld l, a
  ld a, e
  add a, l
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ret

DATA_19E2_MultiplesOf12:
  TimesTableLo 0 12 12

LABEL_19EE_:
  ; Copy 32 bytes from DATA_4105_+_RAM_DB97_TrackType*32 to _RAM_DA00_ ; TODO what is it?
  ld hl, _RAM_DEFD_TrackTypeHighBits
  xor a
  ld (_RAM_DEFD_TrackTypeHighBits), a
  ld a, (_RAM_DB97_TrackType)
  ld (_RAM_DEFC_TrackTypeCopy_WriteOnly), a
  or a
  rl a
  rl (hl)
  rl a
  rl (hl)
  rl a
  rl (hl)
  rl a
  rl (hl)
  rl a
  rl (hl)
  ld e, a
  ld a, (hl)
  ld d, a
  ld hl, DATA_4105_
  add hl, de
  ld bc, 32
  ld de, _RAM_DA00_
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  ; Copy 64 bytes from DATA_4225_TrackMetatileLookup+_RAM_DB97_TrackType*64 to _RAM_DA20_TrackMetatileLookup
  ld hl, _RAM_DEFD_TrackTypeHighBits
  xor a
  ld (_RAM_DEFD_TrackTypeHighBits), a
  ld a, (_RAM_DB97_TrackType)
  ld (_RAM_DEFC_TrackTypeCopy_WriteOnly), a
  or a
  rl a
  rl (hl)
  rl a
  rl (hl)
  rl a
  rl (hl)
  rl a
  rl (hl)
  rl a
  rl (hl)
  rl a
  rl (hl)
  ld e, a
  ld a, (hl)
  ld d, a
  ld hl, DATA_4225_TrackMetatileLookup
  add hl, de
  ld bc, $0040
  ld de, _RAM_DA20_TrackMetatileLookup
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  ; Look up DATA_3EA4_+_RAM_DB97_TrackType*8
  ld d, $00
  ld a, (_RAM_DB97_TrackType)
  or a
  rl a
  rl a
  rl a
  ld e, a
  ld hl, DATA_3EA4_
  add hl, de
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  rl a
  ld e, a
  add hl, de

  ; Variously add/copy it to places...
  ld a, (_RAM_DC54_IsGameGear)
  ld c, a
  ld a, (hl)
  add a, c
  ld (_RAM_DBA0_TopLeftMetatileX), a
  inc hl
  ld a, (hl)
  ld (_RAM_DBA2_TopLeftMetatileY), a
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DBAB_), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DBAC_), a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DBA9_), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DBAA_), a
  call LABEL_48C2_
  JumpToPagedFunction LABEL_237E2_

LABEL_1AC8_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, $01
  ld (_RAM_DF0C_), a
  xor a
  ld (_RAM_DF0E_), a
+:ret

LABEL_1AD8_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, $01
  ld (_RAM_DF0C_), a
  ld (_RAM_DF0E_), a
+:ret

LABEL_1AE7_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, $01
  ld (_RAM_DF0B_), a
  xor a
  ld (_RAM_DF0D_), a
  jp LABEL_2673_
.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_1AFA_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, $01
  ld (_RAM_DF0B_), a
  ld (_RAM_DF0D_), a
  jp LABEL_2673_
.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_1B0C_:
  ld a, (ix+22)
  cp $01
  JrZRet +
  ld de, $0001
  or a
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  sbc hl, de
  ld a, l
  ld (ix+2), a
  ld a, h
  ld (ix+3), a
  ld a, $01
  ld (ix+22), a
+:ret

LABEL_1B2F_:
  ld a, (ix+22)
  cp $01
  JrZRet +
  ld de, $0001
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  add hl, de
  ld a, l
  ld (ix+2), a
  ld a, h
  ld (ix+3), a
  ld a, $01
  ld (ix+22), a
+:ret

LABEL_1B50_:
  ld a, (ix+23)
  cp $01
  JrZRet +
  ld de, $0001
  or a
  ld a, (ix+0)
  ld l, a
  ld a, (ix+1)
  ld h, a
  sbc hl, de
  ld a, l
  ld (ix+0), a
  ld a, h
  ld (ix+1), a
  ld a, $01
  ld (ix+23), a
+:ret

LABEL_1B73_:
  ld a, (ix+23)
  cp $01
  JrZRet +
  ld de, $0001
  ld a, (ix+0)
  ld l, a
  ld a, (ix+1)
  ld h, a
  add hl, de
  ld a, l
  ld (ix+0), a
  ld a, h
  ld (ix+1), a
  ld a, $01
  ld (ix+23), a
+:ret

LABEL_1B94_:
  xor a
  ld (_RAM_DEF2_), a
  ld a, (_RAM_DEF5_)
  ld (_RAM_DEF1_), a
  ld hl, $0000
  ld de, (_RAM_DEF1_)
  ld a, (_RAM_DEF4_)
  rra
  rra
  rra
  jr nc, +
  sla e
  rl d
  sla e
  rl d
  add hl, de
+:
  rra
  jr nc, +
  ld de, (_RAM_DEF1_)
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  add hl, de
+:
  rra
  jr nc, +
  ld de, (_RAM_DEF1_)
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  add hl, de
+:
  rra
  jr nc, +
  ld de, (_RAM_DEF1_)
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  add hl, de
+:
  rra
  jr nc, +
  ld de, (_RAM_DEF1_)
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  sla e
  rl d
  add hl, de
+:
  ld (_RAM_DEF1_), hl
  ret

DATA_1C22_TileData_Shadow: ; 4 tiles @ 3bpp
.incbin "Assets/Car shadow.3bpp"

DATA_1c82_TileVRAMAddresses: ; VRAM addresses for RuffTrux non-car sprites
  ; Tiles $68, $6b, $78, $7b - RuffTrux dust animation
  TileWriteAddressData SpriteIndex_RuffTrux_Blank
  TileWriteAddressData SpriteIndex_RuffTrux_Dust1
  TileWriteAddressData SpriteIndex_RuffTrux_Dust2
  TileWriteAddressData SpriteIndex_RuffTrux_Dust3

  ; $8b, $98, $9b, $e8 - RuffTrux HUD tiles
  TileWriteAddressData SpriteIndex_RuffTrux_Digit1
  TileWriteAddressData SpriteIndex_RuffTrux_Digit2
  TileWriteAddressData SpriteIndex_RuffTrux_Colon
  TileWriteAddressData SpriteIndex_RuffTrux_Digit3

  ; $eb, $f8, $fb - RuffTrux water splash animation
  TileWriteAddressData SpriteIndex_RuffTrux_Water1
  TileWriteAddressData SpriteIndex_RuffTrux_Water2
  TileWriteAddressData SpriteIndex_RuffTrux_Blank2

LABEL_1C98_:
  ld de, (_RAM_DBA0_TopLeftMetatileX)
  ld hl, (_RAM_DE79_)
  add hl, de
  ld (_RAM_DBB1_), hl
  ld de, (_RAM_DBA2_TopLeftMetatileY)
  ld hl, (_RAM_DE7B_)
  add hl, de
  ld (_RAM_DBB3_), hl
  ld a, (_RAM_DE7D_)
  and $3F
  ld (_RAM_DBB5_), a
  ld a, (_RAM_DF4F_)
  ld (_RAM_D5DE_), a
  ret

LABEL_1CBD_:
  xor a
  ld (_RAM_DEF1_), a
  ld (_RAM_DEF2_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_)
  add a, l
  and $1F
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld (_RAM_DEF4_), a
  call LABEL_30EA_
+:
  ld a, (_RAM_DEF1_)
  ld l, a
  ld a, (_RAM_DEF2_)
  ld h, a
  ld de, (_RAM_DE79_)
  add hl, de
  ld de, (_RAM_DBA0_TopLeftMetatileX)
  add hl, de
  ld de, $C000
  add hl, de
  ld a, (hl)
  ret

LABEL_1CF4_:
  JumpToPagedFunction LABEL_1FB35_

LABEL_1CFF_:
  ld a, $01
  ld (_RAM_DF65_), a
  ld (_RAM_DCC5_), a
  ld (_RAM_DD06_), a
  ld (_RAM_DD47_), a
  ld a, (_RAM_DF28_)
  ld (_RAM_DF2A_Positions.Blue), a
  ld a, (_RAM_DF29_)
  ld (_RAM_DF2A_Positions.Yellow), a
  ld a, (_RAM_DF6A_)
  or a
  JrNzRet +
  ld a, $F0
  ld (_RAM_DF6A_), a
+:ret

DATA_1D25_HelicoptersAnimatedPalette_GG:
.rept 2
  GGCOLOUR $0000ee
  GGCOLOUR $4444ee
  GGCOLOUR $8888ee
  GGCOLOUR $eeeeee
.endr

DATA_1D35_PowerboatsAnimatedPalette_GG:
  GGCOLOUR $440088
  GGCOLOUR $444488
  GGCOLOUR $8888ee
  GGCOLOUR $ccccee
  GGCOLOUR $8888ee
  GGCOLOUR $444488
  GGCOLOUR $440088
  GGCOLOUR $000844

LABEL_1D45_:
  ld a, $03
  ld (_RAM_DF2A_Positions.Red), a
  ld (_RAM_DF2A_Positions.Green), a
  ld (_RAM_DF2A_Positions.Blue), a
  ld (_RAM_DF2A_Positions.Yellow), a
  call LABEL_4F8F_
  call LABEL_4FDE_
  call LABEL_502D_
  call LABEL_507C_
  call LABEL_50CB_
  jp LABEL_511A_

; Low bytes
DATA_1D65__Lo:
.db <_LABEL_4BAC_ <_LABEL_4BCA_ <_LABEL_4BE8_ <_LABEL_4C06_ <_LABEL_4C24_ <_LABEL_4C42_ <_LABEL_4C60_ <_LABEL_4C7E_ <_LABEL_4C9C_ <_LABEL_4CBA_ <_LABEL_4CD8_ <_LABEL_4CF6_ <_LABEL_4D14_ <_LABEL_4D32_ <_LABEL_4D50_ <_LABEL_4D6E_ <_LABEL_4D8C_ 

; High bytes
DATA_1D76__Hi:
.db >_LABEL_4BAC_ >_LABEL_4BCA_ >_LABEL_4BE8_ >_LABEL_4C06_ >_LABEL_4C24_ >_LABEL_4C42_ >_LABEL_4C60_ >_LABEL_4C7E_ >_LABEL_4C9C_ >_LABEL_4CBA_ >_LABEL_4CD8_ >_LABEL_4CF6_ >_LABEL_4D14_ >_LABEL_4D32_ >_LABEL_4D50_ >_LABEL_4D6E_ >_LABEL_4D8C_ 

; Data from 1D87 to 1D96 (16 bytes)
DATA_1D87_:
.db $04 $06 $08 $0A $0C $0E $00 $02 $05 $07 $09 $0B $0D $0F $01 $03

; Data from 1D97 to 1DA6 (16 bytes)
DATA_1D97_:
.db $08 $09 $0A $0B $0C $0D $0E $0F $00 $01 $02 $03 $04 $05 $06 $07

; Data from 1DA7 to 1DE6 (64 bytes)
DATA_1DA7_:
.db $0C $0A $08 $06 $04 $02 $00 $0E $0B $09 $07 $05 $03 $01 $0F $0D
.db $04 $02 $00 $0E $0C $0A $08 $06 $03 $01 $0F $0D $0B $09 $07 $05
.db $00 $0E $0C $0A $08 $06 $04 $02 $0F $0D $0B $09 $07 $05 $03 $01
.db $08 $06 $04 $02 $00 $0E $0C $0A $07 $05 $03 $01 $0F $0D $0B $09

LABEL_AFD_ReadControls:
  JumpToPagedFunction LABEL_3773B_ReadControls

LABEL_1DF2_:
  ld b, $00
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld b, $07
+:
  ld a, (_RAM_DBA4_)
  ld (_RAM_DF04_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DF05_), a
  ld a, (_RAM_DC56_)
  ld c, a
  ld a, (_RAM_DED3_HScrollValue)
  and $07
  ld l, a
  ld a, (_RAM_DBA6_)
  add a, $0C
  add a, b
  sub l
  rr a
  rr a
  rr a
  sub c
  and $1F
  ld (_RAM_DE71_), a
  ld a, (_RAM_DED4_VScrollValue)
  and $07
  ld l, a
  ld a, (_RAM_DBA7_)
  add a, $0C
  add a, b
  add a, l
  rr a
  rr a
  rr a
  sub c
  and $1F
  ld (_RAM_DE73_), a
  ld hl, DATA_251E_
  ld de, (_RAM_DE71_)
  add hl, de
  ld de, (_RAM_DEDF_)
  add hl, de
  ld a, (hl)
  ld b, a
  and $0F
  ld (_RAM_DE75_), a
  ld a, b
  rr a
  rr a
  rr a
  rr a
  and $03
  ld (_RAM_DE79_), a
  ld hl, DATA_251E_
  ld de, (_RAM_DE73_)
  add hl, de
  ld de, (_RAM_DEE5_)
  add hl, de
  ld a, (hl)
  ld b, a
  and $0F
  ld (_RAM_DE77_), a
  ld a, b
  rr a
  rr a
  rr a
  rr a
  and $03
  ld (_RAM_DE7B_), a
  ld a, (_RAM_DE79_)
  ld l, a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  add a, l
  and $1F
  ld c, a
  ld b, $00
  xor a
  ld (_RAM_DEF1_), a
  ld (_RAM_DEF2_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_)
  add a, l
  and $1F
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld (_RAM_DEF4_), a
  call LABEL_30EA_
+:
  ld a, (_RAM_DEF1_)
  ld l, a
  ld a, (_RAM_DEF2_)
  ld h, a
  add hl, bc
  ld (_RAM_D585_), hl
  ld de, $C000
  add hl, de
  ld a, (hl)
  ld (_RAM_DE7D_), a
  ld hl, (_RAM_D585_)
  ld de, _RAM_C400_TrackIndexes
  add hl, de
  ld a, (hl)
  ld (_RAM_D587_), a
  ld hl, DATA_254E_TimesTable18Lo
  ld a, (_RAM_DE7D_)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  ld hl, DATA_258F_TimesTable18Hi
  add hl, de
  ld a, (hl)
  ld d, a
  ld e, c
  ld hl, _RAM_C800_WallData
  add hl, de
  ld b, h
  ld c, l
  ld hl, DATA_2652_TimesTable12Lo
  ld de, (_RAM_DE77_)
  add hl, de
  ld a, (hl)
  ld l, a
  xor a
  ld h, a
  ld de, (_RAM_DE75_)
  add hl, de
  ld a, l
  ld (_RAM_DE6B_), a
  ld a, h
  ld (_RAM_DE6C_), a
  ld de, DATA_16A38_DivideBy8
  add hl, de
  ld a, :DATA_16A38_DivideBy8
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  xor a
  ld h, a
  add hl, bc
  ld a, (hl)
  ld (_RAM_DE6F_), a
  ld a, (_RAM_DE6B_)
  ld l, a
  ld a, (_RAM_DE6C_)
  ld h, a
  ld de, DATA_169A8_IndexToBitmask
  add hl, de
  ld a, :DATA_169A8_IndexToBitmask
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, (_RAM_DE7D_)
  and $3F
  jr z, ++
  cp $1A
  jr z, ++
+:
  ld a, (_RAM_DE6F_)
  and b
  jp z, LABEL_1FDC_
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, ++
  ld a, :DATA_37232_FourByFour_
  ld (PAGING_REGISTER), a
  ld hl, DATA_37232_FourByFour_
  ld d, $00
  ld a, (_RAM_DE7D_)
  and $3F
  ld e, a
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, l
  or a
  jr nz, LABEL_1FDC_
++:
  ld a, (_RAM_DF58_)
  or a
  jr nz, LABEL_1FDC_
  ld a, (_RAM_DE8C_)
  or a
  jr nz, LABEL_1FDC_
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  ld a, (_RAM_DE7D_)
  cp $15
  jr z, +
  cp $0D
  jr c, +
  cp $18
  jr c, LABEL_1FDC_
+:
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr nz, +
  ld a, SFX_03_Crash
  ld (_RAM_D963_SFXTrigger_Player1), a
+:
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  call LABEL_28AC_
  xor a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DF7B_), a
  ld a, (_RAM_DBA4_)
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DBA7_), a
LABEL_1FBF_:
  ld a, (_RAM_DF00_)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_DF01_), a
  xor a
  ld (_RAM_DEA3_), a
  ld (_RAM_DEA0_), a
  ld (_RAM_DE99_), a
  ld a, $06
  ld (_RAM_DEAC_), a
+:
  jp +

LABEL_1FDC_:
  ld a, (_RAM_DBA4_)
  ld (_RAM_DE5C_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DE5D_), a
  ld a, (_RAM_DBA6_)
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DBA7_)
  ld (_RAM_DBA5_), a
+:
  ld hl, DATA_25D0_TimesTable36Lo
  ld a, (_RAM_DE7D_)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  ld hl, DATA_2611_TimesTable36Hi
  add hl, de
  ld a, (hl)
  ld d, a
  ld e, c
  ld hl, _RAM_CC80_BehaviourData
  add hl, de
  ld b, h
  ld c, l
  ld a, (_RAM_DE6B_)
  ld l, a
  ld a, (_RAM_DE6C_)
  ld h, a
  ld a, :DATA_1B1A2_
  ld (PAGING_REGISTER), a
  ld de, DATA_1B1A2_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  xor a
  ld h, a
  add hl, bc
  ld a, (_RAM_DF58_)
  or a
  jp nz, LABEL_23DD_
  ld a, (hl) ; Load data from ???
  ld (_RAM_DF79_CurrentCombinedByte), a ; Store here
  ld h, a ; And two copies
  ld l, a
  ld a, (_RAM_DC51_PreviousCombinedByte) ; Compare to this
  cp l
  jr z, +
  ld (_RAM_DC52_PreviousCombinedByte2), a ; If not the same, shuffle over and put the new one there
  ld a, l
  ld (_RAM_DC51_PreviousCombinedByte), a
+:
  ld a, h
  and $F0 ; High 4 bits are behaviour
  rr a
  rr a
  rr a
  rr a
  ld b, a ; -> b

  ; Look up track type in behaviour lookup
  ld d, $00
  ld a, (_RAM_DB97_TrackType)
  or a
  rl a
  rl a
  rl a
  rl a
  ld e, a
  ld hl, DATA_242E_BehaviourLookup
  add hl, de

  ; mask out lsb if it is a boats track
  ld a, $0F ; c = $f
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, $0E ; unless boats -> mask to low 7 bits
  ld c, a
+:ld a, b ; mask against the high nibble
  and c

  ld e, a ; then look up the behaviour data
  ld d, $00
  add hl, de
  ld a, (hl)

  ld b, a
  ld a, (_RAM_DEF9_CurrentBehaviour)
  ld (_RAM_DEFA_PreviousBehaviour), a
  cp b
  jr z, +
  ld (_RAM_DEFB_PreviousDifferentBehaviour), a
+:ld a, b
  ld (_RAM_DEF9_CurrentBehaviour), a

  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_20E3_BehaviourEnd_ret

  xor a
  ld (_RAM_D5CD_CarIsSkidding), a

  ; Look up behaviours
  ld a, (_RAM_DEF9_CurrentBehaviour)
  or a
  jp z, LABEL_2121_Behaviour0 ; normal track
  cp $06
  jp z, LABEL_2175_Behaviour6 ; bump
  cp $04
  jp z, LABEL_21F3_Behavour4 ; big jump
  cp $03
  jp z, LABEL_21E1_Behaviour3 ; ??
  cp $0A
  jp z, LABEL_2156_BehaviourA ; death?
  cp $0B
  jp z, LABEL_21BF_BehaviourB ; ??
  cp $0D
  jp z, LABEL_214B_BehaviourD ; ??
  cp $01
  jp z, LABEL_29BC_Behaviour1_FallToFloor ; floor
  cp $0E
  jp z, LABEL_65D0_BehaviourE ; water
  cp $0F
  jp z, LABEL_2934_BehaviourF
  cp $12
  jp z, LABEL_2C69_Behaviour12
  cp $02
  jr z, LABEL_20E4_Behaviour2_Dust ; + ; Dust
  cp $05
  jr z, LABEL_2128_Behaviour5_Skid ; ++ ; Skid
  cp $08
  jp z, LABEL_2C29_Behaviour8_Sticky
  cp $09
  jp z, LABEL_2AB5_Behaviour9
  cp $13
  jp z, LABEL_2AA0_Behaviour13
_LABEL_20E3_BehaviourEnd_ret:
  ret

LABEL_20E4_Behaviour2_Dust
+:
  ; Behaviour 2 = dust/chalk
  ld a, (_RAM_DE92_EngineVelocity)
  cp $07
  JrCRet + ; Only when driving fast enough
  xor a
  ld (_RAM_DD9A_), a
  ld a, $01
  ld (_RAM_DD9B_), a
+:ret

++:
LABEL_2128_Behaviour5_Skid
  ; Behaviour 5 = skid
  ld a, $01
  ld (_RAM_D5CD_CarIsSkidding), a
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  JrZRet +++ ; Not using the engine
  ld a, $01
  ld (_RAM_DD9A_), a ; set ???
  ld (_RAM_DD9B_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_3_TurboWheels
  JrZRet +++
  cp TT_7_RuffTrux
  JrZRet +++
  cp TT_5_Warriors
  jr nz, +
  ld a, $08
  jr ++
+:ld a, $10
++:
  ld (_RAM_D5B6_), a ; set to 8 or 16 (or not at all) depending on track type
+++:ret

LABEL_2121_Behaviour0:
  ld a, (_RAM_DF00_)
  or a
  JrNzRet _LABEL_20E3_BehaviourEnd_ret
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $04
  jr z, +
  cp $0B
  jr z, +
  cp $0D
  jr z, +
  cp $03
  JrNzRet _LABEL_20E3_BehaviourEnd_ret
+:; If coming from 3, 4, b, d:
  ld a, $1C
  ld (_RAM_DF0A_), a
  ld a, $08
  ld (_RAM_DF02_), a
  xor a
  ld (_RAM_DF03_), a
  jp LABEL_22A9_

LABEL_214B_BehaviourD:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $0D
  JrZRet +
  jp LABEL_2175_Behaviour6
.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_2156_BehaviourA:
  ld a, (_RAM_DF00_)
  or a
  JrNzRet +
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $0B
  ; ret nz would be smaller
  jr z, ++
+:ret

++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  jp LABEL_29BC_Behaviour1_FallToFloor

+:; jp z would be smaller
  jp LABEL_2934_BehaviourF

LABEL_2175_Behaviour6:
  ld a, (_RAM_DF00_)
  or a
  JpNzRet _LABEL_22CC_ret ; ret
  ld a, (_RAM_DE2F_)
  or a
  jr z, +
  cp $0B
  jp ++

+:
  ld a, (_RAM_DF0F_)
++:
  ld l, a
  ld a, (_RAM_DE96_)
  add a, l
  cp $0B
  jr nc, +
  ld (_RAM_DE94_), a
  jp ++

+:
  ld a, $0B
  ld (_RAM_DE94_), a
++:
  ld hl, DATA_24AE_
  ld de, (_RAM_DE94_)
  add hl, de
  ld a, (hl)
  ld (_RAM_DF0A_), a
  ld hl, DATA_24BE_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF02_), a
  cp $82
  JpZRet _LABEL_22CC_ret ; ret
  ld a, $01
  ld (_RAM_DF03_), a
  jp LABEL_22A9_

LABEL_21BF_BehaviourB:
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  jr z, ++
  cp TT_1_FourByFour
  JrNzRet +
-:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  or a
  jp z, LABEL_2200_
  cp $06
  jp z, LABEL_2200_
+:ret

++:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $1A
  jr z, -
  ret

LABEL_21E1_Behaviour3:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $07
  JrZRet  +
  ld a, (_RAM_DEFB_PreviousDifferentBehaviour)
  or a
  jr z, LABEL_2200_
  cp $06
  jr z, LABEL_2200_
+:ret

LABEL_21F3_Behavour4:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $07
  jr z, +
  ld a, (_RAM_DEFB_PreviousDifferentBehaviour)
  or a
  JrNzRet _LABEL_2222_ret
LABEL_2200_:
  ld a, (_RAM_DE5C_)
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DE5D_)
  ld (_RAM_DBA5_), a
  call LABEL_28AC_
  xor a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DBA4_)
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DBA7_), a
_LABEL_2222_ret:
  ret

+:
  ld a, (_RAM_DF00_)
  or a
  JpNzRet _LABEL_22CC_ret ; ret
  ld a, (_RAM_D5CF_Player1Handicap)
  ld l, a
  ld a, (_RAM_DE96_)
  add a, l
  ld (_RAM_DE94_), a
  ld a, (_RAM_DEB5_)
  or a
  jr nz, +
  ld a, (_RAM_DE2F_)
  or a
  jr z, +++
  jp ++

+:
  ld a, (_RAM_DF0F_)
++:
  ld l, a
  ld a, (_RAM_DE96_)
  add a, l
  cp $0B
  jr nc, +
  ld (_RAM_DE94_), a
  jp ++

+:
  ld a, $0B
  ld (_RAM_DE94_), a
++:
  ld (_RAM_DF10_), a
  ld a, $01
  ld (_RAM_DEB6_), a
+++:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24EE_
  jp ++

+:
  ld hl, DATA_24CE_
++:
  ld de, (_RAM_DE94_)
  add hl, de
  ld a, (hl)
  or a
  JrZRet _LABEL_2222_ret
  ld (_RAM_DF0A_), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24FE_
  jp ++

+:
  ld hl, DATA_24DE_
++:
  add hl, de
  ld a, (hl)
  ld (_RAM_DF02_), a
  ld a, (_RAM_DEB5_)
  or a
  jr nz, +
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DF11_), a
  ld a, (_RAM_DE96_)
  ld (_RAM_DF0F_), a
+:
  ld a, $02
  ld (_RAM_DF03_), a
LABEL_22A9_:
  ld a, (_RAM_DF04_)
  ld (_RAM_DF06_), a
  ld a, (_RAM_DF05_)
  ld (_RAM_DF07_), a
  ld a, $01
  ld (_RAM_DF00_), a
  ld hl, (_RAM_D95B_)
  ld (_RAM_D58C_), hl
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrZRet _LABEL_22CC_ret ; ret
  ld a, SFX_02_HitGround
  ld (_RAM_D963_SFXTrigger_Player1), a
_LABEL_22CC_ret:
  ret

LABEL_22CD_:
  ld d, $00
  ld a, (_RAM_DF00_)
  or a
  JpZRet _LABEL_23C2_ret
  ld hl, DATA_1B232_SinTable ; $B232
  ld e, a
  add hl, de
  ld a, :DATA_1B232_SinTable ; $06
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DF0A_)
  ld (_RAM_DEF4_), a
  call LABEL_1B94_
  ld a, (_RAM_DEF2_)
  ld l, a
  ld a, (_RAM_DBA4_)
  add a, l
  add a, $04
  ld (_RAM_DE5E_), a
  ld a, (_RAM_DBA5_)
  add a, l
  add a, $04
  ld (_RAM_DE62_), a
  ld a, $01
  ld (_RAM_DE66_), a
  ld a, b
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DF0A_)
  and $FC
  rr a
  rr a
  ld (_RAM_DEF4_), a
  call LABEL_1B94_
  ld a, (_RAM_DEF2_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  ld (_RAM_DF06_), a
  ld a, (_RAM_DBA5_)
  sub l
  ld (_RAM_DF07_), a
  ld a, (_RAM_DF02_)
  ld l, a
  ld a, (_RAM_DF00_)
  add a, l
  ld (_RAM_DF00_), a
  cp $82
  JpCRet _LABEL_23C2_ret
  ld hl, (_RAM_D58C_)
  ld (_RAM_D95B_), hl
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, SFX_11
  jp ++

+:
  ld a, SFX_02_HitGround
++:
  ld (_RAM_D963_SFXTrigger_Player1), a
  xor a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DE8C_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  xor a
  ld (_RAM_D5C5_), a
+:
  ld a, (_RAM_DF0A_)
  cp $1E
  jr c, +
  cp $60
  jr c, LABEL_23C3_
  jp LABEL_23D0_

+:
  ld a, (_RAM_DF03_)
  cp $02
  jr nz, ++
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE90_CarDirection), a
  xor a
  ld (_RAM_DEA3_), a
  ld (_RAM_DEA0_), a
  ld (_RAM_DE99_), a
  ld a, $06
  ld (_RAM_DEAC_), a
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DE96_), a
  ld a, (_RAM_DF01_)
  cp $01
  jr z, ++
  ld a, (_RAM_DEB6_)
  or a
  jr z, +
  ld a, (_RAM_DF10_)
  ld (_RAM_DF0F_), a
  xor a
  ld (_RAM_DEB6_), a
+:
  ld a, $01
  ld (_RAM_DEB5_), a
  ret

++:
  xor a
  ld (_RAM_DF01_), a
_LABEL_23C2_ret:
  ret

LABEL_23C3_:
  ld a, $0A
  ld (_RAM_DF0A_), a
  ld a, $0C
  ld (_RAM_DF02_), a
  jp LABEL_22A9_

LABEL_23D0_:
  ld a, $20
  ld (_RAM_DF0A_), a
  ld a, $08
  ld (_RAM_DF02_), a
  jp LABEL_22A9_

LABEL_23DD_:
  ld a, (_RAM_DE7D_)
  and $C0
  ld (_RAM_DE54_), a
  ld a, (hl)
  and $0F
  ld e, a
  ld d, $00
  ld a, (_RAM_DE54_)
  or a
  jr z, +
  and $80
  jr z, +
  ld a, (_RAM_DE7D_)
  and $3F
  ld c, a
  ld hl, _RAM_D900_
  ld b, $00
  add hl, bc
  ld a, (hl)
  and $60
  sra a
  ld c, a
  ld b, $00
  ld hl, DATA_1DA7_
  add hl, bc
  jp ++

+:
  ld hl, DATA_1D87_
++:
  add hl, de
  ld a, (hl)
  ld (_RAM_DE55_), a
  ld a, (_RAM_DE54_)
  and $40
  JrZRet +
  ld hl, DATA_1D97_
  ld d, $00
  ld a, (_RAM_DE55_)
  ld e, a
  add hl, de
  ld a, (hl)
  ld (_RAM_DE55_), a
+:ret

; Data from 242E to 24AD (128 bytes)
DATA_242E_BehaviourLookup: ; Behaviour lookup per track type
.db $00 $00 $01 $00 $02 $00 $03 $00 $04 $00 $05 $00 $06 $00 $07 $00
.db $00 $06 $05 $08 $01 $0C $0D $0B $0B $0B $0D $0B $0B $00 $00 $00
.db $00 $00 $00 $00 $06 $00 $06 $00 $00 $00 $00 $00 $06 $00 $00 $00
.db $00 $02 $05 $12 $06 $00 $00 $00 $00 $00 $00 $00 $06 $06 $06 $00
.db $00 $0B $02 $00 $00 $01 $13 $00 $09 $09 $0C $0B $09 $00 $0A $0B
.db $00 $00 $02 $00 $06 $00 $05 $00 $08 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $06 $05
.db $00 $00 $06 $03 $06 $00 $05 $0E $00 $00 $00 $00 $00 $00 $00 $00

; Data from 24AE to 24BD (16 bytes)
DATA_24AE_:
.db $00 $00 $00 $00 $00 $0C $10 $14 $18 $1C $20 $20 $20 $20 $20 $20

; Data from 24BE to 24CD (16 bytes)
DATA_24BE_:
.db $82 $82 $82 $82 $82 $0A $0A $09 $09 $08 $08 $08 $08 $08 $08 $08

; Data from 24CE to 24DD (16 bytes)
DATA_24CE_:
.db $00 $00 $00 $00 $00 $00 $28 $28 $38 $38 $58 $78 $78 $78 $78 $78

; Data from 24DE to 24ED (16 bytes)
DATA_24DE_:
.db $82 $82 $82 $82 $82 $82 $06 $06 $05 $05 $04 $03 $03 $03 $03 $03

; Data from 24EE to 24FD (16 bytes)
DATA_24EE_:
.db $00 $00 $00 $00 $00 $28 $28 $38 $38 $58 $78 $88 $88 $88 $88 $88

; Data from 24FE to 250D (16 bytes)
DATA_24FE_:
.db $82 $82 $82 $82 $82 $06 $06 $05 $05 $04 $03 $03 $03 $03 $03 $03

; Data from 250E to 251D (16 bytes)
DATA_250E_:
.db $08 $09 $0A $0B $0C $0D $0E $0F $00 $01 $02 $03 $04 $05 $06 $07

; Data from 251E to 254D (48 bytes)
DATA_251E_:
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $10 $11 $12 $13
.db $14 $15 $16 $17 $18 $19 $1A $1B $20 $21 $22 $23 $24 $25 $26 $27
.db $28 $29 $2A $2B $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B

DATA_254E_TimesTable18Lo:
  TimesTableLo 0, 18, 65

DATA_258F_TimesTable18Hi:
  TimesTableHi 0, 18, 65

DATA_25D0_TimesTable36Lo:
  TimesTableLo 0, 36, 65

DATA_2611_TimesTable36Hi:
  TimesTableHi 0, 36, 65

DATA_2652_TimesTable12Lo:
  TimesTableLo 0, 12, 12

-:ret

LABEL_265F_:
  ld a, (_RAM_DEB5_)
  or a
  JpZRet -
  call LABEL_26F5_
  ld a, (_RAM_DEB5_)
  or a
  JpZRet -
  call LABEL_2724_
LABEL_2673_:
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DEB0_)
+:cp l
  jr z, ++
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_)
  sub l
  ld (_RAM_DEAF_), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_), a
+++:
  ld a, (_RAM_DF0E_)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF0E_)
  ld (_RAM_DEB2_), a
  ret

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  ret

LABEL_26F5_:
  ld hl, _RAM_DEB7_
  inc (hl)
  ld a, (hl)
  cp $0A
  jr nz, ++
  ld a, $00
  ld (_RAM_DEB7_), a
  ld hl, _RAM_DF0F_
  ld a, (hl)
  or a
  jr nz, +
  ld (_RAM_DEB5_), a
  ret

+:
  ld a, (_RAM_DF00_)
  or a
  jr nz, ++
  dec (hl)
++:
  ld hl, _RAM_DEAE_
  inc (hl)
  ld a, (hl)
  cp $06
  JrNzRet +
  ld a, $00
  ld (_RAM_DEAE_), a
+:ret

LABEL_2724_:
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_DF0F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_DF0F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_
  ld a, (_RAM_DF11_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF0B_), a
  ld hl, DATA_40E5_Sign_
  ld a, (_RAM_DF11_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF0D_), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF0D_), a
++:
  ld hl, DATA_3FD3_
  ld a, (_RAM_DF11_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF0C_), a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_DF11_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF0E_), a
  ret

+:
  ld a, $01
  ld (_RAM_DF0E_), a
  ret

LABEL_27B1_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, LABEL_27FB_
  ld a, (_RAM_DB7D_)
  xor $01
  ld (_RAM_DB7D_), a
  ld a, (_RAM_DEB0_)
  cp $01
  jr z, +
  ld hl, _RAM_DEAF_
  ld a, (_RAM_DBA6_)
  sub (hl)
  ld (_RAM_DBA6_), a
  jp ++

+:
  ld hl, _RAM_DEAF_
  ld a, (_RAM_DBA6_)
  add a, (hl)
  ld (_RAM_DBA6_), a
++:
  ld a, (_RAM_DEB2_)
  cp $01
  jr z, +
  ld hl, _RAM_DEB1_VScrollDelta
  ld a, (_RAM_DBA7_)
  sub (hl)
  ld (_RAM_DBA7_), a
  jp LABEL_27FB_

+:
  ld hl, _RAM_DEB1_VScrollDelta
  ld a, (_RAM_DBA7_)
  add a, (hl)
  ld (_RAM_DBA7_), a
LABEL_27FB_:
  ld a, (_RAM_D5C5_)
  cp $01
  JrZRet _LABEL_284F_ret
  ld a, (_RAM_D5B0_)
  or a
  JrNzRet _LABEL_284F_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_284F_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet _LABEL_284F_ret
  ld a, (_RAM_DB80_)
  ld l, a
  ld a, (_RAM_DEAF_)
  add a, l
  ld l, a
  and $01
  jr z, +
  ld a, $01
  ld (_RAM_DB80_), a
-:
  ld a, l
  srl a
  ld (_RAM_DEAF_), a
  jp ++

+:
  xor a
  ld (_RAM_DB80_), a
  jp -

++:
  ld a, (_RAM_DB81_)
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  add a, l
  ld l, a
  and $01
  jr z, +
  ld a, $01
  ld (_RAM_DB81_), a
-:
  ld a, l
  srl a
  ld (_RAM_DEB1_VScrollDelta), a
_LABEL_284F_ret:
  ret

+:
  xor a
  ld (_RAM_DB81_), a
  jp -

LABEL_2857_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet _LABEL_28A4_ret
  ld a, (_RAM_DCFB_)
  ld (_RAM_DB7E_), a
  ld a, (_RAM_DB82_)
  ld l, a
  ld a, (_RAM_DB7E_)
  add a, l
  ld l, a
  and $01
  jr z, +
  ld a, $01
  ld (_RAM_DB82_), a
-:
  ld a, l
  srl a
  ld (_RAM_DB7E_), a
  jp ++

+:
  xor a
  ld (_RAM_DB82_), a
  jp -

++:
  ld a, (_RAM_DCFC_)
  ld (_RAM_DB7F_), a
  ld a, (_RAM_DB83_)
  ld l, a
  ld a, (_RAM_DB7F_)
  add a, l
  ld l, a
  and $01
  jr z, +
  ld a, $01
  ld (_RAM_DB83_), a
-:
  ld a, l
  srl a
  ld (_RAM_DB7F_), a
_LABEL_28A4_ret:
  ret

+:
  xor a
  ld (_RAM_DB83_), a
  jp -

LABEL_28AC_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, +
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ld a, (_RAM_DE90_CarDirection)
  ld l, a
  ld h, $00
  ld de, DATA_250E_
  add hl, de
  ld a, (hl)
  ld c, a
  jr LABEL_28D6_

+:
  ld a, (_RAM_DE90_CarDirection)
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr z, +
  cp TT_7_RuffTrux
  jr nz, ++
LABEL_28D6_:
  ld a, $04
  jp +++

+:
  ld a, (_RAM_DF7B_)
  or a
  jr z, LABEL_28D6_
  ld a, (_RAM_DF7A_)
  ld c, a
  jr LABEL_28D6_

++:
  ld a, (_RAM_DE96_)
  cp $04
  jr nc, +
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DEB5_), a
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE90_CarDirection), a
  ret

+:
  ld a, (_RAM_DE96_)
+++:
  and $FE
  rr a
  ld (_RAM_DF0F_), a
  and $FE
  rr a
  ld (_RAM_DE92_EngineVelocity), a
  ld d, $00
  ld a, c
  ld e, a
  ld hl, DATA_250E_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF11_), a
  ld a, $01
  ld (_RAM_DEB5_), a
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE90_CarDirection), a
  xor a
  ld (_RAM_DEA3_), a
  ld (_RAM_DEA0_), a
  ld (_RAM_DE99_), a
  ld a, $06
  ld (_RAM_DEAC_), a
  ret

LABEL_2934_BehaviourF:
  ld a, (_RAM_DF00_)
  or a
  JrNzRet +
  ld a, (_RAM_DF58_)
  or a
  JrNzRet +
  ld a, SFX_05
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, CarState_1_Exploding
  ld (_RAM_DF59_CarState), a
  ld (_RAM_DF58_), a
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  jp LABEL_71C7_

+:ret

LABEL_2961_:
  ld a, (ix+20)
  or a
  JrNzRet +
  ld a, (ix+46)
  or a
  JrNzRet +
  ld a, $01
  ld (ix+46), a
  xor a
  ld (ix+11), a
  ld (ix+20), a
  ld a, (ix+39)
  ld l, a
  ld a, (ix+40)
  ld h, a
  ld de, $0008
  add hl, de
  xor a
  ld (hl), a
  ld a, (ix+45)
  or a
  jr z, +++
  cp $01
  jr z, ++
  ld a, $01
  ld (_RAM_DF5C_), a
+:ret

++:
  ld a, $01
  ld (_RAM_DF5B_), a
  ret

+++:
  ld a, CarState_1_Exploding
  ld (_RAM_DF5A_CarState3), a
  ret

LABEL_29A3_:
  ld a, (_RAM_DF00_)
  or a
  jr z, +
  cp $80
  JrCRet ++
+:
  ld a, (_RAM_DF58_)
  or a
  JrNzRet ++
  ld a, SFX_09_EnterPoolTableHole
  ld (_RAM_D963_SFXTrigger_Player1), a
  jp LABEL_29BC_Behaviour1_FallToFloor

++:ret

LABEL_29BC_Behaviour1_FallToFloor:
  ld a, (_RAM_D5B0_)
  or a
  JrNzRet _LABEL_2A36_ret
  ld a, (_RAM_DF00_) ; 0 or <$80 -> do nothing
  or a
  jr z, +
  cp $80
  JrCRet _LABEL_2A36_ret
+:
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_2A36_ret
  ld a, (_RAM_D5BD_)
  or a
  jr nz, +
  ; Play sound effect
  ld a, SFX_0E_FallToFloor
  ld (_RAM_D963_SFXTrigger_Player1), a
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ; Two player
  ld a, (_RAM_DD1A_)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5B0_), a
+:; One player
  ld a, (_RAM_D5BF_)
  or a
  jr z, +
  ld a, CarState_4_Submerged
  jp ++
+:ld a, CarState_3_Falling
++:ld (_RAM_DF59_CarState), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  xor a
  ld (_RAM_D95E_), a
LABEL_2A08_:
  ld a, $01
  ld (_RAM_DF58_), a
  ; Zero car state
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DF7B_), a
  ld (_RAM_D5B9_), a
  ld (_RAM_DD08_), a
  ld (_RAM_DF79_CurrentCombinedByte), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, LABEL_2A4A_
  jp LABEL_71C7_

_LABEL_2A36_ret:
  ret

-:
  xor a
  ld (_RAM_DB80_), a
  ld (_RAM_DB81_), a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, $01
  ld (_RAM_D945_), a
  ret

LABEL_2A4A_:
  ld a, (_RAM_DF59_CarState)
  cp CarState_3_Falling
  jr z, -
  cp CarState_4_Submerged
  jr z, -
LABEL_2A55_:
  xor a
  ld (_RAM_DCF7_), a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, $02
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld a, $01
  ld (_RAM_DF81_), a
  ld a, (_RAM_DCFD_)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBA9_)
  add hl, de
  ld de, $0080
  or a
  sbc hl, de
  ld a, l
  and $FC
  ld l, a
  ld (_RAM_DBAD_), hl
  ld a, (_RAM_DCFE_)
  cp $F0
  jr c, +
  xor a
+:
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBAB_)
  add hl, de
  ld de, $0068
  or a
  sbc hl, de
  ld a, l
  and $FC
  ld l, a
  ld (_RAM_DBAF_), hl
  ret

LABEL_2AA0_Behaviour13:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $16
  jp z, LABEL_2200_
  cp $2A
  jp z, LABEL_2200_
  cp $3F
  jp z, LABEL_2200_
  ret

LABEL_2AB5_Behaviour9:
  ld a, (_RAM_DF00_)
  or a
  jr z, +
  ret

+:
  ld a, (_RAM_DE8C_)
  cp $01
  JpZRet _LABEL_2C28_ret
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jp z, LABEL_2B7D_
  cp $01
  jp z, LABEL_2B57_
  ld a, (_RAM_DC52_PreviousCombinedByte2)
  and $10
  jp nz, LABEL_29A3_
  ld a, (_RAM_DF55_)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (_RAM_DE7D_)
  and $3F
  cp $3A
  jp nz, LABEL_29A3_
  jp +++

+:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $3A
  jp nz, LABEL_29A3_
  jp ++++

++:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $1D
  jr z, +++++
  cp $1E
  jp nz, LABEL_29A3_
  jp +++++

+++:
  xor a
  ld (_RAM_DF55_), a
  ld hl, $0B38
  ld (_RAM_DBAD_), hl
  ld hl, $0B50
  ld (_RAM_DBAF_), hl
  ld a, $0E
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

++++:
  ld a, $02
  ld (_RAM_DF55_), a
  ld hl, $07F0
  ld (_RAM_DBAD_), hl
  ld hl, $0620
  ld (_RAM_DBAF_), hl
  ld a, $04
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

+++++:
  ld a, $01
  ld (_RAM_DF55_), a
  ld hl, $06B8
  ld (_RAM_DBAD_), hl
  ld hl, $0148
  ld (_RAM_DBAF_), hl
  ld a, $0A
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

LABEL_2B57_:
  ld a, (_RAM_DC52_PreviousCombinedByte2)
  and $10
  jp nz, LABEL_29A3_
  ld a, (_RAM_DE7D_)
  and $3F
  cp $39
  jp nz, LABEL_29A3_
  ld hl, $0100
  ld (_RAM_DBAD_), hl
  ld hl, $00E0
  ld (_RAM_DBAF_), hl
  ld a, $06
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

LABEL_2B7D_:
  ld a, (_RAM_DC52_PreviousCombinedByte2)
  and $10
  jp nz, LABEL_29A3_
  ld a, (_RAM_DE7D_)
  and $3F
  cp $34
  jr z, +
  cp $35
  jp nz, LABEL_29A3_
+:
  ld hl, $0618
  ld (_RAM_DBAD_), hl
  ld hl, $0500
  ld (_RAM_DBAF_), hl
  ld a, $0C
  ld (_RAM_DE8D_), a
LABEL_2BA4_:
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_2C28_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DD1F_)
  ld (_RAM_D5C6_), a
  or a
  jr nz, +
  ld hl, $0110
  ld (_RAM_DF56_), hl
+:
  xor a
  ld (_RAM_D95E_), a
  ld a, SFX_09_EnterPoolTableHole
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, CarState_3_Falling
  ld (_RAM_DF59_CarState), a
  ld a, $01
  ld (_RAM_DF58_), a
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ld (_RAM_DE2F_), a
  ld a, $01
  ld (_RAM_DE8C_), a
  ld hl, (_RAM_DBAD_)
  ld (_RAM_DEF1_), hl
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0070
  jp ++

+:
  ld de, $004C
++:
  ld hl, (_RAM_DEF1_)
  or a
  sbc hl, de
  ld (_RAM_DBAD_), hl
  ld hl, (_RAM_DBAF_)
  ld (_RAM_DEF1_), hl
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0060
  jp ++

+:
  ld de, $0038
++:
  ld hl, (_RAM_DEF1_)
  or a
  sbc hl, de
  ld (_RAM_DBAF_), hl
_LABEL_2C28_ret:
  ret

LABEL_2C29_Behaviour8_Sticky:
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr z, Behaviour8_Sticky_FourByFour
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  JrZRet +++ ; 0 -> do nothing
  cp $01
  JrZRet +++ ; 1 -> do nothing
  cp $02
  jr z, +   ; 2 -> subtract 1
  sub $02   ; Otherwise, subtract 2
  jp ++

+:
  sub $01
++:
  ld (_RAM_DE92_EngineVelocity), a
  ld a, SFX_07_EnterSticky
  ld (_RAM_D963_SFXTrigger_Player1), a
+++:ret

++++:
Behaviour8_Sticky_FourByFour:
  ld a, (_RAM_DE92_EngineVelocity)
  cp $03
  JrCRet +++ ; 3 -> do nothing
  cp $04
  jr z, +   ; 4 -> subtract 1
  sub $02   ; Otherwise, subtract 2
  jp ++

+:
  sub $01
++:
  ld (_RAM_DE92_EngineVelocity), a
  ld a, SFX_07_EnterSticky
  ld (_RAM_D963_SFXTrigger_Player1), a
+++:ret

LABEL_2C69_Behaviour12:
  ld a, (_RAM_DF00_)
  or a
  JrNzRet _LABEL_2CD0_ret
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_2CD0_ret
  ld a, SFX_08
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  xor a
  ld (_RAM_D95E_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  ld (_RAM_D5BF_), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  xor a
  ld (_RAM_DF73_), a
  jp LABEL_29BC_Behaviour1_FallToFloor

+:
  ld a, CarState_4_Submerged
  ld (_RAM_DF59_CarState), a
  ld a, $01
  ld (_RAM_DF58_), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld a, $01
  ld (_RAM_DE92_EngineVelocity), a
  xor a
  ld (_RAM_DF73_), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ld (_RAM_DE2F_), a
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE90_CarDirection), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  jp LABEL_71C7_

_LABEL_2CD0_ret:
  ret

+:
  jp LABEL_2A4A_

LABEL_2CD4_:
  ld a, (_RAM_DF6B_)
  add a, $01
  and $03
  ld (_RAM_DF6B_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF73_)
  add a, $01
  ld (_RAM_DF73_), a
  cp $03
  jr z, ++
  jr c, ++
  cp $0C
  jr c, +
  ld a, CarState_1_Exploding
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_DF5D_), a
  ld a, $08
  ld (_RAM_DF61_), a
+:
  ld a, $03
++:
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ret

LABEL_2D07_UpdatePalette_RuffTruxSubmerged:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ; Game Gear
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrNzRet + ; ret
  call LABEL_3F22_ScreenOff
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  sla a
  ld hl, DATA_2D36_RuffTruxSubmergedPaletteSequence_GG
  ld e, a
  ld d, $00
  add hl, de
  SetPaletteAddressImmediateGG $13 ; Palette entry $13
  ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_DATA), a
  call LABEL_3F36_ScreenOn
+:ret

DATA_2D36_RuffTruxSubmergedPaletteSequence_GG:
  GGCOLOUR $000000
  GGCOLOUR $000088
  GGCOLOUR $004488
  GGCOLOUR $0088ee
  GGCOLOUR $000000

++: ; SMS
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrNzRet + ; ret
  call LABEL_3F22_ScreenOff ; while we mess with the palette (?!)
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  ld hl, DATA_2FB7_RuffTruxSubmergedPaletteSequence_SMS
  ld e, a
  ld d, $00
  add hl, de
  SetPaletteAddressImmediateSMS $13
  ld a, (hl) ; Set colour
  out (PORT_VDP_DATA), a
  call LABEL_3F36_ScreenOn
+:ret

LABEL_2D63_:
  ld a, (_RAM_DF68_)
  ld e, a
  ld d, $00
  ld a, (_RAM_DF24_LapsRemaining)
  cp $04
  jr z, ++
  ld hl, $0000
  cp $03
  jr z, +
  add hl, de
  cp $02
  jr z, +
  add hl, de
  cp $01
  jr z, +
  add hl, de
+:
  ld b, $00
  ld a, (_RAM_DF4F_)
  ld c, a
  add hl, bc
  ld (_RAM_DF8D_), hl
++:
  ld a, (_RAM_DCC4_)
  cp $04
  jr z, ++
  ld hl, $0000
  cp $03
  jr z, +
  add hl, de
  cp $02
  jr z, +
  add hl, de
  cp $01
  jr z, +
  add hl, de
+:
  ld b, $00
  ld a, (_RAM_DF50_)
  ld c, a
  add hl, bc
  ld (_RAM_DF8F_), hl
++:
  ld a, (_RAM_DD05_)
  cp $04
  jr z, ++
  ld hl, $0000
  cp $03
  jr z, +
  add hl, de
  cp $02
  jr z, +
  add hl, de
  cp $01
  jr z, +
  add hl, de
+:
  ld b, $00
  ld a, (_RAM_DF51_)
  ld c, a
  add hl, bc
  ld (_RAM_DF91_), hl
++:
  ld a, (_RAM_DD46_)
  cp $04
  jr z, ++
  ld hl, $0000
  cp $03
  jr z, +
  add hl, de
  cp $02
  jr z, +
  add hl, de
  cp $01
  jr z, +
  add hl, de
+:
  ld b, $00
  ld a, (_RAM_DF52_)
  ld c, a
  add hl, bc
  ld (_RAM_DF93_), hl
++:
  ld a, (_RAM_DF95_)
  add a, $01
  and $7F
  ld (_RAM_DF95_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF96_)
  add a, $01
  ld (_RAM_DF96_), a
  cp $03
  jr nz, +
  xor a
  ld (_RAM_DF96_), a
+:
  or a
  jr z, +
  cp $01
  jr z, LABEL_2E71_
  jp LABEL_2ED3_

+:
  ld a, (_RAM_DC4F_Cheat_EasierOpponents)
  or a
  jr nz, ++
  ld hl, (_RAM_DF8D_)
  ld de, (_RAM_DF8F_)
  or a
  sbc hl, de
  jr nc, +++
  ld a, h
  xor $FF
  or a
  jr nz, +
  ld a, l
  xor $FF
  add a, $01
  ld l, a
  ld a, (_RAM_DB67_)
  cp l
  jr z, LABEL_2E42_
  jr c, +
LABEL_2E42_:
  ld a, (_RAM_DB68_HandlingData+2)
  ld (_RAM_DCDC_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $01
  jr c, LABEL_2E42_
++:
  ld a, (_RAM_DB68_HandlingData+3)
  ld (_RAM_DCDC_), a
  ret

+++:
  ld a, h
  or a
  jr nz, ++
  ld a, (_RAM_DB66_)
  cp l
  jr z, +
  jr c, ++
+:
  ld a, (_RAM_DB68_HandlingData+1)
  ld (_RAM_DCDC_), a
  ret

++:
  ld a, (_RAM_DB68_HandlingData+0)
  ld (_RAM_DCDC_), a
  ret

LABEL_2E71_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB98_TopSpeed)
  ld (_RAM_DD1D_), a
  ret

+:ld a, (_RAM_DC4F_Cheat_EasierOpponents)
  or a
  jr nz, ++
  ld hl, (_RAM_DF8D_)
  ld de, (_RAM_DF91_)
  or a
  sbc hl, de
  jr nc, +++
  ld a, h
  xor $FF
  or a
  jr nz, +
  ld a, l
  xor $FF
  add a, $01
  ld l, a
  ld a, (_RAM_DB67_)
  cp l
  jr z, LABEL_2EA4_
  jr c, +
LABEL_2EA4_:
  ld a, (_RAM_DB68_HandlingData+6)
  ld (_RAM_DD1D_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $01
  jr c, LABEL_2EA4_
++:
  ld a, (_RAM_DB68_HandlingData+7)
  ld (_RAM_DD1D_), a
  ret

+++:
  ld a, h
  or a
  jr nz, ++
  ld a, (_RAM_DB66_)
  cp l
  jr z, +
  jr c, ++
+:
  ld a, (_RAM_DB68_HandlingData+5)
  ld (_RAM_DD1D_), a
  ret

++:
  ld a, (_RAM_DB68_HandlingData+4)
  ld (_RAM_DD1D_), a
  ret

LABEL_2ED3_:
  ld a, (_RAM_DC4F_Cheat_EasierOpponents)
  or a
  jr nz, ++
  ld hl, (_RAM_DF8D_)
  ld de, (_RAM_DF93_)
  or a
  sbc hl, de
  jr nc, +++
  ld a, h
  xor $FF
  jr nz, +
  ld a, l
  xor $FF
  add a, $01
  ld l, a
  ld a, (_RAM_DB67_)
  cp l
  jr z, LABEL_2EF8_
  jr c, +
LABEL_2EF8_:
  ld a, (_RAM_DB68_HandlingData+10)
  ld (_RAM_DD5E_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $01
  jr c, LABEL_2EF8_
++:
  ; Easier opponents cheat is active, or ???
  ld a, (_RAM_DB68_HandlingData+11)
  ld (_RAM_DD5E_), a
  ret

+++:
  ld a, h
  or a
  jr nz, ++
  ld a, (_RAM_DB66_)
  cp l
  jr z, +
  jr c, ++
+:
  ld a, (_RAM_DB68_HandlingData+9)
  ld (_RAM_DD5E_), a
  ret

++:
  ld a, (_RAM_DB68_HandlingData+8)
  ld (_RAM_DD5E_), a
  ret

DATA_2F27_MultiplesOf32:
  TimesTable16 0 32 32

DATA_2F67_MultiplesOf96:
  TimesTable16 0 96 32

; Data from 2FA7 to 2FAE (8 bytes)
DATA_2FA7_:
.db $20 $40 $00 $00 $40 $00 $40 $20

; Data from 2FAF to 2FB6 (8 bytes)
DATA_2FAF_:
.db $20 $00 $40 $20 $40 $00 $20 $00

DATA_2FB7_RuffTruxSubmergedPaletteSequence_SMS:
  SMSCOLOUR $000000 ; black
  SMSCOLOUR $0000aa ; dark Blue
  SMSCOLOUR $0055aa ; middle Blue
  SMSCOLOUR $00aaff ; light Blue
  SMSCOLOUR $000000 ; black

; Data from 2FBC to 2FDB (32 bytes)
; One byte per track, arranged by type/type index
; Copied to _RAM_DF68
DATA_2FBC_:
.db $52 $A6 $B6 $9E ; SportsCars 
.db $62 $24 $85 $00 ; FourByFour 
.db $1C $51 $5E $4E ; Powerboats 
.db $57 $50 $70 $00 ; TurboWheels
.db $85 $8F $9B $00 ; FormulaOne 
.db $42 $72 $6A $00 ; Warriors   
.db $2C $40 $53 $00 ; Tanks      
.db $38 $3E $4B $00 ; RuffTrux   
                    ; No Helicopters

LABEL_2FDC_:
  ld a, (_RAM_D5C1_)
  or a
  jr nz, LABEL_3028_
  ld a, (_RAM_DE87_)
  add a, $01
  ld (_RAM_DE87_), a
  cp $01
  jr z, +
  cp $0A
  jr nz, LABEL_2FF6_
  xor a
  ld (_RAM_DE87_), a
LABEL_2FF6_:
  jp LABEL_304B_

+:
  ld a, (_RAM_DE88_)
  or a
  jp z, LABEL_3085_
  cp $01
  jp z, LABEL_3057_
  cp $02
  jp z, ++
  ld a, (_RAM_DE88_)
  add a, $01
  ld (_RAM_DE88_), a
  cp $08
  jr nz, LABEL_2FF6_
  ld a, (_RAM_DE8B_)
  or a
  jr z, LABEL_3028_
  ld a, $01
  ld (_RAM_DE89_), a
  xor a
  ld (_RAM_DE8A_CarState2), a ; CarState_0_Normal
  jp +

LABEL_3028_:
  xor a
  ld (_RAM_D5C1_), a
  ld a, CarState_1_Exploding
  ld (_RAM_DE8A_CarState2), a
  ld a, SFX_15_HitFloor
  ld (_RAM_D963_SFXTrigger_Player1), a
+:
  xor a
  ld (_RAM_DE87_), a
  ld (_RAM_DE88_), a
  ret

++:
  ld a, $03
  ld (_RAM_DE88_), a
  xor a
  ld (ix+0), a
  ld (iy+1), a
  ret

LABEL_304B_:
  ld a, (_RAM_DE88_)
  cp $01
  jr z, ++
  cp $02
  jr z, +
  ret

LABEL_3057_:
  ld a, $02
  ld (_RAM_DE88_), a
+:
  xor a
  ld (ix+2), a
  ld (ix+4), a
  ld (ix+6), a
  ld (iy+1), a
  ld (iy+2), a
  ld (iy+3), a
  ld a, (_RAM_DE84_)
  add a, $08
  ld (ix+0), a
  ld a, (_RAM_DE85_)
  add a, $08
  ld (iy+0), a
  ld a, $B7
  ld (ix+1), a
  ret

LABEL_3085_:
  ld a, $01
  ld (_RAM_DE88_), a
++:
  xor a
  ld (ix-2), a
  ld (iy-1), a
  ld (ix+8), a
  ld (ix+10), a
  ld (ix+12), a
  ld (ix+14), a
  ld (ix+16), a
  ld (iy+4), a
  ld (iy+5), a
  ld (iy+6), a
  ld (iy+7), a
  ld (iy+8), a
  ld a, (_RAM_DE84_)
  add a, $04
  ld (ix+0), a
  ld (ix+4), a
  add a, $08
  ld (ix+2), a
  ld (ix+6), a
  ld a, (_RAM_DE85_)
  add a, $04
  ld (iy+0), a
  ld (iy+1), a
  add a, $08
  ld (iy+2), a
  ld (iy+3), a
  ld a, $B3
  ld (ix+1), a
  ld a, $B4
  ld (ix+3), a
  ld a, $B5
  ld (ix+5), a
  ld a, $B6
  ld (ix+7), a
  ret

LABEL_30EA_:
  ld a, (_RAM_DEF5_)
  sla a
  ld l, a
  ld h, $00
  ld de, DATA_2F27_MultiplesOf32
  add hl, de
  ld a, (hl)
  ld (_RAM_DEF1_), a
  inc hl
  ld a, (hl)
  ld (_RAM_DEF2_), a
  ret

LABEL_3100_:
  ld a, (_RAM_DEF5_)
  sla a ; *2
  ld l, a
  ld h, $00
  ld de, DATA_2F67_MultiplesOf96
  add hl, de
  ld a, (hl)
  ld (_RAM_DEF1_), a
  inc hl
  ld a, (hl)
  ld (_RAM_DEF2_), a
  ret

; Data from 3116 to 313A (37 bytes)
DATA_3116_F1_TileHighBytesRunCompressed:
; Bitmask
.db %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111
.db %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111110 %11101111
.db %11111001 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111
.db %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111
; Data (4 bytes)
.db $00 $10 $00 $10 $00
; Expands to:
; 0, 0, ... 0, 10, 10, 10, 10, 0, 0, ... 0, 10, 0, 0, ... 0
; This sets the priority bit on certain tiles

; Data from 313B to 3163 (41 bytes)
DATA_313B_Powerboats_TileHighBytesRunCompressed:
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FE $EF $FF $FC $E7 $FF $FF $FF $7B $FF $FF
.db $00 $10 $00 $10 $00 $10 $00 $10 $00

LABEL_3164_:
  ld a, (_RAM_D582_)
  cp $01
  JrNzRet + ; ret
  ld a, $02
  ld (_RAM_D582_), a
  JumpToPagedFunction LABEL_3682E_

+:ret

LABEL_317C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet + ; ret
  JumpToPagedFunction LABEL_36971_

+:ret

LABEL_318E_InitialiseVDPRegisters_Trampoline:
  JumpToPagedFunction LABEL_1BE82_InitialiseVDPRegisters

LABEL_3199_:
  JumpToPagedFunction LABEL_37529_

; Data from 31A4 to 31B5 (18 bytes)
DATA_31A4_FloorTilesVRAMAddress:
; VRAM address of the four floor tiles per track type. $ffff if no floor.
.dw $4000 | ($20 * $58) ; $4B00
.dw $4000 | ($20 * $a1) ; $5420
.dw $FFFF
.dw $FFFF
.dw $4000 | ($20 * $13) ; $4260
.dw $FFFF
.dw $FFFF
.dw $FFFF
.dw $FFFF

LABEL_31B6_InitialiseFloorTiles:
  xor a
  ld d, a
  ld (_RAM_DF17_HaveFloorTiles), a
  ld a, (_RAM_DB97_TrackType)
  or a
  rl a
  ld e, a
  ld hl, DATA_31A4_FloorTilesVRAMAddress ; Look up per-track-type data from this table
  add hl, de
  ld a, (hl)
  ld (_RAM_DF18_FloorTilesVRAMAddress), a
  inc hl
  ld a, (hl)
  ld (_RAM_DF18_FloorTilesVRAMAddress+1), a
  cp $FF
  JrZRet +
  ; If not $ff
  ld a, $01
  ld (_RAM_DF17_HaveFloorTiles), a ; Set flag
  ld a, (_RAM_DF18_FloorTilesVRAMAddress)
  and $F8
  out (PORT_VDP_ADDRESS), a ; Set VRAM address
  ld a, (_RAM_DF18_FloorTilesVRAMAddress+1)
  out (PORT_VDP_ADDRESS), a
  ld bc, $0080 ; 32*4 bytes
-:
  EmitDataToVDPImmediate8 0 ; Blank it out
  dec bc
  ld a, b
  or c
  jr nz, -
+:ret

LABEL_31F1_UpdateSpriteTable:
  ; Sprite table Y
  SetVDPAddressImmediate SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK
  ld hl, _RAM_DAE0_SpriteTableYs
  ld b, 64*_sizeof_SpriteY
  ld c, PORT_VDP_DATA
  otir
  ; Sprite table XN
  SetVDPAddressImmediate SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK + 128
  ld hl, _RAM_DA60_SpriteTableXNs
  ld b, 64*_sizeof_SpriteXN
  ld c, PORT_VDP_DATA
  otir
  ret

LABEL_3214_BlankSpriteTable:
  ld hl, _RAM_DAE0_SpriteTableYs
  ld bc, 64*_sizeof_SpriteY
-:xor a
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ld hl, _RAM_DA60_SpriteTableXNs
  ld bc, 64*_sizeof_SpriteXN
-:xor a
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

LABEL_3231_BlankDecoratorTiles:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrZRet +
  
  SetTileAddressImmediate SpriteIndex_Decorators
  ld bc, TILE_DATA_SIZE * 4
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
+:ret

.macro UpdateTileBitplane args TileIndex, Bitplane
  ; Emits 8 bytes from hl to port c
  ; while setting the VRAM write address to each bitplane byte 
  ; for the gicen sprite and bitplane number
  .define ADDRESS TileIndex * TILE_DATA_SIZE | VRAM_WRITE_MASK + Bitplane
  .repeat 8
    SetVDPAddressImmediate ADDRESS
    outi
    .redefine ADDRESS ADDRESS+4 ; every 4 bytes -> 1 bitplane
  .endr
  .undefine ADDRESS
.endm

.macro UpdateCarDecorators args CarData, TileIndex, Bitplane
  ld c, PORT_VDP_DATA
  ld ix, CarData
  ld d, $00
  ld a, (ix+13) ; Direction?
  or a ; Multiply by 4
  rl a
  rl a
  rl a
  ld e, a
  ; Offset into decorator data
  ld hl, _RAM_D980_CarDecoratorTileData1bpp
  add hl, de
  UpdateTileBitplane TileIndex, Bitplane  
.endm

LABEL_324C_UpdatePerFrameTiles:
  ; Updates all the tiles which are written into every frame
  ld c, PORT_VDP_DATA
  ld d, $00
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jp z, LABEL_746B_RuffTrux_UpdatePerFrameTiles

  ; Update tiles for car "decorators"
  ; Always do the red and blue cars
  ld a, (_RAM_DE91_CarDirectionPrevious) ; 0-$f
  or a
  rl a ; multiply by 8
  rl a
  rl a
  ld e, a
  ld hl, _RAM_D980_CarDecoratorTileData1bpp ; table here holds the 1bpp tile data
  add hl, de

  UpdateTileBitplane SpriteIndex_Decorators.Red, 0

  call LABEL_336A_UpdateBlueCarDecorator
  
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  
  ; Tournament -> do the other two cars
  call LABEL_3302_UpdateGreenCarDecorator
  jp LABEL_33D2_UpdateYellowCarDecorator ; and ret

+:; Head to head -> update the laps remaining counter
  SetTileAddressImmediate SpriteIndex_HeadToHeadLapCounter
  ld a, (_RAM_DF24_LapsRemaining)
  sub $01
  cp $04
  jr nc, +
  sla a ; Multiply by 32
  sla a
  sla a
  sla a
  sla a
  ld e, a
  ld d, $00
  ld a, :DATA_30A68_ChallengeHUDTiles ; $0C
  ld (PAGING_REGISTER), a
  ld hl, DATA_30A68_ChallengeHUDTiles + 32 * 16 ; Just the laps remaining indicators
  add hl, de
  ld b, $20
  ld c, PORT_VDP_DATA
  otir ; Emit
--:
  jp LABEL_AFD_RestorePaging_fromDE8E

+:
  ld b, TILE_DATA_SIZE ; Emit a blank tile when the number is too large
  xor a
-:out (PORT_VDP_DATA), a
  dec b
  jr nz, -
  jp --

LABEL_3302_UpdateGreenCarDecorator:
  UpdateCarDecorators _RAM_DCAB_CarData_Green, SpriteIndex_Decorators.Green, 1 ; Tile $191 = green car "decorator"
  ret

LABEL_336A_UpdateBlueCarDecorator:
  UpdateCarDecorators _RAM_DCEC_CarData_Blue, SpriteIndex_Decorators.Blue, 2 ; Tile $192 = Blue car "decorator"
  ret

LABEL_33D2_UpdateYellowCarDecorator:
  UpdateCarDecorators _RAM_DD2D_CarData_Yellow, SpriteIndex_Decorators.Yellow, 3 ; Tile $193 = yellow car "decorator"
  ret

LABEL_343A_:
  JumpToPagedFunction LABEL_375A0_

LABEL_3445_:
  JumpToPagedFunction LABEL_3766F_

LABEL_3450_:
  ld a, $01
  ld (_RAM_DE40_), a
  ld (_RAM_DE41_), a
  ld (_RAM_DE42_), a
  ld (_RAM_DE43_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrZRet ++
  ld a, (_RAM_DE4A_)
  xor $FF
  ld (_RAM_DE4A_), a
  xor a
  ld (_RAM_DE4B_), a
  ld (_RAM_DE4C_), a
  ld (_RAM_DE4D_), a
  ld (_RAM_DE4E_), a
  call LABEL_3556_
  ld bc, $0000
  ld e, $06
  ld hl, _RAM_DE44_
-:
  ld a, (hl)
  or a
  jr z, +
  inc bc
+:
  inc hl
  dec e
  jr nz, -
  ld a, c
  cp $03
  jr nc, +++
++:ret

+++:
  ld hl, _RAM_DE4B_
  ld d, $00
  ld c, $00
  ld a, (_RAM_DE44_)
  ld e, a
  ld c, a
  add hl, de
  inc (hl)
  ld hl, _RAM_DE4B_
  ld a, (_RAM_DE45_)
  ld e, a
  add a, c
  ld c, a
  add hl, de
  inc (hl)
  ld hl, _RAM_DE4B_
  ld a, (_RAM_DE46_)
  ld e, a
  add a, c
  ld c, a
  add hl, de
  inc (hl)
  ld hl, _RAM_DE4B_
  ld a, (_RAM_DE47_)
  ld e, a
  add a, c
  ld c, a
  add hl, de
  inc (hl)
  ld hl, _RAM_DE4B_
  ld a, (_RAM_DE48_)
  ld e, a
  add a, c
  ld c, a
  add hl, de
  inc (hl)
  ld hl, _RAM_DE4B_
  ld a, (_RAM_DE49_)
  ld e, a
  add a, c
  ld c, a
  add hl, de
  inc (hl)
  ld hl, _RAM_DE4C_
-:
  ld a, (hl)
  or a
  jr z, +
  dec a
  jr z, +
  ld a, c
  sub $01
  ld c, a
  dec (hl)
  jp -

+:
  ld hl, _RAM_DE4D_
-:
  ld a, (hl)
  or a
  jr z, +
  dec a
  jr z, +
  ld a, c
  sub $02
  ld c, a
  dec (hl)
  jp -

+:
  ld hl, _RAM_DE4E_
-:
  ld a, (hl)
  or a
  jr z, +
  dec a
  jr z, +
  ld a, c
  sub $03
  ld c, a
  dec (hl)
  jp -

+:
  ld a, c
  cp $03
  jr z, +
  cp $04
  jr z, ++
  cp $05
  jr z, LABEL_353A_
  cp $06
  jr z, +++
  ret

+:
  ld a, (_RAM_DE4A_)
  or a
  jr z, LABEL_352B_
  ld (_RAM_DE42_), a
  ret

LABEL_352B_:
  xor a
  ld (_RAM_DE41_), a
  ret

++:
  ld a, (_RAM_DE4A_)
  or a
  jr z, LABEL_352B_
  ld (_RAM_DE43_), a
  ret

LABEL_353A_:
  ld a, (_RAM_DE4A_)
  or a
  jr z, +
  ld (_RAM_DE43_), a
  ret

+:
  xor a
  ld (_RAM_DE42_), a
  ret

+++:
  call LABEL_353A_
  ld a, (_RAM_DE4A_)
  or a
  jr z, LABEL_352B_
  ld (_RAM_DE40_), a
  ret

LABEL_3556_:
  ld c, $06
  ld hl, _RAM_DE44_
-:
  xor a
  ld (hl), a
  inc hl
  dec c
  jr nz, -
  ld a, (_RAM_DCBD_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $01
  ld (_RAM_DE44_), a
+:
  ld a, (_RAM_DCFE_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $02
  ld (_RAM_DE45_), a
+:
  ld a, (_RAM_DD3F_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $03
  ld (_RAM_DE46_), a
+:
  ld a, (_RAM_DCFE_)
  ld l, a
  ld a, (_RAM_DCBD_)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $02
  ld (_RAM_DE47_), a
+:
  ld a, (_RAM_DD3F_)
  ld l, a
  ld a, (_RAM_DCBD_)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $03
  ld (_RAM_DE48_), a
+:
  ld a, (_RAM_DD3F_)
  ld l, a
  ld a, (_RAM_DCFE_)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  JrNcRet +
  ld a, $03
  ld (_RAM_DE49_), a
+:ret

LABEL_35E0_:
  ld a, (_RAM_DF00_)
  or a
  jr z, +
  ld a, (_RAM_DF06_)
  ld (_RAM_DF08_), a
  ld a, (_RAM_DF07_)
  ld (_RAM_DF09_), a
  jp ++

+:
  ld a, (_RAM_DBA4_)
  ld (_RAM_DF08_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DF09_), a
++:
  ld ix, _RAM_DA60_SpriteTableXNs.10
  ld iy, _RAM_DAE0_SpriteTableYs.10
  ld a, (_RAM_DF08_)
  ld (_RAM_DE84_), a
  ld a, (_RAM_DF09_)
  ld (_RAM_DE85_), a
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE86_), a
  ld a, $90
  ld (_RAM_DF1E_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  jp LABEL_3A6B_

+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ld a, (_RAM_DE50_)
  cp $01
  jr z, ++
+:
  ld a, (_RAM_D946_)
  or a
  jr nz, ++
  ld a, (_RAM_DE40_)
  cp $01
  jr z, +++
++:
  ld a, $E0
  ld (_RAM_DE85_), a
+++:
  ld a, (_RAM_DF59_CarState)
  or a
  jp z, LABEL_3709_ ; 0
  cp CarState_3_Falling
  jr z, +
  cp CarState_4_Submerged
  jr nz, ++
+:
  ld a, (_RAM_D5BF_)
  or a
  jr nz, +
  ld a, (_RAM_D5BD_)
  or a
  jr nz, ++
+:
  ld a, (_RAM_DE90_CarDirection)
  or a
  jr z, +
  call LABEL_3DD1_
  call LABEL_3674_
  jp LABEL_370F_

LABEL_3674_:
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ret

+:
  call LABEL_3674_
++:
  ld a, (_RAM_DF5D_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF61_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF59_CarState)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DE8C_)
  ld (_RAM_DE8B_), a
  ld a, (_RAM_D5BD_)
  ld (_RAM_D5C1_), a
  ld a, (_RAM_D5BF_)
  ld (_RAM_D5C2_), a
  call LABEL_3B74_
  ld a, (_RAM_D5C2_)
  ld (_RAM_D5BF_), a
  ld a, (_RAM_D5C1_)
  ld (_RAM_D5BD_), a
  ld a, (_RAM_DE8B_)
  ld (_RAM_DE8C_), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF59_CarState), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF61_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5D_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, ++
  ld a, (_RAM_DF59_CarState)
  cp CarState_2_Respawning
  jr nz, +
  ld a, $0A
  ld (_RAM_D95E_), a
  xor a
  ld (_RAM_DF58_), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld a, (_RAM_DE55_)
  ld (_RAM_DE90_CarDirection), a
  ld (_RAM_DE91_CarDirectionPrevious), a
+:
  ld a, (_RAM_D5B0_)
  or a
  jr z, +
  ld a, CarState_ff
  ld (_RAM_DF59_CarState), a
  jp +++

+:
  xor a ; CarState_0_Normal
  ld (_RAM_DF59_CarState), a
++:
  jp +++

LABEL_3709_:
  ld a, (_RAM_DF58_)
  or a
  jr nz, +++
LABEL_370F_:
  call LABEL_3963_
+++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jp z, LABEL_37BE_
  ld ix, _RAM_DA60_SpriteTableXNs.20
  ld iy, _RAM_DAE0_SpriteTableYs.20
  ld a, (_RAM_DCBC_)
  ld (_RAM_DE84_), a
  ld a, (_RAM_DCBD_)
  ld (_RAM_DE85_), a
  ld a, (_RAM_DCB8_)
  ld (_RAM_DE86_), a
  ld a, $91
  ld (_RAM_DF1E_), a
  ld a, (_RAM_DE41_)
  cp $01
  jr z, +
  ld a, $E0
  ld (_RAM_DE85_), a
+:
  ld a, (_RAM_DF5A_CarState3)
  or a ; CarState_0_Normal
  jr z, LABEL_37B5_
  cp CarState_3_Falling
  jr z, +
  cp CarState_4_Submerged
  jr nz, ++
+:
  ld a, (_RAM_DCB8_)
  or a
  jr z, ++
  call LABEL_3F17_
  jp LABEL_37BB_

++:
  ld a, (_RAM_DF5E_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF62_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5A_CarState3)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DCDE_)
  ld (_RAM_DE8B_), a
  call LABEL_3B74_
  ld a, (_RAM_DE8B_)
  ld (_RAM_DCDE_), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF5A_CarState3), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF62_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5E_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, ++
  ld a, (_RAM_DF5A_CarState3)
  cp CarState_2_Respawning
  jr nz, +
  xor a
  ld (_RAM_DCD9_), a
  ld a, (_RAM_DCB7_)
  ld (_RAM_DCB8_), a
+:
  xor a
  ld (_RAM_DF5A_CarState3), a ; CarState_0_Normal
++:
  jp LABEL_37BE_

LABEL_37B5_:
  ld a, (_RAM_DCD9_)
  or a
  jr nz, LABEL_37BE_
LABEL_37BB_:
  call LABEL_3963_
LABEL_37BE_:
  ld ix, _RAM_DA60_SpriteTableXNs.30
  ld iy, _RAM_DAE0_SpriteTableYs.30
  ld a, (_RAM_DCFD_)
  ld (_RAM_DE84_), a
  ld a, (_RAM_DCFE_)
  ld (_RAM_DE85_), a
  ld a, (_RAM_DCF9_)
  ld (_RAM_DE86_), a
  ld a, $92
  ld (_RAM_DF1E_), a
  ld a, (_RAM_DE42_)
  cp $01
  jr z, +
  ld a, $E0
  ld (_RAM_DE85_), a
+:
  ld a, (_RAM_DF5B_)
  or a
  jp z, LABEL_38B3_
  cp $03
  jr z, +
  cp $04
  jr nz, ++
+:
  ld a, (_RAM_D5C0_)
  or a
  jr nz, +
  ld a, (_RAM_D5BE_)
  or a
  jr nz, ++
+:
  ld a, (_RAM_DCF9_)
  or a
  jr z, +
  call LABEL_48D1_
  call LABEL_3813_
  jp LABEL_38B9_

LABEL_3813_:
  xor a
  ld (_RAM_DE35_), a
  ret

+:
  call LABEL_3813_
++:
  ld a, (_RAM_DF5F_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF63_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5B_)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DD1F_)
  ld (_RAM_DE8B_), a
  ld a, (_RAM_D5BE_)
  ld (_RAM_D5C1_), a
  ld a, (_RAM_D5C0_)
  ld (_RAM_D5C2_), a
  call LABEL_3B74_
  ld a, (_RAM_D5C2_)
  ld (_RAM_D5C0_), a
  ld a, (_RAM_D5C1_)
  ld (_RAM_D5BE_), a
  ld a, (_RAM_DE8B_)
  ld (_RAM_DD1F_), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF63_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5F_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, LABEL_38B0_
  ld a, (_RAM_DF5B_)
  cp $02
  jr nz, ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $0A
  ld (_RAM_D96F_), a
+:
  xor a
  ld (_RAM_DD1A_), a
  ld a, (_RAM_D582_)
  cp $02
  jr nz, +
  ld a, (_RAM_DE55_)
  ld (_RAM_DCF8_), a
  xor a
  ld (_RAM_D582_), a
+:
  ld a, (_RAM_DCF8_)
  ld (_RAM_DCF9_), a
++:
  ld a, (_RAM_D5B0_)
  or a
  jr z, +
  ld a, $FF
  ld (_RAM_DF5B_), a
  jp ++

+:
  xor a
  ld (_RAM_DF5B_), a
LABEL_38B0_:
  jp ++

LABEL_38B3_:
  ld a, (_RAM_DD1A_)
  or a
  jr nz, ++
LABEL_38B9_:
  call LABEL_3963_
++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JpZRet _LABEL_395C_ret
  ld ix, _RAM_DA60_SpriteTableXNs.40
  ld iy, _RAM_DAE0_SpriteTableYs.40
  ld a, (_RAM_DD3E_)
  ld (_RAM_DE84_), a
  ld a, (_RAM_DD3F_)
  ld (_RAM_DE85_), a
  ld a, (_RAM_DD3A_)
  ld (_RAM_DE86_), a
  ld a, $93
  ld (_RAM_DF1E_), a
  ld a, (_RAM_DE43_)
  cp $01
  jr z, +
  ld a, $E0
  ld (_RAM_DE85_), a
+:
  ld a, (_RAM_DF5C_)
  or a
  jr z, LABEL_395D_
  cp $03
  jr z, +
  cp $04
  jr nz, ++
+:
  ld a, (_RAM_DD3A_)
  or a
  jr z, ++
  call LABEL_48FC_
  jp LABEL_3963_

++:
  ld a, (_RAM_DF60_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF64_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5C_)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DD60_)
  ld (_RAM_DE8B_), a
  call LABEL_3B74_
  ld a, (_RAM_DE8B_)
  ld (_RAM_DD60_), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF5C_), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF64_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF60_), a
  ld a, (_RAM_DE89_)
  cp $01
  JrNzRet _LABEL_395C_ret
  ld a, (_RAM_DF5C_)
  cp $02
  jr nz, +
  xor a
  ld (_RAM_DD5B_), a
  ld a, (_RAM_DD39_)
  ld (_RAM_DD3A_), a
+:
  xor a
  ld (_RAM_DF5C_), a
_LABEL_395C_ret:
  ret

LABEL_395D_:
  ld a, (_RAM_DD5B_)
  or a
  JrNzRet _LABEL_395C_ret
LABEL_3963_:
  call LABEL_3969_
  jp LABEL_39AE_

LABEL_3969_:
  ld a, (_RAM_DE84_)
  ld (ix+0), a
  ld (ix+6), a
  ld (ix+12), a
  add a, $08
  ld (ix+2), a
  ld (ix+8), a
  ld (ix+14), a
  add a, $08
  ld (ix+4), a
  ld (ix+10), a
  ld (ix+16), a
  ld a, (_RAM_DE85_)
  ld (iy+0), a
  ld (iy+1), a
  ld (iy+2), a
  add a, $08
  ld (iy+3), a
  ld (iy+4), a
  ld (iy+5), a
  add a, $08
  ld (iy+6), a
  ld (iy+7), a
  ld (iy+8), a
  ret

LABEL_39AE_:
  ld hl, DATA_3E04_ ; Would be easier to do the maths
  ; ld l,a
  ; add a,a
  ; add a,l
  ; - assuming a is not out of range for the table and somehow that is needed
  ld a, (_RAM_DE86_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (ix+1), a
  ld (_RAM_DE9E_), a
  add a, $01
  ld (ix+3), a
  add a, $01
  ld (ix+5), a
  ld a, (_RAM_DE9E_)
  add a, $18
  ld (ix+7), a
  ld (_RAM_DE9E_), a
  add a, $01
  ld (ix+9), a
  add a, $01
  ld (ix+11), a
  ld a, (_RAM_DE9E_)
  add a, $18
  ld (ix+13), a
  add a, $01
  ld (ix+15), a
  add a, $01
  ld (ix+17), a
  ld a, (_RAM_DF1E_)
  ld (ix-1), a
  ld hl, _RAM_DA00_
  ld a, (_RAM_DE86_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE84_)
  add a, l
  ld (ix-2), a
  ld hl, _RAM_DA00_ + 16
  ld a, (_RAM_DE86_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE85_)
  add a, l
  ld (iy-1), a
  ret

LABEL_3A23_:
  JumpToPagedFunction LABEL_36A85_

LABEL_3A2E_SetShadowSpriteIndices:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, +
  
  ; Not RuffTrux
  ld a, <SpriteIndex_Shadow+0
  ld (_RAM_DA60_SpriteTableXNs.49.n), a
  ld (_RAM_DA60_SpriteTableXNs.53.n), a
  ld a, <SpriteIndex_Shadow+1
  ld (_RAM_DA60_SpriteTableXNs.50.n), a
  ld (_RAM_DA60_SpriteTableXNs.54.n), a
  ld a, <SpriteIndex_Shadow+2
  ld (_RAM_DA60_SpriteTableXNs.51.n), a
  ld (_RAM_DA60_SpriteTableXNs.55.n), a
  ld a, <SpriteIndex_Shadow+3
  ld (_RAM_DA60_SpriteTableXNs.52.n), a
  ld (_RAM_DA60_SpriteTableXNs.56.n), a
  ret

+:; RuffTrux
  ld a, SpriteIndex_RuffTrux_Shadow1
  ld (_RAM_DA60_SpriteTableXNs.49.n), a
  ld a, SpriteIndex_RuffTrux_Shadow2
  ld (_RAM_DA60_SpriteTableXNs.50.n), a
  ld a, SpriteIndex_RuffTrux_Shadow3
  ld (_RAM_DA60_SpriteTableXNs.51.n), a
  ld a, SpriteIndex_RuffTrux_Shadow4
  ld (_RAM_DA60_SpriteTableXNs.52.n), a
  ret

LABEL_3A6B_:
  ld a, (_RAM_DF59_CarState)
  or a
  jr z, LABEL_3AC9_
  cp CarState_3_Falling
  jr nz, +
  ld a, (_RAM_DF73_)
  cp $0C
  jr z, +
  call LABEL_2CD4_
  jp LABEL_3ACF_

+:
  ld a, (_RAM_DF5D_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF61_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  call LABEL_3B74_
  ld a, (_RAM_DE88_)
  ld (_RAM_DF61_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5D_), a
  ld a, (_RAM_DE89_)
  cp $01
  JrNzRet _LABEL_3AC8_ret
  ld a, (_RAM_DF59_CarState)
  cp CarState_2_Respawning
  jr nz, +
  ld a, $0A
  ld (_RAM_D95E_), a
  xor a
  ld (_RAM_DF58_), a
  ld a, (_RAM_DE55_)
  ld (_RAM_DE90_CarDirection), a
  ld (_RAM_DE91_CarDirectionPrevious), a
+:
  xor a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld (_RAM_DF59_CarState), a ; CarState_0_Normal
_LABEL_3AC8_ret:
  ret

LABEL_3AC9_:
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_3AC8_ret
LABEL_3ACF_:
  ; Set up RuffTrux sprites
  ; ix = sprite XNs
  ; iy = sprite Ys
  ld a, (_RAM_DE84_) ; Sprite X
  ld (ix+0), a
  ld (ix+8), a
  ld (ix+16), a
  ld (ix+24), a
  add a, $08
  ld (ix+2), a
  ld (ix+10), a
  ld (ix+18), a
  ld (ix+26), a
  add a, $08
  ld (ix+4), a
  ld (ix+12), a
  ld (ix+20), a
  ld (ix+28), a
  add a, $08
  ld (ix+6), a
  ld (ix+14), a
  ld (ix+22), a
  ld (ix+30), a
  ld a, (_RAM_DE85_) ; Sprite Y
  ld (iy+0), a
  ld (iy+1), a
  ld (iy+2), a
  ld (iy+3), a
  add a, $08
  ld (iy+4), a
  ld (iy+5), a
  ld (iy+6), a
  ld (iy+7), a
  add a, $08
  ld (iy+8), a
  ld (iy+9), a
  ld (iy+10), a
  ld (iy+11), a
  add a, $08
  ld (iy+12), a
  ld (iy+13), a
  ld (iy+14), a
  ld (iy+15), a
  ld a, (_RAM_DE86_) ; Rotation index
  sla a
  sla a
  sla a
  sla a
  ld hl, DATA_35C2D_RuffTruxTileIndices
  ld d, $00
  ld e, a
  add hl, de
  ld c, 16 + 1 ; one too many?
  ld a, :DATA_35C2D_RuffTruxTileIndices
  ld (PAGING_REGISTER), a
-:
  ld a, (hl)
  ld (ix+1), a
  inc ix
  inc ix
  inc hl
  dec c
  jr nz, -
  ; Restore paging
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ; Set previous sprite (?) to 0, 0
  xor a
  ld (ix-2), a
  ld (iy-1), a
  ret

LABEL_3B74_:
  ld a, (_RAM_DE8A_CarState2)
  cp CarState_3_Falling
  jp z, LABEL_2FDC_
  cp CarState_4_Submerged
  jp z, LABEL_3E43_
  cp CarState_ff
  JrZRet _LABEL_3BEC_ret
  xor a
  ld (ix-2), a
  ld (iy-1), a
  ld a, (_RAM_DE84_)
  ld (ix+6), a
  add a, $02
  ld (ix+0), a
  ld (ix+12), a
  add a, $06
  ld (ix+2), a
  ld (ix+8), a
  ld (ix+14), a
  add a, $06
  ld (ix+4), a
  ld (ix+16), a
  add a, $02
  ld (ix+10), a
  ld a, (_RAM_DE85_)
  ld (iy+1), a
  add a, $02
  ld (iy+0), a
  ld (iy+2), a
  add a, $06
  ld (iy+3), a
  ld (iy+4), a
  ld (iy+5), a
  add a, $06
  ld (iy+6), a
  ld (iy+8), a
  add a, $02
  ld (iy+7), a
  ld a, (_RAM_DE87_)
  add a, $01
  ld (_RAM_DE87_), a
  cp $01
  jr z, +
  cp $05
  JrNzRet _LABEL_3BEC_ret
  xor a
  ld (_RAM_DE87_), a
_LABEL_3BEC_ret:
  ret

+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  call LABEL_3DEC_RuffTrux_
  ld hl, DATA_3F05_RuffTrux_
  jp ++
+:ld hl, DATA_40D3_NotRuffTrux_
++:
  ; Index into table
  ld a, (_RAM_DE88_)
  sla a
  ld d, $00
  ld e, a
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e
  ; Then follow the pointer and emit 9 bytes to ???
  ld a, (hl)
  ld (ix+1), a
  inc hl
  ld a, (hl)
  ld (ix+3), a
  inc hl
  ld a, (hl)
  ld (ix+5), a
  inc hl
  ld a, (hl)
  ld (ix+7), a
  inc hl
  ld a, (hl)
  ld (ix+9), a
  inc hl
  ld a, (hl)
  ld (ix+11), a
  inc hl
  ld a, (hl)
  ld (ix+13), a
  inc hl
  ld a, (hl)
  ld (ix+15), a
  inc hl
  ld a, (hl)
  ld (ix+17), a
  ; Cycle _RAM_DE88_ from 0 to 8
  ld a, (_RAM_DE88_)
  add a, $01
  ld (_RAM_DE88_), a
  cp $09
  JrNzRet +
  ; When it wraps, set/reset stuff
  ld a, $01
  ld (_RAM_DE89_), a
  xor a
  ld (_RAM_DE87_), a
  ld (_RAM_DE88_), a
+:ret

LABEL_3C54_InitialiseHUDData:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ; RuffTrux: load time limit
  ld a, (_RAM_DB96_TrackIndexForThisType)
  sla a ; x4
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_A91_RuffTruxTimeLimits
  add hl, de
  ld a, (hl)
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  inc hl
  ld a, (hl)
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  inc hl
  ld a, (hl)
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  ; And lap counter
  ld a, RUFFTRUX_LAP_COUNT + 1 ; since we need to cross the start line twice to do one lap
  ld (_RAM_DF24_LapsRemaining), a
  jp ++

+:; Not RuffTrux: load lap counter, others TBC
  ld a, CHALLENGE_LAP_COUNT + 1
  ld (_RAM_DF24_LapsRemaining), a
  ld (_RAM_DD05_), a ; TODO are these different things?
  ld (_RAM_DD46_), a
  ld a, $03
  ld (_RAM_DCC4_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, ++
  ; Not head to head
  ; Change this ???
  ld a, $03
  ld (_RAM_DD05_), a
++:
  xor a
  ld (_RAM_DF25_), a

  ; Copy HUD sprite coordinates to RAM
  ld c, _sizeof_TournamentHUDSprites  
  GetPointerForSystem DATA_A6D_SMS_TournamentHUDSpriteXs DATA_A7F_GG_TournamentHUDSpriteXs "or" "jr" "jp"
  ld de, _RAM_DF2E_HUDSpriteXs
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  dec c
  jr nz, -

  ld c, _sizeof_TournamentHUDSprites
  GetPointerForSystem DATA_A76_SMS_TournamentHUDSpriteYs DATA_A88_GG_TournamentHUDSpriteYs "or" "jr" "jp"
  ld de, _RAM_DF40_HUDSpriteYs
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  dec c
  jr nz, -

  ; Look up ???
  ld a, (_RAM_DB97_TrackType)
  sla a ; x4
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_2FBC_
  add hl, de
  ld a, (_RAM_DB96_TrackIndexForThisType)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ; Store to _RAM_DF68_
  ld (_RAM_DF68_), a
  ; And divided by 2 to _RAM_DF69_
  srl a
  ld (_RAM_DF69_), a
  ; Copy original value to various places
  ld a, (_RAM_DF68_)
  ld (_RAM_D587_), a
  ld (_RAM_DD45_), a
  ld (_RAM_DD04_), a
  ld (_RAM_DF4F_), a
  ld (_RAM_DF52_), a
  ld (_RAM_DF51_), a
  ; ???
  ld a, $01
  ld (_RAM_DCC3_), a
  ld (_RAM_DF50_), a
  ; Init HUD data?
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ; Head to Head only
  ld a, $01
  ld (_RAM_DF51_), a
  ld (_RAM_DD04_), a
  ; fall through
+:
  ld a, <SpriteIndex_Digit1
  ld (_RAM_DF37_HUDSpriteNs.Digit1), a
  ld a, <SpriteIndex_Digit2
  ld (_RAM_DF37_HUDSpriteNs.Digit2), a
  ld a, <SpriteIndex_Digit3
  ld (_RAM_DF37_HUDSpriteNs.Digit3), a
  ld a, <SpriteIndex_Digit4
  ld (_RAM_DF37_HUDSpriteNs.Digit4), a
  ; Set driver position data?
  ld a, $01
  ld (_RAM_DF26_), a
  ld a, $02
  ld (_RAM_DF27_), a
  ld a, $03
  ld (_RAM_DF28_), a
  xor a
  ld (_RAM_DF29_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  ; could or a; ret z
  cp $01
  jr z, +
  ret

+:JumpToPagedFunction LABEL_35F41_InitialiseHeadToHeadHUDSprites

LABEL_3D59_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet _LABEL_3DBC_ret
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet _LABEL_3DBC_ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_3DBC_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_3DBC_ret
  ld a, (_RAM_DCF6_)
  and $3F
  JrZRet _LABEL_3DBC_ret
  cp $3C
  JrZRet _LABEL_3DBC_ret
  ld a, (_RAM_DD08_)
  and $18
  srl a
  or a
  jr z, +
  ld (_RAM_D5B9_), a
  ld a, (_RAM_D5BA_)
  add a, $01
  and $07
  ld (_RAM_D5BA_), a
  jr z, +
  ld a, (_RAM_DCF7_)
  cp $06
  jr c, +
  sub $01
  ld (_RAM_DCF7_), a
+:
  ld a, (_RAM_DCF6_)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld e, a
  ld d, $00
  ld hl, DATA_4425_
  add hl, de
  ld a, (hl)
  cp $FE
  JrZRet _LABEL_3DBC_ret
  cp $FF
  JrZRet _LABEL_3DBC_ret
  ld (_RAM_D5B8_), a
_LABEL_3DBC_ret:
  ret

LABEL_3DBD_:
  JumpToPagedFunction LABEL_239C6_

DATA_3DC8_TrackTypeTileDataPages:
.db :DATA_3C000_Sportscars_Tiles :DATA_39C83_FourByFour_Tiles :DATA_3D901_Powerboats_Tiles :DATA_38000_TurboWheels_Tiles :DATA_34000_FormulaOne_Tiles :DATA_3A8FA_Warriors_Tiles :DATA_39168_Tanks_Tiles :DATA_3CD8D_RuffTrux_Tiles :DATA_34000_Helicopters_Tiles_BadReference

LABEL_3DD1_:
  JumpToPagedFunction LABEL_3636E_

DATA_3DDC_TrackTypeTileDataPointerLo:
.db <DATA_3C000_Sportscars_Tiles <DATA_39C83_FourByFour_Tiles <DATA_3D901_Powerboats_Tiles <DATA_38000_TurboWheels_Tiles <DATA_34000_FormulaOne_Tiles <DATA_3A8FA_Warriors_Tiles <DATA_39168_Tanks_Tiles <DATA_3CD8D_RuffTrux_Tiles

DATA_3DE4_TrackTypeTileDataPointerHi:
.db >DATA_3C000_Sportscars_Tiles >DATA_39C83_FourByFour_Tiles >DATA_3D901_Powerboats_Tiles >DATA_38000_TurboWheels_Tiles >DATA_34000_FormulaOne_Tiles >DATA_3A8FA_Warriors_Tiles >DATA_39168_Tanks_Tiles >DATA_3CD8D_RuffTrux_Tiles

LABEL_3DEC_RuffTrux_:
  ; Disable some sprites?
  ld a, $E0
  ld (iy+9), a
  ld (iy+10), a
  ld (iy+11), a
  ld (iy+12), a
  ld (iy+13), a
  ld (iy+14), a
  ld (iy+15), a
  ret

; Data from 3E04 to 3E23 (32 bytes)
DATA_3E04_:
.db $00 $03 $06 $09 $0C $0F $12 $15 $48 $4B $4E $51 $54 $57 $5A $5D ; Multiples of 3, jumping in the middle
.db $00 $04 $08 $0C $10 $14 $18 $1C $80 $84 $88 $8C $90 $94 $98 $9C ; Multiples of 4, jumping in the middle

LABEL_3E24_:
  JumpToPagedFunction LABEL_37817_

LABEL_3E2F_:
  JumpToPagedFunction LABEL_37946_

DATA_3E3A_TrackTypeDataPageNumbers:
.db :DATA_C000_TrackData_SportsCars
.db :DATA_10000_TrackData_FourByFour
.db :DATA_14000_TrackData_Powerboats
.db :DATA_18000_TrackData_TurboWheels
.db :DATA_1C000_TrackData_FormulaOne
.db :DATA_20000_TrackData_Warriors
.db :DATA_24000_TrackData_Tanks
.db :DATA_28000_TrackData_RuffTrux
.db :DATA_2C000_TrackData_Helicopters_BadReference

LABEL_3E43_:
  ld a, (_RAM_DE87_)
  or a
  jr z, ++
  cp $80
  jr c, +
  ld a, CarState_1_Exploding
  ld (_RAM_DE8A_CarState2), a
  xor a
  ld (_RAM_D5C2_), a
  ld (_RAM_D5C1_), a
  ld (_RAM_DE87_), a
  ld (_RAM_DE88_), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld (_RAM_DF73_), a
  ret

+:
  add a, $01
  ld (_RAM_DE87_), a
  jp +++

++:
  add a, $01
  ld (_RAM_DE87_), a
+++:
  xor a
  ld (ix-2), a
  ld (iy-1), a
  ld a, $B3
  ld (ix+1), a
  ld (ix+5), a
  ld a, $B4
  ld (ix+7), a
  ld (ix+11), a
  ld a, $B5
  ld (ix+13), a
  ld (ix+17), a
  ld a, $AC
  ld (ix+3), a
  ld a, $B6
  ld (ix+9), a
  ld a, $B7
  ld (ix+15), a
  jp LABEL_3969_

; Data from 3EA4 to 3EEB (72 bytes)
DATA_3EA4_:
.db $0E $17 $10 $06 $1D $0D $13 $0F $01 $14 $02 $07 $10 $05 $00 $00
.db $04 $05 $0B $08 $07 $08 $04 $17 $04 $14 $07 $06 $08 $1A $00 $00
.db $0D $07 $0D $17 $1C $07 $00 $00 $13 $15 $0C $11 $0E $1D $00 $00
.db $04 $0A $05 $0F $0D $13 $00 $00 $02 $11 $03 $0F $15 $13 $00 $00
.db $04 $0B $02 $08 $02 $16 $00 $00

; Data from 3EEC to 3EF3 (8 bytes)
DATA_3EEC_CarTileDataLookup_Lo:
.db <DATA_34958_CarTiles_Sportscars <DATA_34CF0_CarTiles_FourByFour <DATA_35048_CarTiles_Powerboats <DATA_35350_CarTiles_TurboWheels <DATA_30000_CarTiles_FormulaOne <DATA_30330_CarTiles_Warriors <DATA_306D0_CarTiles_Tanks <DATA_1296A_CarTiles_RuffTrux

; Data from 3EF4 to 3EFC (9 bytes)
DATA_3EF4_CarTilesDataLookup_PageNumber:
.db :DATA_34958_CarTiles_Sportscars :DATA_34CF0_CarTiles_FourByFour :DATA_35048_CarTiles_Powerboats :DATA_35350_CarTiles_TurboWheels :DATA_30000_CarTiles_FormulaOne :DATA_30330_CarTiles_Warriors :DATA_306D0_CarTiles_Tanks :DATA_1296A_CarTiles_RuffTrux
.db $0c ; dangling Helicopters reference

; Data from 3EFD to 3F04 (8 bytes)
DATA_3EFD_CarTileDataLookup_Hi:
.db >DATA_34958_CarTiles_Sportscars >DATA_34CF0_CarTiles_FourByFour >DATA_35048_CarTiles_Powerboats >DATA_35350_CarTiles_TurboWheels >DATA_30000_CarTiles_FormulaOne >DATA_30330_CarTiles_Warriors >DATA_306D0_CarTiles_Tanks >DATA_1296A_CarTiles_RuffTrux

; Pointer Table from 3F05 to 3F16 (9 entries, indexed by _RAM_DE88_)
DATA_3F05_RuffTrux_:
.dw DATA_3F63_ DATA_3F6C_ DATA_3F75_ DATA_3F7E_ DATA_3F87_ DATA_3F90_ DATA_3F99_ DATA_3FA2_
.dw DATA_3FAB_

LABEL_3F17_:
  JumpToPagedFunction LABEL_23BC6_

LABEL_3F22_ScreenOff:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENOFF
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_3F2B_BlankGameRAMTrampoline:
  JumpToPagedFunction LABEL_23B98_BlankGameRAM

LABEL_3F36_ScreenOn:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENON
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_3F3F_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet +
  CallPagedFunction2 LABEL_362D3_
+:ret

LABEL_3F54_BlankGameRAM:
  ld bc, _RAM_DF9A_EndOfRAM - _RAM_DCAB_CarData_Green ; $02EF ; Byte count
-:ld hl, _RAM_DCAB_CarData_Green ; Start
  add hl, bc
  xor a
  ld (hl), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

; 1st entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F63 to 3F6B (9 bytes)
DATA_3F63_:
.db $68 $68 $68 $68 $68 $68 $68 $68 $68

; 2nd entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F6C to 3F74 (9 bytes)
DATA_3F6C_:
.db $68 $68 $68 $68 $6B $68 $68 $68 $68

; 3rd entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F75 to 3F7D (9 bytes)
DATA_3F75_:
.db $6B $68 $6B $68 $78 $68 $6B $68 $6B

; 4th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F7E to 3F86 (9 bytes)
DATA_3F7E_:
.db $78 $6B $78 $6B $7B $6B $78 $6B $78

; 5th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F87 to 3F8F (9 bytes)
DATA_3F87_:
.db $7B $78 $7B $78 $68 $78 $7B $78 $7B

; 6th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F90 to 3F98 (9 bytes)
DATA_3F90_:
.db $68 $7B $68 $7B $6B $7B $68 $7B $68

; 7th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F99 to 3FA1 (9 bytes)
DATA_3F99_:
.db $68 $68 $68 $68 $78 $68 $68 $68 $68

; 8th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3FA2 to 3FAA (9 bytes)
DATA_3FA2_:
.db $68 $68 $68 $68 $7B $68 $68 $68 $68

; 9th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3FAB to 3FB3 (9 bytes)
DATA_3FAB_:
.db $68 $68 $68 $68 $68 $68 $68 $68 $68

LABEL_3FB4_UpdateAnimatedPalette:
  CallPagedFunction2 LABEL_23CE6_UpdateAnimatedPalette
  ret

; Data from 3FC3 to 3FD2 (16 bytes)
DATA_3FC3_:
; Multiples of 6 from 0 to 24 to 0 to 24 to ...
.db $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06

; Data from 3FD3 to 3FFF (45 bytes)
DATA_3FD3_:
; Antiphase of the above
.db $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12

.ifdef BLANK_FILL_ORIGINAL
; Uninitialised memory containing source code
.db "D", 9, "A,(BULLON2)", 13, 10, 9, "OR", 9, "A", 13, 10, 9, "JR", 9, "Z,"
.endif
;.ends

.orga $3fff
; Bank marker
.db :CADDR
;.section "Bank 1"

; Metatile tilemaps are stored from $0080 in each track data bank
; Each metatile is 12 * 12 = 144 bytes of tile indices
; There are up to $41(?) for each track type
; So we use our "times table" macro to generate the split pointers
DATA_4000_TileIndexPointerLow: ; Low bytes of "tile index data pointer table"
  TimesTableLo $8080 144 $41
DATA_4041_TileIndexPointerHigh: ; High bytes of "tile index data pointer table"
  TimesTableHi $8080 144 $41

; 1st entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 4082 to 408A (9 bytes)
DATA_4082_:
.db $AC $AC $AC $AC $A0 $AC $AC $AC $AC

; 2nd entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 408B to 4093 (9 bytes)
DATA_408B_:
.db $A0 $AC $A0 $AC $A1 $AC $A0 $AC $A0

; 3rd entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 4094 to 409C (9 bytes)
DATA_4094_:
.db $A1 $A0 $A1 $A0 $A2 $A0 $A1 $A0 $A1

; 4th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 409D to 40A5 (9 bytes)
DATA_409D_:
.db $A2 $A1 $A2 $A1 $A3 $A1 $A2 $A1 $A2

; 5th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40A6 to 40AE (9 bytes)
DATA_40A6_:
.db $A3 $A2 $A3 $A2 $A0 $A2 $A3 $A2 $A3

; 6th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40AF to 40B7 (9 bytes)
DATA_40AF_:
.db $AC $A3 $AC $A3 $A1 $A3 $AC $A3 $AC

; 7th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40B8 to 40C0 (9 bytes)
DATA_40B8_:
.db $AC $AC $AC $AC $A2 $AC $AC $AC $AC

; 8th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40C1 to 40C9 (9 bytes)
DATA_40C1_:
.db $AC $AC $AC $AC $A3 $AC $AC $AC $AC

; 9th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40CA to 40D2 (9 bytes)
DATA_40CA_:
.db $AC $AC $AC $AC $AC $AC $AC $AC $AC

; Pointer Table from 40D3 to 40E4 (9 entries, indexed by _RAM_DE88_)
DATA_40D3_NotRuffTrux_:
.dw DATA_4082_ DATA_408B_ DATA_4094_ DATA_409D_ DATA_40A6_ DATA_40AF_ DATA_40B8_ DATA_40C1_
.dw DATA_40CA_

; Data from 40E5 to 40F4 (16 bytes)
DATA_40E5_Sign_: ; Sign bit, 1 = negative, 0 = positive
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $01 $01 $01 $01 $01 $01

; Data from 40F5 to 4104 (16 bytes)
DATA_40F5_Sign_:
.db $01 $01 $01 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $01 $01

; Data from 4105 to 4224 (288 bytes)
DATA_4105_: ; 32 bytes per track type, not sure what it does, copied to $da00
; Sports cars
.db $08 $0B $0D $0E $0F $0E $0D $0B $08 $05 $03 $02 $02 $02 $03 $05
.db $02 $03 $04 $05 $08 $0B $0C $0D $0F $0D $0C $0B $08 $05 $04 $03
; Four by four
.db $09 $0A $0A $0B $0C $0B $0A $0A $09 $08 $07 $06 $05 $06 $07 $08
.db $05 $06 $06 $06 $09 $0B $0B $0B $0C $0B $0B $0B $09 $06 $06 $06
; Powerboats
.db $09 $0B $0C $0D $0D $0D $0C $0B $09 $07 $05 $04 $04 $04 $05 $07
.db $04 $04 $06 $08 $09 $0A $0B $0C $0D $0C $0B $0A $09 $08 $06 $04
; Turbo Wheels
.db $09 $0B $0B $0C $0D $0C $0B $0B $09 $07 $05 $04 $03 $04 $05 $07
.db $03 $03 $05 $07 $09 $0A $0B $0D $0D $0D $0B $0A $09 $07 $05 $03
; Formula One
.db $08 $05 $04 $03 $04 $03 $04 $05 $08 $0B $0C $0D $0C $0D $0C $0B
.db $0C $0D $0C $0B $08 $05 $04 $03 $04 $03 $04 $05 $08 $0B $0C $0D
; Warriors
.db $09 $0A $0A $0B $0C $0B $0A $0A $09 $07 $06 $05 $05 $05 $06 $07
.db $05 $05 $06 $07 $08 $09 $0A $0B $0C $0B $0A $09 $08 $07 $06 $05
; Tanks
.db $09 $08 $09 $07 $08 $07 $09 $09 $09 $09 $09 $0B $0A $0B $09 $0A
.db $0A $0A $0A $0A $09 $08 $08 $08 $08 $08 $08 $08 $09 $0A $0A $0A
; RuffTrux
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
; Helicopters
.db $03 $05 $06 $06 $07 $06 $06 $05 $03 $02 $01 $01 $00 $01 $01 $02
.db $05 $06 $06 $07 $08 $0A $0B $0B $0C $0B $0B $0A $08 $07 $06 $06

; Data from 4225 to 4424 (512 bytes)
DATA_4225_TrackMetatileLookup: ; indexes into "tile index data pointer table", for the 64 metatiles per track type
.db $00 $01 $06 $0D $15 $16 $20 $23 $2A $2F $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $24 $25 $26 $27 $28 $29 $02 $03 $04 $07 $08 $09 $0A $0B $0C $0E $0F $10 $11 $17 $18 $19 $1A $1B $1C $1D $1E $1F $12 $13 $14 $21 $22 $05 $2B $00 $2C $00 $00
.db $00 $0F $12 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $10 $27 $28 $29 $2A $2B $2C $2D $2E $1E $1F $20 $21 $11 $2F $32 $33 $13 $30 $31 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $22 $23 $24 $25 $26 $34 $14 $15 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $01 $16 $17 $2A $32 $18 $19 $1A $1C $20 $21 $22 $23 $25 $24 $26 $27 $28 $29 $2B $01 $01 $01 $0E $12 $2D $2E $2F $30 $31 $2C $1D $1B $1E $1F $01 $08 $0D $01 $00 $00 $00 $00
.db $00 $01 $18 $19 $33 $34 $35 $36 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $3E $3F $37 $38 $39 $32 $03 $04 $05 $06 $2B $2C $2D $2E $2F $24 $25 $23 $29 $02 $3A $3B $3C $3D $26 $28 $27 $1B $1C $1D $1E $1F $20 $22 $21 $30 $31 $1A $17 $2A
.db $00 $01 $02 $03 $04 $05 $06 $14 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F $20 $21 $22 $23 $24 $25 $26 $27 $15 $28 $2A $2B $2C $2D $2E $2F $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $3F $1A
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $19 $1C $1D $1E $1F $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $18 $2D $18 $18 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $02 $03 $06 $07 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $01 $04 $05 $08 $09 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $33 $34 $35 $17 $1F $36 $22 $29 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $01 $03 $04 $06 $07 $19 $1A $31 $32 $18 $16 $34 $35 $37 $1D $20 $1E $1F $05 $0D $0E $0F $10 $11 $12 $13 $14 $15 $33 $02 $0B $0C $38 $39 $3A $17 $36 $1B $1C $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $08 $09 $0A $00 $00 $00 $00 $00

; Data from 4425 to 4464 (64 bytes)
DATA_4425_:
.db $FF $FE $0C $04 $06 $06 $08 $0A $0A $00 $0E $0E $02 $02 $FE $0C
.db $04 $FE $FE $FE $00 $08 $00 $FF $FF $FE $FF $FF $FE $FE $0C $FF
.db $04 $0C $FF $FF $FF $FF $FE $FE $FE $FE $FE $FF $00 $FE $08 $FE
.db $0C $04 $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF

LABEL_4465_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet _LABEL_44C2_ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_44C2_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_44C2_ret
  ld a, (_RAM_DE7D_)
  and $3F
  JrZRet _LABEL_44C2_ret
  cp $3C
  JrZRet _LABEL_44C2_ret
  ld a, (_RAM_DF79_CurrentCombinedByte)
  and $18 ; %00011000
  srl a
  or a
  jr z, +
  ld (_RAM_DF7B_), a ; Bits to here, will be 4, 8 or c
  ld a, (_RAM_DF86_)
  add a, $01
  and $07
  ld (_RAM_DF86_), a
  jr z, +
  ld a, (_RAM_DE92_EngineVelocity)
  cp $06
  jr c, +
  sub $01
  ld (_RAM_DE92_EngineVelocity), a
+:
  ld a, (_RAM_DE7D_)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld e, a
  ld d, $00
  ld hl, DATA_4425_
  add hl, de
  ld a, (hl)
  cp $FE
  JrZRet _LABEL_44C2_ret
  cp $FF
  JrZRet _LABEL_44C2_ret
  ld (_RAM_DF7A_), a
_LABEL_44C2_ret:
  ret

LABEL_44C3_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet +
  ld a, (_RAM_DF7B_)
  or a
  jr nz, ++
+:ret

++:
  ld a, $01
  ld (_RAM_DEB5_), a
  ld hl, _RAM_DF7C_
  inc (hl)
  ld a, (_RAM_DF7C_)
  and $07
  ld (_RAM_DF7C_), a
  or a
  jr nz, +
  ld a, (_RAM_DF7B_)
  sub $01
  ld (_RAM_DF7B_), a
+:
  call LABEL_4595_
  ld a, (_RAM_DF84_)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF82_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_)
  sub l
  ld (_RAM_DEAF_), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_), a
  ld a, (_RAM_DF84_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF82_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_), a
+++:
  ld a, (_RAM_DEB0_)
  or a
  jr nz, +
  jp +

+:
  ld a, (_RAM_DF85_)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF85_)
  ld (_RAM_DEB2_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+++:
  ld a, (_RAM_DEB2_)
  or a
  JrNzRet +
  ; Nothing happens!
  ret

+:ret

LABEL_4595_:
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_DF7B_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_DF7B_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_
  ld a, (_RAM_DF7A_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF82_), a
  ld hl, DATA_40E5_Sign_
  ld a, (_RAM_DF7A_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF84_), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF84_), a
++:
  ld hl, DATA_3FD3_
  ld a, (_RAM_DF7A_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF83_), a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_DF7A_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF85_), a
  ret

+:
  ld a, $01
  ld (_RAM_DF85_), a
  ret

LABEL_4622_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JpNzRet _LABEL_46C8_ret
  ld a, (_RAM_DF58_)
  or a
  JpNzRet _LABEL_46C8_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JpNzRet _LABEL_46C8_ret
  ld a, (_RAM_DE7D_)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, LABEL_4682_
  cp $32
  jr z, LABEL_4682_
  ld hl, (_RAM_DBA0_TopLeftMetatileX)
  ld de, (_RAM_DE79_)
  add hl, de
  ld a, l
  cp $10
  jr z, +
  cp $11
  JrNzRet _LABEL_46C8_ret
+:
  ld hl, (_RAM_DBA2_TopLeftMetatileY)
  ld de, (_RAM_DE7B_)
  add hl, de
  ld a, l
  cp $1D
  jr z, +
  cp $1F
  JrNzRet _LABEL_46C8_ret
  ld a, $01
  ld (_RAM_DEB5_), a
  ld a, $61
  call LABEL_473F_
  jp ++

+:
  ld a, $01
  ld (_RAM_DEB5_), a
  ld a, $21
  call LABEL_473F_
  jp ++

LABEL_4682_:
  ld a, $01
  ld (_RAM_DEB5_), a
  call LABEL_470C_
++:
  ld a, (_RAM_DF84_)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF82_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_)
  sub l
  ld (_RAM_DEAF_), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_), a
  ld a, (_RAM_DF84_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF82_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_), a
  jp +++

_LABEL_46C8_ret:
  ret

+:
  ld a, $07
  ld (_RAM_DEAF_), a
+++:
  ld a, (_RAM_DF85_)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF85_)
  ld (_RAM_DEB2_), a
  ret

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  ret

LABEL_470C_:
  ld a, (_RAM_DE7D_)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, +
  ld bc, DATA_37161_
  jp ++
+:ld bc, DATA_370D1_
++:
  ld hl, DATA_2652_TimesTable12Lo
  ld de, (_RAM_DE77_)
  add hl, de
  ld a, (hl)
  ld l, a
  ld h, $00
  ld de, (_RAM_DE75_)
  add hl, de
  add hl, bc
  ld a, :DATA_37161_
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
LABEL_473F_:
  ld b, a
  cp $FF
  jr z, LABEL_4793_
  and $0F
  jr z, ++
  cp $01
  jr z, ++
  cp $02
  jr nz, +
  ld a, $01
  jr ++

+:
  ld a, $02
++:
  ld (_RAM_DF82_), a
  ld (_RAM_DF83_), a
  ld a, b
  and $20
  jr nz, ++
  ld a, b
  and $80
  jr z, +
  xor a
  ld (_RAM_DF84_), a
  jp +++

+:
  ld a, $01
  ld (_RAM_DF84_), a
  jp +++

++:
  xor a
  ld (_RAM_DF82_), a
+++:
  ld a, b
  and $10
  jr nz, ++
  ld a, b
  and $40
  jr z, +
  xor a
  ld (_RAM_DF85_), a
  ret

+:
  ld a, $01
  ld (_RAM_DF85_), a
  ret

++:
  xor a
  ld (_RAM_DF83_), a
  ret

LABEL_4793_:
  xor a
  ld (_RAM_DF82_), a
  ld (_RAM_DF83_), a
  jp LABEL_29A3_

_LABEL_479D_ret:
  ret

LABEL_479E_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet _LABEL_479D_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DD1A_)
  or a
  JrNzRet _LABEL_479D_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_479D_ret
  ld ix, _RAM_DCEC_CarData_Blue
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call ++
  ld ix, _RAM_DCEC_CarData_Blue
  call ++
  ld ix, _RAM_DD2D_CarData_Yellow
++:
  ld a, (ix+10)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, ++
  cp $32
  jr z, ++
  ld a, (ix+4)
  cp $10
  jr z, +
  cp $11
  JrNzRet _LABEL_479D_ret
+:
  ld a, (ix+5)
  cp $1D
  jr z, +
  cp $1F
  JrNzRet _LABEL_479D_ret
  ld a, $61
  jp +++

+:
  ld a, $21
  jp +++

++:
  ld a, (ix+10)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, +
  ld bc, DATA_37161_
  jp ++

+:
  ld bc, DATA_370D1_
++:
  ld hl, DATA_2652_TimesTable12Lo
  ld d, $00
  ld a, (ix+8)
  ld e, a
  add hl, de
  ld a, (hl)
  ld l, a
  ld h, $00
  ld d, $00
  ld a, (ix+6)
  ld e, a
  add hl, de
  add hl, bc
  ld a, :DATA_37161_
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
+++:
  ld b, a
  cp $FF
  jp z, LABEL_48BF_
  and $0F
  cp $02
  jr c, +
  ld a, $01
+:
  ld (_RAM_DF87_), a
  ld a, b
  and $20
  jr nz, ++
  ld a, b
  and $80
  jr z, +
  ld a, (ix+0)
  ld l, a
  ld a, (ix+1)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+0), a
  ld a, h
  ld (ix+1), a
  jp ++

+:
  ld a, (ix+0)
  ld l, a
  ld a, (ix+1)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  add hl, de
  ld a, l
  ld (ix+0), a
  ld a, h
  ld (ix+1), a
++:
  ld a, b
  and $10
  JrNzRet ++
  ld a, b
  and $40
  jr z, +
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+2), a
  ld a, h
  ld (ix+3), a
  ret

+:
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  add hl, de
  ld a, l
  ld (ix+2), a
  ld a, h
  ld (ix+3), a
++:ret

LABEL_48BF_:
  jp LABEL_4DD4_

LABEL_48C2_:
  CallPagedFunction2 LABEL_23BF1_
  ret

LABEL_48D1_:
  ld a, (_RAM_DF6D_)
  add a, $01
  and $01
  ld (_RAM_DF6D_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF5B_)
  cp $04
  jr z, +
--:
  ld a, (_RAM_DCF9_)
  add a, $01
-:
  and $0F
  ld (_RAM_DCF9_), a
  ret

+:
  ld a, (_RAM_DCF9_)
  cp $08
  jr nc, --
  sub $01
  jp -

LABEL_48FC_:
  ld a, (_RAM_DF6E_)
  add a, $01
  and $01
  ld (_RAM_DF6E_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF5C_)
  cp $04
  jr z, +
--:
  ld a, (_RAM_DD3A_)
  add a, $01
-:
  and $0F
  ld (_RAM_DD3A_), a
  ret

+:
  ld a, (_RAM_DD3A_)
  cp $08
  jr nc, --
  sub $01
  jp -

LABEL_4927_:
  ld ix, _RAM_DCAB_CarData_Green
  call +
  ld ix, _RAM_DCEC_CarData_Blue
  call +
  ld ix, _RAM_DD2D_CarData_Yellow
+:
  ld a, $01
  ld (ix+21), a
  ld de, (_RAM_DBA9_)
  ld a, (ix+20)
  or a
  jr z, +
  ld a, (ix+41)
  ld l, a
  ld a, (ix+42)
  ld h, a
  jp ++

+:
  ld a, (ix+0)
  ld l, a
  ld a, (ix+1)
  ld h, a
++:
  or a
  sbc hl, de
  ld de, (_RAM_DC57_)
  add hl, de
  ld a, l
  ld (ix+17), a
  ld a, h
  or a
  jr nz, +
  ld a, l
  cp $F3
  jr nc, LABEL_49BF_
  jp ++

+:
  cp $FF
  jr nz, LABEL_49BF_
  ld a, l
  cp $FD
  jr c, LABEL_49BF_
++:
  ld de, (_RAM_DBAB_)
  ld a, (ix+20)
  or a
  jr z, +
  ld a, (ix+43)
  ld l, a
  ld a, (ix+44)
  ld h, a
  jp ++

+:
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
++:
  or a
  sbc hl, de
  ld de, (_RAM_DC57_)
  add hl, de
  ld a, l
  ld (ix+18), a
  ld a, h
  or a
  jr z, +
  cp $01
  jr nz, ++
  jp LABEL_49BF_

+:
  ld a, l
  cp $E8
  jr nc, LABEL_49BF_
-:
  ret

++:
  cp $FF
  jr nz, LABEL_49BF_
  ld a, l
  cp $E8
  JrNcRet -
LABEL_49BF_:
  ld a, $E4
  ld (ix+18), a
  xor a
  ld (ix+21), a
  ret

LABEL_49C9_:
  ld a, (_RAM_DE2F_)
  or a
  jr nz, +
  ret

+:
  ld a, $01
  ld (_RAM_DEB5_), a
  ld hl, _RAM_DE30_
  inc (hl)
  ld a, (_RAM_DE30_)
  and $07
  ld (_RAM_DE30_), a
  or a
  jr nz, +
  ld a, (_RAM_DE2F_)
  sub $01
  ld (_RAM_DE2F_), a
+:
  call LABEL_6677_
  JumpToPagedFunction LABEL_1BDF3_

; Data from 49FA to 4DA9 (944 bytes)
; One of the three is pointed to by _RAM_DF53_
; Depending on whether it's track 0, 1 or 2 (for F1)
; ???
_LABEL_49FA_:
.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
_LABEL_4A80_:
.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
_LABEL_4B10_:
.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0

; Data pointed to by DATA_1D65__Lo etc
; TODO what is it? 0..8 with a weird ramp effect
_LABEL_4BAC_: .db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
_LABEL_4BCA_: .db 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 1 0 1 0
_LABEL_4BE8_: .db 0 0 0 0 0 0 1 0 0 1 0 0 1 1 0 1 1 0 1 1 1 1 1 0 1 1 1 1 1 1
_LABEL_4C06_: .db 0 0 0 0 0 0 1 0 1 0 1 0 1 1 1 1 1 1 2 1 1 2 1 1 2 2 1 2 1 1
_LABEL_4C24_: .db 0 0 0 0 0 0 1 1 0 1 1 0 2 1 1 2 1 1 2 2 1 2 2 1 2 2 2 2 2 2
_LABEL_4C42_: .db 0 0 0 0 0 0 1 1 1 1 1 0 2 2 1 2 2 1 3 2 2 2 2 2 3 2 3 2 3 2
_LABEL_4C60_: .db 0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 3 2 3 2 3 2 3 3 3 3 3 3
_LABEL_4C7E_: .db 0 0 0 0 0 0 2 1 1 1 1 1 3 2 2 3 2 2 3 3 3 3 3 3 4 3 4 3 4 3
_LABEL_4C9C_: .db 0 0 0 0 0 0 2 1 1 2 1 1 3 3 2 3 3 2 4 3 3 4 3 3 4 4 4 4 4 4
_LABEL_4CBA_: .db 0 0 0 0 0 0 2 1 2 1 2 1 3 3 3 3 3 3 4 4 4 4 4 3 5 4 5 4 5 4
_LABEL_4CD8_: .db 0 0 0 0 0 0 2 2 1 2 2 1 4 3 3 4 3 3 5 4 4 4 4 4 5 5 5 5 5 5
_LABEL_4CF6_: .db 0 0 0 0 0 0 2 2 2 2 2 1 4 4 3 4 4 3 5 5 4 5 5 4 6 5 6 5 6 5
_LABEL_4D14_: .db 0 0 0 0 0 0 2 2 2 2 2 2 4 4 4 4 4 4 5 5 5 5 5 5 6 6 6 6 6 6
_LABEL_4D32_: .db 0 0 0 0 0 0 3 2 2 2 2 2 5 4 4 5 4 4 6 5 6 5 6 5 7 6 7 6 7 6
_LABEL_4D50_: .db 0 0 0 0 0 0 3 2 2 3 2 2 5 5 4 5 5 4 6 6 6 6 6 5 7 7 7 7 7 7
_LABEL_4D6E_: .db 0 0 0 0 0 0 3 2 3 2 3 2 5 5 5 5 5 5 7 6 6 7 6 6 8 7 8 7 8 7
_LABEL_4D8C_: .db 0 0 0 0 0 0 3 3 2 3 3 2 6 5 5 6 5 5 7 7 6 7 7 6 8 8 8 8 8 8

LABEL_4DAA_:
  ld a, (ix+20)
  or a
  JpNzRet _LABEL_5A87_ret
  ld hl, DATA_24AE_
  ld d, $00
  ld a, (ix+11)
  ld e, a
  add hl, de
  ld a, (hl)
  ld (ix+36), a
  ld hl, DATA_24BE_
  add hl, de
  ld a, (hl)
  ld (ix+37), a
  cp $82
  JpZRet _LABEL_5A87_ret
  ld a, $01
  ld (ix+38), a
  jp LABEL_5A77_

LABEL_4DD4_:
  ld a, (ix+20)
  or a
  ret nz
  ld a, (ix+45)
  or a
  jr z, +
  cp $01
  jr z, ++
  jp LABEL_4EFA_

+:
  ld a, (_RAM_DCD9_)
  or a
  JrNzRet +
  ld a, CarState_3_Falling
  ld (_RAM_DF5A_CarState3), a
  ld a, $01
  ld (_RAM_DCD9_), a
  xor a
  ld (ix+11), a
  ld (ix+20), a
  ld (_RAM_DE67_), a
  ld (_RAM_DE31_), a
  ld (_RAM_DE32_), a
+:ret

++:
  ld a, (_RAM_D5B0_)
  or a
  JrNzRet _LABEL_4E7A_ret
  ld a, (_RAM_DD1A_)
  or a
  JrNzRet _LABEL_4E7A_ret
  ld a, (_RAM_D5BE_)
  or a
  jr nz, +
  ld a, SFX_0E_FallToFloor
  ld (_RAM_D974_SFXTrigger_Player2), a
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DF58_)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5B0_), a
+:
  ld a, (_RAM_D5C0_)
  or a
  jr z, +
  ld a, $04
  jp ++

+:
  ld a, $03
++:
  ld (_RAM_DF5B_), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D96C_), hl
  xor a
  ld (_RAM_D96F_), a
LABEL_4E49_:
  ld a, $01
  ld (_RAM_DD1A_), a
  xor a
  ld (ix+11), a
  ld (ix+20), a
  ld (_RAM_DE68_), a
  ld (_RAM_DE34_), a
  ld (_RAM_DE35_), a
  ld (_RAM_DF7B_), a
  ld (_RAM_D5B9_), a
  ld (_RAM_DD08_), a
  ld (_RAM_DF79_CurrentCombinedByte), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ld (_RAM_D5A5_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, LABEL_4EA0_
_LABEL_4E7A_ret:
  ret

-:
  xor a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DB85_), a
  ld (_RAM_DB84_), a
  ld (_RAM_DB82_), a
  ld (_RAM_DB83_), a
  ld (_RAM_DB7E_), a
  ld (_RAM_DB7F_), a
  ld (_RAM_DCFB_), a
  ld (_RAM_DCFC_), a
  ld a, $01
  ld (_RAM_D940_), a
  ret

LABEL_4EA0_:
  ld a, (_RAM_DF5B_)
  cp $03
  jr z, -
  cp $04
  jr z, -
LABEL_4EAB_:
  xor a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DCF7_), a
  ld (_RAM_D5A4_IsReversing), a
  ld (_RAM_D5A5_), a
  ld a, $01
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld (_RAM_DF81_), a
  ld a, (_RAM_DBA4_)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBA9_)
  add hl, de
  ld de, $0080
  or a
  sbc hl, de
  ld a, l
  and $FC
  ld l, a
  ld (_RAM_DBAD_), hl
  ld a, (_RAM_DBA5_)
  cp $F0
  jr c, +
  xor a
+:
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBAB_)
  add hl, de
  ld de, $0068
  or a
  sbc hl, de
  ld a, l
  and $FC
  ld l, a
  ld (_RAM_DBAF_), hl
  ret

LABEL_4EFA_:
  ld a, (_RAM_DD5B_)
  or a
  JrNzRet +
  ld a, $03
  ld (_RAM_DF5C_), a
  ld a, $01
  ld (_RAM_DD5B_), a
  xor a
  ld (ix+11), a
  ld (ix+20), a
  ld (_RAM_DE69_), a
  ld (_RAM_DE37_), a
  ld (_RAM_DE38_), a
+:ret

LABEL_4F1B_:
  ld hl, (_RAM_DED1_MetatilemapPointer)
  ld a, (hl)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld b, a
  add a, $00
  ld l, a
  ld h, $40
  jr nc, +
  inc h
+:
  ld e, (hl)
  ld a, b
  add a, $41
  ld l, a
  ld h, $40
  jr nc, +
  inc h
+:
  ld d, (hl)
  ld a, (_RAM_DEE7_)
  add a, e
  ld e, a
  jr nc, +
  inc d
+:
  call LABEL_19CE_
  ld hl, (_RAM_DB64_)
  ld a, (_RAM_DC54_IsGameGear)
  ld c, $1D
  or a
  jr z, +
  ld c, $13
+:
  ; de -> hl', c -> de'
  push de
  exx
    pop hl
    ld de, $000C
  exx
  ld a, (_RAM_DEC6_)
  ld d, a
  ld a, (_RAM_DEC8_)
  ld b, a
  ld e, $0C
-:
  exx
    ld a, (hl)
    add hl, de
  exx
  ld (hl), a
  inc hl
  inc b
  ld a, b
  cp c
  jr z, +
  inc d
  ld a, d
  cp e
  jr nz, -
  ld (_RAM_DB64_), hl
  ld a, b
  ld (_RAM_DEC8_), a
  ld a, d
  ld (_RAM_DEC6_), a
  ret

+:
  ld a, b
  ld (_RAM_DEC8_), a
  ld a, d
  ld (_RAM_DEC6_), a
  ld a, $01
  ld (_RAM_DEC9_), a
  ld (_RAM_DECA_), a
  ret

LABEL_4F8F_:
  ld a, (_RAM_DF4F_)
  ld l, a
  ld a, (_RAM_DF50_)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCC4_)
  cp l
  jr z, LABEL_4FA7_
  jr c, LABEL_4FBC_
LABEL_4FA7_:
  ld a, (_RAM_DF2A_Positions.Red)
  sub $01
  ld (_RAM_DF2A_Positions.Red), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCC4_)
  cp l
  jr z, LABEL_4FBC_
  jr nc, LABEL_4FA7_
LABEL_4FBC_:
  ld a, (_RAM_DF2A_Positions.Green)
  sub $01
  ld (_RAM_DF2A_Positions.Green), a
  ret

++:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCC4_)
  cp l
  jr nz, -
  ld a, (_RAM_D589_)
  ld l, a
  ld a, (_RAM_DCC6_)
  cp l
  jr z, LABEL_4FA7_
  jr nc, LABEL_4FBC_
  jp LABEL_4FA7_

LABEL_4FDE_:
  ld a, (_RAM_DF4F_)
  ld l, a
  ld a, (_RAM_DF51_)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr z, LABEL_4FF6_
  jr c, LABEL_500B_
LABEL_4FF6_:
  ld a, (_RAM_DF2A_Positions.Red)
  sub $01
  ld (_RAM_DF2A_Positions.Red), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr z, LABEL_500B_
  jr nc, LABEL_4FF6_
LABEL_500B_:
  ld a, (_RAM_DF2A_Positions.Blue)
  sub $01
  ld (_RAM_DF2A_Positions.Blue), a
  ret

++:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr nz, -
  ld a, (_RAM_D589_)
  ld l, a
  ld a, (_RAM_DD07_)
  cp l
  jr z, LABEL_4FF6_
  jr nc, LABEL_500B_
  jp LABEL_4FF6_

LABEL_502D_:
  ld a, (_RAM_DF4F_)
  ld l, a
  ld a, (_RAM_DF52_)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, LABEL_5045_
  jr c, LABEL_505A_
LABEL_5045_:
  ld a, (_RAM_DF2A_Positions.Red)
  sub $01
  ld (_RAM_DF2A_Positions.Red), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, LABEL_505A_
  jr nc, LABEL_5045_
LABEL_505A_:
  ld a, (_RAM_DF2A_Positions.Yellow)
  sub $01
  ld (_RAM_DF2A_Positions.Yellow), a
  ret

++:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr nz, -
  ld a, (_RAM_D589_)
  ld l, a
  ld a, (_RAM_DD48_)
  cp l
  jr z, LABEL_5045_
  jr nc, LABEL_505A_
  jp LABEL_5045_

LABEL_507C_:
  ld a, (_RAM_DF50_)
  ld l, a
  ld a, (_RAM_DF51_)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr z, LABEL_5094_
  jr c, LABEL_50A9_
LABEL_5094_:
  ld a, (_RAM_DF2A_Positions.Green)
  sub $01
  ld (_RAM_DF2A_Positions.Green), a
  ret

+:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr z, LABEL_50A9_
  jr nc, LABEL_5094_
LABEL_50A9_:
  ld a, (_RAM_DF2A_Positions.Blue)
  sub $01
  ld (_RAM_DF2A_Positions.Blue), a
  ret

++:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr nz, -
  ld a, (_RAM_DCC6_)
  ld l, a
  ld a, (_RAM_DD07_)
  cp l
  jr z, LABEL_5094_
  jr nc, LABEL_50A9_
  jp LABEL_5094_

LABEL_50CB_:
  ld a, (_RAM_DF50_)
  ld l, a
  ld a, (_RAM_DF52_)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, LABEL_50E3_
  jr c, LABEL_50F8_
LABEL_50E3_:
  ld a, (_RAM_DF2A_Positions.Green)
  sub $01
  ld (_RAM_DF2A_Positions.Green), a
  ret

+:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, LABEL_50F8_
  jr nc, LABEL_50E3_
LABEL_50F8_:
  ld a, (_RAM_DF2A_Positions.Yellow)
  sub $01
  ld (_RAM_DF2A_Positions.Yellow), a
  ret

++:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr nz, -
  ld a, (_RAM_DCC6_)
  ld l, a
  ld a, (_RAM_DD48_)
  cp l
  jr z, LABEL_50E3_
  jr nc, LABEL_50F8_
  jp LABEL_50E3_

LABEL_511A_:
  ld a, (_RAM_DF51_)
  ld l, a
  ld a, (_RAM_DF52_)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DD05_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, LABEL_5132_
  jr c, LABEL_5147_
LABEL_5132_:
  ld a, (_RAM_DF2A_Positions.Blue)
  sub $01
  ld (_RAM_DF2A_Positions.Blue), a
  ret

+:
  ld a, (_RAM_DD05_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, LABEL_5147_
  jr nc, LABEL_5132_
LABEL_5147_:
  ld a, (_RAM_DF2A_Positions.Yellow)
  sub $01
  ld (_RAM_DF2A_Positions.Yellow), a
  ret

++:
  ld a, (_RAM_DD05_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr nz, -
  ld a, (_RAM_DD07_)
  ld l, a
  ld a, (_RAM_DD48_)
  cp l
  jr z, LABEL_5132_
  jr nc, LABEL_5147_
  jp LABEL_5132_

LABEL_5169_GameVBlankEngineUpdateTrampoline:
  JumpToPagedFunction LABEL_37292_GameVBlankEngineUpdate

LABEL_5174_GameVBlankPart3Trampoline:
  JumpToPagedFunction LABEL_3730C_GameVBlankPart3

LABEL_517F_NMI_SMS:
    ld a, (_RAM_D599_IsPaused)
    xor $01
    ld (_RAM_D599_IsPaused), a
    or a
    jr z, +
    ; If we became paused, silence the PSG
    ld a, $FF
    out (PORT_PSG), a
    ld a, $9F
    out (PORT_PSG), a
    ld a, $BF
    out (PORT_PSG), a
    ld a, $DF
    out (PORT_PSG), a
+:
  pop af
  retn

LABEL_519D_:
  JumpToPagedFunction LABEL_23C68_ReadGGPauseButton

LABEL_51A8_ClearTilemapTrampoline:
  JumpToPagedFunction LABEL_23DB6_ClearTilemap

LABEL_51B3_:
  ld a, (_RAM_D5DF_)
  or a
  ret nz
  ld ix, _RAM_DCEC_CarData_Blue
  ld l, (ix+0)
  ld h, (ix+1)
  ld (_RAM_D59F_), hl
  ld l, (ix+2)
  ld h, (ix+3)
  ld (_RAM_D5A1_), hl
  ret

LABEL_51CF_:
  JumpToPagedFunction LABEL_3779F_

LABEL_51DA_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld ix, _RAM_DCEC_CarData_Blue
  ld a, (ix+12)
  ld (_RAM_DE56_), a
  ld a, $01
  ld (_RAM_D59E_), a
  call LABEL_5304_
  call LABEL_5764_
  call LABEL_5451_
  TailCall LABEL_5872_

+:
  xor a
  ld (_RAM_DC3D_IsHeadToHead), a
  ld ix, _RAM_DCEC_CarData_Blue
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
  ld a, $01
  ld (_RAM_D59E_), a
  call LABEL_5304_
  call LABEL_5769_
  call LABEL_5451_
  ld a, $01
  ld (_RAM_DC3D_IsHeadToHead), a
  call LABEL_5872_
  ld a, $01
  ld (_RAM_DC3D_IsHeadToHead), a
  ret

LABEL_522C_:
  ld a, (_RAM_DB99_AccelerationDelay)
  dec a
  ld (ix+19), a
  ld a, (_RAM_DB9A_DecelerationDelay)
  dec a
  ld (ix+61), a
  ret

LABEL_523B_:
  xor a
  ld (_RAM_D59E_), a
  ld a, (_RAM_DE4F_)
  cp $80
  jr z, LABEL_52B7_
  inc a
  ld (_RAM_DE4F_), a
  and $0F
  jr nz, +
  ld a, (_RAM_DE50_)
  xor $01
  ld (_RAM_DE50_), a
+:
  call LABEL_1C98_
  ld a, (_RAM_DBB1_)
  ld (_RAM_DBB9_), a
  ld a, (_RAM_DBB3_)
  ld (_RAM_DBBA_), a
  ld a, (_RAM_DBB5_)
  ld (_RAM_DBBB_), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, LABEL_5298_
  ld a, (_RAM_DE4F_)
  cp $2C
  JrNcRet _LABEL_5297_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_5283_
  ld a, $01
  call +
LABEL_5283_:
  ld a, (_RAM_DE4F_)
  cp $16
  JrNcRet _LABEL_5297_ret
  ld a, $01
  ld (_RAM_DEB9_), a
  inc a
  ld (_RAM_DEAF_), a
  xor a
  ld (_RAM_DEB0_), a
_LABEL_5297_ret:
  ret

LABEL_5298_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  dec a
  JrNzRet _LABEL_5297_ret
  ld a, (_RAM_DE4F_)
  cp $08
  JrNcRet _LABEL_5297_ret
  call LABEL_5283_
  ld a, $01
  ld (_RAM_DEB0_), a
+:
  ld (_RAM_DEB8_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DEB2_), a
  ret

LABEL_52B7_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  dec a
  jp z, LABEL_51DA_
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, LABEL_5298_
  ld a, (_RAM_D5CA_)
  inc a
  and $03
  ld (_RAM_D5CA_), a
  ld ix, _RAM_DCAB_CarData_Green
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
  call LABEL_5304_
  ld ix, _RAM_DCEC_CarData_Blue
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
  call LABEL_5304_
  ld ix, _RAM_DD2D_CarData_Yellow
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
LABEL_5304_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jp z, LABEL_536C_
  ld a, (_RAM_DD1A_)
  or a
  jp nz, LABEL_522C_
  jp LABEL_536C_

+:
  ld a, (_RAM_DD1A_)
  or a
  jp nz, LABEL_522C_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, LABEL_536C_
  ld a, (_RAM_DF7F_)
  or a
  jr nz, LABEL_536C_
  ld a, (_RAM_DF6A_)
  or a
  jr nz, LABEL_536C_
  ld b, $07
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_2_MASK ; $20
  jr nz, LABEL_536C_
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_1_MASK ; $10
  jr z, LABEL_536C_
  ld a, (_RAM_D5A5_)
  or a
  jr nz, +
  ld a, (_RAM_DCF7_)
  or a
  jr nz, ++
+:
  ld a, $02
  ld (_RAM_DE57_), a
  ld (_RAM_DCF7_), a
  ld a, $01
  ld (_RAM_D5A5_), a
  ld a, (_RAM_DCF9_)
  ld d, $00
  ld e, a
  ld hl, DATA_250E_
  add hl, de
  ld a, (hl)
  ld (_RAM_DE56_), a
  ret

LABEL_536C_:
  ld a, (_RAM_D5A5_)
  or a
  jr z, +
  xor a
  ld (_RAM_DCF7_), a
  ld (_RAM_D5A5_), a
+:
  ld a, (ix+26)
  or a
  jr z, +++
LABEL_537F_:
  ld b, $07
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld a, (_RAM_DB9A_DecelerationDelay)
  ld b, a
++:
  ld a, (ix+61)
  inc a
  ld (ix+61), a
  cp b
  jp c, LABEL_544A_
  ld (ix+61), $00
  ld a, (ix+11)
  or a
  jp z, LABEL_544A_
  ld a, (ix+20)
  or a
  jp nz, LABEL_544A_
  dec (ix+11)
  jp LABEL_544A_

+++:
  ld l, (ix+47)
  ld h, (ix+48)
  ld a, (hl)
  or a
  jr z, +
  ld b, $07
  jp ++++

+:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
+:
  ld a, (_RAM_DB99_AccelerationDelay)
  jr +++

++:
  ld a, (ix+50)
+++:
  ld b, a
++++:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jp nz, LABEL_522C_
  ld a, (_RAM_DC3D_IsHeadToHead)
  dec a
  jr nz, ++
  ld a, (_RAM_D59D_)
  or a
  jr z, +
  jp ++

+:
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_1_MASK ; $10
  jr z, ++
  ld a, (ix+11)
  or a
  jr nz, LABEL_537F_
  ld a, (_RAM_DB99_AccelerationDelay)
  dec a
  ld (ix+19), a
  jp LABEL_544A_

++:
  ld a, (_RAM_DB9A_DecelerationDelay)
  dec a
  ld (ix+61), a
  ld a, (ix+19)
  inc a
  ld (ix+19), a
  cp b
  jr c, LABEL_544A_
  ld (ix+19), $00
  ld a, (_RAM_D5D0_Player2Handicap)
  or a
  jr z, +
  ld l, a
  ld a, (ix+49)
  sub l
  ld l, a
  ld a, (ix+11)
  cp l
  jr z, LABEL_544A_
  jr c, +++
  jr ++

+:
  ld l, (ix+11)
  ld a, (ix+49)
  cp l
  jr z, LABEL_544A_
  jr nc, +++
++:
  ld a, (ix+20)
  or a
  jr nz, LABEL_544A_
  dec (ix+11)
  jp LABEL_544A_

+++:
  ld a, (ix+20)
  or a
  jr nz, LABEL_544A_
  inc (ix+11)
LABEL_544A_:
  ld a, (_RAM_D59E_)
  or a
  jr z, LABEL_5451_
  ret

LABEL_5451_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (ix+45)
  ld l, a
  ld a, (_RAM_D5CA_)
  cp l
  jp nz, LABEL_56C0_
+:
  ld l, (ix+0)
  ld h, (ix+1)
  ld de, $000C
  add hl, de
  ld (_RAM_DF20_), hl
  call LABEL_7A58_
  ld a, (_RAM_DF20_)
  ld (ix+4), a
  ld a, (_RAM_DF21_)
  srl a
  srl a
  srl a
  ld (ix+6), a
  ld l, (ix+2)
  ld h, (ix+3)
  ld de, $000C
  add hl, de
  ld (_RAM_DF20_), hl
  call LABEL_7A58_
  ld a, (_RAM_DF20_)
  ld (ix+5), a
  ld a, (_RAM_DF21_)
  srl a
  srl a
  srl a
  ld (ix+8), a
  xor a
  ld (_RAM_DEF1_), a
  ld (_RAM_DEF2_), a
  ld a, (ix+5)
  or a
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_MetatilemapWidth)
  ld (_RAM_DEF4_), a
  call LABEL_30EA_
+:
  ld a, (_RAM_DEF1_)
  ld l, a
  ld a, (_RAM_DEF2_)
  ld h, a
  ld d, $00
  ld e, (ix+4)
  add hl, de
  ld (_RAM_D585_), hl
  ld de, _RAM_C400_TrackIndexes
  add hl, de
  ld a, (hl)
  ld (ix+24), a
  ld hl, (_RAM_D585_)
  ld de, $C000
  add hl, de
  ld a, (hl)
  ld (ix+10), a
  and $C0
  ld (_RAM_DE53_), a
  ld hl, DATA_254E_TimesTable18Lo
  ld a, (ix+10)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld c, (hl)
  ld hl, DATA_258F_TimesTable18Hi
  add hl, de
  ld d, (hl)
  ld e, c
  ld hl, _RAM_C800_WallData
  add hl, de
  ld b, h
  ld c, l
  ld hl, DATA_2652_TimesTable12Lo
  ld d, $00
  ld e, (ix+8)
  add hl, de
  ld l, (hl)
  ld h, $00
  ld d, $00
  ld e, (ix+6)
  add hl, de
  ld a, l
  ld (_RAM_DE6D_), a
  ld a, h
  ld (_RAM_DE6E_), a
  ld de, DATA_16A38_DivideBy8
  add hl, de
  ld a, :DATA_16A38_DivideBy8
  ld (PAGING_REGISTER), a
  ld l, (hl)
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld h, $00
  add hl, bc
  ld a, (hl)
  ld (_RAM_DE70_), a
  ld a, (_RAM_DE6D_)
  ld l, a
  ld a, (_RAM_DE6E_)
  ld h, a
  ld de, DATA_169A8_IndexToBitmask
  add hl, de
  ld a, :DATA_169A8_IndexToBitmask
  ld (PAGING_REGISTER), a
  ld b, (hl)
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  xor a
  ld (_RAM_D5DF_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, (_RAM_DCF6_)
  and $3F
  jr z, ++
  cp $1A
  jr z, ++
+:
  ld a, (_RAM_DE70_)
  and b
  jp z, LABEL_5608_
++:
  ld l, (ix+47)
  ld h, (ix+48)
  xor a
  ld (hl), a
  ld (ix+20), a
  ld l, (ix+39)
  ld h, (ix+40)
  ld de, $0008
  add hl, de
  ld (hl), a
  ld a, (_RAM_D59E_)
  or a
  jr z, LABEL_55FA_
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, +
  ld a, :DATA_37232_FourByFour_
  ld (PAGING_REGISTER), a
  ld hl, DATA_37232_FourByFour_
  ld d, $00
  ld a, (_RAM_DCF6_)
  and $3F
  ld e, a
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, l
  or a
  jr nz, LABEL_5608_
+:
  ld a, (_RAM_D5A5_)
  or a
  jr nz, +
  ld a, SFX_03_Crash
  ld (_RAM_D974_SFXTrigger_Player2), a
+:
  ld hl, 1000 ; $03E8
  ld (_RAM_D96C_), hl
  call LABEL_51CF_
  ld hl, (_RAM_D59F_)
  ld (ix+0), l
  ld (ix+1), h
  ld hl, (_RAM_D5A1_)
  ld (ix+2), l
  ld (ix+3), h
  xor a
  ld (ix+11), a
  ld (ix+15), a
  ld (ix+16), a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DB7E_), a
  ld (_RAM_DB7F_), a
  ld (_RAM_D5B9_), a
  ld a, $01
  ld (_RAM_D5DF_), a
  jp LABEL_5608_

LABEL_55FA_:
  ld a, (ix+12)
  cp (ix+13)
  ld a, $00
  jr nz, +
  inc a
+:
  ld (ix+11), a
LABEL_5608_:
  ld hl, DATA_25D0_TimesTable36Lo
  ld a, (ix+10)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  ld d, $00
  ld hl, DATA_2611_TimesTable36Hi
  add hl, de
  ld a, (hl)
  ld d, a
  ld e, c
  ld hl, _RAM_CC80_BehaviourData
  add hl, de
  ld b, h
  ld c, l
  ld a, (_RAM_DE6D_)
  ld l, a
  ld a, (_RAM_DE6E_)
  ld h, a
  ld a, :DATA_1B1A2_
  ld (PAGING_REGISTER), a
  ld de, DATA_1B1A2_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld h, $00
  add hl, bc
  ld a, (hl)
  ld (ix+28), a
  ld h, a
  ld l, a
  ld a, (ix+58)
  cp l
  jr z, +
  ld (ix+59), a
  ld a, l
  ld (ix+58), a
+:
  ld a, (ix+46)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  dec a
  jp z, LABEL_575D_
+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, (ix+10)
  and $3F
  cp $23
  jr nz, +
  ld a, $08
  ld (ix+12), a
  jp LABEL_56C0_

+:
  ld a, h
  and $0F
  ld e, a
  ld d, $00
  ld a, (_RAM_DE53_)
  or a
  jr z, +
  and $80
  jr z, +
  ld a, (ix+10)
  and $3F
  ld c, a
  ld hl, _RAM_D900_
  ld b, $00
  add hl, bc
  ld a, (hl)
  and $60
  sra a
  ld c, a
  ld b, $00
  ld hl, DATA_1DA7_
  add hl, bc
  jp ++

+:
  ld hl, DATA_1D87_
++:
  add hl, de
  ld a, (hl)
  ld (ix+12), a
  ld a, (_RAM_DE53_)
  and $40
  jr z, LABEL_56C0_
  ld hl, DATA_1D97_
  ld d, $00
  ld e, (ix+12)
  add hl, de
  ld a, (hl)
  ld (ix+12), a
LABEL_56C0_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jp nz, LABEL_5764_
  ld a, (_RAM_D5D9_)
  or a
  jp nz, LABEL_5764_
+:
  ld a, (ix+46)
  or a
  jp nz, LABEL_586B_
  ld a, (ix+51)
  or a
  jr z, +
  ld a, (ix+20)
  or a
  jr nz, LABEL_5764_
+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr z, +
  cp TT_4_FormulaOne
  jr nz, ++
  ld l, $05
  jp +++

+:
  ld l, $03
  jp +++

++:
  ld l, $07
+++:
  ld a, (_RAM_DF97_)
  ld d, a
  ld a, (ix+13)
  ld c, a
  ld a, (ix+12)
  cp c
  jr z, LABEL_5764_
  sub c
  jr c, +++
  cp $02
  jr c, ++
  ld b, a
  ld a, (ix+11)
  cp d
  jr c, +
  dec a
  ld (ix+11), a
+:
  ld a, b
++:
  cp $08
  jr nc, LABEL_573C_
--:
  ld a, (ix+13)
  inc a
-:
  and $0F
  ld b, a
  ld a, (ix+14)
  inc a
  and l
  ld (ix+14), a
  or a
  jr nz, LABEL_5764_
  ld a, b
  ld (ix+13), a
  jp LABEL_5764_

LABEL_573C_:
  ld a, (ix+13)
  dec a
  jp -

+++:
  xor $FF
  inc a
  cp $02
  jr c, ++
  ld b, a
  ld a, (ix+11)
  cp d
  jr c, +
  dec a
  ld (ix+11), a
+:
  ld a, b
++:
  cp $08
  jr c, LABEL_573C_
  jp --

LABEL_575D_:
  ld a, (_RAM_D59E_)
  or a
  jr z, LABEL_5764_
  ret

LABEL_5764_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  ret nz
LABEL_5769_:
  ld a, (_RAM_D5A5_)
  or a
  jr nz, +++
  ld a, (ix+46)
  or a
  jp nz, LABEL_586B_
  ld l, (ix+11)
  ld a, (_RAM_DB98_TopSpeed)
  cp l
  jr nz, +
  jp ++

+:
  ld a, (_RAM_DF00_)
  or a
  jr nz, ++ ; no-op
++:
  call LABEL_EE6_
+++:
  ; Look up pointer (index 0..16)
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_DE57_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_DE57_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  
  push de
    ld hl, DATA_3FC3_
    ld a, (_RAM_DE56_)
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    ld hl, _RAM_DEAD_
    add a, (hl)
    ld h, d
    ld l, e
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    ld (ix+15), a
    ld hl, DATA_40E5_Sign_
    ld a, (_RAM_DE56_)
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    or a
    jr z, +
    ld (ix+33), $00
    ld a, (ix+0)
    ld l, a
    ld a, (ix+1)
    ld h, a
    ld d, $00
    ld a, (ix+15)
    ld e, a
    or a
    sbc hl, de
    ld (ix+0), l
    ld (ix+1), h
    jp ++

+:
    ld (ix+33), $01
    ld l, (ix+0)
    ld h, (ix+1)
    ld d, $00
    ld a, (ix+15)
    ld e, a
    add hl, de
    ld (ix+0), l
    ld (ix+1), h
++:
  pop de
  ld hl, DATA_3FD3_
  ld a, (_RAM_DE56_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (ix+16), a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_DE56_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld (ix+32), $00
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  ld d, $00
  ld a, (ix+16)
  ld e, a
  or a
  sbc hl, de
  ld (ix+2), l
  ld (ix+3), h
  jp LABEL_586B_

+:
  ld (ix+32), $01
  ld l, (ix+2)
  ld h, (ix+3)
  ld d, $00
  ld a, (ix+16)
  ld e, a
  add hl, de
  ld (ix+2), l
  ld (ix+3), h
LABEL_586B_:
  ld a, (_RAM_D59E_)
  or a
  jr z, LABEL_5872_
  ret

LABEL_5872_:
  ld a, (ix+28)
  and $F0 ; get behaviour nibble
  rr a
  rr a
  rr a
  rr a
  ld b, a
  ld d, $00
  ld a, (_RAM_DB97_TrackType)
  or a
  rl a ; x16
  rl a
  rl a
  rl a
  ld e, a
  ld hl, DATA_242E_BehaviourLookup
  add hl, de ; look up behaviour
  ld a, $0F
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, $0E
  ld c, a
+:
  ld a, b
  and c
  ld e, a
  add hl, de
  ld a, (hl)
  ld b, a
  ld a, (ix+29)
  ld (ix+30), a
  cp b
  jr z, +
  ld (ix+31), a
+:
  ld a, b
  ld (ix+29), a
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_5902_ret
  ld a, (ix+29)
  or a
  jp z, LABEL_594E_
  cp $06
  jp z, LABEL_4DAA_
  cp $04
  jp z, LABEL_59EF_
  cp $03
  jp z, LABEL_59A4_
  cp $0A
  jp z, LABEL_5983_
  cp $0B
  jp z, LABEL_59BC_
  cp $0D
  jp z, LABEL_5979_
  cp $01
  jp z, LABEL_4DD4_
  cp $02
  jr z, +
  cp $05
  jr z, ++
  cp $12
  jp z, LABEL_79C8_
  cp $08
  jp z, LABEL_1CF4_
  cp $09
  jp z, LABEL_5B9A_
  cp $13
  jp z, LABEL_5E25_
_LABEL_5902_ret:
  ret

+:
  ld a, (ix+11)
  cp $07
  JrCRet +
  ld a, (ix+34)
  ld l, a
  ld a, (ix+35)
  ld h, a
  ld de, $002C
  add hl, de
  xor a
  ld (hl), a
  inc hl
  ld a, $01
  ld (hl), a
+:ret

++:
  ld a, (ix+11)
  or a
  jr z, +++
  ld a, (ix+34)
  ld l, a
  ld a, (ix+35)
  ld h, a
  ld d, $00
  ld e, $2C
  add hl, de
  ld a, $01
  ld (hl), a
  inc hl
  ld (hl), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_3_TurboWheels
  JrZRet +++
  cp TT_7_RuffTrux
  JrZRet +++
  cp TT_5_Warriors
  jr nz, +
  ld a, $08
  jr ++

+:
  ld a, $10
++:
  ld (_RAM_D5B7_), a
+++:ret

LABEL_594E_:
  ld a, (ix+20)
  or a
  JrNzRet _LABEL_5978_ret
  ld a, (ix+30)
  cp $04
  jr z, +
  cp $0B
  jr z, +
  cp $0D
  jr z, +
  cp $03
  JrNzRet _LABEL_5978_ret
+:
  ld a, $1C
  ld (ix+36), a
  ld a, $08
  ld (ix+37), a
  xor a
  ld (ix+38), a
  jp LABEL_5A77_

_LABEL_5978_ret:
  ret

LABEL_5979_:
  ld a, (ix+30)
  cp $0D
  JrZRet _LABEL_5978_ret
  jp LABEL_4DAA_

LABEL_5983_:
  ld a, (ix+20)
  or a
  jr nz, +
  ld a, (ix+30)
  cp $0B
  jr z, ++
+:
  jp LABEL_59DC_

++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  jp LABEL_4DD4_

+:
  jp LABEL_2961_

LABEL_59A4_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, (_RAM_DD0A_)
  cp $07
  jr z, +
  ld a, (_RAM_DD0B_)
  or a
  jr z, LABEL_59FC_
  cp $06
  jr z, LABEL_59FC_
+:ret

LABEL_59BC_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  JrNzRet +
  ld a, (_RAM_DD0A_)
  or a
  jp z, LABEL_59FC_
  cp $06
  jp z, LABEL_59FC_
+:ret

++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  ret nz
LABEL_59DC_:
  ld a, (ix+10)
  and $3F
  cp $1A
  ret z
  JumpToPagedFunction LABEL_1BF17_

LABEL_59EF_:
  ld a, (ix+30)
  cp $07
  jr z, LABEL_5A39_
  ld a, (ix+31)
  or a
  JrNzRet +
LABEL_59FC_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, SFX_03_Crash
  ld (_RAM_D974_SFXTrigger_Player2), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D96C_), hl
  call LABEL_51CF_
  ld hl, (_RAM_D59F_)
  ld (ix+0), l
  ld (ix+1), h
  ld hl, (_RAM_D5A1_)
  ld (ix+2), l
  ld (ix+3), h
  xor a
  ld (ix+11), a
  ld (ix+15), a
  ld (ix+16), a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DB7E_), a
  ld (_RAM_DB7F_), a
+:ret

LABEL_5A39_:
  ld a, (ix+20)
  or a
  JrNzRet _LABEL_5A87_ret
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24EE_
  jp ++

+:
  ld hl, DATA_24CE_
++:
  ld a, (_RAM_D5D0_Player2Handicap)
  ld c, a
  ld d, $00
  ld a, (ix+11)
  add a, c
  ld e, a
  add hl, de
  ld a, (hl)
  ld (ix+36), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24FE_
  jp ++

+:
  ld hl, DATA_24DE_
++:
  add hl, de
  ld a, (hl)
  ld (ix+37), a
  ld a, $02
  ld (ix+38), a
LABEL_5A77_:
  ld a, $01
  ld (ix+20), a
  ld a, (ix+21)
  or a
  JrZRet _LABEL_5A87_ret
  ld a, SFX_02_HitGround
  ld (_RAM_D974_SFXTrigger_Player2), a
_LABEL_5A87_ret:
  ret

LABEL_5A88_:
  ld ix, _RAM_DCAB_CarData_Green
  call +
  ld ix, _RAM_DCEC_CarData_Blue
  call +
  ld ix, _RAM_DD2D_CarData_Yellow
+:
  ld d, $00
  ld a, (ix+20)
  or a
  JpZRet _LABEL_5B77_ret
  ld hl, DATA_1B232_SinTable
  ld e, a
  add hl, de
  ld a, :DATA_1B232_SinTable
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
  ld (_RAM_DEF5_), a
  ld a, (ix+36)
  ld (_RAM_DEF4_), a
  call LABEL_1B94_
  ld a, (ix+39)
  ld e, a
  ld a, (ix+40)
  ld d, a
  ld a, (_RAM_DEF2_)
  ld l, a
  ld a, (ix+17)
  add a, l
  add a, $04
  ld (de), a
  ld a, e
  add a, $04
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ld a, (ix+18)
  add a, l
  add a, $04
  ld (de), a
  ld a, e
  add a, $04
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ld a, (ix+21)
  or a
  jr z, +
  ld a, $01
  ld (de), a
  ld (_RAM_DF8A_), de
+:
  ld a, b
  ld (_RAM_DEF5_), a
  ld a, (ix+36)
  and $FC
  rr a
  rr a
  ld (_RAM_DEF4_), a
  call LABEL_1B94_
  ld d, $00
  ld a, (_RAM_DEF2_)
  ld e, a
  ld a, (ix+0)
  ld l, a
  ld a, (ix+1)
  ld h, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+41), a
  ld a, h
  ld (ix+42), a
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+43), a
  ld a, h
  ld (ix+44), a
  ld a, (ix+37)
  ld l, a
  ld a, (ix+20)
  add a, l
  ld (ix+20), a
  cp $82
  JrCRet _LABEL_5B77_ret
  ld a, (ix+21)
  or a
  jr z, +
  ld a, SFX_02_HitGround
  ld (_RAM_D974_SFXTrigger_Player2), a
+:
  xor a
  ld (ix+20), a
  ld (ix+51), a
  ld (_RAM_D5D9_), a
  ld de, (_RAM_DF8A_)
  ld (de), a
  ld a, (ix+36)
  cp $1E
  jr c, +
  cp $60
  jr c, ++
  jp +++

+:
  ld a, (ix+38)
  cp $02
  JrNzRet _LABEL_5B77_ret
  ; Nothing happens!
  ret

_LABEL_5B77_ret:
  ret

; Data from 5B78 to 5B7F (8 bytes)
; Unreachable code?
.db $3E $8E $32 $00 $80 $C3 $03 $A0

++:
  ld a, $0A
  ld (ix+36), a
  ld a, $0C
  ld (ix+37), a
  jp LABEL_5A77_

+++:
  ld a, $20
  ld (ix+36), a
  ld a, $08
  ld (ix+37), a
  jp LABEL_5A77_

LABEL_5B9A_:
  ld a, (ix+20)
  or a
  jr z, +
  ret

+:
  ld a, (ix+51)
  or a
  JpNzRet _LABEL_5E24_ret
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jp z, LABEL_5CFC_
  cp $01
  jp z, LABEL_5CAF_
  ld a, (ix+59)
  and $10
  jp nz, LABEL_4DD4_
  ld a, (ix+60)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (ix+10)
  and $3F
  cp $3A
  jp nz, LABEL_4DD4_
  jp +++

+:
  ld a, (ix+10)
  and $3F
  cp $3A
  jp nz, LABEL_4DD4_
  jp LABEL_5C31_

++:
  ld a, (ix+10)
  and $3F
  cp $1D
  jp z, LABEL_5C70_
  cp $1E
  jp nz, LABEL_4DD4_
  jp LABEL_5C70_

+++:
  xor a
  ld (ix+60), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+53), $88
  ld (ix+54), $0B
  ld (ix+55), $88
  ld (ix+56), $0B
  jp ++

+:
  ld (ix+53), $B0
  ld (ix+54), $0B
  ld (ix+55), $B0
  ld (ix+56), $0B
++:
  ld a, $0E
  ld (ix+52), a
  ld a, $4D
  ld (ix+51), a
  ld a, $01
  ld (ix+57), a
  jp LABEL_5D4A_

LABEL_5C31_:
  ld a, $02
  ld (ix+60), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+53), $40
  ld (ix+54), $08
  ld (ix+55), $58
  ld (ix+56), $06
  jp ++

+:
  ld (ix+53), $68
  ld (ix+54), $08
  ld (ix+55), $80
  ld (ix+56), $06
++:
  ld a, $04
  ld (ix+52), a
  ld a, $4E
  ld (ix+51), a
  xor a
  ld (ix+57), a
  jp LABEL_5D4A_

LABEL_5C70_:
  ld a, $01
  ld (ix+60), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+53), $08
  ld (ix+54), $07
  ld (ix+55), $80
  ld (ix+56), $01
  jp ++

+:
  ld (ix+53), $30
  ld (ix+54), $07
  ld (ix+55), $A8
  ld (ix+56), $01
++:
  ld a, $0A
  ld (ix+52), a
  ld a, $60
  ld (ix+51), a
  xor a
  ld (ix+57), a
  jp LABEL_5D4A_

LABEL_5CAF_:
  ld a, (ix+59)
  and $10
  jp nz, LABEL_4DD4_
  ld a, (ix+10)
  and $3F
  cp $39
  jp nz, LABEL_4DD4_
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+53), $50
  ld (ix+54), $01
  ld (ix+55), $18
  ld (ix+56), $01
  jp ++

+:
  ld (ix+53), $78
  ld (ix+54), $01
  ld (ix+55), $40
  ld (ix+56), $01
++:
  ld a, $06
  ld (ix+52), a
  ld a, $23
  ld (ix+51), a
  ld a, $01
  ld (ix+57), a
  jp LABEL_5D4A_

LABEL_5CFC_:
  ld a, (ix+59)
  and $10
  jp nz, LABEL_4DD4_
  ld a, (ix+10)
  and $3F
  cp $34
  jr z, +
  cp $35
  jp nz, LABEL_4DD4_
+:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+53), $68
  ld (ix+54), $06
  ld (ix+55), $38
  ld (ix+56), $05
  jp ++

+:
  ld (ix+53), $90
  ld (ix+54), $06
  ld (ix+55), $60
  ld (ix+56), $05
++:
  ld a, $0C
  ld (ix+52), a
  ld a, $1D
  ld (ix+51), a
  ld a, $01
  ld (ix+57), a
LABEL_5D4A_:
  ld a, (ix+46)
  or a
  JpNzRet _LABEL_5E24_ret
  ld a, (ix+45)
  or a
  jr z, LABEL_5DAD_
  cp $01
  jr z, +
  xor a
  ld (_RAM_DE69_), a
  ld (_RAM_DE38_), a
  ld a, $03
  ld (_RAM_DF5C_), a
  jp LABEL_5DB9_

+:
  xor a
  ld (_RAM_DE68_), a
  ld (_RAM_DE35_), a
  ld a, $03
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_5DB9_
  xor a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DCFB_), a
  ld (_RAM_DCFC_), a
  ld (_RAM_DB82_), a
  ld (_RAM_DB83_), a
  ld a, SFX_09_EnterPoolTableHole
  ld (_RAM_D974_SFXTrigger_Player2), a
  ld a, (_RAM_DF56_)
  ld b, a
  ld a, (_RAM_DF57_)
  or b
  jp nz, LABEL_5DB9_
  ld hl, $0110
  ld (_RAM_DF56_), hl
  ld a, $01
  ld (_RAM_D5C6_), a
  jp LABEL_5DB9_

LABEL_5DAD_:
  xor a
  ld (_RAM_DE67_), a
  ld (_RAM_DE32_), a
  ld a, CarState_3_Falling
  ld (_RAM_DF5A_CarState3), a
LABEL_5DB9_:
  ld a, $01
  ld (ix+46), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5D9_), a
+:
  xor a
  ld (ix+11), a
  ld (ix+20), a
  ld a, (ix+53)
  ld (_RAM_DEF1_), a
  ld a, (ix+54)
  ld (_RAM_DEF2_), a
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0070
  jp ++

+:
  ld de, $004C
++:
  ld hl, (_RAM_DEF1_)
  or a
  sbc hl, de
  ld a, l
  ld (ix+53), a
  ld a, h
  ld (ix+54), a
  ld a, (ix+55)
  ld (_RAM_DEF1_), a
  ld a, (ix+56)
  ld (_RAM_DEF2_), a
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0060
  jp ++

+:
  ld de, $0038
++:
  ld hl, (_RAM_DEF1_)
  or a
  sbc hl, de
  ld a, l
  ld (ix+55), a
  ld a, h
  ld (ix+56), a
_LABEL_5E24_ret:
  ret

LABEL_5E25_:
  ld a, (_RAM_DCF6_)
  and $3F
  cp $16
  jp z, LABEL_59FC_
  cp $2A
  jp z, LABEL_59FC_
  cp $3F
  jp z, LABEL_59FC_
  ret

LABEL_5E3A_:
  call LABEL_51B3_
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrZRet +
  xor a
  ld (_RAM_DCC1_), a
  ld (_RAM_DCC2_), a
  ld (_RAM_DD02_), a
  ld (_RAM_DD03_), a
  ld (_RAM_DD43_), a
  ld (_RAM_DD44_), a
  call LABEL_5F5E_
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrZRet +
  call ++
  call LABEL_60AE_
  call LABEL_619B_
  call LABEL_629A_
  jp LABEL_6394_

+:ret

++:
  ld ix, _RAM_DCAB_CarData_Green
  ld bc, $0000
  ld a, (_RAM_DCC0_)
  cp $01
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DE8C_)
  or a
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DF58_)
  or a
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DCD9_)
  or a
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DCBD_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_5F52_ret
  ld a, (_RAM_DCBC_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  JpNcRet _LABEL_5F52_ret
  ld a, $01
  cp b
  jr z, +
  call LABEL_1B0C_
  jp ++

+:
  call LABEL_1B2F_
++:
  ld a, $01
  cp c
  jr z, +
  call LABEL_1B50_
  jp ++

+:
  call LABEL_1B73_
++:
  call LABEL_6571_
  ld a, (_RAM_DE32_)
  ld l, a
  ld a, (_RAM_DE92_EngineVelocity)
  cp l
  jr c, ++
  ld d, a
  ld a, (_RAM_DC4A_Cheat_ExtraLives)
  or a
  jr z, +
  ld d, $0D
+:
  ld a, d
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE32_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE31_), a
++:
  ld a, (_RAM_DE2F_)
  ld l, a
  ld a, (_RAM_DCB6_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE2F_), a
  ld a, (_RAM_DCB8_)
  ld (_RAM_DE2E_), a
  ld a, $06
  ld (_RAM_DEB3_Player1AccelerationDelayCounter), a
++:
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DE92_EngineVelocity)
  ld l, a
  ld a, (_RAM_DCB6_)
  sub l
  jr nc, +
  xor $FF
  add a, $01
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE32_), a
  call LABEL_2934_BehaviourF
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCB6_), a
  ld (_RAM_DE92_EngineVelocity), a
_LABEL_5F52_ret:
  ret

+++:
  xor a
  ld (_RAM_DE32_), a
  ld ix, _RAM_DCAB_CarData_Green
  jp LABEL_2961_

LABEL_5F5E_:
  ld ix, _RAM_DCEC_CarData_Blue
  ld bc, $0000
  ld a, (_RAM_DD01_)
  cp $01
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DE8C_)
  or a
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DF58_)
  or a
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DD1A_)
  or a
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DCFE_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_609C_ret
  ld a, (_RAM_DCFD_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  JpNcRet _LABEL_609C_ret
  ld a, $01
  cp b
  jr z, +
  call LABEL_1B0C_
  call LABEL_1AD8_
  jp ++

+:
  call LABEL_1B2F_
  call LABEL_1AC8_
++:
  ld a, $01
  cp c
  jr z, +
  call LABEL_1B50_
  call LABEL_1AFA_
  jp ++

+:
  call LABEL_1B73_
  call LABEL_1AE7_
++:
  call LABEL_6571_
  ld a, (_RAM_DE35_)
  ld l, a
  ld a, (_RAM_DE92_EngineVelocity)
  cp l
  jr c, +++
  ld d, a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC4A_Cheat_ExtraLives)
  or a
  jr z, +
  ld a, $0D
  jr ++

+:
  ld a, d
  ld d, a
  ld a, (_RAM_DEB5_)
  or a
  jr z, +
  ld a, (_RAM_DF0F_)
  ld d, a
+:
  ld a, d
  cp $02
  jr nc, ++
  ld a, $02
++:
  ld (_RAM_DE35_), a
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ld a, (_RAM_D5A3_)
  jp ++

+:
  ld a, (_RAM_DE90_CarDirection)
++:
  ld (_RAM_DE34_), a
+++:
  ld a, (_RAM_DE2F_)
  ld l, a
  ld a, (_RAM_DCF7_)
  cp l
  jr c, +++
  ld c, a
  ld a, (_RAM_DEB5_)
  or a
  jr z, +
  ld a, c
  srl a
  srl a
  ld c, a
+:
  ld a, c
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE2F_), a
  ld a, (_RAM_D5A5_)
  or a
  jr z, +
  ld a, (_RAM_DE56_)
  jp ++

+:
  ld a, (_RAM_DCF9_)
++:
  ld (_RAM_DE2E_), a
  ld a, $06
  ld (_RAM_DEB3_Player1AccelerationDelayCounter), a
+++:
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, LABEL_609D_
LABEL_6054_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DE92_EngineVelocity)
  ld l, a
  ld a, (_RAM_DCF7_)
  sub l
  jr nc, +
  xor $FF
  add a, $01
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE35_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  ld (_RAM_D5BE_), a
  call LABEL_29BC_Behaviour1_FallToFloor
  call LABEL_4DD4_
  jp ++

+:
  call LABEL_2934_BehaviourF
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCF7_), a
  ld (_RAM_DE92_EngineVelocity), a
_LABEL_609C_ret:
  ret

LABEL_609D_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_6054_
  xor a
  ld (_RAM_DE35_), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_2961_

LABEL_60AE_:
  ld ix, _RAM_DD2D_CarData_Yellow
  ld bc, $0000
  ld a, (_RAM_DD42_)
  cp $01
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DE8C_)
  or a
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DF58_)
  or a
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DD5B_)
  or a
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DD3F_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_618F_ret
  ld a, (_RAM_DD3E_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  JpNcRet _LABEL_618F_ret
  ld a, $01
  cp b
  jr z, +
  call LABEL_1B0C_
  jp ++

+:
  call LABEL_1B2F_
++:
  ld a, $01
  cp c
  jr z, +
  call LABEL_1B50_
  jp ++

+:
  call LABEL_1B73_
++:
  call LABEL_6571_
  ld a, (_RAM_DE38_)
  ld l, a
  ld a, (_RAM_DE92_EngineVelocity)
  cp l
  jr c, ++
  ld d, a
  ld a, (_RAM_DC4A_Cheat_ExtraLives)
  or a
  jr z, +
  ld d, $0D
+:
  ld a, d
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE38_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE37_), a
++:
  ld a, (_RAM_DE2F_)
  ld l, a
  ld a, (_RAM_DD38_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE2F_), a
  ld a, (_RAM_DD3A_)
  ld (_RAM_DE2E_), a
  ld a, $06
  ld (_RAM_DEB3_Player1AccelerationDelayCounter), a
++:
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DE92_EngineVelocity)
  ld l, a
  ld a, (_RAM_DD38_)
  sub l
  jr nc, +
  xor $FF
  add a, $01
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE38_), a
  call LABEL_2934_BehaviourF
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DD38_), a
  ld (_RAM_DE92_EngineVelocity), a
_LABEL_618F_ret:
  ret

+++:
  xor a
  ld (_RAM_DE38_), a
  ld ix, _RAM_DD2D_CarData_Yellow
  jp LABEL_2961_

LABEL_619B_:
  ld bc, $0001
  ld a, (_RAM_DCC0_)
  cp $01
  jp nz, LABEL_6295_
  ld a, (_RAM_DD01_)
  cp $01
  jp nz, LABEL_6295_
  ld a, (_RAM_DCD9_)
  or a
  jp nz, LABEL_6295_
  ld a, (_RAM_DD1A_)
  or a
  jp nz, LABEL_6295_
  ld a, (_RAM_DCBD_)
  ld l, a
  ld a, (_RAM_DCFE_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, LABEL_6295_
  ld a, (_RAM_DCBC_)
  ld l, a
  ld a, (_RAM_DCFD_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  jp nc, LABEL_6295_
  ld a, $01
  cp b
  jr z, +
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B0C_
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B2F_
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B2F_
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B0C_
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B50_
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B73_
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B73_
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B50_
++:
  call LABEL_6582_
  ld a, (_RAM_DE32_)
  ld l, a
  ld a, (_RAM_DCF7_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE32_), a
  ld a, (_RAM_DCF9_)
  ld (_RAM_DE31_), a
++:
  ld a, (_RAM_DE35_)
  ld l, a
  ld a, (_RAM_DCB6_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE35_), a
  ld a, (_RAM_DCB8_)
  ld (_RAM_DE34_), a
++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DCF7_)
  ld l, a
  ld a, (_RAM_DCB6_)
  sub l
  jr nc, +
  xor $FF
  add a, $01
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE35_), a
  ld (_RAM_DE32_), a
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_2961_
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCB6_), a
  ld (_RAM_DCF7_), a
  ret

LABEL_6295_:
  xor a
  ld (_RAM_DE3D_), a
  ret

LABEL_629A_:
  ld bc, $0000
  ld a, (_RAM_DCC0_)
  cp $01
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DD42_)
  cp $01
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DCD9_)
  or a
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DD5B_)
  or a
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DCBD_)
  ld l, a
  ld a, (_RAM_DD3F_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_6393_ret
  ld a, (_RAM_DCBC_)
  ld l, a
  ld a, (_RAM_DD3E_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  JpNcRet _LABEL_6393_ret
  ld a, $01
  cp b
  jr z, +
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B0C_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B2F_
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B2F_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B0C_
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B50_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B73_
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B73_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B50_
++:
  call LABEL_6582_
  ld a, (_RAM_DE32_)
  ld l, a
  ld a, (_RAM_DD38_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE32_), a
  ld a, (_RAM_DD3A_)
  ld (_RAM_DE31_), a
++:
  ld a, (_RAM_DE38_)
  ld l, a
  ld a, (_RAM_DCB6_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE38_), a
  ld a, (_RAM_DCB8_)
  ld (_RAM_DE37_), a
++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DD38_)
  ld l, a
  ld a, (_RAM_DCB6_)
  sub l
  jr nc, +
  xor $FF
  add a, $01
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE38_), a
  ld (_RAM_DE32_), a
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_2961_
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCB6_), a
  ld (_RAM_DD38_), a
_LABEL_6393_ret:
  ret

LABEL_6394_:
  ld bc, $0000
  ld a, (_RAM_DD01_)
  cp $01
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DD42_)
  cp $01
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DD1A_)
  or a
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DD5B_)
  or a
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DCFE_)
  ld l, a
  ld a, (_RAM_DD3F_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_648D_ret
  ld a, (_RAM_DCFD_)
  ld l, a
  ld a, (_RAM_DD3E_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  JpNcRet _LABEL_648D_ret
  ld a, $01
  cp b
  jr z, +
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B0C_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B2F_
  jp ++

+:
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B2F_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B0C_
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B50_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B73_
  jp ++

+:
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B73_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B50_
++:
  call LABEL_6582_
  ld a, (_RAM_DE35_)
  ld l, a
  ld a, (_RAM_DD38_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE35_), a
  ld a, (_RAM_DD3A_)
  ld (_RAM_DE34_), a
++:
  ld a, (_RAM_DE38_)
  ld l, a
  ld a, (_RAM_DCF7_)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE38_), a
  ld a, (_RAM_DCF9_)
  ld (_RAM_DE37_), a
++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DCF7_)
  ld l, a
  ld a, (_RAM_DD38_)
  sub l
  jr nc, +
  xor $FF
  add a, $01
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE35_), a
  ld (_RAM_DE38_), a
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_2961_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCF7_), a
  ld (_RAM_DD38_), a
_LABEL_648D_ret:
  ret

LABEL_648E_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ld ix, $DCAB
  ld iy, _RAM_DE31_
  call ++
  ld ix, $DCEC
  ld iy, _RAM_DE34_
  call ++
  ld ix, $DD2D
  ld iy, _RAM_DE37_
  jp ++

+:
  ld ix, _RAM_DCEC_CarData_Blue
  ld iy, _RAM_DE34_
++:
  JumpToPagedFunction LABEL_1BCE2_

LABEL_64C9_:
  ld a, (_RAM_DBA4_)
  cp $F3
  jr nc, +
  cp $03
  jr c, +
  ld a, (_RAM_DBA5_)
  cp $E8
  JrCRet ++
  cp $F0
  JrNcRet ++
+:ld a, $01
  ld (_RAM_D946_), a
++:ret

LABEL_64E5_SetDrawingParameters_PartialMetatile:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, @GG
  
@SMS:
  ; 8x12, skip 4
  ld a, 8
  ld (_RAM_DECF_RectangleWidth), a
  ld a, 4
  ld (_RAM_DECE_RectRowSkip), a
  ld a, 12
  ld (_RAM_DEC5_RectangleHeight), a
  ret

@GG:
  ; 9x12, skip 3
  ld a, 9
  ld (_RAM_DECF_RectangleWidth), a
  ld a, 3
  ld (_RAM_DECE_RectRowSkip), a
  ld a, 12
  ld (_RAM_DEC5_RectangleHeight), a
  ret

; Data from 650C to 653F (52 bytes)
DATA_650C_SoundInitialisationData:
; TODO: could label with the meanings/RAM labels
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $E8
.db $03 $03 $0A $00 $15 $0B $15 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $E8 $03 $03 $00 $00 $15 $0B $15 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $FF $07 $08
DATA_650C_SoundInitialisationData_End:

LABEL_6540_:
  ld a, (_RAM_D948_)
  inc a
  cp $FF
  jr nz, +
  dec a
+:
  ld (_RAM_D948_), a
  ld a, (_RAM_D949_)
  inc a
  cp $FF
  jr nz, +
  dec a
+:
  ld (_RAM_D949_), a
  ld a, (_RAM_D94A_)
  inc a
  cp $FF
  jr nz, +
  dec a
+:
  ld (_RAM_D94A_), a
  ld a, (_RAM_D5BC_)
  inc a
  cp $FF
  jr nz, +
  dec a
+:
  ld (_RAM_D5BC_), a
  ret

LABEL_6571_:
  ld a, (_RAM_D948_)
  cp $08
  JrCRet +
  xor a
  ld (_RAM_D948_), a
  ld a, SFX_0D
  ld (_RAM_D963_SFXTrigger_Player1), a
+:ret

LABEL_6582_:
  ld a, (_RAM_D949_)
  cp $08
  JrCRet +
  xor a
  ld (_RAM_D949_), a
  ld a, SFX_0D
  ld (_RAM_D974_SFXTrigger_Player2), a
+:ret

LABEL_6593_:
  ld a, (_RAM_D94A_)
  cp $04
  JrCRet _LABEL_65C2_ret
  ld a, (_RAM_DF00_)
  or a
  JrNzRet _LABEL_65C2_ret
  ld a, (_RAM_DE92_EngineVelocity)
  cp $06
  JrCRet _LABEL_65C2_ret
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrZRet _LABEL_65C2_ret
--:
  xor a
  ld (_RAM_D94A_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_3_TurboWheels ; Alternative skid sound for these two
  jr z, +
  cp TT_5_Warriors
  jr z, +
  ld a, SFX_0F_Skid1
-:
  ld (_RAM_D963_SFXTrigger_Player1), a
_LABEL_65C2_ret:
  ret

+:
  ld a, SFX_10_Skid2
  jr -

LABEL_65C7_:
  ld a, (_RAM_D94A_)
  cp $04
  JrCRet _LABEL_65C2_ret
  jr --

LABEL_65D0_BehaviourE:
  ld a, (_RAM_DF00_)
  or a
  JrNzRet +
  ld a, (_RAM_DF58_)
  or a
  JrNzRet +
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  xor a
  ld (_RAM_D95E_), a
  ld a, SFX_08
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, CarState_3_Falling
  ld (_RAM_DF59_CarState), a
  ld a, $01
  ld (_RAM_DF58_), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld a, $03
  ld (_RAM_DE92_EngineVelocity), a
  xor a
  ld (_RAM_DF73_), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  jp LABEL_71C7_

+:ret

LABEL_6611_Tanks:
  JumpToPagedFunction LABEL_37A75_

LABEL_661C_:
  JumpToPagedFunction LABEL_37C45_

LABEL_6627_:
  JumpToPagedFunction LABEL_37C4F_

LABEL_6632_:
  JumpToPagedFunction LABEL_37C59_

LABEL_663D_InitialisePlugholeTiles:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr z, + ; Only for powerboats...
  ret

+:ld a, :DATA_35708_PlugholeTilesHighBitplanePart1
  ld (PAGING_REGISTER), a
  ld hl, DATA_35708_PlugholeTilesHighBitplanePart1 ; Tile data
  ld de, $5B63        ; Tile $db bitplane 3
  ld bc, $0068        ; 13 tiles
  call _f             ; Emit it
  ld hl, DATA_35770_PlugholeTilesHighBitplanePart2 ; Then some more
  ld de, $5DC3        ; Tile $ee bitplane 3
  ld bc, $0088        ; 17 tiles
  ; Fall through and ret
__:
  ld a, e         ; Set VRAM address to de
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ld a, (hl)      ; Copy a byte
  out (PORT_VDP_DATA), a
  inc hl
  ld a, e         ; move forward by a bitplane
  add a, $04
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  dec bc          ; decrement and loop
  ld a, b
  or c
  jr nz, _b
  ret

LABEL_6677_:
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_DE2F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_DE2F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_
  ld a, (_RAM_DE2E_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF0B_), a
  ld hl, DATA_40E5_Sign_
  ld a, (_RAM_DE2E_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF0D_), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF0D_), a
++:
  ld hl, DATA_3FD3_
  ld a, (_RAM_DE2E_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF0C_), a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_DE2E_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF0E_), a
  ret

+:
  ld a, $01
  ld (_RAM_DF0E_), a
  ret

LABEL_6704_LoadHUDTiles:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrZRet _LABEL_6755_ret
  ; Normal cars only
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ; Head to head
  ld a, :DATA_35D2D_HeadToHeadHUDTiles
  ld (PAGING_REGISTER), a
  ld a, $80 ; Tile $194
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  ld bc, $00A0 ; 20 tiles * 8 rows
  ld hl, DATA_35D2D_HeadToHeadHUDTiles
-:
  push bc
    ld b, $03 ; Emit 3bpp tile data
    ld c, PORT_VDP_DATA
    otir
    xor a
    out (PORT_VDP_DATA), a
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

+:; Head to head
  ld a, :DATA_30A68_ChallengeHUDTiles ;$0C
  ld (PAGING_REGISTER), a
  ld a, $80 ; Tile $194
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  ld bc, $00A0 ; 20 tiles * 8 rows
  ld hl, DATA_30A68_ChallengeHUDTiles
-:
  push bc
    ld b, $04 ; Emit four bytes = 1 row
    ld c, PORT_VDP_DATA
    otir
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
_LABEL_6755_ret:
  ret

LABEL_6756_:
  xor a
  ld (_RAM_DEBA_), a
  ld (_RAM_DEBB_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_67AB_
  ld a, (_RAM_D5C5_)
  cp $02
  JpZRet _LABEL_6895_ret
  ld a, (_RAM_DE8C_)
  or a
  jr z, +
  ld a, (_RAM_DD1F_)
  or a
  JpZRet _LABEL_6895_ret
  ld a, (_RAM_DF59_CarState)
  or a
  JpNzRet _LABEL_6895_ret
  ld a, (_RAM_DF5B_)
  or a
  JpNzRet _LABEL_6895_ret
  ld a, $01
  ld (_RAM_D5C5_), a
  ld hl, $0000
  ld (_RAM_DF56_), hl
  jp ++

+:
  ld a, (_RAM_DD1F_)
  or a
  jr z, +
  JpRet _LABEL_6895_ret

+:
  ld a, (_RAM_D945_)
  cp $02
  JpZRet _LABEL_6895_ret
  ld a, (_RAM_DF81_)
  or a
  jr nz, ++
LABEL_67AB_:
  ld a, (_RAM_DF58_)
  or a
  jp z, +
  ld a, (_RAM_DF59_CarState)
  or a
  jp nz, +
  jp ++

+:
  ld a, (_RAM_DF59_CarState)
  cp CarState_ff
  JpNzRet _LABEL_6895_ret
  ld a, (_RAM_DF5B_)
  cp $FF
  jr z, ++
  JpRet _LABEL_6895_ret

++:
  ld a, (_RAM_DBAA_)
  ld l, a
  ld a, (_RAM_DBAE_)
  cp l
  jr z, +
  jr nc, +++
  jp ++

+:
  ld a, (_RAM_DBA9_)
  ld l, a
  ld a, (_RAM_DBAD_)
  cp l
  jr z, +++++
  jr nc, +++
++:
  xor a
  ld (_RAM_DEB0_), a
  jp ++++

+++:
  ld a, $01
  ld (_RAM_DEB0_), a
++++:
  ld a, $01
  ld (_RAM_DEBB_), a
  ld a, (_RAM_DED3_HScrollValue)
  and $03
  jr z, +
  jp ++

+:
  ld a, $04
++:
  ld (_RAM_DEAF_), a
  jp ++++++

+++++:
  xor a
  ld (_RAM_DEBB_), a
  ld (_RAM_DEAF_), a
++++++:
  ld a, (_RAM_DBAC_)
  cp $FF
  jr z, +++
  ld l, a
  ld a, (_RAM_DBB0_)
  cp l
  jr z, +
  jr nc, +++
  jp ++

+:
  ld a, (_RAM_DBAB_)
  ld l, a
  ld a, (_RAM_DBAF_)
  cp l
  jr z, +++++
  jr nc, +++
++:
  xor a
  ld (_RAM_DEB2_), a
  jp ++++

+++:
  ld a, $01
  ld (_RAM_DEB2_), a
++++:
  ld a, $01
  ld (_RAM_DEBA_), a
  ld a, (_RAM_DED4_VScrollValue)
  and $03
  jr z, +
  jp ++

+:
  ld a, $04
++:
  ld (_RAM_DEB1_VScrollDelta), a
  jp ++++++

+++++:
  xor a
  ld (_RAM_DEBA_), a
  ld (_RAM_DEB1_VScrollDelta), a
++++++:
  ld a, (_RAM_DEBA_)
  or a
  JrNzRet _LABEL_6895_ret
  ld a, (_RAM_DEBB_)
  or a
  JrNzRet _LABEL_6895_ret
  ld a, (_RAM_DE8C_)
  cp $01
  jp z, LABEL_69DB_
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ; Not head to head
  ld a, CarState_2_Respawning
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_D946_), a
  ld a, SFX_16_Respawn
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, $74
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $64
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
_LABEL_6895_ret:
  ret

+:
  xor a
  ld (_RAM_DF81_), a
  ld a, (_RAM_DF7F_)
  or a
  jp nz, LABEL_693F_
  ld a, $01
  ld (_RAM_DF7F_), a
  ld a, SFX_13_HeadToHeadWinPoint
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, $00
  ld (_RAM_D95E_), a
  ld (_RAM_D96F_), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  ld (_RAM_D96C_), hl
  ld (_RAM_D58A_), hl
  ld (_RAM_D58E_), hl
  ld (_RAM_D590_), hl
  ld (_RAM_D58C_), hl
  ld a, (_RAM_DBA4_)
  ld (_RAM_DF06_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DF07_), a
  ld a, (_RAM_D5B0_)
  or a
  jr nz, LABEL_6947_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ret

+:
  ld a, (_RAM_D5CB_)
  or a
  jp nz, LABEL_7AC4_
  ld a, $01
  ld (_RAM_DF00_), a
  ld a, $78
  ld (_RAM_DF0A_), a
  ld a, $03
  ld (_RAM_DF02_), a
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_)
  add a, $01
  ld (_RAM_D583_), a
+:
  xor a
  ld (_RAM_DCEE_), a
  ld (_RAM_DCEF_), a
  jp LABEL_B2B_

++:
  ld a, (_RAM_D5CB_)
  or a
  jp nz, LABEL_7AAF_
  ld a, $01
  ld (_RAM_DD00_), a
  ld a, $78
  ld (_RAM_DD10_), a
  ld a, $03
  ld (_RAM_DD11_), a
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_)
  sub $01
  ld (_RAM_D583_), a
+:
  xor a
  ld (_RAM_DBA5_), a
  jp LABEL_B13_

LABEL_693F_:
  ld a, (_RAM_DF7F_)
  cp $05
  JpNzRet _LABEL_6895_ret

LABEL_6947_:
  xor a
  ld (_RAM_D945_), a
  ld (_RAM_D940_), a
  ld (_RAM_D5B0_), a
  ld (_RAM_DF5D_), a
  ld (_RAM_DF5F_), a
  ld (_RAM_DF61_), a
  ld (_RAM_DF63_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DF7D_), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE35_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DF0F_), a
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld (_RAM_DF7F_), a
  ld (_RAM_DB80_), a
  ld (_RAM_DB81_), a
  ld (_RAM_DB82_), a
  ld (_RAM_DB83_), a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DB7E_), a
  ld (_RAM_DB7F_), a
  ld (_RAM_DCFB_), a
  ld (_RAM_DCFC_), a
  ld (_RAM_DF79_CurrentCombinedByte), a
  ld (_RAM_DD08_), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld a, $01
  ld (_RAM_D582_), a
  ld a, $02
  ld (_RAM_DF5B_), a
  ld hl, (_RAM_DBA9_)
  ld e, $74
  ld d, $00
  add hl, de
  ld (_RAM_DCEC_CarData_Blue), hl
  ld hl, (_RAM_DBAB_)
  ld e, $64
  ld d, $00
  add hl, de
  ld (_RAM_DCEE_), hl
  ld a, CarState_2_Respawning
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_D946_), a
  ld a, SFX_16_Respawn
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, $74
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $64
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  ret

LABEL_69DB_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_6A11_
  ld a, (_RAM_D5C5_)
  cp $02
  JpZRet _LABEL_6A6B_ret
  ld a, (_RAM_D5C6_)
  or a
  jr z, +
  ld a, $02
  jr ++

+:
  ld a, $10
++:
  ld (_RAM_DD1F_), a
  xor a
  ld (_RAM_DD25_), a
  ld a, $02
  ld (_RAM_D5C5_), a
  ld a, (_RAM_D5C6_)
  or a
  jr z, LABEL_6A11_
  ld a, $10
  ld (_RAM_D5C7_), a
.ifdef JUMP_TO_RET
  call LABEL_6A4F_
  JrRet _LABEL_6A6B_ret
.else
  TailCall LABEL_6A4F_
.endif

LABEL_6A11_:
  xor a
  ld (_RAM_DF58_), a
  ld (_RAM_DF59_CarState), a ; CarState_0_Normal
  ld hl, 500 ; $01F4
  ld (_RAM_D95B_), hl
  ld (_RAM_D58C_), hl
  ld a, $0A
  ld (_RAM_D95E_), a
  ld a, SFX_0C_LeavePoolTableHole
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, (_RAM_DE8D_)
  ld (_RAM_DE90_CarDirection), a
  ld (_RAM_DE91_CarDirectionPrevious), a
  ld a, $01
  ld (_RAM_DF00_), a
  ld a, $38
  ld (_RAM_DF0A_), a
  ld a, $05
  ld (_RAM_DF02_), a
  ld a, $09
  ld (_RAM_DE92_EngineVelocity), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_6A4F_
  ret

LABEL_6A4F_:
  ld a, $74
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld (_RAM_DF06_), a
  ld (_RAM_DF04_), a
  ld a, $64
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  ld (_RAM_DF07_), a
  ld (_RAM_DF05_), a
_LABEL_6A6B_ret:
  ret

LABEL_6A6C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, (_RAM_D5C5_)
  cp $02
  JrNzRet +
  ld a, (_RAM_D5C7_)
  cp $01
  jr z, ++
  dec a
  ld (_RAM_D5C7_), a
+:ret

++:
  xor a
  ld (_RAM_D5C7_), a
  jp LABEL_6A11_

LABEL_6A8C_:
  JumpToPagedFunction LABEL_36937_

LABEL_6A97_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +++
  ld a, (_RAM_D5C5_)
  cp $02
  jp z, LABEL_6B60_
  ld a, (_RAM_DE8C_)
  or a
  JrNzRet +
  ld a, (_RAM_D5C5_)
  or a
  jr z, ++
+:ret

++:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, +++
  ld a, (_RAM_DF59_CarState)
  cp CarState_ff
  jr z, +
  or a
  jr nz, +++
+:
  call LABEL_71C7_
+++:
  ld a, (_RAM_DCD9_)
  or a
  jp z, LABEL_6B34_
  ld a, (_RAM_DF5A_CarState3)
  or a
  jp nz, LABEL_6B34_
  ; CarState_0_Normal
  ld a, (_RAM_DCDE_)
  or a
  jr nz, +
  ld a, CarState_2_Respawning
  ld (_RAM_DF5A_CarState3), a
  xor a
  ld (_RAM_DCB6_), a
  jp LABEL_7295_

+:
  cp $01
  jr z, +
  sub $01
  ld (_RAM_DCDE_), a
  jp LABEL_6B34_

+:
  ld a, (_RAM_DCE4_)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DCDE_), a
  xor a
  ld (_RAM_DCE4_), a
  jp LABEL_6B34_

+:
  ld hl, (_RAM_DCE0_)
  ld (_RAM_DCAB_CarData_Green), hl
  ld hl, (_RAM_DCE2_)
  ld (_RAM_DCAD_), hl
  xor a
  ld (_RAM_DCD9_), a
  ld (_RAM_DF5A_CarState3), a ; CarState_0_Normal
  ld a, (_RAM_DCDF_)
  ld (_RAM_DCB7_), a
  ld (_RAM_DCB8_), a
  ld a, $01
  ld (_RAM_DCBF_), a
  ld a, $38
  ld (_RAM_DCCF_), a
  ld a, $05
  ld (_RAM_DCD0_), a
  ld a, $09
  ld (_RAM_DCB6_), a
LABEL_6B34_:
  ld a, (_RAM_DD1A_)
  or a
  jp z, LABEL_6BC2_
  ld a, (_RAM_DF5B_)
  or a
  jp nz, LABEL_6BC2_
  ld a, (_RAM_DD1F_)
  or a
  jr nz, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, LABEL_6BC2_
  ld a, $02
  ld (_RAM_DF5B_), a
  xor a
  ld (_RAM_DCF7_), a
  jp LABEL_72CA_

+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_6BC2_
LABEL_6B60_:
  ld a, (_RAM_DD1F_)
  or a
  jr z, LABEL_6BC2_
  ld a, (_RAM_DD1F_)
  cp $01
  jr z, +
  sub $01
  ld (_RAM_DD1F_), a
  jp LABEL_6BC2_

+:
  ld a, (_RAM_DD25_)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DD1F_), a
  xor a
  ld (_RAM_DD25_), a
  jp LABEL_6B34_

+:
  ld hl, (_RAM_DD21_)
  ld (_RAM_DCEC_CarData_Blue), hl
  ld hl, (_RAM_DD23_)
  ld (_RAM_DCEE_), hl
  xor a
  ld (_RAM_DD1A_), a
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DD20_)
  ld (_RAM_DCF8_), a
  ld (_RAM_DCF9_), a
  ld a, $01
  ld (_RAM_DD00_), a
  ld a, $38
  ld (_RAM_DD10_), a
  ld a, $05
  ld (_RAM_DD11_), a
  ld a, $09
  ld (_RAM_DCF7_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_6BC2_
  xor a
  ld (_RAM_DD1F_), a
LABEL_6BC2_:
  ld a, (_RAM_DD5B_)
  or a
  JpZRet +
  ld a, (_RAM_DF5C_)
  or a
  JpNzRet +
  ld a, (_RAM_DD60_)
  or a
  jr nz, ++
  ld a, $02
  ld (_RAM_DF5C_), a
  xor a
  ld (_RAM_DD38_), a
  jp LABEL_7332_

+:ret

++:
  cp $01
  jr z, +
  sub $01
  ld (_RAM_DD60_), a
  ret

+:
  ld a, (_RAM_DD66_)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DD60_), a
  xor a
  ld (_RAM_DD66_), a
  jp LABEL_6B34_

+:
  ld hl, (_RAM_DD62_)
  ld (_RAM_DD2D_CarData_Yellow), hl
  ld hl, (_RAM_DD64_)
  ld (_RAM_DD2F_), hl
  xor a
  ld (_RAM_DD5B_), a
  ld (_RAM_DF5C_), a
  ld a, (_RAM_DD61_)
  ld (_RAM_DD39_), a
  ld (_RAM_DD3A_), a
  ld a, $01
  ld (_RAM_DD41_), a
  ld a, $38
  ld (_RAM_DD51_), a
  ld a, $05
  ld (_RAM_DD52_), a
  ld a, $09
  ld (_RAM_DD38_), a
  ret

; Data from 6C31 to 6C38 (8 bytes)
DATA_6C31_:
.db $0A $0A $0A $0C $09 $0A $0A $06 ; one per track type

LABEL_6C39_:
  ld a, (_RAM_DB97_TrackType)
  ld e, a
  ld d, $00
  ld hl, DATA_6C31_
  add hl, de
  ld a, (hl)
  ld d, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld d, $13
  jr ++

+:
  cp TT_7_RuffTrux
  jr nz, ++
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr nz, ++
  ld d, $05
++:
  ld a, d
  ld (_RAM_D5E0_), a
  ld a, (_RAM_DF69_)
  ld c, a
  ld a, (_RAM_DF65_)
  or a
  jp nz, LABEL_6E00_
  ld a, (_RAM_DF58_)
  or a
  jp nz, LABEL_6E00_
  ld a, (_RAM_DF4F_)
  ld l, a
  ld a, (_RAM_D587_)
  cp $FF
  jp z, LABEL_6D08_
  or a
  jp nz, +
  jp LABEL_6E00_

+:
  cp l
  jp z, LABEL_6E00_
  jr c, +
  sub l
  cp c
  jr nc, ++
-:
  cp d
  jp c, LABEL_6D43_Powerboats
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp z, +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  jp z, LABEL_6E00_
  jp LABEL_6D43_Powerboats

+:
  ld h, a
  ld a, (_RAM_DF68_)
  sub l
  add a, h
  cp c
  jr nc, ++
  jp -

++:
  ld l, a
  ld a, (_RAM_DF68_)
  sub l
  jp -

+++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jp z, LABEL_6D43_Powerboats
  cp TT_4_FormulaOne
  jr nz, LABEL_6D08_
  ; Formula One
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld hl, _LABEL_4B10_
  ld (_RAM_DF53_), hl
  jp +++

+:
  ld hl, _LABEL_4A80_
  ld (_RAM_DF53_), hl
  jp +++

++:
  ld hl, _LABEL_49FA_
  ld (_RAM_DF53_), hl
+++:
  ld a, (_RAM_D587_)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DF53_)
  add hl, de
  ld a, (hl)
  ld c, a
  ld hl, (_RAM_DF53_)
  ld a, (_RAM_DF4F_)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  cp c
  jp nz, LABEL_6E00_

LABEL_6D08_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  jp LABEL_29BC_Behaviour1_FallToFloor

+:
  ld a, CarState_1_Exploding
  ld (_RAM_DF59_CarState), a
  ld (_RAM_DF58_), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  xor a
  ld (_RAM_D95E_), a
  ld a, SFX_05
  ld (_RAM_D963_SFXTrigger_Player1), a
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  call LABEL_71C7_
  jp LABEL_6E00_

LABEL_6D43_Powerboats:
  ld b, $00
  ld a, (_RAM_D587_)
  ld l, a
  ld a, (_RAM_DF4F_)
  sub l
  jr nc, +
  ld b, $01
  xor $FF
  add a, $01
+:
  ld l, a
  ld a, (_RAM_DF68_)
  sub $0A
  cp l
  jr nc, LABEL_6DDB_
  ld a, b
  cp $01
  jr z, LABEL_6DD3_
  xor a
  ld (_RAM_DE51_), a
  ld a, $01
  ld (_RAM_DE52_), a
  ld a, (_RAM_DF24_LapsRemaining)
  sub $01
  ld (_RAM_DF24_LapsRemaining), a
  cp $00
  jr z, +
  ld a, (_RAM_DC55_TrackIndex_Game) ; Qualifying early win?
  cp $00
  jr nz, LABEL_6DDB_
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, LABEL_6DDB_
  ld a, (_RAM_DF2A_Positions.Red)
  cp $00
  jr nz, LABEL_6DDB_
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp nz, LABEL_7AA6_
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ld a, (_RAM_DC55_TrackIndex_Game) ; Track 0 = qualifying
  or a
  jr nz, +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, $01
  ld (_RAM_DC50_Cheat_FasterVehicles), a
+:
  ld a, $01
  ld (_RAM_DF65_), a
  ld a, $F0
  ld (_RAM_DF6A_), a
  ld a, (_RAM_DF25_)
  ld e, a
  ld d, $00
  ld hl, DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF4F_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, LABEL_6DDB_
  call LABEL_1CFF_
  jp LABEL_6DDB_

LABEL_6DD3_:
  ld a, (_RAM_DF24_LapsRemaining)
  add a, $01
  ld (_RAM_DF24_LapsRemaining), a
LABEL_6DDB_:
  ld a, (_RAM_DF65_)
  cp $01
  jr z, LABEL_6E00_
  call LABEL_1CBD_
  and $3F
  ld c, a
  ld hl, _RAM_D900_
  ld b, $00
  add hl, bc
  ld a, (hl)
  and $80
  jr nz, +
  call LABEL_1C98_
+:
  ld a, (_RAM_D587_)
  ld (_RAM_DF4F_), a
  xor a
  ld (_RAM_D589_), a
LABEL_6E00_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JpZRet _LABEL_7171_ret
  ld a, (_RAM_DCC5_)
  cp $00
  jp nz, LABEL_6F10_
  ld a, (_RAM_DF50_)
  ld l, a
  ld a, (_RAM_DCC3_)
  cp $00
  jp z, LABEL_6F10_
  cp l
  jp z, LABEL_6F10_
  ld b, $00
  ld a, (_RAM_DCC3_)
  ld l, a
  ld a, (_RAM_DF50_)
  sub l
  jr nc, +
  ld b, $01
  xor $FF
  add a, $01
+:
  ld l, a
  ld a, (_RAM_DF68_)
  sub $0A
  cp l
  jr nc, LABEL_6E79_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DCC4_)
  sub $01
  ld (_RAM_DCC4_), a
  cp $00
  jr nz, LABEL_6E79_
  ld a, $01
  ld (_RAM_DCC5_), a
  ld a, (_RAM_DF25_)
  ld e, a
  ld d, $00
  ld hl, DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF50_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, LABEL_6E79_
  call LABEL_1CFF_
  jp LABEL_6E79_

+:
  ld a, (_RAM_DCC4_)
  add a, $01
  ld (_RAM_DCC4_), a
LABEL_6E79_:
  ld a, (_RAM_DCC5_)
  cp $01
  jp z, LABEL_6F10_
  ld a, (_RAM_DCB5_)
  and $3F
  ld c, a
  ld hl, _RAM_D900_
  ld b, $00
  add hl, bc
  ld a, (hl)
  and $80
  jr nz, +
  ld a, (_RAM_DCC8_)
  cp $0A
  jr z, +
  call LABEL_7176_
+:
  ld a, (_RAM_DCC3_)
  ld (_RAM_DF50_), a
  xor a
  ld (_RAM_DCC6_), a
  jp LABEL_6F10_

LABEL_6EA9_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jp z, LABEL_6F6D_
  cp TT_4_FormulaOne
  jr nz, LABEL_6EF3_
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $00
  jr z, ++
  cp $01
  jr z, +
  ld hl, $4B10
  ld (_RAM_DF53_), hl
  jp +++

+:
  ld hl, $4A80
  ld (_RAM_DF53_), hl
  jp +++

++:
  ld hl, $49FA
  ld (_RAM_DF53_), hl
+++:
  ld a, (_RAM_DD04_)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DF53_)
  add hl, de
  ld a, (hl)
  ld c, a
  ld hl, (_RAM_DF53_)
  ld a, (_RAM_DF51_)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  cp c
  jp nz, LABEL_6FFF_
LABEL_6EF3_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp z, LABEL_6FFF_
  ld a, (_RAM_DD04_)
  cp $FF
  jr z, +
  ld (_RAM_DF51_), a
+:
  ld a, $01
  ld (_RAM_D5BE_), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_4DD4_

LABEL_6F10_:
  ld a, (_RAM_D5E0_)
  ld d, a
  ld a, (_RAM_DF69_)
  ld c, a
  ld a, (_RAM_DD06_)
  cp $00
  jp nz, LABEL_6FFF_
  ld a, (_RAM_DF51_)
  ld l, a
  ld a, (_RAM_DD04_)
  cp $FF
  jr z, LABEL_6EF3_
  cp $00
  jp z, LABEL_6FFF_
  cp l
  jp z, LABEL_6FFF_
  ld b, a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_6F6D_
  ld a, b
  cp l
  jr c, +
  sub l
  cp c
  jr nc, ++
-:
  cp d
  jp c, LABEL_6F6D_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp z, LABEL_6EA9_
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  jp z, LABEL_6FFF_
  jp LABEL_6F6D_

+:
  ld h, a
  ld a, (_RAM_DF68_)
  sub l
  add a, h
  cp c
  jr nc, ++
  jp -

++:
  ld l, a
  ld a, (_RAM_DF68_)
  sub l
  jp -

LABEL_6F6D_:
  ld b, $00
  ld a, (_RAM_DD04_)
  ld l, a
  ld a, (_RAM_DF51_)
  sub l
  jr nc, +
  ld b, $01
  xor $FF
  add a, $01
+:
  ld l, a
  ld a, (_RAM_DF68_)
  sub $0A
  cp l
  jr nc, LABEL_6FCD_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DD05_)
  sub $01
  ld (_RAM_DD05_), a
  cp $00
  jr nz, LABEL_6FCD_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp nz, LABEL_7AA6_
  ld a, $01
  ld (_RAM_DD06_), a
  ld a, (_RAM_DF25_)
  ld e, a
  ld d, $00
  ld hl, DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF51_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, LABEL_6FCD_
  call LABEL_1CFF_
  jp LABEL_6FCD_

+:
  ld a, (_RAM_DD05_)
  add a, $01
  ld (_RAM_DD05_), a
LABEL_6FCD_:
  ld a, (_RAM_DD06_)
  cp $01
  jr z, LABEL_6FFF_
  ld a, (_RAM_DCF6_)
  and $3F
  ld c, a
  ld hl, _RAM_D900_
  ld b, $00
  add hl, bc
  ld a, (hl)
  and $80
  jr nz, ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DD09_)
  cp $0A
  jr z, ++
+:
  call LABEL_718B_
++:
  ld a, (_RAM_DD04_)
  ld (_RAM_DF51_), a
  xor a
  ld (_RAM_DD07_), a
LABEL_6FFF_:
  ld a, (_RAM_DD47_)
  cp $00
  jp nz, LABEL_709C_
  ld a, (_RAM_DF52_)
  ld l, a
  ld a, (_RAM_DD45_)
  cp $00
  jp z, LABEL_709C_
  cp l
  jp z, LABEL_709C_
  ld b, $00
  ld a, (_RAM_DD45_)
  ld l, a
  ld a, (_RAM_DF52_)
  sub l
  jr nc, +
  ld b, $01
  xor $FF
  add a, $01
+:
  ld l, a
  ld a, (_RAM_DF68_)
  sub $0A
  cp l
  jr nc, LABEL_7070_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DD46_)
  sub $01
  ld (_RAM_DD46_), a
  cp $00
  jr nz, LABEL_7070_
  ld a, $01
  ld (_RAM_DD47_), a
  ld a, (_RAM_DF25_)
  ld e, a
  ld d, $00
  ld hl, DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF52_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, LABEL_7070_
  call LABEL_1CFF_
  jp LABEL_7070_

+:
  ld a, (_RAM_DD46_)
  add a, $01
  ld (_RAM_DD46_), a
LABEL_7070_:
  ld a, (_RAM_DD47_)
  cp $01
  jr z, LABEL_709C_
  ld a, (_RAM_DD37_)
  and $3F
  ld c, a
  ld hl, _RAM_D900_
  ld b, $00
  add hl, bc
  ld a, (hl)
  and $80
  jr nz, +
  ld a, (_RAM_DD4A_)
  cp $0A
  jr z, +
  call LABEL_71A0_
+:
  ld a, (_RAM_DD45_)
  ld (_RAM_DF52_), a
  xor a
  ld (_RAM_DD48_), a
LABEL_709C_:
  ld a, (_RAM_DE52_)
  cp $00
  jr z, ++
  add a, $01
  ld (_RAM_DE52_), a
  cp $81
  jr nz, +
  xor a
  ld (_RAM_DE52_), a
  ret

+:
  and $07
  jr nz, +
  ld a, (_RAM_DE51_)
  xor $01
  ld (_RAM_DE51_), a
  or a
  jr z, +
  ld a, SFX_01
  ld (_RAM_D974_SFXTrigger_Player2), a
+:
  ld a, (_RAM_DE51_)
  cp $00
  jr z, ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +++++++
  xor a
  jp +++

++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, ++++++
  ; Challenge
  ld a, (_RAM_DF24_LapsRemaining)
  cp $05
  jr nc, _TooMany
  cp $00
  jr nz, +
+++:
  add a, <SpriteIndex_Blank - (<SpriteIndex_Digit1 - 1) ; Adjust to the blank tile (in a more complicated way than is at all necessary)
+:add a, <SpriteIndex_Digit1 - 1 ; so 1 => "1"
-:ld (_RAM_DF37_HUDSpriteNs.LapCounter), a
  jp ++++++++

_TooMany:
  ld a, <SpriteIndex_Blank ; $AC ; Blank
  jp -

++++++:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $00
  jr z, +++++++
  ld a, $A6
-:
  ld (_RAM_DF37_HUDSpriteNs.LapCounter), a
  ret

+++++++:
  ld a, $AC
  jp -

++++++++:
  call LABEL_1D45_
  ld hl, _RAM_DF37_HUDSpriteNs.FirstPlace
  ld d, $00
  ld a, (_RAM_DF2A_Positions.Red) ; position
  ld e, a
  add hl, de
  ld a, (_RAM_DF65_) ; has finished
  cp $00
  jr z, +
  ld a, <SpriteIndex_FinishedIndicators.Red
  jp ++
+:ld a, <SpriteIndex_PositionIndicators.Red
++:
  ld (hl), a

  ld hl, _RAM_DF37_HUDSpriteNs.FirstPlace
  ld d, $00
  ld a, (_RAM_DF2A_Positions.Green)
  ld e, a
  add hl, de
  ld a, (_RAM_DCC5_)
  cp $00
  jr z, +
  ld a, <SpriteIndex_FinishedIndicators.Green
  jp ++
+:ld a, <SpriteIndex_PositionIndicators.Green
++:
  ld (hl), a

  ld hl, _RAM_DF37_HUDSpriteNs.FirstPlace
  ld d, $00
  ld a, (_RAM_DF2A_Positions.Blue)
  ld e, a
  add hl, de
  ld a, (_RAM_DD06_)
  cp $00
  jr z, +
  ld a, $9E
  jp ++

+:
  ld a, $96
++:
  ld (hl), a
  ld hl, _RAM_DF37_HUDSpriteNs.FirstPlace
  ld d, $00
  ld a, (_RAM_DF2A_Positions.Yellow)
  ld e, a
  add hl, de
  ld a, (_RAM_DD47_)
  cp $00
  jr z, +
  ld a, $9F
  jp ++

+:
  ld a, $97
++:
  ld (hl), a
_LABEL_7171_ret:
  ret

; Data from 7172 to 7175 (4 bytes)
DATA_7172_:
.db $09 $07 $05 $03

LABEL_7176_:
  ld a, (_RAM_DCAF_)
  ld (_RAM_DBB6_), a
  ld a, (_RAM_DCB0_)
  ld (_RAM_DBB7_), a
  ld a, (_RAM_DCB5_)
  and $3F
  ld (_RAM_DBB8_), a
  ret

LABEL_718B_:
  ld a, (_RAM_DCF0_)
  ld (_RAM_DBB9_), a
  ld a, (_RAM_DCF1_)
  ld (_RAM_DBBA_), a
  ld a, (_RAM_DCF6_)
  and $3F
  ld (_RAM_DBBB_), a
  ret

LABEL_71A0_:
  ld a, (_RAM_DD31_)
  ld (_RAM_DBBC_), a
  ld a, (_RAM_DD32_)
  ld (_RAM_DBBD_), a
  ld a, (_RAM_DD37_)
  and $3F
  ld (_RAM_DBBE_), a
  ret

LABEL_71B5_:
  ld a, (_RAM_DBB9_)
  ld (_RAM_DBB1_), a
  ld a, (_RAM_DBBA_)
  ld (_RAM_DBB3_), a
  ld a, (_RAM_DBBB_)
  ld (_RAM_DBB5_), a
LABEL_71C7_:
  ld a, (_RAM_D945_)
  cp $01
  jr z, +
  cp $02
  jr nz, ++
  ret

+:
  ld a, (_RAM_DBA4_)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBA9_)
  add hl, de
  ld (_RAM_D941_), hl
  ld a, (_RAM_DBA5_)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBAB_)
  add hl, de
  ld (_RAM_D943_), hl
++:
  ld a, (_RAM_DBB1_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D945_)
  or a
  jr z, +
  ld hl, (_RAM_DEF1_)
  jp +++

+:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0070
  jp ++

+:
  ld de, $004C
++:
  ld hl, (_RAM_DEF1_)
  or a
  sbc hl, de
+++:
  ld a, (_RAM_DBB5_)
  call LABEL_7367_
  ld (_RAM_DBAD_), hl
  ld a, (_RAM_DBB3_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D945_)
  or a
  jr z, +
  ld hl, (_RAM_DEF1_)
  jp +++

+:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0060
  jp ++

+:
  ld de, $0038
++:
  ld hl, (_RAM_DEF1_)
  or a
  sbc hl, de
+++:
  ld a, (_RAM_DBB5_)
  call LABEL_7393_
  ld (_RAM_DBAF_), hl
  ld a, (_RAM_D945_)
  cp $01
  jp z, ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet + ; ret
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrNzRet + ; ret
  ld a, (_RAM_D5DE_)
  ld (_RAM_DF4F_), a
  ld (_RAM_D587_), a
+:ret

++:
  JumpToPagedFunction LABEL_36B29_

LABEL_7295_:
  ld a, (_RAM_DBB6_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBB8_)
  call LABEL_7367_
  ld (_RAM_DCAB_CarData_Green), hl
  ld a, (_RAM_DBB7_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBB8_)
  call LABEL_7393_
  ld (_RAM_DCAD_), hl
  ret

LABEL_72CA_:
  ld a, (_RAM_D940_)
  cp $01
  jr z, +
  cp $02
  jr nz, ++
  xor a
  ld (_RAM_DF5B_), a
  ret

+:
  xor a
  ld (_RAM_DF5B_), a
  ld hl, (_RAM_DCEC_CarData_Blue)
  ld (_RAM_D941_), hl
  ld hl, (_RAM_DCEE_)
  ld (_RAM_D943_), hl
++:
  ld a, (_RAM_DBB9_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBB_)
  call LABEL_7367_
  ld (_RAM_DCEC_CarData_Blue), hl
  ld a, (_RAM_DBBA_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBB_)
  call LABEL_7393_
  ld (_RAM_DCEE_), hl
  ld a, (_RAM_D940_)
  cp $01
  jp z, +
  ret

+:
  JumpToPagedFunction LABEL_36BE6_

LABEL_7332_:
  ld a, (_RAM_DBBC_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBE_)
  call LABEL_7367_
  ld (_RAM_DD2D_CarData_Yellow), hl
  ld a, (_RAM_DBBD_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBE_)
  call LABEL_7393_
  ld (_RAM_DD2F_), hl
  ret

LABEL_7367_:
  push hl
    and $3F
    ld c, a
    ld hl, _RAM_D900_
    ld b, $00
    add hl, bc
    ld a, (hl)
    and $1F
    sra a
    sra a
    ld c, a
    ld b, $00
    ld hl, DATA_2FA7_
    add hl, bc
    ld a, (hl)
  pop hl
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrNzRet + ; ret
  ld bc, $0004
  or a
  sbc hl, bc
+:ret

LABEL_7393_:
  push hl
    and $3F
    ld c, a
    ld hl, _RAM_D900_
    ld b, $00
    add hl, bc
    ld a, (hl)
    and $1F
    sra a
    sra a
    ld c, a
    ld b, $00
    ld hl, DATA_2FAF_
    add hl, bc
    ld a, (hl)
  pop hl
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrNzRet + ; ret
  ld bc, $0004
  or a
  sbc hl, bc
+:ret

-:
  call LABEL_6C39_
  CallPagedFunction2 LABEL_35F0D_
  TailCall +

LABEL_73D4_UpdateHUDSprites:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, -
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, LABEL_7427_UpdateHUDSprites_RuffTrux
  ld a, (_RAM_DE8C_)
  or a
  jr nz, +
  call LABEL_6C39_
+:
  ; Emit 8/9 HUD sprites to sprite table RAM
  ld ix, _RAM_DA60_SpriteTableXNs
  ld iy, _RAM_DAE0_SpriteTableYs
  ld bc, $0000
-:
  ld hl, _RAM_DF1F_HUDSpriteFlickerCounter
  inc (hl)
  ld a, (hl)
  cp $09
  jr nz, +
  xor a
  ld (hl), a
+:
  ld hl, _RAM_DF2E_HUDSpriteXs
  ld d, $00
  ld e, a
  add hl, de
  ld a, (hl)
  ld (ix+0), a
  ld e, $09 ; Move on to N
  add hl, de
  ld a, (hl)
  ld (ix+1), a
  ld e, $09 ; Move on to Y
  add hl, de
  ld a, (hl)
  ld (iy+0), a
  inc ix
  inc ix
  inc iy
  inc c
  ld a, c
  cp $08
  jr nz, -
  ret

LABEL_7427_UpdateHUDSprites_RuffTrux:
  call LABEL_6C39_
  ld ix, _RAM_DA60_SpriteTableXNs
  ld iy, _RAM_DAE0_SpriteTableYs
  ld a, (_RAM_DF2E_HUDSpriteXs) ; Start at the usual lap counter location
  ld (ix+0), a
  add a, $08 ; And then 8px spacing
  ld (ix+2), a
  add a, $08
  ld (ix+4), a
  add a, $08
  ld (ix+6), a
  ld a, (_RAM_DF40_HUDSpriteYs) ; All same Y of course...
  ld (iy+0), a
  ld (iy+1), a
  ld (iy+2), a
  ld (iy+3), a
  ; Fill in some Ns with the sprites we have free for digits...
  ld a, $8B
  ld (ix+1), a
  ld a, $98
  ld (ix+3), a
  ld a, $9B
  ld (ix+5), a
  ld a, $E8
  ld (ix+7), a
  ret

LABEL_746B_RuffTrux_UpdatePerFrameTiles:
  JumpToPagedFunction LABEL_36D52_RuffTrux_UpdateTimer

LABEL_7476_PrepareResultsScreen:
  di
  CallPagedFunction2 LABEL_2B5D5_SilencePSG
  call LABEL_7564_SetControlsToNoButtons
  
  ; If track select is active, no results, just back to title screen
  ld a, (_RAM_DC3B_IsTrackSelect)
  cp $01
  jp z, LABEL_7519_BackToTitleSreen
  
  ; Head to head or challenge?
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, LABEL_74E6_HeadToHeadResults
  
  ; Challenge
  ; Check the index for special cases
  ld a, (_RAM_DC55_TrackIndex_Game)
  cp Track_00_QualifyingRace
  jp z, LABEL_7545_QualifyingResults
  cp Track_1A_RuffTrux1
  jp z, LABEL_7520_RuffTruxResults
  cp Track_1B_RuffTrux2
  jp z, LABEL_7520_RuffTruxResults
  cp Track_1C_RuffTrux3
  jp z, LABEL_7520_RuffTruxResults
  
  ; Cheat or not?
  ld a, (_RAM_DC4C_Cheat_AlwaysFirstPlace)
  or a
  jr nz, +
  
  ; Real positions
  ld a, (_RAM_DF2A_Positions.Red)
  ld (_RAM_DBCF_LastRacePosition), a
  ld a, (_RAM_DF2A_Positions.Green)
  ld (_RAM_DBD0_LastRacePosition_Player2), a
  ld a, (_RAM_DF2A_Positions.Blue)
  ld (_RAM_DBD2_LastRacePosition_Player4), a
  ld a, (_RAM_DF2A_Positions.Yellow)
  ld (_RAM_DBD1_LastRacePosition_Player3), a
-:
  ld a, MenuIndex_2_FourPlayerResults ; Four player results
  ld (_RAM_DBCD_MenuIndex), a
  jp LABEL_14_EnterMenus

+:; Always first place cheat
  ; Actually always 1st, 2nd, 3rd, 4th this way
  xor a
  ld (_RAM_DBCF_LastRacePosition), a
  inc a
  ld (_RAM_DBD0_LastRacePosition_Player2), a
  inc a
  ld (_RAM_DBD1_LastRacePosition_Player3), a
  inc a
  ld (_RAM_DBD2_LastRacePosition_Player4), a
  jr -

LABEL_74E6_HeadToHeadResults:
  ld a, (_RAM_DF2A_Positions.Player1)
  ld (_RAM_DBCF_LastRacePosition), a
  ld a, (_RAM_DF2A_Positions.Player2)
  ld (_RAM_DBD0_LastRacePosition_Player2), a
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, +++
  ld a, (_RAM_DC55_TrackIndex_Game)
  or a
  jr nz, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jr z, ++
  xor a
-:
  ld (_RAM_DBCE_Player1Qualified), a
+:
  ld a, MenuIndex_5
  jr ++++

++:
  ld a, $01
  jr -

+++:
  ld a, MenuIndex_4_TwoPlayerResults
++++:
  ld (_RAM_DBCD_MenuIndex), a
  jp LABEL_14_EnterMenus

LABEL_7519_BackToTitleSreen:
  xor a ; MenuIndex_0_TitleScreen
  ld (_RAM_DBCD_MenuIndex), a
  jp LABEL_14_EnterMenus

LABEL_7520_RuffTruxResults:
  ; Next track next time
  ld a, (_RAM_DC39_NextRuffTruxTrack)
  add a, $01
  ld (_RAM_DC39_NextRuffTruxTrack), a
  ; Reset counter for entry to bonus race
  xor a
  ld (_RAM_DC0A_WinsInARow), a
  ; Select the results screen
  ld a, MenuIndex_3_LifeWonOrLost
  ld (_RAM_DBCD_MenuIndex), a
  ; Set the control parameter for that screen
  ld a, (_RAM_DF8C_RuffTruxRanOutOfTime)
  cp $01
  jr z, +
  ld a, LifeWonOrLostMode_RuffTruxWon
  jp ++
+:ld a, LifeWonOrLostMode_RuffTruxLost
++:
  ld (_RAM_DC38_LifeWonOrLost_Mode), a
  ; And go to the menu
  jp LABEL_14_EnterMenus

LABEL_7545_QualifyingResults:
  ld a, MenuIndex_1_QualificationResults
  ld (_RAM_DBCD_MenuIndex), a
  ld a, (_RAM_DF2A_Positions.Red)
  cp $00 ; Won
  jr z, +
  cp $01 ; Lost
  jr nz, ++
+:
  ld a, $01
-:
  ld (_RAM_DBCE_Player1Qualified), a
  call LABEL_173_LoadEnterMenuTrampolineToRAM
  jp LABEL_14_EnterMenus

++:
  xor a
  jp -

LABEL_7564_SetControlsToNoButtons:
  ld a, NO_BUTTONS_PRESSED ; $3F
  ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
  ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
  ld (_RAM_DB20_Player1Controls), a
  ld (_RAM_DB21_Player2Controls), a
  ret

LABEL_7573_EnterGame:
  di
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ; Game Gear
  xor a
  out (PORT_GG_LinkStatus), a
+:
.else
.ifdef IS_GAME_GEAR
  xor a
  out (PORT_GG_LinkStatus), a
.endif
.endif
  ; Bug: should use a different address (and data size) for SMS. 
  ; Seems to work out OK anyway as we probably load a proepr palette soon anyway.
  SetPaletteAddressImmediateGG $10
  xor a ; Set to black
  out (PORT_VDP_DATA), a
  out (PORT_VDP_DATA), a
  ; Set that as the backdrop colour
  call LABEL_7A9F_SetBackdropColour
  call LABEL_156_SetSystemAndAdjustments
  call LABEL_3214_BlankSpriteTable
  call LABEL_31F1_UpdateSpriteTable
  ; Reset life counter if cheat is enabled
  ld a, (_RAM_DC4B_Cheat_InfiniteLives)
  or a
  jr z, +
  ld a, INFINITE_LIVES_COUNT
  ld (_RAM_DC09_Lives), a
+:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, +
  ld a, 1
  ld (_RAM_DC3D_IsHeadToHead), a
+:

  ; ------------------------------------------------------------------
  ; Start loading the track
  ; ------------------------------------------------------------------
  
  ; Get track index
  ld a, (_RAM_DC0A_WinsInARow)
  and $0F ; unnecessary
  cp WINS_IN_A_ROW_FOR_RUFFTRUX
  jr nz, +
  ld a, (_RAM_DC39_NextRuffTruxTrack)
  jp ++
+:ld a, (_RAM_DBD8_TrackIndex_Menus)
++:
  ld (_RAM_DC55_TrackIndex_Game), a

  ; Look up track type
  ld hl, DATA_766A_TrackList_TrackTypes
  ld d, $00
  ld e, a
  add hl, de
  ld a, (hl)
  ld (_RAM_DB97_TrackType), a

  ; Then per-track index
  ld hl, DATA_7687_TrackList_TrackIndexes
  add hl, de
  ld a, (hl)
  ld (_RAM_DB96_TrackIndexForThisType), a

  ; Then top speed
  GetPointerForSystem DATA_76A4_TrackList_TopSpeeds_SMS DATA_7718_TrackList_TopSpeeds_GG "cp" "jr" "jr"
  add hl, de
  ld a, (hl)
  ld (_RAM_DB98_TopSpeed), a

  ; Then acceleration delay
  GetPointerForSystem DATA_76C1_TrackList_AccelerationDelay_SMS DATA_7735_TrackList_AccelerationDelay_GG "cp" "jr" "jr"
  add hl, de
  ld a, (hl)
  ld (_RAM_DB99_AccelerationDelay), a
  
  ; Then deceleration delay
  GetPointerForSystem DATA_76DE_TrackList_DecelerationDelay_SMS DATA_7752_TrackList_DecelerationDelay_GG "cp" "jr" "jr"
  add hl, de
  ld a, (hl)
  ld (_RAM_DB9A_DecelerationDelay), a
  
  ; Then steering delay
  GetPointerForSystem DATA_76FB_TrackList_SteeringDelay_SMS DATA_776F_TrackList_SteeringDelay_GG "cp" "jr" "jr"
  add hl, de
  ld a, (hl)
  ld (_RAM_DB9B_SteeringDelay), a

  ; Unpack handling data
  ld a, :DATA_23DE7_HandlingData_SMS
  ld (PAGING_REGISTER), a
  GetPointerForSystem DATA_23DE7_HandlingData_SMS DATA_23ECF_HandlingData_GG "cp" "jr" "jr"
  ; 8 bytes per track
  ld a, e ; The course index
  sla a ; x8
  sla a
  sla a
  and $F8 ; Zero low bits
  ld e, a
  ld d, $00
  add hl, de ; -> hl
  ; Unpack 8 bytes to 16
  ld de, _RAM_DB86_HandlingData
  ld bc, 8
-:ld a, (hl) ; Read byte
  srl a ; High nibble
  srl a
  srl a
  srl a
  ld (de), a ; -> de
  inc de
  ld a, (hl) ;read it again
  and $0F ; Low nibble
  ld (de), a ; -> de
  inc de
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ; Restore paging
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  
  jp LABEL_383_EnterGame_Part2

; Track list: track type for each track
DATA_766A_TrackList_TrackTypes:
.db TT_2_Powerboats
.db TT_1_FourByFour
.db TT_0_SportsCars
.db TT_5_Warriors
.db TT_3_TurboWheels 
.db TT_1_FourByFour 
.db TT_4_FormulaOne 
.db TT_5_Warriors 
.db TT_2_Powerboats 
.db TT_3_TurboWheels 
.db TT_8_Helicopters 
.db TT_1_FourByFour 
.db TT_2_Powerboats 
.db TT_6_Tanks 
.db TT_4_FormulaOne 
.db TT_0_SportsCars 
.db TT_3_TurboWheels 
.db TT_8_Helicopters 
.db TT_5_Warriors 
.db TT_6_Tanks 
.db TT_0_SportsCars 
.db TT_2_Powerboats 
.db TT_8_Helicopters 
.db TT_4_FormulaOne 
.db TT_6_Tanks 
.db TT_0_SportsCars 
.db TT_7_RuffTrux 
.db TT_7_RuffTrux 
.db TT_7_RuffTrux

; Track list: track index (for the given type)
DATA_7687_TrackList_TrackIndexes:
.db 0 ; Powerboats
.db 1 ; FourByFour
.db 0 ; SportsCars
.db 0 ; Warriors
.db 1 ; TurboWheels
.db 0 ; FourByFour 
.db 0 ; FormulaOne 
.db 1 ; Warriors 
.db 1 ; Powerboats 
.db 0 ; TurboWheels
.db 0 ; Helicopters
.db 2 ; FourByFour 
.db 3 ; Powerboats 
.db 0 ; Tanks 
.db 1 ; FormulaOne 
.db 1 ; SportsCars 
.db 2 ; TurboWheels
.db 1 ; Helicopters
.db 2 ; Warriors 
.db 1 ; Tanks 
.db 2 ; SportsCars 
.db 2 ; Powerboats 
.db 2 ; Helicopters
.db 2 ; FormulaOne 
.db 2 ; Tanks 
.db 2 ; SportsCars 
.db 0 ; RuffTrux 
.db 1 ; RuffTrux 
.db 2 ; RuffTrux

; Track list: SMS top speeds (mostly constant per track type, not always)
DATA_76A4_TrackList_TopSpeeds_SMS:
.db $09 ; Powerboats  0 (9, 9, 9, 9)
.db $08 ; FourByFour  1 (8, 9, 9) <-- different
.db $0B ; SportsCars  0 (b, b, b, b)
.db $0A ; Warriors    0 (a, a, a)
.db $0B ; TurboWheels 1 (b, b, b)
.db $09 ; FourByFour  0 
.db $0B ; FormulaOne  0 (b, b, b)
.db $0A ; Warriors    1 
.db $09 ; Powerboats  1 
.db $0B ; TurboWheels 0 
.db $08 ; Helicopters 0 (8, 8, 8 - unused anyway)
.db $09 ; FourByFour  2 
.db $09 ; Powerboats  3 
.db $07 ; Tanks       0 (7, 7, 7)
.db $0B ; FormulaOne  1 
.db $0B ; SportsCars  1 
.db $0B ; TurboWheels 2 
.db $08 ; Helicopters 1 
.db $0A ; Warriors    2 
.db $07 ; Tanks       1 
.db $0B ; SportsCars  2 
.db $09 ; Powerboats  2 
.db $08 ; Helicopters 2 
.db $0B ; FormulaOne  2 
.db $07 ; Tanks       2 
.db $0B ; SportsCars  2 
.db $08 ; RuffTrux    0 (8, 8, 8)
.db $08 ; RuffTrux    1 
.db $08 ; RuffTrux    2 

; Track list: SMS "Acceleration delay" - higher numbers = slower acceleration
DATA_76C1_TrackList_AccelerationDelay_SMS:
.db $10 ; Powerboats  0 (10, 10, 10, 10)
.db $12 ; FourByFour  1 (12, 12, 12)
.db $09 ; SportsCars  0 (9, 9, 9, 9)
.db $12 ; Warriors    0 (12, 12, 12)
.db $0D ; TurboWheels 1 (d, e, d) <-- different
.db $12 ; FourByFour  0
.db $0F ; FormulaOne  0 (f, f, f)
.db $12 ; Warriors    1
.db $10 ; Powerboats  1
.db $0E ; TurboWheels 0
.db $12 ; Helicopters 0 (12, 12, 12)
.db $12 ; FourByFour  2
.db $10 ; Powerboats  3
.db $06 ; Tanks       0 (6, 6, 6)
.db $0F ; FormulaOne  1
.db $09 ; SportsCars  1
.db $0D ; TurboWheels 2
.db $12 ; Helicopters 1
.db $12 ; Warriors    2
.db $06 ; Tanks       1
.db $09 ; SportsCars  2
.db $10 ; Powerboats  2
.db $12 ; Helicopters 2
.db $0F ; FormulaOne  2
.db $06 ; Tanks       2
.db $09 ; SportsCars  2
.db $13 ; RuffTrux    0 (13, 13, 13)
.db $13 ; RuffTrux    1
.db $13 ; RuffTrux    2

; Track list: SMS "deceleration delay" - higher numbers = slower deceleration (i.e. coast further)
DATA_76DE_TrackList_DecelerationDelay_SMS:
.db $12 ; Powerboats  0 (12, 12, 12, 12)
.db $05 ; FourByFour  1 (5, 12, 12) <-- different
.db $16 ; SportsCars  0 (16, 16, 16, 16)
.db $27 ; Warriors    0 (27, 27, 27)
.db $19 ; TurboWheels 1 (19, 19, 19)
.db $12 ; FourByFour  0
.db $1A ; FormulaOne  0 (1a, 1a, 1a)
.db $27 ; Warriors    1
.db $12 ; Powerboats  1
.db $19 ; TurboWheels 0
.db $12 ; Helicopters 0 (12, 12, 12)
.db $12 ; FourByFour  2
.db $12 ; Powerboats  3
.db $06 ; Tanks       0 (6, 6, 6)
.db $1A ; FormulaOne  1
.db $16 ; SportsCars  1
.db $19 ; TurboWheels 2
.db $12 ; Helicopters 1
.db $27 ; Warriors    2
.db $06 ; Tanks       1
.db $16 ; SportsCars  2
.db $12 ; Powerboats  2
.db $12 ; Helicopters 2
.db $1A ; FormulaOne  2
.db $06 ; Tanks       2
.db $16 ; SportsCars  2
.db $15 ; RuffTrux    0 (15, 15, 15)
.db $15 ; RuffTrux    1
.db $15 ; RuffTrux    2

; Track list: SMS "steering delay" - higher numbers = slower turning
DATA_76FB_TrackList_SteeringDelay_SMS:
.db $07 ; Powerboats  0 (7, 7, 7, 7)
.db $06 ; FourByFour  1 (6, 6, 6)
.db $07 ; SportsCars  0 (7, 6, 6, 6) <-- different
.db $07 ; Warriors    0 (7, 6, 6) <-- different
.db $06 ; TurboWheels 1 (6, 6, 6)
.db $06 ; FourByFour  0
.db $06 ; FormulaOne  0 (6, 6, 6)
.db $06 ; Warriors    1
.db $07 ; Powerboats  1
.db $06 ; TurboWheels 0
.db $06 ; Helicopters 0 (6, 6, 6)
.db $06 ; FourByFour  2
.db $07 ; Powerboats  3
.db $09 ; Tanks       0 (9, 9, 9)
.db $06 ; FormulaOne  1
.db $06 ; SportsCars  1
.db $06 ; TurboWheels 2
.db $06 ; Helicopters 1
.db $06 ; Warriors    2
.db $09 ; Tanks       1
.db $06 ; SportsCars  2
.db $07 ; Powerboats  2
.db $06 ; Helicopters 2
.db $06 ; FormulaOne  2
.db $09 ; Tanks       2
.db $06 ; SportsCars  2
.db $06 ; RuffTrux    0 (6, 6, 6)
.db $06 ; RuffTrux    1
.db $06 ; RuffTrux    2

; Track list: GG top speeds (mostly constant per track type, not always)
; Mostly SMS - 2, i.e. slower
DATA_7718_TrackList_TopSpeeds_GG:
.db $07 ; Powerboats  0 (7, 7, 7, 7) (SMS - 2)
.db $06 ; FourByFour  1 (6, 7, 7)    (SMS - 2) <-- different
.db $0A ; SportsCars  0 (a, a, a, a) (SMS - 1) <-- different difference
.db $08 ; Warriors    0 (8, 8, 8)    (SMS - 2)
.db $09 ; TurboWheels 1 (9, 9, 9)    (SMS - 2)
.db $07 ; FourByFour  0 
.db $09 ; FormulaOne  0 (9, 9, 9)    (SMS - 2)
.db $08 ; Warriors    1 
.db $07 ; Powerboats  1 
.db $09 ; TurboWheels 0 
.db $06 ; Helicopters 0 (6, 6, 6)    (SMS - 2)
.db $07 ; FourByFour  2 
.db $07 ; Powerboats  3 
.db $05 ; Tanks       0 (5, 5, 5)    (SMS - 2)
.db $09 ; FormulaOne  1 
.db $0A ; SportsCars  1 
.db $09 ; TurboWheels 2 
.db $06 ; Helicopters 1 
.db $08 ; Warriors    2 
.db $05 ; Tanks       1 
.db $0A ; SportsCars  2 
.db $07 ; Powerboats  2 
.db $06 ; Helicopters 2 
.db $09 ; FormulaOne  2 
.db $05 ; Tanks       2 
.db $0A ; SportsCars  2 
.db $06 ; RuffTrux    0 (6, 6, 6)    (SMS - 2)
.db $06 ; RuffTrux    1 
.db $06 ; RuffTrux    2 

; Track list: GG "Acceleration delay" - higher numbers = slower acceleration
; Mostly SMS + 2, i.e. slower acceleration
DATA_7735_TrackList_AccelerationDelay_GG:
.db $14 ; Powerboats  0 (14, 14, 14, 14) (SMS + 4)
.db $14 ; FourByFour  1 (14, 14, 14)     (SMS + 2)
.db $09 ; SportsCars  0 (9, 9, 9, 9)     (SMS + 0)
.db $17 ; Warriors    0 (17, 17, 17)     (SMS + 5)
.db $0D ; TurboWheels 1 (d, 10, d)       (SMS + 0 or 2) <-- different
.db $14 ; FourByFour  0
.db $11 ; FormulaOne  0 (11, 11, 11)     (SMS + 2)
.db $17 ; Warriors    1
.db $14 ; Powerboats  1
.db $10 ; TurboWheels 0
.db $14 ; Helicopters 0 (14, 14, 14)     (SMS + 2)
.db $14 ; FourByFour  2
.db $14 ; Powerboats  3
.db $08 ; Tanks       0 (8, 8, 8)        (SMS + 2)
.db $11 ; FormulaOne  1
.db $09 ; SportsCars  1
.db $0D ; TurboWheels 2
.db $14 ; Helicopters 1
.db $17 ; Warriors    2
.db $08 ; Tanks       1
.db $09 ; SportsCars  2
.db $14 ; Powerboats  2
.db $14 ; Helicopters 2
.db $11 ; FormulaOne  2
.db $08 ; Tanks       2
.db $09 ; SportsCars  2
.db $15 ; RuffTrux    0 (15, 15, 15)     (SMS + 2)
.db $15 ; RuffTrux    1
.db $15 ; RuffTrux    2

; Track list: GG "deceleration delay" - higher numbers = slower deceleration (i.e. coast further)
; All are SMS + 2, i.e. more coasting
DATA_7752_TrackList_DecelerationDelay_GG:
.db $14 ; $12 ; Powerboats  0 (14, 14, 14, 14) (SMS + 2)
.db $07 ; $05 ; FourByFour  1 (7, 14, 14)      (SMS + 2) <-- different
.db $18 ; $16 ; SportsCars  0 (18, 18, 18, 18) (SMS + 2)
.db $29 ; $27 ; Warriors    0 (29, 29, 29)     (SMS + 2)
.db $1B ; $19 ; TurboWheels 1 (1b, 1b, 1b)     (SMS + 2)
.db $14 ; $12 ; FourByFour  0
.db $1C ; $1A ; FormulaOne  0 (1c, 1c, 1c)     (SMS + 2)
.db $29 ; $27 ; Warriors    1
.db $14 ; $12 ; Powerboats  1
.db $1B ; $19 ; TurboWheels 0
.db $14 ; $12 ; Helicopters 0 (14, 14, 14)     (SMS + 2)
.db $14 ; $12 ; FourByFour  2
.db $14 ; $12 ; Powerboats  3
.db $08 ; $06 ; Tanks       0 (8, 8, 8)        (SMS + 2)
.db $1C ; $1A ; FormulaOne  1
.db $18 ; $16 ; SportsCars  1
.db $1B ; $19 ; TurboWheels 2
.db $14 ; $12 ; Helicopters 1
.db $29 ; $27 ; Warriors    2
.db $08 ; $06 ; Tanks       1
.db $18 ; $16 ; SportsCars  2
.db $14 ; $12 ; Powerboats  2
.db $14 ; $12 ; Helicopters 2
.db $1C ; $1A ; FormulaOne  2
.db $08 ; $06 ; Tanks       2
.db $18 ; $16 ; SportsCars  2
.db $17 ; $15 ; RuffTrux    0 (17, 17, 17)     (SMS + 2)
.db $17 ; $15 ; RuffTrux    1
.db $17 ; $15 ; RuffTrux    2

; Track list: GG "steering delay" - higher numbers = slower turning
; All are SMS + 1, i.e. slower turning
DATA_776F_TrackList_SteeringDelay_GG:
.db $08 ; $07 ; Powerboats  0 (8, 8, 8, 8)  (SMS + 1)
.db $07 ; $06 ; FourByFour  1 (7, 7, 7)     (SMS + 1)
.db $08 ; $07 ; SportsCars  0 (8, 7, 7, 7)  (SMS + 1) <-- different
.db $08 ; $07 ; Warriors    0 (8, 7, 7)     (SMS + 1) <-- different
.db $07 ; $06 ; TurboWheels 1 (7, 7, 7)     (SMS + 1)
.db $07 ; $06 ; FourByFour  0
.db $07 ; $06 ; FormulaOne  0 (7, 7, 7)     (SMS + 1)
.db $07 ; $06 ; Warriors    1
.db $08 ; $07 ; Powerboats  1
.db $07 ; $06 ; TurboWheels 0
.db $07 ; $06 ; Helicopters 0 (7, 7, 7)     (SMS + 1)
.db $07 ; $06 ; FourByFour  2
.db $08 ; $07 ; Powerboats  3
.db $0A ; $09 ; Tanks       0 (a, a, a)     (SMS + 1)
.db $07 ; $06 ; FormulaOne  1
.db $07 ; $06 ; SportsCars  1
.db $07 ; $06 ; TurboWheels 2
.db $07 ; $06 ; Helicopters 1
.db $07 ; $06 ; Warriors    2
.db $0A ; $09 ; Tanks       1
.db $07 ; $06 ; SportsCars  2
.db $08 ; $07 ; Powerboats  2
.db $07 ; $06 ; Helicopters 2
.db $07 ; $06 ; FormulaOne  2
.db $0A ; $09 ; Tanks       2
.db $07 ; $06 ; SportsCars  2
.db $07 ; $06 ; RuffTrux    0 (7, 7, 7)     (SMS + 1)
.db $07 ; $06 ; RuffTrux    1
.db $07 ; $06 ; RuffTrux    2

LABEL_778C_ScreenOn:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENON
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_7795_ScreenOff:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENOFF
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_779E_ComputeScreenHScrollColumn:
  ld a, (_RAM_DC54_IsGameGear)
  cp 0
  jr z, @SMS
@GG:
  ld a, (_RAM_DED3_HScrollValue)
  and $F8
  rr a
  rr a
  ld l, a
  ld a, TILEMAP_ROW_SIZE
  sub l
  add a, $0A ; Offset by 10 = 5 cells
  and $3F
  ld (_RAM_DEBF_ScreenHScrollColumn.Lo), a
  ret

@SMS:
  ld a, (_RAM_DED3_HScrollValue)
  and $F8
  rr a
  rr a
  ld l, a
  ld a, TILEMAP_ROW_SIZE
  sub l
  and $3F
  ld (_RAM_DEBF_ScreenHScrollColumn.Lo), a
  ret

LABEL_77CD_ComputeScreenTilemapAddress:
  call LABEL_779E_ComputeScreenHScrollColumn
  ld a, (_RAM_DC54_IsGameGear)
  cp 0
  jr z, @SMS
@GG:
  ld c, $17
  jp ++
@SMS:
  ld c, $1C
++:
  ld a, (_RAM_DED4_VScrollValue)
  and $F8 ; Convert to tile scroll amount (divide by 8)
  rr a
  rr a
  rr a
  add a, c
  ld b, a
  ; Convert to tilemap address in de
  ld hl, DATA_9ED_TilemapAddressFromRowNumberLo
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_A2D_TilemapAddressFromRowNumberHi
  ld a, b
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld d, (hl)

  ; Add in X column count
  ld hl, (_RAM_DEBF_ScreenHScrollColumn)
  add hl, de

  ; That's the tilemap address of the top left of the screen
  ld a, l
  ld (_RAM_DEC3_ScreenTilemapAddress.Lo), a
  ld a, h
  ld (_RAM_DEC3_ScreenTilemapAddress.Hi), a
  ret

LABEL_780D_:
  call LABEL_779E_ComputeScreenHScrollColumn
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld c, $04
  jp ++

+:
  ld c, $1F
++:
  ld a, (_RAM_DED4_VScrollValue)
  and $F8
  rr a
  rr a
  rr a
  add a, c
  ld b, a
  ld hl, $09ED
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, $0A2D
  ld a, b
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, (_RAM_DEBF_ScreenHScrollColumn)
  add hl, de
  ld a, l
  ld (_RAM_DEC3_ScreenTilemapAddress.Lo), a
  ld a, h
  ld (_RAM_DEC3_ScreenTilemapAddress.Hi), a
  ret

LABEL_784D_:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ; SMS
  ld a, (_RAM_DED4_VScrollValue)
  and $F8 ; Divide by 8 -> 5 bit number
  rr a ; (could just shift? divide by 8)
  rr a
  rr a
  ld b, a
  ld hl, DATA_9ED_TilemapAddressFromRowNumberLo ; Look up in table; alignment would make this faster
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl) ; Get low byte
  ld hl, DATA_A2D_TilemapAddressFromRowNumberHi ; Look up high byte
  ld a, b
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ; Then save to RAM
  ld a, e
  ld (_RAM_DEBD_TopRowTilemapAddress.Lo), a
  ld a, d
  ld (_RAM_DEBD_TopRowTilemapAddress.Hi), a
  jp LABEL_779E_ComputeScreenHScrollColumn

+:
  ld a, (_RAM_DEB0_)
  cp $00
  jr z, +
  ld a, $34
  jp ++

+:
  ld a, $0A
++:
  ld c, a
  ld a, (_RAM_DED4_VScrollValue)
  ; Divide by 8
  and $F8
  rr a
  rr a
  rr a
  ; Add 5
  add a, $05
  ld b, a
  ; Look up tilemap address
  ld hl, DATA_9ED_TilemapAddressFromRowNumberLo
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_A2D_TilemapAddressFromRowNumberHi
  ld a, b
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ; Save to RAM
  ld a, e
  ld (_RAM_DEBD_TopRowTilemapAddress.Lo), a
  ld a, d
  ld (_RAM_DEBD_TopRowTilemapAddress.Hi), a

  ld a, (_RAM_DED3_HScrollValue)
  and $F8 ; Divide by 8, multiply by 2
  rr a
  rr a
  ld l, a
  ld a, TILEMAP_ROW_SIZE
  sub l
  add a, c
  and $3F
  ld (_RAM_DEBF_ScreenHScrollColumn.Lo), a
  ret

LABEL_78CE_:
  ld a, (_RAM_DECB_)
  or a
  ret z
  ld a, (_RAM_DC54_IsGameGear)
  ld b, $20
  or a
  jr z, +
  ld b, $16
+:
  xor a
  ld (_RAM_DECB_), a
  ld de, _RAM_DB22_
  ld h, $D8
  ld c, PORT_VDP_DATA
  exx
    ld hl, (_RAM_DEC3_ScreenTilemapAddress)
    ld a, l
    and $C0
    ld b, a
    ld a, l
    srl a
    or $E0
    ld d, a
    ld c, PORT_VDP_ADDRESS
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
+:exx
  djnz -
  exx
    ld (_RAM_DEC3_ScreenTilemapAddress), hl
  exx
  ret

LABEL_7916_:
  ld a, (_RAM_DECA_)
  or a
  ret z
  ld a, (_RAM_DC54_IsGameGear)
  ld b, $1D
  or a
  jr z, +
  ld b, $13
+:
  xor a
  ld (_RAM_DECA_), a
  ld de, _RAM_DB42_
  ld h, $D8
  exx
    ld hl, (_RAM_DEC1_VRAMAddress)
    ld c, PORT_VDP_ADDRESS
    ld b, $40
    ld d, $7F ; If the high byte of the VRAM address gets here...
    ld e, $77 ; ...then we wrap it to this
  exx
  ld c, PORT_VDP_DATA
-:
  exx
    ; Set VRAM address
    out (c), l
    out (c), h
    ; Add b to it
    ld a, b
    add a, l
    ld l, a
    jr nc, +
    inc h
    ld a, h
    cp d
    jr nz, +
    ; Wrap address
    ld h, e
+:exx
  ld a, (de) ; Emit data - tile index
  out (c), a
  ld l, a
  ld a, (hl)
  out (c), a ; - high byte
  inc de
  djnz -
  exx
    ; Update stored VRAM address
    ld (_RAM_DEC1_VRAMAddress), hl
  exx
  ret

LABEL_795E_:
  ld hl, (_RAM_DED1_MetatilemapPointer)
  ld a, (hl)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld hl, DATA_4000_TileIndexPointerLow
  ld a, (_RAM_DEBC_TileDataIndex)
  add a, l
  ld l, a
  xor a
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_4041_TileIndexPointerHigh
  ld a, (_RAM_DEBC_TileDataIndex)
  add a, l
  ld l, a
  xor a
  adc a, h
  ld h, a
  ld d, (hl)
  ld a, (_RAM_DEE7_)
  ld l, a
  ld a, e
  add a, l
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  call LABEL_18D2_
  ld hl, (_RAM_DB62_)
  ex de, hl
  exx
    ld a, (_RAM_DC54_IsGameGear)
    ld c, $20
    or a
    jr z, +
    ld c, $15
+:  ld a, (_RAM_DEC7_)
    neg
    add a, $0C
    ld b, a
    ld a, (_RAM_DECC_)
-:exx
  ldi
  exx
    inc a
    cp c
    jr z, +
    djnz -
    ld (_RAM_DECC_), a
  exx
  ld (_RAM_DB62_), de
  ret

+:  ld (_RAM_DECC_), a
  exx
  ld a, $01
  ld (_RAM_DECD_), a
  ld (_RAM_DECB_), a
  ret

LABEL_79C8_:
  ld a, (ix+20)
  cp $00
  jr z, +
  ret

+:
  ld a, (ix+45)
  cp $00
  jr z, +
  cp $01
  jr z, ++
  jp LABEL_7A38_

+:
  ld a, (_RAM_DCD9_)
  cp $00
  JrNzRet +
  ld a, CarState_4_Submerged
  ld (_RAM_DF5A_CarState3), a
  ld a, $01
  ld (_RAM_DCD9_), a
  xor a
  ld (ix+11), a
  xor a
  ld (ix+20), a
  ld (_RAM_DE67_), a
  ld (_RAM_DE32_), a
+:ret

++:
  ld a, (_RAM_DD1A_)
  cp $00
  JrNzRet ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  ld (_RAM_D5C0_), a
  jp LABEL_4DD4_

+:
  ld a, $04
  ld (_RAM_DF5B_), a
  ld a, $01
  ld (_RAM_DD1A_), a
  xor a
  ld (ix+11), a
  xor a
  ld (ix+20), a
  ld (_RAM_DE68_), a
  ld (_RAM_DE35_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +++
++:ret

+++:
  jp LABEL_4EA0_

LABEL_7A38_:
  ld a, (_RAM_DD5B_)
  cp $00
  JrNzRet +
  ld a, $04
  ld (_RAM_DF5C_), a
  ld a, $01
  ld (_RAM_DD5B_), a
  xor a
  ld (ix+11), a
  xor a
  ld (ix+20), a
  ld (_RAM_DE69_), a
  ld (_RAM_DE38_), a
+:ret

LABEL_7A58_:
  ld hl, (_RAM_DF20_)
  rr h ; Divide by 4
  rr l
  rr h
  rr l
  rr h
  rr l
  rr h
  rr l
  srl l
  ld h, $00
  ; Then divide by 3
  ld de, DATA_35B8D_DivideByThree
  add hl, de
  ld a, :DATA_35B8D_DivideByThree
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ; So this is _RAM_DF20_ / 12
  ld (_RAM_DF22_), a

  ; Then multiply by 96
  sla a
  ld l, a
  ld h, $00
  ld de, DATA_35BED_96TimesTable
  add hl, de
  ld e, (hl)
  inc hl
  ld d, (hl)
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld hl, (_RAM_DF20_)
  or a
  sbc hl, de
  ld a, l
  ld (_RAM_DF21_), a
  ld a, (_RAM_DF22_)
  ld (_RAM_DF20_), a
  ret

LABEL_7A9F_SetBackdropColour:
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_BACKDROP_COLOUR
  out (PORT_VDP_REGISTER), a
  ret

LABEL_7AA6_:
  ld a, (_RAM_DB7B_)
  cp $04
  jr z, LABEL_7AF2_
  jr nc, LABEL_7AC4_
LABEL_7AAF_:
  call +
  ld a, CarState_1_Exploding
  ld (_RAM_DF2A_Positions.Player1), a
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_DF2A_Positions.Player2), a
  ld (_RAM_D5CB_), a
  jp LABEL_2A08_

LABEL_7AC4_:
  call +
  xor a
  ld (_RAM_DF2A_Positions.Player1), a
  ld (_RAM_D5CB_), a
  ld a, $01
  ld (_RAM_DF2A_Positions.Player2), a
  ld (_RAM_DF5B_), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_4E49_

+:
  ld a, $01
  ld (_RAM_D947_), a
  ld a, $F0
  ld (_RAM_DF6A_), a
  xor a
  ld (_RAM_DF7F_), a
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld (_RAM_DF81_), a
-:ret

LABEL_7AF2_:
  ld a, (_RAM_D5CB_)
  or a
  JrNzRet -
  ld a, $01
  ld (_RAM_D5CB_), a
  ld (_RAM_D5CC_PlayoffTileLoadFlag), a
  ld a, SFX_14_Playoff
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld (_RAM_D974_SFXTrigger_Player2), a
  jp LABEL_B2B_

LABEL_7B0B_:
  ld a, (_RAM_D581_)
  cp $A0
  JrNcRet +
  ld a, (_RAM_D5CB_)
  inc a
  ld (_RAM_D5CB_), a
  cp $80
  jr c, +
  call LABEL_B63_
+:ret

.org $7b21
LABEL_7B21_Decompress:
; We need a .section to allow us to include it twice...
.section "Decompressor section" force
.include "decompressor.asm"
.ends

LABEL_7C67_:
  JumpToPagedFunction LABEL_36E6B_

LABEL_7C72_:
  JumpToPagedFunction LABEL_36F9E_

LABEL_7C7D_LoadTrack:
  call LABEL_3214_BlankSpriteTable

  ; Load tile high bytes
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr z, +++
  cp TT_4_FormulaOne
  jr nz, +
  ; F1
  ld de, DATA_3116_F1_TileHighBytesRunCompressed
  jp ++++
+:cp TT_7_RuffTrux
  jr nz, +
  ; RuffTrux -> all 1 (low 256 are used for sprites)
  ld a, $01
  ld (_RAM_DF1D_TileHighBytes_ConstantValue), a
  jp ++
+:; Other cars -> all 0 (no priority bits)
  xor a
  ld (_RAM_DF1D_TileHighBytes_ConstantValue), a
++:; Fill with constant
  ld hl, _RAM_D800_TileHighBytes
  ld bc, 256 ; Byte count
-:ld a, (_RAM_DF1D_TileHighBytes_ConstantValue)
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  jp +++++
+++: ; Powerboats
  ld de, DATA_313B_Powerboats_TileHighBytesRunCompressed
++++: ; Fill with compressed date
  ld hl, 256 / 8 ; 256 bits
  add hl, de
  ld b, h
  ld c, l
  ld a, c
  ld (_RAM_DF15_RunCompressedRawDataStartLo), a
  ld a, b
  ld (_RAM_DF16_RunCompressedRawDataStartHi), a
  ld hl, _RAM_D800_TileHighBytes
  call LABEL_7EBE_DecompressRunCompressed
+++++:

  ; Load tile data
  ; First page it in...
  ld hl, DATA_3DC8_TrackTypeTileDataPages
  ld a, (_RAM_DB97_TrackType)
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld (PAGING_REGISTER), a
  ; Then look it up...
  ld a, (_RAM_DB97_TrackType)
  ld hl, DATA_3DE4_TrackTypeTileDataPointerHi
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld d, a
  ld a, (_RAM_DB97_TrackType)
  ld hl, DATA_3DDC_TrackTypeTileDataPointerLo
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld e, a
  ; Then decompress it
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  ex de, hl
  call LABEL_7B21_Decompress
  ; Then to VRAM
  call LABEL_7F02_Copy3bppTileDataToVRAM

  ; Then extra tiles
  call LABEL_663D_InitialisePlugholeTiles

  ; Car tiles
  ; Page...
  ld hl, DATA_3EF4_CarTilesDataLookup_PageNumber
  ld a, (_RAM_DB97_TrackType) ; Index into table
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld (PAGING_REGISTER), a
  ; Pointer...
  ld a, (_RAM_DB97_TrackType) ; Index into next table
  ld hl, DATA_3EFD_CarTileDataLookup_Hi
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld d, a                   ; -> d
  ld a, (_RAM_DB97_TrackType) ; One more time
  ld hl, DATA_3EEC_CarTileDataLookup_Lo
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld e, a                     ; -> e
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld hl, $0300                ; Add $300 for RuffTrux, $96 for other types -> this is the size of the bitmask block
  jp ++                       ; $96 bytes = 150 bytes = 1200 bits = 400 rows = 50 tiles
+:ld hl, $0096                ; $300 bytes = 256 tiles?
++:add hl, de
  ld b, h                     ; -> bc
  ld c, l
  ld a, c
  ld (_RAM_DF15_RunCompressedRawDataStartLo), a          ; then to RAM
  ld a, b
  ld (_RAM_DF16_RunCompressedRawDataStartHi), a
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  call LABEL_7EBE_DecompressRunCompressed
  call LABEL_7F4E_CarAndShadowSpriteTilesToVRAM
  call LABEL_6704_LoadHUDTiles

  ; Look up the page number and page it in
  ld hl, DATA_3E3A_TrackTypeDataPageNumbers
  ld a, (_RAM_DB97_TrackType)
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld (PAGING_REGISTER), a
  ld (_RAM_DE8E_PageNumber), a ; And make that the "page to keep there"

  ; Read data from that page. We use the sports cars labels as our template, as the addresses are the same for all pages.
  ld hl, DATA_C000_TrackData_SportsCars.BehaviourData
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld hl, _RAM_CC80_BehaviourData - 4
  ex de, hl
  call LABEL_7B21_Decompress ; Decompress data there

  ld hl, DATA_C000_TrackData_SportsCars.WallData
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld hl, _RAM_C800_WallData - 4
  ex de, hl
  call LABEL_7B21_Decompress

  ; If it's the bathtub, write some stuff into the wall metadata
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld hl, _RAM_C800_WallData + _sizeof_WallDataMetaTile * $3c; _RAM_CC38_ ; Metatile $3c
  ld bc, _sizeof_WallDataMetaTile
-:ld a, $FF
  ld (hl), a ; Set all wall bits -> make it all solid
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
+:

  ; Load track layout
  ld a, (_RAM_DB96_TrackIndexForThisType)
  add a, $02  ; +2
  or a
  rl a        ; *2
  ld l, a
  ld a, >DATA_C000_TrackData_SportsCars.TrackLayout1 ; Look up -> 0 @ 8004, 1 @ 8006, 2 @ 8008
  ld h, a
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld hl, _RAM_C000_LevelLayout
  ex de, hl
  call LABEL_7B21_Decompress

  ; Load palette
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ; Game Gear
  ld de, DATA_C000_TrackData_SportsCars.GameGearPalette ; GG palette at +c
  ld a, (de)
  ld l, a
  inc de
  ld a, (de)
  ld h, a
  SetPaletteAddressImmediateGG 0
  ld b, 64 ; 64 bytes = full palette
  ld c, PORT_VDP_DATA
  otir
  jp ++

+:; SMS
  ; Look up palette in table
  ld a, :DATA_17EC2_SMSPalettes
  ld (PAGING_REGISTER), a
  ld a, (_RAM_DB97_TrackType)
  sla a
  ld d, 0
  ld e, a
  ld hl, DATA_17EC2_SMSPalettes
  add hl, de
  ld e, (hl)
  inc hl
  ld d, (hl)
  ex de, hl
  ; Emit to VDP
  SetPaletteAddressImmediateSMS 0
  ld b, $20 ; 32 entries
  ld c, PORT_VDP_DATA
  otir
  ; Restore paging
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a

++:
  CallPagedFunction LABEL_1BEB1_ChangePoolTableColour

  ; Load "decorator" 1bpp tile data to RAM buffer
  ld hl, DATA_C000_TrackData_SportsCars.DecoratorTiles
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ; Copy to RAM
  ld bc, 16 * 8
  ld hl, _RAM_D980_CarDecoratorTileData1bpp
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  ; Next pointer -> 64 bytes to _RAM_D900_ ("Data", use TBC)
  ld hl, DATA_C000_TrackData_SportsCars.UnknownData
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld bc, $0040
  ld hl, _RAM_D900_
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  ; Next pointer: car-specific effects tiles
  ld hl, DATA_C000_TrackData_SportsCars.EffectsTiles
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, +
  ; Not RuffTrux
  ld a, $A0 ; Tile $1ad
  out (PORT_VDP_ADDRESS), a
  ld a, $75
  out (PORT_VDP_ADDRESS), a
  ld bc, $0058 ; 88 rows = 11 tiles
-:push bc
    ld b, $03
    ld c, PORT_VDP_DATA
    otir
    EmitDataToVDPImmediate8 0
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  jp LABEL_7EA5_

+:
  ld de, $0000
--:
  push hl
    ld hl, DATA_1c82_TileVRAMAddresses
    add hl, de
    ld a, (hl)
    out (PORT_VDP_ADDRESS), a
    inc hl
    ld a, (hl)
    out (PORT_VDP_ADDRESS), a
  pop hl
  ld bc, $0008
-:push bc
    ld b, $03
    ld c, PORT_VDP_DATA
    otir
    EmitDataToVDPImmediate8 0
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  inc de
  inc de
  ld a, e
  cp $14
  jr nz, --
  SetTileAddressImmediate $68
  ld bc, $0020
-:
  xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
LABEL_7EA5_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, +

  ; RuffTrux
  ld a, VDP_REGISTER_SPRITESET_HIGH
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITESET
  out (PORT_VDP_REGISTER), a
  ret

+:; Other cars
  ld a, VDP_REGISTER_SPRITESET_LOW
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITESET
  out (PORT_VDP_REGISTER), a
  ret

LABEL_7EBE_DecompressRunCompressed:
  ; de = source data bitmask
  ; bc = source data raw bytes
  ; hl = destination
  ; Decomresses data. The data at de is a bitmask read left to right, where 1 = repeat, 0 = new raw byte.
  ; The data at bc contains only the raw bytes. The first raw byte is assumed.
  ; It's not RLE because the run length is not encoded as a number?
  ; e.g.
  ; hl = $c000 (RAM buffer)
  ; de = $8958 (page $d, absolute address $34958)
  ; bc = $89ee
/*
de -> 68 20 00 ... = %0110100000100000...
bc -> 00 01 00 03 02 01 07 01 07 04 03 0F 0C 03 0F 0C 03 0F ...
result -> 00 (00 00) 01 (01) 00 03 02 01 07 (07) 01 07 04 03 0F

*/
  xor a               ; Set bit index to 0
  ld (_RAM_DF13_RunCompressed_BitIndex), a
--:
  ld a, (bc)          ; read byte from source
  ld (hl), a          ; write to dest
  ld (_RAM_DF14_RunCompressed_LastWrittenByte), a  ; save it
  inc bc              ; next source byte
-:
  ld a, (_RAM_DF13_RunCompressed_BitIndex)  ; Next bit index (wrap 7->0)
  add a, $01
  and $07
  ld (_RAM_DF13_RunCompressed_BitIndex), a
  cp $00              ; Do work until it hits 0, else check if we hit de and loop until we do
  jr nz, +
  inc de              ; next bitmask
  ld a, (_RAM_DF15_RunCompressedRawDataStartLo)  ; Unless we ran out
  cp e
  jr nz, +
  ld a, (_RAM_DF16_RunCompressedRawDataStartHi)
  cp d
  jr nz, +
  ret                 ; else we are done

+:
  inc hl              ; next dest byte
  push hl
    ld hl, DATA_7F46_BitsLookup
    ld a, (_RAM_DF13_RunCompressed_BitIndex)  ; Look up the bit
    add a, l
    ld l, a
    ld a, h
    adc a, $00
    ld h, a
    ld a, (hl)      ; Get mask
    ld l, a
    ld a, (de)      ; Check the bit in the bitmask data
    and l
  pop hl
  cp $00            ; If we get a 0, go get another byte
  jr z, --
  ld a, (_RAM_DF14_RunCompressed_LastWrittenByte)  ; Else emit last written byte
  ld (hl), a
  jp -

LABEL_7F02_Copy3bppTileDataToVRAM:
  ld a, $C8     ; When to stop: after $800 bytes
  ld (_RAM_DF1C_CopyToVRAMUpperBoundHi), a
  SetTileAddressImmediate 0
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld a, $C6     ; Stop after $600 bytes for RuffTrux
  ld (_RAM_DF1C_CopyToVRAMUpperBoundHi), a
  SetTileAddressImmediate $100 ; and use upper tiles
+:
  ld hl, _RAM_C000_DecompressionTemporaryBuffer ; Point at the three bitplanes of tile data
  ld bc, _RAM_C000_DecompressionTemporaryBuffer + $0800
  ld de, _RAM_C000_DecompressionTemporaryBuffer + $1000
-:
  ld a, (hl)        ; Emit the three bitplanes
  out (PORT_VDP_DATA), a
  ld a, (bc)
  out (PORT_VDP_DATA), a
  ld a, (de)
  out (PORT_VDP_DATA), a
  xor a             ; And then 0
  out (PORT_VDP_DATA), a
  inc hl
  inc bc
  inc de
  ld a, (_RAM_DF1C_CopyToVRAMUpperBoundHi)  ; loop until hl == _RAM_DF1C_CopyToVRAMUpperBoundHi*256
  cp h
  jr nz, -
  xor a
  cp l
  jr nz, -
  ret

; Data from 7F46 to 7F4D (8 bytes)
DATA_7F46_BitsLookup: ; Index 0 = bit 7, 1 = bit 6, etc
.db %10000000
.db %01000000
.db %00100000
.db %00010000
.db %00001000
.db %00000100
.db %00000010
.db %00000001

LABEL_7F4E_CarAndShadowSpriteTilesToVRAM:
  CallPagedFunction2 LABEL_357F8_CarTilesToVRAM

  ; Then load the shadow tiles
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, +

  ; Normal cars
  ; VRAM address - tile $1a8 = shadow tile
  SetTileAddressImmediate $1a8
  ld bc, 8*4 ; four tiles
  ld hl, DATA_1C22_TileData_Shadow
  call LABEL_7FC9_EmitTileData3bpp

  ; VRAM address - tile $1ac = empty (not for RuffTrux)
  ; Tile is used in-game but in a weird way, and it's glitchy
  SetTileAddressImmediate $1ac
  ld bc, 32
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

+:; RuffTrux version
  ; We squeeze the shadow into unused spaces in the car sprites
  SetTileAddressImmediate $0b
  ld bc, 8
  ld hl, DATA_1C22_TileData_Shadow + 3 * 8 * 0 ; Tile 0
  call LABEL_7FC9_EmitTileData3bpp
  SetTileAddressImmediate $18
  ld bc, 8
  ld hl, DATA_1C22_TileData_Shadow + 3 * 8 * 1 ; Tile 1
  call LABEL_7FC9_EmitTileData3bpp
  SetTileAddressImmediate $1b
  ld bc, 8
  ld hl, DATA_1C22_TileData_Shadow + 3 * 8 * 2 ; Tile 2
  call LABEL_7FC9_EmitTileData3bpp
  SetTileAddressImmediate $88
  ld bc, 8
  ld hl, DATA_1C22_TileData_Shadow + 3 * 8 * 3 ; Tile 3
  ; fall through and return
LABEL_7FC9_EmitTileData3bpp:
  ; Emits bc rows of 3bpp data to the VDP
-:push bc
    ld b, $03 ; 3 bytes data
    ld c, PORT_VDP_DATA
    otir
    EmitDataToVDPImmediate8 0 ; 1 byte padding
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

; Data from 7FDB to 7FEF (21 bytes)
.dsb 5 $FF

;.ends

.BANK 1 SLOT 1
.ORG $0000
;.section "Slot 1" force

; Codemasters header
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

.dstruct Header instanceof CodemastersHeader DATA 16 /* pages */ $24 $11 $93 /* Date */ $13 $11 /* Time */ $B5B4 ($10000 - $B5B4) /* Checksum and complement */

; Data from 7FF0 to 7FFF (16 bytes)
; Sega header
.define SEGA_HEADER_REGION_SMS_EXPORT $4
.define SEGA_HEADER_SIXE_256KB $0
.db "TMR SEGA", $FF, $FF
.dw $E352 ; checksum
.dw $0000 ; Product number
.db $00 ; Version
.db SEGA_HEADER_REGION_SMS_EXPORT << 4 | SEGA_HEADER_SIXE_256KB ; SMS export, 256KB checksum
;.ends

.BANK 2
.ORG $0000
;.section "Bank 2"
LABEL_8000_Main:
  di
  ld hl, STACK_TOP
  ld sp, hl
.ifdef GAME_GEAR_CHECKS
  ld a, $00
  ld (_RAM_DC3C_IsGameGear), a
.endif
  call LABEL_AFAE_RamCodeLoader
  ld a, :DATA_3ED49_SplashScreenCompressed ; $0F
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_3ED49_SplashScreenCompressed ; $AD49 ; Location of compressed data - splash screen implementation, goes up to 3F752, decompresses to 3680 bytes
  CallRamCode LABEL_3B97D_DecompressFromHLToC000 ; loads splash screen code to RAM
  call _RAM_C000_DecompressionTemporaryBuffer ; Splash screen code is here

  call LABEL_AFAE_RamCodeLoader ; Maybe the splash screen broke it?
  call LABEL_B01D_SquinkyTennisHook

LABEL_8021_MenuScreenEntryPoint:
  ; Menu screen changes start here
  call LABEL_AFAE_RamCodeLoader
  ld a, 1
  ld (_RAM_DC3E_InMenus), a
  xor a
  ld (_RAM_D6D5_InGame), a
  call LABEL_BD00_InitialiseVDPRegisters
  call LABEL_BB6C_ScreenOff
  call LABEL_BB49_SetMenuHScroll
  call LABEL_B44E_BlankMenuRAM
  call LABEL_BB5B_SetBackdropToColour0
  call LABEL_BF2E_LoadMenuPalette_SMS
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, $38
  out (PORT_GG_LinkStatus), a
.else
.if IS_GAME_GEAR
  ld a, $38
  out (PORT_GG_LinkStatus), a
.endif
.endif
  ; Call the relevant menu initialiser
+:ld a, (_RAM_DBCD_MenuIndex)
  or a
  jr nz, +
  call LABEL_8114_MenuIndex0_TitleScreen_Initialise
  jp ++
+:dec a
  jr nz, +
  call LABEL_82DF_MenuIndex1_QualificationResults_Initialise
  jp ++
+:dec a
  jr nz, +
  call LABEL_8507_MenuIndex2_FourPlayerResults_Initialise
  jp ++
+:dec a
  jr nz, +
  call LABEL_866C_MenuIndex3_LifeWonOrLost_Initialise
  jp ++
+:dec a
  jr nz, +
  call LABEL_8A38_MenuIndex4_HeadToHeadResults_Initialise
  jp ++
+:dec a
  jr nz, ++
  ; Menu 5 only if course select > 0
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  or a
  jr nz, +
  call LABEL_82DF_MenuIndex1_QualificationResults_Initialise
  jp ++
+:call LABEL_84AA_MenuIndex5_Initialise
++:
  im 1
  ei
-:
  ; Main (menu) loop?
  ; Wait for VBlank flag
  ld a, (_RAM_D6D3_VBlankDone)
  dec a
  jr nz, -
  ld a, $00
  ld (_RAM_D6D3_VBlankDone), a
  call LABEL_90FF_ReadControllers
  call LABEL_80E6_CallMenuScreenHandler
  ld a, (_RAM_D6D5_InGame)
  dec a
  jr z, +
  ; Staying in menus
  ld a, (_RAM_D6D4_Slideshow_PendingLoad)
  or a
  CallRamCodeIfZFlag LABEL_3BB26_Trampoline_MenuMusicFrameHandler
  nop ; Hook point?
  nop
  nop
  call LABEL_B45D_
  jp -

+:; Menu -> game
  di
  ld a, 0
  ld (_RAM_DC3E_InMenus), a
  jp _RAM_DBC0_EnterGameTrampoline  ; Code is loaded from LABEL_75_EnterGameTrampolineImpl

; Jump Table from 80BE to 80E5 (20 entries, indexed by _RAM_D699_MenuScreenIndex)
DATA_80BE_MenuScreenHandlers:
.dw LABEL_80FC_Handler_MenuScreen_Initialise
.dw LABEL_8BAB_Handler_MenuScreen_Title
.dw LABEL_8C35_Handler_MenuScreen_SelectPlayerCount
.dw LABEL_8CE7_Handler_MenuScreen_OnePlayerSelectCharacter
.dw LABEL_8D2B_Handler_MenuScreen_RaceName
.dw LABEL_80FC_Handler_MenuScreen_Initialise ; Unused5
.dw LABEL_8D79_Handler_MenuScreen_Qualify
.dw LABEL_8DCC_Handler_MenuScreen_WhoDoYouWantToRace
.dw LABEL_8E15_Handler_MenuScreen_DisplayCase
.dw LABEL_8E97_Handler_MenuScreen_OnePlayerTrackIntro
.dw LABEL_8EF0_Handler_MenuScreen_OnePlayerChallengeResults
.dw LABEL_8F93_Handler_MenuScreen_UnknownB
.dw LABEL_8FC4_Handler_MenuScreen_LifeWonOrLost
.dw LABEL_9074_Handler_MenuScreen_UnknownD
.dw LABEL_B09F_Handler_MenuScreen_TwoPlayerSelectCharacter
.dw LABEL_8C35_Handler_MenuScreen_SelectPlayerCount ; shared
.dw LABEL_B56D_Handler_MenuScreen_TrackSelect
.dw LABEL_B6B1_Handler_MenuScreen_TwoPlayerResult
.dw LABEL_B84D_Handler_MenuScreen_TournamentChampion
.dw LABEL_B06C_Handler_MenuScreen_OnePlayerMode

LABEL_80E6_CallMenuScreenHandler:
  call LABEL_9167_ScreenOff
  ld a, (_RAM_D699_MenuScreenIndex)
  sla a
  ld c, a
  ld b, $00
  ld hl, DATA_80BE_MenuScreenHandlers
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ex de, hl
  call + ; Invoke looked-up function

; 1st entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_80FC_Handler_MenuScreen_Initialise:
LABEL_80FC_EndMenuScreenHandler:
  TailCall LABEL_915E_ScreenOn ; turn screen back on

+:jp (hl)

; Data from 8101 to 8113 (19 bytes) - dead code?
.ifdef UNNECESSARY_CODE
LABEL_8101_Unknown: ; unreachable?
  ld a,(_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK | BUTTON_2_MASK
  JrNzRet +
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, $8e ; Page $e, high bit ignored
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode LABEL_3BCEF_Trampoline_Unknown
+:ret
.endif

LABEL_8114_MenuIndex0_TitleScreen_Initialise:
  call LABEL_BB85_ScreenOffAtLineFF
  call LABEL_B44E_BlankMenuRAM
  ; Next menu screen is title
  ld a, MenuScreen_Title
  ld (_RAM_D699_MenuScreenIndex), a
  ld (_RAM_D7B3_), a
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_B337_BlankTiles
  call LABEL_9400_BlankSprites
  call LABEL_BAFF_LoadFontTiles
  call LABEL_BAD5_LoadMenuLogoTiles
  call LABEL_BDED_LoadMenuLogoTilemap
  call LABEL_BB13_InitialiseTitleScreenCarPortraitSlideshow
  call LABEL_B323_PopulatePlayerPortraitValues
  call LABEL_8CDB_ResetCheats

  ld a, PlayerPortrait_MrQuestion
  ld (_RAM_DBD4_Player1Character), a
  ld (_RAM_DBD5_Player2Character), a
  ld (_RAM_DBD6_Player3Character), a
  ld (_RAM_DBD7_Player4Character), a

  ld a, $02
  ld (_RAM_DC3A_RequiredPositionForNextRace), a

  xor a
  ld (_RAM_D7B7_), a
  ld (_RAM_D7B8_), a
  ld (_RAM_D7B9_), a
  ld (_RAM_D7B4_IsHeadToHead), a
  ld (_RAM_DC3F_IsTwoPlayer), a
  ld (_RAM_DC3D_IsHeadToHead), a
  ld (_RAM_DBD8_TrackIndex_Menus), a
  ld (_RAM_DC3B_IsTrackSelect), a
  ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  ld (_RAM_D6C6_), a
  ld (_RAM_D6C0_), a
  ld (_RAM_DC0A_WinsInARow), a
  ld (_RAM_DC34_IsTournament), a
  ld (_RAM_DC36_), a
  ld (_RAM_DC37_), a

  call LABEL_A778_InitialiseDisplayCaseData
  call LABEL_B9B3_Initialise_RAM_DC2C_GGTrackSelectFlags

  ld hl, _RAM_DC21_CharacterStates ; Blank this
  ld bc, 11
-:ld a, $00
  ld (hl), a
  inc hl
  dec bc
  ld a, c
  or a
  jr nz, -

  ld a, $FF
  ld (_RAM_D6C4_), a

  ld a, 0.48 * 50 ; 0.48s @ 50Hz, 0.4s @ 60Hz Delay before allowing user to enter the game on the title screen
  ld (_RAM_D6AB_MenuTimer.Lo), a

  ld a, $01
  ld (_RAM_DC35_TournamentRaceNumber), a

  ld a, Track_1A_RuffTrux1
  ld (_RAM_DC39_NextRuffTruxTrack), a

  call LABEL_BF2E_LoadMenuPalette_SMS

.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  ld (_RAM_DC40_IsGameGear), a
.endif

  ld c, Music_01_TitleScreen
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  TailCall LABEL_BB75_ScreenOnAtLineFF


LABEL_81C1_InitialiseSelectGameMenu:
  ; End current menu (title), start "select game"
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_SelectPlayerCount
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_9400_BlankSprites
  call LABEL_BAFF_LoadFontTiles
  call LABEL_BAD5_LoadMenuLogoTiles
  call LABEL_BDED_LoadMenuLogoTilemap
  ld c, Music_07_Menus
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, 0
  ld (_RAM_D6C7_IsTwoPlayer), a
  call LABEL_BB95_LoadSelectMenuGraphics
  call LABEL_BC0C_LoadSelectMenuTilemaps
  call LABEL_A4B7_DrawSelectMenuText
  call LABEL_9317_InitialiseHandSprites
  call LABEL_BDB8_LoadGG2PlayerIcon
  ld a, $00
  ld (_RAM_D6A0_MenuSelection), a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  call LABEL_A673_SelectLowSpriteTiles
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_8205_InitialiseOnePlayerSelectCharacterMenu:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_OnePlayerSelectCharacter
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, 0
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B2F3_DrawHorizontalLines_CharacterSelect
  call LABEL_987B_BlankTileForBlankPortraits
  call LABEL_9434_LoadCursorTiles
  call LABEL_988D_LoadCursorSprites
  xor a
  ld (_RAM_D6B1_), a ; TODO
  ld (_RAM_D6B8_), a
  ld (_RAM_D6B7_), a
  ld (_RAM_D6B9_), a
  TileWriteAddressToHL MenuTileIndex_SelectPlayers_SelectedPortraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_Player1Character)
  call LABEL_9F40_LoadPortraitTiles

  call _LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 13, 8 ; for GG
  jr ++
+:TilemapWriteAddressToHL 9, 9 ; for SMS
++:
.else
.ifdef IS_GAME_GEAR
  TilemapWriteAddressToHL 13, 8 ; for GG
.else
  TilemapWriteAddressToHL 9, 9 ; for SMS
.endif
.endif
  call LABEL_BCCF_EmitTilemapRectangleSequence

  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6A4_), a
  ld (_RAM_D6B4_), a
  ld (_RAM_D6B0_), a
  call LABEL_BDA6_
  ; Start music
  ld c, Music_02_CharacterSelect
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  call LABEL_A67C_
  call LABEL_97EA_DrawDriverPortraitColumn
  call LABEL_B3AE_
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_8272_:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_RaceName
  ld (_RAM_D699_MenuScreenIndex), a
  call LABEL_B2DC_DrawMenuScreenBase_NoLine ; blank screen
  TilemapWriteAddressToHL 0, 5
  call LABEL_B35A_VRAMAddressToHL
  call LABEL_95AF_DrawHorizontalLineIfSMS
  ld a, TT_2_Powerboats
  call LABEL_B478_SelectPortraitPage
  ld hl, DATA_1F3E4_Tiles_Portrait_Powerboats
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  ld de, 80 * 8 ; 80 tiles
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

  ; Draw 10x8 tilemap rect at 11, 10 starting at tile $24
  ld a, $24
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  TilemapWriteAddressToHL 11, 14
  ld a, $08
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, $0A
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call LABEL_BCCF_EmitTilemapRectangleSequence

  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, :TEXT_3ECC9_Vehicle_Name_Powerboats
  ld (_RAM_D741_RequestedPageIndex), a
  TilemapWriteAddressToHL 8, 22
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 16
  ld hl, TEXT_3ECC9_Vehicle_Name_Powerboats
  CallRamCode LABEL_3BC6A_EmitText
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  ld hl, 7.36 * 50 ; 7.36s @ 50Hz, 6.13s @ 60Hz
  ld (_RAM_D6AB_MenuTimer), hl
  xor a
  ld (_RAM_D6C1_), a
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_82DF_MenuIndex1_QualificationResults_Initialise:
  ld a, MenuScreen_Qualify
  ld (_RAM_D699_MenuScreenIndex), a
  
  ld a, $FF
  ld (_RAM_D6C4_), a
  
  ld a, (_RAM_DBCE_Player1Qualified)
  or a
  jr z, +
  jp _LABEL_8360_Qualified

+:; Failed to qualify
  call LABEL_BB85_ScreenOffAtLineFF
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  ld a, $0B
  ld (_RAM_D6B7_), a
  ld a, $01
  ld (_RAM_D6B4_), a
  ld a, $07
  ld (_RAM_D6B1_), a
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_Player1Character)
  ld (_RAM_DBD3_PlayerPortraitBeingDrawn), a
  add a, $01
  call LABEL_9F40_LoadPortraitTiles
  TilemapWriteAddressToHL 13, 12
  call LABEL_B8C9_EmitTilemapRectangle_5x6_24
  TilemapWriteAddressToHL 7, 20
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0012
  ld hl, TEXT_834E_FailedToQualify
  call LABEL_A5B0_EmitToVDP_Text
  ; Music, timer and done
  ld c, Music_08_GameOver
  call LABEL_B1EC_Trampoline_PlayMenuMusic
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, 9.04 * 50 ; 9.04s @ 50Hz
  jr ++
.endif
+:ld hl, 8.534 * 60 ; 8.53333333333333s @ 60Hz
++:
  ld (_RAM_D6AB_MenuTimer), hl
  TailCall LABEL_BB75_ScreenOnAtLineFF

TEXT_834E_FailedToQualify:
.asc "FAILED TO QUALIFY!"

_LABEL_8360_Qualified:
  call LABEL_BB85_ScreenOffAtLineFF
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  ; Initialise lives counter
  ld a, $03
  ld (_RAM_DC09_Lives), a
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, +
  ; Single player only (?)
  ; Next track
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  add a, $01
  ld (_RAM_DBD8_TrackIndex_Menus), a

+:; Load portrait
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_Player1Character)
  call LABEL_9F40_LoadPortraitTiles
  TilemapWriteAddressToHL 13, 14
  call LABEL_B8C9_EmitTilemapRectangle_5x6_24
  ; Draw text: "qualified for challenge"
  TilemapWriteAddressToHL 11, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0009
  ld hl, TEXT_83ED_Qualified
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 9, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000E
  ld hl, TEXT_83F6_ForChallenge
  call LABEL_A5B0_EmitToVDP_Text
  ; If it's head to head, overdraw the correct text
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr z, +
  TilemapWriteAddressToHL 7, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0012
  ld hl, TEXT_8404_ForHeadToHead
  call LABEL_A5B0_EmitToVDP_Text
+:; Draw lives count
  TilemapWriteAddressToHL 12, 22
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, TEXT_8416_Lives
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ; Music, timer and done
  ld c, Music_06_Results
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld hl, 8 * 50 ; 8s @ 50Hz, 6.66666666666667s @ 60Hz
  ld (_RAM_D6AB_MenuTimer), hl
  TailCall LABEL_BB75_ScreenOnAtLineFF

TEXT_83ED_Qualified:      .asc "QUALIFIED"
TEXT_83F6_ForChallenge:   .asc "FOR CHALLENGE!"
TEXT_8404_ForHeadToHead:  .asc "FOR HEAD TO HEAD !"
TEXT_8416_Lives:          .asc "LIVES "

LABEL_841C_:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_WhoDoYouWantToRace
  ld (_RAM_D699_MenuScreenIndex), a
  call LABEL_B337_BlankTiles
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_A673_SelectLowSpriteTiles
  call LABEL_B2F3_DrawHorizontalLines_CharacterSelect
  call LABEL_987B_BlankTileForBlankPortraits
  call LABEL_9434_LoadCursorTiles
  call LABEL_988D_LoadCursorSprites
  xor a
  ld (_RAM_D6B1_), a
  ld (_RAM_D6C0_), a
  ld (_RAM_D6B8_), a
  ld (_RAM_D6B7_), a
  ld (_RAM_D6C1_), a
  xor a
  ld (_RAM_D6C3_), a
  call LABEL_AC1E_
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D697_), a
  ld (_RAM_D6B4_), a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6B0_), a
  ld a, (_RAM_DBFC_)
  ld (_RAM_D6AD_), a
  ld a, (_RAM_DBFD_)
  ld (_RAM_D6AE_), a
  call LABEL_B3AE_
  ld c, Music_02_CharacterSelect
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DBFB_PortraitCurrentIndex)
  ld (_RAM_D6A2_), a
  ld c, a
  ld b, $00
  call LABEL_97EA_DrawDriverPortraitColumn
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_8486_InitialiseDisplayCase:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_DisplayCase
  ld (_RAM_D699_MenuScreenIndex), a
  call LABEL_B2BB_DrawMenuScreenBase_WithLine
  ld c, Music_07_Menus
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  call LABEL_A787_
  call LABEL_AD42_DrawDisplayCase
  call LABEL_B230_DisplayCase_BlankRuffTrux
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_84AA_MenuIndex5_Initialise:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, LABEL_84C7_InitialiseOnePlayerTrackIntro
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jp nz, LABEL_8F73_LoseALife
  call LABEL_B269_IncrementCourseSelectIndex
  cp Track_1A_RuffTrux1
  jr nz, LABEL_84C7_InitialiseOnePlayerTrackIntro
  call LABEL_B877_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_84C7_InitialiseOnePlayerTrackIntro:
  ld a, MenuScreen_OnePlayerTrackIntro
  ld (_RAM_D699_MenuScreenIndex), a
  call LABEL_B2BB_DrawMenuScreenBase_WithLine
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, +
  call LABEL_A7B3_
+:
  ld a, $01
  ld (_RAM_D6C3_), a
  call LABEL_AC1E_
  call LABEL_ACEE_DrawColouredBalls
  call LABEL_AB5B_GetPortraitSource_CourseSelect
  call LABEL_AB86_Decompress3bppTiles_Index100
  call LABEL_ABB0_
  call LABEL_BA3C_LoadColouredBallTilesToIndex150
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6C1_), a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_8507_MenuIndex2_FourPlayerResults_Initialise:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_OnePlayerChallengeResults
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_9400_BlankSprites
  call LABEL_90CA_BlankTiles_BlankControls
  call LABEL_BAFF_LoadFontTiles
  call LABEL_959C_LoadPunctuationTiles
  call LABEL_9448_LoadHeaderTiles
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS
  call LABEL_94AD_DrawHeaderTilemap
  jr ++
  ; GG
+:call LABEL_94F0_DrawHeaderTextTilemap
++:
.else
.ifdef IS_GAME_GEAR
  call LABEL_94F0_DrawHeaderTextTilemap
.else
  call LABEL_94AD_DrawHeaderTilemap
.endif
.endif
  call LABEL_B305_DrawHorizontalLine_Top

  ; Load player tiles
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_RequiredPositionForNextRace)
  ld c, a
  ld a, (_RAM_DBCF_LastRacePosition)
  cp c
  jr nc, +
  ld c, PlayerPortraits.Happy1 ; $00 ; Won
  jp ++
+:ld c, PlayerPortraits.Sad1 ; $01 ; Lost
++:ld a, (_RAM_DBD4_Player1Character)
  add a, c
  call LABEL_9F40_LoadPortraitTiles

  TileWriteAddressToHL MenuTileIndex_Portraits.2
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_RequiredPositionForNextRace)
  ld c, a
  ld a, (_RAM_DBD0_LastRacePosition_Player2)
  cp c
  jr nc, +
  ld c, $00
  jp ++
+:ld c, $01
++:ld a, (_RAM_DBD5_Player2Character)
  add a, c
  call LABEL_9F40_LoadPortraitTiles
  
  TileWriteAddressToHL MenuTileIndex_Portraits.3
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_RequiredPositionForNextRace)
  ld c, a
  ld a, (_RAM_DBD1_LastRacePosition_Player3)
  cp c
  jr nc, +
  ld c, $00
  jp ++
+:ld c, $01
++:ld a, (_RAM_DBD6_Player3Character)
  add a, c
  call LABEL_9F40_LoadPortraitTiles

  TileWriteAddressToHL MenuTileIndex_Portraits.4
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_RequiredPositionForNextRace)
  ld c, a
  ld a, (_RAM_DBD2_LastRacePosition_Player4)
  cp c
  jr nc, +
  ld c, $00
  jp ++
+:ld c, $01
++:ld a, (_RAM_DBD7_Player4Character)
  add a, c
  call LABEL_9F40_LoadPortraitTiles
  ; Show the portraits, prepare the remaining graphics
  ; (could be inlined)
  call LABEL_A877_LoadPositionGraphicsAndDrawPositionPortraitTilemaps

  ; Draw "results" text
  TilemapWriteAddressToHL 12, 7
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_85EC_Results
  call LABEL_A5B0_EmitToVDP_Text
  
  ; Reset stuff
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6C1_), a
  
  ; Play music
  ld c, Music_06_Results
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  
  ; Check if we won that one
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr nz, +
  ; First place
  ld a, (_RAM_DC39_NextRuffTruxTrack)
  cp Track_1C_RuffTrux3 + 1
  jr z, +
  ; Stop incrementing wins in a row because we ran out of RuffTrux tracks
  ld a, (_RAM_DC0A_WinsInARow)
  add a, 1
  ld (_RAM_DC0A_WinsInARow), a
  jr ++

+:; Not first place, reset wins counter
  xor a
  ld (_RAM_DC0A_WinsInARow), a
++:
  ; Done
  TailCall LABEL_BB75_ScreenOnAtLineFF

TEXT_85EC_Results: .asc "RESULTS-"

LABEL_85F4_:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_UnknownB
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, $0E
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  ld a, $0B
  ld (_RAM_D6B7_), a
  ld a, $01
  ld (_RAM_D6B4_), a
  ld a, $07
  ld (_RAM_D6B1_), a
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_D6C4_)
  ld c, a
  ld b, $00
  ld hl, _RAM_DBD5_Player2Character
  add hl, bc
  ld a, (hl)
  ld (_RAM_DBD3_PlayerPortraitBeingDrawn), a
  ld a, PlayerPortrait_MrQuestion
  ld (hl), a
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  add a, $01
  call LABEL_9F40_LoadPortraitTiles
  TilemapWriteAddressToHL 13, 12
  call LABEL_B8C9_EmitTilemapRectangle_5x6_24
  ; Set player to "out of game"
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  srl a
  srl a
  srl a
  ld c, a
  ld b, $00
  ld hl, _RAM_DBFE_PlayerPortraitValues
  add hl, bc
  ld a, PlayerPortrait_OutOfGame2
  ld (hl), a
  ld a, (_RAM_D6C4_)
  add a, $01
  ld (_RAM_D6B9_), a
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld c, Music_09_PlayerOut
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_866C_MenuIndex3_LifeWonOrLost_Initialise:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_LifeWonOrLost
  ld (_RAM_D699_MenuScreenIndex), a
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ; Pick a portrait - won or lost
  ld a, (_RAM_DC38_LifeWonOrLost_Mode)
  cp LifeWonOrLostMode_RuffTruxWon ; the only good one
  jr nz, +
  ld c, PlayerPortraits.Happy1 ; $00 ; Won
  jp ++
+:ld c, PlayerPortraits.Sad1 ; $01 ; Lost
++:
  ld a, (_RAM_DBD4_Player1Character)
  add a, c
  ; Load and draw portrait
  call LABEL_9F40_LoadPortraitTiles
  TilemapWriteAddressToHL 13, 14
  call LABEL_B8C9_EmitTilemapRectangle_5x6_24
  ; Switch on the reason for entering this screen
  ld a, (_RAM_DC38_LifeWonOrLost_Mode)
  dec a
  jr z, _LABEL_8717_GameOver ; LifeWonOrLostMode_GameOver
  dec a
  jp z, _LABEL_876B_RuffTruxWon ; LifeWonOrLostMode_RuffTruxWon
  dec a
  jp z, LABEL_87E9_RuffTruxLost ; LifeWonOrLostMode_RuffTruxLost
  ; Else it's LifeWonOrLostMode_LifeLost
  TilemapWriteAddressToHL 9, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000E
  ld hl, TEXT_882E_OneLifeLost
  call LABEL_A5B0_EmitToVDP_Text
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22 ; SMS
  jr ++
+:TilemapWriteAddressToHL 12, 21 ; GG
++:
.else
.ifdef IS_GAME_GEAR
  TilemapWriteAddressToHL 12, 21 ; GG
.else
  TilemapWriteAddressToHL 12, 22 ; SMS
.endif
.endif
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, TEXT_884A_Lives
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  call LABEL_A673_SelectLowSpriteTiles
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits + 1
  ld (_RAM_D701_SpriteN + 0), a ; Sprite 0
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS
  ld a, $96
  ld (_RAM_D6E1_SpriteX + 0), a
  ld a, $B0
  ld (_RAM_D721_SpriteY + 0), a
  jr ++

+:; GG
  ld a, $90
  ld (_RAM_D6E1_SpriteX + 0), a
  ld a, $A8
  ld (_RAM_D721_SpriteY + 0), a
++:
.else
.if IS_GAME_GEAR
  ld a, $90
  ld (_RAM_D6E1_SpriteX + 0), a
  ld a, $A8
  ld (_RAM_D721_SpriteY + 0), a
.else
  ld a, $96
  ld (_RAM_D6E1_SpriteX + 0), a
  ld a, $B0
  ld (_RAM_D721_SpriteY + 0), a
.endif
.endif
  call LABEL_93CE_UpdateSpriteTable
  ; Music, timer and done
  ld c, Music_0A_LostLife
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, 2.56 * 50 ; 2.56s @ 50Hz, 2.13333333333333s @ 60Hz
  ld (_RAM_D6AB_MenuTimer.Lo), a
  jp LABEL_8826_

_LABEL_8717_GameOver:
  TilemapWriteAddressToHL 9, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000E
  ld hl, TEXT_883C_GameOver
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, TEXT_8850_Level
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DBF1_RaceNumberText + 5)
  cp $0E ; Omit leading '0'
  jr z, +
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
+:
  ld a, (_RAM_DBF1_RaceNumberText + 6)
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld c, Music_08_GameOver
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, 4.52 * 50 ; 4.52s @ 50Hz
  jr ++

+:
  ld a, 4.25 * 60 ; 4.25s @ 60Hz
++:
  ld (_RAM_D6AB_MenuTimer.Lo), a
  jp LABEL_8826_

_LABEL_876B_RuffTruxWon:
  TilemapWriteAddressToHL 10, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, TEXT_8856_YouMadeIt
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 10, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, TEXT_8862_ExtraLife
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, TEXT_884A_Lives
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld a, (_RAM_DC09_Lives)
  cp $09
  jr z, +
  ; Increase up to maximum 9
  add a, $01
+:
  ld (_RAM_DC09_Lives), a
  call LABEL_A673_SelectLowSpriteTiles
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  ld (_RAM_D701_SpriteN), a
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr nz, +
  ld a, $96
  jp ++

+:
  ld a, $90
++:
  ld (_RAM_D6E1_SpriteX), a
  ld a, $E0
  ld (_RAM_D721_SpriteY), a
  call LABEL_93CE_UpdateSpriteTable
  ld c, Music_06_Results
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, 4 * 50 ; 4s @ 50Hz, 3.33333333333333s @ 60Hz
  ld (_RAM_D6AB_MenuTimer.Lo), a
  jp LABEL_8826_

LABEL_87E9_RuffTruxLost:
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0009
  ld hl, TEXT_886E_NoBonus
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, TEXT_884A_Lives
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld c, Music_0A_LostLife
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, 2.56 * 50 ; 2.56s @ 50Hz, 2.13333333333333s @ 60Hz
  ld (_RAM_D6AB_MenuTimer.Lo), a
LABEL_8826_:
  xor a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  TailCall LABEL_BB75_ScreenOnAtLineFF

TEXT_882E_OneLifeLost:  .asc "ONE LIFE LOST!"
TEXT_883C_GameOver:     .asc "  GAME OVER!  "
TEXT_884A_Lives:        .asc "LIVES "
TEXT_8850_Level:        .asc "LEVEL "
TEXT_8856_YouMadeIt:    .asc "YOU MADE IT!"
TEXT_8862_ExtraLife:    .asc " EXTRA LIFE "
TEXT_886E_NoBonus:      .asc "NO  BONUS"

LABEL_8877_:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_UnknownD
  ld (_RAM_D699_MenuScreenIndex), a
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B305_DrawHorizontalLine_Top
  ld a, TT_9_Unknown
  call LABEL_B478_SelectPortraitPage
  ld hl, DATA_2AB4D_Tiles_Portrait_RuffTrux
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Logo
  ld de, 80 * 8 ; 80 tiles
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

  ; Draw 10x8 tilemap rect at 11, (something) starting at tile 256
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 11, 18 ; for SMS
  jr ++
+:TilemapWriteAddressToHL 11, 14 ; for GG
++:xor a
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $08
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, $0A
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call LABEL_BCCF_EmitTilemapRectangleSequence

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 8, 26 ; SMS
  jr ++
+:TilemapWriteAddressToHL 8, 22 ; GG
++:call LABEL_B35A_VRAMAddressToHL

  ld a, :TEXT_3ED39_Vehicle_Name_Rufftrux
  ld (_RAM_D741_RequestedPageIndex), a
  ld bc, 16
  ld hl, TEXT_3ED39_Vehicle_Name_Rufftrux
  CallRamCode LABEL_3BC6A_EmitText
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 9, 9
  ld hl, TEXT_8929_TripleWin
  call LABEL_B3A4_EmitToVDPAtDE_Text
  TilemapWriteAddressToDE 9, 11
  ld hl, TEXT_8937_BonusRace
  call LABEL_B3A4_EmitToVDPAtDE_Text
  jr ++

+:
  TilemapWriteAddressToDE 9, 10
  ld hl, TEXT_8929_TripleWin
  call LABEL_B3A4_EmitToVDPAtDE_Text
  TilemapWriteAddressToDE 9, 12
  ld hl, TEXT_8937_BonusRace
  call LABEL_B3A4_EmitToVDPAtDE_Text
++:
  TilemapWriteAddressToDE 9, 13
  ld hl, TEXT_8945_BeatTheClock
  call LABEL_B3A4_EmitToVDPAtDE_Text
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld (_RAM_D6C1_), a
  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  TailCall LABEL_BB75_ScreenOnAtLineFF

TEXT_8929_TripleWin:    .asc "TRIPLE WIN !!!"
TEXT_8937_BonusRace:    .asc "  BONUS RACE  "
TEXT_8945_BeatTheClock: .asc "BEAT THE CLOCK"

LABEL_8953_InitialiseTwoPlayersMenu:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_TwoPlayerSelectCharacter
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $01
  ld (_RAM_D7B4_IsHeadToHead), a
  xor a
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B2F3_DrawHorizontalLines_CharacterSelect
  call LABEL_987B_BlankTileForBlankPortraits
  call LABEL_9434_LoadCursorTiles
  call LABEL_988D_LoadCursorSprites
  call LABEL_A673_SelectLowSpriteTiles

  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_Player1Character)
  call LABEL_9F40_LoadPortraitTiles
  ld a, (_RAM_DBD5_Player2Character)
  call LABEL_9F40_LoadPortraitTiles

  TilemapWriteAddressToHL 10, 9
  call LABEL_B8C9_EmitTilemapRectangle_5x6_24

  ld a, $42
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  TilemapWriteAddressToHL 17, 9
  call LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, $30
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6CD_), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld (_RAM_D6C6_), a
  ld (_RAM_D6B9_), a
  ld (_RAM_D697_), a
  ld (_RAM_D6B4_), a
  ld (_RAM_D6B0_), a
  ld (_RAM_D6B1_), a
  ld (_RAM_D6C0_), a
  ld (_RAM_D6B8_), a
  ld (_RAM_D6B7_), a
  ld (_RAM_D6C1_), a
  call LABEL_BDA6_
  ld a, $02
  ld (_RAM_D688_), a
  call LABEL_A67C_
  call LABEL_97EA_DrawDriverPortraitColumn
  call LABEL_B3AE_
  ld c, Music_02_CharacterSelect
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_89E2_:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_TwoPlayerGameType
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_9400_BlankSprites
  call LABEL_90CA_BlankTiles_BlankControls
  call LABEL_BAFF_LoadFontTiles
  call LABEL_959C_LoadPunctuationTiles
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call LABEL_9448_LoadHeaderTiles
  call LABEL_94AD_DrawHeaderTilemap
  call LABEL_B305_DrawHorizontalLine_Top
  ld a, $01
  ld (_RAM_D6C7_IsTwoPlayer), a
  ld (_RAM_D7B3_), a
  call LABEL_BB95_LoadSelectMenuGraphics
  call LABEL_BC0C_LoadSelectMenuTilemaps
  call LABEL_A530_DrawChooseGameText
  ld c, Music_07_Menus
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  call LABEL_9317_InitialiseHandSprites
  xor a
  ld (_RAM_D6A0_MenuSelection), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  call LABEL_A673_SelectLowSpriteTiles
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_8A30_InitialiseTwoPlayersRaceSelectMenu:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_TrackSelect
  jp +

LABEL_8A38_MenuIndex4_HeadToHeadResults_Initialise:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_TwoPlayerResult
+:ld (_RAM_D699_MenuScreenIndex), a
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_9400_BlankSprites
  call LABEL_90CA_BlankTiles_BlankControls
  call LABEL_BAFF_LoadFontTiles
  call LABEL_959C_LoadPunctuationTiles
  call LABEL_A296_LoadHandTiles
  call LABEL_BA3C_LoadColouredBallTilesToIndex150
  call LABEL_BA4F_LoadMediumNumberTiles
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TrackSelect
  jr z, ++
+:
.else
.ifdef IS_GAME_GEAR
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TrackSelect
  jr z, ++
.else
.endif
.endif
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call LABEL_9448_LoadHeaderTiles
  call LABEL_94AD_DrawHeaderTilemap
  call LABEL_B305_DrawHorizontalLine_Top
++:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr nz, +

  ; Two players mode - load portraits
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBCF_LastRacePosition)
  ld c, a
  ld a, (_RAM_DBD4_Player1Character)
  add a, c
  call LABEL_9F40_LoadPortraitTiles
  ld a, (_RAM_DBD0_LastRacePosition_Player2)
  ld c, a
  ld a, (_RAM_DBD5_Player2Character)
  add a, c
  call LABEL_9F40_LoadPortraitTiles
  jp ++

+:; One player mode (vs CPU) - load portraits
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_Player1Character)
  call LABEL_9F40_LoadPortraitTiles
  ld a, (_RAM_DBD5_Player2Character)
  call LABEL_9F40_LoadPortraitTiles

++:
  call _LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
  ld a, (_RAM_D699_MenuScreenIndex)

  ; Draw tilemaps
.ifdef GAME_GEAR_CHECKS
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 9, 5  ; Two player mode
  jp ++
+:TilemapWriteAddressToHL 9, 15 ; One player mode
++:
  ld a, (_RAM_DC3C_IsGameGear)
  cp $01
  jr z, +
  ; Add two rows for SMS
  ld bc, $0080
  add hl, bc
+:
.else
.ifdef IS_GAME_GEAR
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 9, 5  ; Two player mode
  jp ++
+:TilemapWriteAddressToHL 9, 15 ; One player mode
++:
.else
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 9, 7  ; Two player mode
  jp ++
+:TilemapWriteAddressToHL 9, 17 ; One player mode
++:
.endif
.endif
  call LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, $42
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  
  ; Same again for the second portrait
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
.ifdef GAME_GEAR_CHECKS
  jr z, +
  TilemapWriteAddressToHL 18, 5
  jp ++
+:TilemapWriteAddressToHL 18, 15
++:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0080 ; Add 2 rows for SMS
  add hl, bc
+:
.else
.ifdef IS_GAME_GEAR
  jr z, +
  TilemapWriteAddressToHL 18, 5  ; Two player mode
  jp ++
+:TilemapWriteAddressToHL 18, 15 ; One player mode
++:
.else
  jr z, +
  TilemapWriteAddressToHL 18, 7  ; Two player mode
  jp ++
+:TilemapWriteAddressToHL 18, 17 ; One player mode
++:
.endif
.endif
  call LABEL_BCCF_EmitTilemapRectangleSequence
  call LABEL_A355_PrintWonLostCounterLabels
  call LABEL_B9ED_
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld (_RAM_D6C1_), a
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  ld (_RAM_D6CC_TwoPlayerTrackSelectIndex), a
  ld (_RAM_D6CE_), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jp z, LABEL_8B89_
  ld a, (_RAM_DC34_IsTournament)
  cp $01
  jr z, +
  call LABEL_A673_SelectLowSpriteTiles
  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  call LABEL_9317_InitialiseHandSprites
  ld hl, DATA_2B356_SpriteNs_HandLeft
  CallRamCode LABEL_3BBB5_PopulateSpriteNs
  jp LABEL_8B9D_

+:
  call LABEL_B785_
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr z, _player2

.define GearToGear_Signal $cc
-:; Send the signal
  ld a, GearToGear_Signal
  out (PORT_GG_LinkSend), a
  ; Wait for something to arrive
  ld a, (_RAM_DC47_GearToGear_OtherPlayerControls1)
  cp NO_BUTTONS_PRESSED
  jr z, -
  ; That's our value
  ld (_RAM_D6CF_GearToGearTrackSelectIndex), a
  jr +

_player2:
-:; Wait for the signal
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  cp GearToGear_Signal
  jr nz, -
  ; Emit the value
  ld a, (_RAM_D6CF_GearToGearTrackSelectIndex)
  out (PORT_GG_LinkSend), a

+:call LABEL_AF5D_BlankControlsRAM
  ; Set the selected index to 1
  ld a, (_RAM_D6CF_GearToGearTrackSelectIndex)
  ld c, a
  ld b, $00
  ld hl, _RAM_DC2C_GGTrackSelectFlags
  add hl, bc
  ld a, $01
  ld (hl), a
  ; Get the real track index
  ld a, c
  call LABEL_B213_GearToGearTrackSelect_GetIndex
  ld a, c
  add a, $01
  call LABEL_AB68_GetPortraitSource_TrackType
  call LABEL_AB9B_Decompress3bppTiles_Index160
  call LABEL_ABB0_
  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  jp LABEL_8B9D_

LABEL_8B89_:
  ld c, Music_0B_TwoPlayerResult
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  call LABEL_A0B4_
  call LABEL_B7FF_
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr nz, LABEL_8B9D_
  call LABEL_B785_
LABEL_8B9D_:
  call LABEL_A14F_
  xor a
  ld (_RAM_D6CB_MenuScreenState), a
  call LABEL_BF2E_LoadMenuPalette_SMS
  TailCall LABEL_BB75_ScreenOnAtLineFF

; 2nd entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8BAB_Handler_MenuScreen_Title:
  call LABEL_AF10_CheckGearToGear

.ifdef UNNECESSARY_CODE
  ld a, (_RAM_D7BB_Unused) ; ??? Never set?
  or a
  jr nz, LABEL_8C2C_GoToTwoPlayerMenu
.endif

  call LABEL_BE1A_InitiallyDrawCopyrightText
  call LABEL_918B_MaybeDrawCarPortraitTilemap
  call LABEL_92CB_SlowCopySlideshowTilesToVRAM
  call LABEL_B9C4_CycleGearToGearTrackSelectIndex
  call LABEL_B484_CheckTitleScreenCheatCodes
  ld a, (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect)
  cp $09 ; full length
  jr z, LABEL_8C23_StartCourseSelect ; cheat 1 entered

  ld a, (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode)
  cp $07 ; middle length
  jr nz, +
  ld a, $01
  ld (_RAM_DC46_Cheat_HardMode), a
  jr ++
+:cp $0A ; full length
  jr nz, ++
  ld a, $02
  ld (_RAM_DC46_Cheat_HardMode), a
++:
  call LABEL_B505_UpdateHardModeText

  ; Decrement timer
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  or a
  jr z, +
  sub $01
  ld (_RAM_D6AB_MenuTimer.Lo), a

  jp +++

+:; _RAM_D6AB_MenuTimer expired
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK
  jr z, ++

  ; GG: start, gear to gear + player 2 skip on
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +++
  ; GG: check for Gear to Gear
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_1_MASK
  jr z, ++
  jr +++

+:; Check for Start button
  in a, (PORT_GG_START)
  and PORT_GG_START_MASK
  jr nz, +++
++:
  ; Either player pressed Start
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, LABEL_8C2C_GoToTwoPlayerMenu
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_81C1_InitialiseSelectGameMenu
+++:
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_8C23_StartCourseSelect:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_B70B_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_8C2C_GoToTwoPlayerMenu:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_8953_InitialiseTwoPlayersMenu
  jp LABEL_80FC_EndMenuScreenHandler

; 3rd entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8C35_Handler_MenuScreen_SelectPlayerCount:
  call LABEL_B9C4_CycleGearToGearTrackSelectIndex
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr z, +

  call LABEL_B433_ResetMenuTimerOnControlPress

  ; Increment timer
  ld hl, (_RAM_D6AB_MenuTimer)
  inc hl
  ld (_RAM_D6AB_MenuTimer), hl
  ld a, h
  cp $03 ; i.e. we reached $300 = 15.36s @ 50Hz, 12.8s @ 60Hz
  jr nz, +

  ; Reset to the start
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_8114_MenuIndex0_TitleScreen_Initialise
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_8CA2_ProcessMenuControls_Player1Priority
  jp +

.ifdef UNNECESSARY_CODE
  call LABEL_8CB1_
.endif

+:
  ld a, (_RAM_D6A0_MenuSelection)
  or a
  jp z, LABEL_80FC_EndMenuScreenHandler
  ; Something is currently selected
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jp nz, LABEL_80FC_EndMenuScreenHandler
  ; And a button was pressed
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr z, ++
  ; Must be one/two players
  ld a, (_RAM_D6A0_MenuSelection)
  dec a
  jr nz, +
  ; One player
  call LABEL_AFCD_InitialiseOnePlayerMenu
  jp LABEL_80FC_EndMenuScreenHandler

+:; Two players
  call LABEL_8953_InitialiseTwoPlayersMenu
  jp LABEL_80FC_EndMenuScreenHandler

++:; Two player game type
  ld a, (_RAM_D6A0_MenuSelection)
  dec a
  jr nz, +
  ; Two player tournament
  ld a, $01
  ld (_RAM_DC34_IsTournament), a
  call LABEL_8A30_InitialiseTwoPlayersRaceSelectMenu
  jp LABEL_80FC_EndMenuScreenHandler

+:; Two player single race
  call LABEL_8A30_InitialiseTwoPlayersRaceSelectMenu
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_8CA2_ProcessMenuControls_Player1Priority:
  ld a, (_RAM_D680_Player1Controls_Menus) ; Check if any buttons we care about are pressed
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  cp BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  jr nz, +
  ; None pressed (active low)
  ; We allow player 2 to influence things
  call LABEL_B9A3_CombinePlayerMenuControlButtons
  jp ++

LABEL_8CB1_:
+:; Yes - copy buttons to shared place and analyse
  ld a, (_RAM_D680_Player1Controls_Menus)
  ld (_RAM_D6C9_ControllingPlayersLR1Buttons), a
++:
  ; Now we act on the menu controls
  and BUTTON_L_MASK ; $04
  jr z, +
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_R_MASK ; $08
  jr z, ++
  ret

+: ; Hand points left, selection = 1
  ld hl, DATA_2B356_SpriteNs_HandLeft
  CallRamCode LABEL_3BBB5_PopulateSpriteNs
  ld a, $01
  ld (_RAM_D6A0_MenuSelection), a
  ret

++: ; Hand points right, selection = 2
  ld hl, DATA_2B36E_SpriteNs_HandRight
  CallRamCode LABEL_3BBB5_PopulateSpriteNs
  ld a, $02
  ld (_RAM_D6A0_MenuSelection), a
  ret

LABEL_8CDB_ResetCheats:
  ld hl, _RAM_DC49_CheatsStart
  xor a
  ld c, _RAM_DC51_CheatsEnd-_RAM_DC49_CheatsStart
-:
  ld (hl), a
  inc hl
  dec c
  jr nz, -
  ret

; 4th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8CE7_Handler_MenuScreen_OnePlayerSelectCharacter:
  call LABEL_996E_
  call LABEL_95C3_
  call LABEL_9B87_
  call LABEL_9D4E_
  ld a, (_RAM_D6B8_)
  or a
  jr z, LABEL_8D28_MenuScreenHandlerDone
  ld a, (_RAM_D6B8_)
  sub $01
  ld (_RAM_D6B8_), a
  cp $10
  jr z, +
  cp $D0
  jr nc, LABEL_8D28_MenuScreenHandlerDone
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, LABEL_8D28_MenuScreenHandlerDone
+:
  ld a, (_RAM_D6A2_)
  ld (_RAM_DBFB_PortraitCurrentIndex), a
  ld a, (_RAM_D6AD_)
  ld (_RAM_DBFC_), a
  ld a, (_RAM_D6AE_)
  ld (_RAM_DBFD_), a
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_8272_
LABEL_8D28_MenuScreenHandlerDone:
  jp LABEL_80FC_EndMenuScreenHandler

; 5th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8D2B_Handler_MenuScreen_RaceName:
  ld a, (_RAM_D6C1_)
  dec a
  jr z, ++
  call LABEL_BA63_
  ; Decrement timer
  ld hl, (_RAM_D6AB_MenuTimer)
  dec hl
  ld (_RAM_D6AB_MenuTimer), hl
  ld a, h
  or a
  jr nz, +++
  ld a, l
  or a
  jr z, +
  cp $FF
  jr nc, +++
  ; Counter reached $ff
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:; Timer reached zero, or button 1 was pressed at timer = $ff
  call LABEL_B368_
++:
  ; Increment timer
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
  cp $04
  jr nz, +++
  ; Wait for timer to reach 4
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call LABEL_BD2F_PaletteFade
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp LABEL_80FC_EndMenuScreenHandler

; 7th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8D79_Handler_MenuScreen_Qualify:
  ld a, (_RAM_DBCE_Player1Qualified)
  or a
  jr z, ++++
  ; Decrement timer
  ld hl, (_RAM_D6AB_MenuTimer)
  dec hl
  ld (_RAM_D6AB_MenuTimer), hl
  ld a, h
  or a
  jr nz, ++
  ld a, l
  or a
  jr z, +
  ld a, l
  cp $FF
  jr nc, ++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:; Timer expired, or button press expired it early
  ld a, $01
  ld (_RAM_D6B9_), a
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, +++
  call LABEL_841C_
++:
  jp LABEL_80FC_EndMenuScreenHandler

+++:
  call LABEL_84AA_MenuIndex5_Initialise
  jp LABEL_80FC_EndMenuScreenHandler

++++:
  call LABEL_9D4E_
  ; Decrement timer
  ld hl, (_RAM_D6AB_MenuTimer)
  dec hl
  ld (_RAM_D6AB_MenuTimer), hl
  ld a, l
  or h
  or a
  jr nz, +
  ; Timer reached 0, reset to title screen
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_8114_MenuIndex0_TitleScreen_Initialise
+:
  jp LABEL_80FC_EndMenuScreenHandler

; 8th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8DCC_Handler_MenuScreen_WhoDoYouWantToRace:
  call LABEL_996E_
  call LABEL_95C3_
  call LABEL_9B87_
  call LABEL_9D4E_
  call LABEL_9E70_
  ld a, (_RAM_D6C0_)
  cp $00
  jr z, +
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  in a, (PORT_GG_START)
  and PORT_GG_START_MASK
  jr nz, +
  ld a, $01
  ld (_RAM_D6C1_), a
+:
  ld a, (_RAM_D6C1_)
  cp $01
  jr nz, +
  ld a, (_RAM_D6A2_)
  ld (_RAM_DBFB_PortraitCurrentIndex), a
  ld a, (_RAM_D6AD_)
  ld (_RAM_DBFC_), a
  ld a, (_RAM_D6AE_)
  ld (_RAM_DBFD_), a
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_8486_InitialiseDisplayCase
+:
  jp LABEL_80FC_EndMenuScreenHandler

; 9th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8E15_Handler_MenuScreen_DisplayCase:
  ; bc = car index
  ld b, $00
  ld a, (_RAM_D6C2_DisplayCase_FlashingCarIndex)
  ld c, a
  ; Flip bit
  ld a, (_RAM_D6AB_MenuTimer.Hi)
  xor $01
  ld (_RAM_D6AB_MenuTimer.Hi), a
  dec a
  jr z, +
  ; Bit is 1 -> increment timer
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:; See where the value is
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $37
  jr nc, +
  ; More than $37
  ; Filter to bit 2 -> change every 4 increments = 8 frames
  and $04
  cp $04
  jr z, +
  ; Bit 2 is 0 -> blank car
  ld a, (_RAM_DC0A_WinsInARow)
  cp WINS_IN_A_ROW_FOR_RUFFTRUX
  jp z, LABEL_B22A_DisplayCase_BlankRuffTrux
  call LABEL_AE46_DisplayCase_BlankCar
  jp LABEL_8E54_

+:; Bit 2 is 1 -> draw car
  ld a, (_RAM_DC0A_WinsInARow)
  cp WINS_IN_A_ROW_FOR_RUFFTRUX
  jp z, LABEL_B254_DisplayCase_RestoreRuffTrux
  call LABEL_AE94_DisplayCase_RestoreRectangle

LABEL_8E54_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld c, $60 ; 3.84s @ 50Hz (double length, see above)
  jp ++
+:ld c, $72 ; 3.8s @ 60Hz
++:ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp c
  jr z, +
  cp $37 ; 2.2s @ 50Hz, 1.8333s @ 60Hz for early finish if button is pressed
  jr c, ++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
  ; End screen
  ld a, $01
  ld (_RAM_D697_), a
+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC0A_WinsInARow)
  cp WINS_IN_A_ROW_FOR_RUFFTRUX
  jr nz, +
  ; Blank out the RuffTrux part, you don't get to "keep" it
  xor a
  ld (_RAM_DBD9_DisplayCaseData + 15), a
  ld (_RAM_DBD9_DisplayCaseData + 19), a
  ld (_RAM_DBD9_DisplayCaseData + 23), a
  call LABEL_8877_
  jp LABEL_80FC_EndMenuScreenHandler

+:; Initialise bonus race screen
  call LABEL_84AA_MenuIndex5_Initialise
++:
  jp LABEL_80FC_EndMenuScreenHandler

; 10th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8E97_Handler_MenuScreen_OnePlayerTrackIntro:
  ld a, (_RAM_D6C1_)
  dec a
  jr z, ++
  call LABEL_A9EB_

  ; Flip bit in the high byte
  ld a, (_RAM_D6AB_MenuTimer.Hi)
  xor $01
  ld (_RAM_D6AB_MenuTimer.Hi), a
  dec a
  jr z, +
  ; And increment the low one
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $B8 ; 7.36s @ 50Hz, 6.13333333333333s @ 60Hz (half rate)
  jr z, +
  cp $30 ; 1.92s @ 50Hz, 1.6s @ 60Hz (half rate) for button to proceed
  jr c, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call LABEL_B368_
++:
  ; Then increment to 4 before proceeding
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
  cp $04
  jr nz, +++
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call LABEL_BD2F_PaletteFade
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp LABEL_80FC_EndMenuScreenHandler

; 11th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8EF0_Handler_MenuScreen_OnePlayerChallengeResults:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $A0 ; 3.2s @ 50Hz, 2.66666666666667s @ 60Hz
  jr z, +
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
  cp $08 ; 0.16s @ 50Hz, 0.133333333333333s @ 60Hz -> first place
  jp z, _LABEL_A8ED_TournamentResults_FirstPlace
  cp $28 ; 0.8s @ 50Hz, 0.666666666666667s @ 60Hz -> second place
  jp z, _LABEL_A8F2_TournamentResults_SecondPlace
  cp $48 ; 1.44s @ 50Hz, 1.2s @ 60Hz
  jp z, _LABEL_A8F7_TournamentResults_ThirdPlace
  cp $68 ; 2.08s @ 50Hz, 1.73333333333333s @ 60Hz
  jp z, LABEL_A8FC_TournamentResults_FourthPlace
LABEL_8F10_:
  call LABEL_A7ED_
  jp LABEL_80FC_EndMenuScreenHandler

+:; Timer expired
  ld a, (_RAM_D6C1_)
  add a, $01
  ld (_RAM_D6C1_), a
  cp $F0
  jr z, +
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DBCF_LastRacePosition)
  cp $02
  jr nc, LABEL_8F73_LoseALife
  ; 1st or 2nd place
  call LABEL_B269_IncrementCourseSelectIndex
  cp Track_19_WinThisRaceToBeChampion
  jr z, +++
  cp Track_1A_RuffTrux1
  jr z, ++++
  call LABEL_A74F_
  cp $FF
  jr z, +
  call LABEL_85F4_
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_8486_InitialiseDisplayCase
++:
  jp LABEL_80FC_EndMenuScreenHandler

+++:
  ld a, $01
  ld (_RAM_DC3A_RequiredPositionForNextRace), a
  call LABEL_84AA_MenuIndex5_Initialise
  jp LABEL_80FC_EndMenuScreenHandler

++++:
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr z, +
  ; Have to play the same track again if you don't win
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  sub $01
  ld (_RAM_DBD8_TrackIndex_Menus), a
  jp LABEL_8F73_LoseALife

+:
  call LABEL_B877_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_8F73_LoseALife:
  ld a, (_RAM_DC09_Lives)
  sub $01
  ld (_RAM_DC09_Lives), a
  or a
  jr z, +
  xor a ; LifeWonOrLostMode_LifeLost
  ld (_RAM_DC38_LifeWonOrLost_Mode), a
  call LABEL_866C_MenuIndex3_LifeWonOrLost_Initialise
  jp LABEL_80FC_EndMenuScreenHandler

+:
  ld a, LifeWonOrLostMode_GameOver
  ld (_RAM_DC38_LifeWonOrLost_Mode), a
  call LABEL_866C_MenuIndex3_LifeWonOrLost_Initialise
  jp LABEL_80FC_EndMenuScreenHandler

; 12th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8F93_Handler_MenuScreen_UnknownB:
  call LABEL_A692_
  ; Flip bit in high byte
  ld a, (_RAM_D6AB_MenuTimer.Hi)
  xor $01
  ld (_RAM_D6AB_MenuTimer.Hi), a
  dec a
  jr z, +
  ; Increment counter
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $90 ; 2.88s @ 50Hz, 2.4s @ 60Hz
  jr z, +
  cp $37 ; 1.1s @ 50Hz, 0.916666666666667s @ 60Hz
  jr c, ++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_841C_
++:
  jp LABEL_80FC_EndMenuScreenHandler

; 13th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8FC4_Handler_MenuScreen_LifeWonOrLost:
  ld a, (_RAM_DC38_LifeWonOrLost_Mode)
  or a
  jr nz, +
  ; LifeWonOrLostMode_LifeLost
  ; Animate spite 0 downwards
  ld a, (_RAM_D721_SpriteY + 0)
  cp 224 ; bottom of the screen
  jr z, _LABEL_902E_LifeSpriteUpdateDone
  ; Else increment y
  add a, $01
  ld (_RAM_D721_SpriteY), a
  call LABEL_93CE_UpdateSpriteTable
  jp _LABEL_902E_LifeSpriteUpdateDone

+:; Other modes
  ld a, (_RAM_D721_SpriteY + 0)
  cp 225 ; $E1 ; Bottom of the screen
  jr z, _LABEL_902E_LifeSpriteUpdateDone
  ld a, (_RAM_DC38_LifeWonOrLost_Mode)
  cp LifeWonOrLostMode_RuffTruxWon
  jr nz, _LABEL_902E_LifeSpriteUpdateDone
  ; We are adding a life - animate the sprite upwards
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, (_RAM_D721_SpriteY + 0)
  cp $B0 ; target Y for SMS
  jr z, +++
  jr ++
+:ld a, (_RAM_D721_SpriteY)
  cp $A8 ; target Y for GG
  jr z, +++
.else
  ld a, (_RAM_D721_SpriteY)
.ifdef IS_GAME_GEAR
  cp $A8 ; target Y for GG
.else
  cp $B0 ; target Y for SMS
.endif
  jr z, +++
.endif
++: ; Else decrement Y
  sub $01
  ld (_RAM_D721_SpriteY), a
  call LABEL_93CE_UpdateSpriteTable
  jp _LABEL_902E_LifeSpriteUpdateDone

+++:
  ; Sprite got to the target - write it into the name table and hide it
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 18, 22 ; SMS
  jr ++
+:TilemapWriteAddressToHL 18, 21 ; GG
++:
.else
.ifdef IS_GAME_GEAR
  TilemapWriteAddressToHL 18, 21 ; GG
.else
  TilemapWriteAddressToHL 18, 22 ; SMS
.endif
.endif
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld a, 225 ; $E1 ; and set the Y position to signal it's been done
  ld (_RAM_D721_SpriteY), a
  call LABEL_93CE_UpdateSpriteTable

_LABEL_902E_LifeSpriteUpdateDone:
  ; Flip timer high bit
  ld a, (_RAM_D6AB_MenuTimer.Hi)
  xor $01
  ld (_RAM_D6AB_MenuTimer.Hi), a
  dec a
  jr z, +
  ; Decrement counter
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  sub $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $00
  jr z, +
  cp 1.92 * 50 ; $60 ; Started at 2.56s, so 0.64s minimum on time
  jr nc, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC38_LifeWonOrLost_Mode)
  dec a
  jr z, ++ ; LifeWonOrLostMode_GameOver
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, +
  ; Challenge mode - display case next
  call LABEL_8486_InitialiseDisplayCase
  jp LABEL_80FC_EndMenuScreenHandler

+:; Head to head mode - track intro next
  call LABEL_84C7_InitialiseOnePlayerTrackIntro
  jp LABEL_80FC_EndMenuScreenHandler

++: ; Game over - go to title screen
  call LABEL_8114_MenuIndex0_TitleScreen_Initialise
+++:
  jp LABEL_80FC_EndMenuScreenHandler

; 14th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_9074_Handler_MenuScreen_UnknownD:
  ld a, (_RAM_D6C1_)
  dec a
  jr z, ++
  ld a, (_RAM_D6AB_MenuTimer.Hi)
  xor $01
  ld (_RAM_D6AB_MenuTimer.Hi), a
  dec a
  jr z, +
  ; Increment every second frame
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $B8 ; 3.68s @ 50Hz, 3.06666666666667s @ 60Hz
  jr z, +
  cp $37 ; 1.1s @ 50Hz, 0.916666666666667s @ 60Hz
  jr c, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call LABEL_B368_
++:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
  cp $04
  jr nz, +++
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call LABEL_BD2F_PaletteFade
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_90CA_BlankTiles_BlankControls:
  ; Blank tiles
  TileWriteAddressToHL $00
  call LABEL_B35A_VRAMAddressToHL
  ld de, $3700 ; Size of tile area
-:xor a
  out (PORT_VDP_DATA), a
  dec de
  ld a, d
  or e
  jr nz, -
  ; Blank controls data
  ld a, NO_BUTTONS_PRESSED ; $3F
  ld (_RAM_D680_Player1Controls_Menus), a
  ld (_RAM_D681_Player2Controls_Menus), a
  ld (_RAM_D687_Player1Controls_PreviousFrame), a
  ret

LABEL_90E7_:
; Called once, could be inlined
  xor a
  ld (_RAM_D691_TitleScreenSlideshowIndex), a
  ld (_RAM_D692_SlideshowPointerOffset), a
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  ld a, 1
  ld (_RAM_D694_DrawCarPortraitTilemap), a
  ld a, MenuTileIndex_Title_Portraits.1
  ld (_RAM_D690_CarPortraitTileIndex), a
  TailCall LABEL_918B_MaybeDrawCarPortraitTilemap

LABEL_90FF_ReadControllers:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr nz, ++

  ; Master System mode
-:in a, (PORT_CONTROL_A) ; Read controller 1
  ld b, a
  and PORT_CONTROL_A_PLAYER1_MASK
  ld (_RAM_D680_Player1Controls_Menus), a ; Store

  ld a, (_RAM_DC3C_IsGameGear)
  or a
  JrNzRet + ; ret

  in a, (PORT_CONTROL_B) ; Read controller 2
  sla a
  sla a
  and %00111100  ; Shift and mask to relevant bits
  ld c, a
  ld a, b
  and %11000000  ; Mask in bits from the other port
  rl a
  rl a
  rl a
  or c
  ld (_RAM_D681_Player2Controls_Menus), a ; Store
+:ret

++:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, - ; Normal operation

  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr nz, +

  ; Read controller, as player 1, emit to GG port and use GG port data for player 2 controls
  in a, (PORT_CONTROL_A) ; Read controller 1
  and PORT_CONTROL_A_PLAYER1_MASK
  ld (_RAM_D680_Player1Controls_Menus), a
  out (PORT_GG_LinkSend), a ; Emit to GG link port?
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2) ; Read in from other Game Gear?
  ld (_RAM_D681_Player2Controls_Menus), a
  ret

+:
  ; Read controller, as player 2, emit to GG port and use GG port data for player 1 controls. We use the data from the previous frame, presumably for timing reasons?
  ld a, (_RAM_D687_Player1Controls_PreviousFrame)
  ld b, a
  in a, (PORT_CONTROL_A) ; Read controller 1
  and PORT_CONTROL_A_PLAYER1_MASK
  ld (_RAM_D687_Player1Controls_PreviousFrame), a ; Store
  out (PORT_GG_LinkSend), a ; Emit to GG link port
  ld a, b
  ld (_RAM_D681_Player2Controls_Menus), a ; My buttons go to player 2
  ld a, (_RAM_DC47_GearToGear_OtherPlayerControls1)
  ld (_RAM_D680_Player1Controls_Menus), a ; Other GG buttons go to player 1
  ret

LABEL_915E_ScreenOn:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENON
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_9167_ScreenOff:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENOFF
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_9170_BlankTilemap_BlankControlsRAM:
; Fills tilemap with e, then chains to LABEL_AF5D_BlankControlsRAM
  TilemapWriteAddressToHL 0, 0
  call LABEL_B35A_VRAMAddressToHL
  ld d, $00
  ld bc, 32*28 ; $0380 ; Size of tilemap
-:ld a, e
  out (PORT_VDP_DATA), a
  EmitDataToVDPImmediate8 0
  dec bc
  ld a, b
  or c
  jr nz, -
  TailCall LABEL_AF5D_BlankControlsRAM

LABEL_918B_MaybeDrawCarPortraitTilemap:
  ld a, (_RAM_D694_DrawCarPortraitTilemap)
  or a
  JrZRet _LABEL_91E7_ret
  ; Init tilemap sequence at the right point
  ld a, (_RAM_D690_CarPortraitTileIndex)
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ; We cycle this as it gets us all the vehicles in game order
  ; (index 0 is special)
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  cp 0
  jr nz, +
  TilemapWriteAddressToHL 11, 15
  jp ++
+:TilemapWriteAddressToHL 11, 14 ; For index 0 we draw a bit higher up - not sure why?
++:
  ; Draw a 10x8 rect from the selected index
  ; Or all blanks for portrait index 0
  xor a
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
--:call LABEL_B35A_VRAMAddressToHL
  ld e, 10 ; Width
-:ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  or a
  jr nz, +
  ld a, <MenuTileIndex_Font.Space ; Draw blank if index 0
  jp ++
+:ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
++:out (PORT_VDP_DATA), a
  xor a ; High byte = 0
  out (PORT_VDP_DATA), a
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
  add a, $01
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec e
  jr nz, -
  ld a, (_RAM_D68B_TilemapRectangleSequence_Row)
  cp 7 ; Height - 1
  jr z, +
  add a, $01
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
  ld de, TILEMAP_ROW_SIZE
  add hl, de
  jp --

+:; Tilemap drawing done
  call LABEL_9276_DrawVehicleName
  call LABEL_91E8_TitleScreenSlideshow_Increment
_LABEL_91E7_ret:
  ret

LABEL_91E8_TitleScreenSlideshow_Increment:
  ; Increment index
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  add a, 1
  ld (_RAM_D691_TitleScreenSlideshowIndex), a
  ; Skip choppers
  cp 6
  jr z, LABEL_91E8_TitleScreenSlideshow_Increment ; -> self
  ; Loop 9 -> 0
  cp 10
  jr nz, +
  xor a
  ld (_RAM_D691_TitleScreenSlideshowIndex), a
+:
.ifdef UNNECESSARY_CODE
  add a, $07
  ld (_RAM_D6D6_TitleScreenSlideshowIndexPlus7_Unused), a
.endif
  ld a, $01
  ld (_RAM_D6D4_Slideshow_PendingLoad), a
  ; Reset address to _RAM_C000_DecompressionTemporaryBuffer
  xor a ; ld a, <_RAM_C000_DecompressionTemporaryBuffer
  ld (_RAM_D68C_SlideshowRAMReadAddress.Lo), a
  ld a, >_RAM_C000_DecompressionTemporaryBuffer
  ld (_RAM_D68C_SlideshowRAMReadAddress.Hi), a
  ; Point decompressor to the next tileset
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  sla a
  ld d, $00
  ld e, a
  ld hl, _DATA_9254_VehiclePortraitOffsets
  add hl, de
  ld a, (hl)
  ld (_RAM_D7B5_DecompressorSource.Lo), a
  inc hl
  ld a, (hl)
  ld (_RAM_D7B5_DecompressorSource.Hi), a
  ; And the next write location
  ld a, (_RAM_D692_SlideshowPointerOffset) ; flip between 0 and 2 for the following lookup
  xor $02
  ld (_RAM_D692_SlideshowPointerOffset), a
  ld d, $00
  ld hl, _DATA_9268_SlideshowTileWriteAddresses
  ld e, a
  add hl, de
  ld a, (hl)
  ld (_RAM_D68E_SlideshowVRAMWriteAddress.Lo), a
  inc hl
  ld a, (hl)
  ld (_RAM_D68E_SlideshowVRAMWriteAddress.Hi), a
  ; Set tile index for tilemap drawing
  ld a, (_RAM_D690_CarPortraitTileIndex)
  xor MenuTileIndex_Title_Portraits.1 ~ MenuTileIndex_Title_Portraits.2 ;$50
  ld (_RAM_D690_CarPortraitTileIndex), a
  ; 
  xor a
  ld (_RAM_D695_SlideshowTileWriteCounter.Lo), a
  ld (_RAM_D695_SlideshowTileWriteCounter.Hi), a
  ld (_RAM_D694_DrawCarPortraitTilemap), a
  ; Start slow-loading tiles
  ld a, 1
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  ret

; Data from 9254 to 9267 (20 bytes)
_DATA_9254_VehiclePortraitOffsets:
; Pointers to compressed tile data for the title screen slideshow
; Index 0 is special, the value is not used
; Index 6 is skippwd
.dw DATA_2AB4D_Tiles_Portrait_RuffTrux
.dw DATA_FAA5_Tiles_Portrait_SportsCars
.dw DATA_1F3E4_Tiles_Portrait_Powerboats
.dw DATA_16F2B_Tiles_Portrait_FormulaOne
.dw DATA_F35D_Tiles_Portrait_FourByFour
.dw DATA_F765_Tiles_Portrait_Warriors
.dw $AB4D ; invalid
.dw DATA_16AC8_Tiles_Portrait_TurboWheels
.dw DATA_1736E_Tiles_Portrait_Tanks
.dw DATA_2AB4D_Tiles_Portrait_RuffTrux

; Data from 9268 to 926B (4 bytes)
_DATA_9268_SlideshowTileWriteAddresses:
  TileWriteAddressData MenuTileIndex_Title_Portraits.1
  TileWriteAddressData MenuTileIndex_Title_Portraits.2

; Data from 926C to 9275 (10 bytes)
_DATA_926C_VehiclePortraitPageNumbers:
; Pages containing "portrait" data for the title screen slideshow
; Index 0 is special, the value is not used
; Index 6 is skippwd
.db :DATA_2AB4D_Tiles_Portrait_RuffTrux
.db :DATA_FAA5_Tiles_Portrait_SportsCars
.db :DATA_1F3E4_Tiles_Portrait_Powerboats
.db :DATA_16F2B_Tiles_Portrait_FormulaOne
.db :DATA_F35D_Tiles_Portrait_FourByFour
.db :DATA_F765_Tiles_Portrait_Warriors
.db $04 ; invalid
.db :DATA_16AC8_Tiles_Portrait_TurboWheels
.db :DATA_1736E_Tiles_Portrait_Tanks
.db :DATA_2AB4D_Tiles_Portrait_RuffTrux

LABEL_9276_DrawVehicleName:
  ld a, :DATA_3ECA9_VehicleNames
  ld (_RAM_D741_RequestedPageIndex), a
  call LABEL_BEF5_TitleScreen_ClearText
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  or a
  rl a ; x16
  rl a
  rl a
  rl a
  ld hl, DATA_3ECA9_VehicleNames
  add a, l ; add it on
  ld l, a
  ld a, h
  adc a, 0
  ld h, a
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  cp $00 ; Text screen
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerTrackIntro ; TODO ???
  jr nc, ++
+:
  TilemapWriteAddressToDE 8, 22 ; (GG, SMS title screen)
  jp ++++
++:
  TilemapWriteAddressToDE 8, 27 ; (SMS track select)
  jp ++++
+++:
  TilemapWriteAddressToDE 8, 14 ; (text)
++++:
  call LABEL_B361_VRAMAddressToDE
  ld bc, 16
  CallRamCode LABEL_3BC6A_EmitText
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  or a
  JrNzRet + ; ret
  ld a, $01
  ld (_RAM_D6CB_MenuScreenState), a
+:ret

LABEL_92CB_SlowCopySlideshowTilesToVRAM:
  ld a, (_RAM_D6D4_Slideshow_PendingLoad)
  cp $01
  JrZRet +
  ld a, (_RAM_D693_SlowLoadSlideshowTiles)
  or a
  JrZRet +

  ; Retrieve pointers
  ld a, (_RAM_D68C_SlideshowRAMReadAddress.Hi)
  ld h, a
  ld a, (_RAM_D68C_SlideshowRAMReadAddress.Lo)
  ld l, a
  ld a, (_RAM_D68E_SlideshowVRAMWriteAddress.Hi)
  ld d, a
  ld a, (_RAM_D68E_SlideshowVRAMWriteAddress.Lo)
  ld e, a

  ; Do the work
  call LABEL_B361_VRAMAddressToDE
  CallRamCode LABEL_3BB93_Emit3bppTiles_2Rows
  
  ; Save them again
  ld a, h
  ld (_RAM_D68C_SlideshowRAMReadAddress.Hi), a
  ld a, l
  ld (_RAM_D68C_SlideshowRAMReadAddress.Lo), a
  ld a, d
  ld (_RAM_D68E_SlideshowVRAMWriteAddress.Hi), a
  ld a, e
  ld (_RAM_D68E_SlideshowVRAMWriteAddress.Lo), a
  
  ; Loop $140 times -> 80 tiles
  ld hl, (_RAM_D695_SlideshowTileWriteCounter)
  inc hl
  ld (_RAM_D695_SlideshowTileWriteCounter), hl
  dec h
  JrNzRet +
  ld a, l
  cp $40
  JrNzRet +
  ; Slow load is done, do tilemap
  xor a
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  ld a, 1
  ld (_RAM_D694_DrawCarPortraitTilemap), a
+:ret

LABEL_9317_InitialiseHandSprites:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_936E_TitleScreenHandXs_GG
  ld de, DATA_9386_TitleScreenHandYs_GG
  jr ++
+:ld hl, DATA_939E_TitleScreenHandXs_SMS
  ld de, DATA_93B6_TitleScreenHandYs_SMS
++:
  ld ix, _RAM_D6E1_SpriteX
  ld iy, _RAM_D721_SpriteY
  ld bc, 24 ; counter

-:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TrackSelect
  jr z, +
  jp ++

+:; Track select
  ld a, (hl)
  add a, $43 ; Shift right
  ld (ix+0), a
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +++
  ld a, (de)
  add a, $18 ; And down (SMS)
  ld (iy+0), a
  jp ++++

++:
  ; Not track select: original X
  ld a, (hl)
  ld (ix+0), a
+++:
  ; Not track select, or GG: original Y
  ld a, (de)
  ld (iy+0), a
++++:
  ; Move pointers on and loop
  inc hl
  inc de
  inc ix
  inc iy
  dec c
  ld a, c
  or a
  jr nz, -
  ld hl, DATA_2B33E_SpriteNs_HandFist
  JumpToRamCode LABEL_3BBB5_PopulateSpriteNs

DATA_936E_TitleScreenHandXs_GG:
.db $6E $76 $7E $86 $8E $96
.db $6E $76 $7E $86 $8E $96
.db $6E $76 $7E $86 $8E $96
.db $6E $76 $7E $86 $8E $96

DATA_9386_TitleScreenHandYs_GG:
.db $90 $90 $90 $90 $90 $90
.db $98 $98 $98 $98 $98 $98
.db $A0 $A0 $A0 $A0 $A0 $A0
.db $A8 $A8 $A8 $A8 $A8 $A8

DATA_939E_TitleScreenHandXs_SMS:
; X coordinates of sprites on title screen
.db $65 $6D $75 $7D $85 $8D
.db $65 $6D $75 $7D $85 $8D
.db $65 $6D $75 $7D $85 $8D
.db $65 $6D $75 $7D $85 $8D

DATA_93B6_TitleScreenHandYs_SMS:
; Y coordinates of sprites on title screen
.db $78 $78 $78 $78 $78 $78
.db $80 $80 $80 $80 $80 $80
.db $88 $88 $88 $88 $88 $88
.db $90 $90 $90 $90 $90 $90

LABEL_93CE_UpdateSpriteTable:
  ld hl, SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK + $80 ; $7F80 ; sprite XN
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 32
  ld hl, _RAM_D6E1_SpriteX
  ld de, _RAM_D701_SpriteN
-:
  ld a, (hl)
  out (PORT_VDP_DATA), a
  ld a, (de)
  out (PORT_VDP_DATA), a
  inc hl
  inc de
  dec c
  ld a, c
  or a
  jr nz, -
  ld hl, SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK + $00 ; $7F00 ; Sprite Y
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 32
  ld hl, _RAM_D721_SpriteY
-:
  ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  dec c
  ld a, c
  or a
  jr nz, -
  ret

LABEL_9400_BlankSprites:
  ld hl, SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK + $80 ; $7F80 ; Sprite XNs
  call LABEL_B35A_VRAMAddressToHL
  ; Blank them out
  ld bc, 64
-:xor a
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, c
  or a
  jr nz, -
  ld hl, SPRITE_TABLE_ADDRESS | VRAM_WRITE_MASK + $00 ; $7F00 ; Sprite Ys
  call LABEL_B35A_VRAMAddressToHL
  ; Blank them out
  ld bc, 64
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, c
  or a
  jr nz, -
  ; Blank out RAM versions
  ld bc, 32*3
  ld hl, _RAM_D6E1_SpriteData
-:xor a
  ld (hl), a
  inc hl
  dec bc
  ld a, c
  or a
  jr nz, -
  ret

LABEL_9434_LoadCursorTiles:
  ld a, :DATA_22BEC_Tiles_Cursor
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_22BEC_Tiles_Cursor
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 8 * 8 ; 8 tiles
  TileWriteAddressToHL <MenuTileIndex_SelectPlayers_Cursor
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

LABEL_9448_LoadHeaderTiles:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr c, +
  TileWriteAddressToHL $110
  jp ++
+:TileWriteAddressToHL $c2
++:
  call LABEL_B35A_VRAMAddressToHL
  ld a, :DATA_2FDE0_Tiles_SmallLogo
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_2FDE0_Tiles_SmallLogo
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 22 * 8 ; 22 tiles
  call LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM
  ld a, :DATA_13D7F_Tiles_MicroMachinesText
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_13D7F_Tiles_MicroMachinesText
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 24 * 8 ; 24 tiles
  call LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerMode
  JrZRet + ; ret z
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr nz, LABEL_949B_LoadHeadToHeadTextTiles

LABEL_948A_LoadChallengeTextTiles:
  ld a, :DATA_2B386_Tiles_ChallengeText
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_2B386_Tiles_ChallengeText
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 16 * 8 ; 16 tiles
  jp LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM ; and ret

LABEL_949B_LoadHeadToHeadTextTiles:
  ld a, :DATA_2B4CA_Tiles_HeadToHeadText
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_2B4CA_Tiles_HeadToHeadText
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 14 * 8 ; 14 tiles
  jp LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM

.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_94AD_DrawHeaderTilemap:
  ld a, :DATA_13F38_Tilemap_SmallLogo
  ld (_RAM_D741_RequestedPageIndex), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr c, +
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  jp ++
+:xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
++:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 1, 1
  jr ++
+:TilemapWriteAddressToDE 6, 5
++:
  call LABEL_B361_VRAMAddressToDE
  ld hl, DATA_13F38_Tilemap_SmallLogo
  ld a, $08
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $03
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, (_RAM_D6C8_HeaderTilesIndexOffset)
  ld c, a
  ld a, $C2
  sub c
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode LABEL_3BB57_EmitTilemapRectangle
  ; Fall through

LABEL_94F0_DrawHeaderTextTilemap:
  ld a, :DATA_13F50_Tilemap_MicroMachinesText
  ld (_RAM_D741_RequestedPageIndex), a
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, ++
  ; SMS
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr nz, +
  TilemapWriteAddressToDE 10, 2
  jp +++
+:TilemapWriteAddressToDE 9, 2
  jp +++

++:; GG
  TilemapWriteAddressToDE 14, 5
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerChallengeResults
  jr nz, +++
  TilemapWriteAddressToDE 6, 5

+++:; Both
  call LABEL_B361_VRAMAddressToDE
  ld hl, DATA_13F50_Tilemap_MicroMachinesText
  ld a, $0C ; 12x2
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $02
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, (_RAM_D6C8_HeaderTilesIndexOffset)
  ld c, a
  ld a, $D8
  sub c
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode LABEL_3BB57_EmitTilemapRectangle

  ld a, :DATA_2B4BA_Tilemap_ChallengeText
  ld (_RAM_D741_RequestedPageIndex), a
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, ++
  ; SMS
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr nz, +
  TilemapWriteAddressToDE 22, 2
  jp +++
+:TilemapWriteAddressToDE 21, 2
  jp +++

++:; GG
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerChallengeResults
  jr z, +
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr nz, ++
  TilemapWriteAddressToDE 17, 7
  jp +++
+:TilemapWriteAddressToDE 18, 5
  jp +++
++:
  TilemapWriteAddressToDE 15, 7

+++:; Both
  call LABEL_B361_VRAMAddressToDE
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr nz, +
  ; Challenge
  ld hl, DATA_2B4BA_Tilemap_ChallengeText
  ld a, $08 ; 8x2
  jp ++

+:; Head to head
  ld hl, DATA_2B5BE_Tilemap_HeadToHeadText
  ld a, $0A ; 10x2
++:
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $02
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, (_RAM_D6C8_HeaderTilesIndexOffset)
  ld c, a
  ld a, $F0
  sub c
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode LABEL_3BB57_EmitTilemapRectangle
  ret

LABEL_959C_LoadPunctuationTiles:
  ld a, :DATA_22B2C_Tiles_PunctuationAndLine
  ld (_RAM_D741_RequestedPageIndex), a
  TileWriteAddressToHL MenuTileIndex_Punctuation
  call LABEL_B35A_VRAMAddressToHL
  ld e, 4 * 8 ; 4 tiles
  ld hl, DATA_22B2C_Tiles_PunctuationAndLine
  JumpToRamCode LABEL_3BB45_Emit3bppTileDataToVRAM ; and ret

LABEL_95AF_DrawHorizontalLineIfSMS:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  JrZRet + ; ret if GG
  ; SMS
  ld e, $20 ; Counter: 32 tiles
-:EmitDataToVDPImmediate16 $1B7 ; Tile index: horizontal bar
  dec e
  jr nz, -
+:ret

LABEL_95C3_:
  ld a, (_RAM_D6B4_)
  cp $01
  JrZRet +
  ld a, (_RAM_D6BA_)
  cp $00
  JrNzRet +
  ld a, (_RAM_D6B0_)
  cp $00
  JrNzRet +
  ; Decrement timer, wait for it to hit 0
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:ret

++:
  ld a, (_RAM_D6A4_)
  cp $00
  jp nz, LABEL_96F6_
  ld a, (_RAM_D6A3_)
  cp $01
  jr z, LABEL_9636_
  cp $02
  jp z, LABEL_96A3_
  ld a, (_RAM_D6C6_)
  dec a
  jr z, +
-:
  ld a, (_RAM_D680_Player1Controls_Menus)
  jp ++

+:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  cp $01
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, -
+:
  ld a, (_RAM_D681_Player2Controls_Menus)
++:
  ld c, a
  and BUTTON_R_MASK ; $08
  jr z, +++
  ld a, c
  and BUTTON_L_MASK ; $04
  jr z, LABEL_9693_
  ret

+++: ; Right
  ld a, $01
  ld (_RAM_D6A3_), a
  ld a, $02
  ld (_RAM_D6A4_), a
  call LABEL_97AF_
  jp LABEL_96F6_

LABEL_9636_: ; Left
  ld a, (_RAM_D6A4_)
  cp $00
  jp nz, LABEL_96F6_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, ++
  ; SMS only
  ld a, (_RAM_D6A2_)
  add a, $01
  cp $30
  jr nz, +
  xor a
+:
  ld (_RAM_D6A2_), a
  sub $03
  and $07
  jp nz, LABEL_96EC_
  jp +++

++:
  ld a, (_RAM_D6A2_)
  add a, $01
  cp $1E
  jr nz, +
  xor a
+:
  ld (_RAM_D6A2_), a
  ld hl, DATA_9817_
  ld b, $00
  ld a, (_RAM_D6A2_)
  ld c, a
  add hl, bc
  ld a, (hl)
  or a
  jr z, LABEL_96EC_
+++:
  xor a
  ld (_RAM_D6A3_), a
  ld a, $08
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, +
  ld a, (_RAM_D7B3_)
  or a
  jr z, +
  sub $01
  ld (_RAM_D7B3_), a
+:
  jp LABEL_96EC_

LABEL_9693_:
  ld a, $02
  ld (_RAM_D6A3_), a
  ld a, $02
  ld (_RAM_D6A4_), a
  call LABEL_977F_
  jp LABEL_96F6_

LABEL_96A3_:
  ld a, (_RAM_D6A4_)
  cp $00
  jr nz, LABEL_96F6_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, ++
  ld a, (_RAM_D6A2_)
  sub $01
  cp $FF
  jr nz, +
  ld a, $2F
+:
  ld (_RAM_D6A2_), a
  sub $03
  and $07
  jr nz, LABEL_96EC_
  jp +++

++:
  ld a, (_RAM_D6A2_)
  sub $01
  cp $FF
  jr nz, +
  ld a, $1D
+:
  ld (_RAM_D6A2_), a
  ld hl, DATA_9817_
  ld b, $00
  ld a, (_RAM_D6A2_)
  ld c, a
  add hl, bc
  ld a, (hl)
  or a
  jr z, LABEL_96EC_
+++:
  xor a
  ld (_RAM_D6A3_), a
  ld a, $08
  ld (_RAM_D6AB_MenuTimer.Lo), a
LABEL_96EC_:
  ld b, $00
  ld a, (_RAM_D6A2_)
  ld c, a
  TailCall LABEL_97EA_DrawDriverPortraitColumn

LABEL_96F6_:
  ld a, (_RAM_D6A4_)
  cp $01
  jr z, LABEL_973C_DrawPortrait_RightTwoColumns
  ld hl, DATA_9773_TileWriteAddresses_AvailablePortraits
LABEL_9700_:
  ld a, (_RAM_DC3C_IsGameGear)
  cp $01
  jr z, +
  ld a, (_RAM_D6A2_)
  sub $03
  sra a
  sra a
  jr ++

+:
  push hl
    ld a, (_RAM_D6A2_)
    ld c, a
    ld b, $00
    ld hl, DATA_9849_
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
  ld (_RAM_D6A8_DisplayCaseTileAddress), de
  call LABEL_B361_VRAMAddressToDE
  ld a, (_RAM_D6AA_)
  call LABEL_9F81_DrawPortrait_ThreeColumns
  ld a, (_RAM_D6A4_)
  sub $01
  ld (_RAM_D6A4_), a
  ret

LABEL_973C_DrawPortrait_RightTwoColumns:
  ld hl, (_RAM_D6A8_DisplayCaseTileAddress)
  ld bc, 15 * TILE_DATA_SIZE ; $01E0
  add hl, bc
  call LABEL_B35A_VRAMAddressToHL
  ld hl, (_RAM_D6A6_DisplayCase_Source)
  ld a, (_RAM_D6AA_)
  call LABEL_9FB8_DrawOrBlank10PortraitTiles
  ld a, (_RAM_D6A4_)
  sub $01
  ld (_RAM_D6A4_), a
  TailCall LABEL_AECD_

; Data from 975B to 9766 (12 bytes)
DATA_975B_TileWriteAddresses_SMS:
  TileWriteAddressData $13c
  TileWriteAddressData $15a
  TileWriteAddressData $178
  TileWriteAddressData $196
  TileWriteAddressData $100
  TileWriteAddressData $11e

; Data from 9767 to 9772 (12 bytes)
DATA_9767_TileWriteAddresses_GG:
  TileWriteAddressData $11e
  TileWriteAddressData $13c
  TileWriteAddressData $15a
  TileWriteAddressData $178
  TileWriteAddressData $196
  TileWriteAddressData $100

; Data from 9773 to 977E (12 bytes)
DATA_9773_TileWriteAddresses_AvailablePortraits:
  TileWriteAddressData MenuTileIndex_SelectPlayers_AvailablePortraits.6
  TileWriteAddressData MenuTileIndex_SelectPlayers_AvailablePortraits.1
  TileWriteAddressData MenuTileIndex_SelectPlayers_AvailablePortraits.2
  TileWriteAddressData MenuTileIndex_SelectPlayers_AvailablePortraits.3
  TileWriteAddressData MenuTileIndex_SelectPlayers_AvailablePortraits.4
  TileWriteAddressData MenuTileIndex_SelectPlayers_AvailablePortraits.5

LABEL_977F_:
  ld a, (_RAM_D6AE_)
  sub $01
  cp $FF
  jr nz, +
  ld a, $0A
+:
  ld (_RAM_D6AE_), a
  ld a, (_RAM_D6AD_)
  sub $01
  cp $FF
  jr nz, +
  ld a, $0A
+:
  ld (_RAM_D6AD_), a
  ld c, a
  ld b, $00
  ld hl, _RAM_DBFE_PlayerPortraitValues
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6AA_), a
  ld hl, DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  ret

LABEL_97AF_:
  ld a, (_RAM_D6AD_)
  add a, $01
  cp $0B
  jr nz, +
  ld a, $00
+:
  ld (_RAM_D6AD_), a
  ld a, (_RAM_D6AE_)
  add a, $01
  cp $0B
  jr nz, +
  ld a, $00
+:
  ld (_RAM_D6AE_), a
  ld c, a
  ld b, $00
  ld hl, _RAM_DBFE_PlayerPortraitValues
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6AA_), a
  ld hl, DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  ret

; Data from 97DF to 97E9 (11 bytes)
DATA_97DF_8TimesTable:
  TimesTableLo 0 8 11

LABEL_97EA_DrawDriverPortraitColumn:
; Seems to be what it does, not clear how yet
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS
  ld a, :DATA_1B7A7_SMS
  ld (_RAM_D741_RequestedPageIndex), a
  TilemapWriteAddressToHL 0, 20
  call LABEL_B35A_VRAMAddressToHL
  ld hl, DATA_1B7A7_SMS
  add hl, bc ; Offset into data
  ld e, $C0 ; entry count
  JumpToRamCode LABEL_3BBD8_EmitTilemapUnknown2

+:
  ld a, :DATA_1B987_GG
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_1B987_GG
  add hl, bc
  ld b, $42
  ld c, $0B
  TilemapWriteAddressToDE 6, 16
  JumpToRamCode LABEL_3BBF8_EmitTilemapUnknown

; Data from 9817 to 9848 (50 bytes)
DATA_9817_:
; = (index - 2) % 5 == 0
.db $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00
.db $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00
.db $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01
.db $00 $00

; Data from 9849 to 987A (50 bytes)
DATA_9849_:
; = floor(index / 5) * 2
.db $00 $00 $00 $00 $00 $02 $02 $02 $02 $02 $04 $04 $04 $04 $04 $06
.db $06 $06 $06 $06 $08 $08 $08 $08 $08 $0A $0A $0A $0A $0A $0C $0C
.db $0C $0C $0C $0E $0E $0E $0E $0E $10 $10 $10 $10 $10 $12 $12 $12
.db $12 $12

LABEL_987B_BlankTileForBlankPortraits:
  TileWriteAddressToHL MenuTileIndex_SelectPlayers_Blank
  call LABEL_B35A_VRAMAddressToHL
  ld bc, TILE_DATA_SIZE
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, c
  or a
  jr nz, -
  ret

LABEL_988D_LoadCursorSprites:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_98AE_PlayerSelectCursorSprites_SMS
  jp ++
+:ld hl, DATA_990E_PlayerSelectCursorSprites_GG
++:ld de, _RAM_D6E1_SpriteX
  ld bc, 32 * 3 ; data size (all X, N, Ys)
-:ld a, (hl) ; ldir
  ld (de), a
  inc hl
  inc de
  dec c
  ld a, c
  or a
  jr nz, -
  jp LABEL_93CE_UpdateSpriteTable ; and ret
  
.macro PlayerSelectCursorData args x, y, w, h
  ; Cursor coordinates are 32 X, N and Y bytes
  ; defining the cursor position in the order top,
  ; left, right, bottom in each section.
  ; X top
  TimesTableLo x 8 w
  .if w < 8
    .dsb 8-w $ff
  .endif
  ; X left
  .dsb h-2 x
  .if h < 10
    .dsb 10-h $ff
  .endif
  ; X right
  .dsb h-2 x+(w-1)*8
  .if h < 10
    .dsb 10-h $ff
  .endif
  ; X bottom
  TimesTableLo x 8 w
  .if w < 8
    .dsb 8-w $ff
  .endif
  ; Indexes
  .db MenuTileIndex_Cursor.TopLeft
  .dsb w-2 MenuTileIndex_Cursor.Top
  .db MenuTileIndex_Cursor.TopRight
  .if w < 8
    .dsb 8-w $ff
  .endif
  .dsb 8 MenuTileIndex_Cursor.Left  ; no cutting short
  .dsb 8 MenuTileIndex_Cursor.Right ; no cutting short
  .db MenuTileIndex_Cursor.BottomLeft
  .dsb w-2 MenuTileIndex_Cursor.Bottom
  .db MenuTileIndex_Cursor.BottomRight
  .if w < 8
    .dsb 8-w $ff
  .endif
  ; Y top
  .dsb w y
  .if w < 8
    .dsb 8-w $ff
  .endif
  ; Y left, right
  .repeat 2
    TimesTableLo y+8 8 h-2
    .if h < 10
      .dsb 10-h $ff
    .endif
  .endr
  ; Y bottom
  .dsb w y+(h-1)*8
  .if w < 8
    .dsb 8-w $ff
  .endif
.endm

; Data from 98AE to 990D (96 bytes)
DATA_98AE_PlayerSelectCursorSprites_SMS:
  PlayerSelectCursorData $62 $8f 8 10

DATA_990E_PlayerSelectCursorSprites_GG:
  PlayerSelectCursorData $40 $77 7 8

LABEL_996E_:
  ld a, (_RAM_D6C6_)
  dec a
  jr nz, +
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jp z, LABEL_9A0E_
+:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  JrZRet _LABEL_99D2_ret
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  ; Flash every 8 frames
  sra a
  sra a
  sra a
  and $01
  jp nz, LABEL_9A0E_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jp z, LABEL_9A6D_
  TilemapWriteAddressToHL 4, 16
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_D6C0_)
  dec a
  jr z, +++
  ld a, (_RAM_D6CA_)
  dec a
  jr z, ++++
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_WhoDoYouWantToRace
  jr z, +
  jp ++

+:
  ld bc, $0018
  ld hl, TEXT_9A3D_WhoDoYouWantToRace
  TailCall LABEL_A5B0_EmitToVDP_Text

++:
  ld bc, $0018
  ld hl, TEXT_9A25_WhoDoYouWantToBe
  TailCall LABEL_A5B0_EmitToVDP_Text

+++:
  ld bc, $0018
  ld hl, TEXT_9A55_PushStartToContinue
  call LABEL_A5B0_EmitToVDP_Text
_LABEL_99D2_ret:
  ret

++++:
  TilemapWriteAddressToHL 13, 16
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  ld c, a
  ld b, $00
  ld hl, TEXT_A6EF_OpponentNames
  add hl, bc
  ld bc, $0007
  call LABEL_A5B0_EmitToVDP_Text
  EmitDataToVDPImmediate16 $1b6 ; TIle index: ???
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  cp $10
  jr z, +
  TilemapWriteAddressToHL 7, 16
  jp ++
+:TilemapWriteAddressToHL 5, 16
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0009
  ld hl, TEXT_9B7E_Handicap
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_9A0E_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jp z, LABEL_9B18_
  TilemapWriteAddressToHL 4, 16
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0018
  ld hl, TEXT_AAAE_Blanks
  TailCall LABEL_A5B0_EmitToVDP_Text

TEXT_9A25_WhoDoYouWantToBe:     .asc " WHO DO YOU WANT TO BE? "
TEXT_9A3D_WhoDoYouWantToRace:   .asc "WHO DO YOU WANT TO RACE?"
TEXT_9A55_PushStartToContinue:  .asc " PUSH START TO CONTINUE "

LABEL_9A6D_:
  ld a, (_RAM_D6C0_)
  dec a
  jr z, LABEL_9ABB_
  ld a, (_RAM_D6CA_)
  dec a
  jp z, LABEL_9AE9_
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_9B46_WhoDo
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_9B4E_YouWant
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_WhoDoYouWantToRace
  jr z, +
  jp ++

+:
  ld hl, TEXT_9B5E_ToRace
  call LABEL_A5B0_EmitToVDP_Text
  JpRet _LABEL_99D2_ret

++:
  ld hl, TEXT_9B56_ToBe
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_9ABB_:
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_9B66_Push
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_9B6E_StartTo
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_9B76_Continue
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_9AE9_:
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_9B7E_Handicap
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 19, 19
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  ld c, a
  ld b, $00
  ld hl, TEXT_A6EF_OpponentNames
  add hl, bc
  inc hl
  ld bc, $0006
  call LABEL_A5B0_EmitToVDP_Text
  EmitDataToVDPImmediate16 $1b6 ; TIle index: ???
  ret

LABEL_9B18_:
  ; Blank text from above
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_AAAE_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_AAAE_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_AAAE_Blanks
  TailCall LABEL_A5B0_EmitToVDP_Text

TEXT_9B46_WhoDo:    .asc "WHO DO  "
TEXT_9B4E_YouWant:  .asc "YOU WANT"
TEXT_9B56_ToBe:     .asc "TO BE ? "
TEXT_9B5E_ToRace:   .asc "TO RACE?"
TEXT_9B66_Push:     .asc "PUSH    "
TEXT_9B6E_StartTo:  .asc "START TO"
TEXT_9B76_Continue: .asc "CONTINUE"
TEXT_9B7E_Handicap: .asc "HANDICAP "

LABEL_9B87_:
  ld a, (_RAM_D6BA_)
  cp $00
  JpNzRet _LABEL_9C5D_ret
  ld a, (_RAM_D6A3_)
  cp $00
  JpNzRet _LABEL_9C5D_ret
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $08
  JpZRet _LABEL_9C5D_ret
  ld a, (_RAM_D6B0_)
  cp $01
  jp z, LABEL_9C64_
  ld a, (_RAM_D6B4_)
  cp $01
  JpZRet _LABEL_9C5D_ret
  ld a, (_RAM_D6C6_)
  cp $01
  jr z, +
-:
  ld a, (_RAM_D680_Player1Controls_Menus)
  jp ++

+:
  ld a, (_RAM_D7B3_)
  cp $00
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, -
+:
  ld a, (_RAM_D681_Player2Controls_Menus)
++:
  and BUTTON_1_MASK ; $10
  JpNzRet _LABEL_9C5D_ret
+++:
  ld a, (_RAM_D6C4_)
  cp $FF
  jr z, +
  add a, $02
  ld c, a
  ld a, (_RAM_D6B9_)
  cp c
  jr nz, +
  jp LABEL_9C5E_

+:
  ld a, (_RAM_D6B9_)
  cp $04
  jr z, LABEL_9C5E_
  ld e, a
  ld d, $00
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  add a, $01
  ld c, a
  ld a, (_RAM_D6AD_)
  add a, c
  cp $0B
  jr c, +
  sub $0B
+:; Look up x8
  ld c, a
  ld b, $00
  ld hl, _RAM_DBFE_PlayerPortraitValues
  add hl, bc
  ld a, (hl)
  
  cp PlayerPortrait_OutOfGame
  JrZRet _LABEL_9C5D_ret
  cp PlayerPortrait_OutOfGame2
  JrZRet _LABEL_9C5D_ret
  
  ; Save value in there
  ld a, PlayerPortrait_OutOfGame
  ld (hl), a
  
  ld (_RAM_D6AA_), a
  ld hl, DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_DBD3_PlayerPortraitBeingDrawn), a
  ld (_RAM_D6BB_), a

  ; Set current character
  ld hl, _RAM_DBD4_Player1Character
  add hl, de
  ld (hl), a

  ld a, $01
  ld (_RAM_D6B4_), a
  ld (_RAM_D6B0_), a
  ld a, $02
  ld (_RAM_D6A4_), a
  ld a, $07
  ld (_RAM_D6B1_), a
  ld a, (_RAM_D6C4_)
  cp $FF
  jr z, +
  add a, $01
  ld c, a
  ld a, (_RAM_D6B9_)
  cp c
  call z, LABEL_B30E_
  jp LABEL_9C64_

+:
  ld a, (_RAM_D6B9_)
  cp $03
  call z, LABEL_B30E_
  jp LABEL_9C64_

.ifdef JUMP_TO_RET
_LABEL_9C5D_ret:
  ret
.endif

LABEL_9C5E_:
  ld a, $01
  ld (_RAM_D6C1_), a
  ret

LABEL_9C64_:
  ld a, (_RAM_D6A4_)
  cp $01
  jp z, LABEL_973C_DrawPortrait_RightTwoColumns
  ld a, (_RAM_DC3C_IsGameGear)
  cp $01
  jr z, +
  ld hl, DATA_975B_TileWriteAddresses_SMS
  jp LABEL_9700_

+:
  ld hl, DATA_9767_TileWriteAddresses_GG
  jp LABEL_9700_

; Data from 9C7F to 9D36 (184 bytes)
DATA_9C7F_RacerPortraitsLocations:
.dw DATA_Tiles_Chen_Happy   DATA_Tiles_Chen_Sad   DATA_Tiles_Chen_Happy    $1000
.dw DATA_Tiles_Chen_Happy   DATA_Tiles_Chen_Sad   DATA_Tiles_Chen_Sad      $1000
.dw DATA_Tiles_Spider_Happy DATA_Tiles_Spider_Sad DATA_Tiles_Spider_Happy  $1000
.dw DATA_Tiles_Spider_Happy DATA_Tiles_Spider_Sad DATA_Tiles_Spider_Sad    $1000
.dw DATA_Tiles_Walter_Happy DATA_Tiles_Walter_Sad DATA_Tiles_Walter_Happy  $1000
.dw DATA_Tiles_Walter_Happy DATA_Tiles_Walter_Sad DATA_Tiles_Walter_Sad    $1000
.dw DATA_Tiles_Dwayne_Happy DATA_Tiles_Dwayne_Sad DATA_Tiles_Dwayne_Happy  $1000
.dw DATA_Tiles_Dwayne_Happy DATA_Tiles_Dwayne_Sad DATA_Tiles_Dwayne_Sad    $1000
.dw DATA_Tiles_Joel_Happy   DATA_Tiles_Joel_Sad   DATA_Tiles_Joel_Happy    $1000
.dw DATA_Tiles_Joel_Happy   DATA_Tiles_Joel_Sad   DATA_Tiles_Joel_Sad      $1000
.dw DATA_Tiles_Bonnie_Happy DATA_Tiles_Bonnie_Sad DATA_Tiles_Bonnie_Happy  $1000
.dw DATA_Tiles_Bonnie_Happy DATA_Tiles_Bonnie_Sad DATA_Tiles_Bonnie_Sad    $1000
.dw DATA_Tiles_Mike_Happy   DATA_Tiles_Mike_Sad   DATA_Tiles_Mike_Happy    $1000
.dw DATA_Tiles_Mike_Happy   DATA_Tiles_Mike_Sad   DATA_Tiles_Mike_Sad      $1000
.dw DATA_Tiles_Emilio_Happy DATA_Tiles_Emilio_Sad DATA_Tiles_Emilio_Happy  $1000
.dw DATA_Tiles_Emilio_Happy DATA_Tiles_Emilio_Sad DATA_Tiles_Emilio_Sad    $1000
.dw DATA_Tiles_Jethro_Happy DATA_Tiles_Jethro_Sad DATA_Tiles_Jethro_Happy  $1000
.dw DATA_Tiles_Jethro_Happy DATA_Tiles_Jethro_Sad DATA_Tiles_Jethro_Sad    $1000
.dw DATA_Tiles_Anne_Happy   DATA_Tiles_Anne_Sad   DATA_Tiles_Anne_Happy    $1000
.dw DATA_Tiles_Anne_Happy   DATA_Tiles_Anne_Sad   DATA_Tiles_Anne_Sad      $1000
.dw DATA_Tiles_Cherry_Happy DATA_Tiles_Cherry_Sad DATA_Tiles_Cherry_Happy  $1000
.dw DATA_Tiles_Cherry_Happy DATA_Tiles_Cherry_Sad DATA_Tiles_Cherry_Sad    $1000

.dw DATA_Tiles_OutOfGame    DATA_Tiles_MrQuestion DATA_Tiles_OutOfGame     $1000

; Data from 9D37 to 9D4D (23 bytes)
; Page numbers for the racer portraits (previous table)
; Two entries per character -> one entry per 4 entries above
DATA_9D37_RacerPortraitsPages:
.db :DATA_Tiles_Chen_Happy
.db :DATA_Tiles_Chen_Sad
.db :DATA_Tiles_Spider_Happy
.db :DATA_Tiles_Spider_Sad
.db :DATA_Tiles_Walter_Happy
.db :DATA_Tiles_Walter_Sad
.db :DATA_Tiles_Dwayne_Happy
.db :DATA_Tiles_Dwayne_Sad
.db :DATA_Tiles_Joel_Happy
.db :DATA_Tiles_Joel_Sad
.db :DATA_Tiles_Bonnie_Happy
.db :DATA_Tiles_Bonnie_Sad
.db :DATA_Tiles_Mike_Happy
.db :DATA_Tiles_Mike_Sad
.db :DATA_Tiles_Emilio_Happy
.db :DATA_Tiles_Emilio_Sad
.db :DATA_Tiles_Jethro_Happy
.db :DATA_Tiles_Jethro_Sad
.db :DATA_Tiles_Anne_Happy
.db :DATA_Tiles_Anne_Sad
.db :DATA_Tiles_Cherry_Happy
.db :DATA_Tiles_Cherry_Sad
.db :DATA_Tiles_OutOfGame

LABEL_9D4E_:
  ld a, (_RAM_D6B1_)
  cp $00
  JrZRet ++
  sub $01
  cp $01
  jr nz, +
  ld a, $04
+:
  ld (_RAM_D6B1_), a
  cp $04
  jr z, LABEL_9DBD_
  cp $03
  jr z, +++
  cp $02
  jr z, ++++
++:ret

+++:
  ld a, (_RAM_D6B9_)
  sla a
  ld c, a
  ld b, $00
  ld hl, DATA_9DAD_TileVRAMAddresses
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  ld a, (_RAM_D6B6_)
  jp LABEL_9F81_DrawPortrait_ThreeColumns

++++:
  ld a, (_RAM_D6B9_)
  sla a
  ld c, a
  ld b, $00
  ld hl, DATA_9DB5_TileVRAMAddresses
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  ld hl, (_RAM_D6A6_DisplayCase_Source)
  ld a, (_RAM_D6B6_)
  call LABEL_9FAB_DrawOrBlank15PortraitTiles
  ld a, (_RAM_D6BA_)
  cp $00
  JrZRet +
  call LABEL_9E29_
+:ret

; Data from 9DAD to 9DB4 (8 bytes)
DATA_9DAD_TileVRAMAddresses:
  TileWriteAddressData MenuTileIndex_Portraits.1
  TileWriteAddressData MenuTileIndex_Portraits.2
  TileWriteAddressData MenuTileIndex_Portraits.3
  TileWriteAddressData MenuTileIndex_Portraits.4

; Data from 9DB5 to 9DBC (8 bytes)
DATA_9DB5_TileVRAMAddresses:
  TileWriteAddressData $33
  TileWriteAddressData $51
  TileWriteAddressData $6f
  TileWriteAddressData $8d

LABEL_9DBD_:
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  ld e, a
  ld a, (_RAM_D6BA_)
  cp $00
  jr nz, +
  ld hl, DATA_9E13_
  ld a, (_RAM_D6B7_)
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (_RAM_D6B5_)
  ld c, a
  add hl, bc
  ld a, (hl)
  cp $FF
  jr z, ++
  add a, e
+:
  ld (_RAM_D6B6_), a
  ld a, (_RAM_D6B5_)
  add a, $01
  ld (_RAM_D6B5_), a
  ret

++:
  ld a, $00
  ld (_RAM_D6B1_), a
  ld (_RAM_D6B5_), a
  ld a, $F0
  ld (_RAM_D6B8_), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerSelectCharacter
  JrZRet +
  cp $0E
  jr z, ++
  ld a, $00
  ld (_RAM_D6B4_), a
  ld a, (_RAM_D6B9_)
  cp $04
  JrZRet +
  add a, $01
  ld (_RAM_D6B9_), a
+:ret

; Data from 9E13 to 9E28 (22 bytes)
DATA_9E13_: ; Indexed by _RAM_D6B7_ + _RAM_D6B5_
.db $04 $02 $04 $02 $04 $00 $FF $FF $FF $FF $FF $06 $05 $06 $05 $06
.db $05 $06 $05 $06 $01 $FF

LABEL_9E29_:
  ld a, $00
  ld (_RAM_D6B1_), a
  ld (_RAM_D6B5_), a
  ld (_RAM_D6BA_), a
  ld (_RAM_D6B4_), a
  ld a, $F0
  ld (_RAM_D6B8_), a
  ret

++:
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  srl a
  srl a
  srl a
  cp $02
  jr z, +
  cp $06
  jr z, +
  cp $09
  jr z, +
LABEL_9E52_:
  xor a
  ld (_RAM_D6CD_), a
  ld (_RAM_D6B4_), a
  ld a, (_RAM_D6B9_)
  add a, $01
  ld (_RAM_D6B9_), a
  TailCall LABEL_A5BE_

+:
  ld a, $01
  ld (_RAM_D6CA_), a
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  ret

LABEL_9E70_:
  ld a, (_RAM_D6B4_)
  cp $01
  JpZRet _LABEL_9F3F_ret
  ld a, (_RAM_D6A3_)
  cp $00
  JpNzRet _LABEL_9F3F_ret
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $08
  JpZRet _LABEL_9F3F_ret
  ld a, (_RAM_D6B0_)
  cp $01
  jp z, LABEL_9C64_
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerSelectCharacter
  jr z, +
  ld a, (_RAM_D6B9_)
  cp $01
  JpZRet _LABEL_9F3F_ret
+:
  ld a, (_RAM_D6B9_)
  cp $00
  JpZRet _LABEL_9F3F_ret
  ld a, (_RAM_D6C4_)
  cp $FF
  jr z, +
  add a, $01
  ld c, a
  ld a, (_RAM_D6B9_)
  cp c
  JpZRet _LABEL_9F3F_ret
+:
  ld a, (_RAM_D697_)
  cp $00
  jr z, +
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_2_MASK ; $20
  JrZRet _LABEL_9F3F_ret
  ld a, $00
  ld (_RAM_D697_), a
+:
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_2_MASK ; $20
  JrNzRet _LABEL_9F3F_ret
  ld a, $01
  ld (_RAM_D697_), a
  ld a, (_RAM_D6B9_)
  sub $01
  ld e, a
  ld d, $00
  ld hl, _RAM_DBD4_Player1Character
  add hl, de
  ld e, (hl)
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  add a, $01
  ld c, a
  ld a, (_RAM_D6AD_)
  add a, c
  cp $0B
  jr c, +
  sub $0B
+:
  ld c, a
  ld b, $00
  ld hl, DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  cp e
  JrNzRet _LABEL_9F3F_ret
  ld hl, _RAM_DBFE_PlayerPortraitValues
  add hl, bc
  add a, $01 ; change from happy to sad
  ld (hl), a
  ld (_RAM_D6AA_), a
  ld a, PlayerPortrait_MrQuestion
  ld (_RAM_D6BA_), a
  ld a, $01
  ld (_RAM_D6B0_), a
  ld a, $02
  ld (_RAM_D6A4_), a
  ld a, $07
  ld (_RAM_D6B1_), a
  ld a, (_RAM_D6C4_)
  cp $FF
  jr z, +
  call LABEL_B31C_
  jp ++

+:
  ld a, (_RAM_D6B9_)
  cp $04
  call z, LABEL_B31C_
++:
  sub $01
  ld (_RAM_D6B9_), a
  jp LABEL_9C64_

_LABEL_9F3F_ret:
  ret

LABEL_9F40_LoadPortraitTiles:
; a = portrait index
  ld (_RAM_D6A1_PortraitIndex), a ; Save

  ld hl, DATA_9D37_RacerPortraitsPages ; Look up in page number
  ld a, (_RAM_D6A1_PortraitIndex)
  sra a ; Divide by 4 to look up the page number because that table has a 1:4 ratio to the portrait pointers
  sra a
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl) ; Look up
  ld (_RAM_D741_RequestedPageIndex), a ; Save value found

  ld d, $00
  ld hl, DATA_9C7F_RacerPortraitsLocations ; Look up pointer to data
  ld a, (_RAM_D6A1_PortraitIndex)
  sla a ; *2 because words
  ld e, a
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, c ; -> hl

  ld de, 30 * 2 ; for blanking
  ld a, (_RAM_D6A1_PortraitIndex)
  cp PlayerPortrait_OutOfGame
  jr z, LABEL_9F74_BlankVRAMRegion
  JumpToRamCode LABEL_3BC27_EmitThirty3bppTiles

LABEL_9F74_BlankVRAMRegion:
; de = amount to write / 16
-:ld hl, DATA_BD6C_ZeroData
  ld b, 16
  ld c, PORT_VDP_DATA
  otir
  dec e
  jr nz, -
  ret

LABEL_9F81_DrawPortrait_ThreeColumns:
  ; save index
  ld (_RAM_D6A1_PortraitIndex), a
  ; Look up page
  ld hl, DATA_9D37_RacerPortraitsPages
  ld a, (_RAM_D6A1_PortraitIndex)
  sra a
  sra a
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld (_RAM_D6A5_), a
  ld (_RAM_D741_RequestedPageIndex), a
  ; Look up pointer
  ld d, $00
  ld hl, DATA_9C7F_RacerPortraitsLocations
  ld a, (_RAM_D6A1_PortraitIndex)
  sla a
  ld e, a
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, c
  ; fall through

LABEL_9FAB_DrawOrBlank15PortraitTiles:
  ld de, 15 * 2 ; to blank 15 tiles
  ld a, (_RAM_D6A1_PortraitIndex)
  cp PlayerPortrait_OutOfGame
  jr z, LABEL_9F74_BlankVRAMRegion
  JumpToRamCode LABEL_3BC3C_EmitFifteen3bppTiles

LABEL_9FB8_DrawOrBlank10PortraitTiles:
  ld de, 10 * 2 ; to blank 10 tiles
  ld a, (_RAM_D6A1_PortraitIndex)
  cp PlayerPortrait_OutOfGame
  jr z, LABEL_9F74_BlankVRAMRegion
  JumpToRamCode LABEL_3BC53_EmitTen3bppTiles

LABEL_9FC5_:
  ld a, (_RAM_DC3B_IsTrackSelect)
  or a
  jr z, +
  jp LABEL_AA02_

+:
  ld bc, $0000 ; Offset 5 rows down for SMS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, TILEMAP_ROW_SIZE * 5 ; $0140
+:
  ld a, (_RAM_D6CE_)
  or a
  jr z, +++
  ld a, (_RAM_D6AF_FlashingCounter)
  sra a
  sra a
  and $01
  jp nz, +++
  ld a, (_RAM_D6CE_)
  cp $80
  jr z, +
  TilemapWriteAddressToHL 6, 22
  jp ++
+:TilemapWriteAddressToHL 7, 22
++:
  add hl, bc
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, TEXT_A019_Pro
  jp LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 6, 22
  add hl, bc
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0004
  ld hl, TEXT_AAAE_Blanks
  jp LABEL_A5B0_EmitToVDP_Text

TEXT_A019_Pro:  .asc "PRO"

LABEL_A01C_:
  ld c, a
  ld b, $00
  ld hl, DATA_A02E_
  add hl, bc
  ld a, (hl)
  ld c, a
  and $C0
  ld (_RAM_D6CE_), a
  ld a, c
  and $3F
  ret

; Data from A02E to A038 (11 bytes)
DATA_A02E_:
.db $FF $01 $81 $03 $43 $08 $07 $05 $02 $04 $06

LABEL_A039_:
  ld de, 0 ; Tilemap offset to apply (SMS)
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, TILEMAP_ROW_SIZE ; 1 row down for GG
+:ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  JrZRet _LABEL_A0A3_ret
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01 ; Flash every 16 frames (8 on, 8 off)
  jp nz, +++
  ; Draw text
  TilemapWriteAddressToHL 8, 14
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 8
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr z, +
  ld hl, TEXT_A0AC_Loser
  jp ++
+:ld hl, TEXT_A0A4_Winner
++:
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 17, 14
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 8
  ld a, (_RAM_DBD0_LastRacePosition_Player2)
  or a
  jr z, +
  ld hl, TEXT_A0AC_Loser
  jp ++
+:ld hl, TEXT_A0A4_Winner
++:
  jp LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 8, 14
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0019 ; Covers both strings
  ld hl, TEXT_AAAE_Blanks
  jp LABEL_A5B0_EmitToVDP_Text

_LABEL_A0A3_ret:
  ret

TEXT_A0A4_Winner: .asc "WINNER!!"
TEXT_A0AC_Loser:  .asc " LOSER! "

LABEL_A0B4_:
  TilemapWriteAddressToHL 12, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0007
  ld hl, TEXT_A0DB_Results
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 7, 11
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, +
  ld bc, $000E
  ld hl, TEXT_A0E2_SingleRace
  jp LABEL_A5B0_EmitToVDP_Text

+:
  jp LABEL_A302_

TEXT_A0DB_Results:    .asc "RESULTS"
TEXT_A0E2_SingleRace: .asc "   SINGLE RACE"

LABEL_A0F0_BlankTilemapRectangle:
  ld bc, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, 5 * TILEMAP_ROW_SIZE ; $0140 - offset to 10, 19 for SMS
+:
  TilemapWriteAddressToHL 10, 14
  add hl, bc
  ld bc, $000C ; Width in tiles
  ld de, $0009 ; Height in tiles
--:
  call LABEL_B35A_VRAMAddressToHL
-:ld a, <MenuTileIndex_Font.Space
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, c
  or a
  jr nz, -
  ld bc, $000C ; Width in tiles
  dec de
  ld a, e
  or a
  JrZRet +
  ld a, l
  add a, TILEMAP_ROW_SIZE ; $40 ; Add a row
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  jp --
.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_A129_:
  ld de, (_RAM_D6A8_DisplayCaseTileAddress)
  call LABEL_B361_VRAMAddressToDE
  exx
    ld hl, (_RAM_D6A6_DisplayCase_Source)
    ld e, 10 * 8 ; 10 tiles
    CallRamCode LABEL_3BB45_Emit3bppTileDataToVRAM
    ld (_RAM_D6A6_DisplayCase_Source), hl
  exx
  ld hl, 32*10 ; 10 tiles
  add hl, de
  ld (_RAM_D6A8_DisplayCaseTileAddress), hl
  ld a, (_RAM_D693_SlowLoadSlideshowTiles)
  sub $01
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_A14F_:
  ; de = location offset - 0 for GG, $80 for SMS
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  rrca
  ld e, a
  ld d, $00

  ld a, (_RAM_DBD4_Player1Character)
  ; Divide by 8 to make a character index
  srl a
  srl a
  srl a
  ld c, a ; 1 = player 2, 2 = player 1 (!)
  ld b, $00
  call LABEL_A1EC_
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 7, 11
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 7, 22
  add hl, de
++:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC21_CharacterStates
  add hl, bc
  ld a, (hl)
  or a
  jr z, +
  call LABEL_A1CA_PrintHandicap
  jp ++
+:call LABEL_A1D3_PrintOrdinary
++:
  ld a, (_RAM_DBD5_Player2Character)
  srl a
  srl a
  srl a
  ld c, a
  ld b, $00
  call LABEL_A225_
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  rrca
  ld e, a
  ld d, $00
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 17, 11
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 17, 22
  add hl, de
++:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC21_CharacterStates
  add hl, bc
  ld a, (hl)
  or a
.ifdef TAIL_CALL
  jr z, +
  call LABEL_A1CA_PrintHandicap
  ret

+:call LABEL_A1D3_PrintOrdinary
  ret
.else
  jp z, LABEL_A1D3_PrintOrdinary
  ; else fall through
.endif

LABEL_A1CA_PrintHandicap:
  ld bc, $0008
  ld hl, TEXT_A1DC_Handicap
  jp LABEL_A5B0_EmitToVDP_Text

LABEL_A1D3_PrintOrdinary:
  ld bc, $0008
  ld hl, TEXT_A1E4_Ordinary
  jp LABEL_A5B0_EmitToVDP_Text

TEXT_A1DC_Handicap: .asc "HANDICAP"
TEXT_A1E4_Ordinary: .asc "ORDINARY"

LABEL_A1EC_:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 7, 6
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 7, 16
  add hl, de
++:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC0B_
  add hl, bc
  call LABEL_A272_PrintBCDNumberWithLeadingHyphen
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 7, 8
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 7, 18
  add hl, de
++:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC16_
  add hl, bc
  TailCall LABEL_A272_PrintBCDNumberWithLeadingHyphen

LABEL_A225_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, e
  add a, $04
  ld e, a
+:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 24, 6
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 24, 16
  add hl, de
++:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC0B_
  add hl, bc
  call LABEL_A272_PrintBCDNumberWithLeadingHyphen
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, e
  add a, $02
  ld e, a
+:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 24, 8
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 24, 18
  add hl, de
++:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC16_
  add hl, bc
  TailCall LABEL_A272_PrintBCDNumberWithLeadingHyphen

LABEL_A272_PrintBCDNumberWithLeadingHyphen:
  ld a, (hl) ; Get byte
  and $F0 ; High nibble
  srl a
  srl a
  srl a
  srl a
  jr nz, + ; high 1 -> "-"
  ld a, <MenuTileIndex_Punctuation.Hyphen
  jp ++
+:add a, <MenuTileIndex_Font.Digits ; else convert to digit
++:
  out (PORT_VDP_DATA), a
  rlc a
  and $01
  out (PORT_VDP_DATA), a
  ld a, (hl) ; Low nibble is printed as a 0
  and $0F
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  ret

LABEL_A296_LoadHandTiles:
  ld a, :DATA_2B151_Tiles_Hand
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_2B151_Tiles_Hand
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 39 * 8 ; 39 tiles - too many (there are only 31 in the data)
  TileWriteAddressToHL MenuTileIndex_Select_Hand
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

LABEL_A2AA_PrintOrFlashMenuScreenText:
  ; Pick a location based on _RAM_DC3B_IsTrackSelect and SMS/GG
  ; Pick text based on _RAM_DC34_IsTournament (Tournament race), _RAM_DC3B_IsTrackSelect (Select a track) (else Select vehicle)
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 7, 16
  jr ++
+:TilemapWriteAddressToHL 7, 13
++:
  call LABEL_B35A_VRAMAddressToHL
  jp ++++

+++:
  ; Track select -> higher up
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 7, 11
  jr ++
+:TilemapWriteAddressToHL 7, 10
++:
  call LABEL_B35A_VRAMAddressToHL
  jp ++++ ; could fall through

++++:
  ld a, (_RAM_D6AF_FlashingCounter)
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  sra a
  and $01
  jp nz, ++
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, LABEL_A302_
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +
  ld hl, TEXT_A325_SelectVehicle
  ld bc, $0010
  jp LABEL_A5B0_EmitToVDP_Text

LABEL_A302_:
  ld hl, TEXT_A335_TournamentRace
  ld bc, $0010
  call LABEL_A5B0_EmitToVDP_Text
  ; Emit number
  ld a, (_RAM_DC35_TournamentRaceNumber)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  ret

+:
  ld hl, TEXT_A345_SelectATrack
  ld bc, $0010
  jp LABEL_A5B0_EmitToVDP_Text

++:
  ld bc, $0011
  ld hl, TEXT_AAAE_Blanks
  jp LABEL_A5B0_EmitToVDP_Text

TEXT_A325_SelectVehicle:  .asc "  SELECT VEHICLE"
TEXT_A335_TournamentRace: .asc "TOURNAMENT RACE "
TEXT_A345_SelectATrack:   .asc "  SELECT A TRACK"

LABEL_A355_PrintWonLostCounterLabels:
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DBD4_Player1Character)
  ; Divide by 8 to make a character index
  srl a
  srl a
  srl a
  ; Result is not used...
.endif
  
; Repeated code pattern... set VRAM address depending on system and whetehr _RAM_D699_MenuScreenIndex == MenuScreen_TwoPlayerResult
.macro SetVRAMWriteAddress1P2P args X1P, Y1P, X2P, Y2P, GGXOffset, GGYOffset
.ifdef IS_GAME_GEAR
  ld de, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, (GGYOffset * TILEMAP_WIDTH + GGXOffset) * TILEMAP_ENTRY_SIZE
+:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL X2P, Y2P
  add hl, de
  jp ++
+:TilemapWriteAddressToHL X1P, Y1P
  add hl, de
++:
.else
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  .ifdef IS_GAME_GEAR
    TilemapWriteAddressToHL X2P - GGXOffset, Y2P - GGYOffset
  .else
    TilemapWriteAddressToHL X1P - GGXOffset, Y1P - GGYOffset
  .endif
  jr ++
  .ifdef IS_GAME_GEAR
    TilemapWriteAddressToHL X2P, Y2P
  .else
    TilemapWriteAddressToHL X1X, Y1P
  .endif
++:
.endif
  call LABEL_B35A_VRAMAddressToHL
.endm

  ; Set tilemap address for "won" text
  SetVRAMWriteAddress1P2P 6, 16, 6, 6, -2, +2
  call LABEL_A3EA_PrintWonText
  
  ; Set tilemap address for "lost" text
  SetVRAMWriteAddress1P2P 6, 18, 6, 8, -3, +2
  call LABEL_A402_PrintLostText
  
  SetVRAMWriteAddress1P2P 23, 16, 23, 6, 0, +2
  call LABEL_A3EA_PrintWonText

  SetVRAMWriteAddress1P2P 23, 18, 23, 8, 0, +2
  jp LABEL_A402_PrintLostText ; and ret

LABEL_A3EA_PrintWonText:
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0005
  ld hl, TEXT_A41E_Won
  jp LABEL_A5B0_EmitToVDP_Text
+:ld bc, $0002
  ld hl, TEXT_A41A_W
  jp LABEL_A5B0_EmitToVDP_Text
.else
  .ifdef IS_GAME_GEAR
    ld bc, $0002
    ld hl, TEXT_A41A_W
  .else
    ld bc, $0005
    ld hl, TEXT_A41E_Won
  .endif
  jp LABEL_A5B0_EmitToVDP_Text
.endif


LABEL_A402_PrintLostText:
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0005
  ld hl, TEXT_A423_Lost
  jp LABEL_A5B0_EmitToVDP_Text
+:ld bc, $0002
  ld hl, TEXT_A41C_L
  jp LABEL_A5B0_EmitToVDP_Text
.else
  .ifdef IS_GAME_GEAR
    ld bc, $0002
    ld hl, TEXT_A41C_L
  .else
    ld bc, $0005
    ld hl, TEXT_A423_Lost
  .endif
  jp LABEL_A5B0_EmitToVDP_Text
.endif

.ifdef GAME_GEAR_CHECKS
TEXT_A41A_W:    .asc "W-"
TEXT_A41C_L:    .asc "L-"
TEXT_A41E_Won:  .asc "WON- "
TEXT_A423_Lost: .asc "LOST-"
.else
  .ifdef IS_GAME_GEAR
TEXT_A41A_W:    .asc "W-"
TEXT_A41C_L:    .asc "L-"
  .else
TEXT_A41E_Won:  .asc "WON- "
TEXT_A423_Lost: .asc "LOST-"
  .endif
.endif

; Unused code (?)
.ifdef UNNECESSARY_CODE
LABEL_A428_DrawPlayerOpponentTypeSelectText:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 4, 24 ; SMS
  jr ++
+:TilemapWriteAddressToDE 6, 20 ; GG
++:call LABEL_B361_VRAMAddressToDE
  ld bc, 8
  ld hl, TEXT_A49D_Player1
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, $0046 ; down and right a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 2
  ld hl, TEXT_A4B5_Vs
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, $0080 ; down a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 8
  ld hl, TEXT_A4A5_Player2
  call LABEL_A5B0_EmitToVDP_Text

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 20, 24 ; SMS
  jr ++
+:TilemapWriteAddressToDE 18, 20 ; GG
++:call LABEL_B361_VRAMAddressToDE
  ld bc, 8
  ld hl, TEXT_A49D_Player1
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, $0046 ; down and right a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 2
  ld hl, TEXT_A4B5_Vs
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, $0080 ; down a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 8
  ld hl, TEXT_A4AD_Computer
  TailCall LABEL_A5B0_EmitToVDP_Text

TEXT_A49D_Player1:  .asc "PLAYER 1"
TEXT_A4A5_Player2:  .asc "PLAYER 2"
TEXT_A4AD_Computer: .asc "COMPUTER"
TEXT_A4B5_Vs:       .asc "VS"
.endif

LABEL_A4B7_DrawSelectMenuText:
  ; Draw "Select Game"
  TilemapWriteAddressToHL 10, 13
  call LABEL_A500_DrawSelectGameText
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerMode
  JrZRet +
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  JrZRet +
  ; For SMS 1/2 player, draw icon text labels
  TilemapWriteAddressToHL 3, 16
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 26
  ld hl, TEXT_A4E6_OnePlayerTwoPlayer
  call LABEL_A5B0_EmitToVDP_Text
+:ret

TEXT_A4DA_SelectGame:         .asc "SELECT  GAME"
TEXT_A4E6_OnePlayerTwoPlayer: .asc "ONE PLAYER      TWO PLAYER"

LABEL_A500_DrawSelectGameText:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, TEXT_A4DA_SelectGame
  jp LABEL_A5B0_EmitToVDP_Text

LABEL_A50C_DrawOnePlayerSelectGameText:
  TilemapWriteAddressToHL 8, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000F
  ld hl, TEXT_A521_OnePlayerGame
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 10, 12
  jp LABEL_A500_DrawSelectGameText

TEXT_A521_OnePlayerGame:  .asc "ONE PLAYER GAME"

LABEL_A530_DrawChooseGameText:
  TilemapWriteAddressToHL 10, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, TEXT_A574_ChooseGame
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 3, 26
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $001A
  ld hl, TEXT_A580_TournamentSingleRace
  TailCall LABEL_A5B0_EmitToVDP_Text

+:
  TilemapWriteAddressToHL 6, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0012
  ld hl, TEXT_A59A_TournamentSingle
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 22, 22
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0004
  ld hl, TEXT_A5AC_Race
  TailCall LABEL_A5B0_EmitToVDP_Text

TEXT_A574_ChooseGame:           .asc "CHOOSE GAME!"
TEXT_A580_TournamentSingleRace: .asc "TOURNAMENT     SINGLE RACE"
TEXT_A59A_TournamentSingle:     .asc "TOURNAMENT  SINGLE"
TEXT_A5AC_Race:                 .asc "RACE"

LABEL_A5B0_EmitToVDP_Text:
  ; Emits tile data from hl to the VDP data port, synthesising the high byte as it goes
  ld a, (hl)
  out (PORT_VDP_DATA), a
  rlc a
  and $01
  out (PORT_VDP_DATA), a
  inc hl
  dec c
  jr nz, LABEL_A5B0_EmitToVDP_Text
  ret

LABEL_A5BE_:
  ld a, $30
  ld (_RAM_D6AF_FlashingCounter), a
  ld a, $01
  ld (_RAM_D6C6_), a
  ret

LABEL_A5C9_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 3, 10
  ld bc, $0006
  ld hl, TEXT_A664_Player
  jr ++

+:
  TilemapWriteAddressToDE 6, 10
  ld bc, $0003
  ld hl, TEXT_A66A_Plr
++:
  call LABEL_B361_VRAMAddressToDE
  call LABEL_A5B0_EmitToVDP_Text

  TilemapWriteAddressToHL 6, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, TEXT_A66D_One
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_A5F9_:
  TilemapWriteAddressToHL 3, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, TEXT_AAAE_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, TEXT_AAAE_Blanks
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_A618_:
  ld de, $79AE
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0006
  ld hl, TEXT_A664_Player
  jr ++

+:
  ld bc, $0003
  ld hl, TEXT_A66A_Plr
++:
  call LABEL_B361_VRAMAddressToDE
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 23, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, TEXT_A670_Two
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_A645_:
  TilemapWriteAddressToHL 23, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, TEXT_AAAE_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 23, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, TEXT_AAAE_Blanks
  TailCall LABEL_A5B0_EmitToVDP_Text

TEXT_A664_Player: .asc "PLAYER"
TEXT_A66A_Plr:    .asc "PLR"
TEXT_A66D_One:    .asc "ONE"
TEXT_A670_Two:    .asc "TWO"

LABEL_A673_SelectLowSpriteTiles:
  ld a, VDP_REGISTER_SPRITESET_LOW
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITESET
  out (PORT_VDP_REGISTER), a
  ret

LABEL_A67C_:
  ; Unknown, character select related?
  ld a, $00
  ld (_RAM_D6AD_), a
  ld a, $04
  ld (_RAM_D6AE_), a
  ld a, $03
  ld (_RAM_D6A2_), a
  ld (_RAM_DBFB_PortraitCurrentIndex), a
  ld bc, $0003
  ret

LABEL_A692_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  JrZRet ++
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, +++
  TilemapWriteAddressToHL 8, 20
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  and $F8
  ld c, a
  ld b, $00
  ld hl, TEXT_A6EF_OpponentNames
  add hl, bc
  ld a, (hl)
  inc hl
  or a
  jr z, +
  TilemapWriteAddressToDE 9, 20
  call LABEL_B361_VRAMAddressToDE
+:
  ld bc, $0007
  call LABEL_A5B0_EmitToVDP_Text
  ld bc, $0008
  ld hl, TEXT_A747_IsOut
  call LABEL_A5B0_EmitToVDP_Text
++:ret

+++:
  TilemapWriteAddressToHL 7, 20
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_AAAE_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  ld bc, $0008
  ld hl, TEXT_AAAE_Blanks
  TailCall LABEL_A5B0_EmitToVDP_Text

TEXT_A6EF_OpponentNames:
.asc 0, "  CHEN "
.asc 1, "SPIDER "
.asc 1, "WALTER "
.asc 1, "DWAYNE "
.asc 0, "  JOEL "
.asc 1, "BONNIE "
.asc 0, "  MIKE "
.asc 1, "EMILIO "
.asc 1, "JETHRO "
.asc 0, "  ANNE "
.asc 1, "CHERRY "

TEXT_A747_IsOut: .asc "IS OUT! "

LABEL_A74F_:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  ld c, a
  ld b, $00
  ld hl, DATA_A75E_
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6C4_), a
  ret

; Data from A75E to A777 (26 bytes) - a byte per course (?), written to _RAM_D6C4_
DATA_A75E_:
.db $FF $FF $FF $00 $FF $FF $01 $FF $FF $02 $FF $FF $FF $00 $FF $FF $01 $FF $FF $FF $02 $FF $FF $FF $00 $FF

LABEL_A778_InitialiseDisplayCaseData:
  ld bc, $0018
  ld hl, _RAM_DBD9_DisplayCaseData
-:xor a
  ld (hl), a
  inc hl
  dec bc
  ld a, c
  or a
  jr nz, -
  ret

LABEL_A787_:
  ld a, (_RAM_DC0A_WinsInARow)
  cp WINS_IN_A_ROW_FOR_RUFFTRUX
  jr nz, +
  ; RuffTrux
  ld a, $02
  ld (_RAM_DBD9_DisplayCaseData + 15), a
  ld (_RAM_DBD9_DisplayCaseData + 19), a
  ld (_RAM_DBD9_DisplayCaseData + 23), a
  ret

+:; Not RuffTrux
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  sub $01
  sla a
  ld c, a
  ld b, $00
  ld hl, DATA_A7BB_
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ld a, $02
  ld (de), a
  ld (_RAM_DBF9_), de
  ret

LABEL_A7B3_:
  ld de, (_RAM_DBF9_)
  ld a, $01
  ld (de), a
  ret

; Data from A7BB to A7EC (50 bytes)
; Display case locations per track index (except qualifying race)
DATA_A7BB_:
.dw _RAM_DBD9_DisplayCaseData+14 ; $DBE7 TheBreakfastBends
.dw _RAM_DBD9_DisplayCaseData+ 0 ; $DBD9 DesktopDropOff
.dw _RAM_DBD9_DisplayCaseData+12 ; $DBE5 OilcanAlley
.dw _RAM_DBD9_DisplayCaseData+ 3 ; $DBDC SandyStraights
.dw _RAM_DBD9_DisplayCaseData+18 ; $DBEB OatmealInOverdrive
.dw _RAM_DBD9_DisplayCaseData+ 1 ; $DBDA TheCueBallCircuit
.dw _RAM_DBD9_DisplayCaseData+16 ; $DBE9 HandymansCurve
.dw _RAM_DBD9_DisplayCaseData+13 ; $DBE6 BermudaBathtub
.dw _RAM_DBD9_DisplayCaseData+ 7 ; $DBE0 SaharaSandpit
.dw _RAM_DBD9_DisplayCaseData+14 ; $DBE7 ThePottedPassage - helicopter!
.dw _RAM_DBD9_DisplayCaseData+22 ; $DBEF FruitJuiceFollies
.dw _RAM_DBD9_DisplayCaseData+17 ; $DBEA FoamyFjords
.dw _RAM_DBD9_DisplayCaseData+ 2 ; $DBDB BedroomBattlefield
.dw _RAM_DBD9_DisplayCaseData+ 5 ; $DBDE PitfallPockets
.dw _RAM_DBD9_DisplayCaseData+ 4 ; $DBDD PencilPlateaux
.dw _RAM_DBD9_DisplayCaseData+11 ; $DBE4 TheDareDevilDunes
.dw _RAM_DBD9_DisplayCaseData+18 ; $DBEB TheShrubberyTwist - helicopter!
.dw _RAM_DBD9_DisplayCaseData+20 ; $DBED PerilousPitStop
.dw _RAM_DBD9_DisplayCaseData+ 6 ; $DBDF WideAwakeWarZone
.dw _RAM_DBD9_DisplayCaseData+ 8 ; $DBE1 CrayonCanyons
.dw _RAM_DBD9_DisplayCaseData+21 ; $DBEE SoapLakeCity!
.dw _RAM_DBD9_DisplayCaseData+22 ; $DBEF TheLeafyBends - helicopter!
.dw _RAM_DBD9_DisplayCaseData+ 9 ; $DBE2 ChalkDustChicane
.dw _RAM_DBD9_DisplayCaseData+10 ; $DBE3 GoForIt
.dw _RAM_DBD9_DisplayCaseData+ 8 ; $DBE1 WinThisRaceToBeChampion

LABEL_A7ED_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  JrZRet +++
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jr nz, ++++
  call LABEL_A859_SetTilemapLocationForLastRacePosition
  ld a, (_RAM_DC3A_RequiredPositionForNextRace)
  dec a
  jr nz, +
  ld a, (_RAM_DBCF_LastRacePosition)
  dec a
  jr nz, +
  ld c, $08
  jp ++

+:
  ld a, (_RAM_DBCF_LastRacePosition)
  and $02
  sla a
  sla a
  ld c, a
++:
  ld b, $00
  ld hl, TEXT_A84A_QualifyFailed
  add hl, bc
  ld bc, $0007
  call LABEL_A5B0_EmitToVDP_Text
+++:ret

++++:
  call LABEL_A859_SetTilemapLocationForLastRacePosition
  ld hl, TEXT_AAAE_Blanks
  ld bc, $0007
  jp LABEL_A5B0_EmitToVDP_Text

; Data from A83A to A841 (8 bytes)
DATA_A83A_TilemapLocations_GG:
  TilemapWriteAddressData  8, 14
  TilemapWriteAddressData 17, 14
  TilemapWriteAddressData  8, 22
  TilemapWriteAddressData 18, 22

; Data from A842 to A849 (8 bytes)
DATA_A842_TilemapLocations_SMS:
  TilemapWriteAddressData  1, 14
  TilemapWriteAddressData 24, 14
  TilemapWriteAddressData  2, 24
  TilemapWriteAddressData 24, 24

; Data from A84A to A858 (15 bytes)
TEXT_A84A_QualifyFailed:
.asc "QUALIFY", $FF
.asc "FAILED "

LABEL_A859_SetTilemapLocationForLastRacePosition:
  ; Index into table for system
  ld a, (_RAM_DBCF_LastRacePosition)
  sla a
  ld c, a
  ld b, $00
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_A842_TilemapLocations_SMS
  jr ++
+:ld hl, DATA_A83A_TilemapLocations_GG
++:
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  TailCall LABEL_B361_VRAMAddressToDE

LABEL_A877_LoadPositionGraphicsAndDrawPositionPortraitTilemaps:
  ; Load big numbers
  ld a, :DATA_13C42_Tiles_BigNumbers
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_13C42_Tiles_BigNumbers
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 24 * 8 ; 24 tiles
  TileWriteAddressToHL $100
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  call LABEL_BA42_LoadColouredBallTiles

  ; Draw portrait tiles
  ; #1
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01 ; 1 for SMS
  rrca ; $80 for SMS = 2 rows
  ld c, a ; -> bc
  ld b, $00
  xor a
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  TilemapWriteAddressToHL 6, 8
  add hl, bc ; Add 2 rows for SMS -> 6, 10
  ld a, $03
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, $02
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call LABEL_BCCF_EmitTilemapRectangleSequence

  ; #2
  ld a, $06
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  TilemapWriteAddressToHL 24, 8
  add hl, bc ; Add 2 rows for SMS -> 24, 10
  ld a, $03
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  call LABEL_BCCF_EmitTilemapRectangleSequence

  ; #3
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  ld b, a
  ld c, $00
  ld a, $0C
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  TilemapWriteAddressToHL 6, 16
  add hl, bc ; Add 2 rows for SMS -> 6, 20
  ld a, $03
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  call LABEL_BCCF_EmitTilemapRectangleSequence
  
  ; #4
  ld a, $12
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  TilemapWriteAddressToHL 24, 16
  add hl, bc ; Add 2 rows for SMS -> 24, 18
  ld a, $03
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  TailCall LABEL_BCCF_EmitTilemapRectangleSequence

_LABEL_A8ED_TournamentResults_FirstPlace:
  ld c, $00
  jp +

_LABEL_A8F2_TournamentResults_SecondPlace:
  ld c, $01
  jp +

_LABEL_A8F7_TournamentResults_ThirdPlace:
  ld c, $02
  jp +

LABEL_A8FC_TournamentResults_FourthPlace:
  ld c, $03
.ifdef UNNECESSARY_CODE
  jp +
.endif

+:; run handler for player at position c
  ld a, (_RAM_DBCF_LastRacePosition)
  cp c
  jp z, _isPlayer1
  ld a, (_RAM_DBD0_LastRacePosition_Player2)
  cp c
  jp z, _isPlayer2
  ld a, (_RAM_DBD1_LastRacePosition_Player3)
  cp c
  jp z, _isPlayer3
  ld a, (_RAM_DBD2_LastRacePosition_Player4)
  cp c
  jp z, _isPlayer4
  ret

_isPlayer1:
  ld a, $80
  ld (_RAM_D6AF_FlashingCounter), a
  ld b, $00
  call LABEL_A9C6_
  call _LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_A9AE_TilemapAddresses_SMS
  jr ++
+:ld hl, DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBCF_LastRacePosition)
  jp LABEL_A996_

_isPlayer2:
  ld b, $01
  call LABEL_A9C6_
  ld a, MenuTileIndex_Portraits.2
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_A9AE_TilemapAddresses_SMS
  jr ++
+:ld hl, DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBD0_LastRacePosition_Player2)
  jp LABEL_A996_

_isPlayer3:
  ld b, $02
  call LABEL_A9C6_
  ld a, MenuTileIndex_Portraits.3
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_A9AE_TilemapAddresses_SMS
  jr ++
+:ld hl, DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBD1_LastRacePosition_Player3)
  jp LABEL_A996_

_isPlayer4:
  ld b, $03
  call LABEL_A9C6_
  ld a, MenuTileIndex_Portraits.4
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_A9AE_TilemapAddresses_SMS
  jr ++
+:ld hl, DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBD2_LastRacePosition_Player4)
  ; fall through
  
LABEL_A996_:
  sla a
  ld c, a
  ld b, $00
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ex de, hl
  call LABEL_BCCF_EmitTilemapRectangleSequence
  jp LABEL_8F10_

; Data from A9A6 to A9AD (8 bytes)
DATA_A9A6_TilemapAddresses_GG:
  TilemapWriteAddressData  9,  8
  TilemapWriteAddressData 18,  8
  TilemapWriteAddressData  9, 16
  TilemapWriteAddressData 18, 16

; Data from A9AE to A9B5 (8 bytes)
DATA_A9AE_TilemapAddresses_SMS:
  TilemapWriteAddressData  9, 10
  TilemapWriteAddressData 18, 10
  TilemapWriteAddressData  9, 20
  TilemapWriteAddressData 18, 20

; Data from A9B6 to A9BD (8 bytes)
DATA_A9B6_TilemapAddresses_GG:
  TilemapWriteAddressData  7, 12
  TilemapWriteAddressData 24, 12
  TilemapWriteAddressData  7, 20
  TilemapWriteAddressData 24, 20

; Data from A9BE to A9C5 (8 bytes)
DATA_A9BE_TilemapAddresses_SMS:
  TilemapWriteAddressData 11, 16
  TilemapWriteAddressData 20, 16
  TilemapWriteAddressData 11, 26
  TilemapWriteAddressData 20, 26

LABEL_A9C6_:
; c = position index (0-3)
; b = tile index (player index 0-3)
  ld a, c
  sla a
  ld e, a
  ld d, $00
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, DATA_A9BE_TilemapAddresses_SMS
  jr ++
+:ld hl, DATA_A9B6_TilemapAddresses_GG
++:
  add hl, de
  ld e, (hl)
  inc hl
  ld d, (hl)
  call LABEL_B361_VRAMAddressToDE
  ld a, b
  add a, $18
  out (PORT_VDP_DATA), a
  EmitDataToVDPImmediate8 $01
  ret

LABEL_A9EB_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  JrZRet _LABEL_AA5D_ret ; ret
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, LABEL_AA8B_
LABEL_AA02_:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  sub $01
  sla a
  ld c, a
  ld b, $00
  ld hl, DATA_AB06_TrackNumberText
  add hl, bc
  ld a, (hl)
  ld (_RAM_DBF1_RaceNumberText + 5), a
  inc hl
  ld a, (hl)
  ld (_RAM_DBF1_RaceNumberText + 6), a
  ld hl, DATA_AACE_TrackNamePointers
  add hl, bc
  ld c, (hl)
  inc hl
  ld b, (hl)
  ld h, b
  ld l, c
  ld a, :DATA_FDC1_TrackNames
  ld (_RAM_D741_RequestedPageIndex), a
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  cp Track_19_WinThisRaceToBeChampion ; Final race
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 11, 16
  call LABEL_B361_VRAMAddressToDE
  ld bc, 20
  TilemapWriteAddressToDE 2, 16
  jr ++

+:TilemapWriteAddressToDE 6, 13
  call LABEL_B361_VRAMAddressToDE
  ld bc, 20
  TilemapWriteAddressToDE 12, 12
++:
  CallRamCode LABEL_3BC6A_EmitText
  call LABEL_B361_VRAMAddressToDE
  ld bc, 8
  ld hl, _RAM_DBF1_RaceNumberText
  CallRamCode LABEL_3BC6A_EmitText
_LABEL_AA5D_ret:
  ret

+++:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS: emit 30 tiles here
  TilemapWriteAddressToHL 0, 16
  ld bc, 30
  jr ++

+:; GG: emit string split across lines
  TilemapWriteAddressToHL 9, 13
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 15
  ld hl, DATA_FFA2_TrackName_24 + 15 ; "TO BE CHAMPION!"
  CallRamCode LABEL_3BC6A_EmitText
  TilemapWriteAddressToHL 9, 12
  ld bc, 15
++:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, DATA_FFA2_TrackName_24 ; " WIN THIS RACE "
  CallRamCode LABEL_3BC6A_EmitText
  ret

LABEL_AA8B_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 0, 15
  jr ++
+:TilemapWriteAddressToHL 0, 12
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0020
  ld hl, TEXT_AAAE_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  ld bc, $0020
  ld hl, TEXT_AAAE_Blanks
  jp LABEL_A5B0_EmitToVDP_Text

TEXT_AAAE_Blanks: .asc "                                "

; Data from AACE to AB05 (56 bytes)
DATA_AACE_TrackNamePointers:
.dw DATA_FDC1_TrackName_00
.dw DATA_FDD5_TrackName_01
.dw DATA_FDE9_TrackName_02
.dw DATA_FDFD_TrackName_03
.dw DATA_FE11_TrackName_04
.dw DATA_FE25_TrackName_05
.dw DATA_FE39_TrackName_06
.dw DATA_FE4D_TrackName_07
.dw DATA_FE61_TrackName_08
.dw DATA_FE75_TrackName_09
.dw DATA_FE89_TrackName_10
.dw DATA_FE9D_TrackName_11
.dw DATA_FEB1_TrackName_12
.dw DATA_FEC5_TrackName_13
.dw DATA_FED9_TrackName_14
.dw DATA_FEED_TrackName_15
.dw DATA_FF01_TrackName_16
.dw DATA_FF15_TrackName_17
.dw DATA_FF29_TrackName_18
.dw DATA_FF3D_TrackName_19
.dw DATA_FF51_TrackName_20
.dw DATA_FF65_TrackName_21
.dw DATA_FF79_TrackName_22
.dw DATA_FF8D_TrackName_23
.dw DATA_FFBF_TrackName_25
.dw DATA_FFBF_TrackName_25
.dw DATA_FFBF_TrackName_25
.dw DATA_FFBF_TrackName_25


DATA_AB06_TrackNumberText:
.asc " 1"
.asc " 2"
.asc " 3"
.asc " 4"
.asc " 5"
.asc " 6"
.asc " 7"
.asc " 8"
.asc " 9"
.db 0,0 ; Helicopter track
.asc "10"
.asc "11"
.asc "12"
.asc "13"
.asc "14"
.asc "15"
.db 0,0 ; Helicopter track
.asc "16"
.asc "17"
.asc "18"
.asc "19"
.db 0,0 ; Helicopter track
.asc "20"
.asc "21"
.asc "22"
.asc "23"
.asc "24"
.asc "25"


; Data from AB3E to AB4C (15 bytes)
DATA_AB3E_CourseSelect_TrackTypes:
; Maps the course select index to a track type
.db TT_4_FormulaOne TT_1_FourByFour TT_5_Warriors TT_7_RuffTrux TT_4_FormulaOne TT_3_TurboWheels TT_5_Warriors TT_2_Powerboats TT_7_RuffTrux TT_6_Tanks TT_4_FormulaOne TT_2_Powerboats TT_8_Helicopters TT_3_TurboWheels TT_1_FourByFour TT_7_RuffTrux TT_6_Tanks TT_5_Warriors TT_8_Helicopters TT_1_FourByFour TT_2_Powerboats TT_6_Tanks TT_3_TurboWheels TT_8_Helicopters TT_1_FourByFour TT_9_Unknown TT_9_Unknown TT_9_Unknown TT_2_Powerboats

LABEL_AB5B_GetPortraitSource_CourseSelect:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  sub $01
  ld c, a
  ld b, $00
  ld hl, DATA_AB3E_CourseSelect_TrackTypes
  add hl, bc
  ld a, (hl)
LABEL_AB68_GetPortraitSource_TrackType:
  ld (_RAM_D691_TitleScreenSlideshowIndex), a
  sla a
  ld de, _DATA_9254_VehiclePortraitOffsets
  add a, e
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ld a, (de)
  ld (_RAM_D7B5_DecompressorSource.Lo), a
  inc de
  ld a, (de)
  ld (_RAM_D7B5_DecompressorSource.Hi), a
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  ld (_RAM_D6A6_DisplayCase_Source), hl
  ret

LABEL_AB86_Decompress3bppTiles_Index100:
  ; Decompresses 80 tiles of 3bpp tile data from the given source address and page to tile $100
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  call LABEL_B478_SelectPortraitPage
  ld hl, (_RAM_D7B5_DecompressorSource)
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $100
  ld de, 80 * 8 ; 80 tiles
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

LABEL_AB9B_Decompress3bppTiles_Index160:
  ; Decompresses 80 tiles of 3bpp tile data from the given source address and page to tile $160
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  call LABEL_B478_SelectPortraitPage
  ld hl, (_RAM_D7B5_DecompressorSource)
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $160
  ld de, 80 * 8 ; 80 tiles
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

LABEL_ABB0_:
  jp LABEL_ABB3_

LABEL_ABB3_:
  xor a
  ld (_RAM_D692_SlideshowPointerOffset), a
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  ld a, $01
  ld (_RAM_D694_DrawCarPortraitTilemap), a
  xor a
  ld (_RAM_D690_CarPortraitTileIndex), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TrackSelect
  jr nz, +
  ld a, $60
  ld (_RAM_D690_CarPortraitTileIndex), a
+:TailCall +

+:ld a, (_RAM_D690_CarPortraitTileIndex)
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 11, 19 ; SMS
  jr ++
+:TilemapWriteAddressToHL 11, 14 ; GG
++:
  xor a
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
--:
  call LABEL_B35A_VRAMAddressToHL
  ld de, 10 ; width
-:ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
  out (PORT_VDP_DATA), a
  EmitDataToVDPImmediate8 1 ; High byte
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
  add a, $01
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec de
  ld a, d
  or e
  jr nz, -
  ld a, (_RAM_D68B_TilemapRectangleSequence_Row)
  cp $07 ; height - 1
  jr z, +
  add a, $01
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
  ld de, TILEMAP_ROW_SIZE
  add hl, de
  jp --

+:
  TailCall LABEL_9276_DrawVehicleName

LABEL_AC1E_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, +++
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_Player1Character)
  ld (_RAM_D6BB_), a
  call LABEL_9F40_LoadPortraitTiles
  call _LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 1, 8
  jr ++

+:
  TilemapWriteAddressToHL 6, 9
  call LABEL_B2B3_
++:
  call LABEL_BCCF_EmitTilemapRectangleSequence
+++:
  TileWriteAddressToHL MenuTileIndex_Portraits.2
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, +
  ld a, (_RAM_DBD4_Player1Character)
  call LABEL_9F40_LoadPortraitTiles
  ld de, $0004
  jp ++

+:
  ld a, (_RAM_DBD5_Player2Character)
  call LABEL_9F40_LoadPortraitTiles
  ld de, $0000
++:
  ld a, $42
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 9, 8
  jr ++

+:
  TilemapWriteAddressToHL 11, 9
  call LABEL_B2B3_
++:
  or a
  sbc hl, de
  call LABEL_BCCF_EmitTilemapRectangleSequence
  TileWriteAddressToHL MenuTileIndex_Portraits.3
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, +
  ld a, (_RAM_DBD5_Player2Character)
  call LABEL_9F40_LoadPortraitTiles
  ld de, $0004
  jp ++

+:
  ld a, (_RAM_DBD6_Player3Character)
  call LABEL_9F40_LoadPortraitTiles
  ld de, $0000
++:
  ld a, $60
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 17, 8
  jr ++

+:
  TilemapWriteAddressToHL 16, 9
  call LABEL_B2B3_
++:
  add hl, de
  call LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  JrZRet +++
  TileWriteAddressToHL MenuTileIndex_Portraits.4
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD7_Player4Character)
  call LABEL_9F40_LoadPortraitTiles
  ld a, $7E
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 25, 8
  jr ++

+:
  TilemapWriteAddressToHL 21, 9
  call LABEL_B2B3_
++:
  call LABEL_BCCF_EmitTilemapRectangleSequence
+++:ret

LABEL_ACEE_DrawColouredBalls:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, +
  ; Four balls
  TilemapWriteAddressToHL 3, 14
  call LABEL_B35A_VRAMAddressToHL
  TilemapWriteAddressToHL 11, 14
  TilemapWriteAddressToBC 19, 14
  TilemapWriteAddressToDE 27, 14
  jr ++

+:; Two balls
  TilemapWriteAddressToHL 9, 14
  call LABEL_B35A_VRAMAddressToHL
  TilemapWriteAddressToDE 21, 14
.ifdef UNNECESSARY_CODE
  jr ++
.endif
++:
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Red
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, + ; Skip green and yellow for 2-player mode
  call LABEL_B35A_VRAMAddressToHL
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Green
  ld h, b
  ld l, c
  call LABEL_B35A_VRAMAddressToHL
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Yellow
+:
  call LABEL_B361_VRAMAddressToDE
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Blue
  ret

LABEL_AD42_DrawDisplayCase:
  ld a, :DATA_3B37F_Tiles_DisplayCase ; $0E
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_3B37F_Tiles_DisplayCase ; $B37F - compressed 3bpp tile data, 2952 bytes = 123 tiles up to $3b970
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $100
  ld de, 123 * 8 ; 123 tiles
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  ld a, :DATA_3B32F_DisplayCaseTilemapCompressed ; $0E
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_3B32F_DisplayCaseTilemapCompressed ; $B32F - compressed data, 440 bytes up to $3b37e
  CallRamCode LABEL_3B97D_DecompressFromHLToC000

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld de, $790A ; 5, 4
  jr ++
+:ld de, $780A ; 5, 0
++:call LABEL_B361_VRAMAddressToDE

  ld hl, _RAM_C000_DecompressionTemporaryBuffer ; decompressed data
  ld a, $16 ; 22x20
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $14
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  xor a
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode LABEL_3BB57_EmitTilemapRectangle

  ; The displayed tilemap includes all the cars, then we blank it out here
  ld bc, $0000
-:ld hl, _RAM_DBD9_DisplayCaseData
  add hl, bc
  ld a, (hl)
  dec a
  jr z, LABEL_AD9C_HaveCar
  dec a
  jr z, +
  call LABEL_AE46_DisplayCase_BlankCar
LABEL_AD9C_HaveCar:
  inc bc
  ld a, c
  cp $18
  jr nz, -
  ret

+:; Flashing car
  ld a, c
  ld (_RAM_D6C2_DisplayCase_FlashingCarIndex), a
  jp LABEL_AD9C_HaveCar

; Data from ADAA to ADD9 (48 bytes)
DATA_ADAA_DisplayCaseSourceDataAddresses: ; Addresses of tilemap data when "restoring" flashing car
.dw $C017 $C01C $C021 $C026 $C059 $C05E $C063 $C068
.dw $C09B $C0A0 $C0A5 $C0AA $C0DD $C0E2 $C0E7 $C0EC
.dw $C11F $C124 $C129 $C12E $C161 $C166 $C16B $C170

; Data from ADDA to AE45 (108 bytes)
DATA_ADDA_DisplayCaseTilemapAddresses: ; Tilemap addresses per car index (0-24)
.dw $784C $7856 $7860 $786A $790C $7916 $7920 $792A ; 6, 1; 11, 1; 16, 1; 21, 1; 6, 4; 11, 4; etc
.dw $79CC $79D6 $79E0 $79EA $7A8C $7A96 $7AA0 $7AAA
.dw $7B4C $7B56 $7B60 $7B6A $7C0C $7C16 $7C20 $7C2A

DATA_AE0A_DisplayCase_BlankRectangle_RuffTruxTop:
.db $04 $05 $05 $05 $06
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
DATA_AE19_DisplayCase_BlankRectangle_RuffTruxMiddle:
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
DATA_AE28_DisplayCase_BlankRectangle_RuffTruxBottom:
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
.db $76 $77 $77 $77 $57

DATA_AE37_DisplayCase_BlankRectangle:
.db $04 $05 $05 $05 $06
.db $4C $4D $4D $4D $19
.db $76 $77 $77 $77 $57

LABEL_AE46_DisplayCase_BlankCar:
; bc = index
  ld (_RAM_D6BC_DisplayCase_IndexBackup), bc ; Unnecessary?
  ld hl, DATA_AE37_DisplayCase_BlankRectangle
  ld (_RAM_D6A6_DisplayCase_Source), hl
LABEL_AE50_DisplayCase_BlankRect:
; bc = index
; hl = source data
  ld a, $02
  ld (_RAM_D741_RequestedPageIndex), a ; Unused?

  ld (_RAM_D6BC_DisplayCase_IndexBackup), bc
  ld a, c ; Look up tilemap address
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_ADDA_DisplayCaseTilemapAddresses
  add hl, de
  ld e, (hl)
  inc hl
  ld d, (hl)
  ld h, d
  ld l, e ; -> hl

  ld a, (_RAM_DC3C_IsGameGear)
  xor $01 ; 1 for SMS, 0 for GG
  ld d, a
  ld e, $00
  add hl, de ; Add 256 for SMS -> shift down by 4 rows
  call LABEL_B35A_VRAMAddressToHL

  ld d, h
  ld e, l
  ld hl, (_RAM_D6A6_DisplayCase_Source)
  ld a, $05 ; 5x3 tilemap rect
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $03
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  xor a
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode LABEL_3BB57_EmitTilemapRectangle
  ld bc, (_RAM_D6BC_DisplayCase_IndexBackup) ; Restore bc (?)
  ret

LABEL_AE94_DisplayCase_RestoreRectangle:
  ld a, $0D
  ld (_RAM_D741_RequestedPageIndex), a ; Unused?

  ld a, c   ; Look up destination address
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_ADDA_DisplayCaseTilemapAddresses
  add hl, de
  ld e, (hl)
  inc hl
  ld d, (hl)

  ex de, hl
    ld a, (_RAM_DC3C_IsGameGear)
    xor $01
    ld d, a
    ld e, $00
    add hl, de ; Shift down 4 rows for SMS
    call LABEL_B35A_VRAMAddressToHL
  ex de, hl

  ld a, c   ; Look up source data address
  sla a
  ld c, a
  ld b, $00
  ld hl, DATA_ADAA_DisplayCaseSourceDataAddresses
  add hl, bc
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld h, a
  ld a, c
  ld l, a

  ; Emit rectangle (5x3)
  ld a, $03
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  JumpToRamCode LABEL_3BC7D_DisplayCase_RestoreRectangle

LABEL_AECD_:
  ld hl, (_RAM_D6A8_DisplayCaseTileAddress)
  ld bc, 25 * TILE_DATA_SIZE ; $0320
  add hl, bc
  call LABEL_B35A_VRAMAddressToHL
  ld hl, DATA_9D37_RacerPortraitsPages
  ld a, (_RAM_D6BB_)
  sra a
  sra a
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld (_RAM_D6A5_), a
  ld (_RAM_D741_RequestedPageIndex), a
  ld d, $00
  ld hl, DATA_9C7F_RacerPortraitsLocations
  ld a, (_RAM_D6BB_)
  sla a
  ld e, a
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, c
  
  ld bc, 3 * 8 * 25 ; $0258 ; Skip 25 tiles @ 3bpp
  add hl, bc
  ld e, 8 * 5 ; $28 ; Emit 5 tiles * 8 rows
  CallRamCode LABEL_03BCAF_Emit3bppTiles
  ld a, $00
  ld (_RAM_D6A4_), a
  ld (_RAM_D6B0_), a
  ret

.define GearToGearStatus_Connected $04 ; TODO move to "System definitions.inc"
; These are game specific
; They should (?) be impossible button presses
.define GearToGearConnect1 $ca
.define GearToGearConnect2 $55

LABEL_AF10_CheckGearToGear:
  ; Do nothing on SMS
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  ret z
  in a, (PORT_GG_LinkStatus)
  and GearToGearStatus_Connected
  jr nz, +++
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, LABEL_AF6F_
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2) ; received value
  cp GearToGearConnect1
  jr z, +
  cp GearToGearConnect2
  jr z, ++
  ; Else send GearToGearConnect1 to see if the other end is there
  ld a, GearToGearConnect1
  out (PORT_GG_LinkSend), a
  ret

+:; Got a $ca
  ; Gear to gear active
  ld a, 1
  ld (_RAM_DC42_GearToGear_IAmPlayer1), a
  ld (_RAM_DC41_GearToGearActive), a
  ; Send GearToGearConnect2 to take control as player 1
  ld a, GearToGearConnect2
  out (PORT_GG_LinkSend), a
  jr LABEL_AF5D_BlankControlsRAM

++:; Got GearToGearConnect2, so we are player 2
  xor a
  ld (_RAM_DC42_GearToGear_IAmPlayer1), a
  ld a, 1
  ld (_RAM_DC41_GearToGearActive), a
  ; Restart music (to indicate connection?)
  ld c, Music_01_TitleScreen
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  jr LABEL_AF5D_BlankControlsRAM ; and ret

.ifdef UNNECESSARY_CODE
  ret
.endif

+++:
  ; No connection
  ; Maybe there used to be a message for it to show?
  call LABEL_AF92_BlankTitleScreenCheatMessage
  xor a
  ld (_RAM_DC41_GearToGearActive), a
.ifdef UNNECESSARY_CODE
  ld a, $00
.endif
  ld (_RAM_DC42_GearToGear_IAmPlayer1), a
  ret

LABEL_AF5D_BlankControlsRAM:
  ld a, NO_BUTTONS_PRESSED
  ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
  ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
  ld (_RAM_D680_Player1Controls_Menus), a
  ld (_RAM_D681_Player2Controls_Menus), a
  ld (_RAM_D687_Player1Controls_PreviousFrame), a
  ret

LABEL_AF6F_:
  ld a, (_RAM_D7BA_HardModeTextFlashCounter)
  inc a
  and $0F
  ld (_RAM_D7BA_HardModeTextFlashCounter), a
  and $08
  jr z, LABEL_AF92_BlankTitleScreenCheatMessage
  TilemapWriteAddressToHL 13, 13
  call LABEL_B35A_VRAMAddressToHL
  ld c, $05
  ld hl, TEXT_AFA0_Link
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  add a, $1B
  out (PORT_VDP_DATA), a
  ret

LABEL_AF92_BlankTitleScreenCheatMessage:
  TilemapWriteAddressToHL 13, 13
  call LABEL_B35A_VRAMAddressToHL
  ld c, $06
  ld hl, TEXT_AAAE_Blanks
  jp LABEL_A5B0_EmitToVDP_Text

TEXT_AFA0_Link: .asc "LINK "

LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL:
  call LABEL_B35A_VRAMAddressToHL
LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM:
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  JumpToRamCode LABEL_3BB31_Emit3bppTileDataToVRAM

LABEL_AFAE_RamCodeLoader:
  ; Trampoline for calling paging code
  ld hl, +  ; Loading Code into RAM
  ld de, _RAM_D640_RamCodeLoader
  ld bc, $0011
  ldir
  jp _RAM_D640_RamCodeLoader  ; Code is loaded from +

; Executed in RAM at d640
+:ld a, :LABEL_3B971_RamCodeLoaderStage2
  ld (_RAM_D741_RequestedPageIndex), a
  ld (PAGING_REGISTER), a ; page in and call
  call LABEL_3B971_RamCodeLoaderStage2
  ld a, :LABEL_AFAE_RamCodeLoader ; $02 ; restore paging
  ld (PAGING_REGISTER), a
  ret

LABEL_AFCD_InitialiseOnePlayerMenu:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_OnePlayerMode
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_B337_BlankTiles
  call LABEL_9400_BlankSprites
  call LABEL_BAFF_LoadFontTiles
  call LABEL_959C_LoadPunctuationTiles
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call LABEL_9448_LoadHeaderTiles
  call LABEL_94AD_DrawHeaderTilemap
  call LABEL_B305_DrawHorizontalLine_Top
  ld c, Music_07_Menus
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  xor a
  ld (_RAM_D6C7_IsTwoPlayer), a
  call LABEL_BB95_LoadSelectMenuGraphics
  call LABEL_BC0C_LoadSelectMenuTilemaps
  call +
  call LABEL_A50C_DrawOnePlayerSelectGameText
  call LABEL_9317_InitialiseHandSprites
  xor a
  ld (_RAM_D6A0_MenuSelection), a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  call LABEL_A673_SelectLowSpriteTiles
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_B01D_SquinkyTennisHook:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  ret z
  ; If a GG...
  ; ...and Start is held...
  in a, (PORT_GG_START)
  add a, a ; start is bit 7, 1 = not pressed
  ret c
  ld a, :DATA_3F753_JonsSquinkyTennisCompressed ;$0F
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_3F753_JonsSquinkyTennisCompressed ;$B753 Up to $3ff78, compressed code (Jon's Squinky Tennis, 5923 bytes)
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  jp _RAM_C000_DecompressionTemporaryBuffer ; $C000

+:
  ld a, :DATA_23656_Tiles_VsCPUPatch ; $08
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_23656_Tiles_VsCPUPatch ; $B656 Up to $237e1, 864 bytes compressed
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $180
  ld de, 36 * 8 ; 36 tiles
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 22, 17 ; GG
  jr ++
+:TilemapWriteAddressToHL 20, 14 ; SMS
++:
  ; Draw it as 6x6 tiles
  ld a, $80
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  TailCall LABEL_BCCF_EmitTilemapRectangleSequence

; 20th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_B06C_Handler_MenuScreen_OnePlayerMode:
  call LABEL_B9C4_CycleGearToGearTrackSelectIndex
  call LABEL_8CA2_ProcessMenuControls_Player1Priority
  ld a, (_RAM_D6A0_MenuSelection)
  or a
  jp z, LABEL_80FC_EndMenuScreenHandler
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jp nz, LABEL_80FC_EndMenuScreenHandler
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_D6A0_MenuSelection)
  dec a
  jr nz, +
  xor a
  ld (_RAM_DC3F_IsTwoPlayer), a
  call LABEL_8205_InitialiseOnePlayerSelectCharacterMenu
  jp LABEL_80FC_EndMenuScreenHandler

+:
  ld a, $01
  ld (_RAM_DC3F_IsTwoPlayer), a
  call LABEL_8953_InitialiseTwoPlayersMenu
  jp LABEL_80FC_EndMenuScreenHandler

; 15th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_B09F_Handler_MenuScreen_TwoPlayerSelectCharacter:
  ld a, (_RAM_D688_)
  or a
  jr z, +
  dec a
  ld (_RAM_D688_), a
  jp LABEL_80FC_EndMenuScreenHandler

+:
  ld a, (_RAM_D6B9_)
  cp $02
  jr z, +
  call LABEL_996E_
  ld a, (_RAM_D6CA_)
  or a
  jp nz, LABEL_B154_
  call LABEL_95C3_
  call LABEL_9B87_
  call LABEL_9D4E_
  ld a, (_RAM_D6B9_)
  or a
  jr z, LABEL_B110_
  dec a
  jr z, LABEL_B132_
  jp LABEL_80FC_EndMenuScreenHandler

+:
  ld a, (_RAM_D6AB_MenuTimer.Hi)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Hi), a
  cp $30 ; 0.96s @ 50Hz, 0.8s @ 60Hz
  jr z, +
  dec a
  call z, LABEL_A645_
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, +
  call LABEL_89E2_
  jp LABEL_80FC_EndMenuScreenHandler

+:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  or a
  jr nz, +
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld a, MenuScreen_OnePlayerTrackIntro
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $01
  ld (_RAM_D6C1_), a
  call LABEL_9400_BlankSprites
  jp LABEL_80FC_EndMenuScreenHandler

+:
  jp LABEL_84AA_MenuIndex5_Initialise

LABEL_B110_:
  ld a, (_RAM_D6CD_)
  cp $02
  jp z, LABEL_80FC_EndMenuScreenHandler
  add a, $01
  ld (_RAM_D6CD_), a
  dec a
  jr z, +
  dec a
  jr z, ++
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_A645_
  jp LABEL_80FC_EndMenuScreenHandler

++:
  call LABEL_A5C9_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B132_:
  ld a, (_RAM_D6CD_)
  cp $02
  jp z, LABEL_80FC_EndMenuScreenHandler
  add a, $01
  ld (_RAM_D6CD_), a
  dec a
  jr z, +
  dec a
  jr z, ++
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_A5F9_
  jp LABEL_80FC_EndMenuScreenHandler

++:
  call LABEL_A618_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B154_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, +
  xor a
  ld (_RAM_D6CB_MenuScreenState), a
  jp +++

+:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $08
  jr z, LABEL_B1B9_Left
  or a
  jr nz, LABEL_B1B6_Select
  ld a, (_RAM_D6C6_)
  dec a
  jr z, +
-:
  ld a, (_RAM_D680_Player1Controls_Menus)
  jp ++

+:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, -
+:
  ld a, (_RAM_D681_Player2Controls_Menus)
++:
  ld (_RAM_D6C9_ControllingPlayersLR1Buttons), a
  and BUTTON_L_MASK ; $04
  jr z, LABEL_B1B9_Left
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_R_MASK ; $08
  jr z, _Right
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jr nz, LABEL_B1B6_Select
+++:
  xor a
  ld (_RAM_D6CA_), a
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  srl a
  srl a
  srl a
  ld c, a
  ld b, $00
  ld hl, _RAM_DC21_CharacterStates
  add hl, bc
  ld a, (_RAM_D6CB_MenuScreenState)
  ld (hl), a
  call LABEL_9E52_
LABEL_B1B6_Select:
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B1B9_Left:
  xor a
  ld (_RAM_D6CB_MenuScreenState), a
  call LABEL_B389_
  ld bc, $0005
  call LABEL_A5B0_EmitToVDP_Text
  jp LABEL_80FC_EndMenuScreenHandler

_Right:
  ld a, $01
  ld (_RAM_D6CB_MenuScreenState), a
  call LABEL_B389_
  ld hl, TEXT_B1E7_Yes
  ld bc, $0005
  call LABEL_A5B0_EmitToVDP_Text
  jp LABEL_80FC_EndMenuScreenHandler

TEXT_B1DD_No:   .asc "-NO- "
TEXT_B1E2_No:   .asc " -NO-"
TEXT_B1E7_Yes:  .asc "-YES-"

LABEL_B1EC_Trampoline_PlayMenuMusic:
  ld a, :LABEL_30CE8_PlayMenuMusic
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode LABEL_3BCDC_Trampoline2_PlayMenuMusic

LABEL_B1F4_Trampoline_StopMenuMusic:
  ld a, :LABEL_30D28_StopMenuMusic
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode LABEL_3BCE6_Trampoline_StopMenuMusic

LABEL_B1FC_TwoPlayerTrackSelect_GetIndex:
  ld a, (_RAM_DC34_IsTournament)
  dec a
  JrZRet +
  ld hl, DATA_B219_TwoPlayerTrackSelectIndices
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex)
  sub $01 ; Make 0-based
-:
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld (_RAM_DBD8_TrackIndex_Menus), a
+:ret

LABEL_B213_GearToGearTrackSelect_GetIndex:
  ld hl, DATA_B222_GearToGearTrackSelectIndices
  jp -

DATA_B219_TwoPlayerTrackSelectIndices:
.db Track_02_DesktopDropOff
.db Track_14_CrayonCanyons
.db Track_0E_PitfallPockets
.db Track_17_ChalkDustChicane
.db Track_0D_BedroomBattlefield
.db Track_04_SandyStraights
.db Track_07_HandymansCurve
.db Track_15_SoapLakeCity
.db Track_05_OatmealInOverdrive

; Data from B222 to B229 (8 bytes)
; Gear to Gear track select options? Nearly the same as SMS, except:
; - pro ones are gone
; - qualifying race is in (!)
; - order is changed
DATA_B222_GearToGearTrackSelectIndices:
.db Track_02_DesktopDropOff
.db Track_15_SoapLakeCity
.db Track_0E_PitfallPockets
.db Track_05_OatmealInOverdrive
.db Track_07_HandymansCurve
.db Track_00_QualifyingRace
.db Track_04_SandyStraights
.db Track_0D_BedroomBattlefield

LABEL_B22A_DisplayCase_BlankRuffTrux:
  call LABEL_B230_DisplayCase_BlankRuffTrux
  jp LABEL_8E54_

LABEL_B230_DisplayCase_BlankRuffTrux:
  ld bc, $000F
  ld hl, DATA_AE0A_DisplayCase_BlankRectangle_RuffTruxTop
  ld (_RAM_D6A6_DisplayCase_Source), hl
  call LABEL_AE50_DisplayCase_BlankRect
  ld bc, $0013
  ld hl, DATA_AE19_DisplayCase_BlankRectangle_RuffTruxMiddle
  ld (_RAM_D6A6_DisplayCase_Source), hl
  call LABEL_AE50_DisplayCase_BlankRect
  ld bc, $0017
  ld hl, DATA_AE28_DisplayCase_BlankRectangle_RuffTruxBottom
  ld (_RAM_D6A6_DisplayCase_Source), hl
  jp LABEL_AE50_DisplayCase_BlankRect ; and ret

LABEL_B254_DisplayCase_RestoreRuffTrux:
  ld bc, $000F
  call LABEL_AE94_DisplayCase_RestoreRectangle
  ld bc, $0013
  call LABEL_AE94_DisplayCase_RestoreRectangle
  ld bc, $0017
  call LABEL_AE94_DisplayCase_RestoreRectangle
  jp LABEL_8E54_

LABEL_B269_IncrementCourseSelectIndex:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  add a, $01
  ld (_RAM_DBD8_TrackIndex_Menus), a
  ; Skip helicopters by recursing (!)
  cp Track_0A_ThePottedPassage
  jr z, LABEL_B269_IncrementCourseSelectIndex
  cp Track_11_TheShrubberyTwist
  jr z, LABEL_B269_IncrementCourseSelectIndex
  cp Track_16_TheLeafyBends
  jr z, LABEL_B269_IncrementCourseSelectIndex
  ; Does not attempt to wrap
  ret

LABEL_B27E_DecrementCourseSelectIndex:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  sub $01
  or a
  jr nz, +
  ; Wrap from $01 to $1c
  ld a, Track_1C_RuffTrux3
+:
  ld (_RAM_DBD8_TrackIndex_Menus), a
  ; Skip helicopters
  cp Track_0A_ThePottedPassage
  jr z, LABEL_B27E_DecrementCourseSelectIndex
  cp Track_11_TheShrubberyTwist
  jr z, LABEL_B27E_DecrementCourseSelectIndex
  cp Track_16_TheLeafyBends
  jr z, LABEL_B27E_DecrementCourseSelectIndex
  ret

LABEL_B298_IncrementCourseSelectIndex:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  add a, $01
  cp Track_1C_RuffTrux3+1
  jr nz, +
  ; Wrap from $1c to $01
  ld a, $01
+:
  ld (_RAM_DBD8_TrackIndex_Menus), a
  ; Skip helicopters
  cp Track_0A_ThePottedPassage
  jr z, LABEL_B298_IncrementCourseSelectIndex
  cp Track_11_TheShrubberyTwist
  jr z, LABEL_B298_IncrementCourseSelectIndex
  cp Track_16_TheLeafyBends
  jr z, LABEL_B298_IncrementCourseSelectIndex
  ret

LABEL_B2B3_:
  ld a, (_RAM_D6C3_)
  ld c, a
  ld a, h
  sub c
  ld h, a
  ret

LABEL_B2BB_DrawMenuScreenBase_WithLine:
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_9400_BlankSprites
  call LABEL_90CA_BlankTiles_BlankControls
  call LABEL_BAFF_LoadFontTiles
  call LABEL_959C_LoadPunctuationTiles
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  JrZRet +
  call LABEL_9448_LoadHeaderTiles
  call LABEL_94AD_DrawHeaderTilemap
  call LABEL_B305_DrawHorizontalLine_Top
+:ret

LABEL_B2DC_DrawMenuScreenBase_NoLine:
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_9400_BlankSprites
  call LABEL_90CA_BlankTiles_BlankControls
  call LABEL_BAFF_LoadFontTiles
  call LABEL_959C_LoadPunctuationTiles
  call LABEL_9448_LoadHeaderTiles
  jp LABEL_94AD_DrawHeaderTilemap

LABEL_B2F3_DrawHorizontalLines_CharacterSelect:
  TilemapWriteAddressToHL 0, 19
  call LABEL_B35A_VRAMAddressToHL
  call LABEL_95AF_DrawHorizontalLineIfSMS
  TilemapWriteAddressToHL 0, 26
  call LABEL_B35A_VRAMAddressToHL
  call LABEL_95AF_DrawHorizontalLineIfSMS
  ; fall through

LABEL_B305_DrawHorizontalLine_Top:
  TilemapWriteAddressToHL 0, 5
  call LABEL_B35A_VRAMAddressToHL
  jp LABEL_95AF_DrawHorizontalLineIfSMS

LABEL_B30E_:
  ld a, $01
  ld (_RAM_D6C0_), a
-:
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  ld a, (_RAM_D6B9_)
  ret

LABEL_B31C_:
  xor a
  ld (_RAM_D6C0_), a
  jp -

LABEL_B323_PopulatePlayerPortraitValues:
  ; Copies data from DATA_97DF_8TimesTable to _RAM_DBFE_PlayerPortraitValues
  ; This selects the first portrait of each player
  ld hl, DATA_97DF_8TimesTable
  ld de, _RAM_DBFE_PlayerPortraitValues
  ld bc, 0 ; would be faster to ldir
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  inc bc
  ld a, c
  cp 11
  jr nz, -
  ret

LABEL_B337_BlankTiles:
  TileWriteAddressToHL $00
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 256 * TILE_DATA_SIZE ; lower tiles
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  TileWriteAddressToHL $100
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 184 * TILE_DATA_SIZE ; Upper tiles
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

LABEL_B35A_VRAMAddressToHL:
  ld a, l
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ret

LABEL_B361_VRAMAddressToDE:
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ret

LABEL_B368_:
  ld a, $01
  ld (_RAM_D6C1_), a
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6C5_PaletteFadeIndex), a
  ret

_LABEL_B375_ConfigureTilemapRect_5x6_Portrait1:
  ld a, $24
_LABEL_B377_ConfigureTilemapRect_5x6_rega:
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $05
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  ret

LABEL_B389_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 22, 16 ; SMS
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_B1DD_No
  JrRet ++
+:TilemapWriteAddressToHL 21, 21 ; GG
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_B1E2_No
++:ret

LABEL_B3A4_EmitToVDPAtDE_Text:
  call LABEL_B361_VRAMAddressToDE
  ld bc, $000E
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_B3AE_:
  ld a, $06 ; Counter to draw 6 portraits
  ld (_RAM_D6AB_MenuTimer.Lo), a ; Using this as a counter now
  ld a, (_RAM_D6AD_)
  sub 1
  cp -1
  jr nz, +
  ld a, 10
+:ld c, a
  ld b, $00
  call LABEL_B412_Scale_RAM_DBFB_PortraitCurrentIndex
  ; fall through
-:; Look up tile address for that scaled index (assume it's even)
  ld hl, DATA_9773_TileWriteAddresses_AvailablePortraits
  add hl, de
  ld (_RAM_D6BE_TileWriteAddress), de
  ld e, (hl)
  inc hl
  ld d, (hl)
  ; And set it
  call LABEL_B361_VRAMAddressToDE
  ; And remember it TODO rename variable
  ld (_RAM_D6A8_DisplayCaseTileAddress), de
  ; _RAM_D6BB_ = player index * 8
  ld hl, DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  
  ld hl, _RAM_DBFE_PlayerPortraitValues
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BC_DisplayCase_IndexBackup), bc
  call LABEL_9F40_LoadPortraitTiles
  call LABEL_AECD_
  ld bc, (_RAM_D6BC_DisplayCase_IndexBackup)
  ld de, (_RAM_D6BE_TileWriteAddress)
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
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  sub $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
  or a
  jr nz, -
  ret

LABEL_B412_Scale_RAM_DBFB_PortraitCurrentIndex:
; scaling by system
; Could be inlined
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS
  ld a, (_RAM_DBFB_PortraitCurrentIndex) ; Subtract 3 then divide by 4 -> de
  sub $03
  sra a
  sra a
  ld d, $00
  ld e, a
  ret

+:ld a, (_RAM_DBFB_PortraitCurrentIndex)
  ld e, a
  ld d, $00
  ld hl, DATA_9849_
  add hl, de
  ld e, (hl)
.ifdef UNNECESSARY_CODE
  ld d, $00 ; already 0 above
.endif
  ret

LABEL_B433_ResetMenuTimerOnControlPress:
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  cp BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  jr nz, +
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  cp BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  jr nz, +
  ret

+:
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ret

LABEL_B44E_BlankMenuRAM:
  ld bc, _RAM_D7BB_MenuRamEnd - _RAM_D680_MenuRamStart ; Size of menu RAM
  ld hl, _RAM_D680_MenuRamStart ; Start of menu RAM
-:xor a
  ld (hl), a
  dec bc
  inc hl
  ld a, b
  or c
  jr nz, -
  ret

LABEL_B45D_:
  ld a, (_RAM_D6D4_Slideshow_PendingLoad) ; Only if 1
  or a
  JpZRet +
  ld a, (_RAM_D691_TitleScreenSlideshowIndex)
  call LABEL_B478_SelectPortraitPage
  ld hl, (_RAM_D7B5_DecompressorSource)
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  xor a
  ld (_RAM_D6D4_Slideshow_PendingLoad), a
  ld (_RAM_D6D3_VBlankDone), a
+:ret

LABEL_B478_SelectPortraitPage:
  ; Indexes into a table with a to select the page number for a subsequent call to RAM code
  ld e, a
  ld d, $00
  ld hl, _DATA_926C_VehiclePortraitPageNumbers
  add hl, de
  ld a, (hl)
  ld (_RAM_D741_RequestedPageIndex), a
  ret

LABEL_B484_CheckTitleScreenCheatCodes:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  JrNzRet ++ ; ret
  ; We wait for a "no buttons pressed" state between each button press.
  ld a, (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen)
  or a
  jr z, +
  ld a, (_RAM_D680_Player1Controls_Menus) ; We just saw one, wait for the buttons to lift
  cp NO_BUTTONS_PRESSED ; $3F
  JrNzRet ++ ; ret
  xor a
  ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a ; Clear the flag
  ret

+:; We are ready to check. Was anything pressed?
  ld a, (_RAM_D680_Player1Controls_Menus)
  cp NO_BUTTONS_PRESSED ; $3F
  JrZRet ++ ; ret
  ; We saw something - check it
  ld e, a
  call _CheckForCheatCode_HardMode
  call _CheckForCheatCode_CourseSelect
++:ret

; Data from B4AB to B4B4 (10 bytes)
DATA_B4AB_CheatKeys_HardMode:
.db BUTTON_U_ONLY
.db BUTTON_2_ONLY
.db BUTTON_D_ONLY
.db BUTTON_2_ONLY
.db BUTTON_2_ONLY
.db BUTTON_L_ONLY
.db BUTTON_2_ONLY
.db BUTTON_2_ONLY
.db BUTTON_2_ONLY
.db 0
; $3e = %00111110 = U
; $1f = %00011111 = 2
; $3d = %00111101 = D
; $1f = %00011111 = 2
; $1f = %00011111 = 2
; $3b = %00111011 = L
; $1f = %00011111 = 2
; $1f = %00011111 = 2
; $1f = %00011111 = 2
; 0               = end

; Data from B4B5 to B4B9 (5 bytes)
DATA_B4B5_CheatKeys_CourseSelect:
.db BUTTON_U_ONLY
.db BUTTON_D_ONLY
.db BUTTON_L_ONLY
.db BUTTON_R_ONLY
.db BUTTON_L_ONLY
.db BUTTON_2_ONLY
.db BUTTON_U_ONLY
.db BUTTON_U_ONLY
.db BUTTON_2_ONLY
.db BUTTON_U_ONLY
.db 0

_CheckForCheatCode_HardMode:
  ld a, (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect) ; Get index of next button press
  ld c, a
  ld b, $00
  ld hl, DATA_B4AB_CheatKeys_HardMode  ; Look up the button press
  add hl, bc
  ld a, (hl)
  cp e  ; Compare to what we have
  jr nz, +
  ld a, (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect) ; If it matches, increase the index
  add a, $01
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ld a, $01
  ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
  ret

+:; If no match, reset the counter
  xor a
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ret

_CheckForCheatCode_CourseSelect:
  ld a, (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode) ; Get index of next button press
  ld c, a
  ld b, $00
  ld hl, DATA_B4B5_CheatKeys_CourseSelect ; Look up the button press
  add hl, bc
  ld a, (hl)
  or a
  jr z, +
  cp e
  jr nz, +
  ld a, (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode) ; If it matches, increase the index
  add a, $01
  ld (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode), a
  ld a, $01
  ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
  ret

+:
  xor a
  ld (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode), a
  ret

LABEL_B505_UpdateHardModeText:
  ld a, (_RAM_DC46_Cheat_HardMode)
  or a
  ret z
  ; Get ready
  TilemapWriteAddressToHL 9, 13
  call LABEL_B35A_VRAMAddressToHL
  ; Increment counter
  ld a, (_RAM_D7BA_HardModeTextFlashCounter)
  inc a
  and $0F
  ld (_RAM_D7BA_HardModeTextFlashCounter), a
  ; Draw or blank every 8 frames
  and $08
  jr z, +++
  ; Draw
  ld a, (_RAM_DC46_Cheat_HardMode)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ret

+:
  ld c, $0C
  ld hl, TEXT_B541_HardMode
  jp LABEL_A5B0_EmitToVDP_Text ; and ret

++:
  ld c, $0E
  ld hl, TEXT_B54D_RockHardMode
  jp LABEL_A5B0_EmitToVDP_Text ; and ret

+++:
-:
  ld c, $0E
  ld hl, TEXT_AAAE_Blanks
  jp LABEL_A5B0_EmitToVDP_Text ; and ret

TEXT_B541_HardMode:     .asc "  HARD  MODE"
TEXT_B54D_RockHardMode: .asc "ROCK HARD MODE"

.ifdef UNNECESSARY_CODE
  ; Turns off the cheats and blanks any text shown
  xor a
  ld (_RAM_DC46_Cheat_HardMode), a
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ld (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode), a
  TilemapWriteAddressToHL 9, 13
  call LABEL_B35A_VRAMAddressToHL
  jr -
.endif

; 17th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_B56D_Handler_MenuScreen_TrackSelect:
  call LABEL_B9C4_CycleGearToGearTrackSelectIndex
  call LABEL_A2AA_PrintOrFlashMenuScreenText
  call LABEL_9FC5_
  ld a, (_RAM_D6C1_)
  cp $01
  jr z, LABEL_B5E7_
  ld a, (_RAM_DC34_IsTournament)
  cp $01
  jr nz, ++
  call LABEL_B9A3_CombinePlayerMenuControlButtons
  ld a, (_RAM_D6CB_MenuScreenState)
  xor $01
  ld (_RAM_D6CB_MenuScreenState), a
  cp $01
  jr z, +
  ; Increment counter
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $B8 ; 3.68s @ 50Hz, 3.06666666666667s @ 60Hz
  jr z, ++++
  cp $40 ; 1.28s @ 50Hz, 1.06666666666667s @ 60Hz
  jr nc, +++
  jp LABEL_B618_

++:
  ld a, (_RAM_D693_SlowLoadSlideshowTiles)
  cp $01
  jp z, LABEL_B6AB_
  cp $00
  jp nz, LABEL_A129_
  call LABEL_B98E_GetMenuControls
  ld a, (_RAM_D697_)
  cp $01
  jr z, LABEL_B623_
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_L_MASK ; $04
  jp z, LABEL_B640_
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_R_MASK ; $08
  jp z, LABEL_B666_
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex)
  cp $00
  jr z, LABEL_B618_
+++:
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jr nz, LABEL_B618_
++++:
  call LABEL_B368_
  call LABEL_9400_BlankSprites
  jp LABEL_B618_

LABEL_B5E7_:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
  cp $04
  jr nz, LABEL_B618_
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call LABEL_BD2F_PaletteFade
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +
  call LABEL_B1FC_TwoPlayerTrackSelect_GetIndex
  ld a, $01
  ld (_RAM_DC3D_IsHeadToHead), a
  ld (_RAM_D6D5_InGame), a
LABEL_B618_:
  jp LABEL_80FC_EndMenuScreenHandler

+:
  ld a, $01
  ld (_RAM_D6D5_InGame), a
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B623_:
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  cp BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  jr nz, LABEL_B618_
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr nz, +
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  cp BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  jr nz, LABEL_B618_
+:
  xor a
  ld (_RAM_D697_), a
  ret

LABEL_B640_:
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +++
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex)
  sub $01
  cp -1
  jr z, +
  or a
  jr nz, ++
+:
  ld a, $09 ; number of tracks in table
++:
  ld (_RAM_D6CC_TwoPlayerTrackSelectIndex), a
  jp ++++

+++:
  call LABEL_B27E_DecrementCourseSelectIndex
  call LABEL_AB5B_GetPortraitSource_CourseSelect
  call LABEL_AA8B_
  jp +++++

LABEL_B666_:
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, ++
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex)
  add a, $01
  cp $0A ; count + 1
  jr nz, +
  ld a, $01
+:
  ld (_RAM_D6CC_TwoPlayerTrackSelectIndex), a
  jp ++++

++:
  call LABEL_B298_IncrementCourseSelectIndex
  call LABEL_AB5B_GetPortraitSource_CourseSelect
  call LABEL_AA8B_
  jp +++++

++++:
  call LABEL_A01C_
  call LABEL_AB68_GetPortraitSource_TrackType
+++++:
  call LABEL_A0F0_BlankTilemapRectangle
  ld a, $01
  ld (_RAM_D6D4_Slideshow_PendingLoad), a
  ld a, $09
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  TileWriteAddressToDE $160
  ld (_RAM_D6A8_DisplayCaseTileAddress), de
  ld a, $01
  ld (_RAM_D697_), a
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B6AB_:
  call LABEL_ABB3_
  jp LABEL_80FC_EndMenuScreenHandler

; 18th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_B6B1_Handler_MenuScreen_TwoPlayerResult:
  call LABEL_B9C4_CycleGearToGearTrackSelectIndex
  call LABEL_A039_
  ld hl, (_RAM_D6AB_MenuTimer)
  inc hl
  ld (_RAM_D6AB_MenuTimer), hl
  ld a, h
  cp $01
  jr z, +
  ld a, l
  cp $80
  jr c, ++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr z, +
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, +++
  call LABEL_8114_MenuIndex0_TitleScreen_Initialise
++:
  jp LABEL_80FC_EndMenuScreenHandler

+++:
  ld a, (_RAM_DC36_)
  cp $04
  jr z, +
  ld a, (_RAM_DC37_)
  cp $04
  jr z, +
  ld a, (_RAM_DC35_TournamentRaceNumber)
  cp $07
  jr z, +
  add a, $01
  ld (_RAM_DC35_TournamentRaceNumber), a
  call LABEL_8A30_InitialiseTwoPlayersRaceSelectMenu
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B877_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B70B_:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_TrackSelect
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, <MenuTileIndex_Font.Space
  call LABEL_9170_BlankTilemap_BlankControlsRAM
  call LABEL_9400_BlankSprites
  call LABEL_90CA_BlankTiles_BlankControls
  call LABEL_BAFF_LoadFontTiles
  call LABEL_959C_LoadPunctuationTiles
  call LABEL_A296_LoadHandTiles
  ld a, $01
  ld (_RAM_DC3B_IsTrackSelect), a
  ld (_RAM_D6CC_TwoPlayerTrackSelectIndex), a
  ld (_RAM_DBD8_TrackIndex_Menus), a
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call LABEL_9448_LoadHeaderTiles
  call LABEL_94AD_DrawHeaderTilemap
  TilemapWriteAddressToHL 0, 5
  call LABEL_B35A_VRAMAddressToHL
  call LABEL_95AF_DrawHorizontalLineIfSMS
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld (_RAM_D6C1_), a
  ld (_RAM_D693_SlowLoadSlideshowTiles), a
  ld (_RAM_D6CE_), a
  call LABEL_AB5B_GetPortraitSource_CourseSelect
  call LABEL_AB9B_Decompress3bppTiles_Index160
  call LABEL_ABB0_
  ld c, Music_07_Menus
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  call LABEL_A673_SelectLowSpriteTiles
  call LABEL_9317_InitialiseHandSprites
  ld hl, DATA_2B356_SpriteNs_HandLeft
  CallRamCode LABEL_3BBB5_PopulateSpriteNs
  call LABEL_BF2E_LoadMenuPalette_SMS
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_B77C_:
  ld hl, _RAM_DC36_
  add hl, de
  ld a, (hl)
  add a, $01
  ld (hl), a
  ret

LABEL_B785_:
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  rrca
  ld e, a
  ld d, $00
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 14, 7
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC36_)
  call LABEL_B7F1_
  TilemapWriteAddressToHL 14, 8
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  call LABEL_B7F9_
  TilemapWriteAddressToHL 17, 7
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC37_)
  call LABEL_B7F1_
  TilemapWriteAddressToHL 17, 8
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  jp LABEL_B7F9_

+:
  TilemapWriteAddressToHL 14, 17
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC36_)
  call LABEL_B7F1_
  TilemapWriteAddressToHL 14, 18
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  call LABEL_B7F9_
  TilemapWriteAddressToHL 17, 17
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC37_)
  call LABEL_B7F1_
  TilemapWriteAddressToHL 17, 18
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  jp LABEL_B7F9_

LABEL_B7F1_:
  sla a
  add a, $60
  ld c, a
  out (PORT_VDP_DATA), a
  ret

LABEL_B7F9_:
  ld a, c
  add a, $01
  out (PORT_VDP_DATA), a
  ret

LABEL_B7FF_:
  ld de, $0000
  ld a, (_RAM_DBD4_Player1Character)
  ld c, a
  ld a, (_RAM_DBCF_LastRacePosition)
  call +
  ld de, $0001
  ld a, (_RAM_DBD5_Player2Character)
  ld c, a
  ld a, (_RAM_DBD0_LastRacePosition_Player2)
  jp +

+:
  or a
  jr z, +
  ld hl, _RAM_DC16_
  jp ++

+:
  call LABEL_B77C_
  ld hl, _RAM_DC0B_
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

; 19th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_B84D_Handler_MenuScreen_TournamentChampion:
  call LABEL_B911_
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $FF ; 5.1s @ 50Hz, 4.25s @ 60Hz
  jr z, +
  add a, $01
  ld (_RAM_D6AB_MenuTimer.Lo), a
  cp $80 ; 2.56s @ 50Hz, 2.13333333333333s @ 60Hz

  jr c, ++
+:
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr z, +
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call LABEL_B1F4_Trampoline_StopMenuMusic
  call LABEL_8114_MenuIndex0_TitleScreen_Initialise
++:
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B877_:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_TournamentChampion
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call LABEL_B2DC_DrawMenuScreenBase_NoLine
  call LABEL_B305_DrawHorizontalLine_Top
  call LABEL_B8CF_LoadTrophyTiles
  call LABEL_B8E3_LoadTrophyTilemap
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC34_IsTournament)
  or a
  jr nz, +
  ld c, Music_03_Ending
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  jp ++

+:
  ld c, Music_0C_TwoPlayerTournamentWinner
  call LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr z, ++
  ld a, (_RAM_DBD5_Player2Character)
  jp +++

++:
  ld a, (_RAM_DBD4_Player1Character)
+++:
  call LABEL_9F40_LoadPortraitTiles
  TilemapWriteAddressToHL 19, 16
  call LABEL_B8C9_EmitTilemapRectangle_5x6_24
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_B8C9_EmitTilemapRectangle_5x6_24:
  call _LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
  jp LABEL_BCCF_EmitTilemapRectangleSequence

LABEL_B8CF_LoadTrophyTiles:
  ld a, :DATA_1B2C3_Tiles_Trophy
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_1B2C3_Tiles_Trophy
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $160
  ld de, 82 * 8 ; 82 tiles
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

LABEL_B8E3_LoadTrophyTilemap:
  ld a, :DATA_279F0_Tilemap_Trophy
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_279F0_Tilemap_Trophy
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TilemapWriteAddressToHL 7, 14
  call LABEL_B35A_VRAMAddressToHL
  TilemapWriteAddressToDE 7, 14
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  ld a, $0C
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $09
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, $60
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  JumpToRamCode LABEL_3BB57_EmitTilemapRectangle

LABEL_B911_:
  ld a, (_RAM_D6AF_FlashingCounter)
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, +++
  ld a, (_RAM_DC3F_IsTwoPlayer)
  dec a
  jr z, ++
  TilemapWriteAddressToHL 6, 11
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC34_IsTournament)
  or a
  jr z, +
  ld hl, TEXT_B966_TournamentChampion
  ld bc, $0014
  jp LABEL_A5B0_EmitToVDP_Text

+:
  ld hl, TEXT_B97A_Challenge
  ld bc, $0014
  jp LABEL_A5B0_EmitToVDP_Text

++:
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_B984_Champion
  ld bc, $000A
  jp LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 6, 11
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_AAAE_Blanks
  ld bc, $0014
  jp LABEL_A5B0_EmitToVDP_Text

; Data from B966 to B979 (20 bytes)
TEXT_B966_TournamentChampion:
.asc "TOURNAMENT CHAMPION!"

; Data from B97A to B983 (10 bytes)
TEXT_B97A_Challenge:
.asc "CHALLENGE "

; Data from B984 to B98D (10 bytes)
TEXT_B984_Champion:
.asc "CHAMPION !"

LABEL_B98E_GetMenuControls:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, LABEL_B9A3_CombinePlayerMenuControlButtons
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, LABEL_B9A3_CombinePlayerMenuControlButtons

  ; If GG and not Gear-to-Gear, only use player 1
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  ld (_RAM_D6C9_ControllingPlayersLR1Buttons), a
  ret

LABEL_B9A3_CombinePlayerMenuControlButtons:
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  ld c, a
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  and c
  ld (_RAM_D6C9_ControllingPlayersLR1Buttons), a
  ret

LABEL_B9B3_Initialise_RAM_DC2C_GGTrackSelectFlags:
  ld hl, _RAM_DC2C_GGTrackSelectFlags
  ld c, $08
-:
  xor a
  ld (hl), a
  inc hl
  dec c
  jr nz, -
  ; Mark index 5 as "done"
  ld a, $01
  ld (_RAM_DC2C_GGTrackSelectFlags+5), a
  ret

LABEL_B9C4_CycleGearToGearTrackSelectIndex:
; This is called every frame so it sort of randomises the starting index?
  ; Loop up to 8 times
  ld e, $08
-:; Increment index (and loop 7->0)
  ld a, (_RAM_D6CF_GearToGearTrackSelectIndex)
  add a, $01
  and $07
  ld (_RAM_D6CF_GearToGearTrackSelectIndex), a
  ; Index into _RAM_DC2C_GGTrackSelectFlags
  ld c, a
  ld b, $00
  ld hl, _RAM_DC2C_GGTrackSelectFlags
  add hl, bc
  ld a, (hl)
  or a
  ; Break when we find a 0
  jr z, +
  dec e
  jr nz, - ; Else loop

+:; _RAM_D6CF_GearToGearTrackSelectIndex is either back where it started, or pointing at the first unset index found
  ; Then we increment (and loop) this... TODO what is it?
  ld a, (_RAM_D7B3_)
  add a, $01
  cp $0B
  jr nz, +
  ld a, $01
+:ld (_RAM_D7B3_), a
  ret

LABEL_B9ED_:
  ; Set VRAM address
  
  ; Offset location for GG by $40 = 2 rows
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  rrca
  rrca
  ld e, a
  ld d, $00
  
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 8, 10
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Red
  TilemapWriteAddressToHL 23, 10
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Blue
  ret

+:
  TilemapWriteAddressToHL 8, 20
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Red
  TilemapWriteAddressToHL 23, 20
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  EmitDataToVDPImmediate16 MenuTileIndex_ColouredBalls.Blue
  ret

LABEL_BA3C_LoadColouredBallTilesToIndex150:
  TileWriteAddressToHL MenuTileIndex_ColouredBalls
  call LABEL_B35A_VRAMAddressToHL
  ; fall through
  
LABEL_BA42_LoadColouredBallTiles:
  ld a, :DATA_22B8C_Tiles_ColouredBalls
  ld (_RAM_D741_RequestedPageIndex), a
  ld e, 4 * 8 ; 4 tiles
  ld hl, DATA_22B8C_Tiles_ColouredBalls
  JumpToRamCode LABEL_3BB45_Emit3bppTileDataToVRAM

LABEL_BA4F_LoadMediumNumberTiles:
  ld a, :DATA_2794C_Tiles_MediumNumbers
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_2794C_Tiles_MediumNumbers
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 10 * 8 ; 10 tiles
  TileWriteAddressToHL $60
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

LABEL_BA63_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  JrZRet +
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jr nz, ++
  ; Text
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, TEXT_BAB7_Qualifying
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 11, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, TEXT_BAC1_Race
  call LABEL_A5B0_EmitToVDP_Text
+:ret

++:
  ; Blanks (for flashing)
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, TEXT_BACB_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 11, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, TEXT_BACB_Blanks
  TailCall LABEL_A5B0_EmitToVDP_Text

; Data from BAB7 to BAC0 (10 bytes)
TEXT_BAB7_Qualifying:
.asc "QUALIFYING"

; Data from BAC1 to BACA (10 bytes)
TEXT_BAC1_Race:
.asc "   RACE   "

; Data from BACB to BAD4 (10 bytes)
TEXT_BACB_Blanks:
.asc "          "

LABEL_BAD5_LoadMenuLogoTiles:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS: big logo
  ld a, :DATA_22C4E_Tiles_BigLogo
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_22C4E_Tiles_BigLogo
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 177 * 8 ; 177 tiles
  jr ++

+:; GG: medium logo
  ld a, :DATA_3E5D7_Tiles_MediumLogo
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_3E5D7_Tiles_MediumLogo
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ld de, 112 * 8 ; 122 tiles
++:
  TileWriteAddressToHL MenuTileIndex_Title_Logo
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL ; and ret

LABEL_BAFF_LoadFontTiles:
  ld a, :DATA_2B02D_Tiles_Font
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_2B02D_Tiles_Font
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Font
  ld de, 36 * 8 ; 36 tiles
  jp LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

LABEL_BB13_InitialiseTitleScreenCarPortraitSlideshow:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +

  ; SMS: draw sports cars portrait into tiles
  ld a, :DATA_FAA5_Tiles_Portrait_SportsCars
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_FAA5_Tiles_Portrait_SportsCars
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  ld de, 80 * 8 ; 80 tiles
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  ; (Seems not to be used... the slideshow does not use it)
  jr ++

+:; GG: blank tiles
  ld bc, 80 * 32 ; 80 tiles
  TileWriteAddressToHL MenuTileIndex_Portraits.1
  call LABEL_B35A_VRAMAddressToHL
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -

++:
  ld a, $01
  ld (_RAM_D6CB_MenuScreenState), a
  TailCall LABEL_90E7_

LABEL_BB49_SetMenuHScroll:
; SMS scroll 6, GG scroll 0
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, $06
  jr ++
+:xor a
++:
.else
.ifdef IS_GAME_GEAR
  xor a
.else
  ld a, 6
.endif
.endif
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_XSCROLL
  out (PORT_VDP_REGISTER), a
  ret

LABEL_BB5B_SetBackdropToColour0:
  xor a
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_BACKDROP_COLOUR
  out (PORT_VDP_REGISTER), a
  ret

; Data from BB63 to BB6B (9 bytes)
.ifdef UNNECESSARY_CODE
LABEL_BB63_ScreenOn:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENON
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret
.endif

LABEL_BB6C_ScreenOff:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENOFF
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_BB75_ScreenOnAtLineFF:
  ; Wait for line $ff
  ; This can be the end of VBlank or it can be earlier!
  ; (Not sure what purpose this serves... turning it on earlier doesn't hurt?)
-:in a, (PORT_VDP_LINECOUNTER)
  cp $FF
  jr nz, -
  ; Screen on
  ld a, VDP_REGISTER_MODECONTROL2_SCREENON
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ei
  ret

LABEL_BB85_ScreenOffAtLineFF:
-:di
  ; Wait for line $ff
  ; See comments above
  in a, (PORT_VDP_LINECOUNTER)
  cp $FF
  jr nz, -
  ; Screen off
  ld a, VDP_REGISTER_MODECONTROL2_SCREENOFF
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_BB95_LoadSelectMenuGraphics:
  ld a, (_RAM_D6C7_IsTwoPlayer)
  dec a
  jr z, _TwoPlayerTournamentSingleRaceGraphics

  ; _RAM_D6C7_IsTwoPlayer != 1
  ; Load "Challenge" icon
  ld a, :DATA_26C52_Tiles_Challenge_Icon
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_26C52_Tiles_Challenge_Icon
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Select_Icon1
  ld de, 60 * 8 ; 60 tiles - smaller than a car portrait
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ; GG
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_SelectPlayerCount
  jr z, ++
+:; Both SMS and (GG if not selecting player count)
  ; Load "head to head" image tiles
  ld hl, DATA_26FC6_Tiles_HeadToHead_Icon
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Select_Icon2
  ld de, 60 * 8 ; 60 tiles again
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  jp +++

++:
  ; GG selecting player count: replace "head to head" icon with "two players on one game gear"
  ld hl, DATA_27A12_Tiles_TwoPlayersOnOneGameGear_Icon
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Select_Icon2
  ld de, 60 * 8 ; 60 tiles again
  call LABEL_BD94_Emit4bppTileDataToVRAMAddressHL
  jp +++

_TwoPlayerTournamentSingleRaceGraphics:
  ; _RAM_D6C7_IsTwoPlayer == 1
  ; Load tournament icon
  ld a, :DATA_27391_Tiles_Tournament_Icon
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_27391_Tiles_Tournament_Icon
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Select_Icon1
  ld de, 54 * 8 ; 54 tiles
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

  ld hl, DATA_27674_Tiles_SingleRace_Icon
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL MenuTileIndex_Select_Icon2
  ld de, 54 * 8 ; 54 tiles
  call LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

+++:
  call LABEL_A296_LoadHandTiles
  call LABEL_949B_LoadHeadToHeadTextTiles ; immediately after in VRAM
  jp LABEL_948A_LoadChallengeTextTiles ; immediately after in VRAM - and ret

LABEL_BC0C_LoadSelectMenuTilemaps:
  ld a, (_RAM_D6C7_IsTwoPlayer)
  or a
  jr z, +
  ld a, 9 ; 9x6
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  jp ++
+:ld a, 10 ; 10x6
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
++:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 4, 18
  jr ++
+:TilemapWriteAddressToHL 6, 15
++:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerMode
  jr nz, +
  ; Subtract a row
  ld de, TILEMAP_ROW_SIZE
  or a
  sbc hl, de
+:
  ld a, MenuTileIndex_Select_Icon1
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, 6
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call LABEL_BCCF_EmitTilemapRectangleSequence

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 18, 18
  jr ++
+:TilemapWriteAddressToHL 16, 15
++:
  ld a, (_RAM_D6C7_IsTwoPlayer)
  or a
  jr z, +
  ; Right by 1
  inc hl
  inc hl
+:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerMode
  jr nz, +
  ; Down a row
  ld de, TILEMAP_ROW_SIZE
  or a
  sbc hl, de
+:ld a, MenuTileIndex_Select_Icon2  
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  call LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  JrZRet +++
  
  ; For the "challenge/head to head" screen, draw graphical text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 4, 25
  jr ++
+:TilemapWriteAddressToDE 6, 21
++:
  call LABEL_B361_VRAMAddressToDE
  ld hl, DATA_2B4BA_Tilemap_ChallengeText ; 8x2
  ld a, 8
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, 2
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, MenuTileIndex_Select_Text2
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode LABEL_3BB57_EmitTilemapRectangle
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 18, 25
  jr ++
+:TilemapWriteAddressToDE 16, 21
++:
  call LABEL_B361_VRAMAddressToDE
  ld hl, DATA_2B5BE_Tilemap_HeadToHeadText ; 10x2
  ld a, 10
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, 2
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, MenuTileIndex_Select_Text1
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode LABEL_3BB57_EmitTilemapRectangle

+++:ret

LABEL_BCCF_EmitTilemapRectangleSequence:
  ; Emits a rectangle of tilemap data
  ; with sequential tile indexes
  ; hl = start location
  ; _RAM_D69A_TilemapRectangleSequence_Width = width
  ; _RAM_D69B_TilemapRectangleSequence_Height = height (modified)
  ; _RAM_D68A_TilemapRectangleSequence_TileIndex = start tile index (modified)
  ; _RAM_D69C_TilemapRectangleSequence_Flags = tile high byte
  call LABEL_B35A_VRAMAddressToHL
  ld de, (_RAM_D69A_TilemapRectangleSequence_Width) ; Width (silly to read as word?)
-:
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex) ; Tile to start with?
  out (PORT_VDP_DATA), a
  ld a, (_RAM_D69C_TilemapRectangleSequence_Flags) ; High byte
  out (PORT_VDP_DATA), a
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex) ; Increment tile index
  add a, $01
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec de             ; loop over column counter
  ld a, e
  or a
  jr nz, -
  ld a, (_RAM_D69B_TilemapRectangleSequence_Height) ; Decrement row counter
  sub $01
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  or a
  JrZRet +
  ld de, TILEMAP_ROW_SIZE
  add hl, de
  jp LABEL_BCCF_EmitTilemapRectangleSequence

+:ret

LABEL_BD00_InitialiseVDPRegisters:
  SetVDPRegisterImmediate VDP_REGISTER_MODECONTROL1, VDP_REGISTER_MODECONTROL1_VALUE
  SetVDPRegisterImmediate VDP_REGISTER_NAMETABLEBASEADDRESS, VDP_REGISTER_NAMETABLEBASEADDRESS_VALUE
  SetVDPRegisterImmediate VDP_REGISTER_SPRITETABLEBASEADDRESS, VDP_REGISTER_SPRITETABLEBASEADDRESS_VALUE
  SetVDPRegisterImmediate VDP_REGISTER_SPRITESET, VDP_REGISTER_SPRITESET_HIGH
  SetVDPRegisterImmediate VDP_REGISTER_XSCROLL, 0
  SetVDPRegisterImmediate VDP_REGISTER_YSCROLL, 0
  ret

LABEL_BD2F_PaletteFade:
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $06
  jr z, LABEL_BD7C_
  cp $03
  jr nc, +
  ld hl, DATA_BD58_Palettes_SMS
  call LABEL_BD82_GetPalettePointerAndSelectIndex0
  ld b, 7 ; count
  ld c, PORT_VDP_DATA
  otir
  ld hl, $C010 ; Palette index $10
  CallRamCode LABEL_3BCC7_VRAMAddressToHL
  ld a, (de) ; 0th palette value
  out (PORT_VDP_DATA), a
+:
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  add a, $01
  ld (_RAM_D6C5_PaletteFadeIndex), a
  ret

; Pointer Table from BD58 to BD5B (2 entries, indexed by unknown)
DATA_BD58_Palettes_SMS:
.dw DATA_BD5E_Palette1_SMS DATA_BD65_Palette2_SMS DATA_BD6C_Palette3_SMS

; 1st entry of Pointer Table from BD58 (indexed by unknown)
; Data from BD5E to BD64 (7 bytes)
DATA_BD5E_Palette1_SMS:
  ; Full intensity
  SMSCOLOUR $000055
  SMSCOLOUR $aaaaaa
  SMSCOLOUR $005500
  SMSCOLOUR $550000
  SMSCOLOUR $aa0000
  SMSCOLOUR $aa5500
  SMSCOLOUR $0000aa

; 2nd entry of Pointer Table from BD58 (indexed by unknown)
; Data from BD65 to BD6B (7 bytes)
DATA_BD65_Palette2_SMS:
  ; Darker
  SMSCOLOUR $000000
  SMSCOLOUR $555555
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $550000
  SMSCOLOUR $550000
  SMSCOLOUR $000055

; Data from BD6C to BD7B (16 bytes)
DATA_BD6C_Palette3_SMS:
DATA_BD6C_ZeroData:
  ; Black (16 entries)
.dsb 16 $00

LABEL_BD7C_:
  ld a, $FF
  ld (_RAM_D6C5_PaletteFadeIndex), a
  ret

LABEL_BD82_GetPalettePointerAndSelectIndex0:
  ; Gets a'th pointer to de and hl, also sets palette index to 0
  sla a
  ld c, a
  ld b, $00
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  PaletteAddressToHLSMS 0 ; Palette index 0
  CallRamCode LABEL_3BCC7_VRAMAddressToHL
  ld h, d
  ld l, e
  ret

LABEL_BD94_Emit4bppTileDataToVRAMAddressHL:
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
-:
  ld b, $04 ; bytes per row
  ld c, PORT_VDP_DATA
  otir
  dec de
  ld a, d
  or e
  jr nz, -
  ret

LABEL_BDA6_:
; Unknown purpose - character select related?
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6A3_), a
  ld a, NO_BUTTONS_PRESSED ; $3F
  ld (_RAM_D680_Player1Controls_Menus), a
  ld (_RAM_D681_Player2Controls_Menus), a
  ld (_RAM_D687_Player1Controls_PreviousFrame), a
  ret

LABEL_BDB8_LoadGG2PlayerIcon:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  JrZRet +
  ; GG only
  ; Replace "head to head" with "2 players on one GG" icon
  ld a, :DATA_17C0C_Tiles_TwoPlayersOnOneGameGear
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_17C0C_Tiles_TwoPlayersOnOneGameGear
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $170
  ld de, 20 * 8 ; 20 tiles
  call LABEL_BD94_Emit4bppTileDataToVRAMAddressHL
  TilemapWriteAddressToHL 16, 21
  ld a, <MenuTileIndex_Select_Icon3 ; $70
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, 2
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, 10
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  ld a, >MenuTileIndex_Select_Icon3
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call LABEL_BCCF_EmitTilemapRectangleSequence
+:ret

LABEL_BDED_LoadMenuLogoTilemap: ; TODO: how does it work for GG?
  ; Decompress to RAM
  ld a, :DATA_2FF6F_Tilemap
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_2FF6F_Tilemap
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  ; Draw to name table
  TilemapWriteAddressToHL 0, 0
  call LABEL_B35A_VRAMAddressToHL
  TilemapWriteAddressToDE 0, 0
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  ld a, 32
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, 11
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  xor a
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  JumpToRamCode LABEL_3BB57_EmitTilemapRectangle ; and ret

LABEL_BE1A_InitiallyDrawCopyrightText:
  ; Only if state != 0
  ld a, (_RAM_D6CB_MenuScreenState)
  or a
  ret z
  xor a
  ld (_RAM_D6CB_MenuScreenState), a
  TilemapWriteAddressToHL 0, 26
  call LABEL_B35A_VRAMAddressToHL
  ld c, $1A
  ld hl, TEXT_BE77_CopyrightCodemasters
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 0, 27
  call LABEL_B35A_VRAMAddressToHL
  ld c, $1C
  ld hl, TEXT_BE91_SoftwareCompanyLtd1993
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 4, 16
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_BEAD_MasterSystemVersionBy
  ld c, $18
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 18
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_BEC5_AshleyRoutledge
  ld c, $14
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 19
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_BED9_And
  ld c, $0D
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 20
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_BEE4_DavidSaunders
  ld c, $11
  jp LABEL_A5B0_EmitToVDP_Text ; and ret

; Data from BE77 to BE90 (26 bytes)
TEXT_BE77_CopyrightCodemasters:
.asc "     COPYRIGHT CODEMASTERS"

; Data from BE91 to BEAC (28 bytes)
TEXT_BE91_SoftwareCompanyLtd1993:
.asc "   SOFTWARE COMPANY LTD 1993"

; Data from BEAD to BEC4 (24 bytes)
TEXT_BEAD_MasterSystemVersionBy:
.asc "MASTER SYSTEM VERSION BY"

; Data from BEC5 to BED8 (20 bytes)
TEXT_BEC5_AshleyRoutledge:
.asc "  ASHLEY ROUTLEDGE  "

; Data from BED9 to BEE3 (11 bytes)
TEXT_BED9_And:
.asc "        AND"

; Data from BEE4 to BEF4 (17 bytes)
TEXT_BEE4_DavidSaunders:
.asc "   DAVID SAUNDERS"

LABEL_BEF5_TitleScreen_ClearText:
  ; We draw some blanks where the text shows around the vehicle portrait
  ; This is a bit of a hack! Better to clear it at the right time
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_Title
  ret nz
  TilemapWriteAddressToHL 4, 16
  call +
  TilemapWriteAddressToHL 4, 18
  call +
  TilemapWriteAddressToHL 4, 20
  call +
  TilemapWriteAddressToHL 21, 16
  call +
  TilemapWriteAddressToHL 21, 18
  call +
  TilemapWriteAddressToHL 21, 20
.ifdef UNNECESSARY_CODE
  jr +
.endif

+:call LABEL_B35A_VRAMAddressToHL
  ld c, $07
-:EmitDataToVDPImmediate8 <MenuTileIndex_Font.Space
  xor a
  out (PORT_VDP_DATA), a
  dec c
  jr nz, -
  ret

LABEL_BF2E_LoadMenuPalette_SMS:
  PaletteAddressToHLSMS 0 ; Palette index 0
  call LABEL_B35A_VRAMAddressToHL
  ld hl, DATA_BF3E_MenuPalette_SMS
  ld b, 32
  ld c, PORT_VDP_DATA
  otir
  ret

; Data from BF3E to BF4F (18 bytes)
DATA_BF3E_MenuPalette_SMS:
  SMSCOLOUR $5500aa
  SMSCOLOUR $ffffff
  SMSCOLOUR $00aa00
  SMSCOLOUR $aa0000
  SMSCOLOUR $ff5555
  SMSCOLOUR $ffaa00
  SMSCOLOUR $5555ff
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $5500aa ; $10
  SMSCOLOUR $ffffff
  SMSCOLOUR $00aa00
  SMSCOLOUR $aa0000
  SMSCOLOUR $ff5555
  SMSCOLOUR $ffaa00
  SMSCOLOUR $aaaaff
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

.ifdef UNNECESSARY_CODE
; GG-only code, misaligned here
; Looks like the equivalent of the above - but not hooked up
LABEL_BF5E_: 
  jr + ; Weird
+:call $B358 ; not a function
  ld c, $05
-:EmitDataToVDPImmediate8 $0e
  xor a
  out (PORT_VDP_DATA), a
  dec c
  jr nz, -
  ret

LABEL_BF70_: ; unused code? Left over memory?
  ld hl, $c000
  call $b358 ; not a function
  ld hl, DATA_BF80_MenuPalette_GG
  ld b, $40
  ld c, PORT_VDP_DATA
  otir
  ret

DATA_BF80_MenuPalette_GG: ; GG menu palette
  GGCOLOUR $440088
  GGCOLOUR $EEEEEE
  GGCOLOUR $008800
  GGCOLOUR $880000
  GGCOLOUR $EE4444
  GGCOLOUR $EE8800
  GGCOLOUR $4444EE
  GGCOLOUR $000000
  GGCOLOUR $222222
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $004400
  GGCOLOUR $00CC00
  GGCOLOUR $00EE00
  GGCOLOUR $EEAAAA
  GGCOLOUR $000000
  GGCOLOUR $440088
  GGCOLOUR $EEEEEE
  GGCOLOUR $008800
  GGCOLOUR $880000
  GGCOLOUR $EE4444
  GGCOLOUR $EE8800
  GGCOLOUR $8888EE
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
.endif

.ifdef BLANK_FILL_ORIGINAL
.db $FE $FF $EE $FF $FE $EF $EF $EE $FF $FF $EF $EF $FA $EF $FF
.db $7F $EA $EF $EE $FF $FA $FF $EB $FF $FF $FE $7F $EF $BA $FE $EF
.db $EE $FE $FB $EF $EB $FB $EF $AE $BD $FE $FF $EF $EE $AF $BF $FF
.db $FF $FF $FF $FE $BB $EE $FB $EF $EE $FE $FF $FF $BA $FE $FF $EF
.endif
;.ends

.orga $bfff
DATA_BFFF_Page2PageNumber:
.db :CADDR

.BANK 3
.ORG $0000
;.section "Bank 3"

/*
; Track data format:
; $8000 dw Pointer to behaviour data (compressed) -> 2308B
; $8002 dw Pointer to wall data (compressed) -> 1156B = 12*12 bits * 6 yiles + 4 byte header
; $8004 dw Pointer to track 0 layout (compressed) = 2048B = 32 * 32 * 2
; $8006 dw Pointer to track 1 layout (compressed) = 2048B = 32 * 32 * 2
; $8008 dw Pointer to track 2 layout (compressed) = 2048B = 32 * 32 * 2
; $800a dw Pointer to track 3 layout (compressed) = 2048B = 32 * 32 * 2 (usually not set to something sensible as most track types only have three tracks)
; $800c dw Pointer to GG palette = 64B = 16 * 2 * 2
; $800e dw Pointer to "decorator" tile data = 128B = 16 * 8 * 8 * 1bpp tile
; $8010 dw Pointer to ??? (copied to _RAM_D900_) = 64B
; $8012 dw Pointer to effects tile data = 264B = 11 * 8 * 8 * 3bpp tile
; $8014 dsb 108 Unused!
; $8080 dsb 144*n Metatile indices for n metatiles (varies by track)
*/

.struct TrackData
BehaviourData   dw
WallData        dw
TrackLayout0    dw
TrackLayout1    dw
TrackLayout2    dw
TrackLayout3    dw
GameGearPalette dw
DecoratorTiles  dw
UnknownData     dw
EffectsTiles    dw
.endst

; Desk tracks data
.dstruct DATA_C000_TrackData_SportsCars instanceof TrackData data  DATA_E480_SportsCars_BehaviourData DATA_E799_SportsCars_WallData DATA_E811_SportsCars_Track0Layout DATA_EA34_SportsCars_Track1Layout DATA_ED79_SportsCars_Track2Layout DATA_F155_SportsCars_Track3Layout DATA_F155_SportsCars_GGPalette DATA_F195_SportsCars_DecoratorTiles DATA_F215_SportsCarsDATA DATA_F255_SportsCars_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $FF $FF $BF $FF $FF $FF $FF $FF $FF $FF $BF $FF $FF $FF $7F $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $DF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF
.endif
;.ends

.orga $8080
;.section "Sportscars metatiles" force
.incbin "Assets/Sportscars/Metatiles.tilemap" ; 64 metatiles

; Pretty much all this could be split up to optimise packing

DATA_E480_SportsCars_BehaviourData:
.incbin "Assets/Sportscars/Behaviour data.compressed"
DATA_E799_SportsCars_WallData:
.incbin "Assets/Sportscars/Wall data.compressed"
DATA_E811_SportsCars_Track0Layout:
.incbin "Assets/Sportscars/Track 0 layout.compressed"
DATA_EA34_SportsCars_Track1Layout:
.incbin "Assets/Sportscars/Track 1 layout.compressed"
DATA_ED79_SportsCars_Track2Layout:
.incbin "Assets/Sportscars/Track 2 layout.compressed"
DATA_F155_SportsCars_Track3Layout:
; missing
DATA_F155_SportsCars_GGPalette:
  GGCOLOUR $000000
  GGCOLOUR $444400
  GGCOLOUR $884400
  GGCOLOUR $EEEEEE
  GGCOLOUR $888888
  GGCOLOUR $444444
  GGCOLOUR $880000
  GGCOLOUR $004488
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
DATA_F195_SportsCars_DecoratorTiles
.incbin "Assets/Sportscars/Decorators.1bpp"
DATA_F215_SportsCarsDATA:
.db $22 $00 $5D $4D $6F $7B $00 $00 $00 $00 $22 $22 $22 $22 $80 $C0 $C0 $C0 $C0 $E0 $E0 $C0 $E0 $C0 $80 $A0 $A0 $A0 $A0 $A0 $22 $C0 $22 $C0 $A0 $A0 $C0 $C0 $C0 $C0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $80 $80 $C0 $A0 $80 $C0 $00 $00
DATA_F255_SportsCars_EffectsTiles:
.incbin "Assets/Sportscars/Effects.3bpp"

; And these could be superfree sections
DATA_F35D_Tiles_Portrait_FourByFour:
.incbin "Assets/Four By Four/Portrait.3bpp.compressed"

DATA_F765_Tiles_Portrait_Warriors:
.incbin "Assets/Warriors/Portrait.3bpp.compressed"

DATA_FAA5_Tiles_Portrait_SportsCars:
.incbin "Assets/Sportscars/Portrait.3bpp.compressed"

; Track names
DATA_FDC1_TrackNames:
DATA_FDC1_TrackName_00: .asc "THE BREAKFAST BENDS "
DATA_FDD5_TrackName_01: .asc "  DESKTOP DROP-OFF  "
DATA_FDE9_TrackName_02: .asc "    OILCAN ALLEY    "
DATA_FDFD_TrackName_03: .asc "  SANDY STRAIGHTS   "
DATA_FE11_TrackName_04: .asc "OATMEAL IN OVERDRIVE"
DATA_FE25_TrackName_05: .asc "THE CUE-BALL CIRCUIT"
DATA_FE39_TrackName_06: .asc "  HANDYMANS CURVE   "
DATA_FE4D_TrackName_07: .asc "  BERMUDA BATHTUB   "
DATA_FE61_TrackName_08: .asc "   SAHARA SANDPIT   "
DATA_FE75_TrackName_09: .asc " THE POTTED PASSAGE " ; Helicopter!
DATA_FE89_TrackName_10: .asc "FRUIT-JUICE FOLLIES "
DATA_FE9D_TrackName_11: .asc "    FOAMY FJORDS    "
DATA_FEB1_TrackName_12: .asc "BEDROOM BATTLEFIELD "
DATA_FEC5_TrackName_13: .asc "  PITFALL POCKETS   "
DATA_FED9_TrackName_14: .asc "  PENCIL PLATEAUX   "
DATA_FEED_TrackName_15: .asc "THE DARE-DEVIL DUNES"
DATA_FF01_TrackName_16: .asc "THE SHRUBBERY TWIST " ; Helicopter!
DATA_FF15_TrackName_17: .asc " PERILOUS PIT-STOP  "
DATA_FF29_TrackName_18: .asc "WIDE-AWAKE WAR-ZONE "
DATA_FF3D_TrackName_19: .asc "   CRAYON CANYONS   "
DATA_FF51_TrackName_20: .asc "  SOAP-LAKE CITY !  "
DATA_FF65_TrackName_21: .asc "  THE LEAFY BENDS   " ; Helicopter!
DATA_FF79_TrackName_22: .asc " CHALK-DUST CHICANE "
DATA_FF8D_TrackName_23: .asc "     GO FOR IT!     "
DATA_FFA2_TrackName_24: .asc " WIN THIS RACE TO BE CHAMPION!" ; Special case for length
DATA_FFBF_TrackName_25: .asc "RUFFTRUX BONUS STAGE"

; blank fill
.ifdef BLANK_FILL_ORIGINAL
.dsb 44 $ff
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 4
.ORG $0000
;.section "Bank 4" force

; Data from 10000 to 13FFF (16384 bytes)
.dstruct DATA_10000_TrackData_FourByFour instanceof TrackData data DATA_9E50_FourByFour_BehaviourData DATA_A105_FourByFour_WallData DATA_A152_FourByFour_Track0Layout DATA_A378_FourByFour_Track1Layout DATA_A466_FourByFour_Track2Layout DATA_A466_FourByFour_Track3Layout DATA_A762_FourByFour_GGPalette DATA_A7A2_FourByFour_DecoratorTiles DATA_A822_FourByFourDATA DATA_A862_FourByFour_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $EF $FF $EF $EB $FF $FB $FF $BF $BF $FF $FF $FF $EF $EF $BF $EF $FF $AF $FF $FF $FF $AF $EF $FF $BF $FF $EF $FF $FF $FF $FF $FF $FF $ED $45 $EF $FF $EF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FF $FF $EF $FF $FF $EF $FF $FF $EF $EF $FF $FF $FE $FF $EF $EF $FF $FF $AF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $FF $FF $EF $FF $FF $BB $FF $FB $FF $FF $FE $FF $FF $FF $FF $FB $FF $FE $EF $FB $FF
.endif

;.ends

.orga $8080
;.section "Four by Four metatiles" force
.incbin "Assets/Four By Four/Metatiles.tilemap"

DATA_9E50_FourByFour_BehaviourData:
.incbin "Assets/Four by Four/Behaviour data.compressed"
DATA_A105_FourByFour_WallData:
.incbin "Assets/Four by Four/Wall data.compressed"
DATA_A152_FourByFour_Track0Layout:
.incbin "Assets/Four by Four/Track 0 layout.compressed"
DATA_A378_FourByFour_Track1Layout:
.incbin "Assets/Four by Four/Track 1 layout.compressed"
DATA_A466_FourByFour_Track2Layout:
DATA_A466_FourByFour_Track3Layout: ; missing
.incbin "Assets/Four by Four/Track 2 layout.compressed"
DATA_A762_FourByFour_GGPalette:
  GGCOLOUR $000000
  GGCOLOUR $884400
  GGCOLOUR $444400
  GGCOLOUR $CCCCCC
  GGCOLOUR $888888
  GGCOLOUR $004488
  GGCOLOUR $4488EE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000

  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000

DATA_A7A2_FourByFour_DecoratorTiles:
.incbin "Assets/Four by Four/Decorators.1bpp"

DATA_A822_FourByFourDATA:
.db $C0 $00 $22 $49 $73 $00 $00 $00 $00 $22 $22 $22 $22 $00 $C0 $C0
.db $C0 $C0 $C0 $C0 $C0 $C0 $80 $80 $80 $00 $80 $C0 $C0 $C0 $A0 $C0
.db $22 $C0 $C0 $80 $80 $80 $80 $80 $00 $00 $80 $80 $80 $80 $80 $00
.db $00 $80 $80 $80 $80 $45 $77 $00 $00 $00 $00 $00 $00 $00 $00 $00

DATA_A862_FourByFour_EffectsTiles:
.incbin "Assets/Four by Four/Effects.3bpp"

DATA_1296A_CarTiles_RuffTrux:
.incbin "Assets/RuffTrux/Car.3bpp.runencoded"
.dsb 3, 0 ; padding?

DATA_13C42_Tiles_BigNumbers:
.incbin "Assets/Menu/Numbers-Big.3bpp.compressed"

DATA_13D7F_Tiles_MicroMachinesText:
.incbin "Assets/Menu/Text-MicroMachines.3bpp.compressed"

DATA_13F38_Tilemap_SmallLogo: ; 8x3
.incbin "Assets/Menu/Logo-small.tilemap"

DATA_13F50_Tilemap_MicroMachinesText:
.incbin "Assets/Menu/Text-MicroMachines.tilemap"

.ifdef BLANK_FILL_ORIGINAL
.db $00 $00 $20 $00 $00 $02 $00 $00 $02 $00 $08 $00 $00 $00 $00 $00 $00 $08 $00 $00 $02 $80 $00 $00 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FB $FF $FF $FF $FA $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FE $FF $FF $FF $FF
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 5
.ORG $0000
;.section "Bank 5" force

.dstruct DATA_14000_TrackData_Powerboats instanceof TrackData data DATA_9D30_Powerboats_BehaviourData DATA_9FE3_Powerboats_WallData DATA_A03C_Powerboats_Track0Layout DATA_A134_Powerboats_Track1Layout DATA_A352_Powerboats_Track2Layout DATA_A5B1_Powerboats_Track3Layout DATA_A7A0_Powerboats_GGPalette DATA_A7E0_Powerboats_DecoratorTiles DATA_A860_PowerboatsDATA DATA_A8A0_Powerboats_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $CF $FF $FF $ED $45 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FB $FF $FF $FF
.endif
;.ends

.orga $8080
;.section "Powerboats metatiles" force
.incbin "Assets/Powerboats/Metatiles.tilemap"

DATA_9D30_Powerboats_BehaviourData:
.incbin "Assets/Powerboats/Behaviour data.compressed"
DATA_9FE3_Powerboats_WallData:
.incbin "Assets/Powerboats/Wall data.compressed"
DATA_A03C_Powerboats_Track0Layout:
.incbin "Assets/Powerboats/Track 0 layout.compressed"
DATA_A134_Powerboats_Track1Layout:
.incbin "Assets/Powerboats/Track 1 layout.compressed"
DATA_A352_Powerboats_Track2Layout:
.incbin "Assets/Powerboats/Track 2 layout.compressed"
DATA_A5B1_Powerboats_Track3Layout:
.incbin "Assets/Powerboats/Track 3 layout.compressed"
DATA_A7A0_Powerboats_GGPalette:
  GGCOLOUR $444488
  GGCOLOUR $000000
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $440000
  GGCOLOUR $884400
  GGCOLOUR $004444
  GGCOLOUR $448888
  GGCOLOUR $440088
  GGCOLOUR $444488
  GGCOLOUR $8888EE
  GGCOLOUR $EEEEEE
  GGCOLOUR $8888EE
  GGCOLOUR $444488
  GGCOLOUR $440088
  GGCOLOUR $000044
  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
DATA_A7E0_Powerboats_DecoratorTiles:
.incbin "Assets/Powerboats/Decorators.1bpp"
DATA_A860_PowerboatsDATA:
.db $C0 $A0 $A0 $E0 $73 $80 $C0 $49 $80 $E0 $77 $C0 $45 $C0 $A0 $A0
.db $A0 $C0 $80 $80 $80 $00 $80 $80 $80 $A0 $A0 $C0 $C0 $22 $A0 $A0
.db $A0 $A0 $80 $C0 $80 $80 $A0 $A0 $A0 $22 $41 $63 $A0 $A0 $A0 $A0
.db $A0 $A0 $A0 $A0 $A0 $A0 $A0 $80 $C0 $C0 $C0 $41 $A0 $00 $00 $00
DATA_A8A0_Powerboats_EffectsTiles:
.incbin "Assets/Powerboats/Effects.3bpp"

; Data from 169A8 to 16A37 (144 bytes)
DATA_169A8_IndexToBitmask:
.repeat 144/8
.db %10000000
.db %01000000
.db %00100000
.db %00010000
.db %00001000
.db %00000100
.db %00000010
.db %00000001
.endr

; Data from 16A38 to 17DD4 (5021 bytes)
DATA_16A38_DivideBy8:
.define n 0
.repeat 144
.db n/8
.redefine n n+1
.endr
.undefine n

DATA_16AC8_Tiles_Portrait_TurboWheels:
.incbin "Assets/Turbo Wheels/Portrait.3bpp.compressed"

DATA_16F2B_Tiles_Portrait_FormulaOne:
.incbin "Assets/Formula One/Portrait.3bpp.compressed"

DATA_1736E_Tiles_Portrait_Tanks:
.incbin "Assets/Tanks/Portrait.3bpp.compressed"

DATA_Tiles_MrQuestion:
.incbin "Assets/racers/MrQuestion.3bpp"

DATA_Tiles_OutOfGame:
.incbin "Assets/racers/OutOfGame.3bpp"

DATA_17C0C_Tiles_TwoPlayersOnOneGameGear:
.incbin "Assets/Menu/Text-TwoPlayersOnOneGameGear.4bpp.compressed"

; Data from 17DD5 to 17E54 (128 bytes)
DATA_17DD5_Tiles_Playoff:
.incbin "Assets/Playoff.4bpp"

LABEL_17E95_LoadPlayoffTiles:
  SetTileAddressImmediate $19c
  ld bc, 4 * 8 ; 4 tiles
  ld hl, DATA_17DD5_Tiles_Playoff
  call LABEL_17EB4_LoadTileRow
  SetTileAddressImmediate $1a4
  ld bc, 2 * 8 ; 2 tiles
  ld hl, DATA_17DD5_Tiles_Playoff+4*32
  ; fall through
LABEL_17EB4_LoadTileRow:
-:push bc
    ld b, $04
    ld c, PORT_VDP_DATA
    otir
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

; Pointer Table from 17EC2 to 17ED1 (8 entries, indexed by _RAM_DB97_TrackType)
DATA_17EC2_SMSPalettes:
.dw DATA_17ED2_SMSPalette_SportsCars
.dw DATA_17EF2_SMSPalette_FourByFour
.dw DATA_17F12_SMSPalette_Powerboats
.dw DATA_17F32_SMSPalette_TurboWheels
.dw DATA_17F52_SMSPalette_FormulaOne
.dw DATA_17F72_SMSPalette_Warriors
.dw DATA_17F92_SMSPalette_Tanks
.dw DATA_17FB2_SMSPalette_RuffTrux

; 1st entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17ED2 to 17EF1 (32 bytes)
DATA_17ED2_SMSPalette_SportsCars:
  SMSCOLOUR $000000
  SMSCOLOUR $555500
  SMSCOLOUR $AA5500
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $555555
  SMSCOLOUR $AA0000
  SMSCOLOUR $0055AA
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

; 2nd entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17EF2 to 17F11 (32 bytes)
DATA_17EF2_SMSPalette_FourByFour:
  SMSCOLOUR $000000
  SMSCOLOUR $AA5500
  SMSCOLOUR $555500
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $0055AA
  SMSCOLOUR $55AAFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

; 3rd entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F12 to 17F31 (32 bytes)
DATA_17F12_SMSPalette_Powerboats:
  SMSCOLOUR $5555AA
  SMSCOLOUR $000000
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFFF00
  SMSCOLOUR $555500
  SMSCOLOUR $AAAA00
  SMSCOLOUR $005555
  SMSCOLOUR $55AAAA
  SMSCOLOUR $5500AA
  SMSCOLOUR $5555AA
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $5555AA
  SMSCOLOUR $5500AA
  SMSCOLOUR $000055

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

; 4th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F32 to 17F51 (32 bytes)
DATA_17F32_SMSPalette_TurboWheels:
  SMSCOLOUR $000000
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $AA5500
  SMSCOLOUR $555500
  SMSCOLOUR $5555FF
  SMSCOLOUR $AA0000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

; 5th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F52 to 17F71 (32 bytes)
DATA_17F52_SMSPalette_FormulaOne:
  SMSCOLOUR $000000
  SMSCOLOUR $00AA00
  SMSCOLOUR $005500
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $555500
  SMSCOLOUR $FFAA00
  SMSCOLOUR $FF0000
  SMSCOLOUR $0000FF
  SMSCOLOUR $5555FF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $0000FF
  SMSCOLOUR $5555FF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

; 6th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F72 to 17F91 (32 bytes)
DATA_17F72_SMSPalette_Warriors:
  SMSCOLOUR $000000
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AA0000
  SMSCOLOUR $005500
  SMSCOLOUR $AA5500
  SMSCOLOUR $FFAA00
  SMSCOLOUR $5500AA
  SMSCOLOUR $5555AA
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $5555AA
  SMSCOLOUR $5500AA
  SMSCOLOUR $000055

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

; 7th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F92 to 17FB1 (32 bytes)
DATA_17F92_SMSPalette_Tanks:
  SMSCOLOUR $000000
  SMSCOLOUR $0000FF
  SMSCOLOUR $5555FF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $550000
  SMSCOLOUR $AA0000
  SMSCOLOUR $00AA00
  SMSCOLOUR $5500AA
  SMSCOLOUR $5555AA
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $5555AA
  SMSCOLOUR $5500AA
  SMSCOLOUR $000055

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

; 8th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17FB2 to 17FFF (78 bytes)
DATA_17FB2_SMSPalette_RuffTrux:
  SMSCOLOUR $000000
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAA55
  SMSCOLOUR $005500
  SMSCOLOUR $00AAFF
  SMSCOLOUR $AA5500
  SMSCOLOUR $555500
  SMSCOLOUR $550000
  SMSCOLOUR $5500AA
  SMSCOLOUR $5555AA
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $5555AA
  SMSCOLOUR $5500AA
  SMSCOLOUR $000055

  SMSCOLOUR $000000
  SMSCOLOUR $FF5555
  SMSCOLOUR $55FF00
  SMSCOLOUR $000000
  SMSCOLOUR $55AAFF
  SMSCOLOUR $555555
  SMSCOLOUR $AAAAAA
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $FFAA00
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $000000

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $FF $FF $FF $FF $DF $FF $FF $FF $DF $FF $FF $FF $7F
.db $FF $7F $FF $FF $FF $7F $FF $FF $FF $7F $FE $FF $FF $FF $FF $FF
.db $FF $F7 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 6
.ORG $0000
;.section "Bank 6" force

.dstruct DATA_18000_TrackData_TurboWheels instanceof TrackData data DATA_A480_TurboWheels_BehaviourData DATA_A7B6_TurboWheels_WallData DATA_A838_TurboWheels_Track0Layout DATA_AACF_TurboWheels_Track1Layout DATA_AD10_TurboWheels_Track2Layout DATA_AD10_TurboWheels_Track3Layout DATA_AF9A_TurboWheels_GGPalette DATA_AFDA_TurboWheels_DecoratorTiles DATA_B05A_TurboWheelsDATA DATA_B09A_TurboWheels_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FE $FF $FF $FF $BF $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $BF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $ED $45 $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF $EF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $EE $FF $FF $FF $EF $FF $FF $EF $ED $45 $FF $FF $EF $FF $FF $FF $FF $FF $BF $FF $FF $FF $FF $FF $EF $FF $FF $FF $EF $FF $FF $FB $FF $FF
.endif
;.ends

.orga $8080
;.section "Turbo Wheels metatiles" force

.incbin "Assets/Turbo Wheels/Metatiles.tilemap"

DATA_A480_TurboWheels_BehaviourData:
.incbin "Assets/Turbo Wheels/Behaviour data.compressed"
DATA_A7B6_TurboWheels_WallData:
.incbin "Assets/Turbo Wheels/Wall data.compressed"
DATA_A838_TurboWheels_Track0Layout:
.incbin "Assets/Turbo Wheels/Track 0 layout.compressed"
DATA_AACF_TurboWheels_Track1Layout:
.incbin "Assets/Turbo Wheels/Track 1 layout.compressed"
DATA_AD10_TurboWheels_Track2Layout:
DATA_AD10_TurboWheels_Track3Layout: ; point to #2
.incbin "Assets/Turbo Wheels/Track 2 layout.compressed"
DATA_AF9A_TurboWheels_GGPalette:
  GGCOLOUR $000000
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $884400
  GGCOLOUR $444400
  GGCOLOUR $4444EE
  GGCOLOUR $880000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
DATA_AFDA_TurboWheels_DecoratorTiles:
.incbin "Assets/Turbo Wheels/Decorators.1bpp"
DATA_B05A_TurboWheelsDATA:
.db $C0 $C0 $00 $00 $22 $22 $A0 $A0 $00 $00 $00 $00 $22 $22 $22 $22
.db $45 $49 $73 $77 $C0 $C0 $C0 $C0 $A0 $A0 $C0 $C0 $C0 $22 $C0 $C0
.db $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $A0 $A0 $A0 $C0 $C0 $C0 $C0
.db $C0 $C0 $A0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $80 $80 $80 $C0 $C0
DATA_B09A_TurboWheels_EffectsTiles:
.incbin "Assets/Turbo Wheels/Effects.3bpp"

; Data from 1B1A2 to 1B231 (144 bytes)
DATA_1B1A2_:
; Indexed by _RAM_DE6D_?
.db $00 $00 $01 $01 $02 $02 $03 $03 $04 $04 $05 $05 $00 $00 $01 $01
.db $02 $02 $03 $03 $04 $04 $05 $05 $06 $06 $07 $07 $08 $08 $09 $09
.db $0A $0A $0B $0B $06 $06 $07 $07 $08 $08 $09 $09 $0A $0A $0B $0B
.db $0C $0C $0D $0D $0E $0E $0F $0F $10 $10 $11 $11 $0C $0C $0D $0D
.db $0E $0E $0F $0F $10 $10 $11 $11 $12 $12 $13 $13 $14 $14 $15 $15
.db $16 $16 $17 $17 $12 $12 $13 $13 $14 $14 $15 $15 $16 $16 $17 $17
.db $18 $18 $19 $19 $1A $1A $1B $1B $1C $1C $1D $1D $18 $18 $19 $19
.db $1A $1A $1B $1B $1C $1C $1D $1D $1E $1E $1F $1F $20 $20 $21 $21
.db $22 $22 $23 $23 $1E $1E $1F $1F $20 $20 $21 $21 $22 $22 $23 $23

; Data from 1B232 to 1BAB2 (2177 bytes)
DATA_1B232_SinTable:
; Holds a sine curve, padded with an extra 0 at the start and 15 extra at the end
; It curves from 0 to 127 to 0 again in the remaining space
; We are able to replicate it with the below:
.db $00
.dbsin 0, 128, 180/128, 128, -0.001
.dsb 15 $00
; dbsin args are:
; - start angle in degrees (0)
; - steo count = number of values to produce - 1 (128 steps -> 129 values)
; - step angle in degrees (180 degrees / 128 steps)
; - scaling factor (128 nominal max value)
; - offset (we use a small value here which results in the peak being rounded down from 128 and everything else is unaffected)
; This is very dependent on the implementation of dbsin to exactly replicate the original, so here's the raw values for reference:
;.db $00 $03 $06 $09 $0C $0F $12 $15 $18 $1C $1F $22 $25 $28 $2B $2E $30 $33 $36 $39 $3C $3F $41 $44 $47 $49 $4C $4E $51 $53 $55 $58 $5A $5C $5E $60 $62 $64 $66 $68 $6A $6C $6D $6F $70 $72 $73 $75 $76 $77 $78 $79 $7A $7B $7C $7C $7D $7E $7E $7F $7F $7F $7F $7F $7F $7F $7F $7F $7F $7F $7E $7E $7D $7C $7C $7B $7A $79 $78 $77 $76 $75 $73 $72 $70 $6F $6D $6C $6A $68 $66 $64 $62 $60 $5E $5C $5A $58 $55 $53 $51 $4E $4C $49 $47 $44 $41 $3F $3C $39 $36 $33 $30 $2E $2B $28 $25 $22 $1F $1C $18 $15 $12 $0F $0C $09 $06 $03 $00

DATA_1B2C3_Tiles_Trophy:
.incbin "Assets/Menu/Trophy.3bpp.compressed"

DATA_1B7A7_SMS:
.incbin "Assets/Menu/Driver select tilemap data (SMS).bin"

DATA_1B987_GG:
.incbin "Assets/Menu/Driver select tilemap data (GG).bin"

LABEL_1BAB3_GetPlayerHandicaps:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet ++
  ; Player 1
  ld a, (_RAM_DBD4_Player1Character)
  ; Divide by 8 to make a character index
  srl a
  srl a
  srl a
  ; Look up state
  ld e, a
  ld d, $00
  ld hl, _RAM_DC21_CharacterStates
  add hl, de
  ld a, (hl)
  ; If non-zero, retrieve the handicap
  or a
  jr z, +
  ld hl, DATA_1BAF2_CharacterHandicaps
  add hl, de
  ld a, (hl)
  ld (_RAM_D5CF_Player1Handicap), a
+:
  ; Repeat for player 2
  ld a, (_RAM_DBD5_Player2Character)
  srl a
  srl a
  srl a
  ld e, a
  ld d, $00
  ld hl, _RAM_DC21_CharacterStates
  add hl, de
  ld a, (hl)
  or a
  JrZRet ++
  ld hl, DATA_1BAF2_CharacterHandicaps
  add hl, de
  ld a, (hl)
  ld (_RAM_D5D0_Player2Handicap), a
++:
  ret

; Data from 1BAF2 to 1BAFC (11 bytes)
DATA_1BAF2_CharacterHandicaps:
; Handicap strengths
; These values are subtracted from the vehicle top speed
; Could use -ve valus to boost speed?
.db 0 ; Chen  
.db 0 ; Spider
.db 3 ; Walter
.db 0 ; Dwayne
.db 0 ; Joel  
.db 0 ; Bonnie
.db 2 ; Mike  
.db 0 ; Emilio
.db 0 ; Jethro
.db 1 ; Anne  
.db 0 ; Cherry

LABEL_1BAFD_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
.ifdef JUMP_TO_RET
  jr nz, +
-:ret
+:
.else
  ret z
.endif

  ; If not head to head...
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet -
  ld a, (_RAM_DF58_)
  or a
  JrNzRet -
  ld a, (_RAM_DD1A_)
  or a
  JrNzRet -
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet -
  ld a, (_RAM_DF00_)
  or a
  JrNzRet -
  ld a, (_RAM_DD00_)
  or a
  JrNzRet -
  ld b, $01
  ld a, (_RAM_DCFD_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  jr nc, +
  ld b, $00
  xor $FF
  add a, $01
+:
  ld l, a
  ld a, $F2
  sub l
  srl a
  ld (_RAM_D5D2_), a
  ld a, b
  or a
  jr z, +
  ld a, (_RAM_DCFD_)
  jr ++

+:
  ld a, (_RAM_DBA4_)
++:
  ld l, a
  ld a, (_RAM_D5D2_)
  ld c, a
  cp l
  jr z, LABEL_1BBAF_
  dec a
  cp l
  jr z, LABEL_1BBAF_
  dec a
  cp l
  jr z, LABEL_1BBAF_
  ld a, c
  inc a
  cp l
  jr z, LABEL_1BBAF_
  inc a
  cp l
  jr z, LABEL_1BBAF_
  ld a, c
  cp l
  jr c, ++
  xor a
  ld (_RAM_D5DC_), a
  ld a, (_RAM_D5D5_)
  or a
  jr nz, +
  ld a, c
  sub l
  cp $04
  jr c, LABEL_1BBAF_
  ld a, $01
  ld (_RAM_D5D5_), a
+:
  ld a, $01
  ld (_RAM_DF0B_), a
  xor a
  ld (_RAM_DF0D_), a
  jr +++

++:
  xor a
  ld (_RAM_D5D5_), a
  ld a, (_RAM_D5DC_)
  or a
  jr nz, +
  ld a, l
  ld l, c
  sub l
  cp $04
  jr c, LABEL_1BBAF_
  ld a, $01
  ld (_RAM_D5DC_), a
+:
  ld a, $01
  ld (_RAM_DF0B_), a
  ld a, $01
  ld (_RAM_DF0D_), a
  jr +++

LABEL_1BBAF_:
  xor a
  ld (_RAM_D5D5_), a
  ld (_RAM_D5DC_), a
  ld (_RAM_DF0B_), a
+++:
  ld b, $01
  ld a, (_RAM_DCFE_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  ld b, $00
  xor $FF
  add a, $01
+:
  ld l, a
  ld a, $D0
  sub l
  srl a
  ld (_RAM_D5D3_), a
  ld a, b
  or a
  jr z, +
  ld a, (_RAM_DCFE_)
  jr ++

+:
  ld a, (_RAM_DBA5_)
++:
  ld l, a
  ld a, (_RAM_D5D3_)
  ld c, a
  cp l
  jr z, LABEL_1BC3F_
  dec a
  cp l
  jr z, LABEL_1BC3F_
  dec a
  cp l
  jr z, LABEL_1BC3F_
  ld a, c
  inc a
  cp l
  jr z, LABEL_1BC3F_
  inc a
  cp l
  jr z, LABEL_1BC3F_
  ld a, c
  cp l
  jr c, ++
  xor a
  ld (_RAM_D5DD_), a
  ld a, (_RAM_D5D4_)
  or a
  jr nz, +
  ld a, c
  sub l
  cp $04
  jr c, LABEL_1BC3F_
  ld a, $01
  ld (_RAM_D5D4_), a
+:
  ld a, $01
  ld (_RAM_DF0C_), a
  xor a
  ld (_RAM_DF0E_), a
  jr +++

++:
  xor a
  ld (_RAM_D5D4_), a
  ld a, (_RAM_D5DD_)
  or a
  jr nz, +
  ld a, l
  ld l, c
  sub l
  cp $04
  jr c, LABEL_1BC3F_
  ld a, $01
  ld (_RAM_D5DD_), a
+:
  ld a, $01
  ld (_RAM_DF0C_), a
  ld a, $01
  ld (_RAM_DF0E_), a
  jr +++

LABEL_1BC3F_:
  xor a
  ld (_RAM_D5D4_), a
  ld (_RAM_D5DD_), a
  ld (_RAM_DF0C_), a
+++:
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_)
  sub l
  ld (_RAM_DEAF_), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_), a
+++:
  ld a, (_RAM_DF0E_)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF0E_)
  ld (_RAM_DEB2_), a
  ret

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  ret

LABEL_1BCCB_DelayIfPlayer2:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  JrZRet ++ ; ret
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr z, +
  JrRet ++ ; ret
+:; Player 2
  ld hl, $0000 ; Waste some time
-:dec hl
  ld a, h
  or l
  jr nz, -
++:ret

LABEL_1BCE2_:
  ld a, (iy+1)
  or a
  jr nz, + ; Better to ret z
  ret

+:
  ld a, (iy+2)
  add a, $01
  and $07
  ld (iy+2), a
  or a
  jr nz, +
  ld a, (iy+1)
  sub $01
  ld (iy+1), a
+:
  ld hl, DATA_1D65__Lo
  ld a, (iy+1)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (iy+1)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  push de
    ld hl, DATA_3FC3_
    ld a, (iy+0)
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    ld hl, _RAM_DEAD_
    add a, (hl)
    ld h, d
    ld l, e
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    ld (ix+15), a
    ld (_RAM_DF7D_), a
    ld hl, DATA_40E5_Sign_
    ld a, (iy+0)
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    cp $00
    jr z, +
    xor a
    ld (_RAM_DB85_), a
    ld a, (ix+0)
    ld l, a
    ld a, (ix+1)
    ld h, a
    ld d, $00
    ld a, (ix+15)
    ld e, a
    or a
    sbc hl, de
    ld a, l
    ld (ix+0), a
    ld a, h
    ld (ix+1), a
    jp ++

+:  ld a, $01
    ld (_RAM_DB85_), a
    ld a, (ix+0)
    ld l, a
    ld a, (ix+1)
    ld h, a
    ld d, $00
    ld a, (ix+15)
    ld e, a
    add hl, de
    ld a, l
    ld (ix+0), a
    ld a, h
    ld (ix+1), a
++:
  pop de
  ld hl, DATA_3FD3_
  ld a, (iy+0)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (ix+16), a
  ld (_RAM_DF7E_), a
  ld hl, DATA_40F5_Sign_
  ld a, (iy+0)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DB84_), a
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  ld d, $00
  ld a, (ix+16)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+2), a
  ld a, h
  ld (ix+3), a
  ret

+:
  ld a, $01
  ld (_RAM_DB84_), a
  ld a, (ix+2)
  ld l, a
  ld a, (ix+3)
  ld h, a
  ld d, $00
  ld a, (ix+16)
  ld e, a
  add hl, de
  ld a, l
  ld (ix+2), a
  ld a, h
  ld (ix+3), a
  ret

LABEL_1BDF3_:
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_)
  sub l
  ld (_RAM_DEAF_), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_), a
+++:
  ld a, (_RAM_DF0E_)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF0E_)
  ld (_RAM_DEB2_), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+++:ret

LABEL_1BE82_InitialiseVDPRegisters:
  ld a, VDP_REGISTER_MODECONTROL1_VALUE
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL1
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_NAMETABLEBASEADDRESS_VALUE
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_NAMETABLEBASEADDRESS
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITETABLEBASEADDRESS_VALUE
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITETABLEBASEADDRESS
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITESET_HIGH
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITESET
  out (PORT_VDP_REGISTER), a
  xor a
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_XSCROLL
  out (PORT_VDP_REGISTER), a
  xor a
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_YSCROLL
  out (PORT_VDP_REGISTER), a
  ret

LABEL_1BEB1_ChangePoolTableColour:
  ; Updates palette indexes 1-2 for the pool table tracks
  ; to change the colour of the cloth
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  JrNzRet _LABEL_1BEF2_ret ; Only for F1 tracks
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ; Game Gear
  SetPaletteAddressImmediateGG 1
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  JrZRet _LABEL_1BEF2_ret
  cp $01
  jr z, +
  ; Track 2
  EmitGGColourImmediate $880044 ; pink
  EmitGGColourImmediate $440000 ; dark red
  ret
+:; Track 1
  EmitGGColourImmediate $004488 ; turquoise
  EmitGGColourImmediate $000044 ; dark Blue
  ret

_LABEL_1BEF2_ret:
  ret

++:
  ; Master System
  SetPaletteAddressImmediateSMS 1
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  JrZRet _LABEL_1BEF2_ret
  cp $01
  jr z, +
  ; Track 2
  EmitSMSColourImmediate $aa0055 ; pink
  EmitSMSColourImmediate $550000 ; dark red
  ret
+:; Track 1
  EmitSMSColourImmediate $0055aa ; turquoise
  EmitSMSColourImmediate $000055 ; dark Blue
  ret

LABEL_1BF17_:
  ld a, (ix+30)
  or a
  jr z, +
  cp $06
  JrNzRet ++ ; ret
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet ++ ; ret
  ld l, (ix+47)
  ld h, (ix+48)
  xor a
  ld (hl), a
  ld (ix+20), a
  jp LABEL_2961_

; Data from 1BF35 to 1BF43 (15 bytes)
.ifdef UNNECESSARY_CODE
  ld a, (ix+$0c)
  ld l, a
  cp (ix+$0d)
  ld a, $00
  jr nz, +
  inc a
+:ld (ix+$0b), a
.endif

++: ret

.ifdef BLANK_FILL_ORIGINAL
.db $00 $02 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $80 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 7
.ORG $0000
;.section "Bank 7" force

.dstruct DATA_1C000_TrackData_FormulaOne instanceof TrackData data  DATA_A480_FormulaOne_BehaviourData DATA_A819_FormulaOne_WallData DATA_A8CA_FormulaOne_Track0Layout DATA_AB11_FormulaOne_Track1Layout DATA_AE73_FormulaOne_Track2Layout DATA_AE73_FormulaOne_Track3Layout DATA_B1DC_FormulaOne_GGPalette DATA_B21C_FormulaOne_DecoratorTiles DATA_B29C_FormulaOneDATA DATA_B2DC_FormulaOne_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $77 $FF $F7 $FF $DF $FF $FF $FF $D7 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FD $EF $FF $FF $5D $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $77 $FD $DD $FF $FF $FF $FF $FF $FD $FF $FF $FF $DF $FF $7F $FF $FF $FF $F7 $FF $FF $FD $F7 $FF $DF $FF $FD $FF $FF $FF $FF $FF $FF $FF $FD $FF $DF $FF $FF $FF $FF $ED $45 $FF $7F $FF $FD $FF $FF $FF $F7 $FF $FF $FF $DF $FF $FF $FF $77 $FF $F7 $DF $F7 $FF $FF $FF $FF
.endif
;.ends

.orga $8080
;.section "Formula One metatiles" force

.incbin "Assets/Formula One/Metatiles.tilemap"

DATA_A480_FormulaOne_BehaviourData:
.incbin "Assets/Formula One/Behaviour data.compressed"
DATA_A819_FormulaOne_WallData:
.incbin "Assets/Formula One/Wall data.compressed"
DATA_A8CA_FormulaOne_Track0Layout:
.incbin "Assets/Formula One/Track 0 layout.compressed"
DATA_AB11_FormulaOne_Track1Layout:
.incbin "Assets/Formula One/Track 1 layout.compressed"
DATA_AE73_FormulaOne_Track2Layout:
DATA_AE73_FormulaOne_Track3Layout: ; points at #2
.incbin "Assets/Formula One/Track 2 layout.compressed"
DATA_B1DC_FormulaOne_GGPalette:
  GGCOLOUR $000000
  GGCOLOUR $008800
  GGCOLOUR $004400
  GGCOLOUR $EEEEEE
  GGCOLOUR $888888
  GGCOLOUR $444400
  GGCOLOUR $EE8800
  GGCOLOUR $EE0000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
DATA_B21C_FormulaOne_DecoratorTiles:
.incbin "Assets/Formula One/Decorators.1bpp"
DATA_B29C_FormulaOneDATA:
.db $C0 $00 $22 $63 $77 $73 $63 $C0 $22 $00 $45 $49 $41 $00 $22 $41 $A0 $80 $80 $80 $80 $2E $A0 $C0 $C0 $80 $00 $3A $A0 $C0 $C0 $C0 $00 $00 $1C $00 $C0 $80 $C0 $80 $00 $3A $3A $2E $08 $1C $C0 $80 $1C $80 $C0 $3A $C0 $C0 $C0 $1C $1C $A0 $A0 $C0 $22 $49 $45 $80
DATA_B2DC_FormulaOne_EffectsTiles:
.incbin "Assets/Formula One/Effects.3bpp"

DATA_1F3E4_Tiles_Portrait_Powerboats:
.incbin "Assets/Powerboats/Portrait.3bpp.compressed"

LABEL_1F8D8_InGameCheatHandler: ; Cheats!
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  ret nz ; Cheats only work in Challenge mode
  
  call LABEL_1FA23_ApplyFasterVehiclesCheat
  
  ; Compute metatile X, Y
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld l, a
  ld a, (_RAM_DE79_)
  add a, l
  ld (_RAM_D5C8_MetatileX), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_)
  add a, l
  ld (_RAM_D5C9_MetatileY), a

  ld a, (_RAM_DB97_TrackType)
  or a ; TT_0_SportsCars
  jp z, LABEL_1F9D4_Cheats_SportsCars
  cp TT_1_FourByFour
  jr z, +
  ret

+:; Four by Four
  call LABEL_1FA05_NoSkidCheatCheck ; for any track index
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $01
  jr z, +
  ret

+:; Four by Four track 1 (Breakfast Bends)
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, +
  ; Tile 1, 1 = top left and press 1+2
  ld a, (_RAM_D5C8_MetatileX)
  cp $01
  jr nz, +
  ld a, (_RAM_D5C9_MetatileY)
  cp $01
  jr nz, +
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK | BUTTON_2_MASK ; $30
  jr nz, +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, $01
  ld (_RAM_DC49_Cheat_ExplosiveOpponents), a
  ret

+:
  ld a, (_RAM_DC4B_Cheat_InfiniteLives)
  or a
  jr nz, +
  ; Tile 16, 8 = bottom right and car is falling
  ld a, (_RAM_D5C8_MetatileX)
  cp $10
  jr nz, +
  ld a, (_RAM_D5C9_MetatileY)
  cp $0B
  jr nz, +
  ld a, (_RAM_DF59_CarState) ; Player car is falling?
  cp CarState_3_Falling
  jr nz, +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFXTrigger_Player2), a
  ld a, $01
  ld (_RAM_DC4B_Cheat_InfiniteLives), a
  ret

+:
  ld a, (_RAM_DC4C_Cheat_AlwaysFirstPlace)
  or a
  jr nz, +
  ; Lap counter is 5 = did a lap backwards from the start
  ld a, (_RAM_DF24_LapsRemaining)
  cp $05
  jr nz, +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFXTrigger_Player2), a
  ld a, $01
  ld (_RAM_DC4C_Cheat_AlwaysFirstPlace), a
  ret

+:
  ld a, (_RAM_DC4E_Cheat_SuperSkids)
  or a
  JrNzRet _LABEL_1F996_ret
  ; (Tile 6, 6 = honey pool OR
  ; tile c, 5 = honey pool) AND
  ; buttons 1+2 (others may be held)
  ld a, (_RAM_D5C8_MetatileX) ; 6, 6
  cp $06
  jr nz, +
  ld a, (_RAM_D5C9_MetatileY)
  cp $06
  jr nz, +
-:
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK | BUTTON_2_MASK ; $30
  JrNzRet _LABEL_1F996_ret
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFXTrigger_Player2), a ; Play sound effect
  ld a, $01
  ld (_RAM_DC4E_Cheat_SuperSkids), a ; And this
_LABEL_1F996_ret:
  jp ++

+:
  ld a, (_RAM_D5C8_MetatileX) ; Or c, 5 = matching orange juice - new info!
  cp $0C
  JrNzRet _LABEL_1F996_ret
  ld a, (_RAM_D5C9_MetatileY)
  cp $05
  jr z, -
  ret

++:
  ld a, (_RAM_DC4F_Cheat_EasierOpponents)
  or a
  JrNzRet +
  ; Tile 16, 1 = top right and falling and reversing
  ld a, (_RAM_D5C8_MetatileX) ; 16, 1
  cp $10
  JrNzRet +
  ld a, (_RAM_D5C9_MetatileY)
  cp $01
  JrNzRet +
  ld a, (_RAM_DF59_CarState) ; Falling
  cp CarState_3_Falling
  JrNzRet +
  ld a, (_RAM_D5A4_IsReversing) ; Reversing
  or a
  JrZRet +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFXTrigger_Player2), a
  ld a, $01
  ld (_RAM_DC4F_Cheat_EasierOpponents), a
+:ret

LABEL_1F9D4_Cheats_SportsCars:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  JrNzRet +
  ; Sports Cars 0 = Desktop Drop-off
  ld a, (_RAM_DC4A_Cheat_ExtraLives) ; Laps done?
  or a
  JrNzRet +
  ; Tile 5, 24 = bottom half of pencil far to the left of the start position, and 4 laps remaining
  ld a, (_RAM_D5C8_MetatileX) ; 5, 24
  cp $05
  JrNzRet +
  ld a, (_RAM_D5C9_MetatileY)
  cp $18
  JrNzRet +
  ld a, (_RAM_DF24_LapsRemaining) ; Haven't crossed the start line yet
  cp $04
  JrNzRet +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFXTrigger_Player2), a
  ld a, $01
  ld (_RAM_DC4A_Cheat_ExtraLives), a
  ld a, $05
  ld (_RAM_DC09_Lives), a
+:ret

LABEL_1FA05_NoSkidCheatCheck:
  ld a, (_RAM_DC4D_Cheat_NoSkidding)
  or a
  JrNzRet +
  ; U+1+2 while driving into/on milk on any Four by Four track
  ; -> cars don't skid (new!)
  ld a, (_RAM_D5CD_CarIsSkidding)
  or a
  JrZRet + ; ret
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_U_MASK | BUTTON_1_MASK | BUTTON_2_MASK ; $31
  JrNzRet +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld a, $01
  ld (_RAM_DC4D_Cheat_NoSkidding), a
+:ret

LABEL_1FA23_ApplyFasterVehiclesCheat:
  ; Changes the car parameters to top speed = 12, acceleration and deceleration delay = 6
  ; Can go up to 15, 16 glitches sound, higher glitches out everything
  ld a, (_RAM_DC50_Cheat_FasterVehicles)
  or a
  JrZRet + ; ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, $0B ; 12
  ld (_RAM_DB98_TopSpeed), a
  ld a, $06 ; 6
  ld (_RAM_DB99_AccelerationDelay), a
  ld (_RAM_DB9A_DecelerationDelay), a
+:ret

LABEL_1FA3D_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_1FA95_ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_1FA95_ret
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_1FA95_ret
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  JrNzRet _LABEL_1FA95_ret
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld a, (_RAM_D59D_)
  or a
  jr z, +
  ld a, (_RAM_DB20_Player1Controls)
  ld d, a
  and BUTTON_U_MASK ; $01
  jr z, +++
  ld a, d
  and BUTTON_D_MASK ; $02
  jr z, LABEL_1FAE5_
  jp ++

+:ld a, (_RAM_DB20_Player1Controls)
  ld d, a
  and BUTTON_L_MASK ; $04
  jr z, +++
  ld a, d
  and BUTTON_R_MASK ; $08
  jr z, LABEL_1FAE5_
++:
  ld hl, _RAM_DE9F_
  ld a, (hl)
  or a
  jr z, +
  dec (hl)
+:ld a, (_RAM_DE99_)
  or a
  JrNzRet _LABEL_1FA95_ret
  ld hl, _RAM_DEA0_
  ld a, (hl)
  or a
  JrZRet _LABEL_1FA95_ret
  dec (hl)
_LABEL_1FA95_ret:
  ret

+++:
  ld a, (_RAM_DE9F_)
  or a
  jr z, +
  sub $01
  ld (_RAM_DE9F_), a
  ret

+:
  ld a, (_RAM_DE99_)
  or a
  jr nz, +
  ld a, $01
  ld (_RAM_DE99_), a
  ld (_RAM_DE9A_), a
+:
  ld a, (_RAM_DE99_)
  cp $02
  jr nz, +
  ld a, (_RAM_DEA3_)
  sub $01
  jp ++

+:
  ld a, (_RAM_DEA3_)
  add a, $01
++:
  ld (_RAM_DEA3_), a
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, +
  ld a, $07
  jp ++

+:
  ld a, (_RAM_DB9B_SteeringDelay)
++:
  ld (_RAM_DE9F_), a
  ld hl, _RAM_DE91_CarDirectionPrevious
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DE91_CarDirectionPrevious), a
  jp LABEL_1295_

LABEL_1FAE5_:
  ld a, (_RAM_DE9F_)
  cp $00
  jr z, +
  sub $01
  ld (_RAM_DE9F_), a
  ret

+:
  ld a, (_RAM_DE99_)
  or a
  jr nz, +
  ld a, $02
  ld (_RAM_DE99_), a
  ld (_RAM_DE9A_), a
+:
  ld a, (_RAM_DE99_)
  cp $01
  jr nz, +
  ld a, (_RAM_DEA3_)
  sub $01
  jp ++

+:
  ld a, (_RAM_DEA3_)
  add a, $01
++:
  ld (_RAM_DEA3_), a
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, +
  ld a, $07
  jp ++

+:
  ld a, (_RAM_DB9B_SteeringDelay)
++:
  ld (_RAM_DE9F_), a
  ld hl, _RAM_DE91_CarDirectionPrevious
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DE91_CarDirectionPrevious), a
  jp LABEL_1295_

LABEL_1FB35_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr z, ++++
  ld a, (ix+11)
  or a
  JrZRet +++
  cp $01
  JrZRet +++
  cp $02
  jr z, +
  sub $02
  jp ++

+:
  sub $01
++:
  ld (ix+11), a
  ld a, (ix+21)
  or a
  JrZRet +++
  ld a, SFX_07_EnterSticky
  ld (_RAM_D974_SFXTrigger_Player2), a
+++:ret

++++:
  ld a, (ix+11)
  cp $03
  JrCRet +++
  cp $04
  jr z, +
  sub $02
  jp ++

+:
  sub $01
++:
  ld (ix+11), a
  ld a, (ix+21)
  or a
  JrZRet +++
  ld a, SFX_07_EnterSticky
  ld (_RAM_D974_SFXTrigger_Player2), a
+++:ret

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FD $FF $FF $DD $FF $DD $FF $FF $7F $FF $FF $FF $FF $DF $FF $FF $FF $FF $FF $FF $DF $77 $FF $7F $DF $DF $FF $FF $FF $FF $FF $DF $7F $FF $F7 $FD $FD $FD $FF $DF $FF $DD $FF $DF $FF $F7 $FF $FF $FF $F7 $D7 $FF $FF $FF $FF $FD $FF $5D $FF $FF $FF $7F $FF $FD $FF $7D $FF $FF $FF $FD $FF $FF $FF $FF $FF $DF $FF $FF $FF $FF $FF $FF $FF $7F $FF $DF $FF $FF $FF $F7 $FF $FF $FF $7F $FF $FF $FF $FD $FF $FD $FF $77 $FF $FF $FF $F7 $FF $D5 $FF $7D $FF $FF $FF $FF $FF $FF $DD $FF $FF $FF $FF $F7 $FF $F7 $FF $F5 $20 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $08 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $04 $00 $44 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $20 $40 $00 $00 $00 $00 $00 $00 $00 $40 $FF $FF $FF $FF $FF $FD $FF $FD $FF $FF $FF $7F $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $D7 $EF $77 $FF $7F $FF $DF $FF $5D $FF $7F $FF $FF $FE $FF $FF $FF $FF $FE $FF $F5 $FF $FF $FF $F7 $FF $FF $FF $FD $BE $FF $EF $5F $FE $FF $FF $57 $FF $F7 $FF $FF $FF $FF $FF $FD $FE $5F $FF $F7 $FF $FF $7F $DF $FF $FF $FF $7F $FF $F7 $FF $DD $FF $7F $FF $FF $FF $DF $FF $D7 $FF $7F $FF $FF $FF $5D $FF $FF $FF $FD $FF $FF $EF $F5 $DF $77 $FF $FD $FF $FF $FF $FF $FF $FF $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $40 $00 $44 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $50 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $04 $14 $00 $00 $00 $04 $00 $00 $00 $00 $00 $04 $00 $44 $00 $40 $00 $00 $00 $00 $00 $00 $40 $00 $00 $04 $00 $40 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $44 $FF $FF $FF $FF $FF $D7 $FF $7F $FF $FF $FF $FF $FF $7F $FF $FF $FF $FF $FF $FF $FF $FD $ED $F7 $FF $FF $FF $FD $FF $FF $FF $F5 $FF $FF $FF $5D $FF $7F $FF $F7 $FF $FF $FD $F7 $FF $5F $FF $7D $FF $FF $FF $DF $FF $FF $7F $FF $FF $FF $FF $7F $FF $FF $DF $7F $FF $FF $FF $5D $DF $FE $FF $77 $FF $7F $FF $FF $FD $DF $FF $7F $EF $FF $FF $57 $FF $FF $DD $DF $FF $F7 $FF $7F $FF $DF $FF $77 $FF $FF $FF $FD $FF $FF $FF $D7 $FF $7F $F7 $F7 $FF $FF $FF $DD $FF $FF $FF $FF $FF $FF $FF $5F $FF $FF $DF $7F $FF $FF $FF $DD $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $40 $00 $01 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $80 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $20 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $40 $00 $40 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $04 $FF $FF $EF $FF $FF $FF $FF $77 $FF $FF $FF $FF $FF $FF $FF $7F $FE $FF $FF $DF $FF $FF $FF $DF $FF $D7 $FF $DF $FF $F5 $FF $D5 $FF $FF $FF $77 $FE $7F $FF $FF $FF $DF $FF $77 $FF $FF $FF $55 $FF $FF $FF $FF $FF $FF $FF $FD $FF $FF $FF $FF $FF $FF $FF $FF $FF $DF $FD $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FD $DF $FD $FF $FF $FF $F7 $FF $5F $DF $F7 $FF $FF $FF $DF $FF $7F $FF $FD $FF $FF $F7 $7F $FF $FF $FF $D5 $FF $FF $FF $FF $FF $F7 $FF $F7 $BF $FF $BF $7F $FF $FF $FF $F7 $FF $FF $FF $DF $FF $FF $FF $77 $00 $00 $00 $00 $00 $00 $00 $10 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $50 $00 $00 $00 $44 $00 $00 $00 $00 $00 $00 $00 $14 $00 $40 $00 $40 $00 $04 $00 $14 $00 $00 $00 $10 $00 $10 $00 $40 $00 $10 $00 $10 $00 $00 $00 $10 $00 $00 $00 $00 $00 $00 $00 $00 $00 $50 $00 $04 $00 $00 $40 $44 $00 $00 $40 $10 $00 $00 $00 $04 $00 $00 $00 $14 $00 $01 $00 $40 $00 $00 $00 $11 $00 $44 $00 $50 $00 $00 $00 $44 $00 $04 $00 $10 $00 $00 $00 $04 $00 $50 $00 $10 $00 $00 $00 $00 $00 $00 $00 $00 $FF $FF $FF $F5 $FF $FD $FF $FD $FF $FF $FF $F7 $FF $FD $DF $F7 $FF $FD $77 $DF $FF $FF $FF $DF $FF $FF $FF $DF $DD $FD $F7 $D7 $FF $DF $FF $DD $FF $7F $FF $DF $FF $7F $FF $7F $FF $FF $FF $7F $FF $FD $FF $DF $FF $5F $FF $F7 $FF $FF $DD $57 $FF $DF $FF $7F $FF $DF $FF $FD $FF $DF $FF $D5 $FF $FF $FF $FF $FF $F7 $DF $77 $FF $D7 $FF $57 $FF $FF $FF $7F $FF $FF $FF $7F $FF $DF $FF $DD $FF $FF $FF $7D $FF $77 $FD $FF $FF $FF $FF $FF $FF $DD $FF $FD $FF $F7 $FF $FD $FF $7F $FD $7D $BF $FF $FF $FD $FF $F7 $F7
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 8
.ORG $0000
;.section "Bank 8" force

.dstruct DATA_20000_TrackData_Warriors instanceof TrackData data  DATA_9D30_Warriors_BehaviourData DATA_A01A_Warriors_WallData DATA_A10F_Warriors_Track0Layout DATA_A3B8_Warriors_Track1Layout DATA_A67C_Warriors_Track2Layout DATA_A67C_Warriors_Track3Layout DATA_A924_Warriors_GGPalette DATA_A964_Warriors_DecoratorTiles DATA_A9E4_WarriorsDATA DATA_AA24_Warriors_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $ED $45 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $ED $45 $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF
.endif
;.ends

.orga $8080
;.section "Warriors metatiles" force

.incbin "Assets/Warriors/Metatiles.tilemap"

DATA_9D30_Warriors_BehaviourData:
.incbin "Assets/Warriors/Behaviour data.compressed"
DATA_A01A_Warriors_WallData:
.incbin "Assets/Warriors/Wall data.compressed"
DATA_A10F_Warriors_Track0Layout:
.incbin "Assets/Warriors/Track 0 layout.compressed"
DATA_A3B8_Warriors_Track1Layout:
.incbin "Assets/Warriors/Track 1 layout.compressed"
DATA_A67C_Warriors_Track2Layout:
DATA_A67C_Warriors_Track3Layout:
.incbin "Assets/Warriors/Track 2 layout.compressed"
DATA_A924_Warriors_GGPalette:
  GGCOLOUR $000000
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $880000
  GGCOLOUR $004400
  GGCOLOUR $884400
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
DATA_A964_Warriors_DecoratorTiles:
.incbin "Assets/Warriors/Decorators.1bpp"
DATA_A9E4_WarriorsDATA:
.db $00 $00 $80 $80 $22 $22 $A0 $A0 $73 $73 $73 $C0 $77 $77 $73 $22 $00 $00 $22 $49 $49 $C0 $45 $45 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $22 $C0 $C0 $C0 $80 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $22 $C0 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
DATA_AA24_Warriors_EffectsTiles:
.incbin "Assets/Warriors/Effects.3bpp"

DATA_22B2C_Tiles_PunctuationAndLine:
.incbin "Assets/Menu/PunctuationAndLine.3bpp"
DATA_22B8C_Tiles_ColouredBalls:
.incbin "Assets/Menu/Balls.3bpp"
DATA_22BEC_Tiles_Cursor:
.incbin "Assets/Menu/Cursor.3bpp.compressed"
DATA_22C4E_Tiles_BigLogo:
.incbin "Assets/Menu/Logo-big.3bpp.compressed"
DATA_23656_Tiles_VsCPUPatch:
.incbin "Assets/Menu/Icon-VsCPUPatch.3bpp.compressed"

LABEL_237E2_:
  xor a
  ld (_RAM_DCD8_), a
  ld a, $01
  ld (_RAM_DD19_), a
  ld a, $02
  ld (_RAM_DD5A_), a
  ld hl, _RAM_DD9E_
  ld (_RAM_DCCD_), hl
  ld hl, _RAM_DDCE_
  ld (_RAM_DD0E_), hl
  ld hl, _RAM_DDFE_
  ld (_RAM_DD4F_), hl
  ld a, $38
  ld (_RAM_DD80_), a
  ld a, $3A
  ld (_RAM_DDB0_), a
  ld a, $3C
  ld (_RAM_DDE0_), a
  ld a, $3E
  ld (_RAM_DE10_), a
  ld hl, _RAM_DE5F_
  ld (_RAM_DCD2_), hl
  ld hl, _RAM_DE60_
  ld (_RAM_DD13_), hl
  ld hl, _RAM_DE61_
  ld (_RAM_DD54_), hl
  ld hl, _RAM_DE32_
  ld (_RAM_DCDA_), hl
  ld hl, _RAM_DE35_
  ld (_RAM_DD1B_), hl
  ld hl, _RAM_DE38_
  ld (_RAM_DD5C_), hl

  ld a, (_RAM_DC55_TrackIndex_Game)
  sla a
  ld b, a

  ; Index *2
  ld e, a
  ld d, $00
  ld hl, DATA_238DE_
  add hl, de
  ld a, (hl)
  ld (_RAM_DB66_), a
  inc hl
  ld a, (hl)
  ld (_RAM_DB67_), a

  ; Index *6
  ld a, b
  sla a
  ld l, a
  ld h, $00
  add hl, de
  ld de, DATA_23918_
  add hl, de
  exx
    ld c, $06
  exx
  ld a, (_RAM_DC46_Cheat_HardMode)
  ld c, a ; 1 for hard mode, 2 for rock hard mode
  ld a, (_RAM_DC54_IsGameGear)
  xor $01
  sla a ; 2 for SMS, 0 for GG
  ld b, a
  ld de, _RAM_DB68_HandlingData
-:; High nibble + adjustment -> _RAM_DB68_HandlingData
  ld a, (hl)
  srl a
  srl a
  srl a
  srl a
  add a, b
  add a, c
  cp $0E
  jr c, +
  ld a, $0D ; Maximum $d
+:ld (de), a

  inc de
  ; Low nibble + adjustment -> _RAM_DB69_
  ld a, (hl)
  and $0F
  add a, b
  add a, c
  cp $0E
  jr c, +
  ld a, $0D
+:ld (de), a

  inc de
  inc hl
  exx
    dec c
  exx
  ; Loop over 6 bytes -> 12 nibbles
  jr nz, -
  ld a, (_RAM_DB68_HandlingData+1)
  ld (_RAM_DCDC_), a
  ld a, (_RAM_DB68_HandlingData+5)
  ld (_RAM_DD1D_), a
  ld a, (_RAM_DB68_HandlingData+9)
  ld (_RAM_DD5E_), a
  ld a, (_RAM_DB97_TrackType)
  ld e, a
  ld d, $00
  ld hl, DATA_238D5_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF97_), a
  ld a, (_RAM_DB97_TrackType)
  or a ; TT_0_SportsCars
  jr z, +
  cp TT_4_FormulaOne
  jr nz, ++
+:
  ld b, $01
  jp +++

++:
  ld b, $01
+++:
  ld a, (_RAM_DB99_AccelerationDelay)
  sub b
  ld (_RAM_DD5F_), a
  sub b
  ld (_RAM_DCDD_), a
  sub b
  ld (_RAM_DD1E_), a
  ret

; Data from 238D5 to 238DD (9 bytes)
DATA_238D5_:
.db $08 $07 $09 $08 $09 $08 $04 $05 $05

; Data from 238DE to 239C5 (232 bytes)
DATA_238DE_: ; indexed by _RAM_DC55_TrackIndex_Game*2 and copied to _RAM_DB66_, _RAM_DB67_
; They are all the same...
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02
DATA_23918_: ; indexed by _RAM_DC55_TrackIndex_Game*6, split to nibbles and sent to _RAM_DB68_HandlingData+
;    ,,--,,-- End up in _RAM_DB68_
;    ||  ||  ,,--,,-- End up in _RAM_DD1D_
;    ||  ||  ||  ||  ,,--,,-- End up in _RAM_DD5E_
.db $54 $42 $65 $53 $54 $42
.db $54 $43 $65 $54 $54 $43
.db $86 $63 $75 $52 $75 $52
.db $87 $75 $87 $75 $76 $65
.db $A9 $97 $A9 $87 $98 $86
.db $87 $75 $77 $66 $76 $65
.db $98 $87 $A9 $88 $88 $76
.db $A9 $88 $98 $87 $88 $77
.db $87 $76 $99 $87 $87 $66
.db $AA $98 $BB $A9 $A9 $87
.db $87 $76 $88 $77 $76 $66
.db $98 $77 $98 $88 $87 $66
.db $97 $65 $A8 $76 $87 $76
.db $76 $65 $86 $66 $66 $55
.db $AA $87 $AA $98 $98 $77
.db $CB $A9 $CC $BB $A9 $87
.db $A9 $97 $BA $98 $CB $A9
.db $76 $65 $76 $65 $65 $55
.db $98 $87 $CB $A9 $BA $98
.db $86 $66 $87 $76 $76 $65
.db $CC $BB $CB $A9 $A9 $87
.db $A9 $87 $BA $98 $97 $66
.db $76 $65 $76 $65 $65 $55
.db $BB $A9 $BB $AA $AA $98
.db $87 $76 $88 $76 $77 $66
.db $CC $CC $CC $BA $CB $A9 ; Final
.db $66 $66 $66 $66 $66 $66 ; Bonus
.db $66 $66 $66 $66 $66 $66
.db $66 $66 $66 $66 $66 $66

LABEL_239C6_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet +
  ld a, (_RAM_D5B9_)
  or a
  jr nz, ++
+:ret

++:
  ld a, $01
  ld (_RAM_DEBA_), a
  ld (_RAM_DEBB_), a
  ld hl, _RAM_D5BB_
  inc (hl)
  ld a, (_RAM_D5BB_)
  and $07
  ld (_RAM_D5BB_), a
  or a
  jr nz, +
  ld a, (_RAM_D5B9_)
  sub $01
  ld (_RAM_D5B9_), a
+:
  call LABEL_23A91_
  ld a, (_RAM_DF84_)
  ld l, a
  ld a, (_RAM_DD0D_)
  cp l
  jr z, ++
  ld a, (_RAM_DCFB_)
  ld l, a
  ld a, (_RAM_DF82_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCFB_)
  sub l
  ld (_RAM_DCFB_), a
  jp +++

+:
  sub l
  ld (_RAM_DCFB_), a
  ld a, (_RAM_DF84_)
  ld (_RAM_DD0D_), a
  jp +++

++:
  ld a, (_RAM_DCFB_)
  ld l, a
  ld a, (_RAM_DF82_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCFB_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DCFB_), a
+++:
  ld a, (_RAM_DF85_)
  ld l, a
  ld a, (_RAM_DD0C_)
  cp l
  jr z, ++
  ld a, (_RAM_DCFC_)
  ld l, a
  ld a, (_RAM_DF83_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCFC_)
  sub l
  ld (_RAM_DCFC_), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  sub l
  ld (_RAM_DCFC_), a
  ld a, (_RAM_DF85_)
  ld (_RAM_DD0C_), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

++:
  ld a, (_RAM_DCFC_)
  ld l, a
  ld a, (_RAM_DF83_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCFC_), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DCFC_), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+++:ret

LABEL_23A91_:
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_
  ld a, (_RAM_D5B8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF82_), a
  ld hl, DATA_40E5_Sign_
  ld a, (_RAM_D5B8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF84_), a
  ld a, (_RAM_DCEC_CarData_Blue)
  ld l, a
  ld a, (_RAM_DCED_)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF82_)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (_RAM_DCEC_CarData_Blue), a
  ld a, h
  ld (_RAM_DCED_), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF84_), a
  ld a, (_RAM_DCEC_CarData_Blue)
  ld l, a
  ld a, (_RAM_DCED_)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF82_)
  ld e, a
  add hl, de
  ld a, l
  ld (_RAM_DCEC_CarData_Blue), a
  ld a, h
  ld (_RAM_DCED_), a
++:
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FD3_
  ld a, (_RAM_D5B8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF83_), a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_D5B8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  cp $00
  jr z, +
  xor a
  ld (_RAM_DF85_), a
  ld a, (_RAM_DCEE_)
  ld l, a
  ld a, (_RAM_DCEF_)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF83_)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (_RAM_DCEE_), a
  ld a, h
  ld (_RAM_DCEF_), a
  ret

+:
  ld a, $01
  ld (_RAM_DF85_), a
  ld a, (_RAM_DCEE_)
  ld l, a
  ld a, (_RAM_DCEF_)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF83_)
  ld e, a
  add hl, de
  ld a, l
  ld (_RAM_DCEE_), a
  ld a, h
  ld (_RAM_DCEF_), a
  ret

LABEL_23B98_BlankGameRAM:
  ; Blank a bunch of RAM
  ld bc, $0062
  ld hl, _RAM_D580_WaitingForGameVBlank
-:ld a, $00
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  
  ; Blank a bunch more RAM
  ld bc, $0012
  ld hl, _RAM_DB74_CarTileLoaderTableIndex
-:ld a, $00
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  
  ; More again
  ld bc, $000B
  ld hl, _RAM_D940_
-:ld a, $00
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

LABEL_23BC6_:
  ld a, (_RAM_DF6C_)
  add a, $01
  and $01
  ld (_RAM_DF6C_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF5A_CarState3)
  cp CarState_4_Submerged
  jr z, +
--:
  ld a, (_RAM_DCB8_)
  add a, $01
-:
  and $0F
  ld (_RAM_DCB8_), a
  ret

+:
  ld a, (_RAM_DCB8_)
  cp $08
  jr nc, --
  sub $01
  jp -

LABEL_23BF1_:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, ++
  ld hl, (_RAM_DBA9_)
  ld de, $0074
  add hl, de
  ld (_RAM_DCAB_CarData_Green), hl
  ld hl, (_RAM_DBA9_)
  ld de, $0090
  add hl, de
  ld (_RAM_DCEC_CarData_Blue), hl
  ld (_RAM_DD2D_CarData_Yellow), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0040
  add hl, de
  ld (_RAM_DCAD_), hl
  ld (_RAM_DCEE_), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0068
  add hl, de
  ld (_RAM_DD2F_), hl
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld (_RAM_DCEE_), hl
+:ret

++:
  ld hl, (_RAM_DBA9_)
  ld de, $0014
  add hl, de
  ld (_RAM_DCAB_CarData_Green), hl
  ld hl, (_RAM_DBA9_)
  ld de, $0030
  add hl, de
  ld (_RAM_DCEC_CarData_Blue), hl
  ld (_RAM_DD2D_CarData_Yellow), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0040
  add hl, de
  ld (_RAM_DCAD_), hl
  ld (_RAM_DCEE_), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0068
  add hl, de
  ld (_RAM_DD2F_), hl
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld (_RAM_DCEE_), hl
+:ret

LABEL_23C68_ReadGGPauseButton:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, _GG
-:ret

_GG:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  JrNzRet -
  ; Not gear to gear
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, _UseStart
  ld a, (_RAM_D59D_)
  or a
  jr z, _UseStart
  
_UseButton2:
  ; Read button 2
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_2_MASK ; $20
  sla a
  sla a
  jp +

_UseStart:
  ; Read start button
  in a, (PORT_GG_START)
  
+:; Save it
  ld (_RAM_D59C_GGStartButtonValue), a
  ld a, (_RAM_D599_IsPaused)
  or a
  jr nz, ++
  ; Not paused
  ld a, (_RAM_D59C_GGStartButtonValue)
  and PORT_GG_START_MASK
  jr z, +
  ret

+:; Start is pressed, pause the game
  ld a, $01
  ld (_RAM_D59A_PauseDebounce1), a
  ld (_RAM_D599_IsPaused), a
  
  ; Mute PSG
  ld a, $FF
  out (PORT_PSG), a
  ld a, $9F
  out (PORT_PSG), a
  ld a, $BF
  out (PORT_PSG), a
  ld a, $DF
  out (PORT_PSG), a
  ret

++:
  ; Paused
  ld a, (_RAM_D59A_PauseDebounce1)
  or a
  jr z, ++
  ; Debounce is still 1, wait for Start to be released before we blank it
  ld a, (_RAM_D59C_GGStartButtonValue)
  and PORT_GG_START_MASK
  JrZRet +
  xor a
  ld (_RAM_D59A_PauseDebounce1), a
+:ret

++:
  ld a, (_RAM_D59C_GGStartButtonValue)
  and PORT_GG_START_MASK
  jr z, ++
  ld a, (_RAM_D59B_PauseDebounce2)
  or a
  JrZRet +
  ; Unpause
  xor a
  ld (_RAM_D599_IsPaused), a
  ld (_RAM_D59B_PauseDebounce2), a
+:ret

++:
  ld a, $01
  ld (_RAM_D59B_PauseDebounce2), a
  ret

LABEL_23CE6_UpdateAnimatedPalette:
  ; Updates the top half of the tile palette for Powerboats and Helicopters levels
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, LABEL_23D4B_SMS_UpdateAnimatedPalette_SMS

  ; GG
  ld a, (_RAM_DB97_TrackType)
  cp TT_8_Helicopters
  jr z, +
  cp TT_2_Powerboats
  jr z, ++
  ret

+:; Helicopters (unused)
  ld hl, DATA_1D25_HelicoptersAnimatedPalette_GG
  ld (_RAM_DF77_PaletteAnimationData), hl
  jp +++

++:; Powerboats
  ld hl, DATA_1D35_PowerboatsAnimatedPalette_GG
  ld (_RAM_DF77_PaletteAnimationData), hl
+++:
  ld a, (_RAM_DF76_PaletteAnimationCounter)
  add a, $01
  and $03
  ld (_RAM_DF76_PaletteAnimationCounter), a
  jr z, +
  ret

+:
  ld de, $C01E ; Palette entry 15
-:; Set palette address
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ld hl, (_RAM_DF77_PaletteAnimationData) ; Read in palette pointer
  ld a, (_RAM_DF75_PaletteAnimationIndex)
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_DATA), a
  ld a, (_RAM_DF75_PaletteAnimationIndex)
  add a, $02
  and $0F
  ld (_RAM_DF75_PaletteAnimationIndex), a
  ld a, e
  sub $02
  ld e, a
  cp $0E
  jr nz, -
  ld a, (_RAM_DF75_PaletteAnimationIndex)
  add a, $02
  and $0F
  ld (_RAM_DF75_PaletteAnimationIndex), a
  ret

LABEL_23D4B_SMS_UpdateAnimatedPalette_SMS:
  ld a, (_RAM_DB97_TrackType)
  cp TT_8_Helicopters
  jr z, +
  cp TT_2_Powerboats
  jr z, ++
  ret

+:
  ld hl, DATA_23DA6_HelicoptersAnimatedPalette_SMS
  ld (_RAM_DF77_PaletteAnimationData), hl
  jp +++

++:
  ld hl, DATA_23DAE_PowerboatsAnimatedPalette_SMS
  ld (_RAM_DF77_PaletteAnimationData), hl
+++:
  ld a, (_RAM_DF76_PaletteAnimationCounter)
  add a, $01
  and $03
  ld (_RAM_DF76_PaletteAnimationCounter), a
  jr z, +
  ret

+:
  ld de, $C00F ; Palette entry $f
-:; Set palette address
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ld hl, (_RAM_DF77_PaletteAnimationData)
  ld a, (_RAM_DF75_PaletteAnimationIndex) ; Look up index
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_DATA), a ; Emit
  ld a, (_RAM_DF75_PaletteAnimationIndex) ; Increment index
  add a, $01
  and $07
  ld (_RAM_DF75_PaletteAnimationIndex), a
  ld a, e ; Decrement palette pointer
  sub $01
  ld e, a
  cp $07
  jr nz, - ; Repeat until done
  ld a, (_RAM_DF75_PaletteAnimationIndex) ; Increment index another time
  add a, $01
  and $07
  ld (_RAM_DF75_PaletteAnimationIndex), a
  ret

; Data from 23DA6 to 23DB5 (16 bytes)
DATA_23DA6_HelicoptersAnimatedPalette_SMS
  SMSCOLOUR $0000FF
  SMSCOLOUR $5555FF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $0000FF
  SMSCOLOUR $5555FF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
DATA_23DAE_PowerboatsAnimatedPalette_SMS
  SMSCOLOUR $5500AA
  SMSCOLOUR $5555AA
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $FFFFFF
  SMSCOLOUR $AAAAFF
  SMSCOLOUR $5555AA
  SMSCOLOUR $5500AA
  SMSCOLOUR $000055

LABEL_23DB6_ClearTilemap:
  ; Clear tilemap
  SetVDPAddressImmediate NAME_TABLE_ADDRESS | VRAM_WRITE_MASK
  ld bc, TILEMAP_SIZE / TILEMAP_ENTRY_SIZE
-:EmitDataToVDPImmediate16 $0000
  dec bc
  ld a, b
  or c
  jr nz, -
  ; Then set the offscreen ones to tile $14
  SetTilemapAddressImmediate 0, 28
  ld bc, $0080
-:EmitDataToVDPImmediate16 $0014
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

; Data from 23DE7 to 23ECE (232 bytes)
DATA_23DE7_HandlingData_SMS:
; 16 nibbles per track
; Unpacked, left to right, from _RAM_DB86_HandlingData
; Maps speed to skidding?
; Per-track data, but actually the same for all tracks of the same type
; Skid more at lower speeds on GG compared to SMS?
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats
.db $11 $11 $11 $24 $66 $66 $66 $66 ; FourByFour
.db $11 $11 $11 $14 $69 $CD $DD $DD ; SportsCars
.db $11 $11 $45 $79 $BD $DD $DD $DD ; Warriors
.db $11 $11 $11 $47 $AC $DD $DD $DD ; TurboWheels
.db $11 $11 $11 $24 $66 $66 $66 $66 ; FourByFour 
.db $11 $11 $11 $24 $68 $99 $99 $99 ; FormulaOne 
.db $11 $11 $45 $79 $BD $DD $DD $DD ; Warriors 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $11 $11 $47 $AC $DD $DD $DD ; TurboWheels
.db $11 $14 $8B $DF $FF $FF $FF $FF ; Helicopters
.db $11 $11 $11 $24 $66 $66 $66 $66 ; FourByFour 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Tanks 
.db $11 $11 $11 $24 $68 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $14 $69 $CD $DD $DD ; SportsCars 
.db $11 $11 $11 $47 $AC $DD $DD $DD ; TurboWheels
.db $11 $14 $8B $DF $FF $FF $FF $FF ; Helicopters
.db $11 $11 $45 $79 $BD $DD $DD $DD ; Warriors 
.db $11 $11 $11 $11 $12 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $14 $69 $CD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $14 $8B $DF $FF $FF $FF $FF ; Helicopters
.db $11 $11 $11 $24 $68 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $11 $12 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $14 $69 $CD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux

; Data from 23ECF to 23FFF (305 bytes)
DATA_23ECF_HandlingData_GG:

.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats
.db $11 $11 $12 $46 $66 $66 $66 $66 ; FourByFour
.db $11 $11 $11 $46 $9C $DD $DD $DD ; SportsCars
.db $11 $14 $57 $9B $DD $DD $DD $DD ; Warriors
.db $11 $11 $14 $7A $CD $DD $DD $DD ; TurboWheels
.db $11 $11 $12 $46 $66 $66 $66 $66 ; FourByFour 
.db $11 $11 $12 $46 $89 $99 $99 $99 ; FormulaOne 
.db $11 $14 $57 $9B $DD $DD $DD $DD ; Warriors 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $11 $14 $7A $CD $DD $DD $DD ; TurboWheels
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Helicopters
.db $11 $11 $12 $46 $66 $66 $66 $66 ; FourByFour 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Tanks 
.db $11 $11 $12 $46 $89 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $46 $9C $DD $DD $DD ; SportsCars 
.db $11 $11 $14 $7A $CD $DD $DD $DD ; TurboWheels
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Helicopters
.db $11 $14 $57 $9B $DD $DD $DD $DD ; Warriors 
.db $11 $11 $11 $11 $23 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $46 $9C $DD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Helicopters
.db $11 $11 $12 $46 $89 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $11 $23 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $46 $9C $DD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux

.ifdef BLANK_FILL_ORIGINAL
.repeat 18
.db $FF $FF $00 $00
.endr
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 9
.ORG $0000
;.section "Bank 9" force

.dstruct DATA_24000_TrackData_Tanks instanceof TrackData data  DATA_9F70_Tanks_BehaviourData DATA_A32A_Tanks_WallData DATA_A42C_Tanks_Track0Layout DATA_A5A6_Tanks_Track1Layout DATA_A7D4_Tanks_Track2Layout DATA_A7D4_Tanks_Track3Layout DATA_AA4A_Tanks_GGPalette DATA_AA8A_Tanks_DecoratorTiles DATA_AB0A_TanksDATA DATA_AB4A_Tanks_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $ED $45 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $ED $45 $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF
.endif
;.ends

.orga $8080
;.section "Tanks metatiles" force

.incbin "Assets/Tanks/Metatiles.tilemap"

DATA_9F70_Tanks_BehaviourData:
.incbin "Assets/Tanks/Behaviour data.compressed"
DATA_A32A_Tanks_WallData:
.incbin "Assets/Tanks/Wall data.compressed"
DATA_A42C_Tanks_Track0Layout:
.incbin "Assets/Tanks/Track 0 layout.compressed"
DATA_A5A6_Tanks_Track1Layout:
.incbin "Assets/Tanks/Track 1 layout.compressed"
DATA_A7D4_Tanks_Track2Layout:
DATA_A7D4_Tanks_Track3Layout:
.incbin "Assets/Tanks/Track 2 layout.compressed"
DATA_AA4A_Tanks_GGPalette:
  GGCOLOUR $000000
  GGCOLOUR $000088
  GGCOLOUR $0044EE
  GGCOLOUR $8888EE
  GGCOLOUR $EEEEEE
  GGCOLOUR $440000
  GGCOLOUR $880000
  GGCOLOUR $008800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
DATA_AA8A_Tanks_DecoratorTiles:
.incbin "Assets/Tanks/Decorators.1bpp"
DATA_AB0A_TanksDATA:
.db $22 $00 $63 $41 $63 $41 $49 $45 $77 $73 $22 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $C0 $E0 $C0 $E0 $A2 $C0 $A0 $A0 $A0 $A0 $80 $A0 $80 $A0 $A0 $A0 $8A $A0 $80 $8A $A0 $80 $82 $C0 $A0 $A0 $C0 $22 $A0 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
DATA_AB4A_Tanks_EffectsTiles:
.incbin "Assets/Tanks/Effects.3bpp"

DATA_26C52_Tiles_Challenge_Icon:
.incbin "Assets/Menu/Icon-Challenge.3bpp.compressed"

DATA_26FC6_Tiles_HeadToHead_Icon:
.incbin "Assets/Menu/Icon-HeadToHead.3bpp.compressed"

DATA_27391_Tiles_Tournament_Icon:
.incbin "Assets/Menu/Icon-Tournament.3bpp.compressed"

DATA_27674_Tiles_SingleRace_Icon:
.incbin "Assets/Menu/Icon-SingleRace.3bpp.compressed"

DATA_2794C_Tiles_MediumNumbers:
.incbin "Assets/Menu/Numbers-Medium.3bpp.compressed"

DATA_279F0_Tilemap_Trophy:
.incbin "Assets/Menu/Trophy.tilemap.compressed"

DATA_27A12_Tiles_TwoPlayersOnOneGameGear_Icon:
.incbin "Assets/Menu/Icon-TwoPlayersOnOneGameGear.4bpp.compressed"

.ifdef BLANK_FILL_ORIGINAL
.rept 65
.db $ff $ff $00 $00 ; Empty
.endr
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 10
.ORG $0000
;.section "Bank 10" force

.dstruct DATA_28000_TrackData_RuffTrux instanceof TrackData data  DATA_A1B0_RuffTrux_BehaviourData DATA_A396_RuffTrux_WallData DATA_A420_RuffTrux_Track0Layout DATA_A5F0_RuffTrux_Track1Layout DATA_A7A8_RuffTrux_Track2Layout DATA_A7A8_RuffTrux_Track3Layout DATA_A9C5_RuffTrux_GGPalette DATA_A9C5_RuffTrux_DecoratorTiles DATA_AA05_RuffTruxDATA DATA_AA45_RuffTrux_EffectsTiles

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $ED $45 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $ED $45 $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF
.endif
;.ends

.orga $8080
;.section "RuffTrux metatiles" force

; Metatiles
.incbin "Assets/RuffTrux/Metatiles.tilemap" ; 64 metatiles

DATA_A1B0_RuffTrux_BehaviourData:
.incbin "Assets/RuffTrux/Behaviour data.compressed"
DATA_A396_RuffTrux_WallData:
.incbin "Assets/RuffTrux/Wall data.compressed"
DATA_A420_RuffTrux_Track0Layout:
.incbin "Assets/RuffTrux/Track 0 layout.compressed"
DATA_A5F0_RuffTrux_Track1Layout:
.incbin "Assets/RuffTrux/Track 1 layout.compressed"
DATA_A7A8_RuffTrux_Track3Layout: ; no data
DATA_A7A8_RuffTrux_Track2Layout:
.incbin "Assets/RuffTrux/Track 2 layout.compressed"
DATA_A9C5_RuffTrux_DecoratorTiles: ; no data
DATA_A9C5_RuffTrux_GGPalette:
  GGCOLOUR $000000
  GGCOLOUR $EEEEEE
  GGCOLOUR $888844
  GGCOLOUR $004400
  GGCOLOUR $0088EE
  GGCOLOUR $884400
  GGCOLOUR $444400
  GGCOLOUR $440000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $EE4444
  GGCOLOUR $44EE00
  GGCOLOUR $000000
  GGCOLOUR $4488EE
  GGCOLOUR $444444
  GGCOLOUR $888888
  GGCOLOUR $EEEEEE
  GGCOLOUR $EE8800
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
  GGCOLOUR $000000
DATA_AA05_RuffTruxDATA:
.db $C0 $C0 $00 $00 $22 $22 $49 $45 $73 $77 $80 $00 $22 $22 $A0 $C0 $C0 $C0 $C0 $22 $E0 $A0 $A0 $A0 $A0 $A0 $A0 $E0 $E0 $A0 $00 $A0 $E0 $C0 $A0 $80 $80 $A0 $A0 $A0 $C0 $C0 $E0 $E0 $A0 $A0 $80 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $22 $22 $A0 $00 $00 $00 $00 $00
DATA_AA45_RuffTrux_EffectsTiles:
.incbin "Assets/RuffTrux/Effects.3bpp"

DATA_2AB4D_Tiles_Portrait_RuffTrux:
.incbin "Assets/RuffTrux/Portrait.3bpp.compressed"

DATA_2B02D_Tiles_Font:
.incbin "Assets/Menu/Font.3bpp.compressed"

DATA_2B151_Tiles_Hand:
.incbin "Assets/Menu/Hand.3bpp.compressed"

DATA_2B33E_SpriteNs_Hand:
DATA_2B33E_SpriteNs_HandFist:
.db  -1,  -1,  -1,  -1,  -1,  -1
.db  -1, $00, $01, $02, $03,  -1
.db  -1, $04, $05, $06, $07,  -1
.db  -1,  -1, $08, $09, $0A,  -1

DATA_2B356_SpriteNs_HandLeft:
.db  -1,  -1,  -1,  -1,  -1,  -1
.db $0B, $0C, $0D, $02, $03,  -1
.db $0E, $0F, $05, $06, $07,  -1
.db  -1,  -1, $08, $09, $0A,  -1

DATA_2B36E_SpriteNs_HandRight:
.db  -1,  -1, $10, $11, $12, $13
.db  -1, $14, $15, $16, $17,  -1
.db  -1, $18, $19, $1A, $1B,  -1
.db  -1,  -1, $1C, $1D, $1E,  -1

DATA_2B386_Tiles_ChallengeText:
.incbin "Assets/Menu/Text-Challenge.3bpp.compressed"

DATA_2B4BA_Tilemap_ChallengeText:
.incbin "Assets/Menu/Text-Challenge.tilemap"

DATA_2B4CA_Tiles_HeadToHeadText:
.incbin "Assets/Menu/Text-HeadtoHead.3bpp.compressed"

DATA_2B5BE_Tilemap_HeadToHeadText:
.incbin "Assets/Menu/Text-HeadtoHead.tilemap"


LABEL_2B5D2_GameVBlankUpdateSoundTrampoline:
  jp LABEL_2B616_Sound

LABEL_2B5D5_SilencePSG:
  ld a, $FF
  out (PORT_PSG), a
  ld a, $9F
  out (PORT_PSG), a
  ld a, $BF
  out (PORT_PSG), a
  ld a, $DF
  out (PORT_PSG), a
  ret

.ifdef UNNECESSARY_CODE
LABEL_2B5E6_Player1SFX_Unused:
  ld a, (_RAM_D97E_Player1SFX_Unused)
  ld (_RAM_D963_SFXTrigger_Player1), a
  ret

LABEL_2B5ED_Player2SFX_Unused:
  ld a, (_RAM_D97F_Player2SFX_Unused)
  ld (_RAM_D974_SFXTrigger_Player2), a
  ret

LABEL_2B5F4_:
  ; _RAM_D95B_ -= 4
  ld hl, (_RAM_D95B_)
  ld bc, 4
  and a
  sbc hl, bc
  ld (_RAM_D95B_), hl
  ret

LABEL_2B601_:
  ; _RAM_D96C_ += 4
  ld hl, (_RAM_D96C_)
  ld bc, 4
  and a
  sbc hl, bc
  ld (_RAM_D96C_), hl
  ret

LABEL_2B60E_:
  ; _RAM_D95B_ += 1
  ld hl, (_RAM_D95B_)
  inc hl
  ld (_RAM_D95B_), hl
  ret
.endif

LABEL_2B616_Sound:
  ld a, (_RAM_D957_SoundIndex)
  ld c, a
  inc a
  and $07
  ld (_RAM_D957_SoundIndex), a
  ld a, c
  and $03
  ld (_RAM_D956_), a
  ld ix, _RAM_D963_SFXTrigger_Player1
  ld bc, _RAM_D94C_Sound1Channel0Volume
  call LABEL_2B7A1_SoundFunction
  call +
  ld ix, _RAM_D974_SFXTrigger_Player2
  ld bc, _RAM_D94F_Sound2Channel0Volume
  call LABEL_2B7A1_SoundFunction
  call ++
  ld a, (_RAM_D95A_)
  or a
  jr nz, LABEL_2B699_Sound
  call LABEL_2B6C9_Sound
  call LABEL_2B70D_
  jp LABEL_2B751_

+:
  ld a, (_RAM_D964_Sound1Control)
  or a
  ret z
  ld a, (_RAM_D94C_Sound1Channel0Volume)
  and $0F
  or $90
  out (PORT_PSG), a
  ld a, (_RAM_D94D_Sound1Channel1Volume)
  or $80
  out (PORT_PSG), a
  ld a, (_RAM_D94E_Sound1Channel2Volume)
  out (PORT_PSG), a
  ld a, (_RAM_D964_Sound1Control)
  cp $02
  ret nz
  xor a
  ld (_RAM_D964_Sound1Control), a
  ret

++:
  ld a, (_RAM_D975_Sound2Control)
  or a
  ret z
  ld a, (_RAM_D94F_Sound2Channel0Volume)
  and $0F
  or $B0
  out (PORT_PSG), a
  ld a, (_RAM_D950_Sound2_Channel1Volume)
  or $A0
  out (PORT_PSG), a
  ld a, (_RAM_D951_Sound2_Channel2Volume)
  out (PORT_PSG), a
  ld a, (_RAM_D975_Sound2Control)
  cp $02
  ret nz
  xor a
  ld (_RAM_D975_Sound2Control), a
  ret

LABEL_2B699_Sound:
  ld a, (_RAM_D96B_SoundMask)
  ld c, a
  ld a, (_RAM_D97C_Sound)
  or c
  ret nz
  ld a, (_RAM_D957_SoundIndex)
  add a, a
  ld c, a
  ld b, $00
  ld hl, DATA_2B791_SoundTable
  add hl, bc
  ld a, (hl)
  or a
  jr z, +
  ld a, $E0
  out (PORT_PSG), a
  ld a, (hl)
  out (PORT_PSG), a
+:inc hl
  ld a, (hl)
  cpl
  and $0F
  or $F0
  out (PORT_PSG), a
  ld a, $C0
  out (PORT_PSG), a
  xor a
  out (PORT_PSG), a
  ret

LABEL_2B6C9_Sound:
  ld hl, _RAM_D95B_
  ld a, (_RAM_D964_Sound1Control)
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
  out (PORT_PSG), a
  inc hl
  ld a, (_RAM_D956_)
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
  ld (_RAM_D953_), a
  ld a, $80
  out (PORT_PSG), a
  ld a, h
  and $3F
  ld (_RAM_D952_), a
  out (PORT_PSG), a
  ret

LABEL_2B70D_:
  ld hl, _RAM_D96C_
  ld a, (_RAM_D975_Sound2Control)
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
  out (PORT_PSG), a
  inc hl
  ld a, (_RAM_D956_)
  ld c, a
  ld b, $00
  add hl, bc
  ld l, (hl)
; Executed in RAM at d954
LABEL_2B72B_:
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
  ld (_RAM_D955_), a
  ld a, $A0
  out (PORT_PSG), a
  ld a, h
  and $3F
  ld (_RAM_D954_), a
  out (PORT_PSG), a
  ret

LABEL_2B751_:
  ld a, (_RAM_D956_)
  and $01
  jp z, +
  ld a, (_RAM_D964_Sound1Control)
  or a
  ret nz
  ld a, r
  and $07
  ld c, a
  ld a, (_RAM_D953_)
  add a, c
  and $0F
  or $C0
  out (PORT_PSG), a
  ld a, (_RAM_D952_)
  and $3F
  out (PORT_PSG), a
  ret

+:
  ld a, (_RAM_D975_Sound2Control)
  or a
  ret nz
  ld a, r
  and $07
  ld c, a
  ld a, (_RAM_D955_)
  add a, c
  and $0F
  or $C0
  out (PORT_PSG), a
  ld a, (_RAM_D954_)
  and $3F
  out (PORT_PSG), a
  ret

; Data from 2B791 to 2B7A0 (16 bytes)
DATA_2B791_SoundTable:
.db $02 $0F
.db $07 $0B
.db $00 $07
.db $00 $03
.db $02 $0F
.db $07 $0B
.db $00 $07
.db $00 $03

LABEL_2B7A1_SoundFunction:
  ld a, (ix+0)
  or a
  jr z, +
  dec a ; Make 0-indexed
  add a, a ; Multiply by 6
  ld e, a
  add a, a
  add a, e
  ld e, a ; Look up
  ld d, $00
  ld hl, DATA_2B911_SoundData_
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
+:ld a, (ix+1)
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
  ld (_RAM_D958_), a
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

+:or a
  jr nz, +
  ld a, $0F
  ld (bc), a
  jr ++

+:inc bc
  push hl
    add a, a
    ld e, a
    ld d, $00
    ld hl, DATA_2B87B_PSGNotes
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
  ld a, (_RAM_D96B_SoundMask)
  ld c, a
  ld a, (_RAM_D97C_Sound)
  or c
  ret nz
  ld a, $FF
  out (PORT_PSG), a
  ld a, $E0
  out (PORT_PSG), a
  xor a
  out (PORT_PSG), a
  ret

+:
  inc hl
  or a
  jr z, +
  ex af, af'
  ld a, (_RAM_D958_)
  or $F0
  out (PORT_PSG), a
  ld a, $E3
  out (PORT_PSG), a
  ex af, af'
  out (PORT_PSG), a
  ld a, $01
  ld (ix+8), a
+:
  ld (ix+6), l
  ld (ix+7), h
  ret

DATA_2B87B_PSGNotes:
.dw 0
  PSGNotes 0, 74

; Data from 2B911 to 2BFFF (1775 bytes)
DATA_2B911_SoundData_:
; 6-byte table of pointers into data pairs/triplets?
; Some point to _RAM_D97D_ instead
; Pointers point to various lengths of data following the table
.dw DATA_2B995_SoundData_ DATA_2B99D_SoundData_ _RAM_D97D_
.dw DATA_2B9A5_SoundData_ DATA_2B9AB_SoundData_ DATA_2B9B1_SoundData_
.dw DATA_2B9B6_SoundData_ DATA_2B9BE_SoundData_ DATA_2B9C6_SoundData_
.dw DATA_2B9CE_SoundData_ DATA_2B9D8_SoundData_ DATA_2B9E1_SoundData_
.dw DATA_2B9EA_SoundData_ DATA_2BA00_SoundData_ DATA_2BA15_SoundData_
.dw DATA_2BA29_SoundData_ DATA_2BA33_SoundData_ DATA_2BA3D_SoundData_
.dw DATA_2BA46_SoundData_ DATA_2BA50_SoundData_ DATA_2BA5A_SoundData_
.dw DATA_2BA63_SoundData_ DATA_2BA7A_SoundData_ DATA_2BA90_SoundData_
.dw DATA_2BAA6_SoundData_ DATA_2BAD3_SoundData_ _RAM_D97D_
.dw DATA_2BAF6_SoundData_ DATA_2BAFF_SoundData_ DATA_2BB07_SoundData_
.dw DATA_2BB0F_SoundData_ DATA_2BB18_SoundData_ DATA_2BB21_SoundData_
.dw DATA_2BB2A_SoundData_ DATA_2BB3A_SoundData_ _RAM_D97D_
.dw DATA_2BB4B_SoundData_ DATA_2BB54_SoundData_ DATA_2BB5D_SoundData_
.dw DATA_2BB66_SoundData_ DATA_2BB93_SoundData_ _RAM_D97D_
.dw DATA_2BBC1_SoundData_ DATA_2BBC9_SoundData_ _RAM_D97D_
.dw DATA_2BBD1_SoundData_ DATA_2BBD8_SoundData_ DATA_2BBDF_SoundData_
.dw DATA_2BBE6_SoundData_ DATA_2BBEF_SoundData_ DATA_2BBF8_SoundData_
.dw DATA_2BC01_SoundData_ DATA_2BC92_SoundData_ _RAM_D97D_
.dw DATA_2BD25_SoundData_ DATA_2BD76_SoundData_ _RAM_D97D_
.dw DATA_2BDC7_SoundData_ DATA_2BE08_SoundData_ _RAM_D97D_
.dw DATA_2BE49_SoundData_ DATA_2BE51_SoundData_ DATA_2BE59_SoundData_
.dw DATA_2BE61_SoundData_ DATA_2BE6F_SoundData_ DATA_2BE7D_SoundData_

; Most data seems terminated by a $00 or $ff, bt not all
DATA_2B995_SoundData_: .db $0F $0E $0D $0C $0B $0A $08 $00
DATA_2B99D_SoundData_: .db $18 $18 $18 $18 $18 $18 $18 $FF
DATA_2B9A5_SoundData_: .db $0F $0C $09 $06 $03 $00
DATA_2B9AB_SoundData_: .db $01 $05 $01 $05 $00 $FF
DATA_2B9B1_SoundData_: .db $07 $06 $00 $00 $FF
DATA_2B9B6_SoundData_: .db $0F $0E $0D $0C $0B $0A $09 $00
DATA_2B9BE_SoundData_: .db $06 $05 $04 $03 $02 $01 $00 $FF
DATA_2B9C6_SoundData_: .db $06 $00 $04 $00 $07 $00 $00 $FF
DATA_2B9CE_SoundData_: .db $0F $0E $0D $0C $0B $0A $09 $08 $07 $00
DATA_2B9D8_SoundData_: .db $05 $00 $00 $04 $00 $03 $00 $00 $FF
DATA_2B9E1_SoundData_: .db $05 $00 $00 $06 $00 $07 $00 $00 $FF
DATA_2B9EA_SoundData_: .db $0F $0F $0F $0E $0E $0D $0D $0D $0C $0C $0B $0B $0B $0A $0A $09 $09 $09 $08 $08 $08 $00
DATA_2BA00_SoundData_: .db $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $FF
DATA_2BA15_SoundData_: .db $05 $00 $00 $00 $06 $00 $00 $00 $00 $04 $00 $00 $00 $00 $07 $00 $00 $00 $00 $FF
DATA_2BA29_SoundData_: .db $0F $0F $0E $0E $0C $0C $0A $0A $08 $00
DATA_2BA33_SoundData_: .db $1E $0A $0A $0C $0E $10 $12 $14 $00 $FF
DATA_2BA3D_SoundData_: .db $06 $00 $05 $00 $04 $00 $07 $00 $FF
DATA_2BA46_SoundData_: .db $0F $0F $0E $0E $0C $0C $0A $0A $08 $00
DATA_2BA50_SoundData_: .db $02 $04 $08 $10 $20 $00 $00 $00 $00 $FF
DATA_2BA5A_SoundData_: .db $05 $00 $00 $00 $07 $00 $00 $00 $FF
DATA_2BA63_SoundData_: .db $0F $0F $0E $0E $0C $0C $0A $0A $08 $08 $07 $07 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $00
DATA_2BA7A_SoundData_: .db $18 $00 $16 $00 $14 $00 $12 $00 $10 $00 $0E $00 $0C $00 $00 $00 $00 $00 $00 $00 $00 $FF
DATA_2BA90_SoundData_: .db $06 $00 $00 $00 $05 $00 $00 $00 $04 $00 $00 $00 $07 $00 $00 $00 $00 $00 $00 $00 $00 $FF
DATA_2BAA6_SoundData_: .db $0F $0F $0F $0F $0E $0E $0E $0E $0D $0D $0D $0D $0C $0C $0C $0C $0B $0B $0B $0B $0A $0A $0A $0A $08 $08 $08 $08 $06 $06 $06 $06 $04 $04 $04 $04 $03 $03 $03 $03 $02 $02 $02 $02 $00
DATA_2BAD3_SoundData_: .db $32 $31 $30 $2F $2E $2D $2C $2B $2A $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $1F $1E $1D $1C $1B $1A $19 $18 $17 $16 $15 $0A $09 $08 $07 $FF
DATA_2BAF6_SoundData_: .db $0F $0E $0D $0C $0A $09 $08 $07 $00
DATA_2BAFF_SoundData_: .db $05 $04 $03 $02 $01 $00 $00 $FF
DATA_2BB07_SoundData_: .db $05 $00 $04 $00 $06 $00 $00 $FF
DATA_2BB0F_SoundData_: .db $0F $0D $0B $09 $07 $05 $03 $01 $00
DATA_2BB18_SoundData_: .db $14 $12 $10 $0E $0C $0A $08 $06 $FF
DATA_2BB21_SoundData_: .db $06 $00 $05 $00 $00 $07 $00 $00 $FF
DATA_2BB2A_SoundData_: .db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F
DATA_2BB3A_SoundData_: .db $28 $2A $2C $2E $30 $32 $0A $0F $14 $19 $1E $23 $28 $2D $32 $37 $FF
DATA_2BB4B_SoundData_: .db $0F $0E $0C $0A $08 $06 $04 $02 $00
DATA_2BB54_SoundData_: .db $0A $09 $08 $07 $06 $05 $00 $00 $FF
DATA_2BB5D_SoundData_: .db $06 $00 $05 $00 $06 $00 $04 $00 $FF
DATA_2BB66_SoundData_: .db $0F $0F $0F $0F $0E $0E $0E $0E $0D $0D $0D $0D $0C $0C $0C $0C $0B $0B $0B $0B $0A $0A $0A $0A $08 $08 $08 $08 $06 $06 $06 $06 $04 $04 $04 $04 $03 $03 $03 $03 $02 $02 $02 $02 $00
DATA_2BB93_SoundData_: .db $22 $22 $22 $21 $21 $21 $20 $20 $20 $1F $1F $1F $1E $1E $1E $1D $1D $1D $1C $1C $1C $1B $1B $1B $1A $1A $1A $19 $19 $19 $18 $18 $18 $17 $17 $17 $16 $16 $16 $15 $15 $15 $14 $14 $14 $FF
DATA_2BBC1_SoundData_: .db $0F $0F $0F $0F $0F $0F $0F $00
DATA_2BBC9_SoundData_: .db $28 $27 $28 $29 $28 $27 $28 $FF
DATA_2BBD1_SoundData_: .db $0F $0F $0F $0F $0F $0F $00
DATA_2BBD8_SoundData_: .db $1E $1D $1E $1F $1E $1D $FF
DATA_2BBDF_SoundData_: .db $07 $00 $00 $00 $00 $00 $FF
DATA_2BBE6_SoundData_: .db $0F $0F $0E $0D $0C $0A $08 $06 $00
DATA_2BBEF_SoundData_: .db $00 $00 $00 $00 $00 $00 $00 $00 $FF
DATA_2BBF8_SoundData_: .db $07 $00 $04 $00 $07 $00 $00 $00 $FF
DATA_2BC01_SoundData_: .db $01 $01 $02 $02 $03 $03 $04 $04 $05 $05 $06 $06 $07 $07 $08 $08 $09 $09 $0A $0A $0B $0B $0C $0C $0D $0D $0E $0E $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0E $0E $0D $0D $0C $0C $0B $0B $0A $0A $09 $09 $08 $08 $07 $07 $06 $06 $05 $05 $04 $04 $03 $03 $02 $02 $01 $01 $00
DATA_2BC92_SoundData_: .db $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $32 $31 $30 $2F $2E $2D $2C $2B $2A $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $1F $1E $1D $1C $1B $1A $19 $18 $17 $16 $15 $14 $13 $12 $11 $10 $0F $0E $0D $0C $0B $0A $FF
DATA_2BD25_SoundData_: .db $0F $0F $0F $0F $0F $0F $0F $0F $0E $0E $0E $0E $0E $0E $0E $0E $0D $0D $0D $0D $0D $0D $0D $0D $0C $0C $0C $0C $0C $0C $0C $0C $0B $0B $0B $0B $0B $0B $0B $0B $0A $0A $0A $0A $0A $0A $0A $0A $08 $08 $08 $08 $08 $08 $08 $08 $06 $06 $06 $06 $06 $06 $06 $06 $04 $04 $04 $04 $04 $04 $04 $04 $02 $02 $02 $02 $02 $02 $02 $02 $00
DATA_2BD76_SoundData_: .db $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $FF
DATA_2BDC7_SoundData_: .db $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $00
DATA_2BE08_SoundData_: .db $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $FF
DATA_2BE49_SoundData_: .db $00 $04 $08 $0C $0F $0F $0F $00
DATA_2BE51_SoundData_: .db $00 $00 $00 $00 $00 $00 $00 $FF
DATA_2BE59_SoundData_: .db $06 $00 $05 $00 $04 $07 $00 $FF
DATA_2BE61_SoundData_: .db $07 $08 $09 $0A $0B $0C $0D $0E $0F $0F $0F $0F $0F $00
DATA_2BE6F_SoundData_: .db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $FF
DATA_2BE7D_SoundData_: .db $07 $00 $00 $04 $00 $00 $05 $00 $00 $06 $00 $00 $00 $FF

.ifdef BLANK_FILL_ORIGINAL
.repeat $174/4
.db $ff $ff $00 $00 ; Uninitialised data
.endr
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 11
.ORG $0000
;.section "Bank 11"

DATA_2C000_TrackData_Helicopters_BadReference:

; Data from 2C000 to 2FFFF (16384 bytes)
; Portrait data (3bpp)
DATA_Tiles_Anne_Happy:
.incbin "Assets/Racers/Anne-Happy.3bpp"
DATA_Tiles_Anne_Sad:
.incbin "Assets/Racers/Anne-Sad.3bpp"
DATA_Tiles_Bonnie_Happy:
.incbin "Assets/Racers/Bonnie-Happy.3bpp"
DATA_Tiles_Bonnie_Sad:
.incbin "Assets/Racers/Bonnie-Sad.3bpp"
DATA_Tiles_Chen_Happy:
.incbin "Assets/Racers/Chen-Happy.3bpp"
DATA_Tiles_Chen_Sad:
.incbin "Assets/Racers/Chen-Sad.3bpp"
DATA_Tiles_Cherry_Happy:
.incbin "Assets/Racers/Cherry-Happy.3bpp"
DATA_Tiles_Cherry_Sad:
.incbin "Assets/Racers/Cherry-Sad.3bpp"
DATA_Tiles_Dwayne_Happy:
.incbin "Assets/Racers/Dwayne-Happy.3bpp"
DATA_Tiles_Dwayne_Sad:
.incbin "Assets/Racers/Dwayne-Sad.3bpp"
DATA_Tiles_Emilio_Happy:
.incbin "Assets/Racers/Emilio-Happy.3bpp"
DATA_Tiles_Emilio_Sad:
.incbin "Assets/Racers/Emilio-Sad.3bpp"
DATA_Tiles_Jethro_Happy:
.incbin "Assets/Racers/Jethro-Happy.3bpp"
DATA_Tiles_Jethro_Sad:
.incbin "Assets/Racers/Jethro-Sad.3bpp"
DATA_Tiles_Joel_Happy:
.incbin "Assets/Racers/Joel-Happy.3bpp"
DATA_Tiles_Joel_Sad:
.incbin "Assets/Racers/Joel-Sad.3bpp"
DATA_Tiles_Mike_Happy:
.incbin "Assets/Racers/Mike-Happy.3bpp"
DATA_Tiles_Mike_Sad:
.incbin "Assets/Racers/Mike-Sad.3bpp"
DATA_Tiles_Spider_Happy:
.incbin "Assets/Racers/Spider-Happy.3bpp"
DATA_Tiles_Spider_Sad:
.incbin "Assets/Racers/Spider-Sad.3bpp"
DATA_Tiles_Walter_Happy:
.incbin "Assets/Racers/Walter-Happy.3bpp"
DATA_Tiles_Walter_Sad:
.incbin "Assets/Racers/Walter-Sad.3bpp"

DATA_2FDE0_Tiles_SmallLogo:
.incbin "Assets/Menu/Logo-small.3bpp.compressed"

DATA_2FF6F_Tilemap:
.incbin "Assets/Menu/Logo-big.tilemap.compressed"

.ifdef BLANK_FILL_ORIGINAL
.db $00 $FF $FF $00 $00
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 12
.ORG $0000
;.section "Bank 12"

; Data from 30000 to 30A67 (2664 bytes)
DATA_30000_CarTiles_FormulaOne:
.incbin "Assets/Formula One/Car.3bpp.runencoded"
.dsb 4, 0 ; Unneeded padding from manual placement?
DATA_30330_CarTiles_Warriors:
.incbin "Assets/Warriors/Car.3bpp.runencoded"
.dsb 4, 0
DATA_306D0_CarTiles_Tanks:
.incbin "Assets/Tanks/Car.3bpp.runencoded"
.dsb 7, 0

; Data from 30A68 to 30C67 (512 bytes)
DATA_30A68_ChallengeHUDTiles:
; 4bpp tiles (32 bytes per tile)
; - Car colour squares *4 (first is highlighted)
; - "st", "nd", "rd", "th"
; - Car colour "finished" squares *4
; - Smoke (unused?) *4
; - Lap remaining numbers (1-4)
.incbin "Assets/Challenge HUD.4bpp"

LABEL_30CE8_PlayMenuMusic:
  or a
  jr nz, +
  ld a, $04 ; 0 -> 4
+:
  dec a ; Subtract 1
  ld c, a
  ex af, af'
    ; Look up first value and put in RAM
    ld b, $00
    ld hl, DATA_31410_MusicIndirection
    add hl, bc
    ld a, (hl)  ; -ve number
    ld (_RAM_D916_MenuSound_), a
    add a, $0C  ; +ve number
    ld (_RAM_D917_MenuSound_), a
    ; Init other stuff
    xor a
    ld (_RAM_D918_MenuSound_), a
  ex af, af'
  add a, a
  ld c, a
  ld hl, DATA_314F7_PointerTable_ ; Look up second value
  add hl, bc
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ld (_RAM_D929_MenuSound_), hl
  ; Init other stuff
  ld a, $06
  ld (_RAM_D92B_MenuSound_), a
  ld (_RAM_D92C_MenuSound_), a
  ld a, $01
  ld (_RAM_D92F_), a
  ld (_RAM_D74D_), a
  ld (_RAM_D772_), a
  ld (_RAM_D797_), a
  ret

LABEL_30D28_StopMenuMusic:
  ld hl, DATA_314AF_MenuMusicStopData
  ld de, _RAM_D91A_MenuSoundData
  ld bc, DATA_314AF_MenuMusicStopData_End - DATA_314AF_MenuMusicStopData
  ldir
  jp LABEL_30F7D_

LABEL_30D36_MenuMusicFrameHandler:
  ld a, (_RAM_D912_)
  ld c, a
  and $01
  ld (_RAM_D90F_), a
  ld a, c
  and $03
  ld (_RAM_D910_), a
  ld a, c
  and $07
  ld (_RAM_D911_), a
  ld a, c
  and $0F
  ld (_RAM_D912_), a
  ld a, (_RAM_D92B_MenuSound_)
  dec a
  ld (_RAM_D92B_MenuSound_), a
  jp nz, LABEL_30DC7_
  ld a, (_RAM_D915_)
  or a
  jr nz, +
  ld a, (_RAM_D92C_MenuSound_)
+:
  ld (_RAM_D92B_MenuSound_), a
  ld a, (_RAM_D92F_)
  dec a
  and $3F
  ld (_RAM_D92F_), a
  jp nz, +
  ld hl, (_RAM_D929_MenuSound_)
  ld a, (hl)
  inc hl
  ld (_RAM_D929_MenuSound_), hl
  add a, a
  ld c, a
  ld b, $00
  ld hl, DATA_3150F_MusicData
  add hl, bc
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ld bc, DATA_31565_
  add hl, bc
  ld (_RAM_D92D_), hl
+:
  ld ix, _RAM_D744_
  ld iy, _RAM_D922_
  ld hl, (_RAM_D92D_)
  ld a, (_RAM_D916_MenuSound_)
  call LABEL_31093_
  call LABEL_31068_
  ld ix, _RAM_D769_
  ld iy, _RAM_D923_
  ld a, (_RAM_D917_MenuSound_)
  call LABEL_31093_
  call LABEL_31068_
  ld ix, _RAM_D78E_
  ld iy, _RAM_D924_
  ld a, (_RAM_D918_MenuSound_)
  call LABEL_31093_
  call LABEL_31068_
  ld (_RAM_D92D_), hl
LABEL_30DC7_:
  ld iy, _RAM_D91A_MenuSoundData
  ld ix, _RAM_D744_
  ld de, _RAM_D922_
  call +
  ld iy, _RAM_D91A_MenuSoundData+2
  ld ix, _RAM_D769_
  ld de, _RAM_D923_
  call +
  ld iy, _RAM_D91A_MenuSoundData+4
  ld ix, _RAM_D78E_
  ld de, _RAM_D924_
  call +
  jp LABEL_30F7D_

+:
  ld a, (ix+0)
  cp -1
  jp z, LABEL_30FEA_
  cp -2
  ret z
  ld a, (ix+9)
  or a
  ret nz
  ld l, (ix+19)
  ld h, (ix+20)
  ld a, (ix+22)
  dec a
  jr nz, LABEL_30E59_
  ld a, (hl)
  cp -1
  jr nz, +
  ld a, (ix+2)
  jr ++

+:
  cp -2
  jr nz, +
  ld l, (ix+17)
  ld h, (ix+18)
  ld a, (hl)
+:
  inc hl
  ld c, a
  ld a, (ix+23)
  or a
  jr z, +
  ld b, $00
  push hl
    ld l, (ix+3)
    ld h, (ix+4)
    add hl, bc
    ld (iy+0), l
    ld (iy+1), h
    jr +++

+:ld a, (ix+2)
  add a, c
++:
  add a, a
  ld c, a
  ld b, $00
  push hl
    ld hl, DATA_3137A_PSGNotes
    add hl, bc
    ld a, (hl)
    ld (iy+0), a
    inc hl
    ld a, (hl)
    ld (iy+1), a
+++:
  pop hl
  ld a, (ix+21)
LABEL_30E59_:
  ld (ix+22), a
  ld (ix+19), l
  ld (ix+20), h
  ld l, (ix+26)
  ld h, (ix+27)
  ld a, (ix+28)
  dec a
  jr nz, +
-:
  inc hl
  inc hl
  ld a, (hl)
  inc hl
  ld (ix+26), l
  ld (ix+27), h
+:
  ld (ix+28), a
  ld a, (hl)
  cp -1
  jr nz, +
  ld a, $01
  ld (ix+28), a
  jr ++

+:
  cp -2
  jr nz, ++
  ld l, (ix+24)
  ld h, (ix+25)
  jr -

++:
  and $07
  add a, a
  inc hl
  ld c, (hl)
  push de
    ld e, a
    ld d, $00
    ld hl, DATA_30EAB_
    add hl, de
  pop de
  ld a, (_RAM_D914_)
  ld b, a
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ld a, (de)
  jp (hl)

; Jump Table from 30EAB to 30EBA (8 entries, indexed by unknown)
DATA_30EAB_:
.dw LABEL_30F25_ LABEL_30F3E_ LABEL_30F67_ LABEL_30F73_ LABEL_30F5D_ LABEL_30F53_ LABEL_30F34_ LABEL_30F2A_

LABEL_30EBB_:
  ld (de), a
  ld l, (iy+0)
  ld h, (iy+1)
  ld a, (ix+32)
  cp $FF
  jr z, LABEL_30F12_
  dec a
  ld (ix+32), a
  jp nz, LABEL_30F12_
  inc a
  ld (ix+32), a
  ld l, (iy+0)
  ld h, (iy+1)
  ld c, (ix+31)
  ld a, (ix+34)
  or a
  jp nz, ++
  ld a, (ix+33)
  add a, c
  cp $0A
  jr c, +
  ld a, (ix+34)
  xor $01
  ld (ix+34), a
  ld a, $0A
+:
  ld (ix+33), a
  jp +++

++:
  ld a, (ix+33)
  sub c
  jr nc, +
  ld a, (ix+34)
  xor $01
  ld (ix+34), a
  xor a
+:
  ld (ix+33), a
+++:
  ld c, a
  ld b, $00
  add hl, bc
LABEL_30F12_:
  ld c, (ix+35)
  bit 7, c
  ld b, $00
  jr z, +
  ld b, $FF
+:
  add hl, bc
  ld (iy+0), l
  ld (iy+1), h
  ret

; 1st entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F25_:
  ld c, $00
  jp LABEL_30F3E_

; 8th entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F2A_:
  ld a, (_RAM_D910_)
  or a
  jr nz, LABEL_30F3E_
  ld a, (de)
  jp LABEL_30EBB_

; 7th entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F34_:
  ld a, (_RAM_D90F_)
  or a
  jr nz, LABEL_30F3E_
  ld a, (de)
  jp LABEL_30EBB_

; 2nd entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F3E_:
  ld a, (de)
  sub c
  jr nc, +
  xor a
+:
  cp (ix+1)
  jr nc, +
  ld a, (ix+1)
+:
  cp b
  jp nc, LABEL_30EBB_
  ld a, b
  jp LABEL_30EBB_

; 6th entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F53_:
  ld a, (_RAM_D910_)
  or a
  jr z, LABEL_30F67_
  ld a, (de)
  jp LABEL_30EBB_

; 5th entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F5D_:
  ld a, (_RAM_D90F_)
  or a
  jr z, LABEL_30F67_
  ld a, (de)
  jp LABEL_30EBB_

; 3rd entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F67_:
  ld a, (de)
  add a, c
  cp $0F
  jp c, LABEL_30EBB_
  ld a, $0F
  jp LABEL_30EBB_

; 4th entry of Jump Table from 30EAB (indexed by unknown)
LABEL_30F73_:
  ld a, $01
  ld (ix+9), a
  ld a, $0F
  jp LABEL_30EBB_

LABEL_30F7D_:
  ld ix, _RAM_D91A_MenuSoundData
  ld c, $80
  call LABEL_30FCA_
  ld c, $90
  ld a, (_RAM_D922_)
  or c
  out (PORT_PSG), a
  inc ix
  inc ix
  ld c, $A0
  call LABEL_30FCA_
  ld c, $B0
  ld a, (_RAM_D923_)
  or c
  out (PORT_PSG), a
  inc ix
  inc ix
  ld c, $C0
  call LABEL_30FCA_
  ld c, $D0
  ld a, (_RAM_D924_)
  or c
  out (PORT_PSG), a
  ld a, (_RAM_D920_)
  bit 7, a
  jr nz, +
  ld c, a
  ld a, $E0
  out (PORT_PSG), a
  ld a, c
  and $07
  out (PORT_PSG), a
+:
  ld a, (_RAM_D921_)
  ld c, $F0
  or c
  out (PORT_PSG), a
  ret

LABEL_30FCA_:
  ld e, (ix+0)
  ld d, (ix+1)
  ld a, e
  and $0F
  or c
  out (PORT_PSG), a
  rr d
  rr e
  rr d
  rr e
  rr d
  rr e
  rr d
  rr e
  ld a, e
  out (PORT_PSG), a
  ret

LABEL_30FEA_:
  ld l, (ix+11)
  ld h, (ix+12)
  ld a, (hl)
  cp $FF
  jr nz, +
  ld a, $FE
  ld (ix+0), a
  xor a
  ld (ix+10), a
  ret

+:
  inc hl
  ld (ix+11), l
  ld (ix+12), h
  add a, a
  ld c, a
  ld b, $00
  ld hl, DATA_3137A_PSGNotes
  add hl, bc
  ld a, (hl)
  ld (iy+0), a
  inc hl
  ld a, (hl)
  ld (iy+1), a
  ld l, (ix+13)
  ld h, (ix+14)
  ld a, (hl)
  inc hl
  ld (ix+13), l
  ld (ix+14), h
  ld (_RAM_D930_), a
  ld l, (ix+15)
  ld h, (ix+16)
  ld a, (hl)
  inc hl
  ld (ix+15), l
  ld (ix+16), h
  ld b, a
  ld a, (ix+10)
  or a
  ld a, b
  jr nz, +
  cp (ix+1)
  jr nc, +
  ld a, (ix+1)
+:
  ld b, a
  ld a, (_RAM_D913_)
  cp b
  jp nc, +
  ld a, b
+:
  ld (de), a
  ld b, a
  ld a, (_RAM_D930_)
  cp $09
  jr c, +
  set 7, a
+:
  ld (_RAM_D920_), a
  cp $08
  ld a, b
  jr nz, +
  ld a, $0F
+:
  ld (_RAM_D921_), a
  ret

LABEL_31068_:
  ld a, (ix+0)
  cp $FE
  ret nc
  or a
  ret z
  push hl
    dec a
    add a, a
    ld c, a
    add a, a
    add a, c
    ld c, a
    ld b, $00
    ld hl, DATA_3141C_
    add hl, bc
    push ix
      ld b, $06
-:    ld a, (hl)
      ld (ix+11), a
      inc ix
      inc hl
      djnz -
    pop ix
    ld a, $FF
    ld (ix+0), a
  pop hl
  ret

LABEL_31093_:
  ld (_RAM_D919_), a
  ld a, (_RAM_D914_)
  ld (ix+1), a
  xor a
  ld (ix+36), a
LABEL_310A0_:
  ld a, (hl)
  cp $80
  jp c, LABEL_310EF_
  inc hl
  sub $80
  and $07
  add a, a
  ld c, a
  ld b, $00
  push hl
    ld hl, DATA_310BE_PointerTable
    add hl, bc
    ld e, (hl)
    inc hl
    ld d, (hl)
  pop hl
  push de ; jp (de)
  ret

LABEL_310BA_:
  inc hl
  jp LABEL_310A0_

; Data from 310BE to 310CD (16 bytes)
DATA_310BE_PointerTable:
; Points to bits of code
.dw LABEL_311F3_ LABEL_310CE_ LABEL_311E8_ LABEL_311B3_ LABEL_311BC_ LABEL_31198_ LABEL_311A2_ LABEL_310BA_

LABEL_310CE_:
  ld a, (hl)
  and $3F
  inc hl
  jp z, LABEL_310A0_
  ld c, a
  ld a, (_RAM_D915_)
  or a
  jr nz, +
  ld a, c
+:
.ifdef GAME_GEAR_CHECKS
  ld c, a
  ld a, (_RAM_DC40_IsGameGear)
  or a
  jr z, +
  inc c
+:
  ld a, c
.endif
  ld (_RAM_D92B_MenuSound_), a
  ld (_RAM_D92C_MenuSound_), a
  jp LABEL_310A0_

LABEL_310EF_:
  ld a, (hl)
  or a
  jp z, LABEL_31196_
  ld c, a
  ld a, (_RAM_D919_)
  add a, c
  ld (ix+2), a
  add a, a
  push hl
    ld l, a
    xor a
    ld (ix+9), a
    ld (ix+36), a
    ld a, (ix+7)
    or a
    jr z, ++
    ld c, a
    ld a, (ix+10)
    or a
    ld a, c
    jr nz, +
    ld (ix+0), a
+:pop hl
  inc hl
  ret

++: ld a, (ix+36)
    or a
    jr nz, +
    ld (ix+35), a
+:  ld h, $00
    ld a, (ix+0)
    cp $FE
    jr nz, +
    ld (ix+0), h
+:  ld bc, DATA_3137A_PSGNotes
    add hl, bc
    ld a, (hl)
    ld (ix+3), a
    inc hl
    ld a, (hl)
    ld (ix+4), a
    ld l, (ix+5)
    ld h, (ix+6)
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld a, (bc)
    ld (ix+23), a
    inc bc
    ld a, (bc)
    ld (ix+21), a
    ld (ix+22), a
    inc bc
    ld (ix+17), c
    ld (ix+19), c
    ld (ix+18), b
    ld (ix+20), b
    ld a, $01
    ld (ix+28), a
    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld a, (bc)
    cp (ix+1)
    jr nc, +
    ld a, (ix+1)
+:  ld e, a
    ld a, (_RAM_D914_)
    cp e
    jr nc, +
    ld a, e
+:  ld (iy+0), a
    dec bc
    ld (ix+24), c
    ld (ix+26), c
    ld (ix+25), b
    ld (ix+27), b
    ld a, (ix+30)
    ld (ix+32), a
    xor a
    ld (ix+33), a
    ld (ix+34), a
  pop hl
LABEL_31196_:
  inc hl
  ret

LABEL_31198_:
  ld c, (hl)
  ld a, (ix+$23)
  sub c
  ld (ix+$23), a
  jr +

LABEL_311A2_:
  ld c, (hl)
  ld a, (ix+$23)
  add a, c
  ld (ix+$23), a
+:ld a, $01
  ld (ix+$24), a
  inc hl
  jp LABEL_310A0_

LABEL_311B3_:
  ld a, $01
  ld (_RAM_D92F_), a
  inc hl
  jp LABEL_310A0_

LABEL_311BC_:
  ld a, (hl)
  ld c, a
  ld b, $00
  push hl
    ld hl, DATA_314BE_
    add hl, bc
    ld (_RAM_D929_MenuSound_), hl
    ld a, $01
    ld (_RAM_D92F_), a
  pop hl
  inc hl
  ld a, $01
  ld (_RAM_D74D_), a
  ld (_RAM_D772_), a
  ld (_RAM_D797_), a
  ld a, $0F
  ld (_RAM_D922_), a
  ld (_RAM_D923_), a
  ld (_RAM_D924_), a
  jp LABEL_310A0_

LABEL_311E8_:
  ld a, (hl)
  cpl
  and $0F
  ld (ix+1), a
  inc hl
  jp LABEL_310A0_

LABEL_311F3_:
  push de
    ld a, (hl)
    and $0F
    ld e, a
    add a, a
    ld c, a
    ld b, $00
    push hl
      ld hl, DATA_31229_PointerTable
      add hl, bc
      ld c, (hl)
      ld (ix+5), c
      inc hl
      ld b, (hl)
      ld (ix+6), b
      ld (ix+7), $00
      inc bc
      ld a, (bc)
      cp $FF
      jr nz, +
      ld (ix+7), e
+:    inc bc
      inc bc
      inc bc
      ld a, (bc)
      ld (ix+31), a
      inc bc
      ld a, (bc)
      ld (ix+30), a
    pop hl
  pop de
  inc hl
  jp LABEL_310A0_

; Pointer Table from 31229 to 3124C (18 entries, indexed by unknown)
DATA_31229_PointerTable:
; Points to pointers + data?
.dw DATA_31249_ DATA_31279_ DATA_3128B_ DATA_31267_
.dw DATA_31273_ DATA_31255_ DATA_31261_ DATA_3124F_
.dw DATA_31261_ DATA_31261_ DATA_3127F_ DATA_31261_
.dw DATA_3125B_ DATA_3126D_ DATA_3124F_ DATA_3124F_
; Pointed-to from above
DATA_31249_: .dw DATA_31291_ DATA_312F2_ $FFFF
DATA_3124F_: .dw DATA_312E9_ DATA_31307_ $FFFF
DATA_31255_: .dw DATA_31295_ DATA_31340_ $FFFF
DATA_3125B_: .dw DATA_3129F_ DATA_3135C_ $1E02
DATA_31261_: .dw $FF00 DATA_312F8_ $FFFF
DATA_31267_: .dw DATA_312B1_ DATA_31307_ $FFFF
DATA_3126D_: .dw DATA_312BD_ DATA_31351_ $FFFF
DATA_31273_: .dw DATA_312C4_ DATA_31351_ $FFFF
DATA_31279_: .dw DATA_312D9_ DATA_3136E_ $0604
DATA_3127F_: .dw DATA_312E1_ DATA_31340_ $FFFF
.dw DATA_31295_ DATA_31316_ $0605 ; Unreferenced?
DATA_3128B_: .dw DATA_312CB_ DATA_31316_ $0605
; Pointed-to from above
DATA_31291_: .db $00 $01 $00 $FF
DATA_31295_: .db $01 $01 $00 $02 $00 $04 $00 $02 $00 $FF
DATA_3129F_: .db $00 $01 $00 $0C $00 $00 $00 $00 $00 $FF
.db $00 $01 $00 $0C $00 $0C $00 $FF
DATA_312B1_: .db $00 $01 $00 $04 $07 $0C $00 $04 $07 $0C $00 $FF
DATA_312BD_: .db $00 $01 $00 $03 $07 $0C $FE
DATA_312C4_: .db $00 $01 $00 $04 $07 $0C $FE
DATA_312CB_: .db $01 $01 $00 $01 $00 $01 $00 $01 $00 $01 $00 $01 $00 $FF
DATA_312D9_: .db $01 $01 $00 $04 $01 $03 $02 $FF
DATA_312E1_: .db $00 $01 $00 $18 $00 $18 $00 $FF
DATA_312E9_: .db $00 $01 $00 $0C $18 $00 $0C $18 $FF
DATA_312F2_: .db $0F $00 $03 $00 $00 $FF
DATA_312F8_: .db $06 $02 $01 $01 $06 $00 $00 $0F $05 $01 $00 $03 $00 $00 $FF
DATA_31307_: .db $00 $06 $00 $00 $0F $04 $01 $0F $04 $01 $00 $03 $00 $00 $FF
DATA_31316_: .db $00 $04 $00 $00 $0F $05 $01 $0F $05 $01 $00 $03 $00 $00 $FF
.db $0F $0C $01 $02 $0F $05 $01 $0F $05 $01 $00 $03 $00 $00 $FF
.db $00 $08 $00 $00 $0F $04 $02 $00 $03 $00 $00 $FF
DATA_31340_: .db $00 $0A $04 $01 $00 $03 $00 $00 $FF
.db  $00 $FE
.db $00 $00 $03 $00 $00 $FF
DATA_31351_: .db $06 $06 $01 $01 $FE
.db  $00 $00 $03 $00 $00 $FF
DATA_3135C_: .db $04 $02 $01 $01 $18 $00 $00 $07 $05 $01 $10 $00 $00 $00 $03 $00 $00 $FF
DATA_3136E_: .db $01 $0F $05 $01 $0F $05 $01 $00 $03 $00 $00 $FF

; Data from 3137A to 3141B (162 bytes)
DATA_3137A_PSGNotes:
 .dw 0
  PSGNotes 0, 74

 DATA_31410_MusicIndirection:
.db -10, -5, -2, -6, -6, -4, -4, -5, -3, -3, -4, -2
;.db $F6 $FB $FE $FA $FA $FC $FC $FB $FD $FD $FC $FE

; Data from 3141C to 3150E (243 bytes)
DATA_3141C_:
.dw DATA_3147C_ DATA_31483_ DATA_31489_ DATA_3147C_
.dw DATA_31483_ DATA_31489_ DATA_3147C_ DATA_31483_
.dw DATA_31489_ DATA_3147C_ DATA_31483_ DATA_31489_
.dw DATA_3147C_ DATA_31483_ DATA_31489_ DATA_314A2_
.dw DATA_31483_ DATA_31489_ DATA_3147C_ DATA_31483_
.dw DATA_31489_ DATA_3147C_ DATA_31483_ DATA_31489_
.dw DATA_314A2_ DATA_314A7_ DATA_314AB_ DATA_3147C_
.dw DATA_31483_ DATA_31489_ DATA_3148F_ DATA_31496_
.dw DATA_3149C_ DATA_3147C_ DATA_31483_ DATA_31489_
.dw DATA_3147C_ DATA_31483_ DATA_31489_ DATA_3147C_
.dw DATA_31483_ DATA_31489_ DATA_3147C_ DATA_31483_
.dw DATA_31489_ DATA_3147C_ DATA_31483_ DATA_31489_

DATA_3147C_: .db $0A $09 $08 $07 $06 $05 $FF
DATA_31483_: .db $08 $08 $08 $08 $08 $08
DATA_31489_: .db $00 $00 $00 $00 $00 $0F
DATA_3148F_: .db $16 $14 $12 $10 $0E $0C $FF
DATA_31496_: .db $06 $05 $04 $07 $07 $07
DATA_3149C_: .db $00 $00 $00 $00 $00 $0F
DATA_314A2_: .db $00 $00 $00 $00 $FF
DATA_314A7_: .db $04 $03 $07 $07
DATA_314AB_: .db $00 $02 $04 $0F

DATA_314AF_MenuMusicStopData: ; 15 bytes, menu sound engine init?
.db $00 $00 $00 $00 $00 $00 $07 $0F $0F $0F $0F $00 $00 $00 $00
DATA_314AF_MenuMusicStopData_End:

; Data pointed into by following table
; Also looked up directly?
DATA_314BE_: .db $00 $05 $02 $03 $02 $04 $06 $07 $02 $03 $02 $04 $09 $08 $0B $0B $0A $0A $0C $0D $0C $0E $00 $00
DATA_314D6_: .db $0F $10 $11 $11 $12 $13 $11 $11 $14 $15 $16 $18 $17
DATA_314E3_: .db $19 $1A $1B $1B $1C $1D
DATA_314E9_: .db $1F
DATA_314EA_: .db $20
DATA_314EB_: .db $21
DATA_314EC_: .db $10 $22 $22 $23 $24
DATA_314F1_: .db $25
DATA_314F2_: .db $26
DATA_314F3_: .db $27
DATA_314F4_: .db $28
DATA_314F5_: .db $29 $2A
; Points into the above
DATA_314F7_PointerTable_:
.dw DATA_314BE_ DATA_314D6_ DATA_314E3_ DATA_314E9_ DATA_314EA_ DATA_314EB_ DATA_314EC_ DATA_314F1_ DATA_314F2_ DATA_314F3_ DATA_314F4_ DATA_314F5_

; Data from 3150F to 33FFF (10993 bytes)
DATA_3150F_MusicData:
; relative offsets from DATA_31565_
.dw DATA_31565_1  - DATA_31565_ ; $0000
.dw DATA_31565_2  - DATA_31565_ ; $00c8
.dw DATA_31565_3  - DATA_31565_ ; $01ac
.dw DATA_31565_4  - DATA_31565_ ; $0294
.dw DATA_31565_5  - DATA_31565_ ; $0382
.dw DATA_31565_6  - DATA_31565_ ; $046C
.dw DATA_31565_7  - DATA_31565_ ; $0568
.dw DATA_31565_8  - DATA_31565_ ; $0652
.dw DATA_31565_9  - DATA_31565_ ; $0748
.dw DATA_31565_10 - DATA_31565_ ; $083A
.dw DATA_31565_11 - DATA_31565_ ; $0928
.dw DATA_31565_12 - DATA_31565_ ; $0A0C
.dw DATA_31565_13 - DATA_31565_ ; $0AF0
.dw DATA_31565_14 - DATA_31565_ ; $0BDA
.dw DATA_31565_15 - DATA_31565_ ; $0CC4
.dw DATA_31565_16 - DATA_31565_ ; $0DC0
.dw DATA_31565_17 - DATA_31565_ ; $0E88
.dw DATA_31565_18 - DATA_31565_ ; $0F6C
.dw DATA_31565_19 - DATA_31565_ ; $1050
.dw DATA_31565_20 - DATA_31565_ ; $1134
.dw DATA_31565_21 - DATA_31565_ ; $1222
.dw DATA_31565_22 - DATA_31565_ ; $1306
.dw DATA_31565_23 - DATA_31565_ ; $13F6
.dw DATA_31565_24 - DATA_31565_ ; $14F0
.dw DATA_31565_25 - DATA_31565_ ; $15DE
.dw DATA_31565_26 - DATA_31565_ ; $16C2
.dw DATA_31565_27 - DATA_31565_ ; $178E
.dw DATA_31565_28 - DATA_31565_ ; $185E
.dw DATA_31565_29 - DATA_31565_ ; $1946
.dw DATA_31565_30 - DATA_31565_ ; $1A34
.dw DATA_31565_31 - DATA_31565_ ; $1B24
.dw DATA_31565_32 - DATA_31565_ ; $1C1E
.dw DATA_31565_33 - DATA_31565_ ; $1C2A
.dw DATA_31565_34 - DATA_31565_ ; $1D16
.dw DATA_31565_35 - DATA_31565_ ; $1E02
.dw DATA_31565_36 - DATA_31565_ ; $1EE8
.dw DATA_31565_37 - DATA_31565_ ; $1FD4
.dw DATA_31565_38 - DATA_31565_ ; $20C8
.dw DATA_31565_39 - DATA_31565_ ; $21B4
.dw DATA_31565_40 - DATA_31565_ ; $223B
.dw DATA_31565_41 - DATA_31565_ ; $22C2
.dw DATA_31565_42 - DATA_31565_ ; $23AE
.dw DATA_31565_43 - DATA_31565_ ; $2498

DATA_31565_:
DATA_31565_1:  .db $80 $05 $81 $04 $12 $80 $01 $12 $00 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $00 $00 $17 $00 $12 $1B $00 $00 $1E $00 $12 $12 $00 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $00 $00 $17 $00 $12 $1B $00 $00 $1E $00 $10 $12 $00 $00 $16 $00 $10 $19 $00 $00 $1E $00 $10 $12 $00 $00 $17 $00 $0F $1B $00 $00 $1E $00 $0F $12 $00 $00 $16 $00 $0F $19 $00 $00 $1E $80 $06 $0F $10 $12 $00 $00 $17 $0F $10 $1B $00 $00 $1E $0F $12 $12 $00 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $00 $00 $17 $00 $12 $1B $00 $00 $1E $00 $12 $12 $00 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $00 $00 $17 $00 $12 $1B $00 $00 $1E $00 $10 $12 $00 $00 $16 $00 $10 $19 $00 $00 $1E $00 $10 $12 $00 $00 $17 $00 $0F $1B $00 $00 $1E $00 $0F $12 $00 $00 $16 $00 $0F $19 $00 $00 $1E $00 $10 $12 $00 $00 $17 $00 $10 $1B $00 $00 $1E $00
DATA_31565_2:  .db $80 $05 $12 $80 $01 $12 $80 $08 $14 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $12 $12 $80 $08 $14 $00 $16 $00 $12 $19 $14 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $10 $12 $80 $08 $14 $00 $16 $00 $10 $19 $00 $00 $1E $00 $10 $12 $80 $0B $19 $00 $17 $00 $0F $1B $80 $08 $14 $00 $1E $00 $0F $12 $00 $00 $16 $00 $0F $19 $14 $00 $1E $00 $10 $12 $80 $0B $19 $00 $17 $00 $10 $1B $19 $00 $1E $19 $12 $12 $80 $08 $14 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $12 $12 $80 $08 $14 $00 $16 $00 $12 $19 $14 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $10 $12 $80 $08 $14 $00 $16 $00 $10 $19 $00 $00 $1E $00 $10 $12 $80 $0B $19 $00 $17 $00 $0F $1B $80 $08 $14 $00 $1E $00 $0F $12 $00 $00 $16 $00 $0F $19 $14 $00 $1E $00 $10 $12 $80 $0B $19 $00 $17 $19 $10 $1B $19 $00 $1E $19
DATA_31565_3:  .db $80 $05 $12 $80 $0C $16 $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $16 $80 $0B $19 $00 $00 $00 $12 $16 $00 $00 $00 $00 $12 $16 $80 $08 $14 $00 $00 $00 $12 $14 $14 $00 $00 $00 $12 $16 $80 $0B $19 $00 $00 $00 $12 $17 $00 $00 $00 $00 $10 $00 $80 $08 $14 $00 $00 $00 $10 $00 $00 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $14 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $00 $10 $00 $19 $00 $00 $19 $12 $1C $80 $08 $14 $00 $00 $00 $12 $1B $00 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $17 $00 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $14 $00 $00 $00 $12 $14 $80 $0B $19 $00 $00 $00 $12 $17 $00 $00 $00 $00 $10 $85 $03 $00 $80 $08 $14 $00 $85 $03 $00 $00 $10 $19 $00 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $14 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $19 $10 $00 $19 $00 $00 $19
DATA_31565_4:  .db $80 $05 $12 $80 $0C $16 $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $16 $80 $0B $19 $00 $00 $00 $12 $16 $00 $00 $00 $00 $12 $16 $80 $08 $14 $00 $00 $00 $12 $14 $14 $00 $00 $00 $12 $16 $80 $0B $19 $00 $00 $00 $12 $17 $00 $00 $00 $00 $10 $00 $80 $08 $14 $00 $00 $00 $10 $00 $00 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $14 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $19 $10 $00 $00 $00 $00 $19 $12 $1C $80 $08 $14 $00 $00 $00 $12 $1B $00 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $17 $00 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $14 $00 $00 $00 $12 $14 $80 $0B $19 $00 $00 $00 $12 $1C $00 $00 $00 $00 $10 $85 $03 $00 $19 $00 $85 $03 $00 $00 $10 $1E $80 $08 $14 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $19 $0F $00 $80 $08 $14 $00 $00 $14 $10 $00 $80 $0B $19 $00 $00 $19 $10 $00 $80 $08 $14 $00 $00 $14
DATA_31565_5:  .db $80 $05 $12 $80 $0C $16 $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $16 $80 $0B $19 $00 $00 $00 $12 $16 $00 $00 $00 $00 $12 $16 $80 $08 $14 $00 $00 $00 $12 $14 $14 $00 $00 $00 $12 $16 $80 $0B $19 $00 $00 $00 $12 $17 $00 $00 $00 $00 $10 $00 $80 $08 $14 $00 $00 $00 $10 $00 $00 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $14 $00 $00 $00 $10 $00 $80 $0B $19 $00 $00 $19 $10 $00 $00 $00 $00 $19 $12 $1C $80 $08 $14 $00 $00 $00 $12 $1B $00 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $17 $00 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $14 $14 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $00 $00 $00 $00 $00 $10 $1E $19 $00 $1C $00 $10 $19 $80 $08 $14 $00 $17 $00 $10 $19 $80 $0B $19 $00 $17 $00 $0F $15 $80 $08 $14 $00 $12 $00 $0F $15 $80 $0B $19 $00 $12 $19 $0F $10 $80 $08 $14 $00 $0D $14 $10 $10 $80 $0B $19 $00 $0D $19 $10 $0B $80 $08 $14 $00 $09 $14
DATA_31565_6:  .db $80 $05 $12 $80 $01 $12 $80 $08 $14 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $12 $12 $80 $08 $14 $00 $16 $00 $12 $19 $14 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $10 $12 $80 $08 $14 $00 $16 $00 $10 $19 $00 $00 $1E $00 $10 $12 $80 $0B $19 $00 $17 $00 $0F $1B $80 $08 $14 $00 $1E $00 $0F $12 $00 $00 $16 $00 $0F $19 $14 $00 $1E $00 $10 $12 $80 $0B $19 $00 $17 $19 $10 $1B $00 $00 $1E $19 $12 $12 $80 $08 $14 $00 $16 $00 $12 $19 $00 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $12 $12 $80 $08 $14 $00 $16 $00 $12 $19 $14 $00 $1E $00 $12 $12 $80 $0B $19 $00 $17 $00 $12 $1B $00 $00 $1E $00 $10 $12 $19 $00 $16 $00 $10 $19 $80 $08 $14 $00 $1E $00 $10 $12 $80 $0B $19 $00 $17 $00 $0F $1B $80 $08 $14 $00 $1E $00 $0F $80 $0C $86 $0A $1E $80 $0B $19 $00 $86 $0A $00 $19 $0F $86 $0A $00 $80 $08 $14 $00 $86 $0A $00 $14 $10 $86 $08 $00 $80 $0B $19 $00 $86 $08 $00 $19 $10 $86 $06 $00 $80 $08 $14 $00 $86 $06 $00 $14
DATA_31565_7:  .db $80 $05 $10 $80 $0C $17 $80 $08 $14 $00 $00 $00 $10 $00 $00 $00 $00 $00 $10 $17 $80 $0B $19 $00 $00 $00 $10 $14 $00 $00 $00 $00 $10 $17 $80 $08 $14 $00 $00 $00 $10 $19 $14 $00 $00 $00 $10 $1B $80 $0B $19 $00 $00 $00 $10 $19 $00 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $00 $14 $00 $00 $00 $12 $17 $80 $0B $19 $00 $00 $19 $12 $19 $00 $00 $00 $19 $17 $1C $80 $08 $14 $00 $00 $00 $17 $1B $00 $00 $00 $00 $17 $00 $80 $0B $19 $00 $00 $00 $17 $17 $00 $00 $00 $00 $17 $00 $80 $08 $14 $00 $00 $00 $17 $14 $14 $00 $00 $00 $17 $00 $80 $0B $19 $00 $00 $00 $14 $1B $00 $00 $00 $00 $12 $19 $19 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $19 $12 $00 $80 $08 $14 $00 $00 $14 $12 $00 $80 $0B $19 $00 $00 $19 $12 $00 $80 $08 $14 $00 $00 $14
DATA_31565_8:  .db $80 $05 $10 $80 $0C $17 $80 $08 $14 $00 $00 $00 $10 $00 $00 $00 $00 $00 $10 $17 $80 $0B $19 $00 $00 $00 $10 $14 $00 $00 $00 $00 $10 $17 $80 $08 $14 $00 $00 $00 $10 $19 $14 $00 $00 $00 $10 $1B $80 $0B $19 $00 $00 $00 $10 $19 $00 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $00 $14 $00 $00 $00 $12 $17 $80 $0B $19 $00 $00 $19 $12 $19 $00 $00 $00 $19 $17 $1C $80 $08 $14 $00 $00 $00 $17 $1B $00 $00 $00 $00 $17 $00 $80 $0B $19 $00 $00 $00 $17 $17 $00 $00 $00 $00 $17 $00 $80 $08 $14 $00 $00 $00 $17 $14 $14 $00 $00 $00 $17 $00 $80 $0B $19 $00 $00 $00 $12 $12 $00 $00 $00 $00 $0D $80 $07 $19 $19 $00 $14 $00 $0D $12 $80 $08 $14 $00 $14 $00 $0D $19 $80 $0B $19 $00 $14 $00 $0D $12 $80 $08 $14 $00 $14 $00 $0D $19 $80 $0B $19 $00 $00 $19 $0D $19 $80 $08 $14 $00 $00 $14 $0D $80 $0C $86 $0A $19 $80 $0B $19 $00 $86 $0A $00 $19 $0D $86 $0A $00 $80 $08 $14 $00 $86 $0A $00 $14
DATA_31565_9:  .db $80 $05 $0B $82 $00 $00 $80 $08 $14 $00 $00 $00 $0B $00 $00 $00 $00 $00 $0B $00 $80 $0B $19 $00 $00 $00 $0E $00 $00 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $00 $0B $00 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $19 $00 $00 $00 $00 $80 $0C $12 $80 $08 $14 $00 $00 $00 $00 $10 $80 $0B $19 $00 $00 $00 $00 $0E $80 $08 $14 $00 $00 $00 $00 $10 $80 $0B $19 $00 $00 $19 $00 $0E $00 $00 $00 $19 $00 $00 $19 $00 $00 $00 $00 $86 $08 $00 $19 $00 $86 $08 $00 $00 $0E $82 $00 $00 $80 $08 $14 $00 $00 $00 $0E $00 $00 $00 $00 $00 $0B $00 $80 $0B $19 $00 $00 $00 $0E $00 $00 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $00 $10 $00 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $19 $00 $00 $00 $00 $17 $80 $08 $14 $00 $00 $00 $00 $15 $80 $0B $19 $00 $00 $00 $00 $17 $80 $08 $14 $00 $00 $00 $00 $15 $80 $0B $19 $00 $00 $19 $00 $17 $80 $08 $14 $00 $15 $14 $00 $12 $80 $0B $19 $00 $10 $19 $00 $0E $80 $08 $14 $00 $0B $14
DATA_31565_10: .db $80 $05 $0B $82 $00 $00 $80 $08 $14 $00 $00 $00 $0B $00 $00 $00 $00 $00 $0B $00 $80 $0B $19 $00 $00 $00 $0E $00 $00 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $00 $0B $00 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $19 $00 $00 $19 $00 $80 $0C $12 $00 $00 $00 $19 $00 $10 $80 $08 $14 $00 $00 $00 $00 $0E $14 $00 $00 $00 $00 $10 $80 $0B $19 $00 $00 $19 $00 $0E $00 $00 $00 $19 $00 $00 $80 $08 $14 $00 $00 $00 $00 $86 $08 $00 $14 $00 $86 $08 $00 $00 $0E $82 $00 $00 $14 $00 $00 $00 $0E $00 $00 $00 $00 $00 $0B $00 $80 $0B $19 $00 $00 $00 $0E $00 $00 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $00 $10 $00 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $14 $00 $15 $00 $00 $00 $14 $00 $14 $80 $0B $19 $00 $00 $00 $00 $15 $00 $00 $00 $00 $00 $17 $80 $08 $14 $00 $00 $14 $00 $00 $00 $00 $00 $14 $00 $00 $80 $0B $19 $00 $85 $08 $00 $00 $00 $85 $08 $00 $19 $00 $85 $08 $00 $19
DATA_31565_11: .db $80 $05 $14 $80 $0C $1B $80 $08 $14 $00 $17 $00 $14 $14 $00 $00 $0F $00 $20 $1B $80 $0B $19 $00 $17 $00 $14 $14 $00 $00 $0F $00 $14 $1B $80 $08 $14 $00 $17 $00 $14 $14 $14 $00 $0F $00 $20 $1B $80 $0B $19 $00 $17 $00 $14 $14 $00 $00 $0F $00 $0D $1D $80 $08 $14 $00 $19 $00 $0D $14 $00 $00 $11 $00 $19 $1D $80 $0B $19 $00 $19 $00 $0D $14 $80 $08 $14 $00 $11 $00 $0D $1D $00 $00 $19 $00 $0D $14 $14 $00 $11 $00 $19 $1D $80 $0B $19 $00 $19 $00 $0D $14 $19 $00 $11 $19 $12 $1E $80 $08 $14 $00 $19 $00 $12 $16 $00 $00 $12 $00 $12 $1E $80 $0B $19 $00 $19 $00 $12 $16 $00 $00 $12 $00 $12 $1E $80 $08 $14 $00 $19 $00 $12 $16 $14 $00 $12 $00 $12 $1E $80 $0B $19 $00 $19 $00 $12 $16 $00 $00 $12 $00 $0D $1D $80 $08 $14 $00 $19 $00 $0D $14 $00 $00 $11 $00 $19 $1D $80 $0B $19 $00 $19 $00 $0D $14 $80 $08 $14 $00 $11 $00 $0D $1D $00 $00 $19 $00 $0D $14 $14 $00 $11 $00 $19 $1D $80 $0B $19 $00 $19 $19 $0D $14 $19 $00 $11 $19
DATA_31565_12: .db $80 $05 $14 $80 $0C $1B $80 $08 $14 $00 $17 $00 $14 $14 $00 $00 $0F $00 $20 $1B $80 $0B $19 $00 $17 $00 $14 $14 $00 $00 $0F $00 $0D $1D $80 $08 $14 $00 $19 $00 $0D $14 $14 $00 $11 $00 $19 $1D $80 $0B $19 $00 $19 $00 $0D $14 $00 $00 $11 $00 $14 $1B $80 $08 $14 $00 $17 $00 $14 $14 $00 $00 $0F $00 $20 $1B $80 $0B $19 $00 $17 $00 $14 $14 $80 $08 $14 $00 $0F $00 $12 $19 $00 $00 $16 $00 $12 $12 $14 $00 $0D $00 $1E $19 $80 $0B $19 $00 $16 $00 $12 $12 $19 $00 $0D $19 $14 $1B $80 $08 $14 $00 $17 $00 $14 $14 $00 $00 $0F $00 $20 $1B $80 $0B $19 $00 $17 $00 $14 $14 $00 $00 $0F $00 $0D $1D $80 $08 $14 $00 $19 $00 $0D $14 $14 $00 $11 $00 $19 $1D $80 $0B $19 $00 $19 $00 $0D $14 $00 $00 $11 $00 $14 $1B $80 $08 $14 $00 $17 $00 $14 $14 $00 $00 $0F $00 $20 $1B $80 $0B $19 $00 $17 $00 $14 $14 $80 $08 $14 $00 $0F $00 $12 $19 $00 $00 $16 $00 $12 $12 $14 $00 $0D $00 $1E $19 $80 $0B $19 $00 $16 $19 $12 $12 $19 $00 $0D $19
DATA_31565_13: .db $80 $05 $14 $80 $0C $1B $80 $08 $14 $00 $00 $00 $14 $00 $00 $00 $00 $00 $20 $00 $80 $0B $19 $00 $00 $00 $14 $00 $00 $00 $00 $00 $14 $00 $80 $08 $14 $00 $00 $00 $14 $00 $14 $00 $00 $00 $20 $1D $80 $0B $19 $00 $00 $00 $14 $1B $00 $00 $00 $00 $0D $1D $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $19 $00 $80 $0B $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0D $00 $14 $00 $00 $00 $19 $1E $80 $0B $19 $00 $00 $19 $0D $1D $00 $00 $00 $19 $12 $1E $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $20 $00 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $14 $00 $00 $00 $12 $1E $80 $0B $19 $00 $00 $00 $12 $00 $00 $00 $00 $00 $0D $1D $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $19 $00 $80 $0B $19 $00 $00 $00 $0D $1B $80 $08 $14 $00 $00 $00 $0D $00 $80 $0B $19 $00 $00 $19 $0D $00 $80 $08 $14 $00 $00 $14 $19 $19 $80 $0B $19 $00 $00 $19 $0D $00 $80 $08 $14 $00 $00 $14
DATA_31565_14: .db $80 $05 $14 $80 $0C $1B $80 $08 $14 $00 $00 $00 $14 $00 $00 $00 $00 $00 $20 $00 $80 $0B $19 $00 $00 $00 $14 $00 $00 $00 $00 $00 $14 $00 $80 $08 $14 $00 $00 $00 $14 $00 $14 $00 $00 $00 $20 $1D $80 $0B $19 $00 $00 $00 $14 $1B $00 $00 $00 $00 $0D $1D $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $19 $00 $80 $0B $19 $00 $00 $00 $0D $1B $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0D $00 $14 $00 $00 $00 $19 $19 $80 $0B $19 $00 $00 $19 $0D $00 $00 $00 $00 $19 $12 $1E $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $00 $80 $0B $19 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $00 $80 $08 $14 $00 $00 $00 $12 $00 $14 $00 $00 $00 $12 $20 $80 $0B $19 $00 $00 $00 $12 $1E $00 $00 $00 $00 $0D $19 $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $19 $00 $80 $0B $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $00 $80 $0B $19 $00 $00 $19 $0D $00 $80 $08 $14 $00 $00 $14 $19 $00 $80 $0B $19 $00 $00 $19 $0D $00 $80 $08 $14 $00 $00 $14
DATA_31565_15: .db $80 $05 $14 $80 $0C $1B $80 $08 $14 $00 $00 $00 $14 $00 $00 $00 $00 $00 $20 $19 $80 $0B $19 $00 $00 $00 $14 $00 $00 $00 $00 $00 $14 $1B $80 $08 $14 $00 $00 $00 $14 $00 $14 $00 $00 $00 $20 $1D $80 $0B $19 $00 $00 $00 $14 $00 $00 $00 $00 $00 $0D $1E $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $19 $1D $80 $0B $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $19 $00 $00 $00 $00 $0D $00 $14 $00 $00 $00 $19 $1D $80 $0B $19 $00 $00 $19 $0D $00 $00 $00 $00 $19 $12 $1E $80 $08 $14 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $20 $80 $0B $19 $00 $00 $00 $12 $00 $00 $00 $00 $00 $12 $1E $80 $08 $14 $00 $00 $00 $12 $00 $14 $00 $00 $00 $12 $1D $80 $0B $19 $00 $00 $00 $12 $00 $00 $00 $00 $00 $0D $1B $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $19 $19 $80 $0B $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $86 $0A $00 $80 $0B $19 $00 $86 $0A $00 $19 $0D $86 $0A $00 $80 $08 $14 $00 $86 $0A $00 $14 $19 $86 $08 $00 $80 $0B $19 $00 $86 $08 $00 $19 $0D $86 $06 $00 $80 $08 $14 $84 $00 $00 $86 $06 $00 $14
DATA_31565_16: .db $80 $05 $81 $06 $0A $82 $00 $00 $00 $00 $00 $00 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $00 $08 $00 $00 $0A $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0D $00 $00 $0F $00 $00 $00 $00 $00 $0D $00 $00 $0F $00 $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $08 $00 $00 $06 $00 $00 $08 $00 $00 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0D $00 $00 $0A $00 $00 $0D $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0D $00 $00 $0F $00 $00 $00 $00 $00 $0D $00 $00 $11 $00 $00 $00 $00 $00 $11 $00 $00 $00 $00 $00 $11 $00 $80 $0B $19 $14 $00 $19 $16 $00 $19 $00 $00 $19
DATA_31565_17: .db $80 $05 $81 $06 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $08 $00 $80 $0B $19 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $00 $0A $00 $80 $0B $19 $08 $00 $00 $0A $00 $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $14 $00 $00 $14 $0D $00 $80 $0B $19 $0F $00 $00 $00 $00 $00 $0D $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $08 $00 $80 $0B $19 $06 $00 $00 $08 $00 $19 $00 $00 $19 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $08 $00 $80 $0B $19 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $0D $00 $80 $0B $19 $0A $00 $00 $0D $00 $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $14 $00 $00 $14 $0D $00 $80 $0B $19 $0F $00 $00 $00 $00 $00 $0D $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $14 $11 $00 $80 $0B $19 $14 $00 $19 $16 $00 $19 $00 $00 $19
DATA_31565_18: .db $80 $05 $0A $80 $0C $11 $80 $08 $14 $00 $0F $00 $0A $11 $14 $00 $00 $14 $08 $00 $80 $0B $19 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $00 $0A $14 $80 $0B $19 $08 $00 $00 $0A $00 $19 $00 $00 $00 $0F $13 $80 $08 $14 $00 $00 $00 $0F $00 $14 $00 $00 $14 $0D $00 $80 $0B $19 $0F $00 $00 $00 $00 $00 $0D $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $08 $14 $80 $0B $19 $06 $13 $00 $08 $11 $19 $00 $0F $19 $0A $11 $80 $08 $14 $00 $0F $00 $0A $11 $14 $00 $00 $14 $08 $00 $80 $0B $19 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $0D $18 $80 $0B $19 $0A $00 $00 $0D $00 $19 $00 $00 $00 $0F $16 $80 $08 $14 $00 $00 $00 $0F $00 $14 $00 $00 $14 $0D $00 $80 $0B $19 $0F $00 $00 $00 $00 $00 $0D $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $14 $11 $0C $80 $0B $19 $14 $0F $19 $16 $11 $19 $00 $14 $19
DATA_31565_19: .db $80 $05 $12 $80 $07 $0D $80 $08 $14 $00 $00 $00 $12 $0D $14 $00 $0D $14 $11 $0D $80 $0B $19 $12 $0C $00 $00 $00 $00 $11 $0D $00 $12 $00 $80 $08 $14 $00 $0A $00 $12 $00 $14 $00 $0A $00 $11 $0D $80 $0B $19 $12 $00 $00 $00 $11 $19 $11 $00 $00 $14 $0F $80 $08 $14 $00 $00 $00 $14 $0F $14 $00 $0F $14 $12 $11 $80 $0B $19 $14 $0F $00 $00 $00 $00 $12 $16 $00 $14 $00 $80 $08 $14 $00 $14 $00 $14 $00 $14 $00 $12 $00 $12 $00 $80 $0B $19 $14 $11 $00 $00 $0F $19 $12 $0D $19 $12 $0D $80 $08 $14 $00 $00 $00 $12 $0D $14 $00 $0C $14 $11 $0D $80 $0B $19 $12 $0F $00 $00 $11 $00 $11 $16 $00 $12 $00 $80 $08 $14 $00 $14 $00 $12 $12 $14 $00 $0D $00 $11 $00 $80 $0B $19 $12 $00 $00 $00 $00 $19 $11 $00 $00 $0F $18 $80 $08 $14 $00 $14 $00 $0F $18 $14 $00 $14 $14 $0D $18 $80 $0B $19 $0F $14 $00 $00 $18 $00 $0D $14 $00 $08 $12 $80 $08 $14 $00 $14 $00 $08 $16 $14 $00 $0F $14 $06 $00 $80 $0B $19 $08 $00 $19 $00 $00 $19 $08 $00 $19
DATA_31565_20: .db $80 $05 $12 $80 $07 $0D $80 $08 $14 $00 $00 $00 $12 $0D $14 $00 $0C $14 $11 $0D $80 $0B $19 $12 $0C $00 $00 $00 $00 $11 $0D $00 $12 $00 $80 $08 $14 $00 $0A $00 $12 $00 $14 $00 $0D $00 $11 $00 $80 $0B $19 $12 $0F $00 $00 $11 $19 $11 $00 $00 $14 $0F $80 $08 $14 $00 $00 $00 $14 $0F $14 $00 $0D $14 $12 $0F $80 $0B $19 $14 $0D $00 $00 $00 $00 $12 $11 $00 $14 $00 $80 $08 $14 $00 $0F $00 $14 $00 $14 $00 $0D $00 $12 $00 $80 $0B $19 $14 $0C $19 $00 $0A $19 $12 $00 $19 $12 $0D $80 $08 $14 $00 $00 $00 $12 $0D $14 $00 $0F $14 $11 $11 $80 $0B $19 $12 $0F $00 $00 $00 $00 $11 $16 $00 $12 $00 $80 $08 $14 $00 $14 $00 $12 $12 $14 $00 $0D $00 $11 $00 $80 $0B $19 $12 $00 $00 $00 $00 $19 $11 $00 $00 $0F $0F $19 $00 $11 $80 $08 $14 $0F $12 $80 $0B $19 $00 $14 $00 $0D $16 $19 $0F $14 $80 $08 $14 $00 $16 $80 $0B $19 $0D $19 $00 $08 $18 $19 $00 $16 $80 $08 $14 $08 $14 $14 $00 $0F $80 $0B $19 $06 $00 $80 $08 $14 $08 $00 $14 $00 $00 $80 $0B $19 $08 $00 $80 $08 $14
DATA_31565_21: .db $80 $05 $0A $80 $0C $0A $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $00 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $19 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $00 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $19 $00 $00 $19 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $00 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $19 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $19 $0A $00 $19 $00 $00 $19
DATA_31565_22: .db $80 $05 $0A $80 $0C $14 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $13 $14 $00 $00 $00 $0A $0F $80 $0B $19 $00 $00 $00 $0A $11 $19 $00 $0F $00 $0A $11 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $00 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $19 $00 $00 $19 $0A $14 $80 $08 $14 $00 $00 $00 $0A $13 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $0F $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $11 $14 $00 $00 $00 $0A $00 $80 $0B $19 $00 $00 $00 $0A $16 $19 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $11 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $86 $08 $00 $14 $00 $86 $08 $00 $14 $0A $86 $08 $00 $80 $0B $19 $00 $86 $08 $00 $19 $0A $86 $08 $00 $19 $00 $86 $08 $00 $19
DATA_31565_23: .db $80 $05 $0A $80 $0C $14 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $13 $14 $00 $00 $00 $0A $0F $80 $0B $19 $00 $00 $00 $0A $11 $19 $00 $0F $00 $0A $11 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0A $00 $14 $00 $00 $00 $0A $00 $80 $0B $19 $00 $00 $19 $0A $00 $19 $00 $00 $19 $14 $16 $80 $08 $14 $00 $00 $00 $14 $16 $14 $00 $00 $14 $14 $11 $80 $0B $19 $00 $00 $00 $13 $14 $00 $00 $00 $00 $13 $00 $80 $08 $14 $00 $00 $00 $13 $13 $14 $00 $00 $00 $14 $14 $80 $0B $19 $00 $00 $00 $14 $1A $19 $00 $00 $00 $0A $00 $19 $00 $00 $80 $08 $14 $0A $16 $80 $0B $19 $00 $00 $00 $0A $00 $19 $00 $00 $80 $08 $14 $0A $00 $80 $0B $19 $00 $00 $00 $0A $00 $19 $00 $00 $80 $08 $14 $0A $86 $08 $00 $14 $00 $86 $08 $00 $80 $0B $19 $0A $86 $08 $00 $80 $08 $14 $00 $86 $08 $00 $14 $0A $86 $08 $00 $80 $0B $19 $00 $86 $08 $00 $80 $08 $14
DATA_31565_24: .db $80 $05 $11 $80 $04 $22 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $14 $11 $22 $80 $0B $19 $00 $00 $00 $11 $20 $00 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $00 $11 $20 $80 $0B $19 $00 $00 $00 $11 $1D $19 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $14 $11 $00 $80 $0B $19 $00 $00 $00 $11 $00 $00 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $00 $11 $00 $80 $0B $19 $00 $00 $19 $11 $00 $19 $00 $00 $19 $11 $22 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $14 $11 $22 $80 $0B $19 $00 $00 $00 $11 $20 $00 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $00 $11 $20 $80 $0B $19 $00 $00 $00 $11 $1B $19 $00 $00 $00 $11 $00 $19 $00 $00 $19 $12 $00 $80 $08 $14 $00 $00 $80 $0B $19 $13 $00 $19 $00 $00 $80 $08 $14 $14 $00 $80 $0B $19 $00 $00 $19 $15 $00 $80 $08 $14 $00 $00 $80 $0B $19 $16 $00 $19 $00 $00 $80 $08 $14 $17 $00 $80 $0B $19 $00 $00 $00 $18 $00 $19 $84 $18 $00 $00 $00
DATA_31565_25: .db $80 $05 $11 $80 $04 $22 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $14 $11 $22 $80 $0B $19 $00 $00 $00 $11 $20 $00 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $00 $11 $20 $80 $0B $19 $00 $00 $00 $11 $1D $19 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $14 $11 $00 $80 $0B $19 $00 $00 $00 $11 $00 $00 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $00 $11 $00 $80 $0B $19 $00 $00 $00 $11 $00 $19 $00 $00 $19 $11 $22 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $14 $11 $22 $80 $0B $19 $00 $00 $00 $11 $20 $00 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $22 $14 $00 $00 $00 $11 $20 $80 $0B $19 $00 $00 $00 $11 $1B $19 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $14 $11 $00 $80 $0B $19 $00 $00 $00 $11 $00 $00 $00 $00 $00 $11 $00 $80 $08 $14 $00 $00 $00 $11 $00 $14 $00 $00 $14 $11 $00 $80 $0B $19 $00 $00 $19 $11 $00 $19 $00 $00 $19
DATA_31565_26: .db $82 $00 $00 $80 $04 $81 $05 $14 $82 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $16 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $16 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $80 $0D $11 $00 $00 $00 $00 $00 $80 $04 $0F $00 $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
DATA_31565_27: .db $80 $05 $08 $80 $04 $14 $00 $00 $00 $00 $08 $00 $00 $00 $00 $00 $08 $14 $00 $00 $00 $00 $08 $14 $00 $00 $00 $00 $08 $16 $00 $00 $00 $00 $08 $14 $00 $00 $00 $00 $08 $00 $00 $00 $00 $00 $08 $00 $00 $00 $00 $00 $0D $0D $00 $00 $00 $00 $0D $0D $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0F $0F $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $00 $14 $14 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $14 $14 $00 $00 $00 $00 $14 $14 $00 $00 $00 $00 $14 $16 $00 $00 $00 $00 $14 $14 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $14 $0D $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0D $0D $00 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0F $80 $0D $11 $00 $00 $00 $00 $0F $80 $04 $0F $80 $0B $19 $00 $00 $80 $08 $14 $0D $0D $14 $00 $00 $14 $0D $00 $80 $0B $19 $00 $00 $80 $08 $14 $0D $00 $14 $00 $00 $14
DATA_31565_28: .db $80 $05 $08 $80 $04 $14 $80 $08 $14 $00 $00 $00 $08 $00 $14 $00 $00 $00 $08 $14 $80 $0B $19 $00 $00 $00 $08 $14 $80 $08 $14 $00 $00 $00 $08 $16 $14 $00 $00 $00 $08 $14 $14 $00 $00 $00 $08 $00 $80 $0B $19 $00 $00 $00 $08 $00 $80 $08 $14 $00 $00 $00 $0D $0D $14 $00 $00 $00 $0D $0D $14 $00 $00 $00 $0D $00 $80 $0B $19 $00 $00 $00 $0F $0F $80 $08 $14 $00 $00 $00 $0F $00 $14 $00 $00 $00 $0F $00 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $00 $0F $00 $19 $00 $00 $19 $14 $14 $80 $08 $14 $00 $00 $00 $14 $00 $14 $00 $00 $00 $14 $14 $80 $0B $19 $00 $00 $00 $14 $14 $80 $08 $14 $00 $00 $00 $14 $16 $14 $00 $00 $00 $14 $14 $14 $00 $00 $00 $14 $00 $80 $0B $19 $00 $00 $00 $14 $0D $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $0D $0D $14 $00 $00 $00 $0D $00 $80 $0B $19 $00 $00 $00 $0F $80 $0D $11 $80 $08 $14 $00 $00 $00 $0F $80 $04 $0F $14 $00 $00 $00 $0D $0D $14 $00 $00 $00 $0D $00 $80 $0B $19 $00 $00 $19 $0D $00 $19 $00 $00 $19
DATA_31565_29: .db $80 $05 $0D $80 $04 $19 $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $19 $00 $0D $1B $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $0C $00 $80 $0B $19 $00 $00 $00 $0D $80 $0D $1D $00 $00 $00 $00 $0D $00 $19 $00 $00 $00 $0D $1D $80 $08 $14 $00 $00 $00 $0D $80 $04 $1B $80 $0B $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $19 $80 $0B $19 $00 $00 $19 $0C $18 $00 $00 $00 $19 $0D $19 $19 $00 $00 $00 $0F $1B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $1B $00 $00 $00 $00 $0F $20 $80 $0B $19 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $14 $20 $14 $00 $00 $00 $14 $20 $80 $0B $19 $00 $00 $00 $0F $1B $00 $00 $00 $00 $0F $00 $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $19 $0D $19 $80 $08 $14 $00 $00 $14 $0C $18 $80 $0B $19 $00 $00 $19 $0C $19 $80 $08 $14 $00 $00 $14
DATA_31565_30: .db $80 $05 $0D $80 $04 $19 $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $19 $00 $0D $1B $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $0C $00 $80 $0B $19 $00 $00 $00 $0D $80 $0D $1D $00 $00 $00 $00 $0D $00 $19 $00 $00 $00 $0D $1D $80 $08 $14 $00 $00 $00 $0D $80 $04 $1B $80 $0B $19 $00 $00 $00 $0D $00 $80 $08 $14 $00 $00 $00 $0D $19 $80 $0B $19 $00 $00 $19 $0C $18 $00 $00 $00 $19 $0D $19 $19 $00 $00 $00 $0F $1B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $1B $00 $00 $00 $00 $0F $20 $80 $0B $19 $00 $00 $00 $0F $00 $00 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $14 $20 $14 $00 $00 $00 $14 $20 $80 $0B $19 $00 $00 $00 $0F $1B $00 $00 $00 $00 $0F $00 $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $00 $0F $00 $80 $08 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $19 $0D $19 $80 $08 $14 $00 $00 $14 $0C $18 $80 $0B $19 $00 $00 $19 $0C $19 $80 $08 $14 $84 $27 $00 $00 $14
DATA_31565_31: .db $80 $05 $0B $82 $00 $00 $80 $08 $14 $00 $00 $00 $0B $00 $00 $00 $00 $00 $0B $00 $80 $0B $19 $00 $00 $00 $0E $00 $00 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $00 $0B $00 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $19 $00 $00 $00 $00 $80 $0C $12 $80 $08 $14 $00 $00 $00 $00 $10 $80 $0B $19 $00 $00 $00 $00 $0E $80 $08 $14 $00 $00 $00 $00 $10 $80 $0B $19 $00 $00 $19 $00 $85 $04 $0E $00 $00 $86 $08 $00 $19 $00 $85 $08 $00 $19 $00 $86 $08 $00 $00 $00 $85 $08 $00 $19 $00 $86 $08 $00 $00 $0E $82 $00 $00 $80 $08 $14 $00 $00 $00 $0E $00 $00 $00 $00 $00 $0B $00 $80 $0B $19 $00 $00 $00 $0E $00 $00 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $00 $10 $00 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $19 $00 $00 $00 $00 $17 $80 $08 $14 $00 $00 $00 $00 $15 $80 $0B $19 $00 $00 $00 $00 $17 $80 $08 $14 $00 $00 $00 $00 $15 $80 $0B $19 $00 $00 $19 $00 $17 $80 $08 $14 $00 $15 $14 $00 $12 $80 $0B $19 $00 $10 $19 $00 $0E $80 $08 $14 $00 $0B $14
DATA_31565_32: .db $82 $00 $00 $82 $00 $00 $00 $84 $2B $00 $00 $00
DATA_31565_33: .db $80 $05 $81 $05 $0A $80 $02 $0A $80 $08 $14 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0D $0D $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0F $0F $80 $08 $14 $00 $00 $00 $0F $00 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $00 $0A $0A $00 $00 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0D $0D $00 $00 $00 $00 $0D $00 $80 $0B $19 $00 $00 $00 $10 $10 $80 $08 $14 $00 $00 $00 $0F $0F $00 $00 $00 $00 $0F $00 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $19 $0F $00 $00 $00 $00 $19 $0A $0A $80 $08 $14 $00 $00 $00 $0A $00 $00 $00 $00 $00 $0D $0D $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $0F $0F $80 $08 $14 $00 $00 $00 $0F $00 $14 $00 $00 $00 $0D $00 $80 $0B $19 $00 $00 $00 $10 $10 $00 $00 $00 $00 $10 $00 $19 $00 $00 $00 $0F $0F $80 $08 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $00 $0D $0D $80 $08 $14 $00 $00 $00 $0A $0A $80 $0B $19 $00 $00 $19 $00 $00 $80 $08 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $19 $84 $2B $00 $00 $00
DATA_31565_34: .db $80 $05 $81 $05 $0D $80 $02 $0D $80 $08 $14 $00 $00 $00 $0D $0D $00 $00 $00 $00 $0D $10 $80 $0B $19 $00 $0D $00 $0D $00 $00 $00 $0B $00 $10 $10 $80 $08 $14 $00 $00 $00 $10 $10 $14 $00 $00 $00 $10 $14 $80 $0B $19 $00 $10 $00 $10 $00 $00 $00 $0F $00 $12 $12 $80 $08 $14 $00 $00 $00 $12 $12 $00 $00 $00 $00 $12 $15 $80 $0B $19 $00 $12 $00 $12 $00 $80 $08 $14 $00 $10 $00 $09 $09 $00 $00 $00 $00 $09 $09 $14 $00 $00 $00 $09 $0D $80 $0B $19 $00 $09 $19 $09 $00 $00 $00 $08 $19 $0D $0D $80 $08 $14 $00 $00 $00 $0D $0D $00 $00 $00 $00 $0D $10 $80 $0B $19 $00 $0D $00 $0D $00 $00 $00 $0B $00 $10 $10 $80 $08 $14 $00 $00 $00 $10 $10 $14 $00 $00 $00 $10 $14 $80 $0B $19 $00 $10 $00 $10 $00 $00 $00 $0F $00 $12 $12 $19 $00 $00 $00 $12 $12 $80 $08 $14 $00 $00 $00 $12 $15 $80 $0B $19 $00 $12 $00 $12 $00 $80 $08 $14 $00 $17 $00 $19 $19 $80 $0B $19 $00 $00 $19 $19 $19 $80 $08 $14 $19 $00 $00 $19 $19 $80 $0B $19 $00 $00 $00 $00 $00 $19 $84 $2B $00 $00 $00
DATA_31565_35: .db $80 $05 $81 $06 $0A $80 $02 $11 $80 $08 $14 $00 $00 $00 $0A $11 $14 $00 $00 $14 $08 $0F $80 $0B $19 $0A $00 $00 $00 $00 $00 $08 $00 $00 $0A $11 $80 $08 $14 $00 $00 $00 $0A $11 $14 $00 $00 $00 $0A $14 $80 $0B $19 $08 $00 $00 $0A $00 $19 $00 $00 $00 $0F $16 $80 $08 $14 $00 $00 $00 $0F $16 $14 $00 $00 $14 $0D $14 $80 $0B $19 $0F $00 $00 $00 $00 $00 $0D $00 $00 $0F $16 $80 $08 $14 $00 $00 $00 $0D $16 $14 $00 $00 $00 $08 $19 $80 $0B $19 $06 $00 $00 $08 $00 $19 $00 $00 $19 $0A $11 $80 $08 $14 $00 $00 $00 $0A $11 $14 $00 $13 $14 $08 $14 $80 $0B $19 $0A $13 $00 $00 $0F $00 $08 $00 $00 $0A $00 $80 $08 $14 $00 $00 $00 $0D $16 $14 $00 $14 $00 $0D $16 $80 $0B $19 $0A $18 $00 $0D $19 $19 $00 $18 $00 $0F $16 $80 $08 $14 $00 $14 $00 $0F $16 $14 $00 $00 $14 $0D $00 $80 $0B $19 $0F $00 $00 $00 $1D $00 $0D $1B $00 $11 $1D $80 $08 $14 $00 $20 $00 $11 $1D $14 $00 $1B $14 $11 $1D $80 $0B $19 $14 $00 $19 $16 $00 $19 $00 $00 $19
DATA_31565_36: .db $80 $05 $81 $06 $06 $80 $02 $12 $80 $08 $14 $00 $00 $00 $06 $00 $00 $00 $12 $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $12 $00 $00 $00 $00 $06 $11 $80 $08 $14 $00 $00 $00 $06 $00 $14 $00 $0F $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $0D $00 $00 $00 $00 $08 $80 $04 $14 $80 $08 $14 $00 $00 $00 $08 $00 $00 $00 $00 $00 $14 $00 $80 $0B $19 $00 $00 $00 $08 $00 $80 $08 $14 $00 $00 $00 $08 $00 $00 $00 $00 $00 $08 $00 $14 $00 $00 $00 $14 $80 $02 $0D $80 $0B $19 $00 $0F $00 $08 $11 $19 $00 $12 $19 $06 $16 $80 $08 $14 $00 $00 $00 $06 $00 $00 $00 $16 $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $16 $00 $00 $00 $00 $06 $14 $80 $08 $14 $00 $00 $00 $06 $00 $14 $00 $12 $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $11 $00 $00 $00 $00 $03 $80 $04 $0F $80 $08 $14 $00 $00 $00 $03 $00 $00 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $00 $03 $00 $80 $08 $14 $00 $00 $00 $03 $00 $00 $00 $00 $00 $03 $00 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $19 $03 $00 $19 $00 $00 $19
DATA_31565_37: .db $80 $05 $81 $06 $06 $80 $02 $12 $80 $08 $14 $00 $00 $00 $06 $00 $00 $00 $12 $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $12 $00 $00 $00 $00 $06 $11 $80 $08 $14 $00 $00 $00 $06 $00 $14 $00 $0F $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $0D $00 $00 $00 $00 $08 $80 $04 $14 $80 $08 $14 $00 $00 $00 $08 $00 $00 $00 $00 $00 $14 $00 $80 $0B $19 $00 $00 $00 $08 $00 $80 $08 $14 $00 $00 $00 $08 $00 $00 $00 $00 $00 $08 $00 $14 $00 $00 $00 $14 $80 $02 $0D $80 $0B $19 $00 $0F $19 $08 $11 $00 $00 $12 $19 $06 $16 $80 $08 $14 $00 $00 $00 $06 $00 $00 $00 $16 $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $16 $00 $00 $00 $00 $06 $14 $80 $08 $14 $00 $00 $00 $06 $00 $14 $00 $12 $00 $12 $00 $80 $0B $19 $00 $00 $00 $06 $11 $00 $00 $00 $00 $03 $80 $04 $0F $19 $00 $00 $00 $03 $00 $80 $08 $14 $00 $00 $00 $0F $00 $80 $0B $19 $00 $00 $00 $03 $00 $80 $08 $14 $00 $00 $00 $03 $00 $80 $0B $19 $00 $00 $19 $03 $00 $80 $08 $14 $00 $00 $14 $0F $00 $80 $0B $19 $00 $00 $19 $03 $00 $80 $08 $14 $84 $2F $00 $00 $14
DATA_31565_38: .db $80 $05 $81 $07 $0D $80 $02 $19 $80 $08 $14 $00 $00 $00 $0D $14 $00 $00 $00 $00 $19 $19 $80 $0B $19 $00 $00 $00 $0D $1B $00 $00 $00 $00 $10 $1C $80 $08 $14 $00 $00 $00 $10 $1B $14 $00 $00 $00 $1C $19 $80 $0B $19 $00 $00 $00 $10 $17 $00 $00 $00 $00 $12 $17 $80 $08 $14 $00 $19 $00 $12 $1E $00 $00 $17 $00 $1E $19 $80 $0B $19 $00 $1E $00 $12 $17 $80 $08 $14 $00 $19 $00 $12 $1E $00 $00 $17 $00 $12 $19 $14 $00 $1E $00 $1E $17 $80 $0B $19 $00 $19 $19 $12 $1E $00 $00 $00 $19 $0D $19 $80 $08 $14 $00 $00 $00 $0D $14 $00 $00 $00 $00 $19 $19 $80 $0B $19 $00 $00 $00 $0D $1B $00 $00 $00 $00 $10 $1C $80 $08 $14 $00 $00 $00 $10 $1B $14 $00 $00 $00 $1C $19 $80 $0B $19 $00 $00 $00 $10 $17 $00 $00 $00 $00 $06 $17 $19 $00 $16 $00 $06 $12 $80 $08 $14 $00 $17 $00 $12 $16 $80 $0B $19 $00 $12 $00 $06 $17 $80 $08 $14 $00 $16 $00 $06 $12 $80 $0B $19 $00 $17 $19 $06 $16 $80 $08 $14 $00 $12 $00 $12 $17 $80 $0B $19 $00 $16 $00 $06 $12 $19 $84 $2B $00 $00 $00
DATA_31565_39: .db $80 $05 $81 $07 $14 $80 $07 $1B $80 $08 $14 $14 $17 $00 $00 $14 $00 $12 $1A $00 $12 $17 $80 $0B $19 $00 $14 $00 $14 $19 $00 $14 $17 $00 $00 $14 $80 $08 $14 $17 $12 $00 $17 $14 $14 $00 $00 $00 $19 $19 $80 $0B $19 $00 $00 $00 $17 $17 $00 $00 $00 $00 $19 $0D $80 $08 $14 $19 $0D $00 $00 $00 $00 $17 $12 $00 $17 $12 $80 $0B $19 $00 $00 $00 $14 $14 $80 $08 $14 $00 $00 $00 $12 $00 $00 $14 $00 $00 $14 $20 $14 $00 $00 $00 $14 $20 $80 $0B $19 $00 $00 $19 $00 $00 $00 $00 $00 $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $84 $2B $00 $00 $00
DATA_31565_40: .db $80 $05 $81 $07 $12 $80 $07 $19 $80 $08 $14 $00 $00 $00 $12 $16 $00 $00 $00 $00 $12 $12 $80 $0B $19 $00 $00 $00 $12 $14 $00 $00 $00 $00 $0D $19 $80 $08 $14 $00 $00 $00 $0D $16 $14 $00 $00 $00 $0D $12 $80 $0B $19 $00 $00 $00 $0D $14 $00 $00 $00 $00 $0B $17 $80 $08 $14 $00 $00 $00 $0B $16 $00 $00 $00 $00 $0D $14 $80 $0B $19 $00 $00 $00 $0D $12 $80 $08 $14 $00 $00 $00 $12 $12 $00 $00 $00 $00 $00 $00 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $84 $2B $00 $00 $00
DATA_31565_41: .db $80 $05 $81 $05 $06 $80 $02 $12 $80 $08 $14 $00 $16 $00 $06 $19 $00 $00 $1B $00 $12 $12 $80 $0B $19 $00 $16 $00 $06 $19 $00 $00 $1B $00 $06 $12 $80 $08 $14 $00 $16 $00 $06 $19 $14 $00 $1B $00 $12 $12 $80 $0B $19 $00 $16 $00 $06 $19 $00 $00 $1B $00 $0B $12 $80 $08 $14 $00 $17 $00 $0B $19 $00 $00 $1C $00 $17 $12 $80 $0B $19 $00 $17 $00 $0B $19 $80 $08 $14 $00 $1C $00 $0B $12 $00 $00 $17 $00 $0B $19 $14 $00 $1C $00 $17 $12 $80 $0B $19 $00 $17 $19 $0B $19 $00 $00 $1C $19 $0D $1C $80 $08 $14 $00 $1B $00 $0D $19 $00 $00 $17 $00 $19 $1C $80 $0B $19 $00 $1B $00 $0D $19 $00 $00 $17 $00 $0B $1C $80 $08 $14 $00 $1B $00 $0B $19 $14 $00 $17 $00 $17 $1C $80 $0B $19 $00 $1B $00 $0B $19 $00 $00 $17 $00 $12 $19 $19 $00 $00 $00 $00 $00 $80 $08 $14 $00 $00 $00 $12 $1E $80 $0B $19 $00 $00 $00 $12 $1E $80 $08 $14 $12 $1E $00 $12 $1E $80 $0B $19 $00 $00 $19 $00 $00 $80 $08 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $19 $84 $2B $00 $00 $00
DATA_31565_42: .db $80 $05 $81 $05 $0D $80 $0C $14 $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $16 $00 $00 $00 $00 $0D $14 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $06 $12 $80 $08 $14 $00 $00 $00 $06 $11 $00 $00 $00 $00 $12 $0F $80 $0B $19 $00 $00 $00 $06 $0D $80 $08 $14 $00 $00 $00 $08 $14 $00 $00 $00 $00 $08 $00 $14 $00 $00 $00 $14 $00 $80 $0B $19 $00 $00 $19 $08 $00 $00 $00 $00 $19 $0D $14 $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $16 $00 $00 $00 $00 $0D $14 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $06 $12 $19 $00 $00 $00 $06 $11 $80 $08 $14 $00 $00 $00 $12 $0F $80 $0B $19 $00 $00 $00 $06 $0D $80 $08 $14 $00 $00 $00 $08 $0F $80 $0B $19 $00 $00 $19 $08 $00 $80 $08 $14 $00 $00 $00 $14 $00 $80 $0B $19 $00 $00 $00 $08 $00 $19 $00 $00 $00
DATA_31565_43: .db $80 $05 $81 $05 $0D $80 $0C $14 $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $16 $00 $00 $00 $00 $0D $14 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $06 $12 $80 $08 $14 $00 $00 $00 $06 $11 $00 $00 $00 $00 $12 $0F $80 $0B $19 $00 $00 $00 $06 $0D $80 $08 $14 $00 $00 $00 $08 $14 $00 $00 $00 $00 $08 $00 $14 $00 $00 $00 $14 $00 $80 $0B $19 $00 $00 $19 $08 $00 $00 $00 $00 $19 $0D $14 $80 $08 $14 $00 $00 $00 $0D $00 $00 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $16 $00 $00 $00 $00 $0D $14 $80 $08 $14 $00 $00 $00 $0D $00 $14 $00 $00 $00 $19 $11 $80 $0B $19 $00 $00 $00 $0D $00 $00 $00 $00 $00 $06 $12 $19 $00 $00 $00 $06 $11 $80 $08 $14 $00 $00 $00 $12 $0F $80 $0B $19 $00 $00 $00 $06 $0D $80 $08 $14 $00 $00 $00 $0D $19 $80 $0B $19 $00 $00 $19 $00 $00 $80 $08 $14 $00 $00 $00 $00 $00 $80 $0B $19 $00 $00 $00 $00 $00 $19 $84 $2B $00 $00 $00

; Sprite handling code...
LABEL_33AE9_:
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld c, a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_D5A7_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (iy+$00)
  sub c ; subtract
  ld (iy+$00), a
  jp ++
+:ld a, (iy+$00)
  add a, c ; add
  ld (iy+$00), a
++:
  cp $f8
  jr nc, LABEL_33B35_
  call LABEL_33BEF_
LABEL_33B25_:
  ld a, (_RAM_D5A6_)
  inc a
  ld (_RAM_D5A6_), a
  cp $25
  jr nz, ++
  ld a, SFX_04_TankMiss
  ld (_RAM_D963_SFXTrigger_Player1), a
LABEL_33B35_:
  xor a
  ld (_RAM_D5A6_), a
  ld (ix+$00), a
  ld (iy+$00), a
  ld (ix+$02), a
  ld (iy+$01), a
  ret
++:
  jp LABEL_33F92_

LABEL_44B49_:
  sub $1a
  ld e, a
  ld d, $00
  ld hl, DATA_33B5E_
  add hl, de
  ld a, (hl)
  ld (ix+$01), a
  ld a, $ac
  ld (ix+$03), a
  jp LABEL_33B25_

DATA_33B5E_:
.db $A0 $A0 $A0 $A1 $A1 $A1 $A2 $A2 $A2 $A3 $A3 $A3 $AC

  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, ++
  ld a, (_RAM_D5AB_)
  cp $a0
  JrNzRet _LABEL_33BEE_ret
+: ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK | BUTTON_2_MASK ; Both buttons pressed
  JrNzRet _LABEL_33BEE_ret
++: ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_33BEE_ret
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_33BEE_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_33BEE_ret
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_D5A7_), a
  ld a, (_RAM_DE92_EngineVelocity)
  add a, $06
  and $0f
  ld (_RAM_D5A8_), a
  ld a, $01
  ld (_RAM_D5A6_), a
  ld a, SFX_0A_TankShoot
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld ix, _RAM_DA60_SpriteTableXNs.57.x
  ld iy, _RAM_DAE0_SpriteTableYs.57
  ld (ix+$01), <SpriteIndex_Bullet
  ld (ix+$03), <SpriteIndex_BulletShadow
  ld hl, DATA_33C0A_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA4_)
  add a, l
  ld (ix+$00), a
  ld hl, DATA_33C1A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA5_)
  add a, l
  ld (iy+$00), a
_LABEL_33BEE_ret:
  ret

LABEL_33BEF_:
  ld a, (_RAM_D5A6_)
  ld e, a
  ld d, $00
  ld hl, DATA_33C2A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+$00)
  add a, l
  ld (ix+$02), a
  ld a, (iy+$00)
  add a, l
  ld (iy+$01), a
  ret

DATA_33C0A_:
.db $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03 $00 $03 $05 $08
DATA_33C1A_:
.db $00 $03 $05 $08 $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03
DATA_33C2A_:
.db $00 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $0F $0E $0D $0C $0B $0A $09 $08 $07 $06 $05 $04 $03 $02 $01 $00

  ld ix, _RAM_DCAB_CarData_Green
  ld iy, _RAM_DA60_SpriteTableXNs.59.x
  jr ++
  ld ix, _RAM_DCEC_CarData_Blue
  ld iy, _RAM_DA60_SpriteTableXNs.61.x
  jr ++
  ld a, (_RAM_D5AB_)
  cp $a0
  jr z, +
  inc a
  ld (_RAM_D5AB_), a
  ret
+:ld ix, _RAM_DD2D_CarData_Yellow
  ld iy, _RAM_DA60_SpriteTableXNs.63.x
++:
  ld a, (ix+$3f)
  or a
  jp z, LABEL_34D9C_
  cp $1a
  jp nc, LABEL_34D87_
  ; e = DATA_1D65__Lo[ix+$40]
  ld hl, DATA_1D65__Lo
  ld a, (ix+$40)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ; d = DATA_1D76__Hi[ix+$40]
  ld hl, DATA_1D76__Hi
  ld a, (ix+$40)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ; a = DATA_3FC3_[ix+$3e] (one of 0, 6, 12, 18, 24)
  ld hl, DATA_3FC3_
  ld a, (ix+$3e)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ; c = _RAM_DEAD_[a]
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld c, a
  ; Read DATA_40E5_Sign_[ix+$3e] and add or subtract c accordingly
  ld hl, DATA_40E5_Sign_
  ld a, (ix+$3e)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (iy+$00)
  sub c ; Subtract
  ld (iy+$00), a
  jr ++
+:; Add
  ld a, (iy+$00)
  add a, c
  ld (iy+$00), a
++:
  cp $f8
  jr nc, LABEL_33D49_ ; Offscreen?
  ld (_RAM_D5A9_), iy

  ; Selects which sprite to move
  ld a, (ix+$2d)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  jr +++
+:
  ld iy, _RAM_DAE0_SpriteTableYs.61
  jr +++
++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
+++:
  ; Similar to previous phase...
  ld hl, DATA_3FD3_
  ld a, (ix+$3e)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld c, a
  ld hl, DATA_40F5_Sign_
  ld a, (ix+$3e)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (iy+$00)
  sub c
  ld (iy+$00), a
  jr ++
+:ld a, (iy+$00)
  add a, c
  ld (iy+$00), a
++:
  cp $f8
  jr nc, LABEL_33D49_
  call LABEL_33E62_
LABEL_33D33:
  ld a, (ix+$3f)
  inc a
  ld (ix+$3f), a
  cp $25
  jr nz, LABEL_34D84_
  ld a, (ix+$15)
  or a
  jr z, LABEL_33D49_
  ld a, SFX_04_TankMiss
  ld (_RAM_D974_SFXTrigger_Player2), a
LABEL_33D49_:
  xor a
  ld (ix+$3f), a
  ld a, (ix+$2d)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  ld ix, _RAM_DA60_SpriteTableXNs.59.x
  jp +++
+:
  ld iy, _RAM_DAE0_SpriteTableYs.61
  ld ix, _RAM_DA60_SpriteTableXNs.61.x
  jp +++
++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
  ld ix, _RAM_DA60_SpriteTableXNs.63.x
+++:
  xor a
  ld (ix+$00), a
  ld (ix+$02), a
  ld (iy+$00), a
  ld (iy+$01), a
  ret
LABEL_34D84_:
  jp LABEL_33E81_
LABEL_34D87_:
  sub $1a
  ld e, a
  ld d, $00
  ld hl, DATA_33B5E_
  add hl, de
  ld a, (hl)
  ld (iy+$01), a
  ld a, $ac
  ld (iy+$03), a
  jp LABEL_33D33

LABEL_34D9C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
++:
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_1_MASK | BUTTON_2_MASK ; Both buttons pressed
  JpNzRet _LABEL_33E61_ret
+:ld a, (_RAM_DE4F_)
  cp $80
  JpNzRet _LABEL_33E61_ret
  ld a, (ix+$15)
  or a
  JpZRet _LABEL_33E61_ret
  ld a, (ix+$2e)
  or a
  JpNzRet _LABEL_33E61_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_33DF4_
  ld a, (ix+$11)
  cp $e0
  JpNcRet _LABEL_33E61_ret
  cp $20
  JpCRet _LABEL_33E61_ret
  ld a, (ix+$12)
  cp $20
  JpCRet _LABEL_33E61_ret
  cp $e0
  JpNcRet _LABEL_33E61_ret
  jr +
LABEL_33DF4_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_33E61_ret
+:ld a, (ix+$0d)
  ld (ix+$3e), a
  ld a, (ix+$0b)
  add a, $06
  and $0f
  ld (ix+$40), a
  ld a, $01
  ld (ix+$3f), a
  ld a, (ix+$15)
  or a
  jr z, +
  ld a, SFX_0A_TankShoot
  ld (_RAM_D974_SFXTrigger_Player2), a
+:ld (iy+$01), $ad
  ld (iy+$03), $ae
  ld hl, DATA_33C0A_
  ld a, (ix+$0d)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+$11)
  add a, l
  ld (iy+$00), a
  ld (_RAM_D5A9_), iy
  ld a, (ix+$2d)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  jr +++
+:ld iy, _RAM_DAE0_SpriteTableYs.61
  jr +++
++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
+++:
  ld hl, DATA_33C1A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+$12)
  add a, l
  ld (iy+$00), a
_LABEL_33E61_ret:
  ret
LABEL_33E62_:
  ld a, (ix+$3f)
  ld e, a
  ld d, $00
  ld hl, DATA_33C2A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (iy+$00)
  add a, l
  ld (iy+$01), a
  ld iy, (_RAM_D5A9_)
  ld a, (iy+$00)
  add a, l
  ld (iy+$02), a
  ret
LABEL_33E81_:
  ld a, (ix+$2d)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_33F11_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_33F11_
  ld de, _RAM_DA60_SpriteTableXNs.59.x
  ld bc, _RAM_DAE0_SpriteTableYs.59
  jp +++
+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_33F3A_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_33F3A_
  ld de, _RAM_DA60_SpriteTableXNs.61.x
  ld bc, _RAM_DAE0_SpriteTableYs.61
  jp +++
++:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_33F69_
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_33F69_
  ld de, _RAM_DA60_SpriteTableXNs.63.x
  ld bc, _RAM_DAE0_SpriteTableYs.63
+++:
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_33F10_ret
  ld a, (_RAM_DBA4_)
  ld l, a
  ld a, (de)
  sub l
  JrCRet _LABEL_33F10_ret
  cp $18
  JrNcRet _LABEL_33F10_ret
  ld a, (_RAM_DBA5_)
  ld l, a
  ld a, (bc)
  sub l
  JrCRet _LABEL_33F10_ret
  cp $18
  JrNcRet _LABEL_33F10_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  call ++
  ld a, $01
  ld (_RAM_D5BD_), a
  jp LABEL_29BC_Behaviour1_FallToFloor
+:
  call LABEL_2934_BehaviourF
++:
  xor a
  ld (_RAM_DD2B_), a
  ld (_RAM_DA60_SpriteTableXNs.61.x), a
  ld (_RAM_DAE0_SpriteTableYs.61), a
  ld (_RAM_DA60_SpriteTableXNs.62.x), a
  ld (_RAM_DAE0_SpriteTableYs.62), a
_LABEL_33F10_ret:
  ret

LABEL_33F11_:
  ld a, (ix+$15)
  or a
  JrZRet _LABEL_33F39_ret
  ld a, (ix+$11)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.59.x)
  sub l
  JrCRet _LABEL_33F39_ret
  cp $18
  JrNcRet _LABEL_33F39_ret
  ld a, (ix+$12)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.59)
  sub l
  JrCRet _LABEL_33F39_ret
  cp $18
  JrNcRet _LABEL_33F39_ret
  call LABEL_2961_
  jp LABEL_33D49_
_LABEL_33F39_ret:
  ret

LABEL_33F3A_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet _LABEL_33F68_ret
  ld a, (ix+$15)
  or a
  JrZRet _LABEL_33F68_ret
  ld a, (ix+$11)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  sub l
  JrCRet _LABEL_33F68_ret
  cp $18
  JrNcRet _LABEL_33F68_ret
  ld a, (ix+$12)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.61)
  sub l
  JrCRet _LABEL_33F68_ret
  cp $18
  JrNcRet _LABEL_33F68_ret
  call LABEL_2961_
  jp LABEL_33D49_
_LABEL_33F68_ret:
  ret

LABEL_33F69_:
  ld a, (ix+$15)
  or a
  jr z, LABEL_33D91_
  ld a, (ix+$11)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  sub l
  jr c, LABEL_33D91_
  cp $18
  jr nc, LABEL_33D91_
  ld a, (ix+$12)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.63)
  sub l
  jr c, LABEL_33D91_
  cp $18
  jr nc, LABEL_33D91_
  call LABEL_2961_
  jp LABEL_33D49_
LABEL_33D91_:
  ret

LABEL_33F92_:
  ld ix, _RAM_DCEC_CarData_Blue
  call +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet _LABEL_33FF7_ret
  ld ix, _RAM_DCAB_CarData_Green
  call +
  ld ix, _RAM_DD2D_CarData_Yellow
+:
  ld a, (ix+$2e)
  or a
  JrNzRet _LABEL_33FF7_ret
  ld a, (ix+$15)
  or a
  JrZRet _LABEL_33FF7_ret
  ld a, (ix+$11)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.57.x)
  sub l
  JrCRet _LABEL_33FF7_ret
  cp $18
  JrNcRet _LABEL_33FF7_ret
  ld a, (ix+$12)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.57)
  sub l
  JrCRet _LABEL_33FF7_ret
  cp $18
  JrNcRet _LABEL_33FF7_ret
  ld a, (ix+$2d)
  cp $01
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  call LABEL_4DD4_
  jr ++
+:
  call LABEL_2961_
++:
  ld ix, _RAM_DA60_SpriteTableXNs.57.x
  ld iy, _RAM_DAE0_SpriteTableYs.57
  jp LABEL_33B35_
_LABEL_33FF7_ret:
  ret

.ifdef BLANK_FILL_ORIGINAL
.db $ff $00 $00 $ff $ff $00 $00
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 13
.ORG $0000
;.section "Bank 13"

DATA_34000_Helicopters_Tiles_BadReference: ; Helicopters tiles used to be in this bank (?)

DATA_34000_FormulaOne_Tiles:
.incbin "Assets/Formula One/Tiles.compressed" ; 3bpp bitplane separated
DATA_34958_CarTiles_Sportscars:
.incbin "Assets/Sportscars/Car.3bpp.runencoded"
.dsb 6, 0
DATA_34CF0_CarTiles_FourByFour:
.incbin "Assets/Four By Four/Car.3bpp.runencoded"
.dsb 1, 0
DATA_35048_CarTiles_Powerboats:
.incbin "Assets/Powerboats/Car.3bpp.runencoded"
.dsb 7, 0
DATA_35350_CarTiles_TurboWheels:
.incbin "Assets/Turbo Wheels/Car.3bpp.runencoded"
.dsb 1, 0

; 1bpp data to push the plughole into the upper 8 palette entries
DATA_35708_PlugholeTilesHighBitplanePart1:
; TODO: generate this from PNG
; Need to make an "ignore this colour" option?
.db $00 $00 $00 $00 $03 $0F $3F $FF $00 $00 $00 $3F $FF $FF $FF $FF
.db $01 $03 $07 $0F $1F $3F $3F $7F $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $7F $BF $BF $B7 $27 $46 $48 $48
.db $FF $FF $FF $FF $FF $DF $9F $AF $FF $FF $FF $FF $FF $FF $FF $FF
.db $AF $2F $2F $0F $0F $0F $0F $0F $FF $FF $FF $FF $FF $FF $FF $FF
.db $0F $07 $07 $07 $03 $03 $01 $00 $FF $FF $FF $FF $FF $FF $FF $FF
.db $7F $3F $0F $03 $01 $00 $00 $00

DATA_35770_PlugholeTilesHighBitplanePart2:
.db $00 $00 $00 $F0 $FC $FF $FF $FF $00 $00 $00 $00 $00 $80 $F0 $FC
.db $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF $FF $FF
.db $00 $00 $80 $C0 $E0 $F0 $F0 $F8 $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $F8 $FC $FE $FE $FE $FE $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FE $FE $FE $FC $FC $F8 $F8 $F0
.db $FF $FF $FF $FF $FF $7F $00 $00 $FF $FF $FF $FE $F8 $C0 $00 $00
.db $E0 $C0 $80 $00 $00 $00 $00 $00

LABEL_357F8_CarTilesToVRAM:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ; RuffTrux
  ; VRAM address 0, 256 tiles
  SetTileAddressImmediate 0
  ld bc, $0800 ; loop count - we consume 3x this much data to produce 256 tiles
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
-:push bc
    ld b, $03
    ld c, PORT_VDP_DATA
    otir          ; 3 bytes data
    EmitDataToVDPImmediate8 0 ; 1 byte padding
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

+:; Normal cars
  ld a, $00
  ld (_RAM_DF98_CarTileLoaderCounter), a
-:ld a, (_RAM_DF98_CarTileLoaderCounter)
  ld e, a
  ld d, $00
  ld hl, DATA_35868_CarTileLoaderCounterToTableLookup   ; Look up in a table
  add hl, de
  ld a, (hl)
  ld (_RAM_DB74_CarTileLoaderTableIndex), a    ; and store
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_35B4D_CarDrawingData   ; and index into another table
  add hl, de
  ld a, (hl)
  ld (_RAM_DB75_CarTileLoaderDataIndex), a    ; store data (4 bytes) to RAM
  inc hl
  ld a, (hl)
  ld (_RAM_DB76_CarTileLoaderPositionIndex), a
  inc hl
  ld a, (hl)
  ld (_RAM_DB79_CarTileLoaderHFlip), a
  inc hl
  ld a, (hl)
  ld (_RAM_DB7A_CarTileLoaderVFlip), a

  call _LoadOnePosition

  ld a, (_RAM_DF98_CarTileLoaderCounter)  ; Increment counter
  add a, $01
  ld (_RAM_DF98_CarTileLoaderCounter), a
  cp $0D
  call z, LABEL_35A3E_CarTileLoader_HFlipSwapData ; When we get to 13, we are in the realm of both h- and v-flipped tiles. The code doesn't support this properly so we munge the data here (!) so it works right.
  ld a, (_RAM_DF98_CarTileLoaderCounter)
  cp 16
  jr nz, -              ; Repeat for all 16 car rotations
  ret

; Data from 35868 to 35877 (16 bytes)
DATA_35868_CarTileLoaderCounterToTableLookup:
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $0C $0D $0E $0F $09 $0A $0B

_LoadOnePosition:
  ld a, (_RAM_DB79_CarTileLoaderHFlip)
  cp 1
  jr z, _hflip
  ld a, (_RAM_DB7A_CarTileLoaderVFlip)
  cp 1
  jr z, LABEL_358D9_vflip
  jp LABEL_3591C_noflip

_hflip:
  ; hflip flag is 1
  call +
  ld a, (_RAM_DB7A_CarTileLoaderVFlip)
  cp $01
  jr z, LABEL_358D9_vflip ; If it's H- and V-flipped, we wasted time loading it h-flipped because now we re-load it v-flipped
  ret

+:; load data, hflipped
  ld a, (_RAM_DB75_CarTileLoaderDataIndex) ; Index into table of pointers, read into bc
  sla a
  ld hl, DATA_35AE3_CarTileRAMLocations
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld b, a

  ld a, (_RAM_DB76_CarTileLoaderPositionIndex) ; Index into table of 6 byte entries, read first two into hl
  sla a
  ld l, a
  ld h, $00
  sla a
  ld e, a
  ld d, $00
  add hl, de
  ld de, DATA_35AED_CarTileAddresses
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e

  ld de, $05DC  ; Subtract this? $600 - 36? Adjusts the address to suit
  or a
  sbc hl, de
  push hl
    call LABEL_359C0_emitThreeTilesHFlipped
  pop hl
  ld de, $0300
  add hl, de
  push hl
    call LABEL_359C0_emitThreeTilesHFlipped
  pop hl
  ld de, $0300
  add hl, de
  TailCall LABEL_359C0_emitThreeTilesHFlipped

LABEL_358D9_vflip:
  ld a, (_RAM_DB75_CarTileLoaderDataIndex) ; Index into table of pointers, read into bc
  sla a
  ld hl, DATA_35AE3_CarTileRAMLocations
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld b, a

  ld a, (_RAM_DB76_CarTileLoaderPositionIndex) ; Index into table of 6 byte entries, read first two into hl
  sla a
  ld l, a
  ld h, $00
  sla a
  ld e, a
  ld d, $00
  add hl, de
  ld de, DATA_35AED_CarTileAddresses
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e

  ; Use the tile address as-is
  push hl
    call LABEL_3598D_emitThreeTilesVFlipped
  pop hl
  ld de, $0300 ; 18 tiles?
  or a
  sbc hl, de
  push hl
    call LABEL_3598D_emitThreeTilesVFlipped
  pop hl
  ld de, $0300
  or a
  sbc hl, de
  TailCall LABEL_3598D_emitThreeTilesVFlipped

LABEL_3591C_noflip:
  ld a, (_RAM_DB75_CarTileLoaderDataIndex) ; Index into table of pointers, read into bc
  sla a
  ld hl, DATA_35AE3_CarTileRAMLocations
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld b, a

  ld a, (_RAM_DB76_CarTileLoaderPositionIndex) ; Index into table of 6 byte entries, read first two into hl
  sla a
  ld l, a
  ld h, $00
  sla a
  ld e, a
  ld d, $00
  add hl, de
  ld de, DATA_35AED_CarTileAddresses
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e

  ld de, $061C ; Adjust the tile address
  or a
  sbc hl, de

  ld a, l       ; Set VRAM address
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld de, $0018  ; Emit three tiles with no flipping
  call LABEL_35977_Emit3bppTileData
  ld de, $0300  ; move on by 18 tiles
  add hl, de
  ld a, l       ; and repeat
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld de, $0018
  call LABEL_35977_Emit3bppTileData
  ld de, $0300 ; and again
  add hl, de
  ld a, l
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld de, $0018
  jp LABEL_35977_Emit3bppTileData ; and return

LABEL_35977_Emit3bppTileData:
  ; Emits 3*de bytes from bc to VDP
-:ld a, (bc)
  out (PORT_VDP_DATA), a
  inc bc
  ld a, (bc)
  out (PORT_VDP_DATA), a
  inc bc
  ld a, (bc)
  out (PORT_VDP_DATA), a
  inc bc
  EmitDataToVDPImmediate8 0 ; padding
  dec de
  ld a, d
  or e
  jr nz, -
  ret

LABEL_3598D_emitThreeTilesVFlipped:
  ; bc = 3bpp tile data
  ; hl = VRAM address to start at (end of first tile)
  ; Emits the data such that the tiles appear vertically flipped
  ld e, $03 ; Tile count
--:
  ld d, $08 ; Rows of data
-:ld a, l   ; Set VRAM address
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a

  ld a, (bc)    ; Emit data as-is, in order
  out (PORT_VDP_DATA), a
  inc bc
  ld a, (bc)
  out (PORT_VDP_DATA), a
  inc bc
  ld a, (bc)
  out (PORT_VDP_DATA), a
  inc bc
  EmitDataToVDPImmediate8 0 ; Last bitplane is 0
  push de
    ld de, $0004 ; Subtract 4 from VRAM address -> one row up
    or a
    sbc hl, de
  pop de
  dec d   ; row counter
  ld a, d
  or a
  jr nz, -
  push de
    ld de, $0040 ; +2 tiles
    add hl, de
  pop de
  dec e
  ld a, e
  or a
  jr nz, --
  ret

LABEL_359C0_emitThreeTilesHFlipped:
  ; bc = 3bpp tile data
  ; hl = VRAM address to start at (start of last tile)
  ; Emits the data such that the tiles appear horizontally flipped
  ld e, $03     ; Tile count
--:
  ld d, $08     ; Rows of data
  ld a, l       ; Set VRAM address
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a

-:push hl
    ld a, (bc)    ; Read byte from here
    call _hflipByte_usingHL
    out (PORT_VDP_DATA), a
    inc bc
    ld a, (bc)
    call _hflipByte_usingHL
    out (PORT_VDP_DATA), a
    inc bc
    ld a, (bc)
    call _hflipByte_usingHL
    out (PORT_VDP_DATA), a
    inc bc
    EmitDataToVDPImmediate8 0 ; last bitplane is 0
  pop hl
  dec d
  ld a, d
  or a
  jr nz, -
  push de
    ld de, 32 ; Move to previous tile
    or a
    sbc hl, de
  pop de
  dec e
  ld a, e
  or a
  jr nz, -- ; Loop over the counter
  ret

+:
_hflipByte_usingHL:
  ld l, a
  rr l
  rl h
  rr l
  rl h
  rr l
  rl h
  rr l
  rl h
  rr l
  rl h
  rr l
  rl h
  rr l
  rl h
  rr l
  rl h
  ld a, h
  ret

LABEL_35A1B_hflipByte_usingBC:
  ld c, a
  rr c
  rl b
  rr c
  rl b
  rr c
  rl b
  rr c
  rl b
  rr c
  rl b
  rr c
  rl b
  rr c
  rl b
  rr c
  rl b
  ld a, b
  ret

LABEL_35A3E_CarTileLoader_HFlipSwapData:
  ; Munges the car tile data so that when loaded as v-flipped, it comes out h-flipped too.
  ; (Is this just h-flipping the bytes?)
  ld a, $00
  ld (_RAM_DB77_CarTileLoaderCounter), a ; Loop counter and index
--:
  ld a, (_RAM_DB77_CarTileLoaderCounter) ; Index into table of 4-byte entries
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_35ABF_HFlipSwapDataLocations ; Read into de, hl
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  inc hl
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, c
  ld bc, $0018 ; 3 tiles?
-:push bc
    ; H-flip and swap bytes at hl and de
    ld a, (hl)
    call LABEL_35A1B_hflipByte_usingBC
    ld (_RAM_DB78_CarTileLoaderTempByte), a
    ld a, (de)
    call LABEL_35A1B_hflipByte_usingBC
    ld (hl), a
    ld a, (_RAM_DB78_CarTileLoaderTempByte)
    ld (de), a
  pop bc
  inc de
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -

  ld a, (_RAM_DB77_CarTileLoaderCounter) ; Increment counter
  add a, $01
  ld (_RAM_DB77_CarTileLoaderCounter), a
  cp $09
  jr nz, -- ; Loop executes 8 times

  ld a, $00
  ld (_RAM_DB77_CarTileLoaderCounter), a ; Start again
--:
  ld a, (_RAM_DB77_CarTileLoaderCounter) ; Look up again
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_35ABF_HFlipSwapDataLocations ; read into hl only
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e
  ld de, $0018  ; add one tile?
  add hl, de
  ld bc, $0018  ; For one tile...
-:
  push bc
    ld a, (hl)
    call LABEL_35A1B_hflipByte_usingBC ; hflip it back again???
    ld (hl), a
  pop bc
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ld a, (_RAM_DB77_CarTileLoaderCounter)
  add a, $01
  ld (_RAM_DB77_CarTileLoaderCounter), a
  cp $09
  jr nz, -- ; Loop 8 times again
  ret

DATA_35ABF_HFlipSwapDataLocations:
.dw $C0F0 $C120 ; Address pairs for data munging
.dw $C138 $C168
.dw $C180 $C1B0
.dw $C1E0 $C210
.dw $C228 $C258
.dw $C270 $C2A0
.dw $C2D0 $C300
.dw $C318 $C348
.dw $C360 $C390

; VRAM offsets of the five car positions - N, NNW, NW, WNW, W
; They are every $f0 bytes from the start of the buffer
DATA_35AE3_CarTileRAMLocations:
  TimesTable16 _RAM_C000_DecompressionTemporaryBuffer $f0 5

; Tile addresses to write at for various flipping modes, only first of each triplet is used?  
DATA_35AED_CarTileAddresses:
; Addresses are $1c bytes past the start of each tile
.dw $661C $631C $601C ; $130, $118, $100 
.dw $667C $637C $607C ; $133, $11b, $103
.dw $66DC $63DC $60DC ; ...
.dw $673C $643C $613C
.dw $679C $649C $619C
.dw $67FC $64FC $61FC
.dw $685C $655C $625C
.dw $68BC $65BC $62BC
.dw $6F1C $6C1C $691C ; Jumps to $178, $160, $148
.dw $6F7C $6C7C $697C ; and continues...
.dw $6FDC $6CDC $69DC
.dw $703C $6D3C $6A3C
.dw $709C $6D9C $6A9C
.dw $70FC $6DFC $6AFC
.dw $715C $6E5C $6B5C
.dw $71BC $6EBC $6BBC

DATA_35B4D_CarDrawingData:
; Rotation generation data
;   ,- index of underlying data (car position unflipped, 0..4)
;   |  ,- index of rotation
;   |  | ,- horizontal flip
;   |  | | ,- vertical flip
.db 0 $0 0 0
.db 1 $1 0 0
.db 2 $2 0 0
.db 3 $3 0 0
.db 4 $4 0 0
.db 3 $5 0 1
.db 2 $6 0 1
.db 1 $7 0 1
.db 0 $8 0 1
.db 1 $9 1 1
.db 2 $A 1 1
.db 3 $B 1 1
.db 4 $C 1 0
.db 3 $D 1 0
.db 2 $E 1 0
.db 1 $F 1 0

DATA_35B8D_DivideByThree:
  DivisionTable 3 96

DATA_35BED_96TimesTable:
  TimesTable16 0 96 32

DATA_35C2D_RuffTruxTileIndices:
; 16 bytes tile indices for each of 16 positions
.db $00 $01 $02 $03 
.db $20 $21 $22 $23 
.db $40 $41 $42 $43 
.db $60 $61 $62 $63

.db $04 $05 $06 $07
.db $24 $25 $26 $27
.db $44 $45 $46 $47
.db $64 $65 $66 $67

.db $08 $09 $0A $08 ; 45 degrees, using tile $08 for corners
.db $28 $29 $2A $2B
.db $48 $49 $4A $4B
.db $08 $69 $6A $08

.db $0C $0D $0E $0F
.db $2C $2D $2E $2F
.db $4C $4D $4E $4F
.db $6C $6D $6E $6F

.db $10 $11 $12 $13
.db $30 $31 $32 $33
.db $50 $51 $52 $53
.db $70 $71 $72 $73

.db $14 $15 $16 $17
.db $34 $35 $36 $37
.db $54 $55 $56 $57
.db $74 $75 $76 $77

.db $08 $19 $1A $08 ; 45 degrees, using tile $08 for corners
.db $38 $39 $3A $3B
.db $58 $59 $5A $5B
.db $08 $79 $7A $08

.db $1C $1D $1E $1F
.db $3C $3D $3E $3F
.db $5C $5D $5E $5F
.db $7C $7D $7E $7F

.db $80 $81 $82 $83
.db $A0 $A1 $A2 $A3
.db $C0 $C1 $C2 $C3
.db $E0 $E1 $E2 $E3

.db $84 $85 $86 $87
.db $A4 $A5 $A6 $A7
.db $C4 $C5 $C6 $C7
.db $E4 $E5 $E6 $E7

.db $08 $89 $8A $08 ; 45 degrees, using tile $08 for corners
.db $A8 $A9 $AA $AB
.db $C8 $C9 $CA $CB
.db $08 $E9 $EA $08

.db $8C $8D $8E $8F
.db $AC $AD $AE $AF
.db $CC $CD $CE $CF
.db $EC $ED $EE $EF

.db $90 $91 $92 $93
.db $B0 $B1 $B2 $B3
.db $D0 $D1 $D2 $D3
.db $F0 $F1 $F2 $F3

.db $94 $95 $96 $97
.db $B4 $B5 $B6 $B7
.db $D4 $D5 $D6 $D7
.db $F4 $F5 $F6 $F7

.db $08 $99 $9A $08 ; 45 degrees, using tile $08 for corners
.db $B8 $B9 $BA $BB
.db $D8 $D9 $DA $DB
.db $08 $F9 $FA $08

.db $9C $9D $9E $9F
.db $BC $BD $BE $BF
.db $DC $DD $DE $DF
.db $FC $FD $FE $FF

DATA_35D2D_HeadToHeadHUDTiles:
; 3bpp tile data (24 bytes per tile)
; - Red dot
; - Blue dot
; - "WINNER" (6 tiles)
; - "BONUS" (first 4 tiles)
; - Explosion sprites
; - "BONUS" (last 2 tiles)
; - Digit for laps remaining (unused - replaced with tile from challenge mode data)
; - Blank tile
.incbin "Assets/Head to Head HUD.3bpp"

LABEL_35F0D_:
  ld a, $00
  ld (_RAM_DB7C_), a
  ld a, (_RAM_DB7B_)
  ld c, a
  ld hl, _RAM_DF37_HUDSpriteNs.FirstPlace
-:
  ld a, (_RAM_DB7C_)
  cp c
  jr z, LABEL_35F30_
  ld a, $94
  ld (hl), a
  inc hl
  ld a, (_RAM_DB7C_)
  add a, $01
  ld (_RAM_DB7C_), a
  cp $08
  jr nz, -
  ret

LABEL_35F30_:
  ld a, $95
  ld (hl), a
  inc hl
  ld a, (_RAM_DB7C_)
  add a, $01
  ld (_RAM_DB7C_), a
  cp $08
  jr nz, LABEL_35F30_
  ret
  
LABEL_35F41_InitialiseHeadToHeadHUDSprites:
  ; Lap counter = 3
  ld a, <SpriteIndex_Digit3
  ld (_RAM_DF37_HUDSpriteNs.LapCounter), a

.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ; Only for GG:
  ld hl, _RAM_DF2E_HUDSpriteXs
  ld ix, _RAM_DF40_HUDSpriteYs
  ld e, $30 ; Y coordinate of first sprite
  ld bc, $0009 ; Sprite count
-:ld a, $38 ; X coordinate of all sprites
  ld (hl), a
  ld a, e
  ld (ix+0), a ; Y
  add a, 8 ; Y offset
  ld e, a
  inc hl
  inc ix
  dec bc ; Loop over all sprites (djnz would be faster)
  ld a, b
  or c
  jr nz, -
  ret
+:; Only for SMS:
  ; Same as above with different constants
  ld hl, _RAM_DF2E_HUDSpriteXs
  ld ix, _RAM_DF40_HUDSpriteYs
  ld e, $08 ; Y coordinate of first sprite
  ld bc, $0009 ; Sprite count
-:ld a, $10 ; X coordinate of all sprites
  ld (hl), a
  ld a, e
  ld (ix+0), a ; Y
  add a, $08 ; Y offset
  ld e, a
  inc hl
  inc ix
  dec bc
  ld a, b
  or c
  jr nz, -
  ret
.else
  ld hl, _RAM_DF2E_HUDSpriteXs
  ld ix, _RAM_DF40_HUDSpriteYs
.ifdef IS_GAME_GEAR
  ld e, $30 ; Y coordinate of first sprite
.else
  ld e, $08 ; Y coordinate of first sprite
.endif
  ld b, 9 ; Sprite count
-:
.ifdef IS_GAME_GEAR
  ld a, $38 ; X coordinate of all sprites
.else
  ld a, $10 ; X coordinate of all sprites
.endif
  ld (hl), a
  ld a, e
  ld (ix+0), a ; Y
  add a, $08 ; Y offset
  ld e, a
  inc hl
  inc ix
  djnz -
  ret
.endif

LABEL_35F8A_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  JrNzRet _LABEL_35FEB_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_35FEB_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet _LABEL_35FEB_ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_35FEB_ret
  ld a, (_RAM_DD1A_)
  or a
  JrNzRet _LABEL_35FEB_ret
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, +
  in a, (PORT_GG_START)
  and PORT_GG_START_MASK
  jp z, LABEL_3603C_
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK ; $10
  jp z, +++
  jp ++

+:
  ld a, (_RAM_DB21_Player2Controls)
  ld d, a
  and BUTTON_L_MASK ; $04
  jr z, +++
  ld a, d
  and BUTTON_R_MASK ; $08
  jr z, LABEL_3603C_
++:
  ld hl, _RAM_DEA1_
  ld a, (hl)
  or a
  jr z, +
  dec (hl)
+:
  ld a, (_RAM_DE9B_)
  or a
  JrNzRet _LABEL_35FEB_ret
  ld hl, _RAM_DEA2_
  ld a, (hl)
  or a
  JrZRet _LABEL_35FEB_ret
  dec (hl)
_LABEL_35FEB_ret:
  ret

+++:
  ld a, (_RAM_DEA1_)
  cp $00
  jr z, +
  sub $01
  ld (_RAM_DEA1_), a
  ret

+:
  ld a, (_RAM_DE9B_)
  or a
  jr nz, +
  ld a, $01
  ld (_RAM_DE9B_), a
  ld (_RAM_DE9C_), a
+:
  ld a, (_RAM_DE9B_)
  cp $02
  jr nz, +
  ld a, (_RAM_DEA4_)
  sub $01
  jp ++

+:
  ld a, (_RAM_DEA4_)
  add a, $01
++:
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DCF7_)
  or a
  jr nz, +
  ld a, $07
  jp ++

+:
  ld a, (_RAM_DB9B_SteeringDelay)
++:
  ld (_RAM_DEA1_), a
  ld hl, _RAM_DCF9_
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCF9_), a
  jp LABEL_3608C_

LABEL_3603C_:
  ld a, (_RAM_DEA1_)
  cp $00
  jr z, +
  sub $01
  ld (_RAM_DEA1_), a
  ret

+:
  ld a, (_RAM_DE9B_)
  or a
  jr nz, +
  ld a, $02
  ld (_RAM_DE9B_), a
  ld (_RAM_DE9C_), a
+:
  ld a, (_RAM_DE9B_)
  cp $01
  jr nz, +
  ld a, (_RAM_DEA4_)
  sub $01
  jp ++

+:
  ld a, (_RAM_DEA4_)
  add a, $01
++:
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DCF7_)
  or a
  jr nz, +
  ld a, $07
  jp ++

+:
  ld a, (_RAM_DB9B_SteeringDelay)
++:
  ld (_RAM_DEA1_), a
  ld hl, _RAM_DCF9_
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCF9_), a
  jp LABEL_3608C_

LABEL_3608C_:
  ld a, (_RAM_DCF9_)
  ld l, a
  ld a, (_RAM_DCF8_)
  cp l
  jr nz, +
  ld a, $00
  ld (_RAM_DE9B_), a
  ld (_RAM_DE9C_), a
  ld (_RAM_DEA4_), a
  ret

+:
  ld a, (_RAM_DEA4_)
  cp $04
  jr nz, +
  ld a, $01
  ld (_RAM_DE9D_), a
  JpRet ++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $00
  ld (_RAM_DE9D_), a
++:ret

-:ret

LABEL_360B9_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet -
  ld a, (_RAM_D5C5_)
  cp $01
  JrZRet -
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet -
  call LABEL_36152_
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_)
  sub l
  ld (_RAM_DEAF_), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_), a
+++:
  ld a, (_RAM_DF0E_)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF0E_)
  ld (_RAM_DEB2_), a
  ret

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  ret

LABEL_36152_:
  ld a, (_RAM_DB7E_)
  ld (_RAM_DF0B_), a
  ld a, (_RAM_DB7F_)
  ld (_RAM_DF0C_), a
  ld a, (_RAM_DD0C_)
  ld (_RAM_DF0E_), a
  ld a, (_RAM_DD0D_)
  ld (_RAM_DF0D_), a
  ret

LABEL_3616B_:
  call LABEL_361F0_
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DD0D_)
  cp l
  jr z, ++
  ld a, (_RAM_DCFB_)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCFB_)
  sub l
  ld (_RAM_DCFB_), a
  jp +++

+:
  sub l
  ld (_RAM_DCFB_), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DD0D_), a
  jp +++

++:
  ld a, (_RAM_DCFB_)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCFB_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DCFB_), a
+++:
  ld a, (_RAM_DF0E_)
  ld l, a
  ld a, (_RAM_DD0C_)
  cp l
  jr z, ++
  ld a, (_RAM_DCFC_)
  ld l, a
  ld a, (_RAM_DF0C_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCFC_)
  sub l
  ld (_RAM_DCFC_), a
  ret

+:
  sub l
  ld (_RAM_DCFC_), a
  ld a, (_RAM_DF0E_)
  ld (_RAM_DD0C_), a
  ret

++:
  ld a, (_RAM_DCFC_)
  ld l, a
  ld a, (_RAM_DF0C_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCFC_), a
  ret

+:
  ld a, $07
  ld (_RAM_DCFC_), a
  ret

LABEL_361F0_:
  ld a, (_RAM_DF7D_)
  ld (_RAM_DF0B_), a
  ld a, (_RAM_DF7E_)
  ld (_RAM_DF0C_), a
  ld a, (_RAM_DB84_)
  ld (_RAM_DF0E_), a
  ld a, (_RAM_DB85_)
  ld (_RAM_DF0D_), a
  ret

LABEL_36209_:
  ld a, (_RAM_D5B7_)
  or a
  jr z, +
  dec a
  ld (_RAM_D5B7_), a
+:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  JrNzRet +
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet +
  ld a, (_RAM_DCF7_)
  or a
  jr z, ++
  ld a, (_RAM_DE9B_)
  or a
  JrZRet +
  cp $01
  jr z, +++
  jp LABEL_36287_

+:ret

++:
  ld a, (_RAM_DCF9_)
  ld (_RAM_DCF8_), a
  ld a, $00
  ld (_RAM_DEA4_), a
  ld (_RAM_DEA2_), a
  ld (_RAM_DE9B_), a
  ret

+++:
  ld a, (_RAM_DD00_)
  or a
  JrNzRet +
  ld a, (_RAM_D5B7_)
  or a
  JrNzRet _LABEL_3625F_ret
  ld a, (_RAM_DEA2_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA2_), a
+:ret

_LABEL_3625F_ret:
  ret

++:
  ld a, (_RAM_DEA4_)
  sub $01
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DE9D_)
  cp $01
  jr nz, +
  ld a, $06
  jp ++

+:
  call LABEL_362C7_
++:
  ld (_RAM_DEA2_), a
  ld hl, _RAM_DCF8_
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCF8_), a
  jp LABEL_3608C_

LABEL_36287_:
  ld a, (_RAM_DD00_)
  or a
  JrNzRet +
  ld a, (_RAM_D5B7_)
  or a
  JrNzRet _LABEL_3625F_ret
  ld a, (_RAM_DEA2_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA2_), a
+:ret

++:
  ld a, (_RAM_DEA4_)
  sub $01
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DE9D_)
  cp $01
  jr nz, +
  ld a, $06
  jp ++

+:
  call LABEL_362C7_
++:
  ld (_RAM_DEA2_), a
  ld hl, _RAM_DCF8_
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCF8_), a
  jp LABEL_3608C_

LABEL_362C7_:
  ld hl, _RAM_DB86_HandlingData
  ld de, (_RAM_DCF7_)
  ld d, $00
  add hl, de
  ld a, (hl)
  ret

LABEL_362D3_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr z, ++
  or a ; TT_0_SportsCars
  jr z, LABEL_36338_
  cp TT_3_TurboWheels
  jr z, +
  ret

+:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $01
  jr z, +
  ret

+:
  ld b, $38
  ld c, $3B
  jp LABEL_36343_

++:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld b, $48
  ld c, $4C
  jp +++

+:
  ld b, $2A
  ld c, $2E
  jp +++

++:
  ld b, $16
  ld c, $1A
+++:
  ld a, (_RAM_DF50_)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, $03
  ld (_RAM_DCB6_), a
+:
  ld a, (_RAM_DF51_)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, $03
  ld (_RAM_DCF7_), a
+:
  ld a, (_RAM_DF52_)
  cp b
  JrCRet +
  cp c
  JrNcRet +
  ld a, $03
  ld (_RAM_DD38_), a
+:ret

LABEL_36338_:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, +
  ret

+:
  ld b, $0A
  ld c, $0D
LABEL_36343_:
  ld a, (_RAM_DF50_)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, $0C
  ld (_RAM_DCB6_), a
+:
  ld a, (_RAM_DF51_)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, $0C
  ld (_RAM_DCF7_), a
+:
  ld a, (_RAM_DF52_)
  cp b
  JrCRet +
  cp c
  JrNcRet +
  ld a, $0C
  ld (_RAM_DD38_), a
+:ret

LABEL_3636E_:
  ld a, (_RAM_DF6B_)
  add a, $01
  and $01
  ld (_RAM_DF6B_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF59_CarState)
  cp CarState_4_Submerged
  jr z, +
--:
  ld a, (_RAM_DE91_CarDirectionPrevious)
  add a, $01
-:
  and $0F
  ld (_RAM_DE91_CarDirectionPrevious), a
  ld (_RAM_DE90_CarDirection), a
  ret

+:
  ld a, (_RAM_DE91_CarDirectionPrevious)
  cp $08
  jr nc, --
  sub $01
  jp -

LABEL_3639C_:
  ld a, (_RAM_D5BC_)
  cp $04
  JrCRet _LABEL_363CB_ret
  ld a, (_RAM_DD00_)
  or a
  JrNzRet _LABEL_363CB_ret
  ld a, (_RAM_DCF7_)
  cp $06
  JrCRet _LABEL_363CB_ret
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrZRet _LABEL_363CB_ret
--:
  xor a
  ld (_RAM_D5BC_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_3_TurboWheels ; Alternative skid sounds for these two
  jr z, +
  cp TT_5_Warriors
  jr z, +
  ld a, SFX_0F_Skid1
-:ld (_RAM_D974_SFXTrigger_Player2), a
_LABEL_363CB_ret:
  ret

+:
  ld a, SFX_10_Skid2
  jr -

LABEL_363D0_:
  ld a, (_RAM_D5BC_)
  cp $04
  JrCRet _LABEL_363CB_ret
  jr --

LABEL_363D9_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet _LABEL_36454_ret
  ld a, (_RAM_DD00_)
  or a
  jr z, +
  ld a, (_RAM_DD12_)
  cp $02
  JrZRet _LABEL_36454_ret
+:
  ld a, (_RAM_DEA4_)
  or a
  jr z, ++
  cp $01
  jr z, +
  call LABEL_3639C_
+:
  ld a, (_RAM_DE9B_)
  cp $00
  jr z, ++
  cp $01
  jr z, +
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_L_MASK ; $04
  jr z, LABEL_3645B_
  jp ++

+:
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_R_MASK ; $08
  jr z, LABEL_3645B_
++:
  ld a, (_RAM_DEA4_)
  cp $00
  jr z, LABEL_3645B_
  ld a, (_RAM_DB21_Player2Controls)
  ld l, a
  and BUTTON_L_MASK ; $04
  jr z, +
  ld a, l
  and BUTTON_R_MASK ; $08
  JrNzRet _LABEL_36454_ret
+:
  ld a, $01
  ld (_RAM_DEAA_), a
  ld hl, _RAM_DEA8_
  inc (hl)
  ld a, (hl)
  cp $44
  jr nz, LABEL_3643D_
  ld a, $43
  ld (_RAM_DEA8_), a
LABEL_3643D_:
  ld hl, DATA_EA2_
  ld de, (_RAM_DEA8_)
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DCF7_)
  sub l
  ld l, a
  and $80
  jr nz, +
  ld a, l
  ld (_RAM_DE57_), a
_LABEL_36454_ret:
  ret

+:
  ld a, $00
  ld (_RAM_DE57_), a
  ret

LABEL_3645B_:
  ld a, (_RAM_DEAA_)
  cp $00
  jr z, +
  ld a, (_RAM_DEA8_)
  cp $00
  jr z, +
  cp $01
  jr z, +
  sub $02
  ld (_RAM_DEA8_), a
  jp LABEL_3643D_

+:
  ld a, $00
  ld (_RAM_DEA8_), a
  ld (_RAM_DEAA_), a
  ld a, (_RAM_DCF7_)
  ld (_RAM_DE57_), a
  ret

LABEL_36484_PatchForLevel:
  ; Patch level data after loading
  ; Strange, maybe they couldn't easily alter it at some stage?

.macro PatchLayout args x, y, index
  ld a, index
  ld (_RAM_C000_LevelLayout + x + y*32), a
.endm

.macro PatchWallData args index, offset, value
  ld a, value
  ld (_RAM_C800_WallData + index * _sizeof_WallDataMetaTile + offset), a
.endm

.macro PatchBehaviourData args index, x, y, value
.if NARGS == 4
  ld a, value
.endif
  ld (_RAM_CC80_BehaviourData + index * _sizeof_BehaviourDataMetaTile + y * 6 + x), a
.endm

  ; Also patches other stuff - code?
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jp z, LABEL_3666D_Powerboats
  cp TT_0_SportsCars
  jp z, LABEL_366CB_SportsCars
  cp TT_6_Tanks
  jp z, LABEL_3665F_Tanks
  cp TT_4_FormulaOne
  jr z, ++
  cp TT_3_TurboWheels
  jr z, +
  ret

+:; Turbo Wheels
  PatchBehaviourData 43, 1, 1, $0f
  PatchBehaviourData 43, 1, 2, $02
  PatchBehaviourData 43, 1, 3
  PatchBehaviourData 43, 1, 4, $01
  ret

++: ; F1
  PatchWallData 58  0 %11000000 ; Hole (right)
  PatchWallData 58 15 %11110000
  PatchWallData 58  1 %00001111
  PatchWallData 58 16 %00001100
  PatchWallData 57  2 %00001111 ; Hole (right)
  PatchWallData 57 16 %11110000
  PatchWallData 53  8 %00000100 ; Hole (bottom right)
  PatchWallData 53 10 %01100000
  PatchWallData 52  1 %00001110 ; Hole (bottom right, more)
  PatchWallData 52  3 %00100000
  PatchWallData 46  2 %00000111 ; Hole (bottom left)
  PatchWallData 46  4 %01000000
  PatchWallData 47  7 %11110010 ; Hole (bottom left, more)
  PatchWallData 47  9 %01100000
  PatchWallData 29 16 %01110000 ; Hole (top left)
  PatchWallData 29 14 %00000100
  PatchWallData 30  7 %00000110 ; Hole (top left, more)
  PatchWallData 30  9 %00100000
  PatchWallData 37  8 %00000110 ; Hole (top right)
  PatchWallData 37 10 %01001111
  PatchWallData 36 13 %00000010 ; Hole (top right, more)
  PatchWallData 36 15 %11100000

  PatchBehaviourData 37, 5, 2, $85
  PatchBehaviourData 36, 1, 4, $81
  PatchBehaviourData 36, 1, 0, $0F
  PatchBehaviourData 36, 2, 0; $0F
  PatchBehaviourData 36, 6, 0, $85
  PatchBehaviourData 36, 8, 0, $80
  PatchBehaviourData 36, 9, 0, $09
  PatchBehaviourData 36, 3, 2; $09
  PatchBehaviourData 36, 2, 3, $81
  PatchBehaviourData 29, 3, 0, $00
  PatchBehaviourData 29, 4, 0; $00
  PatchBehaviourData 29, 2, 1, $0E
  PatchBehaviourData 29, 3, 1, $85
  PatchBehaviourData 29, 5, 1, $87
  PatchBehaviourData 29, 2, 2, $0D
  PatchBehaviourData 29, 3, 3, $84
  PatchBehaviourData 29, 4, 4, $8F
  PatchBehaviourData 30, 0, 2, $8A
  PatchBehaviourData 49, 4, 0, $19
  PatchBehaviourData 49, 5, 0; $19
  PatchBehaviourData 49, 4, 1; $19
  PatchBehaviourData 49, 5, 1; $19
  PatchBehaviourData 48, 0, 1; $19
  PatchBehaviourData 48, 1, 1; $19
  PatchBehaviourData 48, 2, 1; $19
  PatchBehaviourData 48, 3, 1; $19
  PatchBehaviourData 48, 4, 1; $19
  PatchBehaviourData 48, 5, 1; $19
  PatchBehaviourData 47, 0, 5, $1A
  PatchBehaviourData 47, 1, 5; $1A
  PatchBehaviourData 47, 2, 5; $1A
  PatchBehaviourData 47, 3, 5; $1A
  PatchBehaviourData 47, 4, 5; $1A
  PatchBehaviourData 47, 5, 5; $1A
  PatchBehaviourData 46, 4, 1, $85
  PatchBehaviourData 46, 3, 2, $85
  PatchBehaviourData 46, 2, 3, $0D
  PatchBehaviourData 46, 2, 4, $05
  PatchBehaviourData 46, 3, 4, $83
  PatchBehaviourData 46, 5, 4, $81
  PatchBehaviourData 46, 3, 5, $04
  PatchBehaviourData 46, 4, 5, $0B
  PatchBehaviourData 47, 0, 3, $87
  PatchBehaviourData 52, 1, 1, $87
  PatchBehaviourData 52, 2, 2, $87
  PatchBehaviourData 52, 3, 3, $09
  PatchBehaviourData 52, 0, 4, $83
  PatchBehaviourData 52, 2, 4, $81
  PatchBehaviourData 52, 3, 4, $0A
  PatchBehaviourData 52, 1, 5, $04
  PatchBehaviourData 52, 2, 5, $0B
  PatchBehaviourData 53, 5, 3, $83
  PatchBehaviourData 57, 5, 0, $E5
  PatchBehaviourData 57, 5, 5, $E2
  PatchBehaviourData 57, 2, 1, $85
  PatchBehaviourData 57, 3, 1; $85
  PatchBehaviourData 57, 1, 2, $8D
  PatchBehaviourData 57, 1, 3; $8D
  PatchBehaviourData 57, 2, 2, $84
  PatchBehaviourData 57, 2, 3; $84
  PatchBehaviourData 57, 2, 4; $84
  PatchBehaviourData 57, 3, 4, $83
  PatchBehaviourData 58, 2, 1, $87
  PatchBehaviourData 58, 3, 1, $80
  PatchBehaviourData 58, 3, 2, $81
  PatchBehaviourData 58, 3, 3; $81
  PatchBehaviourData 58, 2, 4; $81
  PatchBehaviourData 58, 3, 4; $81
  PatchBehaviourData 58, 4, 2, $89
  PatchBehaviourData 58, 4, 3; $89
  PatchBehaviourData 57, 4, 1, $86
  PatchBehaviourData 57, 4, 4, $82
  PatchBehaviourData 58, 1, 1, $84
  PatchBehaviourData 58, 1, 4; $84
  ret

LABEL_3665F_Tanks:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $01
  jr z, +
  ret

+:; Tanks 1
  PatchLayout 8, 5, $19
  ret

LABEL_3666D_Powerboats:
  PatchBehaviourData 36, 0, 4, $04
  PatchBehaviourData 36, 1, 4; $04
  PatchBehaviourData 36, 2, 4; $04
  PatchBehaviourData 36, 3, 4; $04
  PatchBehaviourData 36, 4, 4; $04
  PatchBehaviourData 36, 5, 4; $04
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $00
  jr z, ++
  cp $01
  jr z, +++
  cp $02
  jr z, +
  ; Race 3 - Foamy Fjords
  ; Change soap and bottle at start further from the track
  ; from ---S++BB----
  ; to   --S-++-BB---
  PatchLayout 3, 23, $B5 ; Move soap left at start
  PatchLayout 4, 23, $9E ; Fill space next to it
  PatchLayout 6, 23, $9F ;
  PatchLayout 7, 23, $B6
  PatchLayout 8, 23, $B7
  ret

+:; Race 2
  PatchLayout 8, 8, $9D
  ret

++: ; Race 0 - qualifying
  PatchLayout 12, 5, $1E
  PatchLayout 11, 5, $35
  ret

+++: ; Race 1
  PatchLayout 12, 8, $9D
  PatchLayout 17, 8, $35
  PatchLayout 18, 8, $1E
  ret

LABEL_366CB_SportsCars:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $02
  jr z, +
  ret

+:; Track 2 - Crayon Canyons - layout error at bottom right corner of track
  PatchLayout 0, 0, $34
  PatchLayout 0, 31, $32
  ret

LABEL_366DE_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jp z, LABEL_36798_
  cp $02
  jr z, +
  ret

+:
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld b, $02
  ld a, (_RAM_D583_)
  cp $00
  jr nz, ++
+:
  ld b, $03
++:
  ld a, (_RAM_DD00_)
  cp $00
  jr nz, +
  ld a, (_RAM_DF7F_)
  cp b
  jr nc, LABEL_36752_
  add a, $01
  ld (_RAM_DF7F_), a
  ld a, $78
  ld (_RAM_DD10_), a
  ld a, $03
  ld (_RAM_DD11_), a
  ld a, $01
  ld (_RAM_DD00_), a
+:
  ld a, (_RAM_DF99_)
  add a, $01
  ld (_RAM_DF99_), a
  and $01
  jr nz, LABEL_36736_
  ld a, (_RAM_DCF9_)
  add a, $01
  and $0F
  ld (_RAM_DCF9_), a
  ld (_RAM_DCF8_), a
LABEL_36736_:
  ld a, (_RAM_DF99_)
  and $0F
  jr z, +
  ret

+:
  ld a, (_RAM_DB7B_)
  ld l, a
  ld a, (_RAM_D583_)
  cp l
  jr z, +
  ld (_RAM_DB7B_), a
  ret

+:
  add a, $01
  ld (_RAM_DB7B_), a
  ret

LABEL_36752_:
  call LABEL_B63_
  ld a, (_RAM_D581_)
  cp $A0
  jr c, LABEL_36736_
  ld a, (_RAM_D583_)
  ld (_RAM_DB7B_), a
  cp $00
  jr z, +
  cp $08
  jr nz, ++
+:
  ld a, $01
  ld (_RAM_DF6A_), a
  ld a, $00
  ld (_RAM_DF2A_Positions.Player2), a
  ld a, $01
  ld (_RAM_DF2A_Positions.Player1), a
++:
  ld a, (_RAM_DF7F_)
  cp $05
  jr z, +
  ld a, $05
  ld (_RAM_DF7F_), a
  ld a, $01
  ld (_RAM_DD1A_), a
  ld (_RAM_DF5B_), a
  jp LABEL_71B5_

+:
  xor a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld (_RAM_DF73_), a
  ret

LABEL_36798_:
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld b, $02
  ld a, (_RAM_D583_)
  cp $08
  jr nz, ++
+:
  ld b, $03
++:
  ld a, (_RAM_DF00_)
  cp $00
  jr nz, +
  ld a, (_RAM_DF7F_)
  cp b
  jr nc, LABEL_367FF_
  add a, $01
  ld (_RAM_DF7F_), a
  ld a, $78
  ld (_RAM_DF0A_), a
  ld a, $03
  ld (_RAM_DF02_), a
  ld a, $01
  ld (_RAM_DF00_), a
+:
  ld a, (_RAM_DF99_)
  add a, $01
  ld (_RAM_DF99_), a
  and $01
  jr nz, LABEL_367E3_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  add a, $01
  and $0F
  ld (_RAM_DE91_CarDirectionPrevious), a
  ld (_RAM_DE90_CarDirection), a
LABEL_367E3_:
  ld a, (_RAM_DF99_)
  and $0F
  jr z, +
  ret

+:
  ld a, (_RAM_DB7B_)
  ld l, a
  ld a, (_RAM_D583_)
  cp l
  jr z, +
  ld (_RAM_DB7B_), a
  ret

+:
  sub $01
  ld (_RAM_DB7B_), a
  ret

LABEL_367FF_:
  call LABEL_B63_
  ld a, (_RAM_D581_)
  cp $A0
  jr c, LABEL_367E3_
  ld a, (_RAM_D583_)
  ld (_RAM_DB7B_), a
  cp $00
  jr z, +
  cp $08
  jr nz, ++
+:
  ld a, $01
  ld (_RAM_DF6A_), a
  ld a, $00
  ld (_RAM_DF2A_Positions.Player1), a
  ld a, $01
  ld (_RAM_DF2A_Positions.Player2), a
++:
  ld a, $05
  ld (_RAM_DF7F_), a
  jp LABEL_2934_BehaviourF

LABEL_3682E_:
  ld a, (_RAM_DE55_)
  sla a
  ld hl, DATA_368F7_
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld b, a
  ld a, c
  and $80
  jr z, +
  ld a, c
  and $7F
  ld c, a
  ld a, (_RAM_DBA4_)
  sub c
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  jp ++

+:
  ld a, (_RAM_DBA4_)
  add a, c
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
++:
  ld a, b
  and $80
  jr z, +
  ld a, b
  and $7F
  ld c, a
  ld hl, (_RAM_DCEC_CarData_Blue)
  ld b, $00
  or a
  sbc hl, bc
  ld (_RAM_DCEC_CarData_Blue), hl
  jp ++

+:
  ld hl, (_RAM_DCEC_CarData_Blue)
  ld c, b
  ld b, $00
  add hl, bc
  ld (_RAM_DCEC_CarData_Blue), hl
++:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld de, $0028
  ld hl, (_RAM_DCEC_CarData_Blue)
  or a
  sbc hl, de
  ld (_RAM_DCEC_CarData_Blue), hl
+:
  ld a, (_RAM_DE55_)
  sla a
  ld hl, DATA_36917_
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  inc hl
  ld a, (hl)
  ld b, a
  ld a, c
  and $80 ; Check sign
  jr z, +
  ld a, c
  and $7F ; Remove sign bit
  ld c, a
  ld a, (_RAM_DBA5_)
  sub c ; Subtract
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  jp ++
+:ld a, (_RAM_DBA5_)
  add a, c ; Add
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
++:
  ld a, b
  and $80
  jr z, +
  ld a, b
  and $7F
  ld c, a
  ld hl, (_RAM_DCEE_)
  ld b, $00
  or a
  sbc hl, bc
  ld (_RAM_DCEE_), hl
  jp ++

+:
  ld hl, (_RAM_DCEE_)
  ld c, b
  ld b, $00
  add hl, bc
  ld (_RAM_DCEE_), hl
++:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  JrZRet +
  ld de, $0028
  ld hl, (_RAM_DCEE_)
  or a
  sbc hl, de
  ld (_RAM_DCEE_), hl
+:ret

DATA_368F7_:
  ; Delta pairs applied to _RAM_DBA4_ and _RAM_DCEC_CarData_Blue, indexed by _RAM_DE55_
  SignAndMagnitude  12, -12
  SignAndMagnitude  12, -12
  SignAndMagnitude   9,  -9
  SignAndMagnitude  -6,   6
  SignAndMagnitude   0,   0
  SignAndMagnitude  -6,   6
  SignAndMagnitude   9,  -9
  SignAndMagnitude -12,  12
  SignAndMagnitude  12, -12
  SignAndMagnitude -12,  12
  SignAndMagnitude  -9,   9
  SignAndMagnitude   6,  -6
  SignAndMagnitude   0,   0
  SignAndMagnitude   6,  -6
  SignAndMagnitude  -9,   9
  SignAndMagnitude  12, -12

DATA_36917_:
  ; Delta pairs applied to _RAM_DBA5_ and _RAM_DCEE_, indexed by _RAM_DE55_
  SignAndMagnitude   0,   0
  SignAndMagnitude   6,  -6
  SignAndMagnitude   9,  -9
  SignAndMagnitude -12,  12
  SignAndMagnitude  12, -12
  SignAndMagnitude  12, -12
  SignAndMagnitude  -9,   9
  SignAndMagnitude   6,  -6
  SignAndMagnitude   0,   0
  SignAndMagnitude  -6,   6
  SignAndMagnitude  -9,   9
  SignAndMagnitude  12, -12
  SignAndMagnitude  12, -12
  SignAndMagnitude -12,  12
  SignAndMagnitude   9,  -9
  SignAndMagnitude  -6,   6
  ; Since they're always matched, it could be stored as a single byte...

LABEL_36937_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  JrNzRet +++
  ld a, (_RAM_D5C5_)
  or a
  JrNzRet +++
  ld a, (_RAM_DE8C_)
  or a
  jr z, +
  ld a, (_RAM_DD1F_)
  or a
  JrNzRet +++
  jp ++

+:
  ld a, (_RAM_DD1F_)
  or a
  JrZRet +++
++:
  ld hl, (_RAM_DF56_)
  xor a
  cp l
  jr nz, +
  cp h
  jr nz, +
  jp LABEL_369EE_

+:
  dec hl
  ld (_RAM_DF56_), hl
+++:ret

LABEL_36971_:
  ld a, (_RAM_DE4F_)
  cp $80
  JpNzRet _LABEL_369ED_ret
  ld a, (_RAM_D5C5_)
  or a
  JpNzRet _LABEL_369ED_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $00
  JpNzRet _LABEL_369ED_ret
  ld a, (_RAM_DF7F_)
  cp $00
  JpNzRet _LABEL_369ED_ret
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DBA4_)
  cp $CA
  jr nc, LABEL_369EE_
  cp $28
  jr c, LABEL_369EE_
  ld a, (_RAM_DBA5_)
  cp $AA
  jr nc, LABEL_369EE_
  cp $12
  jr c, LABEL_369EE_
  ld a, (_RAM_DCFD_)
  cp $CA
  jr nc, LABEL_369EE_
  cp $28
  jr c, LABEL_369EE_
  ld a, (_RAM_DCFE_)
  cp $12
  jr c, LABEL_369EE_
  cp $AA
  JpCRet _LABEL_369ED_ret
  jp LABEL_369EE_

+:
  ld a, (_RAM_DBA4_)
  cp $EA
  jr nc, LABEL_369EE_
  cp $08
  jr c, LABEL_369EE_
  ld a, (_RAM_DBA5_)
  cp $C6
  jr nc, LABEL_369EE_
  ld a, (_RAM_DCFD_)
  cp $EA
  jr nc, LABEL_369EE_
  cp $08
  jr c, LABEL_369EE_
  ld a, (_RAM_DCFE_)
  cp $C6
  JrCRet _LABEL_369ED_ret
  jp LABEL_369EE_

_LABEL_369ED_ret:
  ret

LABEL_369EE_:
  xor a
  ld (_RAM_DEB5_), a
  ld (_RAM_DF0F_), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE35_), a
  ld a, (_RAM_D945_)
  or a
  jr nz, LABEL_36A4F_
  ld a, (_RAM_D940_)
  or a
  jr nz, LABEL_36A56_
  ld a, (_RAM_DE8C_)
  or a
  jr nz, LABEL_36A6D_
  ld a, (_RAM_DD1F_)
  or a
  jr nz, LABEL_36A5D_
  ld a, (_RAM_DF8E_)
  ld l, a
  ld a, (_RAM_DF92_)
  cp l
  jr z, +
  jr nc, LABEL_36A3F_
  jp LABEL_36A2C_

+:
  ld a, (_RAM_DF8D_)
  ld l, a
  ld a, (_RAM_DF91_)
  cp l
  jr nc, LABEL_36A3F_
LABEL_36A2C_:
  ld a, (_RAM_DF58_)
  cp $00
  jr nz, +
--:
  ld a, $01
  ld (_RAM_DF5B_), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_4E49_

LABEL_36A3F_:
  ld a, (_RAM_DD1A_)
  cp $00
  JrNzRet +
-:
  ld a, CarState_1_Exploding
  ld (_RAM_DF59_CarState), a
  jp LABEL_2A08_
.ifdef JUMP_TO_RET
+:ret
.endif
LABEL_36A4F_:
  xor a
  ld (_RAM_D945_), a
  jp -

LABEL_36A56_:
  xor a
  ld (_RAM_D940_), a
  jp --

LABEL_36A5D_:
  xor a
  ld (_RAM_DD1A_), a
  ld a, (_RAM_DF55_)
  ld (_RAM_DD28_), a
  call +
  jp LABEL_36A3F_

LABEL_36A6D_:
  xor a
  ld (_RAM_DF58_), a
  ld a, (_RAM_DD28_)
  ld (_RAM_DF55_), a
  call +
  jp LABEL_36A2C_

+:
  xor a
  ld (_RAM_DE8C_), a
  ld (_RAM_DD1F_), a
  ret

LABEL_36A85_:
  ld a, (_RAM_DE6A_)
  add a, $01
  and $01
  ld (_RAM_DE6A_), a
  cp $00
  jr z, +
  ld ix, _RAM_DE60_
  ld iy, _RAM_DE64_
  ld bc, _RAM_DE68_
  call ++
  ld bc, _RAM_DE69_
  jp +++

+:
  ld ix, _RAM_DE5E_
  ld iy, _RAM_DE62_
  ld bc, _RAM_DE66_
  call ++
  ld bc, _RAM_DE67_
  jp +++

++:
  ld a, (bc)
  cp $00
  jr z, LABEL_36B0B_
  ld a, (ix+0)
  ld (_RAM_DA60_SpriteTableXNs.49.x), a
  ld (_RAM_DA60_SpriteTableXNs.51.x), a
  add a, $08
  ld (_RAM_DA60_SpriteTableXNs.50.x), a
  ld (_RAM_DA60_SpriteTableXNs.52.x), a
  ld a, (iy+0)
  ld (_RAM_DAE0_SpriteTableYs.49.y), a
  ld (_RAM_DAE0_SpriteTableYs.50.y), a
  add a, $08
  ld (_RAM_DAE0_SpriteTableYs.51.y), a
  ld (_RAM_DAE0_SpriteTableYs.52.y), a
  ret

+++:
  ld a, (bc)
  cp $00
  jr z, +
  ld a, (ix+1)
  ld (_RAM_DA60_SpriteTableXNs.53.x), a
  ld (_RAM_DA60_SpriteTableXNs.55.x), a
  add a, $08
  ld (_RAM_DA60_SpriteTableXNs.54.x), a
  ld (_RAM_DA60_SpriteTableXNs.56.x), a
  ld a, (iy+1)
  ld (_RAM_DAE0_SpriteTableYs.53.y), a
  ld (_RAM_DAE0_SpriteTableYs.54.y), a
  add a, $08
  ld (_RAM_DAE0_SpriteTableYs.55.y), a
  ld (_RAM_DAE0_SpriteTableYs.56.y), a
  ret

LABEL_36B0B_:
  ld a, $F0
  ld (_RAM_DAE0_SpriteTableYs.49.y), a
  ld (_RAM_DAE0_SpriteTableYs.50.y), a
  ld (_RAM_DAE0_SpriteTableYs.51.y), a
  ld (_RAM_DAE0_SpriteTableYs.52.y), a
  ret

+:
  ld a, $F0
  ld (_RAM_DAE0_SpriteTableYs.53.y), a
  ld (_RAM_DAE0_SpriteTableYs.54.y), a
  ld (_RAM_DAE0_SpriteTableYs.55.y), a
  ld (_RAM_DAE0_SpriteTableYs.56.y), a
  ret

LABEL_36B29_:
  ld a, (_RAM_D5B0_)
  or a
  jp nz, LABEL_36B36_
  ld a, (_RAM_D940_)
  or a
  jr z, +
LABEL_36B36_:
  xor a
  ld (_RAM_D940_), a
  ld (_RAM_D945_), a
  ret

+:
  ld a, $02
  ld (_RAM_D945_), a
  ld de, (_RAM_D941_)
  ld hl, (_RAM_DBAD_)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DEB0_), a
  ld (_RAM_D5C3_), a
  ld hl, (_RAM_D941_)
  ld de, (_RAM_DBAD_)
  or a
  sbc hl, de
  ld (_RAM_D941_), hl
  jp ++

+:
  ld (_RAM_D941_), hl
  ld a, $01
  ld (_RAM_DEB0_), a
  ld (_RAM_D5C3_), a
++:
  ld de, (_RAM_D943_)
  ld hl, (_RAM_DBAF_)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DEB2_), a
  ld (_RAM_D5C4_), a
  ld hl, (_RAM_D943_)
  ld de, (_RAM_DBAF_)
  or a
  sbc hl, de
  ld (_RAM_D943_), hl
  jp ++

+:
  ld (_RAM_D943_), hl
  ld a, $01
  ld (_RAM_DEB2_), a
  ld (_RAM_D5C4_), a
++:
  ld hl, (_RAM_DCEE_)
  ld b, h
  ld c, l
  ld de, (_RAM_DBAF_)
  or a
  sbc hl, de
  jr nc, +
  ld h, d
  ld l, e
  ld d, b
  ld e, c
  or a
  sbc hl, de
+:
  ld a, h
  or a
  jr nz, LABEL_36BBF_
  ld a, l
  cp $90
  jr c, +
LABEL_36BBF_:
  ld a, $00
  ld (_RAM_D945_), a
  jp LABEL_2A55_

+:
  ld hl, (_RAM_DCEC_CarData_Blue)
  ld b, h
  ld c, l
  ld de, (_RAM_DBAD_)
  or a
  sbc hl, de
  jr nc, +
  ld h, d
  ld l, e
  ld d, b
  ld e, c
  or a
  sbc hl, de
+:
  ld a, h
  or a
  jr nz, LABEL_36BBF_
  ld a, l
  cp $D2
  jr nc, LABEL_36BBF_
  ret

LABEL_36BE6_:
  ld a, (_RAM_D5B0_)
  or a
  jp nz, LABEL_36B36_
  ld a, (_RAM_D945_)
  or a
  jr z, +
  jp LABEL_36B36_

+:
  ld a, $02
  ld (_RAM_D940_), a
  ld de, (_RAM_D941_)
  ld hl, (_RAM_DCEC_CarData_Blue)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DD0D_), a
  ld hl, (_RAM_D941_)
  ld de, (_RAM_DCEC_CarData_Blue)
  or a
  sbc hl, de
  ld (_RAM_D941_), hl
  jp ++

+:
  ld (_RAM_D941_), hl
  ld a, $01
  ld (_RAM_DD0D_), a
++:
  ld de, (_RAM_D943_)
  ld hl, (_RAM_DCEE_)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DD0C_), a
  ld hl, (_RAM_D943_)
  ld de, (_RAM_DCEE_)
  or a
  sbc hl, de
  ld (_RAM_D943_), hl
  jp ++

+:
  ld (_RAM_D943_), hl
  ld a, $01
  ld (_RAM_DD0C_), a
++:
  ld hl, (_RAM_DBAB_)
  ld a, (_RAM_DBA5_)
  ld e, a
  ld d, $00
  add hl, de
  ld b, h
  ld c, l
  ld de, (_RAM_DCEE_)
  or a
  sbc hl, de
  jr nc, +
  ld h, d
  ld l, e
  ld d, b
  ld e, c
  or a
  sbc hl, de
+:
  ld a, h
  or a
  jr nz, LABEL_36C72_
  ld a, l
  cp $C6
  jr c, +
LABEL_36C72_:
  ld a, $00
  ld (_RAM_D940_), a
  ld a, $00
  ld (_RAM_DF5B_), a
  jp LABEL_4EAB_

+:
  ld hl, (_RAM_DBA9_)
  ld a, (_RAM_DBA4_)
  ld e, a
  ld d, $00
  add hl, de
  ld b, h
  ld c, l
  ld de, (_RAM_DCEC_CarData_Blue)
  or a
  sbc hl, de
  jr nc, +
  ld h, d
  ld l, e
  ld d, b
  ld e, c
  or a
  sbc hl, de
+:
  ld a, h
  or a
  jr nz, LABEL_36C72_
  ld a, l
  cp $D2
  jr nc, LABEL_36C72_
  ret

LABEL_36CA5_:
  ld a, (_RAM_DF59_CarState)
  or a
  JrNzRet _LABEL_36D06_ret
  ld a, (_RAM_D5C3_)
  ld (_RAM_DEB0_), a
  ld a, (_RAM_D5C4_)
  ld (_RAM_DEB2_), a
  ld a, (_RAM_D941_)
  and $FC
  jr z, +
  sub $04
  ld (_RAM_D941_), a
  ld a, $04
-:
  ld (_RAM_DEAF_), a
  jp ++

+:
  ld a, $00
  jp -

++:
  ld a, (_RAM_D943_)
  and $FC
  jr z, +
  sub $04
  ld (_RAM_D943_), a
  ld a, $04
-:
  ld (_RAM_DEB1_VScrollDelta), a
  jp ++

+:
  ld a, $00
  jp -

++:
  ld a, (_RAM_DEAF_)
  cp $00
  JrNzRet _LABEL_36D06_ret
  ld a, (_RAM_DEB1_VScrollDelta)
  cp $00
  JrNzRet _LABEL_36D06_ret
  ld a, $00
  ld (_RAM_D945_), a
  ld a, CarState_2_Respawning
  ld (_RAM_DF59_CarState), a
  ld a, SFX_16_Respawn
  ld (_RAM_D963_SFXTrigger_Player1), a
_LABEL_36D06_ret:
  ret

LABEL_36D07_:
  ld a, (_RAM_D941_)
  and $FC
  jr z, +
  sub $04
  ld (_RAM_D941_), a
  ld a, $04
-:
  ld (_RAM_DCFB_), a
  jp ++

+:
  ld a, $00
  jp -

++:
  ld a, (_RAM_D943_)
  and $FC
  jr z, +
  sub $04
  ld (_RAM_D943_), a
  ld a, $04
-:
  ld (_RAM_DCFC_), a
  jp ++

+:
  ld a, $00
  jp -

++:
  ld a, (_RAM_DCFB_)
  cp $00
  JrNzRet +
  ld a, (_RAM_DCFC_)
  cp $00
  JrNzRet +
  ld a, $00
  ld (_RAM_D940_), a
  ld a, $02
  ld (_RAM_DF5B_), a
+:ret

LABEL_36D52_RuffTrux_UpdateTimer:
  call LABEL_36DFF_RuffTrux_DecrementTimer
  ; Render timer into tiles
  ld d, $00
  ld a, (_RAM_DF6F_RuffTruxTimer_TensOfSeconds)
  sla a
  sla a
  sla a
  ld hl, DATA_36DAF_TimerDigitTilesData
  ld e, a
  add hl, de
  ld de, $5162 ; tile $8b lower bitplanes
  call +
  ld d, $00
  ld a, (_RAM_DF70_RuffTruxTimer_Seconds)
  sla a
  sla a
  sla a
  ld hl, DATA_36DAF_TimerDigitTilesData
  ld e, a
  add hl, de
  ld de, $5302 ; tile $98 lower bitplanes
  call +
  ld d, $00
  ld a, (_RAM_DF71_RuffTruxTimer_Tenths)
  sla a
  sla a
  sla a
  ld hl, DATA_36DAF_TimerDigitTilesData
  ld e, a
  add hl, de
  ld de, $5D02 ; tile $e8 lower bitplanes
+:
  ld bc, $0008 ; Bytes of data
-:
  ; Set VRAM address
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ; Emit data
  ld a, (hl)
  out (PORT_VDP_DATA), a
  dec bc
  inc hl
  ; Set VRAM address +4
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
DATA_36DAF_TimerDigitTilesData: ; 1bpp data. This is written into the right bitplane, but the upper bitplanes select whether 0 means transparent or black.
.incbin "Assets/RuffTrux/Numbers.1bpp"

LABEL_36DFF_RuffTrux_DecrementTimer:
  ld a, (_RAM_D599_IsPaused)
  or a
  JrNzRet _LABEL_36E6A_ret
  ld a, (_RAM_DF65_)
  cp $01
  JrZRet _LABEL_36E6A_ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_36E6A_ret

  ; Increment frame counter
  ld a, (_RAM_DF72_RuffTruxTimer_Frames)
  add a, $01
  ld (_RAM_DF72_RuffTruxTimer_Frames), a
  cp $0A ; BUG: should be 5 or 6 for 50 or 60Hz!
  JrNzRet _LABEL_36E6A_ret

  ; Reached target, decrement tenths
  ld a, $00
  ld (_RAM_DF72_RuffTruxTimer_Frames), a
  ld a, (_RAM_DF71_RuffTruxTimer_Tenths)
  sub $01
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  cp $FF
  JrNzRet _LABEL_36E6A_ret

  ; Decrement seconds
  ld a, $09
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  ld a, (_RAM_DF70_RuffTruxTimer_Seconds)
  sub $01
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  cp $FF
  JrNzRet _LABEL_36E6A_ret

  ; Decrement tens of seconds
  ld a, $09
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  ld a, (_RAM_DF6F_RuffTruxTimer_TensOfSeconds)
  sub $01
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  cp $FF
  JrNzRet _LABEL_36E6A_ret

  ; Ran out of time!
  ld a, $01
  ld (_RAM_DF65_), a
  ld (_RAM_DF8C_RuffTruxRanOutOfTime), a
  ld a, $F0
  ld (_RAM_DF6A_), a
  ld a, $00
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
_LABEL_36E6A_ret:
  ret

LABEL_36E6B_:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DBA4_)
  add a, l
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DBA6_)
  add a, l
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, LABEL_36F4B_
  ld a, (_RAM_DF88_)
  add a, $01
  and $01
  ld (_RAM_DF88_), a
  cp $00
  jr z, LABEL_36EEA_
  ld a, (_RAM_DD6E_)
  add a, l
  ld (_RAM_DD6E_), a
  ld a, (_RAM_DD71_)
  add a, l
  ld (_RAM_DD71_), a
  ld a, (_RAM_DD74_)
  add a, l
  ld (_RAM_DD74_), a
  ld a, (_RAM_DD77_)
  add a, l
  ld (_RAM_DD77_), a
  ld a, (_RAM_DD7A_)
  add a, l
  ld (_RAM_DD7A_), a
  ld a, (_RAM_DD7D_)
  add a, l
  ld (_RAM_DD7D_), a
  ld a, (_RAM_DD9E_)
  add a, l
  ld (_RAM_DD9E_), a
  ld a, (_RAM_DDA1_)
  add a, l
  ld (_RAM_DDA1_), a
  ld a, (_RAM_DDA4_)
  add a, l
  ld (_RAM_DDA4_), a
  ld a, (_RAM_DDA7_)
  add a, l
  ld (_RAM_DDA7_), a
  ld a, (_RAM_DDAA_)
  add a, l
  ld (_RAM_DDAA_), a
  ld a, (_RAM_DDAD_)
  add a, l
  ld (_RAM_DDAD_), a
  jp LABEL_36F3E_

LABEL_36EEA_:
  ld a, (_RAM_DDCE_)
  add a, l
  ld (_RAM_DDCE_), a
  ld a, (_RAM_DDD1_)
  add a, l
  ld (_RAM_DDD1_), a
  ld a, (_RAM_DDD4_)
  add a, l
  ld (_RAM_DDD4_), a
  ld a, (_RAM_DDD7_)
  add a, l
  ld (_RAM_DDD7_), a
  ld a, (_RAM_DDDA_)
  add a, l
  ld (_RAM_DDDA_), a
  ld a, (_RAM_DDDD_)
  add a, l
  ld (_RAM_DDDD_), a
  ld a, (_RAM_DDFE_)
  add a, l
  ld (_RAM_DDFE_), a
  ld a, (_RAM_DE01_)
  add a, l
  ld (_RAM_DE01_), a
  ld a, (_RAM_DE04_)
  add a, l
  ld (_RAM_DE04_), a
  ld a, (_RAM_DE07_)
  add a, l
  ld (_RAM_DE07_), a
  ld a, (_RAM_DE0A_)
  add a, l
  ld (_RAM_DE0A_), a
  ld a, (_RAM_DE0D_)
  add a, l
  ld (_RAM_DE0D_), a
LABEL_36F3E_:
  or a
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBA9_)
  sbc hl, de
  ld (_RAM_DBA9_), hl
  ret

LABEL_36F4B_:
  ld a, (_RAM_D5A6_)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.57.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.57.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.58.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.58.x), a
+:
  ld a, (_RAM_DCEA_)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.59.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.59.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.60.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.60.x), a
+:
  ld a, (_RAM_DD2B_)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.61.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.62.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.62.x), a
+:
  ld a, (_RAM_DD6C_)
  or a
  jr z, LABEL_36F3E_
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.63.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.64.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.64.x), a
  jp LABEL_36F3E_

LABEL_36F9E_:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DBA5_)
  add a, l
  ld (_RAM_DBA5_), a
  ld a, (_RAM_DBA7_)
  add a, l
  ld (_RAM_DBA7_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, LABEL_3707E_
  ld a, (_RAM_DF89_)
  add a, $01
  and $01
  ld (_RAM_DF89_), a
  cp $00
  jr z, LABEL_3701D_
  ld a, (_RAM_DD70_)
  add a, l
  ld (_RAM_DD70_), a
  ld a, (_RAM_DD73_)
  add a, l
  ld (_RAM_DD73_), a
  ld a, (_RAM_DD76_)
  add a, l
  ld (_RAM_DD76_), a
  ld a, (_RAM_DD79_)
  add a, l
  ld (_RAM_DD79_), a
  ld a, (_RAM_DD7C_)
  add a, l
  ld (_RAM_DD7C_), a
  ld a, (_RAM_DD7F_)
  add a, l
  ld (_RAM_DD7F_), a
  ld a, (_RAM_DDA0_)
  add a, l
  ld (_RAM_DDA0_), a
  ld a, (_RAM_DDA3_)
  add a, l
  ld (_RAM_DDA3_), a
  ld a, (_RAM_DDA6_)
  add a, l
  ld (_RAM_DDA6_), a
  ld a, (_RAM_DDA9_)
  add a, l
  ld (_RAM_DDA9_), a
  ld a, (_RAM_DDAC_)
  add a, l
  ld (_RAM_DDAC_), a
  ld a, (_RAM_DDAF_)
  add a, l
  ld (_RAM_DDAF_), a
  jp LABEL_37071_

LABEL_3701D_:
  ld a, (_RAM_DDD0_)
  add a, l
  ld (_RAM_DDD0_), a
  ld a, (_RAM_DDD3_)
  add a, l
  ld (_RAM_DDD3_), a
  ld a, (_RAM_DDD6_)
  add a, l
  ld (_RAM_DDD6_), a
  ld a, (_RAM_DDD9_)
  add a, l
  ld (_RAM_DDD9_), a
  ld a, (_RAM_DDDC_)
  add a, l
  ld (_RAM_DDDC_), a
  ld a, (_RAM_DDDF_)
  add a, l
  ld (_RAM_DDDF_), a
  ld a, (_RAM_DE00_)
  add a, l
  ld (_RAM_DE00_), a
  ld a, (_RAM_DE03_)
  add a, l
  ld (_RAM_DE03_), a
  ld a, (_RAM_DE06_)
  add a, l
  ld (_RAM_DE06_), a
  ld a, (_RAM_DE09_)
  add a, l
  ld (_RAM_DE09_), a
  ld a, (_RAM_DE0C_)
  add a, l
  ld (_RAM_DE0C_), a
  ld a, (_RAM_DE0F_)
  add a, l
  ld (_RAM_DE0F_), a
LABEL_37071_:
  or a
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBAB_)
  sbc hl, de
  ld (_RAM_DBAB_), hl
  ret

LABEL_3707E_:
  ld a, (_RAM_D5A6_)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.57.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.57.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.58.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.58.y), a
+:
  ld a, (_RAM_DCEA_)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.59.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.59.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.60.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.60.y), a
+:
  ld a, (_RAM_DD2B_)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.61.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.61.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.62.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.62.y), a
+:
  ld a, (_RAM_DD6C_)
  or a
  jr z, LABEL_37071_
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.63.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.64.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.64.y), a
  jp LABEL_37071_

; Data from 370D1 to 37160 (144 bytes)
; Something to do with metadata? 12x12 bytes
DATA_370D1_:
.db $00 $00 $00 $00 $01 $01 $01 $02 $02 $02 $03 $03 $00 $00 $00 $01
.db $01 $01 $02 $02 $02 $03 $03 $03 $00 $00 $01 $01 $01 $02 $02 $02
.db $03 $03 $03 $04 $00 $00 $01 $01 $01 $02 $02 $03 $03 $04 $04 $04
.db $00 $01 $01 $01 $02 $02 $02 $03 $03 $04 $04 $04 $00 $01 $01 $01
.db $02 $02 $03 $03 $04 $04 $04 $04 $00 $11 $11 $11 $12 $12 $13 $13
.db $14 $14 $14 $14 $00 $41 $41 $41 $42 $42 $43 $43 $44 $44 $44 $44
.db $00 $41 $41 $41 $42 $42 $42 $43 $43 $44 $44 $44 $00 $00 $41 $41
.db $41 $42 $42 $43 $43 $44 $44 $44 $00 $00 $41 $41 $41 $42 $42 $42
.db $43 $43 $43 $44 $00 $00 $00 $41 $41 $41 $42 $42 $42 $43 $43 $43

; Data from 37161 to 371F0 (144 bytes)
; Alternate (switched) version of the above
DATA_37161_:
.db $23 $83 $83 $82 $82 $82 $81 $81 $81 $00 $00 $00 $23 $83 $83 $83
.db $82 $82 $82 $81 $81 $81 $00 $00 $24 $84 $83 $83 $83 $82 $82 $82
.db $81 $81 $81 $00 $24 $84 $84 $84 $83 $83 $82 $82 $81 $81 $81 $00
.db $24 $84 $84 $84 $83 $83 $82 $82 $82 $81 $81 $81 $24 $84 $84 $84
.db $84 $83 $83 $82 $82 $81 $81 $81 $FF $94 $94 $94 $94 $93 $93 $92
.db $92 $91 $91 $91 $64 $C4 $C4 $C4 $C4 $C3 $C3 $C2 $C2 $C1 $C1 $C1
.db $64 $C4 $C4 $C4 $C3 $C3 $C2 $C2 $C2 $C1 $C1 $C1 $64 $C4 $C4 $C4
.db $C3 $C3 $C2 $C2 $C1 $C1 $C1 $00 $64 $C4 $C3 $C3 $C3 $C2 $C2 $C2
.db $C1 $C1 $C1 $00 $63 $C3 $C3 $C3 $C2 $C2 $C2 $C1 $C1 $C1 $00 $00

LABEL_371F1_:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  ld c, a
  ld a, (_RAM_D589_)
  add a, l
  add a, c
  ld (_RAM_D589_), a
  ld a, (_RAM_DCBA_)
  ld l, a
  ld a, (_RAM_DCBB_)
  ld c, a
  ld a, (_RAM_DCC6_)
  add a, l
  add a, c
  ld (_RAM_DCC6_), a
  ld a, (_RAM_DCFB_)
  ld l, a
  ld a, (_RAM_DCFC_)
  ld c, a
  ld a, (_RAM_DD07_)
  add a, l
  add a, c
  ld (_RAM_DD07_), a
  ld a, (_RAM_DD3C_)
  ld l, a
  ld a, (_RAM_DD3D_)
  ld c, a
  ld a, (_RAM_DD48_)
  add a, l
  add a, c
  ld (_RAM_DD48_), a
  ret

; Data from 37232 to 37271 (64 bytes)
; Something specific to Four by Four
DATA_37232_FourByFour_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

; Data from 37272 to 37291 (32 bytes)
; indexed by _RAM_DE92_EngineVelocity, value stored at _RAM_D58A_
; 1000, 960, 920, ... , 440, 400
DATA_37272_:
  TimesTable16 1000, -40, 16

LABEL_37292_GameVBlankEngineUpdate:
  ; Look up 16-bit value in table
  ld a, (_RAM_DE92_EngineVelocity)
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_37272_
  add hl, de
  ld a, (hl)
  ld (_RAM_D58A_.Lo), a
  inc hl
  ld a, (hl)
  ld (_RAM_D58A_.Hi), a
  ld l, a ; Does nothing
  ; Subtract $10 for some reason
  ld bc, $0010
  ld hl, (_RAM_D58A_)
  or a
  sbc hl, bc
  ld (_RAM_D58A_), hl
  ; Then grab the high byte
  ld a, (_RAM_D58A_.Hi)
  ld l, a
  ld a, (_RAM_DF00_)
  or a
  jr nz, ++
  ld a, (_RAM_D95C_)
  cp l
  jr z, +
  jr c, LABEL_372D3_
-:
  ld de, $0004
  ld hl, (_RAM_D95B_)
  ; _RAM_D95B_ -= 4
  or a
  sbc hl, de
  ld (_RAM_D95B_), hl
  ret

LABEL_372D3_:
  ; _RAM_D95B_ += 2
  ld hl, (_RAM_D95B_)
  ld de, $0002
  add hl, de
  ld (_RAM_D95B_), hl
  ret

+:
  ld a, (_RAM_D58A_.Lo)
  ld l, a
  ld a, (_RAM_D95B_)
  cp l
  JrZRet +
  jr c, LABEL_372D3_
  jp -

+:ret

++:
  ld a, (_RAM_D95C_)
  cp $01
  jr z, +
--:
  ; _RAM_D95B_ -= 4
  ld de, $0004
  ld hl, (_RAM_D95B_)
  or a
  sbc hl, de
  ld (_RAM_D95B_), hl
-:ret

+:
  ld a, (_RAM_D95B_)
  cp $90
  JrCRet -
  jp --

LABEL_3730C_GameVBlankPart3:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D96F_)
  ld (_RAM_D595_), a
  jp LABEL_37408_

+:
  xor a
  ld (_RAM_D594_), a
  ld (_RAM_D595_), a
  ld (_RAM_D596_), a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld l, a
  ld a, (_RAM_DE79_)
  add a, l
  sub $05
  jr nc, +
  xor a
+:
  ld (_RAM_D592_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_)
  add a, l
  sub $05
  jr nc, +
  xor a
+:
  ld (_RAM_D593_), a
  ld l, a
  ld a, (_RAM_DCB0_)
  sub l
  jr c, +
  cp $0A
  jr nc, +
  ld e, a
  ld d, $00
  ld hl, DATA_3751E_11TimesTable
  add hl, de
  ld a, (_RAM_D592_)
  ld c, a
  ld a, (_RAM_DCAF_)
  sub c
  jr c, +
  cp $0A
  jr nc, +
  ld e, a
  ld a, (hl)
  add a, e
  ld e, a
  ld d, $00
  ld hl, DATA_374A5_
  add hl, de
  ld a, (hl)
  ld (_RAM_D594_), a
+:
  ld a, (_RAM_D593_)
  ld l, a
  ld a, (_RAM_DCF1_)
  sub l
  jr c, +
  cp $0A
  jr nc, +
  ld e, a
  ld d, $00
  ld hl, DATA_3751E_11TimesTable
  add hl, de
  ld a, (_RAM_D592_)
  ld c, a
  ld a, (_RAM_DCF0_)
  sub c
  jr c, +
  cp $0A
  jr nc, +
  ld e, a
  ld a, (hl)
  add a, e
  ld e, a
  ld d, $00
  ld hl, DATA_374A5_
  add hl, de
  ld a, (hl)
  ld (_RAM_D595_), a
+:
  ld a, (_RAM_D593_)
  ld l, a
  ld a, (_RAM_DD32_)
  sub l
  jr c, +
  cp $0A
  jr nc, +
  ld e, a
  ld d, $00
  ld hl, DATA_3751E_11TimesTable
  add hl, de
  ld a, (_RAM_D592_)
  ld c, a
  ld a, (_RAM_DD31_)
  sub c
  jr c, +
  cp $0A
  jr nc, +
  ld e, a
  ld a, (hl)
  add a, e
  ld e, a
  ld d, $00
  ld hl, DATA_374A5_
  add hl, de
  ld a, (hl)
  ld (_RAM_D596_), a
+:
  ld a, (_RAM_D594_)
  ld l, a
  ld a, (_RAM_D595_)
  cp l
  jr nc, +
  ld a, (_RAM_D596_)
  cp l
  jr nc, LABEL_373F3_
  ld a, (_RAM_DCBF_)
  ld b, a
  ld a, (_RAM_DCB6_)
  ex af, af'
  ld a, (_RAM_D594_)
  jp ++

LABEL_373F3_:
  ld a, (_RAM_DD41_)
  ld b, a
  ld a, (_RAM_DD38_)
  ex af, af'
  ld a, (_RAM_D596_)
  jp ++

+:
  ld l, a
  ld a, (_RAM_D596_)
  cp l
  jr nc, LABEL_373F3_
LABEL_37408_:
  ld a, (_RAM_DD00_)
  ld b, a
  ld a, (_RAM_DCF7_)
  ex af, af'
  ld a, (_RAM_D595_)
++:
  ld (_RAM_D597_), a
  or a
  jr z, +++
  ld l, a
  ld a, (_RAM_D96F_)
  cp l
  jr z, ++
  jr nc, +
  inc a
  ld (_RAM_D96F_), a
  jp ++

+:
  dec a
  ld (_RAM_D96F_), a
++:
  ex af, af'
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_37272_
  add hl, de
  ld a, (hl)
  ld (_RAM_D58E_), a
  inc hl
  ld a, (hl)
  ld (_RAM_D58F_), a
  jp ++++

+++:
  ex af, af'
  xor a
  ld (_RAM_D96F_), a
  ret

++++:
  ld a, b
  or a
  jr nz, ++
  ld a, (_RAM_D58F_)
  ld l, a
  ld a, (_RAM_D96D_)
  cp l
  jr z, +
  jr c, LABEL_37466_
-:
  ld de, $0004
  ld hl, (_RAM_D96C_)
  or a
  sbc hl, de
  ld (_RAM_D96C_), hl
  ret

LABEL_37466_:
  ld hl, (_RAM_D96C_)
  ld de, $0002
  add hl, de
  ld (_RAM_D96C_), hl
  ret

+:
  ld a, (_RAM_D58E_)
  ld l, a
  ld a, (_RAM_D96C_)
  cp l
  JrZRet +
  jr c, LABEL_37466_
  jp -

+:ret

++:
  ld a, (_RAM_DF7F_)
  or a
  JrNzRet _LABEL_3749A_ret
  ld a, (_RAM_D96D_)
  cp $01
  jr z, +
-:
  ld de, $0004
  ld hl, (_RAM_D96C_)
  or a
  sbc hl, de
  ld (_RAM_D96C_), hl
_LABEL_3749A_ret:
  ret

+:
  ld a, (_RAM_D96C_)
  cp $90
  JrCRet _LABEL_3749A_ret
  jp -

; Data from 374A5 to 3751D (121 bytes)
DATA_374A5_:
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $04 $04 $04 $04
.db $04 $04 $04 $04 $04 $02 $02 $04 $06 $06 $06 $06 $06 $06 $06 $04
.db $02 $02 $04 $06 $08 $08 $08 $08 $08 $06 $04 $02 $02 $04 $06 $08
.db $09 $09 $09 $08 $06 $04 $02 $02 $04 $06 $08 $09 $0A $09 $08 $06
.db $04 $02 $02 $04 $06 $08 $09 $09 $09 $08 $06 $04 $02 $02 $04 $06
.db $08 $08 $08 $08 $08 $06 $04 $02 $02 $04 $06 $06 $06 $06 $06 $06
.db $06 $04 $02 $02 $04 $04 $04 $04 $04 $04 $04 $04 $04 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02

; Data from 3751E to 37528 (11 bytes)
DATA_3751E_11TimesTable:
  ; 11, 22, ... 133
  TimesTableLo 11 11 11

LABEL_37529_: ; initialises some stuff, TODO
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  xor a
  jp ++
+:ld a, (_RAM_DC3D_IsHeadToHead)
++:
  ld (_RAM_D59D_), a ; !IsGameGear || GearToGearActive || IsHeadToHead
  ld a, $04
  ld (_RAM_DB7B_), a
  ld a, $01
  ld (_RAM_DBA8_), a
  ld a, (_RAM_DB99_AccelerationDelay)
  sub $01
  ld (_RAM_DCBE_), a
  ld (_RAM_DCFF_), a
  ld (_RAM_DD40_), a

  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, @GG

@SMS:
  ld a, $74
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $68
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  ret

@GG:
  ld a, $3C
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $8F
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  ret

; Data from 37580 to 3758F (16 bytes)
DATA_37580_:
.db $74 $68 $58 $58 $58 $58 $58 $68 $74 $80 $90 $90 $90 $90 $90 $80

; Data from 37590 to 3759F (16 bytes)
DATA_37590_:
.db $7F $7F $7F $6F $63 $57 $47 $47 $47 $47 $47 $57 $63 $6F $7F $7F

LABEL_375A0_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet ++
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ret

+:
  ld a, (_RAM_D5A4_IsReversing)
  or a
  JrNzRet ++
  ld a, (_RAM_DF6A_)
  or a
  JrNzRet ++
  ld a, $00
  ld (_RAM_DEB8_), a
  ld a, (_RAM_DF58_)
  cp $00
  JrNzRet ++
  ld a, (_RAM_DE90_CarDirection)
  ld l, a
  ld c, a
  ld a, (_RAM_DE80_)
  cp l
  jr nz, +++
  jr +++

++:ret

+++:
  ld a, $00
  ld (_RAM_DE7F_), a
  ld h, $00
  ld de, DATA_37590_
  add hl, de
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DEB2_)
  or a
  jr nz, LABEL_3762B_
  ld a, (_RAM_DE5D_)
  cp b
  jr z, +
  jr c, +++
  ld a, (_RAM_DEB1_VScrollDelta)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  ld a, $01
  ld (_RAM_DE7F_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE80_), a
  ret

++:
  ld a, $01
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DEB8_), a
  ld a, $01
  ld (_RAM_DEB2_), a
  ret

+++:
  ld a, (_RAM_DEB1_VScrollDelta)
  add a, $01
  ld (_RAM_DEB1_VScrollDelta), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB8_), a
  ld a, $00
  ld (_RAM_DEB2_), a
+:ret

LABEL_3762B_:
  ld a, (_RAM_DE5D_)
  cp b
  jr z, +
  jr nc, +++
  ld a, (_RAM_DEB1_VScrollDelta)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEB1_VScrollDelta), a
  ret

+:
  ld a, $01
  ld (_RAM_DE7F_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE80_), a
  ret

++:
  ld a, $01
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DEB8_), a
  ld a, $00
  ld (_RAM_DEB2_), a
  ret

+++:
  ld a, (_RAM_DEB1_VScrollDelta)
  add a, $01
  ld (_RAM_DEB1_VScrollDelta), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB8_), a
  ld a, $01
  ld (_RAM_DEB2_), a
+:ret

LABEL_3766F_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet ++
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ret

+:
  ld a, (_RAM_D5A4_IsReversing)
  or a
  JrNzRet ++
  ld a, (_RAM_DF6A_)
  or a
  JrNzRet ++
  ld a, $00
  ld (_RAM_DEB9_), a
  ld a, (_RAM_DF58_)
  cp $00
  JrNzRet ++
  ld a, (_RAM_DE90_CarDirection)
  ld l, a
  ld c, a
  ld a, (_RAM_DE81_)
  cp l
  jr nz, +++
  jr +++

++:ret

+++:
  ld a, $00
  ld (_RAM_DE82_), a
  ld h, $00
  ld de, DATA_37580_
  add hl, de
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DEB0_)
  or a
  jr nz, LABEL_376FA_
  ld a, (_RAM_DE5C_)
  cp b
  jr z, +
  jr c, +++
  ld a, (_RAM_DEAF_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEAF_), a
  ret

+:
  ld a, $01
  ld (_RAM_DE82_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE81_), a
  ret

++:
  ld a, $01
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB9_), a
  ld a, $01
  ld (_RAM_DEB0_), a
  ret

+++:
  ld a, (_RAM_DEAF_)
  add a, $01
  ld (_RAM_DEAF_), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB9_), a
  ld a, $00
  ld (_RAM_DEB0_), a
+:ret

LABEL_376FA_:
  ld a, (_RAM_DE5C_)
  cp b
  jr z, +
  jr nc, +++
  ld a, (_RAM_DEAF_)
  or a
  jr z, ++
  sub $01
  ld (_RAM_DEAF_), a
  ret

+:
  ld a, $01
  ld (_RAM_DE82_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE81_), a
  ret

++:
  ld a, $01
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB9_), a
  ld a, $00
  ld (_RAM_DEB0_), a
  ret

+++:
  ld a, (_RAM_DEAF_)
  add a, $01
  ld (_RAM_DEAF_), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB9_), a
  ld (_RAM_DEB0_), a
+:ret

LABEL_3773B_ReadControls:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, ++
-:; Read player 1 controls
  in a, (PORT_CONTROL_A)
  ld b, a
  and PORT_CONTROL_A_PLAYER1_MASK
  ld (_RAM_DB20_Player1Controls), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  JrNzRet + ; ret
  ; Read player 2 controls
  in a, (PORT_CONTROL_B)
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
  ld (_RAM_DB21_Player2Controls), a
+:ret

++:; Game Gear
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, - ; Read controls same as SMS
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr nz, +

  ; I am player 1
  xor a
  ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
  in a, (PORT_CONTROL_A)
  and $3F
  ld (_RAM_DB20_Player1Controls), a
  out (PORT_GG_LinkSend), a
-:
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  or a
  jr z, -
  ld (_RAM_DB21_Player2Controls), a
  ret

+:; I am player 2
  ld a, (_RAM_DC47_GearToGear_OtherPlayerControls1)
  or a
  JrZRet + ; ret
  ld (_RAM_DB20_Player1Controls), a
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  ld (_RAM_DB21_Player2Controls), a
  ld a, $00
  ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
  ret
.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_3779F_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, +
  ld a, (_RAM_D5A5_)
  or a
  jr z, +
  ld a, (_RAM_DCF8_)
  ld l, a
  ld h, $00
  ld de, DATA_250E_
  add hl, de
  ld a, (hl)
  ld c, a
  jr ++

+:
  ld a, (_RAM_DCF8_)
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, ++++
  ld a, (_RAM_D5B9_)
  or a
  jr nz, +++
++:
  ld a, $04
  jr +++++

+++:
  ld a, (_RAM_D5B8_)
  ld c, a
  ld a, $04
  jr +++++

++++:
  ld a, (_RAM_DCF7_)
  cp $04
  jr nc, +
  ld a, $00
  ld (_RAM_DCF7_), a
  ld (_RAM_DE35_), a
  ld a, (_RAM_DCF9_)
  ld (_RAM_DCF8_), a
  ret

+:
  ld a, (_RAM_DCF7_)
+++++:
  and $FE
  rr a
  ld (_RAM_DE35_), a
  and $FE
  rr a
  ld (_RAM_DCF7_), a
  ld d, $00
  ld a, c
  ld e, a
  ld hl, DATA_250E_
  add hl, de
  ld a, (hl)
  ld (_RAM_DE34_), a
  ld a, (_RAM_DCF9_)
  ld (_RAM_DCF8_), a
  ret

LABEL_37817_:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  ld (_RAM_DBA5_), a
  ld a, (_RAM_DBA7_)
  sub l
  ld (_RAM_DBA7_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, LABEL_378F4_
  ld a, (_RAM_DF89_)
  add a, $01
  and $01
  ld (_RAM_DF89_), a
  cp $00
  jr z, LABEL_37895_
  ld a, (_RAM_DD70_)
  sub l
  ld (_RAM_DD70_), a
  ld a, (_RAM_DD73_)
  sub l
  ld (_RAM_DD73_), a
  ld a, (_RAM_DD76_)
  sub l
  ld (_RAM_DD76_), a
  ld a, (_RAM_DD79_)
  sub l
  ld (_RAM_DD79_), a
  ld a, (_RAM_DD7C_)
  sub l
  ld (_RAM_DD7C_), a
  ld a, (_RAM_DD7F_)
  sub l
  ld (_RAM_DD7F_), a
  ld a, (_RAM_DDA0_)
  sub l
  ld (_RAM_DDA0_), a
  ld a, (_RAM_DDA3_)
  sub l
  ld (_RAM_DDA3_), a
  ld a, (_RAM_DDA6_)
  sub l
  ld (_RAM_DDA6_), a
  ld a, (_RAM_DDA9_)
  sub l
  ld (_RAM_DDA9_), a
  ld a, (_RAM_DDAC_)
  sub l
  ld (_RAM_DDAC_), a
  ld a, (_RAM_DDAF_)
  sub l
  ld (_RAM_DDAF_), a
  jr LABEL_378E9_

LABEL_37895_:
  ld a, (_RAM_DDD0_)
  sub l
  ld (_RAM_DDD0_), a
  ld a, (_RAM_DDD3_)
  sub l
  ld (_RAM_DDD3_), a
  ld a, (_RAM_DDD6_)
  sub l
  ld (_RAM_DDD6_), a
  ld a, (_RAM_DDD9_)
  sub l
  ld (_RAM_DDD9_), a
  ld a, (_RAM_DDDC_)
  sub l
  ld (_RAM_DDDC_), a
  ld a, (_RAM_DDDF_)
  sub l
  ld (_RAM_DDDF_), a
  ld a, (_RAM_DE00_)
  sub l
  ld (_RAM_DE00_), a
  ld a, (_RAM_DE03_)
  sub l
  ld (_RAM_DE03_), a
  ld a, (_RAM_DE06_)
  sub l
  ld (_RAM_DE06_), a
  ld a, (_RAM_DE09_)
  sub l
  ld (_RAM_DE09_), a
  ld a, (_RAM_DE0C_)
  sub l
  ld (_RAM_DE0C_), a
  ld a, (_RAM_DE0F_)
  sub l
  ld (_RAM_DE0F_), a
LABEL_378E9_:
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBAB_)
  add hl, de
  ld (_RAM_DBAB_), hl
  ret

LABEL_378F4_:
  ld a, (_RAM_D5A6_)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.57.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.57.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.58.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.58.y), a
+:
  ld a, (_RAM_DCEA_)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.59.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.59.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.60.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.60.y), a
+:
  ld a, (_RAM_DD2B_)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.61.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.61.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.62.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.62.y), a
+:
  ld a, (_RAM_DD6C_)
  or a
  jr z, LABEL_378E9_
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.63.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.64.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.64.y), a
  jr LABEL_378E9_

LABEL_37946_:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DBA6_)
  sub l
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, LABEL_37A23_
  ld a, (_RAM_DF88_)
  add a, $01
  and $01
  ld (_RAM_DF88_), a
  or a
  jr z, LABEL_379C4_
  ld a, (_RAM_DD6E_)
  sub l
  ld (_RAM_DD6E_), a
  ld a, (_RAM_DD71_)
  sub l
  ld (_RAM_DD71_), a
  ld a, (_RAM_DD74_)
  sub l
  ld (_RAM_DD74_), a
  ld a, (_RAM_DD77_)
  sub l
  ld (_RAM_DD77_), a
  ld a, (_RAM_DD7A_)
  sub l
  ld (_RAM_DD7A_), a
  ld a, (_RAM_DD7D_)
  sub l
  ld (_RAM_DD7D_), a
  ld a, (_RAM_DD9E_)
  sub l
  ld (_RAM_DD9E_), a
  ld a, (_RAM_DDA1_)
  sub l
  ld (_RAM_DDA1_), a
  ld a, (_RAM_DDA4_)
  sub l
  ld (_RAM_DDA4_), a
  ld a, (_RAM_DDA7_)
  sub l
  ld (_RAM_DDA7_), a
  ld a, (_RAM_DDAA_)
  sub l
  ld (_RAM_DDAA_), a
  ld a, (_RAM_DDAD_)
  sub l
  ld (_RAM_DDAD_), a
  jp LABEL_37A18_

LABEL_379C4_:
  ld a, (_RAM_DDCE_)
  sub l
  ld (_RAM_DDCE_), a
  ld a, (_RAM_DDD1_)
  sub l
  ld (_RAM_DDD1_), a
  ld a, (_RAM_DDD4_)
  sub l
  ld (_RAM_DDD4_), a
  ld a, (_RAM_DDD7_)
  sub l
  ld (_RAM_DDD7_), a
  ld a, (_RAM_DDDA_)
  sub l
  ld (_RAM_DDDA_), a
  ld a, (_RAM_DDDD_)
  sub l
  ld (_RAM_DDDD_), a
  ld a, (_RAM_DDFE_)
  sub l
  ld (_RAM_DDFE_), a
  ld a, (_RAM_DE01_)
  sub l
  ld (_RAM_DE01_), a
  ld a, (_RAM_DE04_)
  sub l
  ld (_RAM_DE04_), a
  ld a, (_RAM_DE07_)
  sub l
  ld (_RAM_DE07_), a
  ld a, (_RAM_DE0A_)
  sub l
  ld (_RAM_DE0A_), a
  ld a, (_RAM_DE0D_)
  sub l
  ld (_RAM_DE0D_), a
LABEL_37A18_:
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBA9_)
  add hl, de
  ld (_RAM_DBA9_), hl
  ret

LABEL_37A23_:
  ld a, (_RAM_D5A6_)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.57.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.57.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.58.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.58.x), a
+:
  ld a, (_RAM_DCEA_)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.59.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.59.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.60.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.60.x), a
+:
  ld a, (_RAM_DD2B_)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.61.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.62.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.62.x), a
+:
  ld a, (_RAM_DD6C_)
  or a
  jr z, LABEL_37A18_
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.63.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.64.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.64.x), a
  jr LABEL_37A18_

LABEL_37A75_:
  ld a, (_RAM_D5A6_)
  or a
  jp z, LABEL_37B6B_
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  cp $1A
  jp nc, LABEL_37B49_
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_D5A8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_D5A8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_
  ld a, (_RAM_D5A7_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld c, a
  ld hl, DATA_40E5_Sign_
  ld a, (_RAM_D5A7_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (ix+0)
  sub c
  ld (ix+0), a
  jr ++

+:
  ld a, (ix+0)
  add a, c
  ld (ix+0), a
++:
  cp $F8
  jr nc, LABEL_37B35_
  ld hl, DATA_3FD3_
  ld a, (_RAM_D5A7_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld c, a
  ld hl, DATA_40F5_Sign_
  ld a, (_RAM_D5A7_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (iy+0)
  sub c
  ld (iy+0), a
  jp ++

+:
  ld a, (iy+0)
  add a, c
  ld (iy+0), a
++:
  cp $F8
  jr nc, LABEL_37B35_
  call LABEL_37BEF_
-:
  ld a, (_RAM_D5A6_)
  inc a
  ld (_RAM_D5A6_), a
  cp $25
  jr nz, +
  ld a, SFX_04_TankMiss
  ld (_RAM_D963_SFXTrigger_Player1), a
LABEL_37B35_:
  xor a
  ld (_RAM_D5A6_), a
  ld (ix+0), a
  ld (iy+0), a
  ld (ix+2), a
  ld (iy+1), a
  ret

+:
  jp LABEL_37F92_

LABEL_37B49_:
  sub $1A
  ld e, a
  ld d, $00
  ld hl, DATA_37B5E_
  add hl, de
  ld a, (hl)
  ld (ix+1), a
  ld a, $AC
  ld (ix+3), a
  jp -

; Data from 37B5E to 37B6A (13 bytes)
DATA_37B5E_:
.db $A0 $A0 $A0 $A1 $A1 $A1 $A2 $A2 $A2 $A3 $A3 $A3 $AC

LABEL_37B6B_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, ++
  ld a, (_RAM_D5AB_)
  cp $A0
  JrNzRet _LABEL_37BEE_ret
+:
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK | BUTTON_2_MASK ; $30
  JrNzRet _LABEL_37BEE_ret
++:
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_37BEE_ret
  ld a, (_RAM_DF58_)
  or a
  JrNzRet _LABEL_37BEE_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_37BEE_ret
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_D5A7_), a
  ld a, (_RAM_DE92_EngineVelocity)
  add a, $06
  and $0F
  ld (_RAM_D5A8_), a
  ld a, $01
  ld (_RAM_D5A6_), a
  ld a, SFX_0A_TankShoot
  ld (_RAM_D963_SFXTrigger_Player1), a
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  ld (ix+1), $AD
  ld (ix+3), $AE
  ld hl, DATA_37C0A_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA4_)
  add a, l
  ld (ix+0), a
  ld hl, DATA_37C1A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA5_)
  add a, l
  ld (iy+0), a
_LABEL_37BEE_ret:
  ret

LABEL_37BEF_:
  ld a, (_RAM_D5A6_)
  ld e, a
  ld d, $00
  ld hl, DATA_37C2A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+0)
  add a, l
  ld (ix+2), a
  ld a, (iy+0)
  add a, l
  ld (iy+1), a
  ret

; Data from 37C0A to 37C19 (16 bytes)
DATA_37C0A_:
.db $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03 $00 $03 $05 $08

; Data from 37C1A to 37C29 (16 bytes)
DATA_37C1A_:
.db $00 $03 $05 $08 $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03

; Data from 37C2A to 37C44 (27 bytes)
DATA_37C2A_:
.db $00 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $0F $0E $0D $0C $0B
.db $0A $09 $08 $07 $06 $05 $04 $03 $02 $01 $00

LABEL_37C45_:
  ld ix, _RAM_DCAB_CarData_Green
  ld iy, _RAM_DA60_SpriteTableXNs.59
  jr ++

LABEL_37C4F_:
  ld ix, _RAM_DCEC_CarData_Blue
  ld iy, _RAM_DA60_SpriteTableXNs.61
  jr ++

LABEL_37C59_:
  ld a, (_RAM_D5AB_)
  cp $A0
  jr z, +
  inc a
  ld (_RAM_D5AB_), a
  ret

+:
  ld ix, _RAM_DD2D_CarData_Yellow
  ld iy, _RAM_DA60_SpriteTableXNs.63
++:
  ld a, (ix+63)
  or a
  jp z, LABEL_37D9C_
  cp $1A
  jp nc, LABEL_37D87_
  ld hl, DATA_1D65__Lo
  ld a, (ix+64)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (ix+64)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_
  ld a, (ix+62)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld c, a
  ld hl, DATA_40E5_Sign_
  ld a, (ix+62)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (iy+0)
  sub c
  ld (iy+0), a
  jr ++

+:
  ld a, (iy+0)
  add a, c
  ld (iy+0), a
++:
  cp $F8
  jr nc, LABEL_37D49_
  ld (_RAM_D5A9_), iy
  ld a, (ix+45)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  jr +++

+:
  ld iy, _RAM_DAE0_SpriteTableYs.61
  jr +++

++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
+++:
  ld hl, DATA_3FD3_
  ld a, (ix+62)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ld c, a
  ld hl, DATA_40F5_Sign_
  ld a, (ix+62)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (iy+0)
  sub c
  ld (iy+0), a
  jr ++

+:
  ld a, (iy+0)
  add a, c
  ld (iy+0), a
++:
  cp $F8
  jr nc, LABEL_37D49_
  call LABEL_37E62_
LABEL_37D33_:
  ld a, (ix+63)
  inc a
  ld (ix+63), a
  cp $25
  jr nz, LABEL_37D84_
  ld a, (ix+21)
  or a
  jr z, LABEL_37D49_
  ld a, SFX_04_TankMiss
  ld (_RAM_D974_SFXTrigger_Player2), a
LABEL_37D49_:
  xor a
  ld (ix+63), a
  ld a, (ix+45)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  ld ix, _RAM_DA60_SpriteTableXNs.59
  jp +++

+:
  ld iy, _RAM_DAE0_SpriteTableYs.61
  ld ix, _RAM_DA60_SpriteTableXNs.61
  jp +++

++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
  ld ix, _RAM_DA60_SpriteTableXNs.63
+++:
  xor a
  ld (ix+0), a
  ld (ix+2), a
  ld (iy+0), a
  ld (iy+1), a
  ret

LABEL_37D84_:
  jp LABEL_37E81_

LABEL_37D87_:
  sub $1A
  ld e, a
  ld d, $00
  ld hl, DATA_37B5E_
  add hl, de
  ld a, (hl)
  ld (iy+1), a
  ld a, $AC
  ld (iy+3), a
  jp LABEL_37D33_

LABEL_37D9C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, ++
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, ++
+:
  ld a, (_RAM_DB21_Player2Controls) ; If 1+2 are pressed, skip the rest
  and BUTTON_1_MASK | BUTTON_2_MASK ; $30
  JpNzRet _LABEL_37E61_ret
++:
  ld a, (_RAM_DE4F_)
  cp $80
  JpNzRet _LABEL_37E61_ret
  ld a, (ix+21)
  or a
  JpZRet _LABEL_37E61_ret
  ld a, (ix+46)
  or a
  JpNzRet _LABEL_37E61_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (ix+17)
  cp $E0
  JpNcRet _LABEL_37E61_ret
  cp $20
  JpCRet _LABEL_37E61_ret
  ld a, (ix+18)
  cp $20
  JpCRet _LABEL_37E61_ret
  cp $E0
  JpNcRet _LABEL_37E61_ret
  jr ++

+:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_37E61_ret
++:
  ld a, (ix+13)
  ld (ix+62), a
  ld a, (ix+11)
  add a, $06
  and $0F
  ld (ix+64), a
  ld a, $01
  ld (ix+63), a
  ld a, (ix+21)
  or a
  jr z, +
  ld a, SFX_0A_TankShoot
  ld (_RAM_D974_SFXTrigger_Player2), a
+:
  ld (iy+1), $AD
  ld (iy+3), $AE
  ld hl, DATA_37C0A_
  ld a, (ix+13)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+17)
  add a, l
  ld (iy+0), a
  ld (_RAM_D5A9_), iy
  ld a, (ix+45)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  jr +++

+:
  ld iy, _RAM_DAE0_SpriteTableYs.61
  jr +++

++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
+++:
  ld hl, DATA_37C1A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+18)
  add a, l
  ld (iy+0), a
_LABEL_37E61_ret:
  ret

LABEL_37E62_:
  ld a, (ix+63)
  ld e, a
  ld d, $00
  ld hl, DATA_37C2A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (iy+0)
  add a, l
  ld (iy+1), a
  ld iy, (_RAM_D5A9_)
  ld a, (iy+0)
  add a, l
  ld (iy+2), a
  ret

LABEL_37E81_:
  ld a, (ix+45)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_37F11_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_37F11_
  ld de, _RAM_DA60_SpriteTableXNs.59
  ld bc, _RAM_DAE0_SpriteTableYs.59
  jp +++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_37F3A_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_37F3A_
  ld de, _RAM_DA60_SpriteTableXNs.61
  ld bc, _RAM_DAE0_SpriteTableYs.61
  jp +++

++:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_37F69_
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_37F69_
  ld de, _RAM_DA60_SpriteTableXNs.63
  ld bc, _RAM_DAE0_SpriteTableYs.63
+++:
  ld a, (_RAM_DF58_)
  or a
  JrNzRet +++
  ld a, (_RAM_DBA4_)
  ld l, a
  ld a, (de)
  sub l
  JrCRet +++
  cp $18
  JrNcRet +++
  ld a, (_RAM_DBA5_)
  ld l, a
  ld a, (bc)
  sub l
  JrCRet +++
  cp $18
  JrNcRet +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  call ++
  ld a, $01
  ld (_RAM_D5BD_), a
  jp LABEL_29BC_Behaviour1_FallToFloor

+:
  call LABEL_2934_BehaviourF
++:
  xor a
  ld (_RAM_DD2B_), a
  ld (_RAM_DA60_SpriteTableXNs.61.x), a
  ld (_RAM_DAE0_SpriteTableYs.61.y), a
  ld (_RAM_DA60_SpriteTableXNs.62.x), a
  ld (_RAM_DAE0_SpriteTableYs.62.y), a
+++:ret

LABEL_37F11_:
  ld a, (ix+21)
  or a
  JrZRet +
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.59.x)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.59.y)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  call LABEL_2961_
  jp LABEL_37D49_

.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_37F3A_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet +
  ld a, (ix+21)
  or a
  JrZRet +
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.61.y)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  call LABEL_2961_
  jp LABEL_37D49_

.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_37F69_:
  ld a, (ix+21)
  or a
  JrZRet +
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  call LABEL_2961_
  jp LABEL_37D49_

.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_37F92_:
  ld ix, _RAM_DCEC_CarData_Blue
  call +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet _LABEL_37FF7_ret
  ld ix, _RAM_DCAB_CarData_Green
  call +
  ld ix, _RAM_DD2D_CarData_Yellow
+:
  ld a, (ix+46)
  or a
  JrNzRet _LABEL_37FF7_ret
  ld a, (ix+21)
  or a
  JrZRet _LABEL_37FF7_ret
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.57.x)
  sub l
  JrCRet _LABEL_37FF7_ret
  cp $18
  JrNcRet _LABEL_37FF7_ret
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.57.y)
  sub l
  JrCRet _LABEL_37FF7_ret
  cp $18
  JrNcRet _LABEL_37FF7_ret
  ld a, (ix+45)
  cp $01
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  call LABEL_4DD4_
  jr ++

+:
  call LABEL_2961_
++:
  ld ix, _RAM_DA60_SpriteTableXNs.57.x
  ld iy, _RAM_DAE0_SpriteTableYs.57.y
  jp LABEL_37B35_

_LABEL_37FF7_ret:
  ret

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF
.db $FF $00 $00
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 14
.ORG $0000
;.section "Bank 14"

DATA_38000_TurboWheels_Tiles:
.incbin "Assets/Turbo Wheels/Tiles.compressed"

DATA_39168_Tanks_Tiles:
.incbin "Assets/Tanks/Tiles.compressed"

DATA_39C83_FourByFour_Tiles:
.incbin "Assets/Four By Four/Tiles.compressed"

DATA_3A8FA_Warriors_Tiles:
.incbin "Assets/Warriors/Tiles.compressed"

DATA_3B32F_DisplayCaseTilemapCompressed:
.incbin "Assets/Menu/DisplayCase.tilemap.compressed"

DATA_3B37F_Tiles_DisplayCase:
.incbin "Assets/Menu/DisplayCase.3bpp.compressed"

LABEL_3B971_RamCodeLoaderStage2:
  ; Copy more code into RAM...
  ld hl, LABEL_3B97D_RamCodeStart  ; Loading Code into RAM
  ld de, _RAM_D7BD_RamCode
  ld bc, LABEL_3BD0F_RamCodeEnd - LABEL_3B97D_RamCodeStart ; A lot! 914 bytes
  ldir
  ret

LABEL_3B97D_RamCodeStart:

; Executed in RAM at d7bd
LABEL_3B97D_DecompressFromHLToC000:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741 ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
  ld de, _RAM_C000_DecompressionTemporaryBuffer
  CallRamCode LABEL_3B989_Decompress
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at d7c9
; This is a copy (!) of the code at LABEL_7B21_Decompress
LABEL_3B989_Decompress:
.include "decompressor.asm"

; This is RAM data (!) for the menu music engine
; TODO document it
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $07 $0F $0F $0F $0F $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00

; Executed in RAM at d931
LABEL_3BAF1_MenusVBlank:
  push af
  push bc
  push de
  push hl
  push ix
  push iy
    ld a, (_RAM_D6D4_Slideshow_PendingLoad)
    cp $00
    jr z, + ; almost always the case
    ld a, ($BFFF) ; Last byte of currently mapped page is (usually) the bank number
    ld (_RAM_D742_VBlankSavedPageIndex), a ; save
    ld a, :LABEL_30D36_MenuMusicFrameHandler
    ld (PAGING_REGISTER), a
    call LABEL_30D36_MenuMusicFrameHandler
    ld a, (_RAM_D742_VBlankSavedPageIndex)
    ld (PAGING_REGISTER), a
+:  ld a, 1
    ld (_RAM_D6D3_VBlankDone), a
    in a, (PORT_VDP_STATUS) ; ack INT
  pop iy
  pop ix
  pop hl
  pop de
  pop bc
  pop af
  ei
  reti

; Executed in RAM at d966
LABEL_3BB26_Trampoline_MenuMusicFrameHandler:
  ld a, :LABEL_30D36_MenuMusicFrameHandler
  ld (PAGING_REGISTER), a
  call LABEL_30D36_MenuMusicFrameHandler
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at d971
LABEL_3BB31_Emit3bppTileDataToVRAM:
; hl = source
; de = count of rows (3 bytes data => 1 row of pixels in a tile) to emit
; Write address must be set
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at d974
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir          ; Emit 3 bytes
  xor a
  out (PORT_VDP_DATA), a  ; Fourth = 0
  dec de
  ld a, d
  or e
  jr nz, -
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at d985
LABEL_3BB45_Emit3bppTileDataToVRAM:
; hl = source
; e = count of rows (3 bytes = 1 row of pixels in a tile) to emit
; Write address must be set
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at d988
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA), a
  dec e
  jr nz, -
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at d997
LABEL_3BB57_EmitTilemapRectangle:
; hl = data address
; de = VRAM address, must be already set
; Parameters in RAM
; Tile index $ff is converted to the blank tile from the font at index $0e
; - but if the high bit is set, it needs to be blank at $10e too...
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at d99a
--:
  ld a, (_RAM_D69D_EmitTilemapRectangle_Width)
  ld c, a
  ld a, (_RAM_D69F_EmitTilemapRectangle_IndexOffset)
  ld b, a
; Executed in RAM at d9a2
-:
  ld a, (hl)          ; Read data
  cp $FF
  jr nz, +
  ld a, <MenuTileIndex_Font.Space ; $ff -> $0e (blank tile)
  JumpToRamCode ++
+:add a, b            ; Else add offset
; Executed in RAM at d9ad
++:
  out (PORT_VDP_DATA), a        ; Emit tile index
  ld a, (_RAM_D69C_TilemapRectangleSequence_Flags)
  out (PORT_VDP_DATA), a        ; And flags/high bit
  inc hl
  dec c               ; repeat for width
  jr nz, -
  ld a, (_RAM_D69E_EmitTilemapRectangle_Height)  ; Decrement row counter
  sub $01
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  jr z, +
  ld a, e             ; Move VRAM pointer on
  add a, $40
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  CallRamCode LABEL_3BCC0_VRAMAddressToDE
  JumpToRamCode --

+: ; Done
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at d9d3
; No need to be in VRAM? (RAM to VRAM)
LABEL_3BB93_Emit3bppTiles_2Rows:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
.repeat 2
  ld c, $03
  ; 3 bytes data
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  inc de
  dec c
  jr nz, -
  ; 1 byte padding
  xor a
  out (PORT_VDP_DATA), a
  inc de
.endr
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at d9f5
LABEL_3BBB5_PopulateSpriteNs:
  ld a, :DATA_2B33E_SpriteNs_Hand
  ld (_RAM_D741_RequestedPageIndex), a
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ld de, _RAM_D701_SpriteN
  ld bc, 24
-:ld a, (hl)
  cp $FF
  jr nz, +
  ld a, $53
+:add a, $BB ; 0+ map to $bb+, -1 maps to $53
  ld (de), a
  inc hl
  inc de
  dec c
  jr nz, -
  CallRamCode LABEL_3BD08_BackToSlot2
  jp LABEL_93CE_UpdateSpriteTable

; Executed in RAM at da18
LABEL_3BBD8_EmitTilemapUnknown2:
; hl = source
; e = entry count
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
  ld b, $00
--:
  ld c, PORT_VDP_DATA
-:ld a, (hl) ; Get byte
  out (c), a ; Emit, high byte 1
  ld a, $01
  out (c), a
  inc hl
  dec e       ; Counter
  jr z, +
  ld a, e
  and $1F     ; When we reach a multiple of 32, add $30 to the source pointer
  jr nz, -
  ld c, $30
  add hl, bc
  JumpToRamCode --

+: ; done
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at da38
LABEL_3BBF8_EmitTilemapUnknown:
; hl = source
; de = dest VRAM address
; b = entry count
; c = width?
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
--:
  CallRamCode LABEL_3BCC0_VRAMAddressToDE
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  EmitDataToVDPImmediate8 1 ; High tileset
  inc hl
  inc de
  inc de
  dec b
  jr z, + ; done
  dec c
  jr nz, -
  ; Add $2a to de -> 21 entries on
  ld a, e
  add a, $2A
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ; Set c to 11???
  ld c, $0B
  ; Add $27 to hl -> ???
  ld a, l
  add a, $27
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  JumpToRamCode --

+:CallRamCode LABEL_3BD08_BackToSlot2
  ret

LABEL_3BC27_EmitThirty3bppTiles:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ld e, 30 * 8 ; Row count - 30 tiles
-:ld b, $03 ; bit depth
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA), a
  dec e
  jr nz, -
  CallRamCode LABEL_3BD08_BackToSlot2
  ret

; Executed in RAM at da7c
LABEL_3BC3C_EmitFifteen3bppTiles:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ld e, $78 ; 15 tiles
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA),a
  dec e
  jr nz, -
  ld (_RAM_D6A6_DisplayCase_Source), hl
  JumpToRamCode LABEL_3BD08_BackToSlot2

LABEL_3BC53_EmitTen3bppTiles:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ld e, $50 ; 10 tiles
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA),a
  dec e
  jr nz, -
  ld (_RAM_D6A6_DisplayCase_Source), hl
  JumpToRamCode LABEL_3BD08_BackToSlot2


LABEL_3BC6A_EmitText: ; Executed in RAM at $daaa
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  rlc a
  and $01
  out (PORT_VDP_DATA), a
  inc hl
  dec c
  jr nz, -
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at dabd
LABEL_3BC7D_DisplayCase_RestoreRectangle:
; Restores tilemap data from hl to de (must be already set)
; 5 tiles wide rectangles from 22 tiles wide source data
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
--:
  ld c, $05   ; Width
-:ld a, (hl) ; Emit a byte from (hl), high tileset
  out (PORT_VDP_DATA), a
  EmitDataToVDPImmediate8 1 ; high tileset
  inc hl
  dec c
  jr nz, - ; Loop over row
  ld a, (_RAM_D69E_EmitTilemapRectangle_Height) ; Decrement row counter
  sub $01
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  jr z, + ;$bcad         ; When done

  ; Add $0011 to hl -> skip to next row in 22 tile wide data
  ld a, l
  add a, $11
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ; Add $40 to de -> next row
  ld a, e
  add a, $40
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  CallRamCode LABEL_3BCC0_VRAMAddressToDE
  JumpToRamCode --

  ; When done...
+:jr LABEL_3BD08_BackToSlot2

; Executed in RAM at $daef
LABEL_03BCAF_Emit3bppTiles:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
  ; Emit 3bpp tile data for e bytes
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA), a ; Zero-padded
  dec e
  jr nz, -
  jr LABEL_3BD08_BackToSlot2

; Executed in RAM at db00
LABEL_3BCC0_VRAMAddressToDE:
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ret

; Executed in RAM at db07
LABEL_3BCC7_VRAMAddressToHL:
  ld a, l
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ret

.ifdef UNNECESSARY_CODE
LABEL_3BCCE_ReadPagedByte_de: ; unused?
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ld a, (de)          ; 03BCD1 1A
  JumpToRamCode LABEL_3BCFC_RestorePagingPreserveA

LABEL_3BCD5_ReadPagedByte_bc: ; unused?
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ld a, (bc)          ; 03BCD8 0A
  JumpToRamCode LABEL_3BCFC_RestorePagingPreserveA
.endif

; Executed in RAM at db1c
LABEL_3BCDC_Trampoline2_PlayMenuMusic:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
  ld a, c
  call LABEL_30CE8_PlayMenuMusic
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at db26
LABEL_3BCE6_Trampoline_StopMenuMusic:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
  call LABEL_30D28_StopMenuMusic
  JumpToRamCode LABEL_3BD08_BackToSlot2

.ifdef UNNECESSARY_CODE
LABEL_3BCEF_Trampoline_Unknown: ; unused?
  CallRamCode LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from LABEL_3BCF5_RestorePagingFromD741
  jp $a003 ; Bad destination at $3a003
.endif

; Executed in RAM at db35
LABEL_3BCF5_RestorePagingFromD741:
  ld a, (_RAM_D741_RequestedPageIndex)
  ld (PAGING_REGISTER), a
  ret

.ifdef UNNECESSARY_CODE
LABEL_3BCFC_RestorePagingPreserveA:
; Restores paging to slot 2 without losing the value in a
  ld (_RAM_D743_ReadPagedByteTemp),a
  ld a, $02
  ld (PAGING_REGISTER),a
  ld a, (_RAM_D743_ReadPagedByteTemp)
  ret
.endif

; Executed in RAM at db48
LABEL_3BD08_BackToSlot2:
  ld a, $02
  ld (PAGING_REGISTER), a
  ret

.ifdef UNNECESSARY_CODE
; Extra byte picked up by RAM code copier...
.db $00
.endif

LABEL_3BD0F_RamCodeEnd:

.ifdef BLANK_FILL_ORIGINAL
.repeat 188
.db $FF $FF $00 $00
.endr
.endif
;.ends

.orga $bfff
.db :CADDR ; Page number marker

.BANK 15
.ORG $0000
;.section "Bank 15"

DATA_3C000_Sportscars_Tiles:
.incbin "Assets/Sportscars/Tiles.compressed" ; bitplane-split 3bpp

DATA_3CD8D_RuffTrux_Tiles:
.incbin "Assets/RuffTrux/Tiles.compressed" ; bitplane-split 3bpp

DATA_3D901_Powerboats_Tiles:
.incbin "Assets/Powerboats/Tiles.compressed" ; bitplane-split 3bpp

DATA_3E5D7_Tiles_MediumLogo:
.incbin "Assets/Menu/Logo-Medium.3bpp.compressed" ; bitplane-split 3bpp

DATA_3EC67_Tiles_MediumLogo:
.incbin "Assets/Menu/Logo-Medium.tilemap.compressed"

DATA_3ECA9_VehicleNames:
TEXT_3ECA9_Vehicle_Name_Blank:
.asc "                "
TEXT_3ECB9_Vehicle_Name_Sportscars:
.asc "   SPORTSCARS   "
TEXT_3ECC9_Vehicle_Name_Powerboats:
.asc "   POWERBOATS   "
TEXT_3ECD9_Vehicle_Name_Formula_One:
.asc "  FORMULA  ONE  "
TEXT_3ECE9_Vehicle_Name_Four_By_Four:
.asc "  FOUR BY FOUR  "
TEXT_3ECF9_Vehicle_Name_Warriors:
.asc "    WARRIORS    "
TEXT_3ED09_Vehicle_Name_Choppers:
.asc "    CHOPPERS    "
TEXT_3ED19_Vehicle_Name_Turbo_Wheels:
.asc "  TURBO WHEELS  "
TEXT_3ED29_Vehicle_Name_Tanks:
.asc "      TANKS     "
TEXT_3ED39_Vehicle_Name_Rufftrux:
.asc "    RUFFTRUX    "
;.ends

;.section "Splash screen" force
DATA_3ED49_SplashScreenCompressed:
.incbin "Assets/SplashScreen/SplashScreen.compressed"
;.ends

;.section "Jon's Squinky Tennis" force
DATA_3F753_JonsSquinkyTennisCompressed:
.incbin "Assets/JonsSquinkyTennis.compressed"
;.ends

.ifdef BLANK_FILL_ORIGINAL
;.section "Bank 15 blank fill" force
; Blank fill
.repeat 33
.dw $0000, $ffff
.endr
.dw $0000
;.ends
.endif

.orga $bfff
.db :CADDR ; Page number marker

