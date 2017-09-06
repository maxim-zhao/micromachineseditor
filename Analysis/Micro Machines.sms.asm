; Some options for what we want to keep identical to the original...
.define BLANK_FILL_ORIGINAL ; disable to squash blanks and blank unused bytes - BUGGY
.define UNNECESSARY_CODE ; disable to drop out the unreachable code and code that does nothing - BUGGY
.define JUMP_TO_RET ; disable to use conditional rets
.define TAIL_CALL ; disable to optimise calls followed by rets to jumps - INCOMPLETE
.define AVOID_INC_DEC ; disable to use inc, dec opcodes
.define COMPARE_TO_ZERO ; disable to use or a instead of cp 0
.define GAME_GEAR_CHECKS ; disable to replace runtime Game Gear handling with compile-time - INCOMPLETE
.define IS_GAME_GEAR ; Only applies when GAME_GEAR_CHECKS is disabled - INCOMPLETE

; Some constants
.define INFINITE_LIVES_COUNT 5 ; Number of lives we fix at
.define WINS_IN_A_ROW_FOR_RUFFTRUX 3 ; Number of wins in a row to get RuffTrux
.define RUFFTRUX_LAP_COUNT 1 ; Number of laps to complete
.define CHALLENGE_LAP_COUNT 3 ; Number of laps to complete
.define LOWEST_PITCH_ENGINE_TONE 1000
.define HIGHEST_PITCH_ENGINE_TONE 400
.define MAX_ENGINE_VOLUME 10 ; Player volume is always here
.define MAX_OPPONENT_SPEED $0d ; when applying increases to speed data

.define DUST_MINIMUM_VELOCITY 7 ; Speed at which dust may appear

.define TANK_SHOT_RELATIVE_SPEED 6 ; Speed at which a tank shot moves relative to the player's tank
.define TANK_SHOT_COUNTER_GROUND 26 ; Number of frames before it hits the ground
.define TANK_SHOT_COUNTER_END 37 ; Number of frames before it's finished
.define MAXIMUM_SPEED_MASK 15 ; can't exceed this

.define HEAD_TO_HEAD_TEXT_X 112 ; Where the text "BONUS", "WINNER", "PLAYOFF" appears (x)
.define HEAD_TO_HEAD_TOTAL_POINTS 8

.define CHEAT_EXTRA_LIVES_COUNT 5 ; How many lives the cheat sets you to
.define CHEAT_LEAD_CAR_VALUE $0d ; The "weight" when you have a "lead car"

.define HUD_SPRITE_COUNT 9
.define HUD_X_GG $38
.define HUD_Y_GG $30
.define HUD_X_SMS 16
.define HUD_Y_SMS 8

.define TANK_SPEED_THROUGH_CHESSBOARD 3
.define SPEED_THROUGH_JUMP 12

.define SKID_DURATION_DEFAULT 16
.define SKID_DURATION_WARRIORS 8

.define JUMP_MAX_CURVE_INDEX 130 ; Maximum index to look up into DATA_1B232_JumpCurveTable

.define CRASH_BOUNCE_MINIMUM_SPEED 4 ; Belwo this speed, crashes into walls make you stop

.define POWERBOATS_BUBBLES_PUSH_COUNTER_MASK $7 ; Mask for counter, controls deceleration rate
.define POWERBOATS_BUBBLES_DECELERATION_TARGET_SPEED 6 ; We decelerate while faster than this

.define SLOWER_DIAGONALS ; Undefine to (approximately) maintain speed when driving at an angle

.define LAYOUT_INDEX_MASK %00111111 ; Bits for metatile index from data
.define LAYOUT_EXTRA_MASK %11000000 ; Extra bits

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
TT_8_Choppers     db ; 8 - Incomplete support
TT_9_Unknown      db ; 9 - for portrait drawing only?
.ende

.enum 0 ; Track types, in menus
MenuTT_0_Blank        db ; 0
MenuTT_1_SportsCars   db ; 1
MenuTT_2_Powerboats   db ; 2
MenuTT_3_FormulaOne   db ; 3
MenuTT_4_FourByFour   db ; 4
MenuTT_5_Warriors     db ; 5
MenuTT_6_Choppers     db ; 6 - not used
MenuTT_7_TurboWheels  db ; 7
MenuTT_8_Tanks        db ; 8
MenuTT_9_RuffTrux     db ; 9
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
Track_0A_ThePottedPassage         db ; Chopper!
Track_0B_FruitJuiceFollies        db
Track_0C_FoamyFjords              db
Track_0D_BedroomBattlefield       db
Track_0E_PitfallPockets           db
Track_0F_PencilPlateaux           db
Track_10_TheDareDevilDunes        db
Track_11_TheShrubberyTwist        db ; Chopper!
Track_12_PerilousPitStop          db
Track_13_WideAwakeWarZone         db
Track_14_CrayonCanyons            db
Track_15_SoapLakeCity             db
Track_16_TheLeafyBends            db ; Chopper!
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

.enum 0 ; Menu screens
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

.enum 0 ; Menu indexes
MenuIndex_0_TitleScreen db
MenuIndex_1_QualificationResults db
MenuIndex_2_FourPlayerResults db
MenuIndex_3_LifeWonOrLost db
MenuIndex_4_TwoPlayerResults db
MenuIndex_5 db
MenuIndex_6 db
.ende

.enum 0 ; Life won or lost mode
LifeWonOrLostMode_LifeLost db
LifeWonOrLostMode_GameOver db
LifeWonOrLostMode_RuffTruxWon db
LifeWonOrLostMode_RuffTruxLost db
.ende

.enum 0 ; SFX
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
SFX_11_Powerboats_HitWater db ; Hit ground?
SFX_12_WinOrCheat db
SFX_13_HeadToHeadWinPoint db
SFX_14_Playoff db ; Playoff
SFX_15_HitFloor db ; Hit floor, explode
SFX_16_Respawn db ; Appear?
.ende

.enum 1 ; Music tracks
Music_01_TitleScreen                db ; Title screen
Music_02_CharacterSelect            db ; Who do you want to be?
Music_03_Ending                     db ; Tournament Champion!
Music_04_Silence                    db ; (Stop music)
Music_05_RaceStart                  db ; Smoke On The Water (race start)
Music_06_Results                    db ; Qualified, results
Music_07_Menus                      db ; Menus
Music_08_GameOver                   db ; Game Over
Music_09_PlayerOut                  db ; Someone is out
Music_0A_LostLife                   db ; One life lost
Music_0B_TwoPlayerResult            db ; Tournament results
Music_0C_TwoPlayerTournamentWinner  db ; Tournament champion
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
SpriteIndex_Decorators          instanceof FourPlayers_InGame ; $190
SpriteIndex_HUDStart            .db   ; $194
SpriteIndex_PositionIndicators  instanceof FourPlayers_InGame ; $194
SpriteIndex_SuffixSt            db    ; $198
SpriteIndex_SuffixNd            db    ; $199
SpriteIndex_SuffixRd            db    ; $19a
SpriteIndex_SuffixTh            db    ; $19b
SpriteIndex_FinishedIndicators  instanceof FourPlayers_InGame ; $19c
SpriteIndex_Smoke               dsb 4 ; $1a0
SpriteIndex_Digit1              db    ; $1a4
SpriteIndex_Digit2              db    ; $1a5
SpriteIndex_Digit3              db    ; $1a6 
SpriteIndex_Digit4              db    ; $1a7
SpriteIndex_Shadow              dsb 4 ; $1a8
SpriteIndex_Blank               db    ; $1ac
SpriteIndex_PerVehicleEffects   .db   ; $1ad
SpriteIndex_Dust                dsb 3 ; $1ad..$1af for non-tanks
SpriteIndex_Splash              dsb 3 ; $1b0
SpriteIndex_FallingCar          dsb 4 ; $1b3 2x2 tiles
SpriteIndex_FallingCar2         db    ; $1b7 1x1 tiles
.ende

; Replacements for tracks with water instead of floor
; Sprites are used in positions:
; A A
; BDB
; CEC
.enum SpriteIndex_FallingCar
SpriteIndex_SubmergedCar_FrontWheel       db ; $b3 
SpriteIndex_SubmergedCar_BackWheel_Front  db ; $b4
SpriteIndex_SubmergedCar_BackWheel_Back   db ; $b5 
SpriteIndex_SubmergedCar_Body_Front       db ; $b6 
SpriteIndex_SubmergedCar_Body_Back        db ; $b7 
.ende

; Replacements for tanks
.enum SpriteIndex_Dust
SpriteIndex_Bullet              db    ; $ad for tanks
SpriteIndex_BulletShadow        db    ; $ae for tanks
SpriteIndex_Blank_Unused        db    ; $af for tanks
.ende

; Replacements for head to head mode
.enum SpriteIndex_HUDStart
SpriteIndex_RedBall               db    ; $94
SpriteIndex_BlueBall              db    ; $95
SpriteIndex_Winner                dsb 6 ; $96
SpriteIndex_Bonus_Part1           dsb 4 ; $9c
SpriteIndex_Smoke_Mirror          dsb 4 ; $a0 same as above
SpriteIndex_Bonus_Part2           dsb 2 ; $a4
SpriteIndex_HeadToHeadLapCounter  db    ; $a6
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
.define SpriteIndex_RuffTrux_Shadow1  11 ; $0B
.define SpriteIndex_RuffTrux_Shadow2  24 ; $18
.define SpriteIndex_RuffTrux_Shadow3  27 ; $1B
.define SpriteIndex_RuffTrux_Blank   104 ; $68
.define SpriteIndex_RuffTrux_Dust1   107 ; $6B
.define SpriteIndex_RuffTrux_Dust2   120 ; $78
.define SpriteIndex_RuffTrux_Dust3   123 ; $7B
.define SpriteIndex_RuffTrux_Shadow4 136 ; $88
.define SpriteIndex_RuffTrux_Digit1  139 ; $8B
.define SpriteIndex_RuffTrux_Digit2  152 ; $98
.define SpriteIndex_RuffTrux_Colon   155 ; $9B
.define SpriteIndex_RuffTrux_Digit3  232 ; $E8
.define SpriteIndex_RuffTrux_Water1  235 ; $EB
.define SpriteIndex_RuffTrux_Water2  248 ; $F8
.define SpriteIndex_RuffTrux_Blank2  251 ; $FB

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

.enum 0 ; Metatile behaviours        SportsCars                 FourByFour  Powerboats              TurboWheels         FormulaOne  Warriors    Tanks         RuffTrux   
Behaviour0_Normal             db ;   Table                      Table                                                   Table       Floor
Behaviour1_Fall               db ;   Floor                      Floor                                                   Floor
Behaviour2_Dust               db ;   Chalk                                                          Sand                Chalk       Chalk
Behaviour3_BumpDown           db ;   Red binder, book                                                                                                         Flower beds
Behaviour4_Jump               db ;   Red binder             
Behaviour5_Skid               db ;   Ink                        Milk                                Water edge                      Oil         Card          Water edge
Behaviour6_Bump               db ;   Grey binder, book, ruler   Cereal      Bubbles, soap, bottle   Dune, jump, stones              Nails       Pencils, Lego Bumps, flower beds
Behaviour7_Entry              db ;   Red binder, book
Behaviour8_Sticky             db ;                              Juice                                                               Glue
Behaviour9_PoolTableHole      db ;                                                                                      Hole
BehaviourA_PoolTableCushion   db ;                                                                                      Cushion
BehaviourB_Raised             db ;                              Cereal box                                              Table edge
BehaviourC_RaisedEntry        db ;                              Ramp                                                    Card
BehaviourD_BumpOnEntry        db ;                              Placemat
BehaviourE_RuffTruxWater      db ;                                                                                                                            Water
BehaviourF_Explode            db ;
Behaviour10_Unused            db ;
Behaviour11_Unused            db ;
Behaviour12_Water             db ;                                                                  Water
Behaviour13_Barrier           db ;                                                                                      Cue
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
.repeat count index _x
  .db <(_x * step + start)
.endr
.endm

.macro TimesTableHi args start, step, count
.repeat count index _x
  .db >(_x * step + start)
.endr
.endm

.macro TimesTable16 args start, step, count
.repeat count index _x
  .dw (_x * step + start)
.endr
.endm

.macro DivisionTable args divisor, count
.repeat count index _x
  .db _x / divisor
.endr
.endm

; The game stores some numbers as sign and magnitude bytes.
.macro SignAndMagnitude
  .if \1 < 0
    .redefine _out (-\1) | $80
  .else
    .redefine _out \1
  .endif
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

.macro INC_A
  .ifdef AVOID_INC_DEC
  add a, 1
  .else
  inc a
  .endif
.endm

.macro DEC_A
  .ifdef AVOID_INC_DEC
  sub 1
  .else
  dec a
  .endif
.endm

.macro CP_0
  .ifdef COMPARE_TO_ZERO
  cp 0
  .else
  or a
  .endif
.endm

; These macros allow us to call into RAM code
.macro CallRamCode args address
  call address+_RAM_D7BD_RamCode-LABEL_3B97D_RamCodeStart
.endm
.macro JumpToRamCode args address
  jp address+_RAM_D7BD_RamCode-LABEL_3B97D_RamCodeStart
.endm
.macro CallRamCodeIfZFlag args address
  call z, address+_RAM_D7BD_RamCode-LABEL_3B97D_RamCodeStart
.endm

; Pick the pointer either at runtime or compile time, depending on the flags
.macro GetPointerForSystem args SMSPointer, GGPointer, ComparisonType, Jump1, Jump2
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC54_IsGameGear)
.if ComparisonType == "cp"
  CP_0
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

; Padding helpers
.macro Pad args length
.ifdef BLANK_FILL_ORIGINAL
.dsb length, 0 
.endif
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

.struct SoundChannel
  Attenuation db
  Tone instanceof Word
.endst

.struct SFXData
  Trigger       db ; Index of data to start a new SFX
  Control       db ; 0 = stop, 1 = play, 2 = loop? or stop?
  VolumePointer instanceof Word ; Pointer to volume data bytes, one per frame
  NotePointer   instanceof Word ; Pointer to note data bytes, one per frame
  NoisePointer  instanceof Word ; Pointer to noise data bytes, one per frame
  Noise         db
.endst

.struct EngineSound
  Tone          instanceof Word
  Unused        db ; Seems unused? Not read or written during gameplay
  Volume        db
  Fluctuations  dsb 4
.endst

.struct SpeedLevels
  Highest db ; Only used when >2 metatiles behind player
  High    db ; When >2
  Low     db
  Lowest  db
.endst

.struct TopSpeeds
  Green   instanceof SpeedLevels
  Blue    instanceof SpeedLevels
  Yellow  instanceof SpeedLevels
.endst

.struct CarData
XPosition instanceof Word ; +0 X position in pixels
YPosition instanceof Word ; +2 Y position in pixels
XMetatile db ; +4 X position in metatiles
YMetatile db ; +5 Y position in metatiles
XMetatileRelative db ; +6 X position within metatile (0..12)
Unused07 db ; +7 unused, always 0
YMetatileRelative db ; +8 Y position within metatile (0..12)
Unused09 db ; +9 unused, always 0
CurrentLayoutData db ; +10 The layout data under the car
Unknown11_b_Speed db ; +11
Unknown12_b_Direction db ; +12
Direction db ; +13 Direction (0..15)
Unknown14_b db ; +14 unused?
Unknown15_b db ; +15
Unknown16_b db ; +16
SpriteX db ; +17
SpriteY db ; +18
Unknown19_b db ; +19
Unknown20_b_JumpCurvePosition db ; +20
EffectsEnabled db ; +21
Unknown22_b db ; +22
Unknown23_b db ; +23
CurrentLapProgress db ; +24
LapsRemaining db ; +25
Unknown26_b_HasFinished db ; +26
Unknown27_b db ; +27
Unknown28_b db ; +28
Unknown29_b db ; +29
Unknown30_b db ; +30
Unknown31_b db ; +31
Unknown32_b db ; +32
Unknown33_b db ; +33
Unknown34_w instanceof Word ; +34
Unknown36_b_JumpCurveMultiplier db ; +36 Corresponds to _RAM_DF0A_JumpCurveMultiplier
Unknown37_b db ; +37
Unknown38_b db ; +38 unused?
Unknown39_w instanceof Word ; +39 ; Pointer to something
Unknown41_w instanceof Word ; +41
Unknown43_w instanceof Word ; +43
TankShotSpriteIndex db ; +45
Unknown46_b_ResettingCarToTrack db ; +46 ; Visibility? Controls whether sprite is updated
Unknown47_w instanceof Word ; +47
TopSpeed db ; +49
Unknown50_b db ; +50
Unknown51_b db ; +51
Unknown52_b db ; +52
Unknown53_w instanceof Word ; +53
Unknown55_w instanceof Word ; +55
Unknown57_b db ; +57
Unknown58_b db ; +58
Unknown59_b db ; +59
Unknown60_b db ; +60
Unknown61_b db ; +61
Unknown62_b_ShotDirection db ; +62
Unknown63_b_TankShotState db ; +63 0 = can shoot?
Unknown64_b_ShotSpeed db ; +64
.endst

.struct SpriteData
X db
N db
Y db
.endst

.struct CarEffectSpritePair
  Data instanceof SpriteData 2
.endst

.struct CarEffectState
Enabled db ; Per-item enabled flag
Type    db ; Effect type: 0 = dust, 1 = water
Counter db ; Counter for tile animation
Unused  dsb 3 ; Padding so it's the same size as CarEffectSpritePair
.endst

.struct CarEffects
  ; 3x2 sprite XNY triplets
  Sprites instanceof CarEffectSpritePair 3
  TileBaseIndex db ; Index of first sprite for effect
  Enabled db ; Car "effects" (dust, splashes) enabled flag? 0 -> no effect
  SpriteRotator db ; Selects which "effect" slot is used for which hardware sprite (0..2)
  Direction db ; Car direction
  X db ; Sprite X for car
  Y db ; Sprite Y for car
  DelayCounter db ; Used for timing, effects update every _CarEffectsDelay frames
  NextEffectIndex db ; Selects which "effect" slot is used for the next "effect"?
  States instanceof CarEffectState 3
  NextType db ; The type to use when the current effect ends
  Member45_Enabled2 db
  Member46_JumpCurvePosition db
  Member47_ResettingCarToTrack db
.endst

.struct CarUnknown
  Unknown0_Direction db
  Unknown1 db
  Unknown2_Counter db ; Cycles 0..7
.endst

.enum $C000 export
_RAM_C000_StartOfRam .db
_RAM_C000_DecompressionTemporaryBuffer .db
_RAM_C000_LevelLayout dsb 32 * 32 ; 32x32 metatiles
_RAM_C400_TrackIndexes dsb 32 * 32 ; 32x32 metatile track indexes
_RAM_C800_WallData instanceof WallDataMetaTile 64 ; 64 tiles of 12x12 bits
_RAM_CC80_BehaviourData instanceof BehaviourDataMetaTile 64 ; 64 tiles of 6x6 bytes

_RAM_D580_WaitingForGameVBlank db
_RAM_D581_OverlayTextScrollAmount db
_RAM_D582_ db
_RAM_D583_ db
_RAM_D584_ db ; unused?
_RAM_D585_CurrentMetatileOffset dw ; Distance from start of metatile data to "current"
_RAM_D587_CurrentTrackPositionIndex db ; Track "index" car is in
_RAM_D588_ db ; unused?
_RAM_D589_ db
_RAM_D58A_LowestPitchEngineTone instanceof Word ; GAme won't let it go "lower" (higher value) than this
_RAM_D58C_EngineToneBackup dw ; Some engine tone - backup?
_RAM_D58E_OtherCar_EngineTone instanceof Word ; Not sure what car it is yet
_RAM_D590_Unused_EngineTone dw ; Write-only?
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
_RAM_D5A6_TankShotPosition db
_RAM_D5A7_TankShotDirection db
_RAM_D5A8_ db
_RAM_D5A9_TankShotTileXN dw
_RAM_D5AB_ db
_RAM_D5AC_ dsb 4 ; unused?
_RAM_D5B0_ db
_RAM_D5B1_ dsb 4 ; unused?
_RAM_D5B5_EnableGameVBlank db
_RAM_D5B6_SkidDuration db
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
_RAM_D5E0_TrackSkipThreshold db
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
_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based db ; 1-based track select index, or 0 for null state
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
.ende

; Menu sound data here

.enum $D7B3
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

; These definitions are used in-game
.enum $D800 export
_RAM_D800_TileHighBytes dsb 256 ; 256-aligned
_RAM_D900_UnknownData dsb 64
_RAM_D940_ db
_RAM_D941_ dw
_RAM_D943_ dw
_RAM_D945_ db
_RAM_D946_ db
_RAM_D947_PlayoffWon db
_RAM_D948_ db
_RAM_D949_ db
_RAM_D94A_ db
_RAM_D94B_Unused db
_RAM_D94C_SoundData .db ; 51 bytes total, up to $d97f
_RAM_D94C_SoundChannels instanceof SoundChannel 2
_RAM_D952_EngineSound1ActualTone instanceof BigEndianWord
_RAM_D954_EngineSound2ActualTone instanceof BigEndianWord
_RAM_D956_Sound_ToneEngineSoundsIndex db
_RAM_D957_Sound_ChopperEngineIndex db
_RAM_D958_Sound_LastAttenuation db
_RAM_D959_Unused db
_RAM_D95A_Sound_IsChopperEngine db
_RAM_D95B_EngineSound1 instanceof EngineSound
_RAM_D963_SFX_Player1 instanceof SFXData
_RAM_D96C_EngineSound2 instanceof EngineSound
_RAM_D974_SFX_Player2 instanceof SFXData
_RAM_D97D_Sound_SFXNoiseData db
_RAM_D97E_Player1SFX_Unused db
_RAM_D97F_Player2SFX_Unused db

_RAM_D980_CarDecoratorTileData1bpp dsb 16*8 ; 16 * 1bpp tile data

_RAM_DA00_DecoratorOffsets dsb 32

_RAM_DA20_TrackMetatileLookup dsb 64

_RAM_DA60_SpriteTableXNs instanceof SpriteXN 64
_RAM_DAE0_SpriteTableYs instanceof SpriteY 64

_RAM_DB20_Player1Controls db ; in-game
_RAM_DB21_Player2Controls db
_RAM_DB22_TilemapUpdate_HorizontalTileNumbers dsb $20
_RAM_DB42_TilemapUpdate_VerticalTileNumbers dsb $20
_RAM_DB62_ instanceof Word
_RAM_DB64_ instanceof Word
_RAM_DB66_MetatilesBehindSpeedUpThreshold db
_RAM_DB67_MetatilesAheadSlowDownThreshold db
_RAM_DB68_OpponentTopSpeeds instanceof TopSpeeds
_RAM_DB74_CarTileLoaderTableIndex db
_RAM_DB75_CarTileLoaderDataIndex db
_RAM_DB76_CarTileLoaderPositionIndex db
_RAM_DB77_CarTileLoaderCounter db
_RAM_DB78_CarTileLoaderTempByte db
_RAM_DB79_CarTileLoaderHFlip db
_RAM_DB7A_CarTileLoaderVFlip db
_RAM_DB7B_HeadToHead_RedPoints db
_RAM_DB7C_ db
_RAM_DB7D_ db ; Low bit flipped every 6 frames, never used though?
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
_RAM_DB9C_MetatilemapWidth instanceof Word ; Always 32
_RAM_DB9E_MetatilemapHeight_WriteOnly instanceof Word ; Never used
_RAM_DBA0_TopLeftMetatileX dw
_RAM_DBA2_TopLeftMetatileY dw
_RAM_DBA4_CarX db
_RAM_DBA5_CarY db
_RAM_DBA6_CarX_Next db
_RAM_DBA7_CarY_Next db
_RAM_DBA8_SkipNextGameVBlankVDPUpdate db ; Set to 1 on startup, not sure what purpose it serves?
_RAM_DBA9_ db
_RAM_DBAA_ db
_RAM_DBAB_ db
_RAM_DBAC_ db
_RAM_DBAD_X_ db
_RAM_DBAE_ db
_RAM_DBAF_Y_ db
_RAM_DBB0_ db
_RAM_DBB1_ dw
_RAM_DBB3_ dw
_RAM_DBB5_LayoutByte_ db
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
_RAM_DBF9_CurrentDisplayCaseDataPointer dw
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
_RAM_DC4A_Cheat_ExtraLivesAndLeadCar db
_RAM_DC4B_Cheat_InfiniteLives db
_RAM_DC4C_Cheat_AlwaysFirstPlace db
_RAM_DC4D_Cheat_NoSkidding db
_RAM_DC4E_Cheat_SuperSkids db
_RAM_DC4F_Cheat_EasierOpponents db
_RAM_DC50_Cheat_FasterVehicles db
_RAM_DC51_CheatsEnd .db
_RAM_DC51_PreviousBehaviourByte db ; Only used to allow us to produce _RAM_DC52_PreviousDifferentBehaviourByte
_RAM_DC52_PreviousDifferentBehaviourByte db
_RAM_DC52_ db ; unused?
_RAM_DC54_IsGameGear db ; GG mode if 1, SMS mode if 0
_RAM_DC55_TrackIndex_Game db
_RAM_DC56_Adjustment1_XY db ; Unknown
_RAM_DC57_Adjustment2_XY instanceof Word
_RAM_DC59_FloorTiles dsb 32*2 ; 1bpp tile data
_RAM_DC99_EnterMenuTrampoline dsb 18 ; Code in RAM
.ende

.enum $DCAB export
; Game ram starts here
_RAM_DCAB_GameRAMStart .db

_RAM_DCAB_CarData_Green instanceof CarData
_RAM_DCEC_CarData_Blue instanceof CarData
_RAM_DD2D_CarData_Yellow instanceof CarData

.ende

.enum $dd6e export
_RAM_DD6E_CarEffects instanceof CarEffects 4

_RAM_DE2E_ db
_RAM_DE2F_ db
_RAM_DE30_ db
_RAM_DE31_CarUnknowns instanceof CarUnknown 3
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
_RAM_DE54_CurrentLayoutData_ExtraBits_ db
_RAM_DE55_CPUCarDirection db
_RAM_DE56_ db
_RAM_DE57_ db
.ende

.enum $DE59 export
_RAM_DE59_FloorTileRotationTemp db
.ende

.enum $DE5C export
_RAM_DE5C_CarX_Previous db
_RAM_DE5D_CarY_Previous db
_RAM_DE5E_ db
_RAM_DE5F_GreenCar_ db
_RAM_DE60_BlueCar_ db
_RAM_DE61_YellowCar db
_RAM_DE62_ dsb 2
_RAM_DE64_ dsb 2
_RAM_DE66_ db
_RAM_DE67_ db
_RAM_DE68_ db
_RAM_DE69_ db
_RAM_DE6A_ db
_RAM_DE6B_OffsetInCurrentMetatile instanceof Word
_RAM_DE6D_ instanceof Word
_RAM_DE6F_CurrentWallData db
_RAM_DE70_ db
_RAM_DE71_CarX_Adjusted_ dw
_RAM_DE73_CarY_Adjusted_ dw
_RAM_DE75_CurrentMetaTile_TileX dw ; 0..12 position of car in metatile
_RAM_DE77_CurrentMetatile_TileY dw ; 0..12 position of car in metatile
_RAM_DE79_CurrentMetatile_OffsetX dw ; 0..3 Metatile offset from "top left" metatile
_RAM_DE7B_CurrentMetatile_OffsetY dw ; 0..3 Metatile offset from "top left" metatile
_RAM_DE7D_CurrentLayoutData db ; The index of that metatile
_RAM_DE7E_Unused db
_RAM_DE7F_ db
_RAM_DE80_ db
_RAM_DE81_ db
_RAM_DE82_ db
_RAM_DE83_Unused db
_RAM_DE84_X db
_RAM_DE85_Y db
_RAM_DE86_CarDirection db
_RAM_DE87_CarSpriteAnimationTimer db
_RAM_DE88_CarSpriteAnimationIndex db
_RAM_DE89_ db
_RAM_DE8A_CarState2 db ; Car state?
_RAM_DE8B_ db
_RAM_DE8C_InPoolTableHole db
_RAM_DE8D_ db
_RAM_DE8E_PageNumber db ; For restoring paging to "the one that's supposed to be there"
.ende

.enum $DE90 export
_RAM_DE90_CarDirection db
_RAM_DE91_CarDirectionPrevious db ; To detect changes? Or is this the "actual" one?
_RAM_DE92_EngineSpeed db ; Not necessarily how fast the car is going, but it is if there are no other factors.
.ende

.enum $DE94 export
_RAM_DE94_BumpSpeed dw ; High byte is always 0
_RAM_DE96_Speed dw
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
_RAM_DEAD_ db ; Rotates 0..5? For scaling acceleration/deceleration/etc delays? (6 frames = 0.12s)
_RAM_DEAE_ db
_RAM_DEAF_HScrollDelta db
_RAM_DEB0_ db
_RAM_DEB1_VScrollDelta db
_RAM_DEB2_ db
_RAM_DEB3_Player1AccelerationDelayCounter db
_RAM_DEB4_DecelerationDelayCounter db
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
_RAM_DECA_TilemapUpdate_VerticalNeeded db
_RAM_DECB_TilemapUpdate_HorizontalNeeded db
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
_RAM_DEF1_Multiply_Result instanceof Word ; Result of Multiply function
_RAM_DEF3_Unused db ; Unused
_RAM_DEF4_Multiply_Parameter2 db ; Used for passing parameters into Multiply function
_RAM_DEF5_Multiply_Parameter1 db ; Used for passing parameters into Multiply and MultiplyBy* functions

_RAM_DEF6_FloorScrollingYAmount db ; May not just be for floor scrolling. Sign and magnitude.
_RAM_DEF7_FloorScrollingXAmount db
_RAM_DEF8_FloorScrollingRateLimiter db
_RAM_DEF9_CurrentBehaviour db ; Current behaviour, stored for later cascade into _RAM_DEFA_PreviousBehaviour
_RAM_DEFA_PreviousBehaviour db ; Previous (frame) behaviour, used for "edge triggered" behaviour which only happens once
_RAM_DEFB_PreviousDifferentBehaviour db ; Previous materially different behaviour, used for "edge triggered" behaviour which repeats
_RAM_DEFC_TrackTypeCopy_WriteOnly db ; Seems not needed
_RAM_DEFD_TrackTypeHighBits db ; Used when we want to calculate TrackType*n, the high bits end up here
.ende

.enum $DF00 export
_RAM_DF00_JumpCurvePosition db ; 0 when on the ground, else an index into DATA_1B232_JumpCurveTable
_RAM_DF01_ db ; Some jump related flag
_RAM_DF02_JumpCurveStep db ; Delta applied to _RAM_DF02_Jump_ZSpeed. Larger numbers mean a smaller jump because we skip entries in the table and finish sooner
_RAM_DF03_Jump_Active db ; Values 0, 1, 2, not sure what they mean. 2 = big jump?
_RAM_DF04_CarX_ db
_RAM_DF05_CarY_ db
_RAM_DF06_ db
_RAM_DF07_ db
_RAM_DF08_X db
_RAM_DF09_Y db
_RAM_DF0A_JumpCurveMultiplier db
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
_RAM_DF1E_DecoratorTileIndex db
_RAM_DF1F_HUDSpriteFlickerCounter db
_RAM_DF20_PositionToMetatile_Parameter .db
_RAM_DF20_PositionToMetatile_MetatileIndex db
_RAM_DF21_PositionToMetatile_OffsetInMetatile db
_RAM_DF22_PositionToMetatile_Local_Result db
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
_RAM_DF25_NumberOfCarsFinished db
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
_RAM_DF4F_LastTrackPositionIndex db
_RAM_DF50_GreenCarCurrentLapProgress db
_RAM_DF51_BlueCarCurrentLapProgress db
_RAM_DF52_YellowCarCurrentLapProgress db
_RAM_DF53_FormulaOne_BorderTrackPositionsPointer dw
_RAM_DF55_ db
_RAM_DF56_ db
_RAM_DF57_ db
_RAM_DF58_ResettingCarToTrack db ; 1 when the car is being reset
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
_RAM_DF65_HasFinished db
_RAM_DF66_CarPositionIndicator_CarX db
_RAM_DF67_CarPositionIndicator_CarY db
_RAM_DF68_ProgressTilesPerLap db
_RAM_DF69_ProgressTilesPerHalfLap db
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
_RAM_DF75_PaletteAnimationDataOffset db
_RAM_DF76_PaletteAnimationCounter db
_RAM_DF77_PaletteAnimationData dw
_RAM_DF79_CurrentBehaviourByte db ; "Behaviour data" full byte
_RAM_DF7A_Powerboats_BubblePush_Direction db
_RAM_DF7B_Powerboats_BubblePush_Strength db
_RAM_DF7C_Powerboats_BubblePush_DecayCounter db ; Rate-limits decay of _RAM_DF7B_Powerboats_BubblePush_Strength to 0
_RAM_DF7D_ db
_RAM_DF7E_ db
_RAM_DF7F_ db
_RAM_DF80_TwoPlayerWinPhase db
_RAM_DF81_ db
_RAM_DF82_BubblePush_Strength_X db
_RAM_DF83_BubblePush_Strength_Y db
_RAM_DF84_BubblePush_Sign_X db
_RAM_DF85_BubblePush_Sign_Y db
_RAM_DF86_Powerboats_BubblePush_Counter db
_RAM_DF87_ db
_RAM_DF88_ db
_RAM_DF89_ db
_RAM_DF8A_ dw
_RAM_DF8C_RuffTruxRanOutOfTime db
_RAM_DF8D_RedCarRaceProgress instanceof Word ; These are 16-bit counters for the track metatiles passed, they are used to measure distance between cars.
_RAM_DF8F_GreenCarRaceProgress dw
_RAM_DF91_BlueCarRaceProgress instanceof Word
_RAM_DF93_YellowCarRaceProgress dw
_RAM_DF95_OpponentTopSpeedEvaluationDelayCounter db
_RAM_DF96_OpponentTopSpeedEvaluationSelector db
_RAM_DF97_ db
_RAM_DF98_CarTileLoaderCounter db
_RAM_DF99_ db

_RAM_DF9A_EndOfRAM .db
.ende

.BANK 0 SLOT 0
.ORG $0000

.section "Entry" force
  di
  ld hl, STACK_TOP
  ld sp, hl
  call LABEL_100_Startup ; Copies things to RAM and more
  xor a
  ld (_RAM_DC41_GearToGearActive), a
  ld a, :LABEL_8000_Main
  ld (PAGING_REGISTER), a
  jp LABEL_8000_Main
.ends

.section "Transition from game to menu" force

EnterMenus:
  ; Code jumps here when transitioning from game to menus
  di
  ld a, :MenuScreenEntryPoint
  ld (PAGING_REGISTER), a
  ld a, 1
  ld (_RAM_DC3E_InMenus), a
  ld hl, STACK_TOP
  ld sp, hl
  jp MenuScreenEntryPoint

.ifdef BLANK_FILL_ORIGINAL
.db "P HL", 13, 10, 9, "INC HL", 13, 10, 9, "LD" ; Source code left in RAM
.endif

.ends

.org $0038
.section "VBlank handler" force
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

.ends

.org $0066
.section "Pause/Gear To Gear handler" force
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

.ends

.section "Enter game trampoline and data" force
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
.ends

.section "Enter menu trampoline" force
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
.ends

.section "Floor tiles" force
DATA_C0_FloorTilesRawTileData:
.incbin "Assets/Formula One/Floor.4bpp"
.ends

.section "Startup" force
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
  ld de, LABEL_75_MenuRAMSection  ; Loading code and data into RAM
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

  ; Fill floor tiles buffer with data
  ld hl, _RAM_DC59_FloorTiles
  ld de, DATA_C0_FloorTilesRawTileData
  ld bc, _sizeof_DATA_C0_FloorTilesRawTileData
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
  ld (_RAM_DBA8_SkipNextGameVBlankVDPUpdate), a
.ifdef UNNECESSARY_CODE
  ld a, 32
  ld (_RAM_DB9C_MetatilemapWidth.Lo), a ; Always this value, TODO: could optimise to constant
  ld (_RAM_DB9E_MetatilemapHeight_WriteOnly.Lo), a
.endif
  ld hl, _RAM_DB22_TilemapUpdate_HorizontalTileNumbers
  ld (_RAM_DB62_), hl
  ld hl, _RAM_DB42_TilemapUpdate_VerticalTileNumbers
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
  ld (_RAM_DC56_Adjustment1_XY), a ; If GG
  ld a, $28
  ld (_RAM_DC57_Adjustment2_XY.Lo), a
  JpRet ++
+:xor a
  ld (_RAM_DC56_Adjustment1_XY), a ; If SMS
  ld (_RAM_DC57_Adjustment2_XY.Lo), a
++:ret
.else
.ifdef IS_GAME_GEAR
  ld a, $05
  ld (_RAM_DC56_Adjustment1_XY), a ; If GG
  ld a, $28
  ld (_RAM_DC57_Adjustment2_XY.Lo), a
.else
  xor a
  ld (_RAM_DC56_Adjustment1_XY), a ; If SMS
  ld (_RAM_DC57_Adjustment2_XY.Lo), a
.endif
  ret
.endif

LABEL_173_LoadEnterMenuTrampolineToRAM:
  ; Copy some code to RAM
  ld hl, _RAM_DC99_EnterMenuTrampoline
  ld de, LABEL_AE_EnterMenuTrampolineImpl
  ld bc, _sizeof_LABEL_AE_EnterMenuTrampolineImpl
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
  ; TODO _sizeof_ doesn't work here because DSTRUCT defines labels
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
.ends

.section "Game VBlank" force
LABEL_199_GameVBlank:
  push af
    ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
    or a
    jr nz, _SkipVBlank
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
        call LABEL_5169_Trampoline_GameVBlankEngineUpdate
        call LABEL_5174_Trampoline_GameVBlankPart3
        CallPagedFunction PagedFunction_2B5D2_GameVBlankUpdateSoundTrampoline
+:    pop af
      ld (PAGING_REGISTER), a
    pop iy
    pop ix
    pop de
    pop bc
    pop hl
_SkipVBlank:
    in a, (PORT_VDP_STATUS) ; Ack INT
  pop af
  ret
.ends

.section "unknown slot 0 part 1" force
LABEL_1E4_:
  call LABEL_519D_Trampoline_ReadGGPauseButton
  ld a, (_RAM_D599_IsPaused)
  or a
  jp nz, _IsPaused
  ld a, (_RAM_DF7F_)
  or a
  call nz, LABEL_AB1_
  call LABEL_12D5_Trampoline_PagedFunction_1FA3D_
  call LABEL_12BF_Trampoline_PagedFunction_35F8A_
  call LABEL_11BA_
  call LABEL_12CA_Trampoline_PagedFunction_36209_
  ld a, (_RAM_D5B6_SkidDuration)
  or a
  call nz, LABEL_65C7_
  ld a, (_RAM_D5B7_)
  or a
  call nz, LABEL_B04_
  call LABEL_F9B_
  call LABEL_22CD_ProcessCarJump
  call LABEL_265F_
  call LABEL_5E3A_
  call LABEL_648E_
  call LABEL_49C9_
  call LABEL_4465_Powerboats_BubblePush_GetData
  call LABEL_44C3_Powerboats_BubblePush_ApplyData
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
  ld (_RAM_DD6E_CarEffects.1.Member45_Enabled2), a
  ld (_RAM_DD6E_CarEffects.2.Member45_Enabled2), a
  ld (_RAM_DD6E_CarEffects.3.Member45_Enabled2), a
  ld (_RAM_DD6E_CarEffects.4.Member45_Enabled2), a
  call LABEL_27B1_
  call LABEL_1DF2_
  call LABEL_3164_
  call LABEL_317C_
  call LABEL_343A_
  call LABEL_3445_
  call LABEL_3F3F_Trampoline_TrackPositionAISpeedHacks
  call LABEL_523B_
  call LABEL_3D59_
  call LABEL_3DBD_Trampoline_PagedFunction_239C6_
  call LABEL_AC5_
  call LABEL_2857_
  call LABEL_ABB_
  call LABEL_5A88_
  call LABEL_AF5_
  call LABEL_1593_
  call LABEL_16C0_
  call LABEL_318_CheckForGearToGearWork
  call LABEL_4927_
  CallPagedFunction PagedFunction_371F1_
  call LABEL_318_CheckForGearToGearWork
_IsPaused:
  call LABEL_3450_
  call LABEL_35E0_
  call LABEL_318_CheckForGearToGearWork
  call LABEL_73D4_UpdateHUDSprites
  call LABEL_318_CheckForGearToGearWork
  call LABEL_84A_UpdateExtraSprites
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
  call LABEL_2D63_UpdateRaceProgressAndTopSpeeds
  call LABEL_318_CheckForGearToGearWork
  ld a, (_RAM_D599_IsPaused)
  or a
  jr nz, LABEL_300_
  ; Stuff we only do when not paused...
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  ; ...and not Gear to Gear...
  call LABEL_5169_Trampoline_GameVBlankEngineUpdate
  call LABEL_5174_Trampoline_GameVBlankPart3
  call LABEL_318_CheckForGearToGearWork
  CallPagedFunction PagedFunction_2B5D2_GameVBlankUpdateSoundTrampoline
  call LABEL_318_CheckForGearToGearWork
+:
  call LABEL_BF0_ScrollFloorTileData
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
.ends

.section "Game VBlank VDP work" force
-:xor a
  ld (_RAM_DBA8_SkipNextGameVBlankVDPUpdate), a
  ret

LABEL_33A_GameVBlankVDPWork:
  ld a, (_RAM_DBA8_SkipNextGameVBlankVDPUpdate)
  cp $01
  jr z, -
  call LABEL_7795_ScreenOff
  call LABEL_78CE_TilemapUpdate_Horizontal
  call LABEL_7916_TilemapUpdate_Vertical

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
  CallPagedFunction PagedFunction_17E95_LoadPlayoffTiles ; Call only when flag is set, then reset it
  xor a
  ld (_RAM_D5CC_PlayoffTileLoadFlag), a
+:call LABEL_BC5_EmitFloorTiles
  call LABEL_2D07_UpdatePalette_RuffTruxSubmerged
  call LABEL_3FB4_Trampoline_UpdateAnimatedPalette
  jp LABEL_778C_ScreenOn
.ends

.section "Enter game part 2" force
LABEL_383_EnterGame_Part2:
  call LABEL_3ED_EnterGamePart2a
--:
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr nz, +
  call LABEL_AFD_ReadControls_Trampoline
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

+:; Gear to Gear player 1
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
  call LABEL_AFD_ReadControls_Trampoline
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
  call LABEL_458_Trampoline_PatchForLevel
  call LABEL_51A8_Trampoline_ClearTilemap
  call LABEL_1345_DrawGameFullScreen
  call LABEL_77CD_ComputeScreenTilemapAddress
  call LABEL_1801_
  call LABEL_3231_BlankDecoratorTiles
  call LABEL_3F2B_BlankGameRAMTrampoline
  call LABEL_3199_
  call LABEL_AEB_GetPlayerHandicapsTrampoline
  call LABEL_7564_SetControlsToNoButtons
  call LABEL_186_InitialiseSoundData
  call LABEL_463_Trampoline_SilencePSG
  ld a, MAX_ENGINE_VOLUME
  ld (_RAM_D96C_EngineSound2.Volume), a
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
.ends

.section "Trampolines 1" force
LABEL_458_Trampoline_PatchForLevel:
  JumpToPagedFunction PagedFunction_36484_PatchForLevel

LABEL_463_Trampoline_SilencePSG:
  JumpToPagedFunction PagedFunction_2B5D5_SilencePSG
.ends

.section "Car effects" force
_EffectTileOffsets: ; 4 bytes per entry * 16 entries
  ; Relative XY positions of effects sprites for each direction
.dbm SignAndMagnitude,  4, 23,  12,  23
.dbm SignAndMagnitude, -1, 19,   6,  22
.dbm SignAndMagnitude, -4, 15,   2,  21
.dbm SignAndMagnitude, -6, 11,  -3,  18
.dbm SignAndMagnitude, -7,  4,  -7,  12
.dbm SignAndMagnitude, -3, -2,  -6,   5
.dbm SignAndMagnitude,  2, -5,  -4,   1
.dbm SignAndMagnitude, -1, -3,   6,  -6
.dbm SignAndMagnitude,  4, -7,  12,  -7
.dbm SignAndMagnitude, 10, -6,  17,  -3
.dbm SignAndMagnitude, 14, -5,  20,   1
.dbm SignAndMagnitude, 19, -2,  22,   5
.dbm SignAndMagnitude, 23,  4,  23,  12
.dbm SignAndMagnitude, 22, 11,  19,  18
.dbm SignAndMagnitude, 20, 15,  14,  21
.dbm SignAndMagnitude, 17, 19,  10,  22

_SixTimesTable:
  TimesTableLo 0, 6, 3 ; 0, 6, 12

_CarEffectsDelay:
.db 3

LABEL_4B2_CarEffects_FrameUpdate:
  ld a, (iy+CarEffects.DelayCounter)
  or a
  jr z, +
  DEC_A
  ld (iy+CarEffects.DelayCounter), a
  ret

+:; Only do work when counter gets to 0 -> every 4 frames
  ld a, (_CarEffectsDelay) ; Constant!
  ld (iy+CarEffects.DelayCounter), a

  ld a, (iy+CarEffects.NextEffectIndex)
  ld e, a
  ld d, $00
  ld hl, _SixTimesTable ; (iy+25) * 6
  add hl, de
  ld a, (hl)
  ld e, a
  ld d, $00
  add ix, de ; Add that to ix -> it now points at the CarEffectSpriteDataPair
  ld a, (iy+CarEffects.Direction)
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, _EffectTileOffsets ; Look up _EffectTileOffsets[(iy+21)*4]
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
  ld a, (iy+CarEffects.X) ; Subtract value
  sub b       ; Add constant
  add a, c
  ld (ix+CarEffectSpritePair.Data.1.X), a ; ix+0 = iy+22 - b + c
  jp ++

+:; High bit unset
  ld a, (iy+CarEffects.X)
  add a, b    ; Add value
  add a, c    ; Add constant
  ld (ix+CarEffectSpritePair.Data.1.X), a ; ix+0 = iy+22 + b + c
++:
  inc hl      ; Next byte
  ld a, (hl)
  ld b, a
  and $80     ; High bit is sign again
  jr z, +
  ld a, b
  and $7F
  ld b, a
  ld a, (iy+CarEffects.Y) ; ix+2 = iy+23 (+/-) b - c
  sub b
  add a, c
  ld (ix+CarEffectSpritePair.Data.1.Y), a
  jp ++
+:ld a, (iy+CarEffects.Y)
  add a, b
  add a, c
  ld (ix+CarEffectSpritePair.Data.1.Y), a

++:
  inc hl      ; Next byte: ix+3 = iy+22 (+/-) b + c
  ld a, (hl)
  ld b, a
  and $80
  jr z, +
  ld a, b
  and $7F
  ld b, a
  ld a, (iy+CarEffects.X)
  sub b
  add a, c
  ld (ix+CarEffectSpritePair.Data.2.X), a
  jp ++
+:ld a, (iy+CarEffects.X)
  add a, b
  add a, c
  ld (ix+CarEffectSpritePair.Data.2.X), a
++:
  inc hl    ; Last one: ix+5 = iy+23 (+/-) b + c
  ld a, (hl)
  ld b, a
  and $80
  jr z, +
  ld a, b
  and $7F
  ld b, a
  ld a, (iy+CarEffects.Y)
  sub b
  add a, c
  ld (ix+CarEffectSpritePair.Data.2.Y), a
  jp ++
+:ld a, (iy+CarEffects.Y)
  add a, b
  add a, c
  ld (ix+CarEffectSpritePair.Data.2.Y), a
++:
  ; All done
  ; ix += 26 -> now it points at the CarEffectState for this slot
  ld de, CarEffects.States - CarEffects.Sprites
  add ix, de
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ; Powerboats only:
  xor a ; Force to "dust" type always
  ld (iy+CarEffects.NextType), a
  ld a, (iy+CarEffects.Member47_ResettingCarToTrack)
  xor $01
  ld (iy+CarEffects.Member45_Enabled2), a
+:
  ld a, (iy+CarEffects.Member45_Enabled2)
  or a
  jr z, +
  ld a, (iy+CarEffects.Member46_JumpCurvePosition)
  or a
  jr nz, +
  ; Check X, Y bounds
  ld a, (iy+CarEffects.Y)
  cp $F0
  jr nc, +
  cp $10
  jr c, +
  ld a, (iy+CarEffects.X)
  cp $10
  jr c, +
  cp $F0
  jr nc, +
  ld a, $01 ; Enabled
  jp ++
+:xor a ; Disabled
++:
  ; Enable or disable the effect based on the above
  ld (ix+CarEffectState.Enabled), a
  
  ; Initialise the state
  ld a, (iy+CarEffects.NextType)
  ld (ix+CarEffectState.Type), a
  xor a
  ld (ix+CarEffectState.Counter), a ; 
  ld (ix+CarEffectState.Unused + 0), a ; Unnecessary? Never read back?
  ; Rotate effect index through 0, 1, 2
  ld a, (iy+CarEffects.NextEffectIndex)
  cp $02
  jr z, +
  INC_A
-:ld (iy+CarEffects.NextEffectIndex), a
  ret

+:xor a
  jp -

.ifdef JUMP_TO_RET
_LABEL_5C8_ret:
  ret
.endif

LABEL_5C9_UpdateCarEffects_Red:
  ld iy, _RAM_DD6E_CarEffects.1
  ld ix, _RAM_DD6E_CarEffects.1
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (iy+CarEffects.Direction), a
  ld a, (_RAM_DBA4_CarX)
  ld (iy+CarEffects.X), a
  ld a, (_RAM_DBA5_CarY)
  ld (iy+CarEffects.Y), a
  ld a, $01
  ld (iy+CarEffects.Enabled), a
  ld a, (_RAM_DF00_JumpCurvePosition)
  ld (iy+CarEffects.Member46_JumpCurvePosition), a
  ld a, (_RAM_DF58_ResettingCarToTrack)
  ld (iy+CarEffects.Member47_ResettingCarToTrack), a
  call LABEL_4B2_CarEffects_FrameUpdate
  jp _UpdateSpriteTable

LABEL_5FA_UpdateCarEffects_Green:
  ; Skip for head to head (no green car)
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrZRet _LABEL_5C8_ret
  
  ld iy, _RAM_DD6E_CarEffects.2
  ld ix, _RAM_DD6E_CarEffects.2
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  ld (iy+CarEffects.Direction), a
  ld a, (_RAM_DCAB_CarData_Green.SpriteX)
  ld (iy+CarEffects.X), a
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  ld (iy+CarEffects.Y), a
  ld a, (_RAM_DCAB_CarData_Green.EffectsEnabled)
  ld (iy+CarEffects.Enabled), a
  ld a, (_RAM_DCAB_CarData_Green.Unknown20_b_JumpCurvePosition)
  ld (iy+CarEffects.Member46_JumpCurvePosition), a
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  ld (iy+CarEffects.Member47_ResettingCarToTrack), a
  call LABEL_4B2_CarEffects_FrameUpdate
  jp _UpdateSpriteTable

LABEL_633_UpdateCarEffects3:
  ld iy, _RAM_DD6E_CarEffects.3
  ld ix, _RAM_DD6E_CarEffects.3
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld (iy+CarEffects.Direction), a
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  ld (iy+CarEffects.X), a
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  ld (iy+CarEffects.Y), a
  ld a, (_RAM_DCEC_CarData_Blue.EffectsEnabled)
  ld (iy+CarEffects.Enabled), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  ld (iy+CarEffects.Member46_JumpCurvePosition), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  ld (iy+CarEffects.Member47_ResettingCarToTrack), a
  call LABEL_4B2_CarEffects_FrameUpdate
  jp _UpdateSpriteTable

LABEL_665_UpdateCarEffects4:
  ; Skip for head to head (no yellow car)
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JpZRet _LABEL_5C8_ret

  ld iy, _RAM_DD6E_CarEffects.4
  ld ix, _RAM_DD6E_CarEffects.4
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
  ld (iy+CarEffects.Direction), a
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteX)
  ld (iy+CarEffects.X), a
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  ld (iy+CarEffects.Y), a
  ld a, (_RAM_DD2D_CarData_Yellow.EffectsEnabled)
  ld (iy+CarEffects.Enabled), a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown20_b_JumpCurvePosition)
  ld (iy+CarEffects.Member46_JumpCurvePosition), a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  ld (iy+CarEffects.Member47_ResettingCarToTrack), a
  call LABEL_4B2_CarEffects_FrameUpdate
  ; fall through

_UpdateSpriteTable:
  ; Point de, hl to the correct sprite table entries
  ld a, (iy+CarEffects.TileBaseIndex)
  ld c, a
  ld b, $00
  ld hl, _RAM_DA60_SpriteTableXNs
  add hl, bc
  add hl, bc
  ex de, hl
  ld hl, _RAM_DAE0_SpriteTableYs
  add hl, bc
  ld a, (iy+CarEffects.SpriteRotator)
  INC_A
  cp $03 ; cycle through 0, 1, 2
  jr nz, +
  xor a
+:ld (iy+CarEffects.SpriteRotator), a
  or a
  jr z, @SpriteRotator1
  cp $01
  jr z, @SpriteRotator0

@SpriteRotator2:
  call LABEL_7DD_SetCarEffect2SpriteIndices
  ld a, (iy+CarEffects.Sprites.3.Data.1.X)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.3.Data.1.N)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.3.Data.1.Y)
  ld (hl), a
  inc hl
  ld a, (iy+CarEffects.Sprites.3.Data.2.X)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.3.Data.2.N)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.3.Data.2.Y)
  ld (hl), a
  ret

@SpriteRotator1:
  call LABEL_723_SetCarEffectSpriteIndices
  ld a, (iy+CarEffects.Sprites.1.Data.1.X)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.1.Data.1.N)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.1.Data.1.Y)
  ld (hl), a
  inc hl
  ld a, (iy+CarEffects.Sprites.1.Data.2.X)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.1.Data.2.N)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.1.Data.2.Y)
  ld (hl), a
  ret

@SpriteRotator0:
  call LABEL_780_SetCarEffect1SpriteIndices
  ld a, (iy+CarEffects.Sprites.2.Data.1.X)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.2.Data.1.N)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.2.Data.1.Y)
  ld (hl), a
  inc hl
  ld a, (iy+CarEffects.Sprites.2.Data.2.X)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.2.Data.2.N)
  ld (de), a
  inc de
  ld a, (iy+CarEffects.Sprites.2.Data.2.Y)
  ld (hl), a
  ret

LABEL_723_SetCarEffectSpriteIndices:
  ld a, (iy+CarEffects.Enabled) ; Enabled 1?
  or a
  jr z, LABEL_76B_BlankCarEffects
  ld a, (iy+CarEffects.States.1.Enabled) ; Enabled 2?
  or a
  jr z, LABEL_76B_BlankCarEffects
  push hl
    ld a, (iy+CarEffects.States.1.Type) ; 0 for dust, 1 for liquid
    sla a ; -> offset by 4
    sla a
    ld c, a
    ld b, 0
    ld a, (_RAM_DB97_TrackType)
    cp TT_7_RuffTrux
    jr nz, +
    ld hl, DATA_842_EffectTileIndices_RuffTrux
    jp ++
+:  ld hl, DATA_83A_EffectTileIndices
++: add hl, bc
    ld a, (iy+CarEffects.States.1.Counter) ; Animation counter
    ld c, a
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (iy+CarEffects.Sprites.1.Data.1.N), a ; Set tile index
    ld (iy+CarEffects.Sprites.1.Data.2.N), a
    ld a, c ; Cycle counter 0..2
    cp $03
    jr z, +
    INC_A
    ld (iy+CarEffects.States.1.Counter), a
  pop hl
  ret

+:  xor a
    ld (iy+CarEffects.States.1.Enabled), a
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
  ld (iy+CarEffects.Sprites.1.Data.1.N), a
  ld (iy+CarEffects.Sprites.1.Data.2.N), a
  ret

; Same as LABEL_723_SetCarEffectSpriteIndices except offsets are different
LABEL_780_SetCarEffect1SpriteIndices:
  ld a, (iy+CarEffects.Enabled)
  or a
  jr z, _LABEL_7C8_BlankCarEffect1
  ld a, (iy+CarEffects.States.2.Enabled)
  or a
  jr z, _LABEL_7C8_BlankCarEffect1
  push hl
    ld a, (iy+CarEffects.States.2.Type)
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
    ld a, (iy+CarEffects.States.2.Counter)
    ld c, a
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (iy+CarEffects.Sprites.2.Data.1.N), a
    ld (iy+CarEffects.Sprites.2.Data.2.N), a
    ld a, c
    cp $03
    jr z, +
    INC_A
    ld (iy+CarEffects.States.2.Counter), a
  pop hl
  ret

+:  xor a
    ld (iy+CarEffects.States.2.Enabled), a
  pop hl
  ret

_LABEL_7C8_BlankCarEffect1:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld a, SpriteIndex_RuffTrux_Blank ; RuffTrux
  jp ++
+:ld a, <SpriteIndex_Blank ; Not RuffTrux
++:
  ld (iy+CarEffects.Sprites.2.Data.1.N), a
  ld (iy+CarEffects.Sprites.2.Data.2.N), a
  ret

; Same as LABEL_723_SetCarEffectSpriteIndices except offsets are different
LABEL_7DD_SetCarEffect2SpriteIndices:
  ld a, (iy+CarEffects.Enabled)
  or a
  jr z, _LABEL_825_BlankCarEffect2
  ld a, (iy+CarEffects.States.3.Enabled)
  or a
  jr z, _LABEL_825_BlankCarEffect2
  push hl
    ld a, (iy+CarEffects.States.3.Type) ; Effect type: 0 = dust, 1 = liquid
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
    ld a, (iy+CarEffects.States.3.Counter) ; Effect counter
    ld c, a
    ld b, $00
    add hl, bc ; Look up tile numbers
    ld a, (hl) ; and save to destination
    ld (iy+CarEffects.Sprites.3.Data.1.N), a
    ld (iy+CarEffects.Sprites.3.Data.2.N), a
    ld a, c ; Loop counter 0..2
    cp 3
    jr z, +
    INC_A
    ld (iy+CarEffects.States.3.Counter), a
  pop hl
  ret

+:  ; End of sequence
    xor a
    ld (iy+CarEffects.States.3.Enabled), a
  pop hl
  ret

_LABEL_825_BlankCarEffect2:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld a, SpriteIndex_RuffTrux_Blank ; RuffTrux
  jp ++
+:ld a, <SpriteIndex_Blank ; Not RuffTrux
++:ld (iy+CarEffects.Sprites.3.Data.1.N), a
  ld (iy+CarEffects.Sprites.3.Data.2.N), a
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
.ends

.section "Extra sprites" force
LABEL_84A_UpdateExtraSprites:
  ; Handles position indicators (at end of race) and "effects"
  ; - Position indicator is shown if car has finished
  ; - Else if it's a tank, there's a special handler
  ; - Else, dust/splash effects are updated
  ; - Unless the car is not present! (Green and yellow in head-to-head mode)
  
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jp z, LABEL_97C_UpdateExtraSprites_RuffTrux

  ; Not RuffTrux
@Red:
  ld a, (_RAM_DF65_HasFinished)
  or a
  jr z, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  
  ; Red car position indicator (if finished and not head to head)
  ld a, (_RAM_DBA4_CarX)
  ld (_RAM_DF66_CarPositionIndicator_CarX), a
  ld a, (_RAM_DBA5_CarY)
  ld (_RAM_DF67_CarPositionIndicator_CarY), a
  ld a, (_RAM_DF2A_Positions.Red)
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  call LABEL_97F_ShowCarPositionIndicator
  jp @Green

+:; Either draw tank stuff... (TODO)
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  call LABEL_6611_Tanks_Red_Trampoline
  jp @Green
  
  ; ...or car effects
+:call LABEL_5C9_UpdateCarEffects_Red ; Not for tanks

@Green:
  ld a, (_RAM_DCAB_CarData_Green.Unknown26_b_HasFinished)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, @Blue
  
  ; Green car position indicator (if finished and not head to head)
  ld a, (_RAM_DCAB_CarData_Green.SpriteX)
  ld (_RAM_DF66_CarPositionIndicator_CarX), a
  ld a, (_RAM_DCAB_CarData_Green.EffectsEnabled)
  cp $01
  jr z, +
  ld a, $F0 ; Hide indicator if car is off-screen?
  jp ++
+:ld a, (_RAM_DCAB_CarData_Green.SpriteY)
++:
  ld (_RAM_DF67_CarPositionIndicator_CarY), a
  ld a, (_RAM_DF2A_Positions.Green)
  ld ix, _RAM_DA60_SpriteTableXNs.59
  ld iy, _RAM_DAE0_SpriteTableYs.59
  call LABEL_97F_ShowCarPositionIndicator
  jp @Blue
  
+++:
  ; Or tank stuff
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead) ; ??? Green tank can't fire?
  or a
  jr nz, @Blue
  call LABEL_661C_Tanks_Green_Trampoline
  jp @Blue

+:; Or effects (if SMS)
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, @Blue
  call LABEL_5FA_UpdateCarEffects_Green

@Blue:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown26_b_HasFinished)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, @Yellow

  ; Green car position indicator (if finished and not head to head)
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  ld (_RAM_DF66_CarPositionIndicator_CarX), a
  ld a, (_RAM_DCEC_CarData_Blue.EffectsEnabled)
  cp $01
  jr z, +
  ld a, $F0 ; hide if off-screen
  jp ++
+:ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
++:
  ld (_RAM_DF67_CarPositionIndicator_CarY), a
  ld a, (_RAM_DF2A_Positions.Blue)
  ld ix, _RAM_DA60_SpriteTableXNs.61
  ld iy, _RAM_DAE0_SpriteTableYs.61
  call LABEL_97F_ShowCarPositionIndicator
  jp @Yellow

+++:
  ; Or tank stuff
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  call LABEL_6627_Tanks_Blue_Trampoline
  jp @Yellow

+:; Or effects (if SMS)
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, @Yellow
+:call LABEL_633_UpdateCarEffects3
  
@Yellow: ; Rendered as blue in head-to-head...
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown26_b_HasFinished)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet _LABEL_97B_ret

  ; Yellow car position indicator (if finished and not head to head)
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteX)
  ld (_RAM_DF66_CarPositionIndicator_CarX), a
  ld a, (_RAM_DD2D_CarData_Yellow.EffectsEnabled)
  cp $01
  jr z, +
  ld a, $F0 ; Hide if off-screen
  jp ++
+:ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
++:
  ld (_RAM_DF67_CarPositionIndicator_CarY), a
  ld a, (_RAM_DF2A_Positions.Yellow)
  ld ix, _RAM_DA60_SpriteTableXNs.63
  ld iy, _RAM_DAE0_SpriteTableYs.63
  jp LABEL_97F_ShowCarPositionIndicator

+++:
  ; Or tank stuff
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet _LABEL_97B_ret
  TailCall LABEL_6632_Tanks_Yellow_Trampoline _LABEL_97B_ret

+:; Or effects (if SMS)
  ld a, (_RAM_DC54_IsGameGear)
  or a
  JrNzRet _LABEL_97B_ret
  jp LABEL_665_UpdateCarEffects4

.ifdef JUMP_TO_RET
_LABEL_97B_ret:
  ret
.endif

LABEL_97C_UpdateExtraSprites_RuffTrux:
  ; Just do dust/splash effects
  jp LABEL_5C9_UpdateCarEffects_Red ; and ret

LABEL_97F_ShowCarPositionIndicator:
  ; Sets the two sprites at ix, iy to show 1st, 2nd etc
  ; as per the value in a (0 = 1st) at _RAM_DF66_CarPositionIndicator_CarX, _RAM_DF67_CarPositionIndicator_CarY
  sla a
  ld e, a
  ld d, 0
  ld hl, DATA_9AA_SuffixedPositionSpriteIndices
  add hl, de
  ld a, (hl)
  ld (ix+1), a ; First sprite n
  inc hl
  ld a, (hl)
  ld (ix+3), a ; Second sprite n
  ld a, (_RAM_DF66_CarPositionIndicator_CarX)
  add a, 4 ; Offset +4
  ld (ix+0), a ; First sprite X
  add a, $08
  ld (ix+2), a ; Second sprite X
  ld a, (_RAM_DF67_CarPositionIndicator_CarY)
  sub 12 ; Offset -12
  ld (iy+0), a ; Sprite Ys
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
  and LAYOUT_INDEX_MASK
  exx
    ld l, a
    ld h, $00
    ld bc, _RAM_DA20_TrackMetatileLookup
    add hl, bc
    ld a, (hl)
  exx
  ret
.ends

.section "Game Gear NMI handler" force
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
.ends

.section "Tilemap address conversion tables" force
; This could be inlined where it's used
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
.ends

.section "HUD sprites locations" force
; Sprite X locations for tournament HUD sprites (SMS)
.dstruct DATA_A6D_SMS_TournamentHUDSpriteXs instanceof TournamentHUDSprites data $14 $10 $10 $10 $10 $18 $18 $18 $18

; Sprite Y locations for tournament HUD sprites (SMS)
.dstruct DATA_A76_SMS_TournamentHUDSpriteYs instanceof TournamentHUDSprites data $08 $10 $18 $20 $28 $10 $18 $20 $28

; Sprite X locations for tournament HUD sprites (GG)
.dstruct DATA_A7F_GG_TournamentHUDSpriteXs instanceof TournamentHUDSprites data $3C $38 $38 $38 $38 $40 $40 $40 $40

; Sprite Y locations for tournament HUD sprites (GG)
.dstruct DATA_A88_GG_TournamentHUDSpriteYs instanceof TournamentHUDSprites data $30 $38 $40 $48 $50 $38 $40 $48 $50
.ends

.section "RuffTrux time limits" force
; Nibble encoded time limits to one DP
; Last byte is unused
DATA_A91_RuffTruxTimeLimits:
.macro RuffTruxTimeLimit args time
.db time / 10 # 10, time * 1 # 10, time * 10 # 10, 0
.endm
  RuffTruxTimeLimit 45.0
  RuffTruxTimeLimit 48.0
  RuffTruxTimeLimit 55.0

.ends

.section "Trampolines 2" force
LABEL_A9D_:
  JrToPagedFunction PagedFunction_36D07_

LABEL_AA7_:
  JrToPagedFunction PagedFunction_36CA5_

LABEL_AB1_:
  JrToPagedFunction PagedFunction_366DE_

LABEL_ABB_:
  JrToPagedFunction PagedFunction_360B9_

LABEL_AC5_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet + ; ret
  JrToPagedFunction PagedFunction_3616B_
.ifdef JUMP_TO_RET
+: ret
.endif

LABEL_AD7_DelayIfPlayer2Trampoline:
  JrToPagedFunction PagedFunction_1BCCB_DelayIfPlayer2

LABEL_AE1_InGameCheatHandlerTrampoline:
  JrToPagedFunction PagedFunction_1F8D8_InGameCheatHandler

LABEL_AEB_GetPlayerHandicapsTrampoline:
  JrToPagedFunction PagedFunction_1BAB3_GetPlayerHandicaps

LABEL_AF5_: 
  ; Macros jump into this one so it can't be used here, but it's just a trampoline like the rest
  ld a, :PagedFunction_1BAFD_ ; $06
  ld (PAGING_REGISTER), a
  call PagedFunction_1BAFD_
LABEL_AFD_RestorePaging_fromDE8E:
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ret

LABEL_B04_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  ret z
  JrToPagedFunction PagedFunction_363D0_
.ends

.section "Head to head point scored" force
LABEL_B13_HeadToHead_BlueWins: ; TODO only part of the process
  ; If playoff won, jump to the winner sound
  ld a, (_RAM_D947_PlayoffWon)
  or a
  jr nz, +
  ; Else check the points
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  cp $01 ; 1 about to become 0
  jr z, +
  jp _Bonus
+:ld a, SFX_12_WinOrCheat
  ld (_RAM_D963_SFX_Player1.Trigger), a
  jp _Winner

LABEL_B2B_HeadToHead_RedWins:
  ; Same as above
  ld a, (_RAM_D947_PlayoffWon)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  cp HEAD_TO_HEAD_TOTAL_POINTS - 1 ; 7 about to become 8
  jr nz, _Bonus
+:ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFX_Player2), a

_Winner:
  ld hl, DATA_BB9_WinnerSpriteData
  jp +
_Bonus:
  ld hl, DATA_BAD_BonusSpriteData
+:; Set sprite data
  ld ix, _RAM_DAE0_SpriteTableYs.20
  ld de, _RAM_DA60_SpriteTableXNs.20
  ld c, 12 ; Count
-:ld a, (hl)
  ld (de), a
  ld a, $50 ; y - writes too many!? (12 XNs, should have 6 Ys)
  ld (ix+0), a
  inc ix
  inc hl
  inc de
  dec c
  jr nz, -
  ld a, $02
  ld (_RAM_D581_OverlayTextScrollAmount), a
  ret

LABEL_B63_UpdateOverlayText:
  ld a, (_RAM_D581_OverlayTextScrollAmount)
  cp $A0 ; Do nothing once it is >= this number
  JrNcRet _LABEL_BAC_ret
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  cp 0 + 1
  jr z, +
  cp HEAD_TO_HEAD_TOTAL_POINTS - 1
  jr nz, ++
+:ld ix, DATA_BB9_WinnerSpriteData
  jp +++
++:
  ld ix, DATA_BAD_BonusSpriteData
+++:
  ld de, _RAM_DA60_SpriteTableXNs.20
  ld iy, _RAM_DAE0_SpriteTableYs.20
  ld c, $06 ; Tile count for overlay text
-:
  ld a, (_RAM_D581_OverlayTextScrollAmount)
  ld l, a
  ld a, (ix+0) ; X
  add a, l     ; Plus scroll amount
  ld (de), a   ; Emit it
  cp $50
  jr nc, +
  xor a         ; Zero X, Y if <$50?
  ld (de), a
  ld (iy+0), a
+:
  inc de        ; Next sprite
  inc de
  inc ix
  inc ix
  inc iy
  ld a, $02 ; Scroll amount per frame
  add a, l
  ld (_RAM_D581_OverlayTextScrollAmount), a
  dec c
  jr nz, -
_LABEL_BAC_ret:
  ret

DATA_BAD_BonusSpriteData: ; Sprite X, N for "BONUS"
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 0, <SpriteIndex_Bonus_Part1 + 0 ; TODO enum for head to head mode
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 1, <SpriteIndex_Bonus_Part1 + 1
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 2, <SpriteIndex_Bonus_Part1 + 2
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 3, <SpriteIndex_Bonus_Part1 + 3
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 4, <SpriteIndex_Bonus_Part2 + 0
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 5, <SpriteIndex_Bonus_Part2 + 1
DATA_BB9_WinnerSpriteData: ; Sprite X, N for "WINNER"
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 0, <SpriteIndex_Winner + 0
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 1, <SpriteIndex_Winner + 1
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 2, <SpriteIndex_Winner + 2
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 3, <SpriteIndex_Winner + 3
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 4, <SpriteIndex_Winner + 4
.db HEAD_TO_HEAD_TEXT_X + SPRITE_WIDTH * 5, <SpriteIndex_Winner + 5

.ends

.section "FLoor tiles" force

LABEL_BC5_EmitFloorTiles:
; Emits floor tile data to VRAM, if enabled
  ld a, (_RAM_DF17_HaveFloorTiles)
  or a
  JrZRet + ; ret
  ld hl, (_RAM_DF18_FloorTilesVRAMAddress)
  ld a, l ; Point at them
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld hl, _RAM_DC59_FloorTiles
  ld b, BYTES_PER_TILE * 2
  ld c, PORT_VDP_DATA
  otir
  ld hl, _RAM_DC59_FloorTiles + BYTES_PER_TILE
  ld b, BYTES_PER_TILE ; The the same 2 tiles in the opposite order
  ld c, PORT_VDP_DATA
  otir
  ld hl, _RAM_DC59_FloorTiles
  ld b, BYTES_PER_TILE
  ld c, PORT_VDP_DATA
  otir
+:ret

LABEL_BF0_ScrollFloorTileData:
  ; Skip for tracks without floors
  ; (Could use _RAM_DF17_HaveFloorTiles?)
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
  call LABEL_C81_ScrollFloorTiles_X

  ; Then flip the bit. This is what makes the floor scroll slower
  ; (we use it to scroll half-rate) and also makes any half-motion alternate X and Y between frames.
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  xor $01
  ld (_RAM_DEF8_FloorScrollingRateLimiter), a

  ; Then do vertically
  ld a, (_RAM_DEF6_FloorScrollingYAmount)
  ld b, a
  and $80 ; Check sign
  ld l, a
  ld a, b
  and $7F
  or a
  JrZRet @ret ; Nothing to do
  dec a
  jr z, @1
  dec a
  jr z, @2
  dec a
  jr z, @3
  dec a
  jr z, @4
  dec a
  jr z, @5
  dec a
  jr z, @6
  dec a
  jr z, @7
  dec a
  jr z, @8
  ; Give up if we go this far(!)
@ret:
  ret

@1: ; Shift 50% of the time
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  ; fall through
@2: ; Shift 1 row
  jp LABEL_CF8_ScrollFloorTiles_Y_Row

@3: ; Shift 1 or 2
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  jp LABEL_CF8_ScrollFloorTiles_Y_Row

@4: ; Shift 2
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  jp LABEL_CF8_ScrollFloorTiles_Y_Row

@5: ; Shift 2 or 3
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  jp LABEL_CF8_ScrollFloorTiles_Y_Row

@6: ; Shift 3
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  jp LABEL_CF8_ScrollFloorTiles_Y_Row

@7: ; Shift 3 or 4
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  jp LABEL_CF8_ScrollFloorTiles_Y_Row

@8: ; Shift 4
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  call LABEL_CF8_ScrollFloorTiles_Y_Row
  jp LABEL_CF8_ScrollFloorTiles_Y_Row

LABEL_C81_ScrollFloorTiles_X:
  ld a, (_RAM_DEF7_FloorScrollingXAmount)
  ld b, a
  and $80
  ld l, a ; High bit -> l
  ld a, b
  and $7F
  or a
  JrZRet @ret ; Nothing to do
  dec a
  jr z, @1
  dec a
  jr z, @2
  dec a
  jr z, @3
  dec a
  jr z, @4
  dec a
  jr z, @5
  dec a
  jr z, @6
  dec a
  jr z, @7
  dec a
  jr z, @8
  ; Give up if we go this far(!)
@ret:
  ret

@1: ; Shift 50% of the time
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  ; fall though
@2: ; Shift 1 row
  jp LABEL_DCF_ScrollFloorTiles_X_Column

@3: ; Shift 1 or 2
  call LABEL_DCF_ScrollFloorTiles_X_Column
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  jp LABEL_DCF_ScrollFloorTiles_X_Column

@4: ; Shift 2
  call LABEL_DCF_ScrollFloorTiles_X_Column
  jp LABEL_DCF_ScrollFloorTiles_X_Column

@5: ; Shift 2 or 3
  call LABEL_DCF_ScrollFloorTiles_X_Column
  call LABEL_DCF_ScrollFloorTiles_X_Column
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  jp LABEL_DCF_ScrollFloorTiles_X_Column

@6: ; Shift 3
  call LABEL_DCF_ScrollFloorTiles_X_Column
  call LABEL_DCF_ScrollFloorTiles_X_Column
  jp LABEL_DCF_ScrollFloorTiles_X_Column

@7: ; Shift 3 or 4
  call LABEL_DCF_ScrollFloorTiles_X_Column
  call LABEL_DCF_ScrollFloorTiles_X_Column
  call LABEL_DCF_ScrollFloorTiles_X_Column
  ld a, (_RAM_DEF8_FloorScrollingRateLimiter)
  or a
  JrZRet @ret
  jp LABEL_DCF_ScrollFloorTiles_X_Column

@8: ; Shift 4
  call LABEL_DCF_ScrollFloorTiles_X_Column
  call LABEL_DCF_ScrollFloorTiles_X_Column
  call LABEL_DCF_ScrollFloorTiles_X_Column
  jp LABEL_DCF_ScrollFloorTiles_X_Column

LABEL_CF8_ScrollFloorTiles_Y_Row:
  push hl
    ld a, l
    cp $80
    jp z, LABEL_D67_ScrollFloorTiles_Y_Row_Up

    ; Move the data down
    ; We do this by:
    ; - Reading the bottom row into a temp variable
    ; - Copying each row from 4 bytes above
    ; - Filling in the temporary at the end
    .macro RotateBitplaneVertically args direction, bitplane
    ; Calculate offset of top/bottom row
    .if direction == +1
      .define n BYTES_PER_TILE + BYTES_PER_ROW * 7 + bitplane
    .else
      .define n bitplane
    .endif
    ; Copy into temp
    ld a, (_RAM_DC59_FloorTiles + n)
    ld (_RAM_DE59_FloorTileRotationTemp), a
    ; Copy all the others from above/below
    .repeat SPRITE_HEIGHT * 2 - 1 ; (15 rows)
    ld a, (_RAM_DC59_FloorTiles + n - BYTES_PER_ROW * direction)
    ld (_RAM_DC59_FloorTiles + n), a
      .redefine n, n - BYTES_PER_ROW * direction
    .endr
    ; And the final one comes from temp
    ld a, (_RAM_DE59_FloorTileRotationTemp)
    ld (_RAM_DC59_FloorTiles + n), a
    .undefine n
    .endm
    
    RotateBitplaneVertically +1, 2
  pop hl
  ret

LABEL_D67_ScrollFloorTiles_Y_Row_Up:
    RotateBitplaneVertically -1, 2
  pop hl
  ret

LABEL_DCF_ScrollFloorTiles_X_Column:
  push hl
    ld a, l
    cp $80
    jp z, LABEL_E3C_ScrollFloorTiles_X_Column_Right

    ; Move them left
    ; We rotate bitplane 2 left by:
    ; - Rotate +2 into carry
    ; - Rotate carry into +34 (next tile)
    ; - Rotate carry into +2
    ; This is done for 8 rows
    .macro RotateBitplaneRowLeft args rowNumber, bitplaneNumber
      ld a, (_RAM_DC59_FloorTiles + (rowNumber * BYTES_PER_ROW) + bitplaneNumber)
      rla
      rl (ix+(rowNumber * BYTES_PER_ROW) + bitplaneNumber + BYTES_PER_TILE)
      rl (ix+(rowNumber * BYTES_PER_ROW) + bitplaneNumber)
    .endm
    ld ix, _RAM_DC59_FloorTiles
    RotateBitplaneRowLeft 0 2
    RotateBitplaneRowLeft 1 2
    RotateBitplaneRowLeft 2 2
    RotateBitplaneRowLeft 3 2
    RotateBitplaneRowLeft 4 2
    RotateBitplaneRowLeft 5 2
    RotateBitplaneRowLeft 6 2
    RotateBitplaneRowLeft 7 2
  pop hl
  ret

LABEL_E3C_ScrollFloorTiles_X_Column_Right:
    ; We rotate bitplane 2 right by:
    ; - Rotate +34 into carry
    ; - Rotate carry into +2 (previous tile)
    ; - Rotate carry into +34
    ; This is done for 8 rows
    ; (Not necessary to inert the order from above, it works either way)
    .macro RotateBitplaneRowRight args rowNumber, bitplaneNumber
      ld a, (_RAM_DC59_FloorTiles + (rowNumber * BYTES_PER_ROW) + bitplaneNumber + BYTES_PER_TILE)
      rra
      rr (ix+(rowNumber * BYTES_PER_ROW) + bitplaneNumber)
      rr (ix+(rowNumber * BYTES_PER_ROW) + bitplaneNumber + BYTES_PER_TILE)
    .endm
    ld ix, _RAM_DC59_FloorTiles
    RotateBitplaneRowRight 0 2
    RotateBitplaneRowRight 1 2
    RotateBitplaneRowRight 2 2
    RotateBitplaneRowRight 3 2
    RotateBitplaneRowRight 4 2
    RotateBitplaneRowRight 5 2
    RotateBitplaneRowRight 6 2
    RotateBitplaneRowRight 7 2
  pop hl
  ret
.ends

.section "Bank 0 unknown" force
DATA_EA2_: ; Engine velocity related? Maybe somethingt o do with slowing down while turning?
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $01
.db $00 $00 $01 $01 $02 $02 $01 $01 $02 $02 $03 $03 $02 $02 $03 $03 $04 
.db $04 $03 $03 $04 $04 $05 $05 $04 $04 $05 $05 $06 $06 $05 $05 $06 $06
.ends

.section "Trampolines 3" force
LABEL_EE6_:
  JumpToPagedFunction PagedFunction_363D9_
.ends
  
.section "Bank 0 unknown 2" force
LABEL_EF1_:
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_D5A3_), a
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr z, +
  ; Car is off the ground
  ld a, (_RAM_DF01_)
  or a
  jr nz, +
  ld a, (_RAM_DF03_Jump_Active)
  cp $02
  jr z, LABEL_F6F_ret
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
  
  ; Check for L
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_L_MASK ; $04
  jr z, LABEL_F75_
  jp ++

+:; Check for R
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
  JrNzRet LABEL_F6F_ret
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
  ld a, (_RAM_DE92_EngineSpeed)
  sub l
  ld l, a
  and $80
  jr nz, +
  ld a, l
  ld (_RAM_DE96_Speed), a
LABEL_F6F_ret:
  ret

+:xor a
  ld (_RAM_DE96_Speed), a
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

+:xor a
  ld (_RAM_DEA5_), a
  ld (_RAM_DEA7_), a
  ld a, (_RAM_DE92_EngineSpeed)
  ld (_RAM_DE96_Speed), a
  ret

LABEL_F9B_:
  xor a
  ld (_RAM_DEAF_HScrollDelta), a
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
  ld a, (_RAM_DF58_ResettingCarToTrack)
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
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  jr nz, LABEL_102B_
+:
  ld a, $02
  ld (_RAM_DE96_Speed), a
  ld (_RAM_DE92_EngineSpeed), a
  ld a, $01
  ld (_RAM_D5A4_IsReversing), a
  ld a, (_RAM_DE90_CarDirection)
  ld d, $00
  ld e, a
  ld hl, DATA_250E_OppositeDirections
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
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_D5A4_IsReversing), a
+:
  ld a, (_RAM_DF65_HasFinished)
  or a
  jr z, +
LABEL_1024_:
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  jp z, LABEL_109B_
LABEL_102B_:
  ld hl, _RAM_DEB4_DecelerationDelayCounter
  inc (hl)
  ld a, (hl)
  cp $07
  jr c, LABEL_1081_
  ld a, $00
  ld (_RAM_DEB4_DecelerationDelayCounter), a
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr nz, LABEL_1081_
  ld hl, _RAM_DE92_EngineSpeed
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
  ld a, (_RAM_DE92_EngineSpeed)
  CP_0
  jp z, LABEL_109B_
  ld a, (_RAM_DB9A_DecelerationDelay)
  ld b, a
  ld hl, _RAM_DEB4_DecelerationDelayCounter
  inc (hl)
  ld a, (hl)
  cp b
  jp c, LABEL_1081_
  ld a, $00
  ld (_RAM_DEB4_DecelerationDelayCounter), a
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jp nz, LABEL_1081_
  ld hl, _RAM_DE92_EngineSpeed
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
  DEC_A
  ld (_RAM_DEB4_DecelerationDelayCounter), a
  ld a, (_RAM_DB99_AccelerationDelay)
  DEC_A
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
  ld a, (_RAM_DE92_EngineSpeed)
  ld l, a
  ld a, h
  cp l
  jr nz, +
  jp LABEL_111E_

+:; Not at top speed yet
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr nz, LABEL_111E_
  ; Speed up!
  ld hl, _RAM_DE92_EngineSpeed
  inc (hl)
LABEL_111E_:
  call LABEL_EF1_
LABEL_1121_:
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_DE96_Speed)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_DE96_Speed)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, DATA_3FC3_HorizontalAmountByDirection
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
  ld (_RAM_DEAF_HScrollDelta), a
  ld hl, DATA_40E5_Sign_Directions_X
  ld a, (_RAM_D5A3_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
  jr z, +
  xor a
  ld (_RAM_DEB0_), a
  ld hl, _RAM_DEAF_HScrollDelta
  jp ++

+:
  ld a, $01
  ld (_RAM_DEB0_), a
  ld hl, _RAM_DEAF_HScrollDelta
++:
  ld hl, DATA_3FD3_VerticalAmountByDirection
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
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (_RAM_D5A3_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
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
  ld a, (_RAM_D5B6_SkidDuration)
  or a
  jr z, +
  dec a
  ld (_RAM_D5B6_SkidDuration), a
+:
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  JrNzRet +
  ld a, (_RAM_DC4D_Cheat_NoSkidding)
  or a
  jr nz, ++
  ld a, (_RAM_DE92_EngineSpeed)
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
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr z, LABEL_11E4_
  ret

+++:
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet +
  ld a, (_RAM_D5B6_SkidDuration)
  or a
  JrNzRet _LABEL_121A_ret
  ld a, (_RAM_DEA0_)
  CP_0
  jr z, ++
  DEC_A
  ld (_RAM_DEA0_), a
+:ret
.ifdef JUMP_TO_RET
_LABEL_121A_ret:
  ret
.endif

++:
  ld a, (_RAM_DEA3_)
  DEC_A
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
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet +
  ld a, (_RAM_D5B6_SkidDuration)
  or a
  JrNzRet _LABEL_121A_ret
  ld a, (_RAM_DEA0_)
  CP_0
  jr z, ++
  DEC_A
  ld (_RAM_DEA0_), a
+:ret

++:
  ld a, (_RAM_DEA3_)
  DEC_A
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
  ld de, (_RAM_DE96_Speed)
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

.ends

.section "Trampolines 4" force
LABEL_12BF_Trampoline_PagedFunction_35F8A_:
  JumpToPagedFunction PagedFunction_35F8A_

LABEL_12CA_Trampoline_PagedFunction_36209_:
  JumpToPagedFunction PagedFunction_36209_

LABEL_12D5_Trampoline_PagedFunction_1FA3D_:
  JumpToPagedFunction PagedFunction_1FA3D_
.ends

.section "Game screen tilemap drawing" force
_DrawTilemapRectangle:
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
.ifdef UNNECESSARY_CODE
  ld de, (_RAM_DB9C_MetatilemapWidth)
.else
  ld de, 32
.endif
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

    ld a, <(VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2)
    ld (_RAM_DEC1_VRAMAddress.Lo), a
    ld a, >(VRAM_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2)
    ld (_RAM_DEC1_VRAMAddress.Hi), a

    push hl
      call _DrawTilemapRectangle
    pop hl
  .endm
  
  call LABEL_1583_SetDrawingParameters_FullMetatile
  DrawNextMetatile  0,  0
  inc hl
  DrawNextMetatile 12,  0
  call LABEL_64E5_SetDrawingParameters_PartialMetatile
  inc hl
  DrawNextMetatile 24,  0

.ifdef UNNECESSARY_CODE
  ld de, (_RAM_DB9C_MetatilemapWidth)
.else
  ld de, 32
.endif
  ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de

  call LABEL_1583_SetDrawingParameters_FullMetatile
  DrawNextMetatile 0, 12
  inc hl
  DrawNextMetatile 12, 12
  call LABEL_64E5_SetDrawingParameters_PartialMetatile
  inc hl
  DrawNextMetatile 24, 12

.ifdef UNNECESSARY_CODE
  ld de, (_RAM_DB9C_MetatilemapWidth)
  ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de
  add hl, de
.else
  ld de, 32*2
  ld hl, (_RAM_DED1_MetatilemapPointer)
  add hl, de
.endif
  
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
  INC_A ; 2 for SMS
  ld (_RAM_DED7_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld (_RAM_DEEB_), a
  ld a, $06 ; 4 for SMS
  ld (_RAM_DEE3_), a
  xor a
  ld (_RAM_DEE5_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld (_RAM_DEDB_), a
  INC_A ; 2 for SMS
  ld (_RAM_DED9_), a
  xor a
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  or a
  jr z, +
  ld bc, (_RAM_DBA2_TopLeftMetatileY)
.ifdef UNNECESSARY_CODE
  ld de, (_RAM_DB9C_MetatilemapWidth)
.else
  ld de, 32
.endif
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
.ifdef UNNECESSARY_CODE
  ld de, (_RAM_DB9C_MetatilemapWidth)
.else
  ld de, 32
.endif
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
.ends

.section "Unknown slot 0" force
; Scrolling and tilemap updates?
LABEL_1593_:
  xor a
  ld (_RAM_DEF6_FloorScrollingYAmount), a
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
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  jr nz, +
-:ret
+:ld a, (_RAM_DEB2_)
  cp $01
  JrNzRet - ; ret
  call LABEL_3E24_
  ld a, (_RAM_DEB1_VScrollDelta)
  ld (_RAM_DEF6_FloorScrollingYAmount), a
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
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  jr nz, +
-:ret
+:ld a, (_RAM_DEB2_)
  or a
  JrNzRet - ; ret
  call LABEL_7C72_
  ld a, (_RAM_DEB1_VScrollDelta)
  or $80
  ld (_RAM_DEF6_FloorScrollingYAmount), a
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
  ld (_RAM_DEF7_FloorScrollingXAmount), a
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
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  jr nz, +
-:ret

+:ld a, (_RAM_DEB0_)
  or a
  JrNzRet -
  call LABEL_7C67_
  ld a, (_RAM_DEAF_HScrollDelta)
  ld (_RAM_DEF7_FloorScrollingXAmount), a
  ld l, a
  ld a, (_RAM_DED3_HScrollValue)
  and $07
  add a, l
  cp $08
  jr z, +
  jr c, ++
+:
  ld a, (_RAM_DEAF_HScrollDelta)
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
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  jr nz, +
-:
  ret

+:
  ld a, (_RAM_DEB0_)
  cp $01
  jr nz, -
  call LABEL_3E2F_
  ld a, (_RAM_DEAF_HScrollDelta)
  or $80
  ld (_RAM_DEF7_FloorScrollingXAmount), a
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DED3_HScrollValue)
  and $07
  sub l
  jr nc, +
  call ++
  ld a, (_RAM_DEAF_HScrollDelta)
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
  INC_A
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
  INC_A
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
  INC_A
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
  ld a, <_RAM_DB22_TilemapUpdate_HorizontalTileNumbers
  ld (_RAM_DB62_.Lo), a
  ld a, >_RAM_DB22_TilemapUpdate_HorizontalTileNumbers
  ld (_RAM_DB62_.Hi), a
  xor a
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  ld a, (_RAM_DEEB_)
  and $1F
  or a
  jr z, +
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_30EA_MultiplyBy32
  ld a, (_RAM_DEF1_Multiply_Result.Lo)
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
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
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld l, a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, l
.else
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, 32
.endif
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
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld l, a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, l
.else
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, 32
.endif
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
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld l, a
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, l
.else
  ld a, (_RAM_DED1_MetatilemapPointer.Lo)
  add a, 32
.endif
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
  ld a, <_RAM_DB42_TilemapUpdate_VerticalTileNumbers
  ld (_RAM_DB64_.Lo), a
  ld a, >_RAM_DB42_TilemapUpdate_VerticalTileNumbers
  ld (_RAM_DB64_.Hi), a
  xor a
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld (_RAM_DED1_MetatilemapPointer.Hi), a
  ld a, (_RAM_DEEB_)
  and $1F
  or a
  jr z, +
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_30EA_MultiplyBy32
  ld a, (_RAM_DEF1_Multiply_Result.Lo)
  ld (_RAM_DED1_MetatilemapPointer.Lo), a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
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
  TimesTableLo 0, 12, 12

LABEL_19EE_:
  ; Copy 32 bytes from DATA_4105_CarDecoratorOffsets+_RAM_DB97_TrackType*32 to _RAM_DA00_DecoratorOffsets ; TODO what is it?
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
  ld hl, DATA_4105_CarDecoratorOffsets
  add hl, de
  ld bc, 32
  ld de, _RAM_DA00_DecoratorOffsets
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
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld a, (_RAM_DEF1_Multiply_Result.Lo)
  ld (_RAM_DBAB_), a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld (_RAM_DBAC_), a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld a, (_RAM_DEF1_Multiply_Result.Lo)
  ld (_RAM_DBA9_), a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld (_RAM_DBAA_), a
  call LABEL_48C2_Trampoline_PagedFunction_23BF1_
  JumpToPagedFunction PagedFunction_237E2_

LABEL_1AC8_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, $01
  ld (_RAM_DF0C_), a
  xor a
  ld (_RAM_DF0E_), a
+:ret
.ends

.section "More slot 0" force
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

LABEL_1B0C_DecrementYPosition:
  ; Subtracts 1 from YPosition if Unknown22_b != 1 (and then sets it to 1)
  ld a, (ix+CarData.Unknown22_b)
  cp 1
  JrZRet +
  ld de, 1
  or a
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  sbc hl, de ; could dec hl
  ld a, l
  ld (ix+CarData.YPosition.Lo), a
  ld a, h
  ld (ix+CarData.YPosition.Hi), a
  ld a, 1
  ld (ix+CarData.Unknown22_b), a
+:ret

LABEL_1B2F_IncrementYPosition:
  ld a, (ix+CarData.Unknown22_b)
  cp 1
  JrZRet +
  ld de, 1
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  add hl, de
  ld a, l
  ld (ix+CarData.YPosition.Lo), a
  ld a, h
  ld (ix+CarData.YPosition.Hi), a
  ld a, 1
  ld (ix+CarData.Unknown22_b), a
+:ret

LABEL_1B50_DecrementXPosition:
  ld a, (ix+CarData.Unknown23_b)
  cp 1
  JrZRet +
  ld de, 1
  or a
  ld a, (ix+CarData.XPosition.Lo)
  ld l, a
  ld a, (ix+CarData.XPosition.Hi)
  ld h, a
  sbc hl, de
  ld a, l
  ld (ix+CarData.XPosition.Lo), a
  ld a, h
  ld (ix+CarData.XPosition.Hi), a
  ld a, 1
  ld (ix+CarData.Unknown23_b), a
+:ret

LABEL_1B73_IncrementXPosition:
  ld a, (ix+CarData.Unknown23_b)
  cp 1
  JrZRet +
  ld de, 1
  ld a, (ix+CarData.XPosition.Lo)
  ld l, a
  ld a, (ix+CarData.XPosition.Hi)
  ld h, a
  add hl, de
  ld a, l
  ld (ix+CarData.XPosition.Lo), a
  ld a, h
  ld (ix+CarData.XPosition.Hi), a
  ld a, 1
  ld (ix+CarData.Unknown23_b), a
+:ret

LABEL_1B94_Multiply:
  ; Could check for parameters = 0 for speed?
  ; _RAM_DEF5_Multiply_Parameter1 can be any value (8 bits)
  ; _RAM_DEF4_Multiply_Parameter2 only has bits 2-6 considered (as if masked by %01111100)
  ; The implementation could be a bit faster - it uses RAM unnecessarily (including parameter passing) and re-shifts the value in de many times when multiple bits are set in the multiplier.
  ; Specialised versions are used for parameter 2 = 32 and 96 (using LUTs), see LABEL_3100_MultiplyBy96 and LABEL_30EA_MultiplyBy32
  ; The values passed in parameter 2 do use the low bits

  ; Copy number to be multiplied to the result
  ; This is used as a backup while we modify de
  xor a
  ld (_RAM_DEF1_Multiply_Result.Hi), a
  ld a, (_RAM_DEF5_Multiply_Parameter1)
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  ; hl = accumulator
  ld hl, $0000
  ; de = number to be multiplied by the stride
  ld de, (_RAM_DEF1_Multiply_Result)
  ; Get second parameter
  ld a, (_RAM_DEF4_Multiply_Parameter2)
  
  ; Ignore first two bits
  rra
  rra
  
.macro HandleBit args index, reGetMultiplier
  ; Shift out bit
  rra
  ; Check if it was set
  jr nc, +
  .if reGetMultiplier == 1
  ld de, (_RAM_DEF1_Multiply_Result)
  .endif
  ; Shift de by the right number of bits
  .repeat index
  sla e
  rl d
  .endr
  ; Add it on
  add hl, de
+:
.endm

  HandleBit 2, 0
  HandleBit 3, 1
  HandleBit 4, 1
  HandleBit 5, 1
  HandleBit 6, 1

  ld (_RAM_DEF1_Multiply_Result), hl
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
  ld hl, (_RAM_DE79_CurrentMetatile_OffsetX)
  add hl, de
  ld (_RAM_DBB1_), hl
  ld de, (_RAM_DBA2_TopLeftMetatileY)
  ld hl, (_RAM_DE7B_CurrentMetatile_OffsetY)
  add hl, de
  ld (_RAM_DBB3_), hl
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld (_RAM_DBB5_LayoutByte_), a
  ld a, (_RAM_DF4F_LastTrackPositionIndex)
  ld (_RAM_D5DE_), a
  ret

LABEL_1CBD_GetCurrentMetatileIndex:
  ; Zero the offset (by default)
  xor a
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  ld (_RAM_DEF1_Multiply_Result.Hi), a
  
  ; Look up metatile in memory
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_CurrentMetatile_OffsetY)
  add a, l
  and $1F ; limit to range (max 32)
  jr z, + ; Zero -> no multiplication needed
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_30EA_MultiplyBy32
+:; Load the resulting offset to hl
  ld a, (_RAM_DEF1_Multiply_Result.Lo)
  ld l, a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld h, a
  ; Then add on the X offset
  ld de, (_RAM_DE79_CurrentMetatile_OffsetX)
  add hl, de
  ld de, (_RAM_DBA0_TopLeftMetatileX)
  add hl, de
  ld de, _RAM_C000_LevelLayout
  add hl, de
  ld a, (hl)
  ret
.ends

.section "Trampolines 5" force
LABEL_1CF4_Trampoline_PagedFunction_1FB35_:
  JumpToPagedFunction PagedFunction_1FB35_
.ends

.section "bank 0 again" force
LABEL_1CFF_StopChallengeRace:
  ; All cars finished
  ld a, $01
  ld (_RAM_DF65_HasFinished), a
  ld (_RAM_DCAB_CarData_Green.Unknown26_b_HasFinished), a
  ld (_RAM_DCEC_CarData_Blue.Unknown26_b_HasFinished), a
  ld (_RAM_DD2D_CarData_Yellow.Unknown26_b_HasFinished), a
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

; This really doesn't need to be here!
DATA_1D25_ChoppersAnimatedPalette_GG:
  GGCOLOUR $0000ee
  GGCOLOUR $4444ee
  GGCOLOUR $8888ee
  GGCOLOUR $eeeeee
  GGCOLOUR $0000ee
  GGCOLOUR $4444ee
  GGCOLOUR $8888ee
  GGCOLOUR $eeeeee

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

; Split table pointing at ???
; Low bytes
DATA_1D65__Lo:
.db <Data1d65_0 <Data1d65_1 <Data1d65_2 <Data1d65_3 <Data1d65_4 <Data1d65_5 <Data1d65_6 <Data1d65_7 <Data1d65_8 <Data1d65_9 <Data1d65_10 <Data1d65_11 <Data1d65_12 <Data1d65_13 <Data1d65_14 <Data1d65_15 <Data1d65_16 

; High bytes
DATA_1D76__Hi:
.db >Data1d65_0 >Data1d65_1 >Data1d65_2 >Data1d65_3 >Data1d65_4 >Data1d65_5 >Data1d65_6 >Data1d65_7 >Data1d65_8 >Data1d65_9 >Data1d65_10 >Data1d65_11 >Data1d65_12 >Data1d65_13 >Data1d65_14 >Data1d65_15 >Data1d65_16 

; Data from 1D87 to 1D96 (16 bytes)
DATA_1D87_Default_:
; Used when bit 7 of layout data is 0
.db $04 $06 $08 $0A $0C $0E $00 $02 $05 $07 $09 $0B $0D $0F $01 $03
; E, SE, S, SW, W, NW, N, NE; then around again one notch to the right

; Data from 1D97 to 1DA6 (16 bytes)
DATA_1D97_OppositeDirections:
; Used when bit 6 of layout data is 1
; Selects the opposite direction by index
.db $08 $09 $0A $0B $0C $0D $0E $0F $00 $01 $02 $03 $04 $05 $06 $07

; Data from 1DA7 to 1DE6 (64 bytes)
DATA_1DA7_Special_:
; Chunks of 16 bytes, selected by bits 5-6 of metatile byte in _RAM_D900_UnknownData
; Used when high bit of layout data is 1
.db $0C $0A $08 $06 $04 $02 $00 $0E $0B $09 $07 $05 $03 $01 $0F $0D
; Rotating left from W to NW in steps of 2, then from WSW
.db $04 $02 $00 $0E $0C $0A $08 $06 $03 $01 $0F $0D $0B $09 $07 $05
.db $00 $0E $0C $0A $08 $06 $04 $02 $0F $0D $0B $09 $07 $05 $03 $01
.db $08 $06 $04 $02 $00 $0E $0C $0A $07 $05 $03 $01 $0F $0D $0B $09
.ends

.section "Trampolines 6" force
LABEL_AFD_ReadControls_Trampoline:
  JumpToPagedFunction PagedFunction_3773B_ReadControls
.ends

.section "Bank 0 1df2" force
LABEL_1DF2_:
  ld b, $00
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  ld b, $07
+:
  ld a, (_RAM_DBA4_CarX)
  ld (_RAM_DF04_CarX_), a
  ld a, (_RAM_DBA5_CarY)
  ld (_RAM_DF05_CarY_), a
  ld a, (_RAM_DC56_Adjustment1_XY)
  ld c, a
  
  ld a, (_RAM_DED3_HScrollValue)
  and $07
  ld l, a
  ld a, (_RAM_DBA6_CarX_Next)
  add a, $0C  ; +12
  add a, b    ; +7 if RuffTrux
  sub l       ; -(0..7) for hscroll "fine" adjustment
  rr a        ; /8
  rr a
  rr a
  sub c       ; -_RAM_DC56_Adjustment1_XY
  and $1F     ; And mask
  ld (_RAM_DE71_CarX_Adjusted_), a
  
  ; Similar for Y
  ld a, (_RAM_DED4_VScrollValue)
  and $07
  ld l, a
  ld a, (_RAM_DBA7_CarY_Next)
  add a, $0C
  add a, b
  add a, l
  rr a
  rr a
  rr a
  sub c
  and $1F
  ld (_RAM_DE73_CarY_Adjusted_), a
  
  ; Look up "adjusted" values in a table, plus some other delta
  ld hl, DATA_251E_DivMod12
  ld de, (_RAM_DE71_CarX_Adjusted_)
  add hl, de
  ld de, (_RAM_DEDF_) ; Tile offset of current top-left metatile?
  add hl, de
  ld a, (hl)
  ld b, a
  and $0F
  ld (_RAM_DE75_CurrentMetaTile_TileX), a
  ld a, b
  rr a
  rr a
  rr a
  rr a
  and $03
  ld (_RAM_DE79_CurrentMetatile_OffsetX), a
  ; Repeat for Y
  ld hl, DATA_251E_DivMod12
  ld de, (_RAM_DE73_CarY_Adjusted_)
  add hl, de
  ld de, (_RAM_DEE5_)
  add hl, de
  ld a, (hl)
  ld b, a
  and $0F
  ld (_RAM_DE77_CurrentMetatile_TileY), a
  ld a, b
  rr a
  rr a
  rr a
  rr a
  and $03
  ld (_RAM_DE7B_CurrentMetatile_OffsetY), a
  
  ; Then use them...
  ; X
  ld a, (_RAM_DE79_CurrentMetatile_OffsetX)
  ld l, a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  add a, l
  and $1F
  ld c, a
  ld b, $00
  xor a
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  ld (_RAM_DEF1_Multiply_Result.Hi), a
  ; Y
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_CurrentMetatile_OffsetY)
  add a, l
  and $1F
  jr z, +
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_30EA_MultiplyBy32
+:
  ld a, (_RAM_DEF1_Multiply_Result.Lo)
  ld l, a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld h, a
  add hl, bc
  ld (_RAM_D585_CurrentMetatileOffset), hl

  ld de, _RAM_C000_LevelLayout ; Look up in the level layout
  add hl, de
  ld a, (hl)
  ld (_RAM_DE7D_CurrentLayoutData), a
  
  ld hl, (_RAM_D585_CurrentMetatileOffset)
  ld de, _RAM_C400_TrackIndexes
  add hl, de
  ld a, (hl)
  ld (_RAM_D587_CurrentTrackPositionIndex), a
  
  ; Multiply index by 18 == _sizeof_WallDataMetaTile
  ld hl, DATA_254E_TimesTable18Lo
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
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
  
  ; Then offset within that to the WallDataMetaTile instance
  ld hl, DATA_2652_TimesTable12Lo
  ld de, (_RAM_DE77_CurrentMetatile_TileY)
  add hl, de
  ld a, (hl)
  ld l, a
  xor a
  ld h, a
  ld de, (_RAM_DE75_CurrentMetaTile_TileX)
  add hl, de
  
  ; Save that
  ld a, l
  ld (_RAM_DE6B_OffsetInCurrentMetatile.Lo), a
  ld a, h
  ld (_RAM_DE6B_OffsetInCurrentMetatile.Hi), a
  
  ; Next divide by 8
  ld de, DATA_16A38_DivideBy8
  add hl, de
  ld a, :DATA_16A38_DivideBy8
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  
  ; And now we can lok up the wall data
  xor a
  ld h, a
  add hl, bc
  ld a, (hl)
  ld (_RAM_DE6F_CurrentWallData), a
  ; And mask it to the right bit
  ld a, (_RAM_DE6B_OffsetInCurrentMetatile.Lo)
  ld l, a
  ld a, (_RAM_DE6B_OffsetInCurrentMetatile.Hi)
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
  ; Powerboats: skip bitmask check for tile 0 (bubbles) and $1a (duck in bubbles)
  ; BUGFIX correct the wall data and remove this
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  jr z, ++
  cp $1A
  jr z, ++
+:; Mask to the right bit
  ld a, (_RAM_DE6F_CurrentWallData)
  and b
  jp z, _LABEL_1FDC_NoWall
@Wall:
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, ++
@@FourByFour:
  ld a, :DATA_37232_FourByFour_WallOverrides
  ld (PAGING_REGISTER), a
  ld hl, DATA_37232_FourByFour_WallOverrides
  ld d, $00
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld e, a
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, l
  or a
  jr nz, _LABEL_1FDC_NoWall
++:
  ; Ignore walls while resetting
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  jr nz, _LABEL_1FDC_NoWall
  ; And while in the pool table
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  jr nz, _LABEL_1FDC_NoWall
  ; More wall skipping...
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr nz, +
@@Tanks:
  ; BUGFIX change wall data, remove this
  ; Ignore walls on books
  ld a, (_RAM_DE7D_CurrentLayoutData) ; BUG: doesn't and LAYOUT_INDEX_MASK
  cp $15 ; Book with marble next to it -> excluded (because of the marble? Leaves a weird wall)
  jr z, +
  cp $0D ; First book
  jr c, +
  cp $18 ; Last book
  jr c, _LABEL_1FDC_NoWall
+:; PLay SFX only when driving forwards
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr nz, +
  ld a, SFX_03_Crash
  ld (_RAM_D963_SFX_Player1.Trigger), a
+:; Engine to lowest pitch
  ld hl, LOWEST_PITCH_ENGINE_TONE
  ld (_RAM_D95B_EngineSound1.Tone), hl
  call LABEL_28AC_BounceOffBarrier ; Changes the speed, etc
  xor a
  ld (_RAM_DEAF_HScrollDelta), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DF7B_Powerboats_BubblePush_Strength), a
  ld a, (_RAM_DBA4_CarX)
  ld (_RAM_DBA6_CarX_Next), a
  ld a, (_RAM_DBA5_CarY)
  ld (_RAM_DBA7_CarY_Next), a
  
  ; Are we jumping?
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr z, +
  ; Yes
  ; Set a bunch of stuff...
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

_LABEL_1FDC_NoWall:
  ; Save current X, Y
  ld a, (_RAM_DBA4_CarX)
  ld (_RAM_DE5C_CarX_Previous), a
  ld a, (_RAM_DBA5_CarY)
  ld (_RAM_DE5D_CarY_Previous), a
  ; And then pick up the new values
  ld a, (_RAM_DBA6_CarX_Next)
  ld (_RAM_DBA4_CarX), a
  ld a, (_RAM_DBA7_CarY_Next)
  ld (_RAM_DBA5_CarY), a
+:

  ; Now we look at the "behaviour data"

  ; Compute de = _RAM_DE7D_CurrentLayoutData * 36
  ld hl, DATA_25D0_TimesTable36Lo
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
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
  ; Offset into _RAM_CC80_BehaviourData to get the data for that metatile
  ld hl, _RAM_CC80_BehaviourData
  add hl, de
  ld b, h
  ld c, l
  ; Then convert our position in that metatile from 12x12 to 6x6
  ld a, (_RAM_DE6B_OffsetInCurrentMetatile.Lo)
  ld l, a
  ld a, (_RAM_DE6B_OffsetInCurrentMetatile.Hi)
  ld h, a
  ld a, :DATA_1B1A2_12x12To6x6
  ld (PAGING_REGISTER), a
  ld de, DATA_1B1A2_12x12To6x6
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  xor a
  ld h, a
  ; And point to the behaviour byte
  add hl, bc
  
  ; Handle resetting?
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  jp nz, LABEL_23DD_
  
  ld a, (hl) ; Load behaviour byte
  ld (_RAM_DF79_CurrentBehaviourByte), a ; Store here
  ld h, a ; And two copies
  ld l, a
  ld a, (_RAM_DC51_PreviousBehaviourByte) ; Compare to this
  cp l
  jr z, +
  ld (_RAM_DC52_PreviousDifferentBehaviourByte), a ; If not the same, shuffle over and put the new one there
  ld a, l
  ld (_RAM_DC51_PreviousBehaviourByte), a
+:
  ld a, h
  and $F0 ; High 4 bits are "object index"
  rr a
  rr a
  rr a
  rr a
  ld b, a ; -> b

  ; Look up track type in behaviour lookup
  ld d, 0
  ld a, (_RAM_DB97_TrackType)
  or a
  rl a
  rl a
  rl a
  rl a
  ld e, a
  ld hl, DATA_242E_BehaviourLookup
  add hl, de

  ; Mosk to 4 bits (3 for powerboats)
  ld a, %1111
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, %1110
  ld c, a
+:ld a, b ; mask against the high nibble
  and c

  ld e, a ; then look up the behaviour data for that object index
  ld d, 0
  add hl, de
  ld a, (hl)

  ; Compute the current, previous and last different values for this
  ld b, a
  ld a, (_RAM_DEF9_CurrentBehaviour)
  ld (_RAM_DEFA_PreviousBehaviour), a
  cp b
  jr z, +
  ld (_RAM_DEFB_PreviousDifferentBehaviour), a
+:ld a, b
  ld (_RAM_DEF9_CurrentBehaviour), a

  ; If it's a 2-player win phase then we do not process the behaviour
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_20E3_BehaviourEnd_ret

  ; Reset CarIsSkidding flag - we may set it again shortly
  xor a
  ld (_RAM_D5CD_CarIsSkidding), a

  ; Look up behaviours
  ld a, (_RAM_DEF9_CurrentBehaviour)
  or a ; Behaviour0_Normal
  jp z, _LABEL_2121_Behaviour0_Normal
  cp Behaviour6_Bump
  jp z, _LABEL_2175_Behaviour6_Bump
  cp Behaviour4_Jump
  jp z, _LABEL_21F3_Behavour4_Jump
  cp Behaviour3_BumpDown
  jp z, _LABEL_21E1_Behaviour3_BumpDown
  cp BehaviourA_PoolTableCushion
  jp z, _LABEL_2156_BehaviourA_PoolTableCushion
  cp BehaviourB_Raised
  jp z, _LABEL_21BF_BehaviourB_Raised
  cp BehaviourD_BumpOnEntry
  jp z, _LABEL_214B_BehaviourD_BumpOnEntry
  cp Behaviour1_Fall
  jp z, LABEL_29BC_Behaviour1_Fall
  cp BehaviourE_RuffTruxWater
  jp z, LABEL_65D0_BehaviourE_RuffTruxWater
  cp BehaviourF_Explode
  jp z, LABEL_2934_BehaviourF_Explode
  cp Behaviour12_Water
  jp z, _LABEL_2C69_Behaviour12_Water
  cp Behaviour2_Dust
  jr z, _LABEL_20E4_Behaviour2_Dust
  cp Behaviour5_Skid
  jr z, _LABEL_2128_Behaviour5_Skid
  cp Behaviour8_Sticky
  jp z, _LABEL_2C29_Behaviour8_Sticky
  cp Behaviour9_PoolTableHole
  jp z, _LABEL_2AB5_Behaviour9_PoolTableHole
  cp Behaviour13_Barrier
  jp z, _LABEL_2AA0_Behaviour13_Barrier
_LABEL_20E3_BehaviourEnd_ret:
  ret

_LABEL_20E4_Behaviour2_Dust
  ; Behaviour 2 = dust/chalk
  ld a, (_RAM_DE92_EngineSpeed)
  cp DUST_MINIMUM_VELOCITY
  JrCRet + ; Only when driving fast enough
  xor a ; Effect type 0 = dust
  ld (_RAM_DD6E_CarEffects.1.NextType), a
  ld a, 1
  ld (_RAM_DD6E_CarEffects.1.Member45_Enabled2), a
+:ret

_LABEL_2128_Behaviour5_Skid
  ; Behaviour 5 = skid
  ld a, 1
  ld (_RAM_D5CD_CarIsSkidding), a
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  JrZRet +++ ; Not using the engine
  ld a, 1 ; Effect type 1 = skid
  ld (_RAM_DD6E_CarEffects.1.NextType), a
  ld (_RAM_DD6E_CarEffects.1.Member45_Enabled2), a
  ; Turbo Wheels, RuffTrux -> do not touch _RAM_D5B6_SkidDuration
  ; Warriors -> set _RAM_D5B6_SkidDuration= 8
  ; Else -> set _RAM_D5B6_SkidDuration = 16
  ld a, (_RAM_DB97_TrackType)
  cp TT_3_TurboWheels
  JrZRet +++
  cp TT_7_RuffTrux
  JrZRet +++
  cp TT_5_Warriors
  jr nz, +
  ld a, SKID_DURATION_WARRIORS
  jr ++
+:ld a, SKID_DURATION_DEFAULT
++:
  ld (_RAM_D5B6_SkidDuration), a ; set to 8 or 16 (or not at all) depending on track type
+++:ret

_LABEL_2121_Behaviour0_Normal:
  ; No effect until car is on the ground
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet _LABEL_20E3_BehaviourEnd_ret
  ; Then check to see if we have come from above
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp Behaviour4_Jump
  jr z, +
  cp BehaviourB_Raised
  jr z, +
  cp BehaviourD_BumpOnEntry
  jr z, +
  cp Behaviour3_BumpDown
  JrNzRet _LABEL_20E3_BehaviourEnd_ret
+:; If coming from 3, 4, b, d then we "bump down"
  ld a, $1C
  ld (_RAM_DF0A_JumpCurveMultiplier), a
  ld a, $08
  ld (_RAM_DF02_JumpCurveStep), a
  xor a
  ld (_RAM_DF03_Jump_Active), a
  jp LABEL_22A9_

_LABEL_214B_BehaviourD_BumpOnEntry:
  ; Same as Behaviour6_Bump only on entry
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp BehaviourD_BumpOnEntry
  JrZRet +
  jp _LABEL_2175_Behaviour6_Bump
.ifdef JUMP_TO_RET
+:ret
.endif

_LABEL_2156_BehaviourA_PoolTableCushion:
  ; In air -> do nothing
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet +
  ; If not coming from BehaviourB_Raised, do nothing
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp BehaviourB_Raised
  ; ret nz would be smaller
  jr z, ++
+:ret

++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ; Head to head -> fall? (Looks like an explode)
  ld a, $01
  ld (_RAM_D5BD_), a
  jp LABEL_29BC_Behaviour1_Fall

+:; Not head to head -> explode
  jp LABEL_2934_BehaviourF_Explode

_LABEL_2175_Behaviour6_Bump:
  ; No effect until we are on the ground
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JpNzRet _LABEL_22CC_ret ; ret
  
  ; ???
  ld a, (_RAM_DE2F_)
  or a
  jr z, +
  cp $0B
  jp ++

+:
  ld a, (_RAM_DF0F_)
++:
  ld l, a
  ld a, (_RAM_DE96_Speed)
  add a, l
  cp $0B ; Limit "speed" used here
  jr nc, +
  ld (_RAM_DE94_BumpSpeed), a
  jp ++

+:
  ld a, $0B
  ld (_RAM_DE94_BumpSpeed), a
++:
  ld hl, DATA_24AE_JumpCurveMultiplierForSpeed
  ld de, (_RAM_DE94_BumpSpeed)
  add hl, de
  ld a, (hl)
  ld (_RAM_DF0A_JumpCurveMultiplier), a
  ld hl, DATA_24BE_JumpCurveStepForSpeed
  add hl, de
  ld a, (hl)
  ld (_RAM_DF02_JumpCurveStep), a
  cp JUMP_MAX_CURVE_INDEX
  JpZRet _LABEL_22CC_ret ; ret
  ld a, $01
  ld (_RAM_DF03_Jump_Active), a
  jp LABEL_22A9_

_LABEL_21BF_BehaviourB_Raised:
  ; Only valid on FormulaOne, FourByFour tracks
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  jr z, @FormulaOne
  cp TT_1_FourByFour
  JrNzRet +
-:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  or a ; Behaviour0_Normal
  jp z, _LABEL_2200_HitBarrier
  cp Behaviour6_Bump
  jp z, _LABEL_2200_HitBarrier
+:ret

@FormulaOne:
  ; No effect unless the metatile is the playing card ramp
  ; (tile is not used anywhere else anyway)
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $1A ; PLaying card ramp
  jr z, -
  ret

_LABEL_21E1_Behaviour3_BumpDown:
  ; Only if (Behaviour0_Normal or Behaviour6_Bump) -> Behaviour7_Entry -> Behaviour3_BumpDown
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp Behaviour7_Entry
  JrZRet  +
  ld a, (_RAM_DEFB_PreviousDifferentBehaviour)
  or a ; Behaviour0_Normal
  jr z, _LABEL_2200_HitBarrier
  cp Behaviour6_Bump
  jr z, _LABEL_2200_HitBarrier
+:ret

_LABEL_21F3_Behavour4_Jump:
  ; Behaviour7_Entry -> Behaviour4_Jump => jump
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp Behaviour7_Entry
  jr z, _DoJump
  ; Behaviour0_Normal -> Behaviour4_Jump => do nothing
  ld a, (_RAM_DEFB_PreviousDifferentBehaviour)
  or a ; Behaviour0_Normal
  JrNzRet _LABEL_2222_ret
  ; Else fall through
  
_LABEL_2200_HitBarrier:
  ld a, (_RAM_DE5C_CarX_Previous)
  ld (_RAM_DBA4_CarX), a
  ld a, (_RAM_DE5D_CarY_Previous)
  ld (_RAM_DBA5_CarY), a
  call LABEL_28AC_BounceOffBarrier
  xor a
  ld (_RAM_DEAF_HScrollDelta), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DBA4_CarX)
  ld (_RAM_DBA6_CarX_Next), a
  ld a, (_RAM_DBA5_CarY)
  ld (_RAM_DBA7_CarY_Next), a
_LABEL_2222_ret:
  ret

_DoJump:
  ; Can't jump if we're in the air
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JpNzRet _LABEL_22CC_ret
  
  ; ???
  ld a, (_RAM_D5CF_Player1Handicap)
  ld l, a
  ld a, (_RAM_DE96_Speed)
  add a, l
  ld (_RAM_DE94_BumpSpeed), a
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
  ld a, (_RAM_DE96_Speed)
  add a, l
  cp $0B
  jr nc, +
  ld (_RAM_DE94_BumpSpeed), a
  jp ++

+:
  ld a, $0B
  ld (_RAM_DE94_BumpSpeed), a
++:
  ld (_RAM_DF10_), a
  ld a, $01
  ld (_RAM_DEB6_), a
+++:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24EE_GG_
  jp ++
+:ld hl, DATA_24CE_SMS_
++:
  ld de, (_RAM_DE94_BumpSpeed)
  add hl, de
  ld a, (hl)
  or a
  JrZRet _LABEL_2222_ret
  ld (_RAM_DF0A_JumpCurveMultiplier), a

  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24FE_GG_
  jp ++
+:ld hl, DATA_24DE_SMS_
++:
  add hl, de
  ld a, (hl)
  ld (_RAM_DF02_JumpCurveStep), a
  
  ld a, (_RAM_DEB5_)
  or a
  jr nz, +
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DF11_), a
  ld a, (_RAM_DE96_Speed)
  ld (_RAM_DF0F_), a
+:
  ld a, $02
  ld (_RAM_DF03_Jump_Active), a
  ; fall through
  
LABEL_22A9_:
  ld a, (_RAM_DF04_CarX_)
  ld (_RAM_DF06_), a
  ld a, (_RAM_DF05_CarY_)
  ld (_RAM_DF07_), a
  ld a, 1
  ld (_RAM_DF00_JumpCurvePosition), a
  ld hl, (_RAM_D95B_EngineSound1.Tone)
  ld (_RAM_D58C_EngineToneBackup), hl
  ld a, (_RAM_DB97_TrackType)
  ; No "hit ground" sound effect for boats
  cp TT_2_Powerboats
  JrZRet _LABEL_22CC_ret ; ret
  ld a, SFX_02_HitGround
  ld (_RAM_D963_SFX_Player1.Trigger), a
_LABEL_22CC_ret:
  ret

LABEL_22CD_ProcessCarJump:
  ld d, $00
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JpZRet _LABEL_23C2_ret
  ; Look up sin((_RAM_DF00_JumpCurvePosition-1)*180/129)*128, i.e. a sin hump from 0..127 on Y for 1..130 on X
  ld hl, DATA_1B232_JumpCurveTable ; $B232
  ld e, a
  add hl, de
  ld a, :DATA_1B232_JumpCurveTable ; $06
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
  ; Multiply the result by _RAM_DF0A_JumpCurveMultiplier
  ld (_RAM_DEF5_Multiply_Parameter1), a
  ld a, (_RAM_DF0A_JumpCurveMultiplier)
  ld (_RAM_DEF4_Multiply_Parameter2), a
  call LABEL_1B94_Multiply
  ; Add the high byte to the car X and Y
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
  add a, l
  add a, $04
  ld (_RAM_DE5E_), a
  ld a, (_RAM_DBA5_CarY)
  add a, l
  add a, $04
  ld (_RAM_DE62_), a
  ld a, $01
  ld (_RAM_DE66_), a
  ; Repeat with _RAM_DF0A_JumpCurveMultiplier >> 2
  ld a, b
  ld (_RAM_DEF5_Multiply_Parameter1), a
  ld a, (_RAM_DF0A_JumpCurveMultiplier)
  and $FC
  rr a
  rr a
  ld (_RAM_DEF4_Multiply_Parameter2), a
  call LABEL_1B94_Multiply
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
  sub l
  ld (_RAM_DF06_), a
  ld a, (_RAM_DBA5_CarY)
  sub l
  ld (_RAM_DF07_), a
  ld a, (_RAM_DF02_JumpCurveStep)
  ld l, a
  ld a, (_RAM_DF00_JumpCurvePosition)
  add a, l
  ld (_RAM_DF00_JumpCurvePosition), a
  cp JUMP_MAX_CURVE_INDEX
  JpCRet _LABEL_23C2_ret
  ; Position is above JUMP_MAX_CURVE_INDEX
  ; Restore engine tone
  ld hl, (_RAM_D58C_EngineToneBackup)
  ld (_RAM_D95B_EngineSound1.Tone), hl
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, SFX_11_Powerboats_HitWater
  jp ++
+:ld a, SFX_02_HitGround
++:
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ; End jump
  xor a
  ld (_RAM_DF00_JumpCurvePosition), a
  ld (_RAM_DE66_), a
  ld (_RAM_DE8C_InPoolTableHole), a
  
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  xor a
  ld (_RAM_D5C5_), a
+:
  ld a, (_RAM_DF0A_JumpCurveMultiplier)
  cp $1E
  jr c, +
  cp $60
  jr c, LABEL_23C3_
  jp LABEL_23D0_

+:
  ld a, (_RAM_DF03_Jump_Active)
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
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DE96_Speed), a
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
  ld (_RAM_DF0A_JumpCurveMultiplier), a
  ld a, $0C
  ld (_RAM_DF02_JumpCurveStep), a
  jp LABEL_22A9_

LABEL_23D0_:
  ld a, $20
  ld (_RAM_DF0A_JumpCurveMultiplier), a
  ld a, $08
  ld (_RAM_DF02_JumpCurveStep), a
  jp LABEL_22A9_

; Seems only oto be called while resetting the camera after a car explosion
; Seems only to affect the car direction when it respawns - but it gets called on every frame while resetting
; The data looks a bit like AI data - a direction to go for each 16x16 square - but isn't used like that?
LABEL_23DD_:
  ; Get the extra layout bits
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_EXTRA_MASK ; High bits
  ld (_RAM_DE54_CurrentLayoutData_ExtraBits_), a ; (Only used locally)
  ; Read nibble from hl (behaviour data low nibble)
  ld a, (hl)
  and $0F
  ld e, a
  ld d, 0
  ; Examine extra bits
  ld a, (_RAM_DE54_CurrentLayoutData_ExtraBits_)
.ifdef UNNECESSARY_CODE
  ; the following check for bit 7 will catch zeroes too
  or a
  jr z, +
.endif
  and $80
  jr z, +
  ; High bit is set, so we lookup the value from _RAM_D900_UnknownData
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld c, a
  ld hl, _RAM_D900_UnknownData
  ld b, 0
  add hl, bc
  ld a, (hl)
  ; Then use bits 5-6 to select the data from DATA_1DA7_Special_
  and %01100000; $60
  sra a
  ld c, a
  ld b, 0
  ld hl, DATA_1DA7_Special_
  add hl, bc
  jp ++
+:; We use this table when the high bit in _RAM_DE54_CurrentLayoutData_ExtraBits_ is zero
  ld hl, DATA_1D87_Default_
++:
  ; Then index in there using the nibble we read at the start
  add hl, de
  ld a, (hl)
  ; And save here
  ld (_RAM_DE55_CPUCarDirection), a
  
  ; Next, check bit 6
  ld a, (_RAM_DE54_CurrentLayoutData_ExtraBits_)
  and $40
  JrZRet +
  ; If 1, we select the opposite direction
  ; Could do:
  ; ld a, (_RAM_DE55_CPUCarDirection)
  ; add $10
  ; and $0f
  ; ld (_RAM_DE55_CPUCarDirection), a
  ld hl, DATA_1D97_OppositeDirections
  ld d, 0
  ld a, (_RAM_DE55_CPUCarDirection)
  ld e, a
  add hl, de
  ld a, (hl)
  ld (_RAM_DE55_CPUCarDirection), a
+:ret

; Behaviour lookup per track type
; This maps each track's 16 "object types" to some of the ~19 behaviours - although none use all the slots and ghere is special handling elsewhere because the bevaviours are not necessarily constant across each object (!).
DATA_242E_BehaviourLookup:
; TT_0_SportsCars
; Avoids odd indexes
.db Behaviour0_Normal   ; 0 = most tiles
.db Behaviour0_Normal   ; 
.db Behaviour1_Fall     ; 2 = floor
.db Behaviour0_Normal   ; 
.db Behaviour2_Dust     ; 4 = chalk lines
.db Behaviour0_Normal   ; 
.db Behaviour3_BumpDown ; 6 = blue book edges (outer), red binder edges (outer)
.db Behaviour0_Normal   ; 
.db Behaviour4_Jump     ; 8 = red binder edge (jump)
.db Behaviour0_Normal   ; 
.db Behaviour5_Skid     ; a = ink
.db Behaviour0_Normal   ; 
.db Behaviour6_Bump     ; c = blue book edges (touching desk), ruler, grey binder corners and centre
.db Behaviour0_Normal   ; 
.db Behaviour7_Entry    ; e = blue book edges (inner), red binder edges (inner)
.db Behaviour0_Normal   ; 
; TT_1_FourByFour
.db Behaviour0_Normal      ; 0 = table
.db Behaviour6_Bump        ; 1 = cereal
.db Behaviour5_Skid        ; 2 = milk
.db Behaviour8_Sticky      ; 3 = orange juice
.db Behaviour1_Fall        ; 4 = floor
.db BehaviourC_RaisedEntry ; 5 = ramp bottom (1/5)
.db BehaviourD_BumpOnEntry ; 6 = placemat, ramp (2/5)
.db BehaviourB_Raised      ; 7 = ramp (3/5)
.db BehaviourB_Raised      ; 8 = ramp (4/5)
.db BehaviourB_Raised      ; 9 = cereal box
.db BehaviourD_BumpOnEntry ; a = top of ramp (5/5)
.db BehaviourB_Raised      ; 
.db BehaviourB_Raised      ; 
.db Behaviour0_Normal      ; 
.db Behaviour0_Normal      ; 
.db Behaviour0_Normal      ; 
; TT_2_Powerboats
; Odd entries are not usable due to masking for powerboats, most are unused anyway
.db Behaviour0_Normal ; 0 = Most tiles
.db Behaviour0_Normal ; Unusable
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; Unusable
.db Behaviour6_Bump   ; 4 = small bubbles
.db Behaviour0_Normal ; Unusable
.db Behaviour6_Bump   ; 6 = larger bubbles, bottle in water
.db Behaviour0_Normal ; Unusable
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; Unusable
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; Unusable
.db Behaviour6_Bump   ; c = soap
.db Behaviour0_Normal ; Unusable
.db Behaviour0_Normal ;
.db Behaviour0_Normal ; Unusable
; TT_3_TurboWheels
.db Behaviour0_Normal ; 0 = sometimes next to water, scenery, ramps
.db Behaviour2_Dust   ; 1 = most tiles 
.db Behaviour5_Skid   ; 2 = water edge
.db Behaviour12_Water ; 3 = water
.db Behaviour6_Bump   ; 4 = sand dunes, inside stones
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour6_Bump   ; 
.db Behaviour6_Bump   ; d = footprint, start line
.db Behaviour6_Bump   ; 
.db Behaviour0_Normal ; 
; TT_4_FormulaOne
.db Behaviour0_Normal           ; 0 = most tiles
.db BehaviourB_Raised           ; 1 = table raised edge
.db Behaviour2_Dust             ; 2 = chalk
.db Behaviour0_Normal           ; 
.db Behaviour0_Normal           ; 
.db Behaviour1_Fall             ; 5 = floor
.db Behaviour13_Barrier         ; 6 = cue
.db Behaviour0_Normal           ; 
.db Behaviour9_PoolTableHole    ; 8 = hole
.db Behaviour9_PoolTableHole    ; 9 = hole (sometimes, inaccessible tiles?)
.db BehaviourC_RaisedEntry      ; a = card lower end
.db BehaviourB_Raised           ; b = rest of card
.db Behaviour9_PoolTableHole    ; 
.db Behaviour0_Normal           ; 
.db BehaviourA_PoolTableCushion ; e = cushion
.db BehaviourB_Raised           ; 
; TT_5_Warriors
.db Behaviour0_Normal ; 0 = Most tiles
.db Behaviour0_Normal ; 
.db Behaviour2_Dust   ; 2 = Chalk
.db Behaviour0_Normal ; 
.db Behaviour6_Bump   ; 4 = nails
.db Behaviour0_Normal ; 
.db Behaviour5_Skid   ; 6 = oil
.db Behaviour0_Normal ; 
.db Behaviour8_Sticky ; 8 = glue, also one bolt by accident?
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
; TT_6_Tanks
.db Behaviour0_Normal ; 0 = most tiles
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour0_Normal ; 
.db Behaviour6_Bump   ; e = pencils, lego
.db Behaviour5_Skid   ; f = cards
; TT_7_RuffTrux
.db Behaviour0_Normal        ; 0 = most tiles
.db Behaviour0_Normal        ; 
.db Behaviour6_Bump          ; 2 = bumps
.db Behaviour3_BumpDown      ; 3 = raised area outside edges (unused)
.db Behaviour6_Bump          ; 4 = raised area inside edges (unused)
.db Behaviour0_Normal        ; 
.db Behaviour5_Skid          ; 6 = shallow water
.db BehaviourE_RuffTruxWater ; 7 = deep water
.db Behaviour0_Normal        ; 
.db Behaviour0_Normal        ; 
.db Behaviour0_Normal        ; 
.db Behaviour0_Normal        ; 
.db Behaviour0_Normal        ; 
.db Behaviour0_Normal        ; 
.db Behaviour0_Normal        ; 
.db Behaviour0_Normal        ; 

DATA_24AE_JumpCurveMultiplierForSpeed: ; Indexed by _RAM_DE94_BumpSpeed, copied to _RAM_DF0A_JumpCurveMultiplier
; Maps speed to bump height?
.db $00 $00 $00 $00 $00 $0C $10 $14 $18 $1C $20 $20 $20 $20 $20 $20

DATA_24BE_JumpCurveStepForSpeed: ; Indexed by _RAM_DE94_BumpSpeed, copied to _RAM_DF02_JumpCurveStep
.db JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, 10, 10, 9, 9, 8, 8, 8, 8, 8, 8, 8

DATA_24CE_SMS_: ; Indexed by _RAM_DE94_BumpSpeed, copied to _RAM_DF0A_JumpCurveMultiplier (same as above!)
.db $00 $00 $00 $00 $00 $00 $28 $28 $38 $38 $58 $78 $78 $78 $78 $78

; Data from 24DE to 24ED (16 bytes)
DATA_24DE_SMS_: ; Indexed by _RAM_DE94_BumpSpeed, copied to _RAM_DF02_JumpCurveStep (same as above!)
.db JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, 6, 6, 5, 5, 4, 3, 3, 3, 3, 3

; Data from 24EE to 24FD (16 bytes)
DATA_24EE_GG_: ; Indexed by _RAM_DE94_BumpSpeed, copied to _RAM_DF0A_JumpCurveMultiplier (same as above!)
.db $00 $00 $00 $00 $00 $28 $28 $38 $38 $58 $78 $88 $88 $88 $88 $88

; Data from 24FE to 250D (16 bytes)
DATA_24FE_GG_: ; Indexed by _RAM_DE94_BumpSpeed, copied to _RAM_DF02_JumpCurveStep (same as above!)
.db JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, JUMP_MAX_CURVE_INDEX, 6, 6, 5, 5, 4, 3, 3, 3, 3, 3, 3

; For each car direction, the opposite
DATA_250E_OppositeDirections: ; indexed by _RAM_DE90_CarDirection
; Same as (index + $10) and $f
.db $08 $09 $0A $0B $0C $0D $0E $0F $00 $01 $02 $03 $04 $05 $06 $07

; Data from 251E to 254D (48 bytes)
DATA_251E_DivMod12:
; Converts from tile to metatile coordinates
; For a given tile index (8px based), the high nibble is a metatile index (x/12)
; and the low nibble is the index within that metatile (x%12)
.macro DivMod args value, divisor
  .db (value/divisor)<<4|(value#divisor)
.endm

.repeat 48 index _x
  DivMod _x, 12
.endr

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
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_HScrollDelta)
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_HScrollDelta), a
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
  ld a, (_RAM_DF00_JumpCurvePosition)
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
  ld hl, DATA_3FC3_HorizontalAmountByDirection
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
  ld hl, DATA_40E5_Sign_Directions_X
  ld a, (_RAM_DF11_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
  jr z, +
  xor a
  ld (_RAM_DF0D_), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF0D_), a
++:
  ld hl, DATA_3FD3_VerticalAmountByDirection
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
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (_RAM_DF11_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
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
  ld hl, _RAM_DEAF_HScrollDelta
  ld a, (_RAM_DBA6_CarX_Next)
  sub (hl)
  ld (_RAM_DBA6_CarX_Next), a
  jp ++

+:
  ld hl, _RAM_DEAF_HScrollDelta
  ld a, (_RAM_DBA6_CarX_Next)
  add a, (hl)
  ld (_RAM_DBA6_CarX_Next), a
++:
  ld a, (_RAM_DEB2_)
  cp $01
  jr z, +
  ld hl, _RAM_DEB1_VScrollDelta
  ld a, (_RAM_DBA7_CarY_Next)
  sub (hl)
  ld (_RAM_DBA7_CarY_Next), a
  jp LABEL_27FB_

+:
  ld hl, _RAM_DEB1_VScrollDelta
  ld a, (_RAM_DBA7_CarY_Next)
  add a, (hl)
  ld (_RAM_DBA7_CarY_Next), a
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
  ld a, (_RAM_DEAF_HScrollDelta)
  add a, l
  ld l, a
  and $01
  jr z, +
  ld a, $01
  ld (_RAM_DB80_), a
-:
  ld a, l
  srl a
  ld (_RAM_DEAF_HScrollDelta), a
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
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

LABEL_28AC_BounceOffBarrier:
  ; Special case for Four by Four, in reverse
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, +
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ; Act as if the car was moving forwards in the opposite direction, at 
  ld a, (_RAM_DE90_CarDirection)
  ld l, a
  ld h, 0
  ld de, DATA_250E_OppositeDirections
  add hl, de
  ld a, (hl)
  ld c, a
  jr _LABEL_28D6_SetToMinimumSpeed

+:; Use the real car direction
  ld a, (_RAM_DE90_CarDirection)
  ld c, a
  
  ; 
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr z, _Powerboats
  cp TT_7_RuffTrux
  jr nz, ++
_RuffTrux:  
  
_LABEL_28D6_SetToMinimumSpeed:
  ld a, CRASH_BOUNCE_MINIMUM_SPEED
  jp +++

_Powerboats:
  ; ALways bounce off at minimum speed, change direction if ???
  ld a, (_RAM_DF7B_Powerboats_BubblePush_Strength)
  or a
  jr z, _LABEL_28D6_SetToMinimumSpeed
  ld a, (_RAM_DF7A_Powerboats_BubblePush_Direction)
  ld c, a
  jr _LABEL_28D6_SetToMinimumSpeed

++:
  ; Not RuffTrux or Powerboats
  ld a, (_RAM_DE96_Speed)
  cp CRASH_BOUNCE_MINIMUM_SPEED
  jr nc, +
  ; Speed below CRASH_BOUNCE_MINIMUM_SPEED -> stop
  xor a
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DEB5_), a
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE90_CarDirection), a
  ret

+:ld a, (_RAM_DE96_Speed) ; Unnecessary?
+++:
  ; Divide by 2
  and $FE
  rr a
  ld (_RAM_DF0F_), a ; half speed to here
  ; Divide by 2 again -> that's the engine velocity (crash speed / 4)
  and $FE
  rr a
  ld (_RAM_DE92_EngineSpeed), a
  ; Then look up the opposite direction to the crash
  ld d, 0
  ld a, c
  ld e, a
  ld hl, DATA_250E_OppositeDirections
  add hl, de
  ld a, (hl)
  ld (_RAM_DF11_), a ; Store to here..?
  ; Lots of unknown stuff
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

LABEL_2934_BehaviourF_Explode: ; Invoked from a bunch of places
  ; Not if in the air
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet +
  
  ; Not if resetting
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet +
  
  ; Play SFX
  ld a, SFX_05
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ; Set car state
  ld a, CarState_1_Exploding
  ld (_RAM_DF59_CarState), a
  ld (_RAM_DF58_ResettingCarToTrack), a
  xor a
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DF00_JumpCurvePosition), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  jp LABEL_71C7_

+:ret

LABEL_2961_:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  JrNzRet +
  ld a, (ix+CarData.Unknown46_b_ResettingCarToTrack)
  or a
  JrNzRet +
  ld a, $01
  ld (ix+CarData.Unknown46_b_ResettingCarToTrack), a
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ; Add 8 to Unknown39_w and store 0 at the pointed result
  ld a, (ix+CarData.Unknown39_w.Lo)
  ld l, a
  ld a, (ix+CarData.Unknown39_w.Hi)
  ld h, a
  ld de, $0008
  add hl, de
  xor a
  ld (hl), a
  ld a, (ix+CarData.TankShotSpriteIndex)
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

LABEL_29A3_EnterPoolTableHole:
  ; Not while jumping
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr z, +
  cp $80
  JrCRet ++
+:
  ; Or while resetting
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet ++
  
  ld a, SFX_09_EnterPoolTableHole
  ld (_RAM_D963_SFX_Player1.Trigger), a
  jp LABEL_29BC_Behaviour1_Fall

++:ret

LABEL_29BC_Behaviour1_Fall: ; Invoked from a bunch of places
  ; Not while ???
  ld a, (_RAM_D5B0_)
  or a
  JrNzRet _LABEL_2A36_ret
  ; Or while jumping
  ld a, (_RAM_DF00_JumpCurvePosition) ; >0 and <$80
  or a
  jr z, +
  cp $80
  JrCRet _LABEL_2A36_ret
+:; Or while resetting
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet _LABEL_2A36_ret
  
  ld a, (_RAM_D5BD_)
  or a
  jr nz, +
  ; Play sound effect
  ld a, SFX_0E_FallToFloor
  ld (_RAM_D963_SFX_Player1.Trigger), a
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ; Two player
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
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
  ld hl, LOWEST_PITCH_ENGINE_TONE
  ld (_RAM_D95B_EngineSound1.Tone), hl
  xor a
  ld (_RAM_D95B_EngineSound1.Volume), a
LABEL_2A08_:
  ld a, $01
  ld (_RAM_DF58_ResettingCarToTrack), a
  ; Zero car state
  xor a
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DF00_JumpCurvePosition), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DF7B_Powerboats_BubblePush_Strength), a
  ld (_RAM_D5B9_), a
  ld (_RAM_DCEC_CarData_Blue.Unknown28_b), a
  ld (_RAM_DF79_CurrentBehaviourByte), a
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
  ld (_RAM_DEAF_HScrollDelta), a
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
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DEAF_HScrollDelta), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, $02
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld a, $01
  ld (_RAM_DF81_), a
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
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
  ld (_RAM_DBAD_X_), hl
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
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
  ld (_RAM_DBAF_Y_), hl
  ret

_LABEL_2AA0_Behaviour13_Barrier:
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $16 ; Cue butt
  jp z, _LABEL_2200_HitBarrier
  cp $2A ; Cue tip
  jp z, _LABEL_2200_HitBarrier
  cp $3F ; Card ramp top - has no Behaviour13 tiles
  jp z, _LABEL_2200_HitBarrier
  ret

_LABEL_2AB5_Behaviour9_PoolTableHole:
  ; Do nothing if in the air (bumping over a hole)
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
.ifdef JUMP_TO_RET
  jr z, +
  ret
.else
  ret nz
.endif

+:; If we are in the hole, we are done
  ld a, (_RAM_DE8C_InPoolTableHole)
  cp 1
  JpZRet _LABEL_2C28_ret

  ; Else look up the track index
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jp z, _Track0
  cp 1
  jp z, _Track1
  
_Track2:
  ld a, (_RAM_DC52_PreviousDifferentBehaviourByte)
  and %00010000
  jp nz, LABEL_29A3_EnterPoolTableHole
  ld a, (_RAM_DF55_)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $3A ; Middle-right hole
  jp nz, LABEL_29A3_EnterPoolTableHole
  jp +++

+:
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $3A
  jp nz, LABEL_29A3_EnterPoolTableHole
  jp ++++

++:
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $1D
  jr z, +++++
  cp $1E
  jp nz, LABEL_29A3_EnterPoolTableHole
  jp +++++

+++:
  xor a
  ld (_RAM_DF55_), a
  ld hl, $0B38
  ld (_RAM_DBAD_X_), hl
  ld hl, $0B50
  ld (_RAM_DBAF_Y_), hl
  ld a, $0E
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

++++:
  ld a, $02
  ld (_RAM_DF55_), a
  ld hl, $07F0
  ld (_RAM_DBAD_X_), hl
  ld hl, $0620
  ld (_RAM_DBAF_Y_), hl
  ld a, $04
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

+++++:
  ld a, $01
  ld (_RAM_DF55_), a
  ld hl, $06B8
  ld (_RAM_DBAD_X_), hl
  ld hl, $0148
  ld (_RAM_DBAF_Y_), hl
  ld a, $0A
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

_Track1:
  ld a, (_RAM_DC52_PreviousDifferentBehaviourByte)
  and %00010000
  jp nz, LABEL_29A3_EnterPoolTableHole
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $39
  jp nz, LABEL_29A3_EnterPoolTableHole
  ld hl, $0100
  ld (_RAM_DBAD_X_), hl
  ld hl, $00E0
  ld (_RAM_DBAF_Y_), hl
  ld a, $06
  ld (_RAM_DE8D_), a
  jp LABEL_2BA4_

_Track0:
  ld a, (_RAM_DC52_PreviousDifferentBehaviourByte)
  and %00010000
  jp nz, LABEL_29A3_EnterPoolTableHole
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $34
  jr z, +
  cp $35
  jp nz, LABEL_29A3_EnterPoolTableHole
+:
  ld hl, $0618
  ld (_RAM_DBAD_X_), hl
  ld hl, $0500
  ld (_RAM_DBAF_Y_), hl
  ld a, $0C
  ld (_RAM_DE8D_), a
LABEL_2BA4_:
  ; Not while resetting
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet _LABEL_2C28_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
  ld (_RAM_D5C6_), a
  or a
  jr nz, +
  ld hl, $0110
  ld (_RAM_DF56_), hl
+:
  xor a
  ld (_RAM_D95B_EngineSound1.Volume), a
  ld a, SFX_09_EnterPoolTableHole
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld a, CarState_3_Falling
  ld (_RAM_DF59_CarState), a
  ld a, $01
  ld (_RAM_DF58_ResettingCarToTrack), a
  xor a
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DF00_JumpCurvePosition), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ld (_RAM_DE2F_), a
  ld a, $01
  ld (_RAM_DE8C_InPoolTableHole), a
  ld hl, (_RAM_DBAD_X_)
  ld (_RAM_DEF1_Multiply_Result), hl
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0070
  jp ++

+:
  ld de, $004C
++:
  ld hl, (_RAM_DEF1_Multiply_Result)
  or a
  sbc hl, de
  ld (_RAM_DBAD_X_), hl
  ld hl, (_RAM_DBAF_Y_)
  ld (_RAM_DEF1_Multiply_Result), hl
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0060
  jp ++

+:
  ld de, $0038
++:
  ld hl, (_RAM_DEF1_Multiply_Result)
  or a
  sbc hl, de
  ld (_RAM_DBAF_Y_), hl
_LABEL_2C28_ret:
  ret

_LABEL_2C29_Behaviour8_Sticky:
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr z, @FourByFour
  ld a, (_RAM_DE92_EngineSpeed)
  or a
  JrZRet +++ ; 0 -> do nothing
  cp $01
  JrZRet +++ ; 1 -> do nothing
  cp $02
  jr z, +   ; 2 -> subtract 1
  sub $02   ; Otherwise, subtract 2
  jp ++

+:
  DEC_A
++:
  ld (_RAM_DE92_EngineSpeed), a
  ld a, SFX_07_EnterSticky
  ld (_RAM_D963_SFX_Player1.Trigger), a
+++:ret

++++:
@FourByFour:
  ld a, (_RAM_DE92_EngineSpeed)
  cp $03
  JrCRet +++ ; 3 -> do nothing
  cp $04
  jr z, +   ; 4 -> subtract 1
  sub $02   ; Otherwise, subtract 2
  jp ++

+:
  DEC_A
++:
  ld (_RAM_DE92_EngineSpeed), a
  ld a, SFX_07_EnterSticky
  ld (_RAM_D963_SFX_Player1.Trigger), a
+++:ret

_LABEL_2C69_Behaviour12_Water:
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet _LABEL_2CD0_ret
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet _LABEL_2CD0_ret
  ld a, SFX_08
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld hl, LOWEST_PITCH_ENGINE_TONE
  ld (_RAM_D95B_EngineSound1.Tone), hl
  xor a
  ld (_RAM_D95B_EngineSound1.Volume), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  ld (_RAM_D5BF_), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  xor a
  ld (_RAM_DF73_), a
  jp LABEL_29BC_Behaviour1_Fall

+:
  ld a, CarState_4_Submerged
  ld (_RAM_DF59_CarState), a
  ld a, $01
  ld (_RAM_DF58_ResettingCarToTrack), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld a, $01
  ld (_RAM_DE92_EngineSpeed), a
  xor a
  ld (_RAM_DF73_), a
  ld (_RAM_DF00_JumpCurvePosition), a
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
  INC_A
  and $03
  ld (_RAM_DF6B_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF73_)
  INC_A
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

LABEL_2D63_UpdateRaceProgressAndTopSpeeds:
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  ld e, a
  ld d, $00
  
.macro ComputeTotalProgress args LapsRemaining, CurrentLapProgress, RaceProgress
  ld a, (LapsRemaining)
  cp $04
  jr z, ++ ; Race didn't start yet
  
  ; Compute hl = ProgressTilesPerLap * (3 - LapsRemaining)
  ; i.e. the progress from previous laps
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
+:; Add the progress from this lap
  ld b, $00
  ld a, (CurrentLapProgress)
  ld c, a
  add hl, bc
  ; And save it
  ld (RaceProgress), hl
++:
.endm

  ComputeTotalProgress _RAM_DF24_LapsRemaining, _RAM_DF4F_LastTrackPositionIndex, _RAM_DF8D_RedCarRaceProgress
  ComputeTotalProgress _RAM_DCAB_CarData_Green.LapsRemaining, _RAM_DF50_GreenCarCurrentLapProgress, _RAM_DF8F_GreenCarRaceProgress
  ComputeTotalProgress _RAM_DCEC_CarData_Blue.LapsRemaining, _RAM_DF51_BlueCarCurrentLapProgress, _RAM_DF91_BlueCarRaceProgress
  ComputeTotalProgress _RAM_DD2D_CarData_Yellow.LapsRemaining, _RAM_DF52_YellowCarCurrentLapProgress, _RAM_DF93_YellowCarRaceProgress

  ; Increment a counter so we move on only every $80 frames = 2.56s
  ld a, (_RAM_DF95_OpponentTopSpeedEvaluationDelayCounter)
  INC_A
  and $7F
  ld (_RAM_DF95_OpponentTopSpeedEvaluationDelayCounter), a
  jr z, +
  ret

+:; Then apply a second level counter set to roll at 3,
  ; and we process a different car each time...
  ; (This means each car's to pspeed is reevaluated every 7.68s.)
  ld a, (_RAM_DF96_OpponentTopSpeedEvaluationSelector)
  INC_A
  ld (_RAM_DF96_OpponentTopSpeedEvaluationSelector), a
  cp $03
  jr nz, +
  xor a
  ld (_RAM_DF96_OpponentTopSpeedEvaluationSelector), a
+:or a
  jr z, @Green
  cp 1
  jr z, @Blue
  jp @Yellow

    ; We have three almost identical bits of code, so here's a macro
  .macro EvaluateTopSpeedForOpponent args Progress, CarData, TopSpeeds, Optimised
  ; Cheat: always lowest speed
  ld a, (_RAM_DC4F_Cheat_EasierOpponents)
  or a
  jr nz, @@LowestSpeed
  
  ; Compare progress
  ld hl, (_RAM_DF8D_RedCarRaceProgress)
  ld de, (Progress)
  or a
  sbc hl, de
  jr nc, @@Behind
  ; In front, so negate the value
  ld a, h
  xor $FF
.if Optimised == 0
  or a ; <- Unnecessary and optimised out in one of the three copies (!)
.endif
  jr nz, +
  ld a, l
  xor $FF
  INC_A
  ld l, a
  ; Compare to the threshold
  ld a, (_RAM_DB67_MetatilesAheadSlowDownThreshold)
  cp l
  jr z, @@LowSpeed
  jr c, +
  ; fall through for value < threshold
  ; (Could skip the jr z?)
  
@@LowSpeed:
  ld a, (TopSpeeds + SpeedLevels.Low)
  ld (CarData + CarData.TopSpeed), a
  ret
  
+:; Don't use lowest speed if player has already finished
  ; (We are ahed of him anyway - so why does this matter?)
  ld a, (_RAM_DF24_LapsRemaining)
  cp $01
  jr c, @@LowSpeed

@@LowestSpeed:
  ld a, (TopSpeeds + SpeedLevels.Lowest)
  ld (CarData + CarData.TopSpeed), a
  ret

@@Behind:
  ; Compare to the threshold
  ld a, h
  or a
  jr nz, @@HighestSpeed ; >=256 is definitely more than the threshold
  ld a, (_RAM_DB66_MetatilesBehindSpeedUpThreshold)
  cp l
  jr z, @@HighSpeed
  jr c, @@HighestSpeed
@@HighSpeed:
  ld a, (TopSpeeds + SpeedLevels.High)
  ld (CarData + CarData.TopSpeed), a
  ret

@@HighestSpeed:
  ld a, (TopSpeeds + SpeedLevels.Highest)
  ld (CarData + CarData.TopSpeed), a
  ret
  .endm

@Green:
  EvaluateTopSpeedForOpponent _RAM_DF8F_GreenCarRaceProgress, _RAM_DCAB_CarData_Green, _RAM_DB68_OpponentTopSpeeds.Green, 0

@Blue:
  ; In head to head mode, always use the player's top speed
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB98_TopSpeed)
  ld (_RAM_DCEC_CarData_Blue.TopSpeed), a
  ret
+:; Else, same as above
  EvaluateTopSpeedForOpponent _RAM_DF91_BlueCarRaceProgress, _RAM_DCEC_CarData_Blue, _RAM_DB68_OpponentTopSpeeds.Blue, 0

@Yellow:
  EvaluateTopSpeedForOpponent _RAM_DF93_YellowCarRaceProgress, _RAM_DD2D_CarData_Yellow, _RAM_DB68_OpponentTopSpeeds.Yellow, 1

DATA_2F27_MultiplesOf32:
  TimesTable16 0 32 32

DATA_2F67_MultiplesOf96:
  TimesTable16 0 96 32

DATA_2FA7_XOffsets_:
.db $20 $40 $00 $00 $40 $00 $40 $20

DATA_2FAF_YOffsets_:
.db $20 $00 $40 $20 $40 $00 $20 $00

DATA_2FB7_RuffTruxSubmergedPaletteSequence_SMS:
  SMSCOLOUR $000000 ; black
  SMSCOLOUR $0000aa ; dark blue
  SMSCOLOUR $0055aa ; middle blue
  SMSCOLOUR $00aaff ; light blue
  SMSCOLOUR $000000 ; black

; Data from 2FBC to 2FDB (32 bytes)
; One byte per track, arranged by type/type index
; Copied to _RAM_DF68_ProgressTilesPerLap
; Holds the number of "progress" metatiles in a complete lap
DATA_2FBC_ProgressTilesPerLapPerTrack:
.db $52 $A6 $B6 $9E ; SportsCars 
.db $62 $24 $85 $00 ; FourByFour 
.db $1C $51 $5E $4E ; Powerboats 
.db $57 $50 $70 $00 ; TurboWheels
.db $85 $8F $9B $00 ; FormulaOne 
.db $42 $72 $6A $00 ; Warriors   
.db $2C $40 $53 $00 ; Tanks      
.db $38 $3E $4B $00 ; RuffTrux   
                    ; No Choppers

LABEL_2FDC_Falling:
  ld a, (_RAM_D5C1_)
  or a
  jr nz, LABEL_3028_
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
  INC_A
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  cp 1
  jr z, +
  cp $0A
  jr nz, LABEL_2FF6_
  xor a
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
LABEL_2FF6_:
  jp LABEL_304B_

+:
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  or a
  jp z, LABEL_3085_FallingCarStep1
  cp $01
  jp z, LABEL_3057_FallingCarStep2
  cp $02
  jp z, _FallingCarStep3
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  INC_A
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
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
  ld (_RAM_D963_SFX_Player1.Trigger), a
+:
  xor a
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  ret

_FallingCarStep3:
  ld a, $03
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  ; Hide the remaining sprite
  xor a
  ld (ix+0), a
  ld (iy+1), a
  ret

LABEL_304B_:
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  cp $01
  jr z, ++
  cp $02
  jr z, +
  ret

LABEL_3057_FallingCarStep2:
  ld a, $02
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
+:
  ; Disable the last three car sprites and use the first one for the smallest falling car
  xor a
  ld (ix+2), a ; Set X, Y to 0 for sprites +1, +2, +3
  ld (ix+4), a
  ld (ix+6), a
  ld (iy+1), a
  ld (iy+2), a
  ld (iy+3), a
  ; Remaining sprite is at +8, +8
  ld a, (_RAM_DE84_X)
  add a, $08
  ld (ix+0), a
  ld a, (_RAM_DE85_Y)
  add a, $08
  ld (iy+0), a
  ld a, <SpriteIndex_FallingCar2
  ld (ix+1), a
  ret

LABEL_3085_FallingCarStep1:
  ld a, $01
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
++:
  ; Hide decorator and all but the first four car sprites
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
  ; Remaining sprites are offset by +4, +4 (centred on original 12x12 square)
  ld a, (_RAM_DE84_X)
  add a, 4
  ld (ix+0), a
  ld (ix+4), a
  add a, 8
  ld (ix+2), a
  ld (ix+6), a
  ld a, (_RAM_DE85_Y)
  add a, 4
  ld (iy+0), a
  ld (iy+1), a
  add a, 8
  ld (iy+2), a
  ld (iy+3), a
  ld a, <SpriteIndex_FallingCar + 0
  ld (ix+1), a
  ld a, <SpriteIndex_FallingCar + 1
  ld (ix+3), a
  ld a, <SpriteIndex_FallingCar + 2
  ld (ix+5), a
  ld a, <SpriteIndex_FallingCar + 3
  ld (ix+7), a
  ret

LABEL_30EA_MultiplyBy32:
  ; Takes _RAM_DEF5_Multiply_Parameter1 as input
  ; Multiplies it by 32
  ; Result goes to _RAM_DEF1_Multiply_Result
  ld a, (_RAM_DEF5_Multiply_Parameter1)
  sla a
  ld l, a
  ld h, 0
  ld de, DATA_2F27_MultiplesOf32
  add hl, de
  ld a, (hl)
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  inc hl
  ld a, (hl)
  ld (_RAM_DEF1_Multiply_Result.Hi), a
  ret

LABEL_3100_MultiplyBy96:
  ; Takes _RAM_DEF5_Multiply_Parameter1 as input
  ; Multiplies it by 96
  ; Result goes to _RAM_DEF1_Multiply_Result
  ld a, (_RAM_DEF5_Multiply_Parameter1)
  sla a
  ld l, a
  ld h, 0
  ld de, DATA_2F67_MultiplesOf96
  add hl, de
  ld a, (hl)
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  inc hl
  ld a, (hl)
  ld (_RAM_DEF1_Multiply_Result.Hi), a
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

.ends

.section "Trampolines 7" force
LABEL_3164_:
  ld a, (_RAM_D582_)
  cp $01
  JrNzRet + ; ret
  ld a, $02
  ld (_RAM_D582_), a
  JumpToPagedFunction PagedFunction_3682E_

+:ret

LABEL_317C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet + ; ret
  JumpToPagedFunction PagedFunction_36971_

+:ret

LABEL_318E_InitialiseVDPRegisters_Trampoline:
  JumpToPagedFunction PagedFunction_1BE82_InitialiseVDPRegisters

LABEL_3199_:
  JumpToPagedFunction PagedFunction_37529_
.ends

.section "Floor tiles initialisation" force
; Data from 31A4 to 31B5 (18 bytes)
_FloorTilesVRAMAddresses:
; VRAM address of the four floor tiles per track type. $ffff if no floor.
  TileWriteAddressData $58 ; $4B00
  TileWriteAddressData $a1 ; $5420
.dw $FFFF
.dw $FFFF
  TileWriteAddressData $13 ; $4260
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
  ld hl, _FloorTilesVRAMAddresses ; Look up per-track-type data from this table
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
  ld bc, 4 * 8 * 4 ; $0080 ; 32*4 bytes = 4 tiles @ 4bpp
-:
  EmitDataToVDPImmediate8 0 ; Blank it out
  dec bc
  ld a, b
  or c
  jr nz, -
+:ret
.ends

.section "Sprite table to VRAM" force
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
.ends

.section "Car decorator tiles" force
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
.ends

.section "Per frame tile writes" force
.macro UpdateTileBitplane args TileIndex, Bitplane
  ; Emits 8 bytes from hl to port c
  ; while setting the VRAM write address to each bitplane byte 
  ; for the given sprite and bitplane number
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
  ld a, (ix+CarData.Direction)
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
  jp z, LABEL_746B_Trampoline_RuffTrux_UpdatePerFrameTiles

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
  DEC_A
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
  UpdateCarDecorators _RAM_DCAB_CarData_Green, SpriteIndex_Decorators.Green, 1
  ret

LABEL_336A_UpdateBlueCarDecorator:
  UpdateCarDecorators _RAM_DCEC_CarData_Blue, SpriteIndex_Decorators.Blue, 2
  ret

LABEL_33D2_UpdateYellowCarDecorator:
  UpdateCarDecorators _RAM_DD2D_CarData_Yellow, SpriteIndex_Decorators.Yellow, 3
  ret
.ends

.section "Trampolines 8" force
LABEL_343A_:
  JumpToPagedFunction PagedFunction_375A0_

LABEL_3445_:
  JumpToPagedFunction PagedFunction_3766F_
.ends

.section "Bank 0 3450" force
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
  DEC_A
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
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $01
  ld (_RAM_DE44_), a
+:
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $02
  ld (_RAM_DE45_), a
+:
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $03
  ld (_RAM_DE46_), a
+:
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $02
  ld (_RAM_DE47_), a
+:
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  sub l
  jr nc, +
  xor $FF
+:
  cp $18
  jr nc, +
  ld a, $03
  ld (_RAM_DE48_), a
+:
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
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
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr z, +
  ld a, (_RAM_DF06_)
  ld (_RAM_DF08_X), a
  ld a, (_RAM_DF07_)
  ld (_RAM_DF09_Y), a
  jp ++

+:
  ld a, (_RAM_DBA4_CarX)
  ld (_RAM_DF08_X), a
  ld a, (_RAM_DBA5_CarY)
  ld (_RAM_DF09_Y), a
++:
  ld ix, _RAM_DA60_SpriteTableXNs.10
  ld iy, _RAM_DAE0_SpriteTableYs.10
  ld a, (_RAM_DF08_X)
  ld (_RAM_DE84_X), a
  ld a, (_RAM_DF09_Y)
  ld (_RAM_DE85_Y), a
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_DE86_CarDirection), a
  ld a, <SpriteIndex_Decorators.Red
  ld (_RAM_DF1E_DecoratorTileIndex), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  jp LABEL_3A6B_RuffTrux

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
  ld (_RAM_DE85_Y), a
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
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld a, (_RAM_DF61_)
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF59_CarState)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DE8C_InPoolTableHole)
  ld (_RAM_DE8B_), a
  ld a, (_RAM_D5BD_)
  ld (_RAM_D5C1_), a
  ld a, (_RAM_D5BF_)
  ld (_RAM_D5C2_), a
  call LABEL_3B74_CarSpriteAnimation
  ld a, (_RAM_D5C2_)
  ld (_RAM_D5BF_), a
  ld a, (_RAM_D5C1_)
  ld (_RAM_D5BD_), a
  ld a, (_RAM_DE8B_)
  ld (_RAM_DE8C_InPoolTableHole), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF59_CarState), a
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  ld (_RAM_DF61_), a
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
  ld (_RAM_DF5D_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, ++
  ld a, (_RAM_DF59_CarState)
  cp CarState_2_Respawning
  jr nz, +
  ld a, $0A
  ld (_RAM_D95B_EngineSound1.Volume), a
  xor a
  ld (_RAM_DF58_ResettingCarToTrack), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld a, (_RAM_DE55_CPUCarDirection)
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
  ld a, (_RAM_DF58_ResettingCarToTrack)
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
  ld a, (_RAM_DCAB_CarData_Green.SpriteX)
  ld (_RAM_DE84_X), a
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  ld (_RAM_DE85_Y), a
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  ld (_RAM_DE86_CarDirection), a
  ld a, $91
  ld (_RAM_DF1E_DecoratorTileIndex), a
  ld a, (_RAM_DE41_)
  cp $01
  jr z, +
  ld a, $E0
  ld (_RAM_DE85_Y), a
+:
  ld a, (_RAM_DF5A_CarState3)
  or a ; CarState_0_Normal
  jr z, LABEL_37B5_
  cp CarState_3_Falling
  jr z, +
  cp CarState_4_Submerged
  jr nz, ++
+:
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  or a
  jr z, ++
  call LABEL_3F17_Trampoline_PagedFunction_23BC6_
  jp LABEL_37BB_

++:
  ld a, (_RAM_DF5E_)
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld a, (_RAM_DF62_)
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5A_CarState3)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DCAB_CarData_Green.Unknown51_b)
  ld (_RAM_DE8B_), a
  call LABEL_3B74_CarSpriteAnimation
  ld a, (_RAM_DE8B_)
  ld (_RAM_DCAB_CarData_Green.Unknown51_b), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF5A_CarState3), a
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  ld (_RAM_DF62_), a
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
  ld (_RAM_DF5E_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, ++
  ld a, (_RAM_DF5A_CarState3)
  cp CarState_2_Respawning
  jr nz, +
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack), a
  ld a, (_RAM_DCAB_CarData_Green.Unknown12_b_Direction)
  ld (_RAM_DCAB_CarData_Green.Direction), a
+:
  xor a
  ld (_RAM_DF5A_CarState3), a ; CarState_0_Normal
++:
  jp LABEL_37BE_

LABEL_37B5_:
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  or a
  jr nz, LABEL_37BE_
LABEL_37BB_:
  call LABEL_3963_
LABEL_37BE_:
  ld ix, _RAM_DA60_SpriteTableXNs.30
  ld iy, _RAM_DAE0_SpriteTableYs.30
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  ld (_RAM_DE84_X), a
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  ld (_RAM_DE85_Y), a
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld (_RAM_DE86_CarDirection), a
  ld a, $92
  ld (_RAM_DF1E_DecoratorTileIndex), a
  ld a, (_RAM_DE42_)
  cp $01
  jr z, +
  ld a, $E0
  ld (_RAM_DE85_Y), a
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
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  or a
  jr z, +
  call LABEL_48D1_
  call LABEL_3813_
  jp LABEL_38B9_

LABEL_3813_:
  xor a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ret

+:
  call LABEL_3813_
++:
  ld a, (_RAM_DF5F_)
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld a, (_RAM_DF63_)
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5B_)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
  ld (_RAM_DE8B_), a
  ld a, (_RAM_D5BE_)
  ld (_RAM_D5C1_), a
  ld a, (_RAM_D5C0_)
  ld (_RAM_D5C2_), a
  call LABEL_3B74_CarSpriteAnimation
  ld a, (_RAM_D5C2_)
  ld (_RAM_D5C0_), a
  ld a, (_RAM_D5C1_)
  ld (_RAM_D5BE_), a
  ld a, (_RAM_DE8B_)
  ld (_RAM_DCEC_CarData_Blue.Unknown51_b), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  ld (_RAM_DF63_), a
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
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
  ld a, MAX_ENGINE_VOLUME
  ld (_RAM_D96C_EngineSound2.Volume), a
+:
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack), a
  ld a, (_RAM_D582_)
  cp $02
  jr nz, +
  ld a, (_RAM_DE55_CPUCarDirection)
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
  xor a
  ld (_RAM_D582_), a
+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction)
  ld (_RAM_DCEC_CarData_Blue.Direction), a
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
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
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteX)
  ld (_RAM_DE84_X), a
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  ld (_RAM_DE85_Y), a
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
  ld (_RAM_DE86_CarDirection), a
  ld a, $93
  ld (_RAM_DF1E_DecoratorTileIndex), a
  ld a, (_RAM_DE43_)
  cp $01
  jr z, +
  ld a, $E0
  ld (_RAM_DE85_Y), a
+:
  ld a, (_RAM_DF5C_)
  or a
  jr z, LABEL_395D_
  cp $03
  jr z, +
  cp $04
  jr nz, ++
+:
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
  or a
  jr z, ++
  call LABEL_48FC_
  jp LABEL_3963_

++:
  ld a, (_RAM_DF60_)
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld a, (_RAM_DF64_)
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5C_)
  ld (_RAM_DE8A_CarState2), a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown51_b)
  ld (_RAM_DE8B_), a
  call LABEL_3B74_CarSpriteAnimation
  ld a, (_RAM_DE8B_)
  ld (_RAM_DD2D_CarData_Yellow.Unknown51_b), a
  ld a, (_RAM_DE8A_CarState2)
  ld (_RAM_DF5C_), a
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  ld (_RAM_DF64_), a
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
  ld (_RAM_DF60_), a
  ld a, (_RAM_DE89_)
  cp $01
  JrNzRet _LABEL_395C_ret
  ld a, (_RAM_DF5C_)
  cp $02
  jr nz, +
  xor a
  ld (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack), a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown12_b_Direction)
  ld (_RAM_DD2D_CarData_Yellow.Direction), a
+:
  xor a
  ld (_RAM_DF5C_), a
_LABEL_395C_ret:
  ret

LABEL_395D_:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  or a
  JrNzRet _LABEL_395C_ret
  
LABEL_3963_:
  call LABEL_3969_SetCarSpriteXYs
  jp LABEL_39AE_SetCarSpriteTileIndices ; and ret

LABEL_3969_SetCarSpriteXYs:
  ; Draw sprites in the 9 sprites pointed by ix, iy
  ld a, (_RAM_DE84_X)
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
  ld a, (_RAM_DE85_Y)
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

LABEL_39AE_SetCarSpriteTileIndices:
  ld hl, DATA_3E04_CarTileIndicesPerRow
  ; Index by direction for our starting number
  ld a, (_RAM_DE86_CarDirection)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ; Start with that and increment (and save it)
  ld (ix+1), a
  ld (_RAM_DE9E_), a
  INC_A
  ld (ix+3), a
  INC_A
  ld (ix+5), a
  ; Then again at +24
  ld a, (_RAM_DE9E_)
  add a, 24
  ld (ix+7), a
  ld (_RAM_DE9E_), a
  INC_A
  ld (ix+9), a
  INC_A
  ld (ix+11), a
  ; Then again at +48
  ld a, (_RAM_DE9E_)
  add a, 24
  ld (ix+13), a
  INC_A
  ld (ix+15), a
  INC_A
  ld (ix+17), a
  ; And the decorator...
  ld a, (_RAM_DF1E_DecoratorTileIndex)
  ld (ix-1), a
  ld hl, _RAM_DA00_DecoratorOffsets
  ld a, (_RAM_DE86_CarDirection)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE84_X)
  add a, l
  ld (ix-2), a
  ld hl, _RAM_DA00_DecoratorOffsets + 16
  ld a, (_RAM_DE86_CarDirection)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE85_Y)
  add a, l
  ld (iy-1), a
  ret
.ends

.section "Trampolines 9" force
LABEL_3A23_:
  JumpToPagedFunction PagedFunction_36A85_
.ends

.section "Bank 0 3a2e" force
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

LABEL_3A6B_RuffTrux:
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
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld a, (_RAM_DF61_)
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  xor a
  ld (_RAM_DE89_), a
  call LABEL_3B74_CarSpriteAnimation
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  ld (_RAM_DF61_), a
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
  ld (_RAM_DF5D_), a
  ld a, (_RAM_DE89_)
  cp $01
  JrNzRet _LABEL_3AC8_ret
  ld a, (_RAM_DF59_CarState)
  cp CarState_2_Respawning
  jr nz, +
  ld a, MAX_ENGINE_VOLUME
  ld (_RAM_D95B_EngineSound1.Volume), a
  xor a
  ld (_RAM_DF58_ResettingCarToTrack), a
  ld a, (_RAM_DE55_CPUCarDirection)
  ld (_RAM_DE90_CarDirection), a
  ld (_RAM_DE91_CarDirectionPrevious), a
+:
  xor a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld (_RAM_DF59_CarState), a ; CarState_0_Normal
_LABEL_3AC8_ret:
  ret

LABEL_3AC9_:
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet _LABEL_3AC8_ret
LABEL_3ACF_:
  ; Set up RuffTrux sprites
  ; ix = sprite XNs
  ; iy = sprite Ys
  ld a, (_RAM_DE84_X) ; Sprite X
  ld (ix+0), a
  ld (ix+8), a
  ld (ix+16), a
  ld (ix+24), a
  add a, 8
  ld (ix+2), a
  ld (ix+10), a
  ld (ix+18), a
  ld (ix+26), a
  add a, 8
  ld (ix+4), a
  ld (ix+12), a
  ld (ix+20), a
  ld (ix+28), a
  add a, 8
  ld (ix+6), a
  ld (ix+14), a
  ld (ix+22), a
  ld (ix+30), a
  ld a, (_RAM_DE85_Y) ; Sprite Y
  ld (iy+0), a
  ld (iy+1), a
  ld (iy+2), a
  ld (iy+3), a
  add a, 8
  ld (iy+4), a
  ld (iy+5), a
  ld (iy+6), a
  ld (iy+7), a
  add a, 8
  ld (iy+8), a
  ld (iy+9), a
  ld (iy+10), a
  ld (iy+11), a
  add a, 8
  ld (iy+12), a
  ld (iy+13), a
  ld (iy+14), a
  ld (iy+15), a
  ld a, (_RAM_DE86_CarDirection) ; Rotation index
  sla a
  sla a
  sla a
  sla a
  ld hl, DATA_35C2D_RuffTruxTileIndices
  ld d, 0
  ld e, a
  add hl, de
  ld c, 16 + 1 ; one too many?
  ld a, :DATA_35C2D_RuffTruxTileIndices
  ld (PAGING_REGISTER), a
-:ld a, (hl)
  ld (ix+1), a
  inc ix
  inc ix
  inc hl
  dec c
  jr nz, -
  ; Restore paging
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ; Set "decorator" sprite to 0, 0
  xor a
  ld (ix-2), a
  ld (iy-1), a
  ret

LABEL_3B74_CarSpriteAnimation:
  ld a, (_RAM_DE8A_CarState2)
  cp CarState_3_Falling
  jp z, LABEL_2FDC_Falling
  cp CarState_4_Submerged
  jp z, LABEL_3E43_Submerged
  cp CarState_ff
  JrZRet _LABEL_3BEC_ret
  
  ; Explosion
  
  ; Disable decorator (X,Y = 0)
  xor a
  ld (ix-2), a
  ld (iy-1), a
  
  ; Move corner sprites 2px closer to the centre so the explosion looks more circular  
  ld a, (_RAM_DE84_X)
  ld (ix+6), a
  add a, 2
  ld (ix+0), a
  ld (ix+12), a
  add a, 6
  ld (ix+2), a
  ld (ix+8), a
  ld (ix+14), a
  add a, 6
  ld (ix+4), a
  ld (ix+16), a
  add a, 2
  ld (ix+10), a
  
  ld a, (_RAM_DE85_Y)
  ld (iy+1), a
  add a, 2
  ld (iy+0), a
  ld (iy+2), a
  add a, 6
  ld (iy+3), a
  ld (iy+4), a
  ld (iy+5), a
  add a, 6
  ld (iy+6), a
  ld (iy+8), a
  add a, 2
  ld (iy+7), a
  
  ; Cycle timer
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
  INC_A
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  cp 1
  jr z, +
  cp 5 ; Animate every 5 frames
  JrNzRet _LABEL_3BEC_ret
  xor a
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
_LABEL_3BEC_ret:
  ret

+:; New frame time
  ; Get the frame data
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, +
  call LABEL_3DEC_RuffTrux_
  ld hl, DATA_3F05_RuffTruxExplosionFrames
  jp ++
+:ld hl, DATA_40D3_ExplosionFrames
++:
  ; Index into table
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
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
  ; Then follow the pointer and emit 9 bytes to the sprite indices
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
  
  ; Cycle _RAM_DE88_CarSpriteAnimationIndex from 0 to 8
  ld a, (_RAM_DE88_CarSpriteAnimationIndex)
  INC_A
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  cp 9
  JrNzRet +
  ; When it wraps, set/reset stuff
  ld a, 1
  ld (_RAM_DE89_), a
  xor a
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
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
  ld (_RAM_DCEC_CarData_Blue.LapsRemaining), a ; TODO are these different things?
  ld (_RAM_DD2D_CarData_Yellow.LapsRemaining), a
  ld a, $03
  ld (_RAM_DCAB_CarData_Green.LapsRemaining), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, ++
  ; Not head to head
  ; Change this ???
  ld a, $03
  ld (_RAM_DCEC_CarData_Blue.LapsRemaining), a
++:
  xor a
  ld (_RAM_DF25_NumberOfCarsFinished), a

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
  ld hl, DATA_2FBC_ProgressTilesPerLapPerTrack
  add hl, de
  ld a, (_RAM_DB96_TrackIndexForThisType)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ; Store to _RAM_DF68_ProgressTilesPerLap
  ld (_RAM_DF68_ProgressTilesPerLap), a
  ; And divided by 2 to _RAM_DF69_ProgressTilesPerHalfLap
  srl a
  ld (_RAM_DF69_ProgressTilesPerHalfLap), a
  ; Copy original value to various places
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  ld (_RAM_D587_CurrentTrackPositionIndex), a
  ld (_RAM_DD2D_CarData_Yellow.CurrentLapProgress), a
  ld (_RAM_DCEC_CarData_Blue.CurrentLapProgress), a
  ld (_RAM_DF4F_LastTrackPositionIndex), a
  ld (_RAM_DF52_YellowCarCurrentLapProgress), a
  ld (_RAM_DF51_BlueCarCurrentLapProgress), a
  ; ???
  ld a, $01
  ld (_RAM_DCAB_CarData_Green.CurrentLapProgress), a
  ld (_RAM_DF50_GreenCarCurrentLapProgress), a
  ; Init HUD data?
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ; Head to Head only
  ld a, $01
  ld (_RAM_DF51_BlueCarCurrentLapProgress), a
  ld (_RAM_DCEC_CarData_Blue.CurrentLapProgress), a
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

+:JumpToPagedFunction PagedFunction_35F41_InitialiseHeadToHeadHUDSprites

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
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  JrZRet _LABEL_3DBC_ret
  cp $3C
  JrZRet _LABEL_3DBC_ret
  ld a, (_RAM_DCEC_CarData_Blue.Unknown28_b)
  and $18
  srl a
  or a
  jr z, +
  ld (_RAM_D5B9_), a
  ld a, (_RAM_D5BA_)
  INC_A
  and $07
  ld (_RAM_D5BA_), a
  jr z, +
  ; Decrement down to 6
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  cp $06
  jr c, +
  DEC_A
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
+:ld a, (_RAM_DCEC_CarData_Blue.CurrentLayoutData)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld e, a
  ld d, $00
  ld hl, DATA_4425_BubblePushDirections
  add hl, de
  ld a, (hl)
  cp $FE
  JrZRet _LABEL_3DBC_ret
  cp $FF
  JrZRet _LABEL_3DBC_ret
  ld (_RAM_D5B8_), a
_LABEL_3DBC_ret:
  ret
.ends

.section "Trampolines 10" force
LABEL_3DBD_Trampoline_PagedFunction_239C6_:
  JumpToPagedFunction PagedFunction_239C6_
.ends

.section "Track tiles data pages" force
DATA_3DC8_TrackTypeTileDataPages:
.db :DATA_3C000_Sportscars_Tiles :DATA_39C83_FourByFour_Tiles :DATA_3D901_Powerboats_Tiles :DATA_38000_TurboWheels_Tiles :DATA_34000_FormulaOne_Tiles :DATA_3A8FA_Warriors_Tiles :DATA_39168_Tanks_Tiles :DATA_3CD8D_RuffTrux_Tiles :DATA_34000_Choppers_Tiles_BadReference
.ends

.section "Trampolines 11" force
LABEL_3DD1_:
  JumpToPagedFunction PagedFunction_3636E_
.ends

.section "Track tiles data pointers" force
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
DATA_3E04_CarTileIndicesPerRow:
; Relative tile indices for car tiles
.db $00 $03 $06 $09 $0C $0F $12 $15 $48 $4B $4E $51 $54 $57 $5A $5D ; Multiples of 3, jumping in the middle
; And for RuffTrux
.db $00 $04 $08 $0C $10 $14 $18 $1C $80 $84 $88 $8C $90 $94 $98 $9C ; Multiples of 4, jumping in the middle

.ends

.section "Trampolines 12" force
LABEL_3E24_:
  JumpToPagedFunction PagedFunction_37817_

LABEL_3E2F_:
  JumpToPagedFunction PagedFunction_37946_

.ends

.section "Track data pages, +" force

DATA_3E3A_TrackTypeDataPageNumbers:
.db :DATA_C000_TrackData_SportsCars
.db :DATA_10000_TrackData_FourByFour
.db :DATA_14000_TrackData_Powerboats
.db :DATA_18000_TrackData_TurboWheels
.db :DATA_1C000_TrackData_FormulaOne
.db :DATA_20000_TrackData_Warriors
.db :DATA_24000_TrackData_Tanks
.db :DATA_28000_TrackData_RuffTrux
.db :DATA_2C000_TrackData_Choppers_BadReference

LABEL_3E43_Submerged:
  ; Check the timer
  ld a, (_RAM_DE87_CarSpriteAnimationTimer)
  or a
  jr z, ++
  cp $80
  jr c, +
  ; When it gets to 128, explode
  ld a, CarState_1_Exploding
  ld (_RAM_DE8A_CarState2), a
  xor a
  ld (_RAM_D5C2_), a
  ld (_RAM_D5C1_), a
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  ld (_RAM_DE88_CarSpriteAnimationIndex), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld (_RAM_DF73_), a
  ret

+:; Same as ++
  INC_A
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  jp +++

++:
  INC_A
  ld (_RAM_DE87_CarSpriteAnimationTimer), a
  
+++:
  ; Hide the decorator
  xor a
  ld (ix-2), a
  ld (iy-1), a
  
  ld a, <SpriteIndex_SubmergedCar_FrontWheel
  ld (ix+1), a
  ld (ix+5), a
  ld a, <SpriteIndex_SubmergedCar_BackWheel_Front
  ld (ix+7), a
  ld (ix+11), a
  ld a, <SpriteIndex_SubmergedCar_BackWheel_Back
  ld (ix+13), a
  ld (ix+17), a
  ld a, <SpriteIndex_Blank
  ld (ix+3), a
  ld a, <SpriteIndex_SubmergedCar_Body_Front
  ld (ix+9), a
  ld a, <SpriteIndex_SubmergedCar_Body_Back
  ld (ix+15), a
  jp LABEL_3969_SetCarSpriteXYs ; and ret

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
.ifdef UNNECESSARY_CODE
.db :DATA_30000_CarTiles_Choppers_BadReference
.endif

; Data from 3EFD to 3F04 (8 bytes)
DATA_3EFD_CarTileDataLookup_Hi:
.db >DATA_34958_CarTiles_Sportscars >DATA_34CF0_CarTiles_FourByFour >DATA_35048_CarTiles_Powerboats >DATA_35350_CarTiles_TurboWheels >DATA_30000_CarTiles_FormulaOne >DATA_30330_CarTiles_Warriors >DATA_306D0_CarTiles_Tanks >DATA_1296A_CarTiles_RuffTrux

DATA_3F05_RuffTruxExplosionFrames:
.dw RuffTruxExplosion_Frame0 RuffTruxExplosion_Frame1 RuffTruxExplosion_Frame2 RuffTruxExplosion_Frame3 RuffTruxExplosion_Frame4 RuffTruxExplosion_Frame5 RuffTruxExplosion_Frame6 RuffTruxExplosion_Frame7 RuffTruxExplosion_Frame8

.ends

.section "Trampolines 13" force
LABEL_3F17_Trampoline_PagedFunction_23BC6_:
  JumpToPagedFunction PagedFunction_23BC6_
.ends

.section "Screen off" force
LABEL_3F22_ScreenOff:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENOFF
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret
.ends

.section "Trampolines 14" force
LABEL_3F2B_BlankGameRAMTrampoline:
  JumpToPagedFunction PagedFunction_23B98_BlankGameRAM
.ends

.section "Screen on +" force
LABEL_3F36_ScreenOn:
  ld a, VDP_REGISTER_MODECONTROL2_SCREENON
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_3F3F_Trampoline_TrackPositionAISpeedHacks:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet +
  CallPagedFunction2 PagedFunction_362D3_TrackPositionAISpeedHacks
+:ret

LABEL_3F54_BlankGameRAM:
  ld bc, _RAM_DF9A_EndOfRAM - _RAM_DCAB_GameRAMStart ; $02EF ; Byte count
-:ld hl, _RAM_DCAB_GameRAMStart ; Start
  add hl, bc
  xor a
  ld (hl), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

RuffTruxExplosion_Frame0:
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank

RuffTruxExplosion_Frame1:
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank

RuffTruxExplosion_Frame2:
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust1

RuffTruxExplosion_Frame3:
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Dust2

RuffTruxExplosion_Frame4:
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Dust3

RuffTruxExplosion_Frame5:
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Dust1
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Blank

RuffTruxExplosion_Frame6:
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust2
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank

RuffTruxExplosion_Frame7:
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Dust3
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank

RuffTruxExplosion_Frame8:
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank
.db SpriteIndex_RuffTrux_Blank

LABEL_3FB4_Trampoline_UpdateAnimatedPalette:
  CallPagedFunction2 PagedFunction_23CE6_UpdateAnimatedPalette
  ret

; Data from 3FC3 to 3FD2 (16 bytes)
DATA_3FC3_HorizontalAmountByDirection:
; Multiples of 6 from 0 to 24 to 0 to 24 to ...
; Indexed by direction, gives an absolute amount for the X movement for that direction at a speed of 24.
; Ideal values would be:
; $00 -> sin(0)    = $00
; $06 -> sin(22.5) = $09
; $0C -> sin(45)   = $11
; $12 -> sin(67.5) = $16
; $18 -> sin(90)   = $18
; The "non-ideal" values here correspond to slowing the speed down from 24 to 19 or 17 when driving diagonally.
; 
;                      00
;                   06    06
;                0C          0C
;             12                12
;          18                      18
;             12                12
;                0C          0C
;                   06    06
;                      00
.ifdef SLOWER_DIAGONALS
.db $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06
.else
; We don't use .dbsin here because we also want to take the abs value, and it rounds less nicely
.db $00 $09 $11 $16 $18 $16 $11 $09 $00 $09 $0C $12 $18 $12 $0C $06
.endif

; Data from 3FD3 to 3FFF (45 bytes)
DATA_3FD3_VerticalAmountByDirection:
; Antiphase of the above
; Indexed by direction, gives an absolute amount for the Y movement for that direction at a speed of 24.
;                      18
;                   12    12
;                0C          0C
;             06                06
;          00                      00
;             06                06
;                0C          0C
;                   12    12
;                      18
.ifdef SLOWER_DIAGONALS
.db $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12
.else
.db $18 $16 $11 $09 $00 $09 $0C $12 $18 $12 $0C $06 $00 $09 $11 $16 
.endif

.ifdef BLANK_FILL_ORIGINAL
; Uninitialised memory containing source code
.db "D", 9, "A,(BULLON2)", 13, 10, 9, "OR", 9, "A", 13, 10, 9, "JR", 9, "Z,"
.endif
.ends

.macro BankMarker args offset
.if nargs == 1
.orga offset
.else
.orga $bfff ; default offset
.endif
.section "Bank marker \@" force
.db :CADDR
.ends
.endm

  BankMarker $3fff ; not actually used?

.section "Bank 1" force

; Metatile tilemaps are stored from $0080 in each track data bank
; Each metatile is 12 * 12 = 144 bytes of tile indices
; There are up to $41(?) for each track type
; So we use our "times table" macro to generate the split pointers
DATA_4000_TileIndexPointerLow: ; Low bytes of "tile index data pointer table"
  TimesTableLo $8080, 12*12, $41
DATA_4041_TileIndexPointerHigh: ; High bytes of "tile index data pointer table"
  TimesTableHi $8080, 12*12, $41

DATA_4082_Explosion_Frame0:
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 0 ; First smoke starts in the centre
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank

DATA_408B_Explosion_Frame1:
.db <SpriteIndex_Smoke + 0 ; Four start in the corners
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 0
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 0
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 0

DATA_4094_Explosion_Frame2:
.db <SpriteIndex_Smoke + 1 ; Four more start in the "compass points"
.db <SpriteIndex_Smoke + 0
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Smoke + 0
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Smoke + 0
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Smoke + 0
.db <SpriteIndex_Smoke + 1

DATA_409D_Explosion_Frame3:
.db <SpriteIndex_Smoke + 2 ; Now we just play them through
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Smoke + 2

DATA_40A6_Explosion_Frame4:
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Smoke + 0 ; Centre puff animates twice
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Smoke + 3

DATA_40AF_Explosion_Frame5:
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Smoke + 1
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Blank

DATA_40B8_Explosion_Frame6:
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 2
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank

DATA_40C1_Explosion_Frame7:
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Smoke + 3
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank

DATA_40CA_Explosion_Frame8:
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank
.db <SpriteIndex_Blank

; Pointer Table from 40D3 to 40E4 (9 entries, indexed by _RAM_DE88_CarSpriteAnimationIndex)
DATA_40D3_ExplosionFrames:
.dw DATA_4082_Explosion_Frame0 DATA_408B_Explosion_Frame1 DATA_4094_Explosion_Frame2 DATA_409D_Explosion_Frame3 DATA_40A6_Explosion_Frame4 DATA_40AF_Explosion_Frame5 DATA_40B8_Explosion_Frame6 DATA_40C1_Explosion_Frame7 DATA_40CA_Explosion_Frame8

; Data from 40E5 to 40F4 (16 bytes)
DATA_40E5_Sign_Directions_X: ; Sign bit, 1 = negative, 0 = positive
; For each of the 16 dirctions, 0 for +X (or 0) and 1 for -X
;         0
;       1   0
;     1       0
;   1           0
; 1               0
;   1           0
;     1       0
;       1   0
;         0
.db 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1

; Data from 40F5 to 4104 (16 bytes)
DATA_40F5_Sign_Directions_Y: ; Similar for Y
;         1
;       1   1
;     1       1
;   1           1
; 0               0
;   0           0
;     0       0
;       0   0
;         0
.db 1 1 1 1 0 0 0 0 0 0 0 0 0 1 1 1

; Data from 4105 to 4224 (288 bytes)
DATA_4105_CarDecoratorOffsets: ; 32 bytes per track type, copied to _RAM_DA00_DecoratorOffsets
; First 16 are X offsets of car decorator per car direction
; Second 16 are corresponding Y offsets
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
; Choppers
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

.ends

.section "Powerboats deceleration in bubbles" force
DATA_4425_BubblePushDirections:
; Directions bubbles push for each metatile index
; e f 0 1 2
; d       3
; c       4
; b       5
; a 9 8 7 6
.db  -1,  -2, $0C, $04, $06, $06, $08, $0A, $0A, $00, $0E, $0E, $02, $02,  -2, $0C
.db $04,  -2,  -2,  -2, $00, $08, $00,  -1,  -1,  -2,  -1,  -1,  -2,  -2, $0C,  -1
.db $04, $0C,  -1,  -1,  -1,  -1,  -2,  -2,  -2,  -2,  -2,  -1, $00,  -2, $08,  -2
.db $0C, $04,  -2,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1

LABEL_4465_Powerboats_BubblePush_GetData:
  ; Only for powerboats
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet ++
  
  ; ???
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet ++
  
  ; Win phase -> skip
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet ++
  
  ; Metatiles $00 and $3c (bubbles) -> skip
  ld a, (_RAM_DE7D_CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  JrZRet ++
  cp $3C
  JrZRet ++
  
  ; Grab the middle two bits of the "behaviour byte"
  ld a, (_RAM_DF79_CurrentBehaviourByte)
  and %00011000 ; Middle 2 bits
  srl a
  or a
  jr z, + ; Zero = no deceleration
  ld (_RAM_DF7B_Powerboats_BubblePush_Strength), a ; Bits to here, will be 4, 8 or c
  ; Counter cycles every 8 frames
  ld a, (_RAM_DF86_Powerboats_BubblePush_Counter)
  INC_A
  and POWERBOATS_BUBBLES_PUSH_COUNTER_MASK
  ld (_RAM_DF86_Powerboats_BubblePush_Counter), a
  jr z, +
  ; The counter slows down the engine deceleration, down to 6
  ld a, (_RAM_DE92_EngineSpeed)
  cp POWERBOATS_BUBBLES_DECELERATION_TARGET_SPEED
  jr c, +
  DEC_A
  ld (_RAM_DE92_EngineSpeed), a
+:
  ; Look up the data for this metatile
  ld a, (_RAM_DE7D_CurrentLayoutData)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld e, a
  ld d, $00
  ld hl, DATA_4425_BubblePushDirections
  add hl, de
  ld a, (hl)
  ; -2 and -1 are ignored
  cp -2
  JrZRet ++
  cp -1
  JrZRet ++
  ; Else we load it here
  ld (_RAM_DF7A_Powerboats_BubblePush_Direction), a
++:
  ret

LABEL_44C3_Powerboats_BubblePush_ApplyData:
  ; Only for powerboats
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet +
  ; Not in win phase
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet +
  ; Only if _RAM_DF7B_Powerboats_BubblePush_Strength is set
  ld a, (_RAM_DF7B_Powerboats_BubblePush_Strength)
  or a
  ; Could ret z
  jr nz, ++
+:ret

++:
  ld a, $01
  ld (_RAM_DEB5_), a
  ld hl, _RAM_DF7C_Powerboats_BubblePush_DecayCounter
  inc (hl)
  ld a, (_RAM_DF7C_Powerboats_BubblePush_DecayCounter)
  and POWERBOATS_BUBBLES_PUSH_COUNTER_MASK
  ld (_RAM_DF7C_Powerboats_BubblePush_DecayCounter), a
  or a
  jr nz, +
  ; Decrement _RAM_DF7B_Powerboats_BubblePush_Strength whenever _RAM_DF7C_Powerboats_BubblePush_DecayCounter loops
  ld a, (_RAM_DF7B_Powerboats_BubblePush_Strength)
  DEC_A
  ld (_RAM_DF7B_Powerboats_BubblePush_Strength), a
+:
  call LABEL_4595_GetBubblePushData
  ld a, (_RAM_DF84_BubblePush_Sign_X)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_HScrollDelta)
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  ld a, (_RAM_DF84_BubblePush_Sign_X)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_HScrollDelta), a
+++:
  ld a, (_RAM_DEB0_)
  or a
  jr nz, +
  jp +

+:
  ld a, (_RAM_DF85_BubblePush_Sign_Y)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
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
  ld a, (_RAM_DF85_BubblePush_Sign_Y)
  ld (_RAM_DEB2_), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
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

LABEL_4595_GetBubblePushData:
  ; Look up _RAM_DF7B_Powerboats_BubblePush_Strength-th item in DATA_1D65__Lo and DATA_1D76__Hi, store to de
  ld hl, DATA_1D65__Lo
  ld a, (_RAM_DF7B_Powerboats_BubblePush_Strength)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (_RAM_DF7B_Powerboats_BubblePush_Strength)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  
  ; Look up horizontal max speed for the push direction (0..24)
  ld hl, DATA_3FC3_HorizontalAmountByDirection
  ld a, (_RAM_DF7A_Powerboats_BubblePush_Direction)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  
  ; Add _RAM_DEAD_
  ld hl, _RAM_DEAD_
  add a, (hl)
  
  ; Look up index in table row
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  ; Save to _RAM_DF82_BubblePush_Strength_X
  ld (_RAM_DF82_BubblePush_Strength_X), a
  
  ; Look up sign for the push direction
  ld hl, DATA_40E5_Sign_Directions_X
  ld a, (_RAM_DF7A_Powerboats_BubblePush_Direction)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  ; Save the opposite (1 <-> 0) to _RAM_DF84_BubblePush_Sign_X
  CP_0 ; Could or a
  jr z, +
  xor a
  ld (_RAM_DF84_BubblePush_Sign_X), a
  jp ++
+:ld a, $01
  ld (_RAM_DF84_BubblePush_Sign_X), a
++:

  ; Repeat for vertical direction
  ; Save amount to _RAM_DF83_BubblePush_Strength_Y, sign complement to _RAM_DF85_BubblePush_Sign_Y
  ld hl, DATA_3FD3_VerticalAmountByDirection
  ld a, (_RAM_DF7A_Powerboats_BubblePush_Direction)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  ld hl, _RAM_DEAD_
  add a, (hl)
  ld h, d
  ld l, e
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  ld (_RAM_DF83_BubblePush_Strength_Y), a
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (_RAM_DF7A_Powerboats_BubblePush_Direction)
  add a, l
  ld l, a
  ld a, 0
  adc a, h
  ld h, a
  ld a, (hl)
  cp 0 ; could or a
  jr z, +
  xor a
  ld (_RAM_DF85_BubblePush_Sign_Y), a
  ret
+:ld a, $01
  ld (_RAM_DF85_BubblePush_Sign_Y), a
  ret

LABEL_4622_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JpNzRet _LABEL_46C8_ret
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_46C8_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JpNzRet _LABEL_46C8_ret
  ld a, (_RAM_DE7D_CurrentLayoutData)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, LABEL_4682_
  cp $32
  jr z, LABEL_4682_
  ld hl, (_RAM_DBA0_TopLeftMetatileX)
  ld de, (_RAM_DE79_CurrentMetatile_OffsetX)
  add hl, de
  ld a, l
  cp $10
  jr z, +
  cp $11
  JrNzRet _LABEL_46C8_ret
+:
  ld hl, (_RAM_DBA2_TopLeftMetatileY)
  ld de, (_RAM_DE7B_CurrentMetatile_OffsetY)
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
  ld a, (_RAM_DF84_BubblePush_Sign_X)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_HScrollDelta)
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  ld a, (_RAM_DF84_BubblePush_Sign_X)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

_LABEL_46C8_ret:
  ret

+:
  ld a, $07
  ld (_RAM_DEAF_HScrollDelta), a
+++:
  ld a, (_RAM_DF85_BubblePush_Sign_Y)
  ld l, a
  ld a, (_RAM_DEB2_)
  cp l
  jr z, ++
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
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
  ld a, (_RAM_DF85_BubblePush_Sign_Y)
  ld (_RAM_DEB2_), a
  ret

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
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
  ld a, (_RAM_DE7D_CurrentLayoutData)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, +
  ld bc, DATA_37161_
  jp ++
+:ld bc, DATA_370D1_
++:
  ld hl, DATA_2652_TimesTable12Lo
  ld de, (_RAM_DE77_CurrentMetatile_TileY)
  add hl, de
  ld a, (hl)
  ld l, a
  ld h, $00
  ld de, (_RAM_DE75_CurrentMetaTile_TileX)
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
  ld (_RAM_DF82_BubblePush_Strength_X), a
  ld (_RAM_DF83_BubblePush_Strength_Y), a
  ld a, b
  and $20
  jr nz, ++
  ld a, b
  and $80
  jr z, +
  xor a
  ld (_RAM_DF84_BubblePush_Sign_X), a
  jp +++

+:
  ld a, $01
  ld (_RAM_DF84_BubblePush_Sign_X), a
  jp +++

++:
  xor a
  ld (_RAM_DF82_BubblePush_Strength_X), a
+++:
  ld a, b
  and $10
  jr nz, ++
  ld a, b
  and $40
  jr z, +
  xor a
  ld (_RAM_DF85_BubblePush_Sign_Y), a
  ret

+:
  ld a, $01
  ld (_RAM_DF85_BubblePush_Sign_Y), a
  ret

++:
  xor a
  ld (_RAM_DF83_BubblePush_Strength_Y), a
  ret

LABEL_4793_:
  xor a
  ld (_RAM_DF82_BubblePush_Strength_X), a
  ld (_RAM_DF83_BubblePush_Strength_Y), a
  jp LABEL_29A3_EnterPoolTableHole

_LABEL_479D_ret:
  ret

LABEL_479E_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrNzRet _LABEL_479D_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
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
  ; fall through
++:
  ld a, (ix+CarData.CurrentLayoutData)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, ++
  cp $32
  jr z, ++
  ld a, (ix+CarData.XMetatile)
  cp $10
  jr z, +
  cp $11
  JrNzRet _LABEL_479D_ret
+:
  ld a, (ix+CarData.YMetatile)
  cp $1D
  jr z, +
  cp $1F
  JrNzRet _LABEL_479D_ret
  ld a, $61
  jp +++

+:ld a, $21
  jp +++

++:
  ld a, (ix+CarData.CurrentLayoutData)
  call LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, +
  ld bc, DATA_37161_
  jp ++
+:ld bc, DATA_370D1_
++:
  ld hl, DATA_2652_TimesTable12Lo
  ld d, $00
  ld a, (ix+CarData.YMetatileRelative)
  ld e, a
  add hl, de
  ld a, (hl)
  ld l, a
  ld h, $00
  ld d, $00
  ld a, (ix+CarData.XMetatileRelative)
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
  ld a, (ix+CarData.XPosition.Lo)
  ld l, a
  ld a, (ix+CarData.XPosition.Hi)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+CarData.XPosition.Lo), a
  ld a, h
  ld (ix+CarData.XPosition.Hi), a
  jp ++

+:
  ld a, (ix+CarData.XPosition.Lo)
  ld l, a
  ld a, (ix+CarData.XPosition.Hi)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  add hl, de
  ld a, l
  ld (ix+CarData.XPosition.Lo), a
  ld a, h
  ld (ix+CarData.XPosition.Hi), a
++:
  ld a, b
  and $10
  JrNzRet ++
  ld a, b
  and $40
  jr z, +
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+CarData.YPosition.Lo), a
  ld a, h
  ld (ix+CarData.YPosition.Hi), a
  ret

+:
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF87_)
  ld e, a
  add hl, de
  ld a, l
  ld (ix+CarData.YPosition.Lo), a
  ld a, h
  ld (ix+CarData.YPosition.Hi), a
++:ret

LABEL_48BF_:
  jp LABEL_4DD4_

LABEL_48C2_Trampoline_PagedFunction_23BF1_:
  CallPagedFunction2 PagedFunction_23BF1_
  ret

LABEL_48D1_:
  ld a, (_RAM_DF6D_)
  INC_A
  and $01
  ld (_RAM_DF6D_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF5B_)
  cp $04
  jr z, +
--:
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  INC_A
-:
  and $0F
  ld (_RAM_DCEC_CarData_Blue.Direction), a
  ret

+:
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  cp $08
  jr nc, --
  DEC_A
  jp -

LABEL_48FC_:
  ld a, (_RAM_DF6E_)
  INC_A
  and $01
  ld (_RAM_DF6E_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF5C_)
  cp $04
  jr z, +
--:
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
  INC_A
-:
  and $0F
  ld (_RAM_DD2D_CarData_Yellow.Direction), a
  ret

+:
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
  cp $08
  jr nc, --
  DEC_A
  jp -

LABEL_4927_:
  ld ix, _RAM_DCAB_CarData_Green
  call +
  ld ix, _RAM_DCEC_CarData_Blue
  call +
  ld ix, _RAM_DD2D_CarData_Yellow
+:
  ld a, 1
  ld (ix+CarData.EffectsEnabled), a
  ld de, (_RAM_DBA9_)
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  jr z, +
  ld a, (ix+CarData.Unknown41_w.Lo)
  ld l, a
  ld a, (ix+CarData.Unknown41_w.Hi)
  ld h, a
  jp ++

+:
  ld a, (ix+CarData.XPosition.Lo)
  ld l, a
  ld a, (ix+CarData.XPosition.Hi)
  ld h, a
++:
  or a
  sbc hl, de
  ld de, (_RAM_DC57_Adjustment2_XY)
  add hl, de
  ld a, l
  ld (ix+CarData.SpriteX), a
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
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  jr z, +
  ld a, (ix+CarData.Unknown43_w.Lo)
  ld l, a
  ld a, (ix+CarData.Unknown43_w.Hi)
  ld h, a
  jp ++

+:
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
++:
  or a
  sbc hl, de
  ld de, (_RAM_DC57_Adjustment2_XY)
  add hl, de
  ld a, l
  ld (ix+CarData.SpriteY), a
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
  ld (ix+CarData.SpriteY), a
  xor a
  ld (ix+CarData.EffectsEnabled), a
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
  DEC_A
  ld (_RAM_DE2F_), a
+:
  call LABEL_6677_
  JumpToPagedFunction PagedFunction_1BDF3_

; Data from 49FA to 4DA9 (944 bytes)
; One of the three is pointed to by _RAM_DF53_FormulaOne_BorderTrackPositionsPointer
; Depending on whether it's track 0, 1 or 2 (for F1)
; It's then indexed by the car progress index
; The value is 1 for table edge positions, 0 otherwise
_LABEL_49FA_BorderTrackPositions_Track0:
.db 0 0 0 0 0 0 0 0 0 0 ; 0-16
.db 0 0 0 0 0 0 0
.db               1 1 1 ; 17-81
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1
.db     0 0 0 0 0 0 0 0  ; 82-133
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0
_LABEL_4A80_BorderTrackPositions_Track1:
.db 0 0 0 0 0 0 0 0 0 0 ; 0-56
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0
.db               1 1 1 ; 57-125
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1 1 1 1
.db             0 0 0 0 ; 126-143
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0
_LABEL_4B10_BorderTrackPositions_Track2:
.db 0 0 0 0 0 0 0 0 0 0 ; 0-122
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0 0 0 0 0 0 0 0
.db 0 0 0
.db       1 1 1 1 1 1 1 ; 123-142
.db 1 1 1 1 1 1 1 1 1 1
.db 1 1 1
.db       0 0 0 0 0 0 0 ; 143-155
.db 0 0 0 0 0 0

; Data pointed to by DATA_1D65__Lo etc
; TODO what is it? 0..8 with a weird ramp effect
; row indexed by speed 0..15 + _RAM_DEAD_ (which is 0..5 -> out of range?)
; ALso by _RAM_DF7B_Powerboats_BubblePush_Strength
; column indexed by horizontal/vertical delta for a given speed (0..29)
Data1d65_0:  .db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
Data1d65_1:  .db 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 1 0 1 0
Data1d65_2:  .db 0 0 0 0 0 0 1 0 0 1 0 0 1 1 0 1 1 0 1 1 1 1 1 0 1 1 1 1 1 1
Data1d65_3:  .db 0 0 0 0 0 0 1 0 1 0 1 0 1 1 1 1 1 1 2 1 1 2 1 1 2 2 1 2 1 1
Data1d65_4:  .db 0 0 0 0 0 0 1 1 0 1 1 0 2 1 1 2 1 1 2 2 1 2 2 1 2 2 2 2 2 2
Data1d65_5:  .db 0 0 0 0 0 0 1 1 1 1 1 0 2 2 1 2 2 1 3 2 2 2 2 2 3 2 3 2 3 2
Data1d65_6:  .db 0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 3 2 3 2 3 2 3 3 3 3 3 3
Data1d65_7:  .db 0 0 0 0 0 0 2 1 1 1 1 1 3 2 2 3 2 2 3 3 3 3 3 3 4 3 4 3 4 3
Data1d65_8:  .db 0 0 0 0 0 0 2 1 1 2 1 1 3 3 2 3 3 2 4 3 3 4 3 3 4 4 4 4 4 4
Data1d65_9:  .db 0 0 0 0 0 0 2 1 2 1 2 1 3 3 3 3 3 3 4 4 4 4 4 3 5 4 5 4 5 4
Data1d65_10: .db 0 0 0 0 0 0 2 2 1 2 2 1 4 3 3 4 3 3 5 4 4 4 4 4 5 5 5 5 5 5
Data1d65_11: .db 0 0 0 0 0 0 2 2 2 2 2 1 4 4 3 4 4 3 5 5 4 5 5 4 6 5 6 5 6 5
Data1d65_12: .db 0 0 0 0 0 0 2 2 2 2 2 2 4 4 4 4 4 4 5 5 5 5 5 5 6 6 6 6 6 6
Data1d65_13: .db 0 0 0 0 0 0 3 2 2 2 2 2 5 4 4 5 4 4 6 5 6 5 6 5 7 6 7 6 7 6
Data1d65_14: .db 0 0 0 0 0 0 3 2 2 3 2 2 5 5 4 5 5 4 6 6 6 6 6 5 7 7 7 7 7 7
Data1d65_15: .db 0 0 0 0 0 0 3 2 3 2 3 2 5 5 5 5 5 5 7 6 6 7 6 6 8 7 8 7 8 7
Data1d65_16: .db 0 0 0 0 0 0 3 3 2 3 3 2 6 5 5 6 5 5 7 7 6 7 7 6 8 8 8 8 8 8

LABEL_4DAA_:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  JpNzRet _LABEL_5A87_ret
  ld hl, DATA_24AE_JumpCurveMultiplierForSpeed
  ld d, $00
  ld a, (ix+CarData.Unknown11_b_Speed)
  ld e, a
  add hl, de
  ld a, (hl)
  ld (ix+CarData.Unknown36_b_JumpCurveMultiplier), a
  ld hl, DATA_24BE_JumpCurveStepForSpeed
  add hl, de
  ld a, (hl)
  ld (ix+CarData.Unknown37_b), a
  cp JUMP_MAX_CURVE_INDEX
  JpZRet _LABEL_5A87_ret
  ld a, $01
  ld (ix+CarData.Unknown38_b), a
  jp LABEL_5A77_

LABEL_4DD4_:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  ret nz
  ld a, (ix+CarData.TankShotSpriteIndex)
  or a
  jr z, +
  cp $01
  jr z, ++
  jp LABEL_4EFA_

+:
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  or a
  JrNzRet +
  ld a, CarState_3_Falling
  ld (_RAM_DF5A_CarState3), a
  ld a, $01
  ld (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack), a
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld (_RAM_DE67_), a
  ld (_RAM_DE31_CarUnknowns.1.Unknown0_Direction), a
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
+:ret

++:
  ld a, (_RAM_D5B0_)
  or a
  JrNzRet _LABEL_4E7A_ret
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  JrNzRet _LABEL_4E7A_ret
  ld a, (_RAM_D5BE_)
  or a
  jr nz, +
  ld a, SFX_0E_FallToFloor
  ld (_RAM_D974_SFX_Player2), a
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5B0_), a
+:ld a, (_RAM_D5C0_)
  or a
  jr z, +
  ld a, $04
  jp ++
+:ld a, $03
++:
  ld (_RAM_DF5B_), a
  ; Reset engine pitch
  ld hl, LOWEST_PITCH_ENGINE_TONE ; $03E8
  ld (_RAM_D96C_EngineSound2.Tone), hl
  xor a
  ld (_RAM_D96C_EngineSound2.Volume), a
LABEL_4E49_:
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack), a
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld (_RAM_DE68_), a
  ld (_RAM_DE31_CarUnknowns.2.Unknown0_Direction), a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld (_RAM_DF7B_Powerboats_BubblePush_Strength), a
  ld (_RAM_D5B9_), a
  ld (_RAM_DCEC_CarData_Blue.Unknown28_b), a
  ld (_RAM_DF79_CurrentBehaviourByte), a
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
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
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
  ld (_RAM_DEAF_HScrollDelta), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld (_RAM_D5A4_IsReversing), a
  ld (_RAM_D5A5_), a
  ld a, $01
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld (_RAM_DF81_), a
  ld a, (_RAM_DBA4_CarX)
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
  ld (_RAM_DBAD_X_), hl
  ld a, (_RAM_DBA5_CarY)
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
  ld (_RAM_DBAF_Y_), hl
  ret

LABEL_4EFA_:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  or a
  JrNzRet +
  ld a, $03
  ld (_RAM_DF5C_), a
  ld a, $01
  ld (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack), a
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld (_RAM_DE69_), a
  ld (_RAM_DE31_CarUnknowns.3.Unknown0_Direction), a
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
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
  ld (_RAM_DECA_TilemapUpdate_VerticalNeeded), a
  ret

LABEL_4F8F_:
  ld a, (_RAM_DF4F_LastTrackPositionIndex)
  ld l, a
  ld a, (_RAM_DF50_GreenCarCurrentLapProgress)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  cp l
  jr z, LABEL_4FA7_
  jr c, LABEL_4FBC_
LABEL_4FA7_:
  ld a, (_RAM_DF2A_Positions.Red)
  DEC_A
  ld (_RAM_DF2A_Positions.Red), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  cp l
  jr z, LABEL_4FBC_
  jr nc, LABEL_4FA7_
LABEL_4FBC_:
  ld a, (_RAM_DF2A_Positions.Green)
  DEC_A
  ld (_RAM_DF2A_Positions.Green), a
  ret

++:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  cp l
  jr nz, -
  ld a, (_RAM_D589_)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown27_b)
  cp l
  jr z, LABEL_4FA7_
  jr nc, LABEL_4FBC_
  jp LABEL_4FA7_

LABEL_4FDE_:
  ld a, (_RAM_DF4F_LastTrackPositionIndex)
  ld l, a
  ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  cp l
  jr z, LABEL_4FF6_
  jr c, LABEL_500B_
LABEL_4FF6_:
  ld a, (_RAM_DF2A_Positions.Red)
  DEC_A
  ld (_RAM_DF2A_Positions.Red), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  cp l
  jr z, LABEL_500B_
  jr nc, LABEL_4FF6_
LABEL_500B_:
  ld a, (_RAM_DF2A_Positions.Blue)
  DEC_A
  ld (_RAM_DF2A_Positions.Blue), a
  ret

++:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  cp l
  jr nz, -
  ld a, (_RAM_D589_)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown27_b)
  cp l
  jr z, LABEL_4FF6_
  jr nc, LABEL_500B_
  jp LABEL_4FF6_

LABEL_502D_:
  ld a, (_RAM_DF4F_LastTrackPositionIndex)
  ld l, a
  ld a, (_RAM_DF52_YellowCarCurrentLapProgress)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr z, LABEL_5045_
  jr c, LABEL_505A_
LABEL_5045_:
  ld a, (_RAM_DF2A_Positions.Red)
  DEC_A
  ld (_RAM_DF2A_Positions.Red), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr z, LABEL_505A_
  jr nc, LABEL_5045_
LABEL_505A_:
  ld a, (_RAM_DF2A_Positions.Yellow)
  DEC_A
  ld (_RAM_DF2A_Positions.Yellow), a
  ret

++:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr nz, -
  ld a, (_RAM_D589_)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown27_b)
  cp l
  jr z, LABEL_5045_
  jr nc, LABEL_505A_
  jp LABEL_5045_

LABEL_507C_:
  ld a, (_RAM_DF50_GreenCarCurrentLapProgress)
  ld l, a
  ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  cp l
  jr z, LABEL_5094_
  jr c, LABEL_50A9_
LABEL_5094_:
  ld a, (_RAM_DF2A_Positions.Green)
  DEC_A
  ld (_RAM_DF2A_Positions.Green), a
  ret

+:
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  cp l
  jr z, LABEL_50A9_
  jr nc, LABEL_5094_
LABEL_50A9_:
  ld a, (_RAM_DF2A_Positions.Blue)
  DEC_A
  ld (_RAM_DF2A_Positions.Blue), a
  ret

++:
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  cp l
  jr nz, -
  ld a, (_RAM_DCAB_CarData_Green.Unknown27_b)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown27_b)
  cp l
  jr z, LABEL_5094_
  jr nc, LABEL_50A9_
  jp LABEL_5094_

LABEL_50CB_:
  ld a, (_RAM_DF50_GreenCarCurrentLapProgress)
  ld l, a
  ld a, (_RAM_DF52_YellowCarCurrentLapProgress)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr z, LABEL_50E3_
  jr c, LABEL_50F8_
LABEL_50E3_:
  ld a, (_RAM_DF2A_Positions.Green)
  DEC_A
  ld (_RAM_DF2A_Positions.Green), a
  ret

+:
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr z, LABEL_50F8_
  jr nc, LABEL_50E3_
LABEL_50F8_:
  ld a, (_RAM_DF2A_Positions.Yellow)
  DEC_A
  ld (_RAM_DF2A_Positions.Yellow), a
  ret

++:
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr nz, -
  ld a, (_RAM_DCAB_CarData_Green.Unknown27_b)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown27_b)
  cp l
  jr z, LABEL_50E3_
  jr nc, LABEL_50F8_
  jp LABEL_50E3_

LABEL_511A_:
  ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
  ld l, a
  ld a, (_RAM_DF52_YellowCarCurrentLapProgress)
  cp l
  jr z, ++
  jr nc, +
-:
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr z, LABEL_5132_
  jr c, LABEL_5147_
LABEL_5132_:
  ld a, (_RAM_DF2A_Positions.Blue)
  DEC_A
  ld (_RAM_DF2A_Positions.Blue), a
  ret

+:
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr z, LABEL_5147_
  jr nc, LABEL_5132_
LABEL_5147_:
  ld a, (_RAM_DF2A_Positions.Yellow)
  DEC_A
  ld (_RAM_DF2A_Positions.Yellow), a
  ret

++:
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  cp l
  jr nz, -
  ld a, (_RAM_DCEC_CarData_Blue.Unknown27_b)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown27_b)
  cp l
  jr z, LABEL_5132_
  jr nc, LABEL_5147_
  jp LABEL_5132_

LABEL_5169_Trampoline_GameVBlankEngineUpdate:
  JumpToPagedFunction PagedFunction_37292_GameVBlankEngineUpdate

LABEL_5174_Trampoline_GameVBlankPart3:
  JumpToPagedFunction PagedFunction_3730C_GameVBlankPart3

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

LABEL_519D_Trampoline_ReadGGPauseButton:
  JumpToPagedFunction PagedFunction_23C68_ReadGGPauseButton

LABEL_51A8_Trampoline_ClearTilemap:
  JumpToPagedFunction PagedFunction_23DB6_ClearTilemap

LABEL_51B3_:
  ld a, (_RAM_D5DF_)
  or a
  ret nz
  ld ix, _RAM_DCEC_CarData_Blue
  ld l, (ix+CarData.XPosition.Lo)
  ld h, (ix+CarData.XPosition.Hi)
  ld (_RAM_D59F_), hl
  ld l, (ix+CarData.YPosition.Lo)
  ld h, (ix+CarData.YPosition.Hi)
  ld (_RAM_D5A1_), hl
  ret

LABEL_51CF_:
  JumpToPagedFunction PagedFunction_3779F_

LABEL_51DA_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, +
  ld ix, _RAM_DCEC_CarData_Blue
  ld a, (ix+CarData.Unknown12_b_Direction)
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
  ld a, (ix+CarData.Direction)
  ld (_RAM_DE56_), a
  ld a, (ix+CarData.Unknown11_b_Speed)
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
  ld (ix+CarData.Unknown19_b), a
  ld a, (_RAM_DB9A_DecelerationDelay)
  dec a
  ld (ix+CarData.Unknown61_b), a
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
  ld a, (_RAM_DBB5_LayoutByte_)
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
  ld (_RAM_DEAF_HScrollDelta), a
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
  ld a, (ix+CarData.Direction)
  ld (_RAM_DE56_), a
  ld a, (ix+CarData.Unknown11_b_Speed)
  ld (_RAM_DE57_), a
  call LABEL_5304_
  ld ix, _RAM_DCEC_CarData_Blue
  ld a, (ix+CarData.Direction)
  ld (_RAM_DE56_), a
  ld a, (ix+CarData.Unknown11_b_Speed)
  ld (_RAM_DE57_), a
  call LABEL_5304_
  ld ix, _RAM_DD2D_CarData_Yellow
  ld a, (ix+CarData.Direction)
  ld (_RAM_DE56_), a
  ld a, (ix+CarData.Unknown11_b_Speed)
  ld (_RAM_DE57_), a
LABEL_5304_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jp z, LABEL_536C_
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  jp nz, LABEL_522C_
  jp LABEL_536C_

+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  or a
  jr nz, ++
+:
  ld a, $02
  ld (_RAM_DE57_), a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld a, $01
  ld (_RAM_D5A5_), a
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld d, $00
  ld e, a
  ld hl, DATA_250E_OppositeDirections
  add hl, de
  ld a, (hl)
  ld (_RAM_DE56_), a
  ret

LABEL_536C_:
  ld a, (_RAM_D5A5_)
  or a
  jr z, +
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld (_RAM_D5A5_), a
+:
  ld a, (ix+CarData.Unknown26_b_HasFinished)
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
  ld a, (ix+CarData.Unknown61_b)
  inc a
  ld (ix+CarData.Unknown61_b), a
  cp b
  jp c, LABEL_544A_
  ld (ix+CarData.Unknown61_b), $00
  ld a, (ix+CarData.Unknown11_b_Speed)
  or a
  jp z, LABEL_544A_
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  jp nz, LABEL_544A_
  dec (ix+CarData.Unknown11_b_Speed)
  jp LABEL_544A_

+++:
  ld l, (ix+CarData.Unknown47_w.Lo)
  ld h, (ix+CarData.Unknown47_w.Hi)
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
  ld a, (ix+CarData.Unknown50_b)
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
  ld a, (ix+CarData.Unknown11_b_Speed)
  or a
  jr nz, LABEL_537F_
  ld a, (_RAM_DB99_AccelerationDelay)
  dec a
  ld (ix+CarData.Unknown19_b), a
  jp LABEL_544A_

++:
  ld a, (_RAM_DB9A_DecelerationDelay)
  dec a
  ld (ix+CarData.Unknown61_b), a
  ld a, (ix+CarData.Unknown19_b)
  inc a
  ld (ix+CarData.Unknown19_b), a
  cp b
  jr c, LABEL_544A_
  ld (ix+CarData.Unknown19_b), $00
  ld a, (_RAM_D5D0_Player2Handicap)
  or a
  jr z, +
  ld l, a
  ld a, (ix+CarData.TopSpeed)
  sub l
  ld l, a
  ld a, (ix+CarData.Unknown11_b_Speed)
  cp l
  jr z, LABEL_544A_
  jr c, +++
  jr ++

+:
  ld l, (ix+CarData.Unknown11_b_Speed)
  ld a, (ix+CarData.TopSpeed)
  cp l
  jr z, LABEL_544A_
  jr nc, +++
++:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  jr nz, LABEL_544A_
  dec (ix+CarData.Unknown11_b_Speed)
  jp LABEL_544A_

+++:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  jr nz, LABEL_544A_
  inc (ix+CarData.Unknown11_b_Speed)
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
  ; If single player and not head to head...
  ld a, (ix+CarData.TankShotSpriteIndex)
  ld l, a
  ld a, (_RAM_D5CA_)
  cp l
  jp nz, LABEL_56C0_
+:
  ; Convert X position to metatile index, offset within metatile - after offsetting by 12px
  ld l, (ix+CarData.XPosition.Lo)
  ld h, (ix+CarData.XPosition.Hi)
  ld de, 12
  add hl, de
  ld (_RAM_DF20_PositionToMetatile_Parameter), hl
  call LABEL_7A58_PositionToMetatile_DivMod96
  ld a, (_RAM_DF20_PositionToMetatile_MetatileIndex)
  ld (ix+CarData.XMetatile), a
  ld a, (_RAM_DF21_PositionToMetatile_OffsetInMetatile)
  ; Divide this by 8 so it's a tile offset, not a pixel offset
  srl a
  srl a
  srl a
  ld (ix+CarData.XMetatileRelative), a
  ; Repeat for Y position
  ld l, (ix+CarData.YPosition.Lo)
  ld h, (ix+CarData.YPosition.Hi)
  ld de, 12
  add hl, de
  ld (_RAM_DF20_PositionToMetatile_Parameter), hl
  call LABEL_7A58_PositionToMetatile_DivMod96
  ld a, (_RAM_DF20_PositionToMetatile_Parameter)
  ld (ix+CarData.YMetatile), a
  ld a, (_RAM_DF21_PositionToMetatile_OffsetInMetatile)
  srl a
  srl a
  srl a
  ld (ix+CarData.YMetatileRelative), a
  
  ; Zero _RAM_DEF1_Multiply_Result
  xor a
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  ld (_RAM_DEF1_Multiply_Result.Hi), a
  
  ; Offset 
  ld a, (ix+CarData.YMetatile)
  or a
  jr z, +
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DB9C_MetatilemapWidth.Lo)
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_30EA_MultiplyBy32
+:
  ld a, (_RAM_DEF1_Multiply_Result.Lo)
  ld l, a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld h, a
  ld d, $00
  ld e, (ix+CarData.XMetatile)
  add hl, de
  ld (_RAM_D585_CurrentMetatileOffset), hl
  ld de, _RAM_C400_TrackIndexes
  add hl, de
  ld a, (hl)
  ld (ix+CarData.CurrentLapProgress), a
  ld hl, (_RAM_D585_CurrentMetatileOffset)
  ld de, _RAM_C000_LevelLayout
  add hl, de
  ld a, (hl)
  ld (ix+CarData.CurrentLayoutData), a
  and LAYOUT_EXTRA_MASK
  ld (_RAM_DE53_), a
  ld hl, DATA_254E_TimesTable18Lo
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
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
  ld e, (ix+CarData.YMetatileRelative)
  add hl, de
  ld l, (hl)
  ld h, $00
  ld d, $00
  ld e, (ix+CarData.XMetatileRelative)
  add hl, de
  ld a, l
  ld (_RAM_DE6D_.Lo), a
  ld a, h
  ld (_RAM_DE6D_.Hi), a
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
  ld a, (_RAM_DE6D_.Lo)
  ld l, a
  ld a, (_RAM_DE6D_.Hi)
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
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  jr z, ++
  cp $1A
  jr z, ++
+:
  ld a, (_RAM_DE70_)
  and b
  jp z, LABEL_5608_
++:
  ld l, (ix+CarData.Unknown47_w.Lo)
  ld h, (ix+CarData.Unknown47_w.Hi)
  xor a
  ld (hl), a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ; Add 8 to Unknown39_w and store a at the pointed result
  ld l, (ix+CarData.Unknown39_w.Lo)
  ld h, (ix+CarData.Unknown39_w.Hi)
  ld de, $0008
  add hl, de
  ld (hl), a
  ld a, (_RAM_D59E_)
  or a
  jr z, LABEL_55FA_
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, +
  ld a, :DATA_37232_FourByFour_WallOverrides
  ld (PAGING_REGISTER), a
  ld hl, DATA_37232_FourByFour_WallOverrides
  ld d, $00
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
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
  ld (_RAM_D974_SFX_Player2), a
+:; Reset engine tone
  ld hl, LOWEST_PITCH_ENGINE_TONE ; $03E8
  ld (_RAM_D96C_EngineSound2.Tone), hl
  call LABEL_51CF_
  ld hl, (_RAM_D59F_)
  ld (ix+CarData.XPosition.Lo), l
  ld (ix+CarData.XPosition.Hi), h
  ld hl, (_RAM_D5A1_)
  ld (ix+CarData.YPosition.Lo), l
  ld (ix+CarData.YPosition.Hi), h
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  ld (ix+CarData.Unknown15_b), a
  ld (ix+CarData.Unknown16_b), a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DB7E_), a
  ld (_RAM_DB7F_), a
  ld (_RAM_D5B9_), a
  ld a, $01
  ld (_RAM_D5DF_), a
  jp LABEL_5608_

LABEL_55FA_:
  ld a, (ix+CarData.Unknown12_b_Direction)
  cp (ix+CarData.Direction)
  ld a, $00
  jr nz, +
  inc a
+:ld (ix+CarData.Unknown11_b_Speed), a
LABEL_5608_:
  ld hl, DATA_25D0_TimesTable36Lo
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
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
  ld a, (_RAM_DE6D_.Lo)
  ld l, a
  ld a, (_RAM_DE6D_.Hi)
  ld h, a
  ld a, :DATA_1B1A2_12x12To6x6
  ld (PAGING_REGISTER), a
  ld de, DATA_1B1A2_12x12To6x6
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld h, $00
  add hl, bc
  ld a, (hl)
  ld (ix+CarData.Unknown28_b), a
  ld h, a
  ld l, a
  ld a, (ix+CarData.Unknown58_b)
  cp l
  jr z, +
  ld (ix+CarData.Unknown59_b), a
  ld a, l
  ld (ix+CarData.Unknown58_b), a
+:
  ld a, (ix+CarData.Unknown46_b_ResettingCarToTrack)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  dec a
  jp z, LABEL_575D_
+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr nz, +
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $23
  jr nz, +
  ld a, $08
  ld (ix+CarData.Unknown12_b_Direction), a
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
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld c, a
  ld hl, _RAM_D900_UnknownData
  ld b, $00
  add hl, bc
  ld a, (hl)
  and %01100000 ; Bits 5-6
  sra a
  ld c, a
  ld b, $00
  ld hl, DATA_1DA7_Special_
  add hl, bc
  jp ++

+:
  ld hl, DATA_1D87_Default_
++:
  add hl, de
  ld a, (hl)
  ld (ix+CarData.Unknown12_b_Direction), a
  ld a, (_RAM_DE53_)
  and $40
  jr z, LABEL_56C0_
  ld hl, DATA_1D97_OppositeDirections
  ld d, $00
  ld e, (ix+CarData.Unknown12_b_Direction)
  add hl, de
  ld a, (hl)
  ld (ix+CarData.Unknown12_b_Direction), a
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
  ld a, (ix+CarData.Unknown46_b_ResettingCarToTrack)
  or a
  jp nz, LABEL_586B_
  ld a, (ix+CarData.Unknown51_b)
  or a
  jr z, +
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
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
  ld a, (ix+CarData.Direction)
  ld c, a
  ld a, (ix+CarData.Unknown12_b_Direction)
  cp c
  jr z, LABEL_5764_
  sub c
  jr c, +++
  cp $02
  jr c, ++
  ld b, a
  ld a, (ix+CarData.Unknown11_b_Speed)
  cp d
  jr c, +
  dec a
  ld (ix+CarData.Unknown11_b_Speed), a
+:
  ld a, b
++:
  cp $08
  jr nc, LABEL_573C_
--:
  ld a, (ix+CarData.Direction)
  inc a ; Rotate clockwise
-:
  and $0F
  ld b, a
  ld a, (ix+CarData.Unknown14_b)
  inc a
  and l
  ld (ix+CarData.Unknown14_b), a
  or a
  jr nz, LABEL_5764_
  ld a, b
  ld (ix+CarData.Direction), a
  jp LABEL_5764_

LABEL_573C_:
  ld a, (ix+CarData.Direction)
  dec a
  jp -

+++:
  xor $FF
  inc a
  cp $02
  jr c, ++
  ld b, a
  ld a, (ix+CarData.Unknown11_b_Speed)
  cp d
  jr c, +
  dec a
  ld (ix+CarData.Unknown11_b_Speed), a
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
  ld a, (ix+CarData.Unknown46_b_ResettingCarToTrack)
  or a
  jp nz, LABEL_586B_
  ld l, (ix+CarData.Unknown11_b_Speed)
  ld a, (_RAM_DB98_TopSpeed)
  cp l
  jr nz, +
  jp ++

+:
  ld a, (_RAM_DF00_JumpCurvePosition)
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
    ld hl, DATA_3FC3_HorizontalAmountByDirection
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
    ld (ix+CarData.Unknown15_b), a
    ld hl, DATA_40E5_Sign_Directions_X
    ld a, (_RAM_DE56_)
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    or a
    jr z, +
    ld (ix+CarData.Unknown33_b), $00
    ld a, (ix+CarData.XPosition.Lo)
    ld l, a
    ld a, (ix+CarData.XPosition.Hi)
    ld h, a
    ld d, $00
    ld a, (ix+CarData.Unknown15_b)
    ld e, a
    or a
    sbc hl, de
    ld (ix+CarData.XPosition.Lo), l
    ld (ix+CarData.XPosition.Hi), h
    jp ++

+:
    ld (ix+CarData.Unknown33_b), $01
    ld l, (ix+CarData.XPosition.Lo)
    ld h, (ix+CarData.XPosition.Hi)
    ld d, $00
    ld a, (ix+CarData.Unknown15_b)
    ld e, a
    add hl, de
    ld (ix+CarData.XPosition.Lo), l
    ld (ix+CarData.XPosition.Hi), h
++:
  pop de
  ld hl, DATA_3FD3_VerticalAmountByDirection
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
  ld (ix+CarData.Unknown16_b), a
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (_RAM_DE56_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld (ix+CarData.Unknown32_b), $00
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  ld d, $00
  ld a, (ix+CarData.Unknown16_b)
  ld e, a
  or a
  sbc hl, de
  ld (ix+CarData.YPosition.Lo), l
  ld (ix+CarData.YPosition.Hi), h
  jp LABEL_586B_

+:
  ld (ix+CarData.Unknown32_b), $01
  ld l, (ix+CarData.YPosition.Lo)
  ld h, (ix+CarData.YPosition.Hi)
  ld d, $00
  ld a, (ix+CarData.Unknown16_b)
  ld e, a
  add hl, de
  ld (ix+CarData.YPosition.Lo), l
  ld (ix+CarData.YPosition.Hi), h
LABEL_586B_:
  ld a, (_RAM_D59E_)
  or a
  jr z, LABEL_5872_
  ret

LABEL_5872_:
  ld a, (ix+CarData.Unknown28_b)
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
  ld a, (ix+CarData.Unknown29_b)
  ld (ix+CarData.Unknown30_b), a
  cp b
  jr z, +
  ld (ix+CarData.Unknown31_b), a
+:
  ld a, b
  ld (ix+CarData.Unknown29_b), a
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_5902_ret
  ld a, (ix+CarData.Unknown29_b)
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
  jp z, LABEL_1CF4_Trampoline_PagedFunction_1FB35_
  cp $09
  jp z, LABEL_5B9A_
  cp $13
  jp z, LABEL_5E25_
_LABEL_5902_ret:
  ret

+:
  ld a, (ix+CarData.Unknown11_b_Speed)
  cp $07
  JrCRet +
  ld a, (ix+CarData.Unknown34_w.Lo)
  ld l, a
  ld a, (ix+CarData.Unknown34_w.Hi)
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
  ld a, (ix+CarData.Unknown11_b_Speed)
  or a
  jr z, +++
  ld a, (ix+CarData.Unknown34_w.Lo)
  ld l, a
  ld a, (ix+CarData.Unknown34_w.Hi)
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
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  JrNzRet _LABEL_5978_ret
  ld a, (ix+CarData.Unknown30_b)
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
  ld (ix+CarData.Unknown36_b_JumpCurveMultiplier), a
  ld a, $08
  ld (ix+CarData.Unknown37_b), a
  xor a
  ld (ix+CarData.Unknown38_b), a
  jp LABEL_5A77_

_LABEL_5978_ret:
  ret

LABEL_5979_:
  ld a, (ix+CarData.Unknown30_b)
  cp $0D
  JrZRet _LABEL_5978_ret
  jp LABEL_4DAA_

LABEL_5983_:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  jr nz, +
  ld a, (ix+CarData.Unknown30_b)
  cp $0B
  jr z, ++
+:jp LABEL_59DC_

++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  jp LABEL_4DD4_

+:jp LABEL_2961_

LABEL_59A4_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown30_b)
  cp $07
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown31_b)
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown30_b)
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
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $1A
  ret z
  JumpToPagedFunction PagedFunction_1BF17_

LABEL_59EF_:
  ld a, (ix+CarData.Unknown30_b)
  cp $07
  jr z, LABEL_5A39_
  ld a, (ix+CarData.Unknown31_b)
  or a
  JrNzRet +
LABEL_59FC_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld a, SFX_03_Crash
  ld (_RAM_D974_SFX_Player2), a
  ; Reset engine tone
  ld hl, LOWEST_PITCH_ENGINE_TONE ; $03E8
  ld (_RAM_D96C_EngineSound2.Tone), hl
  call LABEL_51CF_
  ld hl, (_RAM_D59F_)
  ld (ix+CarData.XPosition.Lo), l
  ld (ix+CarData.XPosition.Hi), h
  ld hl, (_RAM_D5A1_)
  ld (ix+CarData.YPosition.Lo), l
  ld (ix+CarData.YPosition.Hi), h
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  ld (ix+CarData.Unknown15_b), a
  ld (ix+CarData.Unknown16_b), a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DB7E_), a
  ld (_RAM_DB7F_), a
+:ret

LABEL_5A39_:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  JrNzRet _LABEL_5A87_ret
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24EE_GG_
  jp ++
+:ld hl, DATA_24CE_SMS_
++:
  ld a, (_RAM_D5D0_Player2Handicap)
  ld c, a
  ld d, $00
  ld a, (ix+CarData.Unknown11_b_Speed)
  add a, c
  ld e, a
  add hl, de
  ld a, (hl)
  ld (ix+CarData.Unknown36_b_JumpCurveMultiplier), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, DATA_24FE_GG_
  jp ++

+:
  ld hl, DATA_24DE_SMS_
++:
  add hl, de
  ld a, (hl)
  ld (ix+CarData.Unknown37_b), a
  ld a, $02
  ld (ix+CarData.Unknown38_b), a
LABEL_5A77_:
  ld a, $01
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld a, (ix+CarData.EffectsEnabled)
  or a
  JrZRet _LABEL_5A87_ret
  ld a, SFX_02_HitGround
  ld (_RAM_D974_SFX_Player2), a
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
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  JpZRet _LABEL_5B77_ret
  ld hl, DATA_1B232_JumpCurveTable
  ld e, a
  add hl, de
  ld a, :DATA_1B232_JumpCurveTable
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
  ld (_RAM_DEF5_Multiply_Parameter1), a
  ld a, (ix+CarData.Unknown36_b_JumpCurveMultiplier)
  ld (_RAM_DEF4_Multiply_Parameter2), a
  call LABEL_1B94_Multiply
  ld a, (ix+CarData.Unknown39_w.Lo)
  ld e, a
  ld a, (ix+CarData.Unknown39_w.Hi)
  ld d, a
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld l, a
  ld a, (ix+CarData.SpriteX)
  add a, l
  add a, $04
  ld (de), a
  ld a, e
  add a, $04
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ld a, (ix+CarData.SpriteY)
  add a, l
  add a, $04
  ld (de), a
  ld a, e
  add a, $04
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ld a, (ix+CarData.EffectsEnabled)
  or a
  jr z, +
  ld a, $01
  ld (de), a
  ld (_RAM_DF8A_), de
+:
  ld a, b
  ld (_RAM_DEF5_Multiply_Parameter1), a
  ld a, (ix+CarData.Unknown36_b_JumpCurveMultiplier)
  and $FC
  rr a
  rr a
  ld (_RAM_DEF4_Multiply_Parameter2), a
  call LABEL_1B94_Multiply
  ld d, $00
  ld a, (_RAM_DEF1_Multiply_Result.Hi)
  ld e, a
  ld a, (ix+CarData.XPosition.Lo)
  ld l, a
  ld a, (ix+CarData.XPosition.Hi)
  ld h, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+CarData.Unknown41_w.Lo), a
  ld a, h
  ld (ix+CarData.Unknown41_w.Hi), a
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+CarData.Unknown43_w.Lo), a
  ld a, h
  ld (ix+CarData.Unknown43_w.Hi), a
  ld a, (ix+CarData.Unknown37_b)
  ld l, a
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  add a, l
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  cp JUMP_MAX_CURVE_INDEX
  JrCRet _LABEL_5B77_ret
  ld a, (ix+CarData.EffectsEnabled)
  or a
  jr z, +
  ld a, SFX_02_HitGround
  ld (_RAM_D974_SFX_Player2), a
+:
  xor a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld (ix+CarData.Unknown51_b), a
  ld (_RAM_D5D9_), a
  ld de, (_RAM_DF8A_)
  ld (de), a
  ld a, (ix+CarData.Unknown36_b_JumpCurveMultiplier)
  cp $1E
  jr c, +
  cp $60
  jr c, ++
  jp +++

+:
  ld a, (ix+CarData.Unknown38_b)
  cp $02
  JrNzRet _LABEL_5B77_ret
  ; Nothing happens!
  ret

_LABEL_5B77_ret:
  ret

; Data from 5B78 to 5B7F (8 bytes)
; Unreachable code
.ifdef UNNECESSARY_CODE
  ld a,$8e ; ??? High bit set
  ld (PAGING_REGISTER),a
  jp $a003 ; ???
.endif

++:
  ld a, $0A
  ld (ix+CarData.Unknown36_b_JumpCurveMultiplier), a
  ld a, $0C
  ld (ix+CarData.Unknown37_b), a
  jp LABEL_5A77_

+++:
  ld a, $20
  ld (ix+CarData.Unknown36_b_JumpCurveMultiplier), a
  ld a, $08
  ld (ix+CarData.Unknown37_b), a
  jp LABEL_5A77_

LABEL_5B9A_:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  or a
  jr z, +
  ret

+:
  ld a, (ix+CarData.Unknown51_b)
  or a
  JpNzRet _LABEL_5E24_ret
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jp z, LABEL_5CFC_
  cp $01
  jp z, LABEL_5CAF_
  ld a, (ix+CarData.Unknown59_b)
  and $10
  jp nz, LABEL_4DD4_
  ld a, (ix+CarData.Unknown60_b)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $3A
  jp nz, LABEL_4DD4_
  jp +++

+:
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $3A
  jp nz, LABEL_4DD4_
  jp LABEL_5C31_

++:
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $1D
  jp z, LABEL_5C70_
  cp $1E
  jp nz, LABEL_4DD4_
  jp LABEL_5C70_

+++:
  xor a
  ld (ix+CarData.Unknown60_b), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+CarData.Unknown53_w.Lo), $88
  ld (ix+CarData.Unknown53_w.Hi), $0B
  ld (ix+CarData.Unknown55_w.Lo), $88
  ld (ix+CarData.Unknown55_w.Hi), $0B
  jp ++

+:
  ld (ix+CarData.Unknown53_w.Lo), $B0
  ld (ix+CarData.Unknown53_w.Hi), $0B
  ld (ix+CarData.Unknown55_w.Lo), $B0
  ld (ix+CarData.Unknown55_w.Hi), $0B
++:
  ld a, $0E
  ld (ix+CarData.Unknown52_b), a
  ld a, $4D
  ld (ix+CarData.Unknown51_b), a
  ld a, $01
  ld (ix+CarData.Unknown57_b), a
  jp LABEL_5D4A_

LABEL_5C31_:
  ld a, $02
  ld (ix+CarData.Unknown60_b), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, @SMS
@GG:
  ld (ix+CarData.Unknown53_w.Lo), $40
  ld (ix+CarData.Unknown53_w.Hi), $08
  ld (ix+CarData.Unknown55_w.Lo), $58
  ld (ix+CarData.Unknown55_w.Hi), $06
  jp ++

@SMS:
  ld (ix+CarData.Unknown53_w.Lo), $68
  ld (ix+CarData.Unknown53_w.Hi), $08
  ld (ix+CarData.Unknown55_w.Lo), $80
  ld (ix+CarData.Unknown55_w.Hi), $06
++:
  ld a, $04
  ld (ix+CarData.Unknown52_b), a
  ld a, $4E
  ld (ix+CarData.Unknown51_b), a
  xor a
  ld (ix+CarData.Unknown57_b), a
  jp LABEL_5D4A_

LABEL_5C70_:
  ld a, $01
  ld (ix+CarData.Unknown60_b), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+CarData.Unknown53_w.Lo), $08
  ld (ix+CarData.Unknown53_w.Hi), $07
  ld (ix+CarData.Unknown55_w.Lo), $80
  ld (ix+CarData.Unknown55_w.Hi), $01
  jp ++

+:
  ld (ix+CarData.Unknown53_w.Lo), $30
  ld (ix+CarData.Unknown53_w.Hi), $07
  ld (ix+CarData.Unknown55_w.Lo), $A8
  ld (ix+CarData.Unknown55_w.Hi), $01
++:
  ld a, $0A
  ld (ix+CarData.Unknown52_b), a
  ld a, $60
  ld (ix+CarData.Unknown51_b), a
  xor a
  ld (ix+CarData.Unknown57_b), a
  jp LABEL_5D4A_

LABEL_5CAF_:
  ld a, (ix+CarData.Unknown59_b)
  and $10
  jp nz, LABEL_4DD4_
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $39
  jp nz, LABEL_4DD4_
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+CarData.Unknown53_w.Lo), $50
  ld (ix+CarData.Unknown53_w.Hi), $01
  ld (ix+CarData.Unknown55_w.Lo), $18
  ld (ix+CarData.Unknown55_w.Hi), $01
  jp ++

+:
  ld (ix+CarData.Unknown53_w.Lo), $78
  ld (ix+CarData.Unknown53_w.Hi), $01
  ld (ix+CarData.Unknown55_w.Lo), $40
  ld (ix+CarData.Unknown55_w.Hi), $01
++:
  ld a, $06
  ld (ix+CarData.Unknown52_b), a
  ld a, $23
  ld (ix+CarData.Unknown51_b), a
  ld a, $01
  ld (ix+CarData.Unknown57_b), a
  jp LABEL_5D4A_

LABEL_5CFC_:
  ld a, (ix+CarData.Unknown59_b)
  and $10
  jp nz, LABEL_4DD4_
  ld a, (ix+CarData.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  cp $34
  jr z, +
  cp $35
  jp nz, LABEL_4DD4_
+:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld (ix+CarData.Unknown53_w.Lo), $68
  ld (ix+CarData.Unknown53_w.Hi), $06
  ld (ix+CarData.Unknown55_w.Lo), $38
  ld (ix+CarData.Unknown55_w.Hi), $05
  jp ++

+:
  ld (ix+CarData.Unknown53_w.Lo), $90
  ld (ix+CarData.Unknown53_w.Hi), $06
  ld (ix+CarData.Unknown55_w.Lo), $60
  ld (ix+CarData.Unknown55_w.Hi), $05
++:
  ld a, $0C
  ld (ix+CarData.Unknown52_b), a
  ld a, $1D
  ld (ix+CarData.Unknown51_b), a
  ld a, $01
  ld (ix+CarData.Unknown57_b), a
LABEL_5D4A_:
  ld a, (ix+CarData.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_5E24_ret
  ld a, (ix+CarData.TankShotSpriteIndex)
  or a
  jr z, LABEL_5DAD_
  cp $01
  jr z, +
  xor a
  ld (_RAM_DE69_), a
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  ld a, $03
  ld (_RAM_DF5C_), a
  jp LABEL_5DB9_

+:
  xor a
  ld (_RAM_DE68_), a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, $03
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_5DB9_
  xor a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  ld (_RAM_DB82_), a
  ld (_RAM_DB83_), a
  ld a, SFX_09_EnterPoolTableHole
  ld (_RAM_D974_SFX_Player2), a
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
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  ld a, CarState_3_Falling
  ld (_RAM_DF5A_CarState3), a
LABEL_5DB9_:
  ld a, $01
  ld (ix+CarData.Unknown46_b_ResettingCarToTrack), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5D9_), a
+:
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld a, (ix+CarData.Unknown53_w.Lo)
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  ld a, (ix+CarData.Unknown53_w.Hi)
  ld (_RAM_DEF1_Multiply_Result.Hi), a
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0070
  jp ++

+:
  ld de, $004C
++:
  ld hl, (_RAM_DEF1_Multiply_Result)
  or a
  sbc hl, de
  ld a, l
  ld (ix+CarData.Unknown53_w.Lo), a
  ld a, h
  ld (ix+CarData.Unknown53_w.Hi), a
  ld a, (ix+CarData.Unknown55_w.Lo)
  ld (_RAM_DEF1_Multiply_Result.Lo), a
  ld a, (ix+CarData.Unknown55_w.Hi)
  ld (_RAM_DEF1_Multiply_Result.Hi), a
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0060
  jp ++

+:
  ld de, $0038
++:
  ld hl, (_RAM_DEF1_Multiply_Result)
  or a
  sbc hl, de
  ld a, l
  ld (ix+CarData.Unknown55_w.Lo), a
  ld a, h
  ld (ix+CarData.Unknown55_w.Hi), a
_LABEL_5E24_ret:
  ret

LABEL_5E25_:
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
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
  ld (_RAM_DCAB_CarData_Green.Unknown22_b), a
  ld (_RAM_DCAB_CarData_Green.Unknown23_b), a
  ld (_RAM_DCEC_CarData_Blue.Unknown22_b), a
  ld (_RAM_DCEC_CarData_Blue.Unknown23_b), a
  ld (_RAM_DD2D_CarData_Yellow.Unknown22_b), a
  ld (_RAM_DD2D_CarData_Yellow.Unknown23_b), a
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
  ld a, (_RAM_DCAB_CarData_Green.EffectsEnabled)
  cp $01
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_5F52_ret
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_5F52_ret
  ld a, (_RAM_DCAB_CarData_Green.SpriteX)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
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
  call LABEL_1B0C_DecrementYPosition
  jp ++

+:
  call LABEL_1B2F_IncrementYPosition
++:
  ld a, $01
  cp c
  jr z, +
  call LABEL_1B50_DecrementXPosition
  jp ++

+:
  call LABEL_1B73_IncrementXPosition
++:
  call LABEL_6571_
  ld a, (_RAM_DE31_CarUnknowns.1.Unknown1)
  ld l, a
  ld a, (_RAM_DE92_EngineSpeed)
  cp l
  jr c, ++
  ld d, a
  ld a, (_RAM_DC4A_Cheat_ExtraLivesAndLeadCar)
  or a
  jr z, +
  ld d, CHEAT_LEAD_CAR_VALUE
+:
  ld a, d
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE31_CarUnknowns.1.Unknown0_Direction), a
++:
  ld a, (_RAM_DE2F_)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE2F_), a
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  ld (_RAM_DE2E_), a
  ld a, $06
  ld (_RAM_DEB3_Player1AccelerationDelayCounter), a
++:
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, +++
_Normal:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DE92_EngineSpeed)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown11_b_Speed)
  sub l
  jr nc, +
  xor $FF
  INC_A
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  call LABEL_2934_BehaviourF_Explode
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown11_b_Speed), a
  ld (_RAM_DE92_EngineSpeed), a
_LABEL_5F52_ret:
  ret

+++:
  xor a
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  ld ix, _RAM_DCAB_CarData_Green
  jp LABEL_2961_

LABEL_5F5E_:
  ld ix, _RAM_DCEC_CarData_Blue
  ld bc, $0000
  ld a, (_RAM_DCEC_CarData_Blue.EffectsEnabled)
  cp $01
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_609C_ret
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_609C_ret
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
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
  call LABEL_1B0C_DecrementYPosition
  call LABEL_1AD8_
  jp ++

+:
  call LABEL_1B2F_IncrementYPosition
  call LABEL_1AC8_
++:
  ld a, $01
  cp c
  jr z, +
  call LABEL_1B50_DecrementXPosition
  call LABEL_1AFA_
  jp ++

+:
  call LABEL_1B73_IncrementXPosition
  call LABEL_1AE7_
++:
  call LABEL_6571_
  ld a, (_RAM_DE31_CarUnknowns.2.Unknown1)
  ld l, a
  ld a, (_RAM_DE92_EngineSpeed)
  cp l
  jr c, +++
  ld d, a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC4A_Cheat_ExtraLivesAndLeadCar)
  or a
  jr z, +
  ld a, CHEAT_LEAD_CAR_VALUE
  jr ++

+:
.ifdef UNNECESSARY_CODE
  ld a, d ; pointless?
  ld d, a
.endif
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
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ld a, (_RAM_D5A3_)
  jp ++

+:
  ld a, (_RAM_DE90_CarDirection)
++:
  ld (_RAM_DE31_CarUnknowns.2.Unknown0_Direction), a
+++:
  ld a, (_RAM_DE2F_)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
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
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
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
  ld a, (_RAM_DE92_EngineSpeed)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  sub l
  jr nc, +
  xor $FF
  INC_A
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  ld (_RAM_D5BE_), a
  call LABEL_29BC_Behaviour1_Fall
  call LABEL_4DD4_
  jp ++

+:
  call LABEL_2934_BehaviourF_Explode
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld (_RAM_DE92_EngineSpeed), a
_LABEL_609C_ret:
  ret

LABEL_609D_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_6054_
  xor a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_2961_

LABEL_60AE_:
  ld ix, _RAM_DD2D_CarData_Yellow
  ld bc, $0000
  ld a, (_RAM_DD2D_CarData_Yellow.EffectsEnabled)
  cp $01
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_618F_ret
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_618F_ret
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteX)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
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
  call LABEL_1B0C_DecrementYPosition
  jp ++

+:
  call LABEL_1B2F_IncrementYPosition
++:
  ld a, $01
  cp c
  jr z, +
  call LABEL_1B50_DecrementXPosition
  jp ++

+:
  call LABEL_1B73_IncrementXPosition
++:
  call LABEL_6571_
  ld a, (_RAM_DE31_CarUnknowns.3.Unknown1)
  ld l, a
  ld a, (_RAM_DE92_EngineSpeed)
  cp l
  jr c, ++
  ld d, a
  ld a, (_RAM_DC4A_Cheat_ExtraLivesAndLeadCar)
  or a
  jr z, +
  ld d, CHEAT_LEAD_CAR_VALUE
+:
  ld a, d
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE31_CarUnknowns.3.Unknown0_Direction), a
++:
  ld a, (_RAM_DE2F_)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE2F_), a
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
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
  ld a, (_RAM_DE92_EngineSpeed)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed)
  sub l
  jr nc, +
  xor $FF
  INC_A
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  call LABEL_2934_BehaviourF_Explode
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed), a
  ld (_RAM_DE92_EngineSpeed), a
_LABEL_618F_ret:
  ret

+++:
  xor a
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  ld ix, _RAM_DD2D_CarData_Yellow
  jp LABEL_2961_

LABEL_619B_:
  ld bc, $0001
  ld a, (_RAM_DCAB_CarData_Green.EffectsEnabled)
  cp $01
  jp nz, LABEL_6295_
  ld a, (_RAM_DCEC_CarData_Blue.EffectsEnabled)
  cp $01
  jp nz, LABEL_6295_
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  or a
  jp nz, LABEL_6295_
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  jp nz, LABEL_6295_
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, LABEL_6295_
  ld a, (_RAM_DCAB_CarData_Green.SpriteX)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
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
  call LABEL_1B0C_DecrementYPosition
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B2F_IncrementYPosition
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B2F_IncrementYPosition
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B0C_DecrementYPosition
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B50_DecrementXPosition
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B73_IncrementXPosition
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B73_IncrementXPosition
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B50_DecrementXPosition
++:
  call LABEL_6582_
  ld a, (_RAM_DE31_CarUnknowns.1.Unknown1)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld (_RAM_DE31_CarUnknowns.1.Unknown0_Direction), a
++:
  ld a, (_RAM_DE31_CarUnknowns.2.Unknown1)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  ld (_RAM_DE31_CarUnknowns.2.Unknown0_Direction), a
++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown11_b_Speed)
  sub l
  jr nc, +
  xor $FF
  INC_A
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_2961_
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown11_b_Speed), a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ret

LABEL_6295_:
  xor a
  ld (_RAM_DE3D_), a
  ret

LABEL_629A_:
  ld bc, $0000
  ld a, (_RAM_DCAB_CarData_Green.EffectsEnabled)
  cp $01
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DD2D_CarData_Yellow.EffectsEnabled)
  cp $01
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_6393_ret
  ld a, (_RAM_DCAB_CarData_Green.SpriteY)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_6393_ret
  ld a, (_RAM_DCAB_CarData_Green.SpriteX)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteX)
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
  call LABEL_1B0C_DecrementYPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B2F_IncrementYPosition
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B2F_IncrementYPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B0C_DecrementYPosition
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B50_DecrementXPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B73_IncrementXPosition
  jp ++

+:
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_1B73_IncrementXPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B50_DecrementXPosition
++:
  call LABEL_6582_
  ld a, (_RAM_DE31_CarUnknowns.1.Unknown1)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
  ld (_RAM_DE31_CarUnknowns.1.Unknown0_Direction), a
++:
  ld a, (_RAM_DE31_CarUnknowns.3.Unknown1)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  ld (_RAM_DE31_CarUnknowns.3.Unknown0_Direction), a
++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown11_b_Speed)
  sub l
  jr nc, +
  xor $FF
  INC_A
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_2961_
  ld ix, _RAM_DCAB_CarData_Green
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown11_b_Speed), a
  ld (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed), a
_LABEL_6393_ret:
  ret

LABEL_6394_:
  ld bc, $0000
  ld a, (_RAM_DCEC_CarData_Blue.EffectsEnabled)
  cp $01
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DD2D_CarData_Yellow.EffectsEnabled)
  cp $01
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_648D_ret
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteY)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  JpNcRet _LABEL_648D_ret
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.SpriteX)
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
  call LABEL_1B0C_DecrementYPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B2F_IncrementYPosition
  jp ++

+:
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B2F_IncrementYPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B0C_DecrementYPosition
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B50_DecrementXPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B73_IncrementXPosition
  jp ++

+:
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_1B73_IncrementXPosition
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_1B50_DecrementXPosition
++:
  call LABEL_6582_
  ld a, (_RAM_DE31_CarUnknowns.2.Unknown1)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, (_RAM_DD2D_CarData_Yellow.Direction)
  ld (_RAM_DE31_CarUnknowns.2.Unknown0_Direction), a
++:
  ld a, (_RAM_DE31_CarUnknowns.3.Unknown1)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  cp l
  jr c, ++
  cp $02
  jr nc, +
  ld a, $02
+:
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld (_RAM_DE31_CarUnknowns.3.Unknown0_Direction), a
++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_5_Warriors
  jr nz, ++
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed)
  sub l
  jr nc, +
  xor $FF
  INC_A
+:
  cp $07
  jr c, ++
  xor a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
  ld ix, _RAM_DCEC_CarData_Blue
  call LABEL_2961_
  ld ix, _RAM_DD2D_CarData_Yellow
  call LABEL_2961_
++:
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed), a
_LABEL_648D_ret:
  ret

LABEL_648E_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ld ix, _RAM_DCAB_CarData_Green
  ld iy, _RAM_DE31_CarUnknowns.1
  call ++
  ld ix, _RAM_DCEC_CarData_Blue
  ld iy, _RAM_DE31_CarUnknowns.2
  call ++
  ld ix, _RAM_DD2D_CarData_Yellow
  ld iy, _RAM_DE31_CarUnknowns.3
  jp ++

+:
  ld ix, _RAM_DCEC_CarData_Blue
  ld iy, _RAM_DE31_CarUnknowns.2
++:
  JumpToPagedFunction PagedFunction_1BCE2_

LABEL_64C9_:
  ld a, (_RAM_DBA4_CarX)
  cp $F3
  jr nc, +
  cp $03
  jr c, +
  ld a, (_RAM_DBA5_CarY)
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
; Most important thing is the last 4 bytes of each engine sound

.dstruct SoundChannel1Init instanceof SoundChannel data 0, 0 ; _RAM_D94C_SoundChannels.1
.dstruct SoundChannel2Init instanceof SoundChannel data 0, 0 ; _RAM_D94C_SoundChannels.2
.dw $0000 ; _RAM_D952_EngineSound1ActualTone
.dw $0000 ; _RAM_D954_EngineSound2ActualTone
.db $00 ; _RAM_D956_Sound_ToneEngineSoundsIndex
.db $00 ; _RAM_D957_Sound_ChopperEngineIndex
.db $00 ; _RAM_D958_Sound_LastAttenuation
.db $00 ; _RAM_D959_Unused
.db $00 ; _RAM_D95A_Sound_IsChopperEngine

; Can't .dstruct if there is a dsb :(
.macro DefineEngineSound args tone, unused, volume, fluctionations1, fluctionations2, fluctionations3, fluctionations4
.dw tone
.db unused, volume, fluctionations1, fluctionations2, fluctionations3, fluctionations4
.endm

  DefineEngineSound LOWEST_PITCH_ENGINE_TONE, $03, MAX_ENGINE_VOLUME, $00 $15 $0B $15 ; _RAM_D95B_EngineSound1
.dstruct SFX_Player1_Init instanceof SFXData data 0, 0, 0, 0, 0, 0 ; _RAM_D963_SFX_Player1
  DefineEngineSound LOWEST_PITCH_ENGINE_TONE, $03, $00, $00 $15 $0B $15 ; _RAM_D96C_EngineSound2
.dstruct SFX_Player2_Init instanceof SFXData data 0, 0, 0, 0, 0, 0 ; _RAM_D974_SFX_Player2

.db SFX_DATA_END ; _RAM_D97D_Sound_SFXNoiseData
.db $07 ; _RAM_D97E_Player1SFX_Unused
.db $08 ; _RAM_D97F_Player2SFX_Unused

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
  ld (_RAM_D963_SFX_Player1.Trigger), a
+:ret

LABEL_6582_:
  ld a, (_RAM_D949_)
  cp $08
  JrCRet +
  xor a
  ld (_RAM_D949_), a
  ld a, SFX_0D
  ld (_RAM_D974_SFX_Player2), a
+:ret

LABEL_6593_:
  ld a, (_RAM_D94A_)
  cp $04
  JrCRet _LABEL_65C2_ret
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet _LABEL_65C2_ret
  ld a, (_RAM_DE92_EngineSpeed)
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
  ld (_RAM_D963_SFX_Player1.Trigger), a
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

LABEL_65D0_BehaviourE_RuffTruxWater:
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet +
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet +
  ld hl, LOWEST_PITCH_ENGINE_TONE
  ld (_RAM_D95B_EngineSound1.Tone), hl
  xor a
  ld (_RAM_D95B_EngineSound1.Volume), a
  ld a, SFX_08
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld a, CarState_3_Falling
  ld (_RAM_DF59_CarState), a
  ld a, $01
  ld (_RAM_DF58_ResettingCarToTrack), a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld a, $03
  ld (_RAM_DE92_EngineSpeed), a
  xor a
  ld (_RAM_DF73_), a
  ld (_RAM_DF00_JumpCurvePosition), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  jp LABEL_71C7_

+:ret

LABEL_6611_Tanks_Red_Trampoline:
  JumpToPagedFunction PagedFunction_37A75_Tanks_Red

LABEL_661C_Tanks_Green_Trampoline:
  JumpToPagedFunction PagedFunction_37C45_Tanks_Green

LABEL_6627_Tanks_Blue_Trampoline:
  JumpToPagedFunction PagedFunction_37C4F_Tanks_Blue

LABEL_6632_Tanks_Yellow_Trampoline:
  JumpToPagedFunction PagedFunction_37C59_Tanks_Yellow

LABEL_663D_InitialisePlugholeTiles:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr z, + ; Only for powerboats...
  ret

+:ld a, :DATA_35708_PlugholeTilesHighBitplanePart1
  ld (PAGING_REGISTER), a
  ld hl, DATA_35708_PlugholeTilesHighBitplanePart1 ; Tile data
  ld de, $5B63        ; Tile $db bitplane 3
  ld bc, _sizeof_DATA_35708_PlugholeTilesHighBitplanePart1 ; $0068 ; 13 tiles
  call _f             ; Emit it
  ld hl, DATA_35770_PlugholeTilesHighBitplanePart2 ; Then some more
  ld de, $5DC3        ; Tile $ee bitplane 3
  ld bc, _sizeof_DATA_35770_PlugholeTilesHighBitplanePart2 ; $0088 ; 17 tiles
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
  add a, 4
  ld e, a
  ld a, d
  adc a, 0
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
  ld hl, DATA_3FC3_HorizontalAmountByDirection
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
  ld hl, DATA_40E5_Sign_Directions_X
  ld a, (_RAM_DE2E_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
  jr z, +
  xor a
  ld (_RAM_DF0D_), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF0D_), a
++:
  ld hl, DATA_3FD3_VerticalAmountByDirection
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
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (_RAM_DE2E_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
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
  SetTileAddressImmediate $194
  ld bc, _sizeof_DATA_35D2D_HeadToHeadHUDTiles / 3 ; $00A0 ; 20 tiles * 8 rows
  ld hl, DATA_35D2D_HeadToHeadHUDTiles
-:
  push bc
    ld b, 3 ; Emit 3bpp tile data
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
  SetTileAddressImmediate SpriteIndex_HUDStart
  ld bc, _sizeof_DATA_30A68_ChallengeHUDTiles / 4 ; $00A0 ; 20 tiles * 8 rows
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
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
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
  ld a, (_RAM_DF58_ResettingCarToTrack)
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
  ld a, (_RAM_DBAD_X_)
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
  ld (_RAM_DEAF_HScrollDelta), a
  jp ++++++

+++++:
  xor a
  ld (_RAM_DEBB_), a
  ld (_RAM_DEAF_HScrollDelta), a
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
  ld a, (_RAM_DBAF_Y_)
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
  ld a, (_RAM_DE8C_InPoolTableHole)
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
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld a, $74
  ld (_RAM_DBA4_CarX), a
  ld (_RAM_DBA6_CarX_Next), a
  ld a, $64
  ld (_RAM_DBA5_CarY), a
  ld (_RAM_DBA7_CarY_Next), a
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
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ; Reset both engine tones
  ld a, 0
  ld (_RAM_D95B_EngineSound1.Volume), a
  ld (_RAM_D96C_EngineSound2.Volume), a
  ld hl, LOWEST_PITCH_ENGINE_TONE
  ld (_RAM_D95B_EngineSound1.Tone), hl
  ld (_RAM_D96C_EngineSound2.Tone), hl
  ld (_RAM_D58A_LowestPitchEngineTone), hl
  ld (_RAM_D58E_OtherCar_EngineTone), hl
  ld (_RAM_D590_Unused_EngineTone), hl
  ld (_RAM_D58C_EngineToneBackup), hl
  ld a, (_RAM_DBA4_CarX)
  ld (_RAM_DF06_), a
  ld a, (_RAM_DBA5_CarY)
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
  jp nz, LABEL_7AC4_HeadToHead_RedWins
  ld a, 1
  ld (_RAM_DF00_JumpCurvePosition), a
  ld a, $78
  ld (_RAM_DF0A_JumpCurveMultiplier), a
  ld a, $03
  ld (_RAM_DF02_JumpCurveStep), a
  ld a, (_RAM_D947_PlayoffWon)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  INC_A
  ld (_RAM_D583_), a
+:
  xor a
  ld (_RAM_DCEC_CarData_Blue.YPosition.Lo), a
  ld (_RAM_DCEC_CarData_Blue.YPosition.Hi), a
  jp LABEL_B2B_HeadToHead_RedWins

++:
  ld a, (_RAM_D5CB_)
  or a
  jp nz, LABEL_7AAF_HeadToHead_BlueWins
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition), a
  ld a, $78
  ld (_RAM_DCEC_CarData_Blue.Unknown36_b_JumpCurveMultiplier), a
  ld a, $03
  ld (_RAM_DCEC_CarData_Blue.Unknown37_b), a
  ld a, (_RAM_D947_PlayoffWon)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  DEC_A
  ld (_RAM_D583_), a
+:
  xor a
  ld (_RAM_DBA5_CarY), a
  jp LABEL_B13_HeadToHead_BlueWins

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
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DF0F_), a
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld (_RAM_DF7F_), a
  ld (_RAM_DB80_), a
  ld (_RAM_DB81_), a
  ld (_RAM_DB82_), a
  ld (_RAM_DB83_), a
  ld (_RAM_DEAF_HScrollDelta), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DB7E_), a
  ld (_RAM_DB7F_), a
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  ld (_RAM_DF79_CurrentBehaviourByte), a
  ld (_RAM_DCEC_CarData_Blue.Unknown28_b), a
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
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
  ld a, CarState_2_Respawning
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_D946_), a
  ld a, SFX_16_Respawn
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld a, $74
  ld (_RAM_DBA4_CarX), a
  ld (_RAM_DBA6_CarX_Next), a
  ld a, $64
  ld (_RAM_DBA5_CarY), a
  ld (_RAM_DBA7_CarY_Next), a
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
  ld (_RAM_DCEC_CarData_Blue.Unknown51_b), a
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown57_b), a
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
  ld (_RAM_DF58_ResettingCarToTrack), a
  ld (_RAM_DF59_CarState), a ; CarState_0_Normal
  ld hl, 500 ; $01F4
  ld (_RAM_D95B_EngineSound1.Tone), hl
  ld (_RAM_D58C_EngineToneBackup), hl
  ld a, MAX_ENGINE_VOLUME
  ld (_RAM_D95B_EngineSound1.Volume), a
  ld a, SFX_0C_LeavePoolTableHole
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld a, (_RAM_DE8D_)
  ld (_RAM_DE90_CarDirection), a
  ld (_RAM_DE91_CarDirectionPrevious), a
  ld a, $01
  ld (_RAM_DF00_JumpCurvePosition), a
  ld a, $38
  ld (_RAM_DF0A_JumpCurveMultiplier), a
  ld a, $05
  ld (_RAM_DF02_JumpCurveStep), a
  ld a, $09
  ld (_RAM_DE92_EngineSpeed), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_6A4F_
  ret

LABEL_6A4F_:
  ld a, $74
  ld (_RAM_DBA4_CarX), a
  ld (_RAM_DBA6_CarX_Next), a
  ld (_RAM_DF06_), a
  ld (_RAM_DF04_CarX_), a
  ld a, $64
  ld (_RAM_DBA5_CarY), a
  ld (_RAM_DBA7_CarY_Next), a
  ld (_RAM_DF07_), a
  ld (_RAM_DF05_CarY_), a
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
  JumpToPagedFunction PagedFunction_36937_

LABEL_6A97_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +++
  ld a, (_RAM_D5C5_)
  cp $02
  jp z, LABEL_6B60_
  ld a, (_RAM_DE8C_InPoolTableHole)
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
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  or a
  jp z, LABEL_6B34_
  ld a, (_RAM_DF5A_CarState3)
  or a
  jp nz, LABEL_6B34_
  ; CarState_0_Normal
  ld a, (_RAM_DCAB_CarData_Green.Unknown51_b)
  or a
  jr nz, +
  ld a, CarState_2_Respawning
  ld (_RAM_DF5A_CarState3), a
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown11_b_Speed), a
  jp LABEL_7295_

+:
  cp $01
  jr z, +
  DEC_A
  ld (_RAM_DCAB_CarData_Green.Unknown51_b), a
  jp LABEL_6B34_

+:
  ld a, (_RAM_DCAB_CarData_Green.Unknown57_b)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DCAB_CarData_Green.Unknown51_b), a
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown57_b), a
  jp LABEL_6B34_

+:
  ld hl, (_RAM_DCAB_CarData_Green.Unknown53_w)
  ld (_RAM_DCAB_CarData_Green.XPosition), hl
  ld hl, (_RAM_DCAB_CarData_Green.Unknown55_w)
  ld (_RAM_DCAB_CarData_Green.YPosition), hl
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack), a
  ld (_RAM_DF5A_CarState3), a ; CarState_0_Normal
  ld a, (_RAM_DCAB_CarData_Green.Unknown52_b)
  ld (_RAM_DCAB_CarData_Green.Unknown12_b_Direction), a
  ld (_RAM_DCAB_CarData_Green.Direction), a
  ld a, $01
  ld (_RAM_DCAB_CarData_Green.Unknown20_b_JumpCurvePosition), a
  ld a, $38
  ld (_RAM_DCAB_CarData_Green.Unknown36_b_JumpCurveMultiplier), a
  ld a, $05
  ld (_RAM_DCAB_CarData_Green.Unknown37_b), a
  ld a, $09
  ld (_RAM_DCAB_CarData_Green.Unknown11_b_Speed), a
LABEL_6B34_:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  jp z, LABEL_6BC2_
  ld a, (_RAM_DF5B_)
  or a
  jp nz, LABEL_6BC2_
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
  or a
  jr nz, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, LABEL_6BC2_
  ld a, $02
  ld (_RAM_DF5B_), a
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  jp LABEL_72CA_

+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, LABEL_6BC2_
LABEL_6B60_:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
  or a
  jr z, LABEL_6BC2_
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
  cp $01
  jr z, +
  DEC_A
  ld (_RAM_DCEC_CarData_Blue.Unknown51_b), a
  jp LABEL_6BC2_

+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown57_b)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DCEC_CarData_Blue.Unknown51_b), a
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown57_b), a
  jp LABEL_6B34_

+:
  ld hl, (_RAM_DCEC_CarData_Blue.Unknown53_w)
  ld (_RAM_DCEC_CarData_Blue), hl
  ld hl, (_RAM_DCEC_CarData_Blue.Unknown55_w)
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack), a
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown52_b)
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
  ld (_RAM_DCEC_CarData_Blue.Direction), a
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition), a
  ld a, $38
  ld (_RAM_DCEC_CarData_Blue.Unknown36_b_JumpCurveMultiplier), a
  ld a, $05
  ld (_RAM_DCEC_CarData_Blue.Unknown37_b), a
  ld a, $09
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, LABEL_6BC2_
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown51_b), a
LABEL_6BC2_:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  or a
  JpZRet +
  ld a, (_RAM_DF5C_)
  or a
  JpNzRet +
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown51_b)
  or a
  jr nz, ++
  ld a, $02
  ld (_RAM_DF5C_), a
  xor a
  ld (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed), a
  jp LABEL_7332_

+:ret

++:
  cp $01
  jr z, +
  DEC_A
  ld (_RAM_DD2D_CarData_Yellow.Unknown51_b), a
  ret

+:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown57_b)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DD2D_CarData_Yellow.Unknown51_b), a
  xor a
  ld (_RAM_DD2D_CarData_Yellow.Unknown57_b), a
  jp LABEL_6B34_

+:
  ld hl, (_RAM_DD2D_CarData_Yellow.Unknown53_w)
  ld (_RAM_DD2D_CarData_Yellow), hl
  ld hl, (_RAM_DD2D_CarData_Yellow.Unknown55_w)
  ld (_RAM_DD2D_CarData_Yellow.YPosition), hl
  xor a
  ld (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack), a
  ld (_RAM_DF5C_), a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown52_b)
  ld (_RAM_DD2D_CarData_Yellow.Unknown12_b_Direction), a
  ld (_RAM_DD2D_CarData_Yellow.Direction), a
  ld a, $01
  ld (_RAM_DD2D_CarData_Yellow.Unknown20_b_JumpCurvePosition), a
  ld a, $38
  ld (_RAM_DD2D_CarData_Yellow.Unknown36_b_JumpCurveMultiplier), a
  ld a, $05
  ld (_RAM_DD2D_CarData_Yellow.Unknown37_b), a
  ld a, $09
  ld (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed), a
  ret

; Data from 6C31 to 6C38 (8 bytes)
DATA_6C31_TrackSkipThresholds:
; one per track type
.db 10 ; SportsCars 
.db 10 ; FourByFour 
.db 10 ; Powerboats 
.db 12 ; TurboWheels
.db  9 ; FormulaOne (19 for head to head)
.db 10 ; Warriors   
.db 10 ; Tanks      
.db  6 ; RuffTrux (5 for first one)
; Maximum shortcut distance (in metatiles)
; Value is the threshold where >= means you explode, so the minimum is 2

LABEL_6C39_CheckTrackSkipThreshold:
  ; Read from table to d
  ld a, (_RAM_DB97_TrackType)
  ld e, a
  ld d, 0
  ld hl, DATA_6C31_TrackSkipThresholds
  add hl, de
  ld a, (hl)
  ld d, a
  
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  jr nz, +
@FormulaOne:
  ; Replace with $13 for head to head
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld d, 19
  jr ++

+:cp TT_7_RuffTrux
  jr nz, ++
@RuffTrux:
  ; Replace with 5 for track index 0
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr nz, ++
  ld d, 5
  
++:
  ; Save value to _RAM_D5E0_TrackSkipThreshold
  ; TODO this could be cached since it never changes?
  ld a, d
  ld (_RAM_D5E0_TrackSkipThreshold), a
  
  ; Load value from _RAM_DF69_ProgressTilesPerHalfLap
  ld a, (_RAM_DF69_ProgressTilesPerHalfLap)
  ld c, a
  
  ; Skip if finished or resetting
  ld a, (_RAM_DF65_HasFinished)
  or a
  jp nz, _Skip__
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  jp nz, _Skip__
  
  ; Store the last position we were on the track
  ld a, (_RAM_DF4F_LastTrackPositionIndex)
  ld l, a
  
  ; Look at where we are now
  ld a, (_RAM_D587_CurrentTrackPositionIndex)
  
  ; $ff means death
  cp $FF
  jp z, _Explode
  
  ; Zero means it's off-track
  or a
  jp nz, _OnTrack
  jp _Skip__

_OnTrack:
  ; We have a track position
  ; We want to convert it to a delta...
  
  ; Is it more or less than last time?
  cp l
  jp z, _Skip__ ; Same -> nothing to do
  jr c, _Less
  ; More -> compute delta
  sub l
  ; Check if the delta is half a lap
  cp c
  jr nc, _HalfLapJump

_CompareDelta:
  ; Compare delta to the threshold
  cp d
  jp c, _BelowThreshold
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp z, _ChallengeModeAndAboveThreshold
  ; Head to head: nothing for F1, else below threshold
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  jp z, _Skip__
  jp _BelowThreshold

_Less:
  ; Did we go backwards, or just past the start line?
  ld h, a
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub l
  add a, h
  cp c
  ; A jump o over half a lap is suspicious, so we fix that up
  jr nc, _HalfLapJump
  jp _CompareDelta

_HalfLapJump:
  ; Our delta is going the "long way round" - convert to the "short way round" and continue
  ld l, a
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub l
  jp _CompareDelta

_ChallengeModeAndAboveThreshold:
  ; For Powerboats, ignore the threshold
  ; (could do this earlier?)
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jp z, _BelowThreshold
  
  ; For all other cars except F1, above threshold => explode
  cp TT_4_FormulaOne
  jr nz, _Explode
  
  ; Formula One
  ; Look up the border/not border flags. If they do not match, we have moved to/from the border and the position has chanegd a lot - not sure when this can happen?
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, ++
  cp 1
  jr z, +
  ld hl, _LABEL_4B10_BorderTrackPositions_Track2
  ld (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer), hl ; Could share this opcode, could also pre-cache the value at track load
  jp +++
+:ld hl, _LABEL_4A80_BorderTrackPositions_Track1
  ld (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer), hl
  jp +++
++:
  ld hl, _LABEL_49FA_BorderTrackPositions_Track0
  ld (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer), hl
+++:
  ; Look up index for this position
  ld a, (_RAM_D587_CurrentTrackPositionIndex)
  ld e, a
  ld d, 0
  ld hl, (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer)
  add hl, de
  ld a, (hl) ; could ld c, (hl)
  ld c, a ; Current value
  ld hl, (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer)
  ld a, (_RAM_DF4F_LastTrackPositionIndex)
  ld e, a
  ld d, 0
  add hl, de
  ld a, (hl) ; New value
  cp c
  jp nz, _Skip__ ; Skip if the values do not match
  ; Fall through if they do match (legitimate track skip)

_Explode:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ; Head to head
  ld a, $01
  ld (_RAM_D5BD_), a
  jp LABEL_29BC_Behaviour1_Fall

+:; Challenge
  ld a, CarState_1_Exploding
  ld (_RAM_DF59_CarState), a
  ld (_RAM_DF58_ResettingCarToTrack), a
  ld hl, LOWEST_PITCH_ENGINE_TONE
  ld (_RAM_D95B_EngineSound1.Tone), hl
  xor a
  ld (_RAM_D95B_EngineSound1.Volume), a
  ld a, SFX_05
  ld (_RAM_D963_SFX_Player1.Trigger), a
  xor a
  ld (_RAM_DE92_EngineSpeed), a
  ld (_RAM_DF00_JumpCurvePosition), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  call LABEL_71C7_
  jp _Skip__

_BelowThreshold:
  ; Compute the delta again, ignoring loop effect
  ; So we get large numbers on crossing the start line
  ; b = backwards flag
  ; a = distance
  ld b, 0
  ld a, (_RAM_D587_CurrentTrackPositionIndex)
  ld l, a
  ld a, (_RAM_DF4F_LastTrackPositionIndex)
  sub l
  jr nc, +
  ld b, 1
  ; Negate
.ifdef UNNECESSARY_CODE
  xor $FF
  INC_A
.else
  neg
.endif
+:
  ld l, a
  
  ; See if the change is large (more than track length - 10)
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub 10
  cp l
  jr nc, _RaceFinished ; Small change
  
  ; Check direction
  ld a, b
  cp $01
  jr z, _CrossedLineBackwards ; Going backwards
  
_CrossedLineForwards:
  ; Set flags?
  xor a
  ld (_RAM_DE51_), a
  ld a, 1 ; could inc a
  ld (_RAM_DE52_), a
  ; Decrement laps remaining counter
  ld a, (_RAM_DF24_LapsRemaining)
  DEC_A
  ld (_RAM_DF24_LapsRemaining), a
.ifdef UNNECESSARY_CODE
  cp 0 ; z flag is already correct from the dec
.endif
  jr z, +

  ; If >0 (i.e not finished yet)
  ; And track 0 (qualifying race)
  ld a, (_RAM_DC55_TrackIndex_Game)
  cp Track_00_QualifyingRace
  jr nz, _RaceFinished
  ; And single-player
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr nz, _RaceFinished
  ; And red car is in first place
  ld a, (_RAM_DF2A_Positions.Red)
  cp 0
  jr nz, _RaceFinished
  
+:; If head to head then end the race now (end or first place in qualifying)
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp nz, LABEL_7AA6_HeadToHead_RaceEnded
  
  ; Else if the car is reversing
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ; And track 0 (qualifying race)
  ld a, (_RAM_DC55_TrackIndex_Game) ; Track 0 = qualifying
  or a
  jr nz, +
  ; Then it's the faster vehicles cheat
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld a, 1
  ld (_RAM_DC50_Cheat_FasterVehicles), a
+:; Either way, end the race now
  ld a, 1
  ld (_RAM_DF65_HasFinished), a
  
  ; ???
  ld a, $F0
  ld (_RAM_DF6A_), a
  
  ; Look up value in this table
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  ld e, a
  ld d, 0
  ld hl, DATA_7172_TrackPositionsByFinishingPlace
  add hl, de
  ld a, (hl)
  ; And set that as the last position index
  ld (_RAM_DF4F_LastTrackPositionIndex), a
  ; Then increment the finished cars count
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  INC_A
  ld (_RAM_DF25_NumberOfCarsFinished), a
  cp $02
  jr nz, _RaceFinished
  ; If it reaches 2 then finish the race
  call LABEL_1CFF_StopChallengeRace
  jp _RaceFinished

_CrossedLineBackwards:
  ld a, (_RAM_DF24_LapsRemaining)
  INC_A
  ld (_RAM_DF24_LapsRemaining), a
  
_RaceFinished:
  ld a, (_RAM_DF65_HasFinished)
  cp $01
  jr z, _Skip__
  call LABEL_1CBD_GetCurrentMetatileIndex ; Only called from here? Seems to calculate what's already in _RAM_DE7D_CurrentLayoutData?
  and LAYOUT_INDEX_MASK
  ; Look up in _RAM_D900_UnknownData
  ld c, a
  ld hl, _RAM_D900_UnknownData
  ld b, 0
  add hl, bc
  ld a, (hl)
  ; Inspect high bit
  and %10000000
  jr nz, +
  call LABEL_1C98_
+:
  ; Copy "current position" to "last position"
  ld a, (_RAM_D587_CurrentTrackPositionIndex)
  ld (_RAM_DF4F_LastTrackPositionIndex), a
  ; Clear this???
  xor a
  ld (_RAM_D589_), a
_Skip__:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JpZRet _LABEL_7171_ret
  ld a, (_RAM_DCAB_CarData_Green.Unknown26_b_HasFinished)
  CP_0
  jp nz, LABEL_6F10_
  ld a, (_RAM_DF50_GreenCarCurrentLapProgress)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.CurrentLapProgress)
  CP_0
  jp z, LABEL_6F10_
  cp l
  jp z, LABEL_6F10_
  ld b, $00
  ld a, (_RAM_DCAB_CarData_Green.CurrentLapProgress)
  ld l, a
  ld a, (_RAM_DF50_GreenCarCurrentLapProgress)
  sub l
  jr nc, +
  ld b, $01
  xor $FF
  INC_A
+:
  ld l, a
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub $0A
  cp l
  jr nc, LABEL_6E79_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  DEC_A
  ld (_RAM_DCAB_CarData_Green.LapsRemaining), a
  CP_0
  jr nz, LABEL_6E79_
  ld a, $01
  ld (_RAM_DCAB_CarData_Green.Unknown26_b_HasFinished), a
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  ld e, a
  ld d, $00
  ld hl, DATA_7172_TrackPositionsByFinishingPlace
  add hl, de
  ld a, (hl)
  ld (_RAM_DF50_GreenCarCurrentLapProgress), a
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  INC_A
  ld (_RAM_DF25_NumberOfCarsFinished), a
  cp $02
  jr nz, LABEL_6E79_
  call LABEL_1CFF_StopChallengeRace
  jp LABEL_6E79_

+:
  ld a, (_RAM_DCAB_CarData_Green.LapsRemaining)
  INC_A
  ld (_RAM_DCAB_CarData_Green.LapsRemaining), a
LABEL_6E79_:
  ld a, (_RAM_DCAB_CarData_Green.Unknown26_b_HasFinished)
  cp $01
  jp z, LABEL_6F10_
  ld a, (_RAM_DCAB_CarData_Green.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld c, a
  ld hl, _RAM_D900_UnknownData
  ld b, $00
  add hl, bc
  ld a, (hl)
  and %10000000 ; High bit
  jr nz, +
  ld a, (_RAM_DCAB_CarData_Green.Unknown29_b)
  cp $0A
  jr z, +
  call LABEL_7176_
+:
  ld a, (_RAM_DCAB_CarData_Green.CurrentLapProgress)
  ld (_RAM_DF50_GreenCarCurrentLapProgress), a
  xor a
  ld (_RAM_DCAB_CarData_Green.Unknown27_b), a
  jp LABEL_6F10_

LABEL_6EA9_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jp z, LABEL_6F6D_
  cp TT_4_FormulaOne
  jr nz, LABEL_6EF3_
  ld a, (_RAM_DB96_TrackIndexForThisType)
  CP_0
  jr z, ++
  cp $01
  jr z, +
  ld hl, _LABEL_4B10_BorderTrackPositions_Track2
  ld (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer), hl
  jp +++
+:ld hl, _LABEL_4A80_BorderTrackPositions_Track1
  ld (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer), hl
  jp +++
++:
  ld hl, _LABEL_49FA_BorderTrackPositions_Track0
  ld (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer), hl
+++:
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLapProgress)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer)
  add hl, de
  ld a, (hl)
  ld c, a
  ld hl, (_RAM_DF53_FormulaOne_BorderTrackPositionsPointer)
  ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
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
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLapProgress)
  cp $FF
  jr z, +
  ld (_RAM_DF51_BlueCarCurrentLapProgress), a
+:
  ld a, $01
  ld (_RAM_D5BE_), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_4DD4_

LABEL_6F10_:
  ld a, (_RAM_D5E0_TrackSkipThreshold)
  ld d, a
  ld a, (_RAM_DF69_ProgressTilesPerHalfLap)
  ld c, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown26_b_HasFinished)
  CP_0
  jp nz, LABEL_6FFF_
  ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLapProgress)
  cp $FF
  jr z, LABEL_6EF3_
  CP_0
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
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub l
  add a, h
  cp c
  jr nc, ++
  jp -

++:
  ld l, a
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub l
  jp -

LABEL_6F6D_:
  ld b, $00
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLapProgress)
  ld l, a
  ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
  sub l
  jr nc, +
  ld b, $01
  xor $FF
  INC_A
+:
  ld l, a
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub $0A
  cp l
  jr nc, LABEL_6FCD_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  DEC_A
  ld (_RAM_DCEC_CarData_Blue.LapsRemaining), a
  CP_0
  jr nz, LABEL_6FCD_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp nz, LABEL_7AA6_HeadToHead_RaceEnded
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.Unknown26_b_HasFinished), a
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  ld e, a
  ld d, $00
  ld hl, DATA_7172_TrackPositionsByFinishingPlace
  add hl, de
  ld a, (hl)
  ld (_RAM_DF51_BlueCarCurrentLapProgress), a
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  INC_A
  ld (_RAM_DF25_NumberOfCarsFinished), a
  cp $02
  jr nz, LABEL_6FCD_
  call LABEL_1CFF_StopChallengeRace
  jp LABEL_6FCD_

+:
  ld a, (_RAM_DCEC_CarData_Blue.LapsRemaining)
  INC_A
  ld (_RAM_DCEC_CarData_Blue.LapsRemaining), a
LABEL_6FCD_:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown26_b_HasFinished)
  cp $01
  jr z, LABEL_6FFF_
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld c, a
  ld hl, _RAM_D900_UnknownData
  ld b, $00
  add hl, bc
  ld a, (hl)
  and %10000000 ; High bit
  jr nz, ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown29_b)
  cp $0A
  jr z, ++
+:
  call LABEL_718B_
++:
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLapProgress)
  ld (_RAM_DF51_BlueCarCurrentLapProgress), a
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown27_b), a
LABEL_6FFF_:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown26_b_HasFinished)
  CP_0
  jp nz, LABEL_709C_
  ld a, (_RAM_DF52_YellowCarCurrentLapProgress)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.CurrentLapProgress)
  CP_0
  jp z, LABEL_709C_
  cp l
  jp z, LABEL_709C_
  ld b, $00
  ld a, (_RAM_DD2D_CarData_Yellow.CurrentLapProgress)
  ld l, a
  ld a, (_RAM_DF52_YellowCarCurrentLapProgress)
  sub l
  jr nc, +
  ld b, $01
  xor $FF
  INC_A
+:
  ld l, a
  ld a, (_RAM_DF68_ProgressTilesPerLap)
  sub $0A
  cp l
  jr nc, LABEL_7070_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  DEC_A
  ld (_RAM_DD2D_CarData_Yellow.LapsRemaining), a
  CP_0
  jr nz, LABEL_7070_
  ld a, $01
  ld (_RAM_DD2D_CarData_Yellow.Unknown26_b_HasFinished), a
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  ld e, a
  ld d, $00
  ld hl, DATA_7172_TrackPositionsByFinishingPlace
  add hl, de
  ld a, (hl)
  ld (_RAM_DF52_YellowCarCurrentLapProgress), a
  ld a, (_RAM_DF25_NumberOfCarsFinished)
  INC_A
  ld (_RAM_DF25_NumberOfCarsFinished), a
  cp $02
  jr nz, LABEL_7070_
  call LABEL_1CFF_StopChallengeRace
  jp LABEL_7070_

+:
  ld a, (_RAM_DD2D_CarData_Yellow.LapsRemaining)
  INC_A
  ld (_RAM_DD2D_CarData_Yellow.LapsRemaining), a
LABEL_7070_:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown26_b_HasFinished)
  cp $01
  jr z, LABEL_709C_
  ld a, (_RAM_DD2D_CarData_Yellow.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld c, a
  ld hl, _RAM_D900_UnknownData
  ld b, $00
  add hl, bc
  ld a, (hl)
  and %10000000 ; High bit
  jr nz, +
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown29_b)
  cp $0A
  jr z, +
  call LABEL_71A0_
+:
  ld a, (_RAM_DD2D_CarData_Yellow.CurrentLapProgress)
  ld (_RAM_DF52_YellowCarCurrentLapProgress), a
  xor a
  ld (_RAM_DD2D_CarData_Yellow.Unknown27_b), a
LABEL_709C_:
  ld a, (_RAM_DE52_)
  CP_0
  jr z, ++
  INC_A
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
  ld (_RAM_D974_SFX_Player2), a
+:
  ld a, (_RAM_DE51_)
  CP_0
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
  CP_0
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
  CP_0
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
  ld a, (_RAM_DF65_HasFinished) ; has finished
  CP_0
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
  ld a, (_RAM_DCAB_CarData_Green.Unknown26_b_HasFinished)
  CP_0
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown26_b_HasFinished)
  CP_0
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
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown26_b_HasFinished)
  CP_0
  jr z, +
  ld a, $9F
  jp ++

+:
  ld a, $97
++:
  ld (hl), a
_LABEL_7171_ret:
  ret

; Indexed by _RAM_DF25_NumberOfCarsFinished
; Value is loaded to the "last track position" state for each car, but not sure if it does anything?
DATA_7172_TrackPositionsByFinishingPlace:
.db $09 $07 $05 $03

LABEL_7176_:
  ld a, (_RAM_DCAB_CarData_Green.XMetatile)
  ld (_RAM_DBB6_), a
  ld a, (_RAM_DCAB_CarData_Green.YMetatile)
  ld (_RAM_DBB7_), a
  ld a, (_RAM_DCAB_CarData_Green.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld (_RAM_DBB8_), a
  ret

LABEL_718B_:
  ld a, (_RAM_DCEC_CarData_Blue.XMetatile)
  ld (_RAM_DBB9_), a
  ld a, (_RAM_DCEC_CarData_Blue.YMetatile)
  ld (_RAM_DBBA_), a
  ld a, (_RAM_DCEC_CarData_Blue.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld (_RAM_DBBB_), a
  ret

LABEL_71A0_:
  ld a, (_RAM_DD2D_CarData_Yellow.XMetatile)
  ld (_RAM_DBBC_), a
  ld a, (_RAM_DD2D_CarData_Yellow.YMetatile)
  ld (_RAM_DBBD_), a
  ld a, (_RAM_DD2D_CarData_Yellow.CurrentLayoutData)
  and LAYOUT_INDEX_MASK
  ld (_RAM_DBBE_), a
  ret

LABEL_71B5_:
  ld a, (_RAM_DBB9_)
  ld (_RAM_DBB1_), a
  ld a, (_RAM_DBBA_)
  ld (_RAM_DBB3_), a
  ld a, (_RAM_DBBB_)
  ld (_RAM_DBB5_LayoutByte_), a
LABEL_71C7_:
  ld a, (_RAM_D945_)
  cp $01
  jr z, +
  cp $02
  jr nz, ++
  ret

+:ld a, (_RAM_DBA4_CarX)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBA9_)
  add hl, de
  ld (_RAM_D941_), hl
  ld a, (_RAM_DBA5_CarY)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DBAB_)
  add hl, de
  ld (_RAM_D943_), hl
++:
  ld a, (_RAM_DBB1_)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D945_)
  or a
  jr z, +
  ld hl, (_RAM_DEF1_Multiply_Result)
  jp +++

+:ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0070 ; GG
  jp ++
+:ld de, $004C ; SMS
++:
  ld hl, (_RAM_DEF1_Multiply_Result)
  or a
  sbc hl, de
+++:
  ld a, (_RAM_DBB5_LayoutByte_)
  call LABEL_7367_AddXOffset_
  ld (_RAM_DBAD_X_), hl
  ld a, (_RAM_DBB3_)
.ifdef UNNECESSARY_CODE
  ld (_RAM_DEF5_Multiply_Parameter1), a
  ld a, 96
.endif
  ld (_RAM_DEF4_Multiply_Parameter2), a
  call LABEL_3100_MultiplyBy96
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D945_)
  or a
  jr z, +
  ld hl, (_RAM_DEF1_Multiply_Result)
  jp +++

+:ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld de, $0060 ; GG
  jp ++
+:ld de, $0038 ; SMS
++:
  ld hl, (_RAM_DEF1_Multiply_Result)
  or a
  sbc hl, de
+++:
  ld a, (_RAM_DBB5_LayoutByte_)
  call LABEL_7393_AddYOffset_
  ld (_RAM_DBAF_Y_), hl
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
  ld (_RAM_DF4F_LastTrackPositionIndex), a
  ld (_RAM_D587_CurrentTrackPositionIndex), a
+:ret

++:
  JumpToPagedFunction PagedFunction_36B29_

LABEL_7295_:
  ld a, (_RAM_DBB6_)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld hl, (_RAM_DEF1_Multiply_Result)
  ld a, (_RAM_DBB8_)
  call LABEL_7367_AddXOffset_
  ld (_RAM_DCAB_CarData_Green.XPosition), hl
  ld a, (_RAM_DBB7_)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld hl, (_RAM_DEF1_Multiply_Result)
  ld a, (_RAM_DBB8_)
  call LABEL_7393_AddYOffset_
  ld (_RAM_DCAB_CarData_Green.YPosition), hl
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
  ld hl, (_RAM_DCEC_CarData_Blue.YPosition)
  ld (_RAM_D943_), hl
++:
  ld a, (_RAM_DBB9_)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld hl, (_RAM_DEF1_Multiply_Result)
  ld a, (_RAM_DBBB_)
  call LABEL_7367_AddXOffset_
  ld (_RAM_DCEC_CarData_Blue.XPosition), hl
  ld a, (_RAM_DBBA_)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld hl, (_RAM_DEF1_Multiply_Result)
  ld a, (_RAM_DBBB_)
  call LABEL_7393_AddYOffset_
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
  ld a, (_RAM_D940_)
  cp $01
  jp z, +
  ret

+:
  JumpToPagedFunction PagedFunction_36BE6_

LABEL_7332_:
  ld a, (_RAM_DBBC_)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld hl, (_RAM_DEF1_Multiply_Result)
  ld a, (_RAM_DBBE_)
  call LABEL_7367_AddXOffset_
  ld (_RAM_DD2D_CarData_Yellow.XPosition), hl
  ld a, (_RAM_DBBD_)
  ld (_RAM_DEF5_Multiply_Parameter1), a
.ifdef UNNECESSARY_CODE
  ld a, 96
  ld (_RAM_DEF4_Multiply_Parameter2), a
.endif
  call LABEL_3100_MultiplyBy96
  ld hl, (_RAM_DEF1_Multiply_Result)
  ld a, (_RAM_DBBE_)
  call LABEL_7393_AddYOffset_
  ld (_RAM_DD2D_CarData_Yellow.YPosition), hl
  ret

LABEL_7367_AddXOffset_:
  push hl
    ; Get metatile index
    and LAYOUT_INDEX_MASK
    ld c, a
    ; Look up data for this metatile
    ld hl, _RAM_D900_UnknownData
    ld b, $00
    add hl, bc
    ld a, (hl)
    ; Get bits 2-4
    and %00011111 ; $1F
    sra a
    sra a
    ; Look up in DATA_2FA7_XOffsets_
    ld c, a
    ld b, $00
    ld hl, DATA_2FA7_XOffsets_
    add hl, bc
    ld a, (hl)
  pop hl
  ; Add value to hl
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrNzRet + ; ret
  ; Subtract 4 for RuffTrux
  ld bc, 4
  or a
  sbc hl, bc
+:ret

LABEL_7393_AddYOffset_:
  push hl
    ; Get metatile index
    and LAYOUT_INDEX_MASK
    ld c, a
    ; Look up offset index
    ld hl, _RAM_D900_UnknownData
    ld b, $00
    add hl, bc
    ld a, (hl)
    and $1F ; Mask to bits %00011100
    sra a
    sra a
    ; Look up offset
    ld c, a
    ld b, $00
    ld hl, DATA_2FAF_YOffsets_
    add hl, bc
    ld a, (hl)
  pop hl
  ; Add it to hl
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  JrNzRet +
  ; Subtract 4 for RuffTrux
  ld bc, 4
  or a
  sbc hl, bc
+:ret

-:
  call LABEL_6C39_CheckTrackSkipThreshold
  CallPagedFunction2 PagedFunction_35F0D_
  TailCall +

LABEL_73D4_UpdateHUDSprites:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, -
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, LABEL_7427_UpdateHUDSprites_RuffTrux
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  jr nz, +
  call LABEL_6C39_CheckTrackSkipThreshold
+:
  ; Emit 8/9 HUD sprites to sprite table RAM
  ld ix, _RAM_DA60_SpriteTableXNs
  ld iy, _RAM_DAE0_SpriteTableYs
  ld bc, 0
-:
  ld hl, _RAM_DF1F_HUDSpriteFlickerCounter
  inc (hl)
  ld a, (hl)
  cp HUD_SPRITE_COUNT
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
  ld e, HUD_SPRITE_COUNT ; Move on to N
  add hl, de
  ld a, (hl)
  ld (ix+1), a
  ld e, HUD_SPRITE_COUNT ; Move on to Y
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
  call LABEL_6C39_CheckTrackSkipThreshold
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

LABEL_746B_Trampoline_RuffTrux_UpdatePerFrameTiles:
  JumpToPagedFunction PagedFunction_36D52_RuffTrux_UpdateTimer

LABEL_7476_PrepareResultsScreen:
  di
  CallPagedFunction2 PagedFunction_2B5D5_SilencePSG
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
  jp EnterMenus

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
  ; Qualifying race only
  ; Set player qualified flag?
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jr z, ++
  xor a
-:ld (_RAM_DBCE_Player1Qualified), a
+:ld a, MenuIndex_5
  jr ++++

++:
  ld a, $01
  jr -

+++:
  ld a, MenuIndex_4_TwoPlayerResults
++++:
  ld (_RAM_DBCD_MenuIndex), a
  jp EnterMenus

LABEL_7519_BackToTitleSreen:
  xor a ; MenuIndex_0_TitleScreen
  ld (_RAM_DBCD_MenuIndex), a
  jp EnterMenus

LABEL_7520_RuffTruxResults:
  ; Next track next time
  ld a, (_RAM_DC39_NextRuffTruxTrack)
  INC_A
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
  jp EnterMenus

LABEL_7545_QualifyingResults:
  ld a, MenuIndex_1_QualificationResults
  ld (_RAM_DBCD_MenuIndex), a
  ld a, (_RAM_DF2A_Positions.Red)
  CP_0 ; Won
  jr z, +
  cp $01 ; Lost
  jr nz, ++
+:
  ld a, $01
-:
  ld (_RAM_DBCE_Player1Qualified), a
  call LABEL_173_LoadEnterMenuTrampolineToRAM
  jp EnterMenus

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
;.ends
;
;.section "Enter game part 1" force
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
  ; Seems to work out OK anyway as we probably load a proper palette soon anyway.
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
;.ends
;
;.section "Track data" force
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
.db TT_8_Choppers 
.db TT_1_FourByFour 
.db TT_2_Powerboats 
.db TT_6_Tanks 
.db TT_4_FormulaOne 
.db TT_0_SportsCars 
.db TT_3_TurboWheels 
.db TT_8_Choppers 
.db TT_5_Warriors 
.db TT_6_Tanks 
.db TT_0_SportsCars 
.db TT_2_Powerboats 
.db TT_8_Choppers 
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
.db 0 ; Choppers
.db 2 ; FourByFour 
.db 3 ; Powerboats 
.db 0 ; Tanks 
.db 1 ; FormulaOne 
.db 1 ; SportsCars 
.db 2 ; TurboWheels
.db 1 ; Choppers
.db 2 ; Warriors 
.db 1 ; Tanks 
.db 2 ; SportsCars 
.db 2 ; Powerboats 
.db 2 ; Choppers
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
.db $08 ; Choppers    0 (8, 8, 8 - unused anyway)
.db $09 ; FourByFour  2 
.db $09 ; Powerboats  3 
.db $07 ; Tanks       0 (7, 7, 7)
.db $0B ; FormulaOne  1 
.db $0B ; SportsCars  1 
.db $0B ; TurboWheels 2 
.db $08 ; Choppers    1 
.db $0A ; Warriors    2 
.db $07 ; Tanks       1 
.db $0B ; SportsCars  2 
.db $09 ; Powerboats  2 
.db $08 ; Choppers    2 
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
.db $12 ; Choppers    0 (12, 12, 12)
.db $12 ; FourByFour  2
.db $10 ; Powerboats  3
.db $06 ; Tanks       0 (6, 6, 6)
.db $0F ; FormulaOne  1
.db $09 ; SportsCars  1
.db $0D ; TurboWheels 2
.db $12 ; Choppers    1
.db $12 ; Warriors    2
.db $06 ; Tanks       1
.db $09 ; SportsCars  2
.db $10 ; Powerboats  2
.db $12 ; Choppers    2
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
.db $12 ; Choppers    0 (12, 12, 12)
.db $12 ; FourByFour  2
.db $12 ; Powerboats  3
.db $06 ; Tanks       0 (6, 6, 6)
.db $1A ; FormulaOne  1
.db $16 ; SportsCars  1
.db $19 ; TurboWheels 2
.db $12 ; Choppers    1
.db $27 ; Warriors    2
.db $06 ; Tanks       1
.db $16 ; SportsCars  2
.db $12 ; Powerboats  2
.db $12 ; Choppers    2
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
.db $06 ; Choppers    0 (6, 6, 6)
.db $06 ; FourByFour  2
.db $07 ; Powerboats  3
.db $09 ; Tanks       0 (9, 9, 9)
.db $06 ; FormulaOne  1
.db $06 ; SportsCars  1
.db $06 ; TurboWheels 2
.db $06 ; Choppers    1
.db $06 ; Warriors    2
.db $09 ; Tanks       1
.db $06 ; SportsCars  2
.db $07 ; Powerboats  2
.db $06 ; Choppers    2
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
.db $06 ; Choppers    0 (6, 6, 6)    (SMS - 2)
.db $07 ; FourByFour  2 
.db $07 ; Powerboats  3 
.db $05 ; Tanks       0 (5, 5, 5)    (SMS - 2)
.db $09 ; FormulaOne  1 
.db $0A ; SportsCars  1 
.db $09 ; TurboWheels 2 
.db $06 ; Choppers    1 
.db $08 ; Warriors    2 
.db $05 ; Tanks       1 
.db $0A ; SportsCars  2 
.db $07 ; Powerboats  2 
.db $06 ; Choppers    2 
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
.db $14 ; Choppers    0 (14, 14, 14)     (SMS + 2)
.db $14 ; FourByFour  2
.db $14 ; Powerboats  3
.db $08 ; Tanks       0 (8, 8, 8)        (SMS + 2)
.db $11 ; FormulaOne  1
.db $09 ; SportsCars  1
.db $0D ; TurboWheels 2
.db $14 ; Choppers    1
.db $17 ; Warriors    2
.db $08 ; Tanks       1
.db $09 ; SportsCars  2
.db $14 ; Powerboats  2
.db $14 ; Choppers    2
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
.db $14 ; $12 ; Choppers    0 (14, 14, 14)     (SMS + 2)
.db $14 ; $12 ; FourByFour  2
.db $14 ; $12 ; Powerboats  3
.db $08 ; $06 ; Tanks       0 (8, 8, 8)        (SMS + 2)
.db $1C ; $1A ; FormulaOne  1
.db $18 ; $16 ; SportsCars  1
.db $1B ; $19 ; TurboWheels 2
.db $14 ; $12 ; Choppers    1
.db $29 ; $27 ; Warriors    2
.db $08 ; $06 ; Tanks       1
.db $18 ; $16 ; SportsCars  2
.db $14 ; $12 ; Powerboats  2
.db $14 ; $12 ; Choppers    2
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
.db $07 ; $06 ; Choppers    0 (7, 7, 7)     (SMS + 1)
.db $07 ; $06 ; FourByFour  2
.db $08 ; $07 ; Powerboats  3
.db $0A ; $09 ; Tanks       0 (a, a, a)     (SMS + 1)
.db $07 ; $06 ; FormulaOne  1
.db $07 ; $06 ; SportsCars  1
.db $07 ; $06 ; TurboWheels 2
.db $07 ; $06 ; Choppers    1
.db $07 ; $06 ; Warriors    2
.db $0A ; $09 ; Tanks       1
.db $07 ; $06 ; SportsCars  2
.db $08 ; $07 ; Powerboats  2
.db $07 ; $06 ; Choppers    2
.db $07 ; $06 ; FormulaOne  2
.db $0A ; $09 ; Tanks       2
.db $07 ; $06 ; SportsCars  2
.db $07 ; $06 ; RuffTrux    0 (7, 7, 7)     (SMS + 1)
.db $07 ; $06 ; RuffTrux    1
.db $07 ; $06 ; RuffTrux    2
;.ends

;.section "Screen control" force

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
  CP_0
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
  CP_0
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
  CP_0
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
  CP_0
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

LABEL_78CE_TilemapUpdate_Horizontal:
  ld a, (_RAM_DECB_TilemapUpdate_HorizontalNeeded)
  or a
  ret z
  ld a, (_RAM_DC54_IsGameGear)
  ld b, 32 ; Tile count (SMS)
  or a
  jr z, +
  ld b, 22 ; (GG)
+:
  ; Clear the flag
  xor a
  ld (_RAM_DECB_TilemapUpdate_HorizontalNeeded), a
  ld de, _RAM_DB22_TilemapUpdate_HorizontalTileNumbers
  ld h, >_RAM_D800_TileHighBytes
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
  ld a, (hl) ; Index into _RAM_D800_TileHighBytes
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

LABEL_7916_TilemapUpdate_Vertical:
  ld a, (_RAM_DECA_TilemapUpdate_VerticalNeeded)
  or a
  ret z
  ld a, (_RAM_DC54_IsGameGear)
  ld b, $1D ; How many tilemap entries to update (SMS)
  or a
  jr z, +
  ld b, $13 ; (GG)
+:
  xor a
  ld (_RAM_DECA_TilemapUpdate_VerticalNeeded), a
  ld de, _RAM_DB42_TilemapUpdate_VerticalTileNumbers
  ld h, >_RAM_D800_TileHighBytes ; $D8
  exx
    ld hl, (_RAM_DEC1_VRAMAddress)
    ld c, PORT_VDP_ADDRESS
    ld b, TILEMAP_ROW_SIZE
    ld d, >(VRAM_WRITE_MASK | SPRITE_TABLE_ADDRESS) ; $7F ; If the high byte of the VRAM address gets here...
    ld e, >(VRAM_WRITE_MASK | NAME_TABLE_ADDRESS) ; $77 ; ...then we wrap it to this
  exx
  ld c, PORT_VDP_DATA
-:
  exx
    ; Set VRAM address
    out (c), l
    out (c), h
    ; Move down one row
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
  ld (_RAM_DECB_TilemapUpdate_HorizontalNeeded), a
  ret

LABEL_79C8_:
  ld a, (ix+CarData.Unknown20_b_JumpCurvePosition)
  CP_0
  jr z, +
  ret

+:
  ld a, (ix+CarData.TankShotSpriteIndex)
  CP_0
  jr z, +
  cp $01
  jr z, ++
  jp LABEL_7A38_

+:
  ld a, (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack)
  CP_0
  JrNzRet +
  ld a, CarState_4_Submerged
  ld (_RAM_DF5A_CarState3), a
  ld a, $01
  ld (_RAM_DCAB_CarData_Green.Unknown46_b_ResettingCarToTrack), a
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  xor a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld (_RAM_DE67_), a
  ld (_RAM_DE31_CarUnknowns.1.Unknown1), a
+:ret

++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  CP_0
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
  ld (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack), a
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  xor a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld (_RAM_DE68_), a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +++
++:ret

+++:
  jp LABEL_4EA0_

LABEL_7A38_:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack)
  CP_0
  JrNzRet +
  ld a, $04
  ld (_RAM_DF5C_), a
  ld a, $01
  ld (_RAM_DD2D_CarData_Yellow.Unknown46_b_ResettingCarToTrack), a
  xor a
  ld (ix+CarData.Unknown11_b_Speed), a
  xor a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  ld (_RAM_DE69_), a
  ld (_RAM_DE31_CarUnknowns.3.Unknown1), a
+:ret

LABEL_7A58_PositionToMetatile_DivMod96:
  ; Divides _RAM_DF20_PositionToMetatile_Parameter by 96
  ; Then computes the remainder from this division too
  
  ; Get parameter (could pass in hl)
  ld hl, (_RAM_DF20_PositionToMetatile_Parameter)
  ; Divide by 32
  rr h
  rr l
  rr h
  rr l
  rr h
  rr l
  rr h
  rr l
  srl l
  ld h, 0
  ; Then divide by 3 to gt a result divided by 96
  ld de, DATA_35B8D_DivideByThree
  add hl, de
  ld a, :DATA_35B8D_DivideByThree
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ; So this is _RAM_DF20_PositionToMetatile_Parameter / 12
  ld (_RAM_DF22_PositionToMetatile_Local_Result), a ; Only used locally

  ; Then multiply by 96 to get the "rounded down" position in de
  sla a
  ld l, a
  ld h, 0
  ld de, DATA_35BED_96TimesTable
  add hl, de
  ld e, (hl)
  inc hl
  ld d, (hl)
  
  ; Restore paging
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  
  ; Subtract this from the original value to get the modulo 96 result
  ld hl, (_RAM_DF20_PositionToMetatile_Parameter)
  or a
  sbc hl, de
  ld a, l
  ld (_RAM_DF21_PositionToMetatile_OffsetInMetatile), a
  
  ; Copy divided by 12 version to the parameter (could return in a)
  ld a, (_RAM_DF22_PositionToMetatile_Local_Result)
  ld (_RAM_DF20_PositionToMetatile_Parameter), a
  ret

LABEL_7A9F_SetBackdropColour:
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_BACKDROP_COLOUR
  out (PORT_VDP_REGISTER), a
  ret

LABEL_7AA6_HeadToHead_RaceEnded:
  ; Head to head race ended
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  cp HEAD_TO_HEAD_TOTAL_POINTS / 2
  jr z, LABEL_7AF2_InitiatePlayoff ; Playoff
  jr nc, LABEL_7AC4_HeadToHead_RedWins ; Red wins
  
LABEL_7AAF_HeadToHead_BlueWins:
  call +
  ; Red car explodes, position 1
  ld a, CarState_1_Exploding
  ld (_RAM_DF2A_Positions.Player1), a
  ld (_RAM_DF59_CarState), a
  ; Blue car position 0
  xor a
  ld (_RAM_DF2A_Positions.Player2), a
  ld (_RAM_D5CB_), a
  jp LABEL_2A08_

LABEL_7AC4_HeadToHead_RedWins:
  call +
  ; Red car position 0
  xor a
  ld (_RAM_DF2A_Positions.Player1), a
  ld (_RAM_D5CB_), a
  ; Blue car explodes, position 1
  ld a, CarState_1_Exploding
  ld (_RAM_DF2A_Positions.Player2), a
  ld (_RAM_DF5B_), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_4E49_

+:ld a, $01
  ld (_RAM_D947_PlayoffWon), a
  ld a, $F0
  ld (_RAM_DF6A_), a
  xor a
  ld (_RAM_DF7F_), a
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld (_RAM_DF81_), a
-:ret

LABEL_7AF2_InitiatePlayoff:
  ld a, (_RAM_D5CB_)
  or a
  JrNzRet -
  ld a, $01
  ld (_RAM_D5CB_), a
  ld (_RAM_D5CC_PlayoffTileLoadFlag), a
  ld a, SFX_14_Playoff
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld (_RAM_D974_SFX_Player2), a
  jp LABEL_B2B_HeadToHead_RedWins

LABEL_7B0B_:
  ld a, (_RAM_D581_OverlayTextScrollAmount)
  cp $A0
  JrNcRet +
  ld a, (_RAM_D5CB_)
  inc a
  ld (_RAM_D5CB_), a
  cp $80
  jr c, +
  call LABEL_B63_UpdateOverlayText
+:ret
.ends

.section "Decompressor" force
LABEL_7B21_Decompress:
.include "decompressor.asm"
.ends

.section "Trampolines 15" force
LABEL_7C67_:
  JumpToPagedFunction PagedFunction_36E6B_

LABEL_7C72_:
  JumpToPagedFunction PagedFunction_36F9E_
.ends

.section "Track loader" force
LABEL_7C7D_LoadTrack:
  call LABEL_3214_BlankSpriteTable

@LoadTileHighBytes
  ; Load tile high bytes
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jr z, @@Powerboats
  cp TT_4_FormulaOne
  jr nz, +

@@FormulaOne:
  ld de, DATA_3116_F1_TileHighBytesRunCompressed
  jp ++
  
+:cp TT_7_RuffTrux
  jr nz, @@OtherCars
  
@@RuffTrux:
  ; all 1 (low 256 are used for sprites)
  ld a, $01
  ld (_RAM_DF1D_TileHighBytes_ConstantValue), a
  jp +
 
@@OtherCars: 
  ; all 0 (no priority bits)
  xor a
  ld (_RAM_DF1D_TileHighBytes_ConstantValue), a
+:; Fill with constant
  ld hl, _RAM_D800_TileHighBytes
  ld bc, 256 ; Byte count
-:ld a, (_RAM_DF1D_TileHighBytes_ConstantValue)
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  jp @LoadTrackTiles
  
@@Powerboats:
  ld de, DATA_313B_Powerboats_TileHighBytesRunCompressed
++:; Fill with compressed data
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
  ; fall through
  
@LoadTrackTiles:
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

@LoadExtraTrackTiles:
  ; Then extra tiles
  call LABEL_663D_InitialisePlugholeTiles

@LoadCarTiles:
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
+:ld hl, $0096                ; $300 bytes = 256 tiles
++:add hl, de
  ld b, h                     ; -> bc
  ld c, l
  ld a, c
  ld (_RAM_DF15_RunCompressedRawDataStartLo), a ; then to RAM
  ld a, b
  ld (_RAM_DF16_RunCompressedRawDataStartHi), a
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  call LABEL_7EBE_DecompressRunCompressed
  call LABEL_7F4E_CarAndShadowSpriteTilesToVRAM

@LoadHUDTiles:
  call LABEL_6704_LoadHUDTiles

@LoadBehaviourData:
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
  CP_0
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
  CallPagedFunction PagedFunction_1BEB1_ChangePoolTableColour

  ; Load "decorator" 1bpp tile data to RAM buffer
  ld hl, DATA_C000_TrackData_SportsCars.DecoratorTiles
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ; Copy to RAM
  ld bc, _sizeof_DATA_F195_SportsCars_DecoratorTiles ; 16 * 8
  ld hl, _RAM_D980_CarDecoratorTileData1bpp
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  ; Next pointer -> 64 bytes to _RAM_D900_UnknownData ("Data", use TBC)
  ld hl, DATA_C000_TrackData_SportsCars.UnknownData
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld bc, _sizeof_DATA_F215_SportsCarsDATA ; $0040
  ld hl, _RAM_D900_UnknownData
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
  SetTileAddressImmediate SpriteIndex_PerVehicleEffects
  ld bc, 11 * 8 ; 11 tiles
-:push bc
    ld b, 3
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
  ld bc, 8 ; 1 tile
-:push bc
    ld b, 3
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
  INC_A
  and $07
  ld (_RAM_DF13_RunCompressed_BitIndex), a
  CP_0              ; Do work until it hits 0, else check if we hit de and loop until we do
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
  CP_0            ; If we get a 0, go get another byte
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
  CallPagedFunction2 PagedFunction_357F8_CarTilesToVRAM

  ; Then load the shadow tiles
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr z, +

  ; Normal cars
  ; VRAM address - tile $1a8 = shadow tile
  SetTileAddressImmediate $1a8
  ld bc, _sizeof_DATA_1C22_TileData_Shadow / 3
  ld hl, DATA_1C22_TileData_Shadow
  call LABEL_7FC9_EmitTileData3bpp

  ; VRAM address - tile $1ac = empty (not for RuffTrux)
  ; Tile is used in-game to "hide" effects when not present - rather than not draw the sprites at all, which would help with the sprite limit (but make flickering dependent on whether effects are happening).
  SetTileAddressImmediate SpriteIndex_Blank
  ld bc, TILE_DATA_SIZE
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

+:; RuffTrux version
  ; We squeeze the shadow into unused spaces in the car sprites
  .macro RuffTruxTile args index, dataPointer
    SetTileAddressImmediate index
    ld bc, 8 ; row count
    ld hl, \2
  .endm
  
  RuffTruxTile SpriteIndex_RuffTrux_Shadow1, DATA_1C22_TileData_Shadow + 3 * 8 * 0 ; Tile 0
  call LABEL_7FC9_EmitTileData3bpp
  RuffTruxTile SpriteIndex_RuffTrux_Shadow2, DATA_1C22_TileData_Shadow + 3 * 8 * 1 ; Tile 1
  call LABEL_7FC9_EmitTileData3bpp
  RuffTruxTile SpriteIndex_RuffTrux_Shadow3, DATA_1C22_TileData_Shadow + 3 * 8 * 2 ; Tile 2
  call LABEL_7FC9_EmitTileData3bpp
  RuffTruxTile SpriteIndex_RuffTrux_Shadow4, DATA_1C22_TileData_Shadow + 3 * 8 * 3 ; Tile 3
  ; fall through and return
LABEL_7FC9_EmitTileData3bpp:
  ; Emits bc rows of 3bpp data to the VDP
-:push bc
    ld b, 3 ; 3 bytes data
    ld c, PORT_VDP_DATA
    otir
    EmitDataToVDPImmediate8 0 ; 1 byte padding
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

.ifdef BLANK_FILL_ORIGINAL
.dsb 5 $FF
.endif

.ends

.BANK 1 SLOT 1
.ORG $0000
.section "Headers" force

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

.dstruct Header instanceof CodemastersHeader data 16 /* pages */ $24 $11 $93 /* Date */ $13 $11 /* Time */ $B5B4 ($10000 - $B5B4) /* Checksum and complement */

.define SEGA_HEADER_REGION_SMS_EXPORT $4
.define SEGA_HEADER_SIZE_256KB $0
/*
.smsheader
  productcode 0,0,0
  version 0
  regioncode SEGA_HEADER_REGION_SMS_EXPORT
  reservedspace $ff, $ff
.endsms
*/

; Data from 7FF0 to 7FFF (16 bytes)
; Sega header
.db "TMR SEGA", $FF, $FF
.dw $E352 ; checksum
.dw $0000 ; Product number
.db $00 ; Version
.db SEGA_HEADER_REGION_SMS_EXPORT << 4 | SEGA_HEADER_SIZE_256KB ; SMS export, 256KB checksum
.ends

.BANK 2
.ORG $0000
.section "Main" force
LABEL_8000_Main:
  di
  ld hl, STACK_TOP
  ld sp, hl
.ifdef GAME_GEAR_CHECKS
  ld a, $00
  ld (_RAM_DC3C_IsGameGear), a
.endif
  call LABEL_AFAE_RamCodeLoader
  ld a, :SplashScreenCompressed ; $0F
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, SplashScreenCompressed ; $AD49 ; Location of compressed data - splash screen implementation, goes up to 3F752, decompresses to 3680 bytes
  CallRamCode LABEL_3B97D_DecompressFromHLToC000 ; loads splash screen code to RAM
  call _RAM_C000_DecompressionTemporaryBuffer ; Splash screen code is here

  call LABEL_AFAE_RamCodeLoader ; The splash screen broke it...
  call JonsSquinkyTennisHook

MenuScreenEntryPoint:
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
  CallRamCodeIfZFlag LABEL_3BB26_Trampoline_Music_Update
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
.ends

.section "Menu screen handlers" force
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
.ends

.ifdef UNNECESSARY_CODE
.section "LABEL_8101_Unknown" force
LABEL_8101_Unknown: ; unreachable?
  ld a,(_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK | BUTTON_2_MASK
  JrNzRet +
  call LABEL_B1F4_Trampoline_Music_Stop
  ld a, $8e ; Page $e, high bit ignored
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode LABEL_3BCEF_Trampoline_Unknown
+:ret
.ends
.endif

.section "Menu screen inititialisation functions" force
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
  call LABEL_B1EC_Trampoline_MusicStart
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "LABEL_81C1_InitialiseSelectGameMenu" force
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
  call LABEL_B1EC_Trampoline_MusicStart
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
.ends

.section "LABEL_8205_InitialiseOnePlayerSelectCharacterMenu" force
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

  call LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
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
  call LABEL_B1EC_Trampoline_MusicStart
  call LABEL_A67C_
  call LABEL_97EA_DrawDriverPortraitColumn
  call LABEL_B3AE_
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "LABEL_8272_" force
LABEL_8272_: ; Qualifying race?
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
  ld a, 8
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, 10
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call LABEL_BCCF_EmitTilemapRectangleSequence

  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_MusicStart
  ld a, :TEXT_VehicleName_Powerboats
  ld (_RAM_D741_RequestedPageIndex), a
  TilemapWriteAddressToHL 8, 22
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof_TEXT_VehicleName_Powerboats
  ld hl, TEXT_VehicleName_Powerboats
  CallRamCode LABEL_3BC6A_EmitText
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  ld hl, 7.36 * 50 ; 7.36s @ 50Hz, 6.13s @ 60Hz
  ld (_RAM_D6AB_MenuTimer), hl
  xor a
  ld (_RAM_D6C1_), a
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "LABEL_82DF_MenuIndex1_QualificationResults_Initialise" force
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
  INC_A
  call LABEL_9F40_LoadPortraitTiles
  TilemapWriteAddressToHL 13, 12
  call LABEL_B8C9_EmitTilemapRectangle_5x6_24
  TilemapWriteAddressToHL 7, 20
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_FailedToQualify
  ld hl, _TEXT_FailedToQualify
  call LABEL_A5B0_EmitToVDP_Text
  ; Music, timer and done
  ld c, Music_08_GameOver
  call LABEL_B1EC_Trampoline_MusicStart
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

_TEXT_FailedToQualify:
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
  INC_A
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
  ld bc, _sizeof__TEXT_Qualified
  ld hl, _TEXT_Qualified
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 9, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_ForChallenge
  ld hl, _TEXT_ForChallenge
  call LABEL_A5B0_EmitToVDP_Text
  ; If it's head to head, overdraw the correct text
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr z, +
  TilemapWriteAddressToHL 7, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_ForHeadToHead
  ld hl, _TEXT_ForHeadToHead
  call LABEL_A5B0_EmitToVDP_Text
+:; Draw lives count
  TilemapWriteAddressToHL 12, 22
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Lives
  ld hl, _TEXT_Lives
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ; Music, timer and done
  ld c, Music_06_Results
  call LABEL_B1EC_Trampoline_MusicStart
  ld hl, 8 * 50 ; 8s @ 50Hz, 6.66666666666667s @ 60Hz
  ld (_RAM_D6AB_MenuTimer), hl
  TailCall LABEL_BB75_ScreenOnAtLineFF

_TEXT_Qualified:      .asc "QUALIFIED"
_TEXT_ForChallenge:   .asc "FOR CHALLENGE!"
_TEXT_ForHeadToHead:  .asc "FOR HEAD TO HEAD !"
_TEXT_Lives:          .asc "LIVES "
.ends

.section "LABEL_841C_" force
LABEL_841C_: ; Who do you want to race?
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
  call LABEL_B1EC_Trampoline_MusicStart
  ld a, (_RAM_DBFB_PortraitCurrentIndex)
  ld (_RAM_D6A2_), a
  ld c, a
  ld b, $00
  call LABEL_97EA_DrawDriverPortraitColumn
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "LABEL_8486_InitialiseDisplayCase" force
LABEL_8486_InitialiseDisplayCase:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, MenuScreen_DisplayCase
  ld (_RAM_D699_MenuScreenIndex), a
  call LABEL_B2BB_DrawMenuScreenBase_WithLine
  ld c, Music_07_Menus
  call LABEL_B1EC_Trampoline_MusicStart
  call LABEL_A787_SetDisplayCaseDataForTrack
  call LABEL_AD42_DrawDisplayCase
  call LABEL_B230_DisplayCase_BlankRuffTrux
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "LABEL_84AA_MenuIndex5_Initialise" force
LABEL_84AA_MenuIndex5_Initialise:
  call LABEL_BB85_ScreenOffAtLineFF
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  jr z, LABEL_84C7_InitialiseOnePlayerTrackIntro
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jp nz, LABEL_8F73_LoseALife
  call LABEL_B269_IncrementOnePlayerCourseIndex
  cp Track_1A_RuffTrux1
  jr nz, LABEL_84C7_InitialiseOnePlayerTrackIntro
  call LABEL_B877_
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "LABEL_84C7_InitialiseOnePlayerTrackIntro" force
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
  call LABEL_B1EC_Trampoline_MusicStart
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "LABEL_8507_MenuIndex2_FourPlayerResults_Initialise" force
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
  ld bc, _sizeof__TEXT_Results
  ld hl, _TEXT_Results
  call LABEL_A5B0_EmitToVDP_Text
  
  ; Reset stuff
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6C1_), a
  
  ; Play music
  ld c, Music_06_Results
  call LABEL_B1EC_Trampoline_MusicStart
  
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
  INC_A
  ld (_RAM_DC0A_WinsInARow), a
  jr ++

+:; Not first place, reset wins counter
  xor a
  ld (_RAM_DC0A_WinsInARow), a
++:
  ; Done
  TailCall LABEL_BB75_ScreenOnAtLineFF

_TEXT_Results: .asc "RESULTS-"
.ends

.section "LABEL_85F4_" force
LABEL_85F4_: ; Player out
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
  INC_A
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
  INC_A
  ld (_RAM_D6B9_), a
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld c, Music_09_PlayerOut
  call LABEL_B1EC_Trampoline_MusicStart
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "LABEL_866C_MenuIndex3_LifeWonOrLost_Initialise" force
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
  jp z, _LABEL_87E9_RuffTruxLost ; LifeWonOrLostMode_RuffTruxLost
  ; Else it's LifeWonOrLostMode_LifeLost
  TilemapWriteAddressToHL 9, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_OneLifeLost
  ld hl, _TEXT_OneLifeLost
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
  ld bc, _sizeof__TEXT_Lives
  ld hl, _TEXT_Lives
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
  call LABEL_B1EC_Trampoline_MusicStart
  ld a, 2.56 * 50 ; 2.56s @ 50Hz, 2.13333333333333s @ 60Hz
  ld (_RAM_D6AB_MenuTimer.Lo), a
  jp LABEL_8826_

_LABEL_8717_GameOver:
  TilemapWriteAddressToHL 9, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_GameOver
  ld hl, _TEXT_GameOver
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Level
  ld hl, _TEXT_Level
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
  call LABEL_B1EC_Trampoline_MusicStart
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
  ld bc, _sizeof__TEXT_YouMadeIt
  ld hl, _TEXT_YouMadeIt
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 10, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_ExtraLife
  ld hl, _TEXT_ExtraLife
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Lives
  ld hl, _TEXT_Lives
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld a, (_RAM_DC09_Lives)
  cp 9
  jr z, +
  ; Increase up to maximum 9
  INC_A
+:
  ld (_RAM_DC09_Lives), a
  call LABEL_A673_SelectLowSpriteTiles
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  ld (_RAM_D701_SpriteN), a
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr nz, +
  ld a, $96 ; SMS
  jp ++
+:ld a, $90 ; GG
++:
  ld (_RAM_D6E1_SpriteX), a
  ld a, $E0
  ld (_RAM_D721_SpriteY), a
  call LABEL_93CE_UpdateSpriteTable
  ld c, Music_06_Results
  call LABEL_B1EC_Trampoline_MusicStart
  ld a, 4 * 50 ; 4s @ 50Hz, 3.33333333333333s @ 60Hz
  ld (_RAM_D6AB_MenuTimer.Lo), a
  jp LABEL_8826_

_LABEL_87E9_RuffTruxLost:
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_NoBonus
  ld hl, _TEXT_NoBonus
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Lives
  ld hl, _TEXT_Lives
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld c, Music_0A_LostLife
  call LABEL_B1EC_Trampoline_MusicStart
  ld a, 2.56 * 50 ; 2.56s @ 50Hz, 2.13333333333333s @ 60Hz
  ld (_RAM_D6AB_MenuTimer.Lo), a
LABEL_8826_:
  xor a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  TailCall LABEL_BB75_ScreenOnAtLineFF

_TEXT_OneLifeLost:  .asc "ONE LIFE LOST!"
_TEXT_GameOver:     .asc "  GAME OVER!  "
_TEXT_Lives:        .asc "LIVES "
_TEXT_Level:        .asc "LEVEL "
_TEXT_YouMadeIt:    .asc "YOU MADE IT!"
_TEXT_ExtraLife:    .asc " EXTRA LIFE "
_TEXT_NoBonus:      .asc "NO  BONUS"
.ends

.section "LABEL_8877_" force
LABEL_8877_: ; RuffTrux start
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
  ld a, 8
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, 10
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

  ld a, :TEXT_Vehicle_Name_Rufftrux
  ld (_RAM_D741_RequestedPageIndex), a
  ld bc, _sizeof_TEXT_Vehicle_Name_Rufftrux
  ld hl, TEXT_Vehicle_Name_Rufftrux
  CallRamCode LABEL_3BC6A_EmitText
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 9, 9
  ld hl, TEXT_TripleWin
  call LABEL_B3A4_EmitBonusRaceText
  TilemapWriteAddressToDE 9, 11
  ld hl, _TEXT_BonusRace
  call LABEL_B3A4_EmitBonusRaceText
  jr ++

+:
  TilemapWriteAddressToDE 9, 10
  ld hl, TEXT_TripleWin
  call LABEL_B3A4_EmitBonusRaceText
  TilemapWriteAddressToDE 9, 12
  ld hl, _TEXT_BonusRace
  call LABEL_B3A4_EmitBonusRaceText
++:
  TilemapWriteAddressToDE 9, 13
  ld hl, _TEXT_BeatTheClock
  call LABEL_B3A4_EmitBonusRaceText
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  ld (_RAM_D6C1_), a
  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_MusicStart
  TailCall LABEL_BB75_ScreenOnAtLineFF

TEXT_TripleWin:     .asc "TRIPLE WIN !!!"
_TEXT_BonusRace:    .asc "  BONUS RACE  "
_TEXT_BeatTheClock: .asc "BEAT THE CLOCK"
.ends

.section "LABEL_8953_InitialiseTwoPlayersMenu" force
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
  call LABEL_B1EC_Trampoline_MusicStart
  TailCall LABEL_BB75_ScreenOnAtLineFF

LABEL_89E2_: ; Choose 2-player game type
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
  call LABEL_B1EC_Trampoline_MusicStart
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
  call LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
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
  ld bc, TILEMAP_ROW_SIZE * 2
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
  ld bc, TILEMAP_ROW_SIZE * 2
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
  ld (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based), a
  ld (_RAM_D6CE_), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jp z, _LABEL_8B89_
  ld a, (_RAM_DC34_IsTournament)
  cp $01
  jr z, +
  call LABEL_A673_SelectLowSpriteTiles
  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_MusicStart
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
  INC_A
  call LABEL_AB68_GetPortraitSource_TrackType
  call LABEL_AB9B_Decompress3bppTiles_Index160
  call LABEL_ABB0_
  ld c, Music_05_RaceStart
  call LABEL_B1EC_Trampoline_MusicStart
  jp LABEL_8B9D_

_LABEL_8B89_:
  ld c, Music_0B_TwoPlayerResult
  call LABEL_B1EC_Trampoline_MusicStart
  call LABEL_A0B4_PrintResultsText
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
.ends

.section "Title screen frame handler" force
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
  cp _sizeof_DATA_B4AB_CheatKeys_CourseSelect - 1 ; full length
  jr z, LABEL_8C23_StartCourseSelect ; cheat 1 entered

  ld a, (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode)
  cp _sizeof_DATA_B4B5_CheatKeys_HardMode - 1 - 3 ; middle length
  jr nz, +
  ld a, 1
  ld (_RAM_DC46_Cheat_HardMode), a
  jr ++
+:cp _sizeof_DATA_B4B5_CheatKeys_HardMode - 1 ; full length
  jr nz, ++
  ld a, 2
  ld (_RAM_DC46_Cheat_HardMode), a
++:
  call LABEL_B505_UpdateHardModeText

  ; Decrement timer
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  or a
  jr z, +
  DEC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
  call LABEL_81C1_InitialiseSelectGameMenu
+++:
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_8C23_StartCourseSelect:
  call LABEL_B1F4_Trampoline_Music_Stop
  call LABEL_B70B_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_8C2C_GoToTwoPlayerMenu:
  call LABEL_B1F4_Trampoline_Music_Stop
  call LABEL_8953_InitialiseTwoPlayersMenu
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Select player count screen frame handler" force
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
  call LABEL_B1F4_Trampoline_Music_Stop
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
  call LABEL_B1F4_Trampoline_Music_Stop
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
.ends

.section "One player select character screen frame handler" force
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
  DEC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
  call LABEL_8272_
LABEL_8D28_MenuScreenHandlerDone:
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Race name screen frame handler" force
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
  INC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Qualify screen frame handler" force
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
  call LABEL_B1F4_Trampoline_Music_Stop
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
  call LABEL_B1F4_Trampoline_Music_Stop
  call LABEL_8114_MenuIndex0_TitleScreen_Initialise
+:
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Who do you want to race? screen frame handler" force
; 8th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8DCC_Handler_MenuScreen_WhoDoYouWantToRace:
  call LABEL_996E_
  call LABEL_95C3_
  call LABEL_9B87_
  call LABEL_9D4E_
  call LABEL_9E70_
  ld a, (_RAM_D6C0_)
  CP_0
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
  call LABEL_B1F4_Trampoline_Music_Stop
  call LABEL_8486_InitialiseDisplayCase
+:
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Display case screen frame handler" force
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
  INC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
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
.ends

.section "One player track intro screen frame handler" force
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
  INC_A
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
  INC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "One player challenge results screen frame handler" force
; 11th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_8EF0_Handler_MenuScreen_OnePlayerChallengeResults:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $A0 ; 3.2s @ 50Hz, 2.66666666666667s @ 60Hz
  jr z, +
  INC_A
  ld (_RAM_D6AB_MenuTimer.Lo), a
  cp $08 ; 0.16s @ 50Hz, 0.133333333333333s @ 60Hz -> first place
  jp z, LABEL_A8ED_TournamentResults_FirstPlace
  cp $28 ; 0.8s @ 50Hz, 0.666666666666667s @ 60Hz -> second place
  jp z, LABEL_A8F2_TournamentResults_SecondPlace
  cp $48 ; 1.44s @ 50Hz, 1.2s @ 60Hz
  jp z, LABEL_A8F7_TournamentResults_ThirdPlace
  cp $68 ; 2.08s @ 50Hz, 1.73333333333333s @ 60Hz
  jp z, LABEL_A8FC_TournamentResults_FourthPlace
LABEL_8F10_:
  call LABEL_A7ED_
  jp LABEL_80FC_EndMenuScreenHandler

+:; Timer expired
  ld a, (_RAM_D6C1_)
  INC_A
  ld (_RAM_D6C1_), a
  cp $F0
  jr z, +
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call LABEL_B1F4_Trampoline_Music_Stop
  ld a, (_RAM_DBCF_LastRacePosition)
  cp $02
  jr nc, LABEL_8F73_LoseALife
  ; 1st or 2nd place
  call LABEL_B269_IncrementOnePlayerCourseIndex
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
  DEC_A
  ld (_RAM_DBD8_TrackIndex_Menus), a
  jp LABEL_8F73_LoseALife

+:
  call LABEL_B877_
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_8F73_LoseALife:
  ld a, (_RAM_DC09_Lives)
  DEC_A
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
.ends

.section "Unknown B screen frame handler" force
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
  INC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
  call LABEL_841C_
++:
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Life won or lost screen frame handler" force
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
  INC_A
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
  DEC_A
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
  DEC_A
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  CP_0
  jr z, +
  cp 1.92 * 50 ; $60 ; Started at 2.56s, so 0.64s minimum on time
  jr nc, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call LABEL_B1F4_Trampoline_Music_Stop
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
.ends

.section "Unknown D screen frame handler" force
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
  INC_A
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
  INC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Various functions 1" force
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
  ld bc, TILEMAP_SIZE / 2 ; 32*28 ; $0380 ; Size of tilemap in words
-:ld a, e
  out (PORT_VDP_DATA), a
  EmitDataToVDPImmediate8 0
  dec bc
  ld a, b
  or c
  jr nz, -
  TailCall LABEL_AF5D_BlankControlsRAM
.ends

.section "Car portraits" force
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
  CP_0
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
  INC_A
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec e
  jr nz, -
  ld a, (_RAM_D68B_TilemapRectangleSequence_Row)
  cp 7 ; Height - 1
  jr z, +
  INC_A
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
  INC_A
  ld (_RAM_D691_TitleScreenSlideshowIndex), a
  ; Skip helicopters
  cp MenuTT_6_Choppers
  jr z, LABEL_91E8_TitleScreenSlideshow_Increment ; -> self
  ; Loop max -> start
  cp _sizeof_DATA_9254_VehiclePortraitOffsets / 2
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
  ld d, 0
  ld e, a
  ld hl, DATA_9254_VehiclePortraitOffsets
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
DATA_9254_VehiclePortraitOffsets:
; Pointers to compressed tile data for the title screen slideshow
; Indexed by a MenuTT_ enum, cycled through by the slideshow
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
DATA_926C_VehiclePortraitPageNumbers:
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
  CP_0 ; Text screen
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerTrackIntro
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
  ld bc, _sizeof_TEXT_VehicleName_Blank ; all are the same width
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
.ends

.section "Hand cursor" force
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
.ends

.section "Menu screen headers" force
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
.ends

.section "Menu screen helpers (needs splitting up)" force
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
  ld e, 32 ; Counter: 32 tiles
-:EmitDataToVDPImmediate16 $1B7 ; Tile index: horizontal bar
  dec e
  jr nz, -
+:ret

LABEL_95C3_:
  ld a, (_RAM_D6B4_)
  cp $01
  JrZRet +
  ld a, (_RAM_D6BA_)
  CP_0
  JrNzRet +
  ld a, (_RAM_D6B0_)
  CP_0
  JrNzRet +
  ; Decrement timer, wait for it to hit 0
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  CP_0
  jr z, ++
  DEC_A
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:ret

++:
  ld a, (_RAM_D6A4_)
  CP_0
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
  CP_0
  jp nz, LABEL_96F6_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, ++
  ; SMS only
  ld a, (_RAM_D6A2_)
  INC_A
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
  INC_A
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
  DEC_A
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
  CP_0
  jr nz, LABEL_96F6_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, ++
  ld a, (_RAM_D6A2_)
  DEC_A
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
  DEC_A
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
  DEC_A
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
  DEC_A
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
  DEC_A
  cp $FF
  jr nz, +
  ld a, $0A
+:
  ld (_RAM_D6AE_), a
  ld a, (_RAM_D6AD_)
  DEC_A
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
  INC_A
  cp $0B
  jr nz, +
  ld a, $00
+:
  ld (_RAM_D6AD_), a
  ld a, (_RAM_D6AE_)
  INC_A
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
  TimesTableLo 0, 8, 11

LABEL_97EA_DrawDriverPortraitColumn:
; Seems to be what it does, not clear how yet
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS
  ld a, :DATA_1B7A7_DriverSelectTilemap_SMS
  ld (_RAM_D741_RequestedPageIndex), a
  TilemapWriteAddressToHL 0, 20
  call LABEL_B35A_VRAMAddressToHL
  ld hl, DATA_1B7A7_DriverSelectTilemap_SMS
  add hl, bc ; Offset into data
  ld e, $C0 ; entry count
  JumpToRamCode LABEL_3BBD8_EmitTilemap_DriverPortraitColumn_SMS

+:
  ld a, :DATA_1B987_DriverSelectTilemap_GG
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, DATA_1B987_DriverSelectTilemap_GG
  add hl, bc
  ld b, $42
  ld c, $0B
  TilemapWriteAddressToDE 6, 16
  JumpToRamCode LABEL_3BBF8_EmitTilemap_DriverPortraitColumn_GG

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
  TimesTableLo x, 8, w
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
  TimesTableLo x, 8, w
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
    TimesTableLo y+8, 8, h-2
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
  jp z, _LABEL_9A0E_Blanks
+:
  ld a, (_RAM_D6AF_FlashingCounter)
  CP_0
  JrZRet _ret
  DEC_A
  ld (_RAM_D6AF_FlashingCounter), a
  ; Flash every 8 frames
  sra a
  sra a
  sra a
  and 1
  jp nz, _LABEL_9A0E_Blanks
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jp z, _GG

_SMS:
  TilemapWriteAddressToHL 4, 16
  call LABEL_B35A_VRAMAddressToHL
  ; Select which text to draw
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

+:ld bc, _sizeof__TEXT_WhoDoYouWantToRace
  ld hl, _TEXT_WhoDoYouWantToRace
  TailCall LABEL_A5B0_EmitToVDP_Text

++:
  ld bc, _sizeof__TEXT_WhoDoYouWantToBe
  ld hl, _TEXT_WhoDoYouWantToBe
  TailCall LABEL_A5B0_EmitToVDP_Text

+++:
  ld bc, _sizeof__TEXT_PushStartToContinue
  ld hl, _TEXT_PushStartToContinue
  call LABEL_A5B0_EmitToVDP_Text
_ret:
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
  EmitDataToVDPImmediate16 MenuTileIndex_Punctuation.QuestionMark
  ld a, (_RAM_DBD3_PlayerPortraitBeingDrawn)
  cp $10
  jr z, +
  TilemapWriteAddressToHL 7, 16
  jp ++
+:TilemapWriteAddressToHL 5, 16
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Handicap
  ld hl, _TEXT_Handicap
  TailCall LABEL_A5B0_EmitToVDP_Text

_LABEL_9A0E_Blanks:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jp z, LABEL_9B18_
  TilemapWriteAddressToHL 4, 16
  call LABEL_B35A_VRAMAddressToHL
  ld bc, 24
  ld hl, TEXT_Blanks_32
  TailCall LABEL_A5B0_EmitToVDP_Text

_TEXT_WhoDoYouWantToBe:     .asc " WHO DO YOU WANT TO BE? "
_TEXT_WhoDoYouWantToRace:   .asc "WHO DO YOU WANT TO RACE?"
_TEXT_PushStartToContinue:  .asc " PUSH START TO CONTINUE "

_GG:
  ld a, (_RAM_D6C0_)
  dec a
  jr z, LABEL_9ABB_
  ld a, (_RAM_D6CA_)
  dec a
  jp z, LABEL_9AE9_
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_WhoDo
  ld hl, _TEXT_WhoDo
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_YouWant
  ld hl, _TEXT_YouWant
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_ToRace
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_WhoDoYouWantToRace
  jr z, +
  jp ++

+:
  ld hl, _TEXT_ToRace
  call LABEL_A5B0_EmitToVDP_Text
  JpRet _ret

++:
  ld hl, _TEXT_ToBe
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_9ABB_:
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Push
  ld hl, _TEXT_Push
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_StartTo
  ld hl, _TEXT_StartTo
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Continue
  ld hl, _TEXT_Continue
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_9AE9_:
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Handicap - 1
  ld hl, _TEXT_Handicap
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
  EmitDataToVDPImmediate16 MenuTileIndex_Punctuation.QuestionMark
  ret

LABEL_9B18_:
  ; Blank text from above
  TilemapWriteAddressToHL 18, 17
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Push
  ld hl, TEXT_Blanks_32
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_StartTo
  ld hl, TEXT_Blanks_32
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Continue
  ld hl, TEXT_Blanks_32
  TailCall LABEL_A5B0_EmitToVDP_Text

_TEXT_WhoDo:    .asc "WHO DO  "
_TEXT_YouWant:  .asc "YOU WANT"
_TEXT_ToBe:     .asc "TO BE ? "
_TEXT_ToRace:   .asc "TO RACE?"
_TEXT_Push:     .asc "PUSH    "
_TEXT_StartTo:  .asc "START TO"
_TEXT_Continue: .asc "CONTINUE"
_TEXT_Handicap: .asc "HANDICAP "

LABEL_9B87_:
  ld a, (_RAM_D6BA_)
  CP_0
  JpNzRet _LABEL_9C5D_ret
  ld a, (_RAM_D6A3_)
  CP_0
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
  CP_0
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
  INC_A
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
  INC_A
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
  CP_0
  JrZRet ++
  DEC_A
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
  CP_0
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
  CP_0
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
  INC_A
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
  INC_A
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
  INC_A
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
  CP_0
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
  CP_0
  JpZRet _LABEL_9F3F_ret
  ld a, (_RAM_D6C4_)
  cp $FF
  jr z, +
  INC_A
  ld c, a
  ld a, (_RAM_D6B9_)
  cp c
  JpZRet _LABEL_9F3F_ret
+:
  ld a, (_RAM_D697_)
  CP_0
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
  DEC_A
  ld e, a
  ld d, $00
  ld hl, _RAM_DBD4_Player1Character
  add hl, de
  ld e, (hl)
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  INC_A
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
  INC_A ; change from happy to sad
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
  DEC_A
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
  ld b, _sizeof_DATA_BD6C_ZeroData
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
.ends

.section "LABEL_9FC5_PrintOrFlashProLabel" force
LABEL_9FC5_PrintOrFlashProLabel:
  ld a, (_RAM_DC3B_IsTrackSelect)
  or a
  jr z, @TwoPLayer  
  jp LABEL_AA02_ ; ???

@TwoPLayer:
  ld bc, $0000 ; Offset 5 rows down for SMS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, TILEMAP_ROW_SIZE * 5 ; $0140
+:
  ld a, (_RAM_D6CE_)
  ; Zero -> always draw blanks
  or a
  jr z, @@Blanks
  ld a, (_RAM_D6AF_FlashingCounter)
  ; Check for %-----1--, i.e. 8 frames in each state
  sra a
  sra a
  and 1
  jp nz, @@Blanks
  ; Zero -> draw "PRO"
  ld a, (_RAM_D6CE_)
  cp TRACK_SELECT_PRO_POSITION1
  jr z, +
  ; Position 2
  TilemapWriteAddressToHL 6, 22
  jp ++
+:; Position 1
  TilemapWriteAddressToHL 7, 22
++:
  add hl, bc
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Pro
  ld hl, _TEXT_Pro
  jp LABEL_A5B0_EmitToVDP_Text

@@Blanks:
  TilemapWriteAddressToHL 6, 22
  add hl, bc
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Pro + 1
  ld hl, TEXT_Blanks_32
  jp LABEL_A5B0_EmitToVDP_Text

_TEXT_Pro:  .asc "PRO"

LABEL_A01C_GetTwoPlayerTrackSelectTrackType:
  ; Get data
  ld c, a
  ld b, 0
  ld hl, _DATA_TwoPlayerTrackSelectTrackTypes
  add hl, bc
  ld a, (hl)
  ld c, a
  ; High two bits go to _RAM_D6CE_
  and %11000000 ; $C0
  ld (_RAM_D6CE_), a
  ld a, c
  ; Return low six bits
  and %00111111 ; $3F
  ret

; Data from A02E to A038 (11 bytes)
_DATA_TwoPlayerTrackSelectTrackTypes:
; Track type info for 2-player track select
; $ff = nothing
; else it's the track type + 1 with the high bit set for "pro"
.define TRACK_SELECT_PRO_POSITION1 $80
.define TRACK_SELECT_PRO_POSITION2 $40
.db $ff
.db TT_0_SportsCars + 1
.db TT_0_SportsCars + 1 + TRACK_SELECT_PRO_POSITION1
.db 3
.db 3 + TRACK_SELECT_PRO_POSITION2
.db 8
.db 7
.db 5
.db 2
.db 4
.db 6

LABEL_A039_:
  ld de, 0 ; Tilemap offset to apply (SMS)
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, TILEMAP_ROW_SIZE ; 1 row down for GG
+:ld a, (_RAM_D6AF_FlashingCounter)
  CP_0
  JrZRet _ret
  DEC_A
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
  ld bc, _sizeof__TEXT_Loser
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr z, +
  ld hl, _TEXT_Loser
  jp ++
+:ld hl, _TEXT_Winner
++:
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 17, 14
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Loser
  ld a, (_RAM_DBD0_LastRacePosition_Player2)
  or a
  jr z, +
  ld hl, _TEXT_Loser
  jp ++
+:ld hl, _TEXT_Winner
++:
  jp LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 8, 14
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0019 ; Covers both strings
  ld hl, TEXT_Blanks_32
  jp LABEL_A5B0_EmitToVDP_Text

_ret:
  ret

_TEXT_Winner: .asc "WINNER!!"
_TEXT_Loser:  .asc " LOSER! "
.ends

.section "LABEL_A0B4_PrintResultsText" force
LABEL_A0B4_PrintResultsText:
  TilemapWriteAddressToHL 12, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Results
  ld hl, _TEXT_Results
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 7, 11
  call LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, +
  ld bc, _sizeof__TEXT_SingleRace
  ld hl, _TEXT_SingleRace
  jp LABEL_A5B0_EmitToVDP_Text

+:jp LABEL_A302_PrintTournamentRaceNumber

_TEXT_Results:    .asc "RESULTS"
_TEXT_SingleRace: .asc "   SINGLE RACE"
.ends

.section "LABEL_A0F0_BlankTilemapRectangle" force
LABEL_A0F0_BlankTilemapRectangle:
  ld bc, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, 5 * TILEMAP_ROW_SIZE ; $0140 - offset to 10, 19 for SMS
+:
  TilemapWriteAddressToHL 10, 14
  add hl, bc
  ld bc, 12 ; Width in tiles
  ld de,  9 ; Height in tiles
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
  ld bc, 12 ; Width in tiles
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
  DEC_A
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
  ld bc, _sizeof__TEXT_Handicap
  ld hl, _TEXT_Handicap
  jp LABEL_A5B0_EmitToVDP_Text

LABEL_A1D3_PrintOrdinary:
  ld bc, _sizeof__TEXT_Ordinary
  ld hl, _TEXT_Ordinary
  jp LABEL_A5B0_EmitToVDP_Text

_TEXT_Handicap: .asc "HANDICAP"
_TEXT_Ordinary: .asc "ORDINARY"
.ends

.section "LABEL_A1EC_" force
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
  DEC_A
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  sra a
  and $01
  jp nz, ++
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, LABEL_A302_PrintTournamentRaceNumber
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +
  ld hl, _TEXT_SelectVehicle
  ld bc, _sizeof__TEXT_SelectVehicle
  jp LABEL_A5B0_EmitToVDP_Text

LABEL_A302_PrintTournamentRaceNumber:
  ld hl, _TEXT_TournamentRace
  ld bc, _sizeof__TEXT_TournamentRace
  call LABEL_A5B0_EmitToVDP_Text
  ; Emit number
  ld a, (_RAM_DC35_TournamentRaceNumber)
  add a, <MenuTileIndex_Font.Digits
  out (PORT_VDP_DATA), a
  ret

+:
  ld hl, _TEXT_SelectATrack
  ld bc, _sizeof__TEXT_SelectATrack
  jp LABEL_A5B0_EmitToVDP_Text

++:
  ld bc, _sizeof__TEXT_SelectATrack + 1
  ld hl, TEXT_Blanks_32
  jp LABEL_A5B0_EmitToVDP_Text

_TEXT_SelectVehicle:  .asc "  SELECT VEHICLE"
_TEXT_TournamentRace: .asc "TOURNAMENT RACE "
_TEXT_SelectATrack:   .asc "  SELECT A TRACK"
.ends

.section "LABEL_A355_PrintWonLostCounterLabels" force
LABEL_A355_PrintWonLostCounterLabels:
.ifdef UNNECESSARY_CODE
  ld a, (_RAM_DBD4_Player1Character)
  ; Divide by 8 to make a character index
  srl a
  srl a
  srl a
  ; Result is not used...
.endif
  
; Repeated code pattern... set VRAM address depending on system and whether _RAM_D699_MenuScreenIndex == MenuScreen_TwoPlayerResult
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
  ld bc, _sizeof__TEXT_Won
  ld hl, _TEXT_Won
  jp LABEL_A5B0_EmitToVDP_Text
+:ld bc, _sizeof__TEXT_W
  ld hl, _TEXT_W
  jp LABEL_A5B0_EmitToVDP_Text
.else
  .ifdef IS_GAME_GEAR
    ld bc, _sizeof__TEXT_W
    ld hl, _TEXT_W
  .else
    ld bc, _sizeof__TEXT_Won
    ld hl, _TEXT_Won
  .endif
  jp LABEL_A5B0_EmitToVDP_Text
.endif


LABEL_A402_PrintLostText:
.ifdef GAME_GEAR_CHECKS
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, _sizeof__TEXT_Lost
  ld hl, _TEXT_Lost
  jp LABEL_A5B0_EmitToVDP_Text
+:ld bc, _sizeof__TEXT_L
  ld hl, _TEXT_L
  jp LABEL_A5B0_EmitToVDP_Text
.else
  .ifdef IS_GAME_GEAR
    ld bc, _sizeof__TEXT_L
    ld hl, _TEXT_L
  .else
    ld bc, _sizeof__TEXT_Lost
    ld hl, _TEXT_Lost
  .endif
  jp LABEL_A5B0_EmitToVDP_Text
.endif

.ifdef GAME_GEAR_CHECKS
_TEXT_W:    .asc "W-"
_TEXT_L:    .asc "L-"
_TEXT_Won:  .asc "WON- "
_TEXT_Lost: .asc "LOST-"
.else
  .ifdef IS_GAME_GEAR
_TEXT_W:    .asc "W-"
_TEXT_L:    .asc "L-"
  .else
_TEXT_Won:  .asc "WON- "
_TEXT_Lost: .asc "LOST-"
  .endif
.endif
.ends


; Unused code (?)
.ifdef UNNECESSARY_CODE
.section "LABEL_A428_DrawPlayerOpponentTypeSelectText" force
LABEL_A428_DrawPlayerOpponentTypeSelectText:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 4, 24 ; SMS
  jr ++
+:TilemapWriteAddressToDE 6, 20 ; GG
++:call LABEL_B361_VRAMAddressToDE
  ld bc, _sizeof__TEXT_Player1
  ld hl, _TEXT_Player1
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, $0046 ; down and right a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Vs
  ld hl, _TEXT_Vs
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, $0080 ; down a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Player2
  ld hl, _TEXT_Player2
  call LABEL_A5B0_EmitToVDP_Text

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 20, 24 ; SMS
  jr ++
+:TilemapWriteAddressToDE 18, 20 ; GG
++:call LABEL_B361_VRAMAddressToDE
  ld bc, _sizeof__TEXT_Player1
  ld hl, _TEXT_Player1
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, TILEMAP_ROW_SIZE * 1 + TILEMAP_ENTRY_SIZE * 3 ; down and right a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Vs
  ld hl, _TEXT_Vs
  call LABEL_A5B0_EmitToVDP_Text

  ld hl, TILEMAP_ROW_SIZE * 2 ; down a bit
  add hl, de
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Computer
  ld hl, _TEXT_Computer
  TailCall LABEL_A5B0_EmitToVDP_Text

_TEXT_Player1:  .asc "PLAYER 1"
_TEXT_Player2:  .asc "PLAYER 2"
_TEXT_Computer: .asc "COMPUTER"
_TEXT_Vs:       .asc "VS"
.endif
.ends

.section "LABEL_A4B7_DrawSelectMenuText" force
LABEL_A4B7_DrawSelectMenuText:
  ; Draw "Select Game"
  TilemapWriteAddressToHL 10, 13
  call _DrawSelectGameText
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerMode
  JrZRet +
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  JrZRet +
  ; For SMS 1/2 player, draw icon text labels
  TilemapWriteAddressToHL 3, 16
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_OnePlayerTwoPlayer
  ld hl, _TEXT_OnePlayerTwoPlayer
  call LABEL_A5B0_EmitToVDP_Text
+:ret

_TEXT_SelectGame:         .asc "SELECT  GAME"
_TEXT_OnePlayerTwoPlayer: .asc "ONE PLAYER      TWO PLAYER"

_DrawSelectGameText:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_SelectGame
  ld hl, _TEXT_SelectGame
  jp LABEL_A5B0_EmitToVDP_Text

LABEL_A50C_DrawOnePlayerSelectGameText:
  TilemapWriteAddressToHL 8, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_OnePlayerGame
  ld hl, _TEXT_OnePlayerGame
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 10, 12
  jp _DrawSelectGameText

_TEXT_OnePlayerGame:  .asc "ONE PLAYER GAME"
.ends

.section "LABEL_A530_DrawChooseGameText" force
LABEL_A530_DrawChooseGameText:
  TilemapWriteAddressToHL 10, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_A574_ChooseGame
  ld hl, _TEXT_A574_ChooseGame
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 3, 26
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_A580_TournamentSingleRace
  ld hl, _TEXT_A580_TournamentSingleRace
  TailCall LABEL_A5B0_EmitToVDP_Text

+:
  TilemapWriteAddressToHL 6, 21
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_A59A_TournamentSingle
  ld hl, _TEXT_A59A_TournamentSingle
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 22, 22
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_A5AC_Race
  ld hl, _TEXT_A5AC_Race
  TailCall LABEL_A5B0_EmitToVDP_Text

_TEXT_A574_ChooseGame:           .asc "CHOOSE GAME!"
_TEXT_A580_TournamentSingleRace: .asc "TOURNAMENT     SINGLE RACE"
_TEXT_A59A_TournamentSingle:     .asc "TOURNAMENT  SINGLE"
_TEXT_A5AC_Race:                 .asc "RACE"
.ends

.section "LABEL_A5B0_EmitToVDP_Text" force
LABEL_A5B0_EmitToVDP_Text:
  ; Emits tile data from hl to the VDP data port, synthesising the high byte as it goes
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  rlc a
  and $01
  out (PORT_VDP_DATA), a
  inc hl
  dec c
  jr nz, -
  ret

LABEL_A5BE_:
  ld a, $30
  ld (_RAM_D6AF_FlashingCounter), a
  ld a, $01
  ld (_RAM_D6C6_), a
  ret
.ends

.section "LABEL_A5C9_PrintPlayerOne" force
LABEL_A5C9_PrintPlayerOne:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 3, 10
  ld bc, _sizeof__TEXT_Player
  ld hl, _TEXT_Player
  jr ++

+:
  TilemapWriteAddressToDE 6, 10
  ld bc, _sizeof__TEXT_Plr
  ld hl, _TEXT_Plr
++:
  call LABEL_B361_VRAMAddressToDE
  call LABEL_A5B0_EmitToVDP_Text

  TilemapWriteAddressToHL 6, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_One
  ld hl, _TEXT_One
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_A5F9_BlankPlayerOne:
  TilemapWriteAddressToHL 3, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Player
  ld hl, TEXT_Blanks_32
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_One
  ld hl, TEXT_Blanks_32
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_A618_PrintPlayerTwo:
  TilemapWriteAddressToDE 23, 10
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, _sizeof__TEXT_Player ; SMS
  ld hl, _TEXT_Player
  jr ++
+:ld bc, _sizeof__TEXT_Plr ; GG
  ld hl, _TEXT_Plr
++:
  call LABEL_B361_VRAMAddressToDE
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 23, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Two
  ld hl, _TEXT_Two
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_A645_BlankPlayerTwo:
  TilemapWriteAddressToHL 23, 10
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Player
  ld hl, TEXT_Blanks_32
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 23, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Two
  ld hl, TEXT_Blanks_32
  TailCall LABEL_A5B0_EmitToVDP_Text

_TEXT_Player: .asc "PLAYER"
_TEXT_Plr:    .asc "PLR"
_TEXT_One:    .asc "ONE"
_TEXT_Two:    .asc "TWO"
.ends

.section "LABEL_A673_SelectLowSpriteTiles" force
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
  CP_0
  JrZRet ++
  DEC_A
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
  ld a, (hl) ; Get first byte
  inc hl
  or a
  jr z, +
  ; If non-zero, draw the name one tile further to the right
  TilemapWriteAddressToDE 9, 20
  call LABEL_B361_VRAMAddressToDE
+:
  ld bc, $0007 ; string length
  call LABEL_A5B0_EmitToVDP_Text
  ld bc, _sizeof__TEXT_IsOut
  ld hl, _TEXT_IsOut
  call LABEL_A5B0_EmitToVDP_Text
++:ret

+++:
  TilemapWriteAddressToHL 7, 20
  call LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, TEXT_Blanks_32
  call LABEL_A5B0_EmitToVDP_Text
  ld bc, _sizeof__TEXT_IsOut
  ld hl, TEXT_Blanks_32
  TailCall LABEL_A5B0_EmitToVDP_Text

TEXT_A6EF_OpponentNames:
; First byte indicates that the name is longer and should be printed
; one tile further to the right if trying to draw it "centred".
; Else they come out "right aligned".
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

_TEXT_IsOut: .asc "IS OUT! "
.ends

.section "LABEL_A74F_" force
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
.ends

.section "LABEL_A778_InitialiseDisplayCaseData" force
LABEL_A778_InitialiseDisplayCaseData:
  ; Set it all to 0
  ld bc, 24
  ld hl, _RAM_DBD9_DisplayCaseData
-:xor a
  ld (hl), a
  inc hl
  dec bc
  ld a, c
  or a
  jr nz, -
  ret

LABEL_A787_SetDisplayCaseDataForTrack:
  ld a, (_RAM_DC0A_WinsInARow)
  cp WINS_IN_A_ROW_FOR_RUFFTRUX
  jr nz, +
  ; RuffTrux
  ld a, $02 ; -> flashing
  ld (_RAM_DBD9_DisplayCaseData + 15), a
  ld (_RAM_DBD9_DisplayCaseData + 19), a
  ld (_RAM_DBD9_DisplayCaseData + 23), a
  ret

+:; Not RuffTrux
  ; Look up the pointer into _RAM_DBD9_DisplayCaseData for this track
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  DEC_A
  sla a
  ld c, a
  ld b, $00
  ld hl, DATA_A7BB_CourseIndexToDisplayCaseDataPointer
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ; Set it to 2 -> flashing?
  ld a, $02
  ld (de), a
  ; And save the pointer
  ld (_RAM_DBF9_CurrentDisplayCaseDataPointer), de
  ret

LABEL_A7B3_:
  ; Set the display case data to 1 = done?
  ld de, (_RAM_DBF9_CurrentDisplayCaseDataPointer)
  ld a, $01
  ld (de), a
  ret

; Data from A7BB to A7EC (50 bytes)
; Display case locations per track index (except qualifying race)
DATA_A7BB_CourseIndexToDisplayCaseDataPointer:
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
  CP_0
  JrZRet +++
  DEC_A
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
  ld hl, _TEXT_QualifyFailed
  add hl, bc
  ld bc, 7 ; length
  call LABEL_A5B0_EmitToVDP_Text
+++:ret

++++:
  call LABEL_A859_SetTilemapLocationForLastRacePosition
  ld hl, TEXT_Blanks_32
  ld bc, 7
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
_TEXT_QualifyFailed:
.asc "QUALIFY", $FF
.asc "FAILED "
.ends

.section "LABEL_A859_SetTilemapLocationForLastRacePosition" force
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

LABEL_A8ED_TournamentResults_FirstPlace:
  ld c, $00
  jp +

LABEL_A8F2_TournamentResults_SecondPlace:
  ld c, $01
  jp +

LABEL_A8F7_TournamentResults_ThirdPlace:
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
  call LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
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
  call LABEL_B377_ConfigureTilemapRect_5x6_rega
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
  call LABEL_B377_ConfigureTilemapRect_5x6_rega
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
  call LABEL_B377_ConfigureTilemapRect_5x6_rega
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
  CP_0
  JrZRet _LABEL_AA5D_ret ; ret
  DEC_A
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, LABEL_AA8B_BlankTwoRows
LABEL_AA02_:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  DEC_A
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
  ld bc, _sizeof_DATA_FDC1_TrackName_00 ; all are the same length except the final race
  TilemapWriteAddressToDE 2, 16
  jr ++

+:TilemapWriteAddressToDE 6, 13
  call LABEL_B361_VRAMAddressToDE
  ld bc, _sizeof_DATA_FDC1_TrackName_00
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
  ld bc, _sizeof_DATA_FFA2_TrackName_24
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

LABEL_AA8B_BlankTwoRows:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 0, 15
  jr ++
+:TilemapWriteAddressToHL 0, 12
++:
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof_TEXT_Blanks_32
  ld hl, TEXT_Blanks_32
  call LABEL_A5B0_EmitToVDP_Text
  ld bc, _sizeof_TEXT_Blanks_32
  ld hl, TEXT_Blanks_32
  jp LABEL_A5B0_EmitToVDP_Text

TEXT_Blanks_32: .asc "                                "

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
.db 0,0 ; Chopper track
.asc "10"
.asc "11"
.asc "12"
.asc "13"
.asc "14"
.asc "15"
.db 0,0 ; Chopper track
.asc "16"
.asc "17"
.asc "18"
.asc "19"
.db 0,0 ; Chopper track
.asc "20"
.asc "21"
.asc "22"
.asc "23"
.asc "24"
.asc "25"


; Data from AB3E to AB4C (15 bytes)
DATA_AB3E_CourseSelect_TrackTypes:
; Maps the course select index to a (menu) track type
.db MenuTT_4_FourByFour MenuTT_1_SportsCars MenuTT_5_Warriors MenuTT_7_TurboWheels MenuTT_4_FourByFour MenuTT_3_FormulaOne MenuTT_5_Warriors MenuTT_2_Powerboats MenuTT_7_TurboWheels MenuTT_6_Choppers MenuTT_4_FourByFour MenuTT_2_Powerboats MenuTT_8_Tanks MenuTT_3_FormulaOne MenuTT_1_SportsCars MenuTT_7_TurboWheels MenuTT_6_Choppers MenuTT_5_Warriors MenuTT_8_Tanks MenuTT_1_SportsCars MenuTT_2_Powerboats MenuTT_6_Choppers MenuTT_3_FormulaOne MenuTT_8_Tanks MenuTT_1_SportsCars MenuTT_9_RuffTrux MenuTT_9_RuffTrux MenuTT_9_RuffTrux MenuTT_2_Powerboats

LABEL_AB5B_GetPortraitSource_CourseSelect:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  DEC_A
  ld c, a
  ld b, 0
  ld hl, DATA_AB3E_CourseSelect_TrackTypes
  add hl, bc
  ld a, (hl)
  ; Fall through

LABEL_AB68_GetPortraitSource_TrackType:
  ld (_RAM_D691_TitleScreenSlideshowIndex), a
  sla a
  ld de, DATA_9254_VehiclePortraitOffsets
  add a, e
  ld e, a
  ld a, d
  adc a, 0
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
  INC_A
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec de
  ld a, d
  or e
  jr nz, -
  ld a, (_RAM_D68B_TilemapRectangleSequence_Row)
  cp $07 ; height - 1
  jr z, +
  INC_A
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
  call LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
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
  call LABEL_B377_ConfigureTilemapRect_5x6_rega
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
  call LABEL_B377_ConfigureTilemapRect_5x6_rega
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
  call LABEL_B377_ConfigureTilemapRect_5x6_rega
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
  TilemapWriteAddressData  6,  5
  TilemapWriteAddressData 11,  5
  TilemapWriteAddressData 16,  5
  TilemapWriteAddressData 21,  5
  TilemapWriteAddressData  6,  8
  TilemapWriteAddressData 11,  8
  TilemapWriteAddressData 16,  8
  TilemapWriteAddressData 21,  8
  TilemapWriteAddressData  6, 11
  TilemapWriteAddressData 11, 11
  TilemapWriteAddressData 16, 11
  TilemapWriteAddressData 21, 11
  TilemapWriteAddressData  6, 14
  TilemapWriteAddressData 11, 14
  TilemapWriteAddressData 16, 14
  TilemapWriteAddressData 21, 14
  TilemapWriteAddressData  6, 17
  TilemapWriteAddressData 11, 17
  TilemapWriteAddressData 16, 17
  TilemapWriteAddressData 21, 17
  TilemapWriteAddressData  6, 20
  TilemapWriteAddressData 11, 20
  TilemapWriteAddressData 16, 20
  TilemapWriteAddressData 21, 20

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
  
  ld bc, 3 / 8 * TILE_WIDTH * TILE_HEIGHT * 25 ; $0258 ; Skip 25 tiles @ 3bpp
  add hl, bc
  ld e, TILE_HEIGHT * 5 ; $28 ; Emit 5 tiles * 8 rows
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
  call LABEL_B1EC_Trampoline_MusicStart
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
  ld hl, _TEXT_Link
  call LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  add a, $1B
  out (PORT_VDP_DATA), a
  ret

LABEL_AF92_BlankTitleScreenCheatMessage:
  TilemapWriteAddressToHL 13, 13
  call LABEL_B35A_VRAMAddressToHL
  ld c, $06
  ld hl, TEXT_Blanks_32
  jp LABEL_A5B0_EmitToVDP_Text

_TEXT_Link: .asc "LINK "

LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL:
  call LABEL_B35A_VRAMAddressToHL
LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM:
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  JumpToRamCode LABEL_3BB31_Emit3bppTileDataToVRAM
.ends

.section "RAM code loader" force
LABEL_AFAE_RamCodeLoader:
  ; Trampoline for calling paging code
  ld hl, _LABEL_AFBC_RamCodeLoaderSource  ; Loading Code into RAM
  ld de, _RAM_D640_RamCodeLoader
  ld bc, _sizeof__LABEL_AFBC_RamCodeLoaderSource
  ldir
  jp _RAM_D640_RamCodeLoader  ; Code is loaded from +

; Executed in RAM at d640
_LABEL_AFBC_RamCodeLoaderSource:
+:ld a, :LABEL_3B971_RamCodeLoaderStage2
  ld (_RAM_D741_RequestedPageIndex), a
  ld (PAGING_REGISTER), a ; page in and call
  call LABEL_3B971_RamCodeLoaderStage2
  ld a, :LABEL_AFAE_RamCodeLoader ; $02 ; restore paging
  ld (PAGING_REGISTER), a
  ret
.ends

.section "One player menu initialisation" force
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
  call LABEL_B1EC_Trampoline_MusicStart
  xor a
  ld (_RAM_D6C7_IsTwoPlayer), a
  call LABEL_BB95_LoadSelectMenuGraphics
  call LABEL_BC0C_LoadSelectMenuTilemaps
  call LABEL_PatchGraphicsForVsCPU
  call LABEL_A50C_DrawOnePlayerSelectGameText
  call LABEL_9317_InitialiseHandSprites
  xor a
  ld (_RAM_D6A0_MenuSelection), a
  ld (_RAM_D6AB_MenuTimer.Lo), a
  ld (_RAM_D6AB_MenuTimer.Hi), a
  call LABEL_A673_SelectLowSpriteTiles
  TailCall LABEL_BB75_ScreenOnAtLineFF
.ends

.section "Jon's Squinky Tennis hook" force
JonsSquinkyTennisHook:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  ret z
  ; If a GG...
  ; ...and Start is held...
  in a, (PORT_GG_START)
  add a, a ; start is bit 7, 1 = not pressed
  ret c
  ld a, :JonsSquinkyTennisCompressed ;$0F
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, JonsSquinkyTennisCompressed ; $B753 Up to $3ff78, compressed code (Jon's Squinky Tennis, 5923 bytes)
  CallRamCode LABEL_3B97D_DecompressFromHLToC000
  jp _RAM_C000_DecompressionTemporaryBuffer ; $C000
.ends

.section "Patch graphics to 'vs CPU'" force
LABEL_PatchGraphicsForVsCPU:
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
.ends

.section "One player mode screen initialisation" force
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
  call LABEL_B1F4_Trampoline_Music_Stop
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
.ends

.section "Two player select character screen initialisation" force
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
  INC_A
  ld (_RAM_D6AB_MenuTimer.Hi), a
  cp $30 ; 0.96s @ 50Hz, 0.8s @ 60Hz
  jr z, +
  dec a
  call z, LABEL_A645_BlankPlayerTwo
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B1F4_Trampoline_Music_Stop
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
  INC_A
  ld (_RAM_D6CD_), a
  dec a
  jr z, +
  dec a
  jr z, ++
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_A645_BlankPlayerTwo
  jp LABEL_80FC_EndMenuScreenHandler

++:
  call LABEL_A5C9_PrintPlayerOne
  jp LABEL_80FC_EndMenuScreenHandler

LABEL_B132_:
  ld a, (_RAM_D6CD_)
  cp $02
  jp z, LABEL_80FC_EndMenuScreenHandler
  INC_A
  ld (_RAM_D6CD_), a
  dec a
  jr z, +
  dec a
  jr z, ++
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_A5F9_BlankPlayerOne
  jp LABEL_80FC_EndMenuScreenHandler

++:
  call LABEL_A618_PrintPlayerTwo
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
  call LABEL_B389_GetNoText
  ld bc, _sizeof_TEXT_No_SMS
  call LABEL_A5B0_EmitToVDP_Text
  jp LABEL_80FC_EndMenuScreenHandler

_Right:
  ld a, $01
  ld (_RAM_D6CB_MenuScreenState), a
  call LABEL_B389_GetNoText ; also gets the location
  ld hl, _TEXT_Yes
  ld bc, _sizeof__TEXT_Yes
  call LABEL_A5B0_EmitToVDP_Text
  jp LABEL_80FC_EndMenuScreenHandler

TEXT_No_SMS:  .asc "-NO- "
TEXT_No_GG:   .asc " -NO-"
_TEXT_Yes:    .asc "-YES-"
.ends

.section "Music control trampolines" force
LABEL_B1EC_Trampoline_MusicStart:
; c = music index (1-based)
  ld a, :Music_Start
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode LABEL_3BCDC_Trampoline2_MusicStart

LABEL_B1F4_Trampoline_Music_Stop:
  ld a, :Music_Stop
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode LABEL_3BCE6_Trampoline2_Music_Stop
.ends

.section "Track select index to track index" force
LABEL_B1FC_TwoPlayerTrackSelect_GetIndex:
  ld a, (_RAM_DC34_IsTournament)
  dec a
  JrZRet +
  ld hl, TwoPlayerTrackSelectIndices
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based)
  DEC_A ; Make 0-based
-:
  ld e, a
  ld d, 0
  add hl, de
  ld a, (hl)
  ld (_RAM_DBD8_TrackIndex_Menus), a
+:ret

LABEL_B213_GearToGearTrackSelect_GetIndex:
  ld hl, GearToGearTrackSelectIndices
  jp -

TwoPlayerTrackSelectIndices:
.db Track_02_DesktopDropOff
.db Track_14_CrayonCanyons
.db Track_0E_PitfallPockets
.db Track_17_ChalkDustChicane
.db Track_0D_BedroomBattlefield
.db Track_04_SandyStraights
.db Track_07_HandymansCurve
.db Track_15_SoapLakeCity
.db Track_05_OatmealInOverdrive

; Gear to Gear track select options. Nearly the same as SMS, except:
; - pro ones are gone
; - qualifying race is in (!)
; - order is changed
GearToGearTrackSelectIndices:
.db Track_02_DesktopDropOff
.db Track_15_SoapLakeCity
.db Track_0E_PitfallPockets
.db Track_05_OatmealInOverdrive
.db Track_07_HandymansCurve
.db Track_00_QualifyingRace
.db Track_04_SandyStraights
.db Track_0D_BedroomBattlefield
.ends

.section "RuffTrux display case helpers" force
LABEL_B22A_DisplayCase_BlankRuffTrux:
  call LABEL_B230_DisplayCase_BlankRuffTrux
  jp LABEL_8E54_

LABEL_B230_DisplayCase_BlankRuffTrux:
  ; Blank out three "virtual" cars for the 3x height slot
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
.ends

.section "Course index helpers" force
LABEL_B269_IncrementOnePlayerCourseIndex: ; e.g. when you win
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  INC_A
  ld (_RAM_DBD8_TrackIndex_Menus), a
  ; Skip helicopters by recursing (!)
  cp Track_0A_ThePottedPassage
  jr z, LABEL_B269_IncrementOnePlayerCourseIndex
  cp Track_11_TheShrubberyTwist
  jr z, LABEL_B269_IncrementOnePlayerCourseIndex
  cp Track_16_TheLeafyBends
  jr z, LABEL_B269_IncrementOnePlayerCourseIndex
  ; Does not attempt to wrap
  ret

LABEL_B27E_DecrementCourseSelectIndex:
  ld a, (_RAM_DBD8_TrackIndex_Menus)
  DEC_A
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
  INC_A
  cp Track_1C_RuffTrux3+1
  jr nz, +
  ; Wrap from $1c to $01
  ld a, 1
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
.ends

.section "More menu screen helpers" force
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

LABEL_B375_ConfigureTilemapRect_5x6_Portrait1:
  ld a, $24
LABEL_B377_ConfigureTilemapRect_5x6_rega:
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $05
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  ret

LABEL_B389_GetNoText:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 22, 16 ; SMS
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_No_SMS
  JrRet ++
+:TilemapWriteAddressToHL 21, 21 ; GG
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_No_GG
++:ret

LABEL_B3A4_EmitBonusRaceText:
  call LABEL_B361_VRAMAddressToDE
  ld bc, _sizeof_TEXT_TripleWin
  TailCall LABEL_A5B0_EmitToVDP_Text

LABEL_B3AE_:
  ld a, $06 ; Counter to draw 6 portraits
  ld (_RAM_D6AB_MenuTimer.Lo), a ; Using this as a counter now
  ld a, (_RAM_D6AD_)
  DEC_A
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
  DEC_A
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
  ld hl, DATA_926C_VehiclePortraitPageNumbers
  add hl, de
  ld a, (hl)
  ld (_RAM_D741_RequestedPageIndex), a
  ret
.ends

.section "Title screen cheat checks" force
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
  call _CheckForCheatCode_CourseSelect
  call _CheckForCheatCode_HardMode
++:ret

DATA_B4AB_CheatKeys_CourseSelect:
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

DATA_B4B5_CheatKeys_HardMode:
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

_CheckForCheatCode_CourseSelect:
  ld a, (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect) ; Get index of next button press
  ld c, a
  ld b, 0
  ld hl, DATA_B4AB_CheatKeys_CourseSelect  ; Look up the button press
  add hl, bc
  ld a, (hl)
  cp e  ; Compare to what we have
  jr nz, +
  ld a, (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect) ; If it matches, increase the index
  INC_A
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ld a, 1
  ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
  ret

+:; If no match, reset the counter
  xor a
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ret

_CheckForCheatCode_HardMode:
  ld a, (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode) ; Get index of next button press
  ld c, a
  ld b, 0
  ld hl, DATA_B4B5_CheatKeys_HardMode ; Look up the button press
  add hl, bc
  ld a, (hl)
  or a
  jr z, +
  cp e
  jr nz, +
  ld a, (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode) ; If it matches, increase the index
  INC_A
  ld (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode), a
  ld a, 1
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
  ld c, _sizeof__TEXT_HardMode
  ld hl, _TEXT_HardMode
  jp LABEL_A5B0_EmitToVDP_Text ; and ret

++:
  ld c, _sizeof__TEXT_RockHardMode
  ld hl, _TEXT_RockHardMode
  jp LABEL_A5B0_EmitToVDP_Text ; and ret

+++:
-:
  ld c, $0E
  ld hl, TEXT_Blanks_32
  jp LABEL_A5B0_EmitToVDP_Text ; and ret

_TEXT_HardMode:     .asc "  HARD  MODE"
_TEXT_RockHardMode: .asc "ROCK HARD MODE"

.ifdef UNNECESSARY_CODE
_Unused_ResetTitleScreenCheats:
  ; Turns off the cheats and blanks any text shown
  xor a
  ld (_RAM_DC46_Cheat_HardMode), a
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ld (_RAM_DC45_TitleScreenCheatCodeCounter_HardMode), a
  TilemapWriteAddressToHL 9, 13
  call LABEL_B35A_VRAMAddressToHL
  jr -
.endif
.ends

.section "Track select screen frame handler" force
; 17th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_B56D_Handler_MenuScreen_TrackSelect:
  call LABEL_B9C4_CycleGearToGearTrackSelectIndex
  call LABEL_A2AA_PrintOrFlashMenuScreenText
  call LABEL_9FC5_PrintOrFlashProLabel
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
  INC_A
  ld (_RAM_D6AB_MenuTimer.Lo), a
+:
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp 3.68 * 50 ; $B8 ; 3.68s @ 50Hz, 3.06666666666667s @ 60Hz
  jr z, ++++
  cp 1.28 * 50 ; $40 ; 1.28s @ 50Hz, 1.06666666666667s @ 60Hz
  jr nc, +++
  jp LABEL_B618_

++:
  ld a, (_RAM_D693_SlowLoadSlideshowTiles)
  cp $01
  jp z, LABEL_B6AB_
  CP_0
  jp nz, LABEL_A129_
  call LABEL_B98E_GetMenuControls
  ld a, (_RAM_D697_)
  cp $01
  jr z, LABEL_B623_
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_L_MASK ; $04
  jp z, LABEL_B640_TrackSelect_Previous
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_R_MASK ; $08
  jp z, LABEL_B666_TrackSelect_Next
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based)
  CP_0
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
  INC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
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

LABEL_B640_TrackSelect_Previous:
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, @OnePlayer
  
@TwoPLayer:
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based)
  DEC_A
  cp -1 ; Left at start
  jr z, +
  or a ; Or 1 -> 0
  jr nz, ++
+:ld a, _sizeof_TwoPlayerTrackSelectIndices ; max index
++:
  ld (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based), a
  jp ++++

@OnePlayer:
  call LABEL_B27E_DecrementCourseSelectIndex
  call LABEL_AB5B_GetPortraitSource_CourseSelect
  call LABEL_AA8B_BlankTwoRows
  jp +++++

LABEL_B666_TrackSelect_Next:
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, @OnePlayer
  
@TwoPlayer:
  ld a, (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based)
  INC_A
  cp _sizeof_TwoPlayerTrackSelectIndices + 1 ; past end?
  jr nz, +
  ld a, 1
+:ld (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based), a
  jp ++++

@OnePlayer:
  call LABEL_B298_IncrementCourseSelectIndex
  call LABEL_AB5B_GetPortraitSource_CourseSelect
  call LABEL_AA8B_BlankTwoRows
  jp +++++

_TrackSelect_TwoPlayerUpdate:
++++:
  call LABEL_A01C_GetTwoPlayerTrackSelectTrackType
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
.ends

.section "Two player result screen frame handler" force
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
  call LABEL_B1F4_Trampoline_Music_Stop
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
  INC_A
  ld (_RAM_DC35_TournamentRaceNumber), a
  call LABEL_8A30_InitialiseTwoPlayersRaceSelectMenu
  jp LABEL_80FC_EndMenuScreenHandler

+:
  call LABEL_B877_
  jp LABEL_80FC_EndMenuScreenHandler
.ends

.section "Yet more menu screen helpers" force
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
  ld (_RAM_D6CC_TwoPlayerTrackSelectIndex_1Based), a
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
  call LABEL_B1EC_Trampoline_MusicStart
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
  INC_A
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
  INC_A
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
  INC_A
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
.ends

.section "Tournament champion screen frame handler" force
; 19th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
LABEL_B84D_Handler_MenuScreen_TournamentChampion:
  call LABEL_B911_
  ld a, (_RAM_D6AB_MenuTimer.Lo)
  cp $FF ; 5.1s @ 50Hz, 4.25s @ 60Hz
  jr z, +
  INC_A
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
  call LABEL_B1F4_Trampoline_Music_Stop
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
  call LABEL_B1EC_Trampoline_MusicStart
  jp ++

+:
  ld c, Music_0C_TwoPlayerTournamentWinner
  call LABEL_B1EC_Trampoline_MusicStart
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
  call LABEL_B375_ConfigureTilemapRect_5x6_Portrait1
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
  DEC_A
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
  ld hl, _TEXT_TournamentChampion
  ld bc, _sizeof__TEXT_TournamentChampion
  jp LABEL_A5B0_EmitToVDP_Text

+:
  ld hl, _TEXT_Challenge
  ld bc, _sizeof__TEXT_Challenge + _sizeof__TEXT_Champion
  jp LABEL_A5B0_EmitToVDP_Text

++:
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_Champion
  ld bc, _sizeof__TEXT_Champion
  jp LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 6, 11
  call LABEL_B35A_VRAMAddressToHL
  ld hl, TEXT_Blanks_32
  ld bc, _sizeof__TEXT_TournamentChampion
  jp LABEL_A5B0_EmitToVDP_Text

; Data from B966 to B979 (20 bytes)
_TEXT_TournamentChampion:
.asc "TOURNAMENT CHAMPION!"

; Data from B97A to B983 (10 bytes)
_TEXT_Challenge:
.asc "CHALLENGE "

; Data from B984 to B98D (10 bytes)
_TEXT_Champion:
.asc "CHAMPION !"
.ends

.section "Menu controls handlers" force
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
.ends

.section "Gear to gear stuff" force
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
  INC_A
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
  INC_A
  cp $0B
  jr nz, +
  ld a, $01
+:ld (_RAM_D7B3_), a
  ret
.ends

.section "Menu results screen helpers" force
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
  CP_0
  JrZRet +
  DEC_A
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jr nz, ++
  ; Text
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Qualifying
  ld hl, _TEXT_Qualifying
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 11, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Race
  ld hl, _TEXT_Race
  call LABEL_A5B0_EmitToVDP_Text
+:ret

++:
  ; Blanks (for flashing)
  TilemapWriteAddressToHL 11, 11
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Qualifying
  ld hl, _TEXT_Blanks
  call LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 11, 12
  call LABEL_B35A_VRAMAddressToHL
  ld bc, _sizeof__TEXT_Race
  ld hl, _TEXT_Blanks
  TailCall LABEL_A5B0_EmitToVDP_Text

_TEXT_Qualifying: .asc "QUALIFYING"
_TEXT_Race:       .asc "   RACE   "
_TEXT_Blanks:     .asc "          "
.ends

.section "Logo loaders" force
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
.ends

.section "Initialise slideshow" force
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
  ld bc, 80 * TILE_DATA_SIZE ; 80 tiles
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
.ends

.section "Menu screen random stuff again" force
LABEL_BB49_SetMenuHScroll: ; Called once
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

LABEL_BB5B_SetBackdropToColour0: ; Called once
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

LABEL_BB6C_ScreenOff:; Called once
  ld a, VDP_REGISTER_MODECONTROL2_SCREENOFF
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

LABEL_BB75_ScreenOnAtLineFF: ; Called lots of times
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

LABEL_BB85_ScreenOffAtLineFF: ; Called lots of times
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
  INC_A
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec de             ; loop over column counter
  ld a, e
  or a
  jr nz, -
  ld a, (_RAM_D69B_TilemapRectangleSequence_Height) ; Decrement row counter
  DEC_A
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
  jr z, _LABEL_BD7C_PaletteFadeDone
  cp $03
  jr nc, +
  ld hl, DATA_BD58_Palettes_SMS
  call LABEL_BD82_GetPalettePointerAndSelectIndex0
  ld b, 7 ; count
  ld c, PORT_VDP_DATA
  otir
  ld hl, PALETTE_WRITE_MASK | 16 ; $C010 ; Palette index $10
  CallRamCode LABEL_3BCC7_VRAMAddressToHL
  ld a, (de) ; 0th palette value
  out (PORT_VDP_DATA), a
+:
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  INC_A
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

_LABEL_BD7C_PaletteFadeDone:
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
  
  .macro DrawText args x, y, pointer, size, mode
  TilemapWriteAddressToHL x, y
  call LABEL_B35A_VRAMAddressToHL
  .if mode == 0
  ld c, size
  ld hl, pointer
  .else
  ld hl, pointer
  ld c, size
  .endif
  .if mode == 2
  jp LABEL_A5B0_EmitToVDP_Text
  .else
  call LABEL_A5B0_EmitToVDP_Text
  .endif
  .endm

  DrawText 0, 26, _TEXT_CopyrightCodemasters,    _sizeof__TEXT_CopyrightCodemasters,   0
  DrawText 0, 27, _TEXT_SoftwareCompanyLtd1993,  _sizeof__TEXT_SoftwareCompanyLtd1993, 0
  DrawText 4, 16, _TEXT_MasterSystemVersionBy,   _sizeof__TEXT_MasterSystemVersionBy,  1
  DrawText 6, 18, _TEXT_AshleyRoutledge,         _sizeof__TEXT_AshleyRoutledge,        1
  DrawText 6, 19, _TEXT_And,                     /*_sizeof__TEXT_And+2*/ 13,           1
  DrawText 6, 20, _TEXT_DavidSaunders,           _sizeof__TEXT_DavidSaunders,          2

_TEXT_CopyrightCodemasters:   .asc "     COPYRIGHT CODEMASTERS"
_TEXT_SoftwareCompanyLtd1993: .asc "   SOFTWARE COMPANY LTD 1993"
_TEXT_MasterSystemVersionBy:  .asc "MASTER SYSTEM VERSION BY"
_TEXT_AshleyRoutledge:        .asc "  ASHLEY ROUTLEDGE  "
_TEXT_And:                    .asc "        AND"
_TEXT_DavidSaunders:          .asc "   DAVID SAUNDERS"
.ends

.section "LABEL_BEF5_TitleScreen_ClearText" force
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
.ends

.section "LABEL_BF2E_LoadMenuPalette_SMS" force
LABEL_BF2E_LoadMenuPalette_SMS:
  PaletteAddressToHLSMS 0 ; Palette index 0
  call LABEL_B35A_VRAMAddressToHL
  ld hl, _MenuPalette_SMS
  ld b, _sizeof__MenuPalette_SMS
  ld c, PORT_VDP_DATA
  otir
  ret

; Data from BF3E to BF4F (18 bytes)
_MenuPalette_SMS:
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
.ends

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

.orga $bfff ; so the label ends up in the right place
DATA_BFFF_Page2PageNumber:
  BankMarker

.BANK 3
.ORG $0000
.section "Sports cars data index" force

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
; $8010 dw Pointer to ??? (copied to _RAM_D900_UnknownData) = 64B
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

.dstruct DATA_C000_TrackData_SportsCars instanceof TrackData data  DATA_E480_SportsCars_BehaviourData DATA_E799_SportsCars_WallData DATA_E811_SportsCars_Track0Layout DATA_EA34_SportsCars_Track1Layout DATA_ED79_SportsCars_Track2Layout DATA_F155_SportsCars_Track3Layout DATA_F155_SportsCars_GGPalette DATA_F195_SportsCars_DecoratorTiles DATA_F215_SportsCarsDATA DATA_F255_SportsCars_EffectsTiles

.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $FF $FF $BF $FF $FF $FF $FF $FF $FF $FF $BF $FF $FF $FF $7F $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $DF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF
.endif

.orga $8080
.section "DATA_C080_SportsCarsMetatiles" force
DATA_C080_SportsCarsMetatiles:
.incbin "Assets/Sportscars/Metatiles.tilemap" ; 64 metatiles
.ends

.section "DATA_E480_SportsCars_BehaviourData" force
DATA_E480_SportsCars_BehaviourData:
.incbin "Assets/Sportscars/Behaviour data.compressed"
.ends

.section "DATA_E799_SportsCars_WallData" force
DATA_E799_SportsCars_WallData:
.incbin "Assets/Sportscars/Wall data.compressed"
.ends

.section "DATA_E811_SportsCars_Track0Layout" force
DATA_E811_SportsCars_Track0Layout:
.incbin "Assets/Sportscars/Track 0 layout.compressed"
.ends

.section "DATA_EA34_SportsCars_Track1Layout" force
DATA_EA34_SportsCars_Track1Layout:
.incbin "Assets/Sportscars/Track 1 layout.compressed"
.ends

.section "DATA_ED79_SportsCars_Track2Layout" force
DATA_ED79_SportsCars_Track2Layout:
.incbin "Assets/Sportscars/Track 2 layout.compressed"
DATA_F155_SportsCars_Track3Layout:
; missing
.ends

.section "DATA_F155_SportsCars_GGPalette" force
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
.ends

.section "DATA_F195_SportsCars_DecoratorTile" force
DATA_F195_SportsCars_DecoratorTiles
.incbin "Assets/Sportscars/Decorators.1bpp"
.ends

.section "DATA_F215_SportsCarsDATA" force
DATA_F215_SportsCarsDATA:
; One byte per metatile
; High bit = off-track?
.db $22 $00 $5D $4D $6F $7B $00 $00 $00 $00 $22 $22 $22 $22 $80 $C0 $C0 $C0 $C0 $E0 $E0 $C0 $E0 $C0 $80 $A0 $A0 $A0 $A0 $A0 $22 $C0 $22 $C0 $A0 $A0 $C0 $C0 $C0 $C0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $80 $80 $C0 $A0 $80 $C0 $00 $00
.ends

.section "DATA_F255_SportsCars_EffectsTiles" force
DATA_F255_SportsCars_EffectsTiles:
.incbin "Assets/Sportscars/Effects.3bpp"
.ends

.section "DATA_F35D_Tiles_Portrait_FourByFour" force
DATA_F35D_Tiles_Portrait_FourByFour:
.incbin "Assets/Four By Four/Portrait.3bpp.compressed"
.ends

.section "DATA_F765_Tiles_Portrait_Warriors" force
DATA_F765_Tiles_Portrait_Warriors:
.incbin "Assets/Warriors/Portrait.3bpp.compressed"
.ends

.section "DATA_FAA5_Tiles_Portrait_SportsCars" force
DATA_FAA5_Tiles_Portrait_SportsCars:
.incbin "Assets/Sportscars/Portrait.3bpp.compressed"
.ends

.section "Track names" force
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
DATA_FE75_TrackName_09: .asc " THE POTTED PASSAGE " ; Choppers!
DATA_FE89_TrackName_10: .asc "FRUIT-JUICE FOLLIES "
DATA_FE9D_TrackName_11: .asc "    FOAMY FJORDS    "
DATA_FEB1_TrackName_12: .asc "BEDROOM BATTLEFIELD "
DATA_FEC5_TrackName_13: .asc "  PITFALL POCKETS   "
DATA_FED9_TrackName_14: .asc "  PENCIL PLATEAUX   "
DATA_FEED_TrackName_15: .asc "THE DARE-DEVIL DUNES"
DATA_FF01_TrackName_16: .asc "THE SHRUBBERY TWIST " ; Choppers!
DATA_FF15_TrackName_17: .asc " PERILOUS PIT-STOP  "
DATA_FF29_TrackName_18: .asc "WIDE-AWAKE WAR-ZONE "
DATA_FF3D_TrackName_19: .asc "   CRAYON CANYONS   "
DATA_FF51_TrackName_20: .asc "  SOAP-LAKE CITY !  "
DATA_FF65_TrackName_21: .asc "  THE LEAFY BENDS   " ; Choppers!
DATA_FF79_TrackName_22: .asc " CHALK-DUST CHICANE "
DATA_FF8D_TrackName_23: .asc "     GO FOR IT!     "
DATA_FFA2_TrackName_24: .asc " WIN THIS RACE TO BE CHAMPION!" ; Special case for length
DATA_FFBF_TrackName_25: .asc "RUFFTRUX BONUS STAGE"
.ends

.ifdef BLANK_FILL_ORIGINAL
.dsb 44 $ff
.endif

  BankMarker

.BANK 4
.ORG $0000
.section "Four by four data index" force
.dstruct DATA_10000_TrackData_FourByFour instanceof TrackData data DATA_9E50_FourByFour_BehaviourData DATA_A105_FourByFour_WallData DATA_A152_FourByFour_Track0Layout DATA_A378_FourByFour_Track1Layout DATA_A466_FourByFour_Track2Layout DATA_A466_FourByFour_Track3Layout DATA_A762_FourByFour_GGPalette DATA_A7A2_FourByFour_DecoratorTiles DATA_A822_FourByFourDATA DATA_A862_FourByFour_EffectsTiles
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $EF $FF $EF $EB $FF $FB $FF $BF $BF $FF $FF $FF $EF $EF $BF $EF $FF $AF $FF $FF $FF $AF $EF $FF $BF $FF $EF $FF $FF $FF $FF $FF $FF $ED $45 $EF $FF $EF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FF $FF $EF $FF $FF $EF $FF $FF $EF $EF $FF $FF $FE $FF $EF $EF $FF $FF $AF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $FF $FF $EF $FF $FF $BB $FF $FB $FF $FF $FE $FF $FF $FF $FF $FB $FF $FE $EF $FB $FF
.endif

.orga $8080
.section "DATA_8080_FourByFour_Metatiles" force
DATA_8080_FourByFour_Metatiles:
.incbin "Assets/Four By Four/Metatiles.tilemap"
.ends

.section "DATA_9E50_FourByFour_BehaviourData" force
DATA_9E50_FourByFour_BehaviourData:
.incbin "Assets/Four by Four/Behaviour data.compressed"
.ends

.section "DATA_A105_FourByFour_WallData" force
DATA_A105_FourByFour_WallData:
.incbin "Assets/Four by Four/Wall data.compressed"
.ends

.section "DATA_A152_FourByFour_Track0Layout" force
DATA_A152_FourByFour_Track0Layout:
.incbin "Assets/Four by Four/Track 0 layout.compressed"
.ends

.section "DATA_A378_FourByFour_Track1Layout" force
DATA_A378_FourByFour_Track1Layout:
.incbin "Assets/Four by Four/Track 1 layout.compressed"
.ends

.section "DATA_A466_FourByFour_Track2Layout" force
DATA_A466_FourByFour_Track2Layout: 
DATA_A466_FourByFour_Track3Layout: ; missing
.incbin "Assets/Four by Four/Track 2 layout.compressed"
.ends

.section "DATA_A762_FourByFour_GGPalette" force
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
.ends

.section "DATA_A7A2_FourByFour_DecoratorTiles" force
DATA_A7A2_FourByFour_DecoratorTiles:
.incbin "Assets/Four by Four/Decorators.1bpp"
.ends

.section "DATA_A822_FourByFourDATA" force
DATA_A822_FourByFourDATA:
.db $C0 $00 $22 $49 $73 $00 $00 $00 $00 $22 $22 $22 $22 $00 $C0 $C0
.db $C0 $C0 $C0 $C0 $C0 $C0 $80 $80 $80 $00 $80 $C0 $C0 $C0 $A0 $C0
.db $22 $C0 $C0 $80 $80 $80 $80 $80 $00 $00 $80 $80 $80 $80 $80 $00
.db $00 $80 $80 $80 $80 $45 $77 $00 $00 $00 $00 $00 $00 $00 $00 $00
.ends

.section "DATA_A862_FourByFour_EffectsTiles" force
DATA_A862_FourByFour_EffectsTiles:
.incbin "Assets/Four by Four/Effects.3bpp"
.ends

.section "DATA_1296A_CarTiles_RuffTrux" force
DATA_1296A_CarTiles_RuffTrux:
.incbin "Assets/RuffTrux/Car.3bpp.runencoded"
.dsb 3, 0 ; padding?
.ends

.section "DATA_13C42_Tiles_BigNumbers" force
DATA_13C42_Tiles_BigNumbers:
.incbin "Assets/Menu/Numbers-Big.3bpp.compressed"
.ends

.section "DATA_13D7F_Tiles_MicroMachinesText" force
DATA_13D7F_Tiles_MicroMachinesText:
.incbin "Assets/Menu/Text-MicroMachines.3bpp.compressed"
.ends

.section "DATA_13F38_Tilemap_SmallLogo" force
DATA_13F38_Tilemap_SmallLogo: ; 8x3
.incbin "Assets/Menu/Logo-small.tilemap"
.ends

.section "DATA_13F50_Tilemap_MicroMachinesText" force
DATA_13F50_Tilemap_MicroMachinesText:
.incbin "Assets/Menu/Text-MicroMachines.tilemap"
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $00 $00 $20 $00 $00 $02 $00 $00 $02 $00 $08 $00 $00 $00 $00 $00 $00 $08 $00 $00 $02 $80 $00 $00 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FB $FF $FF $FF $FA $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FE $FF $FF $FF $FF
.endif

  BankMarker

.BANK 5
.ORG $0000
.section "Powerboats data index" force

.dstruct DATA_14000_TrackData_Powerboats instanceof TrackData data DATA_9D30_Powerboats_BehaviourData DATA_9FE3_Powerboats_WallData DATA_A03C_Powerboats_Track0Layout DATA_A134_Powerboats_Track1Layout DATA_A352_Powerboats_Track2Layout DATA_A5B1_Powerboats_Track3Layout DATA_A7A0_Powerboats_GGPalette DATA_A7E0_Powerboats_DecoratorTiles DATA_A860_PowerboatsDATA DATA_A8A0_Powerboats_EffectsTiles

.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $CF $FF $FF $ED $45 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FB $FF $FF $FF
.endif

.orga $8080
.section "DATA_8080_Powerboats_Metatiles" force
DATA_8080_Powerboats_Metatiles:
.incbin "Assets/Powerboats/Metatiles.tilemap"
.ends

.section "DATA_9D30_Powerboats_BehaviourData" force
DATA_9D30_Powerboats_BehaviourData:
.incbin "Assets/Powerboats/Behaviour data.compressed"
.ends

.section "DATA_9FE3_Powerboats_WallData" force
DATA_9FE3_Powerboats_WallData:
.incbin "Assets/Powerboats/Wall data.compressed"
.ends

.section "DATA_A03C_Powerboats_Track0Layout" force
DATA_A03C_Powerboats_Track0Layout:
.incbin "Assets/Powerboats/Track 0 layout.compressed"
.ends

.section "DATA_A134_Powerboats_Track1Layout" force
DATA_A134_Powerboats_Track1Layout:
.incbin "Assets/Powerboats/Track 1 layout.compressed"
.ends

.section "DATA_A352_Powerboats_Track2Layout" force
DATA_A352_Powerboats_Track2Layout:
.incbin "Assets/Powerboats/Track 2 layout.compressed"
.ends

.section "DATA_A5B1_Powerboats_Track3Layout" force
DATA_A5B1_Powerboats_Track3Layout:
.incbin "Assets/Powerboats/Track 3 layout.compressed"
.ends

.section "DATA_A7A0_Powerboats_GGPalette" force
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
.ends

.section "DATA_A7E0_Powerboats_DecoratorTiles" force
DATA_A7E0_Powerboats_DecoratorTiles:
.incbin "Assets/Powerboats/Decorators.1bpp"
.ends

.section "DATA_A860_PowerboatsDATA" force
DATA_A860_PowerboatsDATA:
.db $C0 $A0 $A0 $E0 $73 $80 $C0 $49 $80 $E0 $77 $C0 $45 $C0 $A0 $A0
.db $A0 $C0 $80 $80 $80 $00 $80 $80 $80 $A0 $A0 $C0 $C0 $22 $A0 $A0
.db $A0 $A0 $80 $C0 $80 $80 $A0 $A0 $A0 $22 $41 $63 $A0 $A0 $A0 $A0
.db $A0 $A0 $A0 $A0 $A0 $A0 $A0 $80 $C0 $C0 $C0 $41 $A0 $00 $00 $00
.ends

.section "DATA_A8A0_Powerboats_EffectsTiles" force
DATA_A8A0_Powerboats_EffectsTiles:
.incbin "Assets/Powerboats/Effects.3bpp"
.ends

.section "DATA_169A8_IndexToBitmask" force
DATA_169A8_IndexToBitmask:
; Converts from an index (0..143) to a bitmask for the relevant byte (left to right)
.repeat 12*12 index _x
  .db 1 << (7 - _x # 8)
.endr
.ends

.section "DATA_16A38_DivideBy8" force
DATA_16A38_DivideBy8:
  DivisionTable 8 144
.ends

.section "DATA_16AC8_Tiles_Portrait_TurboWheels" force
DATA_16AC8_Tiles_Portrait_TurboWheels:
.incbin "Assets/Turbo Wheels/Portrait.3bpp.compressed"
.ends

.section "DATA_16F2B_Tiles_Portrait_FormulaOne" force
DATA_16F2B_Tiles_Portrait_FormulaOne:
.incbin "Assets/Formula One/Portrait.3bpp.compressed"
.ends

.section "DATA_1736E_Tiles_Portrait_Tanks" force
DATA_1736E_Tiles_Portrait_Tanks:
.incbin "Assets/Tanks/Portrait.3bpp.compressed"
.ends

.section "DATA_Tiles_MrQuestion" force
DATA_Tiles_MrQuestion:
.incbin "Assets/racers/MrQuestion.3bpp"
.ends

.section "DATA_Tiles_OutOfGame" force
DATA_Tiles_OutOfGame:
.incbin "Assets/racers/OutOfGame.3bpp"
.ends

.section "DATA_17C0C_Tiles_TwoPlayersOnOneGameGear" force
DATA_17C0C_Tiles_TwoPlayersOnOneGameGear:
.incbin "Assets/Menu/Text-TwoPlayersOnOneGameGear.4bpp.compressed"
.ends

.section "DATA_17DD5_Tiles_Playoff" force
DATA_17DD5_Tiles_Playoff:
.incbin "Assets/Playoff.4bpp"
.ends

.section "Playoff tiles loader" force
PagedFunction_17E95_LoadPlayoffTiles:
  SetTileAddressImmediate $19c
  ld bc, 4 * 8 ; 4 tiles
  ld hl, DATA_17DD5_Tiles_Playoff
  call _LoadTileRow
  SetTileAddressImmediate $1a4
  ld bc, 2 * 8 ; 2 tiles
  ld hl, DATA_17DD5_Tiles_Playoff+4*32
  ; fall through
_LoadTileRow:
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
.ends

.section "SMS palettes" force
DATA_17EC2_SMSPalettes:
.dw DATA_17ED2_SMSPalette_SportsCars
.dw DATA_17EF2_SMSPalette_FourByFour
.dw DATA_17F12_SMSPalette_Powerboats
.dw DATA_17F32_SMSPalette_TurboWheels
.dw DATA_17F52_SMSPalette_FormulaOne
.dw DATA_17F72_SMSPalette_Warriors
.dw DATA_17F92_SMSPalette_Tanks
.dw DATA_17FB2_SMSPalette_RuffTrux

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
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $FF $FF $FF $FF $DF $FF $FF $FF $DF $FF $FF $FF $7F
.db $FF $7F $FF $FF $FF $7F $FF $FF $FF $7F $FE $FF $FF $FF $FF $FF
.db $FF $F7 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.endif

  BankMarker

.BANK 6
.ORG $0000
.section "Turbo Wheels data index" force
.dstruct DATA_18000_TrackData_TurboWheels instanceof TrackData data DATA_A480_TurboWheels_BehaviourData DATA_A7B6_TurboWheels_WallData DATA_A838_TurboWheels_Track0Layout DATA_AACF_TurboWheels_Track1Layout DATA_AD10_TurboWheels_Track2Layout DATA_AD10_TurboWheels_Track3Layout DATA_AF9A_TurboWheels_GGPalette DATA_AFDA_TurboWheels_DecoratorTiles DATA_B05A_TurboWheelsDATA DATA_B09A_TurboWheels_EffectsTiles
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FE $FF $FF $FF $BF $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $BF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $ED $45 $FF $FF $FF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF $EF $EF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $EE $FF $FF $FF $EF $FF $FF $EF $ED $45 $FF $FF $EF $FF $FF $FF $FF $FF $BF $FF $FF $FF $FF $FF $EF $FF $FF $FF $EF $FF $FF $FB $FF $FF
.endif

.orga $8080
.section "DATA_8080_TurboWheels_Metatiles" force
DATA_8080_TurboWheels_Metatiles:
.incbin "Assets/Turbo Wheels/Metatiles.tilemap"
.ends

.section "DATA_A480_TurboWheels_BehaviourData" force
DATA_A480_TurboWheels_BehaviourData:
.incbin "Assets/Turbo Wheels/Behaviour data.compressed"
.ends

.section "DATA_A7B6_TurboWheels_WallData" force
DATA_A7B6_TurboWheels_WallData:
.incbin "Assets/Turbo Wheels/Wall data.compressed"
.ends

.section "DATA_A838_TurboWheels_Track0Layout" force
DATA_A838_TurboWheels_Track0Layout:
.incbin "Assets/Turbo Wheels/Track 0 layout.compressed"
.ends

.section "DATA_AACF_TurboWheels_Track1Layout" force
DATA_AACF_TurboWheels_Track1Layout:
.incbin "Assets/Turbo Wheels/Track 1 layout.compressed"
.ends

.section "DATA_AD10_TurboWheels_Track2Layout" force
DATA_AD10_TurboWheels_Track2Layout: 
DATA_AD10_TurboWheels_Track3Layout: ; point to #2
.incbin "Assets/Turbo Wheels/Track 2 layout.compressed"
.ends

.section "DATA_AF9A_TurboWheels_GGPalette" force
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
.ends
  
.section "DATA_AFDA_TurboWheels_DecoratorTiles" force
DATA_AFDA_TurboWheels_DecoratorTiles:
.incbin "Assets/Turbo Wheels/Decorators.1bpp"
.ends

.section "DATA_B05A_TurboWheelsDATA" force
DATA_B05A_TurboWheelsDATA:
.db $C0 $C0 $00 $00 $22 $22 $A0 $A0 $00 $00 $00 $00 $22 $22 $22 $22
.db $45 $49 $73 $77 $C0 $C0 $C0 $C0 $A0 $A0 $C0 $C0 $C0 $22 $C0 $C0
.db $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $A0 $A0 $A0 $C0 $C0 $C0 $C0
.db $C0 $C0 $A0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $80 $80 $80 $C0 $C0
.ends

.section "DATA_B09A_TurboWheels_EffectsTiles" force
DATA_B09A_TurboWheels_EffectsTiles:
.incbin "Assets/Turbo Wheels/Effects.3bpp"
.ends

.section "DATA_1B1A2_12x12To6x6" force
DATA_1B1A2_12x12To6x6:
; Indexed by _RAM_DE6B_OffsetInCurrentMetatile and _RAM_DE6D_
; 144 values
; Maps a 12x12 rect to 6x6 values
.db $00 $00 $01 $01 $02 $02 $03 $03 $04 $04 $05 $05 
.db $00 $00 $01 $01 $02 $02 $03 $03 $04 $04 $05 $05
.db $06 $06 $07 $07 $08 $08 $09 $09 $0A $0A $0B $0B 
.db $06 $06 $07 $07 $08 $08 $09 $09 $0A $0A $0B $0B
.db $0C $0C $0D $0D $0E $0E $0F $0F $10 $10 $11 $11 
.db $0C $0C $0D $0D $0E $0E $0F $0F $10 $10 $11 $11
.db $12 $12 $13 $13 $14 $14 $15 $15 $16 $16 $17 $17
.db $12 $12 $13 $13 $14 $14 $15 $15 $16 $16 $17 $17
.db $18 $18 $19 $19 $1A $1A $1B $1B $1C $1C $1D $1D
.db $18 $18 $19 $19 $1A $1A $1B $1B $1C $1C $1D $1D
.db $1E $1E $1F $1F $20 $20 $21 $21 $22 $22 $23 $23
.db $1E $1E $1F $1F $20 $20 $21 $21 $22 $22 $23 $23 
.ends

.section "DATA_1B232_JumpCurveTable" force
DATA_1B232_JumpCurveTable:
; Holds a sine curve, padded with an extra 0 at the start and 15 extra at the end
; It curves from 0 to 127 to 0 again in the remaining space
; 127 |      _
;     |     / \
;     |    |   |
;     |   |     |
;   0 |--'       `--------
;       1   65   130    145
; We are able to replicate it with the below:
.db $00
.dbsin 0, 128, 180/128, 128, -0.001
.dsb 15 $00
; dbsin args are:
; - start angle in degrees (0)
; - step count = number of values to produce - 1 (128 steps -> 129 values)
; - step angle in degrees (180 degrees / 128 steps)
; - scaling factor (128 nominal max value)
; - offset (we use a small value here which results in the peak being rounded down from 128 and everything else is unaffected)
; This is very dependent on the implementation of dbsin to exactly replicate the original, so here's the raw values for reference:
;.db $00 $03 $06 $09 $0C $0F $12 $15 $18 $1C $1F $22 $25 $28 $2B $2E $30 $33 $36 $39 $3C $3F $41 $44 $47 $49 $4C $4E $51 $53 $55 $58 $5A $5C $5E $60 $62 $64 $66 $68 $6A $6C $6D $6F $70 $72 $73 $75 $76 $77 $78 $79 $7A $7B $7C $7C $7D $7E $7E $7F $7F $7F $7F $7F $7F $7F $7F $7F $7F $7F $7E $7E $7D $7C $7C $7B $7A $79 $78 $77 $76 $75 $73 $72 $70 $6F $6D $6C $6A $68 $66 $64 $62 $60 $5E $5C $5A $58 $55 $53 $51 $4E $4C $49 $47 $44 $41 $3F $3C $39 $36 $33 $30 $2E $2B $28 $25 $22 $1F $1C $18 $15 $12 $0F $0C $09 $06 $03 $00
.ends

.section "DATA_1B2C3_Tiles_Trophy" force
DATA_1B2C3_Tiles_Trophy:
.incbin "Assets/Menu/Trophy.3bpp.compressed"
.ends

.section "DATA_1B7A7_DriverSelectTilemap_SMS" force
DATA_1B7A7_DriverSelectTilemap_SMS:
.incbin "Assets/Menu/Driver select tilemap data (SMS).bin"
.ends

.section "DATA_1B987_DriverSelectTilemap_GG" force
DATA_1B987_DriverSelectTilemap_GG:
.incbin "Assets/Menu/Driver select tilemap data (GG).bin"
.ends

.section "Get player handicaps" force
PagedFunction_1BAB3_GetPlayerHandicaps:
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
  ld hl, _DATA_CharacterHandicaps
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
  ld hl, _DATA_CharacterHandicaps
  add hl, de
  ld a, (hl)
  ld (_RAM_D5D0_Player2Handicap), a
++:
  ret

; Data from 1BAF2 to 1BAFC (11 bytes)
_DATA_CharacterHandicaps:
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
.ends

.section "PagedFunction_1BAFD_" force
PagedFunction_1BAFD_:
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
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet -
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  JrNzRet -
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet -
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  JrNzRet -
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  or a
  JrNzRet -
  ld b, $01
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
  sub l
  jr nc, +
  ld b, $00
  xor $FF
  INC_A
+:
  ld l, a
  ld a, $F2
  sub l
  srl a
  ld (_RAM_D5D2_), a
  ld a, b
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  jr ++

+:
  ld a, (_RAM_DBA4_CarX)
++:
  ld l, a
  ld a, (_RAM_D5D2_)
  ld c, a
  cp l
  jr z, _LABEL_1BBAF_
  dec a
  cp l
  jr z, _LABEL_1BBAF_
  dec a
  cp l
  jr z, _LABEL_1BBAF_
  ld a, c
  inc a
  cp l
  jr z, _LABEL_1BBAF_
  inc a
  cp l
  jr z, _LABEL_1BBAF_
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
  jr c, _LABEL_1BBAF_
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
  jr c, _LABEL_1BBAF_
  ld a, $01
  ld (_RAM_D5DC_), a
+:
  ld a, $01
  ld (_RAM_DF0B_), a
  ld a, $01
  ld (_RAM_DF0D_), a
  jr +++

_LABEL_1BBAF_:
  xor a
  ld (_RAM_D5D5_), a
  ld (_RAM_D5DC_), a
  ld (_RAM_DF0B_), a
+++:
  ld b, $01
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  jr nc, +
  ld b, $00
  xor $FF
  INC_A
+:
  ld l, a
  ld a, $D0
  sub l
  srl a
  ld (_RAM_D5D3_), a
  ld a, b
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  jr ++

+:
  ld a, (_RAM_DBA5_CarY)
++:
  ld l, a
  ld a, (_RAM_D5D3_)
  ld c, a
  cp l
  jr z, _LABEL_1BC3F_
  dec a
  cp l
  jr z, _LABEL_1BC3F_
  dec a
  cp l
  jr z, _LABEL_1BC3F_
  ld a, c
  inc a
  cp l
  jr z, _LABEL_1BC3F_
  inc a
  cp l
  jr z, _LABEL_1BC3F_
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
  jr c, _LABEL_1BC3F_
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
  jr c, _LABEL_1BC3F_
  ld a, $01
  ld (_RAM_D5DD_), a
+:
  ld a, $01
  ld (_RAM_DF0C_), a
  ld a, $01
  ld (_RAM_DF0E_), a
  jr +++

_LABEL_1BC3F_:
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
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_HScrollDelta)
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_HScrollDelta), a
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
.ends

.section "Delay if player2" force
PagedFunction_1BCCB_DelayIfPlayer2:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  JrZRet ++ ; ret
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr z, +
  JrRet ++ ; ret
+:; Player 2
  ld hl, 0 ; Waste some time
-:dec hl
  ld a, h
  or l
  jr nz, -
++:ret
.ends

.section "PagedFunction_1BCE2_" force
PagedFunction_1BCE2_:
  ; ix points at a CarData
  ; iy points at a CarUnknown
  ld a, (iy+CarUnknown.Unknown1)
  or a
  jr nz, + ; Better to ret z
  ret

+:
  ld a, (iy+CarUnknown.Unknown2_Counter)
  INC_A
  and $07
  ld (iy+CarUnknown.Unknown2_Counter), a
  or a
  jr nz, +
  ld a, (iy+1)
  DEC_A
  ld (iy+1), a
+:
  ld hl, DATA_1D65__Lo
  ld a, (iy+CarUnknown.Unknown1)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (iy+CarUnknown.Unknown1)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  push de
    ld hl, DATA_3FC3_HorizontalAmountByDirection
    ld a, (iy+CarUnknown.Unknown0_Direction)
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
    ld (ix+CarData.Unknown15_b), a
    ld (_RAM_DF7D_), a
    ld hl, DATA_40E5_Sign_Directions_X
    ld a, (iy+CarUnknown.Unknown0_Direction)
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a
    ld a, (hl)
    CP_0
    jr z, +
    xor a
    ld (_RAM_DB85_), a
    ld a, (ix+CarData.XPosition.Lo)
    ld l, a
    ld a, (ix+CarData.XPosition.Hi)
    ld h, a
    ld d, $00
    ld a, (ix+CarData.Unknown15_b)
    ld e, a
    or a
    sbc hl, de
    ld a, l
    ld (ix+CarData.XPosition.Lo), a
    ld a, h
    ld (ix+CarData.XPosition.Hi), a
    jp ++

+:  ld a, $01
    ld (_RAM_DB85_), a
    ld a, (ix+CarData.XPosition.Lo)
    ld l, a
    ld a, (ix+CarData.XPosition.Hi)
    ld h, a
    ld d, $00
    ld a, (ix+CarData.Unknown15_b)
    ld e, a
    add hl, de
    ld a, l
    ld (ix+CarData.XPosition.Lo), a
    ld a, h
    ld (ix+CarData.XPosition.Hi), a
++:
  pop de
  ld hl, DATA_3FD3_VerticalAmountByDirection
  ld a, (iy+CarUnknown.Unknown0_Direction)
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
  ld (ix+CarData.Unknown16_b), a
  ld (_RAM_DF7E_), a
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (iy+CarUnknown.Unknown0_Direction)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
  jr z, +
  xor a
  ld (_RAM_DB84_), a
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  ld d, $00
  ld a, (ix+CarData.Unknown16_b)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (ix+CarData.YPosition.Lo), a
  ld a, h
  ld (ix+CarData.YPosition.Hi), a
  ret

+:
  ld a, $01
  ld (_RAM_DB84_), a
  ld a, (ix+CarData.YPosition.Lo)
  ld l, a
  ld a, (ix+CarData.YPosition.Hi)
  ld h, a
  ld d, $00
  ld a, (ix+CarData.Unknown16_b)
  ld e, a
  add hl, de
  ld a, l
  ld (ix+CarData.YPosition.Lo), a
  ld a, h
  ld (ix+CarData.YPosition.Hi), a
  ret
.ends

.section "PagedFunction_1BDF3_" force
PagedFunction_1BDF3_:
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_HScrollDelta)
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_HScrollDelta), a
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
.ends

.section "Initialise VDP registers" force
PagedFunction_1BE82_InitialiseVDPRegisters:
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
.ends

.section "Change pool table colour" force
PagedFunction_1BEB1_ChangePoolTableColour:
  ; Updates palette indexes 1-2 for the pool table tracks
  ; to change the colour of the cloth
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  JrNzRet _ret ; Only for F1 tracks
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ; Game Gear
  SetPaletteAddressImmediateGG 1
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  JrZRet _ret
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

.ifdef JUMP_TO_RET
_ret:
  ret
.endif

++:
  ; Master System
  SetPaletteAddressImmediateSMS 1
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  JrZRet _ret
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
.ends

.section "PagedFunction_1BF17_" force
PagedFunction_1BF17_:
  ; Must be 0 or 6
  ld a, (ix+CarData.Unknown30_b)
  or a
  jr z, +
  cp 6
  JrNzRet ++
+:; And not head to head
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet ++
  ; Read pointer
  ld l, (ix+CarData.Unknown47_w.Lo)
  ld h, (ix+CarData.Unknown47_w.Hi)
  ; Blank it
  xor a
  ld (hl), a
  ld (ix+CarData.Unknown20_b_JumpCurvePosition), a
  jp LABEL_2961_

.ifdef UNNECESSARY_CODE
  ; Unreachable
  ld a, (ix+CarData.Unknown12_b_Direction)
  ld l, a
  cp (ix+CarData.Direction)
  ld a, $00
  jr nz, +
  inc a
+:ld (ix+CarData.Unknown11_b_Speed), a
.endif

++: ret
.ends

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

  BankMarker

.BANK 7
.ORG $0000

.section "Formula One dat index" force
.dstruct DATA_1C000_TrackData_FormulaOne instanceof TrackData data  DATA_A480_FormulaOne_BehaviourData DATA_A819_FormulaOne_WallData DATA_A8CA_FormulaOne_Track0Layout DATA_AB11_FormulaOne_Track1Layout DATA_AE73_FormulaOne_Track2Layout DATA_AE73_FormulaOne_Track3Layout DATA_B1DC_FormulaOne_GGPalette DATA_B21C_FormulaOne_DecoratorTiles DATA_B29C_FormulaOneDATA DATA_B2DC_FormulaOne_EffectsTiles
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FF $FF $77 $FF $F7 $FF $DF $FF $FF $FF $D7 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FD $EF $FF $FF $5D $FF $FF $FF $FF $FF $FF $FF $FF $ED $45 $FF $FF $FF $77 $FD $DD $FF $FF $FF $FF $FF $FD $FF $FF $FF $DF $FF $7F $FF $FF $FF $F7 $FF $FF $FD $F7 $FF $DF $FF $FD $FF $FF $FF $FF $FF $FF $FF $FD $FF $DF $FF $FF $FF $FF $ED $45 $FF $7F $FF $FD $FF $FF $FF $F7 $FF $FF $FF $DF $FF $FF $FF $77 $FF $F7 $DF $F7 $FF $FF $FF $FF
.endif

.orga $8080
.section "LABEL_8080_FormulaOne_Metatiles" force
LABEL_8080_FormulaOne_Metatiles:
.incbin "Assets/Formula One/Metatiles.tilemap"
.ends

.section "DATA_A480_FormulaOne_BehaviourData" force
DATA_A480_FormulaOne_BehaviourData:
.incbin "Assets/Formula One/Behaviour data.compressed"
.ends

.section "DATA_A819_FormulaOne_WallData" force
DATA_A819_FormulaOne_WallData:
.incbin "Assets/Formula One/Wall data.compressed"
.ends

.section "DATA_A8CA_FormulaOne_Track0Layout" force
DATA_A8CA_FormulaOne_Track0Layout:
.incbin "Assets/Formula One/Track 0 layout.compressed"
.ends

.section "DATA_AB11_FormulaOne_Track1Layout" force
DATA_AB11_FormulaOne_Track1Layout:
.incbin "Assets/Formula One/Track 1 layout.compressed"
.ends

.section "DATA_AE73_FormulaOne_Track2Layout" force
DATA_AE73_FormulaOne_Track2Layout: 
DATA_AE73_FormulaOne_Track3Layout: ; points at #2
.incbin "Assets/Formula One/Track 2 layout.compressed"
.ends

.section "DATA_B1DC_FormulaOne_GGPalette" force
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
.ends

.section "DATA_B21C_FormulaOne_DecoratorTiles" force
DATA_B21C_FormulaOne_DecoratorTiles:
.incbin "Assets/Formula One/Decorators.1bpp"
.ends

.section "DATA_B29C_FormulaOneDATA" force
DATA_B29C_FormulaOneDATA:
.db $C0 $00 $22 $63 $77 $73 $63 $C0 $22 $00 $45 $49 $41 $00 $22 $41 $A0 $80 $80 $80 $80 $2E $A0 $C0 $C0 $80 $00 $3A $A0 $C0 $C0 $C0 $00 $00 $1C $00 $C0 $80 $C0 $80 $00 $3A $3A $2E $08 $1C $C0 $80 $1C $80 $C0 $3A $C0 $C0 $C0 $1C $1C $A0 $A0 $C0 $22 $49 $45 $80
.ends

.section "DATA_B2DC_FormulaOne_EffectsTiles" force
DATA_B2DC_FormulaOne_EffectsTiles:
.incbin "Assets/Formula One/Effects.3bpp"
.ends

.section "DATA_1F3E4_Tiles_Portrait_Powerboats" force
DATA_1F3E4_Tiles_Portrait_Powerboats:
.incbin "Assets/Powerboats/Portrait.3bpp.compressed"
.ends

.section "In-game cheat handler" force
PagedFunction_1F8D8_InGameCheatHandler: ; Cheats!
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  ret nz ; Cheats only work in Challenge mode
  
  call _ApplyFasterVehiclesCheat
  
  ; Compute metatile X, Y
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld l, a
  ld a, (_RAM_DE79_CurrentMetatile_OffsetX)
  add a, l
  ld (_RAM_D5C8_MetatileX), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_CurrentMetatile_OffsetY)
  add a, l
  ld (_RAM_D5C9_MetatileY), a

  ld a, (_RAM_DB97_TrackType)
  or a ; TT_0_SportsCars
  jp z, _SportsCars
  cp TT_1_FourByFour
  jr z, _FourByFour
  ret

_FourByFour:
  call _NoSkidCheatCheck ; for any track index
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
  ld (_RAM_D963_SFX_Player1.Trigger), a
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
  ld (_RAM_D974_SFX_Player2), a
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
  ld (_RAM_D974_SFX_Player2), a
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
  ld (_RAM_D974_SFX_Player2), a ; Play sound effect
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
  ld (_RAM_D974_SFX_Player2), a
  ld a, $01
  ld (_RAM_DC4F_Cheat_EasierOpponents), a
+:ret

_SportsCars:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  JrNzRet +
  ; Sports Cars 0 = Desktop Drop-off
  ld a, (_RAM_DC4A_Cheat_ExtraLivesAndLeadCar) ; If cheat was already activated, don't check for it again
  or a
  JrNzRet +
  ; Tile 5, 24 = bottom half of pencil far to the left of the start position, and 4 laps remaining
  ld a, (_RAM_D5C8_MetatileX) ; 5, 24
  cp 5
  JrNzRet +
  ld a, (_RAM_D5C9_MetatileY)
  cp 24
  JrNzRet +
  ld a, (_RAM_DF24_LapsRemaining) ; Haven't crossed the start line yet
  cp $04
  JrNzRet +
  ld a, SFX_12_WinOrCheat
  ld (_RAM_D974_SFX_Player2), a
  ld a, 1
  ld (_RAM_DC4A_Cheat_ExtraLivesAndLeadCar), a
  ld a, CHEAT_EXTRA_LIVES_COUNT ; Set lives count to 5
  ld (_RAM_DC09_Lives), a
+:ret

_NoSkidCheatCheck:
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
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld a, $01
  ld (_RAM_DC4D_Cheat_NoSkidding), a
+:ret

_ApplyFasterVehiclesCheat:
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
.ends

.section "PagedFunction_1FA3D_" force
PagedFunction_1FA3D_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _ret
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet _ret
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  JrNzRet _ret
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
  jr z, _LABEL_1FAE5_
  jp ++

+:ld a, (_RAM_DB20_Player1Controls)
  ld d, a
  and BUTTON_L_MASK ; $04
  jr z, +++
  ld a, d
  and BUTTON_R_MASK ; $08
  jr z, _LABEL_1FAE5_
++:
  ld hl, _RAM_DE9F_
  ld a, (hl)
  or a
  jr z, +
  dec (hl)
+:ld a, (_RAM_DE99_)
  or a
  JrNzRet _ret
  ld hl, _RAM_DEA0_
  ld a, (hl)
  or a
  JrZRet _ret
  dec (hl)
_ret:
  ret

+++:
  ld a, (_RAM_DE9F_)
  or a
  jr z, +
  DEC_A
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
  DEC_A
  jp ++

+:
  ld a, (_RAM_DEA3_)
  INC_A
++:
  ld (_RAM_DEA3_), a
  ld a, (_RAM_DE92_EngineSpeed)
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

_LABEL_1FAE5_:
  ld a, (_RAM_DE9F_)
  CP_0
  jr z, +
  DEC_A
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
  DEC_A
  jp ++

+:
  ld a, (_RAM_DEA3_)
  INC_A
++:
  ld (_RAM_DEA3_), a
  ld a, (_RAM_DE92_EngineSpeed)
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
.ends

.section "PagedFunction_1FB35_" force
PagedFunction_1FB35_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr z, _FourByFour
  
  ld a, (ix+CarData.Unknown11_b_Speed)
  or a
  JrZRet +++  ; 0-1 -> no effect
  cp 1
  JrZRet +++
  cp 2
  jr z, +     ; 2 -> subtract 1
  sub 2       ; higher -> subtract 2
  jp ++
+:DEC_A
++:
  ld (ix+CarData.Unknown11_b_Speed), a

  ; Play SFX if enabled
  ld a, (ix+CarData.EffectsEnabled)
  or a
  JrZRet +++
  ld a, SFX_07_EnterSticky
  ld (_RAM_D974_SFX_Player2), a
+++:ret

_FourByFour:
  ld a, (ix+CarData.Unknown11_b_Speed)
  cp 3
  JrCRet +++  ; 0-3 -> no effect
  cp 4
  jr z, +     ; 4 -> subtract 1
  sub 2       ; Higher -> subtract 2
  jp ++
+:DEC_A
++:
  ld (ix+CarData.Unknown11_b_Speed), a
  
  ; Play SFX if enabled
  ld a, (ix+CarData.EffectsEnabled)
  or a
  JrZRet +++
  ld a, SFX_07_EnterSticky
  ld (_RAM_D974_SFX_Player2), a
+++:ret
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $FD $FF $FF $DD $FF $DD $FF $FF $7F $FF $FF $FF $FF $DF $FF $FF $FF $FF $FF $FF $DF $77 $FF $7F $DF $DF $FF $FF $FF $FF $FF $DF $7F $FF $F7 $FD $FD $FD $FF $DF $FF $DD $FF $DF $FF $F7 $FF $FF $FF $F7 $D7 $FF $FF $FF $FF $FD $FF $5D $FF $FF $FF $7F $FF $FD $FF $7D $FF $FF $FF $FD $FF $FF $FF $FF $FF $DF $FF $FF $FF $FF $FF $FF $FF $7F $FF $DF $FF $FF $FF $F7 $FF $FF $FF $7F $FF $FF $FF $FD $FF $FD $FF $77 $FF $FF $FF $F7 $FF $D5 $FF $7D $FF $FF $FF $FF $FF $FF $DD $FF $FF $FF $FF $F7 $FF $F7 $FF $F5 $20 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $08 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $04 $00 $44 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $20 $40 $00 $00 $00 $00 $00 $00 $00 $40 $FF $FF $FF $FF $FF $FD $FF $FD $FF $FF $FF $7F $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $D7 $EF $77 $FF $7F $FF $DF $FF $5D $FF $7F $FF $FF $FE $FF $FF $FF $FF $FE $FF $F5 $FF $FF $FF $F7 $FF $FF $FF $FD $BE $FF $EF $5F $FE $FF $FF $57 $FF $F7 $FF $FF $FF $FF $FF $FD $FE $5F $FF $F7 $FF $FF $7F $DF $FF $FF $FF $7F $FF $F7 $FF $DD $FF $7F $FF $FF $FF $DF $FF $D7 $FF $7F $FF $FF $FF $5D $FF $FF $FF $FD $FF $FF $EF $F5 $DF $77 $FF $FD $FF $FF $FF $FF $FF $FF $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $40 $00 $44 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $50 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $04 $14 $00 $00 $00 $04 $00 $00 $00 $00 $00 $04 $00 $44 $00 $40 $00 $00 $00 $00 $00 $00 $40 $00 $00 $04 $00 $40 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $44 $FF $FF $FF $FF $FF $D7 $FF $7F $FF $FF $FF $FF $FF $7F $FF $FF $FF $FF $FF $FF $FF $FD $ED $F7 $FF $FF $FF $FD $FF $FF $FF $F5 $FF $FF $FF $5D $FF $7F $FF $F7 $FF $FF $FD $F7 $FF $5F $FF $7D $FF $FF $FF $DF $FF $FF $7F $FF $FF $FF $FF $7F $FF $FF $DF $7F $FF $FF $FF $5D $DF $FE $FF $77 $FF $7F $FF $FF $FD $DF $FF $7F $EF $FF $FF $57 $FF $FF $DD $DF $FF $F7 $FF $7F $FF $DF $FF $77 $FF $FF $FF $FD $FF $FF $FF $D7 $FF $7F $F7 $F7 $FF $FF $FF $DD $FF $FF $FF $FF $FF $FF $FF $5F $FF $FF $DF $7F $FF $FF $FF $DD $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $40 $00 $01 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $80 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $20 $00 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $00 $00 $40 $00 $40 $00 $00 $00 $40 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $04 $00 $00 $00 $00 $04 $FF $FF $EF $FF $FF $FF $FF $77 $FF $FF $FF $FF $FF $FF $FF $7F $FE $FF $FF $DF $FF $FF $FF $DF $FF $D7 $FF $DF $FF $F5 $FF $D5 $FF $FF $FF $77 $FE $7F $FF $FF $FF $DF $FF $77 $FF $FF $FF $55 $FF $FF $FF $FF $FF $FF $FF $FD $FF $FF $FF $FF $FF $FF $FF $FF $FF $DF $FD $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FD $DF $FD $FF $FF $FF $F7 $FF $5F $DF $F7 $FF $FF $FF $DF $FF $7F $FF $FD $FF $FF $F7 $7F $FF $FF $FF $D5 $FF $FF $FF $FF $FF $F7 $FF $F7 $BF $FF $BF $7F $FF $FF $FF $F7 $FF $FF $FF $DF $FF $FF $FF $77 $00 $00 $00 $00 $00 $00 $00 $10 $00 $00 $00 $04 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $40 $00 $50 $00 $00 $00 $44 $00 $00 $00 $00 $00 $00 $00 $14 $00 $40 $00 $40 $00 $04 $00 $14 $00 $00 $00 $10 $00 $10 $00 $40 $00 $10 $00 $10 $00 $00 $00 $10 $00 $00 $00 $00 $00 $00 $00 $00 $00 $50 $00 $04 $00 $00 $40 $44 $00 $00 $40 $10 $00 $00 $00 $04 $00 $00 $00 $14 $00 $01 $00 $40 $00 $00 $00 $11 $00 $44 $00 $50 $00 $00 $00 $44 $00 $04 $00 $10 $00 $00 $00 $04 $00 $50 $00 $10 $00 $00 $00 $00 $00 $00 $00 $00 $FF $FF $FF $F5 $FF $FD $FF $FD $FF $FF $FF $F7 $FF $FD $DF $F7 $FF $FD $77 $DF $FF $FF $FF $DF $FF $FF $FF $DF $DD $FD $F7 $D7 $FF $DF $FF $DD $FF $7F $FF $DF $FF $7F $FF $7F $FF $FF $FF $7F $FF $FD $FF $DF $FF $5F $FF $F7 $FF $FF $DD $57 $FF $DF $FF $7F $FF $DF $FF $FD $FF $DF $FF $D5 $FF $FF $FF $FF $FF $F7 $DF $77 $FF $D7 $FF $57 $FF $FF $FF $7F $FF $FF $FF $7F $FF $DF $FF $DD $FF $FF $FF $7D $FF $77 $FD $FF $FF $FF $FF $FF $FF $DD $FF $FD $FF $F7 $FF $FD $FF $7F $FD $7D $BF $FF $FF $FD $FF $F7 $F7
.endif

  BankMarker

.BANK 8
.ORG $0000
.section "Warriors data index" force
.dstruct DATA_20000_TrackData_Warriors instanceof TrackData data  DATA_9D30_Warriors_BehaviourData DATA_A01A_Warriors_WallData DATA_A10F_Warriors_Track0Layout DATA_A3B8_Warriors_Track1Layout DATA_A67C_Warriors_Track2Layout DATA_A67C_Warriors_Track3Layout DATA_A924_Warriors_GGPalette DATA_A964_Warriors_DecoratorTiles DATA_A9E4_WarriorsDATA DATA_AA24_Warriors_EffectsTiles
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $ED $45 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $ED $45 $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF
.endif

.orga $8080
.section "LABEL_8080_Warriors_Metatiles" force
LABEL_8080_Warriors_Metatiles:
.incbin "Assets/Warriors/Metatiles.tilemap"
.ends

.section "DATA_9D30_Warriors_BehaviourData" force
DATA_9D30_Warriors_BehaviourData:
.incbin "Assets/Warriors/Behaviour data.compressed"
.ends

.section "DATA_A01A_Warriors_WallData" force
DATA_A01A_Warriors_WallData:
.incbin "Assets/Warriors/Wall data.compressed"
.ends

.section "DATA_A10F_Warriors_Track0Layout" force
DATA_A10F_Warriors_Track0Layout:
.incbin "Assets/Warriors/Track 0 layout.compressed"
.ends

.section "DATA_A3B8_Warriors_Track1Layout" force
DATA_A3B8_Warriors_Track1Layout:
.incbin "Assets/Warriors/Track 1 layout.compressed"
.ends

.section "DATA_A67C_Warriors_Track2Layout" force
DATA_A67C_Warriors_Track2Layout: 
DATA_A67C_Warriors_Track3Layout: ; missing
.incbin "Assets/Warriors/Track 2 layout.compressed"
.ends

.section "DATA_A924_Warriors_GGPalette" force
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
.ends

.section "DATA_A964_Warriors_DecoratorTiles" force
DATA_A964_Warriors_DecoratorTiles:
.incbin "Assets/Warriors/Decorators.1bpp"
.ends

.section "DATA_A9E4_WarriorsDATA" force
DATA_A9E4_WarriorsDATA:
.db $00 $00 $80 $80 $22 $22 $A0 $A0 $73 $73 $73 $C0 $77 $77 $73 $22 $00 $00 $22 $49 $49 $C0 $45 $45 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $22 $C0 $C0 $C0 $80 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $22 $C0 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.ends

.section "DATA_AA24_Warriors_EffectsTiles" force
DATA_AA24_Warriors_EffectsTiles:
.incbin "Assets/Warriors/Effects.3bpp"
.ends

.section "DATA_22B2C_Tiles_PunctuationAndLine" force
DATA_22B2C_Tiles_PunctuationAndLine:
.incbin "Assets/Menu/PunctuationAndLine.3bpp"
.ends

.section "DATA_22B8C_Tiles_ColouredBalls" force
DATA_22B8C_Tiles_ColouredBalls:
.incbin "Assets/Menu/Balls.3bpp"
.ends

.section "DATA_22BEC_Tiles_Cursor" force
DATA_22BEC_Tiles_Cursor:
.incbin "Assets/Menu/Cursor.3bpp.compressed"
.ends

.section "DATA_22C4E_Tiles_BigLogo" force
DATA_22C4E_Tiles_BigLogo:
.incbin "Assets/Menu/Logo-big.3bpp.compressed"
.ends

.section "DATA_23656_Tiles_VsCPUPatch" force
DATA_23656_Tiles_VsCPUPatch:
.incbin "Assets/Menu/Icon-VsCPUPatch.3bpp.compressed"
.ends

.section "PagedFunction_237E2_" force
PagedFunction_237E2_:
  xor a
  ld (_RAM_DCAB_CarData_Green.TankShotSpriteIndex), a
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.TankShotSpriteIndex), a
  ld a, $02
  ld (_RAM_DD2D_CarData_Yellow.TankShotSpriteIndex), a
  
  ld hl, _RAM_DD6E_CarEffects.2.Sprites.1.Data.1.X
  ld (_RAM_DCAB_CarData_Green.Unknown34_w), hl
  ld hl, _RAM_DD6E_CarEffects.3.Sprites.1.Data.1.X
  ld (_RAM_DCEC_CarData_Blue.Unknown34_w), hl
  ld hl, _RAM_DD6E_CarEffects.4.Sprites.1.Data.1.X
  ld (_RAM_DD2D_CarData_Yellow.Unknown34_w), hl
  
  ; Sprite indexes used for bullets?
  ld a, $38
  ld (_RAM_DD6E_CarEffects.1.TileBaseIndex), a
  ld a, $3A
  ld (_RAM_DD6E_CarEffects.2.TileBaseIndex), a
  ld a, $3C
  ld (_RAM_DD6E_CarEffects.3.TileBaseIndex), a
  ld a, $3E
  ld (_RAM_DD6E_CarEffects.4.TileBaseIndex), a
  
  ld hl, _RAM_DE5F_GreenCar_
  ld (_RAM_DCAB_CarData_Green.Unknown39_w), hl
  ld hl, _RAM_DE60_BlueCar_
  ld (_RAM_DCEC_CarData_Blue.Unknown39_w), hl
  ld hl, _RAM_DE61_YellowCar
  ld (_RAM_DD2D_CarData_Yellow.Unknown39_w), hl
  
  ld hl, _RAM_DE31_CarUnknowns.1.Unknown1
  ld (_RAM_DCAB_CarData_Green.Unknown47_w), hl
  ld hl, _RAM_DE31_CarUnknowns.2.Unknown1
  ld (_RAM_DCEC_CarData_Blue.Unknown47_w), hl
  ld hl, _RAM_DE31_CarUnknowns.3.Unknown1
  ld (_RAM_DD2D_CarData_Yellow.Unknown47_w), hl

  ld a, (_RAM_DC55_TrackIndex_Game)
  sla a
  ld b, a

  ; Index *2
  ld e, a
  ld d, 0
  ld hl, _DATA_238DE_OpponentSpeedChangeThresholdsPerTrack
  add hl, de
  ld a, (hl)
  ld (_RAM_DB66_MetatilesBehindSpeedUpThreshold), a
  inc hl
  ld a, (hl)
  ld (_RAM_DB67_MetatilesAheadSlowDownThreshold), a

  ; Index *6
  ld a, b
  sla a
  ld l, a
  ld h, $00
  add hl, de
  ld de, _DATA_23918_OpponentTopSpeedsPerTrack
  add hl, de
  exx
    ld c, 6
  exx
  ld a, (_RAM_DC46_Cheat_HardMode)
  ld c, a ; +1 for hard mode, +2 for rock hard mode
  ld a, (_RAM_DC54_IsGameGear)
  xor 1
  sla a ; +2 for SMS, 0 for GG
  ld b, a
  ld de, _RAM_DB68_OpponentTopSpeeds
-:; High nibble + adjustment
  ld a, (hl)
  srl a
  srl a
  srl a
  srl a
  add a, b
  add a, c
  cp MAX_OPPONENT_SPEED + 1
  jr c, +
  ld a, MAX_OPPONENT_SPEED ; Maximum $d
+:ld (de), a

  inc de
  ; Low nibble + adjustment
  ld a, (hl)
  and $0F
  add a, b
  add a, c
  cp MAX_OPPONENT_SPEED + 1
  jr c, +
  ld a, MAX_OPPONENT_SPEED
+:ld (de), a

  inc de
  inc hl
  exx
    dec c
  exx
  ; Loop over 6 bytes -> 12 nibbles
  jr nz, -
  ; 
  ld a, (_RAM_DB68_OpponentTopSpeeds.Green.High)
  ld (_RAM_DCAB_CarData_Green.TopSpeed), a
  ld a, (_RAM_DB68_OpponentTopSpeeds.Blue.High)
  ld (_RAM_DCEC_CarData_Blue.TopSpeed), a
  ld a, (_RAM_DB68_OpponentTopSpeeds.Yellow.High)
  ld (_RAM_DD2D_CarData_Yellow.TopSpeed), a
  ld a, (_RAM_DB97_TrackType)
  ld e, a
  ld d, $00
  ld hl, _DATA_238D5_
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
  ld (_RAM_DD2D_CarData_Yellow.Unknown50_b), a
  sub b
  ld (_RAM_DCAB_CarData_Green.Unknown50_b), a
  sub b
  ld (_RAM_DCEC_CarData_Blue.Unknown50_b), a
  ret

; Data from 238D5 to 238DD (9 bytes)
_DATA_238D5_:
.db $08 $07 $09 $08 $09 $08 $04 $05 $05

; Data from 238DE to 239C5 (232 bytes)
_DATA_238DE_OpponentSpeedChangeThresholdsPerTrack: ; indexed by _RAM_DC55_TrackIndex_Game*2 and copied to _RAM_DB66_MetatilesBehindSpeedUpThreshold, _RAM_DB67_MetatilesAheadSlowDownThreshold
; They are all the same...
; These are related to the way opponent top speeds get selected
.repeat 29
.db $02 $02
.endr

_DATA_23918_OpponentTopSpeedsPerTrack: ; indexed by _RAM_DC55_TrackIndex_Game*6, split to nibbles and sent to _RAM_DB68_OpponentTopSpeeds+
;    ,,--,,-- End up in _RAM_DCAB_CarData_Green.TopSpeed
;    ||  ||  ,,--,,-- End up in _RAM_DCEC_CarData_Blue.TopSpeed
;    ||  ||  ||  ||  ,,--,,-- End up in _RAM_DD2D_CarData_Yellow.TopSpeed
.db $54 $42 $65 $53 $54 $42 ; $9 ; Top speeds for some index 0..3 for each car (packed nibbles)
.db $54 $43 $65 $54 $54 $43 ; $8 ; Compare to player 1 top speeds at DATA_76A4_TrackList_TopSpeeds_SMS in the comments here
.db $86 $63 $75 $52 $75 $52 ; $B ; +1 for hard mode
.db $87 $75 $87 $75 $76 $65 ; $A ; +2 for rock hard mode
.db $A9 $97 $A9 $87 $98 $86 ; $B ; +2 for SMS (raw are for GG)
.db $87 $75 $77 $66 $76 $65 ; $9 ; Clamped to $0d though
.db $98 $87 $A9 $88 $88 $76 ; $B
.db $A9 $88 $98 $87 $88 $77 ; $A ; start seeing equally fast opponents
.db $87 $76 $99 $87 $87 $66 ; $9
.db $AA $98 $BB $A9 $A9 $87 ; $B
.db $87 $76 $88 $77 $76 $66 ; $8
.db $98 $77 $98 $88 $87 $66 ; $9
.db $97 $65 $A8 $76 $87 $76 ; $9 ; start seeing faster opponents
.db $76 $65 $86 $66 $66 $55 ; $7
.db $AA $87 $AA $98 $98 $77 ; $B
.db $CB $A9 $CC $BB $A9 $87 ; $B
.db $A9 $97 $BA $98 $CB $A9 ; $B
.db $76 $65 $76 $65 $65 $55 ; $8
.db $98 $87 $CB $A9 $BA $98 ; $A
.db $86 $66 $87 $76 $76 $65 ; $7
.db $CC $BB $CB $A9 $A9 $87 ; $B
.db $A9 $87 $BA $98 $97 $66 ; $9
.db $76 $65 $76 $65 $65 $55 ; $8
.db $BB $A9 $BB $AA $AA $98 ; $B
.db $87 $76 $88 $76 $77 $66 ; $7
.db $CC $CC $CC $BA $CB $A9 ; $B ; Final - green is always faster
.db $66 $66 $66 $66 $66 $66 ; $8 ; Bonus - values not used
.db $66 $66 $66 $66 $66 $66 ; $8
.db $66 $66 $66 $66 $66 $66 ; $8

.ends

.section "PagedFunction_239C6_" force
PagedFunction_239C6_:
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
  DEC_A
  ld (_RAM_D5B9_), a
+:
  call _LABEL_23A91_
  ld a, (_RAM_DF84_BubblePush_Sign_X)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown33_b)
  cp l
  jr z, ++
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  ld l, a
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  jp +++

+:
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  ld a, (_RAM_DF84_BubblePush_Sign_X)
  ld (_RAM_DCEC_CarData_Blue.Unknown33_b), a
  jp +++

++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  ld l, a
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
+++:
  ld a, (_RAM_DF85_BubblePush_Sign_Y)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown32_b)
  cp l
  jr z, ++
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  ld l, a
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  ld a, (_RAM_DF85_BubblePush_Sign_Y)
  ld (_RAM_DCEC_CarData_Blue.Unknown32_b), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  ld l, a
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  JpRet +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+++:ret

_LABEL_23A91_:
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
  ld hl, DATA_3FC3_HorizontalAmountByDirection
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
  ld (_RAM_DF82_BubblePush_Strength_X), a
  ld hl, DATA_40E5_Sign_Directions_X
  ld a, (_RAM_D5B8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
  jr z, +
  xor a
  ld (_RAM_DF84_BubblePush_Sign_X), a
  ld a, (_RAM_DCEC_CarData_Blue)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.XPosition+1)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (_RAM_DCEC_CarData_Blue), a
  ld a, h
  ld (_RAM_DCEC_CarData_Blue.XPosition+1), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF84_BubblePush_Sign_X), a
  ld a, (_RAM_DCEC_CarData_Blue)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.XPosition+1)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF82_BubblePush_Strength_X)
  ld e, a
  add hl, de
  ld a, l
  ld (_RAM_DCEC_CarData_Blue), a
  ld a, h
  ld (_RAM_DCEC_CarData_Blue.XPosition+1), a
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
  ld hl, DATA_3FD3_VerticalAmountByDirection
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
  ld (_RAM_DF83_BubblePush_Strength_Y), a
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (_RAM_D5B8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  CP_0
  jr z, +
  xor a
  ld (_RAM_DF85_BubblePush_Sign_Y), a
  ld a, (_RAM_DCEC_CarData_Blue.YPosition)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.YPosition+1)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (_RAM_DCEC_CarData_Blue.YPosition), a
  ld a, h
  ld (_RAM_DCEC_CarData_Blue.YPosition+1), a
  ret

+:
  ld a, $01
  ld (_RAM_DF85_BubblePush_Sign_Y), a
  ld a, (_RAM_DCEC_CarData_Blue.YPosition)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.YPosition+1)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF83_BubblePush_Strength_Y)
  ld e, a
  add hl, de
  ld a, l
  ld (_RAM_DCEC_CarData_Blue.YPosition), a
  ld a, h
  ld (_RAM_DCEC_CarData_Blue.YPosition+1), a
  ret
.ends

.section "Blank game RAM" force
PagedFunction_23B98_BlankGameRAM:
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
.ends

.section "PagedFunction_23BC6_" force
PagedFunction_23BC6_:
  ld a, (_RAM_DF6C_)
  INC_A
  and $01
  ld (_RAM_DF6C_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF5A_CarState3)
  cp CarState_4_Submerged
  jr z, +
--:
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  INC_A
-:
  and $0F
  ld (_RAM_DCAB_CarData_Green.Direction), a
  ret

+:
  ld a, (_RAM_DCAB_CarData_Green.Direction)
  cp $08
  jr nc, --
  DEC_A
  jp -
.ends

.section "PagedFunction_23BF1_" force
PagedFunction_23BF1_:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, ++
  ld hl, (_RAM_DBA9_)
  ld de, $0074
  add hl, de
  ld (_RAM_DCAB_CarData_Green.XPosition), hl
  ld hl, (_RAM_DBA9_)
  ld de, $0090
  add hl, de
  ld (_RAM_DCEC_CarData_Blue), hl
  ld (_RAM_DD2D_CarData_Yellow), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0040
  add hl, de
  ld (_RAM_DCAB_CarData_Green.YPosition), hl
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0068
  add hl, de
  ld (_RAM_DD2D_CarData_Yellow.YPosition), hl
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
+:ret

++:
  ld hl, (_RAM_DBA9_)
  ld de, $0014
  add hl, de
  ld (_RAM_DCAB_CarData_Green.XPosition), hl
  ld hl, (_RAM_DBA9_)
  ld de, $0030
  add hl, de
  ld (_RAM_DCEC_CarData_Blue), hl
  ld (_RAM_DD2D_CarData_Yellow), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0040
  add hl, de
  ld (_RAM_DCAB_CarData_Green.YPosition), hl
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
  ld hl, (_RAM_DBAB_)
  ld de, $0068
  add hl, de
  ld (_RAM_DD2D_CarData_Yellow.YPosition), hl
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
+:ret
.ends

.section "Read GG pause button" force
PagedFunction_23C68_ReadGGPauseButton:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  ; could ret z
  jr nz, +
-:ret

+:ld a, (_RAM_DC41_GearToGearActive)
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
  SetPSGAttenuationImmediate 3, 0
  SetPSGAttenuationImmediate 0, 0
  SetPSGAttenuationImmediate 1, 0
  SetPSGAttenuationImmediate 2, 0
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
.ends

.section "Update animated palette" force
PagedFunction_23CE6_UpdateAnimatedPalette:
  ; Updates the top half of the tile palette for Powerboats and Choppers levels
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, LABEL_23D4B_SMS_UpdateAnimatedPalette_SMS

  ; GG
  ld a, (_RAM_DB97_TrackType)
  cp TT_8_Choppers
  jr z, +
  cp TT_2_Powerboats
  jr z, ++
  ret

+:; Choppers (unused)
  ld hl, DATA_1D25_ChoppersAnimatedPalette_GG
  ld (_RAM_DF77_PaletteAnimationData), hl
  jp +++

++:; Powerboats
  ld hl, DATA_1D35_PowerboatsAnimatedPalette_GG
  ld (_RAM_DF77_PaletteAnimationData), hl
+++:
  ; Update every fourth frame
  ld a, (_RAM_DF76_PaletteAnimationCounter)
  INC_A
  and 3
  ld (_RAM_DF76_PaletteAnimationCounter), a
  jr z, +
  ret

+:
  ld de, PALETTE_WRITE_MASK + 15 * PALETTE_ENTRY_SIZE_GG ; $C01E ; Palette entry 15
-:; Set palette address
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ld hl, (_RAM_DF77_PaletteAnimationData) ; Read in palette pointer
  ld a, (_RAM_DF75_PaletteAnimationDataOffset) ; And the offset within it
  ld c, a
  ld b, 0
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_DATA), a
  ld a, (_RAM_DF75_PaletteAnimationDataOffset)
  add a, PALETTE_ENTRY_SIZE_GG
  and _sizeof_DATA_1D25_ChoppersAnimatedPalette_GG - 1
  ld (_RAM_DF75_PaletteAnimationDataOffset), a
  ; Move to the previous palette entry
  ld a, e
  sub PALETTE_ENTRY_SIZE_GG
  ld e, a
  cp 7 * 2 ; Loop until entry 7 (not inclusive)
  jr nz, -
  ; Increment the offset so we start one position further on next time
  ld a, (_RAM_DF75_PaletteAnimationDataOffset)
  add a, PALETTE_ENTRY_SIZE_GG
  and _sizeof_DATA_1D25_ChoppersAnimatedPalette_GG - 1
  ld (_RAM_DF75_PaletteAnimationDataOffset), a
  ret

LABEL_23D4B_SMS_UpdateAnimatedPalette_SMS:
  ld a, (_RAM_DB97_TrackType)
  cp TT_8_Choppers
  jr z, +
  cp TT_2_Powerboats
  jr z, ++
  ret

+:
  ld hl, DATA_23DA6_ChoppersAnimatedPalette_SMS
  ld (_RAM_DF77_PaletteAnimationData), hl
  jp +++

++:
  ld hl, DATA_23DAE_PowerboatsAnimatedPalette_SMS
  ld (_RAM_DF77_PaletteAnimationData), hl
+++:
  ld a, (_RAM_DF76_PaletteAnimationCounter)
  INC_A
  and $03
  ld (_RAM_DF76_PaletteAnimationCounter), a
  jr z, +
  ret

+:
  ld de, PALETTE_WRITE_MASK | 15 * PALETTE_ENTRY_SIZE_SMS ; $C00F ; Palette entry $f
-:; Set palette address
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ld hl, (_RAM_DF77_PaletteAnimationData)
  ld a, (_RAM_DF75_PaletteAnimationDataOffset) ; Look up index
  ld c, a
  ld b, 0
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_DATA), a ; Emit
  ld a, (_RAM_DF75_PaletteAnimationDataOffset) ; Increment index
  add a, PALETTE_ENTRY_SIZE_SMS
  and _sizeof_DATA_23DA6_ChoppersAnimatedPalette_SMS - 1
  ld (_RAM_DF75_PaletteAnimationDataOffset), a
  ld a, e ; Decrement palette pointer
  sub PALETTE_ENTRY_SIZE_SMS
  ld e, a
  cp $07
  jr nz, - ; Repeat until index 7 (not inclusive)
  ld a, (_RAM_DF75_PaletteAnimationDataOffset) ; Increment index another time
  add a, PALETTE_ENTRY_SIZE_SMS
  and _sizeof_DATA_23DA6_ChoppersAnimatedPalette_SMS - 1
  ld (_RAM_DF75_PaletteAnimationDataOffset), a
  ret

; Data from 23DA6 to 23DB5 (16 bytes)
DATA_23DA6_ChoppersAnimatedPalette_SMS
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
.ends

.section "Clear tilemap" force
PagedFunction_23DB6_ClearTilemap:
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
  ld bc, TILEMAP_ROW_SIZE * 2 ; $0080
-:EmitDataToVDPImmediate16 $0014
  dec bc
  ld a, b
  or c
  jr nz, -
  ret
.ends

.section "DATA_23DE7_HandlingData_SMS" force
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
.db $11 $14 $8B $DF $FF $FF $FF $FF ; Choppers
.db $11 $11 $11 $24 $66 $66 $66 $66 ; FourByFour 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Tanks 
.db $11 $11 $11 $24 $68 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $14 $69 $CD $DD $DD ; SportsCars 
.db $11 $11 $11 $47 $AC $DD $DD $DD ; TurboWheels
.db $11 $14 $8B $DF $FF $FF $FF $FF ; Choppers
.db $11 $11 $45 $79 $BD $DD $DD $DD ; Warriors 
.db $11 $11 $11 $11 $12 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $14 $69 $CD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $14 $8B $DF $FF $FF $FF $FF ; Choppers
.db $11 $11 $11 $24 $68 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $11 $12 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $14 $69 $CD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux
.ends

.section "DATA_23ECF_HandlingData_GG" force
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
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Choppers
.db $11 $11 $12 $46 $66 $66 $66 $66 ; FourByFour 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Tanks 
.db $11 $11 $12 $46 $89 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $46 $9C $DD $DD $DD ; SportsCars 
.db $11 $11 $14 $7A $CD $DD $DD $DD ; TurboWheels
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Choppers
.db $11 $14 $57 $9B $DD $DD $DD $DD ; Warriors 
.db $11 $11 $11 $11 $23 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $46 $9C $DD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Powerboats 
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Choppers
.db $11 $11 $12 $46 $89 $99 $99 $99 ; FormulaOne 
.db $11 $11 $11 $11 $23 $33 $33 $33 ; Tanks 
.db $11 $11 $11 $46 $9C $DD $DD $DD ; SportsCars 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux 
.db $11 $11 $11 $11 $11 $11 $11 $11 ; RuffTrux
.ends

.ifdef BLANK_FILL_ORIGINAL
.repeat 18
.db $FF $FF $00 $00
.endr
.endif

  BankMarker

.BANK 9
.ORG $0000

.section "Tanks data index" force
.dstruct DATA_24000_TrackData_Tanks instanceof TrackData data  DATA_9F70_Tanks_BehaviourData DATA_A32A_Tanks_WallData DATA_A42C_Tanks_Track0Layout DATA_A5A6_Tanks_Track1Layout DATA_A7D4_Tanks_Track2Layout DATA_A7D4_Tanks_Track3Layout DATA_AA4A_Tanks_GGPalette DATA_AA8A_Tanks_DecoratorTiles DATA_AB0A_TanksDATA DATA_AB4A_Tanks_EffectsTiles
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $ED $45 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $ED $45 $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF
.endif

.orga $8080
.section "DATA_8080_Tanks_Metatiles" force
DATA_8080_Tanks_Metatiles:
.incbin "Assets/Tanks/Metatiles.tilemap"
.ends

.section "DATA_9F70_Tanks_BehaviourData" force
DATA_9F70_Tanks_BehaviourData:
.incbin "Assets/Tanks/Behaviour data.compressed"
.ends

.section "DATA_A32A_Tanks_WallData" force
DATA_A32A_Tanks_WallData:
.incbin "Assets/Tanks/Wall data.compressed"
.ends

.section "DATA_A42C_Tanks_Track0Layout" force
DATA_A42C_Tanks_Track0Layout:
.incbin "Assets/Tanks/Track 0 layout.compressed"
.ends

.section "DATA_A5A6_Tanks_Track1Layout" force
DATA_A5A6_Tanks_Track1Layout:
.incbin "Assets/Tanks/Track 1 layout.compressed"
.ends

.section "DATA_A7D4_Tanks_Track2Layout" force
DATA_A7D4_Tanks_Track2Layout:
DATA_A7D4_Tanks_Track3Layout:
.incbin "Assets/Tanks/Track 2 layout.compressed"
.ends

.section "DATA_AA4A_Tanks_GGPalette" force
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
.ends

.section "DATA_AA8A_Tanks_DecoratorTiles" force
DATA_AA8A_Tanks_DecoratorTiles:
.incbin "Assets/Tanks/Decorators.1bpp"
.ends

.section "DATA_AB0A_TanksDATA" force
DATA_AB0A_TanksDATA:
.db $22 $00 $63 $41 $63 $41 $49 $45 $77 $73 $22 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $C0 $E0 $C0 $E0 $A2 $C0 $A0 $A0 $A0 $A0 $80 $A0 $80 $A0 $A0 $A0 $8A $A0 $80 $8A $A0 $80 $82 $C0 $A0 $A0 $C0 $22 $A0 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.ends

.section "DATA_AB4A_Tanks_EffectsTiles" force
DATA_AB4A_Tanks_EffectsTiles:
.incbin "Assets/Tanks/Effects.3bpp"
.ends

.section "DATA_26C52_Tiles_Challenge_Icon" force
DATA_26C52_Tiles_Challenge_Icon:
.incbin "Assets/Menu/Icon-Challenge.3bpp.compressed"
.ends

.section "DATA_26FC6_Tiles_HeadToHead_Icon" force
DATA_26FC6_Tiles_HeadToHead_Icon:
.incbin "Assets/Menu/Icon-HeadToHead.3bpp.compressed"
.ends

.section "DATA_27391_Tiles_Tournament_Icon" force
DATA_27391_Tiles_Tournament_Icon:
.incbin "Assets/Menu/Icon-Tournament.3bpp.compressed"
.ends

.section "DATA_27674_Tiles_SingleRace_Icon" force
DATA_27674_Tiles_SingleRace_Icon:
.incbin "Assets/Menu/Icon-SingleRace.3bpp.compressed"
.ends

.section "DATA_2794C_Tiles_MediumNumbers" force
DATA_2794C_Tiles_MediumNumbers:
.incbin "Assets/Menu/Numbers-Medium.3bpp.compressed"
.ends

.section "DATA_279F0_Tilemap_Trophy" force
DATA_279F0_Tilemap_Trophy:
.incbin "Assets/Menu/Trophy.tilemap.compressed"
.ends

.section "DATA_27A12_Tiles_TwoPlayersOnOneGameGear_Icon" force
DATA_27A12_Tiles_TwoPlayersOnOneGameGear_Icon:
.incbin "Assets/Menu/Icon-TwoPlayersOnOneGameGear.4bpp.compressed"
.ends

.ifdef BLANK_FILL_ORIGINAL
.rept 65
.db $ff $ff $00 $00 ; Empty
.endr
.endif

  BankMarker

.BANK 10
.ORG $0000
.section "RuffTrux data index" force
.dstruct DATA_28000_TrackData_RuffTrux instanceof TrackData data  DATA_A1B0_RuffTrux_BehaviourData DATA_A396_RuffTrux_WallData DATA_A420_RuffTrux_Track0Layout DATA_A5F0_RuffTrux_Track1Layout DATA_A7A8_RuffTrux_Track2Layout DATA_A7A8_RuffTrux_Track3Layout DATA_A9C5_RuffTrux_GGPalette DATA_A9C5_RuffTrux_DecoratorTiles DATA_AA05_RuffTruxDATA DATA_AA45_RuffTrux_EffectsTiles
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $ED $45 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $ED $45 $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF
.endif

.orga $8080
.section "DATA_8080_RuffTrux_Metatiles" force
DATA_8080_RuffTrux_Metatiles:
.incbin "Assets/RuffTrux/Metatiles.tilemap" ; 64 metatiles
.ends

.section "DATA_A1B0_RuffTrux_BehaviourData" force
DATA_A1B0_RuffTrux_BehaviourData:
.incbin "Assets/RuffTrux/Behaviour data.compressed"
.ends

.section "DATA_A396_RuffTrux_WallData" force
DATA_A396_RuffTrux_WallData:
.incbin "Assets/RuffTrux/Wall data.compressed"
.ends

.section "DATA_A420_RuffTrux_Track0Layout" force
DATA_A420_RuffTrux_Track0Layout:
.incbin "Assets/RuffTrux/Track 0 layout.compressed"
.ends

.section "DATA_A5F0_RuffTrux_Track1Layout" force
DATA_A5F0_RuffTrux_Track1Layout:
.incbin "Assets/RuffTrux/Track 1 layout.compressed"
.ends

.section "DATA_A7A8_RuffTrux_Track2Layout" force
DATA_A7A8_RuffTrux_Track2Layout:
DATA_A7A8_RuffTrux_Track3Layout: ; no data
.incbin "Assets/RuffTrux/Track 2 layout.compressed"
.ends

.section "DATA_A9C5_RuffTrux_GGPalette" force
DATA_A9C5_RuffTrux_GGPalette:
DATA_A9C5_RuffTrux_DecoratorTiles: ; no data
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
.ends

.section "DATA_AA05_RuffTruxDATA" force
DATA_AA05_RuffTruxDATA:
.db $C0 $C0 $00 $00 $22 $22 $49 $45 $73 $77 $80 $00 $22 $22 $A0 $C0 $C0 $C0 $C0 $22 $E0 $A0 $A0 $A0 $A0 $A0 $A0 $E0 $E0 $A0 $00 $A0 $E0 $C0 $A0 $80 $80 $A0 $A0 $A0 $C0 $C0 $E0 $E0 $A0 $A0 $80 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $22 $22 $A0 $00 $00 $00 $00 $00
.ends

.section "DATA_AA45_RuffTrux_EffectsTiles" force
DATA_AA45_RuffTrux_EffectsTiles:
.incbin "Assets/RuffTrux/Effects.3bpp"
.ends

.section "DATA_2AB4D_Tiles_Portrait_RuffTrux" force
DATA_2AB4D_Tiles_Portrait_RuffTrux:
.incbin "Assets/RuffTrux/Portrait.3bpp.compressed"
.ends

.section "DATA_2B02D_Tiles_Font" force
DATA_2B02D_Tiles_Font:
.incbin "Assets/Menu/Font.3bpp.compressed"
.ends

.section "DATA_2B151_Tiles_Hand" force
DATA_2B151_Tiles_Hand:
.incbin "Assets/Menu/Hand.3bpp.compressed"
.ends

.section "DATA_2B33E_SpriteNs_Hand" force
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
.ends

.section "DATA_2B386_Tiles_ChallengeText" force
DATA_2B386_Tiles_ChallengeText:
.incbin "Assets/Menu/Text-Challenge.3bpp.compressed"
.ends

.section "DATA_2B4BA_Tilemap_ChallengeText" force
DATA_2B4BA_Tilemap_ChallengeText:
.incbin "Assets/Menu/Text-Challenge.tilemap"
.ends

.section "DATA_2B4CA_Tiles_HeadToHeadText" force
DATA_2B4CA_Tiles_HeadToHeadText:
.incbin "Assets/Menu/Text-HeadtoHead.3bpp.compressed"
.ends

.section "DATA_2B5BE_Tilemap_HeadToHeadText" force
DATA_2B5BE_Tilemap_HeadToHeadText:
.incbin "Assets/Menu/Text-HeadtoHead.tilemap"
.ends

.include "SFX engine.asm"

.ifdef BLANK_FILL_ORIGINAL
.repeat $174/4
.db $ff $ff $00 $00
.endr
.endif

  BankMarker

.BANK 11
.ORG $0000
DATA_2C000_TrackData_Choppers_BadReference:

; It looks like these could all be superfree...
.section "DATA_Tiles_Anne_Happy" force
DATA_Tiles_Anne_Happy:
.incbin "Assets/Racers/Anne-Happy.3bpp"
.ends
.section "DATA_Tiles_Anne_Sad" force
DATA_Tiles_Anne_Sad:
.incbin "Assets/Racers/Anne-Sad.3bpp"
.ends
.section "DATA_Tiles_Bonnie_Happy" force
DATA_Tiles_Bonnie_Happy:
.incbin "Assets/Racers/Bonnie-Happy.3bpp"
.ends
.section "DATA_Tiles_Bonnie_Sad" force
DATA_Tiles_Bonnie_Sad:
.incbin "Assets/Racers/Bonnie-Sad.3bpp"
.ends
.section "DATA_Tiles_Chen_Happy" force
DATA_Tiles_Chen_Happy:
.incbin "Assets/Racers/Chen-Happy.3bpp"
.ends
.section "DATA_Tiles_Chen_Sad" force
DATA_Tiles_Chen_Sad:
.incbin "Assets/Racers/Chen-Sad.3bpp"
.ends
.section "DATA_Tiles_Cherry_Happy" force
DATA_Tiles_Cherry_Happy:
.incbin "Assets/Racers/Cherry-Happy.3bpp"
.ends
.section "DATA_Tiles_Cherry_Sad" force
DATA_Tiles_Cherry_Sad:
.incbin "Assets/Racers/Cherry-Sad.3bpp"
.ends
.section "DATA_Tiles_Dwayne_Happy" force
DATA_Tiles_Dwayne_Happy:
.incbin "Assets/Racers/Dwayne-Happy.3bpp"
.ends
.section "DATA_Tiles_Dwayne_Sad" force
DATA_Tiles_Dwayne_Sad:
.incbin "Assets/Racers/Dwayne-Sad.3bpp"
.ends
.section "DATA_Tiles_Emilio_Happy" force
DATA_Tiles_Emilio_Happy:
.incbin "Assets/Racers/Emilio-Happy.3bpp"
.ends
.section "DATA_Tiles_Emilio_Sad" force
DATA_Tiles_Emilio_Sad:
.incbin "Assets/Racers/Emilio-Sad.3bpp"
.ends
.section "DATA_Tiles_Jethro_Happy" force
DATA_Tiles_Jethro_Happy:
.incbin "Assets/Racers/Jethro-Happy.3bpp"
.ends
.section "DATA_Tiles_Jethro_Sad" force
DATA_Tiles_Jethro_Sad:
.incbin "Assets/Racers/Jethro-Sad.3bpp"
.ends
.section "DATA_Tiles_Joel_Happy" force
DATA_Tiles_Joel_Happy:
.incbin "Assets/Racers/Joel-Happy.3bpp"
.ends
.section "DATA_Tiles_Joel_Sad" force
DATA_Tiles_Joel_Sad:
.incbin "Assets/Racers/Joel-Sad.3bpp"
.ends
.section "DATA_Tiles_Mike_Happy" force
DATA_Tiles_Mike_Happy:
.incbin "Assets/Racers/Mike-Happy.3bpp"
.ends
.section "DATA_Tiles_Mike_Sad" force
DATA_Tiles_Mike_Sad:
.incbin "Assets/Racers/Mike-Sad.3bpp"
.ends
.section "DATA_Tiles_Spider_Happy" force
DATA_Tiles_Spider_Happy:
.incbin "Assets/Racers/Spider-Happy.3bpp"
.ends
.section "DATA_Tiles_Spider_Sad" force
DATA_Tiles_Spider_Sad:
.incbin "Assets/Racers/Spider-Sad.3bpp"
.ends
.section "DATA_Tiles_Walter_Happy" force
DATA_Tiles_Walter_Happy:
.incbin "Assets/Racers/Walter-Happy.3bpp"
.ends
.section "DATA_Tiles_Walter_Sad" force
DATA_Tiles_Walter_Sad:
.incbin "Assets/Racers/Walter-Sad.3bpp"
.ends

.section "DATA_2FDE0_Tiles_SmallLogo" force
DATA_2FDE0_Tiles_SmallLogo:
.incbin "Assets/Menu/Logo-small.3bpp.compressed"
.ends

.section "DATA_2FF6F_Tilemap" force
DATA_2FF6F_Tilemap:
.incbin "Assets/Menu/Logo-big.tilemap.compressed"
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $00 $FF $FF $00 $00
.endif

  BankMarker

.BANK 12
.ORG $0000
DATA_30000_CarTiles_Choppers_BadReference:

.section "Formula One car tiles" force
; Data from 30000 to 30A67 (2664 bytes)
DATA_30000_CarTiles_FormulaOne:
.incbin "Assets/Formula One/Car.3bpp.runencoded"
.ends
  Pad 4 ; Unneeded padding from manual placement?
.section "Warriors car tiles" force
DATA_30330_CarTiles_Warriors:
.incbin "Assets/Warriors/Car.3bpp.runencoded"
.ends
  Pad 4
.section "Tanks car tiles" force
DATA_306D0_CarTiles_Tanks:
.incbin "Assets/Tanks/Car.3bpp.runencoded"
.ends
  Pad 7
.section "Challenge mode HUD tiles" force
DATA_30A68_ChallengeHUDTiles:
; 4bpp tiles (32 bytes per tile)
; - Car colour squares *4 (first is highlighted)
; - "st", "nd", "rd", "th"
; - Car colour "finished" squares *4
; - Smoke (unused?) *4
; - Lap remaining numbers (1-4)
.incbin "Assets/Challenge HUD.4bpp"
.ends

.include "Music engine.asm"

.ifdef BLANK_FILL_ORIGINAL
; This seems to be a copy of code in bank 13. Presumably the music engine insertion left stuff here in the unused space. Check from PagedFunction_37A75_Tanks_Red for the real version.
.db $6F $3E $00 $8C $67 $7E $21 $AD $DE $86 $62 $6B $85 $6F $3E $00 $8C $67 $7E $4F $21 $F5 $40 $3A $A7 $D5 $85 $6F $3E $00 $8C $67 $7E $B7 $28 $0A $FD $7E $00 $91 $FD $77 $00 $C3 $1E $BB $FD $7E $00 $81 $FD $77 $00 $FE $F8 $30 $13 $CD $EF $BB $3A $A6 $D5 $3C $32 $A6 $D5 $FE $25 $20 $16 $3E $04 $32 $63 $D9 $AF $32 $A6 $D5 $DD $77 $00 $FD $77 $00 $DD $77 $02 $FD $77 $01 $C9 $C3 $92 $BF $D6 $1A $5F $16 $00 $21 $5E $BB $19 $7E $DD $77 $01 $3E $AC $DD $77 $03 $C3 $25 $BB $A0 $A0 $A0 $A1 $A1 $A1 $A2 $A2 $A2 $A3 $A3 $A3 $AC $3A $3F $DC $B7 $20 $19 $3A $54 $DC $B7 $28 $13 $3A $41 $DC $B7 $20 $0D $3A $3D $DC $B7 $20 $0E $3A $AB $D5 $FE $A0 $20 $64 $3A $20 $DB $E6 $30 $20 $5D $3A $4F $DE $FE $80 $20 $56 $3A $58 $DF $B7 $20 $50 $3A $80 $DF $B7 $20 $4A $3A $91 $DE $32 $A7 $D5 $3A $92 $DE $C6 $06 $E6 $0F $32 $A8 $D5 $3E $01 $32 $A6 $D5 $3E $0A $32 $63 $D9 $DD $21 $D0 $DA $FD $21 $18 $DB $DD $36 $01 $AD $DD $36 $03 $AE $21 $0A $BC $3A $91 $DE $5F $16 $00 $19 $7E $6F $3A $A4 $DB $85 $DD $77 $00 $21 $1A $BC $19 $7E $6F $3A $A5 $DB $85 $FD $77 $00 $C9 $3A $A6 $D5 $5F $16 $00 $21 $2A $BC $19 $7E $6F $DD $7E $00 $85 $DD $77 $02 $FD $7E $00 $85 $FD $77 $01 $C9 $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03 $00 $03 $05 $08 $00 $03 $05 $08 $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03 $00 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $0F $0E $0D $0C $0B $0A $09 $08 $07 $06 $05 $04 $03 $02 $01 $00 $DD $21 $AB $DC $FD $21 $D4 $DA $18 $1E $DD $21 $EC $DC $FD $21 $D8 $DA $18 $14 $3A $AB $D5 $FE $A0 $28 $05 $3C $32 $AB $D5 $C9 $DD $21 $2D $DD $FD $21 $DC $DA $DD $7E $3F $B7 $CA $9C $BD $FE $1A $D2 $87 $BD $21 $65 $1D $DD $7E $40 $85 $6F $3E $00 $8C $67 $5E $21 $76 $1D $DD $7E $40 $85 $6F $3E $00 $8C $67 $56 $21 $C3 $3F $DD $7E $3E $85 $6F $3E $00 $8C $67 $7E $21 $AD $DE $86 $62 $6B $85 $6F $3E $00 $8C $67 $7E $4F $21 $E5 $40 $DD $7E $3E $85 $6F $3E $00 $8C $67 $7E $B7 $28 $09 $FD $7E $00 $91 $FD $77 $00 $18 $07 $FD $7E $00 $81 $FD $77 $00 $FE $F8 $30 $77 $FD $22 $A9 $D5 $DD $7E $2D $FE $01 $28 $0A $FE $02 $28 $0C $FD $21 $1A $DB $18 $0A $FD $21 $1C $DB $18 $04 $FD $21 $1E $DB $21 $D3 $3F $DD $7E $3E $85 $6F $3E $00 $8C $67 $7E $21 $AD $DE $86 $62 $6B $85 $6F $3E $00 $8C $67 $7E $4F $21 $F5 $40 $DD $7E $3E $85 $6F $3E $00 $8C $67 $7E $B7 $28 $09 $FD $7E $00 $91 $FD $77 $00 $18 $07 $FD $7E $00 $81 $FD $77 $00 $FE $F8 $30 $19 $CD $62 $BE $DD $7E $3F $3C $DD $77 $3F $FE $25 $20 $46 $DD $7E $15 $B7 $28 $05 $3E $04 $32 $74 $D9 $AF $DD $77 $3F $DD $7E $2D $FE $01 $28 $0F $FE $02 $28 $16 $FD $21 $1A $DB $DD $21 $D4 $DA $C3 $76 $BD $FD $21 $1C $DB $DD $21 $D8 $DA $C3 $76 $BD $FD $21 $1E $DB $DD $21 $DC $DA $AF $DD $77 $00 $DD $77 $02 $FD $77 $00 $FD $77 $01 $C9 $C3 $81 $BE $D6 $1A $5F $16 $00 $21 $5E $BB $19 $7E $FD $77 $01 $3E $AC $FD $77 $03 $C3 $33 $BD $3A $3D $DC $B7 $28 $1A $3A $3F $DC $B7 $20 $14 $3A $54 $DC $B7 $28 $06 $3A $41 $DC $B7 $28 $08 $3A $21 $DB $E6 $30 $C2 $61 $BE $3A $4F $DE $FE $80 $C2 $61 $BE $DD $7E $15 $B7 $CA $61 $BE $DD $7E $2E $B7 $C2 $61 $BE $3A $3D $DC $B7 $20 $1C $DD $7E $11 $FE $E0 $D2 $61 $BE $FE $20 $DA $61 $BE $DD $7E $12 $FE $20 $DA $61 $BE $FE $E0 $D2 $61 $BE $18 $06 $3A $80 $DF $B7 $20 $67 $DD $7E $0D $DD $77 $3E $DD $7E $0B $C6 $06 $E6 $0F $DD $77 $40 $3E $01 $DD $77 $3F $DD $7E $15 $B7 $28 $05 $3E $0A $32 $74 $D9 $FD $36 $01 $AD $FD $36 $03 $AE $21 $0A $BC $DD $7E $0D $5F $16 $00 $19 $7E $6F $DD $7E $11 $85 $FD $77 $00 $FD $22 $A9 $D5 $DD $7E $2D $FE $01 $28 $0A $FE $02 $28 $0C $FD $21 $1A $DB $18 $0A $FD $21 $1C $DB $18 $04 $FD $21 $1E $DB $21 $1A $BC $19 $7E $6F $DD $7E $12 $85 $FD $77 $00 $C9 $DD $7E $3F $5F $16 $00 $21 $2A $BC $19 $7E $6F $FD $7E $00 $85 $FD $77 $01 $FD $2A $A9 $D5 $FD $7E $00 $85 $FD $77 $02 $C9 $DD $7E $2D $FE $01 $28 $1B $FE $02 $28 $2E $DD $21 $EC $DC $CD $11 $BF $DD $21 $2D $DD $CD $11 $BF $11 $D4 $DA $01 $1A $DB $C3 $CE $BE $DD $21 $AB $DC $CD $3A $BF $DD $21 $2D $DD $CD $3A $BF $11 $D8 $DA $01 $1C $DB $C3 $CE $BE $DD $21 $AB $DC $CD $69 $BF $DD $21 $EC $DC $CD $69 $BF $11 $DC $DA $01 $1E $DB $3A $58 $DF $B7 $20 $3C $3A $A4 $DB $6F $1A $95 $38 $34 $FE $18 $30 $30 $3A $A5 $DB $6F $0A $95 $38 $28 $FE $18 $30 $24 $3A $3D $DC $B7 $28 $0B $CD $00 $BF $3E $01 $32 $BD $D5 $C3 $BC $29 $CD $34 $29 $AF $32 $2B $DD $32 $D8 $DA $32 $1C $DB $32 $DA $DA $32 $1D $DB $C9 $DD $7E $15 $B7 $28 $22 $DD $7E $11 $6F $3A $D4 $DA $95 $38 $18 $FE $18 $30 $14 $DD $7E $12 $6F $3A $1A $DB $95 $38 $0A $FE $18 $30 $06 $CD $61 $29 $C3 $49 $BD $C9 $3A $3D $DC $B7 $20 $28 $DD $7E $15 $B7 $28 $22 $DD $7E $11 $6F $3A $D8 $DA $95 $38 $18 $FE $18 $30 $14 $DD $7E $12 $6F $3A $1C $DB $95 $38 $0A $FE $18 $30 $06 $CD $61 $29 $C3 $49 $BD $C9 $DD $7E $15 $B7 $28 $22 $DD $7E $11 $6F $3A $DC $DA $95 $38 $18 $FE $18 $30 $14 $DD $7E $12 $6F $3A $1E $DB $95 $38 $0A $FE $18 $30 $06 $CD $61 $29 $C3 $49 $BD $C9 $DD $21 $EC $DC $CD $AA $BF $3A $3D $DC $B7 $20 $58 $DD $21 $AB $DC $CD $AA $BF $DD $21 $2D $DD $DD $7E $2E $B7 $20 $47 $DD $7E $15 $B7 $28 $41 $DD $7E $11 $6F $3A $D0 $DA $95 $38 $37 $FE $18 $30 $33 $DD $7E $12 $6F $3A $18 $DB $95 $38 $29 $FE $18 $30 $25 $DD $7E $2D $FE $01 $20 $10 $3A $3D $DC $B7 $28 $0A $3E $01 $32 $BE $D5 $CD $D4 $4D $18 $03 $CD $61 $29 $DD $21 $D0 $DA $FD $21 $18 $DB $C3 $35 $BB $C9
; ...and some more normal blank fill
.db $ff $00 $00 $ff $ff $00 $00
.endif

  BankMarker

.BANK 13
.ORG $0000
DATA_34000_Choppers_Tiles_BadReference: ; Choppers tiles used to be in this bank (?)

.section "DATA_34000_FormulaOne_Tiles" force
DATA_34000_FormulaOne_Tiles:
.incbin "Assets/Formula One/Tiles.compressed" ; 3bpp bitplane separated
.ends

.section "DATA_34958_CarTiles_Sportscars" force
DATA_34958_CarTiles_Sportscars:
.incbin "Assets/Sportscars/Car.3bpp.runencoded"
.ends
  Pad 6
.section "DATA_34CF0_CarTiles_FourByFour" force
DATA_34CF0_CarTiles_FourByFour:
.incbin "Assets/Four By Four/Car.3bpp.runencoded"
.ends
  Pad 1
.section "DATA_35048_CarTiles_Powerboats" force
DATA_35048_CarTiles_Powerboats:
.incbin "Assets/Powerboats/Car.3bpp.runencoded"
.ends
  Pad 7
.section "DATA_35350_CarTiles_TurboWheels" force
DATA_35350_CarTiles_TurboWheels:
.incbin "Assets/Turbo Wheels/Car.3bpp.runencoded"
.ends
  Pad 1

.section "Plughole tiles high bitplane data" force
; 1bpp data to push the plughole into the upper 8 palette entries
DATA_35708_PlugholeTilesHighBitplanePart1:
; TODO: generate this from PNG somehow?
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
.ends

.section "PagedFunction_357F8_CarTilesToVRAM" force
PagedFunction_357F8_CarTilesToVRAM:
  ld a, (_RAM_DB97_TrackType)
  cp TT_7_RuffTrux
  jr nz, _NormalCars
  
_RuffTrux:
  ; VRAM address 0, 256 tiles
  SetTileAddressImmediate 0
  ld bc, 256 * 8 ; $0800 ; loop count - we consume 3x this much data to produce 256 tiles
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

_NormalCars:
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
  INC_A
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
  jr z, _vflip
  jp _noflip

_hflip:
  ; hflip flag is 1
  call +
  ld a, (_RAM_DB7A_CarTileLoaderVFlip)
  cp $01
  jr z, _vflip ; If it's H- and V-flipped, we wasted time loading it h-flipped because now we re-load it v-flipped
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
    call _emitThreeTilesHFlipped
  pop hl
  ld de, $0300
  add hl, de
  push hl
    call _emitThreeTilesHFlipped
  pop hl
  ld de, $0300
  add hl, de
  TailCall _emitThreeTilesHFlipped

_vflip:
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
    call _emitThreeTilesVFlipped
  pop hl
  ld de, $0300 ; 18 tiles?
  or a
  sbc hl, de
  push hl
    call _emitThreeTilesVFlipped
  pop hl
  ld de, $0300
  or a
  sbc hl, de
  TailCall _emitThreeTilesVFlipped

_noflip:
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
  call _Emit3bppTileData
  ld de, $0300  ; move on by 18 tiles
  add hl, de
  ld a, l       ; and repeat
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld de, $0018
  call _Emit3bppTileData
  ld de, $0300 ; and again
  add hl, de
  ld a, l
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld de, $0018
.ifdef UNNECESSARY_CODE
  jp _Emit3bppTileData ; and return
.endif

_Emit3bppTileData:
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

_emitThreeTilesVFlipped:
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
    ld de, TILE_DATA_SIZE * 2 ; $0040 ; +2 tiles
    add hl, de
  pop de
  dec e
  ld a, e
  or a
  jr nz, --
  ret

_emitThreeTilesHFlipped:
  ; bc = 3bpp tile data
  ; hl = VRAM address to start at (start of last tile)
  ; Emits the data such that the tiles appear horizontally flipped
  ld e, $03     ; Tile count
--:
  ld d, TILE_HEIGHT ; Rows of data
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
    ld de, TILE_DATA_SIZE ; Move to previous tile
    or a
    sbc hl, de
  pop de
  dec e
  ld a, e
  or a
  jr nz, -- ; Loop over the counter
  ret

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

_hflipByte_usingBC:
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
  ld bc, 8 * 3 ; $0018 ; 3 bitplanes -> 1 tile
-:push bc
    ; H-flip and swap bytes at hl and de
    ld a, (hl)
    call _hflipByte_usingBC
    ld (_RAM_DB78_CarTileLoaderTempByte), a
    ld a, (de)
    call _hflipByte_usingBC
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
  INC_A
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
  ld de, 3 * 8 ; $0018  ; add one tile
  add hl, de
  ld bc, 3 * 8 ; $0018  ; For one tile...
-:
  push bc
    ld a, (hl)
    call _hflipByte_usingBC ; hflip it back again???
    ld (hl), a
  pop bc
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ld a, (_RAM_DB77_CarTileLoaderCounter)
  INC_A
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
.ends

.section "Divide by three table" force
DATA_35B8D_DivideByThree:
  DivisionTable 3 96
.ends

.section "Multiply by 96 table" force
DATA_35BED_96TimesTable:
  TimesTable16 0 96 32
.ends

.section "DATA_35C2D_RuffTruxTileIndices" force
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
.ends

.section "DATA_35D2D_HeadToHeadHUDTiles" force
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
.ends

.section "PagedFunction_35F0D_" force
PagedFunction_35F0D_:
  ld a, $00
  ld (_RAM_DB7C_), a
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  ld c, a
  ld hl, _RAM_DF37_HUDSpriteNs.FirstPlace
-:
  ld a, (_RAM_DB7C_)
  cp c
  jr z, _LABEL_35F30_
  ld a, $94
  ld (hl), a
  inc hl
  ld a, (_RAM_DB7C_)
  INC_A
  ld (_RAM_DB7C_), a
  cp $08
  jr nz, -
  ret

_LABEL_35F30_:
  ld a, $95
  ld (hl), a
  inc hl
  ld a, (_RAM_DB7C_)
  INC_A
  ld (_RAM_DB7C_), a
  cp $08
  jr nz, _LABEL_35F30_
  ret
.ends
  
.section "PagedFunction_35F41_InitialiseHeadToHeadHUDSprites" force
PagedFunction_35F41_InitialiseHeadToHeadHUDSprites:
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
  ld e, HUD_Y_GG ; Y coordinate of first sprite
  ld bc, HUD_SPRITE_COUNT ; Sprite count
-:ld a, HUD_X_GG ; X coordinate of all sprites
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
  ld e, HUD_Y_SMS ; Y coordinate of first sprite
  ld bc, HUD_SPRITE_COUNT ; Sprite count
-:ld a, HUD_X_SMS ; X coordinate of all sprites
  ld (hl), a
  ld a, e
  ld (ix+0), a ; Y
  add a, 8 ; Y offset
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
  ld e, HUD_Y_GG ; Y coordinate of first sprite
.else
  ld e, HUD_Y_SMS ; Y coordinate of first sprite
.endif
  ld b, HUD_SPRITE_COUNT ; Sprite count
-:
.ifdef IS_GAME_GEAR
  ld a, HUD_X_GG ; X coordinate of all sprites
.else
  ld a, HUD_X_SMS ; X coordinate of all sprites
.endif
  ld (hl), a
  ld a, e
  ld (ix+0), a ; Y
  add a, 8 ; Y offset
  ld e, a
  inc hl
  inc ix
  djnz -
  ret
.endif
.ends

.section "PagedFunction_35F8A_" force
PagedFunction_35F8A_:
  ld a, (_RAM_DC3F_IsTwoPlayer)
  or a
  JrNzRet _ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet _ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _ret
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  or a
  JrNzRet _ret
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, +
  in a, (PORT_GG_START)
  and PORT_GG_START_MASK
  jp z, _LABEL_3603C_
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
  jr z, _LABEL_3603C_
++:
  ld hl, _RAM_DEA1_
  ld a, (hl)
  or a
  jr z, +
  dec (hl)
+:
  ld a, (_RAM_DE9B_)
  or a
  JrNzRet _ret
  ld hl, _RAM_DEA2_
  ld a, (hl)
  or a
  JrZRet _ret
  dec (hl)
_ret:
  ret

+++:
  ld a, (_RAM_DEA1_)
  CP_0
  jr z, +
  DEC_A
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
  DEC_A
  jp ++

+:
  ld a, (_RAM_DEA4_)
  INC_A
++:
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  or a
  jr nz, +
  ld a, $07
  jp ++

+:
  ld a, (_RAM_DB9B_SteeringDelay)
++:
  ld (_RAM_DEA1_), a
  ld hl, _RAM_DCEC_CarData_Blue.Direction
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCEC_CarData_Blue.Direction), a
  jp LABEL_3608C_

_LABEL_3603C_:
  ld a, (_RAM_DEA1_)
  CP_0
  jr z, +
  DEC_A
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
  DEC_A
  jp ++

+:
  ld a, (_RAM_DEA4_)
  INC_A
++:
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  or a
  jr nz, +
  ld a, $07
  jp ++

+:
  ld a, (_RAM_DB9B_SteeringDelay)
++:
  ld (_RAM_DEA1_), a
  ld hl, _RAM_DCEC_CarData_Blue.Direction
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCEC_CarData_Blue.Direction), a
.ifdef UNNECESSARY_CODE
  jp LABEL_3608C_
.endif
.ends

.section "LABEL_3608C_" force
LABEL_3608C_:
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction)
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
.ends

.section "PagedFunction_360B9_" force
.ifdef JUMP_TO_RET
-:ret
.endif

PagedFunction_360B9_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet -
  ld a, (_RAM_D5C5_)
  cp $01
  JrZRet -
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet -
  call _LABEL_36152_
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DEB0_)
  cp l
  jr z, ++
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DEAF_HScrollDelta)
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

+:
  sub l
  ld (_RAM_DEAF_HScrollDelta), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DEB0_), a
  jp +++

++:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEAF_HScrollDelta), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DEAF_HScrollDelta), a
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

_LABEL_36152_:
  ld a, (_RAM_DB7E_)
  ld (_RAM_DF0B_), a
  ld a, (_RAM_DB7F_)
  ld (_RAM_DF0C_), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown32_b)
  ld (_RAM_DF0E_), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown33_b)
  ld (_RAM_DF0D_), a
  ret
.ends

.section "PagedFunction_3616B_" force
PagedFunction_3616B_:
  call _LABEL_361F0_
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown33_b)
  cp l
  jr z, ++
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  ld l, a
  ld a, (_RAM_DF0B_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  jp +++

+:
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  ld a, (_RAM_DF0D_)
  ld (_RAM_DCEC_CarData_Blue.Unknown33_b), a
  jp +++

++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  ld l, a
  ld a, (_RAM_DF0B_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  jp +++

.ifdef UNNECESSARY_CODE
  ret
.endif

+:
  ld a, $07
  ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
+++:
  ld a, (_RAM_DF0E_)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown32_b)
  cp l
  jr z, ++
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  ld l, a
  ld a, (_RAM_DF0C_)
  cp l
  jr nc, +
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  ret

+:
  sub l
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  ld a, (_RAM_DF0E_)
  ld (_RAM_DCEC_CarData_Blue.Unknown32_b), a
  ret

++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  ld l, a
  ld a, (_RAM_DF0C_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  ret

+:
  ld a, $07
  ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  ret

_LABEL_361F0_: ; Could inline
  ld a, (_RAM_DF7D_)
  ld (_RAM_DF0B_), a
  ld a, (_RAM_DF7E_)
  ld (_RAM_DF0C_), a
  ld a, (_RAM_DB84_)
  ld (_RAM_DF0E_), a
  ld a, (_RAM_DB85_)
  ld (_RAM_DF0D_), a
  ret
.ends

.section "PagedFunction_36209_" force
PagedFunction_36209_:
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
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
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
  ld a, $00
  ld (_RAM_DEA4_), a
  ld (_RAM_DEA2_), a
  ld (_RAM_DE9B_), a
  ret

+++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  or a
  JrNzRet +
  ld a, (_RAM_D5B7_)
  or a
  JrNzRet _ret
  ld a, (_RAM_DEA2_)
  CP_0
  jr z, ++
  DEC_A
  ld (_RAM_DEA2_), a
+:ret

.ifdef JUMP_TO_RET
_ret:
  ret
.endif

++:
  ld a, (_RAM_DEA4_)
  DEC_A
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DE9D_)
  cp $01
  jr nz, +
  ld a, $06
  jp ++

+:
  call _LABEL_362C7_
++:
  ld (_RAM_DEA2_), a
  ld hl, _RAM_DCEC_CarData_Blue.Unknown12_b_Direction
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
  jp LABEL_3608C_

LABEL_36287_:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  or a
  JrNzRet +
  ld a, (_RAM_D5B7_)
  or a
  JrNzRet _ret
  ld a, (_RAM_DEA2_)
  CP_0
  jr z, ++
  DEC_A
  ld (_RAM_DEA2_), a
+:ret

++:
  ld a, (_RAM_DEA4_)
  DEC_A
  ld (_RAM_DEA4_), a
  ld a, (_RAM_DE9D_)
  cp $01
  jr nz, +
  ld a, $06
  jp ++

+:
  call _LABEL_362C7_
++:
  ld (_RAM_DEA2_), a
  ld hl, _RAM_DCEC_CarData_Blue.Unknown12_b_Direction
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
  jp LABEL_3608C_

_LABEL_362C7_:
  ld hl, _RAM_DB86_HandlingData
  ld de, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  ld d, $00
  add hl, de
  ld a, (hl)
  ret
.ends

.section "PagedFunction_362D3_TrackPositionAISpeedHacks" force
PagedFunction_362D3_TrackPositionAISpeedHacks:
  ; Applies special logic to certain track locations to the AI can progress by going faster
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jr z, _Tanks
  or a ; TT_0_SportsCars
  jr z, _SportsCars
  cp TT_3_TurboWheels
  jr z, _TurboWheels
  ret

_TurboWheels:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp 1
  jr z, _SandyStraights
  ret

_SandyStraights: ; Speed up over jump
  ld b, 56 ; Before jump
  ld c, 59 ; After jump
  jp _SpeedTo12IfInRange

_Tanks:
  ; Slow down around chess boards
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, _BedroomBattlefield
  cp 1
  jr z, _WideAwakeWarzone
  
_GoForIt:
  ld b, 72
  ld c, 76
  jp _SpeedTo3IfInRange

_WideAwakeWarzone:
  ld b, 42
  ld c, 46
  jp _SpeedTo3IfInRange

_BedroomBattlefield:
  ld b, 22
  ld c, 26
_SpeedTo3IfInRange:
  ld a, (_RAM_DF50_GreenCarCurrentLapProgress)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, TANK_SPEED_THROUGH_CHESSBOARD
  ld (_RAM_DCAB_CarData_Green.Unknown11_b_Speed), a
+:ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, TANK_SPEED_THROUGH_CHESSBOARD
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
+:ld a, (_RAM_DF52_YellowCarCurrentLapProgress)
  cp b
  JrCRet +
  cp c
  JrNcRet +
  ld a, TANK_SPEED_THROUGH_CHESSBOARD
  ld (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed), a
+:ret

_SportsCars:
  ; Only for track 0 for this type
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, _DesktopDropoff
  ; You might think this means cars can negotiate jumps later on - but it's not the case, some opponents get stuck unable to cross jumps later.
  ret

_DesktopDropoff:
  ld b, 10
  ld c, 13
_SpeedTo12IfInRange:
  ld a, (_RAM_DF50_GreenCarCurrentLapProgress)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, SPEED_THROUGH_JUMP
  ld (_RAM_DCAB_CarData_Green.Unknown11_b_Speed), a
+:
  ld a, (_RAM_DF51_BlueCarCurrentLapProgress)
  cp b
  jr c, +
  cp c
  jr nc, +
  ld a, SPEED_THROUGH_JUMP
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
+:
  ld a, (_RAM_DF52_YellowCarCurrentLapProgress)
  cp b
  JrCRet +
  cp c
  JrNcRet +
  ld a, SPEED_THROUGH_JUMP
  ld (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed), a
+:ret
.ends

.section "PagedFunction_3636E_" force
PagedFunction_3636E_:
  ld a, (_RAM_DF6B_)
  INC_A
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
  INC_A
-:
  and $0F
  ld (_RAM_DE91_CarDirectionPrevious), a
  ld (_RAM_DE90_CarDirection), a
  ret

+:
  ld a, (_RAM_DE91_CarDirectionPrevious)
  cp $08
  jr nc, --
  DEC_A
  jp -
.ends

.section "PagedFunction_363D0_" force
_LABEL_3639C_:
  ld a, (_RAM_D5BC_)
  cp $04
  JrCRet _ret
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  or a
  JrNzRet _ret
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  cp $06
  JrCRet _ret
  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  JrZRet _ret
--:
  xor a
  ld (_RAM_D5BC_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_3_TurboWheels ; Alternative skid sounds for these two
  jr z, +
  cp TT_5_Warriors
  jr z, +
  ld a, SFX_0F_Skid1
-:ld (_RAM_D974_SFX_Player2), a
_ret:
  ret

+:
  ld a, SFX_10_Skid2
  jr -

PagedFunction_363D0_:
  ld a, (_RAM_D5BC_)
  cp $04
  JrCRet _ret
  jr --

PagedFunction_363D9_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  JrNzRet _LABEL_36454_ret
  
  ; Head to head only
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown38_b)
  cp $02
  JrZRet _LABEL_36454_ret

+:ld a, (_RAM_DEA4_)
  or a
  jr z, ++
  cp $01
  jr z, +
  call _LABEL_3639C_
+:ld a, (_RAM_DE9B_)
  CP_0
  jr z, ++
  cp $01
  jr z, +
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_L_MASK ; $04
  jr z, _LABEL_3645B_
  jp ++

+:
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_R_MASK ; $08
  jr z, _LABEL_3645B_
++:
  ld a, (_RAM_DEA4_)
  CP_0
  jr z, _LABEL_3645B_
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
  ; Clamp to max index
  ld a, (hl)
  cp _sizeof_DATA_EA2_
  jr nz, +
  ld a, _sizeof_DATA_EA2_ - 1
  ld (_RAM_DEA8_), a
+:

_LABEL_3643D_:
  ; Look up value
  ld hl, DATA_EA2_
  ld de, (_RAM_DEA8_)
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  sub l
  ld l, a
  and $80
  jr nz, +
  ld a, l
  ld (_RAM_DE57_), a
_LABEL_36454_ret:
  ret

+:ld a, $00
  ld (_RAM_DE57_), a
  ret

_LABEL_3645B_:
  ld a, (_RAM_DEAA_)
  CP_0
  jr z, +
  ld a, (_RAM_DEA8_)
  ; Subtract 2 if >1
  CP_0
  jr z, +
  cp $01
  jr z, +
  sub $02
  ld (_RAM_DEA8_), a
  jp _LABEL_3643D_

  
+:; Else set to 0
  ld a, $00
  ld (_RAM_DEA8_), a
  ld (_RAM_DEAA_), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  ld (_RAM_DE57_), a
  ret
.ends

.section "PagedFunction_36484_PatchForLevel" force
PagedFunction_36484_PatchForLevel:
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

  ld a, (_RAM_DB97_TrackType)
  cp TT_2_Powerboats
  jp z, @Powerboats
  cp TT_0_SportsCars
  jp z, @SportsCars
  cp TT_6_Tanks
  jp z, @Tanks
  cp TT_4_FormulaOne
  jr z, @FormulaOne
  cp TT_3_TurboWheels
  jr z, @TurboWheels
  ret

@TurboWheels:
  ; Tile 43 top left -> f, 2, 2, 1
  PatchBehaviourData 43, 1, 1, $0f
  PatchBehaviourData 43, 1, 2, $02
  PatchBehaviourData 43, 1, 3; $02
  PatchBehaviourData 43, 1, 4, $01
  ret

@FormulaOne:
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

@Tanks:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $01
  jr z, @@WideAwakeWarzone
  ret

@@WideAwakeWarzone:
  ; Replace marbles+dice at top-left corner of track with empty space
  PatchLayout 8, 5, $19
  ret

@Powerboats:
  PatchBehaviourData 36, 0, 4, $04
  PatchBehaviourData 36, 1, 4; $04
  PatchBehaviourData 36, 2, 4; $04
  PatchBehaviourData 36, 3, 4; $04
  PatchBehaviourData 36, 4, 4; $04
  PatchBehaviourData 36, 5, 4; $04
  ld a, (_RAM_DB96_TrackIndexForThisType)
  CP_0
  jr z, @@QualifyingRace
  cp 1
  jr z, @@BermudaBathtub
  cp 2
  jr z, @@SoapLakeCity
  
@@FoamyFjords:
  ; Change soap and bottle at start further from the track
  ; from ---S++BB----
  ; to   --S-++-BB---
  PatchLayout 3, 23, $B5 ; Move soap left at start
  PatchLayout 4, 23, $9E
  PatchLayout 6, 23, $9F ; Move bottle right
  PatchLayout 7, 23, $B6
  PatchLayout 8, 23, $B7
  ret

@@SoapLakeCity:
  ; Change soap in tray over track to empty tray
  PatchLayout 8, 8, $9D
  ret

@@QualifyingRace:
  ; Move soap in tray near track to the left a bit
  PatchLayout 12, 5, $1E
  PatchLayout 11, 5, $35
  ret

@@BermudaBathtub:
  ; Change soap in tray over track to empty tray
  PatchLayout 12, 8, $9D ; High bit set?
  ; Move soap in tray near track to the left a bit
  PatchLayout 17, 8, $35
  PatchLayout 18, 8, $1E
  ret

@SportsCars:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp 2
  jr z, @@CrayonCanyons
  ret

@@CrayonCanyons:
  ; layout error at bottom right corner of track
  PatchLayout 0,  0, $34
  PatchLayout 0, 31, $32
  ret
.ends

.section "PagedFunction_366DE_" force
PagedFunction_366DE_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jp z, _LABEL_36798_
  cp $02
  jr z, +
  ret

+:
  ld a, (_RAM_D947_PlayoffWon)
  or a
  jr nz, +
  ld b, $02
  ld a, (_RAM_D583_)
  CP_0
  jr nz, ++
+:
  ld b, $03
++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  CP_0
  jr nz, +
  ld a, (_RAM_DF7F_)
  cp b
  jr nc, _LABEL_36752_
  INC_A
  ld (_RAM_DF7F_), a
  ld a, $78
  ld (_RAM_DCEC_CarData_Blue.Unknown36_b_JumpCurveMultiplier), a
  ld a, $03
  ld (_RAM_DCEC_CarData_Blue.Unknown37_b), a
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition), a
+:
  ld a, (_RAM_DF99_)
  INC_A
  ld (_RAM_DF99_), a
  and $01
  jr nz, LABEL_36736_
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  INC_A
  and $0F
  ld (_RAM_DCEC_CarData_Blue.Direction), a
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
LABEL_36736_:
  ld a, (_RAM_DF99_)
  and $0F
  jr z, +
  ret

+:
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  ld l, a
  ld a, (_RAM_D583_)
  cp l
  jr z, +
  ld (_RAM_DB7B_HeadToHead_RedPoints), a
  ret

+:
  INC_A
  ld (_RAM_DB7B_HeadToHead_RedPoints), a
  ret

_LABEL_36752_:
  call LABEL_B63_UpdateOverlayText
  ld a, (_RAM_D581_OverlayTextScrollAmount)
  cp $A0
  jr c, LABEL_36736_
  ld a, (_RAM_D583_)
  ld (_RAM_DB7B_HeadToHead_RedPoints), a
  CP_0 ; Blue win
  jr z, +
  cp HEAD_TO_HEAD_TOTAL_POINTS ; Red win
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
  ld (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack), a
  ld (_RAM_DF5B_), a
  jp LABEL_71B5_

+:
  xor a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld (_RAM_DF73_), a
  ret

_LABEL_36798_:
  ld a, (_RAM_D947_PlayoffWon)
  or a
  jr nz, +
  ld b, $02
  ld a, (_RAM_D583_)
  cp $08
  jr nz, ++
+:
  ld b, $03
++:
  ld a, (_RAM_DF00_JumpCurvePosition)
  CP_0
  jr nz, +
  ld a, (_RAM_DF7F_)
  cp b
  jr nc, _LABEL_367FF_
  INC_A
  ld (_RAM_DF7F_), a
  ld a, $78
  ld (_RAM_DF0A_JumpCurveMultiplier), a
  ld a, $03
  ld (_RAM_DF02_JumpCurveStep), a
  ld a, $01
  ld (_RAM_DF00_JumpCurvePosition), a
+:
  ld a, (_RAM_DF99_)
  INC_A
  ld (_RAM_DF99_), a
  and $01
  jr nz, _LABEL_367E3_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  INC_A
  and $0F
  ld (_RAM_DE91_CarDirectionPrevious), a
  ld (_RAM_DE90_CarDirection), a
_LABEL_367E3_:
  ld a, (_RAM_DF99_)
  and $0F
  jr z, +
  ret

+:
  ld a, (_RAM_DB7B_HeadToHead_RedPoints)
  ld l, a
  ld a, (_RAM_D583_)
  cp l
  jr z, +
  ld (_RAM_DB7B_HeadToHead_RedPoints), a
  ret

+:
  DEC_A
  ld (_RAM_DB7B_HeadToHead_RedPoints), a
  ret

_LABEL_367FF_:
  call LABEL_B63_UpdateOverlayText
  ld a, (_RAM_D581_OverlayTextScrollAmount)
  cp $A0
  jr c, _LABEL_367E3_
  ld a, (_RAM_D583_)
  ld (_RAM_DB7B_HeadToHead_RedPoints), a
  CP_0 ; Blue win
  jr z, +
  cp HEAD_TO_HEAD_TOTAL_POINTS ; Red win
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
  jp LABEL_2934_BehaviourF_Explode
.ends

.section "PagedFunction_3682E_" force
PagedFunction_3682E_:
  ld a, (_RAM_DE55_CPUCarDirection)
  sla a
  ld hl, _DATA_368F7_
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
  ld a, (_RAM_DBA4_CarX)
  sub c
  ld (_RAM_DBA4_CarX), a
  ld (_RAM_DBA6_CarX_Next), a
  jp ++

+:
  ld a, (_RAM_DBA4_CarX)
  add a, c
  ld (_RAM_DBA4_CarX), a
  ld (_RAM_DBA6_CarX_Next), a
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
  ld a, (_RAM_DE55_CPUCarDirection)
  sla a
  ld hl, _DATA_36917_
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
  ld a, (_RAM_DBA5_CarY)
  sub c ; Subtract
  ld (_RAM_DBA5_CarY), a
  ld (_RAM_DBA7_CarY_Next), a
  jp ++
+:ld a, (_RAM_DBA5_CarY)
  add a, c ; Add
  ld (_RAM_DBA5_CarY), a
  ld (_RAM_DBA7_CarY_Next), a
++:
  ld a, b
  and $80
  jr z, +
  ld a, b
  and $7F
  ld c, a
  ld hl, (_RAM_DCEC_CarData_Blue.YPosition)
  ld b, $00
  or a
  sbc hl, bc
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
  jp ++

+:
  ld hl, (_RAM_DCEC_CarData_Blue.YPosition)
  ld c, b
  ld b, $00
  add hl, bc
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
++:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  JrZRet +
  ld de, $0028
  ld hl, (_RAM_DCEC_CarData_Blue.YPosition)
  or a
  sbc hl, de
  ld (_RAM_DCEC_CarData_Blue.YPosition), hl
+:ret

_DATA_368F7_:
  ; Delta pairs applied to _RAM_DBA4_CarX and _RAM_DCEC_CarData_Blue, indexed by _RAM_DE55_CPUCarDirection
.dbm SignAndMagnitude,  12, -12
.dbm SignAndMagnitude,  12, -12
.dbm SignAndMagnitude,   9,  -9
.dbm SignAndMagnitude,  -6,   6
.dbm SignAndMagnitude,   0,   0
.dbm SignAndMagnitude,  -6,   6
.dbm SignAndMagnitude,   9,  -9
.dbm SignAndMagnitude, -12,  12
.dbm SignAndMagnitude,  12, -12
.dbm SignAndMagnitude, -12,  12
.dbm SignAndMagnitude,  -9,   9
.dbm SignAndMagnitude,   6,  -6
.dbm SignAndMagnitude,   0,   0
.dbm SignAndMagnitude,   6,  -6
.dbm SignAndMagnitude,  -9,   9
.dbm SignAndMagnitude,  12, -12

_DATA_36917_:
  ; Delta pairs applied to _RAM_DBA5_CarY and _RAM_DCEC_CarData_Blue.YPosition, indexed by _RAM_DE55_CPUCarDirection
.dbm SignAndMagnitude,   0,   0
.dbm SignAndMagnitude,   6,  -6
.dbm SignAndMagnitude,   9,  -9
.dbm SignAndMagnitude, -12,  12
.dbm SignAndMagnitude,  12, -12
.dbm SignAndMagnitude,  12, -12
.dbm SignAndMagnitude,  -9,   9
.dbm SignAndMagnitude,   6,  -6
.dbm SignAndMagnitude,   0,   0
.dbm SignAndMagnitude,  -6,   6
.dbm SignAndMagnitude,  -9,   9
.dbm SignAndMagnitude,  12, -12
.dbm SignAndMagnitude,  12, -12
.dbm SignAndMagnitude, -12,  12
.dbm SignAndMagnitude,   9,  -9
.dbm SignAndMagnitude,  -6,   6
  ; Since they're always matched, it could be stored as a single byte...
.ends

.section "PagedFunction_36937_" force
PagedFunction_36937_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrZRet +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_4_FormulaOne
  JrNzRet +++
  ld a, (_RAM_D5C5_)
  or a
  JrNzRet +++
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
  or a
  JrNzRet +++
  jp ++

+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
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
.ends

.section "PagedFunction_36971_" force
PagedFunction_36971_:
  ld a, (_RAM_DE4F_)
  cp $80
  JpNzRet _ret
  ld a, (_RAM_D5C5_)
  or a
  JpNzRet _ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  CP_0
  JpNzRet _ret
  ld a, (_RAM_DF7F_)
  CP_0
  JpNzRet _ret
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DBA4_CarX)
  cp $CA
  jr nc, LABEL_369EE_
  cp $28
  jr c, LABEL_369EE_
  ld a, (_RAM_DBA5_CarY)
  cp $AA
  jr nc, LABEL_369EE_
  cp $12
  jr c, LABEL_369EE_
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  cp $CA
  jr nc, LABEL_369EE_
  cp $28
  jr c, LABEL_369EE_
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  cp $12
  jr c, LABEL_369EE_
  cp $AA
  JpCRet _ret
  jp LABEL_369EE_

+:
  ld a, (_RAM_DBA4_CarX)
  cp $EA
  jr nc, LABEL_369EE_
  cp $08
  jr c, LABEL_369EE_
  ld a, (_RAM_DBA5_CarY)
  cp $C6
  jr nc, LABEL_369EE_
  ld a, (_RAM_DCEC_CarData_Blue.SpriteX)
  cp $EA
  jr nc, LABEL_369EE_
  cp $08
  jr c, LABEL_369EE_
  ld a, (_RAM_DCEC_CarData_Blue.SpriteY)
  cp $C6
  JrCRet _ret
  jp LABEL_369EE_

_ret:
  ret
.ends

.section "LABEL_369EE_" force
LABEL_369EE_:
  xor a
  ld (_RAM_DEB5_), a
  ld (_RAM_DF0F_), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, (_RAM_D945_)
  or a
  jr nz, _LABEL_36A4F_
  ld a, (_RAM_D940_)
  or a
  jr nz, _LABEL_36A56_
  ld a, (_RAM_DE8C_InPoolTableHole)
  or a
  jr nz, _LABEL_36A6D_
  ld a, (_RAM_DCEC_CarData_Blue.Unknown51_b)
  or a
  jr nz, _LABEL_36A5D_
  ld a, (_RAM_DF8D_RedCarRaceProgress.Hi)
  ld l, a
  ld a, (_RAM_DF91_BlueCarRaceProgress.Hi)
  cp l
  jr z, +
  jr nc, _LABEL_36A3F_
  jp _LABEL_36A2C_

+:
  ld a, (_RAM_DF8D_RedCarRaceProgress.Lo)
  ld l, a
  ld a, (_RAM_DF91_BlueCarRaceProgress.Lo)
  cp l
  jr nc, _LABEL_36A3F_
_LABEL_36A2C_:
  ld a, (_RAM_DF58_ResettingCarToTrack)
  CP_0
  jr nz, +
--:
  ld a, $01
  ld (_RAM_DF5B_), a
  ld ix, _RAM_DCEC_CarData_Blue
  jp LABEL_4E49_

_LABEL_36A3F_:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack)
  CP_0
  JrNzRet +
-:
  ld a, CarState_1_Exploding
  ld (_RAM_DF59_CarState), a
  jp LABEL_2A08_
.ifdef JUMP_TO_RET
+:ret
.endif
_LABEL_36A4F_:
  xor a
  ld (_RAM_D945_), a
  jp -

_LABEL_36A56_:
  xor a
  ld (_RAM_D940_), a
  jp --

_LABEL_36A5D_:
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown46_b_ResettingCarToTrack), a
  ld a, (_RAM_DF55_)
  ld (_RAM_DCEC_CarData_Blue.Unknown60_b), a
  call +
  jp _LABEL_36A3F_

_LABEL_36A6D_:
  xor a
  ld (_RAM_DF58_ResettingCarToTrack), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown60_b)
  ld (_RAM_DF55_), a
  call +
  jp _LABEL_36A2C_

+:
  xor a
  ld (_RAM_DE8C_InPoolTableHole), a
  ld (_RAM_DCEC_CarData_Blue.Unknown51_b), a
  ret
.ends

.section "PagedFunction_36A85_" force
PagedFunction_36A85_:
  ld a, (_RAM_DE6A_)
  INC_A
  and $01
  ld (_RAM_DE6A_), a
  CP_0
  jr z, +
  ld ix, _RAM_DE60_BlueCar_
  ld iy, _RAM_DE64_
  ld bc, _RAM_DE68_
  call ++
  ld bc, _RAM_DE69_
  jp +++

+:ld ix, _RAM_DE5E_
  ld iy, _RAM_DE62_
  ld bc, _RAM_DE66_
  call ++
  ld bc, _RAM_DE67_
  jp +++

++:
  ld a, (bc)
  CP_0
  jr z, _LABEL_36B0B_
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
  CP_0
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

_LABEL_36B0B_:
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

.ends

.section "PagedFunction_36B29_" force
PagedFunction_36B29_:
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
  ld hl, (_RAM_DBAD_X_)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DEB0_), a
  ld (_RAM_D5C3_), a
  ld hl, (_RAM_D941_)
  ld de, (_RAM_DBAD_X_)
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
  ld hl, (_RAM_DBAF_Y_)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DEB2_), a
  ld (_RAM_D5C4_), a
  ld hl, (_RAM_D943_)
  ld de, (_RAM_DBAF_Y_)
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
  ld hl, (_RAM_DCEC_CarData_Blue.YPosition)
  ld b, h
  ld c, l
  ld de, (_RAM_DBAF_Y_)
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
  jr nz, _LABEL_36BBF_
  ld a, l
  cp $90
  jr c, +
_LABEL_36BBF_:
  ld a, $00
  ld (_RAM_D945_), a
  jp LABEL_2A55_

+:
  ld hl, (_RAM_DCEC_CarData_Blue)
  ld b, h
  ld c, l
  ld de, (_RAM_DBAD_X_)
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
  jr nz, _LABEL_36BBF_
  ld a, l
  cp $D2
  jr nc, _LABEL_36BBF_
  ret
.ends

.section "PagedFunction_36BE6_" force
PagedFunction_36BE6_:
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
  ld (_RAM_DCEC_CarData_Blue.Unknown33_b), a
  ld hl, (_RAM_D941_)
  ld de, (_RAM_DCEC_CarData_Blue)
  or a
  sbc hl, de
  ld (_RAM_D941_), hl
  jp ++

+:
  ld (_RAM_D941_), hl
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.Unknown33_b), a
++:
  ld de, (_RAM_D943_)
  ld hl, (_RAM_DCEC_CarData_Blue.YPosition)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DCEC_CarData_Blue.Unknown32_b), a
  ld hl, (_RAM_D943_)
  ld de, (_RAM_DCEC_CarData_Blue.YPosition)
  or a
  sbc hl, de
  ld (_RAM_D943_), hl
  jp ++

+:
  ld (_RAM_D943_), hl
  ld a, $01
  ld (_RAM_DCEC_CarData_Blue.Unknown32_b), a
++:
  ld hl, (_RAM_DBAB_)
  ld a, (_RAM_DBA5_CarY)
  ld e, a
  ld d, $00
  add hl, de
  ld b, h
  ld c, l
  ld de, (_RAM_DCEC_CarData_Blue.YPosition)
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
  jr nz, _LABEL_36C72_
  ld a, l
  cp $C6
  jr c, +
_LABEL_36C72_:
  ld a, $00
  ld (_RAM_D940_), a
  ld a, $00
  ld (_RAM_DF5B_), a
  jp LABEL_4EAB_

+:
  ld hl, (_RAM_DBA9_)
  ld a, (_RAM_DBA4_CarX)
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
  jr nz, _LABEL_36C72_
  ld a, l
  cp $D2
  jr nc, _LABEL_36C72_
  ret
.ends

.section "PagedFunction_36CA5_" force
PagedFunction_36CA5_:
  ld a, (_RAM_DF59_CarState)
  or a
  JrNzRet _ret ; Do nothing if normal
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
-:ld (_RAM_DEAF_HScrollDelta), a
  jp ++
+:ld a, $00
  jp -
++:
  ld a, (_RAM_D943_)
  and $FC
  jr z, +
  sub $04
  ld (_RAM_D943_), a
  ld a, $04
-:ld (_RAM_DEB1_VScrollDelta), a
  jp ++
+:ld a, $00
  jp -

++:
  ld a, (_RAM_DEAF_HScrollDelta)
  CP_0
  JrNzRet _ret
  ld a, (_RAM_DEB1_VScrollDelta)
  CP_0
  JrNzRet _ret
  ld a, $00
  ld (_RAM_D945_), a
  ld a, CarState_2_Respawning
  ld (_RAM_DF59_CarState), a
  ld a, SFX_16_Respawn
  ld (_RAM_D963_SFX_Player1.Trigger), a
_ret:
  ret
.ends

.section "PagedFunction_36D07_" force
PagedFunction_36D07_:
  ld a, (_RAM_D941_)
  and $FC
  jr z, +
  sub $04
  ld (_RAM_D941_), a
  ld a, $04
-:ld (_RAM_DCEC_CarData_Blue.Unknown15_b), a
  jp ++
+:ld a, $00
  jp -
++:
  ld a, (_RAM_D943_)
  and $FC
  jr z, +
  sub $04
  ld (_RAM_D943_), a
  ld a, $04
-:ld (_RAM_DCEC_CarData_Blue.Unknown16_b), a
  jp ++
+:ld a, $00
  jp -
++:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  CP_0
  JrNzRet +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  CP_0
  JrNzRet +
  ld a, $00
  ld (_RAM_D940_), a
  ld a, $02
  ld (_RAM_DF5B_), a
+:ret
.ends

.section "PagedFunction_36D52_RuffTrux_UpdateTimer" force
PagedFunction_36D52_RuffTrux_UpdateTimer:
  call _DecrementTimer
  ; Render timer into tiles
  ld d, $00
  ld a, (_RAM_DF6F_RuffTruxTimer_TensOfSeconds)
  sla a
  sla a
  sla a
  ld hl, _DATA_36DAF_TimerDigitTilesData
  ld e, a
  add hl, de
  ld de, $5162 ; tile $8b lower bitplanes
  call +
  ld d, $00
  ld a, (_RAM_DF70_RuffTruxTimer_Seconds)
  sla a
  sla a
  sla a
  ld hl, _DATA_36DAF_TimerDigitTilesData
  ld e, a
  add hl, de
  ld de, $5302 ; tile $98 lower bitplanes
  call +
  ld d, $00
  ld a, (_RAM_DF71_RuffTruxTimer_Tenths)
  sla a
  sla a
  sla a
  ld hl, _DATA_36DAF_TimerDigitTilesData
  ld e, a
  add hl, de
  ld de, $5D02 ; tile $e8 lower bitplanes
+:
  ld bc, 8 ; Bytes of data
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
_DATA_36DAF_TimerDigitTilesData: ; 1bpp data. This is written into the right bitplane, but the upper bitplanes select whether 0 means transparent or black.
.incbin "Assets/RuffTrux/Numbers.1bpp"

_DecrementTimer:
  ld a, (_RAM_D599_IsPaused)
  or a
  JrNzRet _ret
  ld a, (_RAM_DF65_HasFinished)
  cp $01
  JrZRet _ret
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _ret

  ; Increment frame counter
  ld a, (_RAM_DF72_RuffTruxTimer_Frames)
  INC_A
  ld (_RAM_DF72_RuffTruxTimer_Frames), a
  cp $0A ; BUG: should be 5 or 6 for 50 or 60Hz!
  JrNzRet _ret

  ; Reached target, decrement tenths
  ld a, $00
  ld (_RAM_DF72_RuffTruxTimer_Frames), a
  ld a, (_RAM_DF71_RuffTruxTimer_Tenths)
  DEC_A
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  cp $FF
  JrNzRet _ret

  ; Decrement seconds
  ld a, $09
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  ld a, (_RAM_DF70_RuffTruxTimer_Seconds)
  DEC_A
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  cp $FF
  JrNzRet _ret

  ; Decrement tens of seconds
  ld a, $09
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  ld a, (_RAM_DF6F_RuffTruxTimer_TensOfSeconds)
  DEC_A
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  cp $FF
  JrNzRet _ret

  ; Ran out of time!
  ld a, $01
  ld (_RAM_DF65_HasFinished), a
  ld (_RAM_DF8C_RuffTruxRanOutOfTime), a
  ld a, $F0
  ld (_RAM_DF6A_), a
  ld a, $00
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
_ret:
  ret
.ends

.section "PagedFunction_36E6B_" force
PagedFunction_36E6B_:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
  add a, l
  ld (_RAM_DBA4_CarX), a
  ld a, (_RAM_DBA6_CarX_Next)
  add a, l
  ld (_RAM_DBA6_CarX_Next), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, _LABEL_36F4B_
  
  ld a, (_RAM_DF88_)
  INC_A
  and $01
  ld (_RAM_DF88_), a
  CP_0
  jr z, @EvenFrames
  
@OddFrames:
  ; Effects 1 and 2
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.X), a
  jp _LABEL_36F3E_

@EvenFrames:
  ; Effects 3 and 4
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.X)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.X), a

_LABEL_36F3E_:
  or a
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBA9_)
  sbc hl, de
  ld (_RAM_DBA9_), hl
  ret

_LABEL_36F4B_:
  ld a, (_RAM_D5A6_TankShotPosition)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.57.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.57.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.58.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.58.x), a
+:
  ld a, (_RAM_DCAB_CarData_Green.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.59.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.59.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.60.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.60.x), a
+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.61.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.62.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.62.x), a
+:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown63_b_TankShotState)
  or a
  jr z, _LABEL_36F3E_
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.63.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.64.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.64.x), a
  jp _LABEL_36F3E_
.ends

.section "PagedFunction_36F9E_" force
PagedFunction_36F9E_:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  add a, l
  ld (_RAM_DBA5_CarY), a
  ld a, (_RAM_DBA7_CarY_Next)
  add a, l
  ld (_RAM_DBA7_CarY_Next), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, _Tanks
  ld a, (_RAM_DF89_)
  INC_A
  and $01
  ld (_RAM_DF89_), a
  CP_0
  jr z, _LABEL_3701D_
  ; Add l to a bunch of things for car 1, 2
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.Y), a
  jp _LABEL_37071_

_LABEL_3701D_:
  ; Add l to a bunch of things for car 3, 4
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.Y)
  add a, l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.Y), a
_LABEL_37071_:
  or a
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBAB_)
  sbc hl, de
  ld (_RAM_DBAB_), hl
  ret

_Tanks:
  ld a, (_RAM_D5A6_TankShotPosition)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.57.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.57.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.58.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.58.y), a
+:ld a, (_RAM_DCAB_CarData_Green.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.59.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.59.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.60.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.60.y), a
+:ld a, (_RAM_DCEC_CarData_Blue.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.61.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.61.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.62.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.62.y), a
+:ld a, (_RAM_DD2D_CarData_Yellow.Unknown63_b_TankShotState)
  or a
  jr z, _LABEL_37071_
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.63.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.64.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.64.y), a
  jp _LABEL_37071_
.ends

.section "DATA_370D1_" force
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
.ends

.section "PagedFunction_371F1_" force
PagedFunction_371F1_:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DEB1_VScrollDelta)
  ld c, a
  ld a, (_RAM_D589_)
  add a, l
  add a, c
  ld (_RAM_D589_), a
  ld a, (_RAM_DCAB_CarData_Green.Unknown15_b)
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown16_b)
  ld c, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown27_b)
  add a, l
  add a, c
  ld (_RAM_DCAB_CarData_Green.Unknown27_b), a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown15_b)
  ld l, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown16_b)
  ld c, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown27_b)
  add a, l
  add a, c
  ld (_RAM_DCEC_CarData_Blue.Unknown27_b), a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown15_b)
  ld l, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown16_b)
  ld c, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown27_b)
  add a, l
  add a, c
  ld (_RAM_DD2D_CarData_Yellow.Unknown27_b), a
  ret
.ends

.section "DATA_37232_FourByFour_WallOverrides" force
DATA_37232_FourByFour_WallOverrides:
; Overides any wall data for metatiles where the value is 1
; i.e. tiles $22-$2d
; This removes the walls around the cereal box, allowing you to drive off it
; BUGFIX correct the wall data and remove this
; BUG it is off by one so the bottom right corner is still a wall
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.ends

.section "DATA_37272_EngineTonesByVelocity" force
; indexed by _RAM_DE92_EngineSpeed, value stored at _RAM_D58A_LowestPitchEngineTone
; Steps from LOWEST_PITCH_ENGINE_TONE to HIGHEST_PITCH_ENGINE_TONE with 16 values total
; 1000, 960, 920, ... , 440, 400
DATA_37272_EngineTonesByVelocity:
  TimesTable16 LOWEST_PITCH_ENGINE_TONE, (HIGHEST_PITCH_ENGINE_TONE - LOWEST_PITCH_ENGINE_TONE) / 15, 16
.ends

.section "PagedFunction_37292_GameVBlankEngineUpdate" force
PagedFunction_37292_GameVBlankEngineUpdate:
  ; Look up engine tone for this velocity
  ld a, (_RAM_DE92_EngineSpeed)
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_37272_EngineTonesByVelocity
  add hl, de
  ld a, (hl)
  ; Save it to RAM
  ld (_RAM_D58A_LowestPitchEngineTone.Lo), a
  inc hl
  ld a, (hl)
  ld (_RAM_D58A_LowestPitchEngineTone.Hi), a
.ifdef UNNECESSARY_CODE
  ld l, a ; Does nothing
.endif
  ; Subtract $10 for some reason - maybe so peturbations don't exceed the limit?
  ld bc, $0010
  ld hl, (_RAM_D58A_LowestPitchEngineTone)
  or a
  sbc hl, bc
  ld (_RAM_D58A_LowestPitchEngineTone), hl
  ; Then grab the high byte
  ld a, (_RAM_D58A_LowestPitchEngineTone.Hi)
  ld l, a
  ld a, (_RAM_DF00_JumpCurvePosition)
  or a
  jr nz, ++
  ld a, (_RAM_D95B_EngineSound1.Tone.Hi)
  cp l
  jr z, +
  jr c, _LABEL_372D3_
-:
  ld de, $0004
  ld hl, (_RAM_D95B_EngineSound1.Tone)
  ; _RAM_D95B_EngineSound1.Tone -= 4
  or a
  sbc hl, de
  ld (_RAM_D95B_EngineSound1.Tone), hl
  ret

_LABEL_372D3_:
  ; _RAM_D95B_EngineSound1.Tone += 2
  ld hl, (_RAM_D95B_EngineSound1.Tone)
  ld de, $0002
  add hl, de
  ld (_RAM_D95B_EngineSound1.Tone), hl
  ret

+:
  ld a, (_RAM_D58A_LowestPitchEngineTone.Lo)
  ld l, a
  ld a, (_RAM_D95B_EngineSound1.Tone.Lo)
  cp l
  JrZRet +
  ; Only if not the same
  jr c, _LABEL_372D3_
  jp -

+:ret

++:
  ld a, (_RAM_D95B_EngineSound1.Tone.Hi)
  cp >HIGHEST_PITCH_ENGINE_TONE
  jr z, +
--:
  ; _RAM_D95B_EngineSound1.Tone -= 4
  ld de, $0004
  ld hl, (_RAM_D95B_EngineSound1.Tone)
  or a
  sbc hl, de
  ld (_RAM_D95B_EngineSound1.Tone), hl
-:ret

+:
  ld a, (_RAM_D95B_EngineSound1.Tone.Lo)
  cp <HIGHEST_PITCH_ENGINE_TONE 
  JrCRet -
  jp --
.ends

.section "PagedFunction_3730C_GameVBlankPart3" force
PagedFunction_3730C_GameVBlankPart3:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D96C_EngineSound2.Volume)
  ld (_RAM_D595_), a
  jp LABEL_37408_

+:
  xor a
  ld (_RAM_D594_), a
  ld (_RAM_D595_), a
  ld (_RAM_D596_), a
  ld a, (_RAM_DBA0_TopLeftMetatileX)
  ld l, a
  ld a, (_RAM_DE79_CurrentMetatile_OffsetX)
  add a, l
  sub $05
  jr nc, +
  xor a
+:
  ld (_RAM_D592_), a
  ld a, (_RAM_DBA2_TopLeftMetatileY)
  ld l, a
  ld a, (_RAM_DE7B_CurrentMetatile_OffsetY)
  add a, l
  sub $05
  jr nc, +
  xor a
+:
  ld (_RAM_D593_), a
  ld l, a
  ld a, (_RAM_DCAB_CarData_Green.YMetatile)
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
  ld a, (_RAM_DCAB_CarData_Green.XMetatile)
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
  ld a, (_RAM_DCEC_CarData_Blue.YMetatile)
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
  ld a, (_RAM_DCEC_CarData_Blue.XMetatile)
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
  ld a, (_RAM_DD2D_CarData_Yellow.YMetatile)
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
  ld a, (_RAM_DD2D_CarData_Yellow.XMetatile)
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
  ld a, (_RAM_DCAB_CarData_Green.Unknown20_b_JumpCurvePosition)
  ld b, a
  ld a, (_RAM_DCAB_CarData_Green.Unknown11_b_Speed)
  ex af, af'
  ld a, (_RAM_D594_)
  jp ++

LABEL_373F3_:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown20_b_JumpCurvePosition)
  ld b, a
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown11_b_Speed)
  ex af, af'
  ld a, (_RAM_D596_)
  jp ++

+:
  ld l, a
  ld a, (_RAM_D596_)
  cp l
  jr nc, LABEL_373F3_
  
LABEL_37408_:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown20_b_JumpCurvePosition)
  ld b, a
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  ex af, af'
    ld a, (_RAM_D595_)
++: ld (_RAM_D597_), a
    or a
    jr z, +++
    ld l, a
    ld a, (_RAM_D96C_EngineSound2.Volume)
    cp l
    jr z, ++
    jr nc, +
    inc a
    ld (_RAM_D96C_EngineSound2.Volume), a
    jp ++
+:  dec a
    ld (_RAM_D96C_EngineSound2.Volume), a
++:
  ex af, af'
  sla a
  ld e, a
  ld d, $00
  ld hl, DATA_37272_EngineTonesByVelocity
  add hl, de
  ld a, (hl)
  ld (_RAM_D58E_OtherCar_EngineTone.Lo), a
  inc hl
  ld a, (hl)
  ld (_RAM_D58E_OtherCar_EngineTone.Hi), a
  jp ++++

+++:
  ex af, af'
  xor a
  ld (_RAM_D96C_EngineSound2.Volume), a
  ret

++++:
  ld a, b
  or a
  jr nz, ++
  ld a, (_RAM_D58E_OtherCar_EngineTone.Hi)
  ld l, a
  ld a, (_RAM_D96C_EngineSound2.Tone.Hi)
  cp l
  jr z, +
  jr c, LABEL_37466_
-:
  ld de, $0004
  ld hl, (_RAM_D96C_EngineSound2.Tone)
  or a
  sbc hl, de
  ld (_RAM_D96C_EngineSound2.Tone), hl
  ret

LABEL_37466_:
  ld hl, (_RAM_D96C_EngineSound2.Tone)
  ld de, $0002
  add hl, de
  ld (_RAM_D96C_EngineSound2.Tone), hl
  ret

+:
  ld a, (_RAM_D58E_OtherCar_EngineTone.Lo)
  ld l, a
  ld a, (_RAM_D96C_EngineSound2.Tone.Lo)
  cp l
  JrZRet +
  jr c, LABEL_37466_
  jp -

+:ret

++:
  ld a, (_RAM_DF7F_)
  or a
  JrNzRet _LABEL_3749A_ret
  ld a, (_RAM_D96C_EngineSound2.Tone.Hi)
  cp $01
  jr z, +
-:
  ld de, $0004
  ld hl, (_RAM_D96C_EngineSound2.Tone)
  or a
  sbc hl, de
  ld (_RAM_D96C_EngineSound2.Tone), hl
_LABEL_3749A_ret:
  ret

+:
  ld a, (_RAM_D96C_EngineSound2.Tone.Lo)
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
  TimesTableLo 11, 11, 11
.ends

.section "PagedFunction_37529_" force
PagedFunction_37529_: ; initialises some stuff, TODO
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
  ld a, HEAD_TO_HEAD_TOTAL_POINTS / 2
  ld (_RAM_DB7B_HeadToHead_RedPoints), a
  ld a, $01
  ld (_RAM_DBA8_SkipNextGameVBlankVDPUpdate), a
  ld a, (_RAM_DB99_AccelerationDelay)
  DEC_A ; Other cars can accelerate faster?!?
  ld (_RAM_DCAB_CarData_Green.Unknown19_b), a
  ld (_RAM_DCEC_CarData_Blue.Unknown19_b), a
  ld (_RAM_DD2D_CarData_Yellow.Unknown19_b), a

  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, @GG

@SMS:
  ld a, $74
  ld (_RAM_DBA4_CarX), a
  ld (_RAM_DBA6_CarX_Next), a
  ld a, $68
  ld (_RAM_DBA5_CarY), a
  ld (_RAM_DBA7_CarY_Next), a
  ret

@GG:
  ld a, $3C
  ld (_RAM_DBA4_CarX), a
  ld (_RAM_DBA6_CarX_Next), a
  ld a, $8F
  ld (_RAM_DBA5_CarY), a
  ld (_RAM_DBA7_CarY_Next), a
  ret
.ends

.section "PagedFunction_375A0_" force
; Data from 37580 to 3758F (16 bytes)
DATA_37580_: ; Indexed by car direction
.db $74 $68 $58 $58 $58 $58 $58 $68 $74 $80 $90 $90 $90 $90 $90 $80

; Data from 37590 to 3759F (16 bytes)
DATA_37590_: ; Indexed by car direction
.db $7F $7F $7F $6F $63 $57 $47 $47 $47 $47 $47 $57 $63 $6F $7F $7F

PagedFunction_375A0_:
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
  ld a, (_RAM_DF58_ResettingCarToTrack)
  CP_0
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
  ld a, (_RAM_DE5D_CarY_Previous)
  cp b
  jr z, +
  jr c, +++
  ld a, (_RAM_DEB1_VScrollDelta)
  CP_0
  jr z, ++
  DEC_A
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
  INC_A
  ld (_RAM_DEB1_VScrollDelta), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB8_), a
  ld a, $00
  ld (_RAM_DEB2_), a
+:ret

LABEL_3762B_:
  ld a, (_RAM_DE5D_CarY_Previous)
  cp b
  jr z, +
  jr nc, +++
  ld a, (_RAM_DEB1_VScrollDelta)
  CP_0
  jr z, ++
  DEC_A
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
  INC_A
  ld (_RAM_DEB1_VScrollDelta), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB8_), a
  ld a, $01
  ld (_RAM_DEB2_), a
+:ret
.ends

.section "PagedFunction_3766F_" force
PagedFunction_3766F_:
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
  ld a, (_RAM_DF58_ResettingCarToTrack)
  CP_0
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
  ld a, (_RAM_DE5C_CarX_Previous)
  cp b
  jr z, +
  jr c, +++
  ld a, (_RAM_DEAF_HScrollDelta)
  CP_0
  jr z, ++
  DEC_A
  ld (_RAM_DEAF_HScrollDelta), a
  ret

+:
  ld a, $01
  ld (_RAM_DE82_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE81_), a
  ret

++:
  ld a, $01
  ld (_RAM_DEAF_HScrollDelta), a
  ld (_RAM_DEB9_), a
  ld a, $01
  ld (_RAM_DEB0_), a
  ret

+++:
  ld a, (_RAM_DEAF_HScrollDelta)
  INC_A
  ld (_RAM_DEAF_HScrollDelta), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB9_), a
  ld a, $00
  ld (_RAM_DEB0_), a
+:ret

LABEL_376FA_:
  ld a, (_RAM_DE5C_CarX_Previous)
  cp b
  jr z, +
  jr nc, +++
  ld a, (_RAM_DEAF_HScrollDelta)
  or a
  jr z, ++
  DEC_A
  ld (_RAM_DEAF_HScrollDelta), a
  ret

+:
  ld a, $01
  ld (_RAM_DE82_), a
  ld a, (_RAM_DE90_CarDirection)
  ld (_RAM_DE81_), a
  ret

++:
  ld a, $01
  ld (_RAM_DEAF_HScrollDelta), a
  ld (_RAM_DEB9_), a
  ld a, $00
  ld (_RAM_DEB0_), a
  ret

+++:
  ld a, (_RAM_DEAF_HScrollDelta)
  INC_A
  ld (_RAM_DEAF_HScrollDelta), a
  cp $01
  JrNzRet +
  ld (_RAM_DEB9_), a
  ld (_RAM_DEB0_), a
+:ret
.ends

.section "PagedFunction_3773B_ReadControls" force
PagedFunction_3773B_ReadControls:
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
  and PORT_CONTROL_A_PLAYER1_MASK
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

.ends

.section "PagedFunction_3779F_" force
PagedFunction_3779F_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB97_TrackType)
  cp TT_1_FourByFour
  jr nz, +
  ld a, (_RAM_D5A5_)
  or a
  jr z, +
  ld a, (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction)
  ld l, a
  ld h, $00
  ld de, DATA_250E_OppositeDirections
  add hl, de
  ld a, (hl)
  ld c, a
  jr ++

+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction)
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
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
  cp $04
  jr nc, +
  ld a, $00
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
  ret

+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed)
+++++:
  and $FE
  rr a
  ld (_RAM_DE31_CarUnknowns.2.Unknown1), a
  and $FE
  rr a
  ld (_RAM_DCEC_CarData_Blue.Unknown11_b_Speed), a
  ld d, $00
  ld a, c
  ld e, a
  ld hl, DATA_250E_OppositeDirections
  add hl, de
  ld a, (hl)
  ld (_RAM_DE31_CarUnknowns.2.Unknown0_Direction), a
  ld a, (_RAM_DCEC_CarData_Blue.Direction)
  ld (_RAM_DCEC_CarData_Blue.Unknown12_b_Direction), a
  ret
.ends

.section "PagedFunction_37817_" force
PagedFunction_37817_:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  sub l
  ld (_RAM_DBA5_CarY), a
  ld a, (_RAM_DBA7_CarY_Next)
  sub l
  ld (_RAM_DBA7_CarY_Next), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, LABEL_378F4_
  ld a, (_RAM_DF89_)
  INC_A
  and $01
  ld (_RAM_DF89_), a
  CP_0
  jr z, LABEL_37895_
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.Y), a
  jr LABEL_378E9_

LABEL_37895_:
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.Y), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.Y)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.Y), a
LABEL_378E9_:
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBAB_)
  add hl, de
  ld (_RAM_DBAB_), hl
  ret

LABEL_378F4_:
  ld a, (_RAM_D5A6_TankShotPosition)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.57.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.57.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.58.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.58.y), a
+:
  ld a, (_RAM_DCAB_CarData_Green.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.59.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.59.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.60.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.60.y), a
+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DAE0_SpriteTableYs.61.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.61.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.62.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.62.y), a
+:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown63_b_TankShotState)
  or a
  jr z, LABEL_378E9_
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.63.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.64.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.64.y), a
  jr LABEL_378E9_
.ends

.section "PagedFunction_37946_" force
PagedFunction_37946_:
  ld a, (_RAM_DEAF_HScrollDelta)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
  sub l
  ld (_RAM_DBA4_CarX), a
  ld a, (_RAM_DBA6_CarX_Next)
  sub l
  ld (_RAM_DBA6_CarX_Next), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_6_Tanks
  jp z, LABEL_37A23_
  ld a, (_RAM_DF88_)
  INC_A
  and $01
  ld (_RAM_DF88_), a
  or a
  jr z, LABEL_379C4_
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.1.Sprites.3.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.2.Sprites.3.Data.2.X), a
  jp LABEL_37A18_

LABEL_379C4_:
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.3.Sprites.3.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.1.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.2.Data.2.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.X)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.1.X), a
  ld a, (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.X)
  sub l
  ld (_RAM_DD6E_CarEffects.4.Sprites.3.Data.2.X), a
LABEL_37A18_:
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBA9_)
  add hl, de
  ld (_RAM_DBA9_), hl
  ret

LABEL_37A23_:
  ld a, (_RAM_D5A6_TankShotPosition)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.57.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.57.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.58.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.58.x), a
+:
  ld a, (_RAM_DCAB_CarData_Green.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.59.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.59.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.60.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.60.x), a
+:
  ld a, (_RAM_DCEC_CarData_Blue.Unknown63_b_TankShotState)
  or a
  jr z, +
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.61.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.62.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.62.x), a
+:
  ld a, (_RAM_DD2D_CarData_Yellow.Unknown63_b_TankShotState)
  or a
  jr z, LABEL_37A18_
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.63.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.64.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.64.x), a
  jr LABEL_37A18_
.ends

.section "Tank shot handling" force
PagedFunction_37A75_Tanks_Red:
  ld a, (_RAM_D5A6_TankShotPosition)
  or a
  jp z, _CheckForNewShot_Red
  ; Else update the shot in progress
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  cp TANK_SHOT_COUNTER_GROUND
  jp nc, _ShotHitGround_Red
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
  ld hl, DATA_3FC3_HorizontalAmountByDirection
  ld a, (_RAM_D5A7_TankShotDirection)
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
  ld hl, DATA_40E5_Sign_Directions_X
  ld a, (_RAM_D5A7_TankShotDirection)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (ix+0) ; Update X
  sub c
  ld (ix+0), a
  jr ++
+:ld a, (ix+0)
  add a, c
  ld (ix+0), a
++:
  cp -8
  jr nc, _ShotFinished
  ld hl, DATA_3FD3_VerticalAmountByDirection
  ld a, (_RAM_D5A7_TankShotDirection)
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
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (_RAM_D5A7_TankShotDirection)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ld a, (iy+0)
  sub c ; subtract
  ld (iy+0), a
  jp ++
+:
  ld a, (iy+0)
  add a, c ; add
  ld (iy+0), a
++:
  cp $F8
  jr nc, _ShotFinished
  call _SetShadowSpritePosition
-:
  ld a, (_RAM_D5A6_TankShotPosition)
  inc a
  ld (_RAM_D5A6_TankShotPosition), a
  cp TANK_SHOT_COUNTER_END
  jr nz, +
  ld a, SFX_04_TankMiss
  ld (_RAM_D963_SFX_Player1.Trigger), a
_ShotFinished:
  xor a
  ld (_RAM_D5A6_TankShotPosition), a
  ; Move sprites to 0,0
  ld (ix+0), a
  ld (iy+0), a
  ld (ix+2), a
  ld (iy+1), a
  ret

+:jp _LABEL_37F92_

_ShotHitGround_Red:
  sub TANK_SHOT_COUNTER_GROUND
  ld e, a
  ld d, 0
  ld hl, _ShotTileAnimationData
  add hl, de
  ld a, (hl)
  ld (ix+1), a ; Explosion animation
  ld a, <SpriteIndex_Blank
  ld (ix+3), a ; Blank shadow
  jp -

_ShotTileAnimationData:
.db <SpriteIndex_Smoke + 0 
.db <SpriteIndex_Smoke + 0 
.db <SpriteIndex_Smoke + 0 
.db <SpriteIndex_Smoke + 1 
.db <SpriteIndex_Smoke + 1 
.db <SpriteIndex_Smoke + 1 
.db <SpriteIndex_Smoke + 2 
.db <SpriteIndex_Smoke + 2 
.db <SpriteIndex_Smoke + 2 
.db <SpriteIndex_Smoke + 3 
.db <SpriteIndex_Smoke + 3 
.db <SpriteIndex_Smoke + 3 
.db <SpriteIndex_Blank

_CheckForNewShot_Red:
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
  and BUTTON_1_MASK | BUTTON_2_MASK ; Both buttons pressed
  JrNzRet _LABEL_37BEE_ret
++:
  ld a, (_RAM_DE4F_)
  cp $80
  JrNzRet _LABEL_37BEE_ret
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet _LABEL_37BEE_ret
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_37BEE_ret
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_D5A7_TankShotDirection), a
  ld a, (_RAM_DE92_EngineSpeed)
  add a, $06
  and $0F
  ld (_RAM_D5A8_), a
  ld a, $01
  ld (_RAM_D5A6_TankShotPosition), a
  ld a, SFX_0A_TankShoot
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  ld (ix+1), <SpriteIndex_Bullet
  ld (ix+3), <SpriteIndex_BulletShadow
  ld hl, _TankShotXOffsets
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA4_CarX)
  add a, l
  ld (ix+0), a ; Shot X
  ld hl, _TankShotYOffsets
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA5_CarY)
  add a, l
  ld (iy+0), a
_LABEL_37BEE_ret:
  ret

_SetShadowSpritePosition:
  ld a, (_RAM_D5A6_TankShotPosition)
  ld e, a
  ld d, 0
  ld hl, _ShadowOffsetFromShot
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+0) ; Shot X
  add a, l
  ld (ix+2), a ; Shadow X
  ld a, (iy+0) ; Shot Y
  add a, l
  ld (iy+1), a ; Shadow Y
  ret

_TankShotXOffsets:
; X offset to start a shot at, for each car direction
;             10
;          08    13
;       05          15
;    03                18
; 00                      20
;    03                18
;       05          15
;          08    13
;             10
.db $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03 $00 $03 $05 $08

_TankShotYOffsets:
; Y offset to start a shot at, for each car direction
;             00
;          03    03
;       05          05
;    08                08
; 10                      10
;    13                13
;       15          15
;          18    18
;             20
.db $00 $03 $05 $08 $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03

_ShadowOffsetFromShot:
; X and Y offset for the shot's shadow for each frame of its arc
; Somewhat triangular, could be mroe curved...
.db 0 ; no shadow?
.db 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ; Up...
.db 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 ; ...and down

PagedFunction_37C45_Tanks_Green:
  ld ix, _RAM_DCAB_CarData_Green
  ld iy, _RAM_DA60_SpriteTableXNs.59
  jr ++

PagedFunction_37C4F_Tanks_Blue:
  ld ix, _RAM_DCEC_CarData_Blue
  ld iy, _RAM_DA60_SpriteTableXNs.61
  jr ++

PagedFunction_37C59_Tanks_Yellow:
  ; Timer to delay something?
  ld a, (_RAM_D5AB_)
  cp $A0
  jr z, +
  inc a
  ld (_RAM_D5AB_), a
  ret

+:ld ix, _RAM_DD2D_CarData_Yellow
  ld iy, _RAM_DA60_SpriteTableXNs.63
  ; fall through
  
  ; Common code for green, blue, yellow
++:
  ld a, (ix+CarData.Unknown63_b_TankShotState)
  or a
  jp z, LABEL_37D9C_CheckForInitiateShot_OtherPlayers
  
  ; If not zero, a shot must be in the air
  cp TANK_SHOT_COUNTER_GROUND
  jp nc, LABEL_37D87_ShotHitGround
  
  ; If we get here then it is still moving
  ; Look up data for the speed -> de
  ld hl, DATA_1D65__Lo
  ld a, (ix+CarData.Unknown64_b_ShotSpeed)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, DATA_1D76__Hi
  ld a, (ix+CarData.Unknown64_b_ShotSpeed)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ; And the direction -> a
  ld hl, DATA_3FC3_HorizontalAmountByDirection
  ld a, (ix+CarData.Unknown62_b_ShotDirection)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  ; Then add _RAM_DEAD_
  ld hl, _RAM_DEAD_
  add a, (hl)
  ; Get speed data pointer
  ld h, d
  ld l, e
  ; Index by horizontal amount + _RAM_DEAD_
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl) ; Get byte to c
  ld c, a
  ; Look up if that's + or -
  ld hl, DATA_40E5_Sign_Directions_X
  ld a, (ix+CarData.Unknown62_b_ShotDirection)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld a, (hl)
  or a
  jr z, +
  ; 1 => subtract c from X coordinate
  ld a, (iy+0)
  sub c
  ld (iy+0), a
  jr ++

+:; 0 => add c to X coordinate
  ld a, (iy+0)
  add a, c
  ld (iy+0), a
  
++:
  ; If it gets to the right of the screen then kill it
  cp $F8
  jr nc, LABEL_37D49_TankShotDone

  ; Save the coordinates pointer
  ld (_RAM_D5A9_TankShotTileXN), iy

  ; Look up the Y coordinate
  ; Selects which sprite to move
  ld a, (ix+CarData.TankShotSpriteIndex)
  cp 1
  jr z, +
  cp 2
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  jr +++
+:ld iy, _RAM_DAE0_SpriteTableYs.61
  jr +++
++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
+++:
  ; Similar to previous phase...
  ld hl, DATA_3FD3_VerticalAmountByDirection
  ld a, (ix+CarData.Unknown62_b_ShotDirection)
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
  ld hl, DATA_40F5_Sign_Directions_Y
  ld a, (ix+CarData.Unknown62_b_ShotDirection)
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
  jr nc, LABEL_37D49_TankShotDone
  call LABEL_37E62_
LABEL_37D33_:
  ld a, (ix+CarData.Unknown63_b_TankShotState)
  inc a
  ld (ix+CarData.Unknown63_b_TankShotState), a
  cp TANK_SHOT_COUNTER_END
  jr nz, LABEL_37D84_
  ld a, (ix+CarData.EffectsEnabled)
  or a
  jr z, LABEL_37D49_TankShotDone
  ld a, SFX_04_TankMiss
  ld (_RAM_D974_SFX_Player2), a
  ; fall through
  
LABEL_37D49_TankShotDone:
  ; Kill shot
  ; Set state to 0
  xor a
  ld (ix+CarData.Unknown63_b_TankShotState), a
  ; Set sprite Xs, Ys to 0
  ld a, (ix+CarData.TankShotSpriteIndex)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld iy, _RAM_DAE0_SpriteTableYs.59
  ld ix, _RAM_DA60_SpriteTableXNs.59
  jp +++
+:ld iy, _RAM_DAE0_SpriteTableYs.61
  ld ix, _RAM_DA60_SpriteTableXNs.61
  jp +++
++:
  ld iy, _RAM_DAE0_SpriteTableYs.63
  ld ix, _RAM_DA60_SpriteTableXNs.63
+++:
  xor a
  ; Xs
  ld (ix+0), a
  ld (ix+2), a
  ; Ys
  ld (iy+0), a
  ld (iy+1), a
  ret

LABEL_37D84_:
  jp LABEL_37E81_

LABEL_37D87_ShotHitGround:
  sub TANK_SHOT_COUNTER_GROUND
  ld e, a
  ld d, 0
  ld hl, _ShotTileAnimationData
  add hl, de
  ld a, (hl)
  ld (iy+1), a
  ld a, <SpriteIndex_Blank
  ld (iy+3), a
  jp LABEL_37D33_

LABEL_37D9C_CheckForInitiateShot_OtherPlayers:
  ; Check if player 2 is in control of shots...
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
+:; If head to head and 2-player and (SMS or Gear-to-Gear)
  ld a, (_RAM_DB21_Player2Controls) ; If 1+2 are not pressed, skip the rest
  and BUTTON_1_MASK | BUTTON_2_MASK ; $30
  JpNzRet _LABEL_37E61_ret
++:
  ; If we get here than either player 2 is not there, or he has pressed 1+2
  ; (so CPU cars shoot continuously(!))
  ; We still do nothing if:
  ; - high bit of _RAM_DE4F_ is set
  ld a, (_RAM_DE4F_)
  cp $80
  JpNzRet _LABEL_37E61_ret
  ; - Effects are disabled (car is off-screen)
  ld a, (ix+CarData.EffectsEnabled)
  or a
  JpZRet _LABEL_37E61_ret
  ; - Unknown46_b_ResettingCarToTrack is set
  ld a, (ix+CarData.Unknown46_b_ResettingCarToTrack)
  or a
  JpNzRet _LABEL_37E61_ret

  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ; Challenge
  ; Car can't shoot if not on-screen enough
.define ON_SCREEN_MIN_X $20 ; TODO are these used anywhere else?
.define ON_SCREEN_MAX_X $E0
.define ON_SCREEN_MIN_Y $20
.define ON_SCREEN_MAX_Y $E0
  ld a, (ix+CarData.SpriteX)
  cp ON_SCREEN_MAX_X
  JpNcRet _LABEL_37E61_ret
  cp ON_SCREEN_MIN_X
  JpCRet _LABEL_37E61_ret
  ld a, (ix+CarData.SpriteY)
  cp ON_SCREEN_MIN_Y
  JpCRet _LABEL_37E61_ret
  cp ON_SCREEN_MAX_Y
  JpNcRet _LABEL_37E61_ret
  jr ++

+:; Head to head
  ; Can't shoot during "win phase"
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  JrNzRet _LABEL_37E61_ret
  
++:
  ; Let's initiate a shot
  ; It inherits the car direction
  ld a, (ix+CarData.Direction)
  ld (ix+CarData.Unknown62_b_ShotDirection), a
  ; And the car's speed + 6 (subject to an upper bound)
  ld a, (ix+CarData.Unknown11_b_Speed)
  add a, TANK_SHOT_RELATIVE_SPEED
  and MAXIMUM_SPEED_MASK
  ld (ix+CarData.Unknown64_b_ShotSpeed), a
  ld a, $01
  ld (ix+CarData.Unknown63_b_TankShotState), a
  ld a, (ix+CarData.EffectsEnabled)
  or a
  jr z, +
  ld a, SFX_0A_TankShoot
  ld (_RAM_D974_SFX_Player2), a
+:
  ; Show the sprite
  ld (iy+1), <SpriteIndex_Bullet
  ld (iy+3), <SpriteIndex_BulletShadow
  ; Compute the coordinates: X...
  ld hl, _TankShotXOffsets
  ld a, (ix+CarData.Direction)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+CarData.SpriteX)
  add a, l
  ld (iy+0), a
  ld (_RAM_D5A9_TankShotTileXN), iy
  ; And Y...
  ld a, (ix+CarData.TankShotSpriteIndex)
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
  ld hl, _TankShotYOffsets
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+CarData.SpriteY)
  add a, l
  ld (iy+0), a
_LABEL_37E61_ret:
  ret

LABEL_37E62_:
  ld a, (ix+CarData.Unknown63_b_TankShotState)
  ld e, a
  ld d, $00
  ld hl, _ShadowOffsetFromShot
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (iy+0)
  add a, l
  ld (iy+1), a
  ld iy, (_RAM_D5A9_TankShotTileXN)
  ld a, (iy+0)
  add a, l
  ld (iy+2), a
  ret

LABEL_37E81_:
  ld a, (ix+CarData.TankShotSpriteIndex)
  cp 1
  jr z, +
  cp 2
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
  ld a, (_RAM_DF58_ResettingCarToTrack)
  or a
  JrNzRet +++
  ld a, (_RAM_DBA4_CarX)
  ld l, a
  ld a, (de)
  sub l
  JrCRet +++
  cp $18
  JrNcRet +++
  ld a, (_RAM_DBA5_CarY)
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
  jp LABEL_29BC_Behaviour1_Fall

+:
  call LABEL_2934_BehaviourF_Explode
++:
  xor a
  ld (_RAM_DCEC_CarData_Blue.Unknown63_b_TankShotState), a
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
  jp LABEL_37D49_TankShotDone

.ifdef JUMP_TO_RET
+:ret
.endif

LABEL_37F3A_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  JrNzRet +
  ld a, (ix+CarData.EffectsEnabled)
  or a
  JrZRet +
  ld a, (ix+CarData.SpriteX)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  ld a, (ix+CarData.SpriteY)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.61.y)
  sub l
  JrCRet +
  cp $18
  JrNcRet +
  call LABEL_2961_
  jp LABEL_37D49_TankShotDone

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
  jp LABEL_37D49_TankShotDone

.ifdef JUMP_TO_RET
+:ret
.endif

_LABEL_37F92_:
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
  jp _ShotFinished

_LABEL_37FF7_ret:
  ret
.ends

.ifdef BLANK_FILL_ORIGINAL
.db $FF $00 $00 $FF
.db $FF $00 $00
.endif

  BankMarker

.BANK 14
.ORG $0000

.section "DATA_38000_TurboWheels_Tiles" force
DATA_38000_TurboWheels_Tiles:
.incbin "Assets/Turbo Wheels/Tiles.compressed"
.ends

.section "DATA_39168_Tanks_Tiles" force
DATA_39168_Tanks_Tiles:
.incbin "Assets/Tanks/Tiles.compressed"
.ends

.section "DATA_39C83_FourByFour_Tiles" force
DATA_39C83_FourByFour_Tiles:
.incbin "Assets/Four By Four/Tiles.compressed"
.ends

.section "DATA_3A8FA_Warriors_Tiles" force
DATA_3A8FA_Warriors_Tiles:
.incbin "Assets/Warriors/Tiles.compressed"
.ends

.section "DATA_3B32F_DisplayCaseTilemapCompressed" force
DATA_3B32F_DisplayCaseTilemapCompressed:
.incbin "Assets/Menu/DisplayCase.tilemap.compressed"
.ends

.section "DATA_3B37F_Tiles_DisplayCase" force
DATA_3B37F_Tiles_DisplayCase:
.incbin "Assets/Menu/DisplayCase.3bpp.compressed"
.ends

.section "RAM code and music engine data initialisation" force
; Much of this code could instead live in slots 0-1 - and some of it does, as redundant copies!
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
.db $00                     ; _RAM_D90F_MenuSound_Counter2
.db $00                     ; _RAM_D910_MenuSound_Counter4
.db $00                     ; _RAM_D911_MenuSound_Counter8
.db $00                     ; _RAM_D912_MenuSound_Counter16
.db $00                     ; _RAM_D913_MenuSound_NoiseGlobalAttenuation
.db $00                     ; _RAM_D914_MenuSound_GlobalAttenuation
.db $00                     ; _RAM_D915_MenuSound_RowDurationOverride
.db $00                     ; _RAM_D916_MenuSound_OffsetDownTone0
.db $00                     ; _RAM_D917_MenuSound_OffsetUpTone1
.db $00                     ; _RAM_D918_MenuSound_OffsetTone2_Always0
.db $00                     ; _RAM_D919_MenuSound_NoteOffset
.dw $0000                   ; _RAM_D91A_MenuSoundData.Tone0
.dw $0000                   ; _RAM_D91A_MenuSoundData.Tone1
.dw $0000                   ; _RAM_D91A_MenuSoundData.Tone2
.db PSG_NOISE_TONE2         ; _RAM_D91A_MenuSoundData.NoiseModeControl
.db PSG_ATTENUATION_SILENCE ; _RAM_D91A_MenuSoundData.NoiseAttenuation
.db PSG_ATTENUATION_SILENCE ; _RAM_D91A_MenuSoundData.Attenuation0
.db PSG_ATTENUATION_SILENCE ; _RAM_D91A_MenuSoundData.Attenuation1
.db PSG_ATTENUATION_SILENCE ; _RAM_D91A_MenuSoundData.Attenuation2
.dsb 4 $00                  ; _RAM_D91A_MenuSoundData.Unused
.dw $0000                   ; _RAM_D929_MenuSound_SequencePointer
.db $00                     ; _RAM_D92B_MenuSound_RowDurationCounter
.db $00                     ; _RAM_D92C_MenuSound_RowDuration
.dw $0000                   ; _RAM_D92D_MenuSound_PatternPointer
.db $00                     ; _RAM_D92F_MenuSound_PatternRowCounter
.db $00                     ; _RAM_D930_MenuSound_NoiseData

; Executed in RAM at d931
LABEL_3BAF1_MenusVBlank:
  push af
  push bc
  push de
  push hl
  push ix
  push iy
    ld a, (_RAM_D6D4_Slideshow_PendingLoad)
    CP_0
    jr z, + ; almost always the case
    ld a, ($BFFF) ; Last byte of currently mapped page is the bank number
    ld (_RAM_D742_VBlankSavedPageIndex), a ; save
    ld a, :Music_Update
    ld (PAGING_REGISTER), a
    call Music_Update
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
LABEL_3BB26_Trampoline_Music_Update:
  ld a, :Music_Update
  ld (PAGING_REGISTER), a
  call Music_Update
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at d971
LABEL_3BB31_Emit3bppTileDataToVRAM:
; hl = source
; de = count of rows (3 bytes data => 1 row of pixels in a tile) to emit
; Write address must be set
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
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
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
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
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
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
  DEC_A
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
+:add a, MenuTileIndex_Hand ; 0+ map to $bb+, -1 maps to $53
  ld (de), a
  inc hl
  inc de
  dec c
  jr nz, -
  CallRamCode LABEL_3BD08_BackToSlot2
  jp LABEL_93CE_UpdateSpriteTable

; Executed in RAM at da18
LABEL_3BBD8_EmitTilemap_DriverPortraitColumn_SMS:
; hl = source
; e = entry count
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
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
LABEL_3BBF8_EmitTilemap_DriverPortraitColumn_GG:
; hl = source
; de = dest VRAM address
; b = entry count
; c = width?
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
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
  ld e, 30 * TILE_HEIGHT ; Row count - 30 tiles
-:ld b, 3 ; bit depth
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
  ld e, 15 * TILE_HEIGHT ; 15 tiles
-:ld b, 3 ; bit depth
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
  ld e, 10 * TILE_HEIGHT ; 10 tiles
-:ld b, 3 ; bit depth
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
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
--:
  ld c, $05   ; Width
-:ld a, (hl) ; Emit a byte from (hl), high tileset
  out (PORT_VDP_DATA), a
  EmitDataToVDPImmediate8 1 ; high tileset
  inc hl
  dec c
  jr nz, - ; Loop over row
  ld a, (_RAM_D69E_EmitTilemapRectangle_Height) ; Decrement row counter
  DEC_A
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
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ; Emit 3bpp tile data for e rows
-:ld b, 3 ; bit depth
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
LABEL_3BCDC_Trampoline2_MusicStart:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  ld a, c
  call Music_Start
  JumpToRamCode LABEL_3BD08_BackToSlot2

; Executed in RAM at db26
LABEL_3BCE6_Trampoline2_Music_Stop:
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
  call Music_Stop
  JumpToRamCode LABEL_3BD08_BackToSlot2

.ifdef UNNECESSARY_CODE
LABEL_3BCEF_Trampoline_Unknown: ; unused?
  CallRamCode LABEL_3BCF5_RestorePagingFromD741
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
.ends

.ifdef BLANK_FILL_ORIGINAL
.repeat 188
.db $FF $FF $00 $00
.endr
.endif

  BankMarker

.BANK 15
.ORG $0000

.section "DATA_3C000_Sportscars_Tiles" force
DATA_3C000_Sportscars_Tiles:
.incbin "Assets/Sportscars/Tiles.compressed" ; bitplane-split 3bpp
.ends

.section "DATA_3CD8D_RuffTrux_Tiles" force
DATA_3CD8D_RuffTrux_Tiles:
.incbin "Assets/RuffTrux/Tiles.compressed" ; bitplane-split 3bpp
.ends

.section "DATA_3D901_Powerboats_Tiles" force
DATA_3D901_Powerboats_Tiles:
.incbin "Assets/Powerboats/Tiles.compressed" ; bitplane-split 3bpp
.ends

.section "DATA_3E5D7_Tiles_MediumLogo" force
DATA_3E5D7_Tiles_MediumLogo:
.incbin "Assets/Menu/Logo-Medium.3bpp.compressed" ; bitplane-split 3bpp
.ends

.section "DATA_3EC67_Tilemap_MediumLogo" force
DATA_3EC67_Tilemap_MediumLogo:
.incbin "Assets/Menu/Logo-Medium.tilemap.compressed"
.ends

.section "Vehicle names" force
DATA_3ECA9_VehicleNames:
; Ordered by MenuTT_ enum ordering
; Some are directly referenced, some not...
TEXT_VehicleName_Blank:         .asc "                "
_TEXT_VehicleName_Sportscars:   .asc "   SPORTSCARS   "
TEXT_VehicleName_Powerboats:    .asc "   POWERBOATS   "
_TEXT_VehicleName_FormulaOne:   .asc "  FORMULA  ONE  "
_TEXT_VehicleName_FourByFour:   .asc "  FOUR BY FOUR  "
_TEXT_VehicleName_Warriors:     .asc "    WARRIORS    "
_TEXT_VehicleName_Choppers:     .asc "    CHOPPERS    "
_TEXT_VehicleName_TurboWheels:  .asc "  TURBO WHEELS  "
_TEXT_VehicleName_Tanks:        .asc "      TANKS     "
TEXT_Vehicle_Name_Rufftrux:     .asc "    RUFFTRUX    "
.ends

.section "Splash screen" force
SplashScreenCompressed:
.incbin "Assets/Splash screen/SplashScreen.bin.compressed"
.ends

.section "Jon's Squinky Tennis" force
JonsSquinkyTennisCompressed:
.incbin "Assets/Jon's Squinky Tennis/JonsSquinkyTennis.gg.compressed"
.ends

.ifdef BLANK_FILL_ORIGINAL
.repeat 33
.dw $0000, $ffff
.endr
.dw $0000
.endif

  BankMarker


