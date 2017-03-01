; This disassembly was created using Emulicious (http://www.emulicious.net)
.memorymap
slotsize $7ff0
slot 0 $0000
slotsize $10
slot 1 $7ff0
slotsize $4000
slot 2 $8000
defaultslot 2
.endme
.rombankmap
bankstotal 16
banksize $7ff0
banks 1
banksize $10
banks 1
banksize $4000
banks 14
.endro

; SMS stuff
.include "System definitions.inc"

.enum 0 ; TrackTypes
TT_SportsCars   db ; 0
TT_FourByFour   db ; 1
TT_Powerboats   db ; 2
TT_TurboWheels  db ; 3
TT_FormulaOne   db ; 4
TT_Warriors     db ; 5
TT_Tanks        db ; 6
TT_RuffTrux     db ; 7
TT_Helicopters  db ; 8 - Incomplete support
TT_Unknown9       db ; 9 - for portrait drawing only?
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
MenuScreen_None               db ; 0 Do-nothing
MenuScreen_Title              db ; 1 Title screen with credits, image slideshow, etc
MenuScreen_SelectPlayerCount  db ; 2 Select Game - One Player, Two Player
MenuScreen_OnePlayerSelectCharacter db ; 3 One-player Who Do You Want To Be?
MenuScreen_RaceName           db ; 4 Qualifying Race
MenuScreen_Unused5            db ; 5 Uused, same as 0?
MenuScreen_Qualify            db ; 6 Qualified for challenge!, Failed to qualify!
MenuScreen_WhoDoYouWantToRace db ; 7 Who do you want to race?
MenuScreen_StorageBox         db ; 8 Car storage box
MenuScreen_OnePlayerTrackIntro db ; 9 1-player pre-track
MenuScreen_OnePlayerTournamentResults db ; a 1-player tournament results
MenuScreen_UnknownB           db ; b
MenuScreen_LifeList           db ; c One life lost!, Game over!
MenuScreen_UnknownD           db ; d
MenuScreen_TwoPlayerSelectCharacter db ; e Two-player Who Do You Want To Be? (head to head)
MenuScreen_TwoPlayerGameType  db ; f Two player choose game (tournament or single race)
MenuScreen_TrackSelect        db ; 10 Track select cheat, two-player pre-track and track select
MenuScreen_TwoPlayerResult    db ; 11 Two-player win/lose
MenuScreen_TournamentChampion db ; 12 Tournament champion!
MenuScreen_OnePlayerMode      db ; 13 Challenge or Head to Head
.ende

; ASCII mapping for menu screen text
.define BLANK_TILE_INDEX = $0e
.define ZERO_DIGIT_TILE_INDEX = $1a
.define HYPHEN_TILE_INDEX = $b5
.asctable
map "A" to "N" = $00
map "O" = $1a
map "P" to "Z" = $0f
map "0" to "9" = ZERO_DIGIT_TILE_INDEX
map " " = BLANK_TILE_INDEX
map "!" = $B4
map "-" = HYPHEN_TILE_INDEX
map "?" = $B6
.enda

.define STACK_TOP $dfff

.macro CallPagedFunction args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  call _LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro JumpToPagedFunction args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  jp _LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro JrToPagedFunction args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  jr _LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro CallPagedFunction2 args function
  ld a, :function
  ld (PAGING_REGISTER), a
  call function
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
.endm

.macro TilemapWriteAddressToHL args x, y
  ld hl, VDP_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TilemapWriteAddressToDE args x, y
  ld de, VDP_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TilemapWriteAddressToBC args x, y
  ld bc, VDP_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TilemapWriteAddressData args x, y
.dw VDP_WRITE_MASK | NAME_TABLE_ADDRESS + y * 64 + x * 2
.endm

.macro TileWriteAddressToHL args index
  ld hl, VDP_WRITE_MASK | (index * 32)
.endm

.macro TileWriteAddressData args index
.dw VDP_WRITE_MASK | (index * 32)
.endm

.macro SetVRAMAddressImmediate args address
  ld a, <address
  out (PORT_VDP_ADDRESS), a
  ld a, >address
  out (PORT_VDP_ADDRESS), a
.endm

.macro SetPaletteAddressImmediateSMS args index
  SetVRAMAddressImmediate index + $c000
.endm

.macro SetPaletteAddressImmediateGG args index
  SetVRAMAddressImmediate index*2 + $c000
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

.enum $C000 export
_RAM_C000_StartOfRam .db
_RAM_C000_DecompressionTemporaryBuffer .db ; $800?
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
_RAM_D58A_ db
_RAM_D58B_ db
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
_RAM_D59A_ db
_RAM_D59B_ db
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
_RAM_D5CF_ db
_RAM_D5D0_ db
_RAM_D5D1_ db ; unused?
_RAM_D5D2_ db
_RAM_D5D3_ db
_RAM_D5D4_ db
_RAM_D5D5_ db
_RAM_D5D6_ db
_RAM_D5D7_ db
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
_RAM_D68C_ db
_RAM_D68D_ db
_RAM_D68E_ db
_RAM_D68F_ db
_RAM_D690_ db
_RAM_D691_TrackType db
_RAM_D692_ db
_RAM_D693_ db
_RAM_D694_ db
_RAM_D695_ db
_RAM_D696_ db
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
_RAM_D6AB_ db
_RAM_D6AC_ db
_RAM_D6AD_ db
_RAM_D6AE_ db
_RAM_D6AF_FlashingCounter db
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
_RAM_D6BE_ dw
_RAM_D6C0_ db
_RAM_D6C1_ db
_RAM_D6C2_DisplayCase_FlashingCarIndex db
_RAM_D6C3_ db
_RAM_D6C4_ db ; Per-course value, usually -1, sometimes 0, 1, 2
_RAM_D6C5_PaletteFadeIndex db
_RAM_D6C6_ db
_RAM_D6C7_ db ; 0 or 1
_RAM_D6C8_HeaderTilesIndexOffset db
_RAM_D6C9_ControllingPlayersLR1Buttons db ; Combination of player 1 and 2 when applicable, else player 1
_RAM_D6CA_ db
_RAM_D6CB_ db
_RAM_D6CC_ db
_RAM_D6CD_ db
_RAM_D6CE_ db
_RAM_D6CF_ db
_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect db
_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen db ; Used for "debouncing"
_RAM_D6D2_Unused db
_RAM_D6D3_VBlankDone db
_RAM_D6D4_ db
_RAM_D6D5_InGame db
_RAM_D6D6_ db
_RAM_D6D7_ dsb 10 ; unused?
_RAM_D6E1_SpriteData .db
_RAM_D6E1_SpriteX dsb 32
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
_RAM_D7B5_DecompressorSource dw
_RAM_D7B7_ db
_RAM_D7B8_ db
_RAM_D7B9_ db
_RAM_D7BA_HardModeTextFlashCounter db
_RAM_D7BB_ db
_RAM_D7BB_MenuRamEnd .db
_RAM_D7BC_ db ; unused?
_RAM_D7BD_RamCode dsb $392 ; runs over the next bit
.ende

; These macros allow us to call into RAM code from the above address
.macro CallRamCode args address
  call address+_RAM_D7BD_RamCode-_LABEL_3B97D_RamCodeStart
.endm
.macro JumpToRamCode args address
  jp address+_RAM_D7BD_RamCode-_LABEL_3B97D_RamCodeStart
.endm
.macro CallRamCodeIfZFlag args address
  call z, address+_RAM_D7BD_RamCode-_LABEL_3B97D_RamCodeStart
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
_RAM_D963_SFXTrigger2 db
_RAM_D964_Sound1Control db
_RAM_D965_ dsb 6 ; unused?
_RAM_D96B_SoundMask db
_RAM_D96C_ db
_RAM_D96D_ db
_RAM_D96E_ db ; unused?
_RAM_D96F_ db
_RAM_D970_ dsb 4 ; unused?
_RAM_D974_SFXTrigger db
_RAM_D975_Sound2Control db
_RAM_D976_ dsb 6 ; unused?
_RAM_D97C_Sound db
_RAM_D97D_ dsb 3 ; unused?

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
_RAM_DB68_ db
_RAM_DB69_ db
_RAM_DB6A_ db
_RAM_DB6B_ db
_RAM_DB6C_ db
_RAM_DB6D_ db
_RAM_DB6E_ db
_RAM_DB6F_ db
_RAM_DB70_ db
_RAM_DB71_ db
_RAM_DB72_ db
_RAM_DB73_ db
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
_RAM_DB9C_ dw
_RAM_DB9E_ db
_RAM_DB9F_ db ; unused?
_RAM_DBA0_ dw
_RAM_DBA2_ dw
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
_RAM_DBC0_EnterGameTrampoline dsb 13
_RAM_DBCD_MenuIndex db
_RAM_DBCE_ db
_RAM_DBCF_LastRacePosition db
_RAM_DBD0_HeadToHeadLost2 db
_RAM_DBD1_ db
_RAM_DBD2_ db
_RAM_DBD3_ db
_RAM_DBD4_ db
_RAM_DBD5_ db
_RAM_DBD6_ db
_RAM_DBD7_ db
_RAM_DBD8_CourseSelectIndex db
_RAM_DBD9_DisplayCaseData dsb $18 ; includes the following three labels; 0 = blank, 1 = filled, 2 = flashing
_RAM_DBF1_RaceNumberText dsb 8 ; "RACE xx-", xx is replaced at runtime
_RAM_DBF9_ dw
_RAM_DBFB_ db
_RAM_DBFC_ db
_RAM_DBFD_ db
_RAM_DBFE_ dsb 11
_RAM_DC09_Lives db
_RAM_DC0A_ db
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
_RAM_DC21_ db
.ende

.enum $DC2C export
_RAM_DC2C_ db
.ende

.enum $DC31 export
_RAM_DC31_ db
.ende

.enum $DC34 export
_RAM_DC34_IsTournament db
_RAM_DC35_TournamentRaceNumber db
_RAM_DC36_ db
_RAM_DC37_ db
_RAM_DC38_ db
_RAM_DC39_ db
_RAM_DC3A_ db
_RAM_DC3B_IsTrackSelect db
_RAM_DC3C_IsGameGear db ; Most code is common with the GG game
_RAM_DC3D_IsHeadToHead db
_RAM_DC3E_InMenus db ; 1 in menus, 0 otherwise
_RAM_DC3F_GameMode db
_RAM_DC40_ db
_RAM_DC41_GearToGearActive db
_RAM_DC42_GearToGear_IAmPlayer1 db
.ende

.enum $DC45 export
_RAM_DC45_TitleScreenCheatCodeCounter_HardMode db ; Counts up correct keypresses
_RAM_DC46_Cheat_HardMode db ; 0 = normal 1 = hard 2 = rock hard
_RAM_DC47_GearToGear_OtherPlayerControls1 db
_RAM_DC48_GearToGear_OtherPlayerControls2 db
_RAM_DC49_Cheat_ExplosiveOpponents db
_RAM_DC4A_Cheat_ExtraLives db
_RAM_DC4B_Cheat_InfiniteLives db
_RAM_DC4C_Cheat_AlwaysFirstPlace db
_RAM_DC4D_Cheat_NoSkidding db
_RAM_DC4E_Cheat_SuperSkids db
_RAM_DC4F_Cheat_EasierOpponents db
_RAM_DC50_Cheat_FasterVehicles db
_RAM_DC51_PreviousCombinedByte db
_RAM_DC52_PreviousCombinedByte2 db
_RAM_DC52_ db ; unused?
_RAM_DC54_IsGameGear db ; GG mode if 1, SMS mode if 0
_RAM_DC55_CourseIndex db
_RAM_DC56_ db ;
_RAM_DC57_ dw
_RAM_DC59_FloorTiles dsb 32*2 ; 1bpp tile data
_RAM_DC99_EnterMenuTrampoline dsb 18 ; Code in RAM
_RAM_DCAB_ dw
_RAM_DCAD_ dw
_RAM_DCAF_ db
_RAM_DCB0_ db
.ende

.enum $DCB5 export
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
_RAM_DCEC_ db
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
_RAM_DD2D_ dw
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
_RAM_DE6D_ db
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
_RAM_DE8A_ db
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
_RAM_DEB3_ db
_RAM_DEB4_ db
_RAM_DEB5_ db
_RAM_DEB6_ db
_RAM_DEB7_ db
_RAM_DEB8_ db
_RAM_DEB9_ db
_RAM_DEBA_ db
_RAM_DEBB_ db
_RAM_DEBC_TileDataIndex db
_RAM_DEBD_ db
_RAM_DEBE_ db
_RAM_DEBF_ dw
_RAM_DEC1_VRAMAddress instanceof Word
_RAM_DEC3_ db
_RAM_DEC4_ db
_RAM_DEC5_ db
_RAM_DEC6_ db
_RAM_DEC7_ db
_RAM_DEC8_ db
_RAM_DEC9_ db
_RAM_DECA_ db
_RAM_DECB_ db
_RAM_DECC_ db
_RAM_DECD_ db
_RAM_DECE_ db
_RAM_DECF_RectangleWidth dw
_RAM_DED1_ db
_RAM_DED2_ db
_RAM_DED3_HScrollValue db
_RAM_DED4_VScrollValue db
_RAM_DED5_ db
_RAM_DED6_ db
_RAM_DED7_ db
_RAM_DED8_ db
_RAM_DED9_ db
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
_RAM_DEF8_ db
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
_RAM_DF1F_ db
_RAM_DF20_ db
_RAM_DF21_ db
_RAM_DF22_ db
.ende

.enum $DF24 export
_RAM_DF24_LapsRemaining db
_RAM_DF25_ db
_RAM_DF26_ db
_RAM_DF27_ db
_RAM_DF28_ db
_RAM_DF29_ db
_RAM_DF2A_ db
_RAM_DF2B_ db
_RAM_DF2C_ db
_RAM_DF2D_ db
_RAM_DF2E_ dsb 9 ;Data copied from _DATA_A7F_GG or _DATA_A6D_SMS
_RAM_DF37_ db
_RAM_DF38_ db
.ende

.enum $DF3C export
_RAM_DF3C_ db
_RAM_DF3D_ db
_RAM_DF3E_ db
_RAM_DF3F_ db
_RAM_DF40_ dsb 9 ; Data copied from _DATA_A88_GG or _DATA_A76_SMS
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
_RAM_DF5A_ db
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
_RAM_DF8C_ db
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

  di
  ld hl, STACK_TOP
  ld sp, hl
  call _LABEL_100_Startup ; Copies things to RAM and more
  xor a
  ld (_RAM_DC41_GearToGearActive), a
  ld a, :_LABEL_8000_Main
  ld (PAGING_REGISTER), a
  jp _LABEL_8000_Main

_LABEL_14_EnterMenus:
  ; Code jumps here when transitioning from game to menus
  di
  ld a, :_LABEL_8021_MenuScreenEntryPoint
  ld (PAGING_REGISTER), a
  ld a, 1
  ld (_RAM_DC3E_InMenus), a
  ld hl, STACK_TOP
  ld sp, hl
  jp _LABEL_8021_MenuScreenEntryPoint

; Data from 26 to 37 (18 bytes)
.db "P HL", 13, 10, 9, "INC HL", 13, 10, 9, "LD" ; Source code left in RAM

_LABEL_38_:
  push af
    ld a, (_RAM_DC3E_InMenus)
    or a
    jr z, ++
    cp $01
    jr z, +
    ; Unreachable code
    in a, (PORT_VDP_STATUS) ; Ack INT
  pop af
  ei
  reti

+:; In menus
  pop af
  JumpToRamCode _LABEL_3BAF1_MenusVBlank

++:; In game
  pop af
  call _LABEL_199_GameVBlank
  ei
  reti

; Data from 54 to 65 (18 bytes)
.db " (CH2MAP2+9),A", 13, 10, 9, "L" ; Source code left in RAM

_LABEL_66_NMI:
  push af
    ld a, (_RAM_DC3C_IsGameGear)
    or a
    jp nz, _LABEL_9BF_NMI_GG
    jp _LABEL_517F_NMI_SMS

; Data from 71 to 74 (4 bytes)
.db "9),A" ; Source code left in RAM

; Executed in RAM at dbc0
_LABEL_75_EnterGameTrampolineImpl:
  ld a, $00
  ld (PAGING_REGISTER_Slot0), a
  ld a, $01
  ld (PAGING_REGISTER_Slot1), a
  jp _LABEL_7573_EnterGame

; Data from 82 to 95 (20 bytes)
; Copied to $dbcd onwards
; This initialises a bunch of stuff...
; _RAM_DBCD_MenuIndex onwards
.db $00 $01 $01 $00 $03 $02 $50 $50 $00 $00 $00 $00
; _RAM_DBD9_DisplayCaseData
.dsb 24 0
; _RAM_DBF1_RaceNumberText
.asc "RACE 01-" ;.db $11 $00 $02 $04 $0E $1A $1B $B5
; End stuff copied to RAM

; Data from AE to BF (18 bytes), copied to RAM $dc99..$dcaa
_LABEL_AE_EnterMenuTrampolineImpl:
  di
  ld a,:_LABEL_8000_Main
  ld (PAGING_REGISTER),a
  ld a, 1
  ld (_RAM_DC3E_InMenus),a
  ld hl, STACK_TOP
  ld sp, hl
  jp _LABEL_8000_Main
_LABEL_AE_EnterMenuTrampolineImplEnd:

; Data from C0 to FF (64 bytes)
_DATA_C0_FloorTilesRawTileData:
.repeat 8
.db $00 $00 $FF $00
.endr
.repeat 8
.db $00 $00 $00 $00
.endr
_DATA_C0_FloorTilesRawTileDataEnd:

_LABEL_100_Startup:
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
  ld de, _LABEL_75_EnterGameTrampolineImpl  ; Loading Code and data into RAM
  ld bc, $0039
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  call _LABEL_173_LoadEnterMenuTrampolineToRAM

  ld hl, _RAM_DC59_FloorTiles ; Fill floor tiles buffer with data
  ld de, _DATA_C0_FloorTilesRawTileData
  ld bc, _DATA_C0_FloorTilesRawTileDataEnd - _DATA_C0_FloorTilesRawTileData
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  call _LABEL_186_InitialiseSoundData
  ; More RAM initialisation
  ld a, $01
  ld (_RAM_DBA8_), a
  ld a, $20
  ld (_RAM_DB9C_), a
  ld (_RAM_DB9E_), a
  ld hl, _RAM_DB22_
  ld (_RAM_DB62_), hl
  ld hl, _RAM_DB42_
  ld (_RAM_DB64_), hl
  ld a, $1A
  ld (_RAM_DC39_), a
_LABEL_156_:
  ld a, $00
  ld (_RAM_DC54_IsGameGear), a ; Set to SMS mode
  or a
  jr z, +
  ld a, $05
  ld (_RAM_DC56_), a ; If GG
  ld a, $28
  ld (_RAM_DC57_), a
  jp ++ ; ret
+:xor a
  ld (_RAM_DC56_), a ; If SMS
  ld (_RAM_DC57_), a
++:ret

_LABEL_173_LoadEnterMenuTrampolineToRAM:
  ; Copy some code to RAM
  ld hl, _RAM_DC99_EnterMenuTrampoline
  ld de, _LABEL_AE_EnterMenuTrampolineImpl
  ld bc, _LABEL_AE_EnterMenuTrampolineImplEnd - _LABEL_AE_EnterMenuTrampolineImpl
  ; Could ldir
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

_LABEL_186_InitialiseSoundData:
  ld hl, _RAM_D94C_SoundData
  ld de, _DATA_650C_SoundInitialisationData
  ld bc, _DATA_650C_SoundInitialisationData_End - _DATA_650C_SoundInitialisationData
-:ld a, (de)
  ld (hl), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

_LABEL_199_GameVBlank:
  push af
    ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
    or a
    jr nz, _LABEL_1E0_SkipVBlank
    push hl
    push bc
    push de
    push ix
    push iy
      ld a, (_DATA_BFFF_Page2PageNumber)
      push af
        ld a, (_RAM_D5B5_EnableGameVBlank)
        or a
        jr z, +
        xor a
        ld (_RAM_D580_WaitingForGameVBlank), a
        call _LABEL_33A_GameVBlankVDPWork
        ld a, (_RAM_DC41_GearToGearActive)
        or a
        jr nz, +
        ld a, (_RAM_D599_IsPaused)
        or a
        jr nz, +
        call _LABEL_5169_GameVBlankEngineUpdateTrampoline
        call _LABEL_5174_GameVBlankPart3Trampoline
        CallPagedFunction _LABEL_2B5D2_GameVBlankUpdateSoundTrampoline
+:
      pop af
      ld (PAGING_REGISTER), a
    pop iy
    pop ix
    pop de
    pop bc
    pop hl
_LABEL_1E0_SkipVBlank:
    in a, (PORT_VDP_STATUS) ; Ack INT
  pop af
  ret

_LABEL_1E4_:
  call _LABEL_519D_
  ld a, (_RAM_D599_IsPaused)
  or a
  jp nz, _LABEL_29D_
  ld a, (_RAM_DF7F_)
  or a
  call nz, _LABEL_AB1_
  call _LABEL_12D5_
  call _LABEL_12BF_
  call _LABEL_11BA_
  call _LABEL_12CA_
  ld a, (_RAM_D5B6_)
  or a
  call nz, _LABEL_65C7_
  ld a, (_RAM_D5B7_)
  or a
  call nz, _LABEL_B04_
  call _LABEL_F9B_
  call _LABEL_22CD_
  call _LABEL_265F_
  call _LABEL_5E3A_
  call _LABEL_648E_
  call _LABEL_49C9_
  call _LABEL_4465_
  call _LABEL_44C3_
  call _LABEL_4622_
  call _LABEL_479E_
  call _LABEL_6756_
  call _LABEL_6A97_
  call _LABEL_6A6C_
  call _LABEL_6A8C_
  ld a, (_RAM_D940_)
  cp $02
  call z, _LABEL_A9D_
  ld a, (_RAM_D945_)
  cp $02
  call z, _LABEL_AA7_
  xor a
  ld (_RAM_DD9B_), a
  ld (_RAM_DDCB_), a
  ld (_RAM_DDFB_), a
  ld (_RAM_DE2B_), a
  call _LABEL_27B1_
  call _LABEL_1DF2_
  call _LABEL_3164_
  call _LABEL_317C_
  call _LABEL_343A_
  call _LABEL_3445_
  call _LABEL_3F3F_
  call _LABEL_523B_
  call _LABEL_3D59_
  call _LABEL_3DBD_
  call _LABEL_AC5_
  call _LABEL_2857_
  call _LABEL_ABB_
  call _LABEL_5A88_
  call _LABEL_AF5_
  call _LABEL_1593_
  call _LABEL_16C0_
  call _LABEL_318_
  call _LABEL_4927_
  CallPagedFunction _LABEL_371F1_
  call _LABEL_318_
_LABEL_29D_:
  call _LABEL_3450_
  call _LABEL_35E0_
  call _LABEL_318_
  call _LABEL_73D4_
  call _LABEL_318_
  call _LABEL_84A_
  call _LABEL_318_
  call _LABEL_3A23_
  call _LABEL_6540_
  ld a, (_RAM_D5CB_)
  or a
  call nz, _LABEL_7B0B_
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, +
  in a, (PORT_VDP_LINECOUNTER)
  cp $B8
  jr nc, _LABEL_315_
+:
  call _LABEL_64C9_
  call _LABEL_2D63_
  call _LABEL_318_
  ld a, (_RAM_D599_IsPaused)
  or a
  jr nz, _LABEL_300_
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  call _LABEL_5169_GameVBlankEngineUpdateTrampoline
  call _LABEL_5174_GameVBlankPart3Trampoline
  call _LABEL_318_
  CallPagedFunction _LABEL_2B5D2_GameVBlankUpdateSoundTrampoline
  call _LABEL_318_
+:
  call _LABEL_BF0_UpdateFloorTiles
  call _LABEL_AE1_
  call _LABEL_318_
_LABEL_300_:
  ld a, (_RAM_DF6A_)
  or a
  jr z, + ; ret
  dec a
  ld (_RAM_DF6A_), a
  or a
  jr nz, + ; ret
  inc a
  ld (_RAM_DF6A_), a
  ld (_RAM_D5D6_), a
+:
  ret

_LABEL_315_:
  jp _LABEL_300_

_LABEL_318_:
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  ret z
  ld a, (_RAM_D5D7_)
  or a
  ret nz
  in a, (PORT_VDP_LINECOUNTER)
  cp $B8
  jr c, + ; ret
  cp $F0
  jr nc, + ; ret
  call _LABEL_33A_GameVBlankVDPWork
  ld a, $01
  ld (_RAM_D5D7_), a
+:
  ret

-:
  xor a
  ld (_RAM_DBA8_), a
  ret

_LABEL_33A_GameVBlankVDPWork:
  ld a, (_RAM_DBA8_)
  cp $01
  jr z, -
  call _LABEL_7795_ScreenOff
  call _LABEL_78CE_
  call _LABEL_7916_

  ; Update scroll registers
  ld a, (_RAM_DED4_VScrollValue)
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_YSCROLL
  out (PORT_VDP_REGISTER), a
  ld a, (_RAM_DED3_HScrollValue)
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_XSCROLL
  out (PORT_VDP_REGISTER), a

  call _LABEL_31F1_UpdateSpriteTable
  call _LABEL_324C_UpdatePerFrameTiles
  ld a, (_RAM_D5CC_PlayoffTileLoadFlag)
  or a
  jr z, +
  CallPagedFunction _LABEL_17E95_LoadPlayoffTiles ; Call only when flag is set, then reset it
  xor a
  ld (_RAM_D5CC_PlayoffTileLoadFlag), a
+:call _LABEL_BC5_UpdateFloorTiles
  call _LABEL_2D07_UpdatePalette_RuffTruxSubmerged
  call _LABEL_3FB4_UpdateAnimatedPalette
  jp _LABEL_778C_ScreenOn

_LABEL_383_:
  call _LABEL_3ED_
--:
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr nz, +
  call _LABEL_AFD_ReadControls
-:
  ld a, (_RAM_D580_WaitingForGameVBlank)
  or a
  jr nz, -
  xor a
  ld (_RAM_D5B5_EnableGameVBlank), a
  call _LABEL_1E4_
  ld a, (_RAM_D5D6_)
  or a
  jp nz, _LABEL_7476_
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
  jp nz, _LABEL_7476_
  ld a, (_RAM_D5D8_)
  or a
  jr z, --
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  out (PORT_GG_LinkSend), a
  xor a
  ld (_RAM_D5D7_), a
  ld (_RAM_D5D8_), a
  call _LABEL_AFD_ReadControls
  call _LABEL_1E4_
  ld a, (_RAM_D5D7_)
  or a
  jr nz, --
-:
  in a, (PORT_VDP_LINECOUNTER)
  cp $B8
  jr c, -
  cp $F0
  jr nc, -
  call _LABEL_33A_GameVBlankVDPWork
  jr --

_LABEL_3ED_:
  call _LABEL_318E_
  call _LABEL_3F22_ScreenOff
  call _LABEL_3F54_
  call _LABEL_19EE_
  call _LABEL_7C7D_
  call _LABEL_3A2E_
  call _LABEL_31B6_InitialiseFloorTiles
  call _LABEL_3C54_
  call _LABEL_458_PatchForLevelTrampoline
  call _LABEL_51A8_
  call _LABEL_1345_
  call _LABEL_77CD_
  call _LABEL_1801_
  call _LABEL_3231_
  call _LABEL_3F2B_
  call _LABEL_3199_
  call _LABEL_AEB_
  call _LABEL_7564_SetControlsToNoButtons
  call _LABEL_186_InitialiseSoundData
  call ++
  ld a, $0A
  ld (_RAM_D96F_), a
  ld a, $01
  ld (_RAM_D5B5_EnableGameVBlank), a
  xor a
  ld (_RAM_D946_), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, $38
  out (PORT_GG_LinkStatus), a
  call _LABEL_7564_SetControlsToNoButtons
  call _LABEL_AD7_DelayIfPlayer2
+:
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr nz, +
  call _LABEL_3F36_ScreenOn
  im 1
  ei
  ret

+:
  im 1
  di
  ret

_LABEL_458_PatchForLevelTrampoline:
  JumpToPagedFunction _LABEL_36484_PatchForLevel

++:
  JumpToPagedFunction _LABEL_2B5D5_SilencePSG

; Data from 46E to 4AD (64 bytes)
_DATA_46E_:
.db $04 $17 $0C $17 $81 $13 $06 $16 $84 $0F $02 $15 $86 $0B $83 $12
.db $87 $04 $87 $0C $83 $82 $86 $05 $02 $85 $84 $01 $81 $83 $06 $86
.db $04 $87 $0C $87 $0A $86 $11 $83 $0E $85 $14 $01 $13 $82 $16 $05
.db $17 $04 $17 $0C $16 $0B $13 $12 $14 $0F $0E $15 $11 $13 $0A $16

; Data from 4AE to 4B0 (3 bytes)
_DATA_4AE_:
.db $00 $06 $0C

; Data from 4B1 to 4B1 (1 bytes)
_DATA_4B1_:
.db $03

_LABEL_4B2_:
  ld a, (iy+24)
  or a
  jr z, +
  sub $01
  ld (iy+24), a
  ret

+:
  ld a, (_DATA_4B1_)
  ld (iy+24), a
  ld a, (iy+25)
  ld e, a
  ld d, $00
  ld hl, _DATA_4AE_
  add hl, de
  ld a, (hl)
  ld e, a
  ld d, $00
  add ix, de
  ld a, (iy+21)
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_46E_
  add hl, de
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld c, $04
  jp ++

+:
  ld c, $00
++:
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
  ld (ix+0), a
  jp ++

+:
  ld a, (iy+22)
  add a, b
  add a, c
  ld (ix+0), a
++:
  inc hl
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
  ld (ix+2), a
  jp ++

+:
  ld a, (iy+23)
  add a, b
  add a, c
  ld (ix+2), a
++:
  inc hl
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

+:
  ld a, (iy+22)
  add a, b
  add a, c
  ld (ix+3), a
++:
  inc hl
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

+:
  ld a, (iy+23)
  add a, b
  add a, c
  ld (ix+5), a
++:
  ld de, $001A
  add ix, de
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, +
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

+:
  xor a
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

_LABEL_5C8_ret:
  ret

_LABEL_5C9_:
  ld iy, _RAM_DD6E_
  ld ix, $DD6E
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
  call _LABEL_4B2_
  jp _LABEL_69C_

_LABEL_5FA_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, _LABEL_5C8_ret ; 7 when nz, 12+10 otherwise; ret z = 5/11 so always better(!)
  ld iy, _RAM_DD9E_
  ld ix, $DD9E
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
  call _LABEL_4B2_
  jp _LABEL_69C_

_LABEL_633_:
  ld iy, _RAM_DDCE_
  ld ix, $DDCE
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
  call _LABEL_4B2_
  jp _LABEL_69C_

_LABEL_665_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jp z, _LABEL_5C8_ret
  ld iy, _RAM_DDFE_
  ld ix, $DDFE
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
  call _LABEL_4B2_
_LABEL_69C_:
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
  jr z, _LABEL_702_
  call _LABEL_7DD_
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
  call _LABEL_723_
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

_LABEL_702_:
  call _LABEL_780_
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

_LABEL_723_:
  ld a, (iy+19)
  or a
  jr z, _LABEL_76B_
  ld a, (iy+26)
  or a
  jr z, _LABEL_76B_
  push hl
    ld a, (iy+27)
    sla a
    sla a
    ld c, a
    ld b, $00
    ld a, (_RAM_DB97_TrackType)
    cp TT_RuffTrux
    jr nz, +
    ld hl, _DATA_842_RuffTrux
    jp ++

+:
    ld hl, _DATA_83A_NotRuffTrux
++:
    add hl, bc
    ld a, (iy+28)
    ld c, a
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (iy+1), a
    ld (iy+4), a
    ld a, c
    cp $03
    jr z, +
    add a, $01
    ld (iy+28), a
  pop hl
  ret

+:
    xor a
    ld (iy+26), a
  pop hl
  ret

_LABEL_76B_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld a, $68 ; RuffTrux
  jp ++

+:
  ld a, $AC ; Not RuffTrux
++:
  ld (iy+1), a
  ld (iy+4), a
  ret

_LABEL_780_:
  ld a, (iy+19)
  or a
  jr z, _LABEL_7C8_
  ld a, (iy+32)
  or a
  jr z, _LABEL_7C8_
  push hl
    ld a, (iy+33)
    sla a
    sla a
    ld c, a
    ld b, $00
    ld a, (_RAM_DB97_TrackType)
    cp TT_RuffTrux
    jr nz, +
    ld hl, _DATA_842_RuffTrux
    jp ++

+:
    ld hl, _DATA_83A_NotRuffTrux
++:
    add hl, bc
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

+:
    xor a
    ld (iy+32), a
  pop hl
  ret

_LABEL_7C8_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld a, $68 ; RuffTrux
  jp ++

+:
  ld a, $AC ; Not RuffTrux
++:
  ld (iy+7), a
  ld (iy+10), a
  ret

_LABEL_7DD_:
  ld a, (iy+19)
  or a
  jr z, _LABEL_825_
  ld a, (iy+38)
  or a
  jr z, _LABEL_825_
  push hl
    ld a, (iy+39)
    sla a
    sla a
    ld c, a
    ld b, $00
    ld a, (_RAM_DB97_TrackType)
    cp TT_RuffTrux
    jr nz, +
    ld hl, _DATA_842_RuffTrux
    jp ++
+:  ld hl, _DATA_83A_NotRuffTrux
++: add hl, bc
    ld a, (iy+40)
    ld c, a
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (iy+13), a
    ld (iy+16), a
    ld a, c
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

_LABEL_825_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld a, $68 ; RuffTrux
  jp ++
+:ld a, $AC ; Not RuffTrux
++:ld (iy+13), a
  ld (iy+16), a
  ret

; Data from 83A to 841 (8 bytes)
_DATA_83A_NotRuffTrux:
.db $AD $AE $AF $AC $B2 $B1 $B0 $AC

; Data from 842 to 849 (8 bytes)
_DATA_842_RuffTrux:
.db $EB $F8 $FB $68 $EB $F8 $FB $68

_LABEL_84A_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jp z, _LABEL_97C_RuffTrux
  ; RuffTrux
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
  ld a, (_RAM_DF2A_)
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  call _LABEL_97F_
  jp ++

+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jr nz, +
  call _LABEL_6611_Tanks
  jp ++
+:call _LABEL_5C9_ ; Not tanks
++:ld a, (_RAM_DCC5_)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_8DC_
  ld a, (_RAM_DCBC_)
  ld (_RAM_DF66_), a
  ld a, (_RAM_DCC0_)
  cp $01
  jr z, +
  ld a, $F0
  jp ++
+:ld a, (_RAM_DCBD_)
++:ld (_RAM_DF67_), a
  ld a, (_RAM_DF2B_)
  ld ix, _RAM_DA60_SpriteTableXNs.59
  ld iy, _RAM_DAE0_SpriteTableYs.59
  call _LABEL_97F_
  jp _LABEL_8DC_
+++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_8DC_
  call _LABEL_661C_
  jp _LABEL_8DC_

+:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, _LABEL_8DC_
  call _LABEL_5FA_
_LABEL_8DC_:
  ld a, (_RAM_DD06_)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_92D_
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
  ld a, (_RAM_DF2C_)
  ld ix, _RAM_DA60_SpriteTableXNs.61
  ld iy, _RAM_DAE0_SpriteTableYs.61
  call _LABEL_97F_
  jp _LABEL_92D_

+++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jr nz, +
  call _LABEL_6627_
  jp _LABEL_92D_

+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, _LABEL_92D_
+:
  call _LABEL_633_
_LABEL_92D_:
  ld a, (_RAM_DD47_)
  or a
  jr z, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_97B_ret
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
  ld a, (_RAM_DF2D_)
  ld ix, _RAM_DA60_SpriteTableXNs.63
  ld iy, _RAM_DAE0_SpriteTableYs.63
  jp _LABEL_97F_

+++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_97B_ret
  call _LABEL_6632_
  jp _LABEL_97B_ret

+:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, _LABEL_97B_ret
  jp _LABEL_665_

_LABEL_97B_ret:
  ret

_LABEL_97C_RuffTrux:
  jp _LABEL_5C9_

_LABEL_97F_:
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_9AA_
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

; Data from 9AA to 9B1 (8 bytes)
_DATA_9AA_:
.db $A4 $98 $A5 $99 $A6 $9A $A7 $9B

_LABEL_9B2_ConvertMetatileIndexToDataIndex:
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

_LABEL_9BF_NMI_GG:
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

; Data from 9EB to 9EC (2 bytes)
_DATA_9EB_ValueC000:
.dw $C000


; Data in range $7700 .. $7e00

; Data from 9ED to A2C (64 bytes)
_DATA_9ED_:
; Low byte of tilemap address for different row indexes
.db $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0

; Data from A2D to A6C (64 bytes)
_DATA_A2D_:
; High byte of tilemap address for different ???
.db $77 $77 $77 $77 $78 $78 $78 $78
.db $79 $79 $79 $79 $7A $7A $7A $7A
.db $7B $7B $7B $7B $7C $7C $7C $7C
.db $7D $7D $7D $7D $7E $7E $7E $7E
.db $77 $77 $77 $77 $78 $78 $78 $78
.db $79 $79 $79 $79 $7A $7A $7A $7A
.db $7B $7B $7B $7B $7C $7C $7C $7C
.db $7D $7D $7D $7D $7E $7E $7E $7E

; Data from A6D to A75 (9 bytes)
_DATA_A6D_SMS:
.db $14 $10 $10 $10 $10 $18 $18 $18 $18

; Data from A76 to A7E (9 bytes)
_DATA_A76_SMS:
.db $08 $10 $18 $20 $28 $10 $18 $20 $28

; Data from A7F to A87 (9 bytes)
_DATA_A7F_GG:
.db $3C $38 $38 $38 $38 $40 $40 $40 $40

; Data from A88 to A90 (9 bytes)
_DATA_A88_GG:
.db $30 $38 $40 $48 $50 $38 $40 $48 $50

; Data from A91 to A9C (12 bytes)
_DATA_A91_RuffTruxTimeLimits:
.db $04 $05 $00 $00 ; 45.00s
.db $04 $08 $00 $00 ; 48.00s
.db $05 $05 $00 $00 ; 55.00s

_LABEL_A9D_:
  JrToPagedFunction _LABEL_36D07_

_LABEL_AA7_:
  JrToPagedFunction _LABEL_36CA5_

_LABEL_AB1_:
  JrToPagedFunction _LABEL_366DE_

_LABEL_ABB_:
  JrToPagedFunction _LABEL_360B9_

_LABEL_AC5_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr nz, + ; ret
  JrToPagedFunction _LABEL_3616B_
+:ret

_LABEL_AD7_DelayIfPlayer2:
  JrToPagedFunction _LABEL_1BCCB_DelayIfPlayer2

_LABEL_AE1_:
  JrToPagedFunction _LABEL_1F8D8_

_LABEL_AEB_:
  JrToPagedFunction _LABEL_1BAB3_

_LABEL_AF5_:
  ld a, :_LABEL_1BAFD_ ; $06
  ld (PAGING_REGISTER), a
  call _LABEL_1BAFD_
_LABEL_AFD_RestorePaging_fromDE8E:
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ret

_LABEL_B04_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  ret z
  JrToPagedFunction _LABEL_363D0_

_LABEL_B13_:
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_)
  cp $01
  jr z, +
  jp +++

+:
  ld a, $12
  ld (_RAM_D963_SFXTrigger2), a
  jp ++

_LABEL_B2B_:
  ld a, (_RAM_D947_)
  or a
  jr nz, +
  ld a, (_RAM_DB7B_)
  cp $07
  jr nz, +++
+:
  ld a, $12
  ld (_RAM_D974_SFXTrigger), a
++:
  ld hl, _DATA_BB9_
  jp ++++

+++:
  ld hl, _DATA_BAD_
++++:
  ld ix, _RAM_DAE0_SpriteTableYs.20
  ld de, _RAM_DA60_SpriteTableXNs.20
  ld c, $0C
-:
  ld a, (hl)
  ld (de), a
  ld a, $50
  ld (ix+0), a
  inc ix
  inc hl
  inc de
  dec c
  jr nz, -
  ld a, $02
  ld (_RAM_D581_), a
  ret

_LABEL_B63_:
  ld a, (_RAM_D581_)
  cp $A0
  jr nc, _LABEL_BAC_ret
  ld a, (_RAM_DB7B_)
  cp $01
  jr z, +
  cp $07
  jr nz, ++
+:
  ld ix, _DATA_BB9_
  jp +++

++:
  ld ix, _DATA_BAD_
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

; Data from BAD to BC4 (24 bytes)
_DATA_BAD_:
.db $70 $9C $78 $9D $80 $9E $88 $9F $90 $A4 $98 $A5
_DATA_BB9_:
.db $70 $96 $78 $97 $80 $98 $88 $99 $90 $9A $98 $9B

;.section "Floor tiles updates" force
  ; Executed in RAM at da92 - or is it?
_LABEL_BC5_UpdateFloorTiles:
  ld a, (_RAM_DF17_HaveFloorTiles)
  or a
  jr z, + ; ret
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

_LABEL_BF0_UpdateFloorTiles:
  ld a, (_RAM_DB97_TrackType)
  or a
  jr z, + ; TT_SportsCars
  cp TT_FourByFour
  jr z, +
  cp TT_FormulaOne
  jr z, +
  ret

+:
  call _LABEL_C81_UpdateFloorTiles_H
  ; Then do vertically
  ld a, (_RAM_DEF8_)
  xor $01
  ld (_RAM_DEF8_), a
  ld a, (_RAM_DEF6_)
  ld b, a
  and $80
  ld l, a
  ld a, b
  and $7F
  or a
  jr z, _LABEL_C2F_ret
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
  jr z, _LABEL_C75_
_LABEL_C2F_ret:
  ret

+:
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_C2F_ret
++:
  jp _LABEL_CF8_MoveFloorTilesVertically

+++:
  call _LABEL_CF8_MoveFloorTilesVertically
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_C2F_ret
  jp _LABEL_CF8_MoveFloorTilesVertically

++++:
  call _LABEL_CF8_MoveFloorTilesVertically
  jp _LABEL_CF8_MoveFloorTilesVertically

+++++:
  call _LABEL_CF8_MoveFloorTilesVertically
  call _LABEL_CF8_MoveFloorTilesVertically
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_C2F_ret
  jp _LABEL_CF8_MoveFloorTilesVertically

++++++:
  call _LABEL_CF8_MoveFloorTilesVertically
  call _LABEL_CF8_MoveFloorTilesVertically
  jp _LABEL_CF8_MoveFloorTilesVertically

+++++++:
  call _LABEL_CF8_MoveFloorTilesVertically
  call _LABEL_CF8_MoveFloorTilesVertically
  call _LABEL_CF8_MoveFloorTilesVertically
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_C2F_ret
  jp _LABEL_CF8_MoveFloorTilesVertically

_LABEL_C75_:
  call _LABEL_CF8_MoveFloorTilesVertically
  call _LABEL_CF8_MoveFloorTilesVertically
  call _LABEL_CF8_MoveFloorTilesVertically
  jp _LABEL_CF8_MoveFloorTilesVertically

_LABEL_C81_UpdateFloorTiles_H:
  ld a, (_RAM_DEF7_)
  ld b, a
  and $80
  ld l, a ; High bit -> l
  ld a, b
  and $7F
  or a
  jr z, _LABEL_CA6_ret ; Nothing to do
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
  jr z, _LABEL_CEC_
_LABEL_CA6_ret:
  ret

+:; Shift if flag is set
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_CA6_ret
++:
  jp _LABEL_DCF_MoveFloorTilesHorizontally

+++:
  call _LABEL_DCF_MoveFloorTilesHorizontally
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_CA6_ret
  jp _LABEL_DCF_MoveFloorTilesHorizontally

++++:
  call _LABEL_DCF_MoveFloorTilesHorizontally
  jp _LABEL_DCF_MoveFloorTilesHorizontally

+++++:
  call _LABEL_DCF_MoveFloorTilesHorizontally
  call _LABEL_DCF_MoveFloorTilesHorizontally
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_CA6_ret
  jp _LABEL_DCF_MoveFloorTilesHorizontally

++++++:
  call _LABEL_DCF_MoveFloorTilesHorizontally
  call _LABEL_DCF_MoveFloorTilesHorizontally
  jp _LABEL_DCF_MoveFloorTilesHorizontally

+++++++:
  call _LABEL_DCF_MoveFloorTilesHorizontally
  call _LABEL_DCF_MoveFloorTilesHorizontally
  call _LABEL_DCF_MoveFloorTilesHorizontally
  ld a, (_RAM_DEF8_)
  or a
  jr z, _LABEL_CA6_ret
  jp _LABEL_DCF_MoveFloorTilesHorizontally

_LABEL_CEC_:
  call _LABEL_DCF_MoveFloorTilesHorizontally
  call _LABEL_DCF_MoveFloorTilesHorizontally
  call _LABEL_DCF_MoveFloorTilesHorizontally
  jp _LABEL_DCF_MoveFloorTilesHorizontally

_LABEL_CF8_MoveFloorTilesVertically:
  push hl
    ld a, l
    cp $80
    jp z, _LABEL_D67_MoveFloorTilesUp
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

_LABEL_D67_MoveFloorTilesUp:
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

_LABEL_DCF_MoveFloorTilesHorizontally:
  push hl
    ld a, l
    cp $80
    jp z, _LABEL_E3C_MoveFloorTilesRight
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

_LABEL_E3C_MoveFloorTilesRight:
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
;.ends

; Data from EA2 to EE5 (68 bytes)
_DATA_EA2_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $01 $01 $00 $00 $01 $01 $02 $02 $01 $01 $02 $02 $03 $03 $02 $02
.db $03 $03 $04 $04 $03 $03 $04 $04 $05 $05 $04 $04 $05 $05 $06 $06
.db $05 $05 $06 $06

_LABEL_EE6_:
  JumpToPagedFunction _LABEL_363D9_

_LABEL_EF1_:
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
  jr z, _LABEL_F6F_
+:
  ld a, (_RAM_DEA3_)
  or a
  jr z, ++
  cp $01
  jr z, +
  call _LABEL_6593_
+:
  ld a, (_RAM_DE99_)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_L_MASK ; $04
  jr z, _LABEL_F75_
  jp ++

+:
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_R_MASK ; $08
  jr z, _LABEL_F75_
++:
  ld a, (_RAM_DEA3_)
  or a
  jr z, _LABEL_F75_
  ld a, (_RAM_DB20_Player1Controls)
  ld l, a
  and BUTTON_L_MASK ; $04
  jr z, +
  ld a, l
  and BUTTON_R_MASK ; $08
  jr nz, _LABEL_F6F_
+:
  ld a, $01
  ld (_RAM_DEA7_), a
  ld hl, _RAM_DEA5_
  inc (hl)
  ld a, (hl)
  cp $44
  jr nz, _LABEL_F58_
  ld a, $43
  ld (_RAM_DEA5_), a
_LABEL_F58_:
  ld hl, _DATA_EA2_
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
_LABEL_F6F_:
  ret

+:
  xor a
  ld (_RAM_DE96_), a
  ret

_LABEL_F75_:
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
  jp _LABEL_F58_

+:
  xor a
  ld (_RAM_DEA5_), a
  ld (_RAM_DEA7_), a
  ld a, (_RAM_DE92_EngineVelocity)
  ld (_RAM_DE96_), a
  ret

_LABEL_F9B_:
  xor a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jp nz, _LABEL_109B_
  ld a, (_RAM_DE4F_)
  cp $80
  jp nz, _LABEL_109B_
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  jr nz, _LABEL_1024_
  ld a, (_RAM_DF58_)
  or a
  jp nz, _LABEL_109B_
  ld a, (_RAM_DF6A_)
  or a
  jr nz, _LABEL_1011_
  ld a, (_RAM_DB20_Player1Controls)
  ld b, a
  and BUTTON_2_MASK ; $20
  jr nz, _LABEL_1011_
  ld a, b
  and BUTTON_1_MASK ; $10
  jr z, _LABEL_1011_
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr nz, +
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr nz, _LABEL_102B_
+:
  ld a, $02
  ld (_RAM_DE96_), a
  ld (_RAM_DE92_EngineVelocity), a
  ld a, $01
  ld (_RAM_D5A4_IsReversing), a
  ld a, (_RAM_DE90_CarDirection)
  ld d, $00
  ld e, a
  ld hl, _DATA_250E_
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
  jp _LABEL_1121_

_LABEL_1011_:
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
_LABEL_1024_:
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jp z, _LABEL_109B_
_LABEL_102B_:
  ld hl, _RAM_DEB4_
  inc (hl)
  ld a, (hl)
  cp $07
  jr c, _LABEL_1081_
  ld a, $00
  ld (_RAM_DEB4_), a
  ld a, (_RAM_DF00_)
  or a
  jr nz, _LABEL_1081_
  ld hl, _RAM_DE92_EngineVelocity
  dec (hl)
  jp _LABEL_1081_

+:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr nz, +
  ld a, (_RAM_D59D_)
  or a
  jr z, +
  jp _LABEL_10C2_

+:
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK ; $10
  jr z, _LABEL_10C2_
  ld a, (_RAM_DE92_EngineVelocity)
  cp $00
  jp z, _LABEL_109B_
  ld a, (_RAM_DB9A_DecelerationDelay)
  ld b, a
  ld hl, _RAM_DEB4_
  inc (hl)
  ld a, (hl)
  cp b
  jp c, _LABEL_1081_
  ld a, $00
  ld (_RAM_DEB4_), a
  ld a, (_RAM_DF00_)
  or a
  jp nz, _LABEL_1081_
  ld hl, _RAM_DE92_EngineVelocity
  dec (hl)
_LABEL_1081_:
  ld hl, _RAM_DEAD_
  inc (hl)
  ld a, (hl)
  cp $06
  jp nz, _LABEL_111E_
  ld a, $00
  ld (_RAM_DEAD_), a
  ld a, (_RAM_DB7D_)
  xor $01
  ld (_RAM_DB7D_), a
  jp _LABEL_111E_

_LABEL_109B_:
  ld a, (_RAM_DB9A_DecelerationDelay)
  sub $01
  ld (_RAM_DEB4_), a
  ld a, (_RAM_DB99_AccelerationDelay)
  sub $01
  ld (_RAM_DEB3_), a
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
  ret

_LABEL_10C2_:
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
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
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
  ld hl, _RAM_DEB3_
  inc (hl)
  ld a, (hl)
  cp b
  jr c, _LABEL_111E_
  ld a, $00
  ld (_RAM_DEB3_), a
  ld a, (_RAM_D5CF_)
  ld l, a
  ld a, (_RAM_DB98_TopSpeed)
  sub l
  ld h, a
  ld a, (_RAM_DE92_EngineVelocity)
  ld l, a
  ld a, h
  cp l
  jr nz, +
  jp _LABEL_111E_

+:
  ld a, (_RAM_DF00_)
  or a
  jr nz, _LABEL_111E_
  ld hl, _RAM_DE92_EngineVelocity
  inc (hl)
_LABEL_111E_:
  call _LABEL_EF1_
_LABEL_1121_:
  ld hl, _DATA_1D65_
  ld a, (_RAM_DE96_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_DE96_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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

_LABEL_11BA_:
  ld a, (_RAM_D5B6_)
  or a
  jr z, +
  dec a
  ld (_RAM_D5B6_), a
+:
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  jr nz, +
  ld a, (_RAM_DC4D_Cheat_NoSkidding)
  or a
  jr nz, ++
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr z, _LABEL_11E4_
  ld a, (_RAM_DE99_)
  or a
  jr z, +
  cp $01
  jr z, +++
  jp _LABEL_1242_

+:
  ret

_LABEL_11E4_:
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
  jr z, _LABEL_11E4_
  ret

+++:
  ld a, (_RAM_DF00_)
  or a
  jr nz, +
  ld a, (_RAM_D5B6_)
  or a
  jr nz, _LABEL_121A_
  ld a, (_RAM_DEA0_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA0_), a
+:
  ret

_LABEL_121A_:
  ret

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
  call _LABEL_1282_
++:
  ld (_RAM_DEA0_), a
  ld hl, _RAM_DE90_CarDirection ; Rotate left
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DE90_CarDirection), a
  jp _LABEL_1295_

_LABEL_1242_:
  ld a, (_RAM_DF00_)
  or a
  jr nz, +
  ld a, (_RAM_D5B6_)
  or a
  jr nz, _LABEL_121A_
  ld a, (_RAM_DEA0_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA0_), a
+:
  ret

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
  call _LABEL_1282_
++:
  ld (_RAM_DEA0_), a
  ld hl, _RAM_DE90_CarDirection ; Rotate right
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DE90_CarDirection), a
  jp _LABEL_1295_

_LABEL_1282_:
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

_LABEL_1295_:
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
  jp ++ ; ret

; Unreachable code
  ret

+:xor a
  ld (_RAM_DEAB_), a
++:
  ret

_LABEL_12BF_:
  JumpToPagedFunction _LABEL_35F8A_

_LABEL_12CA_:
  JumpToPagedFunction _LABEL_36209_

_LABEL_12D5_:
  JumpToPagedFunction _LABEL_1FA3D_

_LABEL_12E0_:
  ; Look up tile index data pointer into de
  ld hl, _DATA_4000_TileIndexPointerLow
  ld a, (_RAM_DEBC_TileDataIndex)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_4041_TileIndexPointerHigh
  ld a, (_RAM_DEBC_TileDataIndex)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)

  ld a, (_RAM_DEC5_)
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
  ; Loop over l rows
  dec l
  ld a, l
  cp $00
  jr z, + ; ret
  ; Add a row to the VRAM address
  ld a, (_RAM_DEC1_VRAMAddress.Lo)
  add a, $40
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, (_RAM_DEC1_VRAMAddress.Hi)
  adc a, $00
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    ; Add _RAM_DECE_ to de
    ld hl, _RAM_DECE_
    ld a, e
    add a, (hl)
    ld e, a
    ld a, d
    adc a, $00
    ld d, a
  pop hl
  jp --

+:ret

_LABEL_1345_:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jp nz, _LABEL_14A8_
  ; SMS
  ld a, $07
  ld (_RAM_DEE1_), a
  xor a
  ld (_RAM_DEDF_), a
  ld a, (_RAM_DBA0_)
  ld (_RAM_DED5_), a
  add a, $02
  ld (_RAM_DED7_), a
  ld a, (_RAM_DBA2_)
  ld (_RAM_DEEB_), a
  ld a, $04
  ld (_RAM_DEE3_), a
  xor a
  ld (_RAM_DEE5_), a
  ld a, (_RAM_DBA2_)
  ld (_RAM_DEDB_), a
  add a, $02
  ld (_RAM_DED9_), a
  xor a
  ld (_RAM_DED1_), a
  ld (_RAM_DED2_), a
  ld a, (_RAM_DBA2_)
  or a
  jr z, +
  ld bc, (_RAM_DBA2_)
  ld de, (_RAM_DB9C_)
-:
  ld hl, (_RAM_DED1_)
  add hl, de
  ld (_RAM_DED1_), hl
  dec bc
  ld a, b
  or c
  jr z, +
  jp -

+:
  ld hl, (_RAM_DED1_)
  ld de, (_RAM_DBA0_)
  add hl, de
  ld de, (_DATA_9EB_ValueC000)
  add hl, de
  ld (_RAM_DED1_), hl
  call _LABEL_1583_
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ; Tile $1b8
  ld a, $00
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $77
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ; Tile $1b8, last bitplane
  ld a, $18
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $77
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  call _LABEL_64E5_
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $30
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $77
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  ld de, (_RAM_DB9C_)
  ld hl, (_RAM_DED1_)
  add hl, de
  call _LABEL_1583_
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $00
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7A
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $18
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7A
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
  call _LABEL_12E0_
  pop hl
  call _LABEL_64E5_
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $30
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7A
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  ld de, (_RAM_DB9C_)
  ld hl, (_RAM_DED1_)
  add hl, de
  add hl, de
  call _LABEL_1583_
  ld a, $04
  ld (_RAM_DEC5_), a
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $00
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7D
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $18
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7D
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  call _LABEL_64E5_
  ld a, $04
  ld (_RAM_DEC5_), a
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $30
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7D
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  ret

_LABEL_14A8_:
  ; GG version of the above
  ld a, $08
  ld (_RAM_DEE1_), a
  xor a
  ld (_RAM_DEDF_), a
  ld a, (_RAM_DBA0_)
  ld (_RAM_DED5_), a
  add a, $01
  ld (_RAM_DED7_), a
  ld a, (_RAM_DBA2_)
  ld (_RAM_DEEB_), a
  ld a, $06
  ld (_RAM_DEE3_), a
  xor a
  ld (_RAM_DEE5_), a
  ld a, (_RAM_DBA2_)
  ld (_RAM_DEDB_), a
  add a, $01
  ld (_RAM_DED9_), a
  xor a
  ld (_RAM_DED1_), a
  ld (_RAM_DED2_), a
  ld a, (_RAM_DBA2_)
  or a
  jr z, +
  ld bc, (_RAM_DBA2_)
  ld de, (_RAM_DB9C_)
-:ld hl, (_RAM_DED1_)
  add hl, de
  ld (_RAM_DED1_), hl
  dec bc
  ld a, b
  or c
  jr z, +
  jp -

+:ld hl, (_RAM_DED1_)
  ld de, (_RAM_DBA0_)
  add hl, de
  ld de, (_DATA_9EB_ValueC000)
  add hl, de
  ld (_RAM_DED1_), hl
  call _LABEL_1583_
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $4A
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $78
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  call _LABEL_64E5_
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $62
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $78
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  ld de, (_RAM_DB9C_)
  ld hl, (_RAM_DED1_)
  add hl, de
  call _LABEL_1583_
  ld a, $06
  ld (_RAM_DEC5_), a
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $4A
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7B
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  call _LABEL_64E5_
  ld a, $06
  ld (_RAM_DEC5_), a
  inc hl
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld a, $62
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, $7B
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  push hl
    call _LABEL_12E0_
  pop hl
  ret

_LABEL_1583_:
  ld a, $0C
  ld (_RAM_DECF_RectangleWidth), a
  ld a, $00
  ld (_RAM_DECE_), a
  ld a, $0C
  ld (_RAM_DEC5_), a
  ret

_LABEL_1593_:
  xor a
  ld (_RAM_DEF6_), a
  ld a, (_RAM_DEB2_)
  or a
  jp z, _LABEL_162D_
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
  jr nz, - ; ret
  call _LABEL_3E24_
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
  ld hl, _RAM_DBA2_
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
  call _LABEL_77CD_
  call _LABEL_1801_
  ret

_LABEL_162D_:
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
  jr nz, - ; ret
  call _LABEL_7C72_
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
  ld hl, _RAM_DBA2_
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
  call _LABEL_780D_
  call _LABEL_17E6_
  ret

_LABEL_16C0_:
  xor a
  ld (_RAM_DEF7_), a
  ld a, (_RAM_DEB0_)
  or a
  jr z, +
  jp _LABEL_174E_

+:
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
  or a
  jr nz, -
  call _LABEL_7C67_
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
  ld hl, _RAM_DBA0_
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
  call _LABEL_17D0_
  call _LABEL_18E6_
  ret

_LABEL_174E_:
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
  call _LABEL_3E2F_
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
  ld hl, _RAM_DBA0_
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
  call _LABEL_17D0_
  call _LABEL_18FD_
  ret

_LABEL_17D0_:
  call _LABEL_784D_
  ld a, (_RAM_DEBF_)
  ld e, a
  ld d, $00
  ld hl, (_RAM_DEBD_)
  add hl, de
  ld a, l
  ld (_RAM_DEC1_VRAMAddress.Lo), a
  ld a, h
  ld (_RAM_DEC1_VRAMAddress.Hi), a
  ret

_LABEL_17E6_:
  ld a, (_RAM_DEE5_)
  ld (_RAM_DEE9_), a
  ld a, (_RAM_DEDF_)
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DEDB_)
  ld (_RAM_DEEB_), a
  ld a, (_RAM_DEDC_)
  ld (_RAM_DEEC_), a
  jp +

_LABEL_1801_:
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
  ld a, (_RAM_DBA0_)
  and $1F
  ld (_RAM_DEDD_), a
  call _LABEL_188E_
  xor a
  ld (_RAM_DEC7_), a
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED1_)
  ld c, a
  and $E0
  ld b, a
  ld a, c
  add a, $01
  and $1F
  or b
  ld (_RAM_DED1_), a
  call _LABEL_795E_
  ld a, (_RAM_DECD_)
  cp $01
  jr z, +
  xor a
  ld (_RAM_DEC7_), a
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED1_)
  ld c, a
  and $E0
  ld b, a
  ld a, c
  add a, $01
  and $1F
  or b
  ld (_RAM_DED1_), a
  call _LABEL_795E_
  ld a, (_RAM_DECD_)
  cp $01
  jr z, +
  xor a
  ld (_RAM_DEC7_), a
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED1_)
  ld c, a
  and $E0
  ld b, a
  ld a, c
  add a, $01
  and $1F
  or b
  ld (_RAM_DED1_), a
  call _LABEL_795E_
+:
  ret

_LABEL_188E_:
  ld a, $22
  ld (_RAM_DB62_), a
  ld a, $DB
  ld (_RAM_DB63_), a
  xor a
  ld (_RAM_DED1_), a
  ld (_RAM_DED2_), a
  ld a, (_RAM_DEEB_)
  and $1F
  or a
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_)
  ld (_RAM_DEF4_), a
  call _LABEL_30EA_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DED1_), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DED2_), a
+:
  ld hl, (_RAM_DED1_)
  ld de, (_RAM_DEDD_)
  add hl, de
  ld de, (_DATA_9EB_ValueC000)
  add hl, de
  ld (_RAM_DED1_), hl
  jp _LABEL_795E_

_LABEL_18D2_:
  ld bc, _DATA_19E2_
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

_LABEL_18E6_:
  ld a, (_RAM_DEDF_)
  ld (_RAM_DEE7_), a
  ld a, (_RAM_DED5_)
  and $1F
  ld (_RAM_DEDD_), a
  ld a, (_RAM_DED6_)
  ld (_RAM_DEDE_), a
  jp +

_LABEL_18FD_:
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
  ld a, (_RAM_DBA2_)
  ld (_RAM_DEEB_), a
  call _LABEL_198A_
  xor a
  ld (_RAM_DEC6_), a
  ld a, (_RAM_DB9C_)
  ld l, a
  ld a, (_RAM_DED1_)
  add a, l
  ld (_RAM_DED1_), a
  ld a, (_RAM_DED2_)
  adc a, $00
  and $C3
  ld (_RAM_DED2_), a
  call _LABEL_4F1B_
  ld a, (_RAM_DEC9_)
  cp $01
  jr z, _LABEL_1989_
  xor a
  ld (_RAM_DEC6_), a
  ld a, (_RAM_DB9C_)
  ld l, a
  ld a, (_RAM_DED1_)
  add a, l
  ld (_RAM_DED1_), a
  ld a, (_RAM_DED2_)
  adc a, $00
  and $C3
  ld (_RAM_DED2_), a
  call _LABEL_4F1B_
  ld a, (_RAM_DEC9_)
  cp $01
  jr z, _LABEL_1989_
  xor a
  ld (_RAM_DEC6_), a
  ld a, (_RAM_DB9C_)
  ld l, a
  ld a, (_RAM_DED1_)
  add a, l
  ld (_RAM_DED1_), a
  ld a, (_RAM_DED2_)
  adc a, $00
  and $C3
  ld (_RAM_DED2_), a
  call _LABEL_4F1B_
_LABEL_1989_:
  ret

_LABEL_198A_:
  ld a, $42
  ld (_RAM_DB64_), a
  ld a, $DB
  ld (_RAM_DB65_), a
  xor a
  ld (_RAM_DED1_), a
  ld (_RAM_DED2_), a
  ld a, (_RAM_DEEB_)
  and $1F
  or a
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_)
  ld (_RAM_DEF4_), a
  call _LABEL_30EA_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DED1_), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DED2_), a
+:
  ld hl, (_RAM_DED1_)
  ld de, (_RAM_DEDD_)
  add hl, de
  ld de, (_DATA_9EB_ValueC000)
  add hl, de
  ld (_RAM_DED1_), hl
  jp _LABEL_4F1B_

_LABEL_19CE_:
  ld bc, _DATA_19E2_
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

; Data from 19E2 to 19ED (12 bytes)
_DATA_19E2_:
.db $00 $0C $18 $24 $30 $3C $48 $54 $60 $6C $78 $84

_LABEL_19EE_:
  ; Copy 32 bytes from _DATA_4105_+_RAM_DB97_TrackType*32 to _RAM_DA00_ ; TODO what is it?
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
  ld hl, _DATA_4105_
  add hl, de
  ld bc, $0020
  ld de, _RAM_DA00_
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  dec bc
  ld a, b
  or c
  jr nz, -

  ; Copy 64 bytes from _DATA_4225_TrackMetatileLookup+_RAM_DB97_TrackType*64 to _RAM_DA20_TrackMetatileLookup
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
  ld hl, _DATA_4225_TrackMetatileLookup
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

  ; Look up _DATA_3EA4_+_RAM_DB97_TrackType*8
  ld d, $00
  ld a, (_RAM_DB97_TrackType)
  or a
  rl a
  rl a
  rl a
  ld e, a
  ld hl, _DATA_3EA4_
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
  ld (_RAM_DBA0_), a
  inc hl
  ld a, (hl)
  ld (_RAM_DBA2_), a
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DBAB_), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DBAC_), a
  ld a, (_RAM_DBA0_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld a, (_RAM_DEF1_)
  ld (_RAM_DBA9_), a
  ld a, (_RAM_DEF2_)
  ld (_RAM_DBAA_), a
  call _LABEL_48C2_
  JumpToPagedFunction _LABEL_237E2_

_LABEL_1AC8_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_DF0C_), a
  xor a
  ld (_RAM_DF0E_), a
+:
  ret

_LABEL_1AD8_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_DF0C_), a
  ld (_RAM_DF0E_), a
+:
  ret

_LABEL_1AE7_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_DF0B_), a
  xor a
  ld (_RAM_DF0D_), a
  jp _LABEL_2673_

+:
  ret

_LABEL_1AFA_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_DF0B_), a
  ld (_RAM_DF0D_), a
  jp _LABEL_2673_

+:
  ret

_LABEL_1B0C_:
  ld a, (ix+22)
  cp $01
  jr z, +
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
+:
  ret

_LABEL_1B2F_:
  ld a, (ix+22)
  cp $01
  jr z, +
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
+:
  ret

_LABEL_1B50_:
  ld a, (ix+23)
  cp $01
  jr z, +
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
+:
  ret

_LABEL_1B73_:
  ld a, (ix+23)
  cp $01
  jr z, +
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
+:
  ret

_LABEL_1B94_:
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

; Data from 1C22 to 1C39 (24 bytes)
_DATA_1C22_TileData_ShadowTopLeft: ; 3bpp -> 24bytes
.db $03 $03 $00 $0F $0F $00 $1F $1F
.db $00 $3F $3F $00 $3F $3F $00 $7F
.db $7F $00 $7F $7F $00 $7F $7F $00

; Data from 1C3A to 1C51 (24 bytes)
_DATA_1C3A_TileData_ShadowTopRight:
.db $C0 $C0 $00 $F0 $F0 $00 $F8 $F8
.db $00 $FC $FC $00 $FC $FC $00 $FE
.db $FE $00 $FE $FE $00 $FE $FE $00

; Data from 1C52 to 1C69 (24 bytes)
_DATA_1C52_TileData_ShadowBottomLeft:
.db $7F $7F $00 $7F $7F $00 $7F $7F
.db $00 $3F $3F $00 $3F $3F $00 $1F
.db $1F $00 $0F $0F $00 $03 $03 $00

; Data from 1C6A to 1C81 (24 bytes)
_DATA_1C6A_TileData_ShadowBottomRight:
.db $FE $FE $00 $FE $FE $00 $FE $FE
.db $00 $FC $FC $00 $FC $FC $00 $F8
.db $F8 $00 $F0 $F0 $00 $C0 $C0 $00

_DATA_1c82_TileVRAMAddresses: ; VRAM addresses
.dw $4D00 $4D60 $4F00 $4F60 ; Tiles $68, $6b, $78, $7b
.dw $5160 $5300 $5360 $5D00 ; $8b, $98, $9b, $e8
.dw $5D60 $5F00 $5F60 ; $eb, $f8, $fb

_LABEL_1C98_:
  ld de, (_RAM_DBA0_)
  ld hl, (_RAM_DE79_)
  add hl, de
  ld (_RAM_DBB1_), hl
  ld de, (_RAM_DBA2_)
  ld hl, (_RAM_DE7B_)
  add hl, de
  ld (_RAM_DBB3_), hl
  ld a, (_RAM_DE7D_)
  and $3F
  ld (_RAM_DBB5_), a
  ld a, (_RAM_DF4F_)
  ld (_RAM_D5DE_), a
  ret

_LABEL_1CBD_:
  xor a
  ld (_RAM_DEF1_), a
  ld (_RAM_DEF2_), a
  ld a, (_RAM_DBA2_)
  ld l, a
  ld a, (_RAM_DE7B_)
  add a, l
  and $1F
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_)
  ld (_RAM_DEF4_), a
  call _LABEL_30EA_
+:
  ld a, (_RAM_DEF1_)
  ld l, a
  ld a, (_RAM_DEF2_)
  ld h, a
  ld de, (_RAM_DE79_)
  add hl, de
  ld de, (_RAM_DBA0_)
  add hl, de
  ld de, $C000
  add hl, de
  ld a, (hl)
  ret

_LABEL_1CF4_:
  JumpToPagedFunction _LABEL_1FB35_

_LABEL_1CFF_:
  ld a, $01
  ld (_RAM_DF65_), a
  ld (_RAM_DCC5_), a
  ld (_RAM_DD06_), a
  ld (_RAM_DD47_), a
  ld a, (_RAM_DF28_)
  ld (_RAM_DF2C_), a
  ld a, (_RAM_DF29_)
  ld (_RAM_DF2D_), a
  ld a, (_RAM_DF6A_)
  or a
  jr nz, +
  ld a, $F0
  ld (_RAM_DF6A_), a
+:
  ret

; Data from 1D25 to 1D44 (32 bytes)
_DATA_1D25_HelicoptersAnimatedPalette_GG:
.rept 2
  GGCOLOUR $0000ee
  GGCOLOUR $4444ee
  GGCOLOUR $8888ee
  GGCOLOUR $eeeeee
.endr
_DATA_1D35_PowerboatsAnimatedPalette_GG:
  GGCOLOUR $440088
  GGCOLOUR $444488
  GGCOLOUR $8888ee
  GGCOLOUR $ccccee
  GGCOLOUR $8888ee
  GGCOLOUR $444488
  GGCOLOUR $440088
  GGCOLOUR $0000844

_LABEL_1D45_:
  ld a, $03
  ld (_RAM_DF2A_), a
  ld (_RAM_DF2B_), a
  ld (_RAM_DF2C_), a
  ld (_RAM_DF2D_), a
  call _LABEL_4F8F_
  call _LABEL_4FDE_
  call _LABEL_502D_
  call _LABEL_507C_
  call _LABEL_50CB_
  jp _LABEL_511A_

; Data from 1D65 to 1D75 (17 bytes)
_DATA_1D65_:
.db $AC $CA $E8 $06 $24 $42 $60 $7E $9C $BA $D8 $F6 $14 $32 $50 $6E
.db $8C

; Data from 1D76 to 1D86 (17 bytes)
_DATA_1D76_:
.db $4B $4B $4B $4C $4C $4C $4C $4C $4C $4C $4C $4C $4D $4D $4D $4D
.db $4D

; Data from 1D87 to 1D96 (16 bytes)
_DATA_1D87_:
.db $04 $06 $08 $0A $0C $0E $00 $02 $05 $07 $09 $0B $0D $0F $01 $03

; Data from 1D97 to 1DA6 (16 bytes)
_DATA_1D97_:
.db $08 $09 $0A $0B $0C $0D $0E $0F $00 $01 $02 $03 $04 $05 $06 $07

; Data from 1DA7 to 1DE6 (64 bytes)
_DATA_1DA7_:
.db $0C $0A $08 $06 $04 $02 $00 $0E $0B $09 $07 $05 $03 $01 $0F $0D
.db $04 $02 $00 $0E $0C $0A $08 $06 $03 $01 $0F $0D $0B $09 $07 $05
.db $00 $0E $0C $0A $08 $06 $04 $02 $0F $0D $0B $09 $07 $05 $03 $01
.db $08 $06 $04 $02 $00 $0E $0C $0A $07 $05 $03 $01 $0F $0D $0B $09

_LABEL_AFD_ReadControls:
  JumpToPagedFunction _LABEL_3773B_ReadControls

_LABEL_1DF2_:
  ld b, $00
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
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
  ld hl, _DATA_251E_
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
  ld hl, _DATA_251E_
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
  ld a, (_RAM_DBA0_)
  add a, l
  and $1F
  ld c, a
  ld b, $00
  xor a
  ld (_RAM_DEF1_), a
  ld (_RAM_DEF2_), a
  ld a, (_RAM_DBA2_)
  ld l, a
  ld a, (_RAM_DE7B_)
  add a, l
  and $1F
  jr z, +
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DB9C_)
  ld (_RAM_DEF4_), a
  call _LABEL_30EA_
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
  ld hl, _DATA_254E_TimesTable18Lo
  ld a, (_RAM_DE7D_)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  ld hl, _DATA_258F_TimesTable18Hi
  add hl, de
  ld a, (hl)
  ld d, a
  ld e, c
  ld hl, _RAM_C800_WallData
  add hl, de
  ld b, h
  ld c, l
  ld hl, _DATA_2652_TimesTable12Lo
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
  ld de, _DATA_16A38_DivideBy8
  add hl, de
  ld a, :_DATA_16A38_DivideBy8
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
  ld de, _DATA_169A8_IndexToBitmask
  add hl, de
  ld a, :_DATA_169A8_IndexToBitmask
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, +
  ld a, (_RAM_DE7D_)
  and $3F
  jr z, ++
  cp $1A
  jr z, ++
+:
  ld a, (_RAM_DE6F_)
  and b
  jp z, _LABEL_1FDC_
  ld a, (_RAM_DB97_TrackType)
  cp TT_FourByFour
  jr nz, ++
  ld a, :_DATA_37232_
  ld (PAGING_REGISTER), a
  ld hl, _DATA_37232_
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
  jr nz, _LABEL_1FDC_
++:
  ld a, (_RAM_DF58_)
  or a
  jr nz, _LABEL_1FDC_
  ld a, (_RAM_DE8C_)
  or a
  jr nz, _LABEL_1FDC_
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jr nz, +
  ld a, (_RAM_DE7D_)
  cp $15
  jr z, +
  cp $0D
  jr c, +
  cp $18
  jr c, _LABEL_1FDC_
+:
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr nz, +
  ld a, $03
  ld (_RAM_D963_SFXTrigger2), a
+:
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  call _LABEL_28AC_
  xor a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DF7B_), a
  ld a, (_RAM_DBA4_)
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DBA7_), a
_LABEL_1FBF_:
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

_LABEL_1FDC_:
  ld a, (_RAM_DBA4_)
  ld (_RAM_DE5C_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DE5D_), a
  ld a, (_RAM_DBA6_)
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DBA7_)
  ld (_RAM_DBA5_), a
+:
  ld hl, _DATA_25D0_
  ld a, (_RAM_DE7D_)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  ld hl, _DATA_2611_
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
  ld a, :_DATA_1B1A2_
  ld (PAGING_REGISTER), a
  ld de, _DATA_1B1A2_
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
  jp nz, _LABEL_23DD_
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
  ld hl, _DATA_242E_BehaviourLookup
  add hl, de

  ; mask out lsb if it is a boats track
  ld a, $0F ; c = $f
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
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
  jr nz, _LABEL_20E3_BehaviourEnd

  xor a
  ld (_RAM_D5CD_CarIsSkidding), a

  ; Look up behaviours
  ld a, (_RAM_DEF9_CurrentBehaviour)
  or a
  jp z, _LABEL_2121_Behaviour0 ; normal track
  cp $06
  jp z, _LABEL_2175_Behaviour6 ; bump
  cp $04
  jp z, _LABEL_21F3_Behavour4 ; big jump
  cp $03
  jp z, _LABEL_21E1_Behaviour3 ; ??
  cp $0A
  jp z, _LABEL_2156_BehaviourA ; death?
  cp $0B
  jp z, _LABEL_21BF_BehaviourB ; ??
  cp $0D
  jp z, _LABEL_214B_BehaviourD ; ??
  cp $01
  jp z, _LABEL_29BC_Behaviour1_FallToFloor ; floor
  cp $0E
  jp z, _LABEL_65D0_BehaviourE ; water
  cp $0F
  jp z, _LABEL_2934_BehaviourF
  cp $12
  jp z, _LABEL_2C69_Behaviour12
  cp $02
  jr z, _LABEL_20E4_Behaviour2_Dust ; + ; Dust
  cp $05
  jr z, _LABEL_2128_Behaviour5_Skid ; ++ ; Skid
  cp $08
  jp z, _LABEL_2C29_Behaviour8_Sticky
  cp $09
  jp z, _LABEL_2AB5_Behaviour9
  cp $13
  jp z, _LABEL_2AA0_Behaviour13
_LABEL_20E3_BehaviourEnd:
  ret

_LABEL_20E4_Behaviour2_Dust
+:
  ; Behaviour 2 = dust/chalk
  ld a, (_RAM_DE92_EngineVelocity)
  cp $07
  jr c, + ; Only when driving fast enough
  xor a
  ld (_RAM_DD9A_), a
  ld a, $01
  ld (_RAM_DD9B_), a
+:
  ret

++:
_LABEL_2128_Behaviour5_Skid
  ; Behaviour 5 = skid
  ld a, $01
  ld (_RAM_D5CD_CarIsSkidding), a
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr z, +++ ; Not using the engine
  ld a, $01
  ld (_RAM_DD9A_), a ; set ???
  ld (_RAM_DD9B_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_TurboWheels
  jr z, +++
  cp TT_RuffTrux
  jr z, +++
  cp TT_Warriors
  jr nz, +
  ld a, $08
  jr ++

+:
  ld a, $10
++:
  ld (_RAM_D5B6_), a ; set to 8 or 16 (or not at all) depending on track type
+++:
  ret

_LABEL_2121_Behaviour0:
  ld a, (_RAM_DF00_)
  or a
  jr nz, _LABEL_20E3_BehaviourEnd
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $04
  jr z, +
  cp $0B
  jr z, +
  cp $0D
  jr z, +
  cp $03
  jr nz, _LABEL_20E3_BehaviourEnd
+:; If coming from 3, 4, b, d:
  ld a, $1C
  ld (_RAM_DF0A_), a
  ld a, $08
  ld (_RAM_DF02_), a
  xor a
  ld (_RAM_DF03_), a
  jp _LABEL_22A9_

_LABEL_214B_BehaviourD:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $0D
  jr z, +
  jp _LABEL_2175_Behaviour6

+:
  ret

_LABEL_2156_BehaviourA:
  ld a, (_RAM_DF00_)
  or a
  jr nz, +
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $0B
  jr z, ++
+:
  ret

++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  jp _LABEL_29BC_Behaviour1_FallToFloor

+:
  jp _LABEL_2934_BehaviourF

_LABEL_2175_Behaviour6:
  ld a, (_RAM_DF00_)
  or a
  jp nz, _LABEL_22CC_
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
  ld hl, _DATA_24AE_
  ld de, (_RAM_DE94_)
  add hl, de
  ld a, (hl)
  ld (_RAM_DF0A_), a
  ld hl, _DATA_24BE_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF02_), a
  cp $82
  jp z, _LABEL_22CC_
  ld a, $01
  ld (_RAM_DF03_), a
  jp _LABEL_22A9_

_LABEL_21BF_BehaviourB:
  ld a, (_RAM_DB97_TrackType)
  cp TT_FormulaOne
  jr z, ++
  cp TT_FourByFour
  jr nz, +
-:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  or a
  jp z, _LABEL_2200_
  cp $06
  jp z, _LABEL_2200_
+:
  ret

++:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $1A
  jr z, -
  ret

_LABEL_21E1_Behaviour3:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $07
  jr z, +
  ld a, (_RAM_DEFB_PreviousDifferentBehaviour)
  or a
  jr z, _LABEL_2200_
  cp $06
  jr z, _LABEL_2200_
+:
  ret

_LABEL_21F3_Behavour4:
  ld a, (_RAM_DEFA_PreviousBehaviour)
  cp $07
  jr z, +
  ld a, (_RAM_DEFB_PreviousDifferentBehaviour)
  or a
  jr nz, _LABEL_2222_
_LABEL_2200_:
  ld a, (_RAM_DE5C_)
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DE5D_)
  ld (_RAM_DBA5_), a
  call _LABEL_28AC_
  xor a
  ld (_RAM_DEAF_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DBA4_)
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DBA5_)
  ld (_RAM_DBA7_), a
_LABEL_2222_:
  ret

+:
  ld a, (_RAM_DF00_)
  or a
  jp nz, _LABEL_22CC_
  ld a, (_RAM_D5CF_)
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
  ld hl, _DATA_24EE_
  jp ++

+:
  ld hl, _DATA_24CE_
++:
  ld de, (_RAM_DE94_)
  add hl, de
  ld a, (hl)
  or a
  jr z, _LABEL_2222_
  ld (_RAM_DF0A_), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, _DATA_24FE_
  jp ++

+:
  ld hl, _DATA_24DE_
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
_LABEL_22A9_:
  ld a, (_RAM_DF04_)
  ld (_RAM_DF06_), a
  ld a, (_RAM_DF05_)
  ld (_RAM_DF07_), a
  ld a, $01
  ld (_RAM_DF00_), a
  ld hl, (_RAM_D95B_)
  ld (_RAM_D58C_), hl
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr z, _LABEL_22CC_
  ld a, $02
  ld (_RAM_D963_SFXTrigger2), a
_LABEL_22CC_:
  ret

_LABEL_22CD_:
  ld d, $00
  ld a, (_RAM_DF00_)
  or a
  jp z, _LABEL_23C2_
  ld hl, _DATA_1B232_ ; $B232
  ld e, a
  add hl, de
  ld a, :_DATA_1B232_ ; $06
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
  ld (_RAM_DEF5_), a
  ld a, (_RAM_DF0A_)
  ld (_RAM_DEF4_), a
  call _LABEL_1B94_
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
  call _LABEL_1B94_
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
  jp c, _LABEL_23C2_
  ld hl, (_RAM_D58C_)
  ld (_RAM_D95B_), hl
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, +
  ld a, $11
  jp ++

+:
  ld a, $02
++:
  ld (_RAM_D963_SFXTrigger2), a
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
  jr c, _LABEL_23C3_
  jp _LABEL_23D0_

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
_LABEL_23C2_:
  ret

_LABEL_23C3_:
  ld a, $0A
  ld (_RAM_DF0A_), a
  ld a, $0C
  ld (_RAM_DF02_), a
  jp _LABEL_22A9_

_LABEL_23D0_:
  ld a, $20
  ld (_RAM_DF0A_), a
  ld a, $08
  ld (_RAM_DF02_), a
  jp _LABEL_22A9_

_LABEL_23DD_:
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
  ld hl, _DATA_1DA7_
  add hl, bc
  jp ++

+:
  ld hl, _DATA_1D87_
++:
  add hl, de
  ld a, (hl)
  ld (_RAM_DE55_), a
  ld a, (_RAM_DE54_)
  and $40
  jr z, +
  ld hl, _DATA_1D97_
  ld d, $00
  ld a, (_RAM_DE55_)
  ld e, a
  add hl, de
  ld a, (hl)
  ld (_RAM_DE55_), a
+:
  ret

; Data from 242E to 24AD (128 bytes)
_DATA_242E_BehaviourLookup: ; Behaviour lookup per track type
.db $00 $00 $01 $00 $02 $00 $03 $00 $04 $00 $05 $00 $06 $00 $07 $00
.db $00 $06 $05 $08 $01 $0C $0D $0B $0B $0B $0D $0B $0B $00 $00 $00
.db $00 $00 $00 $00 $06 $00 $06 $00 $00 $00 $00 $00 $06 $00 $00 $00
.db $00 $02 $05 $12 $06 $00 $00 $00 $00 $00 $00 $00 $06 $06 $06 $00
.db $00 $0B $02 $00 $00 $01 $13 $00 $09 $09 $0C $0B $09 $00 $0A $0B
.db $00 $00 $02 $00 $06 $00 $05 $00 $08 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $06 $05
.db $00 $00 $06 $03 $06 $00 $05 $0E $00 $00 $00 $00 $00 $00 $00 $00

; Data from 24AE to 24BD (16 bytes)
_DATA_24AE_:
.db $00 $00 $00 $00 $00 $0C $10 $14 $18 $1C $20 $20 $20 $20 $20 $20

; Data from 24BE to 24CD (16 bytes)
_DATA_24BE_:
.db $82 $82 $82 $82 $82 $0A $0A $09 $09 $08 $08 $08 $08 $08 $08 $08

; Data from 24CE to 24DD (16 bytes)
_DATA_24CE_:
.db $00 $00 $00 $00 $00 $00 $28 $28 $38 $38 $58 $78 $78 $78 $78 $78

; Data from 24DE to 24ED (16 bytes)
_DATA_24DE_:
.db $82 $82 $82 $82 $82 $82 $06 $06 $05 $05 $04 $03 $03 $03 $03 $03

; Data from 24EE to 24FD (16 bytes)
_DATA_24EE_:
.db $00 $00 $00 $00 $00 $28 $28 $38 $38 $58 $78 $88 $88 $88 $88 $88

; Data from 24FE to 250D (16 bytes)
_DATA_24FE_:
.db $82 $82 $82 $82 $82 $06 $06 $05 $05 $04 $03 $03 $03 $03 $03 $03

; Data from 250E to 251D (16 bytes)
_DATA_250E_:
.db $08 $09 $0A $0B $0C $0D $0E $0F $00 $01 $02 $03 $04 $05 $06 $07

; Data from 251E to 254D (48 bytes)
_DATA_251E_:
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $10 $11 $12 $13
.db $14 $15 $16 $17 $18 $19 $1A $1B $20 $21 $22 $23 $24 $25 $26 $27
.db $28 $29 $2A $2B $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B

.macro TimesTableLo args start, step, count
.define x start
.rept count
.db <x
.redefine x x+step
.endr
.undef x
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

; Data from 254E to 258E (65 bytes)
_DATA_254E_TimesTable18Lo:
  TimesTableLo 0, 18, 65

; Data from 258F to 25CF (65 bytes)
_DATA_258F_TimesTable18Hi:
  TimesTableHi 0, 18, 65

; Data from 25D0 to 2610 (65 bytes)
_DATA_25D0_:
  TimesTableLo 0, 36, 65

; Data from 2611 to 261F (15 bytes)
_DATA_2611_:
  TimesTableHi 0, 36, 65

_DATA_2652_TimesTable12Lo:
  TimesTableLo 0, 12, 12

-:
  ret

_LABEL_265F_:
  ld a, (_RAM_DEB5_)
  or a
  jp z, -
  call _LABEL_26F5_
  ld a, (_RAM_DEB5_)
  or a
  jp z, -
  call _LABEL_2724_
_LABEL_2673_:
  ld a, (_RAM_DF0D_)
  ld l, a
  ld a, (_RAM_DEB0_)
+:
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

; Data from 26B1 to 26B1 (1 bytes)
.db $C9 ; ret

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

_LABEL_26F5_:
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
  jr nz, +
  ld a, $00
  ld (_RAM_DEAE_), a
+:
  ret

_LABEL_2724_:
  ld hl, _DATA_1D65_
  ld a, (_RAM_DF0F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_DF0F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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

_LABEL_27B1_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_27FB_
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
  jp _LABEL_27FB_

+:
  ld hl, _RAM_DEB1_VScrollDelta
  ld a, (_RAM_DBA7_)
  add a, (hl)
  ld (_RAM_DBA7_), a
_LABEL_27FB_:
  ld a, (_RAM_D5C5_)
  cp $01
  jr z, _LABEL_284F_
  ld a, (_RAM_D5B0_)
  or a
  jr nz, _LABEL_284F_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_284F_
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr nz, _LABEL_284F_
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
_LABEL_284F_:
  ret

+:
  xor a
  ld (_RAM_DB81_), a
  jp -

_LABEL_2857_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr nz, _LABEL_28A4_
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
_LABEL_28A4_:
  ret

+:
  xor a
  ld (_RAM_DB83_), a
  jp -

_LABEL_28AC_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_FourByFour
  jr nz, +
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ld a, (_RAM_DE90_CarDirection)
  ld l, a
  ld h, $00
  ld de, _DATA_250E_
  add hl, de
  ld a, (hl)
  ld c, a
  jr _LABEL_28D6_

+:
  ld a, (_RAM_DE90_CarDirection)
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr z, +
  cp TT_RuffTrux
  jr nz, ++
_LABEL_28D6_:
  ld a, $04
  jp +++

+:
  ld a, (_RAM_DF7B_)
  or a
  jr z, _LABEL_28D6_
  ld a, (_RAM_DF7A_)
  ld c, a
  jr _LABEL_28D6_

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
  ld hl, _DATA_250E_
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

_LABEL_2934_BehaviourF:
  ld a, (_RAM_DF00_)
  or a
  jr nz, +
  ld a, (_RAM_DF58_)
  or a
  jr nz, +
  ld a, $05
  ld (_RAM_D963_SFXTrigger2), a
  ld a, $01
  ld (_RAM_DF59_CarState), a
  ld (_RAM_DF58_), a
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  jp _LABEL_71C7_

+:
  ret

_LABEL_2961_:
  ld a, (ix+20)
  or a
  jr nz, +
  ld a, (ix+46)
  or a
  jr nz, +
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
+:
  ret

++:
  ld a, $01
  ld (_RAM_DF5B_), a
  ret

+++:
  ld a, $01
  ld (_RAM_DF5A_), a
  ret

_LABEL_29A3_:
  ld a, (_RAM_DF00_)
  or a
  jr z, +
  cp $80
  jr c, ++
+:
  ld a, (_RAM_DF58_)
  or a
  jr nz, ++
  ld a, $09
  ld (_RAM_D963_SFXTrigger2), a
  jp _LABEL_29BC_Behaviour1_FallToFloor

++:
  ret

_LABEL_29BC_Behaviour1_FallToFloor:
  ld a, (_RAM_D5B0_)
  or a
  jr nz, _LABEL_2A36_ret
  ld a, (_RAM_DF00_) ; 0 or <$80 -> do nothing
  or a
  jr z, +
  cp $80
  jr c, _LABEL_2A36_ret
+:
  ld a, (_RAM_DF58_)
  or a
  jr nz, _LABEL_2A36_ret
  ld a, (_RAM_D5BD_)
  or a
  jr nz, +
  ; Play sound effect
  ld a, $0E
  ld (_RAM_D963_SFXTrigger2), a
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
  ld a, $04
  jp ++
+:ld a, $03
++:ld (_RAM_DF59_CarState), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  xor a
  ld (_RAM_D95E_), a
_LABEL_2A08_:
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
  jr z, _LABEL_2A4A_
  jp _LABEL_71C7_

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

_LABEL_2A4A_:
  ld a, (_RAM_DF59_CarState)
  cp $03
  jr z, -
  cp $04
  jr z, -
_LABEL_2A55_:
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

_LABEL_2AA0_Behaviour13:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $16
  jp z, _LABEL_2200_
  cp $2A
  jp z, _LABEL_2200_
  cp $3F
  jp z, _LABEL_2200_
  ret

_LABEL_2AB5_Behaviour9:
  ld a, (_RAM_DF00_)
  or a
  jr z, +
  ret

+:
  ld a, (_RAM_DE8C_)
  cp $01
  jp z, _LABEL_2C28_
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jp z, _LABEL_2B7D_
  cp $01
  jp z, _LABEL_2B57_
  ld a, (_RAM_DC52_PreviousCombinedByte2)
  and $10
  jp nz, _LABEL_29A3_
  ld a, (_RAM_DF55_)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (_RAM_DE7D_)
  and $3F
  cp $3A
  jp nz, _LABEL_29A3_
  jp +++

+:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $3A
  jp nz, _LABEL_29A3_
  jp ++++

++:
  ld a, (_RAM_DE7D_)
  and $3F
  cp $1D
  jr z, +++++
  cp $1E
  jp nz, _LABEL_29A3_
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
  jp _LABEL_2BA4_

++++:
  ld a, $02
  ld (_RAM_DF55_), a
  ld hl, $07F0
  ld (_RAM_DBAD_), hl
  ld hl, $0620
  ld (_RAM_DBAF_), hl
  ld a, $04
  ld (_RAM_DE8D_), a
  jp _LABEL_2BA4_

+++++:
  ld a, $01
  ld (_RAM_DF55_), a
  ld hl, $06B8
  ld (_RAM_DBAD_), hl
  ld hl, $0148
  ld (_RAM_DBAF_), hl
  ld a, $0A
  ld (_RAM_DE8D_), a
  jp _LABEL_2BA4_

_LABEL_2B57_:
  ld a, (_RAM_DC52_PreviousCombinedByte2)
  and $10
  jp nz, _LABEL_29A3_
  ld a, (_RAM_DE7D_)
  and $3F
  cp $39
  jp nz, _LABEL_29A3_
  ld hl, $0100
  ld (_RAM_DBAD_), hl
  ld hl, $00E0
  ld (_RAM_DBAF_), hl
  ld a, $06
  ld (_RAM_DE8D_), a
  jp _LABEL_2BA4_

_LABEL_2B7D_:
  ld a, (_RAM_DC52_PreviousCombinedByte2)
  and $10
  jp nz, _LABEL_29A3_
  ld a, (_RAM_DE7D_)
  and $3F
  cp $34
  jr z, +
  cp $35
  jp nz, _LABEL_29A3_
+:
  ld hl, $0618
  ld (_RAM_DBAD_), hl
  ld hl, $0500
  ld (_RAM_DBAF_), hl
  ld a, $0C
  ld (_RAM_DE8D_), a
_LABEL_2BA4_:
  ld a, (_RAM_DF58_)
  or a
  jr nz, _LABEL_2C28_
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
  ld a, $09
  ld (_RAM_D963_SFXTrigger2), a
  ld a, $03
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
_LABEL_2C28_:
  ret

_LABEL_2C29_Behaviour8_Sticky:
  ld a, (_RAM_DB97_TrackType)
  cp TT_FourByFour
  jr z, Behaviour8_Sticky_FourByFour
  ld a, (_RAM_DE92_EngineVelocity)
  or a
  jr z, +++ ; 0 -> do nothing
  cp $01
  jr z, +++ ; 1 -> do nothing
  cp $02
  jr z, +   ; 2 -> subtract 1
  sub $02   ; Otherwise, subtract 2
  jp ++

+:
  sub $01
++:
  ld (_RAM_DE92_EngineVelocity), a
  ld a, $07
  ld (_RAM_D963_SFXTrigger2), a
+++:
  ret

++++:
Behaviour8_Sticky_FourByFour:
  ld a, (_RAM_DE92_EngineVelocity)
  cp $03
  jr c, +++ ; 3 -> do nothing
  cp $04
  jr z, +   ; 4 -> subtract 1
  sub $02   ; Otherwise, subtract 2
  jp ++

+:
  sub $01
++:
  ld (_RAM_DE92_EngineVelocity), a
  ld a, $07
  ld (_RAM_D963_SFXTrigger2), a
+++:
  ret

_LABEL_2C69_Behaviour12:
  ld a, (_RAM_DF00_)
  or a
  jr nz, _LABEL_2CD0_
  ld a, (_RAM_DF58_)
  or a
  jr nz, _LABEL_2CD0_
  ld a, $08
  ld (_RAM_D963_SFXTrigger2), a
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
  jp _LABEL_29BC_Behaviour1_FallToFloor

+:
  ld a, $04
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
  jp _LABEL_71C7_

_LABEL_2CD0_:
  ret

+:
  jp _LABEL_2A4A_

_LABEL_2CD4_:
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
  ld a, $01
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

_LABEL_2D07_UpdatePalette_RuffTruxSubmerged:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ; Game Gear
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, + ; ret
  call _LABEL_3F22_ScreenOff
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  sla a
  ld hl, _DATA_2D36_RuffTruxSubmergedPaletteSequence_GG
  ld e, a
  ld d, $00
  add hl, de
  ld a, $26 ; Palette entry $13
  out (PORT_VDP_ADDRESS), a
  ld a, $C0
  out (PORT_VDP_ADDRESS), a
  ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_DATA), a
  call _LABEL_3F36_ScreenOn
+:
  ret

; Data from 2D36 to 2D3F (10 bytes)
_DATA_2D36_RuffTruxSubmergedPaletteSequence_GG:
  GGCOLOUR $000000
  GGCOLOUR $000088
  GGCOLOUR $004488
  GGCOLOUR $0088ee
  GGCOLOUR $000000

++: ; SMS
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, + ; ret
  call _LABEL_3F22_ScreenOff ; while we mess with the palette (?!)
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  ld hl, _DATA_2FB7_RuffTruxSubmergedPaletteSequence_SMS
  ld e, a
  ld d, $00
  add hl, de
  ld a, $13 ; Palette index $13
  out (PORT_VDP_ADDRESS), a
  ld a, $C0
  out (PORT_VDP_ADDRESS), a
  ld a, (hl) ; Set colour
  out (PORT_VDP_DATA), a
  call _LABEL_3F36_ScreenOn
+:ret

_LABEL_2D63_:
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
  jr z, _LABEL_2E71_
  jp _LABEL_2ED3_

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
  jr z, _LABEL_2E42_
  jr c, +
_LABEL_2E42_:
  ld a, (_RAM_DB6A_)
  ld (_RAM_DCDC_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $01
  jr c, _LABEL_2E42_
++:
  ld a, (_RAM_DB6B_)
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
  ld a, (_RAM_DB69_)
  ld (_RAM_DCDC_), a
  ret

++:
  ld a, (_RAM_DB68_)
  ld (_RAM_DCDC_), a
  ret

_LABEL_2E71_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB98_TopSpeed)
  ld (_RAM_DD1D_), a
  ret

+:
  ld a, (_RAM_DC4F_Cheat_EasierOpponents)
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
  jr z, _LABEL_2EA4_
  jr c, +
_LABEL_2EA4_:
  ld a, (_RAM_DB6E_)
  ld (_RAM_DD1D_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $01
  jr c, _LABEL_2EA4_
++:
  ld a, (_RAM_DB6F_)
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
  ld a, (_RAM_DB6D_)
  ld (_RAM_DD1D_), a
  ret

++:
  ld a, (_RAM_DB6C_)
  ld (_RAM_DD1D_), a
  ret

_LABEL_2ED3_:
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
  jr z, _LABEL_2EF8_
  jr c, +
_LABEL_2EF8_:
  ld a, (_RAM_DB72_)
  ld (_RAM_DD5E_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $01
  jr c, _LABEL_2EF8_
++:
  ld a, (_RAM_DB73_)
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
  ld a, (_RAM_DB71_)
  ld (_RAM_DD5E_), a
  ret

++:
  ld a, (_RAM_DB70_)
  ld (_RAM_DD5E_), a
  ret

; Data from 2F27 to 2F66 (64 bytes)
_DATA_2F27_:
.db $00 $00 $20 $00 $40 $00 $60 $00 $80 $00 $A0 $00 $C0 $00 $E0 $00
.db $00 $01 $20 $01 $40 $01 $60 $01 $80 $01 $A0 $01 $C0 $01 $E0 $01
.db $00 $02 $20 $02 $40 $02 $60 $02 $80 $02 $A0 $02 $C0 $02 $E0 $02
.db $00 $03 $20 $03 $40 $03 $60 $03 $80 $03 $A0 $03 $C0 $03 $E0 $03

; Data from 2F67 to 2FA6 (64 bytes)
_DATA_2F67_:
.db $00 $00 $60 $00 $C0 $00 $20 $01 $80 $01 $E0 $01 $40 $02 $A0 $02
.db $00 $03 $60 $03 $C0 $03 $20 $04 $80 $04 $E0 $04 $40 $05 $A0 $05
.db $00 $06 $60 $06 $C0 $06 $20 $07 $80 $07 $E0 $07 $40 $08 $A0 $08
.db $00 $09 $60 $09 $C0 $09 $20 $0A $80 $0A $E0 $0A $40 $0B $A0 $0B

; Data from 2FA7 to 2FAE (8 bytes)
_DATA_2FA7_:
.db $20 $40 $00 $00 $40 $00 $40 $20

; Data from 2FAF to 2FB6 (8 bytes)
_DATA_2FAF_:
.db $20 $00 $40 $20 $40 $00 $20 $00

; Data from 2FB7 to 2FBB (5 bytes)
_DATA_2FB7_RuffTruxSubmergedPaletteSequence_SMS:
  SMSCOLOUR $000000 ; black
  SMSCOLOUR $0000aa ; dark blue
  SMSCOLOUR $0055aa ; middle blue
  SMSCOLOUR $00aaff ; light blue
  SMSCOLOUR $000000 ; black

; Data from 2FBC to 2FDB (32 bytes)
_DATA_2FBC_:
.db $52 $A6 $B6 $9E ; 4 bytes per track tyoe
.db $62 $24 $85 $00 ; Copied to _RAM_DF68
.db $1C $51 $5E $4E
.db $57 $50 $70 $00
.db $85 $8F $9B $00
.db $42 $72 $6A $00
.db $2C $40 $53 $00
.db $38 $3E $4B $00

_LABEL_2FDC_:
  ld a, (_RAM_D5C1_)
  or a
  jr nz, _LABEL_3028_
  ld a, (_RAM_DE87_)
  add a, $01
  ld (_RAM_DE87_), a
  cp $01
  jr z, +
  cp $0A
  jr nz, _LABEL_2FF6_
  xor a
  ld (_RAM_DE87_), a
_LABEL_2FF6_:
  jp _LABEL_304B_

+:
  ld a, (_RAM_DE88_)
  or a
  jp z, _LABEL_3085_
  cp $01
  jp z, _LABEL_3057_
  cp $02
  jp z, ++
  ld a, (_RAM_DE88_)
  add a, $01
  ld (_RAM_DE88_), a
  cp $08
  jr nz, _LABEL_2FF6_
  ld a, (_RAM_DE8B_)
  or a
  jr z, _LABEL_3028_
  ld a, $01
  ld (_RAM_DE89_), a
  xor a
  ld (_RAM_DE8A_), a
  jp +

_LABEL_3028_:
  xor a
  ld (_RAM_D5C1_), a
  ld a, $01
  ld (_RAM_DE8A_), a
  ld a, $15
  ld (_RAM_D963_SFXTrigger2), a
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

_LABEL_304B_:
  ld a, (_RAM_DE88_)
  cp $01
  jr z, ++
  cp $02
  jr z, +
  ret

_LABEL_3057_:
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

_LABEL_3085_:
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

_LABEL_30EA_:
  ld a, (_RAM_DEF5_)
  sla a
  ld l, a
  ld h, $00
  ld de, _DATA_2F27_
  add hl, de
  ld a, (hl)
  ld (_RAM_DEF1_), a
  inc hl
  ld a, (hl)
  ld (_RAM_DEF2_), a
  ret

_LABEL_3100_:
  ld a, (_RAM_DEF5_)
  sla a
  ld l, a
  ld h, $00
  ld de, _DATA_2F67_
  add hl, de
  ld a, (hl)
  ld (_RAM_DEF1_), a
  inc hl
  ld a, (hl)
  ld (_RAM_DEF2_), a
  ret

; Data from 3116 to 313A (37 bytes)
_DATA_3116_F1_TileHighBytesRunCompressed:
; Bitmask
.db %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111
.db %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111110 %11101111
.db %11111001 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111
.db %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111 %11111111
; Data (4 bytes)
.db $00 $10 $00 $10 $00
; Expands to:
; 0, 0, ... 0, 10, 10, 10, 10, 0, 0, ... 0, 10, 0, 0, ... 0

; Data from 313B to 3163 (41 bytes)
_DATA_313B_Powerboats_TileHighBytesRunCompressed:
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FE $EF $FF $FC $E7 $FF $FF $FF $7B $FF $FF
.db $00 $10 $00 $10 $00 $10 $00 $10 $00

_LABEL_3164_:
  ld a, (_RAM_D582_)
  cp $01
  jr nz, + ; ret
  ld a, $02
  ld (_RAM_D582_), a
  JumpToPagedFunction _LABEL_3682E_

+:
  ret

_LABEL_317C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, + ; ret
  JumpToPagedFunction _LABEL_36971_

+:
  ret

_LABEL_318E_:
  JumpToPagedFunction _LABEL_1BE82_

_LABEL_3199_:
  JumpToPagedFunction _LABEL_37529_

; Data from 31A4 to 31B5 (18 bytes)
_DATA_31A4_FloorTilesVRAMAddress:
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

_LABEL_31B6_InitialiseFloorTiles:
  xor a
  ld d, a
  ld (_RAM_DF17_HaveFloorTiles), a
  ld a, (_RAM_DB97_TrackType)
  or a
  rl a
  ld e, a
  ld hl, _DATA_31A4_FloorTilesVRAMAddress ; Look up per-track-type data from this table
  add hl, de
  ld a, (hl)
  ld (_RAM_DF18_FloorTilesVRAMAddress), a
  inc hl
  ld a, (hl)
  ld (_RAM_DF18_FloorTilesVRAMAddress+1), a
  cp $FF
  jr z, +
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
  ld a, $00    ; Blank it out
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
+:
  ret

_LABEL_31F1_UpdateSpriteTable:
  ; Sprite table Y
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $7F
  out (PORT_VDP_ADDRESS), a
  ld hl, _RAM_DAE0_SpriteTableYs
  ld b, 64*_sizeof_SpriteY
  ld c, PORT_VDP_DATA
  otir
  ; Sprite table XN
  ld a, $80
  out (PORT_VDP_ADDRESS), a
  ld a, $7F
  out (PORT_VDP_ADDRESS), a
  ld hl, _RAM_DA60_SpriteTableXNs
  ld b, 64*_sizeof_SpriteXN
  ld c, PORT_VDP_DATA
  otir
  ret

_LABEL_3214_BlankSpriteTable:
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

_LABEL_3231_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, +
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  ld bc, $0080
-:
  xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
+:
  ret

_LABEL_324C_UpdatePerFrameTiles:
  ; Updates all the tiles which are written into every frame
  ld c, PORT_VDP_DATA
  ld d, $00
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jp z, _LABEL_746B_RuffTrux_UpdatePerFrameTiles

  ; Update tiles for car "decorators"
  ; Always do the red car
  ld a, (_RAM_DE91_CarDirectionPrevious) ; 0-$f
  or a
  rl a ; multiply by 8
  rl a
  rl a
  ld e, a
  ld hl, _RAM_D980_CarDecoratorTileData1bpp ; table here holds the 1bpp tile data
  add hl, de
  ld a, $00 ; tile 190 = red car decorator
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $04 ; every 4 bytes -> 1 bitplane
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $08
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $0C
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $10
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $14
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $18
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $1C
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  call _LABEL_336A_UpdateBlueCarDecorator
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ; Tournament
  call _LABEL_3302_UpdateGreenCarDecorator
  jp _LABEL_33D2_UpdateYellowCarDecorator ; and ret

+:; Head to head
  ld a, $C0 ; Tile $1a6
  out (PORT_VDP_ADDRESS), a
  ld a, $74
  out (PORT_VDP_ADDRESS), a
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
  ld a, :_DATA_30A68_ChallengeHUDTiles ; $0C
  ld (PAGING_REGISTER), a
  ld hl, _DATA_30A68_ChallengeHUDTiles + 32 * 16 ; Just the laps remaining indicators
  add hl, de
  ld b, $20
  ld c, PORT_VDP_DATA
  otir ; Emit
--:
  jp _LABEL_AFD_RestorePaging_fromDE8E

+:
  ld b, $20 ; Emit a blank tile
  xor a
-:out (PORT_VDP_DATA), a
  dec b
  jr nz, -
  jp --

_LABEL_3302_UpdateGreenCarDecorator:
  ld c, PORT_VDP_DATA
  ld ix, _RAM_DCAB_
  ld d, $00
  ld a, (ix+13)
  or a
  rl a
  rl a
  rl a
  ld e, a
  ld hl, _RAM_D980_CarDecoratorTileData1bpp
  add hl, de
  ld a, $21 ; Tile $191 = green car "decorator"
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $25
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $29
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $2D
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $31
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $35
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $39
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $3D
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ret

_LABEL_336A_UpdateBlueCarDecorator:
  ld c, PORT_VDP_DATA
  ld ix, _RAM_DCEC_
  ld d, $00
  ld a, (ix+13) ; Direction?
  or a
  rl a
  rl a
  rl a
  ld e, a
  ld hl, _RAM_D980_CarDecoratorTileData1bpp
  add hl, de
  ld a, $42 ; Tile $192 = blue car "decorator"
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $46
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $4A
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $4E
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $52
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $56
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $5A
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $5E
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ret

_LABEL_33D2_UpdateYellowCarDecorator:
  ld c, PORT_VDP_DATA
  ld ix, _RAM_DD2D_
  ld d, $00
  ld a, (ix+13)
  or a
  rl a
  rl a
  rl a
  ld e, a
  ld hl, _RAM_D980_CarDecoratorTileData1bpp
  add hl, de
  ld a, $63 ; Tile $193 = yellow car "decorator"
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $67
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $6B
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $6F
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $73
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $77
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $7B
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ld a, $7F
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  outi
  ret

_LABEL_343A_:
  JumpToPagedFunction _LABEL_375A0_

_LABEL_3445_:
  JumpToPagedFunction _LABEL_3766F_

_LABEL_3450_:
  ld a, $01
  ld (_RAM_DE40_), a
  ld (_RAM_DE41_), a
  ld (_RAM_DE42_), a
  ld (_RAM_DE43_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, ++
  ld a, (_RAM_DE4A_)
  xor $FF
  ld (_RAM_DE4A_), a
  xor a
  ld (_RAM_DE4B_), a
  ld (_RAM_DE4C_), a
  ld (_RAM_DE4D_), a
  ld (_RAM_DE4E_), a
  call _LABEL_3556_
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
++:
  ret

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
  jr z, _LABEL_353A_
  cp $06
  jr z, +++
  ret

+:
  ld a, (_RAM_DE4A_)
  or a
  jr z, _LABEL_352B_
  ld (_RAM_DE42_), a
  ret

_LABEL_352B_:
  xor a
  ld (_RAM_DE41_), a
  ret

++:
  ld a, (_RAM_DE4A_)
  or a
  jr z, _LABEL_352B_
  ld (_RAM_DE43_), a
  ret

_LABEL_353A_:
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
  call _LABEL_353A_
  ld a, (_RAM_DE4A_)
  or a
  jr z, _LABEL_352B_
  ld (_RAM_DE40_), a
  ret

_LABEL_3556_:
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
  jr nc, +
  ld a, $03
  ld (_RAM_DE49_), a
+:
  ret

_LABEL_35E0_:
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
  cp TT_RuffTrux
  jr nz, +
  jp _LABEL_3A6B_

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
  jp z, _LABEL_3709_
  cp $03
  jr z, +
  cp $04
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
  call _LABEL_3DD1_
  call _LABEL_3674_
  jp _LABEL_370F_

_LABEL_3674_:
  xor a
  ld (_RAM_DE2F_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  ret

+:
  call _LABEL_3674_
++:
  ld a, (_RAM_DF5D_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF61_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF59_CarState)
  ld (_RAM_DE8A_), a
  ld a, (_RAM_DE8C_)
  ld (_RAM_DE8B_), a
  ld a, (_RAM_D5BD_)
  ld (_RAM_D5C1_), a
  ld a, (_RAM_D5BF_)
  ld (_RAM_D5C2_), a
  call _LABEL_3B74_
  ld a, (_RAM_D5C2_)
  ld (_RAM_D5BF_), a
  ld a, (_RAM_D5C1_)
  ld (_RAM_D5BD_), a
  ld a, (_RAM_DE8B_)
  ld (_RAM_DE8C_), a
  ld a, (_RAM_DE8A_)
  ld (_RAM_DF59_CarState), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF61_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5D_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, ++
  ld a, (_RAM_DF59_CarState)
  cp $02
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
  ld a, $FF
  ld (_RAM_DF59_CarState), a
  jp +++

+:
  xor a
  ld (_RAM_DF59_CarState), a
++:
  jp +++

_LABEL_3709_:
  ld a, (_RAM_DF58_)
  or a
  jr nz, +++
_LABEL_370F_:
  call _LABEL_3963_
+++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jp z, _LABEL_37BE_
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
  ld a, (_RAM_DF5A_)
  or a
  jr z, _LABEL_37B5_
  cp $03
  jr z, +
  cp $04
  jr nz, ++
+:
  ld a, (_RAM_DCB8_)
  or a
  jr z, ++
  call _LABEL_3F17_
  jp _LABEL_37BB_

++:
  ld a, (_RAM_DF5E_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF62_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5A_)
  ld (_RAM_DE8A_), a
  ld a, (_RAM_DCDE_)
  ld (_RAM_DE8B_), a
  call _LABEL_3B74_
  ld a, (_RAM_DE8B_)
  ld (_RAM_DCDE_), a
  ld a, (_RAM_DE8A_)
  ld (_RAM_DF5A_), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF62_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5E_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, ++
  ld a, (_RAM_DF5A_)
  cp $02
  jr nz, +
  xor a
  ld (_RAM_DCD9_), a
  ld a, (_RAM_DCB7_)
  ld (_RAM_DCB8_), a
+:
  xor a
  ld (_RAM_DF5A_), a
++:
  jp _LABEL_37BE_

_LABEL_37B5_:
  ld a, (_RAM_DCD9_)
  or a
  jr nz, _LABEL_37BE_
_LABEL_37BB_:
  call _LABEL_3963_
_LABEL_37BE_:
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
  jp z, _LABEL_38B3_
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
  call _LABEL_48D1_
  call _LABEL_3813_
  jp _LABEL_38B9_

_LABEL_3813_:
  xor a
  ld (_RAM_DE35_), a
  ret

+:
  call _LABEL_3813_
++:
  ld a, (_RAM_DF5F_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF63_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5B_)
  ld (_RAM_DE8A_), a
  ld a, (_RAM_DD1F_)
  ld (_RAM_DE8B_), a
  ld a, (_RAM_D5BE_)
  ld (_RAM_D5C1_), a
  ld a, (_RAM_D5C0_)
  ld (_RAM_D5C2_), a
  call _LABEL_3B74_
  ld a, (_RAM_D5C2_)
  ld (_RAM_D5C0_), a
  ld a, (_RAM_D5C1_)
  ld (_RAM_D5BE_), a
  ld a, (_RAM_DE8B_)
  ld (_RAM_DD1F_), a
  ld a, (_RAM_DE8A_)
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF63_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5F_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, _LABEL_38B0_
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
_LABEL_38B0_:
  jp ++

_LABEL_38B3_:
  ld a, (_RAM_DD1A_)
  or a
  jr nz, ++
_LABEL_38B9_:
  call _LABEL_3963_
++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jp z, _LABEL_395C_
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
  jr z, _LABEL_395D_
  cp $03
  jr z, +
  cp $04
  jr nz, ++
+:
  ld a, (_RAM_DD3A_)
  or a
  jr z, ++
  call _LABEL_48FC_
  jp _LABEL_3963_

++:
  ld a, (_RAM_DF60_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF64_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  ld a, (_RAM_DF5C_)
  ld (_RAM_DE8A_), a
  ld a, (_RAM_DD60_)
  ld (_RAM_DE8B_), a
  call _LABEL_3B74_
  ld a, (_RAM_DE8B_)
  ld (_RAM_DD60_), a
  ld a, (_RAM_DE8A_)
  ld (_RAM_DF5C_), a
  ld a, (_RAM_DE88_)
  ld (_RAM_DF64_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF60_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, _LABEL_395C_
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
_LABEL_395C_:
  ret

_LABEL_395D_:
  ld a, (_RAM_DD5B_)
  or a
  jr nz, _LABEL_395C_
_LABEL_3963_:
  call _LABEL_3969_
  jp _LABEL_39AE_

_LABEL_3969_:
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

_LABEL_39AE_:
  ld hl, _DATA_3E04_ ; Would be easier to do the maths
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

_LABEL_3A23_:
  JumpToPagedFunction _LABEL_36A85_

_LABEL_3A2E_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, +
  ld a, $A8
  ld (_RAM_DA60_SpriteTableXNs.49.n), a
  ld (_RAM_DA60_SpriteTableXNs.53.n), a
  ld a, $A9
  ld (_RAM_DA60_SpriteTableXNs.50.n), a
  ld (_RAM_DA60_SpriteTableXNs.54.n), a
  ld a, $AA
  ld (_RAM_DA60_SpriteTableXNs.51.n), a
  ld (_RAM_DA60_SpriteTableXNs.55.n), a
  ld a, $AB
  ld (_RAM_DA60_SpriteTableXNs.52.n), a
  ld (_RAM_DA60_SpriteTableXNs.56.n), a
  ret

+:
  ld a, $0B
  ld (_RAM_DA60_SpriteTableXNs.49.n), a
  ld a, $18
  ld (_RAM_DA60_SpriteTableXNs.50.n), a
  ld a, $1B
  ld (_RAM_DA60_SpriteTableXNs.51.n), a
  ld a, $88
  ld (_RAM_DA60_SpriteTableXNs.52.n), a
  ret

_LABEL_3A6B_:
  ld a, (_RAM_DF59_CarState)
  or a
  jr z, _LABEL_3AC9_
  cp $03
  jr nz, +
  ld a, (_RAM_DF73_)
  cp $0C
  jr z, +
  call _LABEL_2CD4_
  jp _LABEL_3ACF_

+:
  ld a, (_RAM_DF5D_)
  ld (_RAM_DE87_), a
  ld a, (_RAM_DF61_)
  ld (_RAM_DE88_), a
  xor a
  ld (_RAM_DE89_), a
  call _LABEL_3B74_
  ld a, (_RAM_DE88_)
  ld (_RAM_DF61_), a
  ld a, (_RAM_DE87_)
  ld (_RAM_DF5D_), a
  ld a, (_RAM_DE89_)
  cp $01
  jr nz, _LABEL_3AC8_
  ld a, (_RAM_DF59_CarState)
  cp $02
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
  ld (_RAM_DF59_CarState), a
_LABEL_3AC8_:
  ret

_LABEL_3AC9_:
  ld a, (_RAM_DF58_)
  or a
  jr nz, _LABEL_3AC8_
_LABEL_3ACF_:
  ld a, (_RAM_DE84_)
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
  ld a, (_RAM_DE85_)
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
  ld a, (_RAM_DE86_)
  sla a
  sla a
  sla a
  sla a
  ld hl, _DATA_35C2D_
  ld d, $00
  ld e, a
  add hl, de
  ld c, $11
  ld a, :_DATA_35C2D_
  ld (PAGING_REGISTER), a
-:
  ld a, (hl)
  ld (ix+1), a
  inc ix
  inc ix
  inc hl
  dec c
  jr nz, -
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  xor a
  ld (ix-2), a
  ld (iy-1), a
  ret

_LABEL_3B74_:
  ld a, (_RAM_DE8A_)
  cp $03
  jp z, _LABEL_2FDC_
  cp $04
  jp z, _LABEL_3E43_
  cp $FF
  jr z, _LABEL_3BEC_
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
  jr nz, _LABEL_3BEC_
  xor a
  ld (_RAM_DE87_), a
_LABEL_3BEC_:
  ret

+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  call _LABEL_3DEC_
  ld hl, _DATA_3F05_
  jp ++

+:
  ld hl, _DATA_40D3_
++:
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
  ld a, (_RAM_DE88_)
  add a, $01
  ld (_RAM_DE88_), a
  cp $09
  jr nz, +
  ld a, $01
  ld (_RAM_DE89_), a
  xor a
  ld (_RAM_DE87_), a
  ld (_RAM_DE88_), a
+:
  ret

_LABEL_3C54_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld a, (_RAM_DB96_TrackIndexForThisType)
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_A91_RuffTruxTimeLimits
  add hl, de
  ld a, (hl)
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  inc hl
  ld a, (hl)
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  inc hl
  ld a, (hl)
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  ld a, $02
  ld (_RAM_DF24_LapsRemaining), a
  jp ++

+:
  ld a, $04
  ld (_RAM_DF24_LapsRemaining), a
  ld (_RAM_DD05_), a
  ld (_RAM_DD46_), a
  ld a, $03
  ld (_RAM_DCC4_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, ++
  ld a, $03
  ld (_RAM_DD05_), a
++:
  xor a
  ld (_RAM_DF25_), a
  ; Copy data to RAM
  ld c, $09
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, _DATA_A7F_GG
  jp ++
+:ld hl, _DATA_A6D_SMS
++:
  ld de, _RAM_DF2E_
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  dec c
  jr nz, -
  ; Copy data to RAM
  ld c, $09
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, _DATA_A88_GG
  jp ++
+:ld hl, _DATA_A76_SMS
++:
  ld de, _RAM_DF40_
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  dec c
  jr nz, -

  ld a, (_RAM_DB97_TrackType)
  sla a ; x4
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_2FBC_
  add hl, de
  ld a, (_RAM_DB96_TrackIndexForThisType)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld (_RAM_DF68_), a
  srl a
  ld (_RAM_DF69_), a
  ld a, (_RAM_DF68_)
  ld (_RAM_D587_), a
  ld (_RAM_DD45_), a
  ld (_RAM_DD04_), a
  ld (_RAM_DF4F_), a
  ld (_RAM_DF52_), a
  ld (_RAM_DF51_), a
  ld a, $01
  ld (_RAM_DCC3_), a
  ld (_RAM_DF50_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ld a, $01
  ld (_RAM_DF51_), a
  ld (_RAM_DD04_), a
+:
  ld a, $A4
  ld (_RAM_DF3C_), a
  ld a, $A5
  ld (_RAM_DF3D_), a
  ld a, $A6
  ld (_RAM_DF3E_), a
  ld a, $A7
  ld (_RAM_DF3F_), a
  ld a, $01
  ld (_RAM_DF26_), a
  ld a, $02
  ld (_RAM_DF27_), a
  ld a, $03
  ld (_RAM_DF28_), a
  xor a
  ld (_RAM_DF29_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ret

+:
  JumpToPagedFunction _LABEL_35F41_

_LABEL_3D59_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, _LABEL_3DBC_
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, _LABEL_3DBC_
  ld a, (_RAM_DE4F_)
  cp $80
  jr nz, _LABEL_3DBC_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_3DBC_
  ld a, (_RAM_DCF6_)
  and $3F
  jr z, _LABEL_3DBC_
  cp $3C
  jr z, _LABEL_3DBC_
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
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld e, a
  ld d, $00
  ld hl, _DATA_4425_
  add hl, de
  ld a, (hl)
  cp $FE
  jr z, _LABEL_3DBC_
  cp $FF
  jr z, _LABEL_3DBC_
  ld (_RAM_D5B8_), a
_LABEL_3DBC_:
  ret

_LABEL_3DBD_:
  JumpToPagedFunction _LABEL_239C6_

; Data from 3DC8 to 3DD0 (9 bytes)
_DATA_3DC8_TrackTypeTileDataPages:
.db :_DATA_3C000_Sportscars_Tiles :_DATA_39C83_FourByFour_Tiles :_DATA_3D901_Powerboats_Tiles :_DATA_38000_TurboWheels_Tiles :_DATA_34000_FormulaOne_Tiles :_DATA_3A8FA_Warriors_Tiles :_DATA_39168_Tanks_Tiles :_DATA_3CD8D_RuffTrux_Tiles
.db $0D ; Dangling helicopters reference

_LABEL_3DD1_:
  JumpToPagedFunction _LABEL_3636E_

; Data from 3DDC to 3DE3 (8 bytes)
_DATA_3DDC_TrackTypeTileDataPointerLo:
.db <_DATA_3C000_Sportscars_Tiles <_DATA_39C83_FourByFour_Tiles <_DATA_3D901_Powerboats_Tiles <_DATA_38000_TurboWheels_Tiles <_DATA_34000_FormulaOne_Tiles <_DATA_3A8FA_Warriors_Tiles <_DATA_39168_Tanks_Tiles <_DATA_3CD8D_RuffTrux_Tiles

; Data from 3DE4 to 3DEB (8 bytes)
_DATA_3DE4_TrackTypeTileDataPointerHi:
.db >_DATA_3C000_Sportscars_Tiles >_DATA_39C83_FourByFour_Tiles >_DATA_3D901_Powerboats_Tiles >_DATA_38000_TurboWheels_Tiles >_DATA_34000_FormulaOne_Tiles >_DATA_3A8FA_Warriors_Tiles >_DATA_39168_Tanks_Tiles >_DATA_3CD8D_RuffTrux_Tiles

_LABEL_3DEC_:
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
_DATA_3E04_:
.db $00 $03 $06 $09 $0C $0F $12 $15 $48 $4B $4E $51 $54 $57 $5A $5D ; Multiples of 3, jumping in the middle
.db $00 $04 $08 $0C $10 $14 $18 $1C $80 $84 $88 $8C $90 $94 $98 $9C ; Multiples of 4, jumping in the middle

_LABEL_3E24_:
  JumpToPagedFunction _LABEL_37817_

_LABEL_3E2F_:
  JumpToPagedFunction _LABEL_37946_

; Data from 3E3A to 3E42 (9 bytes)
_DATA_3E3A_TrackTypeDataPageNumbers:
.db :_DATA_C000_TrackData_SportsCars
.db :_DATA_10000_TrackData_FourByFour
.db :_DATA_14000_TrackData_Powerboats
.db :_DATA_18000_TrackData_TurboWheels
.db :_DATA_1C000_TrackData_FormulaOne
.db :_DATA_20000_TrackData_Warriors
.db :_DATA_24000_TrackData_Tanks
.db :_DATA_28000_TrackData_RuffTrux
.db :_DATA_2C000_TrackData_Helicopters_BadReference

_LABEL_3E43_:
  ld a, (_RAM_DE87_)
  or a
  jr z, ++
  cp $80
  jr c, +
  ld a, $01
  ld (_RAM_DE8A_), a
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
  jp _LABEL_3969_

; Data from 3EA4 to 3EEB (72 bytes)
_DATA_3EA4_:
.db $0E $17 $10 $06 $1D $0D $13 $0F $01 $14 $02 $07 $10 $05 $00 $00
.db $04 $05 $0B $08 $07 $08 $04 $17 $04 $14 $07 $06 $08 $1A $00 $00
.db $0D $07 $0D $17 $1C $07 $00 $00 $13 $15 $0C $11 $0E $1D $00 $00
.db $04 $0A $05 $0F $0D $13 $00 $00 $02 $11 $03 $0F $15 $13 $00 $00
.db $04 $0B $02 $08 $02 $16 $00 $00

; Data from 3EEC to 3EF3 (8 bytes)
_DATA_3EEC_CarTileDataLookup_Lo:
.db <_DATA_34958_CarTiles_Sportscars <_DATA_34CF0_CarTiles_FourByFour <_DATA_35048_CarTiles_Powerboats <_DATA_35350_CarTiles_TurboWheels <_DATA_30000_CarTiles_FormulaOne <_DATA_30330_CarTiles_Warriors <_DATA_306D0_CarTiles_Tanks <_DATA_1296A_CarTiles_RuffTrux

; Data from 3EF4 to 3EFC (9 bytes)
_DATA_3EF4_CarTilesDataLookup_PageNumber:
.db :_DATA_34958_CarTiles_Sportscars :_DATA_34CF0_CarTiles_FourByFour :_DATA_35048_CarTiles_Powerboats :_DATA_35350_CarTiles_TurboWheels :_DATA_30000_CarTiles_FormulaOne :_DATA_30330_CarTiles_Warriors :_DATA_306D0_CarTiles_Tanks :_DATA_1296A_CarTiles_RuffTrux
.db $0c ; dangling Helicopters reference

; Data from 3EFD to 3F04 (8 bytes)
_DATA_3EFD_CarTileDataLookup_Hi:
.db >_DATA_34958_CarTiles_Sportscars >_DATA_34CF0_CarTiles_FourByFour >_DATA_35048_CarTiles_Powerboats >_DATA_35350_CarTiles_TurboWheels >_DATA_30000_CarTiles_FormulaOne >_DATA_30330_CarTiles_Warriors >_DATA_306D0_CarTiles_Tanks >_DATA_1296A_CarTiles_RuffTrux

; Pointer Table from 3F05 to 3F16 (9 entries, indexed by _RAM_DE88_)
_DATA_3F05_:
.dw _DATA_3F63_ _DATA_3F6C_ _DATA_3F75_ _DATA_3F7E_ _DATA_3F87_ _DATA_3F90_ _DATA_3F99_ _DATA_3FA2_
.dw _DATA_3FAB_

_LABEL_3F17_:
  JumpToPagedFunction _LABEL_23BC6_

_LABEL_3F22_ScreenOff:
/*
 D7 - No effect
 D6 - (BLK) 1= Display visible, 0= display blanked.
 D5 - (IE0) 1= Frame interrupt enable.
 D4 - (M1) Selects 224-line screen for Mode 4 if M2=1, else has no effect.
 D3 - (M3) Selects 240-line screen for Mode 4 if M2=1, else has no effect.
 D2 - No effect
 D1 - Sprites are 1=16x16,0=8x8 (TMS9918), Sprites are 1=8x16,0=8x8 (Mode 4)
 D0 - Sprite pixels are doubled in size.
*/
  ld a, $10
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_3F2B_:
  JumpToPagedFunction _LABEL_23B98_

_LABEL_3F36_ScreenOn:
  ld a, $70
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_3F3F_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  CallPagedFunction2 _LABEL_362D3_
+:
  ret

_LABEL_3F54_:
  ld bc, $02EF
-:
  ld hl, _RAM_DCAB_
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
_DATA_3F63_:
.db $68 $68 $68 $68 $68 $68 $68 $68 $68

; 2nd entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F6C to 3F74 (9 bytes)
_DATA_3F6C_:
.db $68 $68 $68 $68 $6B $68 $68 $68 $68

; 3rd entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F75 to 3F7D (9 bytes)
_DATA_3F75_:
.db $6B $68 $6B $68 $78 $68 $6B $68 $6B

; 4th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F7E to 3F86 (9 bytes)
_DATA_3F7E_:
.db $78 $6B $78 $6B $7B $6B $78 $6B $78

; 5th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F87 to 3F8F (9 bytes)
_DATA_3F87_:
.db $7B $78 $7B $78 $68 $78 $7B $78 $7B

; 6th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F90 to 3F98 (9 bytes)
_DATA_3F90_:
.db $68 $7B $68 $7B $6B $7B $68 $7B $68

; 7th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3F99 to 3FA1 (9 bytes)
_DATA_3F99_:
.db $68 $68 $68 $68 $78 $68 $68 $68 $68

; 8th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3FA2 to 3FAA (9 bytes)
_DATA_3FA2_:
.db $68 $68 $68 $68 $7B $68 $68 $68 $68

; 9th entry of Pointer Table from 3F05 (indexed by _RAM_DE88_)
; Data from 3FAB to 3FB3 (9 bytes)
_DATA_3FAB_:
.db $68 $68 $68 $68 $68 $68 $68 $68 $68

_LABEL_3FB4_UpdateAnimatedPalette:
  CallPagedFunction2 _LABEL_23CE6_UpdateAnimatedPalette
  ret

; Data from 3FC3 to 3FD2 (16 bytes)
_DATA_3FC3_:
.db $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06

; Data from 3FD3 to 3FFF (45 bytes)
_DATA_3FD3_:
.db $18 $12 $0C $06 $00 $06 $0C $12 $18 $12 $0C $06 $00 $06 $0C $12
.db "D", 9, "A,(BULLON2)", 13, 10, 9, "OR", 9, "A", 13, 10, 9, "JR", 9, "Z,"

; Bank marker
.db :CADDR

; Data from 4000 to 4040 (65 bytes)
_DATA_4000_TileIndexPointerLow: ; Low bytes of "tile index data pointer table"
.db $80 $10 $A0 $30 $C0 $50 $E0 $70 $00 $90 $20 $B0 $40 $D0 $60 $F0
.db $80 $10 $A0 $30 $C0 $50 $E0 $70 $00 $90 $20 $B0 $40 $D0 $60 $F0
.db $80 $10 $A0 $30 $C0 $50 $E0 $70 $00 $90 $20 $B0 $40 $D0 $60 $F0
.db $80 $10 $A0 $30 $C0 $50 $E0 $70 $00 $90 $20 $B0 $40 $D0 $60 $F0
.db $80 ; unused?

; Data from 4041 to 4081 (65 bytes)
_DATA_4041_TileIndexPointerHigh: ; High bytes of "tile index data pointer table"
.db $80 $81 $81 $82 $82 $83 $83 $84 $85 $85 $86 $86 $87 $87 $88 $88
.db $89 $8A $8A $8B $8B $8C $8C $8D $8E $8E $8F $8F $90 $90 $91 $91
.db $92 $93 $93 $94 $94 $95 $95 $96 $97 $97 $98 $98 $99 $99 $9A $9A
.db $9B $9C $9C $9D $9D $9E $9E $9F $A0 $A0 $A1 $A1 $A2 $A2 $A3 $A3
.db $A4 ; unused?

; 1st entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 4082 to 408A (9 bytes)
_DATA_4082_:
.db $AC $AC $AC $AC $A0 $AC $AC $AC $AC

; 2nd entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 408B to 4093 (9 bytes)
_DATA_408B_:
.db $A0 $AC $A0 $AC $A1 $AC $A0 $AC $A0

; 3rd entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 4094 to 409C (9 bytes)
_DATA_4094_:
.db $A1 $A0 $A1 $A0 $A2 $A0 $A1 $A0 $A1

; 4th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 409D to 40A5 (9 bytes)
_DATA_409D_:
.db $A2 $A1 $A2 $A1 $A3 $A1 $A2 $A1 $A2

; 5th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40A6 to 40AE (9 bytes)
_DATA_40A6_:
.db $A3 $A2 $A3 $A2 $A0 $A2 $A3 $A2 $A3

; 6th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40AF to 40B7 (9 bytes)
_DATA_40AF_:
.db $AC $A3 $AC $A3 $A1 $A3 $AC $A3 $AC

; 7th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40B8 to 40C0 (9 bytes)
_DATA_40B8_:
.db $AC $AC $AC $AC $A2 $AC $AC $AC $AC

; 8th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40C1 to 40C9 (9 bytes)
_DATA_40C1_:
.db $AC $AC $AC $AC $A3 $AC $AC $AC $AC

; 9th entry of Pointer Table from 40D3 (indexed by _RAM_DE88_)
; Data from 40CA to 40D2 (9 bytes)
_DATA_40CA_:
.db $AC $AC $AC $AC $AC $AC $AC $AC $AC

; Pointer Table from 40D3 to 40E4 (9 entries, indexed by _RAM_DE88_)
_DATA_40D3_:
.dw _DATA_4082_ _DATA_408B_ _DATA_4094_ _DATA_409D_ _DATA_40A6_ _DATA_40AF_ _DATA_40B8_ _DATA_40C1_
.dw _DATA_40CA_

; Data from 40E5 to 40F4 (16 bytes)
_DATA_40E5_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $01 $01 $01 $01 $01 $01

; Data from 40F5 to 4104 (16 bytes)
_DATA_40F5_:
.db $01 $01 $01 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $01 $01

; Data from 4105 to 4224 (288 bytes)
_DATA_4105_: ; 32 bytes per track type, not sure what it does, copied to $da00
.db $08 $0B $0D $0E $0F $0E $0D $0B $08 $05 $03 $02 $02 $02 $03 $05
.db $02 $03 $04 $05 $08 $0B $0C $0D $0F $0D $0C $0B $08 $05 $04 $03

.db $09 $0A $0A $0B $0C $0B $0A $0A $09 $08 $07 $06 $05 $06 $07 $08
.db $05 $06 $06 $06 $09 $0B $0B $0B $0C $0B $0B $0B $09 $06 $06 $06

.db $09 $0B $0C $0D $0D $0D $0C $0B $09 $07 $05 $04 $04 $04 $05 $07
.db $04 $04 $06 $08 $09 $0A $0B $0C $0D $0C $0B $0A $09 $08 $06 $04

.db $09 $0B $0B $0C $0D $0C $0B $0B $09 $07 $05 $04 $03 $04 $05 $07
.db $03 $03 $05 $07 $09 $0A $0B $0D $0D $0D $0B $0A $09 $07 $05 $03

.db $08 $05 $04 $03 $04 $03 $04 $05 $08 $0B $0C $0D $0C $0D $0C $0B
.db $0C $0D $0C $0B $08 $05 $04 $03 $04 $03 $04 $05 $08 $0B $0C $0D

.db $09 $0A $0A $0B $0C $0B $0A $0A $09 $07 $06 $05 $05 $05 $06 $07
.db $05 $05 $06 $07 $08 $09 $0A $0B $0C $0B $0A $09 $08 $07 $06 $05

.db $09 $08 $09 $07 $08 $07 $09 $09 $09 $09 $09 $0B $0A $0B $09 $0A
.db $0A $0A $0A $0A $09 $08 $08 $08 $08 $08 $08 $08 $09 $0A $0A $0A

.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

.db $03 $05 $06 $06 $07 $06 $06 $05 $03 $02 $01 $01 $00 $01 $01 $02
.db $05 $06 $06 $07 $08 $0A $0B $0B $0C $0B $0B $0A $08 $07 $06 $06

; Data from 4225 to 4424 (512 bytes)
_DATA_4225_TrackMetatileLookup: ; indexes into "tile index data pointer table", for the 64 metatiles per track type
.db $00 $01 $06 $0D $15 $16 $20 $23 $2A $2F $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $24 $25 $26 $27 $28 $29 $02 $03 $04 $07 $08 $09 $0A $0B $0C $0E $0F $10 $11 $17 $18 $19 $1A $1B $1C $1D $1E $1F $12 $13 $14 $21 $22 $05 $2B $00 $2C $00 $00
.db $00 $0F $12 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $10 $27 $28 $29 $2A $2B $2C $2D $2E $1E $1F $20 $21 $11 $2F $32 $33 $13 $30 $31 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $22 $23 $24 $25 $26 $34 $14 $15 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $01 $16 $17 $2A $32 $18 $19 $1A $1C $20 $21 $22 $23 $25 $24 $26 $27 $28 $29 $2B $01 $01 $01 $0E $12 $2D $2E $2F $30 $31 $2C $1D $1B $1E $1F $01 $08 $0D $01 $00 $00 $00 $00
.db $00 $01 $18 $19 $33 $34 $35 $36 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $3E $3F $37 $38 $39 $32 $03 $04 $05 $06 $2B $2C $2D $2E $2F $24 $25 $23 $29 $02 $3A $3B $3C $3D $26 $28 $27 $1B $1C $1D $1E $1F $20 $22 $21 $30 $31 $1A $17 $2A
.db $00 $01 $02 $03 $04 $05 $06 $14 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F $20 $21 $22 $23 $24 $25 $26 $27 $15 $28 $2A $2B $2C $2D $2E $2F $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $3F $1A
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $19 $1C $1D $1E $1F $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $18 $2D $18 $18 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $02 $03 $06 $07 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $01 $04 $05 $08 $09 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $33 $34 $35 $17 $1F $36 $22 $29 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $01 $03 $04 $06 $07 $19 $1A $31 $32 $18 $16 $34 $35 $37 $1D $20 $1E $1F $05 $0D $0E $0F $10 $11 $12 $13 $14 $15 $33 $02 $0B $0C $38 $39 $3A $17 $36 $1B $1C $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $08 $09 $0A $00 $00 $00 $00 $00

; Data from 4425 to 4464 (64 bytes)
_DATA_4425_:
.db $FF $FE $0C $04 $06 $06 $08 $0A $0A $00 $0E $0E $02 $02 $FE $0C
.db $04 $FE $FE $FE $00 $08 $00 $FF $FF $FE $FF $FF $FE $FE $0C $FF
.db $04 $0C $FF $FF $FF $FF $FE $FE $FE $FE $FE $FF $00 $FE $08 $FE
.db $0C $04 $FE $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF

_LABEL_4465_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, _LABEL_44C2_
  ld a, (_RAM_DE4F_)
  cp $80
  jr nz, _LABEL_44C2_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_44C2_
  ld a, (_RAM_DE7D_)
  and $3F
  jr z, _LABEL_44C2_
  cp $3C
  jr z, _LABEL_44C2_
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
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld e, a
  ld d, $00
  ld hl, _DATA_4425_
  add hl, de
  ld a, (hl)
  cp $FE
  jr z, _LABEL_44C2_
  cp $FF
  jr z, _LABEL_44C2_
  ld (_RAM_DF7A_), a
_LABEL_44C2_:
  ret

_LABEL_44C3_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, +
  ld a, (_RAM_DF7B_)
  or a
  jr nz, ++
+:
  ret

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
  call _LABEL_4595_
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

; Data from 4534 to 4534 (1 bytes)
.db $C9 ; ret

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

; Data from 4562 to 4562 (1 bytes)
.db $C9 ; ret

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF85_)
  ld (_RAM_DEB2_), a
  jp +++

; Data from 4570 to 4570 (1 bytes)
.db $C9 ; ret

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF83_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  jp +++

; Data from 4583 to 4583 (1 bytes)
.db $C9 ; ret

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  jp +++

; Data from 458C to 458C (1 bytes)
.db $C9 ; ret

+++:
  ld a, (_RAM_DEB2_)
  or a
  jr nz, +
  ret

+:
  ret

_LABEL_4595_:
  ld hl, _DATA_1D65_
  ld a, (_RAM_DF7B_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_DF7B_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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

_LABEL_4622_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jp nz, _LABEL_46C8_
  ld a, (_RAM_DF58_)
  or a
  jp nz, _LABEL_46C8_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jp nz, _LABEL_46C8_
  ld a, (_RAM_DE7D_)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, _LABEL_4682_
  cp $32
  jr z, _LABEL_4682_
  ld hl, (_RAM_DBA0_)
  ld de, (_RAM_DE79_)
  add hl, de
  ld a, l
  cp $10
  jr z, +
  cp $11
  jr nz, _LABEL_46C8_
+:
  ld hl, (_RAM_DBA2_)
  ld de, (_RAM_DE7B_)
  add hl, de
  ld a, l
  cp $1D
  jr z, +
  cp $1F
  jr nz, _LABEL_46C8_
  ld a, $01
  ld (_RAM_DEB5_), a
  ld a, $61
  call _LABEL_473F_
  jp ++

+:
  ld a, $01
  ld (_RAM_DEB5_), a
  ld a, $21
  call _LABEL_473F_
  jp ++

_LABEL_4682_:
  ld a, $01
  ld (_RAM_DEB5_), a
  call _LABEL_470C_
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

_LABEL_46C8_:
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

_LABEL_470C_:
  ld a, (_RAM_DE7D_)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, +
  ld bc, $B161
  jp ++

+:
  ld bc, $B0D1
++:
  ld hl, _DATA_2652_TimesTable12Lo
  ld de, (_RAM_DE77_)
  add hl, de
  ld a, (hl)
  ld l, a
  ld h, $00
  ld de, (_RAM_DE75_)
  add hl, de
  add hl, bc
  ld a, $0D ; ??? relates to value in _RAM_DE75_
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
_LABEL_473F_:
  ld b, a
  cp $FF
  jr z, _LABEL_4793_
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

_LABEL_4793_:
  xor a
  ld (_RAM_DF82_), a
  ld (_RAM_DF83_), a
  jp _LABEL_29A3_

_LABEL_479D_:
  ret

_LABEL_479E_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, _LABEL_479D_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DD1A_)
  or a
  jr nz, _LABEL_479D_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_479D_
  ld ix, _RAM_DCEC_
  jp ++

+:
  ld ix, _RAM_DCAB_
  call ++
  ld ix, _RAM_DCEC_
  call ++
  ld ix, _RAM_DD2D_
++:
  ld a, (ix+10)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, ++
  cp $32
  jr z, ++
  ld a, (ix+4)
  cp $10
  jr z, +
  cp $11
  jr nz, _LABEL_479D_
+:
  ld a, (ix+5)
  cp $1D
  jr z, +
  cp $1F
  jr nz, _LABEL_479D_
  ld a, $61
  jp +++

+:
  ld a, $21
  jp +++

++:
  ld a, (ix+10)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  cp $2A
  jr z, +
  ld bc, $B161
  jp ++

+:
  ld bc, $B0D1
++:
  ld hl, _DATA_2652_TimesTable12Lo
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
  ld a, $0D
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
+++:
  ld b, a
  cp $FF
  jp z, _LABEL_48BF_
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
  jr nz, ++
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
++:
  ret

_LABEL_48BF_:
  jp _LABEL_4DD4_

_LABEL_48C2_:
  CallPagedFunction2 _LABEL_23BF1_
  ret

_LABEL_48D1_:
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

_LABEL_48FC_:
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

_LABEL_4927_:
  ld ix, _RAM_DCAB_
  call +
  ld ix, _RAM_DCEC_
  call +
  ld ix, _RAM_DD2D_
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
  jr nc, _LABEL_49BF_
  jp ++

+:
  cp $FF
  jr nz, _LABEL_49BF_
  ld a, l
  cp $FD
  jr c, _LABEL_49BF_
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
  jp _LABEL_49BF_

+:
  ld a, l
  cp $E8
  jr nc, _LABEL_49BF_
-:
  ret

++:
  cp $FF
  jr nz, _LABEL_49BF_
  ld a, l
  cp $E8
  jr nc, -
_LABEL_49BF_:
  ld a, $E4
  ld (ix+18), a
  xor a
  ld (ix+21), a
  ret

_LABEL_49C9_:
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
  call _LABEL_6677_
  JumpToPagedFunction _LABEL_1BDF3_

; Data from 49FA to 4DA9 (944 bytes)
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01
.db $01 $01 $01 $01 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $01 $00 $00 $00 $00 $00 $01 $00 $00 $01
.db $00 $00 $01 $00 $00 $01 $00 $00 $01 $00 $01 $00 $01 $00 $00 $00
.db $00 $00 $00 $00 $01 $00 $00 $01 $00 $00 $01 $01 $00 $01 $01 $00
.db $01 $01 $01 $01 $01 $00 $01 $01 $01 $01 $01 $01 $00 $00 $00 $00
.db $00 $00 $01 $00 $01 $00 $01 $00 $01 $01 $01 $01 $01 $01 $02 $01
.db $01 $02 $01 $01 $02 $02 $01 $02 $01 $01 $00 $00 $00 $00 $00 $00
.db $01 $01 $00 $01 $01 $00 $02 $01 $01 $02 $01 $01 $02 $02 $01 $02
.db $02 $01 $02 $02 $02 $02 $02 $02 $00 $00 $00 $00 $00 $00 $01 $01
.db $01 $01 $01 $00 $02 $02 $01 $02 $02 $01 $03 $02 $02 $02 $02 $02
.db $03 $02 $03 $02 $03 $02 $00 $00 $00 $00 $00 $00 $01 $01 $01 $01
.db $01 $01 $02 $02 $02 $02 $02 $02 $03 $02 $03 $02 $03 $02 $03 $03
.db $03 $03 $03 $03 $00 $00 $00 $00 $00 $00 $02 $01 $01 $01 $01 $01
.db $03 $02 $02 $03 $02 $02 $03 $03 $03 $03 $03 $03 $04 $03 $04 $03
.db $04 $03 $00 $00 $00 $00 $00 $00 $02 $01 $01 $02 $01 $01 $03 $03
.db $02 $03 $03 $02 $04 $03 $03 $04 $03 $03 $04 $04 $04 $04 $04 $04
.db $00 $00 $00 $00 $00 $00 $02 $01 $02 $01 $02 $01 $03 $03 $03 $03
.db $03 $03 $04 $04 $04 $04 $04 $03 $05 $04 $05 $04 $05 $04 $00 $00
.db $00 $00 $00 $00 $02 $02 $01 $02 $02 $01 $04 $03 $03 $04 $03 $03
.db $05 $04 $04 $04 $04 $04 $05 $05 $05 $05 $05 $05 $00 $00 $00 $00
.db $00 $00 $02 $02 $02 $02 $02 $01 $04 $04 $03 $04 $04 $03 $05 $05
.db $04 $05 $05 $04 $06 $05 $06 $05 $06 $05 $00 $00 $00 $00 $00 $00
.db $02 $02 $02 $02 $02 $02 $04 $04 $04 $04 $04 $04 $05 $05 $05 $05
.db $05 $05 $06 $06 $06 $06 $06 $06 $00 $00 $00 $00 $00 $00 $03 $02
.db $02 $02 $02 $02 $05 $04 $04 $05 $04 $04 $06 $05 $06 $05 $06 $05
.db $07 $06 $07 $06 $07 $06 $00 $00 $00 $00 $00 $00 $03 $02 $02 $03
.db $02 $02 $05 $05 $04 $05 $05 $04 $06 $06 $06 $06 $06 $05 $07 $07
.db $07 $07 $07 $07 $00 $00 $00 $00 $00 $00 $03 $02 $03 $02 $03 $02
.db $05 $05 $05 $05 $05 $05 $07 $06 $06 $07 $06 $06 $08 $07 $08 $07
.db $08 $07 $00 $00 $00 $00 $00 $00 $03 $03 $02 $03 $03 $02 $06 $05
.db $05 $06 $05 $05 $07 $07 $06 $07 $07 $06 $08 $08 $08 $08 $08 $08

_LABEL_4DAA_:
  ld a, (ix+20)
  or a
  jp nz, _LABEL_5A87_
  ld hl, _DATA_24AE_
  ld d, $00
  ld a, (ix+11)
  ld e, a
  add hl, de
  ld a, (hl)
  ld (ix+36), a
  ld hl, _DATA_24BE_
  add hl, de
  ld a, (hl)
  ld (ix+37), a
  cp $82
  jp z, _LABEL_5A87_
  ld a, $01
  ld (ix+38), a
  jp _LABEL_5A77_

_LABEL_4DD4_:
  ld a, (ix+20)
  or a
  ret nz
  ld a, (ix+45)
  or a
  jr z, +
  cp $01
  jr z, ++
  jp _LABEL_4EFA_

+:
  ld a, (_RAM_DCD9_)
  or a
  jr nz, +
  ld a, $03
  ld (_RAM_DF5A_), a
  ld a, $01
  ld (_RAM_DCD9_), a
  xor a
  ld (ix+11), a
  ld (ix+20), a
  ld (_RAM_DE67_), a
  ld (_RAM_DE31_), a
  ld (_RAM_DE32_), a
+:
  ret

++:
  ld a, (_RAM_D5B0_)
  or a
  jr nz, _LABEL_4E7A_
  ld a, (_RAM_DD1A_)
  or a
  jr nz, _LABEL_4E7A_
  ld a, (_RAM_D5BE_)
  or a
  jr nz, +
  ld a, $0E
  ld (_RAM_D974_SFXTrigger), a
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
_LABEL_4E49_:
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
  jr z, _LABEL_4EA0_
_LABEL_4E7A_:
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

_LABEL_4EA0_:
  ld a, (_RAM_DF5B_)
  cp $03
  jr z, -
  cp $04
  jr z, -
_LABEL_4EAB_:
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

_LABEL_4EFA_:
  ld a, (_RAM_DD5B_)
  or a
  jr nz, +
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
+:
  ret

_LABEL_4F1B_:
  ld hl, (_RAM_DED1_)
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
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
  call _LABEL_19CE_
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

_LABEL_4F8F_:
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
  jr z, _LABEL_4FA7_
  jr c, _LABEL_4FBC_
_LABEL_4FA7_:
  ld a, (_RAM_DF2A_)
  sub $01
  ld (_RAM_DF2A_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DCC4_)
  cp l
  jr z, _LABEL_4FBC_
  jr nc, _LABEL_4FA7_
_LABEL_4FBC_:
  ld a, (_RAM_DF2B_)
  sub $01
  ld (_RAM_DF2B_), a
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
  jr z, _LABEL_4FA7_
  jr nc, _LABEL_4FBC_
  jp _LABEL_4FA7_

_LABEL_4FDE_:
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
  jr z, _LABEL_4FF6_
  jr c, _LABEL_500B_
_LABEL_4FF6_:
  ld a, (_RAM_DF2A_)
  sub $01
  ld (_RAM_DF2A_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr z, _LABEL_500B_
  jr nc, _LABEL_4FF6_
_LABEL_500B_:
  ld a, (_RAM_DF2C_)
  sub $01
  ld (_RAM_DF2C_), a
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
  jr z, _LABEL_4FF6_
  jr nc, _LABEL_500B_
  jp _LABEL_4FF6_

_LABEL_502D_:
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
  jr z, _LABEL_5045_
  jr c, _LABEL_505A_
_LABEL_5045_:
  ld a, (_RAM_DF2A_)
  sub $01
  ld (_RAM_DF2A_), a
  ret

+:
  ld a, (_RAM_DF24_LapsRemaining)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, _LABEL_505A_
  jr nc, _LABEL_5045_
_LABEL_505A_:
  ld a, (_RAM_DF2D_)
  sub $01
  ld (_RAM_DF2D_), a
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
  jr z, _LABEL_5045_
  jr nc, _LABEL_505A_
  jp _LABEL_5045_

_LABEL_507C_:
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
  jr z, _LABEL_5094_
  jr c, _LABEL_50A9_
_LABEL_5094_:
  ld a, (_RAM_DF2B_)
  sub $01
  ld (_RAM_DF2B_), a
  ret

+:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD05_)
  cp l
  jr z, _LABEL_50A9_
  jr nc, _LABEL_5094_
_LABEL_50A9_:
  ld a, (_RAM_DF2C_)
  sub $01
  ld (_RAM_DF2C_), a
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
  jr z, _LABEL_5094_
  jr nc, _LABEL_50A9_
  jp _LABEL_5094_

_LABEL_50CB_:
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
  jr z, _LABEL_50E3_
  jr c, _LABEL_50F8_
_LABEL_50E3_:
  ld a, (_RAM_DF2B_)
  sub $01
  ld (_RAM_DF2B_), a
  ret

+:
  ld a, (_RAM_DCC4_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, _LABEL_50F8_
  jr nc, _LABEL_50E3_
_LABEL_50F8_:
  ld a, (_RAM_DF2D_)
  sub $01
  ld (_RAM_DF2D_), a
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
  jr z, _LABEL_50E3_
  jr nc, _LABEL_50F8_
  jp _LABEL_50E3_

_LABEL_511A_:
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
  jr z, _LABEL_5132_
  jr c, _LABEL_5147_
_LABEL_5132_:
  ld a, (_RAM_DF2C_)
  sub $01
  ld (_RAM_DF2C_), a
  ret

+:
  ld a, (_RAM_DD05_)
  ld l, a
  ld a, (_RAM_DD46_)
  cp l
  jr z, _LABEL_5147_
  jr nc, _LABEL_5132_
_LABEL_5147_:
  ld a, (_RAM_DF2D_)
  sub $01
  ld (_RAM_DF2D_), a
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
  jr z, _LABEL_5132_
  jr nc, _LABEL_5147_
  jp _LABEL_5132_

_LABEL_5169_GameVBlankEngineUpdateTrampoline:
  JumpToPagedFunction _LABEL_37292_GameVBlankEngineUpdate

_LABEL_5174_GameVBlankPart3Trampoline:
  JumpToPagedFunction _LABEL_3730C_GameVBlankPart3

_LABEL_517F_NMI_SMS:
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

_LABEL_519D_:
  JumpToPagedFunction _LABEL_23C68_

_LABEL_51A8_:
  JumpToPagedFunction _LABEL_23DB6_

_LABEL_51B3_:
  ld a, (_RAM_D5DF_)
  or a
  ret nz
  ld ix, _RAM_DCEC_
  ld l, (ix+0)
  ld h, (ix+1)
  ld (_RAM_D59F_), hl
  ld l, (ix+2)
  ld h, (ix+3)
  ld (_RAM_D5A1_), hl
  ret

_LABEL_51CF_:
  JumpToPagedFunction _LABEL_3779F_

_LABEL_51DA_:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr nz, +
  ld ix, _RAM_DCEC_
  ld a, (ix+12)
  ld (_RAM_DE56_), a
  ld a, $01
  ld (_RAM_D59E_), a
  call _LABEL_5304_
  call _LABEL_5764_
  call _LABEL_5451_
  call _LABEL_5872_
  ret

+:
  xor a
  ld (_RAM_DC3D_IsHeadToHead), a
  ld ix, _RAM_DCEC_
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
  ld a, $01
  ld (_RAM_D59E_), a
  call _LABEL_5304_
  call _LABEL_5769_
  call _LABEL_5451_
  ld a, $01
  ld (_RAM_DC3D_IsHeadToHead), a
  call _LABEL_5872_
  ld a, $01
  ld (_RAM_DC3D_IsHeadToHead), a
  ret

_LABEL_522C_:
  ld a, (_RAM_DB99_AccelerationDelay)
  dec a
  ld (ix+19), a
  ld a, (_RAM_DB9A_DecelerationDelay)
  dec a
  ld (ix+61), a
  ret

_LABEL_523B_:
  xor a
  ld (_RAM_D59E_), a
  ld a, (_RAM_DE4F_)
  cp $80
  jr z, _LABEL_52B7_
  inc a
  ld (_RAM_DE4F_), a
  and $0F
  jr nz, +
  ld a, (_RAM_DE50_)
  xor $01
  ld (_RAM_DE50_), a
+:
  call _LABEL_1C98_
  ld a, (_RAM_DBB1_)
  ld (_RAM_DBB9_), a
  ld a, (_RAM_DBB3_)
  ld (_RAM_DBBA_), a
  ld a, (_RAM_DBB5_)
  ld (_RAM_DBBB_), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, _LABEL_5298_
  ld a, (_RAM_DE4F_)
  cp $2C
  jr nc, _LABEL_5297_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, _LABEL_5283_
  ld a, $01
  call +
_LABEL_5283_:
  ld a, (_RAM_DE4F_)
  cp $16
  jr nc, _LABEL_5297_
  ld a, $01
  ld (_RAM_DEB9_), a
  inc a
  ld (_RAM_DEAF_), a
  xor a
  ld (_RAM_DEB0_), a
_LABEL_5297_:
  ret

_LABEL_5298_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  dec a
  jr nz, _LABEL_5297_
  ld a, (_RAM_DE4F_)
  cp $08
  jr nc, _LABEL_5297_
  call _LABEL_5283_
  ld a, $01
  ld (_RAM_DEB0_), a
+:
  ld (_RAM_DEB8_), a
  ld (_RAM_DEB1_VScrollDelta), a
  ld (_RAM_DEB2_), a
  ret

_LABEL_52B7_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  dec a
  jp z, _LABEL_51DA_
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, _LABEL_5298_
  ld a, (_RAM_D5CA_)
  inc a
  and $03
  ld (_RAM_D5CA_), a
  ld ix, _RAM_DCAB_
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
  call _LABEL_5304_
  ld ix, _RAM_DCEC_
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
  call _LABEL_5304_
  ld ix, _RAM_DD2D_
  ld a, (ix+13)
  ld (_RAM_DE56_), a
  ld a, (ix+11)
  ld (_RAM_DE57_), a
_LABEL_5304_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DC3F_GameMode)
  or a
  jp z, _LABEL_536C_
  ld a, (_RAM_DD1A_)
  or a
  jp nz, _LABEL_522C_
  jp _LABEL_536C_

+:
  ld a, (_RAM_DD1A_)
  or a
  jp nz, _LABEL_522C_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_536C_
  ld a, (_RAM_DF7F_)
  or a
  jr nz, _LABEL_536C_
  ld a, (_RAM_DF6A_)
  or a
  jr nz, _LABEL_536C_
  ld b, $07
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_2_MASK ; $20
  jr nz, _LABEL_536C_
  ld a, (_RAM_DB21_Player2Controls)
  and BUTTON_1_MASK ; $10
  jr z, _LABEL_536C_
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
  ld hl, _DATA_250E_
  add hl, de
  ld a, (hl)
  ld (_RAM_DE56_), a
  ret

_LABEL_536C_:
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
_LABEL_537F_:
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
  jp c, _LABEL_544A_
  ld (ix+61), $00
  ld a, (ix+11)
  or a
  jp z, _LABEL_544A_
  ld a, (ix+20)
  or a
  jp nz, _LABEL_544A_
  dec (ix+11)
  jp _LABEL_544A_

+++:
  ld l, (ix+47)
  ld h, (ix+48)
  ld a, (hl)
  or a
  jr z, +
  ld b, $07
  jp ++++

+:
  ld a, (_RAM_DC3F_GameMode)
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
  jp nz, _LABEL_522C_
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
  jr nz, _LABEL_537F_
  ld a, (_RAM_DB99_AccelerationDelay)
  dec a
  ld (ix+19), a
  jp _LABEL_544A_

++:
  ld a, (_RAM_DB9A_DecelerationDelay)
  dec a
  ld (ix+61), a
  ld a, (ix+19)
  inc a
  ld (ix+19), a
  cp b
  jr c, _LABEL_544A_
  ld (ix+19), $00
  ld a, (_RAM_D5D0_)
  or a
  jr z, +
  ld l, a
  ld a, (ix+49)
  sub l
  ld l, a
  ld a, (ix+11)
  cp l
  jr z, _LABEL_544A_
  jr c, +++
  jr ++

+:
  ld l, (ix+11)
  ld a, (ix+49)
  cp l
  jr z, _LABEL_544A_
  jr nc, +++
++:
  ld a, (ix+20)
  or a
  jr nz, _LABEL_544A_
  dec (ix+11)
  jp _LABEL_544A_

+++:
  ld a, (ix+20)
  or a
  jr nz, _LABEL_544A_
  inc (ix+11)
_LABEL_544A_:
  ld a, (_RAM_D59E_)
  or a
  jr z, _LABEL_5451_
  ret

_LABEL_5451_:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (ix+45)
  ld l, a
  ld a, (_RAM_D5CA_)
  cp l
  jp nz, _LABEL_56C0_
+:
  ld l, (ix+0)
  ld h, (ix+1)
  ld de, $000C
  add hl, de
  ld (_RAM_DF20_), hl
  call _LABEL_7A58_
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
  call _LABEL_7A58_
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
  ld a, (_RAM_DB9C_)
  ld (_RAM_DEF4_), a
  call _LABEL_30EA_
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
  ld hl, _DATA_254E_TimesTable18Lo
  ld a, (ix+10)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld c, (hl)
  ld hl, _DATA_258F_TimesTable18Hi
  add hl, de
  ld d, (hl)
  ld e, c
  ld hl, _RAM_C800_WallData
  add hl, de
  ld b, h
  ld c, l
  ld hl, _DATA_2652_TimesTable12Lo
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
  ld de, _DATA_16A38_DivideBy8
  add hl, de
  ld a, :_DATA_16A38_DivideBy8
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
  ld de, _DATA_169A8_IndexToBitmask
  add hl, de
  ld a, :_DATA_169A8_IndexToBitmask
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
  cp TT_Powerboats
  jr nz, +
  ld a, (_RAM_DCF6_)
  and $3F
  jr z, ++
  cp $1A
  jr z, ++
+:
  ld a, (_RAM_DE70_)
  and b
  jp z, _LABEL_5608_
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
  jr z, _LABEL_55FA_
  ld a, (_RAM_DB97_TrackType)
  cp TT_FourByFour
  jr nz, +
  ld a, :_DATA_37232_
  ld (PAGING_REGISTER), a
  ld hl, _DATA_37232_
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
  jr nz, _LABEL_5608_
+:
  ld a, (_RAM_D5A5_)
  or a
  jr nz, +
  ld a, $03
  ld (_RAM_D974_SFXTrigger), a
+:
  ld hl, 1000 ; $03E8
  ld (_RAM_D96C_), hl
  call _LABEL_51CF_
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
  jp _LABEL_5608_

_LABEL_55FA_:
  ld a, (ix+12)
  cp (ix+13)
  ld a, $00
  jr nz, +
  inc a
+:
  ld (ix+11), a
_LABEL_5608_:
  ld hl, _DATA_25D0_
  ld a, (ix+10)
  and $3F
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld c, a
  ld d, $00
  ld hl, _DATA_2611_
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
  ld a, :_DATA_1B1A2_
  ld (PAGING_REGISTER), a
  ld de, _DATA_1B1A2_
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
  jp z, _LABEL_575D_
+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, +
  ld a, (ix+10)
  and $3F
  cp $23
  jr nz, +
  ld a, $08
  ld (ix+12), a
  jp _LABEL_56C0_

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
  ld hl, _DATA_1DA7_
  add hl, bc
  jp ++

+:
  ld hl, _DATA_1D87_
++:
  add hl, de
  ld a, (hl)
  ld (ix+12), a
  ld a, (_RAM_DE53_)
  and $40
  jr z, _LABEL_56C0_
  ld hl, _DATA_1D97_
  ld d, $00
  ld e, (ix+12)
  add hl, de
  ld a, (hl)
  ld (ix+12), a
_LABEL_56C0_:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jp nz, _LABEL_5764_
  ld a, (_RAM_D5D9_)
  or a
  jp nz, _LABEL_5764_
+:
  ld a, (ix+46)
  or a
  jp nz, _LABEL_586B_
  ld a, (ix+51)
  or a
  jr z, +
  ld a, (ix+20)
  or a
  jr nz, _LABEL_5764_
+:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jr z, +
  cp TT_FormulaOne
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
  jr z, _LABEL_5764_
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
  jr nc, _LABEL_573C_
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
  jr nz, _LABEL_5764_
  ld a, b
  ld (ix+13), a
  jp _LABEL_5764_

_LABEL_573C_:
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
  jr c, _LABEL_573C_
  jp --

_LABEL_575D_:
  ld a, (_RAM_D59E_)
  or a
  jr z, _LABEL_5764_
  ret

_LABEL_5764_:
  ld a, (_RAM_DC3F_GameMode)
  or a
  ret nz
_LABEL_5769_:
  ld a, (_RAM_D5A5_)
  or a
  jr nz, +++
  ld a, (ix+46)
  or a
  jp nz, _LABEL_586B_
  ld l, (ix+11)
  ld a, (_RAM_DB98_TopSpeed)
  cp l
  jr nz, +
  jp ++

+:
  ld a, (_RAM_DF00_)
  or a
  jr nz, ++
++:
  call _LABEL_EE6_
+++:
  ld hl, _DATA_1D65_
  ld a, (_RAM_DE57_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_DE57_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  push de
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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
  jp _LABEL_586B_

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
_LABEL_586B_:
  ld a, (_RAM_D59E_)
  or a
  jr z, _LABEL_5872_
  ret

_LABEL_5872_:
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
  ld hl, _DATA_242E_BehaviourLookup
  add hl, de ; look up behaviour
  ld a, $0F
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
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
  jr nz, _LABEL_5902_
  ld a, (ix+29)
  or a
  jp z, _LABEL_594E_
  cp $06
  jp z, _LABEL_4DAA_
  cp $04
  jp z, _LABEL_59EF_
  cp $03
  jp z, _LABEL_59A4_
  cp $0A
  jp z, _LABEL_5983_
  cp $0B
  jp z, _LABEL_59BC_
  cp $0D
  jp z, _LABEL_5979_
  cp $01
  jp z, _LABEL_4DD4_
  cp $02
  jr z, +
  cp $05
  jr z, ++
  cp $12
  jp z, _LABEL_79C8_
  cp $08
  jp z, _LABEL_1CF4_
  cp $09
  jp z, _LABEL_5B9A_
  cp $13
  jp z, _LABEL_5E25_
_LABEL_5902_:
  ret

+:
  ld a, (ix+11)
  cp $07
  jr c, +
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
+:
  ret

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
  cp TT_TurboWheels
  jr z, +++
  cp TT_RuffTrux
  jr z, +++
  cp TT_Warriors
  jr nz, +
  ld a, $08
  jr ++

+:
  ld a, $10
++:
  ld (_RAM_D5B7_), a
+++:
  ret

_LABEL_594E_:
  ld a, (ix+20)
  or a
  jr nz, _LABEL_5978_
  ld a, (ix+30)
  cp $04
  jr z, +
  cp $0B
  jr z, +
  cp $0D
  jr z, +
  cp $03
  jr nz, _LABEL_5978_
+:
  ld a, $1C
  ld (ix+36), a
  ld a, $08
  ld (ix+37), a
  xor a
  ld (ix+38), a
  jp _LABEL_5A77_

_LABEL_5978_:
  ret

_LABEL_5979_:
  ld a, (ix+30)
  cp $0D
  jr z, _LABEL_5978_
  jp _LABEL_4DAA_

_LABEL_5983_:
  ld a, (ix+20)
  or a
  jr nz, +
  ld a, (ix+30)
  cp $0B
  jr z, ++
+:
  jp _LABEL_59DC_

++:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  jp _LABEL_4DD4_

+:
  jp _LABEL_2961_

_LABEL_59A4_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DD0A_)
  cp $07
  jr z, +
  ld a, (_RAM_DD0B_)
  or a
  jr z, _LABEL_59FC_
  cp $06
  jr z, _LABEL_59FC_
+:
  ret

_LABEL_59BC_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld a, (_RAM_DB97_TrackType)
  cp TT_FourByFour
  jr nz, +
  ld a, (_RAM_DD0A_)
  or a
  jp z, _LABEL_59FC_
  cp $06
  jp z, _LABEL_59FC_
+:
  ret

++:
  ld a, (_RAM_DB97_TrackType)
  cp TT_FormulaOne
  ret nz
_LABEL_59DC_:
  ld a, (ix+10)
  and $3F
  cp $1A
  ret z
  JumpToPagedFunction _LABEL_1BF17_

_LABEL_59EF_:
  ld a, (ix+30)
  cp $07
  jr z, _LABEL_5A39_
  ld a, (ix+31)
  or a
  jr nz, +
_LABEL_59FC_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $03
  ld (_RAM_D974_SFXTrigger), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D96C_), hl
  call _LABEL_51CF_
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
+:
  ret

_LABEL_5A39_:
  ld a, (ix+20)
  or a
  jr nz, _LABEL_5A87_
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, _DATA_24EE_
  jp ++

+:
  ld hl, _DATA_24CE_
++:
  ld a, (_RAM_D5D0_)
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
  ld hl, _DATA_24FE_
  jp ++

+:
  ld hl, _DATA_24DE_
++:
  add hl, de
  ld a, (hl)
  ld (ix+37), a
  ld a, $02
  ld (ix+38), a
_LABEL_5A77_:
  ld a, $01
  ld (ix+20), a
  ld a, (ix+21)
  or a
  jr z, _LABEL_5A87_
  ld a, $02
  ld (_RAM_D974_SFXTrigger), a
_LABEL_5A87_:
  ret

_LABEL_5A88_:
  ld ix, _RAM_DCAB_
  call +
  ld ix, _RAM_DCEC_
  call +
  ld ix, _RAM_DD2D_
+:
  ld d, $00
  ld a, (ix+20)
  or a
  jp z, _LABEL_5B77_
  ld hl, _DATA_1B232_
  ld e, a
  add hl, de
  ld a, :_DATA_1B232_
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DE8E_PageNumber)
  ld (PAGING_REGISTER), a
  ld a, b
  ld (_RAM_DEF5_), a
  ld a, (ix+36)
  ld (_RAM_DEF4_), a
  call _LABEL_1B94_
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
  call _LABEL_1B94_
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
  jr c, _LABEL_5B77_
  ld a, (ix+21)
  or a
  jr z, +
  ld a, $02
  ld (_RAM_D974_SFXTrigger), a
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
  jr nz, _LABEL_5B77_
  ret

_LABEL_5B77_:
  ret

; Data from 5B78 to 5B7F (8 bytes)
.db $3E $8E $32 $00 $80 $C3 $03 $A0

++:
  ld a, $0A
  ld (ix+36), a
  ld a, $0C
  ld (ix+37), a
  jp _LABEL_5A77_

+++:
  ld a, $20
  ld (ix+36), a
  ld a, $08
  ld (ix+37), a
  jp _LABEL_5A77_

_LABEL_5B9A_:
  ld a, (ix+20)
  or a
  jr z, +
  ret

+:
  ld a, (ix+51)
  or a
  jp nz, _LABEL_5E24_
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jp z, _LABEL_5CFC_
  cp $01
  jp z, _LABEL_5CAF_
  ld a, (ix+59)
  and $10
  jp nz, _LABEL_4DD4_
  ld a, (ix+60)
  or a
  jr z, ++
  cp $01
  jr z, +
  ld a, (ix+10)
  and $3F
  cp $3A
  jp nz, _LABEL_4DD4_
  jp +++

+:
  ld a, (ix+10)
  and $3F
  cp $3A
  jp nz, _LABEL_4DD4_
  jp _LABEL_5C31_

++:
  ld a, (ix+10)
  and $3F
  cp $1D
  jp z, _LABEL_5C70_
  cp $1E
  jp nz, _LABEL_4DD4_
  jp _LABEL_5C70_

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
  jp _LABEL_5D4A_

_LABEL_5C31_:
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
  jp _LABEL_5D4A_

_LABEL_5C70_:
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
  jp _LABEL_5D4A_

_LABEL_5CAF_:
  ld a, (ix+59)
  and $10
  jp nz, _LABEL_4DD4_
  ld a, (ix+10)
  and $3F
  cp $39
  jp nz, _LABEL_4DD4_
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
  jp _LABEL_5D4A_

_LABEL_5CFC_:
  ld a, (ix+59)
  and $10
  jp nz, _LABEL_4DD4_
  ld a, (ix+10)
  and $3F
  cp $34
  jr z, +
  cp $35
  jp nz, _LABEL_4DD4_
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
_LABEL_5D4A_:
  ld a, (ix+46)
  or a
  jp nz, _LABEL_5E24_
  ld a, (ix+45)
  or a
  jr z, _LABEL_5DAD_
  cp $01
  jr z, +
  xor a
  ld (_RAM_DE69_), a
  ld (_RAM_DE38_), a
  ld a, $03
  ld (_RAM_DF5C_), a
  jp _LABEL_5DB9_

+:
  xor a
  ld (_RAM_DE68_), a
  ld (_RAM_DE35_), a
  ld a, $03
  ld (_RAM_DF5B_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, _LABEL_5DB9_
  xor a
  ld (_RAM_DF7D_), a
  ld (_RAM_DF7E_), a
  ld (_RAM_DCFB_), a
  ld (_RAM_DCFC_), a
  ld (_RAM_DB82_), a
  ld (_RAM_DB83_), a
  ld a, $09
  ld (_RAM_D974_SFXTrigger), a
  ld a, (_RAM_DF56_)
  ld b, a
  ld a, (_RAM_DF57_)
  or b
  jp nz, _LABEL_5DB9_
  ld hl, $0110
  ld (_RAM_DF56_), hl
  ld a, $01
  ld (_RAM_D5C6_), a
  jp _LABEL_5DB9_

_LABEL_5DAD_:
  xor a
  ld (_RAM_DE67_), a
  ld (_RAM_DE32_), a
  ld a, $03
  ld (_RAM_DF5A_), a
_LABEL_5DB9_:
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
_LABEL_5E24_:
  ret

_LABEL_5E25_:
  ld a, (_RAM_DCF6_)
  and $3F
  cp $16
  jp z, _LABEL_59FC_
  cp $2A
  jp z, _LABEL_59FC_
  cp $3F
  jp z, _LABEL_59FC_
  ret

_LABEL_5E3A_:
  call _LABEL_51B3_
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, +
  xor a
  ld (_RAM_DCC1_), a
  ld (_RAM_DCC2_), a
  ld (_RAM_DD02_), a
  ld (_RAM_DD03_), a
  ld (_RAM_DD43_), a
  ld (_RAM_DD44_), a
  call _LABEL_5F5E_
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  call ++
  call _LABEL_60AE_
  call _LABEL_619B_
  call _LABEL_629A_
  jp _LABEL_6394_

+:
  ret

++:
  ld ix, _RAM_DCAB_
  ld bc, $0000
  ld a, (_RAM_DCC0_)
  cp $01
  jp nz, _LABEL_5F52_
  ld a, (_RAM_DE8C_)
  or a
  jp nz, _LABEL_5F52_
  ld a, (_RAM_DF58_)
  or a
  jp nz, _LABEL_5F52_
  ld a, (_RAM_DCD9_)
  or a
  jp nz, _LABEL_5F52_
  ld a, (_RAM_DCBD_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, _LABEL_5F52_
  ld a, (_RAM_DCBC_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  jp nc, _LABEL_5F52_
  ld a, $01
  cp b
  jr z, +
  call _LABEL_1B0C_
  jp ++

+:
  call _LABEL_1B2F_
++:
  ld a, $01
  cp c
  jr z, +
  call _LABEL_1B50_
  jp ++

+:
  call _LABEL_1B73_
++:
  call _LABEL_6571_
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
  ld (_RAM_DEB3_), a
++:
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_Warriors
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
  call _LABEL_2934_BehaviourF
  ld ix, _RAM_DCAB_
  call _LABEL_2961_
++:
  xor a
  ld (_RAM_DCB6_), a
  ld (_RAM_DE92_EngineVelocity), a
_LABEL_5F52_:
  ret

+++:
  xor a
  ld (_RAM_DE32_), a
  ld ix, _RAM_DCAB_
  jp _LABEL_2961_

_LABEL_5F5E_:
  ld ix, _RAM_DCEC_
  ld bc, $0000
  ld a, (_RAM_DD01_)
  cp $01
  jp nz, _LABEL_609C_
  ld a, (_RAM_DE8C_)
  or a
  jp nz, _LABEL_609C_
  ld a, (_RAM_DF58_)
  or a
  jp nz, _LABEL_609C_
  ld a, (_RAM_DD1A_)
  or a
  jp nz, _LABEL_609C_
  ld a, (_RAM_DCFE_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, _LABEL_609C_
  ld a, (_RAM_DCFD_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  jp nc, _LABEL_609C_
  ld a, $01
  cp b
  jr z, +
  call _LABEL_1B0C_
  call _LABEL_1AD8_
  jp ++

+:
  call _LABEL_1B2F_
  call _LABEL_1AC8_
++:
  ld a, $01
  cp c
  jr z, +
  call _LABEL_1B50_
  call _LABEL_1AFA_
  jp ++

+:
  call _LABEL_1B73_
  call _LABEL_1AE7_
++:
  call _LABEL_6571_
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
  ld (_RAM_DEB3_), a
+++:
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, _LABEL_609D_
_LABEL_6054_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Warriors
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
  call _LABEL_29BC_Behaviour1_FallToFloor
  call _LABEL_4DD4_
  jp ++

+:
  call _LABEL_2934_BehaviourF
  ld ix, _RAM_DCEC_
  call _LABEL_2961_
++:
  xor a
  ld (_RAM_DCF7_), a
  ld (_RAM_DE92_EngineVelocity), a
_LABEL_609C_:
  ret

_LABEL_609D_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_6054_
  xor a
  ld (_RAM_DE35_), a
  ld ix, _RAM_DCEC_
  jp _LABEL_2961_

_LABEL_60AE_:
  ld ix, _RAM_DD2D_
  ld bc, $0000
  ld a, (_RAM_DD42_)
  cp $01
  jp nz, _LABEL_618F_
  ld a, (_RAM_DE8C_)
  or a
  jp nz, _LABEL_618F_
  ld a, (_RAM_DF58_)
  or a
  jp nz, _LABEL_618F_
  ld a, (_RAM_DD5B_)
  or a
  jp nz, _LABEL_618F_
  ld a, (_RAM_DD3F_)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, _LABEL_618F_
  ld a, (_RAM_DD3E_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  jp nc, _LABEL_618F_
  ld a, $01
  cp b
  jr z, +
  call _LABEL_1B0C_
  jp ++

+:
  call _LABEL_1B2F_
++:
  ld a, $01
  cp c
  jr z, +
  call _LABEL_1B50_
  jp ++

+:
  call _LABEL_1B73_
++:
  call _LABEL_6571_
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
  ld (_RAM_DEB3_), a
++:
  ld a, (_RAM_DC49_Cheat_ExplosiveOpponents)
  or a
  jr nz, +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_Warriors
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
  call _LABEL_2934_BehaviourF
  ld ix, _RAM_DD2D_
  call _LABEL_2961_
++:
  xor a
  ld (_RAM_DD38_), a
  ld (_RAM_DE92_EngineVelocity), a
_LABEL_618F_:
  ret

+++:
  xor a
  ld (_RAM_DE38_), a
  ld ix, _RAM_DD2D_
  jp _LABEL_2961_

_LABEL_619B_:
  ld bc, $0001
  ld a, (_RAM_DCC0_)
  cp $01
  jp nz, _LABEL_6295_
  ld a, (_RAM_DD01_)
  cp $01
  jp nz, _LABEL_6295_
  ld a, (_RAM_DCD9_)
  or a
  jp nz, _LABEL_6295_
  ld a, (_RAM_DD1A_)
  or a
  jp nz, _LABEL_6295_
  ld a, (_RAM_DCBD_)
  ld l, a
  ld a, (_RAM_DCFE_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, _LABEL_6295_
  ld a, (_RAM_DCBC_)
  ld l, a
  ld a, (_RAM_DCFD_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  jp nc, _LABEL_6295_
  ld a, $01
  cp b
  jr z, +
  ld ix, _RAM_DCAB_
  call _LABEL_1B0C_
  ld ix, _RAM_DCEC_
  call _LABEL_1B2F_
  jp ++

+:
  ld ix, _RAM_DCAB_
  call _LABEL_1B2F_
  ld ix, _RAM_DCEC_
  call _LABEL_1B0C_
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCAB_
  call _LABEL_1B50_
  ld ix, _RAM_DCEC_
  call _LABEL_1B73_
  jp ++

+:
  ld ix, _RAM_DCAB_
  call _LABEL_1B73_
  ld ix, _RAM_DCEC_
  call _LABEL_1B50_
++:
  call _LABEL_6582_
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
  cp TT_Warriors
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
  ld ix, _RAM_DCEC_
  call _LABEL_2961_
  ld ix, _RAM_DCAB_
  call _LABEL_2961_
++:
  xor a
  ld (_RAM_DCB6_), a
  ld (_RAM_DCF7_), a
  ret

_LABEL_6295_:
  xor a
  ld (_RAM_DE3D_), a
  ret

_LABEL_629A_:
  ld bc, $0000
  ld a, (_RAM_DCC0_)
  cp $01
  jp nz, _LABEL_6393_
  ld a, (_RAM_DD42_)
  cp $01
  jp nz, _LABEL_6393_
  ld a, (_RAM_DCD9_)
  or a
  jp nz, _LABEL_6393_
  ld a, (_RAM_DD5B_)
  or a
  jp nz, _LABEL_6393_
  ld a, (_RAM_DCBD_)
  ld l, a
  ld a, (_RAM_DD3F_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, _LABEL_6393_
  ld a, (_RAM_DCBC_)
  ld l, a
  ld a, (_RAM_DD3E_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  jp nc, _LABEL_6393_
  ld a, $01
  cp b
  jr z, +
  ld ix, _RAM_DCAB_
  call _LABEL_1B0C_
  ld ix, _RAM_DD2D_
  call _LABEL_1B2F_
  jp ++

+:
  ld ix, _RAM_DCAB_
  call _LABEL_1B2F_
  ld ix, _RAM_DD2D_
  call _LABEL_1B0C_
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCAB_
  call _LABEL_1B50_
  ld ix, _RAM_DD2D_
  call _LABEL_1B73_
  jp ++

+:
  ld ix, _RAM_DCAB_
  call _LABEL_1B73_
  ld ix, _RAM_DD2D_
  call _LABEL_1B50_
++:
  call _LABEL_6582_
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
  cp TT_Warriors
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
  ld ix, _RAM_DD2D_
  call _LABEL_2961_
  ld ix, _RAM_DCAB_
  call _LABEL_2961_
++:
  xor a
  ld (_RAM_DCB6_), a
  ld (_RAM_DD38_), a
_LABEL_6393_:
  ret

_LABEL_6394_:
  ld bc, $0000
  ld a, (_RAM_DD01_)
  cp $01
  jp nz, _LABEL_648D_
  ld a, (_RAM_DD42_)
  cp $01
  jp nz, _LABEL_648D_
  ld a, (_RAM_DD1A_)
  or a
  jp nz, _LABEL_648D_
  ld a, (_RAM_DD5B_)
  or a
  jp nz, _LABEL_648D_
  ld a, (_RAM_DCFE_)
  ld l, a
  ld a, (_RAM_DD3F_)
  sub l
  jr nc, +
  xor $FF
  ld b, $01
+:
  cp $10
  jp nc, _LABEL_648D_
  ld a, (_RAM_DCFD_)
  ld l, a
  ld a, (_RAM_DD3E_)
  sub l
  jr nc, +
  xor $FF
  ld c, $01
+:
  cp $10
  jp nc, _LABEL_648D_
  ld a, $01
  cp b
  jr z, +
  ld ix, _RAM_DCEC_
  call _LABEL_1B0C_
  ld ix, _RAM_DD2D_
  call _LABEL_1B2F_
  jp ++

+:
  ld ix, _RAM_DCEC_
  call _LABEL_1B2F_
  ld ix, _RAM_DD2D_
  call _LABEL_1B0C_
++:
  ld a, $01
  cp c
  jr z, +
  ld ix, _RAM_DCEC_
  call _LABEL_1B50_
  ld ix, _RAM_DD2D_
  call _LABEL_1B73_
  jp ++

+:
  ld ix, _RAM_DCEC_
  call _LABEL_1B73_
  ld ix, _RAM_DD2D_
  call _LABEL_1B50_
++:
  call _LABEL_6582_
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
  cp TT_Warriors
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
  ld ix, _RAM_DCEC_
  call _LABEL_2961_
  ld ix, _RAM_DD2D_
  call _LABEL_2961_
++:
  xor a
  ld (_RAM_DCF7_), a
  ld (_RAM_DD38_), a
_LABEL_648D_:
  ret

_LABEL_648E_:
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
  ld ix, _RAM_DCEC_
  ld iy, _RAM_DE34_
++:
  JumpToPagedFunction _LABEL_1BCE2_

_LABEL_64C9_:
  ld a, (_RAM_DBA4_)
  cp $F3
  jr nc, +
  cp $03
  jr c, +
  ld a, (_RAM_DBA5_)
  cp $E8
  jr c, ++
  cp $F0
  jr nc, ++
; Executed in RAM at d946
+:
  ld a, $01
  ld (_RAM_D946_), a
++:
  ret

_LABEL_64E5_:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld a, $08
  ld (_RAM_DECF_RectangleWidth), a
  ld a, $04
  ld (_RAM_DECE_), a
  ld a, $0C
  ld (_RAM_DEC5_), a
  ret

+:
  ld a, $09
  ld (_RAM_DECF_RectangleWidth), a
  ld a, $03
  ld (_RAM_DECE_), a
  ld a, $0C
  ld (_RAM_DEC5_), a
  ret

; Data from 650C to 653F (52 bytes)
_DATA_650C_SoundInitialisationData:
; TODO: could label with the meanings/RAM labels
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $E8
.db $03 $03 $0A $00 $15 $0B $15 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $E8 $03 $03 $00 $00 $15 $0B $15 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $FF $07 $08
_DATA_650C_SoundInitialisationData_End:

_LABEL_6540_:
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

_LABEL_6571_:
  ld a, (_RAM_D948_)
  cp $08
  jr c, +
  xor a
  ld (_RAM_D948_), a
  ld a, $0D
  ld (_RAM_D963_SFXTrigger2), a
+:
  ret

_LABEL_6582_:
  ld a, (_RAM_D949_)
  cp $08
  jr c, +
  xor a
  ld (_RAM_D949_), a
  ld a, $0D
  ld (_RAM_D974_SFXTrigger), a
+:
  ret

_LABEL_6593_:
  ld a, (_RAM_D94A_)
  cp $04
  jr c, _LABEL_65C2_
  ld a, (_RAM_DF00_)
  or a
  jr nz, _LABEL_65C2_
  ld a, (_RAM_DE92_EngineVelocity)
  cp $06
  jr c, _LABEL_65C2_
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr z, _LABEL_65C2_
--:
  xor a
  ld (_RAM_D94A_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_TurboWheels
  jr z, +
  cp TT_Warriors
  jr z, +
  ld a, $0F
-:
  ld (_RAM_D963_SFXTrigger2), a
_LABEL_65C2_:
  ret

+:
  ld a, $10
  jr -

_LABEL_65C7_:
  ld a, (_RAM_D94A_)
  cp $04
  jr c, _LABEL_65C2_
  jr --

_LABEL_65D0_BehaviourE:
  ld a, (_RAM_DF00_)
  or a
  jr nz, +
  ld a, (_RAM_DF58_)
  or a
  jr nz, +
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  xor a
  ld (_RAM_D95E_), a
  ld a, $08
  ld (_RAM_D963_SFXTrigger2), a
  ld a, $03
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
  jp _LABEL_71C7_

+:
  ret

_LABEL_6611_Tanks:
  JumpToPagedFunction _LABEL_37A75_

_LABEL_661C_:
  JumpToPagedFunction _LABEL_37C45_

_LABEL_6627_:
  JumpToPagedFunction _LABEL_37C4F_

_LABEL_6632_:
  JumpToPagedFunction _LABEL_37C59_

_LABEL_663D_InitialisePlugholeTiles:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr z, + ; Only for powerboats...
  ret

+:ld a, :_DATA_35708_PlugholeTilesPart1
  ld (PAGING_REGISTER), a
  ld hl, _DATA_35708_PlugholeTilesPart1 ; Tile data
  ld de, $5B63        ; Tile $db bitplane 3?
  ld bc, $0068        ; Data to copy in - 13 tiles?
  call _f             ; Emit it
  ld hl, _DATA_35770_PlugholeTilesPart2 ; Then some more
  ld de, $5DC3        ; Tile $ee bitplane 3?
  ld bc, $0088        ; 11 tiles?
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

_LABEL_6677_:
  ld hl, _DATA_1D65_
  ld a, (_RAM_DE2F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_DE2F_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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

_LABEL_6704_LoadHUDTiles:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, _LABEL_6755_ret
  ; Normal cars only
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ; Head to head
  ld a, :_DATA_35D2D_HeadToHeadHUDTiles
  ld (PAGING_REGISTER), a
  ld a, $80 ; Tile $194
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  ld bc, $00A0 ; 20 tiles * 8 rows
  ld hl, _DATA_35D2D_HeadToHeadHUDTiles
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
  ld a, :_DATA_30A68_ChallengeHUDTiles ;$0C
  ld (PAGING_REGISTER), a
  ld a, $80 ; Tile $194
  out (PORT_VDP_ADDRESS), a
  ld a, $72
  out (PORT_VDP_ADDRESS), a
  ld bc, $00A0 ; 20 tiles * 8 rows
  ld hl, _DATA_30A68_ChallengeHUDTiles
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

_LABEL_6756_:
  xor a
  ld (_RAM_DEBA_), a
  ld (_RAM_DEBB_), a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, _LABEL_67AB_
  ld a, (_RAM_D5C5_)
  cp $02
  jp z, _LABEL_6895_
  ld a, (_RAM_DE8C_)
  or a
  jr z, +
  ld a, (_RAM_DD1F_)
  or a
  jp z, _LABEL_6895_
  ld a, (_RAM_DF59_CarState)
  or a
  jp nz, _LABEL_6895_
  ld a, (_RAM_DF5B_)
  or a
  jp nz, _LABEL_6895_
  ld a, $01
  ld (_RAM_D5C5_), a
  ld hl, $0000
  ld (_RAM_DF56_), hl
  jp ++

+:
  ld a, (_RAM_DD1F_)
  or a
  jr z, +
  jp _LABEL_6895_

+:
  ld a, (_RAM_D945_)
  cp $02
  jp z, _LABEL_6895_
  ld a, (_RAM_DF81_)
  or a
  jr nz, ++
_LABEL_67AB_:
  ld a, (_RAM_DF58_)
  or a
  jp z, +
  ld a, (_RAM_DF59_CarState)
  or a
  jp nz, +
  jp ++

+:
  ld a, (_RAM_DF59_CarState)
  cp $FF
  jp nz, _LABEL_6895_
  ld a, (_RAM_DF5B_)
  cp $FF
  jr z, ++
  jp _LABEL_6895_

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
  jr nz, _LABEL_6895_
  ld a, (_RAM_DEBB_)
  or a
  jr nz, _LABEL_6895_
  ld a, (_RAM_DE8C_)
  cp $01
  jp z, _LABEL_69DB_
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, +
  ld a, $02
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_D946_), a
  ld a, $16
  ld (_RAM_D963_SFXTrigger2), a
  ld a, $74
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $64
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
_LABEL_6895_:
  ret

+:
  xor a
  ld (_RAM_DF81_), a
  ld a, (_RAM_DF7F_)
  or a
  jp nz, _LABEL_693F_
  ld a, $01
  ld (_RAM_DF7F_), a
  ld a, $13
  ld (_RAM_D963_SFXTrigger2), a
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
  jr nz, _LABEL_6947_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ret

+:
  ld a, (_RAM_D5CB_)
  or a
  jp nz, _LABEL_7AC4_
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
  jp _LABEL_B2B_

++:
  ld a, (_RAM_D5CB_)
  or a
  jp nz, _LABEL_7AAF_
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
  jp _LABEL_B13_

_LABEL_693F_:
  ld a, (_RAM_DF7F_)
  cp $05
  jp nz, _LABEL_6895_
_LABEL_6947_:
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
  ld (_RAM_DCEC_), hl
  ld hl, (_RAM_DBAB_)
  ld e, $64
  ld d, $00
  add hl, de
  ld (_RAM_DCEE_), hl
  ld a, $02
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_D946_), a
  ld a, $16
  ld (_RAM_D963_SFXTrigger2), a
  ld a, $74
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $64
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  ret

_LABEL_69DB_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, _LABEL_6A11_
  ld a, (_RAM_D5C5_)
  cp $02
  jp z, _LABEL_6A6B_
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
  jr z, _LABEL_6A11_
  ld a, $10
  ld (_RAM_D5C7_), a
  call _LABEL_6A4F_
  jr _LABEL_6A6B_

_LABEL_6A11_:
  xor a
  ld (_RAM_DF58_), a
  ld (_RAM_DF59_CarState), a
  ld hl, $01F4
  ld (_RAM_D95B_), hl
  ld (_RAM_D58C_), hl
  ld a, $0A
  ld (_RAM_D95E_), a
  ld a, $0C
  ld (_RAM_D963_SFXTrigger2), a
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
  jr z, _LABEL_6A4F_
  ret

_LABEL_6A4F_:
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
_LABEL_6A6B_:
  ret

_LABEL_6A6C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D5C5_)
  cp $02
  jr nz, +
  ld a, (_RAM_D5C7_)
  cp $01
  jr z, ++
  dec a
  ld (_RAM_D5C7_), a
+:
  ret

++:
  xor a
  ld (_RAM_D5C7_), a
  jp _LABEL_6A11_

_LABEL_6A8C_:
  JumpToPagedFunction _LABEL_36937_

_LABEL_6A97_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +++
  ld a, (_RAM_D5C5_)
  cp $02
  jp z, _LABEL_6B60_
  ld a, (_RAM_DE8C_)
  or a
  jr nz, +
  ld a, (_RAM_D5C5_)
  or a
  jr z, ++
+:
  ret

++:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, +++
  ld a, (_RAM_DF59_CarState)
  cp $FF
  jr z, +
  or a
  jr nz, +++
+:
  call _LABEL_71C7_
+++:
  ld a, (_RAM_DCD9_)
  or a
  jp z, _LABEL_6B34_
  ld a, (_RAM_DF5A_)
  or a
  jp nz, _LABEL_6B34_
  ld a, (_RAM_DCDE_)
  or a
  jr nz, +
  ld a, $02
  ld (_RAM_DF5A_), a
  xor a
  ld (_RAM_DCB6_), a
  jp _LABEL_7295_

+:
  cp $01
  jr z, +
  sub $01
  ld (_RAM_DCDE_), a
  jp _LABEL_6B34_

+:
  ld a, (_RAM_DCE4_)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DCDE_), a
  xor a
  ld (_RAM_DCE4_), a
  jp _LABEL_6B34_

+:
  ld hl, (_RAM_DCE0_)
  ld (_RAM_DCAB_), hl
  ld hl, (_RAM_DCE2_)
  ld (_RAM_DCAD_), hl
  xor a
  ld (_RAM_DCD9_), a
  ld (_RAM_DF5A_), a
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
_LABEL_6B34_:
  ld a, (_RAM_DD1A_)
  or a
  jp z, _LABEL_6BC2_
  ld a, (_RAM_DF5B_)
  or a
  jp nz, _LABEL_6BC2_
  ld a, (_RAM_DD1F_)
  or a
  jr nz, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_6BC2_
  ld a, $02
  ld (_RAM_DF5B_), a
  xor a
  ld (_RAM_DCF7_), a
  jp _LABEL_72CA_

+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_6BC2_
_LABEL_6B60_:
  ld a, (_RAM_DD1F_)
  or a
  jr z, _LABEL_6BC2_
  ld a, (_RAM_DD1F_)
  cp $01
  jr z, +
  sub $01
  ld (_RAM_DD1F_), a
  jp _LABEL_6BC2_

+:
  ld a, (_RAM_DD25_)
  cp $01
  jr nz, +
  ld a, $FF
  ld (_RAM_DD1F_), a
  xor a
  ld (_RAM_DD25_), a
  jp _LABEL_6B34_

+:
  ld hl, (_RAM_DD21_)
  ld (_RAM_DCEC_), hl
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
  jr z, _LABEL_6BC2_
  xor a
  ld (_RAM_DD1F_), a
_LABEL_6BC2_:
  ld a, (_RAM_DD5B_)
  or a
  jp z, +
  ld a, (_RAM_DF5C_)
  or a
  jp nz, +
  ld a, (_RAM_DD60_)
  or a
  jr nz, ++
  ld a, $02
  ld (_RAM_DF5C_), a
  xor a
  ld (_RAM_DD38_), a
  jp _LABEL_7332_

+:
  ret

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
  jp _LABEL_6B34_

+:
  ld hl, (_RAM_DD62_)
  ld (_RAM_DD2D_), hl
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
_DATA_6C31_:
.db $0A $0A $0A $0C $09 $0A $0A $06 ; one per track

_LABEL_6C39_:
  ld a, (_RAM_DB97_TrackType)
  ld e, a
  ld d, $00
  ld hl, _DATA_6C31_
  add hl, de
  ld a, (hl)
  ld d, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_FormulaOne
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld d, $13
  jr ++

+:
  cp TT_RuffTrux
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
  jp nz, _LABEL_6E00_
  ld a, (_RAM_DF58_)
  or a
  jp nz, _LABEL_6E00_
  ld a, (_RAM_DF4F_)
  ld l, a
  ld a, (_RAM_D587_)
  cp $FF
  jp z, _LABEL_6D08_
  or a
  jp nz, +
  jp _LABEL_6E00_

+:
  cp l
  jp z, _LABEL_6E00_
  jr c, +
  sub l
  cp c
  jr nc, ++
-:
  cp d
  jp c, _LABEL_6D43_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp z, +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_FormulaOne
  jp z, _LABEL_6E00_
  jp _LABEL_6D43_

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
  cp TT_Powerboats
  jp z, _LABEL_6D43_
  cp TT_FormulaOne
  jr nz, _LABEL_6D08_
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
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
  jp nz, _LABEL_6E00_
_LABEL_6D08_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BD_), a
  jp _LABEL_29BC_Behaviour1_FallToFloor

+:
  ld a, $01
  ld (_RAM_DF59_CarState), a
  ld (_RAM_DF58_), a
  ld hl, 1000 ; $03E8
  ld (_RAM_D95B_), hl
  xor a
  ld (_RAM_D95E_), a
  ld a, $05
  ld (_RAM_D963_SFXTrigger2), a
  xor a
  ld (_RAM_DE92_EngineVelocity), a
  ld (_RAM_DF00_), a
  ld (_RAM_DE66_), a
  ld (_RAM_DEB5_), a
  ld (_RAM_DEB6_), a
  call _LABEL_71C7_
  jp _LABEL_6E00_

_LABEL_6D43_:
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
  jr nc, _LABEL_6DDB_
  ld a, b
  cp $01
  jr z, _LABEL_6DD3_
  xor a
  ld (_RAM_DE51_), a
  ld a, $01
  ld (_RAM_DE52_), a
  ld a, (_RAM_DF24_LapsRemaining)
  sub $01
  ld (_RAM_DF24_LapsRemaining), a
  cp $00
  jr z, +
  ld a, (_RAM_DC55_CourseIndex) ; Qualifying early win?
  cp $00
  jr nz, _LABEL_6DDB_
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr nz, _LABEL_6DDB_
  ld a, (_RAM_DF2A_)
  cp $00
  jr nz, _LABEL_6DDB_
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp nz, _LABEL_7AA6_
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr z, +
  ld a, (_RAM_DC55_CourseIndex) ; Track 0 = qualifying
  or a
  jr nz, +
  ld a, $12
  ld (_RAM_D963_SFXTrigger2), a
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
  ld hl, _DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF4F_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, _LABEL_6DDB_
  call _LABEL_1CFF_
  jp _LABEL_6DDB_

_LABEL_6DD3_:
  ld a, (_RAM_DF24_LapsRemaining)
  add a, $01
  ld (_RAM_DF24_LapsRemaining), a
_LABEL_6DDB_:
  ld a, (_RAM_DF65_)
  cp $01
  jr z, _LABEL_6E00_
  call _LABEL_1CBD_
  and $3F
  ld c, a
  ld hl, _RAM_D900_
  ld b, $00
  add hl, bc
  ld a, (hl)
  and $80
  jr nz, +
  call _LABEL_1C98_
+:
  ld a, (_RAM_D587_)
  ld (_RAM_DF4F_), a
  xor a
  ld (_RAM_D589_), a
_LABEL_6E00_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jp z, _LABEL_7171_
  ld a, (_RAM_DCC5_)
  cp $00
  jp nz, _LABEL_6F10_
  ld a, (_RAM_DF50_)
  ld l, a
  ld a, (_RAM_DCC3_)
  cp $00
  jp z, _LABEL_6F10_
  cp l
  jp z, _LABEL_6F10_
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
  jr nc, _LABEL_6E79_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DCC4_)
  sub $01
  ld (_RAM_DCC4_), a
  cp $00
  jr nz, _LABEL_6E79_
  ld a, $01
  ld (_RAM_DCC5_), a
  ld a, (_RAM_DF25_)
  ld e, a
  ld d, $00
  ld hl, _DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF50_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, _LABEL_6E79_
  call _LABEL_1CFF_
  jp _LABEL_6E79_

+:
  ld a, (_RAM_DCC4_)
  add a, $01
  ld (_RAM_DCC4_), a
_LABEL_6E79_:
  ld a, (_RAM_DCC5_)
  cp $01
  jp z, _LABEL_6F10_
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
  call _LABEL_7176_
+:
  ld a, (_RAM_DCC3_)
  ld (_RAM_DF50_), a
  xor a
  ld (_RAM_DCC6_), a
  jp _LABEL_6F10_

_LABEL_6EA9_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jp z, _LABEL_6F6D_
  cp TT_FormulaOne
  jr nz, _LABEL_6EF3_
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
  jp nz, _LABEL_6FFF_
_LABEL_6EF3_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp z, _LABEL_6FFF_
  ld a, (_RAM_DD04_)
  cp $FF
  jr z, +
  ld (_RAM_DF51_), a
+:
  ld a, $01
  ld (_RAM_D5BE_), a
  ld ix, _RAM_DCEC_
  jp _LABEL_4DD4_

_LABEL_6F10_:
  ld a, (_RAM_D5E0_)
  ld d, a
  ld a, (_RAM_DF69_)
  ld c, a
  ld a, (_RAM_DD06_)
  cp $00
  jp nz, _LABEL_6FFF_
  ld a, (_RAM_DF51_)
  ld l, a
  ld a, (_RAM_DD04_)
  cp $FF
  jr z, _LABEL_6EF3_
  cp $00
  jp z, _LABEL_6FFF_
  cp l
  jp z, _LABEL_6FFF_
  ld b, a
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, _LABEL_6F6D_
  ld a, b
  cp l
  jr c, +
  sub l
  cp c
  jr nc, ++
-:
  cp d
  jp c, _LABEL_6F6D_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp z, _LABEL_6EA9_
  ld a, (_RAM_DB97_TrackType)
  cp TT_FormulaOne
  jp z, _LABEL_6FFF_
  jp _LABEL_6F6D_

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

_LABEL_6F6D_:
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
  jr nc, _LABEL_6FCD_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DD05_)
  sub $01
  ld (_RAM_DD05_), a
  cp $00
  jr nz, _LABEL_6FCD_
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jp nz, _LABEL_7AA6_
  ld a, $01
  ld (_RAM_DD06_), a
  ld a, (_RAM_DF25_)
  ld e, a
  ld d, $00
  ld hl, _DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF51_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, _LABEL_6FCD_
  call _LABEL_1CFF_
  jp _LABEL_6FCD_

+:
  ld a, (_RAM_DD05_)
  add a, $01
  ld (_RAM_DD05_), a
_LABEL_6FCD_:
  ld a, (_RAM_DD06_)
  cp $01
  jr z, _LABEL_6FFF_
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
  call _LABEL_718B_
++:
  ld a, (_RAM_DD04_)
  ld (_RAM_DF51_), a
  xor a
  ld (_RAM_DD07_), a
_LABEL_6FFF_:
  ld a, (_RAM_DD47_)
  cp $00
  jp nz, _LABEL_709C_
  ld a, (_RAM_DF52_)
  ld l, a
  ld a, (_RAM_DD45_)
  cp $00
  jp z, _LABEL_709C_
  cp l
  jp z, _LABEL_709C_
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
  jr nc, _LABEL_7070_
  ld a, b
  cp $01
  jr z, +
  ld a, (_RAM_DD46_)
  sub $01
  ld (_RAM_DD46_), a
  cp $00
  jr nz, _LABEL_7070_
  ld a, $01
  ld (_RAM_DD47_), a
  ld a, (_RAM_DF25_)
  ld e, a
  ld d, $00
  ld hl, _DATA_7172_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF52_), a
  ld a, (_RAM_DF25_)
  add a, $01
  ld (_RAM_DF25_), a
  cp $02
  jr nz, _LABEL_7070_
  call _LABEL_1CFF_
  jp _LABEL_7070_

+:
  ld a, (_RAM_DD46_)
  add a, $01
  ld (_RAM_DD46_), a
_LABEL_7070_:
  ld a, (_RAM_DD47_)
  cp $01
  jr z, _LABEL_709C_
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
  call _LABEL_71A0_
+:
  ld a, (_RAM_DD45_)
  ld (_RAM_DF52_), a
  xor a
  ld (_RAM_DD48_), a
_LABEL_709C_:
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
  ld a, $01
  ld (_RAM_D974_SFXTrigger), a
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
  ld a, (_RAM_DF24_LapsRemaining)
  cp $05
  jr nc, +++++
  cp $00
  jr nz, ++++
+++:
  add a, $09
++++:
  add a, $A3
-:
  ld (_RAM_DF37_), a
  jp ++++++++

+++++:
  ld a, $AC
  jp -

++++++:
  ld a, (_RAM_DF24_LapsRemaining)
  cp $00
  jr z, +++++++
  ld a, $A6
-:
  ld (_RAM_DF37_), a
  ret

+++++++:
  ld a, $AC
  jp -

++++++++:
  call _LABEL_1D45_
  ld hl, _RAM_DF38_
  ld d, $00
  ld a, (_RAM_DF2A_)
  ld e, a
  add hl, de
  ld a, (_RAM_DF65_)
  cp $00
  jr z, +
  ld a, $9C
  jp ++

+:
  ld a, $94
++:
  ld (hl), a
  ld hl, _RAM_DF38_
  ld d, $00
  ld a, (_RAM_DF2B_)
  ld e, a
  add hl, de
  ld a, (_RAM_DCC5_)
  cp $00
  jr z, +
  ld a, $9D
  jp ++

+:
  ld a, $95
++:
  ld (hl), a
  ld hl, _RAM_DF38_
  ld d, $00
  ld a, (_RAM_DF2C_)
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
  ld hl, _RAM_DF38_
  ld d, $00
  ld a, (_RAM_DF2D_)
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
_LABEL_7171_:
  ret

; Data from 7172 to 7175 (4 bytes)
_DATA_7172_:
.db $09 $07 $05 $03

_LABEL_7176_:
  ld a, (_RAM_DCAF_)
  ld (_RAM_DBB6_), a
  ld a, (_RAM_DCB0_)
  ld (_RAM_DBB7_), a
  ld a, (_RAM_DCB5_)
  and $3F
  ld (_RAM_DBB8_), a
  ret

_LABEL_718B_:
  ld a, (_RAM_DCF0_)
  ld (_RAM_DBB9_), a
  ld a, (_RAM_DCF1_)
  ld (_RAM_DBBA_), a
  ld a, (_RAM_DCF6_)
  and $3F
  ld (_RAM_DBBB_), a
  ret

_LABEL_71A0_:
  ld a, (_RAM_DD31_)
  ld (_RAM_DBBC_), a
  ld a, (_RAM_DD32_)
  ld (_RAM_DBBD_), a
  ld a, (_RAM_DD37_)
  and $3F
  ld (_RAM_DBBE_), a
  ret

_LABEL_71B5_:
  ld a, (_RAM_DBB9_)
  ld (_RAM_DBB1_), a
  ld a, (_RAM_DBBA_)
  ld (_RAM_DBB3_), a
  ld a, (_RAM_DBBB_)
  ld (_RAM_DBB5_), a
_LABEL_71C7_:
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
  call _LABEL_3100_
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
  call _LABEL_7367_
  ld (_RAM_DBAD_), hl
  ld a, (_RAM_DBB3_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
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
  call _LABEL_7393_
  ld (_RAM_DBAF_), hl
  ld a, (_RAM_D945_)
  cp $01
  jp z, ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld a, (_RAM_D5DE_)
  ld (_RAM_DF4F_), a
  ld (_RAM_D587_), a
+:
  ret

++:
  JumpToPagedFunction _LABEL_36B29_

_LABEL_7295_:
  ld a, (_RAM_DBB6_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBB8_)
  call _LABEL_7367_
  ld (_RAM_DCAB_), hl
  ld a, (_RAM_DBB7_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBB8_)
  call _LABEL_7393_
  ld (_RAM_DCAD_), hl
  ret

_LABEL_72CA_:
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
  ld hl, (_RAM_DCEC_)
  ld (_RAM_D941_), hl
  ld hl, (_RAM_DCEE_)
  ld (_RAM_D943_), hl
++:
  ld a, (_RAM_DBB9_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBB_)
  call _LABEL_7367_
  ld (_RAM_DCEC_), hl
  ld a, (_RAM_DBBA_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBB_)
  call _LABEL_7393_
  ld (_RAM_DCEE_), hl
  ld a, (_RAM_D940_)
  cp $01
  jp z, +
  ret

+:
  JumpToPagedFunction _LABEL_36BE6_

_LABEL_7332_:
  ld a, (_RAM_DBBC_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBE_)
  call _LABEL_7367_
  ld (_RAM_DD2D_), hl
  ld a, (_RAM_DBBD_)
  ld (_RAM_DEF5_), a
  ld a, $60
  ld (_RAM_DEF4_), a
  call _LABEL_3100_
  ld hl, (_RAM_DEF1_)
  ld a, (_RAM_DBBE_)
  call _LABEL_7393_
  ld (_RAM_DD2F_), hl
  ret

_LABEL_7367_:
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
  ld hl, _DATA_2FA7_
  add hl, bc
  ld a, (hl)
  pop hl
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld bc, $0004
  or a
  sbc hl, bc
+:
  ret

_LABEL_7393_:
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
  ld hl, _DATA_2FAF_
  add hl, bc
  ld a, (hl)
  pop hl
  ld c, a
  ld b, $00
  add hl, bc
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld bc, $0004
  or a
  sbc hl, bc
+:
  ret

-:
  call _LABEL_6C39_
  CallPagedFunction2 _LABEL_35F0D_
  call +
  ret

_LABEL_73D4_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, -
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, _LABEL_7427_
  ld a, (_RAM_DE8C_)
  or a
  jr nz, +
  call _LABEL_6C39_
+:
  ld ix, _RAM_DA60_SpriteTableXNs
  ld iy, _RAM_DAE0_SpriteTableYs
  ld bc, $0000
-:
  ld hl, _RAM_DF1F_
  inc (hl)
  ld a, (hl)
  cp $09
  jr nz, +
  xor a
  ld (hl), a
+:
  ld hl, _RAM_DF2E_
  ld d, $00
  ld e, a
  add hl, de
  ld a, (hl)
  ld (ix+0), a
  ld e, $09
  add hl, de
  ld a, (hl)
  ld (ix+1), a
  ld e, $09
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

_LABEL_7427_:
  call _LABEL_6C39_
  ld ix, _RAM_DA60_SpriteTableXNs
  ld iy, _RAM_DAE0_SpriteTableYs
  ld a, (_RAM_DF2E_)
  ld (ix+0), a
  add a, $08
  ld (ix+2), a
  add a, $08
  ld (ix+4), a
  add a, $08
  ld (ix+6), a
  ld a, (_RAM_DF40_)
  ld (iy+0), a
  ld (iy+1), a
  ld (iy+2), a
  ld (iy+3), a
  ld a, $8B
  ld (ix+1), a
; Executed in RAM at da63
_LABEL_745B_:
  ld a, $98
  ld (ix+3), a
  ld a, $9B
  ld (ix+5), a
  ld a, $E8
  ld (ix+7), a
  ret

_LABEL_746B_RuffTrux_UpdatePerFrameTiles:
  JumpToPagedFunction _LABEL_36D52_RuffTrux_UpdateTimer

_LABEL_7476_:
  di
  CallPagedFunction2 _LABEL_2B5D5_SilencePSG
  call _LABEL_7564_SetControlsToNoButtons
  ld a, (_RAM_DC3B_IsTrackSelect)
  cp $01
  jp z, _LABEL_7519_
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr z, _LABEL_74E6_
  ld a, (_RAM_DC55_CourseIndex)
  cp $00
  jp z, _LABEL_7545_
  cp $1A
  jp z, _LABEL_7520_
  cp $1B
  jp z, _LABEL_7520_
  cp $1C
  jp z, _LABEL_7520_
  ld a, (_RAM_DC4C_Cheat_AlwaysFirstPlace)
  or a
  jr nz, +
  ld a, (_RAM_DF2A_)
  ld (_RAM_DBCF_LastRacePosition), a
  ld a, (_RAM_DF2B_)
  ld (_RAM_DBD0_HeadToHeadLost2), a
  ld a, (_RAM_DF2C_)
  ld (_RAM_DBD2_), a
  ld a, (_RAM_DF2D_)
  ld (_RAM_DBD1_), a
-:
  ld a, $02
  ld (_RAM_DBCD_MenuIndex), a
  jp _LABEL_14_EnterMenus

+:
  xor a
  ld (_RAM_DBCF_LastRacePosition), a
  inc a
  ld (_RAM_DBD0_HeadToHeadLost2), a
  inc a
  ld (_RAM_DBD1_), a
  inc a
  ld (_RAM_DBD2_), a
  jr -

_LABEL_74E6_:
  ld a, (_RAM_DF2A_)
  ld (_RAM_DBCF_LastRacePosition), a
  ld a, (_RAM_DF2B_)
  ld (_RAM_DBD0_HeadToHeadLost2), a
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, +++
  ld a, (_RAM_DC55_CourseIndex)
  or a
  jr nz, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jr z, ++
  xor a
-:
  ld (_RAM_DBCE_), a
+:
  ld a, $05
  jr ++++

++:
  ld a, $01
  jr -

+++:
  ld a, $04
++++:
  ld (_RAM_DBCD_MenuIndex), a
  jp _LABEL_14_EnterMenus

_LABEL_7519_:
  xor a
  ld (_RAM_DBCD_MenuIndex), a
  jp _LABEL_14_EnterMenus

_LABEL_7520_:
  ld a, (_RAM_DC39_)
  add a, $01
  ld (_RAM_DC39_), a
  xor a
  ld (_RAM_DC0A_), a
  ld a, $03
  ld (_RAM_DBCD_MenuIndex), a
  ld a, (_RAM_DF8C_)
  cp $01
  jr z, +
  ld a, $02
  jp ++

+:
  ld a, $03
++:
  ld (_RAM_DC38_), a
  jp _LABEL_14_EnterMenus

_LABEL_7545_:
  ld a, $01
  ld (_RAM_DBCD_MenuIndex), a
  ld a, (_RAM_DF2A_)
  cp $00
  jr z, +
  cp $01
  jr nz, ++
+:
  ld a, $01
-:
  ld (_RAM_DBCE_), a
  call _LABEL_173_LoadEnterMenuTrampolineToRAM
  jp _LABEL_14_EnterMenus

++:
  xor a
  jp -

_LABEL_7564_SetControlsToNoButtons:
  ld a, NO_BUTTONS_PRESSED ; $3F
  ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
  ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
  ld (_RAM_DB20_Player1Controls), a
  ld (_RAM_DB21_Player2Controls), a
  ret

_LABEL_7573_EnterGame:
  di
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ; Game Gear
  xor a
  out (PORT_GG_LinkStatus), a
+:
  SetPaletteAddressImmediateGG $10
  xor a ; Set to black
  out (PORT_VDP_DATA), a
  out (PORT_VDP_DATA), a
  ; Set that as the backdrop colour
  call _LABEL_7A9F_SetBackdropColour
  call _LABEL_156_
  call _LABEL_3214_BlankSpriteTable
  call _LABEL_31F1_UpdateSpriteTable
  ; Reset life counter if cheat is enabled
  ld a, (_RAM_DC4B_Cheat_InfiniteLives)
  or a
  jr z, +
  ld a, $05
  ld (_RAM_DC09_Lives), a
+:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_DC3D_IsHeadToHead), a
+:
  ld a, (_RAM_DC0A_)
  and $0F
  cp $03
  jr nz, +
  ld a, (_RAM_DC39_)
  jp ++

+:
  ld a, (_RAM_DBD8_CourseSelectIndex)
++:
  ld (_RAM_DC55_CourseIndex), a
   ; Look up track type
  ld hl, _DATA_766A_CourseList_TrackTypes
  ld d, $00
  ld e, a
  add hl, de
  ld a, (hl)
  ld (_RAM_DB97_TrackType), a
  ; Then track index
  ld hl, _DATA_7687_CourseList_TrackIndexes
  add hl, de
  ld a, (hl)
  ld (_RAM_DB96_TrackIndexForThisType), a
  ; Then top speed
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld hl, _DATA_7718_CourseList_TopSpeeds_GG
  jr ++
+:ld hl, _DATA_76A4_CourseList_TopSpeeds_SMS
++:add hl, de
  ld a, (hl)
  ld (_RAM_DB98_TopSpeed), a
  ; Then acceleration delay
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld hl, _DATA_7735_CourseList_AccelerationDelay_GG
  jr ++
+:ld hl, _DATA_76C1_CourseList_AccelerationDelay_SMS
++:add hl, de
  ld a, (hl)
  ld (_RAM_DB99_AccelerationDelay), a
  ; Then deceleration delay
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld hl, _DATA_7752_CourseList_DecelerationDelay_GG
  jr ++
+:ld hl, _DATA_76DE_CourseList_DecelerationDelay_SMS
++:add hl, de
  ld a, (hl)
  ld (_RAM_DB9A_DecelerationDelay), a
  ; Then steering delay
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld hl, _DATA_776F_CourseList_SteeringDelay_GG
  jr ++
+:ld hl, _DATA_76FB_CourseList_SteeringDelay_SMS
++:add hl, de
  ld a, (hl)
  ld (_RAM_DB9B_SteeringDelay), a

  ; Unpack 16 nibbles
  ld a, :_DATA_23ECF_HandlingData_SMS
  ld (PAGING_REGISTER), a
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld hl, _DATA_23ECF_HandlingData_SMS
  jr ++
+:ld hl, _DATA_23DE7_HandlingData_GG
++:ld a, e ; The course index
  sla a ; x8
  sla a
  sla a
  and $F8 ; Zero low bits
  ld e, a
  ld d, $00
  add hl, de ; -> hl

  ld de, _RAM_DB86_HandlingData
  ld bc, $0008
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
  jp _LABEL_383_

; Data from 766A to 7686 (29 bytes)
_DATA_766A_CourseList_TrackTypes:
.db $02 $01 $00 $05 $03 $01 $04 $05 $02 $03 $08 $01 $02 $06 $04 $00 $03 $08 $05 $06 $00 $02 $08 $04 $06 $00 $07 $07 $07

; Data from 7687 to 76A3 (29 bytes)
_DATA_7687_CourseList_TrackIndexes:
.db $00 $01 $00 $00 $01 $00 $00 $01 $01 $00 $00 $02 $03 $00 $01 $01 $02 $01 $02 $01 $02 $02 $02 $02 $02 $02 $00 $01 $02

; Data from 76A4 to 76C0 (29 bytes)
_DATA_76A4_CourseList_TopSpeeds_SMS:
.db $09 $08 $0B $0A $0B $09 $0B $0A $09 $0B $08 $09 $09 $07 $0B $0B $0B $08 $0A $07 $0B $09 $08 $0B $07 $0B $08 $08 $08

; Data from 76C1 to 76DD (29 bytes)
_DATA_76C1_CourseList_AccelerationDelay_SMS:
.db $10 $12 $09 $12 $0D $12 $0F $12 $10 $0E $12 $12 $10 $06 $0F $09 $0D $12 $12 $06 $09 $10 $12 $0F $06 $09 $13 $13 $13

; Data from 76DE to 76FA (29 bytes)
_DATA_76DE_CourseList_DecelerationDelay_SMS:
.db $12 $05 $16 $27 $19 $12 $1A $27 $12 $19 $12 $12 $12 $06 $1A $16 $19 $12 $27 $06 $16 $12 $12 $1A $06 $16 $15 $15 $15

; Data from 76FB to 7717 (29 bytes)
_DATA_76FB_CourseList_SteeringDelay_SMS:
.db $07 $06 $07 $07 $06 $06 $06 $06 $07 $06 $06 $06 $07 $09 $06 $06 $06 $06 $06 $09 $06 $07 $06 $06 $09 $06 $06 $06 $06

; Data from 7718 to 7734 (29 bytes)
_DATA_7718_CourseList_TopSpeeds_GG:
.db $07 $06 $0A $08 $09 $07 $09 $08 $07 $09 $06 $07 $07 $05 $09 $0A $09 $06 $08 $05 $0A $07 $06 $09 $05 $0A $06 $06 $06

; Data from 7735 to 7751 (29 bytes)
_DATA_7735_CourseList_AccelerationDelay_GG:
.db $14 $14 $09 $17 $0D $14 $11 $17 $14 $10 $14 $14 $14 $08 $11 $09 $0D $14 $17 $08 $09 $14 $14 $11 $08 $09 $15 $15 $15

; Data from 7752 to 776E (29 bytes)
_DATA_7752_CourseList_DecelerationDelay_GG:
.db $14 $07 $18 $29 $1B $14 $1C $29 $14 $1B $14 $14 $14 $08 $1C $18 $1B $14 $29 $08 $18 $14 $14 $1C $08 $18 $17 $17 $17

; Data from 776F to 778B (29 bytes)
_DATA_776F_CourseList_SteeringDelay_GG:
.db $08 $07 $08 $08 $07 $07 $07 $07 $08 $07 $07 $07 $08 $0A $07 $07 $07 $07 $07 $0A $07 $08 $07 $07 $0A $07 $07 $07 $07

_LABEL_778C_ScreenOn:
  ld a, $70
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_7795_ScreenOff:
  ld a, $10
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_779E_:
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld a, (_RAM_DED3_HScrollValue)
  and $F8
  rr a
  rr a
  ld l, a
  ld a, $40
  sub l
  add a, $0A
  and $3F
  ld (_RAM_DEBF_), a
  ret

+:
  ld a, (_RAM_DED3_HScrollValue)
  and $F8
  rr a
  rr a
  ld l, a
  ld a, $40
  sub l
  and $3F
  ld (_RAM_DEBF_), a
  ret

_LABEL_77CD_:
  call _LABEL_779E_
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ld c, $17
  jp ++

+:
  ld c, $1C
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
  ld hl, (_RAM_DEBF_)
  add hl, de
  ld a, l
  ld (_RAM_DEC3_), a
  ld a, h
  ld (_RAM_DEC4_), a
  ret

_LABEL_780D_:
  call _LABEL_779E_
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
  ld hl, (_RAM_DEBF_)
  add hl, de
  ld a, l
  ld (_RAM_DEC3_), a
  ld a, h
  ld (_RAM_DEC4_), a
  ret

_LABEL_784D_:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ld a, (_RAM_DED4_VScrollValue)
  and $F8
  rr a
  rr a
  rr a
  ld b, a
  ld hl, _DATA_9ED_
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_A2D_
  ld a, b
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld a, e
  ld (_RAM_DEBD_), a
  ld a, d
  ld (_RAM_DEBE_), a
  jp _LABEL_779E_

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
  add a, $05
  ld b, a
  ld hl, _DATA_9ED_
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_A2D_
  ld a, b
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld a, e
  ld (_RAM_DEBD_), a
  ld a, d
  ld (_RAM_DEBE_), a
  ld a, (_RAM_DED3_HScrollValue)
  and $F8
  rr a
  rr a
  ld l, a
  ld a, $40
  sub l
  add a, c
  and $3F
  ld (_RAM_DEBF_), a
  ret

_LABEL_78CE_:
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
    ld hl, (_RAM_DEC3_)
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
    ld (_RAM_DEC3_), hl
  exx
  ret

_LABEL_7916_:
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

_LABEL_795E_:
  ld hl, (_RAM_DED1_)
  ld a, (hl)
  call _LABEL_9B2_ConvertMetatileIndexToDataIndex
  ld (_RAM_DEBC_TileDataIndex), a
  ld hl, _DATA_4000_TileIndexPointerLow
  ld a, (_RAM_DEBC_TileDataIndex)
  add a, l
  ld l, a
  xor a
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_4041_TileIndexPointerHigh
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
  call _LABEL_18D2_
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

+:
    ld (_RAM_DECC_), a
  exx
  ld a, $01
  ld (_RAM_DECD_), a
  ld (_RAM_DECB_), a
  ret

_LABEL_79C8_:
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
  jp _LABEL_7A38_

+:
  ld a, (_RAM_DCD9_)
  cp $00
  jr nz, +
  ld a, $04
  ld (_RAM_DF5A_), a
  ld a, $01
  ld (_RAM_DCD9_), a
  xor a
  ld (ix+11), a
  xor a
  ld (ix+20), a
  ld (_RAM_DE67_), a
  ld (_RAM_DE32_), a
+:
  ret

++:
  ld a, (_RAM_DD1A_)
  cp $00
  jr nz, ++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  ld (_RAM_D5C0_), a
  jp _LABEL_4DD4_

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
++:
  ret

+++:
  jp _LABEL_4EA0_

_LABEL_7A38_:
  ld a, (_RAM_DD5B_)
  cp $00
  jr nz, +
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
+:
  ret

_LABEL_7A58_:
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
  ld de, _DATA_35B8D_
  add hl, de
  ld a, :_DATA_35B8D_
  ld (PAGING_REGISTER), a
  ld a, (hl)
  ld (_RAM_DF22_), a

  sla a
  ld l, a
  ld h, $00
  ld de, _DATA_35BED_96TimesTable
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

_LABEL_7A9F_SetBackdropColour:
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_BACKDROP_COLOUR
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_7AA6_:
  ld a, (_RAM_DB7B_)
  cp $04
  jr z, _LABEL_7AF2_
  jr nc, _LABEL_7AC4_
_LABEL_7AAF_:
  call +
  ld a, $01
  ld (_RAM_DF2A_), a
  ld (_RAM_DF59_CarState), a
  xor a
  ld (_RAM_DF2B_), a
  ld (_RAM_D5CB_), a
  jp _LABEL_2A08_

_LABEL_7AC4_:
  call +
  xor a
  ld (_RAM_DF2A_), a
  ld (_RAM_D5CB_), a
  ld a, $01
  ld (_RAM_DF2B_), a
  ld (_RAM_DF5B_), a
  ld ix, _RAM_DCEC_
  jp _LABEL_4E49_

+:
  ld a, $01
  ld (_RAM_D947_), a
  ld a, $F0
  ld (_RAM_DF6A_), a
  xor a
  ld (_RAM_DF7F_), a
  ld (_RAM_DF80_TwoPlayerWinPhase), a
  ld (_RAM_DF81_), a
-:
  ret

_LABEL_7AF2_:
  ld a, (_RAM_D5CB_)
  or a
  jr nz, -
  ld a, $01
  ld (_RAM_D5CB_), a
  ld (_RAM_D5CC_PlayoffTileLoadFlag), a
  ld a, $14
  ld (_RAM_D963_SFXTrigger2), a
  ld (_RAM_D974_SFXTrigger), a
  jp _LABEL_B2B_

_LABEL_7B0B_:
  ld a, (_RAM_D581_)
  cp $A0
  jr nc, +
  ld a, (_RAM_D5CB_)
  inc a
  ld (_RAM_D5CB_), a
  cp $80
  jr c, +
  call _LABEL_B63_
+:
  ret

_LABEL_7B21_Decompress:
; Parameters:
; hl = source
; de = dest
; Returns hc = number of bytes decompressed (i.e. output size)
; Uses afbcde
; Relocatable (no absolute addresses used), but in the end there's another copy
; which gets relocated to RAM - this one executes in place.
  push de
    jr _get_next_mask_set_carry

_exit:
  pop hl    ; Get original de = dest address
  ld a, e   ; Return hc = de - original de = number of bytes written
  sub l
  ld c, a
  ld a, d
  sbc a, h
  ld h, a
  ret

_5x_use_a:
      ld b, a
_5x_use_b:
      ld a, e     ; get dest low byte
      sub (hl)    ; subtract next byte
      inc hl
      ld c, (hl)  ; and get the next byte as a counter
      push hl
        ld l, a   ; Save subtracted low byte
        ld a, d   ; High byte
        sbc a, b  ; Subtract carry (from offset subtraction) and b
        ld h, a   ; That's our offset + 1
        dec hl
        ld a, c   ; save c
        ldi       ; copy 3 bytes
        ldi
        ldi
        ld c, a   ; restore c
        ld b, $00
        inc bc    ; increment counter
        jr _copybcbytes

_2x3x4x_real: ; LZ: copy x+3 bytes from offset -(*p++ + (high-2)*256 - 2)
; Examples:
; 21 ee
; de = c118
; Copy 4 bytes from $c118 - 0*256 - $ee - 2 = $c028
; 30 02
; de = c1d0
; Copy 3 bytes from $c1d0 - 1*256 - 2 - 2 = $c0cc
; 40 76
; de = c2a8
; Copy 3 bytes from $c2a8 - 2*256 - $76 - 2 = $c030

      ld b, a     ; save value - in range 0-$2f?
      and $0F     ; c = x+2
      add a, $02
      ld c, a
      ld a, b
      and $30     ; Mask to high bits
      rlca        ; Get high nibble (0..2)
      rlca
      rlca
      rlca
      cpl         ; Invert (-1..-3)
      ld b, a     ; -> B
      ld a, (hl)  ; Get next byte
      push hl
        cpl         ; Subtract from de
        add a, e
        ld l, a
        ld a, d
        adc a, b    ; Also subtract b*256
        ld h, a
        dec hl

_copycplusonebytes:
        ld b, $00 ; counter = c
        inc c
        ldi       ; copy from hl to de
_copybcbytes:
        ldir      ; 1-257 bytes?
      pop hl
      inc hl      ; Next byte
    ex af, af'
    jr _get_next_mask_7bits

_5x: ; LZ: data bytes are offset, count.
; If x is $f, there is an extra offset-high byte first.
; Else, x is the high byte.
; Copy count+4 bytes from -(offset + 1).
; Examples:
; 5f 0f ff 06
; de = d180
; Copy 10 bytes from $d180 - $fff - 1 = $c180
; 53 26 01
; de = d1f2
; Copy 5 bytes from $d1f2 - $326 - 1 = $cecb
      cp $0F              ; Use x unless it's $f, when the next byte is the count
      jr nz, _5x_use_a
      ld b, (hl)          ; else b = next byte
      inc hl
      jr _5x_use_b

_2x3x4x:
      jr _2x3x4x_real

_highbitsetcompresseddata: ; %1 nn ooooo Copy n+2 bytes from offset -(n+o+2)
; e.g. $ad = %1 01 01101 = 1, 13
; de = $c120
; So 3 bytes of data is written from $c120 which is copied from $c120 - $1 - $d - $2 = c110
      cp $FF        ; All the bits set?
      jr z, _exit   ; If so, done

      and $60       ; Mask to bits %01100000
      rlca          ; Move to LSBs = n
      rlca
      rlca
      inc a         ; Add 1
      ld c, a

      ld a, (hl)    ; Get byte again
      push hl
        and $1F     ; Mask to $00011111 = o
        add a, c    ; Add c
        cpl         ; Two's complement the hard way..?
        add a, e    ; Overall: hl = de - a - 1
        ld l, a
        ld a, d
        adc a, -1
        ld h, a
        jr _copycplusonebytes

_copy_byte_and_get_next_mask_with_carry:
    ldi
_get_next_mask_set_carry:
    scf           ; Set carry, so as we shift we should not have zeroes in a even if it would otherwise
_get_next_mask:
    ld a, (hl)    ; Get byte
    inc hl        ; Point at next

    adc a, a      ; High bit 1 = compressed, 0 = raw byte follows. Unrolled loop here, plus carry in
    jr c, _compressed
    ldi
_get_next_mask_7bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_6bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_5bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_4bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_3bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_2bits:
    add a, a
    jr c, _compressed
    ldi
_get_next_mask_1bit:
    add a, a
    jr nc, _copy_byte_and_get_next_mask_with_carry

_compressed:
    jr z, _get_next_mask      ; If no set bits left, we're done with our flags byte (we got to the terminating bit)
    ex af, af'                ; Save a
_compressed_real:
      ld a, (hl)
      cp $80
      jr nc, _highbitsetcompresseddata

_highbitnotset:
      inc hl                  ; Point at next byte
      sub $70
      jr nc, _7x
      add a, $10
      jr c, _6x
      add a, $10
      jr c, _5x
      add a, $30
      jr c, _2x3x4x
      add a, $10
      jr nc, _0x

_1x: ; Repeat previous byte x+2 times
      ld b, $00
      sub $0F                 ; Check for $f
      jr z, +                 ; $f means there's another data byte
      add a, $11              ; c = x + 2
_duplicate_previous_byte_ba_times:
      ld c, a
      push hl
        ld l, e               ; repeat previous byte x times
        ld h, d
        dec hl
        ldi
        ldir
      pop hl
    ex af, af'
    jr _get_next_mask_7bits

+:    ld a, (hl)              ; next byte
      inc hl
      add a, $11              ; add 17
      jr nc, _duplicate_previous_byte_ba_times ; check for >255
      inc b                   ; if so, increment high counter byte
      jr _duplicate_previous_byte_ba_times

_7x: ; run of x+2 incrementing bytes, following last byte written. x = $f -> next byte is run length - 17.
; Examples:
; 70
; Run of 2 bytes following previous value
; 7f 03
; Run of 20 bytes following previous value
      sub $0F           ; $f means the next byte is the run length
      jr nz, +          ; else it is the run length (-2) itself
      ld a, (hl)
      inc hl
+:    add a, $11        ; a = x+2
      ld b, a
      dec de
      ld a, (de)        ; read previous byte
      inc de
-:    inc a             ; add 1
      ld (de), a        ; write
      inc de
      djnz -
    ex af, af'
--: jr _get_next_mask_7bits

_6x: ; LZ run in reverse order
; 6x oo
; Copy x+3 bytes, starting from -(o+1) and working backwards
; Examples:
; 64 0a
; de = d229
; Copy 7 bytes from $d229 - $0a - 1 = $d21e
; down to $d21e - 6 = $d218 inclusive
      add a, $03            ; b = x+3
      ld b, a
      ld a, (hl)            ; get next byte o
      push hl
        cpl                 ; invert bits
        scf                 ; set carry
        adc a, e            ; hl = de - o
        ld l, a
        ld a, d
        adc a, $FF
        ld h, a
-:      dec hl              ; move back
        ld a, (hl)          ; read byte
        ld (de), a          ; copy to de
        inc de
        djnz -
      pop hl
      inc hl
    ex af, af'
    jr --

_0x: ; Raw run:
; if (x == $f)
;   x = next byte
;   if (x = $ff)
;     x = following 2 bytes
;   else
;     x += 30
; else
;   x += 8
; Copy x raw bytes
; Examples:
; 03 [data x 11]
; 0f 0c [data x 42]
; 0f ff 12 34 [data x 13330]
      ld b, $00
      inc a                 ; increment
      jr z, _0f             ; That'd be $0f originally
      add a, $17            ; a = x+8
      ld c, a               ; that's our count
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldir                  ; copy c bytes total, but allow range 8..263
-:    jr _compressed_real

_0f:
      ld a, (hl)            ; read byte
      inc hl
      inc a                 ; $ff -> double-byte length
      jr z, _0fff
      add a, $1D            ; add 29
      ld c, a
      ld a, $08
      jr nc, _f             ; deal with >255
      inc b
__:   ldi                   ; copy 8 bytes at a time until bc <= 8
      ldi                   ; This allows us to have bc in the range 9..65544 but that can't actually happen?
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      cp c                  ; compare a to c
      jr c, _b
      dec b
      inc b
      jr nz, _b
      ldir
      jr -

_0fff:
      ld c, (hl)
      inc hl
      ld b, (hl)
      inc hl
      ld a, $08
      jr _b

; end of decompress code


_LABEL_7C67_:
  JumpToPagedFunction _LABEL_36E6B_

_LABEL_7C72_:
  JumpToPagedFunction _LABEL_36F9E_

_LABEL_7C7D_:
  call _LABEL_3214_BlankSpriteTable

  ; Load tile high bytes
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr z, +++
  cp TT_FormulaOne
  jr nz, +
  ; F1
  ld de, _DATA_3116_F1_TileHighBytesRunCompressed
  jp ++++
+:cp TT_RuffTrux
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
  ld de, _DATA_313B_Powerboats_TileHighBytesRunCompressed
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
  call _LABEL_7EBE_DecompressRunCompressed
+++++:

  ; Load tile data
  ; First page it in...
  ld hl, _DATA_3DC8_TrackTypeTileDataPages
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
  ld hl, _DATA_3DE4_TrackTypeTileDataPointerHi
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld d, a
  ld a, (_RAM_DB97_TrackType)
  ld hl, _DATA_3DDC_TrackTypeTileDataPointerLo
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
  call _LABEL_7B21_Decompress
  ; Then to VRAM
  call _LABEL_7F02_Copy3bppTileDataToVRAM

  ; Then extra tiles
  call _LABEL_663D_InitialisePlugholeTiles

  ; Car tiles
  ; Page...
  ld hl, _DATA_3EF4_CarTilesDataLookup_PageNumber
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
  ld hl, _DATA_3EFD_CarTileDataLookup_Hi
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld d, a                   ; -> d
  ld a, (_RAM_DB97_TrackType) ; One more time
  ld hl, _DATA_3EEC_CarTileDataLookup_Lo
  add a, l
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (hl)
  ld e, a                     ; -> e
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
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
  call _LABEL_7EBE_DecompressRunCompressed
  call _LABEL_7F4E_CarAndShadowSpriteTilesToVRAM
  call _LABEL_6704_LoadHUDTiles

  ; Look up the page number and page it in
  ld hl, _DATA_3E3A_TrackTypeDataPageNumbers
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
  ld hl, _DATA_C000_TrackData_SportsCars.BehaviourData
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld hl, _RAM_CC80_BehaviourData - 4
  ex de, hl
  call _LABEL_7B21_Decompress ; Decompress data there

  ld hl, _DATA_C000_TrackData_SportsCars.WallData
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld hl, _RAM_C800_WallData - 4
  ex de, hl
  call _LABEL_7B21_Decompress

  ; If it's the bathtub, write some stuff into the wall metadata
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
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
  ld a, >_DATA_C000_TrackData_SportsCars.TrackLayout1 ; Look up -> 0 @ 8004, 1 @ 8006, 2 @ 8008
  ld h, a
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld d, a
  ld hl, _RAM_C000_LevelLayout
  ex de, hl
  call _LABEL_7B21_Decompress

  ; Load palette
  ld a, (_RAM_DC54_IsGameGear)
  cp $00
  jr z, +
  ; Game Gear
  ld de, _DATA_C000_TrackData_SportsCars.GameGearPalette ; GG palette at +c
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
  ld a, :_DATA_17EC2_SMSPalettes
  ld (PAGING_REGISTER), a
  ld a, (_RAM_DB97_TrackType)
  sla a
  ld d, 0
  ld e, a
  ld hl, _DATA_17EC2_SMSPalettes
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
  CallPagedFunction _LABEL_1BEB1_ChangePoolTableColour

  ; Load "decorator" 1bpp tile data to RAM buffer
  ld hl, _DATA_C000_TrackData_SportsCars.DecoratorTiles
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
  ld hl, _DATA_C000_TrackData_SportsCars.UnknownData
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
  ld hl, _DATA_C000_TrackData_SportsCars.EffectsTiles
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
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
    ld a, $00
    out (PORT_VDP_DATA), a
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  jp _LABEL_7EA5_

+:
  ld de, $0000
--:
  push hl
    ld hl, _DATA_1c82_TileVRAMAddresses
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
    ld a, $00
    out (PORT_VDP_DATA), a
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
  ld a, $00 ; Tile $68
  out (PORT_VDP_ADDRESS), a
  ld a, $4D
  out (PORT_VDP_ADDRESS), a
  ld bc, $0020
-:
  xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
_LABEL_7EA5_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, +

  ; RuffTrux
  ld a, $04
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_UNUSED6
  out (PORT_VDP_REGISTER), a
  ret

+:; Other cars
  ld a, $00
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_UNUSED6
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_7EBE_DecompressRunCompressed:
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
    ld hl, _DATA_7F46_BitsLookup
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

_LABEL_7F02_Copy3bppTileDataToVRAM:
  ld a, $C8     ; When to stop: after $800 bytes
  ld (_RAM_DF1C_CopyToVRAMUpperBoundHi), a
  ld a, $00     ; VRAM address 0
  out (PORT_VDP_ADDRESS), a
  ld a, $40
  out (PORT_VDP_ADDRESS), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ld a, $C6     ; Stop after $600 bytes for RuffTrux
  ld (_RAM_DF1C_CopyToVRAMUpperBoundHi), a
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $60     ; VRAM address $2000
  out (PORT_VDP_ADDRESS), a
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
_DATA_7F46_BitsLookup: ; Index 0 = bit 7, 1 = bit 6, etc
.db $80 $40 $20 $10 $08 $04 $02 $01

_LABEL_7F4E_CarAndShadowSpriteTilesToVRAM:
  CallPagedFunction2 _LABEL_357F8_CarTilesToVRAM

  ; Then load the shadow tiles
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr z, +

  ; Normal cars
  ; VRAM address - tile $1a8 = shadow tile
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $75
  out (PORT_VDP_ADDRESS), a
  ld bc, 8*4 ; four tiles
  ld hl, _DATA_1C22_TileData_ShadowTopLeft
  call _LABEL_7FC9_EmitTileData3bpp

  ; VRAM address - tile $1ac = empty (not for RuffTrux)
  ; Tile is used in-game but in a weird way, and it's glitchy
  ld a, $80
  out (PORT_VDP_ADDRESS), a
  ld a, $75
  out (PORT_VDP_ADDRESS), a
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
  ld a, $60
  out (PORT_VDP_ADDRESS), a
  ld a, $41
  out (PORT_VDP_ADDRESS), a
  ld bc, $0008
  ld hl, _DATA_1C22_TileData_ShadowTopLeft
  call _LABEL_7FC9_EmitTileData3bpp
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $43
  out (PORT_VDP_ADDRESS), a
  ld bc, $0008
  ld hl, _DATA_1C3A_TileData_ShadowTopRight
  call _LABEL_7FC9_EmitTileData3bpp
  ld a, $60
  out (PORT_VDP_ADDRESS), a
  ld a, $43
  out (PORT_VDP_ADDRESS), a
  ld bc, $0008
  ld hl, _DATA_1C52_TileData_ShadowBottomLeft
  call _LABEL_7FC9_EmitTileData3bpp
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $51
  out (PORT_VDP_ADDRESS), a
  ld bc, $0008
  ld hl, _DATA_1C6A_TileData_ShadowBottomRight
  ; fall through and return
_LABEL_7FC9_EmitTileData3bpp:
  ; Emits bc rows of 3bpp data to the VDP
-:push bc
    ld b, $03 ; 3 bytes data
    ld c, PORT_VDP_DATA
    otir
    ld a, $00 ; 1 byte padding
    out (PORT_VDP_DATA), a
  pop bc
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

; Data from 7FDB to 7FEF (21 bytes)
.dsb 5 $FF

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

.BANK 1 SLOT 1
.ORG $0000

; Data from 7FF0 to 7FFF (16 bytes)
; Sega header
.define SEGA_HEADER_REGION_SMS_EXPORT $4
.define SEGA_HEADER_SIXE_256KB $0
.db "TMR SEGA", $FF, $FF
.dw $E352 ; checksum
.dw $0000 ; Product number
.db $00 ; Version
.db SEGA_HEADER_REGION_SMS_EXPORT << 4 | SEGA_HEADER_SIXE_256KB ; SMS export, 256KB checksum

.BANK 2
.ORG $0000

_LABEL_8000_Main:
  di
  ld hl, STACK_TOP
  ld sp, hl
  ld a, $00
  ld (_RAM_DC3C_IsGameGear), a
  call _LABEL_AFAE_RamCodeLoader
  ld a, :_DATA_3ED49_SplashScreenCompressed ; $0F
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_3ED49_SplashScreenCompressed ; $AD49 ; Location of compressed data - splash screen implementation, goes up to 3F752, decompresses to 3680 bytes
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000 ; loads splash screen code to RAM
  call _RAM_C000_DecompressionTemporaryBuffer ; Splash screen code is here

  call _LABEL_AFAE_RamCodeLoader ; Maybe the splash screen broke it?
  call _LABEL_B01D_SquinkyTennisHook

_LABEL_8021_MenuScreenEntryPoint:
  ; Menu screen changes start here
  call _LABEL_AFAE_RamCodeLoader
  ld a, 1
  ld (_RAM_DC3E_InMenus), a
  xor a
  ld (_RAM_D6D5_InGame), a
  call _LABEL_BD00_InitialiseVDPRegisters
  call _LABEL_BB6C_ScreenOff
  call _LABEL_BB49_SetMenuHScroll
  call _LABEL_B44E_BlankMenuRAM
  call _LABEL_BB5B_SetBackdropToColour0
  call _LABEL_BF2E_LoadMenuPalette_SMS
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, $38
  out (PORT_GG_LinkStatus), a
  ; Call the relevant menu initialiser
+:ld a, (_RAM_DBCD_MenuIndex)
  or a
  jr nz, +
  call _LABEL_8114_Menu0
  jp ++
+:dec a
  jr nz, +
  call _LABEL_82DF_Menu1
  jp ++
+:dec a
  jr nz, +
  call _LABEL_8507_Menu2
  jp ++
+:dec a
  jr nz, +
  call _LABEL_866C_Menu3
  jp ++
+:dec a
  jr nz, +
  call _LABEL_8A38_Menu4
  jp ++
+:dec a
  jr nz, ++
  ; Menu 5 only if course select > 0
  ld a, (_RAM_DBD8_CourseSelectIndex)
  or a
  jr nz, +
  call _LABEL_82DF_Menu1
  jp ++
+:call _LABEL_84AA_Menu5
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
  call _LABEL_90FF_ReadControllers
  call _LABEL_80E6_CallMenuScreenHandler
  ld a, (_RAM_D6D5_InGame)
  dec a
  jr z, +
  ; Staying in menus
  ld a, (_RAM_D6D4_)
  or a
  CallRamCodeIfZFlag _LABEL_3BB26_Trampoline_MenuMusicFrameHandler
  nop ; Hook point?
  nop
  nop
  call _LABEL_B45D_
  jp -

+:; Menu -> game
  di
  ld a, 0
  ld (_RAM_DC3E_InMenus), a
  jp _RAM_DBC0_EnterGameTrampoline  ; Code is loaded from _LABEL_75_EnterGameTrampolineImpl

; Jump Table from 80BE to 80E5 (20 entries, indexed by _RAM_D699_MenuScreenIndex)
_DATA_80BE_MenuScreenHandlers:
.dw _LABEL_80FC_Handler_MenuScreen_None
.dw _LABEL_8BAB_Handler_MenuScreen_Title 
.dw _LABEL_8C35_Handler_MenuScreen_SelectPlayerCount 
.dw _LABEL_8CE7_Handler_MenuScreen_OnePlayerSelectCharacter
.dw _LABEL_8D2B_Handler_MenuScreen_RaceName
.dw _LABEL_80FC_Handler_MenuScreen_None ; Unused5
.dw _LABEL_8D79_Handler_MenuScreen_Qualify
.dw _LABEL_8DCC_Handler_MenuScreen_WhoDoYouWantToRace
.dw _LABEL_8E15_Handler_MenuScreen_StorageBox
.dw _LABEL_8E97_Handler_MenuScreen_OnePlayerTrackIntro
.dw _LABEL_8EF0_Handler_MenuScreen_OnePlayerTournamentResults
.dw _LABEL_8F93_Handler_MenuScreen_UnknownB
.dw _LABEL_8FC4_Handler_MenuScreen_LifeList
.dw _LABEL_9074_Handler_MenuScreen_UnknownD
.dw _LABEL_B09F_Handler_MenuScreen_TwoPlayerSelectCharacter
.dw _LABEL_8C35_Handler_MenuScreen_SelectPlayerCount ; shared
.dw _LABEL_B56D_MenuScreen_TrackSelect
.dw _LABEL_B6B1_MenuScreen_TwoPlayerResult
.dw _LABEL_B84D_MenuScreen_TournamentChampion
.dw _LABEL_B06C_MenuScreen_OnePlayerMode

_LABEL_80E6_CallMenuScreenHandler:
  call _LABEL_9167_ScreenOff
  ld a, (_RAM_D699_MenuScreenIndex)
  sla a
  ld c, a
  ld b, $00
  ld hl, _DATA_80BE_MenuScreenHandlers
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ex de, hl
  call + ; Invoke looked-up function

; 1st entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_80FC_Handler_MenuScreen_None:
_LABEL_80FC_EndMenuScreenHandler:
  call _LABEL_915E_ScreenOn ; turn screen back on
  ret

+:jp (hl)

; Data from 8101 to 8113 (19 bytes) - dead code?
.db $3A $80 $D6 $E6 $30 $20 $0B $CD $F4 $B1 $3E $8E $32 $41 $D7 $C3
.db $2F $DB $C9

_LABEL_8114_Menu0: ; init functions, need renaming
  call _LABEL_BB85_ScreenOn
  call _LABEL_B44E_BlankMenuRAM
  ld a, MenuScreen_Title
  ld (_RAM_D699_MenuScreenIndex), a
  ld (_RAM_D7B3_), a
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_B337_BlankTiles
  call _LABEL_9400_BlankSprites
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_BAD5_LoadMenuLogoTiles
  call _LABEL_BDED_LoadMenuLogoTilemap
  call _LABEL_BB13_
  call _LABEL_B323_Populate_RAM_DBFE_
  call _LABEL_8CDB_
  ld a, $59
  ld (_RAM_DBD4_), a
  ld (_RAM_DBD5_), a
  ld (_RAM_DBD6_), a
  ld (_RAM_DBD7_), a
  ld a, $02
  ld (_RAM_DC3A_), a
  xor a
  ld (_RAM_D7B7_), a
  ld (_RAM_D7B8_), a
  ld (_RAM_D7B9_), a
  ld (_RAM_D7B4_IsHeadToHead), a
  ld (_RAM_DC3F_GameMode), a
  ld (_RAM_DC3D_IsHeadToHead), a
  ld (_RAM_DBD8_CourseSelectIndex), a
  ld (_RAM_DC3B_IsTrackSelect), a
  ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
  ld (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect), a
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  ld (_RAM_D6C6_), a
  ld (_RAM_D6C0_), a
  ld (_RAM_DC0A_), a
  ld (_RAM_DC34_IsTournament), a
  ld (_RAM_DC36_), a
  ld (_RAM_DC37_), a
  call _LABEL_A778_InitDisplayCaseData
  call _LABEL_B9B3_
  ld hl, _RAM_DC21_
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
  ld (_RAM_D6C4_), a
  ld a, $18
  ld (_RAM_D6AB_), a
  ld a, $01
  ld (_RAM_DC35_TournamentRaceNumber), a
  ld a, $1A
  ld (_RAM_DC39_), a
  call _LABEL_BF2E_LoadMenuPalette_SMS
  ld a, (_RAM_DC3C_IsGameGear)
  ld (_RAM_DC40_), a
  ld c, $01
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_BB75_
  ret

_LABEL_81C1_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_SelectPlayerCount
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_9400_BlankSprites
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_BAD5_LoadMenuLogoTiles
  call _LABEL_BDED_LoadMenuLogoTilemap
  ld c, $07
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, $00
  ld (_RAM_D6C7_), a
  call _LABEL_BB95_LoadIconMenuGraphics
  call _LABEL_BC0C_
  call _LABEL_A4B7_
  call _LABEL_9317_InitialiseHandSprites
  call _LABEL_BDB8_
  ld a, $00
  ld (_RAM_D6A0_MenuSelection), a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  call _LABEL_A673_
  call _LABEL_BB75_
  ret

_LABEL_8205_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_OnePlayerSelectCharacter
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $00
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call _LABEL_B2DC_
  call _LABEL_B2F3_DrawHorizontalLines_CharacterSelect
  call _LABEL_987B_BlankTile1B4
  call _LABEL_9434_
  call _LABEL_988D_
  xor a
  ld (_RAM_D6B1_), a
  ld (_RAM_D6B8_), a
  ld (_RAM_D6B7_), a
  ld (_RAM_D6B9_), a
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_)
  call _LABEL_9F40_

  call _LABEL_B375_ConfigureTilemapRect_5x6_24
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 13, 8 ; for GG
  jr ++
+:TilemapWriteAddressToHL 9, 9 ; for SMS
++:call _LABEL_BCCF_EmitTilemapRectangleSequence

  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6A4_), a
  ld (_RAM_D6B4_), a
  ld (_RAM_D6B0_), a
  call _LABEL_BDA6_
  ld c, $02
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_A67C_
  call _LABEL_97EA_DrawDriverPortraitColumn
  call _LABEL_B3AE_
  call _LABEL_BB75_
  ret

_LABEL_8272_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_RaceName
  ld (_RAM_D699_MenuScreenIndex), a
  call _LABEL_B2DC_ ; blank screen
  TilemapWriteAddressToHL 0, 5
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_95AF_DrawHorizontalLineIfSMS
  ld a, TT_Powerboats
  call _LABEL_B478_SelectPortraitPage
  ld hl, _DATA_1F3E4_Tiles_Portrait_Powerboats
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $24
  ld de, 80 * 8 ; 80 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

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
  call _LABEL_BCCF_EmitTilemapRectangleSequence

  ld c, $05
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, :_TEXT_3ECC9_VEHICLE_NAME_POWERBOATS
  ld (_RAM_D741_RequestedPageIndex), a
  TilemapWriteAddressToHL 8, 22
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, 16
  ld hl, _TEXT_3ECC9_VEHICLE_NAME_POWERBOATS
  CallRamCode _LABEL_3BC6A_EmitText
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  ld hl, $0170
  ld (_RAM_D6AB_), hl
  xor a
  ld (_RAM_D6C1_), a
  call _LABEL_BB75_
  ret

_LABEL_82DF_Menu1:
  ld a, MenuScreen_Qualify
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $FF
  ld (_RAM_D6C4_), a
  ld a, (_RAM_DBCE_)
  or a
  jr z, +
  jp _LABEL_8360_

+:
  call _LABEL_BB85_ScreenOn
  call _LABEL_B2DC_
  call _LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  ld a, $0B
  ld (_RAM_D6B7_), a
  ld a, $01
  ld (_RAM_D6B4_), a
  ld a, $07
  ld (_RAM_D6B1_), a
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_)
  ld (_RAM_DBD3_), a
  add a, $01
  call _LABEL_9F40_
  ld hl, $7A1A
  call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
  TilemapWriteAddressToHL 7, 20
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0012
  ld hl, _TEXT_834E_FailedToQualify
  call _LABEL_A5B0_EmitToVDP_Text
  ld c, $08
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, $01C4
  jr ++

+:
  ld hl, $0200
++:
  ld (_RAM_D6AB_), hl
  call _LABEL_BB75_
  ret

; Data from 834E to 835F (18 bytes)
_TEXT_834E_FailedToQualify:
.asc "FAILED TO QUALIFY!" ; $05 $00 $08 $0B $04 $03 $0E $13 $1A $0E $10 $14 $00 $0B $08 $05 $18 $B4

_LABEL_8360_:
  call _LABEL_BB85_ScreenOn
  call _LABEL_B2DC_
  call _LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  ld a, $03
  ld (_RAM_DC09_Lives), a
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +
  ld a, (_RAM_DBD8_CourseSelectIndex)
  add a, $01
  ld (_RAM_DBD8_CourseSelectIndex), a
+:TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_)
  call _LABEL_9F40_
  ld hl, $7A9A
  call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
  TilemapWriteAddressToHL 11, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0009
  ld hl, _TEXT_83ED_Qualified
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 9, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000E
  ld hl, _TEXT_83F6_ForChallenge
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr z, +
  TilemapWriteAddressToHL 7, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0012
  ld hl, _TEXT_8404_ForHeadToHead
  call _LABEL_A5B0_EmitToVDP_Text
+:
  TilemapWriteAddressToHL 12, 22
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, _TEXT_8416_Lives
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, $1A
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld c, $06
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld hl, $0190
  ld (_RAM_D6AB_), hl
  call _LABEL_BB75_
  ret

; Data from 83ED to 83F5 (9 bytes)
_TEXT_83ED_Qualified:
.asc "QUALIFIED" ; $10 $14 $00 $0B $08 $05 $08 $04 $03

; Data from 83F6 to 8403 (14 bytes)
_TEXT_83F6_ForChallenge:
.asc "FOR CHALLENGE!" ; $05 $1A $11 $0E $02 $07 $00 $0B $0B $04 $0D $06 $04 $B4

; Data from 8404 to 8415 (18 bytes)
_TEXT_8404_ForHeadToHead:
.asc "FOR HEAD TO HEAD !" ; $05 $1A $11 $0E $07 $04 $00 $03 $0E $13 $1A $0E $07 $04 $00 $03 $0E $B4

; Data from 8416 to 841B (6 bytes)
_TEXT_8416_Lives:
.asc "LIVES " ; $0B $08 $15 $04 $12 $0E

_LABEL_841C_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_WhoDoYouWantToRace
  ld (_RAM_D699_MenuScreenIndex), a
  call _LABEL_B337_BlankTiles
  call _LABEL_B2DC_
  call _LABEL_A673_
  call _LABEL_B2F3_DrawHorizontalLines_CharacterSelect
  call _LABEL_987B_BlankTile1B4
  call _LABEL_9434_
  call _LABEL_988D_
  xor a
  ld (_RAM_D6B1_), a
  ld (_RAM_D6C0_), a
  ld (_RAM_D6B8_), a
  ld (_RAM_D6B7_), a
  ld (_RAM_D6C1_), a
  xor a
  ld (_RAM_D6C3_), a
  call _LABEL_AC1E_
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D697_), a
  ld (_RAM_D6B4_), a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6B0_), a
  ld a, (_RAM_DBFC_)
  ld (_RAM_D6AD_), a
  ld a, (_RAM_DBFD_)
  ld (_RAM_D6AE_), a
  call _LABEL_B3AE_
  ld c, $02
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DBFB_)
  ld (_RAM_D6A2_), a
  ld c, a
  ld b, $00
  call _LABEL_97EA_DrawDriverPortraitColumn
  call _LABEL_BB75_
  ret

_LABEL_8486_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_StorageBox
  ld (_RAM_D699_MenuScreenIndex), a
  call _LABEL_B2BB_
  ld c, $07
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_A787_
  call _LABEL_AD42_DrawDisplayCase
  call _LABEL_B230_DisplayCase_BlankRuffTrux
  xor a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  call _LABEL_BB75_
  ret

_LABEL_84AA_Menu5:
  call _LABEL_BB85_ScreenOn
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, _LABEL_84C7_
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jp nz, _LABEL_8F73_
  call _LABEL_B269_
  cp $1A
  jr nz, _LABEL_84C7_
  call _LABEL_B877_
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_84C7_:
  ld a, MenuScreen_OnePlayerTrackIntro
  ld (_RAM_D699_MenuScreenIndex), a
  call _LABEL_B2BB_
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +
  call _LABEL_A7B3_
+:
  ld a, $01
  ld (_RAM_D6C3_), a
  call _LABEL_AC1E_
  call _LABEL_ACEE_
  call _LABEL_AB5B_GetPortraitSource_CourseSelect
  call _LABEL_AB86_Decompress3bppTiles_Index100
  call _LABEL_ABB0_
  call _LABEL_BA3C_LoadColouredCirclesTilesToIndex150
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6C1_), a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  ld c, $05
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_BB75_
  ret

_LABEL_8507_Menu2:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_OnePlayerTournamentResults
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_9400_BlankSprites
  call _LABEL_90CA_BlankTiles_BlankControls
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_959C_LoadPunctuationTiles
  call _LABEL_9448_LoadHeaderTiles
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  call _LABEL_94AD_DrawHeaderTilemap
  jr ++
+:call _LABEL_94F0_DrawHeaderTextTilemap
++:
  call _LABEL_B305_DrawHorizontalLine_Top
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_)
  ld c, a
  ld a, (_RAM_DBCF_LastRacePosition)
  cp c
  jr nc, +
  ld c, $00
  jp ++

+:
  ld c, $01
++:
  ld a, (_RAM_DBD4_)
  add a, c
  call _LABEL_9F40_
  TileWriteAddressToHL $42
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_)
  ld c, a
  ld a, (_RAM_DBD0_HeadToHeadLost2)
  cp c
  jr nc, +
  ld c, $00
  jp ++

+:
  ld c, $01
++:
  ld a, (_RAM_DBD5_)
  add a, c
  call _LABEL_9F40_
  TileWriteAddressToHL $60
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_)
  ld c, a
  ld a, (_RAM_DBD1_)
  cp c
  jr nc, +
  ld c, $00
  jp ++

+:
  ld c, $01
++:
  ld a, (_RAM_DBD6_)
  add a, c
  call _LABEL_9F40_
  TileWriteAddressToHL $7e
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3A_)
  ld c, a
  ld a, (_RAM_DBD2_)
  cp c
  jr nc, +
  ld c, $00
  jp ++

+:
  ld c, $01
++:
  ld a, (_RAM_DBD7_)
  add a, c
  call _LABEL_9F40_
  call _LABEL_A877_
  TilemapWriteAddressToHL 12, 7
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_85EC_Results
  call _LABEL_A5B0_EmitToVDP_Text
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6C1_), a
  ld c, $06
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr nz, +
  ld a, (_RAM_DC39_)
  cp $1D
  jr z, +
  ld a, (_RAM_DC0A_)
  add a, $01
  ld (_RAM_DC0A_), a
  jr ++

+:
  xor a
  ld (_RAM_DC0A_), a
++:
  call _LABEL_BB75_
  ret

; Data from 85EC to 85F3 (8 bytes)
_TEXT_85EC_Results:
.asc "RESULTS-" ; $11 $04 $12 $14 $0B $13 $12 $B5

_LABEL_85F4_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_UnknownB
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, $0E
  call _LABEL_B2DC_
  call _LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  ld a, $0B
  ld (_RAM_D6B7_), a
  ld a, $01
  ld (_RAM_D6B4_), a
  ld a, $07
  ld (_RAM_D6B1_), a
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_D6C4_)
  ld c, a
  ld b, $00
  ld hl, _RAM_DBD5_
  add hl, bc
  ld a, (hl)
  ld (_RAM_DBD3_), a
  ld a, $59
  ld (hl), a
  ld a, (_RAM_DBD3_)
  add a, $01
  call _LABEL_9F40_
  ld hl, $7A1A
  call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
  ld a, (_RAM_DBD3_)
  srl a
  srl a
  srl a
  ld c, a
  ld b, $00
  ld hl, _RAM_DBFE_
  add hl, bc
  ld a, $5A
  ld (hl), a
  ld a, (_RAM_D6C4_)
  add a, $01
  ld (_RAM_D6B9_), a
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  ld c, $09
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_BB75_
  ret

_LABEL_866C_Menu3:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_LifeList
  ld (_RAM_D699_MenuScreenIndex), a
  call _LABEL_B2DC_
  call _LABEL_B305_DrawHorizontalLine_Top
  xor a
  ld (_RAM_D6B8_), a
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC38_)
  cp $02
  jr nz, +
  ld c, $00
  jp ++

+:
  ld c, $01
++:
  ld a, (_RAM_DBD4_)
  add a, c
  call _LABEL_9F40_
  ld hl, $7A9A
  call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
  ld a, (_RAM_DC38_)
  dec a
  jr z, _LABEL_8717_
  dec a
  jp z, _LABEL_876B_
  dec a
  jp z, _LABEL_87E9_
  TilemapWriteAddressToHL 9, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000E
  ld hl, _TEXT_882E_OneLifeLost
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22 ; SMS
  jr ++
+:TilemapWriteAddressToHL 12, 21 ; GG
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, _TEXT_884A_Lives
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, $1A
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  call _LABEL_A673_
  ld a, (_RAM_DC09_Lives)
  add a, $1B
  ld (_RAM_D701_SpriteN), a
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, $96
  ld (_RAM_D6E1_SpriteX), a
  ld a, $B0
  ld (_RAM_D721_SpriteY), a
  jr ++

+:
  ld a, $90
  ld (_RAM_D6E1_SpriteX), a
  ld a, $A8
  ld (_RAM_D721_SpriteY), a
++:
  call _LABEL_93CE_UpdateSpriteTable
  ld c, $0A
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, $80
  ld (_RAM_D6AB_), a
  jp _LABEL_8826_

_LABEL_8717_:
  TilemapWriteAddressToHL 9, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000E
  ld hl, _TEXT_883C_GameOver
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, _TEXT_8850_Level
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DBF1_RaceNumberText + 5)
  cp $0E ; '0'?
  jr z, +
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
+:
  ld a, (_RAM_DBF1_RaceNumberText + 6)
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld c, $08
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, $E2
  jr ++

+:
  ld a, $FF
++:
  ld (_RAM_D6AB_), a
  jp _LABEL_8826_

_LABEL_876B_:
  TilemapWriteAddressToHL 10, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, _TEXT_8856_YouMadeIt
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 10, 12
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, _TEXT_8862_ExtraLife
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, _TEXT_884A_Lives
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, $1A
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld a, (_RAM_DC09_Lives)
  cp $09
  jr z, +
  add a, $01
+:
  ld (_RAM_DC09_Lives), a
  call _LABEL_A673_
  ld a, (_RAM_DC09_Lives)
  add a, $1A
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
  call _LABEL_93CE_UpdateSpriteTable
  ld c, $06
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, $C8
  ld (_RAM_D6AB_), a
  jp _LABEL_8826_

_LABEL_87E9_:
  TilemapWriteAddressToHL 11, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0009
  ld hl, _TEXT_886E_NoBonus
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 12, 22
  jr ++
+:TilemapWriteAddressToHL 12, 21
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, _TEXT_884A_Lives
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC09_Lives)
  add a, $1A
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld c, $0A
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, $80
  ld (_RAM_D6AB_), a
_LABEL_8826_:
  xor a
  ld (_RAM_D6AC_), a
  call _LABEL_BB75_
  ret

; Data from 882E to 883B (14 bytes)
_TEXT_882E_OneLifeLost:
.asc "ONE LIFE LOST!" ; $1A $0D $04 $0E $0B $08 $05 $04 $0E $0B $1A $12 $13 $B4

; Data from 883C to 8849 (14 bytes)
_TEXT_883C_GameOver:
.asc "  GAME OVER!  " ; $0E $0E $06 $00 $0C $04 $0E $1A $15 $04 $11 $B4 $0E $0E

; Data from 884A to 884F (6 bytes)
_TEXT_884A_Lives:
.asc "LIVES " ; $0B $08 $15 $04 $12 $0E

; Data from 8850 to 8855 (6 bytes)
_TEXT_8850_Level:
.asc "LEVEL " ; $0B $04 $15 $04 $0B $0E

; Data from 8856 to 8861 (12 bytes)
_TEXT_8856_YouMadeIt:
.asc "YOU MADE IT!" ; $18 $1A $14 $0E $0C $00 $03 $04 $0E $08 $13 $B4

; Data from 8862 to 886D (12 bytes)
_TEXT_8862_ExtraLife:
.asc " EXTRA LIFE " ; $0E $04 $17 $13 $11 $00 $0E $0B $08 $05 $04 $0E

; Data from 886E to 8876 (9 bytes)
_TEXT_886E_NoBonus:
.asc "NO  BONUS" ; $0D $1A $0E $0E $01 $1A $0D $14 $12

_LABEL_8877_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_UnknownD
  ld (_RAM_D699_MenuScreenIndex), a
  call _LABEL_B2DC_
  call _LABEL_B305_DrawHorizontalLine_Top
  ld a, TT_Unknown9
  call _LABEL_B478_SelectPortraitPage
  ld hl, _DATA_2AB4D_Tiles_Portrait_RuffTrux
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $100
  ld de, 80 * 8 ; 80 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

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
  call _LABEL_BCCF_EmitTilemapRectangleSequence

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 8, 26 ; SMS
  jr ++
+:TilemapWriteAddressToHL 8, 22 ; GG
++:call _LABEL_B35A_VRAMAddressToHL

  ld a, :_TEXT_3ED39_VEHICLE_NAME_RUFFTRUX
  ld (_RAM_D741_RequestedPageIndex), a
  ld bc, 16
  ld hl, _TEXT_3ED39_VEHICLE_NAME_RUFFTRUX
  CallRamCode _LABEL_3BC6A_EmitText
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 9, 9
  ld hl, _TEXT_8929_TripleWin
  call _LABEL_B3A4_EmitToVDPAtDE_Text
  TilemapWriteAddressToDE 9, 11
  ld hl, _TEXT_8937_BonusRace
  call _LABEL_B3A4_EmitToVDPAtDE_Text
  jr ++

+:
  TilemapWriteAddressToDE 9, 10
  ld hl, _TEXT_8929_TripleWin
  call _LABEL_B3A4_EmitToVDPAtDE_Text
  TilemapWriteAddressToDE 9, 12
  ld hl, _TEXT_8937_BonusRace
  call _LABEL_B3A4_EmitToVDPAtDE_Text
++:
  TilemapWriteAddressToDE 9, 13
  ld hl, _TEXT_8945_BeatTheClock
  call _LABEL_B3A4_EmitToVDPAtDE_Text
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  ld (_RAM_D6C1_), a
  ld c, $05
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_BB75_
  ret

; Data from 8929 to 8936 (14 bytes)
_TEXT_8929_TripleWin:
.asc "TRIPLE WIN !!!" ; $13 $11 $08 $0F $0B $04 $0E $16 $08 $0D $0E $B4 $B4 $B4

; Data from 8937 to 8944 (14 bytes)
_TEXT_8937_BonusRace:
.asc "  BONUS RACE  " ; $0E $0E $01 $1A $0D $14 $12 $0E $11 $00 $02 $04 $0E $0E

; Data from 8945 to 8952 (14 bytes)
_TEXT_8945_BeatTheClock:
.asc "BEAT THE CLOCK" ; $01 $04 $00 $13 $0E $13 $07 $04 $0E $02 $0B $1A $02 $0A

_LABEL_8953_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_TwoPlayerSelectCharacter
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $01
  ld (_RAM_D7B4_IsHeadToHead), a
  xor a
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call _LABEL_B2DC_
  call _LABEL_B2F3_DrawHorizontalLines_CharacterSelect
  call _LABEL_987B_BlankTile1B4
  call _LABEL_9434_
  call _LABEL_988D_
  call _LABEL_A673_

  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_)
  call _LABEL_9F40_
  ld a, (_RAM_DBD5_)
  call _LABEL_9F40_

  TilemapWriteAddressToHL 10, 9
  call _LABEL_B8C9_EmitTilemapRectangle_5x6_24

  ld a, $42
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  TilemapWriteAddressToHL 17, 9
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, $30
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6CD_), a
  ld (_RAM_D6AC_), a
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
  call _LABEL_BDA6_
  ld a, $02
  ld (_RAM_D688_), a
  call _LABEL_A67C_
  call _LABEL_97EA_DrawDriverPortraitColumn
  call _LABEL_B3AE_
  ld c, $02
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_BB75_
  ret

_LABEL_89E2_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_TwoPlayerGameType
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_9400_BlankSprites
  call _LABEL_90CA_BlankTiles_BlankControls
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_959C_LoadPunctuationTiles
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call _LABEL_9448_LoadHeaderTiles
  call _LABEL_94AD_DrawHeaderTilemap
  call _LABEL_B305_DrawHorizontalLine_Top
  ld a, $01
  ld (_RAM_D6C7_), a
  ld (_RAM_D7B3_), a
  call _LABEL_BB95_LoadIconMenuGraphics
  call _LABEL_BC0C_
  call _LABEL_A530_DrawChooseGameText
  ld c, $07
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_9317_InitialiseHandSprites
  xor a
  ld (_RAM_D6A0_MenuSelection), a
  ld (_RAM_D6AC_), a
  call _LABEL_A673_
  call _LABEL_BB75_
  ret

_LABEL_8A30_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_TrackSelect
  jp +

_LABEL_8A38_Menu4:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_TwoPlayerResult
+:ld (_RAM_D699_MenuScreenIndex), a
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_9400_BlankSprites
  call _LABEL_90CA_BlankTiles_BlankControls
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_959C_LoadPunctuationTiles
  call _LABEL_A296_LoadHandTiles
  call _LABEL_BA3C_LoadColouredCirclesTilesToIndex150
  call _LABEL_BA4F_LoadMediumNumberTiles
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TrackSelect
  jr z, ++
+:
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call _LABEL_9448_LoadHeaderTiles
  call _LABEL_94AD_DrawHeaderTilemap
  call _LABEL_B305_DrawHorizontalLine_Top
++:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr nz, +
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBCF_LastRacePosition)
  ld c, a
  ld a, (_RAM_DBD4_)
  add a, c
  call _LABEL_9F40_
  ld a, (_RAM_DBD0_HeadToHeadLost2)
  ld c, a
  ld a, (_RAM_DBD5_)
  add a, c
  call _LABEL_9F40_
  jp ++

+:
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_)
  call _LABEL_9F40_
  ld a, (_RAM_DBD5_)
  call _LABEL_9F40_
++:
  call _LABEL_B375_ConfigureTilemapRect_5x6_24
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 9, 5
  jp ++

+:TilemapWriteAddressToHL 9, 15
++:
  ld a, (_RAM_DC3C_IsGameGear)
  cp $01
  jr z, +
  ; Add two rows for SMS -> 9, 13
  ld bc, $0080
  add hl, bc
+:
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, $42
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 18, 5
  jp ++
+:TilemapWriteAddressToHL 18, 15
++:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0080 ; Add 2 rows for SMS -> 18, 13
  add hl, bc
+:
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  call _LABEL_A355_
  call _LABEL_B9ED_
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  ld (_RAM_D6C1_), a
  ld (_RAM_D693_), a
  ld (_RAM_D6CC_), a
  ld (_RAM_D6CE_), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jp z, _LABEL_8B89_
  ld a, (_RAM_DC34_IsTournament)
  cp $01
  jr z, +
  call _LABEL_A673_
  ld c, $05
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_9317_InitialiseHandSprites
  ld hl, _DATA_2B356_SpriteNs_HandLeft
  CallRamCode _LABEL_3BBB5_PopulateSpriteNs
  jp _LABEL_8B9D_

+:
  call _LABEL_B785_
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr z, _LABEL_8B55_
-:
  ld a, $CC
  out (PORT_GG_LinkSend), a
  ld a, (_RAM_DC47_GearToGear_OtherPlayerControls1)
  cp $3F
  jr z, -
  ld (_RAM_D6CF_), a
  jr +

_LABEL_8B55_:
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  cp $CC
  jr nz, _LABEL_8B55_
  ld a, (_RAM_D6CF_)
  out (PORT_GG_LinkSend), a
+:
  call _LABEL_AF5D_BlankControlsRAM
  ld a, (_RAM_D6CF_)
  ld c, a
  ld b, $00
  ld hl, _RAM_DC2C_
  add hl, bc
  ld a, $01
  ld (hl), a
  ld a, c
  call _LABEL_B213_
  ld a, c
  add a, $01
  call _LABEL_AB68_GetPortraitSource_TrackType
  call _LABEL_AB9B_Decompress3bppTiles_Index160
  call _LABEL_ABB0_
  ld c, $05
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  jp _LABEL_8B9D_

_LABEL_8B89_:
  ld c, $0B
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_A0B4_
  call _LABEL_B7FF_
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr nz, _LABEL_8B9D_
  call _LABEL_B785_
_LABEL_8B9D_:
  call _LABEL_A14F_
  xor a
  ld (_RAM_D6CB_), a
  call _LABEL_BF2E_LoadMenuPalette_SMS
  call _LABEL_BB75_
  ret

; 2nd entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8BAB_Handler_MenuScreen_Title:
  call _LABEL_AF10_
  ld a, (_RAM_D7BB_)
  or a
  jr nz, _LABEL_8C2C_
  call _LABEL_BE1A_DrawCopyrightText
  call _LABEL_918B_
  call _LABEL_92CB_
  call _LABEL_B9C4_
  call _LABEL_B484_CheckTitleScreenCheatCodes
  ld a, (_RAM_D6D0_TitleScreenCheatCodeCounter_CourseSelect)
  cp $09 ; full length
  jr z, _LABEL_8C23_StartCourseSelect ; cheat 1 entered

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
  call _LABEL_B505_UpdateHardModeText

  ld a, (_RAM_D6AB_)
  or a
  jr z, +
  sub $01
  ld (_RAM_D6AB_), a

  jp +++

+:; No hard mode, or _RAM_D6AB_ = 0
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK
  jr z, ++
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
  jr nz, _LABEL_8C2C_
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_81C1_
+++:
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_8C23_StartCourseSelect:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_B70B_
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_8C2C_:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_8953_
  jp _LABEL_80FC_EndMenuScreenHandler

; 3rd entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8C35_Handler_MenuScreen_SelectPlayerCount:
  call _LABEL_B9C4_
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr z, +
  call _LABEL_B433_
  ld hl, (_RAM_D6AB_)
  inc hl
  ld (_RAM_D6AB_), hl
  ld a, h
  cp $03
  jr nz, +
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_8114_Menu0
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_8CA2_
  jp +

; Data from 8C5D to 8C5F (3 bytes)
.db $CD $B1 $8C

+:
  ld a, (_RAM_D6A0_MenuSelection)
  or a
  jp z, _LABEL_80FC_EndMenuScreenHandler
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jp nz, _LABEL_80FC_EndMenuScreenHandler
  ; Select
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr z, ++
  ld a, (_RAM_D6A0_MenuSelection)
  dec a
  jr nz, +
  call _LABEL_AFCD_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_8953_
  jp _LABEL_80FC_EndMenuScreenHandler

++:
  ld a, (_RAM_D6A0_MenuSelection)
  dec a
  jr nz, +
  ld a, $01
  ld (_RAM_DC34_IsTournament), a
  call _LABEL_8A30_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_8A30_
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_8CA2_:
  ld a, (_RAM_D680_Player1Controls_Menus) ; Check if any buttons we care about are pressed
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  cp BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  jr nz, +
  ; None pressed
  call _LABEL_B9A3_
  jp ++

+:; No - copy buttons
  ld a, (_RAM_D680_Player1Controls_Menus)
  ld (_RAM_D6C9_ControllingPlayersLR1Buttons), a
++:
  and BUTTON_L_MASK ; $04
  jr z, +
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_R_MASK ; $08
  jr z, ++
  ret

+:
  ld hl, _DATA_2B356_SpriteNs_HandLeft
  CallRamCode _LABEL_3BBB5_PopulateSpriteNs
  ld a, $01
  ld (_RAM_D6A0_MenuSelection), a
  ret

++:
  ld hl, _DATA_2B36E_SpriteNs_HandRight
  CallRamCode _LABEL_3BBB5_PopulateSpriteNs
  ld a, $02
  ld (_RAM_D6A0_MenuSelection), a
  ret

_LABEL_8CDB_:
  ld hl, _RAM_DC49_Cheat_ExplosiveOpponents
  xor a
  ld c, $08
-:
  ld (hl), a
  inc hl
  dec c
  jr nz, -
  ret

; 4th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8CE7_Handler_MenuScreen_OnePlayerSelectCharacter:
  call _LABEL_996E_
  call _LABEL_95C3_
  call _LABEL_9B87_
  call _LABEL_9D4E_
  ld a, (_RAM_D6B8_)
  or a
  jr z, _LABEL_8D28_MenuScreenHandlerDone
  ld a, (_RAM_D6B8_)
  sub $01
  ld (_RAM_D6B8_), a
  cp $10
  jr z, +
  cp $D0
  jr nc, _LABEL_8D28_MenuScreenHandlerDone
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, _LABEL_8D28_MenuScreenHandlerDone
+:
  ld a, (_RAM_D6A2_)
  ld (_RAM_DBFB_), a
  ld a, (_RAM_D6AD_)
  ld (_RAM_DBFC_), a
  ld a, (_RAM_D6AE_)
  ld (_RAM_DBFD_), a
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_8272_
_LABEL_8D28_MenuScreenHandlerDone:
  jp _LABEL_80FC_EndMenuScreenHandler

; 5th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8D2B_Handler_MenuScreen_RaceName:
  ld a, (_RAM_D6C1_)
  dec a
  jr z, ++
  call _LABEL_BA63_
  ld hl, (_RAM_D6AB_)
  dec hl
  ld (_RAM_D6AB_), hl
  ld a, h
  or a
  jr nz, +++
  ld a, l
  or a
  jr z, +
  cp $FF
  jr nc, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call _LABEL_B368_
++:
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
  cp $04
  jr nz, +++
  xor a
  ld (_RAM_D6AB_), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call _LABEL_BD2F_PaletteFade
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp _LABEL_80FC_EndMenuScreenHandler

; 7th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8D79_Handler_MenuScreen_Qualify:
  ld a, (_RAM_DBCE_)
  or a
  jr z, ++++
  ld hl, (_RAM_D6AB_)
  dec hl
  ld (_RAM_D6AB_), hl
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
+:
  ld a, $01
  ld (_RAM_D6B9_), a
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +++
  call _LABEL_841C_
++:
  jp _LABEL_80FC_EndMenuScreenHandler

+++:
  call _LABEL_84AA_Menu5
  jp _LABEL_80FC_EndMenuScreenHandler

++++:
  call _LABEL_9D4E_
  ld hl, (_RAM_D6AB_)
  dec hl
  ld (_RAM_D6AB_), hl
  ld a, l
  or h
  or a
  jr nz, +
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_8114_Menu0
+:
  jp _LABEL_80FC_EndMenuScreenHandler

; 8th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8DCC_Handler_MenuScreen_WhoDoYouWantToRace:
  call _LABEL_996E_
  call _LABEL_95C3_
  call _LABEL_9B87_
  call _LABEL_9D4E_
  call _LABEL_9E70_
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
  ld (_RAM_DBFB_), a
  ld a, (_RAM_D6AD_)
  ld (_RAM_DBFC_), a
  ld a, (_RAM_D6AE_)
  ld (_RAM_DBFD_), a
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_8486_
+:
  jp _LABEL_80FC_EndMenuScreenHandler

; 9th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8E15_Handler_MenuScreen_StorageBox:
  ld b, $00
  ld a, (_RAM_D6C2_DisplayCase_FlashingCarIndex)
  ld c, a
  ld a, (_RAM_D6AC_)
  xor $01
  ld (_RAM_D6AC_), a
  dec a
  jr z, +
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
+:
  ld a, (_RAM_D6AB_)
  cp $37
  jr nc, +
  and $04
  cp $04
  jr z, +
  ld a, (_RAM_DC0A_)
  cp $03
  jp z, _LABEL_B22A_
  call _LABEL_AE46_DisplayCase_BlankCar
  jp _LABEL_8E54_

+:
  ld a, (_RAM_DC0A_)
  cp $03
  jp z, _LABEL_B254_DisplayCase_RestoreRuffTrux
  call _LABEL_AE94_DisplayCase_RestoreRectangle

_LABEL_8E54_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld c, $60
  jp ++
+:ld c, $72
++:ld a, (_RAM_D6AB_)
  cp c
  jr z, +
  cp $37
  jr c, ++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
  ld a, $01
  ld (_RAM_D697_), a
+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC0A_)
  cp $03
  jr nz, +
  xor a
  ld (_RAM_DBD9_DisplayCaseData + 15), a
  ld (_RAM_DBD9_DisplayCaseData + 19), a
  ld (_RAM_DBD9_DisplayCaseData + 23), a
  call _LABEL_8877_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_84AA_Menu5
++:
  jp _LABEL_80FC_EndMenuScreenHandler

; 10th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8E97_Handler_MenuScreen_OnePlayerTrackIntro:
  ld a, (_RAM_D6C1_)
  dec a
  jr z, ++
  call _LABEL_A9EB_
  ld a, (_RAM_D6AC_)
  xor $01
  ld (_RAM_D6AC_), a
  dec a
  jr z, +
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
+:
  ld a, (_RAM_D6AB_)
  cp $B8
  jr z, +
  cp $30
  jr c, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call _LABEL_B368_
++:
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
  cp $04
  jr nz, +++
  xor a
  ld (_RAM_D6AB_), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call _LABEL_BD2F_PaletteFade
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp _LABEL_80FC_EndMenuScreenHandler

; 11th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8EF0_Handler_MenuScreen_OnePlayerTournamentResults:
  ld a, (_RAM_D6AB_)
  cp $A0
  jr z, +
  add a, $01
  ld (_RAM_D6AB_), a
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
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  ld a, (_RAM_D6C1_)
  add a, $01
  ld (_RAM_D6C1_), a
  cp $F0
  jr z, +
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DBCF_LastRacePosition)
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
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_8486_
++:
  jp _LABEL_80FC_EndMenuScreenHandler

+++:
  ld a, $01
  ld (_RAM_DC3A_), a
  call _LABEL_84AA_Menu5
  jp _LABEL_80FC_EndMenuScreenHandler

++++:
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr z, +
  ld a, (_RAM_DBD8_CourseSelectIndex)
  sub $01
  ld (_RAM_DBD8_CourseSelectIndex), a
  jp _LABEL_8F73_

+:
  call _LABEL_B877_
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_8F73_:
  ld a, (_RAM_DC09_Lives)
  sub $01
  ld (_RAM_DC09_Lives), a
  or a
  jr z, +
  xor a
  ld (_RAM_DC38_), a
  call _LABEL_866C_Menu3
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  ld a, $01
  ld (_RAM_DC38_), a
  call _LABEL_866C_Menu3
  jp _LABEL_80FC_EndMenuScreenHandler

; 12th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8F93_Handler_MenuScreen_UnknownB:
  call _LABEL_A692_
  ld a, (_RAM_D6AC_)
  xor $01
  ld (_RAM_D6AC_), a
  dec a
  jr z, +
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
+:
  ld a, (_RAM_D6AB_)
  cp $90
  jr z, +
  cp $37
  jr c, ++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_841C_
++:
  jp _LABEL_80FC_EndMenuScreenHandler

; 13th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8FC4_Handler_MenuScreen_LifeList:
  ld a, (_RAM_DC38_)
  or a
  jr nz, +
  ld a, (_RAM_D721_SpriteY)
  cp $E0
  jr z, _LABEL_902E_
  add a, $01
  ld (_RAM_D721_SpriteY), a
  call _LABEL_93CE_UpdateSpriteTable
  jp _LABEL_902E_

+:
  ld a, (_RAM_D721_SpriteY)
  cp $E1
  jr z, _LABEL_902E_
  ld a, (_RAM_DC38_)
  cp $02
  jr nz, _LABEL_902E_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, (_RAM_D721_SpriteY)
  cp $B0
  jr z, +++
  jr ++

+:
  ld a, (_RAM_D721_SpriteY)
  cp $A8
  jr z, +++
++:
  sub $01
  ld (_RAM_D721_SpriteY), a
  call _LABEL_93CE_UpdateSpriteTable
  jp _LABEL_902E_

+++:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 18, 22
  jr ++
+:TilemapWriteAddressToHL 18, 21
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC09_Lives)
  add a, $1A
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld a, $E1
  ld (_RAM_D721_SpriteY), a
  call _LABEL_93CE_UpdateSpriteTable
_LABEL_902E_:
  ld a, (_RAM_D6AC_)
  xor $01
  ld (_RAM_D6AC_), a
  dec a
  jr z, +
  ld a, (_RAM_D6AB_)
  sub $01
  ld (_RAM_D6AB_), a
+:
  ld a, (_RAM_D6AB_)
  cp $00
  jr z, +
  cp $60
  jr nc, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC38_)
  dec a
  jr z, ++
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +
  call _LABEL_8486_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_84C7_
  jp _LABEL_80FC_EndMenuScreenHandler

++:
  call _LABEL_8114_Menu0
+++:
  jp _LABEL_80FC_EndMenuScreenHandler

; 14th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_9074_Handler_MenuScreen_UnknownD:
  ld a, (_RAM_D6C1_)
  dec a
  jr z, ++
  ld a, (_RAM_D6AC_)
  xor $01
  ld (_RAM_D6AC_), a
  dec a
  jr z, +
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
+:
  ld a, (_RAM_D6AB_)
  cp $B8
  jr z, +
  cp $37
  jr c, +++
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, +++
+:
  call _LABEL_B368_
++:
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
  cp $04
  jr nz, +++
  xor a
  ld (_RAM_D6AB_), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call _LABEL_BD2F_PaletteFade
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, $01
  ld (_RAM_D6D5_InGame), a
+++:
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_90CA_BlankTiles_BlankControls:
  ; Blank tiles
  TileWriteAddressToHL $00
  call _LABEL_B35A_VRAMAddressToHL
  ld de, $3700
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

_LABEL_90E7_:
  xor a
  ld (_RAM_D691_TrackType), a
  ld (_RAM_D692_), a
  ld (_RAM_D693_), a
  ld a, $01
  ld (_RAM_D694_), a
  ld a, $24
  ld (_RAM_D690_), a
  call _LABEL_918B_
  ret

_LABEL_90FF_ReadControllers:
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
  jr nz, + ; ret

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
+:
  ret

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

_LABEL_915E_ScreenOn:
  ld a, $70
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_9167_ScreenOff:
  ld a, $10
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL2
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_9170_BlankTilemap_BlankControlsRAM:
; Fills tilemap with e, then chains to _LABEL_AF5D_BlankControlsRAM
  TilemapWriteAddressToHL 0, 0
  call _LABEL_B35A_VRAMAddressToHL
  ld d, $00
  ld bc, 32*28 ; $0380 ; Size of tilemap
-:ld a, e
  out (PORT_VDP_DATA), a
  ld a, $00
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  call _LABEL_AF5D_BlankControlsRAM ; could jp
  ret

_LABEL_918B_:
  ld a, (_RAM_D694_)
  or a
  jr z, _LABEL_91E7_ret
  ld a, (_RAM_D690_)
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, (_RAM_D691_TrackType)
  cp $00
  jr nz, +
  TilemapWriteAddressToHL 11, 15
  jp ++
+:TilemapWriteAddressToHL 11, 14
++:
  xor a
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
--:
  call _LABEL_B35A_VRAMAddressToHL
  ld e, $0A ; Width
-:
  ld a, (_RAM_D691_TrackType)
  or a
  jr nz, +
  ld a, BLANK_TILE_INDEX
  jp ++

+:
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
++:
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
  add a, $01
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec e
  jr nz, -
  ld a, (_RAM_D68B_TilemapRectangleSequence_Row)
  cp $07
  jr z, +
  add a, $01
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
  ld de, $0040 ; Add to VRAM address
  add hl, de
  jp --

+:
  call _LABEL_9276_
  call _LABEL_91E8_
_LABEL_91E7_ret:
  ret

_LABEL_91E8_:
  ld a, (_RAM_D691_TrackType)
  add a, $01
  ld (_RAM_D691_TrackType), a
  cp $06
  jr z, _LABEL_91E8_
  cp $0A
  jr nz, +
  xor a
  ld (_RAM_D691_TrackType), a
+:
  add a, $07
  ld (_RAM_D6D6_), a
  ld a, $01
  ld (_RAM_D6D4_), a
  xor a
  ld (_RAM_D68D_), a
  ld a, $C0
  ld (_RAM_D68C_), a
  ld a, (_RAM_D691_TrackType)
  sla a
  ld d, $00
  ld e, a
  ld hl, _DATA_9254_VehiclePortraitOffsets
  add hl, de
  ld a, (hl)
  ld (_RAM_D7B5_DecompressorSource), a
  inc hl
  ld a, (hl)
  ld (_RAM_D7B5_DecompressorSource+1), a
  ld a, (_RAM_D692_)
  xor $02
  ld (_RAM_D692_), a
  ld d, $00
  ld hl, _DATA_9268_
  ld e, a
  add hl, de
  ld a, (hl)
  ld (_RAM_D68F_), a
  inc hl
  ld a, (hl)
  ld (_RAM_D68E_), a
  ld a, (_RAM_D690_)
  xor $50
  ld (_RAM_D690_), a
  xor a
  ld (_RAM_D695_), a
  ld (_RAM_D696_), a
  ld (_RAM_D694_), a
  ld a, $01
  ld (_RAM_D693_), a
  ret

; Data from 9254 to 9267 (20 bytes)
_DATA_9254_VehiclePortraitOffsets:
; Pointers to compressed tile data for each track type
.dw _DATA_2AB4D_Tiles_Portrait_RuffTrux
.dw _DATA_FAA5_Tiles_Portrait_SportsCars
.dw _DATA_1F3E4_Tiles_Portrait_Powerboats
.dw _DATA_16F2B_Tiles_Portrait_FormulaOne
.dw _DATA_F35D_Tiles_Portrait_FourByFour
.dw _DATA_F765_Tiles_Portrait_Warriors
.dw $AB4D ; invalid?
.dw _DATA_16AC8_Tiles_Portrait_TurboWheels
.dw _DATA_1736E_Tiles_Portrait_Tanks
.dw _DATA_2AB4D_Tiles_Portrait_RuffTrux

; Data from 9268 to 926B (4 bytes)
_DATA_9268_:
.db $80 $44 $80 $4E

; Data from 926C to 9275 (10 bytes)
_DATA_926C_VehiclePortraitPageNumbers:
; Pages containing portrait (?) data for different vehicle types(?)
.db :_DATA_2AB4D_Tiles_Portrait_RuffTrux
.db :_DATA_FAA5_Tiles_Portrait_SportsCars
.db :_DATA_1F3E4_Tiles_Portrait_Powerboats
.db :_DATA_16F2B_Tiles_Portrait_FormulaOne
.db :_DATA_F35D_Tiles_Portrait_FourByFour
.db :_DATA_F765_Tiles_Portrait_Warriors
.db $04 ; invalid?
.db :_DATA_16AC8_Tiles_Portrait_TurboWheels
.db :_DATA_1736E_Tiles_Portrait_Tanks
.db :_DATA_2AB4D_Tiles_Portrait_RuffTrux

_LABEL_9276_:
  ld a, :_TEXT_3ECA9_VEHICLE_NAME_BLANK
  ld (_RAM_D741_RequestedPageIndex), a
  call _LABEL_BEF5_
  ld a, (_RAM_D691_TrackType)
  or a
  rl a ; x16
  rl a
  rl a
  rl a
  ld hl, _TEXT_3ECA9_VEHICLE_NAME_BLANK
  add a, l ; add it on
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  ld a, (_RAM_D691_TrackType)
  cp $00 ; Qualifying race
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerTrackIntro
  jr nc, ++
+:
  TilemapWriteAddressToDE 8, 22 (GG, SMS one player)
  jp ++++
++:
  TilemapWriteAddressToDE 8, 27 (SMS two player)
  jp ++++
+++:
  TilemapWriteAddressToDE 8, 14 (qualifying race)
++++:
  call _LABEL_B361_VRAMAddressToDE
  ld bc, 16
  CallRamCode _LABEL_3BC6A_EmitText
  ld a, (_RAM_D691_TrackType)
  or a
  jr nz, + ; ret
  ld a, $01
  ld (_RAM_D6CB_), a
+:ret

_LABEL_92CB_:
  ld a, (_RAM_D6D4_)
  cp $01
  jr z, _LABEL_9316_
  ld a, (_RAM_D693_)
  or a
  jr z, _LABEL_9316_
  ld a, (_RAM_D68C_)
  ld h, a
  ld a, (_RAM_D68D_)
  ld l, a
  ld a, (_RAM_D68E_)
  ld d, a
  ld a, (_RAM_D68F_)
  ld e, a
  call _LABEL_B361_VRAMAddressToDE
  CallRamCode _LABEL_3BB93_Emit3bppTiles_2Rows
  ld a, h
  ld (_RAM_D68C_), a
  ld a, l
  ld (_RAM_D68D_), a
  ld a, d
  ld (_RAM_D68E_), a
  ld a, e
  ld (_RAM_D68F_), a
  ld hl, (_RAM_D695_)
  inc hl
  ld (_RAM_D695_), hl
  dec h
  jr nz, _LABEL_9316_
  ld a, l
  cp $40
  jr nz, _LABEL_9316_
  xor a
  ld (_RAM_D693_), a
  ld a, $01
  ld (_RAM_D694_), a
_LABEL_9316_:
  ret

_LABEL_9317_InitialiseHandSprites:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, _DATA_936E_TitleScreenHandXs_GG
  ld de, _DATA_9386_TitleScreenHandYs_GG
  jr ++
+:ld hl, _DATA_939E_TitleScreenHandXs_SMS
  ld de, _DATA_93B6_TitleScreenHandYs_SMS
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
  ld hl, _DATA_2B33E_SpriteNs_HandFist
  JumpToRamCode _LABEL_3BBB5_PopulateSpriteNs

; Data from 936E to 9385 (24 bytes)
_DATA_936E_TitleScreenHandXs_GG:
.db $6E $76 $7E $86 $8E $96 
.db $6E $76 $7E $86 $8E $96 
.db $6E $76 $7E $86 $8E $96 
.db $6E $76 $7E $86 $8E $96 

; Data from 9386 to 939D (24 bytes)
_DATA_9386_TitleScreenHandYs_GG:
.db $90 $90 $90 $90 $90 $90 
.db $98 $98 $98 $98 $98 $98 
.db $A0 $A0 $A0 $A0 $A0 $A0 
.db $A8 $A8 $A8 $A8 $A8 $A8

; Data from 939E to 93B5 (24 bytes)
_DATA_939E_TitleScreenHandXs_SMS:
; X coordinates of sprites on title screen
.db $65 $6D $75 $7D $85 $8D 
.db $65 $6D $75 $7D $85 $8D 
.db $65 $6D $75 $7D $85 $8D 
.db $65 $6D $75 $7D $85 $8D

; Data from 93B6 to 93CD (24 bytes)
_DATA_93B6_TitleScreenHandYs_SMS:
; Y coordinates of sprites on title screen
.db $78 $78 $78 $78 $78 $78 
.db $80 $80 $80 $80 $80 $80 
.db $88 $88 $88 $88 $88 $88 
.db $90 $90 $90 $90 $90 $90

_LABEL_93CE_UpdateSpriteTable:
  ld hl, SPRITE_TABLE_ADDRESS | VDP_WRITE_MASK + $80 ; $7F80 ; sprite XN
  call _LABEL_B35A_VRAMAddressToHL
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
  ld hl, SPRITE_TABLE_ADDRESS | VDP_WRITE_MASK + $00 ; $7F00 ; Sprite Y
  call _LABEL_B35A_VRAMAddressToHL
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

_LABEL_9400_BlankSprites:
  ld hl, SPRITE_TABLE_ADDRESS | VDP_WRITE_MASK + $80 ; $7F80 ; Sprite XNs
  call _LABEL_B35A_VRAMAddressToHL
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
  ld hl, SPRITE_TABLE_ADDRESS | VDP_WRITE_MASK + $00 ; $7F00 ; Sprite Ys
  call _LABEL_B35A_VRAMAddressToHL
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

_LABEL_9434_:
  ld a, :_DATA_22BEC_Tiles_Cursor
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_22BEC_Tiles_Cursor
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 8 * 8 ; 8 tiles
  TileWriteAddressToHL $ba
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_9448_LoadHeaderTiles:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr c, +
  TileWriteAddressToHL $110
  jp ++
+:TileWriteAddressToHL $c2
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld a, :_DATA_2FDE0_Tiles_SmallLogo
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_2FDE0_Tiles_SmallLogo
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 22 * 8 ; 22 tiles
  call _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM
  ld a, :_DATA_13D7F_Tiles_MicroMachinesText
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_13D7F_Tiles_MicroMachinesText
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 24 * 8 ; 24 tiles
  call _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerMode
  jr z, + ; ret z
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr nz, _LABEL_949B_LoadHeadToHeadTextTiles
  
_LABEL_948A_LoadChallengeTextTiles:
  ld a, :_DATA_2B386_Tiles_ChallengeText
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_2B386_Tiles_ChallengeText
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 16 * 8 ; 16 tiles
  jp _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM ; and ret

_LABEL_949B_LoadHeadToHeadTextTiles:
  ld a, :_DATA_2B4CA_Tiles_HeadToHeadText
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_2B4CA_Tiles_HeadToHeadText
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 14 * 8 ; 14 tiles
  jp _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM

+:ret

_LABEL_94AD_DrawHeaderTilemap:
  ld a, :_DATA_13F38_Tilemap_SmallLogo
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
  call _LABEL_B361_VRAMAddressToDE
  ld hl, _DATA_13F38_Tilemap_SmallLogo
  ld a, $08
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $03
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, (_RAM_D6C8_HeaderTilesIndexOffset)
  ld c, a
  ld a, $C2
  sub c
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode _LABEL_3BB57_EmitTilemapRectangle
  ; Fall through

_LABEL_94F0_DrawHeaderTextTilemap:
  ld a, :_DATA_13F50_Tilemap_MicroMachinesText
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
  cp MenuScreen_OnePlayerTournamentResults
  jr nz, +++
  TilemapWriteAddressToDE 6, 5
  
+++:; Both
  call _LABEL_B361_VRAMAddressToDE
  ld hl, _DATA_13F50_Tilemap_MicroMachinesText
  ld a, $0C ; 12x2
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $02
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, (_RAM_D6C8_HeaderTilesIndexOffset)
  ld c, a
  ld a, $D8
  sub c
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode _LABEL_3BB57_EmitTilemapRectangle

  ld a, :_DATA_2B4BA_Tilemap_ChallengeText
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
  cp MenuScreen_OnePlayerTournamentResults
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
  call _LABEL_B361_VRAMAddressToDE
  ld a, (_RAM_D7B4_IsHeadToHead)
  or a
  jr nz, +
  ; Challenge
  ld hl, _DATA_2B4BA_Tilemap_ChallengeText
  ld a, $08 ; 8x2
  jp ++

+:; Head to head
  ld hl, _DATA_2B5BE_Tilemap_HeadToHeadText
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
  CallRamCode _LABEL_3BB57_EmitTilemapRectangle
  ret

_LABEL_959C_LoadPunctuationTiles:
  ld a, :_DATA_22B2C_Tiles_PunctuationAndLine
  ld (_RAM_D741_RequestedPageIndex), a
  TileWriteAddressToHL $1b4
  call _LABEL_B35A_VRAMAddressToHL
  ld e, 4 * 8 ; 4 tiles
  ld hl, _DATA_22B2C_Tiles_PunctuationAndLine
  JumpToRamCode _LABEL_3BB45_Emit3bppTileDataToVRAM ; and ret

_LABEL_95AF_DrawHorizontalLineIfSMS:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, + ; ret if GG
  ; SMS
  ld e, $20 ; Counter: 32 tiles
-:ld a, $B7 ; Tile index: horizontal bar
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  dec e
  jr nz, -
+:ret

_LABEL_95C3_:
  ld a, (_RAM_D6B4_)
  cp $01
  jr z, +
  ld a, (_RAM_D6BA_)
  cp $00
  jr nz, +
  ld a, (_RAM_D6B0_)
  cp $00
  jr nz, +
  ld a, (_RAM_D6AB_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_D6AB_), a
+:
  ret

++:
  ld a, (_RAM_D6A4_)
  cp $00
  jp nz, _LABEL_96F6_
  ld a, (_RAM_D6A3_)
  cp $01
  jr z, _LABEL_9636_
  cp $02
  jp z, _LABEL_96A3_
  ld a, (_RAM_D6C6_)
  dec a
  jr z, +
-:
  ld a, (_RAM_D680_Player1Controls_Menus)
  jp ++

+:
  ld a, (_RAM_DC3F_GameMode)
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
  jr z, _LABEL_9693_
  ret

+++:
  ld a, $01
  ld (_RAM_D6A3_), a
  ld a, $02
  ld (_RAM_D6A4_), a
  call _LABEL_97AF_
  jp _LABEL_96F6_

_LABEL_9636_:
  ld a, (_RAM_D6A4_)
  cp $00
  jp nz, _LABEL_96F6_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, ++
  ld a, (_RAM_D6A2_)
  add a, $01
  cp $30
  jr nz, +
  xor a
+:
  ld (_RAM_D6A2_), a
  sub $03
  and $07
  jp nz, _LABEL_96EC_
  jp +++

++:
  ld a, (_RAM_D6A2_)
  add a, $01
  cp $1E
  jr nz, +
  xor a
+:
  ld (_RAM_D6A2_), a
  ld hl, _DATA_9817_
  ld b, $00
  ld a, (_RAM_D6A2_)
  ld c, a
  add hl, bc
  ld a, (hl)
  or a
  jr z, _LABEL_96EC_
+++:
  xor a
  ld (_RAM_D6A3_), a
  ld a, $08
  ld (_RAM_D6AB_), a
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, +
  ld a, (_RAM_D7B3_)
  or a
  jr z, +
  sub $01
  ld (_RAM_D7B3_), a
+:
  jp _LABEL_96EC_

_LABEL_9693_:
  ld a, $02
  ld (_RAM_D6A3_), a
  ld a, $02
  ld (_RAM_D6A4_), a
  call _LABEL_977F_
  jp _LABEL_96F6_

_LABEL_96A3_:
  ld a, (_RAM_D6A4_)
  cp $00
  jr nz, _LABEL_96F6_
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
  jr nz, _LABEL_96EC_
  jp +++

++:
  ld a, (_RAM_D6A2_)
  sub $01
  cp $FF
  jr nz, +
  ld a, $1D
+:
  ld (_RAM_D6A2_), a
  ld hl, _DATA_9817_
  ld b, $00
  ld a, (_RAM_D6A2_)
  ld c, a
  add hl, bc
  ld a, (hl)
  or a
  jr z, _LABEL_96EC_
+++:
  xor a
  ld (_RAM_D6A3_), a
  ld a, $08
  ld (_RAM_D6AB_), a
_LABEL_96EC_:
  ld b, $00
  ld a, (_RAM_D6A2_)
  ld c, a
  call _LABEL_97EA_DrawDriverPortraitColumn
  ret

_LABEL_96F6_:
  ld a, (_RAM_D6A4_)
  cp $01
  jr z, _LABEL_973C_DrawPortrait_RightTwoColumns
  ld hl, _DATA_9773_TileWriteAddresses
_LABEL_9700_:
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
    ld hl, _DATA_9849_
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
  call _LABEL_B361_VRAMAddressToDE
  ld a, (_RAM_D6AA_)
  call _LABEL_9F81_DrawPortrait_ThreeColumns
  ld a, (_RAM_D6A4_)
  sub $01
  ld (_RAM_D6A4_), a
  ret

_LABEL_973C_DrawPortrait_RightTwoColumns:
  ld hl, (_RAM_D6A8_DisplayCaseTileAddress)
  ld bc, 15 * TILE_DATA_SIZE ; $01E0
  add hl, bc
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, (_RAM_D6A6_DisplayCase_Source)
  ld a, (_RAM_D6AA_)
  call _LABEL_9FB8_DrawOrBlank10PortraitTiles
  ld a, (_RAM_D6A4_)
  sub $01
  ld (_RAM_D6A4_), a
  call _LABEL_AECD_
  ret

; Data from 975B to 9766 (12 bytes)
_DATA_975B_TileWriteAddresses_SMS:
  TileWriteAddressData $13c
  TileWriteAddressData $15a
  TileWriteAddressData $178
  TileWriteAddressData $196
  TileWriteAddressData $100
  TileWriteAddressData $11e

; Data from 9767 to 9772 (12 bytes)
_DATA_9767_TileWriteAddresses_GG:
  TileWriteAddressData $11e
  TileWriteAddressData $13c
  TileWriteAddressData $15a
  TileWriteAddressData $178
  TileWriteAddressData $196
  TileWriteAddressData $100

; Data from 9773 to 977E (12 bytes)
_DATA_9773_TileWriteAddresses:
  TileWriteAddressData $196
  TileWriteAddressData $100
  TileWriteAddressData $11e
  TileWriteAddressData $13c
  TileWriteAddressData $15a
  TileWriteAddressData $178

_LABEL_977F_:
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
  ld hl, _RAM_DBFE_
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6AA_), a
  ld hl, _DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  ret

_LABEL_97AF_:
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
  ld hl, _RAM_DBFE_
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6AA_), a
  ld hl, _DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  ret

; Data from 97DF to 97E9 (11 bytes)
_DATA_97DF_8TimesTable:
  TimesTableLo 0 8 11

_LABEL_97EA_DrawDriverPortraitColumn:
; Seems to be what it does, not clear how yet
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS
  ld a, :_DATA_1B7A7_SMS
  ld (_RAM_D741_RequestedPageIndex), a
  TilemapWriteAddressToHL 0, 20
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _DATA_1B7A7_SMS
  add hl, bc ; Offset into data
  ld e, $C0 ; entry count
  JumpToRamCode _LABEL_3BBD8_EmitTilemapUnknown2

+:
  ld a, :_DATA_1B987_GG
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_1B987_GG
  add hl, bc
  ld b, $42
  ld c, $0B
  TilemapWriteAddressToDE 6, 16
  JumpToRamCode _LABEL_3BBF8_EmitTilemapUnknown

; Data from 9817 to 9848 (50 bytes)
_DATA_9817_:
.db $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00
.db $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00
.db $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01 $00 $00 $00 $00 $01
.db $00 $00

; Data from 9849 to 987A (50 bytes)
_DATA_9849_:
.db $00 $00 $00 $00 $00 $02 $02 $02 $02 $02 $04 $04 $04 $04 $04 $06
.db $06 $06 $06 $06 $08 $08 $08 $08 $08 $0A $0A $0A $0A $0A $0C $0C
.db $0C $0C $0C $0E $0E $0E $0E $0E $10 $10 $10 $10 $10 $12 $12 $12
.db $12 $12

_LABEL_987B_BlankTile1B4:
  TileWriteAddressToHL $1b4
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, TILE_DATA_SIZE
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, c
  or a
  jr nz, -
  ret

_LABEL_988D_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, _DATA_98AE_
  jp ++

+:
  ld hl, _DATA_990E_
++:
  ld de, _RAM_D6E1_SpriteX
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
  jp _LABEL_93CE_UpdateSpriteTable

; Data from 98AE to 990D (96 bytes)
_DATA_98AE_:
.db $62 $6A $72 $7A $82 $8A $92 $9A $62 $62 $62 $62 $62 $62 $62 $62
.db $9A $9A $9A $9A $9A $9A $9A $9A $62 $6A $72 $7A $82 $8A $92 $9A
.db $BA $BB $BB $BB $BB $BB $BB $BC $BD $BD $BD $BD $BD $BD $BD $BD
.db $BE $BE $BE $BE $BE $BE $BE $BE $BF $C0 $C0 $C0 $C0 $C0 $C0 $C1
.db $8F $8F $8F $8F $8F $8F $8F $8F $97 $9F $A7 $AF $B7 $BF $C7 $CF
.db $97 $9F $A7 $AF $B7 $BF $C7 $CF $D7 $D7 $D7 $D7 $D7 $D7 $D7 $D7

; Data from 990E to 996D (96 bytes)
_DATA_990E_:
.db $40 $48 $50 $58 $60 $68 $70 $FF $40 $40 $40 $40 $40 $40 $FF $FF
.db $70 $70 $70 $70 $70 $70 $FF $FF $40 $48 $50 $58 $60 $68 $70 $FF
.db $BA $BB $BB $BB $BB $BB $BC $FF $BD $BD $BD $BD $BD $BD $BD $BD
.db $BE $BE $BE $BE $BE $BE $BE $BE $BF $C0 $C0 $C0 $C0 $C0 $C1 $FF
.db $77 $77 $77 $77 $77 $77 $77 $FF $7F $87 $8F $97 $9F $A7 $FF $FF
.db $7F $87 $8F $97 $9F $A7 $FF $FF $AF $AF $AF $AF $AF $AF $AF $FF

_LABEL_996E_:
  ld a, (_RAM_D6C6_)
  dec a
  jr nz, +
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jp z, _LABEL_9A0E_
+:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  jr z, _LABEL_99D2_ret
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  ; Flash every 8 frames
  sra a
  sra a
  sra a
  and $01
  jp nz, _LABEL_9A0E_
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jp z, _LABEL_9A6D_
  TilemapWriteAddressToHL 4, 16
  call _LABEL_B35A_VRAMAddressToHL
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
  ld hl, _TEXT_9A3D_WhoDoYouWantToRace
  call _LABEL_A5B0_EmitToVDP_Text
  ret

++:
  ld bc, $0018
  ld hl, _TEXT_9A25_WhoDoYouWantToBe
  call _LABEL_A5B0_EmitToVDP_Text
  ret

+++:
  ld bc, $0018
  ld hl, _TEXT_9A55_PushStartToContinue
  call _LABEL_A5B0_EmitToVDP_Text
_LABEL_99D2_ret:
  ret

++++:
  TilemapWriteAddressToHL 13, 16
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD3_)
  ld c, a
  ld b, $00
  ld hl, _TEXT_A6EF_OpponentNames
  add hl, bc
  ld bc, $0007
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, $B6
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ld a, (_RAM_DBD3_)
  cp $10
  jr z, +
  TilemapWriteAddressToHL 7, 16
  jp ++
+:TilemapWriteAddressToHL 5, 16
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0009
  ld hl, _TEXT_9B7E_Handicap
  call _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_9A0E_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jp z, _LABEL_9B18_
  TilemapWriteAddressToHL 4, 16
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0018
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ret

; Data from 9A25 to 9A3C (24 bytes)
_TEXT_9A25_WhoDoYouWantToBe:
.asc " WHO DO YOU WANT TO BE? " ; $0E $16 $07 $1A $0E $03 $1A $0E $18 $1A $14 $0E $16 $00 $0D $13 $0E $13 $1A $0E $01 $04 $B6 $0E

; Data from 9A3D to 9A54 (24 bytes)
_TEXT_9A3D_WhoDoYouWantToRace:
.asc "WHO DO YOU WANT TO RACE?" ; $16 $07 $1A $0E $03 $1A $0E $18 $1A $14 $0E $16 $00 $0D $13 $0E $13 $1A $0E $11 $00 $02 $04 $B6

; Data from 9A55 to 9A6C (24 bytes)
_TEXT_9A55_PushStartToContinue:
.asc " PUSH START TO CONTINUE " ; $0E $0F $14 $12 $07 $0E $12 $13 $00 $11 $13 $0E $13 $1A $0E $02 $1A $0D $13 $08 $0D $14 $04 $0E

_LABEL_9A6D_:
  ld a, (_RAM_D6C0_)
  dec a
  jr z, _LABEL_9ABB_
  ld a, (_RAM_D6CA_)
  dec a
  jp z, _LABEL_9AE9_
  TilemapWriteAddressToHL 18, 17
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_9B46_WhoDo
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_9B4E_YouWant
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_WhoDoYouWantToRace
  jr z, +
  jp ++

+:
  ld hl, _TEXT_9B5E_ToRace
  call _LABEL_A5B0_EmitToVDP_Text
  jp _LABEL_99D2_ret

++:
  ld hl, _TEXT_9B56_ToBe
  call _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_9ABB_:
  TilemapWriteAddressToHL 18, 17
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_9B66_Push
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_9B6E_StartTo
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_9B76_Continue
  call _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_9AE9_:
  TilemapWriteAddressToHL 18, 17
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_9B7E_Handicap
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 19, 19
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD3_)
  ld c, a
  ld b, $00
  ld hl, _TEXT_A6EF_OpponentNames
  add hl, bc
  inc hl
  ld bc, $0006
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, $B6
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ret

_LABEL_9B18_:
  ; Blank text from above
  TilemapWriteAddressToHL 18, 17
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 19
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 18, 21
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ret

; Data from 9B46 to 9B4D (8 bytes)
_TEXT_9B46_WhoDo:
.asc "WHO DO  " ; $16 $07 $1A $0E $03 $1A $0E $0E

; Data from 9B4E to 9B55 (8 bytes)
_TEXT_9B4E_YouWant:
.asc "YOU WANT" ; $18 $1A $14 $0E $16 $00 $0D $13

; Data from 9B56 to 9B5D (8 bytes)
_TEXT_9B56_ToBe:
.asc "TO BE ? " ; $13 $1A $0E $01 $04 $0E $B6 $0E

; Data from 9B5E to 9B65 (8 bytes)
_TEXT_9B5E_ToRace:
.asc "TO RACE?" ; $13 $1A $0E $11 $00 $02 $04 $B6

; Data from 9B66 to 9B6D (8 bytes)
_TEXT_9B66_Push:
.asc "PUSH    " ; $0F $14 $12 $07 $0E $0E $0E $0E

; Data from 9B6E to 9B75 (8 bytes)
_TEXT_9B6E_StartTo:
.asc "START TO" ; $12 $13 $00 $11 $13 $0E $13 $1A

; Data from 9B76 to 9B7D (8 bytes)
_TEXT_9B76_Continue:
.asc "CONTINUE" ; $02 $1A $0D $13 $08 $0D $14 $04

; Data from 9B7E to 9B86 (9 bytes)
_TEXT_9B7E_Handicap:
.asc "HANDICAP " ; $07 $00 $0D $03 $08 $02 $00 $0F $0E

_LABEL_9B87_:
  ld a, (_RAM_D6BA_)
  cp $00
  jp nz, _LABEL_9C5D_
  ld a, (_RAM_D6A3_)
  cp $00
  jp nz, _LABEL_9C5D_
  ld a, (_RAM_D6AB_)
  cp $08
  jp z, _LABEL_9C5D_
  ld a, (_RAM_D6B0_)
  cp $01
  jp z, _LABEL_9C64_
  ld a, (_RAM_D6B4_)
  cp $01
  jp z, _LABEL_9C5D_
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
  jp nz, _LABEL_9C5D_
+++:
  ld a, (_RAM_D6C4_)
  cp $FF
  jr z, +
  add a, $02
  ld c, a
  ld a, (_RAM_D6B9_)
  cp c
  jr nz, +
  jp _LABEL_9C5E_

+:
  ld a, (_RAM_D6B9_)
  cp $04
  jr z, _LABEL_9C5E_
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
+:
  ld c, a
  ld b, $00
  ld hl, _RAM_DBFE_
  add hl, bc
  ld a, (hl)
  cp $58
  jr z, _LABEL_9C5D_
  cp $5A
  jr z, _LABEL_9C5D_
  ld a, $58
  ld (hl), a
  ld (_RAM_D6AA_), a
  ld hl, _DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_DBD3_), a
  ld (_RAM_D6BB_), a
  ld hl, _RAM_DBD4_
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
  call z, _LABEL_B30E_
  jp _LABEL_9C64_

+:
  ld a, (_RAM_D6B9_)
  cp $03
  call z, _LABEL_B30E_
  jp _LABEL_9C64_

_LABEL_9C5D_:
  ret

_LABEL_9C5E_:
  ld a, $01
  ld (_RAM_D6C1_), a
  ret

_LABEL_9C64_:
  ld a, (_RAM_D6A4_)
  cp $01
  jp z, _LABEL_973C_DrawPortrait_RightTwoColumns
  ld a, (_RAM_DC3C_IsGameGear)
  cp $01
  jr z, +
  ld hl, _DATA_975B_TileWriteAddresses_SMS
  jp _LABEL_9700_

+:
  ld hl, _DATA_9767_TileWriteAddresses_GG
  jp _LABEL_9700_

; Data from 9C7F to 9D36 (184 bytes)
_DATA_9C7F_RacerPortraitsLocations:
.dw _DATA_Tiles_Chen_Happy   _DATA_Tiles_Chen_Sad   _DATA_Tiles_Chen_Happy    $1000
.dw _DATA_Tiles_Chen_Happy   _DATA_Tiles_Chen_Sad   _DATA_Tiles_Chen_Sad      $1000
.dw _DATA_Tiles_Spider_Happy _DATA_Tiles_Spider_Sad _DATA_Tiles_Spider_Happy  $1000
.dw _DATA_Tiles_Spider_Happy _DATA_Tiles_Spider_Sad _DATA_Tiles_Spider_Sad    $1000
.dw _DATA_Tiles_Walter_Happy _DATA_Tiles_Walter_Sad _DATA_Tiles_Walter_Happy  $1000
.dw _DATA_Tiles_Walter_Happy _DATA_Tiles_Walter_Sad _DATA_Tiles_Walter_Sad    $1000
.dw _DATA_Tiles_Dwayne_Happy _DATA_Tiles_Dwayne_Sad _DATA_Tiles_Dwayne_Happy  $1000
.dw _DATA_Tiles_Dwayne_Happy _DATA_Tiles_Dwayne_Sad _DATA_Tiles_Dwayne_Sad    $1000
.dw _DATA_Tiles_Joel_Happy   _DATA_Tiles_Joel_Sad   _DATA_Tiles_Joel_Happy    $1000
.dw _DATA_Tiles_Joel_Happy   _DATA_Tiles_Joel_Sad   _DATA_Tiles_Joel_Sad      $1000
.dw _DATA_Tiles_Bonnie_Happy _DATA_Tiles_Bonnie_Sad _DATA_Tiles_Bonnie_Happy  $1000
.dw _DATA_Tiles_Bonnie_Happy _DATA_Tiles_Bonnie_Sad _DATA_Tiles_Bonnie_Sad    $1000
.dw _DATA_Tiles_Mike_Happy   _DATA_Tiles_Mike_Sad   _DATA_Tiles_Mike_Happy    $1000
.dw _DATA_Tiles_Mike_Happy   _DATA_Tiles_Mike_Sad   _DATA_Tiles_Mike_Sad      $1000
.dw _DATA_Tiles_Emilio_Happy _DATA_Tiles_Emilio_Sad _DATA_Tiles_Emilio_Happy  $1000
.dw _DATA_Tiles_Emilio_Happy _DATA_Tiles_Emilio_Sad _DATA_Tiles_Emilio_Sad    $1000
.dw _DATA_Tiles_Jethro_Happy _DATA_Tiles_Jethro_Sad _DATA_Tiles_Jethro_Happy  $1000
.dw _DATA_Tiles_Jethro_Happy _DATA_Tiles_Jethro_Sad _DATA_Tiles_Jethro_Sad    $1000
.dw _DATA_Tiles_Anne_Happy   _DATA_Tiles_Anne_Sad   _DATA_Tiles_Anne_Happy    $1000
.dw _DATA_Tiles_Anne_Happy   _DATA_Tiles_Anne_Sad   _DATA_Tiles_Anne_Sad      $1000
.dw _DATA_Tiles_Cherry_Happy _DATA_Tiles_Cherry_Sad _DATA_Tiles_Cherry_Happy  $1000
.dw _DATA_Tiles_Cherry_Happy _DATA_Tiles_Cherry_Sad _DATA_Tiles_Cherry_Sad    $1000

.dw _DATA_Tiles_OutOfGame    _DATA_Tiles_MrQuestion _DATA_Tiles_OutOfGame     $1000

; Data from 9D37 to 9D4D (23 bytes)
; Page numbers for the racer portraits (previous table)
_DATA_9D37_RacerPortraitsPages:
.db :_DATA_Tiles_Chen_Happy  
.db :_DATA_Tiles_Chen_Happy  
.db :_DATA_Tiles_Spider_Happy
.db :_DATA_Tiles_Spider_Happy
.db :_DATA_Tiles_Walter_Happy
.db :_DATA_Tiles_Walter_Happy
.db :_DATA_Tiles_Dwayne_Happy
.db :_DATA_Tiles_Dwayne_Happy
.db :_DATA_Tiles_Joel_Happy  
.db :_DATA_Tiles_Joel_Happy  
.db :_DATA_Tiles_Bonnie_Happy
.db :_DATA_Tiles_Bonnie_Happy
.db :_DATA_Tiles_Mike_Happy  
.db :_DATA_Tiles_Mike_Happy  
.db :_DATA_Tiles_Emilio_Happy
.db :_DATA_Tiles_Emilio_Happy
.db :_DATA_Tiles_Jethro_Happy
.db :_DATA_Tiles_Jethro_Happy
.db :_DATA_Tiles_Anne_Happy  
.db :_DATA_Tiles_Anne_Happy  
.db :_DATA_Tiles_Cherry_Happy
.db :_DATA_Tiles_Cherry_Happy
.db :_DATA_Tiles_OutOfGame   

_LABEL_9D4E_:
  ld a, (_RAM_D6B1_)
  cp $00
  jr z, ++
  sub $01
  cp $01
  jr nz, +
  ld a, $04
+:
  ld (_RAM_D6B1_), a
  cp $04
  jr z, _LABEL_9DBD_
  cp $03
  jr z, +++
  cp $02
  jr z, ++++
++:
  ret

+++:
  ld a, (_RAM_D6B9_)
  sla a
  ld c, a
  ld b, $00
  ld hl, _DATA_9DAD_TileVRAMAddresses
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  ld a, (_RAM_D6B6_)
  jp _LABEL_9F81_DrawPortrait_ThreeColumns

++++:
  ld a, (_RAM_D6B9_)
  sla a
  ld c, a
  ld b, $00
  ld hl, _DATA_9DB5_TileVRAMAddresses
  add hl, bc
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  inc hl
  ld a, (hl)
  out (PORT_VDP_ADDRESS), a
  ld hl, (_RAM_D6A6_DisplayCase_Source)
  ld a, (_RAM_D6B6_)
  call _LABEL_9FAB_DrawOrBlank15PortraitTiles
  ld a, (_RAM_D6BA_)
  cp $00
  jr z, +
  call _LABEL_9E29_
+:
  ret

; Data from 9DAD to 9DB4 (8 bytes)
_DATA_9DAD_TileVRAMAddresses:
.dw $4480 $4840 $4C00 $4FC0 ; Tiles $24, $42, $60, 7e

; Data from 9DB5 to 9DBC (8 bytes)
_DATA_9DB5_TileVRAMAddresses:
.dw $4660 $4A20 $4DE0 $51A0 ; Tiles $33, $51, $6f, $8d

_LABEL_9DBD_:
  ld a, (_RAM_DBD3_)
  ld e, a
  ld a, (_RAM_D6BA_)
  cp $00
  jr nz, +
  ld hl, _DATA_9E13_
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
  jr z, +
  cp $0E
  jr z, ++
  ld a, $00
  ld (_RAM_D6B4_), a
  ld a, (_RAM_D6B9_)
  cp $04
  jr z, +
  add a, $01
  ld (_RAM_D6B9_), a
+:
  ret

; Data from 9E13 to 9E28 (22 bytes)
_DATA_9E13_:
.db $04 $02 $04 $02 $04 $00 $FF $FF $FF $FF $FF $06 $05 $06 $05 $06
.db $05 $06 $05 $06 $01 $FF

_LABEL_9E29_:
  ld a, $00
  ld (_RAM_D6B1_), a
  ld (_RAM_D6B5_), a
  ld (_RAM_D6BA_), a
  ld (_RAM_D6B4_), a
  ld a, $F0
  ld (_RAM_D6B8_), a
  ret

++:
  ld a, (_RAM_DBD3_)
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
  ld (_RAM_D6CD_), a
  ld (_RAM_D6B4_), a
  ld a, (_RAM_D6B9_)
  add a, $01
  ld (_RAM_D6B9_), a
  call _LABEL_A5BE_
  ret

+:
  ld a, $01
  ld (_RAM_D6CA_), a
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  ret

_LABEL_9E70_:
  ld a, (_RAM_D6B4_)
  cp $01
  jp z, _LABEL_9F3F_ret
  ld a, (_RAM_D6A3_)
  cp $00
  jp nz, _LABEL_9F3F_ret
  ld a, (_RAM_D6AB_)
  cp $08
  jp z, _LABEL_9F3F_ret
  ld a, (_RAM_D6B0_)
  cp $01
  jp z, _LABEL_9C64_
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerSelectCharacter
  jr z, +
  ld a, (_RAM_D6B9_)
  cp $01
  jp z, _LABEL_9F3F_ret
+:
  ld a, (_RAM_D6B9_)
  cp $00
  jp z, _LABEL_9F3F_ret
  ld a, (_RAM_D6C4_)
  cp $FF
  jr z, +
  add a, $01
  ld c, a
  ld a, (_RAM_D6B9_)
  cp c
  jp z, _LABEL_9F3F_ret
+:
  ld a, (_RAM_D697_)
  cp $00
  jr z, +
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_2_MASK ; $20
  jr z, _LABEL_9F3F_ret
  ld a, $00
  ld (_RAM_D697_), a
+:
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_2_MASK ; $20
  jr nz, _LABEL_9F3F_ret
  ld a, $01
  ld (_RAM_D697_), a
  ld a, (_RAM_D6B9_)
  sub $01
  ld e, a
  ld d, $00
  ld hl, _RAM_DBD4_
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
  ld hl, _DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  cp e
  jr nz, _LABEL_9F3F_ret
  ld hl, _RAM_DBFE_
  add hl, bc
  add a, $01
  ld (hl), a
  ld (_RAM_D6AA_), a
  ld a, $59
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
  call _LABEL_B31C_
  jp ++

+:
  ld a, (_RAM_D6B9_)
  cp $04
  call z, _LABEL_B31C_
++:
  sub $01
  ld (_RAM_D6B9_), a
  jp _LABEL_9C64_

_LABEL_9F3F_ret:
  ret

_LABEL_9F40_:
; a = portrait index
  ld (_RAM_D6A1_PortraitIndex), a ; Save

  ld hl, _DATA_9D37_RacerPortraitsPages ; Look up in page number
  ld a, (_RAM_D6A1_PortraitIndex)
  sra a ; Divide by 4 to look up the page number because that table has a 1:4 ratio to the portrait pointers
  sra a
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl) ; Look up
  ld (_RAM_D741_RequestedPageIndex), a ; Save value found

  ld d, $00
  ld hl, _DATA_9C7F_RacerPortraitsLocations ; Look up pointer to data
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
  cp $58
  jr z, _LABEL_9F74_BlankVRAMRegion
  JumpToRamCode _LABEL_3BC27_EmitThirty3bppTiles

_LABEL_9F74_BlankVRAMRegion:
; de = amount to write / 16
-:ld hl, _DATA_BD6C_ZeroData
  ld b, 16
  ld c, PORT_VDP_DATA
  otir
  dec e
  jr nz, -
  ret

_LABEL_9F81_DrawPortrait_ThreeColumns:
  ; save index
  ld (_RAM_D6A1_PortraitIndex), a
  ; Look up page
  ld hl, _DATA_9D37_RacerPortraitsPages
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
  ld hl, _DATA_9C7F_RacerPortraitsLocations
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
  
_LABEL_9FAB_DrawOrBlank15PortraitTiles:
  ld de, 15 * 2 ; to blank 15 tiles
  ld a, (_RAM_D6A1_PortraitIndex)
  cp $58
  jr z, _LABEL_9F74_BlankVRAMRegion
  JumpToRamCode _LABEL_3BC3C_EmitFifteen3bppTiles

_LABEL_9FB8_DrawOrBlank10PortraitTiles:
  ld de, 10 * 2 ; to blank 10 tiles
  ld a, (_RAM_D6A1_PortraitIndex)
  cp $58
  jr z, _LABEL_9F74_BlankVRAMRegion
  JumpToRamCode _LABEL_3BC53_EmitTen3bppTiles

_LABEL_9FC5_:
  ld a, (_RAM_DC3B_IsTrackSelect)
  or a
  jr z, +
  jp _LABEL_AA02_

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
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, _TEXT_A019_Pro
  jp _LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 6, 22
  add hl, bc
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0004
  ld hl, _TEXT_AAAE_Blanks
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from A019 to A01B (3 bytes)
_TEXT_A019_Pro:
.asc "PRO" ; $0F $11 $1A

_LABEL_A01C_:
  ld c, a
  ld b, $00
  ld hl, _DATA_A02E_
  add hl, bc
  ld a, (hl)
  ld c, a
  and $C0
  ld (_RAM_D6CE_), a
  ld a, c
  and $3F
  ret

; Data from A02E to A038 (11 bytes)
_DATA_A02E_:
.db $FF $01 $81 $03 $43 $08 $07 $05 $02 $04 $06

_LABEL_A039_:
  ld de, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, $40
+:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  jr z, _LABEL_A0A3_
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, +++
  TilemapWriteAddressToHL 8, 14
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr z, +
  ld hl, _TEXT_A0AC_Loser
  jp ++

+:
  ld hl, _TEXT_A0A4_Winner
++:
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 17, 14
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld a, (_RAM_DBD0_HeadToHeadLost2)
  or a
  jr z, +
  ld hl, _TEXT_A0AC_Loser
  jp ++

+:
  ld hl, _TEXT_A0A4_Winner
++:
  jp _LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 8, 14
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0019
  ld hl, _TEXT_AAAE_Blanks
  jp _LABEL_A5B0_EmitToVDP_Text

_LABEL_A0A3_:
  ret

; Data from A0A4 to A0AB (8 bytes)
_TEXT_A0A4_Winner:
.asc "WINNER!!" ; $16 $08 $0D $0D $04 $11 $B4 $B4

; Data from A0AC to A0B3 (8 bytes)
_TEXT_A0AC_Loser:
.asc " LOSER! " ; $0E $0B $1A $12 $04 $11 $B4 $0E

_LABEL_A0B4_:
  TilemapWriteAddressToHL 12, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0007
  ld hl, _TEXT_A0DB_Results
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 7, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, +
  ld bc, $000E
  ld hl, _TEXT_A0E2_SingleRace
  jp _LABEL_A5B0_EmitToVDP_Text

+:
  jp _LABEL_A302_

; Data from A0DB to A0E1 (7 bytes)
_TEXT_A0DB_Results:
.asc "RESULTS" ; $11 $04 $12 $14 $0B $13 $12

; Data from A0E2 to A0EF (14 bytes)
_TEXT_A0E2_SingleRace:
.asc "   SINGLE RACE" ; $0E $0E $0E $12 $08 $0D $06 $0B $04 $0E $11 $00 $02 $04

_LABEL_A0F0_BlankTilemapRectangle:
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
  call _LABEL_B35A_VRAMAddressToHL
-:ld a, BLANK_TILE_INDEX
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
  jr z, +
  ld a, l
  add a, TILEMAP_ROW_SIZE ; $40 ; Add a row
  ld l, a
  ld a, h
  adc a, $00
  ld h, a
  jp --

+:ret

_LABEL_A129_:
  ld de, (_RAM_D6A8_DisplayCaseTileAddress)
  call _LABEL_B361_VRAMAddressToDE
  exx
    ld hl, (_RAM_D6A6_DisplayCase_Source)
    ld e, 10 * 8 ; 10 tiles
    CallRamCode _LABEL_3BB45_Emit3bppTileDataToVRAM
    ld (_RAM_D6A6_DisplayCase_Source), hl
  exx
  ld hl, 32*10 ; 10 tiles
  add hl, de
  ld (_RAM_D6A8_DisplayCaseTileAddress), hl
  ld a, (_RAM_D693_)
  sub $01
  ld (_RAM_D693_), a
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_A14F_:
  ; de = location offset - 0 for GG, $80 for SMS
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  rrca
  ld e, a
  ld d, $00
  
  ld a, (_RAM_DBD4_)
  srl a
  srl a
  srl a
  ld c, a ; 1 = player 2, 2 = player 1 (!)
  ld b, $00
  call _LABEL_A1EC_
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 7, 11
  add hl, de
  jp ++

+:
  TilemapWriteAddressToHL 7, 22
  add hl, de
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC21_
  add hl, bc
  ld a, (hl)
  or a
  jr z, +
  call _LABEL_A1CA_PrintHandicap
  jp ++
+:call _LABEL_A1D3_PrintOrdinary
++:
  ld a, (_RAM_DBD5_)
  srl a
  srl a
  srl a
  ld c, a
  ld b, $00
  call _LABEL_A225_
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
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC21_
  add hl, bc
  ld a, (hl)
  or a
  jr z, +
  call _LABEL_A1CA_PrintHandicap
  ret

+:call _LABEL_A1D3_PrintOrdinary
  ret

_LABEL_A1CA_PrintHandicap:
  ld bc, $0008
  ld hl, _TEXT_A1DC_Handicap
  jp _LABEL_A5B0_EmitToVDP_Text

_LABEL_A1D3_PrintOrdinary:
  ld bc, $0008
  ld hl, _TEXT_A1E4_Ordinary
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from A1DC to A1E3 (8 bytes)
_TEXT_A1DC_Handicap:
.asc "HANDICAP" ; $07 $00 $0D $03 $08 $02 $00 $0F

; Data from A1E4 to A1EB (8 bytes)
_TEXT_A1E4_Ordinary:
.asc "ORDINARY" ; $1A $11 $03 $08 $0D $00 $11 $18

_LABEL_A1EC_:
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 7, 6
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 7, 16
  add hl, de
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC0B_
  add hl, bc
  call _LABEL_A272_PrintBCDNumberWithLeadingHyphen
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 7, 8
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 7, 18
  add hl, de
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC16_
  add hl, bc
  call _LABEL_A272_PrintBCDNumberWithLeadingHyphen
  ret

_LABEL_A225_:
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
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC0B_
  add hl, bc
  call _LABEL_A272_PrintBCDNumberWithLeadingHyphen
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
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _RAM_DC16_
  add hl, bc
  call _LABEL_A272_PrintBCDNumberWithLeadingHyphen
  ret

_LABEL_A272_PrintBCDNumberWithLeadingHyphen:
  ld a, (hl) ; Get byte
  and $F0 ; High nibble
  srl a
  srl a
  srl a
  srl a
  jr nz, + ; high 0 -> "-"
  ld a, HYPHEN_TILE_INDEX
  jp ++
+:add a, ZERO_DIGIT_TILE_INDEX ; else convert to digit
++:
  out (PORT_VDP_DATA), a
  rlc a
  and $01
  out (PORT_VDP_DATA), a
  ld a, (hl) ; Low nibble is printed as a 0
  and $0F
  add a, ZERO_DIGIT_TILE_INDEX
  out (PORT_VDP_DATA), a
  ret

_LABEL_A296_LoadHandTiles:
  ld a, :_DATA_2B151_Tiles_Hand
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_2B151_Tiles_Hand
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 39 * 8 ; 39 tiles
  TileWriteAddressToHL $bb
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_A2AA_PrintOrFlashMenuScreenText:
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
  call _LABEL_B35A_VRAMAddressToHL
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
  call _LABEL_B35A_VRAMAddressToHL
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
  jr z, _LABEL_A302_
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +
  ld hl, _TEXT_A325_SelectVehicle
  ld bc, $0010
  jp _LABEL_A5B0_EmitToVDP_Text

_LABEL_A302_:
  ld hl, _TEXT_A335_TournamentRace
  ld bc, $0010
  call _LABEL_A5B0_EmitToVDP_Text
  ; Emit number
  ld a, (_RAM_DC35_TournamentRaceNumber)
  add a, ZERO_DIGIT_TILE_INDEX
  out (PORT_VDP_DATA), a
  ret

+:
  ld hl, _TEXT_A345_SelectATrack
  ld bc, $0010
  jp _LABEL_A5B0_EmitToVDP_Text

++:
  ld bc, $0011
  ld hl, _TEXT_AAAE_Blanks
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from A325 to A334 (16 bytes)
_TEXT_A325_SelectVehicle:
.asc "  SELECT VEHICLE" ; $0E $0E $12 $04 $0B $04 $02 $13 $0E $15 $04 $07 $08 $02 $0B $04

; Data from A335 to A344 (16 bytes)
_TEXT_A335_TournamentRace:
.asc "TOURNAMENT RACE " ; $13 $1A $14 $11 $0D $00 $0C $04 $0D $13 $0E $11 $00 $02 $04 $0E

; Data from A345 to A354 (16 bytes)
_TEXT_A345_SelectATrack:
.asc "  SELECT A TRACK" ; $0E $0E $12 $04 $0B $04 $02 $13 $0E $00 $0E $13 $11 $00 $02 $0A

_LABEL_A355_:
  ld a, (_RAM_DBD4_)
  srl a
  srl a
  srl a
  ld de, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, $7C
+:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 6, 6
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 6, 16
  add hl, de
++:
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_A3EA_
  ld de, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, $7A
+:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 6, 8
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 6, 18
  add hl, de
++:
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_A402_
  ld de, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, $80
+:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 23, 6
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 23, 16
  add hl, de
++:
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_A3EA_
  ld de, $0000
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld e, $80
+:ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerResult
  jr z, +
  TilemapWriteAddressToHL 23, 8
  add hl, de
  jp ++
+:TilemapWriteAddressToHL 23, 18
  add hl, de
++:
  call _LABEL_B35A_VRAMAddressToHL
  jp _LABEL_A402_

_LABEL_A3EA_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0005
  ld hl, _TEXT_A41E_Won
  jp _LABEL_A5B0_EmitToVDP_Text

+:
  ld bc, $0002
  ld hl, _TEXT_A41A_W
  jp _LABEL_A5B0_EmitToVDP_Text

_LABEL_A402_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0005
  ld hl, _TEXT_A423_Lost
  jp _LABEL_A5B0_EmitToVDP_Text

+:
  ld bc, $0002
  ld hl, _TEXT_A41C_L
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from A41A to A41D (4 bytes)
_TEXT_A41A_W:
.asc "W-" ; $16 $B5
_TEXT_A41C_L:
.asc "L-" ; $0B $B5

; Data from A41E to A422 (5 bytes)
_TEXT_A41E_Won:
.asc "WON- " ; $16 $1A $0D $B5 $0E

; Data from A423 to A4B6 (148 bytes)
_TEXT_A423_Lost:
.asc "LOST-" ; $0B $1A $12 $13 $B5

; Unused code (?)
_LABEL_A428_DrawPlayerOpponentTypeSelectText:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 4, 24 ; SMS
  jr ++
+:TilemapWriteAddressToDE 6, 20 ; GG
++:call _LABEL_B361_VRAMAddressToDE
  ld bc, 8
  ld hl, _TEXT_A49D_Player1
  call _LABEL_A5B0_EmitToVDP_Text

  ld hl, $0046 ; down and right a bit
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL          
  ld bc, 2
  ld hl, _TEXT_A4B5_Vs
  call _LABEL_A5B0_EmitToVDP_Text           

  ld hl, $0080 ; down a bit
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, 8
  ld hl, _TEXT_A4A5_Player2
  call _LABEL_A5B0_EmitToVDP_Text           

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 20, 24 ; SMS
  jr ++
+:TilemapWriteAddressToDE 18, 20 ; GG
++:call _LABEL_B361_VRAMAddressToDE           
  ld bc, 8
  ld hl, _TEXT_A49D_Player1
  call _LABEL_A5B0_EmitToVDP_Text

  ld hl, $0046 ; down and right a bit
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL          
  ld bc, 2
  ld hl, _TEXT_A4B5_Vs
  call _LABEL_A5B0_EmitToVDP_Text           

  ld hl, $0080 ; down a bit
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, 8
  ld hl, _TEXT_A4AD_Computer
  call _LABEL_A5B0_EmitToVDP_Text           
  ret                    

_TEXT_A49D_Player1:
.asc "PLAYER 1"
_TEXT_A4A5_Player2:
.asc "PLAYER 2"
_TEXT_A4AD_Computer:
.asc "COMPUTER"
_TEXT_A4B5_Vs:
.asc "VS"

_LABEL_A4B7_:
  TilemapWriteAddressToHL 10, 13
  call _LABEL_A500_DrawSelectGameText
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_OnePlayerMode
  jr z, +
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 3, 16
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $001A
  ld hl, _TEXT_A4E6_OnePlayerTwoPlayer
  call _LABEL_A5B0_EmitToVDP_Text
+:ret

; Data from A4DA to A4E5 (12 bytes)
_TEXT_A4DA_SelectGame:
.asc "SELECT  GAME" ; $12 $04 $0B $04 $02 $13 $0E $0E $06 $00 $0C $04

; Data from A4E6 to A4FF (26 bytes)
_TEXT_A4E6_OnePlayerTwoPlayer:
.asc "ONE PLAYER      TWO PLAYER" ; $1A $0D $04 $0E $0F $0B $00 $18 $04 $11 $0E $0E $0E $0E $0E $0E $13 $16 $1A $0E $0F $0B $00 $18 $04 $11

_LABEL_A500_DrawSelectGameText:
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, _TEXT_A4DA_SelectGame
  jp _LABEL_A5B0_EmitToVDP_Text

_LABEL_A50C_DrawOnePlayerSelectGameText:
  TilemapWriteAddressToHL 8, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000F
  ld hl, _TEXT_A521_OnePlayerGame
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 10, 12
  jp _LABEL_A500_DrawSelectGameText

; Data from A521 to A52F (15 bytes)
_TEXT_A521_OnePlayerGame:
.asc "ONE PLAYER GAME" ; $1A $0D $04 $0E $0F $0B $00 $18 $04 $11 $0E $06 $00 $0C $04

_LABEL_A530_DrawChooseGameText:
  TilemapWriteAddressToHL 10, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000C
  ld hl, _TEXT_A574_ChooseGame
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 3, 26
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $001A
  ld hl, _TEXT_A580_TournamentSingleRace
  call _LABEL_A5B0_EmitToVDP_Text
  ret

+:
  TilemapWriteAddressToHL 6, 21
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0012
  ld hl, _TEXT_A59A_TournamentSingle
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 22, 22
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0004
  ld hl, _TEXT_A5AC_Race
  call _LABEL_A5B0_EmitToVDP_Text
  ret

; Data from A574 to A57F (12 bytes)
_TEXT_A574_ChooseGame:
.asc "CHOOSE GAME!" ; .db $02 $07 $1A $1A $12 $04 $0E $06 $00 $0C $04 $B4

; Data from A580 to A599 (26 bytes)
_TEXT_A580_TournamentSingleRace:
.asc "TOURNAMENT     SINGLE RACE"; .db $13 $1A $14 $11 $0D $00 $0C $04 $0D $13 $0E $0E $0E $0E $0E $12 $08 $0D $06 $0B $04 $0E $11 $00 $02 $04

; Data from A59A to A5AB (18 bytes)
_TEXT_A59A_TournamentSingle:
.asc "TOURNAMENT  SINGLE" ; .db $13 $1A $14 $11 $0D $00 $0C $04 $0D $13 $0E $0E $12 $08 $0D $06 $0B $04

; Data from A5AC to A5AF (4 bytes)
_TEXT_A5AC_Race:
.asc "RACE" ; .db $11 $00 $02 $04

_LABEL_A5B0_EmitToVDP_Text:
  ; Emits tile data from hl to the VDP data port, synthesising the high byte as it goes
  ld a, (hl)
  out (PORT_VDP_DATA), a
  rlc a
  and $01
  out (PORT_VDP_DATA), a
  inc hl
  dec c
  jr nz, _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_A5BE_:
  ld a, $30
  ld (_RAM_D6AF_FlashingCounter), a
  ld a, $01
  ld (_RAM_D6C6_), a
  ret

_LABEL_A5C9_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 3, 10
  ld bc, $0006
  ld hl, _TEXT_A664_Player
  jr ++

+:
  TilemapWriteAddressToDE 6, 10
  ld bc, $0003
  ld hl, _TEXT_A66A_Plr
++:
  call _LABEL_B361_VRAMAddressToDE
  call _LABEL_A5B0_EmitToVDP_Text
  
  TilemapWriteAddressToHL 6, 12
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, _TEXT_A66D_One
  call _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_A5F9_:
  TilemapWriteAddressToHL 3, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 12
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_A618_:
  ld de, $79AE
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld bc, $0006
  ld hl, _TEXT_A664_Player
  jr ++

+:
  ld bc, $0003
  ld hl, _TEXT_A66A_Plr
++:
  call _LABEL_B361_VRAMAddressToDE
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 23, 12
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, _TEXT_A670_Two
  call _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_A645_:
  TilemapWriteAddressToHL 23, 10
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0006
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 23, 12
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0003
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ret

; Data from A664 to A669 (6 bytes)
_TEXT_A664_Player:
.asc "PLAYER" ; $0F $0B $00 $18 $04 $11

; Data from A66A to A66C (3 bytes)
_TEXT_A66A_Plr:
.asc "PLR" ; $0F $0B $11

; Data from A66D to A66F (3 bytes)
_TEXT_A66D_One:
.asc "ONE" ; $1A $0D $04

; Data from A670 to A672 (3 bytes)
_TEXT_A670_Two:
.asc "TWO" ; $13 $16 $1A

_LABEL_A673_:
  ld a, $00
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_UNUSED6
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_A67C_:
  ld a, $00
  ld (_RAM_D6AD_), a
  ld a, $04
  ld (_RAM_D6AE_), a
  ld a, $03
  ld (_RAM_D6A2_), a
  ld (_RAM_DBFB_), a
  ld bc, $0003
  ret

_LABEL_A692_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, +++
  TilemapWriteAddressToHL 8, 20
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD3_)
  and $F8
  ld c, a
  ld b, $00
  ld hl, _TEXT_A6EF_OpponentNames
  add hl, bc
  ld a, (hl)
  inc hl
  or a
  jr z, +
  TilemapWriteAddressToDE 9, 20
  call _LABEL_B361_VRAMAddressToDE
+:
  ld bc, $0007
  call _LABEL_A5B0_EmitToVDP_Text
  ld bc, $0008
  ld hl, _TEXT_A747_IsOut
  call _LABEL_A5B0_EmitToVDP_Text
++:
  ret

+++:
  TilemapWriteAddressToHL 7, 20
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0008
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ld bc, $0008
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ret

; Data from A6EF to A746 (88 bytes)
_TEXT_A6EF_OpponentNames:
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

; Data from A747 to A74E (8 bytes)
_TEXT_A747_IsOut:
.asc "IS OUT! " ; $08 $12 $0E $1A $14 $13 $B4 $0E

_LABEL_A74F_:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  ld c, a
  ld b, $00
  ld hl, _DATA_A75E_
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6C4_), a
  ret

; Data from A75E to A777 (26 bytes) - a byte per course (?), written to _RAM_D6C4_
_DATA_A75E_:
.db $FF $FF $FF $00 $FF $FF $01 $FF $FF $02 $FF $FF $FF $00 $FF $FF $01 $FF $FF $FF $02 $FF $FF $FF $00 $FF

_LABEL_A778_InitDisplayCaseData:
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

_LABEL_A787_:
  ld a, (_RAM_DC0A_)
  cp $03
  jr nz, +
  ld a, $02
  ld (_RAM_DBD9_DisplayCaseData + 15), a
  ld (_RAM_DBD9_DisplayCaseData + 19), a
  ld (_RAM_DBD9_DisplayCaseData + 23), a
  ret

+:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  sub $01
  sla a
  ld c, a
  ld b, $00
  ld hl, _DATA_A7BB_
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ld a, $02
  ld (de), a
  ld (_RAM_DBF9_), de
  ret

_LABEL_A7B3_:
  ld de, (_RAM_DBF9_)
  ld a, $01
  ld (de), a
  ret

; Data from A7BB to A7EC (50 bytes)
_DATA_A7BB_:
.db $E7 $DB $D9 $DB $E5 $DB $DC $DB $EB $DB $DA $DB $E9 $DB $E6 $DB
.db $E0 $DB $E7 $DB $EF $DB $EA $DB $DB $DB $DE $DB $DD $DB $E4 $DB
.db $EB $DB $ED $DB $DF $DB $E1 $DB $EE $DB $EF $DB $E2 $DB $E3 $DB
.db $E1 $DB

_LABEL_A7ED_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  jr z, +++
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jr nz, ++++
  call _LABEL_A859_SetTilemapLocationForLastRacePosition
  ld a, (_RAM_DC3A_)
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
  ld hl, _TEXT_A84A_QualifyFailed
  add hl, bc
  ld bc, $0007
  call _LABEL_A5B0_EmitToVDP_Text
+++:
  ret

++++:
  call _LABEL_A859_SetTilemapLocationForLastRacePosition
  ld hl, _TEXT_AAAE_Blanks
  ld bc, $0007
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from A83A to A841 (8 bytes)
_DATA_A83A_TilemapLocations_GG:
  TilemapWriteAddressData  8, 14
  TilemapWriteAddressData 17, 14
  TilemapWriteAddressData  8, 22
  TilemapWriteAddressData 18, 22

; Data from A842 to A849 (8 bytes)
_DATA_A842_TilemapLocations_SMS:
  TilemapWriteAddressData  1, 14
  TilemapWriteAddressData 24, 14
  TilemapWriteAddressData  2, 24
  TilemapWriteAddressData 24, 24

; Data from A84A to A858 (15 bytes)
_TEXT_A84A_QualifyFailed:
.asc "QUALIFY", $FF
.asc "FAILED "

_LABEL_A859_SetTilemapLocationForLastRacePosition:
  ; Index into table for system
  ld a, (_RAM_DBCF_LastRacePosition)
  sla a
  ld c, a
  ld b, $00
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, _DATA_A842_TilemapLocations_SMS
  jr ++
+:ld hl, _DATA_A83A_TilemapLocations_GG
++:
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  call _LABEL_B361_VRAMAddressToDE
  ret

_LABEL_A877_:
  ld a, :_DATA_13C42_Tiles_BigNumbers
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_13C42_Tiles_BigNumbers
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 24 * 8 ; 24 tiles
  TileWriteAddressToHL $100
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  call _LABEL_BA42_LoadColouredCirclesTiles
  ld a, (_RAM_DC3C_IsGameGear)
  xor $01
  rrca
  ld c, a
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
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, $06
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  TilemapWriteAddressToHL 24, 8
  add hl, bc ; Add 2 rows for SMS -> 24, 10
  ld a, $03
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  call _LABEL_BCCF_EmitTilemapRectangleSequence
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
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, $12
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  TilemapWriteAddressToHL 24, 16
  add hl, bc ; Add 22 ros for SMS -> 24, 18
  ld a, $03
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  call _LABEL_BCCF_EmitTilemapRectangleSequence
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

+:ld a, (_RAM_DBCF_LastRacePosition)
  cp c
  jp z, +
  ld a, (_RAM_DBD0_HeadToHeadLost2)
  cp c
  jp z, +++
  ld a, (_RAM_DBD1_)
  cp c
  jp z, _LABEL_A95D_
  ld a, (_RAM_DBD2_)
  cp c
  jp z, _LABEL_A97B_
  ret

+:
  ld a, $80
  ld (_RAM_D6AF_FlashingCounter), a
  ld b, $00
  call _LABEL_A9C6_
  call _LABEL_B375_ConfigureTilemapRect_5x6_24
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, $A9AE
  jr ++

+:
  ld hl, _DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBCF_LastRacePosition)
  jp _LABEL_A996_

+++:
  ld b, $01
  call _LABEL_A9C6_
  ld a, $42
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, _DATA_A9AE_TilemapAddresses_SMS
  jr ++

+:
  ld hl, _DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBD0_HeadToHeadLost2)
  jp _LABEL_A996_

_LABEL_A95D_:
  ld b, $02
  call _LABEL_A9C6_
  ld a, $60
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, _DATA_A9AE_TilemapAddresses_SMS
  jr ++

+:
  ld hl, _DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBD1_)
  jp _LABEL_A996_

_LABEL_A97B_:
  ld b, $03
  call _LABEL_A9C6_
  ld a, $7E
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, _DATA_A9AE_TilemapAddresses_SMS
  jr ++
+:ld hl, _DATA_A9A6_TilemapAddresses_GG
++:
  ld a, (_RAM_DBD2_)
_LABEL_A996_:
  sla a
  ld c, a
  ld b, $00
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ex de, hl
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  jp _LABEL_8F10_

; Data from A9A6 to A9AD (8 bytes)
_DATA_A9A6_TilemapAddresses_GG:
  TilemapWriteAddressData  9,  8
  TilemapWriteAddressData 18,  8
  TilemapWriteAddressData  9, 16
  TilemapWriteAddressData 18, 16

; Data from A9AE to A9B5 (8 bytes)
_DATA_A9AE_TilemapAddresses_SMS:
  TilemapWriteAddressData  9, 10
  TilemapWriteAddressData 18, 10
  TilemapWriteAddressData  9, 20
  TilemapWriteAddressData 18, 20

; Data from A9B6 to A9BD (8 bytes)
_DATA_A9B6_TilemapAddresses_GG:
  TilemapWriteAddressData  7, 12
  TilemapWriteAddressData 24, 12
  TilemapWriteAddressData  7, 20
  TilemapWriteAddressData 24, 20

; Data from A9BE to A9C5 (8 bytes)
_DATA_A9BE_TilemapAddresses_SMS:
  TilemapWriteAddressData 11, 16
  TilemapWriteAddressData 20, 16
  TilemapWriteAddressData 11, 26
  TilemapWriteAddressData 20, 26

_LABEL_A9C6_:
; c = position index?
; b = tile index
  ld a, c
  sla a
  ld e, a
  ld d, $00
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld hl, _DATA_A9BE_TilemapAddresses_SMS
  jr ++
+:ld hl, _DATA_A9B6_TilemapAddresses_GG
++:
  add hl, de
  ld e, (hl)
  inc hl
  ld d, (hl)
  call _LABEL_B361_VRAMAddressToDE
  ld a, b
  add a, $18
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ret

_LABEL_A9EB_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  jr z, _LABEL_AA5D_ ; ret
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, _LABEL_AA8B_
_LABEL_AA02_:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  sub $01
  sla a
  ld c, a
  ld b, $00
  ld hl, _DATA_AB06_TrackNumberText
  add hl, bc
  ld a, (hl)
  ld (_RAM_DBF1_RaceNumberText + 5), a
  inc hl
  ld a, (hl)
  ld (_RAM_DBF1_RaceNumberText + 6), a
  ld hl, _DATA_AACE_TrackNamePointers
  add hl, bc
  ld c, (hl)
  inc hl
  ld b, (hl)
  ld h, b
  ld l, c
  ld a, $03
  ld (_RAM_D741_RequestedPageIndex), a
  ld a, (_RAM_DBD8_CourseSelectIndex)
  cp $19
  jr z, +++
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 11, 16
  call _LABEL_B361_VRAMAddressToDE
  ld bc, 20
  TilemapWriteAddressToDE 2, 16
  jr ++

+:TilemapWriteAddressToDE 6, 13
  call _LABEL_B361_VRAMAddressToDE
  ld bc, 20
  TilemapWriteAddressToDE 12, 12
++:
  CallRamCode _LABEL_3BC6A_EmitText
  call _LABEL_B361_VRAMAddressToDE
  ld bc, 8
  ld hl, _RAM_DBF1_RaceNumberText
  CallRamCode _LABEL_3BC6A_EmitText
_LABEL_AA5D_:
  ret

+++:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS: emit 30 tiles here
  TilemapWriteAddressToHL 0, 16
  ld bc, 30
  jr ++

+:; GG: emit "string" split across lines
  TilemapWriteAddressToHL 9, 13
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, 15
  ld hl, _DATA_BFB0_
  CallRamCode _LABEL_3BC6A_EmitText
  TilemapWriteAddressToHL 9, 12
  ld bc, 15
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _DATA_BFA1_
  CallRamCode _LABEL_3BC6A_EmitText
  ret

_LABEL_AA8B_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 0, 15
  jr ++
+:TilemapWriteAddressToHL 0, 12
++:
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $0020
  ld hl, _TEXT_AAAE_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ld bc, $0020
  ld hl, _TEXT_AAAE_Blanks
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from AAAE to AACD (32 bytes)
_TEXT_AAAE_Blanks:
.asc "                                "

; Data from AACE to AB05 (56 bytes)
_DATA_AACE_TrackNamePointers:
.dw _DATA_FDC1_TrackName_00
.dw _DATA_FDD5_TrackName_01
.dw _DATA_FDE9_TrackName_02
.dw _DATA_FDFD_TrackName_03
.dw _DATA_FE11_TrackName_04
.dw _DATA_FE25_TrackName_05
.dw _DATA_FE39_TrackName_06
.dw _DATA_FE4D_TrackName_07
.dw _DATA_FE61_TrackName_08
.dw _DATA_FE75_TrackName_09
.dw _DATA_FE89_TrackName_10
.dw _DATA_FE9D_TrackName_11
.dw _DATA_FEB1_TrackName_12
.dw _DATA_FEC5_TrackName_13
.dw _DATA_FED9_TrackName_14
.dw _DATA_FEED_TrackName_15
.dw _DATA_FF01_TrackName_16
.dw _DATA_FF15_TrackName_17
.dw _DATA_FF29_TrackName_18
.dw _DATA_FF3D_TrackName_19
.dw _DATA_FF51_TrackName_20
.dw _DATA_FF65_TrackName_21
.dw _DATA_FF79_TrackName_22
.dw _DATA_FF8D_TrackName_23
.dw _DATA_FFBF_TrackName_25
.dw _DATA_FFBF_TrackName_25
.dw _DATA_FFBF_TrackName_25
.dw _DATA_FFBF_TrackName_25


; Data from AB06 to AB2B (38 bytes)
_DATA_AB06_TrackNumberText:
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
; Data from AB2C to AB3D (18 bytes)
_DATA_AB2C_:
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
_DATA_AB3E_CourseSelect_TrackTypes:
; Maps the course select index to a track type
; (???)
.db TT_FormulaOne TT_FourByFour TT_Warriors TT_RuffTrux TT_FormulaOne
.db TT_TurboWheels TT_Warriors TT_Powerboats TT_RuffTrux TT_Tanks
.db TT_FormulaOne TT_Powerboats TT_Helicopters TT_TurboWheels TT_FourByFour
.db TT_RuffTrux TT_Tanks TT_Warriors TT_Helicopters TT_FourByFour TT_Powerboats
.db TT_Tanks TT_TurboWheels TT_Helicopters TT_FourByFour TT_Unknown9 TT_Unknown9
.db TT_Unknown9 TT_Powerboats

_LABEL_AB5B_GetPortraitSource_CourseSelect:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  sub $01
  ld c, a
  ld b, $00
  ld hl, _DATA_AB3E_CourseSelect_TrackTypes
  add hl, bc
  ld a, (hl)
_LABEL_AB68_GetPortraitSource_TrackType:
  ld (_RAM_D691_TrackType), a
  sla a
  ld de, _DATA_9254_VehiclePortraitOffsets
  add a, e
  ld e, a
  ld a, d
  adc a, $00
  ld d, a
  ld a, (de)
  ld (_RAM_D7B5_DecompressorSource), a
  inc de
  ld a, (de)
  ld (_RAM_D7B5_DecompressorSource+1), a
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  ld (_RAM_D6A6_DisplayCase_Source), hl
  ret

_LABEL_AB86_Decompress3bppTiles_Index100:
  ; Decompresses 80 tiles of 3bpp tile data from the given source address and page to tile $100
  ld a, (_RAM_D691_TrackType)
  call _LABEL_B478_SelectPortraitPage
  ld hl, (_RAM_D7B5_DecompressorSource)
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $100
  ld de, 80 * 8 ; 80 tiles
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_AB9B_Decompress3bppTiles_Index160:
  ; Decompresses 80 tiles of 3bpp tile data from the given source address and page to tile $160
  ld a, (_RAM_D691_TrackType)
  call _LABEL_B478_SelectPortraitPage
  ld hl, (_RAM_D7B5_DecompressorSource)
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $160
  ld de, 80 * 8 ; 80 tiles
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_ABB0_:
  jp _LABEL_ABB3_

_LABEL_ABB3_:
  xor a
  ld (_RAM_D692_), a
  ld (_RAM_D693_), a
  ld a, $01
  ld (_RAM_D694_), a
  xor a
  ld (_RAM_D690_), a
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TrackSelect
  jr nz, +
  ld a, $60
  ld (_RAM_D690_), a
+:
  call +
  ret

+:
  ld a, (_RAM_D690_)
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 11, 19
  jr ++

+:
  TilemapWriteAddressToHL 11, 14
++:
  xor a
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
--:
  call _LABEL_B35A_VRAMAddressToHL
  ld de, $000A
-:
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
  add a, $01
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  dec de
  ld a, d
  or e
  jr nz, -
  ld a, (_RAM_D68B_TilemapRectangleSequence_Row)
  cp $07
  jr z, +
  add a, $01
  ld (_RAM_D68B_TilemapRectangleSequence_Row), a
  ld de, $0040
  add hl, de
  jp --

+:
  call _LABEL_9276_
  ret

_LABEL_AC1E_:
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +++
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD4_)
  ld (_RAM_D6BB_), a
  call _LABEL_9F40_
  call _LABEL_B375_ConfigureTilemapRect_5x6_24
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 1, 8
  jr ++

+:
  TilemapWriteAddressToHL 6, 9
  call _LABEL_B2B3_
++:
  call _LABEL_BCCF_EmitTilemapRectangleSequence
+++:
  TileWriteAddressToHL $42
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, +
  ld a, (_RAM_DBD4_)
  call _LABEL_9F40_
  ld de, $0004
  jp ++

+:
  ld a, (_RAM_DBD5_)
  call _LABEL_9F40_
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
  call _LABEL_B2B3_
++:
  or a
  sbc hl, de
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  TileWriteAddressToHL $60
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, +
  ld a, (_RAM_DBD5_)
  call _LABEL_9F40_
  ld de, $0004
  jp ++

+:
  ld a, (_RAM_DBD6_)
  call _LABEL_9F40_
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
  call _LABEL_B2B3_
++:
  add hl, de
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +++
  TileWriteAddressToHL $7e
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DBD7_)
  call _LABEL_9F40_
  ld a, $7E
  call _LABEL_B377_ConfigureTilemapRect_5x6_rega
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 25, 8
  jr ++

+:
  TilemapWriteAddressToHL 21, 9
  call _LABEL_B2B3_
++:
  call _LABEL_BCCF_EmitTilemapRectangleSequence
+++:
  ret

_LABEL_ACEE_:
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +
  TilemapWriteAddressToHL 3, 14
  call _LABEL_B35A_VRAMAddressToHL
  TilemapWriteAddressToHL 11, 14
  TilemapWriteAddressToBC 19, 14
  TilemapWriteAddressToDE 27, 14
  jr ++

+:TilemapWriteAddressToHL 9, 14
  call _LABEL_B35A_VRAMAddressToHL
  TilemapWriteAddressToDE 21, 14
  jr ++

++:
  ld a, $50
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +
  call _LABEL_B35A_VRAMAddressToHL
  ld a, $51
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ld h, b
  ld l, c
  call _LABEL_B35A_VRAMAddressToHL
  ld a, $52
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
+:
  call _LABEL_B361_VRAMAddressToDE
  ld a, $53
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ret

_LABEL_AD42_DrawDisplayCase:
  ld a, :_DATA_3B37F_Tiles_DisplayCase ; $0E
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_3B37F_Tiles_DisplayCase ; $B37F - compressed 3bpp tile data, 2952 bytes = 123 tiles up to $3b970
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $100
  ld de, 123 * 8 ; 123 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  ld a, :_DATA_3B32F_DisplayCaseTilemapCompressed ; $0E
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_3B32F_DisplayCaseTilemapCompressed ; $B32F - compressed data, 440 bytes up to $3b37e
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000

  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld de, $790A ; 5, 4
  jr ++
+:ld de, $780A ; 5, 0
++:call _LABEL_B361_VRAMAddressToDE

  ld hl, _RAM_C000_DecompressionTemporaryBuffer ; decompressed data
  ld a, $16 ; 22x20
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $14
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  xor a
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode _LABEL_3BB57_EmitTilemapRectangle

  ; The displayed tilemap includes all the cars, then we blank it out here
  ld bc, $0000
-:ld hl, _RAM_DBD9_DisplayCaseData
  add hl, bc
  ld a, (hl)
  dec a
  jr z, _LABEL_AD9C_HaveCar
  dec a
  jr z, +
  call _LABEL_AE46_DisplayCase_BlankCar
_LABEL_AD9C_HaveCar:
  inc bc
  ld a, c
  cp $18
  jr nz, -
  ret

+:; Flashing car
  ld a, c
  ld (_RAM_D6C2_DisplayCase_FlashingCarIndex), a
  jp _LABEL_AD9C_HaveCar

; Data from ADAA to ADD9 (48 bytes)
_DATA_ADAA_DisplayCaseSourceDataAddresses: ; Addresses of tilemap data when "restoring" flashing car
.dw $C017 $C01C $C021 $C026 $C059 $C05E $C063 $C068
.dw $C09B $C0A0 $C0A5 $C0AA $C0DD $C0E2 $C0E7 $C0EC
.dw $C11F $C124 $C129 $C12E $C161 $C166 $C16B $C170

; Data from ADDA to AE45 (108 bytes)
_DATA_ADDA_DisplayCaseTilemapAddresses: ; Tilemap addresses per car index (0-24)
.dw $784C $7856 $7860 $786A $790C $7916 $7920 $792A ; 6, 1; 11, 1; 16, 1; 21, 1; 6, 4; 11, 4; etc
.dw $79CC $79D6 $79E0 $79EA $7A8C $7A96 $7AA0 $7AAA
.dw $7B4C $7B56 $7B60 $7B6A $7C0C $7C16 $7C20 $7C2A

_DATA_AE0A_DisplayCase_BlankRectangle_RuffTruxTop:
.db $04 $05 $05 $05 $06
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
_DATA_AE19_DisplayCase_BlankRectangle_RuffTruxMiddle:
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
_DATA_AE28_DisplayCase_BlankRectangle_RuffTruxBottom:
.db $4C $4D $4D $4D $19
.db $4C $4D $4D $4D $19
.db $76 $77 $77 $77 $57

_DATA_AE37_DisplayCase_BlankRectangle:
.db $04 $05 $05 $05 $06
.db $4C $4D $4D $4D $19
.db $76 $77 $77 $77 $57

_LABEL_AE46_DisplayCase_BlankCar:
; bc = index
  ld (_RAM_D6BC_DisplayCase_IndexBackup), bc ; Unnecessary?
  ld hl, _DATA_AE37_DisplayCase_BlankRectangle
  ld (_RAM_D6A6_DisplayCase_Source), hl
_LABEL_AE50_DisplayCase_BlankRect:
; bc = index
; hl = source data
  ld a, $02
  ld (_RAM_D741_RequestedPageIndex), a ; Unused?

  ld (_RAM_D6BC_DisplayCase_IndexBackup), bc
  ld a, c ; Look up tilemap address
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_ADDA_DisplayCaseTilemapAddresses
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
  call _LABEL_B35A_VRAMAddressToHL

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
  CallRamCode _LABEL_3BB57_EmitTilemapRectangle
  ld bc, (_RAM_D6BC_DisplayCase_IndexBackup) ; Restore bc (?)
  ret

_LABEL_AE94_DisplayCase_RestoreRectangle:
  ld a, $0D
  ld (_RAM_D741_RequestedPageIndex), a ; Unused?

  ld a, c   ; Look up destination address
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_ADDA_DisplayCaseTilemapAddresses
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
    call _LABEL_B35A_VRAMAddressToHL
  ex de, hl

  ld a, c   ; Look up source data address
  sla a
  ld c, a
  ld b, $00
  ld hl, _DATA_ADAA_DisplayCaseSourceDataAddresses
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
  JumpToRamCode _LABEL_3BC7D_DisplayCase_RestoreRectangle

_LABEL_AECD_:
  ld hl, (_RAM_D6A8_DisplayCaseTileAddress)
  ld bc, 25 * TILE_DATA_SIZE ; $0320
  add hl, bc
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _DATA_9D37_RacerPortraitsPages
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
  ld hl, _DATA_9C7F_RacerPortraitsLocations
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
  ld bc, $0258
  add hl, bc
  ld e, $28 ; 5 tiles
  CallRamCode _LABEL_03BCAF_Emit3bppTiles
  ld a, $00
  ld (_RAM_D6A4_), a
  ld (_RAM_D6B0_), a
  ret

_LABEL_AF10_:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  ret z
  in a, (PORT_GG_LinkStatus)
  and $04
  jr nz, +++
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, _LABEL_AF6F_
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  cp $CA
  jr z, +
  cp $55
  jr z, ++
  ld a, $CA
  out (PORT_GG_LinkSend), a
  ret

+:
  ld a, $01
  ld (_RAM_DC42_GearToGear_IAmPlayer1), a
  ld (_RAM_DC41_GearToGearActive), a
  ld a, $55
  out (PORT_GG_LinkSend), a
  jr _LABEL_AF5D_BlankControlsRAM

++:
  xor a
  ld (_RAM_DC42_GearToGear_IAmPlayer1), a
  ld a, $01
  ld (_RAM_DC41_GearToGearActive), a
  ld c, $01
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  jr _LABEL_AF5D_BlankControlsRAM

; Data from AF4F to AF4F (1 bytes)
.db $C9 ; ret

+++:
  call _LABEL_AF92_
  xor a
  ld (_RAM_DC41_GearToGearActive), a
  ld a, $00
  ld (_RAM_DC42_GearToGear_IAmPlayer1), a
  ret

_LABEL_AF5D_BlankControlsRAM:
  ld a, NO_BUTTONS_PRESSED
  ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
  ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
  ld (_RAM_D680_Player1Controls_Menus), a
  ld (_RAM_D681_Player2Controls_Menus), a
  ld (_RAM_D687_Player1Controls_PreviousFrame), a
  ret

_LABEL_AF6F_:
  ld a, (_RAM_D7BA_HardModeTextFlashCounter)
  inc a
  and $0F
  ld (_RAM_D7BA_HardModeTextFlashCounter), a
  and $08
  jr z, _LABEL_AF92_
  TilemapWriteAddressToHL 13, 13
  call _LABEL_B35A_VRAMAddressToHL
  ld c, $05
  ld hl, _TEXT_AFA0_Link
  call _LABEL_A5B0_EmitToVDP_Text
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  add a, $1B
  out (PORT_VDP_DATA), a
  ret

_LABEL_AF92_:
  TilemapWriteAddressToHL 13, 13
  call _LABEL_B35A_VRAMAddressToHL
  ld c, $06
  ld hl, _TEXT_AAAE_Blanks
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from AFA0 to AFA4 (5 bytes)
_TEXT_AFA0_Link:
.asc "LINK " ; $0B $08 $0D $0A $0E

_LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL:
  call _LABEL_B35A_VRAMAddressToHL
_LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM:
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
  JumpToRamCode _LABEL_3BB31_Emit3bppTileDataToVRAM

_LABEL_AFAE_RamCodeLoader:
  ; Trampoline for calling paging code
  ld hl, +  ; Loading Code into RAM
  ld de, _RAM_D640_RamCodeLoader
  ld bc, $0011
  ldir
  jp _RAM_D640_RamCodeLoader  ; Code is loaded from +

; Executed in RAM at d640
+:ld a, :_LABEL_3B971_RamCodeLoaderStage2
  ld (_RAM_D741_RequestedPageIndex), a
  ld (PAGING_REGISTER), a ; page in and call
  call _LABEL_3B971_RamCodeLoaderStage2
  ld a, $02 ; restore paging
  ld (PAGING_REGISTER), a
  ret

_LABEL_AFCD_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_OnePlayerMode
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_B337_BlankTiles
  call _LABEL_9400_BlankSprites
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_959C_LoadPunctuationTiles
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call _LABEL_9448_LoadHeaderTiles
  call _LABEL_94AD_DrawHeaderTilemap
  call _LABEL_B305_DrawHorizontalLine_Top
  ld c, $07
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  xor a
  ld (_RAM_D6C7_), a
  call _LABEL_BB95_LoadIconMenuGraphics
  call _LABEL_BC0C_
  call +
  call _LABEL_A50C_DrawOnePlayerSelectGameText
  call _LABEL_9317_InitialiseHandSprites
  xor a
  ld (_RAM_D6A0_MenuSelection), a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  call _LABEL_A673_
  call _LABEL_BB75_
  ret

_LABEL_B01D_SquinkyTennisHook:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  ret z
  ; If a GG...
  ; ...and Start is held...
  in a, (PORT_GG_START)
  add a, a ; start is bit 7, 1 = not pressed
  ret c
  ld a, :_DATA_3F753_JonsSquinkyTennisCompressed ;$0F
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_3F753_JonsSquinkyTennisCompressed ;$B753 Up to $3ff78, compressed code (Jon's Squinky Tennis, 5923 bytes)
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  jp _RAM_C000_DecompressionTemporaryBuffer ; $C000 ; Possibly invalid

+:
  ld a, :_DATA_23656_Tiles_VsCPUPatch ; $08
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_23656_Tiles_VsCPUPatch ; $B656 Up to $237e1, 864 bytes compressed
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $180
  ld de, 36 * 8 ; 36 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
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
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  ret

; 20th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_B06C_MenuScreen_OnePlayerMode:
  call _LABEL_B9C4_
  call _LABEL_8CA2_
  ld a, (_RAM_D6A0_MenuSelection)
  or a
  jp z, _LABEL_80FC_EndMenuScreenHandler
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jp nz, _LABEL_80FC_EndMenuScreenHandler
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_D6A0_MenuSelection)
  dec a
  jr nz, +
  xor a
  ld (_RAM_DC3F_GameMode), a
  call _LABEL_8205_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  ld a, $01
  ld (_RAM_DC3F_GameMode), a
  call _LABEL_8953_
  jp _LABEL_80FC_EndMenuScreenHandler

; 15th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_B09F_Handler_MenuScreen_TwoPlayerSelectCharacter:
  ld a, (_RAM_D688_)
  or a
  jr z, +
  dec a
  ld (_RAM_D688_), a
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  ld a, (_RAM_D6B9_)
  cp $02
  jr z, +
  call _LABEL_996E_
  ld a, (_RAM_D6CA_)
  or a
  jp nz, _LABEL_B154_
  call _LABEL_95C3_
  call _LABEL_9B87_
  call _LABEL_9D4E_
  ld a, (_RAM_D6B9_)
  or a
  jr z, _LABEL_B110_
  dec a
  jr z, _LABEL_B132_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  ld a, (_RAM_D6AC_)
  add a, $01
  ld (_RAM_D6AC_), a
  cp $30
  jr z, +
  dec a
  call z, _LABEL_A645_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, +
  call _LABEL_89E2_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  or a
  jr nz, +
  ld (_RAM_D6AB_), a
  ld a, MenuScreen_OnePlayerTrackIntro
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $01
  ld (_RAM_D6C1_), a
  call _LABEL_9400_BlankSprites
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  jp _LABEL_84AA_Menu5

_LABEL_B110_:
  ld a, (_RAM_D6CD_)
  cp $02
  jp z, _LABEL_80FC_EndMenuScreenHandler
  add a, $01
  ld (_RAM_D6CD_), a
  dec a
  jr z, +
  dec a
  jr z, ++
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_A645_
  jp _LABEL_80FC_EndMenuScreenHandler

++:
  call _LABEL_A5C9_
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_B132_:
  ld a, (_RAM_D6CD_)
  cp $02
  jp z, _LABEL_80FC_EndMenuScreenHandler
  add a, $01
  ld (_RAM_D6CD_), a
  dec a
  jr z, +
  dec a
  jr z, ++
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_A5F9_
  jp _LABEL_80FC_EndMenuScreenHandler

++:
  call _LABEL_A618_
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_B154_:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr z, +
  xor a
  ld (_RAM_D6CB_), a
  jp +++

+:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $08
  jr z, _LABEL_B1B9_Left
  or a
  jr nz, _LABEL_B1B6_Select
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
  jr z, _LABEL_B1B9_Left
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_R_MASK ; $08
  jr z, _Right
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jr nz, _LABEL_B1B6_Select
+++:
  xor a
  ld (_RAM_D6CA_), a
  ld a, (_RAM_DBD3_)
  srl a
  srl a
  srl a
  ld c, a
  ld b, $00
  ld hl, _RAM_DC21_
  add hl, bc
  ld a, (_RAM_D6CB_)
  ld (hl), a
  call _LABEL_9E52_
_LABEL_B1B6_Select:
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_B1B9_Left:
  xor a
  ld (_RAM_D6CB_), a
  call _LABEL_B389_
  ld bc, $0005
  call _LABEL_A5B0_EmitToVDP_Text
  jp _LABEL_80FC_EndMenuScreenHandler

_Right:
  ld a, $01
  ld (_RAM_D6CB_), a
  call _LABEL_B389_
  ld hl, _TEXT_B1E7_Yes
  ld bc, $0005
  call _LABEL_A5B0_EmitToVDP_Text
  jp _LABEL_80FC_EndMenuScreenHandler

; Data from B1DD to B1E6 (10 bytes)
_TEXT_B1DD_No:
.asc "-NO- " ; $B5 $0D $1A $B5 $0E

_TEXT_B1E2_No:
.asc " -NO-" ; $0E $B5 $0D $1A $B5

; Data from B1E7 to B1EB (5 bytes)
_TEXT_B1E7_Yes:
.asc "-YES-" ; $B5 $18 $04 $12 $B5

_LABEL_B1EC_Trampoline_PlayMenuMusic:
  ld a, :_LABEL_30CE8_PlayMenuMusic
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode _LABEL_3BCDC_Trampoline2_PlayMenuMusic

_LABEL_B1F4_Trampoline_StopMenuMusic:
  ld a, :_LABEL_30D28_StopMenuMusic
  ld (_RAM_D741_RequestedPageIndex), a
  JumpToRamCode _LABEL_3BCE6_Trampoline_StopMenuMusic

_LABEL_B1FC_:
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, +
  ld hl, _DATA_B219_
  ld a, (_RAM_D6CC_)
  sub $01
-:
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld (_RAM_DBD8_CourseSelectIndex), a
+:
  ret

_LABEL_B213_:
  ld hl, _DATA_B222_
  jp -

; Data from B219 to B221 (9 bytes)
_DATA_B219_:
.db $02 $14 $0E $17 $0D $04 $07 $15 $05

; Data from B222 to B229 (8 bytes)
_DATA_B222_:
.db $02 $15 $0E $05 $07 $00 $04 $0D

_LABEL_B22A_:
  call _LABEL_B230_DisplayCase_BlankRuffTrux
  jp _LABEL_8E54_

_LABEL_B230_DisplayCase_BlankRuffTrux:
  ld bc, $000F
  ld hl, _DATA_AE0A_DisplayCase_BlankRectangle_RuffTruxTop
  ld (_RAM_D6A6_DisplayCase_Source), hl
  call _LABEL_AE50_DisplayCase_BlankRect
  ld bc, $0013
  ld hl, _DATA_AE19_DisplayCase_BlankRectangle_RuffTruxMiddle
  ld (_RAM_D6A6_DisplayCase_Source), hl
  call _LABEL_AE50_DisplayCase_BlankRect
  ld bc, $0017
  ld hl, _DATA_AE28_DisplayCase_BlankRectangle_RuffTruxBottom
  ld (_RAM_D6A6_DisplayCase_Source), hl
  jp _LABEL_AE50_DisplayCase_BlankRect ; and ret

_LABEL_B254_DisplayCase_RestoreRuffTrux:
  ld bc, $000F
  call _LABEL_AE94_DisplayCase_RestoreRectangle
  ld bc, $0013
  call _LABEL_AE94_DisplayCase_RestoreRectangle
  ld bc, $0017
  call _LABEL_AE94_DisplayCase_RestoreRectangle
  jp _LABEL_8E54_

_LABEL_B269_:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  add a, $01
  ld (_RAM_DBD8_CourseSelectIndex), a
  cp $0A
  jr z, _LABEL_B269_
  cp $11
  jr z, _LABEL_B269_
  cp $16
  jr z, _LABEL_B269_
  ret

_LABEL_B27E_:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  sub $01
  or a
  jr nz, +
  ld a, $1C
+:
  ld (_RAM_DBD8_CourseSelectIndex), a
  cp $0A
  jr z, _LABEL_B27E_
  cp $11
  jr z, _LABEL_B27E_
  cp $16
  jr z, _LABEL_B27E_
  ret

_LABEL_B298_:
  ld a, (_RAM_DBD8_CourseSelectIndex)
  add a, $01
  cp $1D
  jr nz, +
  ld a, $01
+:
  ld (_RAM_DBD8_CourseSelectIndex), a
  cp $0A
  jr z, _LABEL_B298_
  cp $11
  jr z, _LABEL_B298_
  cp $16
  jr z, _LABEL_B298_
  ret

_LABEL_B2B3_:
  ld a, (_RAM_D6C3_)
  ld c, a
  ld a, h
  sub c
  ld h, a
  ret

_LABEL_B2BB_:
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_9400_BlankSprites
  call _LABEL_90CA_BlankTiles_BlankControls
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_959C_LoadPunctuationTiles
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  call _LABEL_9448_LoadHeaderTiles
  call _LABEL_94AD_DrawHeaderTilemap
  call _LABEL_B305_DrawHorizontalLine_Top
+:
  ret

_LABEL_B2DC_:
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_9400_BlankSprites
  call _LABEL_90CA_BlankTiles_BlankControls
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_959C_LoadPunctuationTiles
  call _LABEL_9448_LoadHeaderTiles
  jp _LABEL_94AD_DrawHeaderTilemap

_LABEL_B2F3_DrawHorizontalLines_CharacterSelect:
  TilemapWriteAddressToHL 0, 19
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_95AF_DrawHorizontalLineIfSMS
  TilemapWriteAddressToHL 0, 26
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_95AF_DrawHorizontalLineIfSMS
  ; fall through
  
_LABEL_B305_DrawHorizontalLine_Top:
  TilemapWriteAddressToHL 0, 5
  call _LABEL_B35A_VRAMAddressToHL
  jp _LABEL_95AF_DrawHorizontalLineIfSMS

_LABEL_B30E_:
  ld a, $01
  ld (_RAM_D6C0_), a
-:
  ld a, $40
  ld (_RAM_D6AF_FlashingCounter), a
  ld a, (_RAM_D6B9_)
  ret

_LABEL_B31C_:
  xor a
  ld (_RAM_D6C0_), a
  jp -

_LABEL_B323_Populate_RAM_DBFE_:
  ; Copies data from _DATA_97DF_8TimesTable to _RAM_DBFE_
  ld hl, _DATA_97DF_8TimesTable
  ld de, _RAM_DBFE_
  ld bc, $0000
-:ld a, (hl)
  ld (de), a
  inc hl
  inc de
  inc bc
  ld a, c
  cp 11
  jr nz, -
  ret

_LABEL_B337_BlankTiles:
  TileWriteAddressToHL $00
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, 256 * TILE_DATA_SIZE ; lower tiles
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  TileWriteAddressToHL $100
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, 184 * TILE_DATA_SIZE ; Upper tiles
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

_LABEL_B35A_VRAMAddressToHL:
  ld a, l
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ret

_LABEL_B361_VRAMAddressToDE:
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ret

_LABEL_B368_:
  ld a, $01
  ld (_RAM_D6C1_), a
  xor a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6C5_PaletteFadeIndex), a
  ret

_LABEL_B375_ConfigureTilemapRect_5x6_24:
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

_LABEL_B389_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 22, 16 ; SMS
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_B1DD_No
  jr ++
+:TilemapWriteAddressToHL 21, 21 ; GG
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_B1E2_No
++:
  ret

_LABEL_B3A4_EmitToVDPAtDE_Text:
  call _LABEL_B361_VRAMAddressToDE
  ld bc, $000E
  call _LABEL_A5B0_EmitToVDP_Text
  ret

_LABEL_B3AE_:
  ld a, $06
  ld (_RAM_D6AB_), a
  ld a, (_RAM_D6AD_)
  sub $01
  cp $FF
  jr nz, +
  ld a, $0A
+:
  ld c, a
  ld b, $00
  call _LABEL_B412_
_LABEL_B3C4_:
  ld hl, _DATA_9773_TileWriteAddresses
  add hl, de
  ld (_RAM_D6BE_), de
  ld e, (hl)
  inc hl
  ld d, (hl)
  call _LABEL_B361_VRAMAddressToDE
  ld (_RAM_D6A8_DisplayCaseTileAddress), de
  ld hl, _DATA_97DF_8TimesTable
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BB_), a
  ld hl, _RAM_DBFE_
  add hl, bc
  ld a, (hl)
  ld (_RAM_D6BC_DisplayCase_IndexBackup), bc
  call _LABEL_9F40_
  call _LABEL_AECD_
  ld bc, (_RAM_D6BC_DisplayCase_IndexBackup)
  ld de, (_RAM_D6BE_)
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
  ld a, (_RAM_D6AB_)
  sub $01
  ld (_RAM_D6AB_), a
  or a
  jr nz, _LABEL_B3C4_
  ret

_LABEL_B412_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ld a, (_RAM_DBFB_)
  sub $03
  sra a
  sra a
  ld d, $00
  ld e, a
  ret

+:
  ld a, (_RAM_DBFB_)
  ld e, a
  ld d, $00
  ld hl, _DATA_9849_
  add hl, de
  ld e, (hl)
  ld d, $00
  ret

_LABEL_B433_:
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
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  ret

_LABEL_B44E_BlankMenuRAM:
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

_LABEL_B45D_:
  ld a, (_RAM_D6D4_) ; Only if 1
  or a
  jp z, +
  ld a, (_RAM_D691_TrackType)
  call _LABEL_B478_SelectPortraitPage
  ld hl, (_RAM_D7B5_DecompressorSource)
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  xor a
  ld (_RAM_D6D4_), a
  ld (_RAM_D6D3_VBlankDone), a
+:
  ret

_LABEL_B478_SelectPortraitPage:
  ; Indexes into a table with a to select the page number for a subsequent call to RAM code
  ld e, a
  ld d, $00
  ld hl, _DATA_926C_VehiclePortraitPageNumbers
  add hl, de
  ld a, (hl)
  ld (_RAM_D741_RequestedPageIndex), a
  ret

_LABEL_B484_CheckTitleScreenCheatCodes:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, ++ ; ret
  ; We wait for a "no buttons pressed" state between each button press.
  ld a, (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen)
  or a
  jr z, +
  ld a, (_RAM_D680_Player1Controls_Menus) ; We just saw one, wait for the buttons to lift
  cp NO_BUTTONS_PRESSED ; $3F
  jr nz, ++ ; ret
  xor a
  ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a ; Clear the flag
  ret

+:; We are ready to check. Was anything pressed?
  ld a, (_RAM_D680_Player1Controls_Menus)
  cp NO_BUTTONS_PRESSED ; $3F
  jr z, ++ ; ret
  ; We saw something - check it
  ld e, a
  call _CheckForCheatCode_HardMode
  call _CheckForCheatCode_CourseSelect
++:
  ret

; Data from B4AB to B4B4 (10 bytes)
_DATA_B4AB_CheatKeys_HardMode:
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
_DATA_B4B5_CheatKeys_CourseSelect:
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
  ld hl, _DATA_B4AB_CheatKeys_HardMode  ; Look up the button press
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
  ld hl, _DATA_B4B5_CheatKeys_CourseSelect ; Look up the button press
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

_LABEL_B505_UpdateHardModeText:
  ld a, (_RAM_DC46_Cheat_HardMode)
  or a
  ret z
  ; Get ready
  TilemapWriteAddressToHL 9, 13
  call _LABEL_B35A_VRAMAddressToHL
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
  ld hl, _TEXT_B541_HardMode
  jp _LABEL_A5B0_EmitToVDP_Text ; and ret

++:
  ld c, $0E
  ld hl, _TEXT_B54D_RockHardMode
  jp _LABEL_A5B0_EmitToVDP_Text ; and ret

+++:
  ld c, $0E
  ld hl, _TEXT_AAAE_Blanks
  jp _LABEL_A5B0_EmitToVDP_Text ; and ret

; Data from B541 to B54C (12 bytes)
_TEXT_B541_HardMode:
.asc "  HARD  MODE" ; .db $0E $0E $07 $00 $11 $03 $0E $0E $0C $1A $03 $04

; Data from B54D to B56C (32 bytes)
_TEXT_B54D_RockHardMode:
.asc "ROCK HARD MODE" ; .db $11 $1A $02 $0A $0E $07 $00 $11 $03 $0E $0C $1A $03 $04

; Unknown data
.db $AF $32
.db $46 $DC $32 $D0 $D6 $32 $45 $DC $21 $52 $7A $CD $5A $B3 $18 $CC

; 17th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_B56D_MenuScreen_TrackSelect:
  call _LABEL_B9C4_
  call _LABEL_A2AA_PrintOrFlashMenuScreenText
  call _LABEL_9FC5_
  ld a, (_RAM_D6C1_)
  cp $01
  jr z, _LABEL_B5E7_
  ld a, (_RAM_DC34_IsTournament)
  cp $01
  jr nz, ++
  call _LABEL_B9A3_
  ld a, (_RAM_D6CB_)
  xor $01
  ld (_RAM_D6CB_), a
  cp $01
  jr z, +
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
+:
  ld a, (_RAM_D6AB_)
  cp $B8
  jr z, ++++
  cp $40
  jr nc, +++
  jp _LABEL_B618_

++:
  ld a, (_RAM_D693_)
  cp $01
  jp z, _LABEL_B6AB_
  cp $00
  jp nz, _LABEL_A129_
  call _LABEL_B98E_
  ld a, (_RAM_D697_)
  cp $01
  jr z, _LABEL_B623_
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_L_MASK ; $04
  jp z, _LABEL_B640_
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_R_MASK ; $08
  jp z, _LABEL_B666_
  ld a, (_RAM_D6CC_)
  cp $00
  jr z, _LABEL_B618_
+++:
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK ; $10
  jr nz, _LABEL_B618_
++++:
  call _LABEL_B368_
  call _LABEL_9400_BlankSprites
  jp _LABEL_B618_

_LABEL_B5E7_:
  ld a, (_RAM_D6AB_)
  add a, $01
  ld (_RAM_D6AB_), a
  cp $04
  jr nz, _LABEL_B618_
  xor a
  ld (_RAM_D6AB_), a
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $FF
  jr z, +
  call _LABEL_BD2F_PaletteFade
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +
  call _LABEL_B1FC_
  ld a, $01
  ld (_RAM_DC3D_IsHeadToHead), a
  ld (_RAM_D6D5_InGame), a
_LABEL_B618_:
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  ld a, $01
  ld (_RAM_D6D5_InGame), a
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_B623_:
  ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
  and BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  cp BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  jr nz, _LABEL_B618_
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr nz, +
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  cp BUTTON_1_MASK | BUTTON_L_MASK | BUTTON_R_MASK ; $1C
  jr nz, _LABEL_B618_
+:
  xor a
  ld (_RAM_D697_), a
  ret

_LABEL_B640_:
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, +++
  ld a, (_RAM_D6CC_)
  sub $01
  cp $FF
  jr z, +
  or a
  jr nz, ++
+:
  ld a, $09
++:
  ld (_RAM_D6CC_), a
  jp ++++

+++:
  call _LABEL_B27E_
  call _LABEL_AB5B_GetPortraitSource_CourseSelect
  call _LABEL_AA8B_
  jp +++++

_LABEL_B666_:
  ld a, (_RAM_DC3B_IsTrackSelect)
  dec a
  jr z, ++
  ld a, (_RAM_D6CC_)
  add a, $01
  cp $0A
  jr nz, +
  ld a, $01
+:
  ld (_RAM_D6CC_), a
  jp ++++

++:
  call _LABEL_B298_
  call _LABEL_AB5B_GetPortraitSource_CourseSelect
  call _LABEL_AA8B_
  jp +++++

++++:
  call _LABEL_A01C_
  call _LABEL_AB68_GetPortraitSource_TrackType
+++++:
  call _LABEL_A0F0_BlankTilemapRectangle
  ld a, $01
  ld (_RAM_D6D4_), a
  ld a, $09
  ld (_RAM_D693_), a
  ld de, $6C00
  ld (_RAM_D6A8_DisplayCaseTileAddress), de
  ld a, $01
  ld (_RAM_D697_), a
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_B6AB_:
  call _LABEL_ABB3_
  jp _LABEL_80FC_EndMenuScreenHandler

; 18th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_B6B1_MenuScreen_TwoPlayerResult:
  call _LABEL_B9C4_
  call _LABEL_A039_
  ld hl, (_RAM_D6AB_)
  inc hl
  ld (_RAM_D6AB_), hl
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
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  ld a, (_RAM_DC34_IsTournament)
  dec a
  jr z, +++
  call _LABEL_8114_Menu0
++:
  jp _LABEL_80FC_EndMenuScreenHandler

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
  call _LABEL_8A30_
  jp _LABEL_80FC_EndMenuScreenHandler

+:
  call _LABEL_B877_
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_B70B_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_TrackSelect
  ld (_RAM_D699_MenuScreenIndex), a
  ld e, BLANK_TILE_INDEX
  call _LABEL_9170_BlankTilemap_BlankControlsRAM
  call _LABEL_9400_BlankSprites
  call _LABEL_90CA_BlankTiles_BlankControls
  call _LABEL_BAFF_LoadFontTiles
  call _LABEL_959C_LoadPunctuationTiles
  call _LABEL_A296_LoadHandTiles
  ld a, $01
  ld (_RAM_DC3B_IsTrackSelect), a
  ld (_RAM_D6CC_), a
  ld (_RAM_DBD8_CourseSelectIndex), a
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call _LABEL_9448_LoadHeaderTiles
  call _LABEL_94AD_DrawHeaderTilemap
  TilemapWriteAddressToHL 0, 5
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_95AF_DrawHorizontalLineIfSMS
  ld a, $60
  ld (_RAM_D6AF_FlashingCounter), a
  xor a
  ld (_RAM_D6AB_), a
  ld (_RAM_D6AC_), a
  ld (_RAM_D6C1_), a
  ld (_RAM_D693_), a
  ld (_RAM_D6CE_), a
  call _LABEL_AB5B_GetPortraitSource_CourseSelect
  call _LABEL_AB9B_Decompress3bppTiles_Index160
  call _LABEL_ABB0_
  ld c, $07
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  call _LABEL_A673_
  call _LABEL_9317_InitialiseHandSprites
  ld hl, _DATA_2B356_SpriteNs_HandLeft
  CallRamCode _LABEL_3BBB5_PopulateSpriteNs
  call _LABEL_BF2E_LoadMenuPalette_SMS
  call _LABEL_BB75_
  ret

_LABEL_B77C_:
  ld hl, _RAM_DC36_
  add hl, de
  ld a, (hl)
  add a, $01
  ld (hl), a
  ret

_LABEL_B785_:
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
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC36_)
  call _LABEL_B7F1_
  TilemapWriteAddressToHL 14, 8
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_B7F9_
  TilemapWriteAddressToHL 17, 7
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC37_)
  call _LABEL_B7F1_
  TilemapWriteAddressToHL 17, 8
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  jp _LABEL_B7F9_

+:
  TilemapWriteAddressToHL 14, 17
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC36_)
  call _LABEL_B7F1_
  TilemapWriteAddressToHL 14, 18
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  call _LABEL_B7F9_
  TilemapWriteAddressToHL 17, 17
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC37_)
  call _LABEL_B7F1_
  TilemapWriteAddressToHL 17, 18
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  jp _LABEL_B7F9_

_LABEL_B7F1_:
  sla a
  add a, $60
  ld c, a
  out (PORT_VDP_DATA), a
  ret

_LABEL_B7F9_:
  ld a, c
  add a, $01
  out (PORT_VDP_DATA), a
  ret

_LABEL_B7FF_:
  ld de, $0000
  ld a, (_RAM_DBD4_)
  ld c, a
  ld a, (_RAM_DBCF_LastRacePosition)
  call +
  ld de, $0001
  ld a, (_RAM_DBD5_)
  ld c, a
  ld a, (_RAM_DBD0_HeadToHeadLost2)
  jp +

+:
  or a
  jr z, +
  ld hl, _RAM_DC16_
  jp ++

+:
  call _LABEL_B77C_
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
_LABEL_B84D_MenuScreen_TournamentChampion:
  call _LABEL_B911_
  ld a, (_RAM_D6AB_)
  cp $FF
  jr z, +
  add a, $01
  ld (_RAM_D6AB_), a
  cp $80
  jr c, ++
+:
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr z, +
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_1_MASK ; $10
  jr nz, ++
+:
  call _LABEL_B1F4_Trampoline_StopMenuMusic
  call _LABEL_8114_Menu0
++:
  jp _LABEL_80FC_EndMenuScreenHandler

_LABEL_B877_:
  call _LABEL_BB85_ScreenOn
  ld a, MenuScreen_TournamentChampion
  ld (_RAM_D699_MenuScreenIndex), a
  ld a, $B2
  ld (_RAM_D6C8_HeaderTilesIndexOffset), a
  call _LABEL_B2DC_
  call _LABEL_B305_DrawHorizontalLine_Top
  call _LABEL_B8CF_
  call _LABEL_B8E3_
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC34_IsTournament)
  or a
  jr nz, +
  ld c, $03
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  jp ++

+:
  ld c, $0C
  call _LABEL_B1EC_Trampoline_PlayMenuMusic
  ld a, (_RAM_DBCF_LastRacePosition)
  or a
  jr z, ++
  ld a, (_RAM_DBD5_)
  jp +++

++:
  ld a, (_RAM_DBD4_)
+++:
  call _LABEL_9F40_
  TilemapWriteAddressToHL 19, 16
  call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
  xor a
  ld (_RAM_D6AB_), a
  call _LABEL_BB75_
  ret

_LABEL_B8C9_EmitTilemapRectangle_5x6_24:
  call _LABEL_B375_ConfigureTilemapRect_5x6_24
  jp _LABEL_BCCF_EmitTilemapRectangleSequence

_LABEL_B8CF_:
  ld a, :_DATA_1B2C3_Tiles_Trophy
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_1B2C3_Tiles_Trophy
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $160
  ld de, 82 * 8 ; 82 tiles
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_B8E3_:
  ld a, :_DATA_279F0_Tilemap_
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_279F0_Tilemap_
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TilemapWriteAddressToHL 7, 14
  call _LABEL_B35A_VRAMAddressToHL
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
  JumpToRamCode _LABEL_3BB57_EmitTilemapRectangle

_LABEL_B911_:
  ld a, (_RAM_D6AF_FlashingCounter)
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jp nz, +++
  ld a, (_RAM_DC3F_GameMode)
  dec a
  jr z, ++
  TilemapWriteAddressToHL 6, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld a, (_RAM_DC34_IsTournament)
  or a
  jr z, +
  ld hl, _TEXT_B966_TournamentChampion
  ld bc, $0014
  jp _LABEL_A5B0_EmitToVDP_Text

+:
  ld hl, _TEXT_B97A_Challenge
  ld bc, $0014
  jp _LABEL_A5B0_EmitToVDP_Text

++:
  TilemapWriteAddressToHL 11, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_B984_Champion
  ld bc, $000A
  jp _LABEL_A5B0_EmitToVDP_Text

+++:
  TilemapWriteAddressToHL 6, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_AAAE_Blanks
  ld bc, $0014
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from B966 to B979 (20 bytes)
_TEXT_B966_TournamentChampion:
.asc "TOURNAMENT CHAMPION!" ; $13 $1A $14 $11 $0D $00 $0C $04 $0D $13 $0E $02 $07 $00 $0C $0F $08 $1A $0D $B4

; Data from B97A to B983 (10 bytes)
_TEXT_B97A_Challenge:
.asc "CHALLENGE " ; $02 $07 $00 $0B $0B $04 $0D $06 $04 $0E

; Data from B984 to B98D (10 bytes)
_TEXT_B984_Champion:
.asc "CHAMPION !" ; $02 $07 $00 $0C $0F $08 $1A $0D $0E $B4

_LABEL_B98E_:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, _LABEL_B9A3_
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, _LABEL_B9A3_
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  ld (_RAM_D6C9_ControllingPlayersLR1Buttons), a
  ret

_LABEL_B9A3_:
  ld a, (_RAM_D680_Player1Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  ld c, a
  ld a, (_RAM_D681_Player2Controls_Menus)
  and BUTTON_L_MASK | BUTTON_R_MASK | BUTTON_1_MASK ; $1C
  and c
  ld (_RAM_D6C9_ControllingPlayersLR1Buttons), a
  ret

_LABEL_B9B3_:
  ld hl, _RAM_DC2C_
  ld c, $08
-:
  xor a
  ld (hl), a
  inc hl
  dec c
  jr nz, -
  ld a, $01
  ld (_RAM_DC31_), a
  ret

_LABEL_B9C4_:
  ld e, $08
-:
  ld a, (_RAM_D6CF_)
  add a, $01
  and $07
  ld (_RAM_D6CF_), a
  ld c, a
  ld b, $00
  ld hl, _RAM_DC2C_
  add hl, bc
  ld a, (hl)
  or a
  jr z, +
  dec e
  jr nz, -
+:
  ld a, (_RAM_D7B3_)
  add a, $01
  cp $0B
  jr nz, +
  ld a, $01
+:
  ld (_RAM_D7B3_), a
  ret

_LABEL_B9ED_:
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
  call _LABEL_B35A_VRAMAddressToHL
  ld a, $50 ; Tile $150
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  TilemapWriteAddressToHL 23, 10
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld a, $53 ; Tile $153
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ret

+:
  TilemapWriteAddressToHL 8, 20
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld a, $50 ; Tile $150
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  TilemapWriteAddressToHL 23, 20
  add hl, de
  call _LABEL_B35A_VRAMAddressToHL
  ld a, $53 ; Tile $153
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
  ret

_LABEL_BA3C_LoadColouredCirclesTilesToIndex150:
  TileWriteAddressToHL $150
  call _LABEL_B35A_VRAMAddressToHL

_LABEL_BA42_LoadColouredCirclesTiles:
  ld a, :_DATA_22B8C_Tiles_ColouredCircles
  ld (_RAM_D741_RequestedPageIndex), a
  ld e, 4 * 8 ; 4 tiles
  ld hl, _DATA_22B8C_Tiles_ColouredCircles
  JumpToRamCode _LABEL_3BB45_Emit3bppTileDataToVRAM

_LABEL_BA4F_LoadMediumNumberTiles:
  ld a, :_DATA_2794C_Tiles_MediumNumbers
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_2794C_Tiles_MediumNumbers
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 10 * 8 ; 10 tiles
  TileWriteAddressToHL $60
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_BA63_:
  ld a, (_RAM_D6AF_FlashingCounter)
  cp $00
  jr z, +
  sub $01
  ld (_RAM_D6AF_FlashingCounter), a
  sra a
  sra a
  sra a
  and $01
  jr nz, ++
  ; Text
  TilemapWriteAddressToHL 11, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, _TEXT_BAB7_Qualifying
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 11, 12
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, _TEXT_BAC1_Race
  call _LABEL_A5B0_EmitToVDP_Text
+:
  ret

++:
  ; Blanks (for flashing)
  TilemapWriteAddressToHL 11, 11
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, _TEXT_BACB_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 11, 12
  call _LABEL_B35A_VRAMAddressToHL
  ld bc, $000A
  ld hl, _TEXT_BACB_Blanks
  call _LABEL_A5B0_EmitToVDP_Text
  ret

; Data from BAB7 to BAC0 (10 bytes)
_TEXT_BAB7_Qualifying:
.asc "QUALIFYING" ; $10 $14 $00 $0B $08 $05 $18 $08 $0D $06

; Data from BAC1 to BACA (10 bytes)
_TEXT_BAC1_Race:
.asc "   RACE   " ; $0E $0E $0E $11 $00 $02 $04 $0E $0E $0E

; Data from BACB to BAD4 (10 bytes)
_TEXT_BACB_Blanks:
.asc "          " ; $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E

_LABEL_BAD5_LoadMenuLogoTiles:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS: big logo
  ld a, :_DATA_22C4E_Tiles_BigLogo
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_22C4E_Tiles_BigLogo
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 177 * 8 ; 177 tiles
  jr ++

+:; GG: medium logo
  ld a, :_DATA_3E5D7_Tiles_MediumLogo
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_3E5D7_Tiles_MediumLogo
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ld de, 112 * 8 ; 122 tiles
++:
  TileWriteAddressToHL $100
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL ; and ret

_LABEL_BAFF_LoadFontTiles:
  ld a, :_DATA_2B02D_Tiles_Font
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_2B02D_Tiles_Font
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL 0
  ld de, 36 * 8 ; 36 tiles
  jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_BB13_:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +

  ; SMS: draw sports cars portrait
  ld a, :_DATA_FAA5_Tiles_Portrait_SportsCars
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_FAA5_Tiles_Portrait_SportsCars
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $24
  ld de, 80 * 8 ; 80 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  jr ++

+:; GG: blank tiles
  ld bc, 80 * 32 ; 80 tiles
  TileWriteAddressToHL $24
  call _LABEL_B35A_VRAMAddressToHL
-:xor a
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -

++:
  ld a, $01
  ld (_RAM_D6CB_), a
  call _LABEL_90E7_
  ret

_LABEL_BB49_SetMenuHScroll:
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  ; SMS scroll 6, GG scroll 0
  ld a, $06
  jr ++
+:xor a
++:out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_XSCROLL
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_BB5B_SetBackdropToColour0:
  xor a
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_BACKDROP_COLOUR
  out (PORT_VDP_REGISTER), a
  ret

; Data from BB63 to BB6B (9 bytes)
.db $3E $70 $D3 $BF $3E $81 $D3 $BF $C9

_LABEL_BB6C_ScreenOff:
  ld a, $10
  out (PORT_VDP_REGISTER), a
  ld a, $81
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_BB75_:
  ; Wait for line $ff
-:in a, (PORT_VDP_LINECOUNTER)
  cp $FF
  jr nz, -
  ; Screen on
  ld a, $70
  out (PORT_VDP_REGISTER), a
  ld a, $81
  out (PORT_VDP_REGISTER), a
  ei
  ret

_LABEL_BB85_ScreenOn:
-:di
  ; Wait for line $ff
  in a, (PORT_VDP_LINECOUNTER)
  cp $FF
  jr nz, -
  ; Screen on
  ld a, $10
  out (PORT_VDP_REGISTER), a
  ld a, $81
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_BB95_LoadIconMenuGraphics:
  ld a, (_RAM_D6C7_)
  dec a
  jr z, _LABEL_BBE0_LoadTwoPlayerTournamentSingleRaceGraphics
  
  ; _RAM_D6C7_ != 1
  ; Load chopper portrait - unused
  ld a, :_DATA_26C52_Tiles_Challenge_Icon
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_26C52_Tiles_Challenge_Icon
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $24
  ld de, 60 * 8 ; 60 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ; GG
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_SelectPlayerCount
  jr z, ++
+:; Both SMS and (GG if not selecting player count)
  ; Load "head to head" image tiles
  ld hl, _DATA_26FC6_Tiles_HeadToHead_Icon
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $74
  ld de, 60 * 8 ; 60 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  jp +++

++:
  ; GG selecting player count: replace "head to head" icon with "two players on one game gear"
  ld hl, _DATA_27A12_Tiles_TwoPlayersOnOneGameGear_Icon
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $74
  ld de, 60 * 8 ; 60 tiles
  call _LABEL_BD94_Emit4bppTileDataToVRAMAddressHL
  jp +++

_LABEL_BBE0_LoadTwoPlayerTournamentSingleRaceGraphics:
  ; _RAM_D6C7_ == 1
  ; Load tournament icon
  ld a, :_DATA_27391_Tiles_Tournament_Icon
  
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_27391_Tiles_Tournament_Icon
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $24
  ld de, 54 * 8 ; 54 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  
  ld hl, _DATA_27674_Tiles_SingleRace_Icon
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $74
  ld de, 54 * 8 ; 54 tiles
  call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
+++:
  call _LABEL_A296_LoadHandTiles
  call _LABEL_949B_LoadHeadToHeadTextTiles
  jp _LABEL_948A_LoadChallengeTextTiles ; tail call optimisation

_LABEL_BC0C_:
  ld a, (_RAM_D6C7_)
  or a
  jr z, +
  ld a, $09
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  jp ++
+:ld a, $0A
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
  ld a, $24
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  xor a
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToHL 18, 18
  jr ++
+:TilemapWriteAddressToHL 16, 15
++:
  ld a, (_RAM_D6C7_)
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
+:ld a, $74
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $06
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  call _LABEL_BCCF_EmitTilemapRectangleSequence
  ld a, (_RAM_D699_MenuScreenIndex)
  cp MenuScreen_TwoPlayerGameType
  jr z, _LABEL_BCCE_ret
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 4, 25
  jr ++
+:TilemapWriteAddressToDE 6, 21
++:
  call _LABEL_B361_VRAMAddressToDE
  ld hl, _DATA_2B4BA_Tilemap_ChallengeText
  ld a, $08
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $02
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, $F0
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode _LABEL_3BB57_EmitTilemapRectangle
  ld a, (_RAM_DC3C_IsGameGear)
  dec a
  jr z, +
  TilemapWriteAddressToDE 18, 25
  jr ++
+:TilemapWriteAddressToDE 16, 21
++:
  call _LABEL_B361_VRAMAddressToDE
  ld hl, _DATA_2B5BE_Tilemap_HeadToHeadText
  ld a, $0A
  ld (_RAM_D69D_EmitTilemapRectangle_Width), a
  ld a, $02
  ld (_RAM_D69E_EmitTilemapRectangle_Height), a
  ld a, $E2
  ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
  CallRamCode _LABEL_3BB57_EmitTilemapRectangle
_LABEL_BCCE_ret:
  ret

_LABEL_BCCF_EmitTilemapRectangleSequence:
  ; Emits a rectangle of tilemap data
  ; with sequential tile indexes
  ; hl = start location
  ; _RAM_D69A_TilemapRectangleSequence_Width = width
  ; _RAM_D69B_TilemapRectangleSequence_Height = height (modified)
  ; _RAM_D68A_TilemapRectangleSequence_TileIndex = start tile index (modified)
  ; _RAM_D69C_TilemapRectangleSequence_Flags = tile high byte
  call _LABEL_B35A_VRAMAddressToHL
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
  jr z, +
  ld de, $0040
  add hl, de
  jp _LABEL_BCCF_EmitTilemapRectangleSequence

+:
  ret

_LABEL_BD00_InitialiseVDPRegisters:
  ld a, $26 ; TODO: docuement these
  out (PORT_VDP_REGISTER), a
  ld a, $80
  out (PORT_VDP_REGISTER), a
  ld a, $0E
  out (PORT_VDP_REGISTER), a
  ld a, $82
  out (PORT_VDP_REGISTER), a
  ld a, $7F
  out (PORT_VDP_REGISTER), a
  ld a, $85
  out (PORT_VDP_REGISTER), a
  ld a, $04
  out (PORT_VDP_REGISTER), a
  ld a, $86
  out (PORT_VDP_REGISTER), a
  xor a
  out (PORT_VDP_REGISTER), a
  ld a, $88
  out (PORT_VDP_REGISTER), a
  xor a
  out (PORT_VDP_REGISTER), a
  ld a, $89
  out (PORT_VDP_REGISTER), a
  ret

_LABEL_BD2F_PaletteFade:
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  cp $06
  jr z, _LABEL_BD7C_
  cp $03
  jr nc, +
  ld hl, _DATA_BD58_Palettes_SMS
  call _LABEL_BD82_GetPalettePointerAndSelectIndex0
  ld b, 7 ; count
  ld c, PORT_VDP_DATA
  otir
  ld hl, $C010 ; Palette index $10
  CallRamCode _LABEL_3BCC7_VRAMAddressToHL
  ld a, (de) ; 0th palette value
  out (PORT_VDP_DATA), a
+:
  ld a, (_RAM_D6C5_PaletteFadeIndex)
  add a, $01
  ld (_RAM_D6C5_PaletteFadeIndex), a
  ret

; Pointer Table from BD58 to BD5B (2 entries, indexed by unknown)
_DATA_BD58_Palettes_SMS:
.dw _DATA_BD5E_Palette1_SMS _DATA_BD65_Palette2_SMS _DATA_BD6C_Palette3_SMS

; 1st entry of Pointer Table from BD58 (indexed by unknown)
; Data from BD5E to BD64 (7 bytes)
_DATA_BD5E_Palette1_SMS:
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
_DATA_BD65_Palette2_SMS:
  ; Darker
  SMSCOLOUR $000000
  SMSCOLOUR $555555
  SMSCOLOUR $000000
  SMSCOLOUR $000000
  SMSCOLOUR $550000
  SMSCOLOUR $550000
  SMSCOLOUR $000055

; Data from BD6C to BD7B (16 bytes)
_DATA_BD6C_Palette3_SMS:
_DATA_BD6C_ZeroData:
  ; Black (16 entries)
.dsb 16 $00

_LABEL_BD7C_:
  ld a, $FF
  ld (_RAM_D6C5_PaletteFadeIndex), a
  ret

_LABEL_BD82_GetPalettePointerAndSelectIndex0:
  ; Gets a'th pointer to de and hl, also sets palette index to 0
  sla a
  ld c, a
  ld b, $00
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  ld hl, $C000 ; Palette index 0
  CallRamCode _LABEL_3BCC7_VRAMAddressToHL
  ld h, d
  ld l, e
  ret

_LABEL_BD94_Emit4bppTileDataToVRAMAddressHL:
  call _LABEL_B35A_VRAMAddressToHL
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

_LABEL_BDA6_:
  ld (_RAM_D6AB_), a
  ld (_RAM_D6A3_), a
  ld a, NO_BUTTONS_PRESSED ; $3F
  ld (_RAM_D680_Player1Controls_Menus), a
  ld (_RAM_D681_Player2Controls_Menus), a
  ld (_RAM_D687_Player1Controls_PreviousFrame), a
  ret

_LABEL_BDB8_:
  ld a, (_RAM_DC3C_IsGameGear)
  or a
  jr z, +
  ld a, :_DATA_17C0C_Tiles_TwoPlayersOnOneGameGear
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_17C0C_Tiles_TwoPlayersOnOneGameGear
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  TileWriteAddressToHL $170
  ld de, 20 * 8 ; 20 tiles
  call _LABEL_BD94_Emit4bppTileDataToVRAMAddressHL
  TilemapWriteAddressToHL 16, 21
  ld a, $70
  ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
  ld a, $02
  ld (_RAM_D69B_TilemapRectangleSequence_Height), a
  ld a, $0A
  ld (_RAM_D69A_TilemapRectangleSequence_Width), a
  ld a, $01
  ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
  call _LABEL_BCCF_EmitTilemapRectangleSequence
+:
  ret

_LABEL_BDED_LoadMenuLogoTilemap: ; TODO: how does it work for GG?
  ; Decompress to RAM
  ld a, :_DATA_2FF6F_Tilemap
  ld (_RAM_D741_RequestedPageIndex), a
  ld hl, _DATA_2FF6F_Tilemap
  CallRamCode _LABEL_3B97D_DecompressFromHLToC000
  ; Draw to name table
  TilemapWriteAddressToHL 0, 0
  call _LABEL_B35A_VRAMAddressToHL
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
  JumpToRamCode _LABEL_3BB57_EmitTilemapRectangle ; and ret

_LABEL_BE1A_DrawCopyrightText:
  ld a, (_RAM_D6CB_)
  or a
  ret z
  xor a
  ld (_RAM_D6CB_), a
  TilemapWriteAddressToHL 0, 26
  call _LABEL_B35A_VRAMAddressToHL
  ld c, $1A
  ld hl, _TEXT_BE77_CopyrightCodemasters
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 0, 27
  call _LABEL_B35A_VRAMAddressToHL
  ld c, $1C
  ld hl, _TEXT_BE91_SoftwareCompanyLtd1993
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 4, 16
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_BEAD_MasterSystemVersionBy
  ld c, $18
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 18
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_BEC5_AshleyRoutledge
  ld c, $14
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 19
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_BED9_And
  ld c, $0D
  call _LABEL_A5B0_EmitToVDP_Text
  TilemapWriteAddressToHL 6, 20
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _TEXT_BEE4_DavidSaunders
  ld c, $11
  jp _LABEL_A5B0_EmitToVDP_Text

; Data from BE77 to BE90 (26 bytes)
_TEXT_BE77_CopyrightCodemasters:
.asc "     COPYRIGHT CODEMASTERS" ; $0E $0E $0E $0E $0E $02 $1A $0F $18 $11 $08 $06 $07 $13 $0E $02 $1A $03 $04 $0C $00 $12 $13 $04 $11 $12

; Data from BE91 to BEAC (28 bytes)
_TEXT_BE91_SoftwareCompanyLtd1993:
.asc "   SOFTWARE COMPANY LTD 1993" ; $0E $0E $0E $12 $1A $05 $13 $16 $00 $11 $04 $0E $02 $1A $0C $0F $00 $0D $18 $0E $0B $13 $03 $0E $1B $23 $23 $1D

; Data from BEAD to BEC4 (24 bytes)
_TEXT_BEAD_MasterSystemVersionBy:
.asc "MASTER SYSTEM VERSION BY" ; $0C $00 $12 $13 $04 $11 $0E $12 $18 $12 $13 $04 $0C $0E $15 $04 $11 $12 $08 $1A $0D $0E $01 $18

; Data from BEC5 to BED8 (20 bytes)
_TEXT_BEC5_AshleyRoutledge:
.asc "  ASHLEY ROUTLEDGE  " ; $0E $0E $00 $12 $07 $0B $04 $18 $0E $11 $1A $14 $13 $0B $04 $03 $06 $04 $0E $0E

; Data from BED9 to BEE3 (11 bytes)
_TEXT_BED9_And:
.asc "        AND" ; $0E $0E $0E $0E $0E $0E $0E $0E $00 $0D $03

; Data from BEE4 to BEF4 (17 bytes)
_TEXT_BEE4_DavidSaunders:
.asc "   DAVID SAUNDERS" ; $0E $0E $0E $03 $00 $15 $08 $03 $0E $12 $00 $14 $0D $03 $04 $11 $12

_LABEL_BEF5_:
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
  jr +

+:
  call _LABEL_B35A_VRAMAddressToHL
  ld c, $07
-:
  ld a, BLANK_TILE_INDEX
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  dec c
  jr nz, -
  ret

_LABEL_BF2E_LoadMenuPalette_SMS:
  ld hl, $C000 ; Palette index 0
  call _LABEL_B35A_VRAMAddressToHL
  ld hl, _DATA_BF3E_MenuPalette_SMS
  ld b, $20
  ld c, PORT_VDP_DATA
  otir
  ret

; Data from BF3E to BF4F (18 bytes)
_DATA_BF3E_MenuPalette_SMS:
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

/*
; Data from BF5E to BF6E (16 bytes)
; Code?
.db $18 $00
.db $CD $58 $B3 $0E $05 $3E $0E $D3 $BE $AF $D3 $BE $0D $20 $F6

; Data from BF6F to BFFE (144 bytes)
.db $C9 $21 $00 $C0 $CD $58 $B3 $21 $80 $BF $06 $40 $0E $BE $ED $B3
.db $C9 $04 $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $44 $0E $00
.db $00 $22 $02 $44 $04 $88 $08 $40 $00 $C0 $00 $E0 $00 $AE $0A $00
.db $00 $04 $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $88 $0E $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $FE $FF $EE $FF $FE $EF $EF $EE $FF $FF $EF $EF $FA $EF $FF
.db $7F $EA $EF $EE $FF $FA $FF $EB $FF $FF $FE $7F $EF $BA $FE $EF
.db $EE $FE $FB $EF $EB $FB $EF $AE $BD $FE $FF $EF $EE $AF $BF $FF
.db $FF $FF $FF $FE $BB $EE $FB $EF $EE $FE $FF $FF $BA $FE $FF $EF
*/

_LABEL_BF5E_: ; GG-only code, misaligned here
  jr + ; Weird
+:call $B358 ; not a function
  ld c, $05
-:ld a, $0e
  out (PORT_VDP_DATA), a
  xor a
  out (PORT_VDP_DATA), a
  dec c
  jr nz, -
  ret

_LABEL_BF70_: ; unused code? Left over memory?
  ld hl, $c000
  call $b358
  ld hl, _DATA_BF80_
  ld b, $40
  ld c, PORT_VDP_DATA
  otir
  ret

_DATA_BF80_: ; GG menu palette(s)?
.db $04 $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $44 $0E $00 $00
.db $22 $02 $44 $04 $88 $08 $40 $00 $C0 $00 $E0 $00 $AE $0A $00 $00
.db $04

_DATA_BFA1_: ; Treated as text but not text..? Unused?
.db     $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $88 $0E $00 $00
_DATA_BFB0_: ; Same as above
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

; blank space?
.db $00 $FE $FF $EE $FF $FE $EF $EF $EE $FF $FF $EF $EF $FA $EF $FF
.db $7F $EA $EF $EE $FF $FA $FF $EB $FF $FF $FE $7F $EF $BA $FE $EF
.db $EE $FE $FB $EF $EB $FB $EF $AE $BD $FE $FF $EF $EE $AF $BF $FF
.db $FF $FF $FF $FE $BB $EE $FB $EF $EE $FE $FF $FF $BA $FE $FF $EF

; Data from BFFF to BFFF (1 bytes)
_DATA_BFFF_Page2PageNumber:
.db :CADDR

.BANK 3
.ORG $0000

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
.dstruct _DATA_C000_TrackData_SportsCars instanceof TrackData data  _DATA_E480_SportsCars_BehaviourData _DATA_E799_SportsCars_WallData _DATA_E811_SportsCars_Track0Layout _DATA_EA34_SportsCars_Track1Layout _DATA_ED79_SportsCars_Track2Layout _DATA_F155_SportsCars_GGPalette _DATA_F155_SportsCars_GGPalette _DATA_F195_SportsCars_DecoratorTiles _DATA_F215_SportsCars_Data _DATA_F255_SportsCars_EffectsTiles

.incbin "Assets/raw/Micro Machines_c000.inc" skip $0014 read $246c ; ??? 

_DATA_E480_SportsCars_BehaviourData:
.incbin "Assets/Sportscars/Behaviour data.compressed"
_DATA_E799_SportsCars_WallData:
.incbin "Assets/Sportscars/Wall data.compressed"
_DATA_E811_SportsCars_Track0Layout:
.incbin "Assets/Sportscars/Track 0 layout.compressed"
_DATA_EA34_SportsCars_Track1Layout:
.incbin "Assets/Sportscars/Track 1 layout.compressed"
_DATA_ED79_SportsCars_Track2Layout:
.incbin "Assets/Sportscars/Track 2 layout.compressed"
_DATA_F155_SportsCars_GGPalette:
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
_DATA_F195_SportsCars_DecoratorTiles
.incbin "Assets/Sportscars/Decorators.1bpp"
_DATA_F215_SportsCars_Data:
.db $22 $00 $5D $4D $6F $7B $00 $00 $00 $00 $22 $22 $22 $22 $80 $C0 $C0 $C0 $C0 $E0 $E0 $C0 $E0 $C0 $80 $A0 $A0 $A0 $A0 $A0 $22 $C0 $22 $C0 $A0 $A0 $C0 $C0 $C0 $C0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $A0 $80 $80 $C0 $A0 $80 $C0 $00 $00
_DATA_F255_SportsCars_EffectsTiles:
.incbin "Assets/Sportscars/Effects.3bpp"

_DATA_F35D_Tiles_Portrait_FourByFour:
.incbin "Assets/Four By Four/Portrait.3bpp.compressed"

_DATA_F765_Tiles_Portrait_Warriors:
.incbin "Assets/Warriors/Portrait.3bpp.compressed"

_DATA_FAA5_Tiles_Portrait_SportsCars:
.incbin "Assets/Sportscars/Portrait.3bpp.compressed"

; Track names
_DATA_FDC1_TrackName_00: .asc "THE BREAKFAST BENDS "
_DATA_FDD5_TrackName_01: .asc "  DESKTOP DROP-OFF  "
_DATA_FDE9_TrackName_02: .asc "    OILCAN ALLEY    "
_DATA_FDFD_TrackName_03: .asc "  SANDY STRAIGHTS   "
_DATA_FE11_TrackName_04: .asc "OATMEAL IN OVERDRIVE"
_DATA_FE25_TrackName_05: .asc "THE CUE-BALL CIRCUIT"
_DATA_FE39_TrackName_06: .asc "  HANDYMANS CURVE   "
_DATA_FE4D_TrackName_07: .asc "  BERMUDA BATHTUB   "
_DATA_FE61_TrackName_08: .asc "   SAHARA SANDPIT   "
_DATA_FE75_TrackName_09: .asc " THE POTTED PASSAGE " ; Helicopter!
_DATA_FE89_TrackName_10: .asc "FRUIT-JUICE FOLLIES "
_DATA_FE9D_TrackName_11: .asc "    FOAMY FJORDS    "
_DATA_FEB1_TrackName_12: .asc "BEDROOM BATTLEFIELD "
_DATA_FEC5_TrackName_13: .asc "  PITFALL POCKETS   "
_DATA_FED9_TrackName_14: .asc "  PENCIL PLATEAUX   "
_DATA_FEED_TrackName_15: .asc "THE DARE-DEVIL DUNES"
_DATA_FF01_TrackName_16: .asc "THE SHRUBBERY TWIST " ; Helicopter!
_DATA_FF15_TrackName_17: .asc " PERILOUS PIT-STOP  "
_DATA_FF29_TrackName_18: .asc "WIDE-AWAKE WAR-ZONE "
_DATA_FF3D_TrackName_19: .asc "   CRAYON CANYONS   "
_DATA_FF51_TrackName_20: .asc "  SOAP-LAKE CITY !  "
_DATA_FF65_TrackName_21: .asc "  THE LEAFY BENDS   " ; Helicopter!
_DATA_FF79_TrackName_22: .asc " CHALK-DUST CHICANE "
_DATA_FF8D_TrackName_23: .asc "     GO FOR IT!     "
_DATA_FFA2_TrackName_24: .asc " WIN THIS RACE TO BE CHAMPION!" ; Special case for length
_DATA_FFBF_TrackName_25: .asc "RUFFTRUX BONUS STAGE"

; blank fill
.dsb 44 $ff
; Page number marker
.db :CADDR

.BANK 4
.ORG $0000

; Data from 10000 to 13FFF (16384 bytes)
.dstruct _DATA_10000_TrackData_FourByFour instanceof TrackData data _DATA_9E50_FourByFour_BehaviourData _DATA_A105_FourByFour_WallData _DATA_A152_FourByFour_Track0Layout _DATA_A378_FourByFour_Track1Layout _DATA_A466_FourByFour_Track2Layout _DATA_A466_FourByFour_Track2Layout _DATA_A762_FourByFour_GGPalette _DATA_A7A2_FourByFour_DecoratorTiles _DATA_A822_FourByFour_Data _DATA_A862_FourByFour_EffectsTiles

; ???
.incbin "Assets/raw/Micro Machines_10000.inc" skip $10014-$10000 read $11e50-$10014

_DATA_9E50_FourByFour_BehaviourData:
.incbin "Assets/Four by Four/Behaviour data.compressed"
_DATA_A105_FourByFour_WallData:
.incbin "Assets/Four by Four/Wall data.compressed"
_DATA_A152_FourByFour_Track0Layout:
.incbin "Assets/Four by Four/Track 0 layout.compressed"
_DATA_A378_FourByFour_Track1Layout:
.incbin "Assets/Four by Four/Track 1 layout.compressed"
_DATA_A466_FourByFour_Track2Layout:
.incbin "Assets/Four by Four/Track 2 layout.compressed"
_DATA_A762_FourByFour_GGPalette:
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

_DATA_A7A2_FourByFour_DecoratorTiles:
.incbin "Assets/Four by Four/Decorators.1bpp"

_DATA_A822_FourByFour_Data:
.db $C0 $00 $22 $49 $73 $00 $00 $00 $00 $22 $22 $22 $22 $00 $C0 $C0
.db $C0 $C0 $C0 $C0 $C0 $C0 $80 $80 $80 $00 $80 $C0 $C0 $C0 $A0 $C0
.db $22 $C0 $C0 $80 $80 $80 $80 $80 $00 $00 $80 $80 $80 $80 $80 $00
.db $00 $80 $80 $80 $80 $45 $77 $00 $00 $00 $00 $00 $00 $00 $00 $00

_DATA_A862_FourByFour_EffectsTiles:
.incbin "Assets/Four by Four/Effects.3bpp"

_DATA_1296A_CarTiles_RuffTrux:
.incbin "Assets/RuffTrux/Car.3bpp.runencoded"
.dsb 3, 0 ; padding?

_DATA_13C42_Tiles_BigNumbers:
.incbin "Assets/Menu/Numbers-Big.3bpp.compressed"

_DATA_13D7F_Tiles_MicroMachinesText:
.incbin "Assets/Menu/Text-MicroMachines.3bpp.compressed"

_DATA_13F38_Tilemap_SmallLogo: ; 8x3
.incbin "Assets/Menu/Logo-small.tilemap"

_DATA_13F50_Tilemap_MicroMachinesText:
.incbin "Assets/Menu/Text-MicroMachines.tilemap"

.incbin "Assets/raw/Micro Machines_10000.inc" skip $13f68-$10000 read $13fff-$13f68

.db :CADDR

.BANK 5
.ORG $0000

.dstruct _DATA_14000_TrackData_Powerboats instanceof TrackData data _DATA_9D30_Powerboats_BehaviourData _DATA_9FE3_Powerboats_WallData _DATA_A03C_Powerboats_Track0Layout _DATA_A134_Powerboats_Track1Layout _DATA_A352_Powerboats_Track2Layout _DATA_A5B1_Powerboats_Track3Layout _DATA_A7A0_Powerboats_GGPalette _DATA_A7E0_Powerboats_DecoratorTiles _DATA_A860_Powerboats_Data _DATA_A8A0_Powerboats_EffectsTiles 

; ???
.incbin "Assets/raw/Micro Machines_14000.inc" skip $14014-$14000 read $15d30-$14014

_DATA_9D30_Powerboats_BehaviourData:
.incbin "Assets/Powerboats/Behaviour data.compressed"
_DATA_9FE3_Powerboats_WallData:
.incbin "Assets/Powerboats/Wall data.compressed"
_DATA_A03C_Powerboats_Track0Layout:
.incbin "Assets/Powerboats/Track 0 layout.compressed"
_DATA_A134_Powerboats_Track1Layout:
.incbin "Assets/Powerboats/Track 1 layout.compressed"
_DATA_A352_Powerboats_Track2Layout:
.incbin "Assets/Powerboats/Track 2 layout.compressed"
_DATA_A5B1_Powerboats_Track3Layout:
.incbin "Assets/Powerboats/Track 3 layout.compressed"
_DATA_A7A0_Powerboats_GGPalette:
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
_DATA_A7E0_Powerboats_DecoratorTiles:
.incbin "Assets/Powerboats/Decorators.1bpp"
_DATA_A860_Powerboats_Data:
.db $C0 $A0 $A0 $E0 $73 $80 $C0 $49 $80 $E0 $77 $C0 $45 $C0 $A0 $A0
.db $A0 $C0 $80 $80 $80 $00 $80 $80 $80 $A0 $A0 $C0 $C0 $22 $A0 $A0
.db $A0 $A0 $80 $C0 $80 $80 $A0 $A0 $A0 $22 $41 $63 $A0 $A0 $A0 $A0
.db $A0 $A0 $A0 $A0 $A0 $A0 $A0 $80 $C0 $C0 $C0 $41 $A0 $00 $00 $00
_DATA_A8A0_Powerboats_EffectsTiles:
.incbin "Assets/Powerboats/Effects.3bpp"

; Data from 169A8 to 16A37 (144 bytes)
_DATA_169A8_IndexToBitmask:
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
_DATA_16A38_DivideBy8:
.define n 0
.repeat 144
.db n/8
.redefine n n+1
.endr
.undefine n

_DATA_16AC8_Tiles_Portrait_TurboWheels:
.incbin "Assets/Turbo Wheels/Portrait.3bpp.compressed"

_DATA_16F2B_Tiles_Portrait_FormulaOne:
.incbin "Assets/Formula One/Portrait.3bpp.compressed"

_DATA_1736E_Tiles_Portrait_Tanks:
.incbin "Assets/Tanks/Portrait.3bpp.compressed"

_DATA_Tiles_MrQuestion:
.incbin "Assets/racers/MrQuestion.3bpp"

_DATA_Tiles_OutOfGame:
.incbin "Assets/racers/OutOfGame.3bpp"

_DATA_17C0C_Tiles_TwoPlayersOnOneGameGear:
.incbin "Assets/Menu/Text-TwoPlayersOnOneGameGear.4bpp.compressed"

; Data from 17DD5 to 17E54 (128 bytes)
_DATA_17DD5_Tiles_Playoff:
.incbin "Assets/Playoff.4bpp"

_LABEL_17E95_LoadPlayoffTiles:
  ld a, $80 ; Tile $19c
  out (PORT_VDP_ADDRESS), a
  ld a, $73
  out (PORT_VDP_ADDRESS), a
  ld bc, 4 * 8 ; 4 tiles
  ld hl, _DATA_17DD5_Tiles_Playoff
  call _LABEL_17EB4_LoadTileRow
  ld a, $80 ; TIle $1a4
  out (PORT_VDP_ADDRESS), a
  ld a, $74
  out (PORT_VDP_ADDRESS), a
  ld bc, 2 * 8 ; 2 tiles
  ld hl, _DATA_17DD5_Tiles_Playoff+4*32
  ; fall through
_LABEL_17EB4_LoadTileRow:
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
_DATA_17EC2_SMSPalettes:
.dw _DATA_17ED2_SMSPalette_SportsCars
.dw _DATA_17EF2_SMSPalette_FourByFour
.dw _DATA_17F12_SMSPalette_Powerboats
.dw _DATA_17F32_SMSPalette_TurboWheels
.dw _DATA_17F52_SMSPalette_FormulaOne
.dw _DATA_17F72_SMSPalette_Warriors
.dw _DATA_17F92_SMSPalette_Tanks
.dw _DATA_17FB2_SMSPalette_RuffTrux

; 1st entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17ED2 to 17EF1 (32 bytes)
_DATA_17ED2_SMSPalette_SportsCars:
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
_DATA_17EF2_SMSPalette_FourByFour:
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
_DATA_17F12_SMSPalette_Powerboats:
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
_DATA_17F32_SMSPalette_TurboWheels:
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
_DATA_17F52_SMSPalette_FormulaOne:
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
_DATA_17F72_SMSPalette_Warriors:
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
_DATA_17F92_SMSPalette_Tanks:
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
_DATA_17FB2_SMSPalette_RuffTrux:
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

; Uninitialised data? Mostly set bits
.db $FF $FF $FF $FF $FF $FF $FF $DF $FF $FF $FF $DF $FF $FF $FF $7F
.db $FF $7F $FF $FF $FF $7F $FF $FF $FF $7F $FE $FF $FF $FF $FF $FF
.db $FF $F7 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF

; Bank index marker
.db :CADDR

.BANK 6
.ORG $0000

; Data from 18000 to 1B1A1 (12706 bytes)
_DATA_18000_TrackData_TurboWheels: ; TODO
.incbin "Assets/raw/Micro Machines_18000.inc"

; Data from 1B1A2 to 1B231 (144 bytes)
_DATA_1B1A2_:
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
_DATA_1B232_:
.incbin "Assets/raw/Micro Machines_1b232.inc" skip $1B232-$1B232 read $1b2c3-$1B232

_DATA_1B2C3_Tiles_Trophy:
.incbin "Assets/raw/Micro Machines_1b232.inc" skip $1b2c3-$1B232 read $1b7a7-$1b2c3

_DATA_1B7A7_SMS:
.incbin "Assets/raw/Micro Machines_1b232.inc" skip $1b7a7-$1B232 read $1b987-$1b7a7

_DATA_1B987_GG:
.incbin "Assets/raw/Micro Machines_1b232.inc" skip $1b987-$1B232 read $1bab3-$1b987

_LABEL_1BAB3_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld a, (_RAM_DBD4_)
  srl a
  srl a
  srl a
  ld e, a
  ld d, $00
  ld hl, _RAM_DC21_
  add hl, de
  ld a, (hl)
  or a
  jr z, +
  ld hl, _DATA_1BAF2_
  add hl, de
  ld a, (hl)
  ld (_RAM_D5CF_), a
+:
  ld a, (_RAM_DBD5_)
  srl a
  srl a
  srl a
  ld e, a
  ld d, $00
  ld hl, _RAM_DC21_
  add hl, de
  ld a, (hl)
  or a
  jr z, ++
  ld hl, _DATA_1BAF2_
  add hl, de
  ld a, (hl)
  ld (_RAM_D5D0_), a
++:
  ret

; Data from 1BAF2 to 1BAFC (11 bytes)
_DATA_1BAF2_:
.db $00 $00 $03 $00 $00 $00 $02 $00 $00 $01 $00

_LABEL_1BAFD_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
-:
  ret

+:
  ld a, (_RAM_DE4F_)
  cp $80
  jr nz, -
  ld a, (_RAM_DF58_)
  or a
  jr nz, -
  ld a, (_RAM_DD1A_)
  or a
  jr nz, -
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, -
  ld a, (_RAM_DF00_)
  or a
  jr nz, -
  ld a, (_RAM_DD00_)
  or a
  jr nz, -
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

; Data from 1BC87 to 1BC87 (1 bytes)
.db $C9 ; ret

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

_LABEL_1BCCB_DelayIfPlayer2:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, ++ ; ret
  ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
  or a
  jr z, +
  jr ++ ; ret
+:; Player 2
  ld hl, $0000 ; Waste some time
-:dec hl
  ld a, h
  or l
  jr nz, -
++:
  ret

_LABEL_1BCE2_:
  ld a, (iy+1)
  or a
  jr nz, +
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
  ld hl, _DATA_1D65_
  ld a, (iy+1)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (iy+1)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  push de
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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

+:
  ld a, $01
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
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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

_LABEL_1BDF3_:
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

; Data from 1BE31 to 1BE31 (1 bytes)
.db $C9

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
  jp +++

; Data from 1BE56 to 1BE56 (1 bytes)
.db $C9

+:
  sub l
  ld (_RAM_DEB1_VScrollDelta), a
  ld a, (_RAM_DF0E_)
  ld (_RAM_DEB2_), a
  jp +++

; Data from 1BE64 to 1BE64 (1 bytes)
.db $C9

++:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DF0C_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DEB1_VScrollDelta), a
  jp +++

; Data from 1BE77 to 1BE77 (1 bytes)
.db $C9

+:
  ld a, $07
  ld (_RAM_DEB1_VScrollDelta), a
  jp +++

; Data from 1BE80 to 1BE80 (1 bytes)
.db $C9

+++:
  ret

_LABEL_1BE82_:
  ld a, $26
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_MODECONTROL1
  out (PORT_VDP_REGISTER), a
  ld a, $0E
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_NAMETABLEBASEADDRESS
  out (PORT_VDP_REGISTER), a
  ld a, $7F
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_SPRITETABLEBASEADDRESS
  out (PORT_VDP_REGISTER), a
  ld a, $04
  out (PORT_VDP_REGISTER), a
  ld a, VDP_REGISTER_UNUSED6
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

_LABEL_1BEB1_ChangePoolTableColour:
  ; Updates palette indexes 1-2 for the pool table tracks
  ; to change the colour of the cloth
  ld a, (_RAM_DB97_TrackType)
  cp TT_FormulaOne
  jr nz, _LABEL_1BEF2_ret ; Only for F1 tracks
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ; Game Gear
  SetPaletteAddressImmediateGG 1
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, _LABEL_1BEF2_ret
  cp $01
  jr z, +
  ; Track 2
  EmitGGColourImmediate $880044 ; pink
  EmitGGColourImmediate $440000 ; dark red
  ret
+:; Track 1
  EmitGGColourImmediate $004488 ; turquoise
  EmitGGColourImmediate $000044 ; dark blue
  ret

_LABEL_1BEF2_ret:
  ret

++:
  ; Master System
  SetPaletteAddressImmediateSMS 1
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, _LABEL_1BEF2_ret
  cp $01
  jr z, +
  ; Track 2
  EmitSMSColourImmediate $aa0055 ; pink
  EmitSMSColourImmediate $550000 ; dark red
  ret
+:; Track 1
  EmitSMSColourImmediate $0055aa ; turquoise
  EmitSMSColourImmediate $000055 ; dark blue
  ret

_LABEL_1BF17_:
  ld a, (ix+30)
  or a
  jr z, +
  cp $06
  jr nz, ++ ; ret
+:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, ++ ; ret
  ld l, (ix+47)
  ld h, (ix+48)
  xor a
  ld (hl), a
  ld (ix+20), a
  jp _LABEL_2961_

; Data from 1BF35 to 1BF43 (15 bytes)
.db $DD $7E $0C $6F $DD $BE $0D $3E $00 $20 $01 $3C $DD $77 $0B

++: ret

; Data from 1BF45 to 1BFFF (187 bytes)
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
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF :CADDR

.BANK 7
.ORG $0000

; Data from 1C000 to 1F8D7 (14552 bytes)
_DATA_1C000_TrackData_FormulaOne: ; TODO
.incbin "Assets/raw/Micro Machines_1c000.inc" skip 0 read $1f3e4-$1c000

_DATA_1F3E4_Tiles_Portrait_Powerboats:
.incbin "Assets/Powerboats/Portrait.3bpp.compressed"

_LABEL_1F8D8_: ; Cheats!
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  ret nz
  call _LABEL_1FA23_ApplyFasterVehiclesCheat
  ; Compute metatile X, Y
  ld a, (_RAM_DBA0_)
  ld l, a
  ld a, (_RAM_DE79_)
  add a, l
  ld (_RAM_D5C8_MetatileX), a
  ld a, (_RAM_DBA2_)
  ld l, a
  ld a, (_RAM_DE7B_)
  add a, l
  ld (_RAM_D5C9_MetatileY), a

  ld a, (_RAM_DB97_TrackType)
  or a ; TT_SportsCars
  jp z, _LABEL_1F9D4_Cheats_SportsCars
  cp TT_FourByFour
  jr z, +
  ret

+:; Four by Four
  call _LABEL_1FA05_NoSkidCheatCheck ; for any track index
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
  ld a, $12
  ld (_RAM_D963_SFXTrigger2), a
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
  cp $03
  jr nz, +
  ld a, $12
  ld (_RAM_D974_SFXTrigger), a
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
  ld a, $12
  ld (_RAM_D974_SFXTrigger), a
  ld a, $01
  ld (_RAM_DC4C_Cheat_AlwaysFirstPlace), a
  ret

+:
  ld a, (_RAM_DC4E_Cheat_SuperSkids)
  or a
  jr nz, _LABEL_1F996_ret
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
  jr nz, _LABEL_1F996_ret
  ld a, $12
  ld (_RAM_D974_SFXTrigger), a ; Play sound effect
  ld a, $01
  ld (_RAM_DC4E_Cheat_SuperSkids), a ; And this
_LABEL_1F996_ret:
  jp ++

+:
  ld a, (_RAM_D5C8_MetatileX) ; Or c, 5 = matching orange juice - new info!
  cp $0C
  jr nz, _LABEL_1F996_ret
  ld a, (_RAM_D5C9_MetatileY)
  cp $05
  jr z, -
  ret

++:
  ld a, (_RAM_DC4F_Cheat_EasierOpponents)
  or a
  jr nz, +
  ; Tile 16, 1 = top right and falling and reversing
  ld a, (_RAM_D5C8_MetatileX) ; 16, 1
  cp $10
  jr nz, +
  ld a, (_RAM_D5C9_MetatileY)
  cp $01
  jr nz, +
  ld a, (_RAM_DF59_CarState) ; Falling
  cp $03
  jr nz, +
  ld a, (_RAM_D5A4_IsReversing) ; Reversing
  or a
  jr z, +
  ld a, $12
  ld (_RAM_D974_SFXTrigger), a
  ld a, $01
  ld (_RAM_DC4F_Cheat_EasierOpponents), a
+:
  ret

_LABEL_1F9D4_Cheats_SportsCars:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr nz, + ; ret
  ; Sports Cars 0 = Desktop Drop-off
  ld a, (_RAM_DC4A_Cheat_ExtraLives) ; Laps done?
  or a
  jr nz, +
  ; Tile 5, 24 = bototm half of pencil far to theleft of the start position, and 4 laps remaining
  ld a, (_RAM_D5C8_MetatileX) ; 5, 24
  cp $05
  jr nz, +
  ld a, (_RAM_D5C9_MetatileY)
  cp $18
  jr nz, +
  ld a, (_RAM_DF24_LapsRemaining) ; Haven't crossed the start line yet
  cp $04
  jr nz, +
  ld a, $12
  ld (_RAM_D974_SFXTrigger), a
  ld a, $01
  ld (_RAM_DC4A_Cheat_ExtraLives), a
  ld a, $05
  ld (_RAM_DC09_Lives), a
+:
  ret

_LABEL_1FA05_NoSkidCheatCheck:
  ld a, (_RAM_DC4D_Cheat_NoSkidding)
  or a
  jr nz, + ; ret
  ; U+1+2 while driving into/on milk on any Four by Four track
  ; -> cars don't skid (new!)
  ld a, (_RAM_D5CD_CarIsSkidding)
  or a
  jr z, + ; ret
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_U_MASK | BUTTON_1_MASK | BUTTON_2_MASK ; $31
  jr nz, +
  ld a, $12
  ld (_RAM_D963_SFXTrigger2), a ; TODO: find more of these
  ld a, $01
  ld (_RAM_DC4D_Cheat_NoSkidding), a
+:
  ret

_LABEL_1FA23_ApplyFasterVehiclesCheat:
  ; Changes the car parameters to top speed = 12, acceleration and deceleration delay = 6
  ; Can go up to 15, 16 glitches sound, higher glitches out everything
  ld a, (_RAM_DC50_Cheat_FasterVehicles)
  or a
  jr z, + ; ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, $0B ; 12
  ld (_RAM_DB98_TopSpeed), a
  ld a, $06 ; 6
  ld (_RAM_DB99_AccelerationDelay), a
  ld (_RAM_DB9A_DecelerationDelay), a
+:
  ret

_LABEL_1FA3D_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_1FA95_
  ld a, (_RAM_DE4F_)
  cp $80
  jr nz, _LABEL_1FA95_
  ld a, (_RAM_DF58_)
  or a
  jr nz, _LABEL_1FA95_
  ld a, (_RAM_DF74_RuffTruxSubmergedCounter)
  or a
  jr nz, _LABEL_1FA95_
  ld a, (_RAM_DC3F_GameMode)
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

+:
  ld a, (_RAM_DB20_Player1Controls)
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
+:
  ld a, (_RAM_DE99_)
  or a
  jr nz, _LABEL_1FA95_
  ld hl, _RAM_DEA0_
  ld a, (hl)
  or a
  jr z, _LABEL_1FA95_
  dec (hl)
_LABEL_1FA95_:
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
  jp _LABEL_1295_

_LABEL_1FAE5_:
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
  jp _LABEL_1295_

_LABEL_1FB35_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_FourByFour
  jr z, ++++
  ld a, (ix+11)
  or a
  jr z, +++
  cp $01
  jr z, +++
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
  jr z, +++
  ld a, $07
  ld (_RAM_D974_SFXTrigger), a
+++:
  ret

++++:
  ld a, (ix+11)
  cp $03
  jr c, +++
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
  jr z, +++
  ld a, $07
  ld (_RAM_D974_SFXTrigger), a
+++:
  ret

; Data from 1FB81 to 1FFFF (1151 bytes)
; Unreferenced?
.incbin "Assets/raw/Micro Machines_1fb81.inc"

.BANK 8
.ORG $0000

; Data from 20000 to 237E1 (14306 bytes)
_DATA_20000_TrackData_Warriors: ; TODO
.incbin "Assets/raw/Micro Machines_20000.inc" skip 0 read $22B2C-$20000

_DATA_22B2C_Tiles_PunctuationAndLine:
.incbin "Assets/raw/Micro Machines_20000.inc" skip $22B2C-$20000 read $22B8C-$22B2C
_DATA_22B8C_Tiles_ColouredCircles:
.incbin "Assets/raw/Micro Machines_20000.inc" skip $22B8C-$20000 read $22BEC-$22B8C
_DATA_22BEC_Tiles_Cursor:
.incbin "Assets/raw/Micro Machines_20000.inc" skip $22BEC-$20000 read $22C4E-$22BEC
_DATA_22C4E_Tiles_BigLogo:
.incbin "Assets/raw/Micro Machines_20000.inc" skip $22C4E-$20000 read $23656-$22C4E
_DATA_23656_Tiles_VsCPUPatch:
.incbin "Assets/raw/Micro Machines_20000.inc" skip $23656-$20000 read $237e2-$23656

_LABEL_237E2_:
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
  ld a, (_RAM_DC55_CourseIndex)
  sla a
  ld b, a
  ld e, a
  ld d, $00
  ld hl, _DATA_238DE_
  add hl, de
  ld a, (hl)
  ld (_RAM_DB66_), a
  inc hl
  ld a, (hl)
  ld (_RAM_DB67_), a
  ld a, b
  sla a
  ld l, a
  ld h, $00
  add hl, de
  ld de, $B918
  add hl, de
  exx
    ld c, $06
  exx
  ld a, (_RAM_DC46_Cheat_HardMode)
  ld c, a
  ld a, (_RAM_DC54_IsGameGear)
  xor $01
  sla a
  ld b, a
  ld de, _RAM_DB68_
-:
  ld a, (hl)
  srl a
  srl a
  srl a
  srl a
  add a, b
  add a, c
  cp $0E
  jr c, +
  ld a, $0D
+:
  ld (de), a
  inc de
  ld a, (hl)
  and $0F
  add a, b
  add a, c
  cp $0E
  jr c, +
  ld a, $0D
+:
  ld (de), a
  inc de
  inc hl
  exx
    dec c
  exx
  jr nz, -
  ld a, (_RAM_DB69_)
  ld (_RAM_DCDC_), a
  ld a, (_RAM_DB6D_)
  ld (_RAM_DD1D_), a
  ld a, (_RAM_DB71_)
  ld (_RAM_DD5E_), a
  ld a, (_RAM_DB97_TrackType)
  ld e, a
  ld d, $00
  ld hl, _DATA_238D5_
  add hl, de
  ld a, (hl)
  ld (_RAM_DF97_), a
  ld a, (_RAM_DB97_TrackType)
  or a ; TT_SportsCars
  jr z, +
  cp TT_FormulaOne
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
_DATA_238D5_:
.db $08 $07 $09 $08 $09 $08 $04 $05 $05

; Data from 238DE to 239C5 (232 bytes)
_DATA_238DE_:
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $54 $42 $65 $53 $54 $42
.db $54 $43 $65 $54 $54 $43 $86 $63 $75 $52 $75 $52 $87 $75 $87 $75
.db $76 $65 $A9 $97 $A9 $87 $98 $86 $87 $75 $77 $66 $76 $65 $98 $87
.db $A9 $88 $88 $76 $A9 $88 $98 $87 $88 $77 $87 $76 $99 $87 $87 $66
.db $AA $98 $BB $A9 $A9 $87 $87 $76 $88 $77 $76 $66 $98 $77 $98 $88
.db $87 $66 $97 $65 $A8 $76 $87 $76 $76 $65 $86 $66 $66 $55 $AA $87
.db $AA $98 $98 $77 $CB $A9 $CC $BB $A9 $87 $A9 $97 $BA $98 $CB $A9
.db $76 $65 $76 $65 $65 $55 $98 $87 $CB $A9 $BA $98 $86 $66 $87 $76
.db $76 $65 $CC $BB $CB $A9 $A9 $87 $A9 $87 $BA $98 $97 $66 $76 $65
.db $76 $65 $65 $55 $BB $A9 $BB $AA $AA $98 $87 $76 $88 $76 $77 $66
.db $CC $CC $CC $BA $CB $A9 $66 $66 $66 $66 $66 $66 $66 $66 $66 $66
.db $66 $66 $66 $66 $66 $66 $66 $66

_LABEL_239C6_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr nz, +
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, +
  ld a, (_RAM_D5B9_)
  or a
  jr nz, ++
+:
  ret

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
  call _LABEL_23A91_
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

; Data from 23A40 to 23A40 (1 bytes)
.db $C9

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
  jp +++

; Data from 23A65 to 23A65 (1 bytes)
.db $C9

+:
  sub l
  ld (_RAM_DCFC_), a
  ld a, (_RAM_DF85_)
  ld (_RAM_DD0C_), a
  jp +++

; Data from 23A73 to 23A73 (1 bytes)
.db $C9

++:
  ld a, (_RAM_DCFC_)
  ld l, a
  ld a, (_RAM_DF83_)
  add a, l
  cp $07
  jr nc, +
  ld (_RAM_DCFC_), a
  jp +++

; Data from 23A86 to 23A86 (1 bytes)
.db $C9

+:
  ld a, $07
  ld (_RAM_DCFC_), a
  jp +++

; Data from 23A8F to 23A8F (1 bytes)
.db $C9

+++:
  ret

_LABEL_23A91_:
  ld hl, _DATA_1D65_
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  ld a, (_RAM_DCEC_)
  ld l, a
  ld a, (_RAM_DCED_)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF82_)
  ld e, a
  or a
  sbc hl, de
  ld a, l
  ld (_RAM_DCEC_), a
  ld a, h
  ld (_RAM_DCED_), a
  jp ++

+:
  ld a, $01
  ld (_RAM_DF84_), a
  ld a, (_RAM_DCEC_)
  ld l, a
  ld a, (_RAM_DCED_)
  ld h, a
  ld d, $00
  ld a, (_RAM_DF82_)
  ld e, a
  add hl, de
  ld a, l
  ld (_RAM_DCEC_), a
  ld a, h
  ld (_RAM_DCED_), a
++:
  ld hl, _DATA_1D65_
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_D5B9_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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

_LABEL_23B98_:
  ld bc, $0062
  ld hl, _RAM_D580_WaitingForGameVBlank
-:
  ld a, $00
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ld bc, $0012
  ld hl, _RAM_DB74_CarTileLoaderTableIndex
-:
  ld a, $00
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ld bc, $000B
  ld hl, _RAM_D940_
-:
  ld a, $00
  ld (hl), a
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

_LABEL_23BC6_:
  ld a, (_RAM_DF6C_)
  add a, $01
  and $01
  ld (_RAM_DF6C_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF5A_)
  cp $04
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

_LABEL_23BF1_:
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, ++
  ld hl, (_RAM_DBA9_)
  ld de, $0074
  add hl, de
  ld (_RAM_DCAB_), hl
  ld hl, (_RAM_DBA9_)
  ld de, $0090
  add hl, de
  ld (_RAM_DCEC_), hl
  ld (_RAM_DD2D_), hl
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
  jr z, +
  ld (_RAM_DCEE_), hl
+:
  ret

++:
  ld hl, (_RAM_DBA9_)
  ld de, $0014
  add hl, de
  ld (_RAM_DCAB_), hl
  ld hl, (_RAM_DBA9_)
  ld de, $0030
  add hl, de
  ld (_RAM_DCEC_), hl
  ld (_RAM_DD2D_), hl
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
  jr z, +
  ld (_RAM_DCEE_), hl
+:
  ret

_LABEL_23C68_:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr nz, +
-:
  ret

+:
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr nz, -
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr nz, +
  ld a, (_RAM_D59D_)
  or a
  jr z, +
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_2_MASK ; $20
  sla a
  sla a
  jp ++

+:
  in a, (PORT_GG_START)
++:
  ld (_RAM_D59C_GGStartButtonValue), a
  ld a, (_RAM_D599_IsPaused)
  or a
  jr nz, ++
  ld a, (_RAM_D59C_GGStartButtonValue)
  and $80
  jr z, +
  ret

+:
  ld a, $01
  ld (_RAM_D59A_), a
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
  ld a, (_RAM_D59A_)
  or a
  jr z, ++
  ld a, (_RAM_D59C_GGStartButtonValue)
  and $80
  jr z, +
  xor a
  ld (_RAM_D59A_), a
+:
  ret

++:
  ld a, (_RAM_D59C_GGStartButtonValue)
  and $80
  jr z, ++
  ld a, (_RAM_D59B_)
  or a
  jr z, +
  xor a
  ld (_RAM_D599_IsPaused), a
  ld (_RAM_D59B_), a
+:
  ret

++:
  ld a, $01
  ld (_RAM_D59B_), a
  ret

_LABEL_23CE6_UpdateAnimatedPalette:
  ; Updates the top half of the tile palette for Powerboats and Helicopters levels
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, _LABEL_23D4B_SMS_UpdateAnimatedPalette_SMS

  ; GG
  ld a, (_RAM_DB97_TrackType)
  cp TT_Helicopters
  jr z, +
  cp TT_Powerboats
  jr z, ++
  ret

+:; Helicopters (unused)
  ld hl, _DATA_1D25_HelicoptersAnimatedPalette_GG
  ld (_RAM_DF77_PaletteAnimationData), hl
  jp +++

++:; Powerboats
  ld hl, _DATA_1D35_PowerboatsAnimatedPalette_GG
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

_LABEL_23D4B_SMS_UpdateAnimatedPalette_SMS:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Helicopters
  jr z, +
  cp TT_Powerboats
  jr z, ++
  ret

+:
  ld hl, _DATA_23DA6_HelicoptersAnimatedPalette_SMS
  ld (_RAM_DF77_PaletteAnimationData), hl
  jp +++

++:
  ld hl, _DATA_23DAE_PowerboatsAnimatedPalette_SMS
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
_DATA_23DA6_HelicoptersAnimatedPalette_SMS
.db $30 $35 $3A $3F $30 $35 $3A $3F
_DATA_23DAE_PowerboatsAnimatedPalette_SMS
.db $21 $25 $3A $3F $3A $25 $21 $10

_LABEL_23DB6_:
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $77
  out (PORT_VDP_ADDRESS), a
  ld bc, $0380
-:
  ld a, $00
  out (PORT_VDP_DATA), a
  ld a, $00
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $7E
  out (PORT_VDP_ADDRESS), a
  ld bc, $0080
-:
  ld a, $14
  out (PORT_VDP_DATA), a
  ld a, $00
  out (PORT_VDP_DATA), a
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

; Data from 23DE7 to 23ECE (232 bytes)
_DATA_23DE7_HandlingData_GG:
; More forgiving handing on GG?
.db $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $24 $66 $66 $66 $66
.db $11 $11 $11 $14 $69 $CD $DD $DD
.db $11 $11 $45 $79 $BD $DD $DD $DD
.db $11 $11 $11 $47 $AC $DD $DD $DD
.db $11 $11 $11 $24 $66 $66 $66 $66
.db $11 $11 $11 $24 $68 $99 $99 $99
.db $11 $11 $45 $79 $BD $DD $DD $DD
.db $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $47 $AC $DD $DD $DD
.db $11 $14 $8B $DF $FF $FF $FF $FF
.db $11 $11 $11 $24 $66 $66 $66 $66
.db $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $24 $68 $99 $99 $99
.db $11 $11 $11 $14 $69 $CD $DD $DD
.db $11 $11 $11 $47 $AC $DD $DD $DD
.db $11 $14 $8B $DF $FF $FF $FF $FF
.db $11 $11 $45 $79 $BD $DD $DD $DD
.db $11 $11 $11 $11 $12 $33 $33 $33
.db $11 $11 $11 $14 $69 $CD $DD $DD
.db $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $14 $8B $DF $FF $FF $FF $FF
.db $11 $11 $11 $24 $68 $99 $99 $99
.db $11 $11 $11 $11 $12 $33 $33 $33
.db $11 $11 $11 $14 $69 $CD $DD $DD
.db $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11

; Data from 23ECF to 23FFF (305 bytes)
_DATA_23ECF_HandlingData_SMS:
; 16 nibbles per track
; Unpacked, left to right, from _RAM_DB86_HandlingData
; Maps speed to skidding?
; Per-track data, but actually the same for all tracks of the same type
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Bathtub
.db $11 $11 $12 $46 $66 $66 $66 $66 ; Breakfast
.db $11 $11 $11 $46 $9C $DD $DD $DD ; Desk
.db $11 $14 $57 $9B $DD $DD $DD $DD ; Garage
.db $11 $11 $14 $7A $CD $DD $DD $DD ; Sandpit
.db $11 $11 $12 $46 $66 $66 $66 $66 ; Breakfast
.db $11 $11 $12 $46 $89 $99 $99 $99 ; F1
.db $11 $14 $57 $9B $DD $DD $DD $DD ; Garage
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Bathtub
.db $11 $11 $14 $7A $CD $DD $DD $DD ; Sandpit
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Garden (unused)
.db $11 $11 $12 $46 $66 $66 $66 $66 ; Breakfast
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Bathtub
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Tanks
.db $11 $11 $12 $46 $89 $99 $99 $99 ; F1
.db $11 $11 $11 $46 $9C $DD $DD $DD ; Desk
.db $11 $11 $14 $7A $CD $DD $DD $DD ; Sandpit
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Garden (unused)
.db $11 $14 $57 $9B $DD $DD $DD $DD ; Garage
.db $11 $11 $11 $11 $23 $33 $33 $33 ; Tanks
.db $11 $11 $11 $46 $9C $DD $DD $DD ; Desk
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Bathtub
.db $11 $48 $BD $FF $FF $FF $FF $FF ; Garden (unused)
.db $11 $11 $12 $46 $89 $99 $99 $99 ; F1
.db $11 $11 $11 $11 $23 $33 $33 $33 ; Tanks
.db $11 $11 $11 $46 $9C $DD $DD $DD ; Desk
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Bonus
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Bonus
.db $11 $11 $11 $11 $11 $11 $11 $11 ; Bonus

; Fill to end of bank
.repeat 18
.db $FF $FF $00 $00
.endr

; Bank number
.db :CADDR

.BANK 9
.ORG $0000

; Data from 24000 to 27FFF (16384 bytes)
_DATA_24000_TrackData_Tanks: ; TODO
.incbin "Assets/raw/Micro Machines_24000.inc" skip $24000-$24000 read $26C52-$24000

_DATA_26C52_Tiles_Challenge_Icon:
.incbin "Assets/Menu/Icon-Challenge.3bpp.compressed"

_DATA_26FC6_Tiles_HeadToHead_Icon:
.incbin "Assets/Menu/Icon-HeadToHead.3bpp.compressed"

_DATA_27391_Tiles_Tournament_Icon:
.incbin "Assets/Menu/Icon-Tournament.3bpp.compressed"

_DATA_27674_Tiles_SingleRace_Icon:
.incbin "Assets/Menu/Icon-SingleRace.3bpp.compressed"

_DATA_2794C_Tiles_MediumNumbers:
.incbin "Assets/Menu/Numbers-Medium.3bpp.compressed"

_DATA_279F0_Tilemap_:
.incbin "Assets/raw/Micro Machines_24000.inc" skip $279f0-$24000 read $27a12-$279f0

_DATA_27A12_Tiles_TwoPlayersOnOneGameGear_Icon:
.incbin "Assets/raw/Micro Machines_24000.inc" skip $27a12-$24000 read $27efb-$27a12

.incbin "Assets/raw/Micro Machines_24000.inc" skip $27efb-$24000 read $27fff-$27efb

.db :CADDR

.BANK 10
.ORG $0000

; Data from 28000 to 2B5D1 (13778 bytes)
_DATA_28000_TrackData_RuffTrux: ; TODO
.incbin "Assets/raw/Micro Machines_28000.inc" skip 0 read $2AB4D-$28000

_DATA_2AB4D_Tiles_Portrait_RuffTrux:
.incbin "Assets/RuffTrux/Portrait.3bpp.compressed"

_DATA_2B02D_Tiles_Font:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2b02d-$28000 read $2b151-$2b02d

_DATA_2B151_Tiles_Hand:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2b151-$28000 read $2b33e-$2b151

_DATA_2B33E_SpriteNs_Hand:

_DATA_2B33E_SpriteNs_HandFist:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2b33e-$28000 read $2b356-$2b33e

_DATA_2B356_SpriteNs_HandLeft:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2b356-$28000 read $2b36e-$2b356

_DATA_2B36E_SpriteNs_HandRight:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2b36e-$28000 read $2b386-$2b36e

_DATA_2B386_Tiles_ChallengeText:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2b386-$28000 read $2B4BA-$2b386

_DATA_2B4BA_Tilemap_ChallengeText:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2B4BA-$28000 read $2B4CA-$2B4BA

_DATA_2B4CA_Tiles_HeadToHeadText:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2B4CA-$28000 read $2B5BE-$2B4CA

_DATA_2B5BE_Tilemap_HeadToHeadText:
.incbin "Assets/raw/Micro Machines_28000.inc" skip $2B5BE-$28000 read $2B5D2-$2B5BE


_LABEL_2B5D2_GameVBlankUpdateSoundTrampoline:
  jp _LABEL_2B616_Sound

_LABEL_2B5D5_SilencePSG:
  ld a, $FF
  out (PORT_PSG), a
  ld a, $9F
  out (PORT_PSG), a
  ld a, $BF
  out (PORT_PSG), a
  ld a, $DF
  out (PORT_PSG), a
  ret

; Data from 2B5E6 to 2B615 (48 bytes)
.db $3A $7E $D9 $32 $63 $D9 $C9 $3A $7F $D9 $32 $74 $D9 $C9 $2A $5B
.db $D9 $01 $04 $00 $A7 $ED $42 $22 $5B $D9 $C9 $2A $6C $D9 $01 $04
.db $00 $A7 $ED $42 $22 $6C $D9 $C9 $2A $5B $D9 $23 $22 $5B $D9 $C9

_LABEL_2B616_Sound:
  ld a, (_RAM_D957_SoundIndex)
  ld c, a
  inc a
  and $07
  ld (_RAM_D957_SoundIndex), a
  ld a, c
  and $03
  ld (_RAM_D956_), a
  ld ix, _RAM_D963_SFXTrigger2
  ld bc, _RAM_D94C_Sound1Channel0Volume
  call _LABEL_2B7A1_SoundFunction
  call +
  ld ix, _RAM_D974_SFXTrigger
  ld bc, _RAM_D94F_Sound2Channel0Volume
  call _LABEL_2B7A1_SoundFunction
  call ++
  ld a, (_RAM_D95A_)
  or a
  jr nz, _LABEL_2B699_Sound
  call _LABEL_2B6C9_Sound
  call _LABEL_2B70D_
  jp _LABEL_2B751_

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

_LABEL_2B699_Sound:
  ld a, (_RAM_D96B_SoundMask)
  ld c, a
  ld a, (_RAM_D97C_Sound)
  or c
  ret nz
  ld a, (_RAM_D957_SoundIndex)
  add a, a
  ld c, a
  ld b, $00
  ld hl, _DATA_2B791_SoundTable
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

_LABEL_2B6C9_Sound:
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

_LABEL_2B70D_:
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
_LABEL_2B72B_:
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

_LABEL_2B751_:
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
_DATA_2B791_SoundTable:
.db $02 $0F
.db $07 $0B
.db $00 $07
.db $00 $03
.db $02 $0F
.db $07 $0B
.db $00 $07
.db $00 $03

_LABEL_2B7A1_SoundFunction:
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
  ld hl, _DATA_2B911_
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
    ld hl, _DATA_2B87B_
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

; Data from 2B87B to 2B910 (150 bytes)
_DATA_2B87B_:
.db $00 $00 $F9 $03 $C0 $03 $8A $03 $57 $03 $27 $03 $FA $02 $CF $02
.db $A7 $02 $81 $02 $5D $02 $3B $02 $1B $02 $FC $01 $E0 $01 $C5 $01
.db $AC $01 $94 $01 $7D $01 $68 $01 $53 $01 $40 $01 $2E $01 $1D $01
.db $0D $01 $FE $00 $F0 $00 $E2 $00 $D6 $00 $CA $00 $BE $00 $B4 $00
.db $AA $00 $A0 $00 $97 $00 $8F $00 $87 $00 $7F $00 $78 $00 $71 $00
.db $6B $00 $65 $00 $5F $00 $5A $00 $55 $00 $50 $00 $4C $00 $47 $00
.db $43 $00 $40 $00 $3C $00 $39 $00 $35 $00 $32 $00 $30 $00 $2D $00
.db $2A $00 $28 $00 $26 $00 $24 $00 $22 $00 $20 $00 $1E $00 $1C $00
.db $1B $00 $19 $00 $18 $00 $16 $00 $15 $00 $14 $00 $13 $00 $12 $00
.db $11 $00 $10 $00 $0F $00

; Data from 2B911 to 2BFFF (1775 bytes)
_DATA_2B911_:
.incbin "Assets/raw/Micro Machines_2b911.inc" read $57a

; End of bank

.repeat $174/4
.db $ff $ff $00 $00 ; Uninitialised data
.endr
.db :CADDR

.BANK 11
.ORG $0000

_DATA_2C000_TrackData_Helicopters_BadReference:

; Data from 2C000 to 2FFFF (16384 bytes)
; Portrait data (3bpp)
_DATA_Tiles_Anne_Happy:
.incbin "Assets/Racers/Anne-Happy.3bpp"
_DATA_Tiles_Anne_Sad:
.incbin "Assets/Racers/Anne-Sad.3bpp"
_DATA_Tiles_Bonnie_Happy:
.incbin "Assets/Racers/Bonnie-Happy.3bpp"
_DATA_Tiles_Bonnie_Sad:
.incbin "Assets/Racers/Bonnie-Sad.3bpp"
_DATA_Tiles_Chen_Happy:
.incbin "Assets/Racers/Chen-Happy.3bpp"
_DATA_Tiles_Chen_Sad:
.incbin "Assets/Racers/Chen-Sad.3bpp"
_DATA_Tiles_Cherry_Happy:
.incbin "Assets/Racers/Cherry-Happy.3bpp"
_DATA_Tiles_Cherry_Sad:
.incbin "Assets/Racers/Cherry-Sad.3bpp"
_DATA_Tiles_Dwayne_Happy:
.incbin "Assets/Racers/Dwayne-Happy.3bpp"
_DATA_Tiles_Dwayne_Sad:
.incbin "Assets/Racers/Dwayne-Sad.3bpp"
_DATA_Tiles_Emilio_Happy:
.incbin "Assets/Racers/Emilio-Happy.3bpp"
_DATA_Tiles_Emilio_Sad:
.incbin "Assets/Racers/Emilio-Sad.3bpp"
_DATA_Tiles_Jethro_Happy:
.incbin "Assets/Racers/Jethro-Happy.3bpp"
_DATA_Tiles_Jethro_Sad:
.incbin "Assets/Racers/Jethro-Sad.3bpp"
_DATA_Tiles_Joel_Happy:
.incbin "Assets/Racers/Joel-Happy.3bpp"
_DATA_Tiles_Joel_Sad:
.incbin "Assets/Racers/Joel-Sad.3bpp"
_DATA_Tiles_Mike_Happy:
.incbin "Assets/Racers/Mike-Happy.3bpp"
_DATA_Tiles_Mike_Sad:
.incbin "Assets/Racers/Mike-Sad.3bpp"
_DATA_Tiles_Spider_Happy:
.incbin "Assets/Racers/Spider-Happy.3bpp"
_DATA_Tiles_Spider_Sad:
.incbin "Assets/Racers/Spider-Sad.3bpp"
_DATA_Tiles_Walter_Happy:
.incbin "Assets/Racers/Walter-Happy.3bpp"
_DATA_Tiles_Walter_Sad:
.incbin "Assets/Racers/Walter-Sad.3bpp"

_DATA_2FDE0_Tiles_SmallLogo:
.incbin "Assets/Menu/Logo-small.3bpp.compressed"

_DATA_2FF6F_Tilemap:
.incbin "Assets/Menu/Logo-big.tilemap.compressed"

; End of bank
.db $00 $FF $FF $00 $00 :CADDR

.BANK 12
.ORG $0000

; Data from 30000 to 30A67 (2664 bytes)
_DATA_30000_CarTiles_FormulaOne:
.incbin "Assets/Formula One/Car.3bpp.runencoded"
.dsb 4, 0 ; Unneeded padding from manual placement?
_DATA_30330_CarTiles_Warriors:
.incbin "Assets/Warriors/Car.3bpp.runencoded"
.dsb 4, 0
_DATA_306D0_CarTiles_Tanks:
.incbin "Assets/Tanks/Car.3bpp.runencoded"
.dsb 7, 0

; Data from 30A68 to 30C67 (512 bytes)
_DATA_30A68_ChallengeHUDTiles:
; 4bpp tiles (32 bytes per tile)
; - Car colour squares *4 (first is highlighted)
; - "st", "nd", "rd", "th"
; - Car colour "finished" squares *4
; - Smoke (unused?) *4
; - Lap remaining numbers (1-4)
.incbin "Assets/Challenge HUD.4bpp"

_LABEL_30CE8_PlayMenuMusic:
  or a
  jr nz, +
  ld a, $04 ; 0 -> 4
+:
  dec a ; Subtract 1
  ld c, a
  ex af, af'
    ; Look up first value and put in RAM
    ld b, $00
    ld hl, _DATA_31410_
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
  ld hl, _DATA_314F7_ ; Look up second value
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

_LABEL_30D28_StopMenuMusic:
  ld hl, _DATA_314AF_MenuMusicStopData
  ld de, _RAM_D91A_MenuSoundData
  ld bc, _DATA_314AF_MenuMusicStopData_End - _DATA_314AF_MenuMusicStopData
  ldir
  jp _LABEL_30F7D_

_LABEL_30D36_MenuMusicFrameHandler:
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
  jp nz, _LABEL_30DC7_
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
  ld hl, _DATA_3150F_
  add hl, bc
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ld bc, $9565
  add hl, bc
  ld (_RAM_D92D_), hl
+:
  ld ix, _RAM_D744_
  ld iy, _RAM_D922_
  ld hl, (_RAM_D92D_)
  ld a, (_RAM_D916_MenuSound_)
  call _LABEL_31093_
  call _LABEL_31068_
  ld ix, _RAM_D769_
  ld iy, $D923
  ld a, (_RAM_D917_MenuSound_)
  call _LABEL_31093_
  call _LABEL_31068_
  ld ix, _RAM_D78E_
  ld iy, $D924
  ld a, (_RAM_D918_MenuSound_)
  call _LABEL_31093_
  call _LABEL_31068_
  ld (_RAM_D92D_), hl
_LABEL_30DC7_:
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
  jp _LABEL_30F7D_

+:
  ld a, (ix+0)
  cp $FF
  jp z, _LABEL_30FEA_
  cp $FE
  ret z
  ld a, (ix+9)
  or a
  ret nz
  ld l, (ix+19)
  ld h, (ix+20)
  ld a, (ix+22)
  dec a
  jr nz, _LABEL_30E59_
  ld a, (hl)
  cp $FF
  jr nz, +
  ld a, (ix+2)
  jr ++

+:
  cp $FE
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

+:
  ld a, (ix+2)
  add a, c
++:
  add a, a
  ld c, a
  ld b, $00
  push hl
  ld hl, _DATA_3137A_
  add hl, bc
  ld a, (hl)
  ld (iy+0), a
  inc hl
  ld a, (hl)
  ld (iy+1), a
+++:
  pop hl
  ld a, (ix+21)
_LABEL_30E59_:
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
  cp $FF
  jr nz, +
  ld a, $01
  ld (ix+28), a
  jr ++

+:
  cp $FE
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
  ld hl, _DATA_30EAB_
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
_DATA_30EAB_:
.dw _LABEL_30F25_ _LABEL_30F3E_ _LABEL_30F67_ _LABEL_30F73_ _LABEL_30F5D_ _LABEL_30F53_ _LABEL_30F34_ _LABEL_30F2A_

_LABEL_30EBB_:
  ld (de), a
  ld l, (iy+0)
  ld h, (iy+1)
  ld a, (ix+32)
  cp $FF
  jr z, _LABEL_30F12_
  dec a
  ld (ix+32), a
  jp nz, _LABEL_30F12_
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
_LABEL_30F12_:
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
_LABEL_30F25_:
  ld c, $00
  jp _LABEL_30F3E_

; 8th entry of Jump Table from 30EAB (indexed by unknown)
_LABEL_30F2A_:
  ld a, (_RAM_D910_)
  or a
  jr nz, _LABEL_30F3E_
  ld a, (de)
  jp _LABEL_30EBB_

; 7th entry of Jump Table from 30EAB (indexed by unknown)
_LABEL_30F34_:
  ld a, (_RAM_D90F_)
  or a
  jr nz, _LABEL_30F3E_
  ld a, (de)
  jp _LABEL_30EBB_

; 2nd entry of Jump Table from 30EAB (indexed by unknown)
_LABEL_30F3E_:
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
  jp nc, _LABEL_30EBB_
  ld a, b
  jp _LABEL_30EBB_

; 6th entry of Jump Table from 30EAB (indexed by unknown)
_LABEL_30F53_:
  ld a, (_RAM_D910_)
  or a
  jr z, _LABEL_30F67_
  ld a, (de)
  jp _LABEL_30EBB_

; 5th entry of Jump Table from 30EAB (indexed by unknown)
_LABEL_30F5D_:
  ld a, (_RAM_D90F_)
  or a
  jr z, _LABEL_30F67_
  ld a, (de)
  jp _LABEL_30EBB_

; 3rd entry of Jump Table from 30EAB (indexed by unknown)
_LABEL_30F67_:
  ld a, (de)
  add a, c
  cp $0F
  jp c, _LABEL_30EBB_
  ld a, $0F
  jp _LABEL_30EBB_

; 4th entry of Jump Table from 30EAB (indexed by unknown)
_LABEL_30F73_:
  ld a, $01
  ld (ix+9), a
  ld a, $0F
  jp _LABEL_30EBB_

_LABEL_30F7D_:
  ld ix, _RAM_D91A_MenuSoundData
  ld c, $80
  call _LABEL_30FCA_
  ld c, $90
  ld a, (_RAM_D922_)
  or c
  out (PORT_PSG), a
  inc ix
  inc ix
  ld c, $A0
  call _LABEL_30FCA_
  ld c, $B0
  ld a, (_RAM_D923_)
  or c
  out (PORT_PSG), a
  inc ix
  inc ix
  ld c, $C0
  call _LABEL_30FCA_
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

_LABEL_30FCA_:
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

_LABEL_30FEA_:
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
  ld hl, _DATA_3137A_
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

_LABEL_31068_:
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
  ld hl, _DATA_3141C_
  add hl, bc
  push ix
  ld b, $06
-:
  ld a, (hl)
  ld (ix+11), a
  inc ix
  inc hl
  djnz -
  pop ix
  ld a, $FF
  ld (ix+0), a
  pop hl
  ret

_LABEL_31093_:
  ld (_RAM_D919_), a
  ld a, (_RAM_D914_)
  ld (ix+1), a
  xor a
  ld (ix+36), a
_LABEL_310A0_: ; TODO
  ld a, (hl)
  cp $80
  jp c, _LABEL_310EF_
  inc hl
  sub $80
  and $07
  add a, a
  ld c, a
  ld b, $00
  push hl
  ld hl, _DATA_310BE_
  add hl, bc
  ld e, (hl)
  inc hl
  ld d, (hl)
  pop hl
  push de
  ret

; Data from 310BA to 310BD (4 bytes)
.db $23 $C3 $A0 $90

; Data from 310BE to 310CD (16 bytes)
_DATA_310BE_:
.db $F3 $91 $CE $90 $E8 $91 $B3 $91 $BC $91 $98 $91 $A2 $91 $BA $90

_LABEL_310CE_:
  ld a, (hl)
  and $3F
  inc hl
  jp z, _LABEL_310A0_
  ld c, a
  ld a, (_RAM_D915_)
  or a
  jr nz, +
  ld a, c
+:
  ld c, a
  ld a, (_RAM_DC40_)
  or a
  jr z, +
  inc c
+:
  ld a, c
  ld (_RAM_D92B_MenuSound_), a
  ld (_RAM_D92C_MenuSound_), a
  jp _LABEL_310A0_

_LABEL_310EF_:
  ld a, (hl)
  or a
  jp z, _LABEL_31196_
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
+:
  pop hl
  inc hl
  ret

++:
  ld a, (ix+36)
  or a
  jr nz, +
  ld (ix+35), a
+:
  ld h, $00
  ld a, (ix+0)
  cp $FE
  jr nz, +
  ld (ix+0), h
+:
  ld bc, $937A
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
+:
  ld e, a
  ld a, (_RAM_D914_)
  cp e
  jr nc, +
  ld a, e
+:
  ld (iy+0), a
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
_LABEL_31196_:
  inc hl
  ret

; Data from 31198 to 311BB (36 bytes)
.db $4E $DD $7E $23 $91 $DD $77 $23 $18 $08 $4E $DD $7E $23 $81 $DD
.db $77 $23 $3E $01 $DD $77 $24 $23 $C3 $A0 $90 $3E $01 $32 $2F $D9
.db $23 $C3 $A0 $90

_LABEL_311BC_:
  ld a, (hl)
  ld c, a
  ld b, $00
  push hl
  ld hl, $94BE
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
  jp _LABEL_310A0_

_LABEL_311E8_:
  ld a, (hl)
  cpl
  and $0F
  ld (ix+1), a
  inc hl
  jp _LABEL_310A0_

_LABEL_311F3_:
  push de
  ld a, (hl)
  and $0F
  ld e, a
  add a, a
  ld c, a
  ld b, $00
  push hl
  ld hl, _DATA_31229_
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
+:
  inc bc
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
  jp _LABEL_310A0_

; Pointer Table from 31229 to 3124C (18 entries, indexed by unknown)
_DATA_31229_:
.dw $9249 $9279 $928B $9267 $9273 $9255 $9261 $924F
.dw $9261 $9261 $927F $9261 $925B $926D $924F $924F
.dw $9291 $92F2

; Data from 3124D to 31379 (301 bytes)
.db $FF $FF $E9 $92 $07 $93 $FF $FF $95 $92 $40 $93 $FF $FF $9F $92
.db $5C $93 $02 $1E $00 $FF $F8 $92 $FF $FF $B1 $92 $07 $93 $FF $FF
.db $BD $92 $51 $93 $FF $FF $C4 $92 $51 $93 $FF $FF $D9 $92 $6E $93
.db $04 $06 $E1 $92 $40 $93 $FF $FF $95 $92 $16 $93 $05 $06 $CB $92
.db $16 $93 $05 $06 $00 $01 $00 $FF $01 $01 $00 $02 $00 $04 $00 $02
.db $00 $FF $00 $01 $00 $0C $00 $00 $00 $00 $00 $FF $00 $01 $00 $0C
.db $00 $0C $00 $FF $00 $01 $00 $04 $07 $0C $00 $04 $07 $0C $00 $FF
.db $00 $01 $00 $03 $07 $0C $FE $00 $01 $00 $04 $07 $0C $FE $01 $01
.db $00 $01 $00 $01 $00 $01 $00 $01 $00 $01 $00 $FF $01 $01 $00 $04
.db $01 $03 $02 $FF $00 $01 $00 $18 $00 $18 $00 $FF $00 $01 $00 $0C
.db $18 $00 $0C $18 $FF $0F $00 $03 $00 $00 $FF $06 $02 $01 $01 $06
.db $00 $00 $0F $05 $01 $00 $03 $00 $00 $FF $00 $06 $00 $00 $0F $04
.db $01 $0F $04 $01 $00 $03 $00 $00 $FF $00 $04 $00 $00 $0F $05 $01
.db $0F $05 $01 $00 $03 $00 $00 $FF $0F $0C $01 $02 $0F $05 $01 $0F
.db $05 $01 $00 $03 $00 $00 $FF $00 $08 $00 $00 $0F $04 $02 $00 $03
.db $00 $00 $FF $00 $0A $04 $01 $00 $03 $00 $00 $FF $00 $FE $00 $00
.db $03 $00 $00 $FF $06 $06 $01 $01 $FE $00 $00 $03 $00 $00 $FF $04
.db $02 $01 $01 $18 $00 $00 $07 $05 $01 $10 $00 $00 $00 $03 $00 $00
.db $FF $01 $0F $05 $01 $0F $05 $01 $00 $03 $00 $00 $FF

; Data from 3137A to 3141B (162 bytes)
_DATA_3137A_:
.db $00 $00 $F9 $03 $C0 $03 $8A $03 $57 $03 $27 $03 $FA $02 $CF $02
.db $A7 $02 $81 $02 $5D $02 $3B $02 $1B $02 $FC $01 $E0 $01 $C5 $01
.db $AC $01 $94 $01 $7D $01 $68 $01 $53 $01 $40 $01 $2E $01 $1D $01
.db $0D $01 $FE $00 $F0 $00 $E2 $00 $D6 $00 $CA $00 $BE $00 $B4 $00
.db $AA $00 $A0 $00 $97 $00 $8F $00 $87 $00 $7F $00 $78 $00 $71 $00
.db $6B $00 $65 $00 $5F $00 $5A $00 $55 $00 $50 $00 $4C $00 $47 $00
.db $43 $00 $40 $00 $3C $00 $39 $00 $35 $00 $32 $00 $30 $00 $2D $00
.db $2A $00 $28 $00 $26 $00 $24 $00 $22 $00 $20 $00 $1E $00 $1C $00
.db $1B $00 $19 $00 $18 $00 $16 $00 $15 $00 $14 $00 $13 $00 $12 $00
.db $11 $00 $10 $00 $0F $00

_DATA_31410_:
.db $F6 $FB $FE $FA $FA $FC $FC $FB $FD $FD $FC $FE

; Data from 3141C to 3150E (243 bytes)
_DATA_3141C_:
.db $7C $94 $83 $94 $89 $94 $7C $94 $83 $94 $89 $94 $7C $94 $83 $94
.db $89 $94 $7C $94 $83 $94 $89 $94 $7C $94 $83 $94 $89 $94 $A2 $94
.db $83 $94 $89 $94 $7C $94 $83 $94 $89 $94 $7C $94 $83 $94 $89 $94
.db $A2 $94 $A7 $94 $AB $94 $7C $94 $83 $94 $89 $94 $8F $94 $96 $94
.db $9C $94 $7C $94 $83 $94 $89 $94 $7C $94 $83 $94 $89 $94 $7C $94
.db $83 $94 $89 $94 $7C $94 $83 $94 $89 $94 $7C $94 $83 $94 $89 $94
.db $0A $09 $08 $07 $06 $05 $FF $08 $08 $08 $08 $08 $08 $00 $00 $00
.db $00 $00 $0F $16 $14 $12 $10 $0E $0C $FF $06 $05 $04 $07 $07 $07
.db $00 $00 $00 $00 $00 $0F $00 $00 $00 $00 $FF $04 $03 $07 $07 $00 $02 $04 $0F

_DATA_314AF_MenuMusicStopData: ; 15 bytes, menu sound engine init?
.db $00 $00 $00 $00 $00 $00 $07 $0F $0F $0F $0F $00 $00 $00 $00 
_DATA_314AF_MenuMusicStopData_End:

.db $00 $05 $02 $03 $02 $04 $06 $07 $02 $03 $02 $04 $09 $08
.db $0B $0B $0A $0A $0C $0D $0C $0E $00 $00 $0F $10 $11 $11 $12 $13
.db $11 $11 $14 $15 $16 $18 $17 $19 $1A $1B $1B $1C $1D $1F $20 $21
.db $10 $22 $22 $23 $24 $25 $26 $27 $28 $29 $2A
_DATA_314F7_:
.dw $94BE $94D6 $94E3 $94E9 $94EA $94EB $94EC $94F1 $94F2 $94F3 $94F4 $94F5

; Data from 3150F to 33FFF (10993 bytes)
_DATA_3150F_:
.incbin "Assets/raw/Micro Machines_3150f.inc"

.BANK 13
.ORG $0000

; Data from 34000 to 35707 (5896 bytes)
_DATA_34000_FormulaOne_Tiles:
.incbin "Assets/Formula One/Tiles.compressed" ; 3bpp bitplane separated
_DATA_34958_CarTiles_Sportscars:
.incbin "Assets/Sportscars/Car.3bpp.runencoded"
.dsb 6, 0
_DATA_34CF0_CarTiles_FourByFour:
.incbin "Assets/Four By Four/Car.3bpp.runencoded"
.dsb 1, 0
_DATA_35048_CarTiles_Powerboats:
.incbin "Assets/Powerboats/Car.3bpp.runencoded"
.dsb 7, 0
_DATA_35350_CarTiles_TurboWheels:
.incbin "Assets/Turbo Wheels/Car.3bpp.runencoded"
.dsb 1, 0

; Data from 35708 to 3576F (104 bytes)
_DATA_35708_PlugholeTilesPart1:
.db $00 $00 $00 $00 $03 $0F $3F $FF $00 $00 $00 $3F $FF $FF $FF $FF
.db $01 $03 $07 $0F $1F $3F $3F $7F $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $7F $BF $BF $B7 $27 $46 $48 $48
.db $FF $FF $FF $FF $FF $DF $9F $AF $FF $FF $FF $FF $FF $FF $FF $FF
.db $AF $2F $2F $0F $0F $0F $0F $0F $FF $FF $FF $FF $FF $FF $FF $FF
.db $0F $07 $07 $07 $03 $03 $01 $00 $FF $FF $FF $FF $FF $FF $FF $FF
.db $7F $3F $0F $03 $01 $00 $00 $00

; Data from 35770 to 357F7 (136 bytes)
_DATA_35770_PlugholeTilesPart2:
.db $00 $00 $00 $F0 $FC $FF $FF $FF $00 $00 $00 $00 $00 $80 $F0 $FC
.db $FF $FF $FF $FF $FF $FF $FF $FF $FE $FF $FF $FF $FF $FF $FF $FF
.db $00 $00 $80 $C0 $E0 $F0 $F0 $F8 $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $F8 $FC $FE $FE $FE $FE $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF $FF $FF $FF $FF $FE $FE $FE $FC $FC $F8 $F8 $F0
.db $FF $FF $FF $FF $FF $7F $00 $00 $FF $FF $FF $FE $F8 $C0 $00 $00
.db $E0 $C0 $80 $00 $00 $00 $00 $00

_LABEL_357F8_CarTilesToVRAM:
  ld a, (_RAM_DB97_TrackType)
  cp TT_RuffTrux
  jr nz, +
  ; RuffTrux
  ; VRAM address 0, 256 tiles
  ld a, $00
  out (PORT_VDP_ADDRESS), a
  ld a, $40
  out (PORT_VDP_ADDRESS), a
  ld bc, $0800 ; loop count - we consume 3x this much data to produce 256 tiles
  ld hl, _RAM_C000_DecompressionTemporaryBuffer
-:
  push bc
    ld b, $03
    ld c, PORT_VDP_DATA
    otir          ; 3 bytes data
    ld a, $00
    out (PORT_VDP_DATA), a  ; 1 byte padding
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
  ld hl, _DATA_35868_CarTileLoaderCounterToTableLookup   ; Look up in a table
  add hl, de
  ld a, (hl)
  ld (_RAM_DB74_CarTileLoaderTableIndex), a    ; and store
  sla a
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_35B4D_CarDrawingData   ; and index into another table
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
  call z, _LABEL_35A3E_CarTileLoader_HFlipSwapData ; When we get to 13, we are in the realm of both h- and v-flipped tiles. The code doesn't support this properly so we munge the data here (!) so it works right.
  ld a, (_RAM_DF98_CarTileLoaderCounter)
  cp 16
  jr nz, -              ; Repeat for all 16 car rotations
  ret

; Data from 35868 to 35877 (16 bytes)
_DATA_35868_CarTileLoaderCounterToTableLookup:
.db $00 $01 $02 $03 $04 $05 $06 $07 $08 $0C $0D $0E $0F $09 $0A $0B

_LoadOnePosition:
  ld a, (_RAM_DB79_CarTileLoaderHFlip)
  cp $01
  jr z, _hflip
  ld a, (_RAM_DB7A_CarTileLoaderVFlip)
  cp $01
  jr z, _LABEL_358D9_vflip
  jp _LABEL_3591C_noflip

_hflip:
  ; hflip flag is 1
  call +
  ld a, (_RAM_DB7A_CarTileLoaderVFlip)
  cp $01
  jr z, _LABEL_358D9_vflip ; If it's H- and V-flipped, we wasted time loading it h-flipped because now we re-load it v-flipped
  ret

+:; load data, hflipped
  ld a, (_RAM_DB75_CarTileLoaderDataIndex) ; Index into table of pointers, read into bc
  sla a
  ld hl, _DATA_35AE3_CarTileRAMLocations
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
  ld de, _DATA_35AED_CarTileAddresses
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
    call _LABEL_359C0_emitThreeTilesHFlipped
  pop hl
  ld de, $0300
  add hl, de
  push hl
    call _LABEL_359C0_emitThreeTilesHFlipped
  pop hl
  ld de, $0300
  add hl, de
  call _LABEL_359C0_emitThreeTilesHFlipped
  ret

_LABEL_358D9_vflip:
  ld a, (_RAM_DB75_CarTileLoaderDataIndex) ; Index into table of pointers, read into bc
  sla a
  ld hl, _DATA_35AE3_CarTileRAMLocations
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
  ld de, _DATA_35AED_CarTileAddresses
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e

  ; Use the tile address as-is
  push hl
    call _LABEL_3598D_emitThreeTilesVFlipped
  pop hl
  ld de, $0300 ; 18 tiles?
  or a
  sbc hl, de
  push hl
    call _LABEL_3598D_emitThreeTilesVFlipped
  pop hl
  ld de, $0300
  or a
  sbc hl, de
    call _LABEL_3598D_emitThreeTilesVFlipped
  ret

_LABEL_3591C_noflip:
  ld a, (_RAM_DB75_CarTileLoaderDataIndex) ; Index into table of pointers, read into bc
  sla a
  ld hl, _DATA_35AE3_CarTileRAMLocations
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
  ld de, _DATA_35AED_CarTileAddresses
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
  call _LABEL_35977_Emit3bppTileData
  ld de, $0300  ; move on by 18 tiles
  add hl, de
  ld a, l       ; and repeat
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld de, $0018
  call _LABEL_35977_Emit3bppTileData
  ld de, $0300 ; and again
  add hl, de
  ld a, l
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ld de, $0018
  jp _LABEL_35977_Emit3bppTileData ; and return

_LABEL_35977_Emit3bppTileData:
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
  ld a, $00
  out (PORT_VDP_DATA), a
  dec de
  ld a, d
  or e
  jr nz, -
  ret

_LABEL_3598D_emitThreeTilesVFlipped:
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
  ld a, $00   ; Last bitplane is 0
  out (PORT_VDP_DATA), a
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

_LABEL_359C0_emitThreeTilesHFlipped:
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
    ld a, $00 ; last bitplane is 0
    out (PORT_VDP_DATA), a
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

_LABEL_35A1B_hlipByte_usingBC:
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

_LABEL_35A3E_CarTileLoader_HFlipSwapData:
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
  ld hl, _DATA_35ABF_ ; Read into de, hl
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
    call _LABEL_35A1B_hlipByte_usingBC
    ld (_RAM_DB78_CarTileLoaderTempByte), a
    ld a, (de)
    call _LABEL_35A1B_hlipByte_usingBC
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
  ld hl, _DATA_35ABF_ ; read into hl only
  add hl, de
  ld a, (hl)
  ld e, a
  inc hl
  ld a, (hl)
  ld h, a
  ld l, e
  ld de, $0018  ; add one tile?
  add hl, de
  ld bc, $0018  ; FOr one tile...
-:
  push bc
    ld a, (hl)
    call _LABEL_35A1B_hlipByte_usingBC ; hflip it back again???
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

; Data from 35ABF to 35AC0 (2 bytes)
_DATA_35ABF_:
.dw $C0F0 $C120 ; Address pairs for data munging
.dw $C138 $C168
.dw $C180 $C1B0
.dw $C1E0 $C210
.dw $C228 $C258
.dw $C270 $C2A0
.dw $C2D0 $C300
.dw $C318 $C348
.dw $C360 $C390

; Data from 35AE3 to 35B4C (106 bytes)
_DATA_35AE3_CarTileRAMLocations:
.dw $C000 $C0F0 $C1E0 $C2D0 $C3C0 ; VRAM offsets of the five car positions - N, NNW, NW, WNW, W
_DATA_35AED_CarTileAddresses:
.dw $661C $631C $601C ; Tile addresses to write at for various flipping modes, only first is used?
.dw $667C $637C $607C
.dw $66DC $63DC $60DC
.dw $673C $643C $613C
.dw $679C $649C $619C
.dw $67FC $64FC $61FC
.dw $685C $655C $625C
.dw $68BC $65BC $62BC
.dw $6F1C $6C1C $691C
.dw $6F7C $6C7C $697C
.dw $6FDC $6CDC $69DC
.dw $703C $6D3C $6A3C
.dw $709C $6D9C $6A9C
.dw $70FC $6DFC $6AFC
.dw $715C $6E5C $6B5C
.dw $71BC $6EBC $6BBC

; Data from 35B4D to 35B8C (64 bytes)
_DATA_35B4D_CarDrawingData:
; Rotation generation data
;    ,,- index of underlying data (car position unflipped)
;    ||  ,,- index of rotation
;    ||  ||  ,,- horizontal flip
;    ||  ||  ||  ,,- vertical flip
.db $00 $00 $00 $00
.db $01 $01 $00 $00
.db $02 $02 $00 $00
.db $03 $03 $00 $00
.db $04 $04 $00 $00
.db $03 $05 $00 $01
.db $02 $06 $00 $01
.db $01 $07 $00 $01
.db $00 $08 $00 $01
.db $01 $09 $01 $01
.db $02 $0A $01 $01
.db $03 $0B $01 $01
.db $04 $0C $01 $00
.db $03 $0D $01 $00
.db $02 $0E $01 $00
.db $01 $0F $01 $00

; Data from 35B8D to 35BEC (96 bytes)
_DATA_35B8D_:
; Gradual ramp from 0 to $1f
.db $00 $00 $00 $01 $01 $01 $02 $02 $02 $03 $03 $03 $04 $04 $04 $05
.db $05 $05 $06 $06 $06 $07 $07 $07 $08 $08 $08 $09 $09 $09 $0A $0A
.db $0A $0B $0B $0B $0C $0C $0C $0D $0D $0D $0E $0E $0E $0F $0F $0F
.db $10 $10 $10 $11 $11 $11 $12 $12 $12 $13 $13 $13 $14 $14 $14 $15
.db $15 $15 $16 $16 $16 $17 $17 $17 $18 $18 $18 $19 $19 $19 $1A $1A
.db $1A $1B $1B $1B $1C $1C $1C $1D $1D $1D $1E $1E $1E $1F $1F $1F

; Data from 35BED to 35C2C (64 bytes)
_DATA_35BED_96TimesTable:
  TimesTable16 0 96 32

; Data from 35C2D to 35D2C (256 bytes)
_DATA_35C2D_:
.db $00 $01 $02 $03 $20 $21 $22 $23 $40 $41 $42 $43 $60 $61 $62 $63
.db $04 $05 $06 $07 $24 $25 $26 $27 $44 $45 $46 $47 $64 $65 $66 $67
.db $08 $09 $0A $08 $28 $29 $2A $2B $48 $49 $4A $4B $08 $69 $6A $08
.db $0C $0D $0E $0F $2C $2D $2E $2F $4C $4D $4E $4F $6C $6D $6E $6F
.db $10 $11 $12 $13 $30 $31 $32 $33 $50 $51 $52 $53 $70 $71 $72 $73
.db $14 $15 $16 $17 $34 $35 $36 $37 $54 $55 $56 $57 $74 $75 $76 $77
.db $08 $19 $1A $08 $38 $39 $3A $3B $58 $59 $5A $5B $08 $79 $7A $08
.db $1C $1D $1E $1F $3C $3D $3E $3F $5C $5D $5E $5F $7C $7D $7E $7F
.db $80 $81 $82 $83 $A0 $A1 $A2 $A3 $C0 $C1 $C2 $C3 $E0 $E1 $E2 $E3
.db $84 $85 $86 $87 $A4 $A5 $A6 $A7 $C4 $C5 $C6 $C7 $E4 $E5 $E6 $E7
.db $08 $89 $8A $08 $A8 $A9 $AA $AB $C8 $C9 $CA $CB $08 $E9 $EA $08
.db $8C $8D $8E $8F $AC $AD $AE $AF $CC $CD $CE $CF $EC $ED $EE $EF
.db $90 $91 $92 $93 $B0 $B1 $B2 $B3 $D0 $D1 $D2 $D3 $F0 $F1 $F2 $F3
.db $94 $95 $96 $97 $B4 $B5 $B6 $B7 $D4 $D5 $D6 $D7 $F4 $F5 $F6 $F7
.db $08 $99 $9A $08 $B8 $B9 $BA $BB $D8 $D9 $DA $DB $08 $F9 $FA $08
.db $9C $9D $9E $9F $BC $BD $BE $BF $DC $DD $DE $DF $FC $FD $FE $FF

; Data from 35D2D to 35F0C (480 bytes)
_DATA_35D2D_HeadToHeadHUDTiles:
; 3bpp tile data (24 bytes per tile)
; - Red dot
; - Blue dot
; - "WINNER" (6 tiles)
; - "BONUS" (first 4 tiles)
; - Exhaust smoke? TODO supposed to be showing this I guess, on the sprites following cars - broken?
; - "BONUS" (last 2 tiles)
; - Digit for laps remaining (unused - replaced with tile from challenge mode data)
; - Blank tile
.incbin "Assets/Head to Head HUD.3bpp"

_LABEL_35F0D_:
  ld a, $00
  ld (_RAM_DB7C_), a
  ld a, (_RAM_DB7B_)
  ld c, a
  ld hl, _RAM_DF38_
-:
  ld a, (_RAM_DB7C_)
  cp c
  jr z, _LABEL_35F30_
  ld a, $94
  ld (hl), a
  inc hl
  ld a, (_RAM_DB7C_)
  add a, $01
  ld (_RAM_DB7C_), a
  cp $08
  jr nz, -
  ret

_LABEL_35F30_:
  ld a, $95
  ld (hl), a
  inc hl
  ld a, (_RAM_DB7C_)
  add a, $01
  ld (_RAM_DB7C_), a
  cp $08
  jr nz, _LABEL_35F30_
  ret

_LABEL_35F41_:
  ld a, $A6
  ld (_RAM_DF37_), a
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld hl, _RAM_DF2E_
  ld ix, _RAM_DF40_
  ld e, $30
  ld bc, $0009
-:
  ld a, $38
  ld (hl), a
  ld a, e
  ld (ix+0), a
  add a, $08
  ld e, a
  inc hl
  inc ix
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

+:
  ld hl, _RAM_DF2E_
  ld ix, _RAM_DF40_
  ld e, $08
  ld bc, $0009
-:
  ld a, $10
  ld (hl), a
  ld a, e
  ld (ix+0), a
  add a, $08
  ld e, a
  inc hl
  inc ix
  dec bc
  ld a, b
  or c
  jr nz, -
  ret

_LABEL_35F8A_:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr nz, _LABEL_35FEB_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_35FEB_
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr nz, _LABEL_35FEB_
  ld a, (_RAM_DE4F_)
  cp $80
  jr nz, _LABEL_35FEB_
  ld a, (_RAM_DD1A_)
  or a
  jr nz, _LABEL_35FEB_
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
  jr nz, _LABEL_35FEB_
  ld hl, _RAM_DEA2_
  ld a, (hl)
  or a
  jr z, _LABEL_35FEB_
  dec (hl)
_LABEL_35FEB_:
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
  jp _LABEL_3608C_

_LABEL_3603C_:
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
  jp _LABEL_3608C_

_LABEL_3608C_:
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
  jp ++

; Data from 360B1 to 360B1 (1 bytes)
.db $C9

+:
  ld a, $00
  ld (_RAM_DE9D_), a
++:
  ret

-:
  ret

_LABEL_360B9_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr nz, -
  ld a, (_RAM_D5C5_)
  cp $01
  jr z, -
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, -
  call _LABEL_36152_
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

; Data from 3610E to 3610E (1 bytes)
.db $C9

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

_LABEL_36152_:
  ld a, (_RAM_DB7E_)
  ld (_RAM_DF0B_), a
  ld a, (_RAM_DB7F_)
  ld (_RAM_DF0C_), a
  ld a, (_RAM_DD0C_)
  ld (_RAM_DF0E_), a
  ld a, (_RAM_DD0D_)
  ld (_RAM_DF0D_), a
  ret

_LABEL_3616B_:
  call _LABEL_361F0_
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

; Data from 361AC to 361AC (1 bytes)
.db $C9

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

_LABEL_361F0_:
  ld a, (_RAM_DF7D_)
  ld (_RAM_DF0B_), a
  ld a, (_RAM_DF7E_)
  ld (_RAM_DF0C_), a
  ld a, (_RAM_DB84_)
  ld (_RAM_DF0E_), a
  ld a, (_RAM_DB85_)
  ld (_RAM_DF0D_), a
  ret

_LABEL_36209_:
  ld a, (_RAM_D5B7_)
  or a
  jr z, +
  dec a
  ld (_RAM_D5B7_), a
+:
  ld a, (_RAM_DC3F_GameMode)
  or a
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr nz, +
  ld a, (_RAM_DCF7_)
  or a
  jr z, ++
  ld a, (_RAM_DE9B_)
  or a
  jr z, +
  cp $01
  jr z, +++
  jp _LABEL_36287_

+:
  ret

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
  jr nz, +
  ld a, (_RAM_D5B7_)
  or a
  jr nz, _LABEL_3625F_
  ld a, (_RAM_DEA2_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA2_), a
+:
  ret

_LABEL_3625F_:
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
  call _LABEL_362C7_
++:
  ld (_RAM_DEA2_), a
  ld hl, _RAM_DCF8_
  dec (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCF8_), a
  jp _LABEL_3608C_

_LABEL_36287_:
  ld a, (_RAM_DD00_)
  or a
  jr nz, +
  ld a, (_RAM_D5B7_)
  or a
  jr nz, _LABEL_3625F_
  ld a, (_RAM_DEA2_)
  cp $00
  jr z, ++
  sub $01
  ld (_RAM_DEA2_), a
+:
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
  call _LABEL_362C7_
++:
  ld (_RAM_DEA2_), a
  ld hl, _RAM_DCF8_
  inc (hl)
  ld a, (hl)
  and $0F
  ld (_RAM_DCF8_), a
  jp _LABEL_3608C_

_LABEL_362C7_:
  ld hl, _RAM_DB86_HandlingData
  ld de, (_RAM_DCF7_)
  ld d, $00
  add hl, de
  ld a, (hl)
  ret

_LABEL_362D3_:
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jr z, ++
  or a ; TT_SportsCars
  jr z, _LABEL_36338_
  cp TT_TurboWheels
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
  jp _LABEL_36343_

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
  jr c, +
  cp c
  jr nc, +
  ld a, $03
  ld (_RAM_DD38_), a
+:
  ret

_LABEL_36338_:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  or a
  jr z, +
  ret

+:
  ld b, $0A
  ld c, $0D
_LABEL_36343_:
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
  jr c, +
  cp c
  jr nc, +
  ld a, $0C
  ld (_RAM_DD38_), a
+:
  ret

_LABEL_3636E_:
  ld a, (_RAM_DF6B_)
  add a, $01
  and $01
  ld (_RAM_DF6B_), a
  jr z, +
  ret

+:
  ld a, (_RAM_DF59_CarState)
  cp $04
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

_LABEL_3639C_:
  ld a, (_RAM_D5BC_)
  cp $04
  jr c, _LABEL_363CB_
  ld a, (_RAM_DD00_)
  or a
  jr nz, _LABEL_363CB_
  ld a, (_RAM_DCF7_)
  cp $06
  jr c, _LABEL_363CB_
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
  jr z, _LABEL_363CB_
--:
  xor a
  ld (_RAM_D5BC_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_TurboWheels
  jr z, +
  cp TT_Warriors
  jr z, +
  ld a, $0F
-:
  ld (_RAM_D974_SFXTrigger), a
_LABEL_363CB_:
  ret

+:
  ld a, $10
  jr -

_LABEL_363D0_:
  ld a, (_RAM_D5BC_)
  cp $04
  jr c, _LABEL_363CB_
  jr --

_LABEL_363D9_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  cp $01
  jr nz, _LABEL_36454_
  ld a, (_RAM_DD00_)
  or a
  jr z, +
  ld a, (_RAM_DD12_)
  cp $02
  jr z, _LABEL_36454_
+:
  ld a, (_RAM_DEA4_)
  or a
  jr z, ++
  cp $01
  jr z, +
  call _LABEL_3639C_
+:
  ld a, (_RAM_DE9B_)
  cp $00
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
  cp $00
  jr z, _LABEL_3645B_
  ld a, (_RAM_DB21_Player2Controls)
  ld l, a
  and BUTTON_L_MASK ; $04
  jr z, +
  ld a, l
  and BUTTON_R_MASK ; $08
  jr nz, _LABEL_36454_
+:
  ld a, $01
  ld (_RAM_DEAA_), a
  ld hl, _RAM_DEA8_
  inc (hl)
  ld a, (hl)
  cp $44
  jr nz, _LABEL_3643D_
  ld a, $43
  ld (_RAM_DEA8_), a
_LABEL_3643D_:
  ld hl, _DATA_EA2_
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
_LABEL_36454_:
  ret

+:
  ld a, $00
  ld (_RAM_DE57_), a
  ret

_LABEL_3645B_:
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
  jp _LABEL_3643D_

+:
  ld a, $00
  ld (_RAM_DEA8_), a
  ld (_RAM_DEAA_), a
  ld a, (_RAM_DCF7_)
  ld (_RAM_DE57_), a
  ret

_LABEL_36484_PatchForLevel:
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
  cp TT_Powerboats
  jp z, _LABEL_3666D_Powerboats
  cp TT_SportsCars
  jp z, _LABEL_366CB_SportsCars
  cp TT_Tanks
  jp z, _LABEL_3665F_Tanks
  cp TT_FormulaOne
  jr z, ++
  cp TT_TurboWheels
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

_LABEL_3665F_Tanks:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $01
  jr z, +
  ret

+:; Tanks 1
  PatchLayout 8, 5, $19
  ret

_LABEL_3666D_Powerboats:
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

_LABEL_366CB_SportsCars:
  ld a, (_RAM_DB96_TrackIndexForThisType)
  cp $02
  jr z, +
  ret

+:; Track 2 - Crayon Canyons - layout error at bottom right corner of track
  PatchLayout 0, 0, $34
  PatchLayout 0, 31, $32
  ret

_LABEL_366DE_:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $01
  jp z, _LABEL_36798_
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
  jr nc, _LABEL_36752_
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
  jr nz, _LABEL_36736_
  ld a, (_RAM_DCF9_)
  add a, $01
  and $0F
  ld (_RAM_DCF9_), a
  ld (_RAM_DCF8_), a
_LABEL_36736_:
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

_LABEL_36752_:
  call _LABEL_B63_
  ld a, (_RAM_D581_)
  cp $A0
  jr c, _LABEL_36736_
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
  ld (_RAM_DF2B_), a
  ld a, $01
  ld (_RAM_DF2A_), a
++:
  ld a, (_RAM_DF7F_)
  cp $05
  jr z, +
  ld a, $05
  ld (_RAM_DF7F_), a
  ld a, $01
  ld (_RAM_DD1A_), a
  ld (_RAM_DF5B_), a
  jp _LABEL_71B5_

+:
  xor a
  ld (_RAM_DF74_RuffTruxSubmergedCounter), a
  ld (_RAM_DF73_), a
  ret

_LABEL_36798_:
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
  jr nc, _LABEL_367FF_
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
  jr nz, _LABEL_367E3_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  add a, $01
  and $0F
  ld (_RAM_DE91_CarDirectionPrevious), a
  ld (_RAM_DE90_CarDirection), a
_LABEL_367E3_:
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

_LABEL_367FF_:
  call _LABEL_B63_
  ld a, (_RAM_D581_)
  cp $A0
  jr c, _LABEL_367E3_
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
  ld (_RAM_DF2A_), a
  ld a, $01
  ld (_RAM_DF2B_), a
++:
  ld a, $05
  ld (_RAM_DF7F_), a
  jp _LABEL_2934_BehaviourF

_LABEL_3682E_:
  ld a, (_RAM_DE55_)
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
  ld hl, (_RAM_DCEC_)
  ld b, $00
  or a
  sbc hl, bc
  ld (_RAM_DCEC_), hl
  jp ++

+:
  ld hl, (_RAM_DCEC_)
  ld c, b
  ld b, $00
  add hl, bc
  ld (_RAM_DCEC_), hl
++:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld de, $0028
  ld hl, (_RAM_DCEC_)
  or a
  sbc hl, de
  ld (_RAM_DCEC_), hl
+:
  ld a, (_RAM_DE55_)
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
  and $80
  jr z, +
  ld a, c
  and $7F
  ld c, a
  ld a, (_RAM_DBA5_)
  sub c
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  jp ++

+:
  ld a, (_RAM_DBA5_)
  add a, c
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
  jr z, +
  ld de, $0028
  ld hl, (_RAM_DCEE_)
  or a
  sbc hl, de
  ld (_RAM_DCEE_), hl
+:
  ret

; Data from 368F7 to 36916 (32 bytes)
_DATA_368F7_:
.db $0C $8C $0C $8C $09 $89 $86 $06 $00 $00 $86 $06 $09 $89 $8C $0C
.db $0C $8C $8C $0C $89 $09 $06 $86 $00 $00 $06 $86 $89 $09 $0C $8C

; Data from 36917 to 36936 (32 bytes)
_DATA_36917_:
.db $00 $00 $06 $86 $09 $89 $8C $0C $0C $8C $0C $8C $89 $09 $06 $86
.db $00 $00 $86 $06 $89 $09 $0C $8C $0C $8C $8C $0C $09 $89 $86 $06

_LABEL_36937_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +++
  ld a, (_RAM_DB97_TrackType)
  cp TT_FormulaOne
  jr nz, +++
  ld a, (_RAM_D5C5_)
  or a
  jr nz, +++
  ld a, (_RAM_DE8C_)
  or a
  jr z, +
  ld a, (_RAM_DD1F_)
  or a
  jr nz, +++
  jp ++

+:
  ld a, (_RAM_DD1F_)
  or a
  jr z, +++
++:
  ld hl, (_RAM_DF56_)
  xor a
  cp l
  jr nz, +
  cp h
  jr nz, +
  jp _LABEL_369EE_

+:
  dec hl
  ld (_RAM_DF56_), hl
+++:
  ret

_LABEL_36971_:
  ld a, (_RAM_DE4F_)
  cp $80
  jp nz, _LABEL_369ED_
  ld a, (_RAM_D5C5_)
  or a
  jp nz, _LABEL_369ED_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  cp $00
  jp nz, _LABEL_369ED_
  ld a, (_RAM_DF7F_)
  cp $00
  jp nz, _LABEL_369ED_
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, +
  ld a, (_RAM_DBA4_)
  cp $CA
  jr nc, _LABEL_369EE_
  cp $28
  jr c, _LABEL_369EE_
  ld a, (_RAM_DBA5_)
  cp $AA
  jr nc, _LABEL_369EE_
  cp $12
  jr c, _LABEL_369EE_
  ld a, (_RAM_DCFD_)
  cp $CA
  jr nc, _LABEL_369EE_
  cp $28
  jr c, _LABEL_369EE_
  ld a, (_RAM_DCFE_)
  cp $12
  jr c, _LABEL_369EE_
  cp $AA
  jp c, _LABEL_369ED_
  jp _LABEL_369EE_

+:
  ld a, (_RAM_DBA4_)
  cp $EA
  jr nc, _LABEL_369EE_
  cp $08
  jr c, _LABEL_369EE_
  ld a, (_RAM_DBA5_)
  cp $C6
  jr nc, _LABEL_369EE_
  ld a, (_RAM_DCFD_)
  cp $EA
  jr nc, _LABEL_369EE_
  cp $08
  jr c, _LABEL_369EE_
  ld a, (_RAM_DCFE_)
  cp $C6
  jr c, _LABEL_369ED_
  jp _LABEL_369EE_

_LABEL_369ED_:
  ret

_LABEL_369EE_:
  xor a
  ld (_RAM_DEB5_), a
  ld (_RAM_DF0F_), a
  ld (_RAM_DE2F_), a
  ld (_RAM_DE35_), a
  ld a, (_RAM_D945_)
  or a
  jr nz, _LABEL_36A4F_
  ld a, (_RAM_D940_)
  or a
  jr nz, _LABEL_36A56_
  ld a, (_RAM_DE8C_)
  or a
  jr nz, _LABEL_36A6D_
  ld a, (_RAM_DD1F_)
  or a
  jr nz, _LABEL_36A5D_
  ld a, (_RAM_DF8E_)
  ld l, a
  ld a, (_RAM_DF92_)
  cp l
  jr z, +
  jr nc, _LABEL_36A3F_
  jp _LABEL_36A2C_

+:
  ld a, (_RAM_DF8D_)
  ld l, a
  ld a, (_RAM_DF91_)
  cp l
  jr nc, _LABEL_36A3F_
_LABEL_36A2C_:
  ld a, (_RAM_DF58_)
  cp $00
  jr nz, +
--:
  ld a, $01
  ld (_RAM_DF5B_), a
  ld ix, _RAM_DCEC_
  jp _LABEL_4E49_

_LABEL_36A3F_:
  ld a, (_RAM_DD1A_)
  cp $00
  jr nz, +
-:
  ld a, $01
  ld (_RAM_DF59_CarState), a
  jp _LABEL_2A08_

+:
  ret

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
  ld (_RAM_DD1A_), a
  ld a, (_RAM_DF55_)
  ld (_RAM_DD28_), a
  call +
  jp _LABEL_36A3F_

_LABEL_36A6D_:
  xor a
  ld (_RAM_DF58_), a
  ld a, (_RAM_DD28_)
  ld (_RAM_DF55_), a
  call +
  jp _LABEL_36A2C_

+:
  xor a
  ld (_RAM_DE8C_), a
  ld (_RAM_DD1F_), a
  ret

_LABEL_36A85_:
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

_LABEL_36B29_:
  ld a, (_RAM_D5B0_)
  or a
  jp nz, _LABEL_36B36_
  ld a, (_RAM_D940_)
  or a
  jr z, +
_LABEL_36B36_:
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
  jr nz, _LABEL_36BBF_
  ld a, l
  cp $90
  jr c, +
_LABEL_36BBF_:
  ld a, $00
  ld (_RAM_D945_), a
  jp _LABEL_2A55_

+:
  ld hl, (_RAM_DCEC_)
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
  jr nz, _LABEL_36BBF_
  ld a, l
  cp $D2
  jr nc, _LABEL_36BBF_
  ret

_LABEL_36BE6_:
  ld a, (_RAM_D5B0_)
  or a
  jp nz, _LABEL_36B36_
  ld a, (_RAM_D945_)
  or a
  jr z, +
  jp _LABEL_36B36_

+:
  ld a, $02
  ld (_RAM_D940_), a
  ld de, (_RAM_D941_)
  ld hl, (_RAM_DCEC_)
  or a
  sbc hl, de
  jr nc, +
  ld a, $00
  ld (_RAM_DD0D_), a
  ld hl, (_RAM_D941_)
  ld de, (_RAM_DCEC_)
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
  jr nz, _LABEL_36C72_
  ld a, l
  cp $C6
  jr c, +
_LABEL_36C72_:
  ld a, $00
  ld (_RAM_D940_), a
  ld a, $00
  ld (_RAM_DF5B_), a
  jp _LABEL_4EAB_

+:
  ld hl, (_RAM_DBA9_)
  ld a, (_RAM_DBA4_)
  ld e, a
  ld d, $00
  add hl, de
  ld b, h
  ld c, l
  ld de, (_RAM_DCEC_)
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

_LABEL_36CA5_:
  ld a, (_RAM_DF59_CarState)
  or a
  jr nz, _LABEL_36D06_
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
  jr nz, _LABEL_36D06_
  ld a, (_RAM_DEB1_VScrollDelta)
  cp $00
  jr nz, _LABEL_36D06_
  ld a, $00
  ld (_RAM_D945_), a
  ld a, $02
  ld (_RAM_DF59_CarState), a
  ld a, $16
  ld (_RAM_D963_SFXTrigger2), a
_LABEL_36D06_:
  ret

_LABEL_36D07_:
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
  jr nz, +
  ld a, (_RAM_DCFC_)
  cp $00
  jr nz, +
  ld a, $00
  ld (_RAM_D940_), a
  ld a, $02
  ld (_RAM_DF5B_), a
+:
  ret

_LABEL_36D52_RuffTrux_UpdateTimer:
  call _LABEL_36DFF_RuffTrux_DecrementTimer
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
_DATA_36DAF_TimerDigitTilesData: ; 1bpp data. This is written into the right bitplane, but the upper bitplanes select whether 0 means transparent or black.
;.db $00 $00 $1C $36 $36 $36 $1C $00 ; 0
.db %00000000
.db %00000000
.db %00011100
.db %00110110
.db %00110110
.db %00110110
.db %00011100
.db %00000000
.db $00 $00 $0C $1C $0C $0C $1E $00 ; 1 ...
.db $00 $00 $1C $36 $0C $18 $3E $00
.db $00 $00 $3C $06 $1C $06 $3C $00
.db $00 $00 $36 $36 $1E $06 $06 $00
.db $00 $00 $3E $30 $3C $06 $3C $00
.db $00 $00 $1C $30 $3C $36 $1C $00
.db $00 $00 $3E $06 $0C $18 $18 $00
.db $00 $00 $1C $36 $1C $36 $1C $00
.db $00 $00 $1C $36 $1E $06 $3C $00

_LABEL_36DFF_RuffTrux_DecrementTimer:
  ld a, (_RAM_D599_IsPaused)
  or a
  jr nz, _LABEL_36E6A_ret
  ld a, (_RAM_DF65_)
  cp $01
  jr z, _LABEL_36E6A_ret
  ld a, (_RAM_DE4F_)
  cp $80
  jr nz, _LABEL_36E6A_ret

  ; Increment frame counter
  ld a, (_RAM_DF72_RuffTruxTimer_Frames)
  add a, $01
  ld (_RAM_DF72_RuffTruxTimer_Frames), a
  cp $0A ; BUG: should be 5 or 6 for 50 or 60Hz!
  jr nz, _LABEL_36E6A_ret

  ; Reached target, decrement tenths
  ld a, $00
  ld (_RAM_DF72_RuffTruxTimer_Frames), a
  ld a, (_RAM_DF71_RuffTruxTimer_Tenths)
  sub $01
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  cp $FF
  jr nz, _LABEL_36E6A_ret

  ; Decrement seconds
  ld a, $09
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
  ld a, (_RAM_DF70_RuffTruxTimer_Seconds)
  sub $01
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  cp $FF
  jr nz, _LABEL_36E6A_ret

  ; Decrement tens of seconds
  ld a, $09
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  ld a, (_RAM_DF6F_RuffTruxTimer_TensOfSeconds)
  sub $01
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  cp $FF
  jr nz, _LABEL_36E6A_ret

  ; Ran out of time!
  ld a, $01
  ld (_RAM_DF65_), a
  ld (_RAM_DF8C_), a
  ld a, $F0
  ld (_RAM_DF6A_), a
  ld a, $00
  ld (_RAM_DF6F_RuffTruxTimer_TensOfSeconds), a
  ld (_RAM_DF70_RuffTruxTimer_Seconds), a
  ld (_RAM_DF71_RuffTruxTimer_Tenths), a
_LABEL_36E6A_ret:
  ret

_LABEL_36E6B_:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DBA4_)
  add a, l
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DBA6_)
  add a, l
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jp z, _LABEL_36F4B_
  ld a, (_RAM_DF88_)
  add a, $01
  and $01
  ld (_RAM_DF88_), a
  cp $00
  jr z, _LABEL_36EEA_
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
  jp _LABEL_36F3E_

_LABEL_36EEA_:
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
_LABEL_36F3E_:
  or a
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBA9_)
  sbc hl, de
  ld (_RAM_DBA9_), hl
  ret

_LABEL_36F4B_:
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
  jr z, _LABEL_36F3E_
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.63.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.64.x)
  add a, l
  ld (_RAM_DA60_SpriteTableXNs.64.x), a
  jp _LABEL_36F3E_

_LABEL_36F9E_:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DBA5_)
  add a, l
  ld (_RAM_DBA5_), a
  ld a, (_RAM_DBA7_)
  add a, l
  ld (_RAM_DBA7_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jp z, _LABEL_3707E_
  ld a, (_RAM_DF89_)
  add a, $01
  and $01
  ld (_RAM_DF89_), a
  cp $00
  jr z, _LABEL_3701D_
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
  jp _LABEL_37071_

_LABEL_3701D_:
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
_LABEL_37071_:
  or a
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBAB_)
  sbc hl, de
  ld (_RAM_DBAB_), hl
  ret

_LABEL_3707E_:
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
  jr z, _LABEL_37071_
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.63.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.64.y)
  add a, l
  ld (_RAM_DAE0_SpriteTableYs.64.y), a
  jp _LABEL_37071_

; Data from 370D1 to 37160 (144 bytes)
_DATA_370D1_:
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
_DATA_37161_:
.db $23 $83 $83 $82 $82 $82 $81 $81 $81 $00 $00 $00 $23 $83 $83 $83
.db $82 $82 $82 $81 $81 $81 $00 $00 $24 $84 $83 $83 $83 $82 $82 $82
.db $81 $81 $81 $00 $24 $84 $84 $84 $83 $83 $82 $82 $81 $81 $81 $00
.db $24 $84 $84 $84 $83 $83 $82 $82 $82 $81 $81 $81 $24 $84 $84 $84
.db $84 $83 $83 $82 $82 $81 $81 $81 $FF $94 $94 $94 $94 $93 $93 $92
.db $92 $91 $91 $91 $64 $C4 $C4 $C4 $C4 $C3 $C3 $C2 $C2 $C1 $C1 $C1
.db $64 $C4 $C4 $C4 $C3 $C3 $C2 $C2 $C2 $C1 $C1 $C1 $64 $C4 $C4 $C4
.db $C3 $C3 $C2 $C2 $C1 $C1 $C1 $00 $64 $C4 $C3 $C3 $C3 $C2 $C2 $C2
.db $C1 $C1 $C1 $00 $63 $C3 $C3 $C3 $C2 $C2 $C2 $C1 $C1 $C1 $00 $00

_LABEL_371F1_:
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
_DATA_37232_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

; Data from 37272 to 37291 (32 bytes)
_DATA_37272_:
.db $E8 $03 $C0 $03 $98 $03 $70 $03 $48 $03 $20 $03 $F8 $02 $D0 $02
.db $A8 $02 $80 $02 $58 $02 $30 $02 $08 $02 $E0 $01 $B8 $01 $90 $01

_LABEL_37292_GameVBlankEngineUpdate:
  ld a, (_RAM_DE92_EngineVelocity)
  sla a
  ld e, a
  ld d, $00
  ld hl, _DATA_37272_
  add hl, de
  ld a, (hl)
  ld (_RAM_D58A_), a
  inc hl
  ld a, (hl)
  ld (_RAM_D58B_), a
  ld l, a
  ld bc, $0010
  ld hl, (_RAM_D58A_)
  or a
  sbc hl, bc
  ld (_RAM_D58A_), hl
  ld a, (_RAM_D58B_)
  ld l, a
  ld a, (_RAM_DF00_)
  or a
  jr nz, ++
  ld a, (_RAM_D95C_)
  cp l
  jr z, +
  jr c, _LABEL_372D3_
-:
  ld de, $0004
  ld hl, (_RAM_D95B_)
  or a
  sbc hl, de
  ld (_RAM_D95B_), hl
  ret

_LABEL_372D3_:
  ld hl, (_RAM_D95B_)
  ld de, $0002
  add hl, de
  ld (_RAM_D95B_), hl
  ret

+:
  ld a, (_RAM_D58A_)
  ld l, a
  ld a, (_RAM_D95B_)
  cp l
  jr z, +
  jr c, _LABEL_372D3_
  jp -

+:
  ret

++:
  ld a, (_RAM_D95C_)
  cp $01
  jr z, +
--:
  ld de, $0004
  ld hl, (_RAM_D95B_)
  or a
  sbc hl, de
  ld (_RAM_D95B_), hl
-:
  ret

+:
  ld a, (_RAM_D95B_)
  cp $90
  jr c, -
  jp --

_LABEL_3730C_GameVBlankPart3:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_D96F_)
  ld (_RAM_D595_), a
  jp _LABEL_37408_

+:
  xor a
  ld (_RAM_D594_), a
  ld (_RAM_D595_), a
  ld (_RAM_D596_), a
  ld a, (_RAM_DBA0_)
  ld l, a
  ld a, (_RAM_DE79_)
  add a, l
  sub $05
  jr nc, +
  xor a
+:
  ld (_RAM_D592_), a
  ld a, (_RAM_DBA2_)
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
  ld hl, _DATA_3751E_
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
  ld hl, _DATA_374A5_
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
  ld hl, _DATA_3751E_
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
  ld hl, _DATA_374A5_
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
  ld hl, _DATA_3751E_
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
  ld hl, _DATA_374A5_
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
  jr nc, _LABEL_373F3_
  ld a, (_RAM_DCBF_)
  ld b, a
  ld a, (_RAM_DCB6_)
  ex af, af'
  ld a, (_RAM_D594_)
  jp ++

_LABEL_373F3_:
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
  jr nc, _LABEL_373F3_
_LABEL_37408_:
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
  ld hl, _DATA_37272_
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
  jr c, _LABEL_37466_
-:
  ld de, $0004
  ld hl, (_RAM_D96C_)
  or a
  sbc hl, de
  ld (_RAM_D96C_), hl
  ret

_LABEL_37466_:
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
  jr z, +
  jr c, _LABEL_37466_
  jp -

+:
  ret

++:
  ld a, (_RAM_DF7F_)
  or a
  jr nz, _LABEL_3749A_
  ld a, (_RAM_D96D_)
  cp $01
  jr z, +
-:
  ld de, $0004
  ld hl, (_RAM_D96C_)
  or a
  sbc hl, de
  ld (_RAM_D96C_), hl
_LABEL_3749A_:
  ret

+:
  ld a, (_RAM_D96C_)
  cp $90
  jr c, _LABEL_3749A_
  jp -

; Data from 374A5 to 3751D (121 bytes)
_DATA_374A5_:
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $04 $04 $04 $04
.db $04 $04 $04 $04 $04 $02 $02 $04 $06 $06 $06 $06 $06 $06 $06 $04
.db $02 $02 $04 $06 $08 $08 $08 $08 $08 $06 $04 $02 $02 $04 $06 $08
.db $09 $09 $09 $08 $06 $04 $02 $02 $04 $06 $08 $09 $0A $09 $08 $06
.db $04 $02 $02 $04 $06 $08 $09 $09 $09 $08 $06 $04 $02 $02 $04 $06
.db $08 $08 $08 $08 $08 $06 $04 $02 $02 $04 $06 $06 $06 $06 $06 $06
.db $06 $04 $02 $02 $04 $04 $04 $04 $04 $04 $04 $04 $04 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02

; Data from 3751E to 37528 (11 bytes)
_DATA_3751E_:
.db $0B $16 $21 $2C $37 $42 $4D $58 $63 $6E $79

_LABEL_37529_:
  ld a, (_RAM_DC54_IsGameGear)
  or a
  jr z, ++
  ld a, (_RAM_DC41_GearToGearActive)
  or a
  jr z, +
  xor a
  jp ++

+:
  ld a, (_RAM_DC3D_IsHeadToHead)
++:
  ld (_RAM_D59D_), a
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
  jr z, +
  ld a, $74
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $68
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  ret

+:
  ld a, $3C
  ld (_RAM_DBA4_), a
  ld (_RAM_DBA6_), a
  ld a, $8F
  ld (_RAM_DBA5_), a
  ld (_RAM_DBA7_), a
  ret

; Data from 37580 to 3758F (16 bytes)
_DATA_37580_:
.db $74 $68 $58 $58 $58 $58 $58 $68 $74 $80 $90 $90 $90 $90 $90 $80

; Data from 37590 to 3759F (16 bytes)
_DATA_37590_:
.db $7F $7F $7F $6F $63 $57 $47 $47 $47 $47 $47 $57 $63 $6F $7F $7F

_LABEL_375A0_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, ++
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ret

+:
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr nz, ++
  ld a, (_RAM_DF6A_)
  or a
  jr nz, ++
  ld a, $00
  ld (_RAM_DEB8_), a
  ld a, (_RAM_DF58_)
  cp $00
  jr nz, ++
  ld a, (_RAM_DE90_CarDirection)
  ld l, a
  ld c, a
  ld a, (_RAM_DE80_)
  cp l
  jr nz, +++
  jr +++

++:
  ret

+++:
  ld a, $00
  ld (_RAM_DE7F_), a
  ld h, $00
  ld de, _DATA_37590_
  add hl, de
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DEB2_)
  or a
  jr nz, _LABEL_3762B_
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
  jr nz, +
  ld (_RAM_DEB8_), a
  ld a, $00
  ld (_RAM_DEB2_), a
+:
  ret

_LABEL_3762B_:
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
  jr nz, +
  ld (_RAM_DEB8_), a
  ld a, $01
  ld (_RAM_DEB2_), a
+:
  ret

_LABEL_3766F_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, ++
  ld a, (_RAM_DC54_IsGameGear)
  cp $01
  jr z, +
  ret

+:
  ld a, (_RAM_D5A4_IsReversing)
  or a
  jr nz, ++
  ld a, (_RAM_DF6A_)
  or a
  jr nz, ++
  ld a, $00
  ld (_RAM_DEB9_), a
  ld a, (_RAM_DF58_)
  cp $00
  jr nz, ++
  ld a, (_RAM_DE90_CarDirection)
  ld l, a
  ld c, a
  ld a, (_RAM_DE81_)
  cp l
  jr nz, +++
  jr +++

++:
  ret

+++:
  ld a, $00
  ld (_RAM_DE82_), a
  ld h, $00
  ld de, _DATA_37580_
  add hl, de
  ld a, (hl)
  ld b, a
  ld a, (_RAM_DEB0_)
  or a
  jr nz, _LABEL_376FA_
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
  jr nz, +
  ld (_RAM_DEB9_), a
  ld a, $00
  ld (_RAM_DEB0_), a
+:
  ret

_LABEL_376FA_:
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
  jr nz, +
  ld (_RAM_DEB9_), a
  ld (_RAM_DEB0_), a
+:
  ret

_LABEL_3773B_ReadControls:
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
  jr nz, + ; ret
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
+:
  ret

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
  jr z, + ; ret
  ld (_RAM_DB20_Player1Controls), a
  ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
  ld (_RAM_DB21_Player2Controls), a
  ld a, $00
  ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
  ret

+:
  ret

_LABEL_3779F_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, (_RAM_DB97_TrackType)
  cp TT_FourByFour
  jr nz, +
  ld a, (_RAM_D5A5_)
  or a
  jr z, +
  ld a, (_RAM_DCF8_)
  ld l, a
  ld h, $00
  ld de, _DATA_250E_
  add hl, de
  ld a, (hl)
  ld c, a
  jr ++

+:
  ld a, (_RAM_DCF8_)
  ld c, a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Powerboats
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
  ld hl, _DATA_250E_
  add hl, de
  ld a, (hl)
  ld (_RAM_DE34_), a
  ld a, (_RAM_DCF9_)
  ld (_RAM_DCF8_), a
  ret

_LABEL_37817_:
  ld a, (_RAM_DEB1_VScrollDelta)
  ld l, a
  ld a, (_RAM_DBA5_)
  sub l
  ld (_RAM_DBA5_), a
  ld a, (_RAM_DBA7_)
  sub l
  ld (_RAM_DBA7_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jp z, _LABEL_378F4_
  ld a, (_RAM_DF89_)
  add a, $01
  and $01
  ld (_RAM_DF89_), a
  cp $00
  jr z, _LABEL_37895_
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
  jr _LABEL_378E9_

_LABEL_37895_:
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
_LABEL_378E9_:
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBAB_)
  add hl, de
  ld (_RAM_DBAB_), hl
  ret

_LABEL_378F4_:
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
  jr z, _LABEL_378E9_
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.63.y), a
  ld a, (_RAM_DAE0_SpriteTableYs.64.y)
  sub l
  ld (_RAM_DAE0_SpriteTableYs.64.y), a
  jr _LABEL_378E9_

_LABEL_37946_:
  ld a, (_RAM_DEAF_)
  ld l, a
  ld a, (_RAM_DBA4_)
  sub l
  ld (_RAM_DBA4_), a
  ld a, (_RAM_DBA6_)
  sub l
  ld (_RAM_DBA6_), a
  ld a, (_RAM_DB97_TrackType)
  cp TT_Tanks
  jp z, _LABEL_37A23_
  ld a, (_RAM_DF88_)
  add a, $01
  and $01
  ld (_RAM_DF88_), a
  or a
  jr z, _LABEL_379C4_
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
  jp _LABEL_37A18_

_LABEL_379C4_:
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
_LABEL_37A18_:
  ld d, $00
  ld e, l
  ld hl, (_RAM_DBA9_)
  add hl, de
  ld (_RAM_DBA9_), hl
  ret

_LABEL_37A23_:
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
  jr z, _LABEL_37A18_
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.63.x), a
  ld a, (_RAM_DA60_SpriteTableXNs.64.x)
  sub l
  ld (_RAM_DA60_SpriteTableXNs.64.x), a
  jr _LABEL_37A18_

_LABEL_37A75_:
  ld a, (_RAM_D5A6_)
  or a
  jp z, _LABEL_37B6B_
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  cp $1A
  jp nc, _LABEL_37B49_
  ld hl, _DATA_1D65_
  ld a, (_RAM_D5A8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (_RAM_D5A8_)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  jr nc, _LABEL_37B35_
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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
  jr nc, _LABEL_37B35_
  call _LABEL_37BEF_
-:
  ld a, (_RAM_D5A6_)
  inc a
  ld (_RAM_D5A6_), a
  cp $25
  jr nz, +
  ld a, $04
  ld (_RAM_D963_SFXTrigger2), a
_LABEL_37B35_:
  xor a
  ld (_RAM_D5A6_), a
  ld (ix+0), a
  ld (iy+0), a
  ld (ix+2), a
  ld (iy+1), a
  ret

+:
  jp _LABEL_37F92_

_LABEL_37B49_:
  sub $1A
  ld e, a
  ld d, $00
  ld hl, _DATA_37B5E_
  add hl, de
  ld a, (hl)
  ld (ix+1), a
  ld a, $AC
  ld (ix+3), a
  jp -

; Data from 37B5E to 37B6A (13 bytes)
_DATA_37B5E_:
.db $A0 $A0 $A0 $A1 $A1 $A1 $A2 $A2 $A2 $A3 $A3 $A3 $AC

_LABEL_37B6B_:
  ld a, (_RAM_DC3F_GameMode)
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
  jr nz, _LABEL_37BEE_
+:
  ld a, (_RAM_DB20_Player1Controls)
  and BUTTON_1_MASK | BUTTON_2_MASK ; $30
  jr nz, _LABEL_37BEE_
++:
  ld a, (_RAM_DE4F_)
  cp $80
  jr nz, _LABEL_37BEE_
  ld a, (_RAM_DF58_)
  or a
  jr nz, _LABEL_37BEE_
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_37BEE_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld (_RAM_D5A7_), a
  ld a, (_RAM_DE92_EngineVelocity)
  add a, $06
  and $0F
  ld (_RAM_D5A8_), a
  ld a, $01
  ld (_RAM_D5A6_), a
  ld a, $0A
  ld (_RAM_D963_SFXTrigger2), a
  ld ix, _RAM_DA60_SpriteTableXNs.57
  ld iy, _RAM_DAE0_SpriteTableYs.57
  ld (ix+1), $AD
  ld (ix+3), $AE
  ld hl, _DATA_37C0A_
  ld a, (_RAM_DE91_CarDirectionPrevious)
  ld e, a
  ld d, $00
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA4_)
  add a, l
  ld (ix+0), a
  ld hl, _DATA_37C1A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (_RAM_DBA5_)
  add a, l
  ld (iy+0), a
_LABEL_37BEE_:
  ret

_LABEL_37BEF_:
  ld a, (_RAM_D5A6_)
  ld e, a
  ld d, $00
  ld hl, _DATA_37C2A_
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
_DATA_37C0A_:
.db $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03 $00 $03 $05 $08

; Data from 37C1A to 37C29 (16 bytes)
_DATA_37C1A_:
.db $00 $03 $05 $08 $0A $0D $0F $12 $14 $12 $0F $0D $0A $08 $05 $03

; Data from 37C2A to 37C44 (27 bytes)
_DATA_37C2A_:
.db $00 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $0F $0E $0D $0C $0B
.db $0A $09 $08 $07 $06 $05 $04 $03 $02 $01 $00

_LABEL_37C45_:
  ld ix, _RAM_DCAB_
  ld iy, _RAM_DA60_SpriteTableXNs.59
  jr ++

_LABEL_37C4F_:
  ld ix, _RAM_DCEC_
  ld iy, _RAM_DA60_SpriteTableXNs.61
  jr ++

_LABEL_37C59_:
  ld a, (_RAM_D5AB_)
  cp $A0
  jr z, +
  inc a
  ld (_RAM_D5AB_), a
  ret

+:
  ld ix, _RAM_DD2D_
  ld iy, _RAM_DA60_SpriteTableXNs.63
++:
  ld a, (ix+63)
  or a
  jp z, _LABEL_37D9C_
  cp $1A
  jp nc, _LABEL_37D87_
  ld hl, _DATA_1D65_
  ld a, (ix+64)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld e, (hl)
  ld hl, _DATA_1D76_
  ld a, (ix+64)
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a
  ld d, (hl)
  ld hl, _DATA_3FC3_
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
  ld hl, _DATA_40E5_
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
  jr nc, _LABEL_37D49_
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
  ld hl, _DATA_3FD3_
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
  ld hl, _DATA_40F5_
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
  jr nc, _LABEL_37D49_
  call _LABEL_37E62_
_LABEL_37D33_:
  ld a, (ix+63)
  inc a
  ld (ix+63), a
  cp $25
  jr nz, _LABEL_37D84_
  ld a, (ix+21)
  or a
  jr z, _LABEL_37D49_
  ld a, $04
  ld (_RAM_D974_SFXTrigger), a
_LABEL_37D49_:
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

_LABEL_37D84_:
  jp _LABEL_37E81_

_LABEL_37D87_:
  sub $1A
  ld e, a
  ld d, $00
  ld hl, _DATA_37B5E_
  add hl, de
  ld a, (hl)
  ld (iy+1), a
  ld a, $AC
  ld (iy+3), a
  jp _LABEL_37D33_

_LABEL_37D9C_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, ++
  ld a, (_RAM_DC3F_GameMode)
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
  jp nz, _LABEL_37E61_ret
++:
  ld a, (_RAM_DE4F_)
  cp $80
  jp nz, _LABEL_37E61_ret
  ld a, (ix+21)
  or a
  jp z, _LABEL_37E61_ret
  ld a, (ix+46)
  or a
  jp nz, _LABEL_37E61_ret
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (ix+17)
  cp $E0
  jp nc, _LABEL_37E61_ret
  cp $20
  jp c, _LABEL_37E61_ret
  ld a, (ix+18)
  cp $20
  jp c, _LABEL_37E61_ret
  cp $E0
  jp nc, _LABEL_37E61_ret
  jr ++

+:
  ld a, (_RAM_DF80_TwoPlayerWinPhase)
  or a
  jr nz, _LABEL_37E61_ret
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
  ld a, $0A
  ld (_RAM_D974_SFXTrigger), a
+:
  ld (iy+1), $AD
  ld (iy+3), $AE
  ld hl, _DATA_37C0A_
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
  ld hl, _DATA_37C1A_
  add hl, de
  ld a, (hl)
  ld l, a
  ld a, (ix+18)
  add a, l
  ld (iy+0), a
_LABEL_37E61_ret:
  ret

_LABEL_37E62_:
  ld a, (ix+63)
  ld e, a
  ld d, $00
  ld hl, _DATA_37C2A_
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

_LABEL_37E81_:
  ld a, (ix+45)
  cp $01
  jr z, +
  cp $02
  jr z, ++
  ld ix, _RAM_DCEC_
  call _LABEL_37F11_
  ld ix, _RAM_DD2D_
  call _LABEL_37F11_
  ld de, _RAM_DA60_SpriteTableXNs.59
  ld bc, _RAM_DAE0_SpriteTableYs.59
  jp +++

+:
  ld ix, _RAM_DCAB_
  call _LABEL_37F3A_
  ld ix, _RAM_DD2D_
  call _LABEL_37F3A_
  ld de, _RAM_DA60_SpriteTableXNs.61
  ld bc, _RAM_DAE0_SpriteTableYs.61
  jp +++

++:
  ld ix, _RAM_DCAB_
  call _LABEL_37F69_
  ld ix, _RAM_DCEC_
  call _LABEL_37F69_
  ld de, _RAM_DA60_SpriteTableXNs.63
  ld bc, _RAM_DAE0_SpriteTableYs.63
+++:
  ld a, (_RAM_DF58_)
  or a
  jr nz, +++
  ld a, (_RAM_DBA4_)
  ld l, a
  ld a, (de)
  sub l
  jr c, +++
  cp $18
  jr nc, +++
  ld a, (_RAM_DBA5_)
  ld l, a
  ld a, (bc)
  sub l
  jr c, +++
  cp $18
  jr nc, +++
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  call ++
  ld a, $01
  ld (_RAM_D5BD_), a
  jp _LABEL_29BC_Behaviour1_FallToFloor

+:
  call _LABEL_2934_BehaviourF
++:
  xor a
  ld (_RAM_DD2B_), a
  ld (_RAM_DA60_SpriteTableXNs.61.x), a
  ld (_RAM_DAE0_SpriteTableYs.61.y), a
  ld (_RAM_DA60_SpriteTableXNs.62.x), a
  ld (_RAM_DAE0_SpriteTableYs.62.y), a
+++:
  ret

_LABEL_37F11_:
  ld a, (ix+21)
  or a
  jr z, +
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.59.x)
  sub l
  jr c, +
  cp $18
  jr nc, +
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.59.y)
  sub l
  jr c, +
  cp $18
  jr nc, +
  call _LABEL_2961_
  jp _LABEL_37D49_

+:
  ret

_LABEL_37F3A_:
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, +
  ld a, (ix+21)
  or a
  jr z, +
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.61.x)
  sub l
  jr c, +
  cp $18
  jr nc, +
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.61.y)
  sub l
  jr c, +
  cp $18
  jr nc, +
  call _LABEL_2961_
  jp _LABEL_37D49_

+:
  ret

_LABEL_37F69_:
  ld a, (ix+21)
  or a
  jr z, +
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.63.x)
  sub l
  jr c, +
  cp $18
  jr nc, +
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.63.y)
  sub l
  jr c, +
  cp $18
  jr nc, +
  call _LABEL_2961_
  jp _LABEL_37D49_

+:
  ret

_LABEL_37F92_:
  ld ix, _RAM_DCEC_
  call +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr nz, _LABEL_37FF7_ret
  ld ix, _RAM_DCAB_
  call +
  ld ix, _RAM_DD2D_
+:
  ld a, (ix+46)
  or a
  jr nz, _LABEL_37FF7_ret
  ld a, (ix+21)
  or a
  jr z, _LABEL_37FF7_ret
  ld a, (ix+17)
  ld l, a
  ld a, (_RAM_DA60_SpriteTableXNs.57.x)
  sub l
  jr c, _LABEL_37FF7_ret
  cp $18
  jr nc, _LABEL_37FF7_ret
  ld a, (ix+18)
  ld l, a
  ld a, (_RAM_DAE0_SpriteTableYs.57.y)
  sub l
  jr c, _LABEL_37FF7_ret
  cp $18
  jr nc, _LABEL_37FF7_ret
  ld a, (ix+45)
  cp $01
  jr nz, +
  ld a, (_RAM_DC3D_IsHeadToHead)
  or a
  jr z, +
  ld a, $01
  ld (_RAM_D5BE_), a
  call _LABEL_4DD4_
  jr ++

+:
  call _LABEL_2961_
++:
  ld ix, _RAM_DA60_SpriteTableXNs.57.x
  ld iy, _RAM_DAE0_SpriteTableYs.57.y
  jp _LABEL_37B35_

_LABEL_37FF7_ret:
  ret

; Data from 37FF8 to 37FFF (8 bytes)
.db $FF $00 $00 $FF
.db $FF $00 $00

; Bank marker
.db :CADDR

.BANK 14
.ORG $0000

; Data from 38000 to 393CD (5070 bytes)
_DATA_38000_TurboWheels_Tiles:
.incbin "Assets/Turbo Wheels/Tiles.compressed"

_DATA_39168_Tanks_Tiles:
.incbin "Assets/Tanks/Tiles.compressed"

_DATA_39C83_FourByFour_Tiles:
.incbin "Assets/Four By Four/Tiles.compressed"

_DATA_3A8FA_Warriors_Tiles:
.incbin "Assets/Warriors/Tiles.compressed"

_DATA_3B32F_DisplayCaseTilemapCompressed:
.incbin "Assets/Menu/DisplayCase.tilemap.compressed"

_DATA_3B37F_Tiles_DisplayCase:
.incbin "Assets/Menu/DisplayCase.3bpp.compressed"

_LABEL_3B971_RamCodeLoaderStage2:
  ; Copy more code into RAM...
  ld hl, _LABEL_3B97D_RamCodeStart  ; Loading Code into RAM
  ld de, _RAM_D7BD_RamCode
  ld bc, _LABEL_3BD0F_RamCodeEnd - _LABEL_3B97D_RamCodeStart ; A lot! 914 bytes
  ldir
  ret

_LABEL_3B97D_RamCodeStart:

; Executed in RAM at d7bd
_LABEL_3B97D_DecompressFromHLToC000:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741 ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
  ld de, _RAM_C000_DecompressionTemporaryBuffer
  CallRamCode _LABEL_3B989_Decompress
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at d7c9
; This is a copy (!) of the code at _LABEL_7B21_Decompress
_LABEL_3B989_Decompress:
  push de
    jr _LABEL_3B9F5_get_next_mask_set_carry

_LABEL_3B98C_exit:
  pop hl
  ld a, e
  sub l
  ld c, a
  ld a, d
  sbc a, h
  ld h, a
  ret

---:  ld b, a
; Executed in RAM at d7d5
_LABEL_3B995_5x_use_b:
      ld a, e
      sub (hl)
      inc hl
      ld c, (hl)
      push hl
        ld l, a
        ld a, d
        sbc a, b
        ld h, a
        dec hl
        ld a, c
        ldi
        ldi
        ldi
        ld c, a
        ld b, $00
        inc bc
        jr +

--:   ld b, a
      and $0F
      add a, $02
      ld c, a
      ld a, b
      and $30
      rlca
      rlca
      rlca
      rlca
      cpl
      ld b, a
      ld a, (hl)
      push hl
        cpl
        add a, e
        ld l, a
        ld a, d
        adc a, b
        ld h, a
        dec hl
-:      ld b, $00
        inc c
        ldi
+:      ldir
      pop hl
      inc hl
    ex af, af'
    jr _LABEL_3B9FD_get_next_mask_7bits

; Executed in RAM at d810
_LABEL_3B9D0_5x:
      cp $0F
      jr nz, ---
      ld b, (hl)
      inc hl
      jr _LABEL_3B995_5x_use_b

_LABEL_3B9D8_2x3x4x:
      jr --

; Executed in RAM at d81a
_LABEL_3B9DA_highbitsetcompresseddata:
      cp $FF
      jr z, _LABEL_3B98C_exit

      and $60
      rlca
      rlca
      rlca
      inc a
      ld c, a

      ld a, (hl)
      push hl
        and $1F
        add a, c
        cpl
        add a, e
        ld l, a
        ld a, d
        adc a, $FF
        ld h, a
        jr -

--: ldi
_LABEL_3B9F5_get_next_mask_set_carry:
    scf
; Executed in RAM at d836
-:  ld a, (hl)
    inc hl

    adc a, a
    jr c, +
    ldi
_LABEL_3B9FD_get_next_mask_7bits:
    add a, a
    jr c, +
    ldi

    add a, a
    jr c, +
    ldi

    add a, a
    jr c, +
    ldi

    add a, a
    jr c, +
    ldi

    add a, a
    jr c, +
    ldi

    add a, a
    jr c, +
    ldi

    add a, a
    jr nc, --
+:  jr z, -
    ex af, af'
_LABEL_3BA21_compressed_real:
      ld a, (hl)
      cp $80
      jr nc, _LABEL_3B9DA_highbitsetcompresseddata
      inc hl
      sub $70
      jr nc, ++
      add a, $10
      jr c, _LABEL_3BA6D_6x
      add a, $10
      jr c, _LABEL_3B9D0_5x
      add a, $30
      jr c, _LABEL_3B9D8_2x3x4x
      add a, $10
      jr nc, _LABEL_3BA85_0x
      ld b, $00
      sub $0F
      jr z, +
      add a, $11
-:    ld c, a
      push hl
        ld l, e
        ld h, d
        dec hl
        ldi
        ldir
      pop hl
      ex af, af'
      jr _LABEL_3B9FD_get_next_mask_7bits

+:    ld a, (hl)
      inc hl
      add a, $11
      jr nc, -
      inc b
      jr -

; Executed in RAM at d899
++:   sub $0F
      jr nz, +
      ld a, (hl)
      inc hl
+:    add a, $11
      ld b, a
      dec de
      ld a, (de)
      inc de
-:    inc a
      ld (de), a
      inc de
      djnz -
    ex af, af'
--: jr _LABEL_3B9FD_get_next_mask_7bits

; Executed in RAM at d8ad
_LABEL_3BA6D_6x:
      add a, $03
      ld b, a
      ld a, (hl)
      push hl
        cpl
        scf
        adc a, e
        ld l, a
        ld a, d
        adc a, $FF
        ld h, a
-:      dec hl
        ld a, (hl)
        ld (de), a
        inc de
        djnz -
      pop hl
      inc hl
    ex af, af'
    jr --

; Executed in RAM at d8c5
_LABEL_3BA85_0x:
      ld b, $00
      inc a
      jr z, +
      add a, $17
      ld c, a
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldir
-:    jr _LABEL_3BA21_compressed_real

+:    ld a, (hl)
      inc hl
      inc a
      jr z, +
      add a, $1D
      ld c, a
      ld a, $08
      jr nc, _f
      inc b
__:   ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      ldi
      cp c
      jr c, _b
      dec b
      inc b
      jr nz, _b
      ldir
      jr -

+:    ld c, (hl)
      inc hl
      ld b, (hl)
      inc hl
      ld a, $08
      jr _b
; End of decompress code

; Data from 3BACF to 3BAF0 (34 bytes)
; Unused?
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $07 $0F $0F $0F $0F $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00

; Executed in RAM at d931
_LABEL_3BAF1_MenusVBlank:
  push af
  push bc
  push de
  push hl
  push ix
  push iy
    ld a, (_RAM_D6D4_)
    cp $00
    jr z, + ; almost always the case
    ld a, ($BFFF) ; Last byte of currently mapped page is (usually) the bank number
    ld (_RAM_D742_VBlankSavedPageIndex), a ; save
    ld a, :_LABEL_30D36_MenuMusicFrameHandler
    ld (PAGING_REGISTER), a
    call _LABEL_30D36_MenuMusicFrameHandler
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
_LABEL_3BB26_Trampoline_MenuMusicFrameHandler:
  ld a, :_LABEL_30D36_MenuMusicFrameHandler
  ld (PAGING_REGISTER), a
  call _LABEL_30D36_MenuMusicFrameHandler
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at d971
_LABEL_3BB31_Emit3bppTileDataToVRAM:
; hl = source
; de = count of rows (3 bytes = 1 row of pixels in a tile) to emit
; Write address must be set
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
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
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at d985
_LABEL_3BB45_Emit3bppTileDataToVRAM:
; hl = source
; e = count of rows (3 bytes = 1 row of pixels in a tile) to emit
; Write address must be set
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at d988
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA), a
  dec e
  jr nz, -
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at d997
_LABEL_3BB57_EmitTilemapRectangle:
; hl = data address
; de = VRAM address, must be already set
; Parameters in RAM
; Tile index $ff is converted to the blank tile from the font at index $0e
; - but if the high bit is set, it needs to be blank at $10e too...
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
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
  ld a, BLANK_TILE_INDEX ; $ff -> $0e (blank tile)
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
  CallRamCode _LABEL_3BCC0_VRAMAddressToDE
  JumpToRamCode --

+: ; Done
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at d9d3
_LABEL_3BB93_Emit3bppTiles_2Rows:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
  ld c, $03
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  inc de
  dec c
  jr nz, -
  xor a
  out (PORT_VDP_DATA), a
  inc de
  ld c, $03
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  inc hl
  inc de
  dec c
  jr nz, -
  xor a
  out (PORT_VDP_DATA), a
  inc de
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at d9f5
_LABEL_3BBB5_PopulateSpriteNs:
  ld a, :_DATA_2B33E_SpriteNs_Hand
  ld (_RAM_D741_RequestedPageIndex), a
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
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
  CallRamCode _LABEL_3BD08_BackToSlot2
  jp _LABEL_93CE_UpdateSpriteTable

; Executed in RAM at da18
_LABEL_3BBD8_EmitTilemapUnknown2:
; hl = source
; e = entry count
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
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
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at da38
_LABEL_3BBF8_EmitTilemapUnknown:
; hl = source
; de = dest VRAM address
; b = entry count
; c = width?
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
--:
  CallRamCode _LABEL_3BCC0_VRAMAddressToDE
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
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

+:CallRamCode _LABEL_3BD08_BackToSlot2
  ret

_LABEL_3BC27_EmitThirty3bppTiles:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
  ld e, 30 * 8 ; Row count - 30 tiles
-:ld b, $03 ; bit depth
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA), a
  dec e
  jr nz, -
  CallRamCode _LABEL_3BD08_BackToSlot2
  ret

; Executed in RAM at da7c
_LABEL_3BC3C_EmitFifteen3bppTiles:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
  ld e, $78 ; 15 tiles
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA),a
  dec e
  jr nz, -
  ld (_RAM_D6A6_DisplayCase_Source), hl
  JumpToRamCode _LABEL_3BD08_BackToSlot2

_LABEL_3BC53_EmitTen3bppTiles:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
  ld e, $50 ; 10 tiles
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA),a
  dec e
  jr nz, -
  ld (_RAM_D6A6_DisplayCase_Source), hl
  JumpToRamCode _LABEL_3BD08_BackToSlot2


_LABEL_3BC6A_EmitText: ; Executed in RAM at $daaa
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
-:ld a, (hl)
  out (PORT_VDP_DATA), a
  rlc a
  and $01
  out (PORT_VDP_DATA), a
  inc hl
  dec c
  jr nz, -
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at dabd
_LABEL_3BC7D_DisplayCase_RestoreRectangle:
; Restores tilemap data from hl to de (must be already set)
; 5 tiles wide rectangles from 22 tiles wide source data
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
--:
  ld c, $05   ; Width
-:ld a, (hl) ; Emit a byte from (hl), high tileset
  out (PORT_VDP_DATA), a
  ld a, $01
  out (PORT_VDP_DATA), a
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
  CallRamCode _LABEL_3BCC0_VRAMAddressToDE
  JumpToRamCode --

  ; When done...
+:jr _LABEL_3BD08_BackToSlot2

; Executed in RAM at $daef
_LABEL_03BCAF_Emit3bppTiles:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
  ; Emit 3bpp tile data for e bytes
-:ld b, $03
  ld c, PORT_VDP_DATA
  otir
  xor a
  out (PORT_VDP_DATA), a ; Zero-padded
  dec e
  jr nz, -
  jr _LABEL_3BD08_BackToSlot2

; Executed in RAM at db00
_LABEL_3BCC0_VRAMAddressToDE:
  ld a, e
  out (PORT_VDP_ADDRESS), a
  ld a, d
  out (PORT_VDP_ADDRESS), a
  ret

; Executed in RAM at db07
_LABEL_3BCC7_VRAMAddressToHL:
  ld a, l
  out (PORT_VDP_ADDRESS), a
  ld a, h
  out (PORT_VDP_ADDRESS), a
  ret

_LABEL_3BCCE_ReadPagedByte_de: ; unused?
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
  ld a, (de)          ; 03BCD1 1A
  JumpToRamCode _LABEL_3BCFC_RestorePagingPreserveA

_LABEL_3BCD5_ReadPagedByte_bc: ; unused?
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741
  ld a, (bc)          ; 03BCD8 0A
  JumpToRamCode _LABEL_3BCFC_RestorePagingPreserveA

; Executed in RAM at db1c
_LABEL_3BCDC_Trampoline2_PlayMenuMusic:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
  ld a, c
  call _LABEL_30CE8_PlayMenuMusic
  JumpToRamCode _LABEL_3BD08_BackToSlot2

; Executed in RAM at db26
_LABEL_3BCE6_Trampoline_StopMenuMusic:
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
  call _LABEL_30D28_StopMenuMusic
  JumpToRamCode _LABEL_3BD08_BackToSlot2

_LABEL_3BCEF_: ; unused?
  CallRamCode _LABEL_3BCF5_RestorePagingFromD741  ; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
  jp $a003 ; Don't know which page

; Executed in RAM at db35
_LABEL_3BCF5_RestorePagingFromD741:
  ld a, (_RAM_D741_RequestedPageIndex)
  ld (PAGING_REGISTER), a
  ret

_LABEL_3BCFC_RestorePagingPreserveA:
; Restores paging to slot 2 without losing the value in a
  ld (_RAM_D743_ReadPagedByteTemp),a
  ld a, $02
  ld (PAGING_REGISTER),a
  ld a, (_RAM_D743_ReadPagedByteTemp)
  ret


; Executed in RAM at db48
_LABEL_3BD08_BackToSlot2:
  ld a, $02
  ld (PAGING_REGISTER), a
  ret

; Extra byte picked up by RAM code copier...
.db $00

_LABEL_3BD0F_RamCodeEnd:

.repeat 188
.db $FF $FF $00 $00
.endr

; Bank marker
.db :CADDR

.BANK 15
.ORG $0000

; Data from 3C000 to 3FFFF (16384 bytes)
_DATA_3C000_Sportscars_Tiles:
.incbin "Assets/Sportscars/Tiles.compressed" ; bitplane-split 3bpp

_DATA_3CD8D_RuffTrux_Tiles:
.incbin "Assets/RuffTrux/Tiles.compressed" ; bitplane-split 3bpp

_DATA_3D901_Powerboats_Tiles:
.incbin "Assets/Powerboats/Tiles.compressed" ; bitplane-split 3bpp

_DATA_3E5D7_Tiles_MediumLogo:
.incbin "Assets/Menu/Logo-Medium.3bpp.compressed" ; bitplane-split 3bpp

_DATA_3EC67_Tiles_MediumLogo:
.incbin "Assets/Menu/Logo-Medium.tilemap.compressed"

_TEXT_3ECA9_VEHICLE_NAME_BLANK:
.asc "                "
_TEXT_3ECB9_VEHICLE_NAME_SPORTSCARS:
.asc "   SPORTSCARS   "
_TEXT_3ECC9_VEHICLE_NAME_POWERBOATS:
.asc "   POWERBOATS   "
_TEXT_3ECD9_VEHICLE_NAME_FORMULA_ONE:
.asc "  FORMULA  ONE  "
_TEXT_3ECE9_VEHICLE_NAME_FOUR_BY_FOUR:
.asc "  FOUR BY FOUR  "
_TEXT_3ECF9_VEHICLE_NAME_WARRIORS:
.asc "    WARRIORS    "
_TEXT_3ED09_VEHICLE_NAME_CHOPPERS:
.asc "    CHOPPERS    "
_TEXT_3ED19_VEHICLE_NAME_TURBO_WHEELS:
.asc "  TURBO WHEELS  "
_TEXT_3ED29_VEHICLE_NAME_TANKS:
.asc "      TANKS     "
_TEXT_3ED39_VEHICLE_NAME_RUFFTRUX:
.asc "    RUFFTRUX    "

_DATA_3ED49_SplashScreenCompressed:
.incbin "Assets/SplashScreen/SplashScreen.compressed"

_DATA_3F753_JonsSquinkyTennisCompressed:
.incbin "Assets/JonsSquinkyTennis.compressed"

; Blank fill
.repeat 33
.dw $0000, $ffff
.endr
.dw $0000

; Bank marker
.db :CADDR
