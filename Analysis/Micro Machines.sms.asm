; This disassembly was created using Emulicious (http://www.emulicious.net)
.MEMORYMAP
SLOTSIZE $7FF0
SLOT 0 $0000
SLOTSIZE $10
SLOT 1 $7FF0
SLOTSIZE $4000
SLOT 2 $8000
DEFAULTSLOT 2
.ENDME
.ROMBANKMAP
BANKSTOTAL 16
BANKSIZE $7FF0
BANKS 1
BANKSIZE $10
BANKS 1
BANKSIZE $4000
BANKS 14
.ENDRO

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
.asciitable
map "A" to "N" = $00
map "O" = $1a
map "P" to "Z" = $0f
map "0" to "9" = $1a
map " " = $0e
map "!" = $B4
map "-" = $B5
map "?" = $B6
.enda

.macro CallPagedFunction args function
	ld a, :function
	ld ($8000), a
	call function
	call _LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro JumpToPagedFunction args function
	ld a, :function
	ld ($8000), a
	call function
	jp _LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro JrToPagedFunction args function
	ld a, :function
	ld ($8000), a
	call function
	jr _LABEL_AFD_RestorePaging_fromDE8E
.endm

.macro CallPagedFunction2 args function
	ld a, :function
	ld ($8000), a
	call function
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
.endm

.enum $C000 export
_RAM_C000_DecompressionTemporaryBuffer db
_RAM_C001_ dw
.ende

.enum $C04C export
_RAM_C04C_ dw
.ende

.enum $C061 export
_RAM_C061_ db
_RAM_C062_ dw
.ende

.enum $C0A0 export
_RAM_C0A0_ dw
.ende

.enum $C0A8 export
_RAM_C0A8_ db
.ende

.enum $C0AB export
_RAM_C0AB_ db
_RAM_C0AC_ db
.ende

.enum $C0FF export
_RAM_C0FF_ dw
.ende

.enum $C108 export
_RAM_C108_ db
.ende

.enum $C10C export
_RAM_C10C_ db
.ende

.enum $C111 export
_RAM_C111_ db
_RAM_C112_ db
.ende

.enum $C2E3 export
_RAM_C2E3_ db
_RAM_C2E4_ db
.ende

.enum $C2E6 export
_RAM_C2E6_ db
_RAM_C2E7_ db
_RAM_C2E8_ db
.ende

.enum $C3E0 export
_RAM_C3E0_ db
.ende

.enum $C800 export
_RAM_C800_WallData dsb 128 * 12 * 12 / 8 ; 128 tiles of 12x12 bits
.ende

.enum $CA18 export
_RAM_CA18_ db
.ende

.enum $CA1A export
_RAM_CA1A_ db
.ende

.enum $CA23 export
_RAM_CA23_ db
.ende

.enum $CA25 export
_RAM_CA25_ db
.ende

.enum $CA95 export
_RAM_CA95_ db
.ende

.enum $CA97 export
_RAM_CA97_ db
.ende

.enum $CAA2 export
_RAM_CAA2_ db
.ende

.enum $CAA4 export
_RAM_CAA4_ db
.ende

.enum $CB3E export
_RAM_CB3E_ db
.ende

.enum $CB40 export
_RAM_CB40_ db
.ende

.enum $CB55 export
_RAM_CB55_ db
.ende

.enum $CB57 export
_RAM_CB57_ db
.ende

.enum $CBA9 export
_RAM_CBA9_ db
.ende

.enum $CBAB export
_RAM_CBAB_ db
.ende

.enum $CBC2 export
_RAM_CBC2_ db
.ende

.enum $CBC4 export
_RAM_CBC4_ db
.ende

.enum $CC04 export
_RAM_CC04_ db
.ende

.enum $CC12 export
_RAM_CC12_ db
.ende

.enum $CC14 export
_RAM_CC14_ db
_RAM_CC15_ db
.ende

.enum $CC23 export
_RAM_CC23_ db
_RAM_CC24_ db
.ende

.enum $CC38 export
_RAM_CC38_ db
.ende

.enum $CC80 export
_RAM_CC80_BehaviourData dsb 128 * 6 * 6 ; 128 tiles of 6x6 bytes
.ende

.enum $D000 export
_RAM_D000_ db
.ende

.enum $D097 export
_RAM_D097_ db
_RAM_D098_ db
.ende

.enum $D09C export
_RAM_D09C_ db
_RAM_D09D_ db
.ende

.enum $D09F export
_RAM_D09F_ db
.ende

.enum $D0A2 export
_RAM_D0A2_ db
.ende

.enum $D0A9 export
_RAM_D0A9_ db
.ende

.enum $D0B0 export
_RAM_D0B0_ db
.ende

.enum $D0C4 export
_RAM_D0C4_ db
.ende

.enum $D191 export
_RAM_D191_ db
_RAM_D192_ db
.ende

.enum $D196 export
_RAM_D196_ db
.ende

.enum $D198 export
_RAM_D198_ db
_RAM_D199_ db
.ende

.enum $D19F export
_RAM_D19F_ db
.ende

.enum $D1A4 export
_RAM_D1A4_ db
.ende

.enum $D1A8 export
_RAM_D1A8_ db
_RAM_D1A9_ db
_RAM_D1AA_ db
_RAM_D1AB_ db
_RAM_D1AC_ db
_RAM_D1AD_ db
.ende

.enum $D1C5 export
_RAM_D1C5_ db
.ende

.enum $D293 export
_RAM_D293_ db
.ende

.enum $D299 export
_RAM_D299_ db
.ende

.enum $D29F export
_RAM_D29F_ db
.ende

.enum $D2A5 export
_RAM_D2A5_ db
.ende

.enum $D302 export
_RAM_D302_ db
.ende

.enum $D307 export
_RAM_D307_ db
.ende

.enum $D30C export
_RAM_D30C_ db
.ende

.enum $D312 export
_RAM_D312_ db
_RAM_D313_ db
.ende

.enum $D315 export
_RAM_D315_ db
.ende

.enum $D319 export
_RAM_D319_ db
_RAM_D31A_ db
.ende

.enum $D32E export
_RAM_D32E_ db
.ende

.enum $D33A export
_RAM_D33A_ db
_RAM_D33B_ db
_RAM_D33C_ db
_RAM_D33D_ db
_RAM_D33E_ db
_RAM_D33F_ db
.ende

.enum $D346 export
_RAM_D346_ db
_RAM_D347_ db
_RAM_D348_ db
_RAM_D349_ db
_RAM_D34A_ db
_RAM_D34B_ db
.ende

.enum $D368 export
_RAM_D368_ db
_RAM_D369_ db
.ende

.enum $D36E export
_RAM_D36E_ db
_RAM_D36F_ db
.ende

.enum $D3D7 export
_RAM_D3D7_ db
.ende

.enum $D3DE export
_RAM_D3DE_ db
.ende

.enum $D3E5 export
_RAM_D3E5_ db
.ende

.enum $D3E8 export
_RAM_D3E8_ db
.ende

.enum $D3EA export
_RAM_D3EA_ db
_RAM_D3EB_ db
.ende

.enum $D3EF export
_RAM_D3EF_ db
_RAM_D3F0_ db
.ende

.enum $D40B export
_RAM_D40B_ db
.ende

.enum $D489 export
_RAM_D489_ db
.ende

.enum $D48C export
_RAM_D48C_ db
_RAM_D48D_ db
_RAM_D48E_ db
.ende

.enum $D491 export
_RAM_D491_ db
_RAM_D492_ db
.ende

.enum $D497 export
_RAM_D497_ db
_RAM_D498_ db
.ende

.enum $D49E export
_RAM_D49E_ db
_RAM_D49F_ db
_RAM_D4A0_ db
.ende

.enum $D4A7 export
_RAM_D4A7_ db
.ende

.enum $D4AF export
_RAM_D4AF_ db
_RAM_D4B0_ db
_RAM_D4B1_ db
.ende

.enum $D4B7 export
_RAM_D4B7_ db
_RAM_D4B8_ db
.ende

.enum $D4BD export
_RAM_D4BD_ db
_RAM_D4BE_ db
.ende

.enum $D4C1 export
_RAM_D4C1_ db
_RAM_D4C2_ db
_RAM_D4C3_ db
.ende

.enum $D580 export
_RAM_D580_ db
_RAM_D581_ db
_RAM_D582_ db
_RAM_D583_ db
.ende

.enum $D585 export
_RAM_D585_ dw
_RAM_D587_ db
.ende

.enum $D589 export
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
.ende

.enum $D599 export
_RAM_D599_IsPaused db
_RAM_D59A_ db
_RAM_D59B_ db
_RAM_D59C_ db
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
.ende

.enum $D5B0 export
_RAM_D5B0_ db
.ende

.enum $D5B5 export
_RAM_D5B5_ db
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
_RAM_D5CC_ db
_RAM_D5CD_CarIsSkidding db
.ende

.enum $D5CF export
_RAM_D5CF_ db
_RAM_D5D0_ db
.ende

.enum $D5D2 export
_RAM_D5D2_ db
_RAM_D5D3_ db
_RAM_D5D4_ db
_RAM_D5D5_ db
_RAM_D5D6_ db
_RAM_D5D7_ db
_RAM_D5D8_ db
_RAM_D5D9_ db
.ende

.enum $D5DC export
_RAM_D5DC_ db
_RAM_D5DD_ db
_RAM_D5DE_ db
_RAM_D5DF_ db
_RAM_D5E0_ db
.ende

.enum $D640 export
_RAM_D640_RamCodeLoader dsb 17
.ende

.enum $D680 export
_RAM_D680_Player1Controls_Menus db
_RAM_D681_Player2Controls_Menus db
.ende

.enum $D687 export
_RAM_D687_Player1Controls_PreviousFrame db
_RAM_D688_ db
.ende

.enum $D68A export
_RAM_D68A_TilemapRectangleSequence_TileIndex db
_RAM_D68B_ db
_RAM_D68C_ db
_RAM_D68D_ db
_RAM_D68E_ db
_RAM_D68F_ db
_RAM_D690_ db
_RAM_D691_ db
_RAM_D692_ db
_RAM_D693_ db
_RAM_D694_ db
_RAM_D695_ db
_RAM_D696_ db
_RAM_D697_ db
.ende

.enum $D699 export
_RAM_D699_MenuScreenIndex db
_RAM_D69A_TilemapRectangleSequence_Width db
_RAM_D69B_TilemapRectangleSequence_Height db
_RAM_D69C_TilemapRectangleSequence_Flags db
_RAM_D69D_EmitTilemapRectangle_Width db
_RAM_D69E_EmitTilemapRectangle_Height db
_RAM_D69F_EmitTilemapRectangle_IndexOffset db
_RAM_D6A0_ db
_RAM_D6A1_ db
_RAM_D6A2_ db
_RAM_D6A3_ db
_RAM_D6A4_ db
_RAM_D6A5_ db
_RAM_D6A6_DisplayCase_Source dw
_RAM_D6A8_ dw
_RAM_D6AA_ db
_RAM_D6AB_ db
_RAM_D6AC_ db
_RAM_D6AD_ db
_RAM_D6AE_ db
_RAM_D6AF_ db
_RAM_D6B0_ db
_RAM_D6B1_ db
.ende

.enum $D6B4 export
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
_RAM_D6C5_ db
_RAM_D6C6_ db
_RAM_D6C7_ db
_RAM_D6C8_ db
_RAM_D6C9_ControllingPlayersLR1Buttons db ; Combination of player 1 and 2 when applicable, else player 1
_RAM_D6CA_ db
_RAM_D6CB_ db
_RAM_D6CC_ db
_RAM_D6CD_ db
_RAM_D6CE_ db
_RAM_D6CF_ db
_RAM_D6D0_TitleScreenCheatCodeCounterHardMode db
_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen db ; Used for "debouncing"
_RAM_D6D2_Unused db
_RAM_D6D3_VBlankDone db
_RAM_D6D4_ db
_RAM_D6D5_ db
_RAM_D6D6_ db
.ende

.enum $D6E1 export
_RAM_D6E1_ db
.ende

.enum $D701 export
_RAM_D701_ db
.ende

.enum $D721 export
_RAM_D721_ db
.ende

.enum $D741 export
_RAM_D741_RAMDecompressorPageIndex db
_RAM_D742_VBlankSavedPageIndex db
.ende

.enum $D744 export
_RAM_D744_ db
.ende

.enum $D74D export
_RAM_D74D_ db
.ende

.enum $D769 export
_RAM_D769_ db
.ende

.enum $D772 export
_RAM_D772_ db
.ende

.enum $D78E export
_RAM_D78E_ db
.ende

.enum $D797 export
_RAM_D797_ db
.ende

.enum $D7B3 export
_RAM_D7B3_ db
_RAM_D7B4_ db
_RAM_D7B5_DecompressorSource db
_RAM_D7B6_ db
_RAM_D7B7_ db
_RAM_D7B8_ db
_RAM_D7B9_ db
_RAM_D7BA_ db
_RAM_D7BB_ db
.ende

.enum $D7BD export
_RAM_D7BD_RamCode dsb $392
.ende

.enum $D800 export
_RAM_D800_ dsb 256
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
_RAM_D916_ db
_RAM_D917_ db
_RAM_D918_ db
_RAM_D919_ db
_RAM_D91A_ dw
_RAM_D91C_ db
.ende

.enum $D91E export
_RAM_D91E_ db
.ende

.enum $D920 export
_RAM_D920_ db
_RAM_D921_ db
_RAM_D922_ db
_RAM_D923_ db
_RAM_D924_ db
.ende

.enum $D929 export
_RAM_D929_ dw
_RAM_D92B_ db
_RAM_D92C_ db
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
_RAM_D94C_ db
_RAM_D94D_ db
_RAM_D94E_ db
_RAM_D94F_ db
_RAM_D950_ db
_RAM_D951_ db
_RAM_D952_ db
_RAM_D953_ db
_RAM_D954_ db
_RAM_D955_ db
_RAM_D956_ db
_RAM_D957_ db
_RAM_D958_ db
.ende

.enum $D95A export
_RAM_D95A_ db
_RAM_D95B_ db
_RAM_D95C_ db
.ende

.enum $D95E export
_RAM_D95E_ db
.ende

.enum $D963 export
_RAM_D963_SFXTrigger2 db
_RAM_D964_ db
.ende

.enum $D96B export
_RAM_D96B_ db
_RAM_D96C_ db
_RAM_D96D_ db
.ende

.enum $D96F export
_RAM_D96F_ db
.ende

.enum $D974 export
_RAM_D974_SFXTrigger db
_RAM_D975_ db
.ende

.enum $D97C export
_RAM_D97C_ db
.ende

.enum $D980 export
_RAM_D980_CarDecoratorTileData1bpp dsb $40
.ende

.enum $DA00 export
_RAM_DA00_ db
.ende

.enum $DA20 export
_RAM_DA20_TrackMetatileLookup dsb 64
_RAM_DA60_SpriteTableXNs dsb 64*2
.ende

.enum $DAC0 export
_RAM_DA60_SpriteTableXNs+96 db
_RAM_DA60_SpriteTableXNs+97 db
_RAM_DA60_SpriteTableXNs+98 db
_RAM_DA60_SpriteTableXNs+99 db
_RAM_DA60_SpriteTableXNs+100 db
_RAM_DA60_SpriteTableXNs+101 db
_RAM_DA60_SpriteTableXNs+102 db
_RAM_DA60_SpriteTableXNs+103 db
_RAM_DA60_SpriteTableXNs+104 db
_RAM_DA60_SpriteTableXNs+105 db
_RAM_DA60_SpriteTableXNs+106 db
_RAM_DA60_SpriteTableXNs+107 db
_RAM_DA60_SpriteTableXNs+108 db
_RAM_DA60_SpriteTableXNs+109 db
_RAM_DA60_SpriteTableXNs+110 db
_RAM_DA60_SpriteTableXNs+111 db
_RAM_DA60_SpriteTableXNs+112 db
.ende

.enum $DAD2 export
_RAM_DA60_SpriteTableXNs+114 db
.ende

.enum $DAD4 export
_RAM_DAD4_ db
.ende

.enum $DAD6 export
_RAM_DAD6_ db
.ende

.enum $DAD8 export
_RAM_DAD8_ db
.ende

.enum $DADA export
_RAM_DADA_ db
.ende

.enum $DADC export
_RAM_DADC_ db
.ende

.enum $DADE export
_RAM_DADE_ db
.ende
*/
.enum $DAE0 export
_RAM_DAE0_SpriteTableYs dsb 64
.ende

.enum $DAE9 export
_RAM_DAE9_ db
.ende

.enum $DAF3 export
_RAM_DAF3_ db
.ende

.enum $DAFD export
_RAM_DAFD_ db
.ende

.enum $DB07 export
_RAM_DB07_ db
.ende

.enum $DB10 export
_RAM_DB10_ db
_RAM_DB11_ db
_RAM_DB12_ db
_RAM_DB13_ db
_RAM_DB14_ db
_RAM_DB15_ db
_RAM_DB16_ db
_RAM_DB17_ db
_RAM_DB18_ db
_RAM_DB19_ db
_RAM_DB1A_ db
_RAM_DB1B_ db
_RAM_DB1C_ db
_RAM_DB1D_ db
_RAM_DB1E_ db
_RAM_DB1F_ db
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
_RAM_DB86_ dsb 16 ; ??? Related to skidding, thresholds when turning?
.ende

.enum $DB96 export
_RAM_DB96_TrackIndexForThisType db
_RAM_DB97_TrackType db
_RAM_DB98_TopSpeed db
_RAM_DB99_AccelerationDelay db
_RAM_DB9A_DecelerationDelay db
_RAM_DB9B_SteeringDelay db
_RAM_DB9C_ dw
_RAM_DB9E_ db
.ende

.enum $DBA0 export
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
.ende

.enum $DBC0 export
_RAM_DBC0_EnterGameTrampoline db
.ende

.enum $DBCD export
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
.ende

.enum $DBE8 export
_RAM_DBE8_ db
.ende

.enum $DBEC export
_RAM_DBEC_ db
.ende

.enum $DBF0 export
_RAM_DBF0_ db
.ende

.enum $DBF6 export
_RAM_DBF6_ db
_RAM_DBF7_ db
.ende

.enum $DBF9 export
_RAM_DBF9_ dw
_RAM_DBFB_ db
_RAM_DBFC_ db
_RAM_DBFD_ db
_RAM_DBFE_ db
.ende

.enum $DC09 export
_RAM_DC09_Lives db
_RAM_DC0A_ db
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
_RAM_DC34_ db
_RAM_DC35_ db
_RAM_DC36_ db
_RAM_DC37_ db
_RAM_DC38_ db
_RAM_DC39_ db
_RAM_DC3A_ db
_RAM_DC3B_ db
_RAM_DC3C_IsGameGear db ; Most code is common with the GG game
_RAM_DC3D_IsHeadToHead db
_RAM_DC3E_InMenus db ; 1 in menus, 0 otherwise
_RAM_DC3F_ db
_RAM_DC40_ db
_RAM_DC41_GearToGearActive db
_RAM_DC42_GearToGear_IAmPlayer1 db
.ende

.enum $DC45 export
_RAM_DC45_TitleScreenCheatCodeCounterCourseSelect db ; Counts up correct keypresses
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
.ende

.enum $DC54 export
_RAM_DC54_IsGameGear db ; GG mode if 1, SMS mode if 0
_RAM_DC55_CourseIndex db
_RAM_DC56_ db ; 
_RAM_DC57_ dw
_RAM_DC59_FloorTiles dsb 32*2
.ende

.enum $DC5B export
_RAM_DC5B_ db
.ende

.enum $DC5F export
_RAM_DC5F_ db
.ende

.enum $DC63 export
_RAM_DC63_ db
.ende

.enum $DC67 export
_RAM_DC67_ db
.ende

.enum $DC6B export
_RAM_DC6B_ db
.ende

.enum $DC6F export
_RAM_DC6F_ db
.ende

.enum $DC73 export
_RAM_DC73_ db
.ende

.enum $DC77 export
_RAM_DC77_ db
.ende

.enum $DC79 export
_RAM_DC79_ db
.ende

.enum $DC7B export
_RAM_DC7B_ db
.ende

.enum $DC7F export
_RAM_DC7F_ db
.ende

.enum $DC83 export
_RAM_DC83_ db
.ende

.enum $DC87 export
_RAM_DC87_ db
.ende

.enum $DC8B export
_RAM_DC8B_ db
.ende

.enum $DC8F export
_RAM_DC8F_ db
.ende

.enum $DC93 export
_RAM_DC93_ db
.ende

.enum $DC97 export
_RAM_DC97_ db
.ende

.enum $DC99 export
_RAM_DC99_EnterMenuTrampoline dsb 18 ; Data copied from ROM, not clear if it's used
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
.ende

.enum $DCBA export
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
.ende

.enum $DE60 export
_RAM_DE60_ db
.ende

.enum $DE62 export
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
_RAM_DEB1_ db
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
_RAM_DEBC_ db
_RAM_DEBD_ db
_RAM_DEBE_ db
_RAM_DEBF_ dw
_RAM_DEC1_ db
_RAM_DEC2_ db
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
_RAM_DECF_ dw
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
_RAM_DF13_BitIndex db
_RAM_DF14_LastWrittenByte db
_RAM_DF15_ db
_RAM_DF16_ db
_RAM_DF17_HaveFloorTiles db
_RAM_DF18_FloorTilesVRAMAddress dw
.ende

.enum $DF1C export
_RAM_DF1C_CopyToVRAMUpperBoundHi db
_RAM_DF1D_ db
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
_RAM_DF2E_ db
.ende

.enum $DF37 export
_RAM_DF37_ db
_RAM_DF38_ db
.ende

.enum $DF3C export
_RAM_DF3C_ db
_RAM_DF3D_ db
_RAM_DF3E_ db
_RAM_DF3F_ db
_RAM_DF40_ db
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
.ende

.enum $EF00 export
_RAM_EF00_ dw
.ende

.BANK 0 SLOT 0
.ORG $0000

_LABEL_0_:
	di
	ld hl, $DFFF
	ld sp, hl
	call _LABEL_100_Startup ; Weird stuff, copies things to RAM and more
	xor a
	ld (_RAM_DC41_GearToGearActive), a
	ld a, $02
	ld ($8000), a
	jp _LABEL_8000_Main

_LABEL_14_EnterMenus: 
  ; Code jumps here when transitioning from game to menus
	di
	ld a, $02
	ld ($8000), a
	ld a, $01
	ld (_RAM_DC3E_InMenus), a
	ld hl, $DFFF
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
    in a, ($BF) ; Ack INT
	pop af
	ei
	reti

+:
	pop af
	jp $D931	; Code is loaded from _LABEL_3BAF1_MenusVBlank

++:
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
	ld ($0000), a
	ld a, $01
	ld ($4000), a
	jp _LABEL_7573_EnterGame

; Data from 82 to 95 (20 bytes)
.db $00 $01 $01 $00 $03 $02 $50 $50 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.asc "RACE 01-" ;.db $11 $00 $02 $04 $0E $1A $1B $B5
; End stuff copied to RAM

; Data from AE to BF (18 bytes), copied to RAM $dc99..$dcaa
_LABEL_AE_EnterMenuTrampolineImpl:
  di
  ld a,2
  ld ($8000),a
  ld a,1
  ld (_RAM_DC3E_InMenus),a
  ld hl,$dfff
  ld sp, hl
  jp $8000

; Data from C0 to FF (64 bytes)
_DATA_C0_FloorTilesRawTileData:
.db $00 $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00
.db $00 $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00 $00 $00 $FF $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

_LABEL_100_Startup:
  ; Blank RAM
	ld hl, $C000
	ld bc, $1F9A
-:xor a
	ld (hl), a
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, -
  
	ld hl, _RAM_DBC0_EnterGameTrampoline
	ld de, _LABEL_75_EnterGameTrampolineImpl	; Loading Code into RAM
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
	ld bc, $0040
-:ld a, (de)
	ld (hl), a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
  
	call _LABEL_186_LoadUnknownDataToRAM
  ; More RAM initialisation
	ld a, $01
	ld (_RAM_DBA8_), a
	ld a, $20
	ld (_RAM_DB9C_), a
	ld (_RAM_DB9E_), a
	ld hl, $DB22
	ld (_RAM_DB62_), hl
	ld hl, $DB42
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
  ; Copy some data to RAM
	ld hl, _RAM_DC99_EnterMenuTrampoline
	ld de, _LABEL_AE_EnterMenuTrampolineImpl
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

_LABEL_186_LoadUnknownDataToRAM:
	ld hl, _RAM_D94C_
	ld de, _DATA_650C_
	ld bc, 52
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
    jr nz, _LABEL_1E0_
    push hl
    push bc
    push de
    push ix
    push iy
      ld a, (_DATA_BFFF_Value02)
      push af
        ld a, (_RAM_D5B5_)
        or a
        jr z, +
        xor a
        ld (_RAM_D580_), a
        call _LABEL_33A_
        ld a, (_RAM_DC41_GearToGearActive)
        or a
        jr nz, +
        ld a, (_RAM_D599_IsPaused)
        or a
        jr nz, +
        call _LABEL_5169_
        call _LABEL_5174_
        CallPagedFunction _LABEL_2B5D2_
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
	in a, ($7E)
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
	call _LABEL_5169_
	call _LABEL_5174_
	call _LABEL_318_
	CallPagedFunction _LABEL_2B5D2_
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
	in a, ($7E)
	cp $B8
	jr c, + ; ret
	cp $F0
	jr nc, + ; ret
	call _LABEL_33A_
	ld a, $01
	ld (_RAM_D5D7_), a
+:
	ret

-:
	xor a
	ld (_RAM_DBA8_), a
	ret

_LABEL_33A_:
	ld a, (_RAM_DBA8_)
	cp $01
	jr z, -
	call _LABEL_7795_
	call _LABEL_78CE_
	call _LABEL_7916_
  
  ; Update scroll registers
	ld a, (_RAM_DED4_VScrollValue)
	out ($BF), a
	ld a, $89
	out ($BF), a
	ld a, (_RAM_DED3_HScrollValue)
	out ($BF), a
	ld a, $88
	out ($BF), a
  
	call _LABEL_31F1_UpdateSpriteTable
	call _LABEL_324C_UpdatePerFrameTiles
	ld a, (_RAM_D5CC_)
	or a
	jr z, +
	CallPagedFunction _LABEL_17E95_ ; Call only when flag is set, then reset it
	xor a
	ld (_RAM_D5CC_), a
+:call _LABEL_BC5_UpdateFloorTiles
	call _LABEL_2D07_UpdatePalette_RuffTruxSubmerged
	call _LABEL_3FB4_UpdateAnimatedPalette
	jp _LABEL_778C_

_LABEL_383_:
	call _LABEL_3ED_
--:
	ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
	or a
	jr nz, +
	call _LABEL_AFD_ReadControls
-:
	ld a, (_RAM_D580_)
	or a
	jr nz, -
	xor a
	ld (_RAM_D5B5_), a
	call _LABEL_1E4_
	ld a, (_RAM_D5D6_)
	or a
	jp nz, _LABEL_7476_
	ld a, $01
	ld (_RAM_D580_), a
	ld (_RAM_D5B5_), a
	jp --

+:
	ld hl, $0800
-:
	dec hl
	ld a, h
	or l
	jr nz, -
	ld (_RAM_D5D8_), a
--:
	ld a, (_RAM_D5D6_)
	or a
	jp nz, _LABEL_7476_
	ld a, (_RAM_D5D8_)
	or a
	jr z, --
	ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2)
	out ($03), a
	xor a
	ld (_RAM_D5D7_), a
	ld (_RAM_D5D8_), a
	call _LABEL_AFD_ReadControls
	call _LABEL_1E4_
	ld a, (_RAM_D5D7_)
	or a
	jr nz, --
-:
	in a, ($7E)
	cp $B8
	jr c, -
	cp $F0
	jr nc, -
	call _LABEL_33A_
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
	call _LABEL_458_
	call _LABEL_51A8_
	call _LABEL_1345_
	call _LABEL_77CD_
	call _LABEL_1801_
	call _LABEL_3231_
	call _LABEL_3F2B_
	call _LABEL_3199_
	call _LABEL_AEB_
	call _LABEL_7564_SetControlsToNoButtons
	call _LABEL_186_LoadUnknownDataToRAM
	call ++
	ld a, $0A
	ld (_RAM_D96F_), a
	ld a, $01
	ld (_RAM_D5B5_), a
	xor a
	ld (_RAM_D946_), a
	ld a, (_RAM_DC54_IsGameGear)
	or a
	jr z, +
	ld a, $38
	out ($05), a
	call _LABEL_7564_SetControlsToNoButtons
	call _LABEL_AD7_
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

_LABEL_458_:
  JumpToPagedFunction _LABEL_36484_

++:
	JumpToPagedFunction _LABEL_2B5D5_

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
	ld hl, $DA60
	add hl, bc
	add hl, bc
	ex de, hl
	ld hl, $DAE0
	add hl, bc
	ld a, (iy+20)
	add a, $01
	cp $03
	jr nz, +
	xor a
+:
	ld (iy+20), a
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
	ld ix, _RAM_DA60_SpriteTableXNs+56*2
	ld iy, _RAM_DB18_
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
	ld ix, _RAM_DAD4_
	ld iy, _RAM_DB1A_
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
	ld ix, _RAM_DAD8_
	ld iy, _RAM_DB1C_
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
	ld ix, _RAM_DADC_
	ld iy, _RAM_DB1E_
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
    in a, ($05)
    in a, ($04)
    ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
	pop af
	retn

+:  in a, ($05)
    in a, ($04)
    ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
    ld a, (_RAM_DC3E_InMenus)
    or a
    jr nz, +
    in a, ($DC)
    and $3F
    ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
    ld a, $01
    ld (_RAM_D5D8_), a
+:pop af
	retn

; Data from 9EB to 9EC (2 bytes)
_DATA_9EB_ValueC000:
.dw $C000

; Data from 9ED to A2C (64 bytes)
_DATA_9ED_:
.db $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0
.db $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0 $00 $40 $80 $C0

; Data from A2D to A6C (64 bytes)
_DATA_A2D_:
.db $77 $77 $77 $77 $78 $78 $78 $78 $79 $79 $79 $79 $7A $7A $7A $7A
.db $7B $7B $7B $7B $7C $7C $7C $7C $7D $7D $7D $7D $7E $7E $7E $7E
.db $77 $77 $77 $77 $78 $78 $78 $78 $79 $79 $79 $79 $7A $7A $7A $7A
.db $7B $7B $7B $7B $7C $7C $7C $7C $7D $7D $7D $7D $7E $7E $7E $7E

; Data from A6D to A75 (9 bytes)
_DATA_A6D_:
.db $14 $10 $10 $10 $10 $18 $18 $18 $18

; Data from A76 to A7E (9 bytes)
_DATA_A76_:
.db $08 $10 $18 $20 $28 $10 $18 $20 $28

; Data from A7F to A87 (9 bytes)
_DATA_A7F_:
.db $3C $38 $38 $38 $38 $40 $40 $40 $40

; Data from A88 to A90 (9 bytes)
_DATA_A88_:
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

_LABEL_AD7_:
	JrToPagedFunction _LABEL_1BCCB_

_LABEL_AE1_:
	JrToPagedFunction _LABEL_1F8D8_

_LABEL_AEB_:
	JrToPagedFunction _LABEL_1BAB3_

_LABEL_AF5_:
	ld a, :_LABEL_1BAFD_ ; $06
	ld ($8000), a
	call _LABEL_1BAFD_
_LABEL_AFD_RestorePaging_fromDE8E:
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld ix, _RAM_DAF3_
	ld de, _RAM_DA60_SpriteTableXNs+19*2
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
	ld de, _RAM_DA60_SpriteTableXNs+19*2
	ld iy, _RAM_DAF3_
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
	out ($BF), a
	ld a, h
	out ($BF), a
	ld hl, _RAM_DC59_FloorTiles
	ld b, $40 ; 2 tiles
	ld c, $BE
	otir
; Executed in RAM at daaa (?)
_LABEL_BDD_:
	ld hl, _RAM_DC59_FloorTiles + $20
	ld b, $20 ; The the same 2 tiles in the opposite order
	ld c, $BE
	otir
	ld hl, _RAM_DC59_FloorTiles
	ld b, $20
	ld c, $BE
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
    ld a, (_RAM_DC97_)
    ld (_RAM_DE59_), a
    ld a, (_RAM_DC93_)
    ld (_RAM_DC97_), a
    ld a, (_RAM_DC8F_)
    ld (_RAM_DC93_), a
    ld a, (_RAM_DC8B_)
    ld (_RAM_DC8F_), a
    ld a, (_RAM_DC87_)
    ld (_RAM_DC8B_), a
    ld a, (_RAM_DC83_)
    ld (_RAM_DC87_), a
    ld a, (_RAM_DC7F_)
    ld (_RAM_DC83_), a
    ld a, (_RAM_DC7B_)
    ld (_RAM_DC7F_), a
    ld a, (_RAM_DC77_)
    ld (_RAM_DC7B_), a
    ld a, (_RAM_DC73_)
    ld (_RAM_DC77_), a
    ld a, (_RAM_DC6F_)
    ld (_RAM_DC73_), a
    ld a, (_RAM_DC6B_)
    ld (_RAM_DC6F_), a
    ld a, (_RAM_DC67_)
    ld (_RAM_DC6B_), a
    ld a, (_RAM_DC63_)
    ld (_RAM_DC67_), a
    ld a, (_RAM_DC5F_)
    ld (_RAM_DC63_), a
    ld a, (_RAM_DC5B_)
    ld (_RAM_DC5F_), a
    ld a, (_RAM_DE59_)
    ld (_RAM_DC5B_), a
	pop hl
	ret

_LABEL_D67_MoveFloorTilesUp:
    ld a, (_RAM_DC5B_)
    ld (_RAM_DE59_), a
    ld a, (_RAM_DC5F_)
    ld (_RAM_DC5B_), a
    ld a, (_RAM_DC63_)
    ld (_RAM_DC5F_), a
    ld a, (_RAM_DC67_)
    ld (_RAM_DC63_), a
    ld a, (_RAM_DC6B_)
    ld (_RAM_DC67_), a
    ld a, (_RAM_DC6F_)
    ld (_RAM_DC6B_), a
    ld a, (_RAM_DC73_)
    ld (_RAM_DC6F_), a
    ld a, (_RAM_DC77_)
    ld (_RAM_DC73_), a
    ld a, (_RAM_DC7B_)
    ld (_RAM_DC77_), a
    ld a, (_RAM_DC7F_)
    ld (_RAM_DC7B_), a
    ld a, (_RAM_DC83_)
    ld (_RAM_DC7F_), a
    ld a, (_RAM_DC87_)
    ld (_RAM_DC83_), a
    ld a, (_RAM_DC8B_)
    ld (_RAM_DC87_), a
    ld a, (_RAM_DC8F_)
    ld (_RAM_DC8B_), a
    ld a, (_RAM_DC93_)
    ld (_RAM_DC8F_), a
    ld a, (_RAM_DC97_)
    ld (_RAM_DC93_), a
    ld a, (_RAM_DE59_)
    ld (_RAM_DC97_), a
	pop hl
	ret

_LABEL_DCF_MoveFloorTilesHorizontally:
	push hl
    ld a, l
    cp $80
    jp z, _LABEL_E3C_MoveFloorTilesRight
    ; Move them left
    ld ix, _RAM_DC59_FloorTiles
    ld a, (_RAM_DC5B_)
    rla
    rl (ix+34)
    rl (ix+2)
    ld a, (_RAM_DC5F_)
    rla
    rl (ix+38)
    rl (ix+6)
    ld a, (_RAM_DC63_)
    rla
    rl (ix+42)
    rl (ix+10)
    ld a, (_RAM_DC67_)
    rla
    rl (ix+46)
    rl (ix+14)
    ld a, (_RAM_DC6B_)
    rla
    rl (ix+50)
    rl (ix+18)
    ld a, (_RAM_DC6F_)
    rla
    rl (ix+54)
    rl (ix+22)
    ld a, (_RAM_DC73_)
    rla
    rl (ix+58)
    rl (ix+26)
    ld a, (_RAM_DC77_)
    rla
    rl (ix+62)
    rl (ix+30)
	pop hl
	ret

_LABEL_E3C_MoveFloorTilesRight:
    ld ix, _RAM_DC59_FloorTiles
    ld a, (_RAM_DC7B_)
    rra
    rr (ix+2)
    rr (ix+34)
    ld a, (_RAM_DC7F_)
    rra
    rr (ix+6)
    rr (ix+38)
    ld a, (_RAM_DC83_)
    rra
    rr (ix+10)
    rr (ix+42)
    ld a, (_RAM_DC87_)
    rra
    rr (ix+14)
    rr (ix+46)
    ld a, (_RAM_DC8B_)
    rra
    rr (ix+18)
    rr (ix+50)
    ld a, (_RAM_DC8F_)
    rra
    rr (ix+22)
    rr (ix+54)
    ld a, (_RAM_DC93_)
    rra
    rr (ix+26)
    rr (ix+58)
    ld a, (_RAM_DC97_)
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
	ld (_RAM_DEB1_), a
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
	ld a, (_RAM_DC3F_)
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
	ld hl, $DEAF
	jp ++

+:
	ld a, $01
	ld (_RAM_DEB0_), a
	ld hl, $DEAF
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
	ld (_RAM_DEB1_), a
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
	ld hl, $DEB1
	ret

+:
	ld a, $01
	ld (_RAM_DEB2_), a
	ld hl, $DEB1
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
	ld hl, _RAM_DB86_ ; Else look something up
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
	jp ++

; Data from 12B9 to 12B9 (1 bytes)
.db $C9 ; ret

+:
	xor a
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
	ld hl, _DATA_4000_TileIndexPointerLow
	ld a, (_RAM_DEBC_)
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld e, (hl)
	ld hl, _DATA_4041_TileIndexPointerHigh
	ld a, (_RAM_DEBC_)
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld d, (hl)
	ld a, (_RAM_DEC5_)
	ld l, a
_LABEL_12FE_:
	ld a, (_RAM_DEC1_)
	out ($BF), a
	ld a, (_RAM_DEC2_)
	out ($BF), a
	ld bc, (_RAM_DECF_)
-:
	ld a, (de)
	out ($BE), a
	push hl
	ld hl, $D800
	add a, l
	ld l, a
	ld a, (hl)
	pop hl
	out ($BE), a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
	dec l
	ld a, l
	cp $00
	jr z, +
	ld a, (_RAM_DEC1_)
	add a, $40
	ld (_RAM_DEC1_), a
	ld a, (_RAM_DEC2_)
	adc a, $00
	ld (_RAM_DEC2_), a
	push hl
	ld hl, _RAM_DECE_
	ld a, e
	add a, (hl)
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	pop hl
	jp _LABEL_12FE_

+:
	ret

_LABEL_1345_:
	ld a, (_RAM_DC54_IsGameGear)
	or a
	jp nz, _LABEL_14A8_
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
	ld (_RAM_DEBC_), a
	ld a, $00
	ld (_RAM_DEC1_), a
	ld a, $77
	ld (_RAM_DEC2_), a
	push hl
    call _LABEL_12E0_
	pop hl
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $18
	ld (_RAM_DEC1_), a
	ld a, $77
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	call _LABEL_64E5_
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $30
	ld (_RAM_DEC1_), a
	ld a, $77
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	ld de, (_RAM_DB9C_)
	ld hl, (_RAM_DED1_)
	add hl, de
	call _LABEL_1583_
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $00
	ld (_RAM_DEC1_), a
	ld a, $7A
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $18
	ld (_RAM_DEC1_), a
	ld a, $7A
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	call _LABEL_64E5_
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $30
	ld (_RAM_DEC1_), a
	ld a, $7A
	ld (_RAM_DEC2_), a
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
	ld (_RAM_DEBC_), a
	ld a, $00
	ld (_RAM_DEC1_), a
	ld a, $7D
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $18
	ld (_RAM_DEC1_), a
	ld a, $7D
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	call _LABEL_64E5_
	ld a, $04
	ld (_RAM_DEC5_), a
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $30
	ld (_RAM_DEC1_), a
	ld a, $7D
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	ret

_LABEL_14A8_:
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
	ld (_RAM_DEBC_), a
	ld a, $4A
	ld (_RAM_DEC1_), a
	ld a, $78
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	call _LABEL_64E5_
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $62
	ld (_RAM_DEC1_), a
	ld a, $78
	ld (_RAM_DEC2_), a
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
	ld (_RAM_DEBC_), a
	ld a, $4A
	ld (_RAM_DEC1_), a
	ld a, $7B
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	call _LABEL_64E5_
	ld a, $06
	ld (_RAM_DEC5_), a
	inc hl
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld a, $62
	ld (_RAM_DEC1_), a
	ld a, $7B
	ld (_RAM_DEC2_), a
	push hl
	call _LABEL_12E0_
	pop hl
	ret

_LABEL_1583_:
	ld a, $0C
	ld (_RAM_DECF_), a
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
-:
	ret

+:
	ld a, (_RAM_DEB2_)
	cp $01
	jr nz, -
	call _LABEL_3E24_
	ld a, (_RAM_DEB1_)
	ld (_RAM_DEF6_), a
	ld l, a
	ld a, (_RAM_DED4_VScrollValue)
	and $07
	add a, l
	cp $08
	jr z, +
	jr c, ++
+:
	ld a, (_RAM_DEB1_)
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
-:
	ret

+:
	ld a, (_RAM_DEB2_)
	or a
	jr nz, -
	call _LABEL_7C72_
	ld a, (_RAM_DEB1_)
	or $80
	ld (_RAM_DEF6_), a
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DED4_VScrollValue)
	and $07
	sub l
	jr nc, +
	call ++
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DED4_VScrollValue)
	sub l
	ld (_RAM_DED4_VScrollValue), a
	ret

+:
	ld a, (_RAM_DED4_VScrollValue)
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
	ld (_RAM_DEC1_), a
	ld a, h
	ld (_RAM_DEC2_), a
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

_DATA_1c82: ; unused?
.db $00 $4D $60 $4D $00 $4F $60 $4F 
.db $60 $51 $00 $53 $60 $53 $00 $5D 
.db $60 $5D $00 $5F $60 $5F

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
.db $00 $0E $44 $0E $88 $0E $EE $0E $00 $0E $44 $0E $88 $0E $EE $0E
_DATA_1D35_PowerboatsAnimatedPalette_GG:
.db $04 $08 $44 $08 $88 $0E $CC $0E $88 $0E $44 $08 $04 $08 $00 $04

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
	ld de, $C400
	add hl, de
	ld a, (hl)
	ld (_RAM_D587_), a
	ld hl, _DATA_254E_
	ld a, (_RAM_DE7D_)
	and $3F
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld c, a
	ld hl, _DATA_258F_
	add hl, de
	ld a, (hl)
	ld d, a
	ld e, c
	ld hl, $C800
	add hl, de
	ld b, h
	ld c, l
	ld hl, $2652
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
	ld de, $AA38
	add hl, de
	ld a, $05
	ld ($8000), a
	ld a, (hl)
	ld l, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
	xor a
	ld h, a
	add hl, bc
	ld a, (hl)
	ld (_RAM_DE6F_), a
	ld a, (_RAM_DE6B_)
	ld l, a
	ld a, (_RAM_DE6C_)
	ld h, a
	ld de, $A9A8
	add hl, de
	ld a, $05
	ld ($8000), a
	ld a, (hl)
	ld b, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld a, $0D
	ld ($8000), a
	ld hl, _DATA_37232_
	ld d, $00
	ld a, (_RAM_DE7D_)
	and $3F
	ld e, a
	add hl, de
	ld a, (hl)
	ld l, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld hl, $03E8
	ld (_RAM_D95B_), hl
	call _LABEL_28AC_
	xor a
	ld (_RAM_DEAF_), a
	ld (_RAM_DEB1_), a
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
	ld hl, $CC80
	add hl, de
	ld b, h
	ld c, l
	ld a, (_RAM_DE6B_)
	ld l, a
	ld a, (_RAM_DE6C_)
	ld h, a
	ld a, $06
	ld ($8000), a
	ld de, _DATA_1B1A2_
	add hl, de
	ld a, (hl)
	ld l, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld (_RAM_DEB1_), a
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
	ld hl, $B232
	ld e, a
	add hl, de
	ld a, $06
	ld ($8000), a
	ld a, (hl)
	ld b, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld hl, $D900
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

; Data from 254E to 258E (65 bytes)
_DATA_254E_:
.db $00 $12 $24 $36 $48 $5A $6C $7E $90 $A2 $B4 $C6 $D8 $EA $FC $0E
.db $20 $32 $44 $56 $68 $7A $8C $9E $B0 $C2 $D4 $E6 $F8 $0A $1C $2E
.db $40 $52 $64 $76 $88 $9A $AC $BE $D0 $E2 $F4 $06 $18 $2A $3C $4E
.db $60 $72 $84 $96 $A8 $BA $CC $DE $F0 $02 $14 $26 $38 $4A $5C $6E
.db $80

; Data from 258F to 25CF (65 bytes)
_DATA_258F_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01
.db $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $01 $02 $02 $02
.db $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $02 $03 $03 $03 $03 $03
.db $03 $03 $03 $03 $03 $03 $03 $03 $03 $04 $04 $04 $04 $04 $04 $04
.db $04

; Data from 25D0 to 2610 (65 bytes)
_DATA_25D0_:
.db $00 $24 $48 $6C $90 $B4 $D8 $FC $20 $44 $68 $8C $B0 $D4 $F8 $1C
.db $40 $64 $88 $AC $D0 $F4 $18 $3C $60 $84 $A8 $CC $F0 $14 $38 $5C
.db $80 $A4 $C8 $EC $10 $34 $58 $7C $A0 $C4 $E8 $0C $30 $54 $78 $9C
.db $C0 $E4 $08 $2C $50 $74 $98 $BC $E0 $04 $28 $4C $70 $94 $B8 $DC
.db $00

; Data from 2611 to 261F (15 bytes)
_DATA_2611_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $01 $01 $01 $01 $01 $01 $01

_LABEL_2620_:
	ld (bc), a
	ld (bc), a
	ld (bc), a
	ld (bc), a
	ld (bc), a
	ld (bc), a
	ld (bc), a
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc b
	inc b
	inc b
	inc b
	inc b
	inc b
	inc b
	dec b
	dec b
	dec b
	dec b
	dec b
	dec b
	dec b
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $07
	rlca
	rlca
	rlca
	rlca
	rlca
	rlca
	ex af, af'
	ex af, af'
	ex af, af'
	ex af, af'
	ex af, af'
	ex af, af'
	ex af, af'
	add hl, bc
	nop
	inc c
	jr +

; Data from 2656 to 265D (8 bytes)
.db $30 $3C $48 $54 $60 $6C $78 $84

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
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	cp l
	jr nc, +
	ld l, a
	ld a, (_RAM_DEB1_)
	sub l
	ld (_RAM_DEB1_), a
	ret

+:
	sub l
	ld (_RAM_DEB1_), a
	ld a, (_RAM_DF0E_)
	ld (_RAM_DEB2_), a
	ret

++:
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	add a, l
	cp $07
	jr nc, +
	ld (_RAM_DEB1_), a
	ret

+:
	ld a, $07
	ld (_RAM_DEB1_), a
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
	ld hl, _RAM_DEB1_
	ld a, (_RAM_DBA7_)
	sub (hl)
	ld (_RAM_DBA7_), a
	jp _LABEL_27FB_

+:
	ld hl, _RAM_DEB1_
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
	ld a, (_RAM_DEB1_)
	add a, l
	ld l, a
	and $01
	jr z, +
	ld a, $01
	ld (_RAM_DB81_), a
-:
	ld a, l
	srl a
	ld (_RAM_DEB1_), a
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
	ld hl, $03E8
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
	ld (_RAM_DEB1_), a
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
	ld (_RAM_DEB1_), a
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
	ld hl, $03E8
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
	ld a, $26
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld a, (hl)
	out ($BE), a
	inc hl
	ld a, (hl)
	out ($BE), a
	call _LABEL_3F36_ScreenOn
+:
	ret

; Data from 2D36 to 2D3F (10 bytes)
_DATA_2D36_RuffTruxSubmergedPaletteSequence_GG:
.dw $0000 
.dw $0800 
.dw $0840 
.dw $0E80 
.dw $0000

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
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld a, (hl) ; Set colour
	out ($BE), a
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
.db $00 $20 $24 $38 $00 ; Colours lookup
; #000000 ; black
; #0000ff ; dark blue
; #0055aa ; middle blue
; #00aaff ; light blue
; #000000 ; black

; Data from 2FBC to 2FDB (32 bytes)
_DATA_2FBC_:
.db $52 $A6 $B6 $9E ; 4 bytes per track tyoe
.db $62 $24 $85 $00 
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
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FE $EF
.db $F9 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $00 $10 $00 $10 $00

; Data from 313B to 3163 (41 bytes)
_DATA_313B_:
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
	out ($BF), a ; Set VRAM address
	ld a, (_RAM_DF18_FloorTilesVRAMAddress+1)
	out ($BF), a
	ld bc, $0080 ; 32*4 bytes
-:
	ld a, $00    ; Blank it out
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
+:
	ret

_LABEL_31F1_UpdateSpriteTable:
  ; Sprite table Y
	ld a, $00
	out ($BF), a
	ld a, $7F
	out ($BF), a
	ld hl, _RAM_DAE0_SpriteTableYs
	ld b, 64
	ld c, $BE
	otir
  ; Sprite table XN
	ld a, $80
	out ($BF), a
	ld a, $7F
	out ($BF), a
	ld hl, _RAM_DA60_SpriteTableXNs
	ld b, 64*2
	ld c, $BE
	otir
	ret

_LABEL_3214_BlankSpriteTable:
	ld hl, _RAM_DAE0_SpriteTableYs
	ld bc, 64
-:xor a
	ld (hl), a
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, -
	ld hl, _RAM_DA60_SpriteTableXNs
	ld bc, 64*2
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
	out ($BF), a
	ld a, $72
	out ($BF), a
	ld bc, $0080
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
+:
	ret

_LABEL_324C_UpdatePerFrameTiles:
  ; Updates all the tiles which are written into every frame
	ld c, $BE
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
	out ($BF), a
	ld a, $72
	out ($BF), a
	outi
	ld a, $04 ; every 4 bytes -> 1 bitplane
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
	call _LABEL_336A_UpdateBlueCarDecorator
	ld a, (_RAM_DC3D_IsHeadToHead)
	cp $01
	jr z, +
  ; Tournament
	call _LABEL_3302_UpdateGreenCarDecorator
	jp _LABEL_33D2_UpdateYellowCarDecorator ; and ret

+:; Head to head
	ld a, $C0 ; Tile $1a6
	out ($BF), a
	ld a, $74
	out ($BF), a
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
	ld a, :_DATA_30C68_LapRemainingIndicators ; $0C
	ld ($8000), a
	ld hl, _DATA_30C68_LapRemainingIndicators
	add hl, de
	ld b, $20
	ld c, $BE
	otir ; Emit
--:
	jp _LABEL_AFD_RestorePaging_fromDE8E

+:
	ld b, $20 ; Emit a blank tile
	xor a
-:out ($BE), a
	dec b
	jr nz, -
	jp --

_LABEL_3302_UpdateGreenCarDecorator:
	ld c, $BE
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

_LABEL_336A_UpdateBlueCarDecorator:
	ld c, $BE
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

_LABEL_33D2_UpdateYellowCarDecorator:
	ld c, $BE
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
	ld hl, $DE4B
	ld d, $00
	ld c, $00
	ld a, (_RAM_DE44_)
	ld e, a
	ld c, a
	add hl, de
	inc (hl)
	ld hl, $DE4B
	ld a, (_RAM_DE45_)
	ld e, a
	add a, c
	ld c, a
	add hl, de
	inc (hl)
	ld hl, $DE4B
	ld a, (_RAM_DE46_)
	ld e, a
	add a, c
	ld c, a
	add hl, de
	inc (hl)
	ld hl, $DE4B
	ld a, (_RAM_DE47_)
	ld e, a
	add a, c
	ld c, a
	add hl, de
	inc (hl)
	ld hl, $DE4B
	ld a, (_RAM_DE48_)
	ld e, a
	add a, c
	ld c, a
	add hl, de
	inc (hl)
	ld hl, $DE4B
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
	ld ix, _RAM_DA60_SpriteTableXNs+18
	ld iy, _RAM_DAE9_
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
	ld ix, _RAM_DA60_SpriteTableXNs+19*2
	ld iy, _RAM_DAF3_
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
	ld ix, _RAM_DA60_SpriteTableXNs+58
	ld iy, _RAM_DAFD_
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
	ld ix, _RAM_DA60_SpriteTableXNs+78
	ld iy, _RAM_DB07_
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
	ld hl, _DATA_3E04_
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
	ld hl, $DA00
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
	ld hl, $DA10
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
	ld (_RAM_DA60_SpriteTableXNs+97), a
	ld (_RAM_DA60_SpriteTableXNs+105), a
	ld a, $A9
	ld (_RAM_DA60_SpriteTableXNs+99), a
	ld (_RAM_DA60_SpriteTableXNs+107), a
	ld a, $AA
	ld (_RAM_DA60_SpriteTableXNs+101), a
	ld (_RAM_DA60_SpriteTableXNs+109), a
	ld a, $AB
	ld (_RAM_DA60_SpriteTableXNs+103), a
	ld (_RAM_DA60_SpriteTableXNs+111), a
	ret

+:
	ld a, $0B
	ld (_RAM_DA60_SpriteTableXNs+97), a
	ld a, $18
	ld (_RAM_DA60_SpriteTableXNs+99), a
	ld a, $1B
	ld (_RAM_DA60_SpriteTableXNs+101), a
	ld a, $88
	ld (_RAM_DA60_SpriteTableXNs+103), a
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
	ld hl, $9C2D
	ld d, $00
	ld e, a
	add hl, de
	ld c, $11
	ld a, $0D
	ld ($8000), a
-:
	ld a, (hl)
	ld (ix+1), a
	inc ix
	inc ix
	inc hl
	dec c
	jr nz, -
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld c, $09
	ld a, (_RAM_DC54_IsGameGear)
	or a
	jr z, +
	ld hl, _DATA_A7F_
	jp ++

+:
	ld hl, _DATA_A6D_
++:
	ld de, _RAM_DF2E_
-:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
	dec c
	jr nz, -
	ld c, $09
	ld a, (_RAM_DC54_IsGameGear)
	or a
	jr z, +
	ld hl, _DATA_A88_
	jp ++

+:
	ld hl, _DATA_A76_
++:
	ld de, _RAM_DF40_
-:
	ld a, (hl)
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
.db $0F $0E $0F $0E $0D $0E $0E $0F $0D

_LABEL_3DD1_:
	JumpToPagedFunction _LABEL_3636E_

; Data from 3DDC to 3DE3 (8 bytes)
_DATA_3DDC_TrackTypeTileDataPointerLo:
.db $00 $83 $01 $00 $00 $FA $68 $8D

; Data from 3DE4 to 3DEB (8 bytes)
_DATA_3DE4_TrackTypeTileDataPointerHi:
.db $80 $9C $99 $80 $80 $A8 $91 $8D

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
.db $00 $03 $06 $09 $0C $0F $12 $15 $48 $4B $4E $51 $54 $57 $5A $5D
.db $00 $04 $08 $0C $10 $14 $18 $1C $80 $84 $88 $8C $90 $94 $98 $9C

_LABEL_3E24_:
	JumpToPagedFunction _LABEL_37817_

_LABEL_3E2F_:
	JumpToPagedFunction _LABEL_37946_

; Data from 3E3A to 3E42 (9 bytes)
_DATA_3E3A_TrackTypeDataPageNumbers:
.db $03 $04 $05 $06 $07 $08 $09 $0A $0B

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
_DATA_3EEC_:
.db $58 $F0 $48 $50 $00 $30 $D0 $6A     ; Pointer low bytes

; Data from 3EF4 to 3EFC (9 bytes)
_DATA_3EF4_:
.db $0D $0D $0D $0D $0C $0C $0C $04 $0C ; Page numbers per track type

; Data from 3EFD to 3F04 (8 bytes)
_DATA_3EFD_:
.db $89 $8C $90 $93 $80 $83 $86 $A9     ; Pointer high bytes

; Rearranged:
; $0D $0D $0D $0D $0C $0C $0C $04 $0C Page
; $89 $8C $90 $93 $80 $83 $86 $A9     High
; $58 $F0 $48 $50 $00 $30 $D0 $6A     Low
; ->
; $0d, $8958 = $34958
; $0d, $8cf0
; etc

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
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_3F2B_:
	JumpToPagedFunction _LABEL_23B98_

_LABEL_3F36_ScreenOn:
	ld a, $70
	out ($BF), a
	ld a, $81
	out ($BF), a
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
	ld hl, $DCAB
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
.db 0 ; page index

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
.db $08 $0B $0D $0E $0F $0E $0D $0B $08 $05 $03 $02 $02 $02 $03 $05 $02 $03 $04 $05 $08 $0B $0C $0D $0F $0D $0C $0B $08 $05 $04 $03
.db $09 $0A $0A $0B $0C $0B $0A $0A $09 $08 $07 $06 $05 $06 $07 $08 $05 $06 $06 $06 $09 $0B $0B $0B $0C $0B $0B $0B $09 $06 $06 $06
.db $09 $0B $0C $0D $0D $0D $0C $0B $09 $07 $05 $04 $04 $04 $05 $07 $04 $04 $06 $08 $09 $0A $0B $0C $0D $0C $0B $0A $09 $08 $06 $04
.db $09 $0B $0B $0C $0D $0C $0B $0B $09 $07 $05 $04 $03 $04 $05 $07 $03 $03 $05 $07 $09 $0A $0B $0D $0D $0D $0B $0A $09 $07 $05 $03
.db $08 $05 $04 $03 $04 $03 $04 $05 $08 $0B $0C $0D $0C $0D $0C $0B $0C $0D $0C $0B $08 $05 $04 $03 $04 $03 $04 $05 $08 $0B $0C $0D
.db $09 $0A $0A $0B $0C $0B $0A $0A $09 $07 $06 $05 $05 $05 $06 $07 $05 $05 $06 $07 $08 $09 $0A $0B $0C $0B $0A $09 $08 $07 $06 $05
.db $09 $08 $09 $07 $08 $07 $09 $09 $09 $09 $09 $0B $0A $0B $09 $0A $0A $0A $0A $0A $09 $08 $08 $08 $08 $08 $08 $08 $09 $0A $0A $0A
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $03 $05 $06 $06 $07 $06 $06 $05 $03 $02 $01 $01 $00 $01 $01 $02 $05 $06 $06 $07 $08 $0A $0B $0B $0C $0B $0B $0A $08 $07 $06 $06

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
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF83_)
	cp l
	jr nc, +
	ld l, a
	ld a, (_RAM_DEB1_)
	sub l
	ld (_RAM_DEB1_), a
	jp +++

; Data from 4562 to 4562 (1 bytes)
.db $C9 ; ret

+:
	sub l
	ld (_RAM_DEB1_), a
	ld a, (_RAM_DF85_)
	ld (_RAM_DEB2_), a
	jp +++

; Data from 4570 to 4570 (1 bytes)
.db $C9 ; ret

++:
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF83_)
	add a, l
	cp $07
	jr nc, +
	ld (_RAM_DEB1_), a
	jp +++

; Data from 4583 to 4583 (1 bytes)
.db $C9 ; ret

+:
	ld a, $07
	ld (_RAM_DEB1_), a
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
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF83_)
	cp l
	jr nc, +
	ld l, a
	ld a, (_RAM_DEB1_)
	sub l
	ld (_RAM_DEB1_), a
	ret

+:
	sub l
	ld (_RAM_DEB1_), a
	ld a, (_RAM_DF85_)
	ld (_RAM_DEB2_), a
	ret

++:
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF83_)
	add a, l
	cp $07
	jr nc, +
	ld (_RAM_DEB1_), a
	ret

+:
	ld a, $07
	ld (_RAM_DEB1_), a
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
	ld hl, $2652
	ld de, (_RAM_DE77_)
	add hl, de
	ld a, (hl)
	ld l, a
	ld h, $00
	ld de, (_RAM_DE75_)
	add hl, de
	add hl, bc
	ld a, $0D
	ld ($8000), a
	ld a, (hl)
	ld b, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld hl, $2652
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
	ld ($8000), a
	ld a, (hl)
	ld b, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld a, $08
	ld ($8000), a
	call _LABEL_23BF1_
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld hl, $03E8
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
	ld (_RAM_DEB1_), a
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
	ld (_RAM_DEBC_), a
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

_LABEL_5169_:
	JumpToPagedFunction _LABEL_37292_

_LABEL_5174_:
	JumpToPagedFunction _LABEL_3730C_

_LABEL_517F_NMI_SMS:
    ld a, (_RAM_D599_IsPaused)
    xor $01
    ld (_RAM_D599_IsPaused), a
    or a
    jr z, +
    ; If we became paused, silence the PSG
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
	ld a, (_RAM_DC3F_)
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
	ld (_RAM_DEB1_), a
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
	ld a, (_RAM_DC3F_)
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
	ld a, (_RAM_DC3F_)
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
	ld a, (_RAM_DC3F_)
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
	ld de, $C400
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
	ld hl, _DATA_254E_
	ld a, (ix+10)
	and $3F
	ld e, a
	ld d, $00
	add hl, de
	ld c, (hl)
	ld hl, _DATA_258F_
	add hl, de
	ld d, (hl)
	ld e, c
	ld hl, $C800
	add hl, de
	ld b, h
	ld c, l
	ld hl, $2652
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
	ld de, $AA38
	add hl, de
	ld a, $05
	ld ($8000), a
	ld l, (hl)
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
	ld h, $00
	add hl, bc
	ld a, (hl)
	ld (_RAM_DE70_), a
	ld a, (_RAM_DE6D_)
	ld l, a
	ld a, (_RAM_DE6E_)
	ld h, a
	ld de, $A9A8
	add hl, de
	ld a, $05
	ld ($8000), a
	ld b, (hl)
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld a, $0D
	ld ($8000), a
	ld hl, _DATA_37232_
	ld d, $00
	ld a, (_RAM_DCF6_)
	and $3F
	ld e, a
	add hl, de
	ld a, (hl)
	ld l, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld hl, $03E8
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
	ld hl, $CC80
	add hl, de
	ld b, h
	ld c, l
	ld a, (_RAM_DE6D_)
	ld l, a
	ld a, (_RAM_DE6E_)
	ld h, a
	ld a, $06
	ld ($8000), a
	ld de, _DATA_1B1A2_
	add hl, de
	ld a, (hl)
	ld l, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld hl, $D900
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
	ld a, (_RAM_DC3F_)
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
	ld a, (_RAM_DC3F_)
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
	ld hl, $03E8
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
	ld hl, $B232
	ld e, a
	add hl, de
	ld a, $06
	ld ($8000), a
	ld a, (hl)
	ld b, a
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
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
	ld (_RAM_DECF_), a
	ld a, $04
	ld (_RAM_DECE_), a
	ld a, $0C
	ld (_RAM_DEC5_), a
	ret

+:
	ld a, $09
	ld (_RAM_DECF_), a
	ld a, $03
	ld (_RAM_DECE_), a
	ld a, $0C
	ld (_RAM_DEC5_), a
	ret

; Data from 650C to 653F (52 bytes)
_DATA_650C_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $E8
.db $03 $03 $0A $00 $15 $0B $15 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $E8 $03 $03 $00 $00 $15 $0B $15 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $FF $07 $08

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
	ld hl, $03E8
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

+:ld a, $0D     ; page 13
	ld ($8000), a
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
	out ($BF), a
	ld a, d
	out ($BF), a
	ld a, (hl)      ; Copy a byte
	out ($BE), a
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

_LABEL_6704_:
	ld a, (_RAM_DB97_TrackType)
	cp TT_RuffTrux
	jr z, _LABEL_6755_ret
  ; Normal cars
	ld a, (_RAM_DC3D_IsHeadToHead)
	or a
	jr z, +
	ld a, $0D
	ld ($8000), a
	ld a, $80
	out ($BF), a
	ld a, $72
	out ($BF), a
	ld bc, $00A0
	ld hl, _DATA_35D2D_
-:
	push bc
	ld b, $03
	ld c, $BE
	otir
	xor a
	out ($BE), a
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

+:
	ld a, $0C
	ld ($8000), a
	ld a, $80
	out ($BF), a
	ld a, $72
	out ($BF), a
	ld bc, $00A0
	ld hl, _DATA_30A68_
-:
	push bc
	ld b, $04
	ld c, $BE
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
	ld (_RAM_DEB1_), a
	jp ++++++

+++++:
	xor a
	ld (_RAM_DEBA_), a
	ld (_RAM_DEB1_), a
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
	ld hl, $03E8
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
	ld (_RAM_DEB1_), a
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
	ld hl, $03E8
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
	ld a, (_RAM_DC3F_)
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
	ld hl, $D900
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
	ld hl, $D900
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
	ld hl, $D900
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
	ld hl, $D900
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
	ld hl, $DF38
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
	ld hl, $DF38
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
	ld hl, $DF38
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
	ld hl, $DF38
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
	ld hl, $D900
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
	ld hl, $D900
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
	ld hl, $DF2E
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
; Executed in RAM at da67
_LABEL_7465_:
	ld a, $E8
	ld (ix+7), a
	ret

_LABEL_746B_RuffTrux_UpdatePerFrameTiles:
	JumpToPagedFunction _LABEL_36D52_RuffTrux_UpdateTimer

_LABEL_7476_:
	di
	CallPagedFunction2 _LABEL_2B5D5_
	call _LABEL_7564_SetControlsToNoButtons
	ld a, (_RAM_DC3B_)
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
	ld a, (_RAM_DC3F_)
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
	xor a
	out ($05), a
+:
	ld a, $20
	out ($BF), a
	ld a, $C0
	out ($BF), a
	xor a
	out ($BE), a
	out ($BE), a
	call _LABEL_7A9F_
	call _LABEL_156_
	call _LABEL_3214_BlankSpriteTable
	call _LABEL_31F1_UpdateSpriteTable
	ld a, (_RAM_DC4B_Cheat_InfiniteLives)
	or a
	jr z, +
	ld a, $05
	ld (_RAM_DC09_Lives), a
+:
	ld a, (_RAM_DC3F_)
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
  ; Page 8
	ld a, $08
	ld ($8000), a
	ld a, (_RAM_DC54_IsGameGear)
	cp $00
	jr z, +
	ld hl, _DATA_23ECF_
	jr ++
+:ld hl, _DATA_23DE7_
++:ld a, e ; The course index
	sla a ; x8
	sla a
	sla a
	and $F8 ; Zero low bits
	ld e, a
	ld d, $00
	add hl, de ; -> hl
	ld de, _RAM_DB86_
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
	ld ($8000), a
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
	ld c, $BE
	exx
	ld hl, (_RAM_DEC3_)
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
	ld hl, (_RAM_DEC1_)
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
	ld (_RAM_DEC1_), hl
	exx
	ret

_LABEL_795E_:
	ld hl, (_RAM_DED1_)
	ld a, (hl)
	call _LABEL_9B2_ConvertMetatileIndexToDataIndex
	ld (_RAM_DEBC_), a
	ld hl, _DATA_4000_TileIndexPointerLow
	ld a, (_RAM_DEBC_)
	add a, l
	ld l, a
	xor a
	adc a, h
	ld h, a
	ld e, (hl)
	ld hl, _DATA_4041_TileIndexPointerHigh
	ld a, (_RAM_DEBC_)
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
+:
	ld a, (_RAM_DEC7_)
	neg
	add a, $0C
	ld b, a
	ld a, (_RAM_DECC_)
-:
	exx
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
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	srl l
	ld h, $00
	ld de, $9B8D
	add hl, de
	ld a, $0D
	ld ($8000), a
	ld a, (hl)
	ld (_RAM_DF22_), a
	sla a
	ld l, a
	ld h, $00
	ld de, _DATA_35BED_
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
	ld hl, (_RAM_DF20_)
	or a
	sbc hl, de
	ld a, l
	ld (_RAM_DF21_), a
	ld a, (_RAM_DF22_)
	ld (_RAM_DF20_), a
	ret

_LABEL_7A9F_:
	out ($BF), a
	ld a, $87
	out ($BF), a
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
	ld (_RAM_D5CC_), a
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
; Seems to be relocatable, but isn't relocated?
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
	ld a, (_RAM_DB97_TrackType)
	cp TT_Powerboats
	jr z, +++
	cp TT_FormulaOne
	jr nz, +
	ld de, $3116
	jp ++++

+:
	cp TT_RuffTrux
	jr nz, +
	ld a, $01
	ld (_RAM_DF1D_), a
	jp ++

+:
	xor a
	ld (_RAM_DF1D_), a
++:
	ld hl, _RAM_D800_
	ld bc, $0100
-:
	ld a, (_RAM_DF1D_)
	ld (hl), a
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, -
	jp +++++

+++:
	ld de, _DATA_313B_
++++:
	ld hl, $0020
	add hl, de
	ld b, h
	ld c, l
	ld a, c
	ld (_RAM_DF15_), a
	ld a, b
	ld (_RAM_DF16_), a
	ld hl, _RAM_D800_
	call _LABEL_7EBE_DecompressRunCompressed
+++++:
	ld hl, _DATA_3DC8_TrackTypeTileDataPages
	ld a, (_RAM_DB97_TrackType)
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, (hl)
	ld ($8000), a
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
	ld hl, _RAM_C000_DecompressionTemporaryBuffer
	ex de, hl
	call _LABEL_7B21_Decompress
	call _LABEL_7F02_Copy3bppTileDataToVRAM
	call _LABEL_663D_InitialisePlugholeTiles
	ld hl, _DATA_3EF4_
	ld a, (_RAM_DB97_TrackType) ; Index into table
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, (hl)
	ld ($8000), a               ; Set page
  
	ld a, (_RAM_DB97_TrackType) ; Index into next table
	ld hl, _DATA_3EFD_
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, (hl)
	ld d, a                   ; -> d
	ld a, (_RAM_DB97_TrackType) ; One more time
	ld hl, _DATA_3EEC_
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
	ld (_RAM_DF15_), a          ; then to RAM
	ld a, b
	ld (_RAM_DF16_), a
	ld hl, _RAM_C000_DecompressionTemporaryBuffer
	call _LABEL_7EBE_DecompressRunCompressed
	call _LABEL_7F4E_CarAndShadowSpriteTilesToVRAM
	call _LABEL_6704_

  ; Look up the page number and page it in
	ld hl, _DATA_3E3A_TrackTypeDataPageNumbers
	ld a, (_RAM_DB97_TrackType)
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, (hl)
	ld ($8000), a
	ld (_RAM_DE8E_PageNumber), a ; And make that the "page to keep there"

	ld hl, $8000 ; Read data from that page. First word points to compressed behaviour data.
	ld a, (hl)
	ld e, a
	inc hl
	ld a, (hl)
	ld d, a
	ld hl, _RAM_CC80_BehaviourData - 4
	ex de, hl
	call _LABEL_7B21_Decompress ; Decompress data there

	ld hl, $8002 ; Next pointer for "wall" data
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
	ld hl, _RAM_CC38_ ; Metatile $3c
	ld bc, $0012 ; Size of a metatile
-:
	ld a, $FF
	ld (hl), a ; Set all wall bits -> make it all solid
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, -
+:

	ld a, (_RAM_DB96_TrackIndexForThisType)
	add a, $02
	or a
	rl a
	ld l, a
	ld a, $80
	ld h, a
	ld a, (hl)
	ld e, a
	inc hl
	ld a, (hl)
	ld d, a
	ld hl, _RAM_C000_DecompressionTemporaryBuffer
	ex de, hl
	call _LABEL_7B21_Decompress
	ld a, (_RAM_DC54_IsGameGear)
	cp $00
	jr z, +
	ld de, $800C
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	ld a, $00
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld b, $40
	ld c, $BE
	otir
	jp ++

+:
	ld a, $05
	ld ($8000), a
	ld a, (_RAM_DB97_TrackType)
	sla a
	ld d, $00
	ld e, a
	ld hl, _DATA_17EC2_
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld a, $00
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld b, $20
	ld c, $BE
	otir
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
++:
	CallPagedFunction _LABEL_1BEB1_ChangePoolTableColour
  ; Load "decorator" 1bpp tile data to RAM buffer
	ld hl, $800E ; Pointer here in each car's bank
	ld a, (hl)
	ld e, a
	inc hl
	ld a, (hl)
	ld d, a
  ; Copy to RAM
	ld bc, $0080
	ld hl, _RAM_D980_CarDecoratorTileData1bpp
-:ld a, (de)
	ld (hl), a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
  
	ld hl, $8010
	ld a, (hl)
	ld e, a
	inc hl
	ld a, (hl)
	ld d, a
	ld bc, $0040
	ld hl, _RAM_D900_
-:
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -
	ld hl, $8012
	ld a, (hl)
	ld e, a
	inc hl
	ld a, (hl)
	ld h, a
	ld l, e
	ld a, (_RAM_DB97_TrackType)
	cp TT_RuffTrux
	jr z, +
	ld a, $A0
	out ($BF), a
	ld a, $75
	out ($BF), a
	ld bc, $0058
-:
	push bc
	ld b, $03
	ld c, $BE
	otir
	ld a, $00
	out ($BE), a
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
	ld hl, $1C82
	add hl, de
	ld a, (hl)
	out ($BF), a
	inc hl
	ld a, (hl)
	out ($BF), a
	pop hl
	ld bc, $0008
-:
	push bc
	ld b, $03
	ld c, $BE
	otir
	ld a, $00
	out ($BE), a
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
	ld a, $00
	out ($BF), a
	ld a, $4D
	out ($BF), a
	ld bc, $0020
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
_LABEL_7EA5_:
	ld a, (_RAM_DB97_TrackType)
	cp TT_RuffTrux
	jr z, +
	ld a, $04
	out ($BF), a
	ld a, $86
	out ($BF), a
	ret

+:
	ld a, $00
	out ($BF), a
	ld a, $86
	out ($BF), a
	ret

_LABEL_7EBE_DecompressRunCompressed:
  ; de = source data bitmask
  ; bc = source data raw bytes
  ; hl = destination
  ; Decomresses data. The data at de is a bitmask read left to right, where 1 = repeat, 0 = new raw byte.
  ; The data at bc contains only the raw bytes.
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
	ld (_RAM_DF13_BitIndex), a
--:
	ld a, (bc)          ; read byte from source
	ld (hl), a          ; write to dest
	ld (_RAM_DF14_LastWrittenByte), a  ; save it
	inc bc              ; next source byte
-:
	ld a, (_RAM_DF13_BitIndex)  ; Next bit index (wrap 7->0)
	add a, $01
	and $07
	ld (_RAM_DF13_BitIndex), a
	cp $00              ; Do work until it hits 0, else check if we hit de and loop until we do
	jr nz, +
	inc de              ; next bitmask
	ld a, (_RAM_DF15_)  ; Unless we ran out
	cp e
	jr nz, +
	ld a, (_RAM_DF16_)
	cp d
	jr nz, +
	ret                 ; else we are done

+:
	inc hl              ; next dest byte
	push hl
    ld hl, _DATA_7F46_BitsLookup
    ld a, (_RAM_DF13_BitIndex)  ; Look up the bit
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
	ld a, (_RAM_DF14_LastWrittenByte)  ; Else emit last written byte
	ld (hl), a
	jp -

_LABEL_7F02_Copy3bppTileDataToVRAM:
	ld a, $C8     ; When to stop: after $800 bytes
	ld (_RAM_DF1C_CopyToVRAMUpperBoundHi), a
	ld a, $00     ; VRAM address 0
	out ($BF), a
	ld a, $40
	out ($BF), a
	ld a, (_RAM_DB97_TrackType)
	cp TT_RuffTrux
	jr nz, +
	ld a, $C6     ; Stop after $600 bytes
	ld (_RAM_DF1C_CopyToVRAMUpperBoundHi), a
	ld a, $00
	out ($BF), a
	ld a, $60     ; VRAM address $2000
	out ($BF), a
+:
	ld hl, _RAM_C000_DecompressionTemporaryBuffer ; Point at the three bitplanes of tile data
	ld bc, _RAM_C000_DecompressionTemporaryBuffer + $0800
	ld de, _RAM_C000_DecompressionTemporaryBuffer + $1000
-:
	ld a, (hl)        ; Emit the three bitplanes
	out ($BE), a
	ld a, (bc)
	out ($BE), a
	ld a, (de)
	out ($BE), a
	xor a             ; And then 0
	out ($BE), a
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
	ld a, $0D
	ld ($8000), a
	call _LABEL_357F8_CarTilesToVRAM ; load decompressed data from RAM to VRAM, generating flipped versions (sometimes)

  ; Then load the shadow tiles
	ld a, (_RAM_DE8E_PageNumber)
	ld ($8000), a
	ld a, (_RAM_DB97_TrackType)
	cp TT_RuffTrux
	jr z, +

  ; Normal cars
  ; VRAM address - tile $1a8 = shadow tile
	ld a, $00
	out ($BF), a
	ld a, $75
	out ($BF), a
	ld bc, 8*4 ; four tiles
	ld hl, _DATA_1C22_TileData_ShadowTopLeft
	call _LABEL_7FC9_EmitTileData3bpp
  
  ; VRAM address - tile $1ac = empty (not for RuffTrux)
  ; Tile is used in-game but in a weird way, and it's glitchy
	ld a, $80
	out ($BF), a
	ld a, $75
	out ($BF), a
	ld bc, 32
-:xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

+:; RuffTrux version
  ; We squeeze the shadow into unused spaces in the car sprites
	ld a, $60
	out ($BF), a
	ld a, $41
	out ($BF), a
	ld bc, $0008
	ld hl, _DATA_1C22_TileData_ShadowTopLeft
	call _LABEL_7FC9_EmitTileData3bpp
	ld a, $00
	out ($BF), a
	ld a, $43
	out ($BF), a
	ld bc, $0008
	ld hl, _DATA_1C3A_TileData_ShadowTopRight
	call _LABEL_7FC9_EmitTileData3bpp
	ld a, $60
	out ($BF), a
	ld a, $43
	out ($BF), a
	ld bc, $0008
	ld hl, _DATA_1C52_TileData_ShadowBottomLeft
	call _LABEL_7FC9_EmitTileData3bpp
	ld a, $00
	out ($BF), a
	ld a, $51
	out ($BF), a
	ld bc, $0008
	ld hl, _DATA_1C6A_TileData_ShadowBottomRight
  ; fall through and return
_LABEL_7FC9_EmitTileData3bpp:
  ; Emits bc rows of 3bpp data to the VDP
-:push bc
    ld b, $03 ; 3 bytes data
    ld c, $BE
    otir
    ld a, $00 ; 1 byte padding
    out ($BE), a
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

; Data from 7FDB to 7FEF (21 bytes)
.db $FF $FF $FF $FF $FF $10 $24 $11 $93 $13 $11 $B4 $B5 $4C $4A $00
.db $00 $00 $00 $00 $00

.BANK 1 SLOT 1
.ORG $0000

; Data from 7FF0 to 7FFF (16 bytes)
.db $54 $4D $52 $20 $53 $45 $47 $41 $FF $FF $52 $E3 $00 $00 $00 $40

.BANK 2
.ORG $0000

_LABEL_8000_Main:
	di
	ld hl, $DFFF
	ld sp, hl
	ld a, $00
	ld (_RAM_DC3C_IsGameGear), a
	call _LABEL_AFAE_RamCodeLoader
	ld a, :_DATA_3ED49_SplashScreenCompressed ; $0F
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, _DATA_3ED49_SplashScreenCompressed ; $AD49 ; Location of compressed data - splash screen implementation, goes up to 3F752, decompresses to 3680 bytes
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000, loads splash screen code to RAM
	call _RAM_C000_DecompressionTemporaryBuffer	; Splash screen code is here
  
	call _LABEL_AFAE_RamCodeLoader ; Maybe the splash screen broke it?
	call _LABEL_B01D_SquinkyTennisHook
  
_LABEL_8021_MenuScreenEntryPoint:
  ; Menu screen changes start here
	call _LABEL_AFAE_RamCodeLoader
	ld a, $01
	ld (_RAM_DC3E_InMenus), a
	xor a
	ld (_RAM_D6D5_), a
	call _LABEL_BD00_
	call _LABEL_BB6C_
	call _LABEL_BB49_
	call _LABEL_B44E_
	call _LABEL_BB5B_
	call _LABEL_BF2E_ ; Loads palette
	ld a, (_RAM_DC3C_IsGameGear)
	or a
	jr z, +
	ld a, $38
	out ($05), a
+:
	ld a, (_RAM_DBCD_MenuIndex)
	or a
	jr nz, +
	call _LABEL_8114_Menu0
	jp ++

+:
	dec a
	jr nz, +
	call _LABEL_82DF_Menu1
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
	ld a, (_RAM_DBD8_CourseSelectIndex)
	or a
	jr nz, +
	call _LABEL_82DF_Menu1
	jp ++

+:
	call _LABEL_84AA_
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
	call _LABEL_80E6_
	ld a, (_RAM_D6D5_)
	dec a
	jr z, +
	ld a, (_RAM_D6D4_)
	or a
	call z, $D966	; Code is loaded from _LABEL_3BB26_
	nop ; Hook point?
	nop
	nop
	call _LABEL_B45D_
	jp -

+:
	di
	ld a, $00
	ld (_RAM_DC3E_InMenus), a
	jp _RAM_DBC0_EnterGameTrampoline	; Code is loaded from _LABEL_75_EnterGameTrampolineImpl

; Jump Table from 80BE to 80E5 (20 entries, indexed by _RAM_D699_MenuScreenIndex)
_DATA_80BE_MenuScreenHandlers:
.dw _LABEL_80FC_MenuScreenHandler_Null 
.dw _LABEL_8BAB_ _LABEL_8C35_ _LABEL_8CE7_ _LABEL_8D2B_ _LABEL_80FC_MenuScreenHandler_Null _LABEL_8D79_ _LABEL_8DCC_
.dw _LABEL_8E15_ _LABEL_8E97_ _LABEL_8EF0_ _LABEL_8F93_ _LABEL_8FC4_ _LABEL_9074_ _LABEL_B09F_ _LABEL_8C35_
.dw _LABEL_B56D_ _LABEL_B6B1_ _LABEL_B84D_ _LABEL_B06C_

_LABEL_80E6_:
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
_LABEL_80FC_MenuScreenHandler_Null:
	call _LABEL_915E_ScreenOn ; turn it back on
	ret

+:
	jp (hl)

; Data from 8101 to 8113 (19 bytes) - dead code
.db $3A $80 $D6 $E6 $30 $20 $0B $CD $F4 $B1 $3E $8E $32 $41 $D7 $C3
.db $2F $DB $C9

_LABEL_8114_Menu0:
	call _LABEL_BB85_
	call _LABEL_B44E_
	ld a, $01
	ld (_RAM_D699_MenuScreenIndex), a
	ld (_RAM_D7B3_), a
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
	ld (_RAM_D7B4_), a
	ld (_RAM_DC3F_), a
	ld (_RAM_DC3D_IsHeadToHead), a
	ld (_RAM_DBD8_CourseSelectIndex), a
	ld (_RAM_DC3B_), a
	ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
	ld (_RAM_D6D0_TitleScreenCheatCodeCounterHardMode), a
	ld (_RAM_D6C8_), a
	ld (_RAM_D6C6_), a
	ld (_RAM_D6C0_), a
	ld (_RAM_DC0A_), a
	ld (_RAM_DC34_), a
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
	ld (_RAM_DC35_), a
	ld a, $1A
	ld (_RAM_DC39_), a
	call _LABEL_BF2E_
	ld a, (_RAM_DC3C_IsGameGear)
	ld (_RAM_DC40_), a
	ld c, $01
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_81C1_:
	call _LABEL_BB85_
	ld a, $02
	ld (_RAM_D699_MenuScreenIndex), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_BAFF_
	call _LABEL_BAD5_
	call _LABEL_BDED_
	ld c, $07
	call _LABEL_B1EC_
	ld a, $00
	ld (_RAM_D6C7_), a
	call _LABEL_BB95_
	call _LABEL_BC0C_
	call _LABEL_A4B7_
	call _LABEL_9317_
	call _LABEL_BDB8_
	ld a, $00
	ld (_RAM_D6A0_), a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6AC_), a
	call _LABEL_A673_
	call _LABEL_BB75_
	ret

_LABEL_8205_:
	call _LABEL_BB85_
	ld a, $03
	ld (_RAM_D699_MenuScreenIndex), a
	ld a, $00
	ld (_RAM_D6C8_), a
	call _LABEL_B2DC_
	call _LABEL_B2F3_
	call _LABEL_987B_
	call _LABEL_9434_
	call _LABEL_988D_
	xor a
	ld (_RAM_D6B1_), a
	ld (_RAM_D6B8_), a
	ld (_RAM_D6B7_), a
	ld (_RAM_D6B9_), a
	ld hl, $4480 ; Tile 24
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD4_)
	call _LABEL_9F40_

	call _LABEL_B375_ConfigureTilemapRect_5x6_24
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $791A ; Tilemap 13, 4 for GG
	jr ++
+:ld hl, $7952 ; Tilemap 9, 5 for SMS
++:call _LABEL_BCCF_EmitTilemapRectangleSequence

	ld a, $60
	ld (_RAM_D6AF_), a
	xor a
	ld (_RAM_D6A4_), a
	ld (_RAM_D6B4_), a
	ld (_RAM_D6B0_), a
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
	ld (_RAM_D699_MenuScreenIndex), a
	call _LABEL_B2DC_
	ld hl, $7840
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_95AF_
	ld a, $02
	call _LABEL_B478_SelectPageNumber
	ld hl, $B3E4
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4480
	ld de, $0280
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
  
  ; Draw 10x8 tilemap rect at 11, 10 starting at tile $24
	ld a, $24
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld hl, $7A96 ; Tilemap 11, 10
	ld a, $08
	ld (_RAM_D69B_TilemapRectangleSequence_Height), a
	ld a, $0A
	ld (_RAM_D69A_TilemapRectangleSequence_Width), a
	xor a
	ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
	call _LABEL_BCCF_EmitTilemapRectangleSequence
  
	ld c, $05
	call _LABEL_B1EC_
	ld a, $0F
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $7C90
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0010
	ld hl, $ACC9
	call $DAAA	; Code is loaded from _LABEL_BDD_
	ld a, $60
	ld (_RAM_D6AF_), a
	ld hl, $0170
	ld (_RAM_D6AB_), hl
	xor a
	ld (_RAM_D6C1_), a
	call _LABEL_BB75_
	ret

_LABEL_82DF_Menu1:
	ld a, $06
	ld (_RAM_D699_MenuScreenIndex), a
	ld a, $FF
	ld (_RAM_D6C4_), a
	ld a, (_RAM_DBCE_)
	or a
	jr z, +
	jp _LABEL_8360_

+:
	call _LABEL_BB85_
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld (_RAM_D6B8_), a
	ld a, $0B
	ld (_RAM_D6B7_), a
	ld a, $01
	ld (_RAM_D6B4_), a
	ld a, $07
	ld (_RAM_D6B1_), a
	ld hl, $4480
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD4_)
	ld (_RAM_DBD3_), a
	add a, $01
	call _LABEL_9F40_
	ld hl, $7A1A
	call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
	ld hl, $7C0E
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0012
	ld hl, _TEXT_834E_FailedToQualify
	call _LABEL_A5B0_EmitToVDP_Text
	ld c, $08
	call _LABEL_B1EC_
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
	call _LABEL_BB85_
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld (_RAM_D6B8_), a
	ld a, $03
	ld (_RAM_DC09_Lives), a
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +
	ld a, (_RAM_DBD8_CourseSelectIndex)
	add a, $01
	ld (_RAM_DBD8_CourseSelectIndex), a
+:
	ld hl, $4480
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD4_)
	call _LABEL_9F40_
	ld hl, $7A9A
	call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
	ld hl, $7996
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0009
	ld hl, _TEXT_83ED_Qualified
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $79D2
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000E
	ld hl, _TEXT_83F6_ForChallenge
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_D7B4_)
	or a
	jr z, +
	ld hl, $79CE
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0012
	ld hl, _TEXT_8404_ForHeadToHead
	call _LABEL_A5B0_EmitToVDP_Text
+:
	ld hl, $7C98
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0006
	ld hl, _TEXT_8416_Lives
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC09_Lives)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld c, $06
	call _LABEL_B1EC_
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
	call _LABEL_BB85_
	ld a, $07
	ld (_RAM_D699_MenuScreenIndex), a
	call _LABEL_B337_
	call _LABEL_B2DC_
	call _LABEL_A673_
	call _LABEL_B2F3_
	call _LABEL_987B_
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
	ld (_RAM_D6AF_), a
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
	call _LABEL_B1EC_
	ld a, (_RAM_DBFB_)
	ld (_RAM_D6A2_), a
	ld c, a
	ld b, $00
	call _LABEL_97EA_
	call _LABEL_BB75_
	ret

_LABEL_8486_:
	call _LABEL_BB85_
	ld a, $08
	ld (_RAM_D699_MenuScreenIndex), a
	call _LABEL_B2BB_
	ld c, $07
	call _LABEL_B1EC_
	call _LABEL_A787_
	call _LABEL_AD42_DrawDisplayCase
	call _LABEL_B230_DisplayCase_BlankRuffTrux
	xor a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6AC_), a
	call _LABEL_BB75_
	ret

_LABEL_84AA_:
	call _LABEL_BB85_
	ld a, (_RAM_DC3F_)
	or a
	jr z, _LABEL_84C7_
	ld a, (_RAM_DBCF_LastRacePosition)
	or a
	jp nz, _LABEL_8F73_
	call _LABEL_B269_
	cp $1A
	jr nz, _LABEL_84C7_
	call _LABEL_B877_
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_84C7_:
	ld a, $09
	ld (_RAM_D699_MenuScreenIndex), a
	call _LABEL_B2BB_
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +
	call _LABEL_A7B3_
+:
	ld a, $01
	ld (_RAM_D6C3_), a
	call _LABEL_AC1E_
	call _LABEL_ACEE_
	call _LABEL_AB5B_
	call _LABEL_AB86_
	call _LABEL_ABB0_
	call _LABEL_BA3C_
	ld a, $40
	ld (_RAM_D6AF_), a
	xor a
	ld (_RAM_D6C1_), a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6AC_), a
	ld c, $05
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_8507_:
	call _LABEL_BB85_
	ld a, $0A
	ld (_RAM_D699_MenuScreenIndex), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	call _LABEL_9448_
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	call _LABEL_94AD_
	jr ++

+:
	call _LABEL_94F0_
++:
	call _LABEL_B305_
	ld hl, $4480
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
	ld hl, $4840
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
	ld hl, $4C00
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
	ld hl, $4FC0
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
	ld hl, $78D8
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_85EC_Results
	call _LABEL_A5B0_EmitToVDP_Text
	xor a
	ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6C1_), a
	ld c, $06
	call _LABEL_B1EC_
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
	call _LABEL_BB85_
	ld a, $0B
	ld (_RAM_D699_MenuScreenIndex), a
	ld e, $0E
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld (_RAM_D6B8_), a
	ld a, $0B
	ld (_RAM_D6B7_), a
	ld a, $01
	ld (_RAM_D6B4_), a
	ld a, $07
	ld (_RAM_D6B1_), a
	ld hl, $4480
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_D6C4_)
	ld c, a
	ld b, $00
	ld hl, $DBD5
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
	ld hl, $DBFE
	add hl, bc
	ld a, $5A
	ld (hl), a
	ld a, (_RAM_D6C4_)
	add a, $01
	ld (_RAM_D6B9_), a
	ld a, $60
	ld (_RAM_D6AF_), a
	xor a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6AC_), a
	ld c, $09
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_866C_:
	call _LABEL_BB85_
	ld a, $0C
	ld (_RAM_D699_MenuScreenIndex), a
	call _LABEL_B2DC_
	call _LABEL_B305_
	xor a
	ld (_RAM_D6B8_), a
	ld hl, $4480
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
	ld hl, $7992
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000E
	ld hl, _TEXT_882E_OneLifeLost
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0006
	ld hl, _TEXT_884A_Lives
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC09_Lives)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	call _LABEL_A673_
	ld a, (_RAM_DC09_Lives)
	add a, $1B
	ld (_RAM_D701_), a
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld a, $96
	ld (_RAM_D6E1_), a
	ld a, $B0
	ld (_RAM_D721_), a
	jr ++

+:
	ld a, $90
	ld (_RAM_D6E1_), a
	ld a, $A8
	ld (_RAM_D721_), a
++:
	call _LABEL_93CE_
	ld c, $0A
	call _LABEL_B1EC_
	ld a, $80
	ld (_RAM_D6AB_), a
	jp _LABEL_8826_

_LABEL_8717_:
	ld hl, $7992
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000E
	ld hl, _TEXT_883C_GameOver
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0006
	ld hl, _TEXT_8850_Level
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DBF6_)
	cp $0E
	jr z, +
	out ($BE), a
	xor a
	out ($BE), a
+:
	ld a, (_RAM_DBF7_)
	out ($BE), a
	xor a
	out ($BE), a
	ld c, $08
	call _LABEL_B1EC_
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
	ld hl, $7994
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000C
	ld hl, _TEXT_8856_YouMadeIt
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7A14
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000C
	ld hl, _TEXT_8862_ExtraLife
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0006
	ld hl, _TEXT_884A_Lives
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC09_Lives)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld a, (_RAM_DC09_Lives)
	cp $09
	jr z, +
	add a, $01
+:
	ld (_RAM_DC09_Lives), a
	call _LABEL_A673_
	ld a, (_RAM_DC09_Lives)
	add a, $1A
	ld (_RAM_D701_), a
	ld a, (_RAM_DC3C_IsGameGear)
	or a
	jr nz, +
	ld a, $96
	jp ++

+:
	ld a, $90
++:
	ld (_RAM_D6E1_), a
	ld a, $E0
	ld (_RAM_D721_), a
	call _LABEL_93CE_
	ld c, $06
	call _LABEL_B1EC_
	ld a, $C8
	ld (_RAM_D6AB_), a
	jp _LABEL_8826_

_LABEL_87E9_:
	ld hl, $79D6
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0009
	ld hl, _TEXT_886E_NoBonus
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7C98
	jr ++

+:
	ld hl, $7C58
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0006
	ld hl, _TEXT_884A_Lives
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC09_Lives)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld c, $0A
	call _LABEL_B1EC_
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
	call _LABEL_BB85_
	ld a, $0D
	ld (_RAM_D699_MenuScreenIndex), a
	call _LABEL_B2DC_
	call _LABEL_B305_
	ld a, $09
	call _LABEL_B478_SelectPageNumber
	ld hl, _DATA_AB4D_
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $6000
	ld de, $0280
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

  ; Draw 10x8 tilemap rect at 11, (something) starting at tile 256
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7B96 ; 11, 14 (SMS)
	jr ++
+:ld hl, $7A96 ; 11, 10 (GG)
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
	ld hl, $7D90 ; 8, 22
	jr ++
+:ld hl, $7C90 ; 8, 18
++:call _LABEL_B35A_VRAMAddressToHL

	ld a, $0F
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld bc, $0010
	ld hl, $AD39
	call $DAAA	; Code is loaded from _LABEL_BDD_
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld de, $7952
	ld hl, _TEXT_8929_TripleWin
	call _LABEL_B3A4_EmitToVDPAtDE_Text
	ld de, $79D2
	ld hl, _TEXT_8937_BonusRace
	call _LABEL_B3A4_EmitToVDPAtDE_Text
	jr ++

+:
	ld de, $7992
	ld hl, _TEXT_8929_TripleWin
	call _LABEL_B3A4_EmitToVDPAtDE_Text
	ld de, $7A12
	ld hl, _TEXT_8937_BonusRace
	call _LABEL_B3A4_EmitToVDPAtDE_Text
++:
	ld de, $7A52
	ld hl, _TEXT_8945_BeatTheClock
	call _LABEL_B3A4_EmitToVDPAtDE_Text
	ld a, $40
	ld (_RAM_D6AF_), a
	xor a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6AC_), a
	ld (_RAM_D6C1_), a
	ld c, $05
	call _LABEL_B1EC_
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
	call _LABEL_BB85_
	ld a, $0E
	ld (_RAM_D699_MenuScreenIndex), a
	ld a, $01
	ld (_RAM_D7B4_), a
	xor a
	ld (_RAM_D6C8_), a
	call _LABEL_B2DC_
	call _LABEL_B2F3_
	call _LABEL_987B_
	call _LABEL_9434_
	call _LABEL_988D_
	call _LABEL_A673_

	ld hl, $4480 ; Tile $24
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD4_)
	call _LABEL_9F40_
	ld a, (_RAM_DBD5_)
	call _LABEL_9F40_
  
	ld hl, $7954 ; Tilemap 10, 5
	call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
  
	ld a, $42
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld a, $06
	ld (_RAM_D69B_TilemapRectangleSequence_Height), a
	ld hl, $7962
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld a, $30
	ld (_RAM_D6AF_), a
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
	call _LABEL_97EA_
	call _LABEL_B3AE_
	ld c, $02
	call _LABEL_B1EC_
	call _LABEL_BB75_
	ret

_LABEL_89E2_:
	call _LABEL_BB85_
	ld a, $0F
	ld (_RAM_D699_MenuScreenIndex), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	ld a, $B2
	ld (_RAM_D6C8_), a
	call _LABEL_9448_
	call _LABEL_94AD_
	call _LABEL_B305_
	ld a, $01
	ld (_RAM_D6C7_), a
	ld (_RAM_D7B3_), a
	call _LABEL_BB95_
	call _LABEL_BC0C_
	call _LABEL_A530_
	ld c, $07
	call _LABEL_B1EC_
	call _LABEL_9317_
	xor a
	ld (_RAM_D6A0_), a
	ld (_RAM_D6AC_), a
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
	ld (_RAM_D699_MenuScreenIndex), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	call _LABEL_A296_
	call _LABEL_BA3C_
	call _LABEL_BA4F_
	ld a, (_RAM_DC3C_IsGameGear)
	or a
	jr z, +
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $10
	jr z, ++
+:
	ld a, $B2
	ld (_RAM_D6C8_), a
	call _LABEL_9448_
	call _LABEL_94AD_
	call _LABEL_B305_
++:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr nz, +
	ld hl, $4480
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
	ld hl, $4480
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD4_)
	call _LABEL_9F40_
	ld a, (_RAM_DBD5_)
	call _LABEL_9F40_
++:
	call _LABEL_B375_ConfigureTilemapRect_5x6_24
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $7852
	jp ++

+:
	ld hl, $7AD2
++:
	ld a, (_RAM_DC3C_IsGameGear)
	cp $01
	jr z, +
	ld bc, $0080
	add hl, bc
+:
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld a, $42
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld a, $06
	ld (_RAM_D69B_TilemapRectangleSequence_Height), a
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $7864
	jp ++

+:
	ld hl, $7AE4
++:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld bc, $0080
	add hl, bc
+:
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	call _LABEL_A355_
	call _LABEL_B9ED_
	ld a, $60
	ld (_RAM_D6AF_), a
	xor a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6AC_), a
	ld (_RAM_D6C1_), a
	ld (_RAM_D693_), a
	ld (_RAM_D6CC_), a
	ld (_RAM_D6CE_), a
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jp z, _LABEL_8B89_
	ld a, (_RAM_DC34_)
	cp $01
	jr z, +
	call _LABEL_A673_
	ld c, $05
	call _LABEL_B1EC_
	call _LABEL_9317_
	ld hl, $B356
	call $D9F5	; Code is loaded from _LABEL_3BBB5_
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
	out ($03), a
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
	out ($03), a
+:
	call _LABEL_AF5D_
	ld a, (_RAM_D6CF_)
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
	ld a, (_RAM_DC34_)
	dec a
	jr nz, _LABEL_8B9D_
	call _LABEL_B785_
_LABEL_8B9D_:
	call _LABEL_A14F_
	xor a
	ld (_RAM_D6CB_), a
	call _LABEL_BF2E_
	call _LABEL_BB75_
	ret

; 2nd entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8BAB_:
	call _LABEL_AF10_
	ld a, (_RAM_D7BB_)
	or a
	jr nz, _LABEL_8C2C_
	call _LABEL_BE1A_DrawCopyrightText
	call _LABEL_918B_
	call _LABEL_92CB_
	call _LABEL_B9C4_
	call _LABEL_B484_
	ld a, (_RAM_D6D0_TitleScreenCheatCodeCounterHardMode)
	cp $09 ; full length
	jr z, _LABEL_8C23_CheatCode1 ; cheat 1 entered

	ld a, (_RAM_DC45_TitleScreenCheatCodeCounterCourseSelect)
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
	call _LABEL_B505_
	ld a, (_RAM_D6AB_)
	or a
	jr z, +
	sub $01
	ld (_RAM_D6AB_), a
	jp +++

+:
	ld a, (_RAM_D680_Player1Controls_Menus)
	and BUTTON_1_MASK
	jr z, ++
	ld a, (_RAM_DC3C_IsGameGear)
	or a
	jr z, +++
	ld a, (_RAM_DC41_GearToGearActive)
	or a
	jr z, +
	ld a, (_RAM_D681_Player2Controls_Menus)
	and BUTTON_1_MASK
	jr z, ++
	jr +++

+:
	in a, ($00) ; GG start button
	and $80
	jr nz, +++
++:
	ld a, (_RAM_DC41_GearToGearActive)
	or a
	jr nz, _LABEL_8C2C_
	call _LABEL_B1F4_
	call _LABEL_81C1_
+++:
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_8C23_CheatCode1:
	call _LABEL_B1F4_
	call _LABEL_B70B_
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_8C2C_:
	call _LABEL_B1F4_
	call _LABEL_8953_
	jp _LABEL_80FC_MenuScreenHandler_Null

; 3rd entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8C35_:
	call _LABEL_B9C4_
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $0F
	jr z, +
	call _LABEL_B433_
	ld hl, (_RAM_D6AB_)
	inc hl
	ld (_RAM_D6AB_), hl
	ld a, h
	cp $03
	jr nz, +
	call _LABEL_B1F4_
	call _LABEL_8114_Menu0
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_8CA2_
	jp +

; Data from 8C5D to 8C5F (3 bytes)
.db $CD $B1 $8C

+:
	ld a, (_RAM_D6A0_)
	or a
	jp z, _LABEL_80FC_MenuScreenHandler_Null
	ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
	and BUTTON_1_MASK ; $10
	jp nz, _LABEL_80FC_MenuScreenHandler_Null
  ; Select
	call _LABEL_B1F4_
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $0F
	jr z, ++
	ld a, (_RAM_D6A0_)
	dec a
	jr nz, +
	call _LABEL_AFCD_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_8953_
	jp _LABEL_80FC_MenuScreenHandler_Null

++:
	ld a, (_RAM_D6A0_)
	dec a
	jr nz, +
	ld a, $01
	ld (_RAM_DC34_), a
	call _LABEL_8A30_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_8A30_
	jp _LABEL_80FC_MenuScreenHandler_Null

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
	ld hl, $B356
	call $D9F5	; Code is loaded from _LABEL_3BBB5_
	ld a, $01
	ld (_RAM_D6A0_), a
	ret

++:
	ld hl, $B36E
	call $D9F5	; Code is loaded from _LABEL_3BBB5_
	ld a, $02
	ld (_RAM_D6A0_), a
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
_LABEL_8CE7_:
	call _LABEL_996E_
	call _LABEL_95C3_
	call _LABEL_9B87_
	call _LABEL_9D4E_
	ld a, (_RAM_D6B8_)
	or a
	jr z, _LABEL_8D28_
	ld a, (_RAM_D6B8_)
	sub $01
	ld (_RAM_D6B8_), a
	cp $10
	jr z, +
	cp $D0
	jr nc, _LABEL_8D28_
	ld a, (_RAM_D680_Player1Controls_Menus)
	and BUTTON_1_MASK ; $10
	jr nz, _LABEL_8D28_
+:
	ld a, (_RAM_D6A2_)
	ld (_RAM_DBFB_), a
	ld a, (_RAM_D6AD_)
	ld (_RAM_DBFC_), a
	ld a, (_RAM_D6AE_)
	ld (_RAM_DBFD_), a
	call _LABEL_B1F4_
	call _LABEL_8272_
_LABEL_8D28_:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 5th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8D2B_:
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
	ld a, (_RAM_D6C5_)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_B1F4_
	ld a, $01
	ld (_RAM_D6D5_), a
+++:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 7th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8D79_:
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
	call _LABEL_B1F4_
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +++
	call _LABEL_841C_
++:
	jp _LABEL_80FC_MenuScreenHandler_Null

+++:
	call _LABEL_84AA_
	jp _LABEL_80FC_MenuScreenHandler_Null

++++:
	call _LABEL_9D4E_
	ld hl, (_RAM_D6AB_)
	dec hl
	ld (_RAM_D6AB_), hl
	ld a, l
	or h
	or a
	jr nz, +
	call _LABEL_B1F4_
	call _LABEL_8114_Menu0
+:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 8th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8DCC_:
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
	in a, ($00)
	and $80
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
	call _LABEL_B1F4_
	call _LABEL_8486_
+:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 9th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8E15_:
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
	call _LABEL_B1F4_
	ld a, (_RAM_DC0A_)
	cp $03
	jr nz, +
	xor a
	ld (_RAM_DBE8_), a
	ld (_RAM_DBEC_), a
	ld (_RAM_DBF0_), a
	call _LABEL_8877_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_84AA_
++:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 10th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8E97_:
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
	ld a, (_RAM_D6C5_)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_B1F4_
	ld a, $01
	ld (_RAM_D6D5_), a
+++:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 11th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8EF0_:
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
	jp _LABEL_80FC_MenuScreenHandler_Null

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
	call _LABEL_B1F4_
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
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_8486_
++:
	jp _LABEL_80FC_MenuScreenHandler_Null

+++:
	ld a, $01
	ld (_RAM_DC3A_), a
	call _LABEL_84AA_
	jp _LABEL_80FC_MenuScreenHandler_Null

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
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_8F73_:
	ld a, (_RAM_DC09_Lives)
	sub $01
	ld (_RAM_DC09_Lives), a
	or a
	jr z, +
	xor a
	ld (_RAM_DC38_), a
	call _LABEL_866C_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	ld a, $01
	ld (_RAM_DC38_), a
	call _LABEL_866C_
	jp _LABEL_80FC_MenuScreenHandler_Null

; 12th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8F93_:
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
	call _LABEL_B1F4_
	call _LABEL_841C_
++:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 13th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_8FC4_:
	ld a, (_RAM_DC38_)
	or a
	jr nz, +
	ld a, (_RAM_D721_)
	cp $E0
	jr z, _LABEL_902E_
	add a, $01
	ld (_RAM_D721_), a
	call _LABEL_93CE_
	jp _LABEL_902E_

+:
	ld a, (_RAM_D721_)
	cp $E1
	jr z, _LABEL_902E_
	ld a, (_RAM_DC38_)
	cp $02
	jr nz, _LABEL_902E_
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld a, (_RAM_D721_)
	cp $B0
	jr z, +++
	jr ++

+:
	ld a, (_RAM_D721_)
	cp $A8
	jr z, +++
++:
	sub $01
	ld (_RAM_D721_), a
	call _LABEL_93CE_
	jp _LABEL_902E_

+++:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7CA4
	jr ++

+:
	ld hl, $7C64
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC09_Lives)
	add a, $1A
	out ($BE), a
	xor a
	out ($BE), a
	ld a, $E1
	ld (_RAM_D721_), a
	call _LABEL_93CE_
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
	call _LABEL_B1F4_
	ld a, (_RAM_DC38_)
	dec a
	jr z, ++
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +
	call _LABEL_8486_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_84C7_
	jp _LABEL_80FC_MenuScreenHandler_Null

++:
	call _LABEL_8114_Menu0
+++:
	jp _LABEL_80FC_MenuScreenHandler_Null

; 14th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_9074_:
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
	ld a, (_RAM_D6C5_)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_B1F4_
	ld a, $01
	ld (_RAM_D6D5_), a
+++:
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_90CA_:
	ld hl, $4000
	call _LABEL_B35A_VRAMAddressToHL
	ld de, $3700
-:
	xor a
	out ($BE), a
	dec de
	ld a, d
	or e
	jr nz, -
	ld a, NO_BUTTONS_PRESSED ; $3F
	ld (_RAM_D680_Player1Controls_Menus), a
	ld (_RAM_D681_Player2Controls_Menus), a
	ld (_RAM_D687_Player1Controls_PreviousFrame), a
	ret

_LABEL_90E7_:
	xor a
	ld (_RAM_D691_), a
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
-:in a, ($DC) ; Read controller 1
	ld b, a
	and $3F     ; Mask to relevant bits
	ld (_RAM_D680_Player1Controls_Menus), a ; Store
  
	ld a, (_RAM_DC3C_IsGameGear)
	or a
	jr nz, + ; ret
  
	in a, ($DD) ; Read controller 2
	sla a
	sla a
	and $3C     ; Shift and mask to relevant bits
	ld c, a
	ld a, b
	and $C0     ; Mask in bits from the other port
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
	in a, ($DC) ; Read controller 1
	and $3F
	ld (_RAM_D680_Player1Controls_Menus), a
	out ($03), a ; Emit to GG link port?
	ld a, (_RAM_DC48_GearToGear_OtherPlayerControls2) ; Read in from other Game Gear?
	ld (_RAM_D681_Player2Controls_Menus), a
	ret

+:
  ; Read controller, as player 2, emit to GG port and use GG port data for player 1 controls. We use the data from the previous frame, presumably for timing reasons?
	ld a, (_RAM_D687_Player1Controls_PreviousFrame)
	ld b, a
	in a, ($DC) ; Read controller 1
	and $3F
	ld (_RAM_D687_Player1Controls_PreviousFrame), a ; Store
	out ($03), a ; Emit to GG link port
	ld a, b
	ld (_RAM_D681_Player2Controls_Menus), a ; My buttons go to player 2
	ld a, (_RAM_DC47_GearToGear_OtherPlayerControls1)
	ld (_RAM_D680_Player1Controls_Menus), a ; Other GG buttons go to player 1
	ret

_LABEL_915E_ScreenOn:
	ld a, $70
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_9167_ScreenOff:
	ld a, $10
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

_LABEL_9170_:
	ld hl, $7700
	call _LABEL_B35A_VRAMAddressToHL
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
	ld a, (_RAM_D694_)
	or a
	jr z, _LABEL_91E7_
	ld a, (_RAM_D690_)
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld a, (_RAM_D691_)
	cp $00
	jr nz, +
	ld hl, $7AD6
	jp ++

+:
	ld hl, $7A96
++:
	xor a
	ld (_RAM_D68B_), a
--:
	call _LABEL_B35A_VRAMAddressToHL
	ld e, $0A
-:
	ld a, (_RAM_D691_)
	or a
	jr nz, +
	ld a, $0E
	jp ++

+:
	ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
++:
	out ($BE), a
	xor a
	out ($BE), a
	ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
	add a, $01
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	dec e
	jr nz, -
	ld a, (_RAM_D68B_)
	cp $07
	jr z, +
	add a, $01
	ld (_RAM_D68B_), a
	ld de, $0040
	add hl, de
	jp --

+:
	call _LABEL_9276_
	call _LABEL_91E8_
_LABEL_91E7_:
	ret

_LABEL_91E8_:
	ld a, (_RAM_D691_)
	add a, $01
	ld (_RAM_D691_), a
	cp $06
	jr z, _LABEL_91E8_
	cp $0A
	jr nz, +
	xor a
	ld (_RAM_D691_), a
+:
	add a, $07
	ld (_RAM_D6D6_), a
	ld a, $01
	ld (_RAM_D6D4_), a
	xor a
	ld (_RAM_D68D_), a
	ld a, $C0
	ld (_RAM_D68C_), a
	ld a, (_RAM_D691_)
	sla a
	ld d, $00
	ld e, a
	ld hl, _DATA_9254_
	add hl, de
	ld a, (hl)
	ld (_RAM_D7B5_DecompressorSource), a
	inc hl
	ld a, (hl)
	ld (_RAM_D7B6_), a
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
_DATA_9254_:
.db $4D $AB $A5 $BA $E4 $B3 $2B $AF $5D $B3 $65 $B7 $4D $AB $C8 $AA
.db $6E $B3 $4D $AB

; Data from 9268 to 926B (4 bytes)
_DATA_9268_:
.db $80 $44 $80 $4E

; Data from 926C to 9275 (10 bytes)
_DATA_926C_PageNumbers:
.db $0A $03 $07 $05 $03 $03 $04 $05 $05 $0A

_LABEL_9276_:
	ld a, $0F
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	call _LABEL_BEF5_
	ld a, (_RAM_D691_)
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
	ld a, (_RAM_D691_)
	cp $00
	jr z, +++
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld a, (_RAM_D699_MenuScreenIndex)
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
	call _LABEL_B361_VRAMAddressToDE
	ld bc, $0010
	call $DAAA	; Code is loaded from _LABEL_BDD_
	ld a, (_RAM_D691_)
	or a
	jr nz, +
	ld a, $01
	ld (_RAM_D6CB_), a
+:
	ret

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
	call $D9D3	; Code is loaded from _LABEL_3BB93_
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

_LABEL_9317_:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, _DATA_936E_
	ld de, _DATA_9386_
	jr ++

+:
	ld hl, _DATA_939E_
	ld de, _DATA_93B6_
++:
	ld ix, _RAM_D6E1_
	ld iy, _RAM_D721_
	ld bc, $0018
-:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $10
	jr z, +
	jp ++

+:
	ld a, (hl)
	add a, $43
	ld (ix+0), a
	ld a, (_RAM_DC3C_IsGameGear)
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
	jp $D9F5	; Code is loaded from _LABEL_3BBB5_

; Data from 936E to 9385 (24 bytes)
_DATA_936E_:
.db $6E $76 $7E $86 $8E $96 $6E $76 $7E $86 $8E $96 $6E $76 $7E $86
.db $8E $96 $6E $76 $7E $86 $8E $96

; Data from 9386 to 939D (24 bytes)
_DATA_9386_:
.db $90 $90 $90 $90 $90 $90 $98 $98 $98 $98 $98 $98 $A0 $A0 $A0 $A0
.db $A0 $A0 $A8 $A8 $A8 $A8 $A8 $A8

; Data from 939E to 93B5 (24 bytes)
_DATA_939E_:
.db $65 $6D $75 $7D $85 $8D $65 $6D $75 $7D $85 $8D $65 $6D $75 $7D
.db $85 $8D $65 $6D $75 $7D $85 $8D

; Data from 93B6 to 93CD (24 bytes)
_DATA_93B6_:
.db $78 $78 $78 $78 $78 $78 $80 $80 $80 $80 $80 $80 $88 $88 $88 $88
.db $88 $88 $90 $90 $90 $90 $90 $90

_LABEL_93CE_:
	ld hl, $7F80
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0020
	ld hl, _RAM_D6E1_
	ld de, _RAM_D701_
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
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0020
	ld hl, _RAM_D721_
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
	call _LABEL_B35A_VRAMAddressToHL
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
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0040
-:
	xor a
	out ($BE), a
	dec bc
	ld a, c
	or a
	jr nz, -
	ld bc, $0060
	ld hl, _RAM_D6E1_
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
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $ABEC
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $0040
	ld hl, $5740
	jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_9448_:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $0F
	jr c, +
	ld hl, $6200
	jp ++

+:
	ld hl, $5840
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld a, $0B
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $BDE0
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $00B0
	call _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM
	ld a, $04
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $BD7F
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $00C0
	call _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $13
	jr z, +
	ld a, (_RAM_D7B4_)
	or a
	jr nz, _LABEL_949B_
_LABEL_948A_:
	ld a, $0A
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B386
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $0080
	jp _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM

_LABEL_949B_:
	ld a, $0A
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B4CA
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $0070
	jp _LABEL_AFA8_Emit3bppTileDataFromDecompressionBufferToVRAM

+:
	ret

_LABEL_94AD_:
	ld a, $04
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $0F
	jr c, +
	ld a, $01
	ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
	jp ++

+:
	xor a
	ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
++:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld de, $7742
	jr ++

+:
	ld de, $784C
++:
	call _LABEL_B361_VRAMAddressToDE
	ld hl, $BF38
	ld a, $08
	ld (_RAM_D69D_EmitTilemapRectangle_Width), a
	ld a, $03
	ld (_RAM_D69E_EmitTilemapRectangle_Height), a
	ld a, (_RAM_D6C8_)
	ld c, a
	ld a, $C2
	sub c
	ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
	call $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle
_LABEL_94F0_:
	ld a, $04
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, ++
	ld a, (_RAM_D7B4_)
	or a
	jr nz, +
	ld de, $7794
	jp +++

+:
	ld de, $7792
	jp +++

++:
	ld de, $785C
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $0A
	jr nz, +++
	ld de, $784C
+++:
	call _LABEL_B361_VRAMAddressToDE
	ld hl, _DATA_BF50_
	ld a, $0C
	ld (_RAM_D69D_EmitTilemapRectangle_Width), a
	ld a, $02
	ld (_RAM_D69E_EmitTilemapRectangle_Height), a
	ld a, (_RAM_D6C8_)
	ld c, a
	ld a, $D8
	sub c
	ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
	call $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle
	ld a, $0A
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, ++
	ld a, (_RAM_D7B4_)
	or a
	jr nz, +
	ld de, $77AC
	jp +++

+:
	ld de, $77AA
	jp +++

++:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $0A
	jr z, +
	ld a, (_RAM_D7B4_)
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
	call _LABEL_B361_VRAMAddressToDE
	ld a, (_RAM_D7B4_)
	or a
	jr nz, +
	ld hl, _DATA_B4BA_
	ld a, $08
	jp ++

+:
	ld hl, $B5BE
	ld a, $0A
++:
	ld (_RAM_D69D_EmitTilemapRectangle_Width), a
	ld a, $02
	ld (_RAM_D69E_EmitTilemapRectangle_Height), a
	ld a, (_RAM_D6C8_)
	ld c, a
	ld a, $F0
	sub c
	ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
	call $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle
	ret

_LABEL_959C_:
	ld a, $08
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $7680
	call _LABEL_B35A_VRAMAddressToHL
	ld e, $20
	ld hl, _DATA_AB2C_
	jp $D985	; Code is loaded from _LABEL_3BB45_

_LABEL_95AF_:
	ld a, (_RAM_DC3C_IsGameGear)
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
	ld a, (_RAM_DC3F_)
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
	ld a, (_RAM_DC3F_)
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
	call _LABEL_97EA_
	ret

_LABEL_96F6_:
	ld a, (_RAM_D6A4_)
	cp $01
	jr z, _LABEL_973C_
	ld hl, _DATA_9773_
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
	ld (_RAM_D6A8_), de
	call _LABEL_B361_VRAMAddressToDE
	ld a, (_RAM_D6AA_)
	call _LABEL_9F81_
	ld a, (_RAM_D6A4_)
	sub $01
	ld (_RAM_D6A4_), a
	ret

_LABEL_973C_:
	ld hl, (_RAM_D6A8_)
	ld bc, $01E0
	add hl, bc
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, (_RAM_D6A6_DisplayCase_Source)
	ld a, (_RAM_D6AA_)
	call _LABEL_9FB8_
	ld a, (_RAM_D6A4_)
	sub $01
	ld (_RAM_D6A4_), a
	call _LABEL_AECD_
	ret

; Data from 975B to 9766 (12 bytes)
_DATA_975B_:
.db $80 $67 $40 $6B $00 $6F $C0 $72 $00 $60 $C0 $63

; Data from 9767 to 9772 (12 bytes)
_DATA_9767_:
.db $C0 $63 $80 $67 $40 $6B $00 $6F $C0 $72 $00 $60

; Data from 9773 to 977E (12 bytes)
_DATA_9773_:
.db $C0 $72 $00 $60 $C0 $63 $80 $67 $40 $6B $00 $6F

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
	ld hl, $DBFE
	add hl, bc
	ld a, (hl)
	ld (_RAM_D6AA_), a
	ld hl, _DATA_97DF_
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
	ld hl, _DATA_97DF_
	add hl, bc
	ld a, (hl)
	ld (_RAM_D6BB_), a
	ret

; Data from 97DF to 97E9 (11 bytes)
_DATA_97DF_:
.db $00 $08 $10 $18 $20 $28 $30 $38 $40 $48 $50

_LABEL_97EA_:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld a, $06
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $7C00
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $B7A7
	add hl, bc
	ld e, $C0
	jp $DA18	; Code is loaded from _LABEL_3BBD8_

+:
	ld a, $06
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B987
	add hl, bc
	ld b, $42
	ld c, $0B
	ld de, $7B0C
	jp $DA38	; Code is loaded from _LABEL_3BBF8_

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

_LABEL_987B_:
	ld hl, $7680
	call _LABEL_B35A_VRAMAddressToHL
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
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, _DATA_98AE_
	jp ++

+:
	ld hl, _DATA_990E_
++:
	ld de, _RAM_D6E1_
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
	ld a, (_RAM_DC3F_)
	dec a
	jp z, _LABEL_9A0E_
+:
	ld a, (_RAM_D6AF_)
	cp $00
	jr z, _LABEL_99D2_
	sub $01
	ld (_RAM_D6AF_), a
	sra a
	sra a
	sra a
	and $01
	jp nz, _LABEL_9A0E_
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jp z, _LABEL_9A6D_
	ld hl, $7B08
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_D6C0_)
	dec a
	jr z, +++
	ld a, (_RAM_D6CA_)
	dec a
	jr z, ++++
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $07
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
_LABEL_99D2_:
	ret

++++:
	ld hl, $7B1A
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD3_)
	ld c, a
	ld b, $00
	ld hl, _TEXT_A6EF_OpponentNames
	add hl, bc
	ld bc, $0007
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, $B6
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld a, (_RAM_DBD3_)
	cp $10
	jr z, +
	ld hl, $7B0E
	jp ++

+:
	ld hl, $7B0A
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
	ld hl, $7B08
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
	ld hl, $7B64
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_9B46_WhoDo
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7BE4
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_9B4E_YouWant
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7C64
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $07
	jr z, +
	jp ++

+:
	ld hl, _TEXT_9B5E_ToRace
	call _LABEL_A5B0_EmitToVDP_Text
	jp _LABEL_99D2_

++:
	ld hl, _TEXT_9B56_ToBe
	call _LABEL_A5B0_EmitToVDP_Text
	ret

_LABEL_9ABB_:
	ld hl, $7B64
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_9B66_Push
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7BE4
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_9B6E_StartTo
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7C64
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_9B76_Continue
	call _LABEL_A5B0_EmitToVDP_Text
	ret

_LABEL_9AE9_:
	ld hl, $7B64
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_9B7E_Handicap
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7BE6
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
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_9B18_:
	ld hl, $7B64
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_AAAE_Blanks
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7BE4
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0008
	ld hl, _TEXT_AAAE_Blanks
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7C64
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
	ld hl, $DBFE
	add hl, bc
	ld a, (hl)
	cp $58
	jr z, _LABEL_9C5D_
	cp $5A
	jr z, _LABEL_9C5D_
	ld a, $58
	ld (hl), a
	ld (_RAM_D6AA_), a
	ld hl, _DATA_97DF_
	add hl, bc
	ld a, (hl)
	ld (_RAM_DBD3_), a
	ld (_RAM_D6BB_), a
	ld hl, $DBD4
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
	jp z, _LABEL_973C_
	ld a, (_RAM_DC3C_IsGameGear)
	cp $01
	jr z, +
	ld hl, _DATA_975B_
	jp _LABEL_9700_

+:
	ld hl, _DATA_9767_
	jp _LABEL_9700_

; Data from 9C7F to 9D36 (184 bytes)
_DATA_9C7F_:
.dw $8B40 $8E10 $8B40 $1000
.dw $8B40 $8E10 $8E10 $1000
.dw $B2A0 $B570 $B2A0 $1000
.dw $B2A0 $B570 $B570 $1000
.dw $B840 $BB10 $B840 $1000
.dw $B840 $BB10 $BB10 $1000
.dw $9680 $9950 $9680 $1000
.dw $9680 $9950 $9950 $1000
.dw $A760 $AA30 $A760 $1000
.dw $A760 $AA30 $AA30 $1000
.dw $85A0 $8870 $85A0 $1000
.dw $85A0 $8870 $8870 $1000
.dw $AD00 $AFD0 $AD00 $1000
.dw $AD00 $AFD0 $AFD0 $1000
.dw $9C20 $9EF0 $9C20 $1000
.dw $9C20 $9EF0 $9EF0 $1000
.dw $A1C0 $A490 $A1C0 $1000
.dw $A1C0 $A490 $A490 $1000
.dw $8000 $82D0 $8000 $1000
.dw $8000 $82D0 $82D0 $1000
.dw $90E0 $93B0 $90E0 $1000
.dw $90E0 $93B0 $93B0 $1000
.dw $B93C $B66C $B93C $1000

; Data from 9D37 to 9D4D (23 bytes)
_DATA_9D37_:
.db $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B $0B
.db $0B $0B $0B $0B $0B $0B $05

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
	ld hl, _DATA_9DAD_
	add hl, bc
	ld a, (hl)
	out ($BF), a
	inc hl
	ld a, (hl)
	out ($BF), a
	ld a, (_RAM_D6B6_)
	jp _LABEL_9F81_

++++:
	ld a, (_RAM_D6B9_)
	sla a
	ld c, a
	ld b, $00
	ld hl, _DATA_9DB5_
	add hl, bc
	ld a, (hl)
	out ($BF), a
	inc hl
	ld a, (hl)
	out ($BF), a
	ld hl, (_RAM_D6A6_DisplayCase_Source)
	ld a, (_RAM_D6B6_)
	call _LABEL_9FAB_
	ld a, (_RAM_D6BA_)
	cp $00
	jr z, +
	call _LABEL_9E29_
+:
	ret

; Data from 9DAD to 9DB4 (8 bytes)
_DATA_9DAD_:
.db $80 $44 $40 $48 $00 $4C $C0 $4F

; Data from 9DB5 to 9DBC (8 bytes)
_DATA_9DB5_:
.db $60 $46 $20 $4A $E0 $4D $A0 $51

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
	cp $03
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
	ld (_RAM_D6AF_), a
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
	cp $0E
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
	ld hl, $DBD4
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
	ld hl, _DATA_97DF_
	add hl, bc
	ld a, (hl)
	ld (_RAM_D6BB_), a
	cp e
	jr nz, _LABEL_9F3F_ret
	ld hl, $DBFE
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
; a = ???
	ld (_RAM_D6A1_), a ; Save
  
	ld hl, _DATA_9D37_ ; Look up in table
	ld a, (_RAM_D6A1_)
	sra a ; Divide by 4
	sra a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl) ; Look up
	ld (_RAM_D741_RAMDecompressorPageIndex), a ; Save value found
  
	ld d, $00
	ld hl, _DATA_9C7F_ ; Look up in another table
	ld a, (_RAM_D6A1_)
	sla a ; *2
	ld e, a
	add hl, de
	ld a, (hl)
	ld c, a
	inc hl
	ld a, (hl)
	ld h, a
	ld l, c ; -> hl
  
	ld de, $003C
	ld a, (_RAM_D6A1_)
	cp $58
	jr z, _LABEL_9F74_
	jp $DA67	; Code is loaded from _LABEL_7465_

_LABEL_9F74_:
	ld hl, _DATA_BD6C_
	ld b, $10
	ld c, $BE
	otir
	dec e
	jr nz, _LABEL_9F74_
	ret

_LABEL_9F81_:
	ld (_RAM_D6A1_), a
	ld hl, _DATA_9D37_
	ld a, (_RAM_D6A1_)
	sra a
	sra a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld (_RAM_D6A5_), a
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld d, $00
	ld hl, _DATA_9C7F_
	ld a, (_RAM_D6A1_)
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
	ld a, (_RAM_D6A1_)
	cp $58
	jr z, _LABEL_9F74_
	jp $DA7C	; Code is loaded from _LABEL_3BC3C_

_LABEL_9FB8_:
	ld de, $0014
	ld a, (_RAM_D6A1_)
	cp $58
	jr z, _LABEL_9F74_
	jp $DA93	; Possibly invalid

_LABEL_9FC5_:
	ld a, (_RAM_DC3B_)
	or a
	jr z, +
	jp _LABEL_AA02_

+:
	ld bc, $0000
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld bc, $0140
+:
	ld a, (_RAM_D6CE_)
	or a
	jr z, +++
	ld a, (_RAM_D6AF_)
	sra a
	sra a
	and $01
	jp nz, +++
	ld a, (_RAM_D6CE_)
	cp $80
	jr z, +
	ld hl, $7C8C
	jp ++

+:
	ld hl, $7C8E
++:
	add hl, bc
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0003
	ld hl, _TEXT_A019_Pro
	jp _LABEL_A5B0_EmitToVDP_Text

+++:
	ld hl, $7C8C
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
	ld a, (_RAM_D6AF_)
	cp $00
	jr z, _LABEL_A0A3_
	sub $01
	ld (_RAM_D6AF_), a
	sra a
	sra a
	sra a
	and $01
	jp nz, +++
	ld hl, $7A90
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
	ld hl, $7AA2
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
	ld hl, $7A90
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
	ld hl, $7998
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0007
	ld hl, _TEXT_A0DB_Results
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $79CE
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC34_)
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

_LABEL_A0F0_:
	ld bc, $0000
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld bc, $0140
+:
	ld hl, $7A94
	add hl, bc
	ld bc, $000C
	ld de, $0009
--:
	call _LABEL_B35A_VRAMAddressToHL
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
	ld de, (_RAM_D6A8_)
	call _LABEL_B361_VRAMAddressToDE
	exx
	ld hl, (_RAM_D6A6_DisplayCase_Source)
	ld e, $50
	call $D985	; Code is loaded from _LABEL_3BB45_
	ld (_RAM_D6A6_DisplayCase_Source), hl
	exx
	ld hl, $0140
	add hl, de
	ld (_RAM_D6A8_), hl
	ld a, (_RAM_D693_)
	sub $01
	ld (_RAM_D693_), a
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_A14F_:
	ld a, (_RAM_DC3C_IsGameGear)
	xor $01
	rrca
	ld e, a
	ld d, $00
	ld a, (_RAM_DBD4_)
	srl a
	srl a
	srl a
	ld c, a
	ld b, $00
	call _LABEL_A1EC_
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $79CE
	add hl, de
	jp ++

+:
	ld hl, $7C8E
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $DC21
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	call _LABEL_A1CA_PrintHandicap
	jp ++

+:
	call _LABEL_A1D3_PrintOrdinary
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
	cp $11
	jr z, +
	ld hl, $79E2
	add hl, de
	jp ++

+:
	ld hl, $7CA2
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $DC21
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	call _LABEL_A1CA_PrintHandicap
	ret

+:
	call _LABEL_A1D3_PrintOrdinary
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
	cp $11
	jr z, +
	ld hl, $788E
	add hl, de
	jp ++

+:
	ld hl, $7B0E
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $DC0B
	add hl, bc
	call _LABEL_A272_
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $790E
	add hl, de
	jp ++

+:
	ld hl, $7B8E
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $DC16
	add hl, bc
	call _LABEL_A272_
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
	cp $11
	jr z, +
	ld hl, $78B0
	add hl, de
	jp ++

+:
	ld hl, $7B30
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $DC0B
	add hl, bc
	call _LABEL_A272_
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld a, e
	add a, $02
	ld e, a
+:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $7930
	add hl, de
	jp ++

+:
	ld hl, $7BB0
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
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
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B151
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $0138
	ld hl, $5760
	jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_A2AA_:
	ld a, (_RAM_DC3B_)
	dec a
	jr z, +++
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7B0E
	jr ++

+:
	ld hl, $7A4E
++:
	call _LABEL_B35A_VRAMAddressToHL
	jp ++++

+++:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $79CE
	jr ++

+:
	ld hl, $798E
++:
	call _LABEL_B35A_VRAMAddressToHL
	jp ++++

++++:
	ld a, (_RAM_D6AF_)
	sub $01
	ld (_RAM_D6AF_), a
	sra a
	sra a
	sra a
	sra a
	and $01
	jp nz, ++
	ld a, (_RAM_DC34_)
	dec a
	jr z, _LABEL_A302_
	ld a, (_RAM_DC3B_)
	dec a
	jr z, +
	ld hl, _TEXT_A325_SelectVehicle
	ld bc, $0010
	jp _LABEL_A5B0_EmitToVDP_Text

_LABEL_A302_:
	ld hl, _TEXT_A335_TournamentRace
	ld bc, $0010
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC35_)
	add a, $1A
	out ($BE), a
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
+:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $788C
	add hl, de
	jp ++

+:
	ld hl, $7B0C
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_A3EA_
	ld de, $0000
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld e, $7A
+:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $790C
	add hl, de
	jp ++

+:
	ld hl, $7B8C
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_A402_
	ld de, $0000
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld e, $80
+:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $78AE
	add hl, de
	jp ++

+:
	ld hl, $7B2E
	add hl, de
++:
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_A3EA_
	ld de, $0000
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld e, $80
+:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $11
	jr z, +
	ld hl, $792E
	add hl, de
	jp ++

+:
	ld hl, $7BAE
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

_DATA_A427_:
.db $3A $3C $DC $3D $28 $05 $11 $08 $7D $18 $03
.db $11 $0C $7C $CD $61 $B3 $01 $08 $00 $21 $9D $A4 $CD $B0 $A5 $21
.db $46 $00 $19 $CD $5A $B3 $01 $02 $00 $21 $B5 $A4 $CD $B0 $A5 $21
.db $80 $00 $19 $CD $5A $B3 $01 $08 $00 $21 $A5 $A4 $CD $B0 $A5 $3A
.db $3C $DC $3D $28 $05 $11 $28 $7D $18 $03 $11 $24 $7C $CD $61 $B3
.db $01 $08 $00 $21 $9D $A4 $CD $B0 $A5 $21 $46 $00 $19 $CD $5A $B3
.db $01 $02 $00 $21 $B5 $A4 $CD $B0 $A5 $21 $80 $00 $19 $CD $5A $B3
.db $01 $08 $00 $21 $AD $A4 $CD $B0 $A5 $C9 $0F $0B $00 $18 $04 $11
.db $0E $1B $0F $0B $00 $18 $04 $11 $0E $1C $02 $1A $0C $0F $14 $13
.db $04 $11 $15 $12

_LABEL_A4B7_:
	ld hl, $7A54
	call _LABEL_A500_
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $13
	jr z, +
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7B06
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $001A
	ld hl, _TEXT_A4E6_OnePlayerTwoPlayer
	call _LABEL_A5B0_EmitToVDP_Text
+:
	ret

; Data from A4DA to A4E5 (12 bytes)
_TEXT_A4DA_SelectGame:
.asc "SELECT  GAME" ; $12 $04 $0B $04 $02 $13 $0E $0E $06 $00 $0C $04

; Data from A4E6 to A4FF (26 bytes)
_TEXT_A4E6_OnePlayerTwoPlayer:
.asc "ONE PLAYER      TWO PLAYER" ; $1A $0D $04 $0E $0F $0B $00 $18 $04 $11 $0E $0E $0E $0E $0E $0E $13 $16 $1A $0E $0F $0B $00 $18 $04 $11

_LABEL_A500_:
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000C
	ld hl, _TEXT_A4DA_SelectGame
	jp _LABEL_A5B0_EmitToVDP_Text

_LABEL_A50C_:
	ld hl, $7990
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000F
	ld hl, _TEXT_A521_OnePlayerGame
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7A14
	jp _LABEL_A500_

; Data from A521 to A52F (15 bytes)
_TEXT_A521_OnePlayerGame:
.asc "ONE PLAYER GAME" ; $1A $0D $04 $0E $0F $0B $00 $18 $04 $11 $0E $06 $00 $0C $04

_LABEL_A530_:
	ld hl, $79D4
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000C
	ld hl, _TEXT_A574_ChooseGame
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7D86
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $001A
	ld hl, _TEXT_A580_TournamentSingleRace
	call _LABEL_A5B0_EmitToVDP_Text
	ret

+:
	ld hl, $7C4C
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0012
	ld hl, _TEXT_A59A_TournamentSingle
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7CAC
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
	out ($BE), a
	rlc a
	and $01
	out ($BE), a
	inc hl
	dec c
	jr nz, _LABEL_A5B0_EmitToVDP_Text
	ret

_LABEL_A5BE_:
	ld a, $30
	ld (_RAM_D6AF_), a
	ld a, $01
	ld (_RAM_D6C6_), a
	ret

_LABEL_A5C9_:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld de, $7986
	ld bc, $0006
	ld hl, _TEXT_A664_Player
	jr ++

+:
	ld de, $798C
	ld bc, $0003
	ld hl, _TEXT_A66A_Plr
++:
	call _LABEL_B361_VRAMAddressToDE
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7A0C
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0003
	ld hl, _TEXT_A66D_One
	call _LABEL_A5B0_EmitToVDP_Text
	ret

_LABEL_A5F9_:
	ld hl, $7986
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0006
	ld hl, _TEXT_AAAE_Blanks
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7A0C
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
	ld hl, $7A2E
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0003
	ld hl, _TEXT_A670_Two
	call _LABEL_A5B0_EmitToVDP_Text
	ret

_LABEL_A645_:
	ld hl, $79AE
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $0006
	ld hl, _TEXT_AAAE_Blanks
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7A2E
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
	out ($BF), a
	ld a, $86
	out ($BF), a
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
	ld a, (_RAM_D6AF_)
	cp $00
	jr z, ++
	sub $01
	ld (_RAM_D6AF_), a
	sra a
	sra a
	sra a
	and $01
	jp nz, +++
	ld hl, $7C10
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
	ld de, $7C12
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
	ld hl, $7C0E
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
	ld (_RAM_DBE8_), a
	ld (_RAM_DBEC_), a
	ld (_RAM_DBF0_), a
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
	ld a, (_RAM_D6AF_)
	cp $00
	jr z, +++
	sub $01
	ld (_RAM_D6AF_), a
	sra a
	sra a
	sra a
	and $01
	jr nz, ++++
	call _LABEL_A859_
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
	call _LABEL_A859_
	ld hl, _TEXT_AAAE_Blanks
	ld bc, $0007
	jp _LABEL_A5B0_EmitToVDP_Text

; Data from A83A to A841 (8 bytes)
_DATA_A83A_:
.db $90 $7A $A2 $7A $90 $7C $A4 $7C

; Data from A842 to A849 (8 bytes)
_DATA_A842_:
.db $82 $7A $B0 $7A $04 $7D $30 $7D

; Data from A84A to A858 (15 bytes)
_TEXT_A84A_QualifyFailed:
.asc "QUALIFY", $FF 
.asc "FAILED "

_LABEL_A859_:
	ld a, (_RAM_DBCF_LastRacePosition)
	sla a
	ld c, a
	ld b, $00
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, _DATA_A842_
	jr ++

+:
	ld hl, _DATA_A83A_
++:
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	call _LABEL_B361_VRAMAddressToDE
	ret

_LABEL_A877_:
	ld a, $04
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $BC42
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $00C0
	ld hl, $6000
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
	call _LABEL_BA42_
	ld a, (_RAM_DC3C_IsGameGear)
	xor $01
	rrca
	ld c, a
	ld b, $00
	xor a
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld hl, $790C
	add hl, bc
	ld a, $03
	ld (_RAM_D69B_TilemapRectangleSequence_Height), a
	ld a, $02
	ld (_RAM_D69A_TilemapRectangleSequence_Width), a
	ld a, $01
	ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld a, $06
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld hl, $7930
	add hl, bc
	ld a, $03
	ld (_RAM_D69B_TilemapRectangleSequence_Height), a
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld a, (_RAM_DC3C_IsGameGear)
	xor $01
	ld b, a
	ld c, $00
	ld a, $0C
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld hl, $7B0C
	add hl, bc
	ld a, $03
	ld (_RAM_D69B_TilemapRectangleSequence_Height), a
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld a, $12
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld hl, $7B30
	add hl, bc
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

+:
	ld a, (_RAM_DBCF_LastRacePosition)
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
	ld (_RAM_D6AF_), a
	ld b, $00
	call _LABEL_A9C6_
	call _LABEL_B375_ConfigureTilemapRect_5x6_24
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $A9AE
	jr ++

+:
	ld hl, _DATA_A9A6_
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
	ld hl, _DATA_A9AE_
	jr ++

+:
	ld hl, _DATA_A9A6_
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
	ld hl, _DATA_A9AE_
	jr ++

+:
	ld hl, _DATA_A9A6_
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
	ld hl, _DATA_A9AE_
	jr ++

+:
	ld hl, _DATA_A9A6_
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
_DATA_A9A6_:
.db $12 $79 $24 $79 $12 $7B $24 $7B

; Data from A9AE to A9B5 (8 bytes)
_DATA_A9AE_:
.db $92 $79 $A4 $79 $12 $7C $24 $7C

; Data from A9B6 to A9BD (8 bytes)
_DATA_A9B6_:
.db $0E $7A $30 $7A $0E $7C $30 $7C

; Data from A9BE to A9C5 (8 bytes)
_DATA_A9BE_:
.db $16 $7B $28 $7B $96 $7D $A8 $7D

_LABEL_A9C6_:
	ld a, c
	sla a
	ld e, a
	ld d, $00
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, _DATA_A9BE_
	jr ++

+:
	ld hl, _DATA_A9B6_
++:
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	call _LABEL_B361_VRAMAddressToDE
	ld a, b
	add a, $18
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_A9EB_:
	ld a, (_RAM_D6AF_)
	cp $00
	jr z, _LABEL_AA5D_
	sub $01
	ld (_RAM_D6AF_), a
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
	ld hl, _DATA_AB06_
	add hl, bc
	ld a, (hl)
	ld (_RAM_DBF6_), a
	inc hl
	ld a, (hl)
	ld (_RAM_DBF7_), a
	ld hl, _DATA_AACE_
	add hl, bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, b
	ld l, c
	ld a, $03
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld a, (_RAM_DBD8_CourseSelectIndex)
	cp $19
	jr z, +++
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld de, $7B16
	call _LABEL_B361_VRAMAddressToDE
	ld bc, $0014
	ld de, $7B04
	jr ++

+:
	ld de, $7A4C
	call _LABEL_B361_VRAMAddressToDE
	ld bc, $0014
	ld de, $7A18
++:
	call $DAAA	; Code is loaded from _LABEL_BDD_
	call _LABEL_B361_VRAMAddressToDE
	ld bc, $0008
	ld hl, $DBF1
	call $DAAA	; Code is loaded from _LABEL_BDD_
_LABEL_AA5D_:
	ret

+++:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7B00
	ld bc, $001E
	jr ++

+:
	ld hl, $7A52
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000F
	ld hl, $BFB0
	call $DAAA	; Code is loaded from _LABEL_BDD_
	ld hl, $7A12
	ld bc, $000F
++:
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $BFA1
	call $DAAA	; Code is loaded from _LABEL_BDD_
	ret

_LABEL_AA8B_:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7AC0
	jr ++

+:
	ld hl, $7A00
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
.db $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E
.db $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E $0E

; Data from AACE to AB05 (56 bytes)
_DATA_AACE_:
.db $C1 $BD $D5 $BD $E9 $BD $FD $BD $11 $BE $25 $BE $39 $BE $4D $BE
.db $61 $BE $75 $BE $89 $BE $9D $BE $B1 $BE $C5 $BE $D9 $BE $ED $BE
.db $01 $BF $15 $BF $29 $BF $3D $BF $51 $BF $65 $BF $79 $BF $8D $BF
.db $BF $BF $BF $BF $BF $BF $BF $BF

; Data from AB06 to AB2B (38 bytes)
_DATA_AB06_:
.db $0E $1B $0E $1C $0E $1D $0E $1E $0E $1F $0E $20 $0E $21 $0E $22
.db $0E $23 $00 $00 $1B $1A $1B $1B $1B $1C $1B $1D $1B $1E $1B $1F
.db $00 $00 $1B $20 $1B $21

; Data from AB2C to AB3D (18 bytes)
_DATA_AB2C_:
.db $1B $22 $1B $23 $00 $00 $1C $1A $1C $1B $1C $1C $1C $1D $1C $1E
.db $1C $1F

; Data from AB3E to AB4C (15 bytes)
_DATA_AB3E_:
.db $04 $01 $05 $07 $04 $03 $05 $02 $07 $06 $04 $02 $08 $03 $01

; Data from AB4D to AB5A (14 bytes)
_DATA_AB4D_:
.db $07 $06 $05 $08 $01 $02 $06 $03 $08 $01 $09 $09 $09 $02

_LABEL_AB5B_:
	ld a, (_RAM_DBD8_CourseSelectIndex)
	sub $01
	ld c, a
	ld b, $00
	ld hl, _DATA_AB3E_
	add hl, bc
	ld a, (hl)
_LABEL_AB68_:
	ld (_RAM_D691_), a
	sla a
	ld de, _DATA_9254_
	add a, e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, (de)
	ld (_RAM_D7B5_DecompressorSource), a
	inc de
	ld a, (de)
	ld (_RAM_D7B6_), a
	ld hl, $C000
	ld (_RAM_D6A6_DisplayCase_Source), hl
	ret

_LABEL_AB86_:
  ; Decompresses data from 
	ld a, (_RAM_D691_)
	call _LABEL_B478_SelectPageNumber
	ld hl, (_RAM_D7B5_DecompressorSource)
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $6000 ; Tile $100
	ld de, $0280 ; 80 * 8 rows
	jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_AB9B_:
	ld a, (_RAM_D691_)
	call _LABEL_B478_SelectPageNumber
	ld hl, (_RAM_D7B5_DecompressorSource)
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $6C00 ; Tile $160
	ld de, $0280 ; 80 * 8 rows
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
	cp $10
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
	ld hl, $7BD6
	jr ++

+:
	ld hl, $7A96
++:
	xor a
	ld (_RAM_D68B_), a
--:
	call _LABEL_B35A_VRAMAddressToHL
	ld de, $000A
-:
	ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld a, (_RAM_D68A_TilemapRectangleSequence_TileIndex)
	add a, $01
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	dec de
	ld a, d
	or e
	jr nz, -
	ld a, (_RAM_D68B_)
	cp $07
	jr z, +
	add a, $01
	ld (_RAM_D68B_), a
	ld de, $0040
	add hl, de
	jp --

+:
	call _LABEL_9276_
	ret

_LABEL_AC1E_:
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +++
	ld hl, $4480
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD4_)
	ld (_RAM_D6BB_), a
	call _LABEL_9F40_
	call _LABEL_B375_ConfigureTilemapRect_5x6_24
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7902
	jr ++

+:
	ld hl, $794C
	call _LABEL_B2B3_
++:
	call _LABEL_BCCF_EmitTilemapRectangleSequence
+++:
	ld hl, $4840
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC3F_)
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
	ld hl, $7912
	jr ++

+:
	ld hl, $7956
	call _LABEL_B2B3_
++:
	or a
	sbc hl, de
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld hl, $4C00
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC3F_)
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
	ld hl, $7922
	jr ++

+:
	ld hl, $7960
	call _LABEL_B2B3_
++:
	add hl, de
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +++
	ld hl, $4FC0
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DBD7_)
	call _LABEL_9F40_
	ld a, $7E
	call _LABEL_B377_ConfigureTilemapRect_5x6_rega
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7932
	jr ++

+:
	ld hl, $796A
	call _LABEL_B2B3_
++:
	call _LABEL_BCCF_EmitTilemapRectangleSequence
+++:
	ret

_LABEL_ACEE_:
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +
	ld hl, $7A86
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, $7A96
	ld bc, $7AA6
	ld de, $7AB6
	jr ++

+:
	ld hl, $7A92
	call _LABEL_B35A_VRAMAddressToHL
	ld de, $7AAA
	jr ++

++:
	ld a, $50
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +
	call _LABEL_B35A_VRAMAddressToHL
	ld a, $51
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld h, b
	ld l, c
	call _LABEL_B35A_VRAMAddressToHL
	ld a, $52
	out ($BE), a
	ld a, $01
	out ($BE), a
+:
	call _LABEL_B361_VRAMAddressToDE
	ld a, $53
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_AD42_DrawDisplayCase:
	ld a, :_DATA_3B37F_DisplayCaseTilesCompressed ; $0E
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, _DATA_3B37F_DisplayCaseTilesCompressed ; $B37F - compressed 3bpp tile data, 2952 bytes = 123 tiles up to $3b970
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $6000 ; Tile $100
	ld de, $03D8 ; 123 * 8 rows
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
	ld a, :_DATA_3B32F_DisplayCaseTilemapCompressed ; $0E
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, _DATA_3B32F_DisplayCaseTilemapCompressed ; $B32F - compressed data, 440 bytes up to $3b37e
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
  
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
	call $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle

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
	ld (_RAM_D741_RAMDecompressorPageIndex), a ; Unused?

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
	call $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle
	ld bc, (_RAM_D6BC_DisplayCase_IndexBackup) ; Restore bc (?)
	ret

_LABEL_AE94_DisplayCase_RestoreRectangle:
	ld a, $0D
	ld (_RAM_D741_RAMDecompressorPageIndex), a ; Unused?

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
	jp $DABD	; Code is loaded from _LABEL_3BC7D_DisplayCase_RestoreRectangle

_LABEL_AECD_:
	ld hl, (_RAM_D6A8_)
	ld bc, $0320
	add hl, bc
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _DATA_9D37_
	ld a, (_RAM_D6BB_)
	sra a
	sra a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld (_RAM_D6A5_), a
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld d, $00
	ld hl, _DATA_9C7F_
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
	ld e, $28
	call $DAEF	; Code is loaded from _LABEL_03BCAF_
	ld a, $00
	ld (_RAM_D6A4_), a
	ld (_RAM_D6B0_), a
	ret

_LABEL_AF10_:
	ld a, (_RAM_DC3C_IsGameGear)
	or a
	ret z
	in a, ($05)
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
	out ($03), a
	ret

+:
	ld a, $01
	ld (_RAM_DC42_GearToGear_IAmPlayer1), a
	ld (_RAM_DC41_GearToGearActive), a
	ld a, $55
	out ($03), a
	jr _LABEL_AF5D_

++:
	xor a
	ld (_RAM_DC42_GearToGear_IAmPlayer1), a
	ld a, $01
	ld (_RAM_DC41_GearToGearActive), a
	ld c, $01
	call _LABEL_B1EC_
	jr _LABEL_AF5D_

; Data from AF4F to AF4F (1 bytes)
.db $C9 ; ret

+++:
	call _LABEL_AF92_
	xor a
	ld (_RAM_DC41_GearToGearActive), a
	ld a, $00
	ld (_RAM_DC42_GearToGear_IAmPlayer1), a
	ret

_LABEL_AF5D_:
	ld a, NO_BUTTONS_PRESSED
	ld (_RAM_DC47_GearToGear_OtherPlayerControls1), a
	ld (_RAM_DC48_GearToGear_OtherPlayerControls2), a
	ld (_RAM_D680_Player1Controls_Menus), a
	ld (_RAM_D681_Player2Controls_Menus), a
	ld (_RAM_D687_Player1Controls_PreviousFrame), a
	ret

_LABEL_AF6F_:
	ld a, (_RAM_D7BA_)
	inc a
	and $0F
	ld (_RAM_D7BA_), a
	and $08
	jr z, _LABEL_AF92_
	ld hl, $7A5A
	call _LABEL_B35A_VRAMAddressToHL
	ld c, $05
	ld hl, _TEXT_AFA0_Link
	call _LABEL_A5B0_EmitToVDP_Text
	ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
	add a, $1B
	out ($BE), a
	ret

_LABEL_AF92_:
	ld hl, $7A5A
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
	jp $D971	; Code is loaded from _LABEL_3BB31_Emit3bppTileDataToVRAM

_LABEL_AFAE_RamCodeLoader:
  ; Trampoline for calling paging code
	ld hl, +	; Loading Code into RAM
	ld de, _RAM_D640_RamCodeLoader
	ld bc, $0011
	ldir
	jp _RAM_D640_RamCodeLoader	; Code is loaded from +

; Executed in RAM at d640
+:
	ld a, :_LABEL_3B971_RamCodeLoaderStage2
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld ($8000), a ; page in and call
	call _LABEL_3B971_RamCodeLoaderStage2
	ld a, $02 ; restore paging
	ld ($8000), a
	ret

_LABEL_AFCD_:
	call _LABEL_BB85_
	ld a, $13
	ld (_RAM_D699_MenuScreenIndex), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_B337_
	call _LABEL_9400_
	call _LABEL_BAFF_
	call _LABEL_959C_
	ld a, $B2
	ld (_RAM_D6C8_), a
	call _LABEL_9448_
	call _LABEL_94AD_
	call _LABEL_B305_
	ld c, $07
	call _LABEL_B1EC_
	xor a
	ld (_RAM_D6C7_), a
	call _LABEL_BB95_
	call _LABEL_BC0C_
	call +
	call _LABEL_A50C_
	call _LABEL_9317_
	xor a
	ld (_RAM_D6A0_), a
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
	in a, ($00)
	add a, a
	ret c
	ld a, :_DATA_3F753_JonsSquinkyTennisCompressed ;$0F
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, _DATA_3F753_JonsSquinkyTennisCompressed ;$B753 Up to $3ff78, compressed code (Jon's Squinky Tennis, 5923 bytes)
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	jp _RAM_C000_DecompressionTemporaryBuffer ; $C000	; Possibly invalid

+:
	ld a, :_DATA_23656_ ; $08
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, _DATA_23656_ ; $B656 Up to $237e1, 864 bytes compressed
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $7000 ; Tile $180
	ld de, $0120 ; 36 * 8 rows
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7B6C ; 22, 13 (GG)
	jr ++
+:ld hl, $7AA8 ; 20, 10 (SMS)
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
_LABEL_B06C_:
	call _LABEL_B9C4_
	call _LABEL_8CA2_
	ld a, (_RAM_D6A0_)
	or a
	jp z, _LABEL_80FC_MenuScreenHandler_Null
	ld a, (_RAM_D6C9_ControllingPlayersLR1Buttons)
	and BUTTON_1_MASK ; $10
	jp nz, _LABEL_80FC_MenuScreenHandler_Null
	call _LABEL_B1F4_
	ld a, (_RAM_D6A0_)
	dec a
	jr nz, +
	xor a
	ld (_RAM_DC3F_), a
	call _LABEL_8205_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	ld a, $01
	ld (_RAM_DC3F_), a
	call _LABEL_8953_
	jp _LABEL_80FC_MenuScreenHandler_Null

; 15th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_B09F_:
	ld a, (_RAM_D688_)
	or a
	jr z, +
	dec a
	ld (_RAM_D688_), a
	jp _LABEL_80FC_MenuScreenHandler_Null

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
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	ld a, (_RAM_D6AC_)
	add a, $01
	ld (_RAM_D6AC_), a
	cp $30
	jr z, +
	dec a
	call z, _LABEL_A645_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_B1F4_
	ld a, (_RAM_DC3F_)
	dec a
	jr z, +
	call _LABEL_89E2_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	ld a, (_RAM_DBD8_CourseSelectIndex)
	or a
	jr nz, +
	ld (_RAM_D6AB_), a
	ld a, $09
	ld (_RAM_D699_MenuScreenIndex), a
	ld a, $01
	ld (_RAM_D6C1_), a
	call _LABEL_9400_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	jp _LABEL_84AA_

_LABEL_B110_:
	ld a, (_RAM_D6CD_)
	cp $02
	jp z, _LABEL_80FC_MenuScreenHandler_Null
	add a, $01
	ld (_RAM_D6CD_), a
	dec a
	jr z, +
	dec a
	jr z, ++
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_A645_
	jp _LABEL_80FC_MenuScreenHandler_Null

++:
	call _LABEL_A5C9_
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_B132_:
	ld a, (_RAM_D6CD_)
	cp $02
	jp z, _LABEL_80FC_MenuScreenHandler_Null
	add a, $01
	ld (_RAM_D6CD_), a
	dec a
	jr z, +
	dec a
	jr z, ++
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_A5F9_
	jp _LABEL_80FC_MenuScreenHandler_Null

++:
	call _LABEL_A618_
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_B154_:
	ld a, (_RAM_DC3F_)
	or a
	jr z, +
	xor a
	ld (_RAM_D6CB_), a
	jp +++

+:
	ld a, (_RAM_D6AF_)
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
	ld hl, $DC21
	add hl, bc
	ld a, (_RAM_D6CB_)
	ld (hl), a
	call _LABEL_9E52_
_LABEL_B1B6_Select:
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_B1B9_Left:
	xor a
	ld (_RAM_D6CB_), a
	call _LABEL_B389_
	ld bc, $0005
	call _LABEL_A5B0_EmitToVDP_Text
	jp _LABEL_80FC_MenuScreenHandler_Null

_Right:
	ld a, $01
	ld (_RAM_D6CB_), a
	call _LABEL_B389_
	ld hl, _TEXT_B1E7_Yes
	ld bc, $0005
	call _LABEL_A5B0_EmitToVDP_Text
	jp _LABEL_80FC_MenuScreenHandler_Null

; Data from B1DD to B1E6 (10 bytes)
_TEXT_B1DD_No:
.asc "-NO- " ; $B5 $0D $1A $B5 $0E 

_TEXT_B1E2_No:
.asc " -NO-" ; $0E $B5 $0D $1A $B5

; Data from B1E7 to B1EB (5 bytes)
_TEXT_B1E7_Yes:
.asc "-YES-" ; $B5 $18 $04 $12 $B5

_LABEL_B1EC_:
	ld a, $0C
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	jp $DB1C	; Code is loaded from _LABEL_3BCDC_

_LABEL_B1F4_:
	ld a, $0C
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	jp $DB26	; Code is loaded from _LABEL_3BCE6_

_LABEL_B1FC_:
	ld a, (_RAM_DC34_)
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
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	ld a, (_RAM_DC3C_IsGameGear)
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
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_95AF_
	ld hl, $7D80
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_95AF_
_LABEL_B305_:
	ld hl, $7840
	call _LABEL_B35A_VRAMAddressToHL
	jp _LABEL_95AF_

_LABEL_B30E_:
	ld a, $01
	ld (_RAM_D6C0_), a
-:
	ld a, $40
	ld (_RAM_D6AF_), a
	ld a, (_RAM_D6B9_)
	ret

_LABEL_B31C_:
	xor a
	ld (_RAM_D6C0_), a
	jp -

_LABEL_B323_:
	ld hl, _DATA_97DF_
	ld de, _RAM_DBFE_
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
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $2000
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	ld hl, $6000
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $1700
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

_LABEL_B35A_VRAMAddressToHL:
	ld a, l
	out ($BF), a
	ld a, h
	out ($BF), a
	ret

_LABEL_B361_VRAMAddressToDE:
	ld a, e
	out ($BF), a
	ld a, d
	out ($BF), a
	ret

_LABEL_B368_:
	ld a, $01
	ld (_RAM_D6C1_), a
	xor a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6C5_), a
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
	ld hl, $7B2C
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _TEXT_B1DD_No
	jr ++

+:
	ld hl, $7C6A
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
	ld hl, _DATA_9773_
	add hl, de
	ld (_RAM_D6BE_), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	call _LABEL_B361_VRAMAddressToDE
	ld (_RAM_D6A8_), de
	ld hl, _DATA_97DF_
	add hl, bc
	ld a, (hl)
	ld (_RAM_D6BB_), a
	ld hl, $DBFE
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

_LABEL_B44E_:
	ld bc, $013C
	ld hl, _RAM_D680_Player1Controls_Menus
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
	ld a, (_RAM_D6D4_) ; Only if 1
	or a
	jp z, +
	ld a, (_RAM_D691_)
	call _LABEL_B478_SelectPageNumber
	ld hl, (_RAM_D7B5_DecompressorSource)
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	xor a
	ld (_RAM_D6D4_), a
	ld (_RAM_D6D3_VBlankDone), a
+:
	ret

_LABEL_B478_SelectPageNumber:
  ; Indexes into a table with a to select the page number for a subsequent call to RAM code
	ld e, a
	ld d, $00
	ld hl, _DATA_926C_PageNumbers
	add hl, de
	ld a, (hl)
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ret

_LABEL_B484_:
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
; $3e = %00111110 = U
; $3d = %00111101 = D
; $3b = %00111011 = L
; $37 = %00110111 = R
; $3b = %00111011 = L

; Data from B4BA to B4BF (6 bytes)
_DATA_B4BA_: ; erroneous label?
.db BUTTON_2_ONLY
.db BUTTON_U_ONLY
.db BUTTON_U_ONLY
.db BUTTON_2_ONLY
.db BUTTON_U_ONLY
.db 0
; $1f = %00011111 = 2
; $3e = %00111110 = U
; $3e = %00111110 = U
; $1f = %00011111 = 2
; $3e = %00111110 = U
; 0               = end

_CheckForCheatCode_HardMode:
	ld a, (_RAM_D6D0_TitleScreenCheatCodeCounterHardMode) ; Get index of next button press
	ld c, a
	ld b, $00
	ld hl, _DATA_B4AB_CheatKeys_HardMode  ; Look up the button press
	add hl, bc
	ld a, (hl)
	cp e  ; Compare to what we have
	jr nz, +
	ld a, (_RAM_D6D0_TitleScreenCheatCodeCounterHardMode) ; If it matches, increase the index
	add a, $01
	ld (_RAM_D6D0_TitleScreenCheatCodeCounterHardMode), a
	ld a, $01
	ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
	ret

+:; If no match, reset the counter
	xor a
	ld (_RAM_D6D0_TitleScreenCheatCodeCounterHardMode), a
	ret

_CheckForCheatCode_CourseSelect:
	ld a, (_RAM_DC45_TitleScreenCheatCodeCounterCourseSelect) ; Get index of next button press
	ld c, a
	ld b, $00
	ld hl, _DATA_B4B5_CheatKeys_CourseSelect ; Look up the button press
	add hl, bc
	ld a, (hl)
	or a
	jr z, +
	cp e
	jr nz, +
	ld a, (_RAM_DC45_TitleScreenCheatCodeCounterCourseSelect) ; If it matches, increase the index
	add a, $01
	ld (_RAM_DC45_TitleScreenCheatCodeCounterCourseSelect), a
	ld a, $01
	ld (_RAM_D6D1_TitleScreenCheatCodes_ButtonPressSeen), a
	ret

+:
	xor a
	ld (_RAM_DC45_TitleScreenCheatCodeCounterCourseSelect), a
	ret

_LABEL_B505_:
	ld a, (_RAM_DC46_Cheat_HardMode)
	or a
	ret z
	ld hl, $7A52
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_D7BA_)
	inc a
	and $0F
	ld (_RAM_D7BA_), a
	and $08
	jr z, +++
	ld a, (_RAM_DC46_Cheat_HardMode)
	cp $01
	jr z, +
	cp $02
	jr z, ++
	ret

+:
	ld c, $0C
	ld hl, _TEXT_B541_HardMode
	jp _LABEL_A5B0_EmitToVDP_Text

++:
	ld c, $0E
	ld hl, _TEXT_B54D_RockHardMode
	jp _LABEL_A5B0_EmitToVDP_Text

+++:
	ld c, $0E
	ld hl, _TEXT_AAAE_Blanks
	jp _LABEL_A5B0_EmitToVDP_Text

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
_LABEL_B56D_:
	call _LABEL_B9C4_
	call _LABEL_A2AA_
	call _LABEL_9FC5_
	ld a, (_RAM_D6C1_)
	cp $01
	jr z, _LABEL_B5E7_
	ld a, (_RAM_DC34_)
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
	call _LABEL_9400_
	jp _LABEL_B618_

_LABEL_B5E7_:
	ld a, (_RAM_D6AB_)
	add a, $01
	ld (_RAM_D6AB_), a
	cp $04
	jr nz, _LABEL_B618_
	xor a
	ld (_RAM_D6AB_), a
	ld a, (_RAM_D6C5_)
	cp $FF
	jr z, +
	call _LABEL_BD2F_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_B1F4_
	ld a, (_RAM_DC3B_)
	dec a
	jr z, +
	call _LABEL_B1FC_
	ld a, $01
	ld (_RAM_DC3D_IsHeadToHead), a
	ld (_RAM_D6D5_), a
_LABEL_B618_:
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	ld a, $01
	ld (_RAM_D6D5_), a
	jp _LABEL_80FC_MenuScreenHandler_Null

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
	ld a, (_RAM_DC3B_)
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
	call _LABEL_AB5B_
	call _LABEL_AA8B_
	jp +++++

_LABEL_B666_:
	ld a, (_RAM_DC3B_)
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
	call _LABEL_AB5B_
	call _LABEL_AA8B_
	jp +++++

++++:
	call _LABEL_A01C_
	call _LABEL_AB68_
+++++:
	call _LABEL_A0F0_
	ld a, $01
	ld (_RAM_D6D4_), a
	ld a, $09
	ld (_RAM_D693_), a
	ld de, $6C00
	ld (_RAM_D6A8_), de
	ld a, $01
	ld (_RAM_D697_), a
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_B6AB_:
	call _LABEL_ABB3_
	jp _LABEL_80FC_MenuScreenHandler_Null

; 18th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_B6B1_:
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
	call _LABEL_B1F4_
	ld a, (_RAM_DC34_)
	dec a
	jr z, +++
	call _LABEL_8114_Menu0
++:
	jp _LABEL_80FC_MenuScreenHandler_Null

+++:
	ld a, (_RAM_DC36_)
	cp $04
	jr z, +
	ld a, (_RAM_DC37_)
	cp $04
	jr z, +
	ld a, (_RAM_DC35_)
	cp $07
	jr z, +
	add a, $01
	ld (_RAM_DC35_), a
	call _LABEL_8A30_
	jp _LABEL_80FC_MenuScreenHandler_Null

+:
	call _LABEL_B877_
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_B70B_:
	call _LABEL_BB85_
	ld a, $10
	ld (_RAM_D699_MenuScreenIndex), a
	ld e, $0E
	call _LABEL_9170_
	call _LABEL_9400_
	call _LABEL_90CA_
	call _LABEL_BAFF_
	call _LABEL_959C_
	call _LABEL_A296_
	ld a, $01
	ld (_RAM_DC3B_), a
	ld (_RAM_D6CC_), a
	ld (_RAM_DBD8_CourseSelectIndex), a
	ld a, $B2
	ld (_RAM_D6C8_), a
	call _LABEL_9448_
	call _LABEL_94AD_
	ld hl, $7840
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_95AF_
	ld a, $60
	ld (_RAM_D6AF_), a
	xor a
	ld (_RAM_D6AB_), a
	ld (_RAM_D6AC_), a
	ld (_RAM_D6C1_), a
	ld (_RAM_D693_), a
	ld (_RAM_D6CE_), a
	call _LABEL_AB5B_
	call _LABEL_AB9B_
	call _LABEL_ABB0_
	ld c, $07
	call _LABEL_B1EC_
	call _LABEL_A673_
	call _LABEL_9317_
	ld hl, $B356
	call $D9F5	; Code is loaded from _LABEL_3BBB5_
	call _LABEL_BF2E_
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
	cp $11
	jr z, +
	ld hl, $78DC
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC36_)
	call _LABEL_B7F1_
	ld hl, $791C
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_B7F9_
	ld hl, $78E2
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC37_)
	call _LABEL_B7F1_
	ld hl, $7922
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	jp _LABEL_B7F9_

+:
	ld hl, $7B5C
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC36_)
	call _LABEL_B7F1_
	ld hl, $7B9C
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	call _LABEL_B7F9_
	ld hl, $7B62
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC37_)
	call _LABEL_B7F1_
	ld hl, $7BA2
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
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

; 19th entry of Jump Table from 80BE (indexed by _RAM_D699_MenuScreenIndex)
_LABEL_B84D_:
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
	call _LABEL_B1F4_
	call _LABEL_8114_Menu0
++:
	jp _LABEL_80FC_MenuScreenHandler_Null

_LABEL_B877_:
	call _LABEL_BB85_
	ld a, $12
	ld (_RAM_D699_MenuScreenIndex), a
	ld a, $B2
	ld (_RAM_D6C8_), a
	call _LABEL_B2DC_
	call _LABEL_B305_
	call _LABEL_B8CF_
	call _LABEL_B8E3_
	ld hl, $4480
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC34_)
	or a
	jr nz, +
	ld c, $03
	call _LABEL_B1EC_
	jp ++

+:
	ld c, $0C
	call _LABEL_B1EC_
	ld a, (_RAM_DBCF_LastRacePosition)
	or a
	jr z, ++
	ld a, (_RAM_DBD5_)
	jp +++

++:
	ld a, (_RAM_DBD4_)
+++:
	call _LABEL_9F40_
	ld hl, $7B26 ; Tilemap 19, 12
	call _LABEL_B8C9_EmitTilemapRectangle_5x6_24
	xor a
	ld (_RAM_D6AB_), a
	call _LABEL_BB75_
	ret

_LABEL_B8C9_EmitTilemapRectangle_5x6_24:
	call _LABEL_B375_ConfigureTilemapRect_5x6_24
	jp _LABEL_BCCF_EmitTilemapRectangleSequence

_LABEL_B8CF_:
	ld a, $06
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B2C3
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $6C00
	ld de, $0290
	jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_B8E3_:
	ld a, $09
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B9F0
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $7A8E
	call _LABEL_B35A_VRAMAddressToHL
	ld de, $7A8E
	ld hl, _RAM_C000_DecompressionTemporaryBuffer
	ld a, $0C
	ld (_RAM_D69D_EmitTilemapRectangle_Width), a
	ld a, $09
	ld (_RAM_D69E_EmitTilemapRectangle_Height), a
	ld a, $60
	ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
	ld a, $01
	ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
	jp $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle

_LABEL_B911_:
	ld a, (_RAM_D6AF_)
	sub $01
	ld (_RAM_D6AF_), a
	sra a
	sra a
	sra a
	and $01
	jp nz, +++
	ld a, (_RAM_DC3F_)
	dec a
	jr z, ++
	ld hl, $79CC
	call _LABEL_B35A_VRAMAddressToHL
	ld a, (_RAM_DC34_)
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
	ld hl, $79D6
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _TEXT_B984_Champion
	ld bc, $000A
	jp _LABEL_A5B0_EmitToVDP_Text

+++:
	ld hl, $79CC
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
	ld hl, $DC2C
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
	cp $11
	jr z, +
	ld hl, $7990
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, $50
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld hl, $79AE
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, $53
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

+:
	ld hl, $7C10
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, $50
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld hl, $7C2E
	add hl, de
	call _LABEL_B35A_VRAMAddressToHL
	ld a, $53
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

_LABEL_BA3C_:
	ld hl, $6A00
	call _LABEL_B35A_VRAMAddressToHL
_LABEL_BA42_:
	ld a, $08
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld e, $20
	ld hl, $AB8C
	jp $D985	; Code is loaded from _LABEL_3BB45_

_LABEL_BA4F_:
	ld a, $09
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B94C
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $0050
	ld hl, $4C00
	jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_BA63_:
	ld a, (_RAM_D6AF_)
	cp $00
	jr z, +
	sub $01
	ld (_RAM_D6AF_), a
	sra a
	sra a
	sra a
	and $01
	jr nz, ++
	ld hl, $79D6
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000A
	ld hl, _TEXT_BAB7_Qualifying
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7A16
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000A
	ld hl, _TEXT_BAC1_Race
	call _LABEL_A5B0_EmitToVDP_Text
+:
	ret

++:
	ld hl, $79D6
	call _LABEL_B35A_VRAMAddressToHL
	ld bc, $000A
	ld hl, _TEXT_BACB_Blanks
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7A16
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

_LABEL_BAD5_:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld a, $08
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $AC4E
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $0588
	jr ++

+:
	ld a, $0F
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $A5D7
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld de, $0380
++:
	ld hl, $6000
	jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_BAFF_:
	ld a, $0A
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B02D
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4000
	ld de, $0120
	jp _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL

_LABEL_BB13_:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld a, $03
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $BAA5
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4480
	ld de, $0280
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
	jr ++

+:
	ld bc, $0A00
	ld hl, $4480
	call _LABEL_B35A_VRAMAddressToHL
-:
	xor a
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
++:
	ld a, $01
	ld (_RAM_D6CB_), a
	call _LABEL_90E7_
	ret

_LABEL_BB49_:
	ld a, (_RAM_DC3C_IsGameGear)
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
	ld a, (_RAM_D6C7_)
	dec a
	jr z, _LABEL_BBE0_
	ld a, $09
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $AC52
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4480
	ld de, $01E0
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
	ld a, (_RAM_DC3C_IsGameGear)
	or a
	jr z, +
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $02
	jr z, ++
+:
	ld hl, $AFC6
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4E80
	ld de, $01E0
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
	jp +++

++:
	ld hl, $BA12
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4E80
	ld de, $01E0
	call _LABEL_BD94_
	jp +++

_LABEL_BBE0_:
	ld a, $09
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $B391
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4480
	ld de, $01B0
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
	ld hl, $B674
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $4E80
	ld de, $01B0
	call _LABEL_AFA5_Emit3bppTileDataFromDecompressionBufferToVRAMAddressHL
+++:
	call _LABEL_A296_
	call _LABEL_949B_
	jp _LABEL_948A_

_LABEL_BC0C_:
	ld a, (_RAM_D6C7_)
	or a
	jr z, +
	ld a, $09
	ld (_RAM_D69A_TilemapRectangleSequence_Width), a
	jp ++

+:
	ld a, $0A
	ld (_RAM_D69A_TilemapRectangleSequence_Width), a
++:
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld hl, $7B88
	jr ++

+:
	ld hl, $7ACC
++:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $13
	jr nz, +
	ld de, $0040
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
	ld hl, $7BA4
	jr ++

+:
	ld hl, $7AE0
++:
	ld a, (_RAM_D6C7_)
	or a
	jr z, +
	inc hl
	inc hl
+:
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $13
	jr nz, +
	ld de, $0040
	or a
	sbc hl, de
+:
	ld a, $74
	ld (_RAM_D68A_TilemapRectangleSequence_TileIndex), a
	ld a, $06
	ld (_RAM_D69B_TilemapRectangleSequence_Height), a
	call _LABEL_BCCF_EmitTilemapRectangleSequence
	ld a, (_RAM_D699_MenuScreenIndex)
	cp $0F
	jr z, _LABEL_BCCE_
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld de, $7D48
	jr ++

+:
	ld de, $7C4C
++:
	call _LABEL_B361_VRAMAddressToDE
	ld hl, _DATA_B4BA_
	ld a, $08
	ld (_RAM_D69D_EmitTilemapRectangle_Width), a
	ld a, $02
	ld (_RAM_D69E_EmitTilemapRectangle_Height), a
	ld a, $F0
	ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
	call $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle
	ld a, (_RAM_DC3C_IsGameGear)
	dec a
	jr z, +
	ld de, $7D64
	jr ++

+:
	ld de, $7C60
++:
	call _LABEL_B361_VRAMAddressToDE
	ld hl, $B5BE
	ld a, $0A
	ld (_RAM_D69D_EmitTilemapRectangle_Width), a
	ld a, $02
	ld (_RAM_D69E_EmitTilemapRectangle_Height), a
	ld a, $E2
	ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
	call $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle
_LABEL_BCCE_:
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
	out ($BE), a
	ld a, (_RAM_D69C_TilemapRectangleSequence_Flags) ; High byte
	out ($BE), a
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
	ld a, (_RAM_D6C5_)
	cp $06
	jr z, _LABEL_BD7C_
	cp $03
	jr nc, +
	ld hl, _DATA_BD58_
	call _LABEL_BD82_
	ld b, $07
	ld c, $BE
	otir
	ld hl, $C010
	call $DB07	; Code is loaded from _LABEL_3BCC7_VRAMAddressToHL
	ld a, (de)
	out ($BE), a
+:
	ld a, (_RAM_D6C5_)
	add a, $01
	ld (_RAM_D6C5_), a
	ret

; Pointer Table from BD58 to BD5B (2 entries, indexed by unknown)
_DATA_BD58_:
.dw _DATA_BD5E_ _DATA_BD65_ _DATA_BD6C_

; 1st entry of Pointer Table from BD58 (indexed by unknown)
; Data from BD5E to BD64 (7 bytes)
_DATA_BD5E_:
.db $10 $2A $04 $01 $02 $06 $20

; 2nd entry of Pointer Table from BD58 (indexed by unknown)
; Data from BD65 to BD6B (7 bytes)
_DATA_BD65_:
.db $00 $15 $00 $00 $01 $01 $10

; Data from BD6C to BD7B (16 bytes)
_DATA_BD6C_:
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

_LABEL_BD7C_:
	ld a, $FF
	ld (_RAM_D6C5_), a
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
	call $DB07	; Code is loaded from _LABEL_3BCC7_VRAMAddressToHL
	ld h, d
	ld l, e
	ret

_LABEL_BD94_:
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _RAM_C000_DecompressionTemporaryBuffer
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
	ld a, $05
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, $BC0C
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $6E00
	ld de, $00A0
	call _LABEL_BD94_
	ld hl, $7C60
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

_LABEL_BDED_:
	ld a, $0B
	ld (_RAM_D741_RAMDecompressorPageIndex), a
	ld hl, _DATA_BF6F_
	call $D7BD	; Code is loaded from _LABEL_3B97D_DecompressFromHLToC000
	ld hl, $7700
	call _LABEL_B35A_VRAMAddressToHL
	ld de, $7700
	ld hl, _RAM_C000_DecompressionTemporaryBuffer
	ld a, $20
	ld (_RAM_D69D_EmitTilemapRectangle_Width), a
	ld a, $0B
	ld (_RAM_D69E_EmitTilemapRectangle_Height), a
	ld a, $01
	ld (_RAM_D69C_TilemapRectangleSequence_Flags), a
	xor a
	ld (_RAM_D69F_EmitTilemapRectangle_IndexOffset), a
	jp $D997	; Code is loaded from _LABEL_3BB57_EmitTilemapRectangle

_LABEL_BE1A_DrawCopyrightText:
	ld a, (_RAM_D6CB_)
	or a
	ret z
	xor a
	ld (_RAM_D6CB_), a
	ld hl, $7D80
	call _LABEL_B35A_VRAMAddressToHL
	ld c, $1A
	ld hl, _TEXT_BE77_CopyrightCodemasters
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7DC0
	call _LABEL_B35A_VRAMAddressToHL
	ld c, $1C
	ld hl, _TEXT_BE91_SoftwareCompanyLtd1993
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7B08
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _TEXT_BEAD_MasterSystemVersionBy
	ld c, $18
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7B8C
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _TEXT_BEC5_AshleyRoutledge
	ld c, $14
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7BCC
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _TEXT_BED9_And
	ld c, $0D
	call _LABEL_A5B0_EmitToVDP_Text
	ld hl, $7C0C
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
	cp $01
	ret nz
	ld hl, $7B08
	call +
	ld hl, $7B88
	call +
	ld hl, $7C08
	call +
	ld hl, $7B2A
	call +
	ld hl, $7BAA
	call +
	ld hl, $7C2A
	jr +

+:
	call _LABEL_B35A_VRAMAddressToHL
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
	call _LABEL_B35A_VRAMAddressToHL
	ld hl, _DATA_BF3E_
	ld b, $20
	ld c, $BE
	otir
	ret

; Data from BF3E to BF4F (18 bytes)
_DATA_BF3E_:
.db $21 $3F $08 $02 $17 $0B $35 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $21 $3F

; Data from BF50 to BF6E (31 bytes)
_DATA_BF50_:
.db $08 $02 $17 $0B $3A $00 $00 $00 $00 $00 $00 $00 $00 $00 $18 $00
.db $CD $58 $B3 $0E $05 $3E $0E $D3 $BE $AF $D3 $BE $0D $20 $F6

; Data from BF6F to BFFE (144 bytes)
_DATA_BF6F_:
.db $C9 $21 $00 $C0 $CD $58 $B3 $21 $80 $BF $06 $40 $0E $BE $ED $B3
.db $C9 $04 $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $44 $0E $00
.db $00 $22 $02 $44 $04 $88 $08 $40 $00 $C0 $00 $E0 $00 $AE $0A $00
.db $00 $04 $08 $EE $0E $80 $00 $08 $00 $4E $04 $8E $00 $88 $0E $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $FE $FF $EE $FF $FE $EF $EF $EE $FF $FF $EF $EF $FA $EF $FF
.db $7F $EA $EF $EE $FF $FA $FF $EB $FF $FF $FE $7F $EF $BA $FE $EF
.db $EE $FE $FB $EF $EB $FB $EF $AE $BD $FE $FF $EF $EE $AF $BF $FF
.db $FF $FF $FF $FE $BB $EE $FB $EF $EE $FE $FF $FF $BA $FE $FF $EF

; Data from BFFF to BFFF (1 bytes)
_DATA_BFFF_Value02:
.db $02

.BANK 3
.ORG $0000

; Data from C000 to CD35 (3382 bytes)
.incbin "Micro Machines_c000.inc"

_LABEL_CD36_:
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	ld d, l
	ld d, a
	rrca
	ld c, $0F
	ld b, $07
	inc b
	dec b
	nop
	rlca
	ld d, l
	ld d, (hl)
	ld b, $07
	nop
	ld bc, $0F0E
	inc c
	dec c
	add hl, bc
	ld d, l
	ld d, a
	rrca
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc b
	dec b
	ld de, $5507
	ld d, (hl)
	nop
	ld bc, $0504
	ld de, $0C03
	dec c
	ld (de), a
	ld d, l
	ld d, a
	rrca
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	rlca
	ld d, l
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, l
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld b, $07
	nop
	ld bc, $5E11
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	ld (de), a
	ld e, (hl)
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld de, $0403
	dec b
	ld b, $5E
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld (de), a
	dec bc
	inc c
	dec c
	ld c, $5E
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld b, $07
	nop
	ld bc, $5E04
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	ld e, (hl)
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	inc b
	dec b
	ld b, $07
	nop
	ld e, (hl)
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld e, (hl)
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	nop
	ld bc, $0504
	ld de, $585E
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld (de), a
	ld e, (hl)
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld b, $07
	ld de, $0603
	ld e, (hl)
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld c, $0F
	ld (de), a
	dec bc
	ld c, $5E
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	inc b
	dec b
	nop
	ld bc, $5E04
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	ld e, (hl)
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	inc b
	dec b
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	inc c
	dec c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	nop
	ld bc, $5B5A
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	add hl, bc
	ld a, (bc)
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	inc b
	dec b
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	inc c
	dec c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	inc b
	dec b
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	inc c
	dec c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	ld de, $5A03
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	ld (de), a
	dec bc
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	nop
	ld bc, $5B5A
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	add hl, bc
	ld a, (bc)
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld h, b
	ld e, h
	ld e, h
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	ld b, $07
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	ld c, $0F
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	ld b, $07
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	ld c, $0F
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	inc b
	dec b
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld h, c
	ld h, d
	ld h, d
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld b, $07
	inc b
	dec b
	ld b, $07
	ld de, $0003
	ld bc, $0504
	ld c, $0F
	inc c
	dec c
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld de, $0403
	dec b
	ld b, $07
	ld b, $07
	ld de, $0403
	dec b
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld b, $07
	nop
	ld bc, $5E00
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	add hl, bc
	ld e, (hl)
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld de, $0603
	rlca
	ld de, $585E
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld e, h
	ld de, $0603
	rlca
	inc b
	dec b
	ld b, $07
	nop
	ld bc, $0504
	ld (de), a
	dec bc
	ld c, $0F
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	inc b
	dec b
	nop
	ld bc, $0504
	nop
	ld d, l
	ld h, h
	ld h, h
	inc hl
	inc bc
	ld d, l
	ld h, h
	ld h, l
	ld h, (hl)
	ld h, a
	ld h, l
	ld h, (hl)
	ld d, a
	rrca
	dec h
	inc h
	inc hl
	ld d, a
	rrca
	ld b, $07
	ld de, $0403
	dec b
	nop
	ld bc, $2425
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0504
	inc b
	dec b
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	dec c
	ld de, $0003
	ld bc, $0706
	ld de, $0003
	ld bc, $0706
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld b, $07
	inc b
	dec b
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0F23
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	ld h, h
	ld h, a
	ld h, l
	ld h, a
	ld h, (hl)
	ld h, (hl)
	ld h, l
	ld h, a
	ld h, l
	ld h, (hl)
	ld h, h
	inc hl
	inc c
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	dec h
	inc h
	ld de, $0403
	dec b
	ld b, $5E
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld (de), a
	dec bc
	inc c
	dec c
	ld c, $5E
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	inc b
	dec b
	inc b
	dec b
	ld b, $5E
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	inc c
	dec c
	inc c
	dec c
	ld c, $5E
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld de, $1716
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	ld (de), a
	jr +

; Data from D34F to D367 (25 bytes)
.db $19 $19 $19 $19 $19 $19 $19 $19 $19 $00 $1A $1B $1B $1B $1B $1B
.db $1B $1B $1B $1B $1B $09 $1C $1D $1D

+:
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	ld b, $07
	inc b
	dec b
	nop
	ld l, b
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld c, $0F
	inc c
	dec c
	add hl, bc
	ld e, (hl)
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	inc b
	dec b
	ld de, $0603
	ld e, (hl)
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	inc c
	dec c
	ld (de), a
	dec bc
	ld c, $5E
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	ld b, $07
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	ld c, $0F
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	ld de, $5A03
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	ld (de), a
	dec bc
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	rla
	ld e, $19
	add hl, de
	add hl, de
	add hl, de
	add hl, de
	add hl, de
	add hl, de
	add hl, de
	add hl, de
	add hl, de
	add hl, de
	rra
	dec de
	dec de
	dec de
	dec de
	dec de
	dec de
	dec de
	dec de
	dec de
	dec de
	dec de
	jr nz, +
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	dec e
	ld hl, $5958
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld l, c
	nop
	ld bc, $5B5A
	ld e, d
	ld e, e
	ld e, d
	ld e, e
+:
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	add hl, bc
	ld a, (bc)
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, c
	ld e, b
	ld e, a
	ld b, $07
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, e
	ld e, d
	ld e, a
	ld c, $0F
	inc b
	dec b
	nop
	ld bc, $0504
	nop
	ld bc, $0706
	ld de, $0C03
	ld d, l
	ld h, h
	ld h, (hl)
	ld h, l
	ld h, a
	ld h, (hl)
	ld h, h
	inc hl
	rrca
	ld (de), a
	dec bc
	ld d, l
	ld d, (hl)
	ld b, $07
	ld de, $0403
	dec h
	ld h, h
	ld h, (hl)
	ld h, l
	ld h, a
	ld d, a
	rrca
	ld c, $0F
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0504
	inc b
	dec b
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	dec c
	ld de, $0003
	ld bc, $0706
	ld de, $0003
	ld bc, $0706
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld b, $07
	inc b
	dec b
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0F0E
	inc c
	dec c
	ld d, l
	ld h, l
	ld h, (hl)
	ld h, l
	ld h, a
	ld h, (hl)
	ld h, l
	ld h, a
	ld d, l
	ld h, (hl)
	ld h, a
	ld h, h
	ld d, a
	rlca
	nop
	ld bc, $0504
	ld de, $5703
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld (de), a
	dec bc
	ld de, $6B6A
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (de), a
	ld l, h
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld b, $6E
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld c, $6E
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld b, $6E
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld c, $6E
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	inc bc
	ld l, (hl)
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	dec bc
	ld l, (hl)
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	rlca
	ld l, (hl)
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	rrca
	ld l, (hl)
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	inc bc
	ld l, (hl)
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	dec bc
	ld l, a
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), c
	rlca
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld l, l
	ld (hl), d
	rrca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	ld bc, $6B6B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	ld a, (bc)
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	inc bc
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	dec bc
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	rlca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	rrca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	rlca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	rrca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), e
	ld bc, $7070
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), b
	ld (hl), h
	ld a, (bc)
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	halt
	rlca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	rrca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	ld bc, $6B6B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	ld a, (bc)
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	inc bc
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	dec bc
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	rlca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	rrca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	rlca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	rrca
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (hl), a
	ld bc, $7878
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, c
	ld a, (bc)
	ld b, $7A
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld (hl), l
	ld c, $7B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld de, $6B7B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (de), a
	ld a, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld b, $7B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld c, $7B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld b, $7B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld c, $7B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld de, $6B7B
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (de), a
	ld a, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld de, $6B7C
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld l, e
	ld (de), a
	ld a, l
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	add a, d
	add a, e
	add a, h
	add a, l
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	add a, (hl)
	add a, a
	adc a, b
	adc a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, h
	ld e, h
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	adc a, d
	ld e, h
	ld b, $07
	adc a, e
	adc a, h
	adc a, l
	adc a, (hl)
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld b, $07
	ld c, $0F
	inc c
	dec c
	ld (de), a
	dec bc
	adc a, e
	adc a, h
	adc a, l
	adc a, (hl)
	ld c, $0F
	inc b
	dec b
	ex af, af'
	ld bc, $0504
	nop
	ld bc, $0806
	ld de, $0C03
	ld d, l
	ld h, h
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $64
	inc hl
	dec bc
	ld d, l
	ld h, h
	ld b, $07
	ld de, $0403
	dec b
	nop
	ex af, af'
	ld h, h
	inc hl
	ld d, a
	ld (bc), a
	ld c, $0F
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	djnz ++
	nop
	ex af, af'
	inc b
	dec b
	ld b, $55
	ld h, h
	inc hl
	inc b
	dec b
	ex af, af'
	dec b
	add hl, bc
	djnz +
	dec c
	ld c, $57
	ld (bc), a
	inc h
	inc c
	dec c
	ld (bc), a
	dec c
	ld de, $0010
+:
	ld bc, $0706
	ex af, af'
	inc bc
	nop
	ld bc, $0710
++:
	ld (de), a
	ex af, af'
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ex af, af'
	dec bc
	add hl, bc
	ld a, (bc)
	ex af, af'
	rrca
	inc h
	ld h, h
	ld h, a
	ld h, l
	ld h, a
	ld h, l
	ld h, (hl)
	ld h, a
	ld h, l
	ld h, a
	ld h, h
	ld d, (hl)
	ld c, $64
	ld (bc), a
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $55
	ld h, h
	ld a, (bc)
	inc b
	djnz 8
	inc bc
	ld b, $07
	nop
	ld bc, $0204
	ld de, $0C03
	dec c
	djnz +
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	ex af, af'
	ld (de), a
	dec bc
	inc b
	dec b
	nop
+:
	ld bc, $0504
	nop
	ld bc, $2306
	ld de, $0C03
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	ld d, l
	ld h, (hl)
	ld h, l
	ld h, a
	ld h, h
	ld h, (hl)
	dec bc
	ld h, h
	inc hl
	ld b, $07
	ld d, l
	ld d, (hl)
	inc b
	dec b
	nop
	ld bc, $2324
	add hl, bc
	inc h
	ld h, a
	ld h, l
	ld d, a
	rrca
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	dec h
	inc h
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0504
	inc b
	dec h
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	dec c
	ld de, $0003
	ld bc, $0706
	ld de, $0003
	ld bc, $0706
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	inc hl
	rlca
	inc b
	dec b
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $2324
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	dec h
	ld h, h
	ld h, l
	ld h, a
	ld h, h
	ld h, a
	ld h, (hl)
	ld bc, $0504
	ld de, $0C03
	dec c
	ld (de), a
	dec bc
	dec h
	ld h, h
	ld h, l
	ld h, (hl)
	ld h, l
	ld h, a
	ld h, l
	ld h, (hl)
	ld b, $07
	ld de, $0403
	dec b
	inc b
	dec b
	ld b, $07
	ld de, $0E03
	rrca
	adc a, a
	sub b
	sub c
	sub d
	inc c
	dec c
	ld c, $0F
	ld (de), a
	dec bc
	inc b
	dec b
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	adc a, a
	sub b
	sub c
	sub d
	ld b, $07
	ld h, d
	ld h, d
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	sub e
	ld h, d
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	add a, d
	add a, e
	add a, h
	add a, l
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	add a, (hl)
	add a, a
	adc a, b
	adc a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, h
	ld e, h
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	adc a, d
	ld e, h
	inc b
	dec b
	adc a, e
	adc a, h
	adc a, l
	adc a, (hl)
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld de, $0C03
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	adc a, e
	adc a, h
	adc a, l
	adc a, (hl)
	ld (de), a
	dec bc
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	add a, d
	add a, e
	add a, h
	add a, l
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	add a, (hl)
	add a, a
	adc a, b
	adc a, c
	ld e, d
	ld e, e
	ld e, b
	ld e, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld e, b
	ld e, c
	ld e, h
	ld e, h
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	adc a, d
	ld e, h
	inc b
	dec b
	adc a, e
	adc a, h
	adc a, l
	adc a, (hl)
	ld a, (hl)
	ld a, a
	add a, b
	add a, c
	ld de, $0C03
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	adc a, e
	adc a, h
	adc a, l
	adc a, (hl)
	ld (de), a
	dec bc
	ld de, $9594
	dec b
	ld de, $1103
	inc bc
	inc b
	dec b
	inc b
	dec b
	sub (hl)
	sub a
	sbc a, b
	sbc a, c
	ld (de), a
	dec bc
	ld (de), a
	dec bc
	inc c
	dec c
	inc c
	dec c
	sbc a, d
	sbc a, e
	sbc a, h
	sbc a, l
	nop
	ld bc, $0504
	nop
	ld bc, $0100
	inc c
	sbc a, (hl)
	sbc a, a
	ld a, (bc)
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	add hl, bc
	ld a, (bc)
	nop
	ld bc, $0311
	nop
	ld bc, $8382
	add a, h
	add a, l
	ld b, $07
	add hl, bc
	ld a, (bc)
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	add a, (hl)
	add a, a
	adc a, b
	adc a, c
	ld c, $0F
	ld de, $0003
	ld bc, $0504
	nop
	ld bc, $0706
	inc b
	dec b
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	inc c
	dec c
	nop
	ld bc, $0504
	ld de, $0003
	ld bc, $0100
	nop
	ld bc, $0A09
	inc c
	dec c
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	add hl, bc
	ld a, (bc)
	add hl, bc
	ld a, (bc)
	and b
	and b
	and c
	and d
	and d
	and d
	and e
	and h
	inc b
	dec b
	nop
	ld bc, _DATA_E5A5_
	and l
	and (hl)
	and (hl)
	and (hl)
	and a
	xor b
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	inc b
	dec b
	nop
	ld bc, $0504
	nop
	ld bc, $0706
	ld de, $0C03
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld d, l
	ld h, l
	ld h, (hl)
	ld h, l
	ld h, a
	inc hl
	inc hl
	ld bc, $6555
	ld h, (hl)
	ld h, a
	ld d, a
	dec b
	nop
	ld bc, $2425
	ld h, h
	ld h, a
	ld d, a
	rrca
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $25
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0504
	inc b
	dec b
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	dec c
	ld de, $0003
	ld bc, $0706
	ld de, $0003
	ld bc, $0706
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld b, $07
	inc b
	dec b
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0F0E
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld d, l
	ld d, l
	ld h, l
	ld h, (hl)
	ld h, (hl)
	ld h, a
	ld h, l
	inc hl
	ld bc, $0504
	ld d, l
	ld d, (hl)
	ld d, a
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	ld h, h
	ld h, a
	ld h, (hl)
	ld h, l
	ld d, a
	rrca
	inc b
	dec b
	ld (bc), a
	ld bc, $0504
	nop
	ld bc, $0806
	ld de, $0C03
	dec c
	ex af, af'
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $02
	ld (de), a
	dec bc
	nop
	ld bc, $0710
	ld de, $0403
	dec b
	nop
	ex af, af'
	ld b, $07
	add hl, bc
	ld a, (bc)
	ld h, h
	inc hl
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld h, h
	inc hl
	rrca
	nop
	ld bc, $6425
	ld b, $07
	nop
	ld bc, $0504
	inc h
	inc hl
	add hl, bc
	ld a, (bc)
	inc c
	ld (bc), a
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	dec h
	ld h, h
	ld de, $0003
	djnz 6
	rlca
	ld de, $0003
	ld bc, $0806
	ld (de), a
	dec bc
	add hl, bc
	ex af, af'
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $02
	ld b, $07
	inc b
	ex af, af'
	nop
	ld bc, $0504
	ld b, $07
	nop
	djnz 14
	rrca
	inc c
	djnz +
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ex af, af'
	inc b
	dec b
+:
	ld de, $0608
	rlca
	nop
	ld bc, $0504
	ld de, $0C02
	dec c
	ld (de), a
	ld (bc), a
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld (de), a
	djnz 4
	ld d, l
	ld d, a
	ld bc, $0504
	nop
	ld bc, $5755
	ld de, $0C03
	djnz +
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	djnz ++
	ld (de), a
	dec bc
+:
	nop
	ex af, af'
	ld b, $07
	ld de, $0403
	dec b
	ex af, af'
	ld bc, $0706
	rlca
++:
	djnz 14
	rrca
	ld (de), a
	dec bc
	inc c
	dec c
	djnz 10
	ld c, $0F
	ld d, l
	ld d, a
	rrca
	dec b
	ld b, $07
	nop
	ld bc, $0502
	inc b
	dec b
	djnz +
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	ex af, af'
	dec c
	inc c
	dec c
+:
	ld (bc), a
	inc bc
	nop
	ld bc, $0706
	ld de, $0803
	ld bc, $0706
	ex af, af'
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	djnz +
	ld c, $0F
	ex af, af'
	rlca
	inc b
	dec b
	nop
	ld bc, $0504
+:
	ex af, af'
	rlca
	nop
	ld bc, $0F08
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	djnz +
	add hl, bc
	ld a, (bc)
	ld (bc), a
	dec b
	ld de, $0603
	rlca
	nop
	ld bc, $0502
	ld de, $1003
+:
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	add hl, bc
	ld a, (bc)
	ld h, h
	inc hl
	ld (de), a
	dec bc
	inc b
	dec b
	ld d, l
	ld d, (hl)
	inc b
	dec b
	nop
	ld bc, $0706
	ld d, l
	ld d, (hl)
	inc c
	dec c
	djnz +
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	djnz 11
	nop
	ld d, l
+:
	ld d, (hl)
	rlca
	ld de, $0403
	dec b
	nop
	ld bc, $0708
	add hl, bc
	djnz 14
	rrca
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	djnz +
	nop
	ex af, af'
	inc b
	dec b
	ld b, $07
	nop
	ld bc, $0504
	ld (bc), a
	dec b
	add hl, bc
	ld (bc), a
	inc c
+:
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ex af, af'
	dec c
	ld de, $0010
	ld bc, $0706
	ld de, $0003
	rlca
	djnz +
	ld (de), a
	ex af, af'
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
+:
	dec bc
	add hl, bc
	ld d, l
	ld d, a
	rrca
	ld b, $10
	inc b
	dec b
	nop
	ld bc, $0504
	ld b, $10
	nop
	ld bc, $640E
	inc hl
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $10
	add hl, bc
	ld a, (bc)
	inc b
	dec h
	ld h, h
	inc bc
	ld b, $07
	nop
	ld bc, $0804
	ld de, $0C03
	dec c
	ex af, af'
	dec bc
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	ld (bc), a
	ld (de), a
	dec bc
	inc h
	inc hl
	nop
	ld bc, $0504
	nop
	ld bc, $2406
	inc hl
	inc bc
	dec h
	inc h
	inc hl
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $25
	inc h
	inc hl
	nop
	dec h
	inc h
	inc hl
	ld de, $0403
	dec b
	nop
	ld bc, $6425
	add hl, bc
	ld a, (bc)
	dec h
	inc h
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $10
	nop
	ld bc, $0204
	ld b, $07
	nop
	ld bc, $0504
	inc b
	ex af, af'
	add hl, bc
	ld a, (bc)
	ld d, l
	ld d, (hl)
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	ex af, af'
	ld de, $1003
	ld bc, $0706
	ld de, $0003
	rlca
	ld d, l
	ld d, (hl)
	ld (de), a
	dec bc
	ex af, af'
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld d, l
	ld d, a
	rrca
	ld b, $07
	ld (bc), a
	dec b
	nop
	ld bc, $0504
	ld b, $10
	nop
	ld bc, $0F0E
	djnz 13
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $08
	add hl, bc
	ld a, (bc)
	inc b
	dec b
	ex af, af'
	inc bc
	ld b, $07
	nop
	ld bc, $0804
	ld de, $0C03
	dec c
	djnz +
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	ld (bc), a
	ld (de), a
	dec bc
	inc b
	dec b
	nop
+:
	ld bc, $0504
	nop
	ld bc, $0706
	ld de, $0C03
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	ld h, l
	ld h, l
	ld h, h
	inc hl
	add a, d
	add a, e
	add a, h
	add a, l
	nop
	ld bc, $6555
	add hl, bc
	ld a, (bc)
	dec h
	inc h
	add a, (hl)
	add a, a
	adc a, b
	adc a, c
	ld d, l
	ld h, l
	ld d, a
	rrca
	nop
	ld bc, $2504
	ld h, h
	ld h, l
	ld h, l
	ld h, l
	ld d, a
	dec b
	inc b
	dec b
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	dec c
	ld de, $0003
	ld bc, $0706
	ld de, $0003
	ld bc, $0706
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld d, l
	ld h, l
	ld h, l
	ld h, l
	ld h, h
	inc hl
	ld c, $0F
	ld b, $55
	ld h, l
	ld h, l
	ld d, a
	sub h
	sub l
	dec b
	dec h
	inc h
	inc hl
	ld bc, $5765
	inc c
	dec c
	sub (hl)
	sub a
	sbc a, b
	sbc a, c
	ld c, $25
	ld h, h
	ld h, l
	inc b
	dec b
	ld de, $9A03
	sbc a, e
	sbc a, h
	sbc a, l
	inc b
	dec b
	ld de, $0C03
	dec c
	ld (de), a
	dec bc
	inc c
	sbc a, (hl)
	sbc a, a
	ld a, (bc)
	inc c
	dec c
	ld (de), a
	dec bc
	inc b
	dec b
	nop
	ld bc, $0504
	nop
	ld bc, $0706
	ld de, $0C03
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	nop
	ld bc, $0706
	ld de, $0403
	dec b
	nop
	ld bc, $0706
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0504
	inc b
	dec b
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	dec c
	ld de, $0003
	ld bc, $0706
	ld de, $0003
	ld bc, $0706
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	ld b, $07
	inc b
	dec b
	nop
	ld bc, $0504
	ld b, $07
	nop
	ld bc, $0F0E
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc b
	dec b
	ld de, $0603
	rlca
	nop
	ld bc, $0504
	ld de, $0C03
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld (de), a
	dec bc
	ld b, $07
	inc b
	dec b
	ld de, $0003
	rlca
	ld b, $07
	inc b
	dec b
	ld c, $0F
	inc c
	dec c
	ld (de), a
	dec bc
	add hl, bc
	rrca
	ld c, $A9
	xor c
	xor c
	inc b
	dec b
	ld b, $07
	ld b, $07
	inc b
	rlca
	ld b, $AA
	xor d
	xor d
	inc c
	dec c
	ld c, $0F
	ld c, $0F
	inc c
	rrca
	ld c, $36
	ld (hl), $36
	inc b
	dec b
	ld de, $0603
	rlca
	ld b, $01
	nop
	xor e
	xor e
	xor e
	inc c
	dec c
	ld (de), a
	dec bc
	ld c, $0F
	ld c, $0A
	add hl, bc
	xor e
	xor e
	xor e
	nop
	ld bc, $0504
	nop
	ld bc, $0700
	ld b, $AB
	xor e
	xor e
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	add hl, bc
	rrca
	ld c, $AB
	xor e
	xor e
	inc b
	dec b
	inc b
	dec b
	ld de, $0403
	dec b
	inc b
	xor e
	xor e
	xor e
	inc c
	dec c
	inc c
	dec c
	ld (de), a
	dec bc
	inc c
	dec c
	inc c
	xor e
	xor e
	xor e
	ld de, $0003
	ld bc, $0100
	ld b, $01
	nop
	xor e
	xor e
	xor e
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	add hl, bc
	ld a, (bc)
	ld c, $0A
	add hl, bc
	xor e
	xor e
	xor e
	ld b, $07
	nop
	ld bc, $0706
	ld de, $0603
	rlca
	inc b
	xor h
	xor c
	xor c
	xor c
	xor c
	xor c
	xor c
	xor c
	xor c
	xor c
	xor c
	xor c
	xor l
	xor d
	xor d
	xor d
	xor d
	xor d
	xor d
	xor d
	xor d
	xor d
	xor d
	xor d
	xor (hl)
	ld (hl), $36
	ld (hl), $36
	ld (hl), $36
	ld (hl), $36
	ld (hl), $36
	ld (hl), $AF
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or b
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	ld b, $07
	inc b
	dec b
	ld b, $07
	nop
	rlca
	ld b, $AB
	xor e
	xor e
	ld c, $0F
	inc c
	dec c
	ld c, $0F
	add hl, bc
	rrca
	ld c, $AB
	xor e
	xor e
	ld b, $07
	ld de, $0403
	dec b
	inc b
	rlca
	ld b, $AB
	xor e
	xor e
	ld c, $0F
	ld (de), a
	dec bc
	inc c
	dec c
	inc c
	rrca
	ld c, $AB
	xor e
	xor e
	nop
	ld bc, $0706
	inc b
	dec b
	ld b, $01
	nop
	xor e
	xor e
	xor e
	add hl, bc
	ld a, (bc)
	ld c, $0F
	inc c
	dec c
	ld c, $0A
	add hl, bc
	xor e
	xor e
	xor e
	ld b, $07
	ld b, $07
	inc b
	dec b
	nop
	rlca
	ld b, $AB
	xor e
	xor e
	ld c, $0F
	ld c, $0F
	inc c
	dec c
	add hl, bc
	rrca
	ld c, $AB
	xor e
	xor e
	inc b
	dec b
	ld de, $0003
	ld bc, $0504
	inc b
	xor e
	xor e
	xor e
	inc c
	dec c
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	xor e
	xor e
	xor e
	nop
	ld bc, $0706
	inc b
	dec b
	ld b, $01
	nop
	xor e
	xor e
	xor e
	add hl, bc
	ld a, (bc)
	ld c, $0F
	inc c
	dec c
	ld c, $0A
	add hl, bc
	ld a, (bc)
	ld c, h
	ld c, e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or c
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	xor e
	or d
	ld c, h
	ld c, e
	ld c, h
	ld c, e
	ld c, h
	ld c, e
	ld c, h
	ld c, e
	ld c, h
	ld c, e
	ld c, h
	ld c, e
	ld de, $0D03
	ld bc, $0706
	inc b
	dec b
	ld b, $07
	ld de, $1203
	dec bc
	ld b, $B3
	or h
	rrca
	inc c
	dec c
	ld c, $0F
	ld (de), a
	dec bc
	ld b, $06
	or e
	or l
	rlca
	dec b
	ld de, $0403
	dec b
	ld b, $07
	ld c, $B6
	or l
	ld b, $0F
	dec c
	ld (de), a
	dec bc
	inc c
	dec c
	ld c, $0F
	ld b, $B7
	ld b, $07
	cp b
	dec b
	ld b, $07
	ld b, $07
	inc b
	dec b
	ld c, $0F
	ld c, $0F
	cp c
	dec c
	ld c, $0F
	ld c, $0F
	inc c
	dec c
	ld b, $07
	ld de, $B903
	or d
	inc b
	dec b
	ld de, $9594
	dec b
	ld c, $0F
	ld (de), a
	dec bc
	cp c
	ld c, e
	inc c
	dec c
	sub (hl)
	sub a
	sbc a, b
	sbc a, c
	inc b
	dec b
	ld b, $07
	cp c
	or d
	ld b, $07
	sbc a, d
	sbc a, e
	sbc a, h
	sbc a, l
	inc c
	dec c
	ld c, $0F
	cp c
	ld c, e
	ld c, $0F
	inc c
	sbc a, (hl)
	sbc a, a
	ld a, (bc)
	ld b, $07
	inc b
	dec b
	cp c
	or d
	ld de, $0603
	rlca
	inc b
	dec b
	ld c, $0F
	inc c
	dec c
	cp c
	ld c, e
	ld (de), a
	dec bc
	ld c, $0F
	inc c
	dec c
	ld b, $07
	nop
	ld bc, $B2B9
	ld de, $0003
	ld bc, $0504
	ld c, $0F
	add hl, bc
	ld a, (bc)
	cp c
	ld c, e
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld de, $0603
	rlca
	cp c
	or d
	nop
	ld bc, $0706
	nop
	ld bc, $0B12
	ld c, $0F
	cp c
	ld c, e
	add hl, bc
	ld a, (bc)
	ld c, $0F
	add hl, bc
	ld a, (bc)
	nop
	ld bc, $0504
	cp c
	or d
	ld b, $07
	ld de, $0603
	rlca
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	inc c
	ld c, e
	ld c, $0F
	ld (de), a
	dec bc
	ld c, $0F
	inc b
	dec b
	ld b, $07
	inc b
	dec b
	nop
	ld bc, $0100
	inc b
	dec b
	inc c
	dec c
	ld c, $0F
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	ld de, $0003
	ld bc, $0706
	add a, d
	add a, e
	add a, h
	add a, l
	ld b, $07
	ld (de), a
	dec bc
	add hl, bc
	ld a, (bc)
	ld c, $0F
	add a, (hl)
	add a, a
	adc a, b
	adc a, c
	ld c, $0F
	ld b, $07
	nop
	ld bc, $0504
	nop
	ld bc, $0706
	inc b
	dec b
	ld c, $0F
	add hl, bc
	ld a, (bc)
	inc c
	dec c
	add hl, bc
	ld a, (bc)
	ld c, $0F
	inc c
	dec c
	cp d
	cp e
	cp h
	cp l
	ld de, $0003
	dec b
	inc b
	dec b
	inc b
	dec b
	cp (hl)
	cp a
	cp a
	cp a
	ret nz
	pop bc
	add hl, bc
	dec c
	inc c
	dec c
	jp nz, $C4C3	; Possibly invalid
; Data from E259 to E5A4 (844 bytes)
.db $C5 $BF $BF $BF $C6 $11 $07 $04 $C7 $C8 $C9 $09 $0A $CA $CB $CC
.db $CD $05 $04 $CE $CF $D0 $D1 $00 $01 $06 $07 $05 $04 $04 $CE $CF
.db $D0 $D1 $03 $09 $05 $04 $05 $04 $0C $CE $CF $D0 $D1 $12 $0B $04
.db $0D $0C $0D $04 $CE $CF $D0 $D1 $05 $04 $05 $0E $07 $00 $01 $CE
.db $CF $D0 $D1 $0C $0D $0C $0D $05 $04 $04 $CE $CF $D0 $D1 $05 $06
.db $07 $00 $01 $0D $0C $D2 $CF $D0 $D1 $0C $0D $0E $0F $09 $0A $07
.db $00 $D3 $D4 $11 $03 $11 $D5 $D6 $D6 $D6 $D7 $0C $07 $00 $01 $12
.db $0B $12 $D8 $D8 $D8 $D8 $D9 $11 $94 $95 $05 $11 $03 $11 $03 $04
.db $05 $04 $05 $96 $97 $98 $99 $12 $0B $12 $0B $0C $0D $0C $0D $9A
.db $9B $9C $9D $00 $01 $04 $05 $00 $01 $00 $01 $0C $9E $9F $0A $09
.db $0A $0C $0D $09 $0A $09 $0A $00 $01 $11 $03 $00 $01 $82 $83 $84
.db $85 $06 $07 $09 $0A $12 $0B $09 $0A $86 $87 $88 $89 $0E $0F $11
.db $03 $00 $01 $04 $05 $00 $01 $06 $07 $04 $05 $12 $0B $09 $0A $0C
.db $0D $09 $0A $0E $0F $0C $0D $00 $01 $04 $05 $11 $03 $00 $01 $00
.db $01 $00 $01 $09 $0A $0C $0D $12 $0B $09 $0A $09 $0A $09 $0A $A0
.db $A0 $A1 $A2 $A2 $A2 $A3 $A4 $04 $05 $00 $01 $A5 $A5 $A5 $A6 $A6
.db $A6 $A7 $A8 $0C $0D $09 $0A $04 $05 $00 $01 $04 $05 $00 $01 $DA
.db $DB $00 $01 $0C $0D $09 $0A $0C $0D $09 $DC $DD $DE $DF $0A $23
.db $55 $64 $23 $11 $03 $E0 $E1 $E2 $E3 $E4 $E5 $64 $57 $25 $24 $23
.db $0B $E6 $E7 $E8 $E9 $EA $EB $00 $01 $04 $25 $24 $23 $EC $ED $EE
.db $EF $F0 $F1 $09 $0A $0C $0D $25 $F2 $F3 $F4 $F5 $F6 $F7 $0B $11
.db $03 $00 $BA $F8 $F9 $FA $11 $03 $01 $06 $07 $12 $0B $09 $BE $BF
.db $BF $BF $C0 $C1 $0A $0E $0F $06 $07 $04 $C4 $C5 $BF $BF $BF $C6
.db $07 $00 $01 $0E $0F $0C $09 $0A $CA $CB $CC $CD $0F $55 $65 $55
.db $65 $66 $67 $64 $23 $00 $01 $04 $55 $57 $03 $57 $0D $12 $0B $25
.db $64 $65 $66 $67 $57 $12 $0B $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $40 $00 $11 $01 $49 $02 $02 $4A $03
.db $DD $50 $05 $1B $13 $48 $13 $21 $32 $16 $4F $13 $40 $07 $13 $48
.db $08 $01 $01 $09 $49 $77 $00 $E2 $98 $C3 $07 $E2 $98 $C3 $C5 $BE
.db $A4 $02 $0A $03 $11 $49 $E2 $7F $09 $E2 $20 $31 $A4 $21 $38 $85
.db $22 $3F $85 $4A $4A $94 $0B $4B $E0 $04 $E0 $0C $AA $E0 $05 $E0
.db $05 $E0 $05 $21 $8E $09 $55 $02 $E0 $0A $E0 $4A $E0 $03 $E0 $4B
.db $03 $E0 $0B $41 $10 $42 $10 $22 $28 $3B $09 $08 $11 $86 $23 $B8
.db $0F $62 $00 $23 $B8 $54 $02 $61 $20 $01 $21 $23 $41 $60 $DC $08
.db $08 $93 $27 $DA $40 $40 $9C $47 $47 $21 $D8 $D9 $5D $41 $A0 $48
.db $9C $68 $14 $21 $46 $0F $62 $1C $C7 $12 $22 $22 $41 $40 $40 $31
.db $02 $39 $1E $62 $1F $39 $0F $46 $10 $21 $22 $30 $66 $0A $43 $29
.db $04 $D4 $30 $00 $C2 $42 $84 $03 $24 $04 $41 $09 $C8 $31 $8A $2F
.db $04 $41 $01 $25 $04 $42 $03 $08 $BE $C3 $43 $83 $B6 $22 $2E $29
.db $04 $35 $C6 $41 $8F $AE $03 $4B $01 $21 $58 $E1 $29 $76 $35 $EA
.db $22 $02 $06 $11 $02 $41 $42 $87 $42 $0E $41 $08 $02 $48 $60 $00
.db $21 $F4 $82 $47 $4F $46 $95 $46 $47 $B8 $BE $39 $EA $1F $07 $CA
.db $30 $8D $10 $06 $04 $12 $00 $50 $05 $14 $06 $79 $06 $41 $22 $50
.db $47 $1A $50 $41 $1A $41 $36 $03 $02 $50 $41 $1A $C3 $30 $0A $10
.db $01 $05 $05 $07 $20 $6C $60 $4D $BB $83 $07 $20

; Data from E5A5 to FFFF (6747 bytes)
_DATA_E5A5_:
.incbin "Micro Machines_e5a5.inc"

.BANK 4
.ORG $0000

; Data from 10000 to 13FFF (16384 bytes)
.incbin "Micro Machines_10000.inc"

.BANK 5
.ORG $0000

; Data from 14000 to 169A7 (10664 bytes)
.incbin "Micro Machines_14000.inc"

; Data from 169A8 to 16A37 (144 bytes)
_DATA_169A8_:
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01
.db $80 $40 $20 $10 $08 $04 $02 $01 $80 $40 $20 $10 $08 $04 $02 $01

; Data from 16A38 to 17DD4 (5021 bytes)
_DATA_16A38_:
.incbin "Micro Machines_16a38.inc"

; Data from 17DD5 to 17E54 (128 bytes)
_DATA_17DD5_:
.db $FF $FF $00 $00 $FF $FD $7E $00 $FF $FF $66 $00 $FF $FD $7E $00
.db $FF $FF $60 $00 $F1 $F1 $60 $00 $F1 $F1 $60 $00 $F1 $F1 $00 $00
.db $E3 $E3 $00 $00 $E7 $E5 $C3 $00 $E7 $E7 $C3 $00 $E7 $E7 $C3 $00
.db $FF $FF $C3 $00 $FF $FF $FB $00 $FF $FF $FB $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $FF $EF $F6 $00 $FF $FF $36 $00 $FF $FB $F7 $00
.db $FF $FF $31 $00 $FB $FB $31 $00 $FB $FB $31 $00 $FB $FB $00 $00
.db $F7 $F7 $00 $00 $FF $FB $67 $00 $FF $FF $66 $00 $FF $DF $E6 $00
.db $EF $EF $86 $00 $CF $CF $87 $00 $CF $CB $87 $00 $C7 $C7 $00 $00

; Data from 17E55 to 17E94 (64 bytes)
_DATA_17E55_:
.db $FF $FF $00 $00 $FF $DF $EF $00 $FF $FF $6C $00 $FF $FF $6F $00
.db $FF $FF $6C $00 $FE $FE $EC $00 $FE $DE $EC $00 $FE $FE $00 $00
.db $FF $FF $00 $00 $FF $FF $BE $00 $FF $FF $30 $00 $FF $FF $BE $00
.db $FF $FF $30 $00 $78 $78 $30 $00 $78 $78 $30 $00 $78 $78 $00 $00

_LABEL_17E95_:
	ld a, $80
	out ($BF), a
	ld a, $73
	out ($BF), a
	ld bc, $0020
	ld hl, _DATA_17DD5_
	call _LABEL_17EB4_
	ld a, $80
	out ($BF), a
	ld a, $74
	out ($BF), a
	ld bc, $0010
	ld hl, _DATA_17E55_
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

; Pointer Table from 17EC2 to 17ED1 (8 entries, indexed by _RAM_DB97_TrackType)
_DATA_17EC2_:
.dw _DATA_17ED2_ _DATA_17EF2_ _DATA_17F12_ _DATA_17F32_ _DATA_17F52_ _DATA_17F72_ _DATA_17F92_ _DATA_17FB2_

; 1st entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17ED2 to 17EF1 (32 bytes)
_DATA_17ED2_:
.db $00 $05 $06 $3F $2A $15 $02 $24 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00

; 2nd entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17EF2 to 17F11 (32 bytes)
_DATA_17EF2_:
.db $00 $06 $05 $3F $2A $24 $39 $0B $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00

; 3rd entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F12 to 17F31 (32 bytes)
_DATA_17F12_:
.db $25 $00 $3F $0F $05 $0A $14 $29 $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00

; 4th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F32 to 17F51 (32 bytes)
_DATA_17F32_:
.db $00 $2A $3F $0B $06 $05 $35 $02 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00

; 5th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F52 to 17F71 (32 bytes)
_DATA_17F52_:
.db $00 $08 $04 $3F $2A $05 $0B $03 $30 $35 $3A $3F $30 $35 $3A $3F
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00

; 6th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F72 to 17F91 (32 bytes)
_DATA_17F72_:
.db $00 $15 $2A $3F $02 $04 $06 $0B $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00

; 7th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17F92 to 17FB1 (32 bytes)
_DATA_17F92_:
.db $00 $30 $35 $3A $3F $01 $02 $08 $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00

; 8th entry of Pointer Table from 17EC2 (indexed by _RAM_DB97_TrackType)
; Data from 17FB2 to 17FFF (78 bytes)
_DATA_17FB2_:
.db $00 $3F $1A $04 $38 $06 $05 $01 $21 $25 $3A $3F $3A $25 $21 $10
.db $00 $17 $0D $00 $39 $15 $2A $3F $0B $00 $00 $00 $00 $00 $00 $00


.db $FF $FF $FF $FF $FF $FF $FF $DF $FF $FF $FF $DF $FF $FF $FF $7F
.db $FF $7F $FF $FF $FF $7F $FF $FF $FF $7F $FE $FF $FF $FF $FF $FF
.db $FF $F7 $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $05

.BANK 6
.ORG $0000

; Data from 18000 to 1B1A1 (12706 bytes)
.incbin "Micro Machines_18000.inc"

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
.incbin "Micro Machines_1b232.inc"

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
	ld hl, $DC21
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
	ld hl, $DC21
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
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	cp l
	jr nc, +
	ld l, a
	ld a, (_RAM_DEB1_)
	sub l
	ld (_RAM_DEB1_), a
	ret

+:
	sub l
	ld (_RAM_DEB1_), a
	ld a, (_RAM_DF0E_)
	ld (_RAM_DEB2_), a
	ret

++:
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	add a, l
	cp $07
	jr nc, +
	ld (_RAM_DEB1_), a
	ret

+:
	ld a, $07
	ld (_RAM_DEB1_), a
	ret

_LABEL_1BCCB_:
	ld a, (_RAM_DC41_GearToGearActive)
	or a
	jr z, ++
	ld a, (_RAM_DC42_GearToGear_IAmPlayer1)
	or a
	jr z, +
	jr ++

+:
	ld hl, $0000
-:
	dec hl
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
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	cp l
	jr nc, +
	ld l, a
	ld a, (_RAM_DEB1_)
	sub l
	ld (_RAM_DEB1_), a
	jp +++

; Data from 1BE56 to 1BE56 (1 bytes)
.db $C9

+:
	sub l
	ld (_RAM_DEB1_), a
	ld a, (_RAM_DF0E_)
	ld (_RAM_DEB2_), a
	jp +++

; Data from 1BE64 to 1BE64 (1 bytes)
.db $C9

++:
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	add a, l
	cp $07
	jr nc, +
	ld (_RAM_DEB1_), a
	jp +++

; Data from 1BE77 to 1BE77 (1 bytes)
.db $C9

+:
	ld a, $07
	ld (_RAM_DEB1_), a
	jp +++

; Data from 1BE80 to 1BE80 (1 bytes)
.db $C9

+++:
	ret

_LABEL_1BE82_:
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
	ld a, $02 ; Palette index 1
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld a, (_RAM_DB96_TrackIndexForThisType)
	or a
	jr z, _LABEL_1BEF2_ret
	cp $01
	jr z, +
  ; Track 2
	ld a, $08 ; $0804
	out ($BE), a
	ld a, $04
	out ($BE), a
	ld a, $04 ; $0004
	out ($BE), a
	ld a, $00
	out ($BE), a
	ret
+:; Track 1
	ld a, $40 ; $0840
	out ($BE), a
	ld a, $08
	out ($BE), a
	ld a, $00 ; $0004
	out ($BE), a
	ld a, $04
	out ($BE), a
	ret

_LABEL_1BEF2_ret:
	ret

++:
  ; Master System
	ld a, $01 ; Palette index 1
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld a, (_RAM_DB96_TrackIndexForThisType)
	or a
	jr z, _LABEL_1BEF2_ret
	cp $01
	jr z, +
  ; Track 2
	ld a, $12 ; %00010010 = #aa0055 = pink
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret
+:; Track 1
	ld a, $24 ; %00100100 = #005555 = 
	out ($BE), a
	ld a, $10
	out ($BE), a
	ret

_LABEL_1BF17_:
	ld a, (ix+30)
	or a
	jr z, +
	cp $06
	jr nz, ++
+:
	ld a, (_RAM_DC3D_IsHeadToHead)
	or a
	jr nz, ++
	ld l, (ix+47)
	ld h, (ix+48)
	xor a
	ld (hl), a
	ld (ix+20), a
	jp _LABEL_2961_

; Data from 1BF35 to 1BF43 (15 bytes)
.db $DD $7E $0C $6F $DD $BE $0D $3E $00 $20 $01 $3C $DD $77 $0B

++:
	ret

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
.db $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF $06

.BANK 7
.ORG $0000

; Data from 1C000 to 1F8D7 (14552 bytes)
.incbin "Micro Machines_1c000.inc"

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
	ld a, (_RAM_DC3F_)
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
.incbin "Micro Machines_1fb81.inc"

.BANK 8
.ORG $0000

; Data from 20000 to 237E1 (14306 bytes)
.incbin "Micro Machines_20000.inc" skip 0 read $23656-$20000
_DATA_23656_:
.incbin "Micro Machines_20000.inc" skip $23656-$20000 read $237e2-$23656

_LABEL_237E2_:
	xor a
	ld (_RAM_DCD8_), a
	ld a, $01
	ld (_RAM_DD19_), a
	ld a, $02
	ld (_RAM_DD5A_), a
	ld hl, $DD9E
	ld (_RAM_DCCD_), hl
	ld hl, $DDCE
	ld (_RAM_DD0E_), hl
	ld hl, $DDFE
	ld (_RAM_DD4F_), hl
	ld a, $38
	ld (_RAM_DD80_), a
	ld a, $3A
	ld (_RAM_DDB0_), a
	ld a, $3C
	ld (_RAM_DDE0_), a
	ld a, $3E
	ld (_RAM_DE10_), a
	ld hl, $DE5F
	ld (_RAM_DCD2_), hl
	ld hl, $DE60
	ld (_RAM_DD13_), hl
	ld hl, $DE61
	ld (_RAM_DD54_), hl
	ld hl, $DE32
	ld (_RAM_DCDA_), hl
	ld hl, $DE35
	ld (_RAM_DD1B_), hl
	ld hl, $DE38
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
	ld hl, _RAM_D580_
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
	ld a, (_RAM_DC3F_)
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
	in a, ($00)
++:
	ld (_RAM_D59C_), a
	ld a, (_RAM_D599_IsPaused)
	or a
	jr nz, ++
	ld a, (_RAM_D59C_)
	and $80
	jr z, +
	ret

+:
	ld a, $01
	ld (_RAM_D59A_), a
	ld (_RAM_D599_IsPaused), a
	ld a, $FF
	out ($7E), a
	ld a, $9F
	out ($7E), a
	ld a, $BF
	out ($7E), a
	ld a, $DF
	out ($7E), a
	ret

++:
	ld a, (_RAM_D59A_)
	or a
	jr z, ++
	ld a, (_RAM_D59C_)
	and $80
	jr z, +
	xor a
	ld (_RAM_D59A_), a
+:
	ret

++:
	ld a, (_RAM_D59C_)
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
	out ($BF), a
	ld a, d
	out ($BF), a
	ld hl, (_RAM_DF77_PaletteAnimationData) ; Read in palette pointer
	ld a, (_RAM_DF75_PaletteAnimationIndex)
	ld c, a
	ld b, $00
	add hl, bc
	ld a, (hl)
	out ($BE), a
	inc hl
	ld a, (hl)
	out ($BE), a
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
	ld hl, _DATA_2BDA6_HelicoptersAnimatedPalette_SMS
	ld (_RAM_DF77_PaletteAnimationData), hl
	jp +++

++:
	ld hl, _DATA_2BDAE_PowerboatsAnimatedPalette_SMS
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
	out ($BF), a
	ld a, d
	out ($BF), a
	ld hl, (_RAM_DF77_PaletteAnimationData)
	ld a, (_RAM_DF75_PaletteAnimationIndex) ; Look up index
	ld c, a
	ld b, $00
	add hl, bc
	ld a, (hl)
	out ($BE), a ; Emit
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
_DATA_2BDA6_HelicoptersAnimatedPalette_SMS
.db $30 $35 $3A $3F $30 $35 $3A $3F 
_DATA_2BDAE_PowerboatsAnimatedPalette_SMS
.db $21 $25 $3A $3F $3A $25 $21 $10

_LABEL_23DB6_:
	ld a, $00
	out ($BF), a
	ld a, $77
	out ($BF), a
	ld bc, $0380
-:
	ld a, $00
	out ($BE), a
	ld a, $00
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	ld a, $00
	out ($BF), a
	ld a, $7E
	out ($BF), a
	ld bc, $0080
-:
	ld a, $14
	out ($BE), a
	ld a, $00
	out ($BE), a
	dec bc
	ld a, b
	or c
	jr nz, -
	ret

; Data from 23DE7 to 23ECE (232 bytes)
_DATA_23DE7_:
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $24 $66 $66 $66 $66
.db $11 $11 $11 $14 $69 $CD $DD $DD $11 $11 $45 $79 $BD $DD $DD $DD
.db $11 $11 $11 $47 $AC $DD $DD $DD $11 $11 $11 $24 $66 $66 $66 $66
.db $11 $11 $11 $24 $68 $99 $99 $99 $11 $11 $45 $79 $BD $DD $DD $DD
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $47 $AC $DD $DD $DD
.db $11 $14 $8B $DF $FF $FF $FF $FF $11 $11 $11 $24 $66 $66 $66 $66
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $24 $68 $99 $99 $99 $11 $11 $11 $14 $69 $CD $DD $DD
.db $11 $11 $11 $47 $AC $DD $DD $DD $11 $14 $8B $DF $FF $FF $FF $FF
.db $11 $11 $45 $79 $BD $DD $DD $DD $11 $11 $11 $11 $12 $33 $33 $33
.db $11 $11 $11 $14 $69 $CD $DD $DD $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $14 $8B $DF $FF $FF $FF $FF $11 $11 $11 $24 $68 $99 $99 $99
.db $11 $11 $11 $11 $12 $33 $33 $33 $11 $11 $11 $14 $69 $CD $DD $DD
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11

; Data from 23ECF to 23FFF (305 bytes)
_DATA_23ECF_:
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $12 $46 $66 $66 $66 $66
.db $11 $11 $11 $46 $9C $DD $DD $DD $11 $14 $57 $9B $DD $DD $DD $DD
.db $11 $11 $14 $7A $CD $DD $DD $DD $11 $11 $12 $46 $66 $66 $66 $66
.db $11 $11 $12 $46 $89 $99 $99 $99 $11 $14 $57 $9B $DD $DD $DD $DD
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $14 $7A $CD $DD $DD $DD
.db $11 $48 $BD $FF $FF $FF $FF $FF $11 $11 $12 $46 $66 $66 $66 $66
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $12 $46 $89 $99 $99 $99 $11 $11 $11 $46 $9C $DD $DD $DD
.db $11 $11 $14 $7A $CD $DD $DD $DD $11 $48 $BD $FF $FF $FF $FF $FF
.db $11 $14 $57 $9B $DD $DD $DD $DD $11 $11 $11 $11 $23 $33 $33 $33
.db $11 $11 $11 $46 $9C $DD $DD $DD $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $48 $BD $FF $FF $FF $FF $FF $11 $11 $12 $46 $89 $99 $99 $99
.db $11 $11 $11 $11 $23 $33 $33 $33 $11 $11 $11 $46 $9C $DD $DD $DD
.db $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11 $11
.db $11 $11 $11 $11 $11 $11 $11 $11 $FF $FF $00 $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00
.db $08

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

_LABEL_2B5D5_:
	ld a, $FF
	out ($7E), a
	ld a, $9F
	out ($7E), a
	ld a, $BF
	out ($7E), a
	ld a, $DF
	out ($7E), a
	ret

; Data from 2B5E6 to 2B615 (48 bytes)
.db $3A $7E $D9 $32 $63 $D9 $C9 $3A $7F $D9 $32 $74 $D9 $C9 $2A $5B
.db $D9 $01 $04 $00 $A7 $ED $42 $22 $5B $D9 $C9 $2A $6C $D9 $01 $04
.db $00 $A7 $ED $42 $22 $6C $D9 $C9 $2A $5B $D9 $23 $22 $5B $D9 $C9

_LABEL_2B616_:
	ld a, (_RAM_D957_)
	ld c, a
	inc a
	and $07
	ld (_RAM_D957_), a
	ld a, c
	and $03
	ld (_RAM_D956_), a
	ld ix, _RAM_D963_SFXTrigger2
	ld bc, _RAM_D94C_
	call _LABEL_2B7A1_
	call +
	ld ix, _RAM_D974_SFXTrigger
	ld bc, _RAM_D94F_
	call _LABEL_2B7A1_
	call ++
	ld a, (_RAM_D95A_)
	or a
	jr nz, _LABEL_2B699_
	call _LABEL_2B6C9_
	call _LABEL_2B70D_
	jp _LABEL_2B751_

+:
	ld a, (_RAM_D964_)
	or a
	ret z
	ld a, (_RAM_D94C_)
	and $0F
	or $90
	out ($7E), a
	ld a, (_RAM_D94D_)
	or $80
	out ($7E), a
	ld a, (_RAM_D94E_)
	out ($7E), a
	ld a, (_RAM_D964_)
	cp $02
	ret nz
	xor a
	ld (_RAM_D964_), a
	ret

++:
	ld a, (_RAM_D975_)
	or a
	ret z
	ld a, (_RAM_D94F_)
	and $0F
	or $B0
	out ($7E), a
	ld a, (_RAM_D950_)
	or $A0
	out ($7E), a
	ld a, (_RAM_D951_)
	out ($7E), a
	ld a, (_RAM_D975_)
	cp $02
	ret nz
	xor a
	ld (_RAM_D975_), a
	ret

_LABEL_2B699_:
	ld a, (_RAM_D96B_)
	ld c, a
	ld a, (_RAM_D97C_)
	or c
	ret nz
	ld a, (_RAM_D957_)
	add a, a
	ld c, a
	ld b, $00
	ld hl, _DATA_2B791_
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
	ld hl, _RAM_D95B_
	ld a, (_RAM_D964_)
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
	out ($7E), a
	ld a, h
	and $3F
	ld (_RAM_D952_), a
	out ($7E), a
	ret

_LABEL_2B70D_:
	ld hl, _RAM_D96C_
	ld a, (_RAM_D975_)
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
	out ($7E), a
	ld a, h
	and $3F
	ld (_RAM_D954_), a
	out ($7E), a
	ret

_LABEL_2B751_:
	ld a, (_RAM_D956_)
	and $01
	jp z, +
	ld a, (_RAM_D964_)
	or a
	ret nz
	ld a, r
	and $07
	ld c, a
	ld a, (_RAM_D953_)
	add a, c
	and $0F
	or $C0
	out ($7E), a
	ld a, (_RAM_D952_)
	and $3F
	out ($7E), a
	ret

+:
	ld a, (_RAM_D975_)
	or a
	ret nz
	ld a, r
	and $07
	ld c, a
	ld a, (_RAM_D955_)
	add a, c
	and $0F
	or $C0
	out ($7E), a
	ld a, (_RAM_D954_)
	and $3F
	out ($7E), a
	ret

; Data from 2B791 to 2B7A0 (16 bytes)
_DATA_2B791_:
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
	ld a, (_RAM_D96B_)
	ld c, a
	ld a, (_RAM_D97C_)
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
	ld a, (_RAM_D958_)
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
.incbin "Micro Machines_2b911.inc"

.BANK 11
.ORG $0000

; Data from 2C000 to 2FFFF (16384 bytes)
.incbin "Micro Machines_2c000.inc"

.BANK 12
.ORG $0000

; Data from 30000 to 30A67 (2664 bytes)
.incbin "Micro Machines_30000.inc"

; Data from 30A68 to 30C67 (512 bytes)
_DATA_30A68_:
.db $00 $00 $00 $00 $7F $7F $7F $00 $7F $41 $41 $00 $7F $41 $41 $00
.db $7F $41 $41 $00 $7F $41 $41 $00 $7F $41 $41 $00 $7F $7F $7F $00
.db $00 $00 $00 $00 $7F $7F $00 $00 $41 $7F $00 $00 $41 $7F $00 $00
.db $41 $7F $00 $00 $41 $7F $00 $00 $41 $7F $00 $00 $7F $7F $00 $00
.db $00 $00 $00 $00 $7F $7F $00 $00 $41 $41 $3E $00 $41 $41 $3E $00
.db $41 $41 $3E $00 $41 $41 $3E $00 $41 $41 $3E $00 $7F $7F $00 $00
.db $00 $00 $00 $00 $7F $7F $00 $00 $41 $41 $00 $3E $41 $41 $00 $3E
.db $41 $41 $00 $3E $41 $41 $00 $3E $41 $41 $00 $3E $7F $7F $00 $00
.db $1C $1C $00 $00 $1C $1C $08 $00 $7E $7E $08 $00 $FE $BE $6C $00
.db $FE $FE $48 $00 $FF $FF $28 $00 $FF $D7 $EE $00 $EF $EF $00 $00
.db $07 $07 $00 $00 $07 $07 $02 $00 $FF $FF $02 $00 $FF $D7 $EE $00
.db $FF $FF $AA $00 $FF $FF $AA $00 $FF $F7 $AE $00 $FF $FF $00 $00
.db $07 $07 $00 $00 $07 $07 $02 $00 $FF $FF $02 $00 $FF $77 $EE $00
.db $FF $FF $8A $00 $FF $FF $8A $00 $FF $F7 $8E $00 $FF $FF $00 $00
.db $DC $DC $00 $00 $DC $DC $88 $00 $FE $FE $88 $00 $FF $FD $CE $00
.db $FF $FF $8A $00 $FF $FF $8A $00 $FF $7F $EA $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $FF $8F $00 $00 $FF $8F $00 $00 $FF $8F $00 $00
.db $FF $F1 $00 $00 $FF $F1 $00 $00 $FF $F1 $00 $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $8F $FF $00 $00 $8F $FF $00 $00 $8F $FF $00 $00
.db $F1 $FF $00 $00 $F1 $FF $00 $00 $F1 $FF $00 $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $8F $8F $70 $00 $8F $8F $70 $00 $8F $8F $70 $00
.db $F1 $F1 $0E $00 $F1 $F1 $0E $00 $F1 $F1 $0E $00 $FF $FF $00 $00
.db $FF $FF $00 $00 $8F $8F $00 $70 $8F $8F $00 $70 $8F $8F $00 $70
.db $F1 $F1 $00 $0E $F1 $F1 $00 $0E $F1 $F1 $00 $0E $FF $FF $00 $00
.db $00 $00 $00 $00 $18 $18 $00 $00 $38 $38 $10 $00 $5C $64 $38 $00
.db $74 $6C $38 $00 $38 $38 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $18 $18 $00 $00 $34 $3C $18 $00 $3A $3E $1C $00 $56 $6A $3C $00
.db $AA $FE $7C $00 $5A $66 $3C $00 $3C $3C $00 $00 $00 $00 $00 $00
.db $1C $1C $00 $00 $2A $3E $1C $00 $2D $3F $1E $00 $53 $6D $3E $00
.db $E6 $BA $7C $00 $B5 $FF $7E $00 $49 $77 $3E $00 $3E $3E $00 $00
.db $1C $1C $00 $00 $36 $2A $1C $00 $22 $3E $1C $00 $36 $2A $1C $00
.db $7E $7E $00 $00 $D7 $B5 $62 $00 $7D $5B $26 $00 $26 $26 $00 $00

; Data from 30C68 to 30CE7 (128 bytes)
_DATA_30C68_LapRemainingIndicators: ; Number tiles
.db $00 $00 $00 $00 $1E $1E $00 $00 $3E $3E $0C $00 $3E $3E $1C $00 ; 0
.db $3E $3E $0C $00 $3F $3F $0C $00 $3F $3F $1E $00 $3F $3F $00 $00
.db $00 $00 $00 $00 $3E $3E $00 $00 $7F $5D $3E $00 $7F $7F $36 $00 ; 1
.db $7F $7D $0E $00 $7F $7B $1C $00 $7F $7F $3E $00 $7F $7F $00 $00
.db $00 $00 $00 $00 $7E $7E $00 $00 $7F $7D $3E $00 $7F $7F $06 $00 ; 2
.db $3F $3D $1E $00 $7F $7F $06 $00 $7F $7D $3E $00 $7E $7E $00 $00
.db $00 $00 $00 $00 $7F $7F $00 $00 $7F $7F $36 $00 $7F $7F $36 $00 ; 3
.db $7F $5F $3E $00 $3F $3F $06 $00 $0F $0F $06 $00 $0F $0F $00 $00

_LABEL_30CE8_:
	or a
	jr nz, +
	ld a, $04
+:
	dec a
	ld c, a
	ex af, af'
	ld b, $00
	ld hl, _DATA_31410_
	add hl, bc
	ld a, (hl)
	ld (_RAM_D916_), a
	add a, $0C
	ld (_RAM_D917_), a
	xor a
	ld (_RAM_D918_), a
	ex af, af'
	add a, a
	ld c, a
	ld hl, _DATA_314F7_
	add hl, bc
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld (_RAM_D929_), hl
	ld a, $06
	ld (_RAM_D92B_), a
	ld (_RAM_D92C_), a
	ld a, $01
	ld (_RAM_D92F_), a
	ld (_RAM_D74D_), a
	ld (_RAM_D772_), a
	ld (_RAM_D797_), a
	ret

_LABEL_30D28_:
	ld hl, _DATA_314AF_
	ld de, _RAM_D91A_
	ld bc, $000F
	ldir
	jp _LABEL_30F7D_

_LABEL_30D36_MainVBlankImpl:
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
	ld a, (_RAM_D92B_)
	dec a
	ld (_RAM_D92B_), a
	jp nz, _LABEL_30DC7_
	ld a, (_RAM_D915_)
	or a
	jr nz, +
	ld a, (_RAM_D92C_)
+:
	ld (_RAM_D92B_), a
	ld a, (_RAM_D92F_)
	dec a
	and $3F
	ld (_RAM_D92F_), a
	jp nz, +
	ld hl, (_RAM_D929_)
	ld a, (hl)
	inc hl
	ld (_RAM_D929_), hl
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
	ld a, (_RAM_D916_)
	call _LABEL_31093_
	call _LABEL_31068_
	ld ix, _RAM_D769_
	ld iy, $D923
	ld a, (_RAM_D917_)
	call _LABEL_31093_
	call _LABEL_31068_
	ld ix, _RAM_D78E_
	ld iy, $D924
	ld a, (_RAM_D918_)
	call _LABEL_31093_
	call _LABEL_31068_
	ld (_RAM_D92D_), hl
_LABEL_30DC7_:
	ld iy, _RAM_D91A_
	ld ix, _RAM_D744_
	ld de, _RAM_D922_
	call +
	ld iy, _RAM_D91C_
	ld ix, _RAM_D769_
	ld de, _RAM_D923_
	call +
	ld iy, _RAM_D91E_
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
	ld ix, _RAM_D91A_
	ld c, $80
	call _LABEL_30FCA_
	ld c, $90
	ld a, (_RAM_D922_)
	or c
	out ($7E), a
	inc ix
	inc ix
	ld c, $A0
	call _LABEL_30FCA_
	ld c, $B0
	ld a, (_RAM_D923_)
	or c
	out ($7E), a
	inc ix
	inc ix
	ld c, $C0
	call _LABEL_30FCA_
	ld c, $D0
	ld a, (_RAM_D924_)
	or c
	out ($7E), a
	ld a, (_RAM_D920_)
	bit 7, a
	jr nz, +
	ld c, a
	ld a, $E0
	out ($7E), a
	ld a, c
	and $07
	out ($7E), a
+:
	ld a, (_RAM_D921_)
	ld c, $F0
	or c
	out ($7E), a
	ret

_LABEL_30FCA_:
	ld e, (ix+0)
	ld d, (ix+1)
	ld a, e
	and $0F
	or c
	out ($7E), a
	rr d
	rr e
	rr d
	rr e
	rr d
	rr e
	rr d
	rr e
	ld a, e
	out ($7E), a
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
	ld (_RAM_D92B_), a
	ld (_RAM_D92C_), a
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
	ld (_RAM_D929_), hl
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
.db $F6 $FB $FE $FA $FA $FC $FC $FB $FD $FD
.db $FC $FE

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
_DATA_314AF_:
.db $00 $00 $00 $00 $00 $00 $07 $0F $0F $0F $0F $00 $00
.db $00 $00 $00 $05 $02 $03 $02 $04 $06 $07 $02 $03 $02 $04 $09 $08
.db $0B $0B $0A $0A $0C $0D $0C $0E $00 $00 $0F $10 $11 $11 $12 $13
.db $11 $11 $14 $15 $16 $18 $17 $19 $1A $1B $1B $1C $1D $1F $20 $21
.db $10 $22 $22 $23 $24 $25 $26 $27 $28 $29 $2A 
_DATA_314F7_:
.db $BE $94 $D6 $94 $E3
.db $94 $E9 $94 $EA $94 $EB $94 $EC $94 $F1 $94 $F2 $94 $F3 $94 $F4
.db $94 $F5 $94

; Data from 3150F to 33FFF (10993 bytes)
_DATA_3150F_:
.incbin "Micro Machines_3150f.inc"

.BANK 13
.ORG $0000

; Data from 34000 to 35707 (5896 bytes)
.incbin "Micro Machines_34000.inc"

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
	out ($BF), a
	ld a, $40
	out ($BF), a
	ld bc, $0800 ; loop count - we consume 3x this much data to produce 256 tiles
	ld hl, _RAM_C000_DecompressionTemporaryBuffer
-:
	push bc
    ld b, $03
    ld c, $BE
    otir          ; 3 bytes data
    ld a, $00
    out ($BE), a  ; 1 byte padding
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
	out ($BF), a
	ld a, h
	out ($BF), a
	ld de, $0018  ; Emit three tiles with no flipping
	call _LABEL_35977_Emit3bppTileData
	ld de, $0300  ; move on by 18 tiles
	add hl, de
	ld a, l       ; and repeat
	out ($BF), a
	ld a, h
	out ($BF), a
	ld de, $0018
	call _LABEL_35977_Emit3bppTileData
	ld de, $0300 ; and again
	add hl, de
	ld a, l
	out ($BF), a
	ld a, h
	out ($BF), a
	ld de, $0018
	jp _LABEL_35977_Emit3bppTileData ; and return

_LABEL_35977_Emit3bppTileData:
  ; Emits 3*de bytes from bc to VDP
-:ld a, (bc)
	out ($BE), a
	inc bc
	ld a, (bc)
	out ($BE), a
	inc bc
	ld a, (bc)
	out ($BE), a
	inc bc
	ld a, $00
	out ($BE), a
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
	out ($BF), a
	ld a, h
	out ($BF), a
  
	ld a, (bc)    ; Emit data as-is, in order
	out ($BE), a
	inc bc
	ld a, (bc)
	out ($BE), a
	inc bc
	ld a, (bc)
	out ($BE), a
	inc bc
	ld a, $00   ; Last bitplane is 0
	out ($BE), a
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
	out ($BF), a
	ld a, h
	out ($BF), a
  
-:push hl
    ld a, (bc)    ; Read byte from here
    call _hflipByte_usingHL
    out ($BE), a
    inc bc
    ld a, (bc)
    call _hflipByte_usingHL
    out ($BE), a
    inc bc
    ld a, (bc)
    call _hflipByte_usingHL
    out ($BE), a
    inc bc
    ld a, $00 ; last bitplane is 0
    out ($BE), a
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
; Rotation generation data?
;    ,,- index of underlying data (car position unflipped)
;    ||  ,,- index of rotation?
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
.db $00 $00 $00 $01 $01 $01 $02 $02 $02 $03 $03 $03 $04 $04 $04 $05
.db $05 $05 $06 $06 $06 $07 $07 $07 $08 $08 $08 $09 $09 $09 $0A $0A
.db $0A $0B $0B $0B $0C $0C $0C $0D $0D $0D $0E $0E $0E $0F $0F $0F
.db $10 $10 $10 $11 $11 $11 $12 $12 $12 $13 $13 $13 $14 $14 $14 $15
.db $15 $15 $16 $16 $16 $17 $17 $17 $18 $18 $18 $19 $19 $19 $1A $1A
.db $1A $1B $1B $1B $1C $1C $1C $1D $1D $1D $1E $1E $1E $1F $1F $1F

; Data from 35BED to 35C2C (64 bytes)
_DATA_35BED_:
.db $00 $00 $60 $00 $C0 $00 $20 $01 $80 $01 $E0 $01 $40 $02 $A0 $02
.db $00 $03 $60 $03 $C0 $03 $20 $04 $80 $04 $E0 $04 $40 $05 $A0 $05
.db $00 $06 $60 $06 $C0 $06 $20 $07 $80 $07 $E0 $07 $40 $08 $A0 $08
.db $00 $09 $60 $09 $C0 $09 $20 $0A $80 $0A $E0 $0A $40 $0B $A0 $0B

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
_DATA_35D2D_:
.db $00 $00 $00 $38 $38 $00 $7C $44 $00 $FE $B2 $30 $FE $B2 $30 $FE
.db $82 $00 $7C $44 $00 $38 $38 $00 $00 $00 $00 $38 $38 $00 $44 $44
.db $38 $B2 $B2 $7C $B2 $B2 $7C $82 $82 $7C $44 $44 $38 $38 $38 $00
.db $7A $7A $00 $7F $7F $30 $7F $7F $32 $7F $7F $37 $5F $7F $3F $7F
.db $7F $1D $3F $3F $18 $3D $3D $00 $FF $FF $00 $FF $FF $6D $FF $FF
.db $6D $FF $FF $6D $DF $FF $ED $FF $FF $CD $FF $FF $CD $FF $FF $00
.db $DF $DF $00 $FF $FF $8D $FF $FF $CD $FF $FF $ED $FF $FF $BD $FF
.db $FF $9D $FF $FF $8D $DF $DF $00 $DF $DF $00 $FF $FF $8D $FF $FF
.db $CD $FF $FF $ED $FF $FF $BD $FF $FF $9D $FF $FF $8D $DF $DF $00
.db $FF $FF $00 $FF $FF $FD $FF $FF $81 $FF $FF $F9 $FF $FF $81 $FF
.db $FF $FD $FF $FF $FD $FF $FF $00 $FC $FC $00 $FE $FA $FC $FE $FE
.db $8C $FE $FA $FC $BC $FC $F0 $FE $FE $98 $FE $FE $8C $DE $DE $00
.db $0F $0F $00 $0F $0F $07 $0F $0F $06 $0F $0F $07 $0F $0F $06 $0F
.db $0F $07 $0F $0F $07 $0F $0F $00 $FF $FF $00 $FF $EB $F7 $FF $BF
.db $76 $FF $EF $F6 $FF $BF $76 $FF $FF $F7 $FF $EB $F7 $FF $FF $00
.db $FF $FF $00 $FF $EF $F6 $FF $FF $37 $7F $7F $37 $FF $FF $36 $FF
.db $FF $F6 $FF $EF $F6 $FF $FF $00 $7F $7F $00 $FF $FF $36 $FF $FF
.db $36 $FF $FF $B6 $FF $FF $F6 $FF $FF $77 $FF $FF $33 $7F $7F $00
.db $00 $00 $00 $18 $18 $00 $38 $38 $10 $5C $64 $38 $74 $6C $38 $38
.db $38 $00 $00 $00 $00 $00 $00 $00 $18 $18 $00 $34 $3C $18 $3A $3E
.db $1C $56 $6A $3C $AA $FE $7C $5A $66 $3C $3C $3C $00 $00 $00 $00
.db $1C $1C $00 $2A $3E $1C $2D $3F $1E $53 $6D $3E $E6 $BA $7C $B5
.db $FF $7E $49 $77 $3E $3E $3E $00 $1C $1C $00 $36 $2A $1C $22 $3E
.db $1C $36 $2A $1C $7E $7E $00 $D7 $B5 $62 $7D $5B $26 $26 $26 $00
.db $7F $7F $00 $7F $7B $37 $7F $7F $36 $7F $7B $37 $FF $FF $30 $FF
.db $FF $F6 $FF $FB $E7 $FF $FF $00 $F0 $F0 $00 $F0 $F0 $E0 $F0 $F0
.db $00 $F8 $E8 $F0 $F8 $F8 $30 $F8 $F8 $30 $F8 $E8 $F0 $F0 $F0 $00
.db $00 $00 $00 $3E $3E $00 $7F $5D $3E $7F $7F $36 $7F $7D $0E $7F
.db $7B $1C $7F $7F $3E $7F $7F $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

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
	ld a, (_RAM_DC3F_)
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
	in a, ($00)
	and $80
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
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	cp l
	jr nc, +
	ld l, a
	ld a, (_RAM_DEB1_)
	sub l
	ld (_RAM_DEB1_), a
	ret

+:
	sub l
	ld (_RAM_DEB1_), a
	ld a, (_RAM_DF0E_)
	ld (_RAM_DEB2_), a
	ret

++:
	ld a, (_RAM_DEB1_)
	ld l, a
	ld a, (_RAM_DF0C_)
	add a, l
	cp $07
	jr nc, +
	ld (_RAM_DEB1_), a
	ret

+:
	ld a, $07
	ld (_RAM_DEB1_), a
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
	ld a, (_RAM_DC3F_)
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
	ld hl, _RAM_DB86_
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

_LABEL_36484_:
	ld a, (_RAM_DB97_TrackType)
	cp TT_Powerboats
	jp z, _LABEL_3666D_
	cp TT_SportsCars
	jp z, _LABEL_366CB_
	cp TT_Tanks
	jp z, _LABEL_3665F_
	cp TT_FormulaOne
	jr z, ++
	cp TT_TurboWheels
	jr z, +
	ret

+:
	ld a, $0F
	ld (_RAM_D293_), a
	ld a, $02
	ld (_RAM_D299_), a
	ld (_RAM_D29F_), a
	ld a, $01
	ld (_RAM_D2A5_), a
	ret

++:
	ld a, $C0
	ld (_RAM_CC14_), a
	ld a, $F0
	ld (_RAM_CC23_), a
	ld a, $0F
	ld (_RAM_CC15_), a
	ld a, $0C
	ld (_RAM_CC24_), a
	ld a, $0F
	ld (_RAM_CC04_), a
	ld a, $F0
	ld (_RAM_CC12_), a
	ld a, $04
	ld (_RAM_CBC2_), a
	ld a, $60
	ld (_RAM_CBC4_), a
	ld a, $0E
	ld (_RAM_CBA9_), a
	ld a, $20
	ld (_RAM_CBAB_), a
	ld a, $07
	ld (_RAM_CB3E_), a
	ld a, $40
	ld (_RAM_CB40_), a
	ld a, $F2
	ld (_RAM_CB55_), a
	ld a, $60
	ld (_RAM_CB57_), a
	ld a, $70
	ld (_RAM_CA1A_), a
	ld a, $04
	ld (_RAM_CA18_), a
	ld a, $06
	ld (_RAM_CA23_), a
	ld a, $20
	ld (_RAM_CA25_), a
	ld a, $06
	ld (_RAM_CAA2_), a
	ld a, $4F
	ld (_RAM_CAA4_), a
	ld a, $02
	ld (_RAM_CA95_), a
	ld a, $E0
	ld (_RAM_CA97_), a
	ld a, $85
	ld (_RAM_D1C5_), a
	ld a, $81
	ld (_RAM_D1A9_), a
	ld a, $0F
	ld (_RAM_D191_), a
	ld (_RAM_D192_), a
	ld a, $85
	ld (_RAM_D196_), a
	ld a, $80
	ld (_RAM_D198_), a
	ld a, $09
	ld (_RAM_D199_), a
	ld (_RAM_D19F_), a
	ld a, $81
	ld (_RAM_D1A4_), a
	ld a, $00
	ld (_RAM_D097_), a
	ld (_RAM_D098_), a
	ld a, $0E
	ld (_RAM_D09C_), a
	ld a, $85
	ld (_RAM_D09D_), a
	ld a, $87
	ld (_RAM_D09F_), a
	ld a, $0D
	ld (_RAM_D0A2_), a
	ld a, $84
	ld (_RAM_D0A9_), a
	ld a, $8F
	ld (_RAM_D0B0_), a
	ld a, $8A
	ld (_RAM_D0C4_), a
	ld a, $19
	ld (_RAM_D368_), a
	ld (_RAM_D369_), a
	ld (_RAM_D36E_), a
	ld (_RAM_D36F_), a
	ld (_RAM_D346_), a
	ld (_RAM_D347_), a
	ld (_RAM_D348_), a
	ld (_RAM_D349_), a
	ld (_RAM_D34A_), a
	ld (_RAM_D34B_), a
	ld a, $1A
	ld (_RAM_D33A_), a
	ld (_RAM_D33B_), a
	ld (_RAM_D33C_), a
	ld (_RAM_D33D_), a
	ld (_RAM_D33E_), a
	ld (_RAM_D33F_), a
	ld a, $85
	ld (_RAM_D302_), a
	ld a, $85
	ld (_RAM_D307_), a
	ld a, $0D
	ld (_RAM_D30C_), a
	ld a, $05
	ld (_RAM_D312_), a
	ld a, $83
	ld (_RAM_D313_), a
	ld a, $81
	ld (_RAM_D315_), a
	ld a, $04
	ld (_RAM_D319_), a
	ld a, $0B
	ld (_RAM_D31A_), a
	ld a, $87
	ld (_RAM_D32E_), a
	ld a, $87
	ld (_RAM_D3D7_), a
	ld a, $87
	ld (_RAM_D3DE_), a
	ld a, $09
	ld (_RAM_D3E5_), a
	ld a, $83
	ld (_RAM_D3E8_), a
	ld a, $81
	ld (_RAM_D3EA_), a
	ld a, $0A
	ld (_RAM_D3EB_), a
	ld a, $04
	ld (_RAM_D3EF_), a
	ld a, $0B
	ld (_RAM_D3F0_), a
	ld a, $83
	ld (_RAM_D40B_), a
	ld a, $E5
	ld (_RAM_D489_), a
	ld a, $E2
	ld (_RAM_D4A7_), a
	ld a, $85
	ld (_RAM_D48C_), a
	ld (_RAM_D48D_), a
	ld a, $8D
	ld (_RAM_D491_), a
	ld (_RAM_D497_), a
	ld a, $84
	ld (_RAM_D492_), a
	ld (_RAM_D498_), a
	ld (_RAM_D49E_), a
	ld a, $83
	ld (_RAM_D49F_), a
	ld a, $87
	ld (_RAM_D4B0_), a
	ld a, $80
	ld (_RAM_D4B1_), a
	ld a, $81
	ld (_RAM_D4B7_), a
	ld (_RAM_D4BD_), a
	ld (_RAM_D4C2_), a
	ld (_RAM_D4C3_), a
	ld a, $89
	ld (_RAM_D4B8_), a
	ld (_RAM_D4BE_), a
	ld a, $86
	ld (_RAM_D48E_), a
	ld a, $82
	ld (_RAM_D4A0_), a
	ld a, $84
	ld (_RAM_D4AF_), a
	ld (_RAM_D4C1_), a
	ret

_LABEL_3665F_:
	ld a, (_RAM_DB96_TrackIndexForThisType)
	cp $01
	jr z, +
	ret

+:
	ld a, $19
	ld (_RAM_C0A8_), a
	ret

_LABEL_3666D_:
	ld a, $04
	ld (_RAM_D1A8_), a
	ld (_RAM_D1A9_), a
	ld (_RAM_D1AA_), a
	ld (_RAM_D1AB_), a
	ld (_RAM_D1AC_), a
	ld (_RAM_D1AD_), a
	ld a, (_RAM_DB96_TrackIndexForThisType)
	cp $00
	jr z, ++
	cp $01
	jr z, +++
	cp $02
	jr z, +
	ld a, $B5
	ld (_RAM_C2E3_), a
	ld a, $9E
	ld (_RAM_C2E4_), a
	ld a, $9F
	ld (_RAM_C2E6_), a
	ld a, $B6
	ld (_RAM_C2E7_), a
	ld a, $B7
	ld (_RAM_C2E8_), a
	ret

+:
	ld a, $9D
	ld (_RAM_C108_), a
	ret

++:
	ld a, $1E
	ld (_RAM_C0AC_), a
	ld a, $35
	ld (_RAM_C0AB_), a
	ret

+++:
	ld a, $9D
	ld (_RAM_C10C_), a
	ld a, $35
	ld (_RAM_C111_), a
	ld a, $1E
	ld (_RAM_C112_), a
	ret

_LABEL_366CB_:
	ld a, (_RAM_DB96_TrackIndexForThisType)
	cp $02
	jr z, +
	ret

+:
	ld a, $34
	ld (_RAM_C000_DecompressionTemporaryBuffer), a
	ld a, $32
	ld (_RAM_C3E0_), a
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
	ld (_RAM_DA60_SpriteTableXNs+96), a
	ld (_RAM_DA60_SpriteTableXNs+100), a
	add a, $08
	ld (_RAM_DA60_SpriteTableXNs+98), a
	ld (_RAM_DA60_SpriteTableXNs+102), a
	ld a, (iy+0)
	ld (_RAM_DB10_), a
	ld (_RAM_DB11_), a
	add a, $08
	ld (_RAM_DB12_), a
	ld (_RAM_DB13_), a
	ret

+++:
	ld a, (bc)
	cp $00
	jr z, +
	ld a, (ix+1)
	ld (_RAM_DA60_SpriteTableXNs+104), a
	ld (_RAM_DA60_SpriteTableXNs+108), a
	add a, $08
	ld (_RAM_DA60_SpriteTableXNs+106), a
	ld (_RAM_DA60_SpriteTableXNs+110), a
	ld a, (iy+1)
	ld (_RAM_DB14_), a
	ld (_RAM_DB15_), a
	add a, $08
	ld (_RAM_DB16_), a
	ld (_RAM_DB17_), a
	ret

_LABEL_36B0B_:
	ld a, $F0
	ld (_RAM_DB10_), a
	ld (_RAM_DB11_), a
	ld (_RAM_DB12_), a
	ld (_RAM_DB13_), a
	ret

+:
	ld a, $F0
	ld (_RAM_DB14_), a
	ld (_RAM_DB15_), a
	ld (_RAM_DB16_), a
	ld (_RAM_DB17_), a
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
	ld (_RAM_DEB1_), a
	jp ++

+:
	ld a, $00
	jp -

++:
	ld a, (_RAM_DEAF_)
	cp $00
	jr nz, _LABEL_36D06_
	ld a, (_RAM_DEB1_)
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
	out ($BF), a
	ld a, d
	out ($BF), a
  ; Emit data
	ld a, (hl)
	out ($BE), a
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
	ld a, (_RAM_DA60_SpriteTableXNs+112)
	add a, l
	ld (_RAM_DA60_SpriteTableXNs+112), a
	ld a, (_RAM_DA60_SpriteTableXNs+114)
	add a, l
	ld (_RAM_DA60_SpriteTableXNs+114), a
+:
	ld a, (_RAM_DCEA_)
	or a
	jr z, +
	ld a, (_RAM_DAD4_)
	add a, l
	ld (_RAM_DAD4_), a
	ld a, (_RAM_DAD6_)
	add a, l
	ld (_RAM_DAD6_), a
+:
	ld a, (_RAM_DD2B_)
	or a
	jr z, +
	ld a, (_RAM_DAD8_)
	add a, l
	ld (_RAM_DAD8_), a
	ld a, (_RAM_DADA_)
	add a, l
	ld (_RAM_DADA_), a
+:
	ld a, (_RAM_DD6C_)
	or a
	jr z, _LABEL_36F3E_
	ld a, (_RAM_DADC_)
	add a, l
	ld (_RAM_DADC_), a
	ld a, (_RAM_DADE_)
	add a, l
	ld (_RAM_DADE_), a
	jp _LABEL_36F3E_

_LABEL_36F9E_:
	ld a, (_RAM_DEB1_)
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
	ld a, (_RAM_DB18_)
	add a, l
	ld (_RAM_DB18_), a
	ld a, (_RAM_DB19_)
	add a, l
	ld (_RAM_DB19_), a
+:
	ld a, (_RAM_DCEA_)
	or a
	jr z, +
	ld a, (_RAM_DB1A_)
	add a, l
	ld (_RAM_DB1A_), a
	ld a, (_RAM_DB1B_)
	add a, l
	ld (_RAM_DB1B_), a
+:
	ld a, (_RAM_DD2B_)
	or a
	jr z, +
	ld a, (_RAM_DB1C_)
	add a, l
	ld (_RAM_DB1C_), a
	ld a, (_RAM_DB1D_)
	add a, l
	ld (_RAM_DB1D_), a
+:
	ld a, (_RAM_DD6C_)
	or a
	jr z, _LABEL_37071_
	ld a, (_RAM_DB1E_)
	add a, l
	ld (_RAM_DB1E_), a
	ld a, (_RAM_DB1F_)
	add a, l
	ld (_RAM_DB1F_), a
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
	ld a, (_RAM_DEB1_)
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

_LABEL_37292_:
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

_LABEL_3730C_:
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
	ld a, (_RAM_DEB1_)
	cp $00
	jr z, ++
	sub $01
	ld (_RAM_DEB1_), a
	ret

+:
	ld a, $01
	ld (_RAM_DE7F_), a
	ld a, (_RAM_DE90_CarDirection)
	ld (_RAM_DE80_), a
	ret

++:
	ld a, $01
	ld (_RAM_DEB1_), a
	ld (_RAM_DEB8_), a
	ld a, $01
	ld (_RAM_DEB2_), a
	ret

+++:
	ld a, (_RAM_DEB1_)
	add a, $01
	ld (_RAM_DEB1_), a
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
	ld a, (_RAM_DEB1_)
	cp $00
	jr z, ++
	sub $01
	ld (_RAM_DEB1_), a
	ret

+:
	ld a, $01
	ld (_RAM_DE7F_), a
	ld a, (_RAM_DE90_CarDirection)
	ld (_RAM_DE80_), a
	ret

++:
	ld a, $01
	ld (_RAM_DEB1_), a
	ld (_RAM_DEB8_), a
	ld a, $00
	ld (_RAM_DEB2_), a
	ret

+++:
	ld a, (_RAM_DEB1_)
	add a, $01
	ld (_RAM_DEB1_), a
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
	in a, ($DC)
	ld b, a
	and $3F
	ld (_RAM_DB20_Player1Controls), a
	ld a, (_RAM_DC54_IsGameGear)
	or a
	jr nz, + ; ret
  ; Read player 2 controls
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
	in a, ($DC)
	and $3F
	ld (_RAM_DB20_Player1Controls), a
	out ($03), a
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
	ld a, (_RAM_DEB1_)
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
	ld a, (_RAM_DB18_)
	sub l
	ld (_RAM_DB18_), a
	ld a, (_RAM_DB19_)
	sub l
	ld (_RAM_DB19_), a
+:
	ld a, (_RAM_DCEA_)
	or a
	jr z, +
	ld a, (_RAM_DB1A_)
	sub l
	ld (_RAM_DB1A_), a
	ld a, (_RAM_DB1B_)
	sub l
	ld (_RAM_DB1B_), a
+:
	ld a, (_RAM_DD2B_)
	or a
	jr z, +
	ld a, (_RAM_DB1C_)
	sub l
	ld (_RAM_DB1C_), a
	ld a, (_RAM_DB1D_)
	sub l
	ld (_RAM_DB1D_), a
+:
	ld a, (_RAM_DD6C_)
	or a
	jr z, _LABEL_378E9_
	ld a, (_RAM_DB1E_)
	sub l
	ld (_RAM_DB1E_), a
	ld a, (_RAM_DB1F_)
	sub l
	ld (_RAM_DB1F_), a
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
	ld a, (_RAM_DA60_SpriteTableXNs+112)
	sub l
	ld (_RAM_DA60_SpriteTableXNs+112), a
	ld a, (_RAM_DA60_SpriteTableXNs+114)
	sub l
	ld (_RAM_DA60_SpriteTableXNs+114), a
+:
	ld a, (_RAM_DCEA_)
	or a
	jr z, +
	ld a, (_RAM_DAD4_)
	sub l
	ld (_RAM_DAD4_), a
	ld a, (_RAM_DAD6_)
	sub l
	ld (_RAM_DAD6_), a
+:
	ld a, (_RAM_DD2B_)
	or a
	jr z, +
	ld a, (_RAM_DAD8_)
	sub l
	ld (_RAM_DAD8_), a
	ld a, (_RAM_DADA_)
	sub l
	ld (_RAM_DADA_), a
+:
	ld a, (_RAM_DD6C_)
	or a
	jr z, _LABEL_37A18_
	ld a, (_RAM_DADC_)
	sub l
	ld (_RAM_DADC_), a
	ld a, (_RAM_DADE_)
	sub l
	ld (_RAM_DADE_), a
	jr _LABEL_37A18_

_LABEL_37A75_:
	ld a, (_RAM_D5A6_)
	or a
	jp z, _LABEL_37B6B_
	ld ix, _RAM_DA60_SpriteTableXNs+112
	ld iy, _RAM_DB18_
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
	ld a, (_RAM_DC3F_)
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
	ld ix, _RAM_DA60_SpriteTableXNs+112
	ld iy, _RAM_DB18_
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
	ld iy, _RAM_DAD4_
	jr ++

_LABEL_37C4F_:
	ld ix, _RAM_DCEC_
	ld iy, _RAM_DAD8_
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
	ld iy, _RAM_DADC_
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
	ld iy, _RAM_DB1A_
	jr +++

+:
	ld iy, _RAM_DB1C_
	jr +++

++:
	ld iy, _RAM_DB1E_
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
	ld iy, _RAM_DB1A_
	ld ix, _RAM_DAD4_
	jp +++

+:
	ld iy, _RAM_DB1C_
	ld ix, _RAM_DAD8_
	jp +++

++:
	ld iy, _RAM_DB1E_
	ld ix, _RAM_DADC_
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
	ld a, (_RAM_DC3F_)
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
	ld iy, _RAM_DB1A_
	jr +++

+:
	ld iy, _RAM_DB1C_
	jr +++

++:
	ld iy, _RAM_DB1E_
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
	ld de, _RAM_DAD4_
	ld bc, _RAM_DB1A_
	jp +++

+:
	ld ix, _RAM_DCAB_
	call _LABEL_37F3A_
	ld ix, _RAM_DD2D_
	call _LABEL_37F3A_
	ld de, _RAM_DAD8_
	ld bc, _RAM_DB1C_
	jp +++

++:
	ld ix, _RAM_DCAB_
	call _LABEL_37F69_
	ld ix, _RAM_DCEC_
	call _LABEL_37F69_
	ld de, _RAM_DADC_
	ld bc, _RAM_DB1E_
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
	ld (_RAM_DAD8_), a
	ld (_RAM_DB1C_), a
	ld (_RAM_DADA_), a
	ld (_RAM_DB1D_), a
+++:
	ret

_LABEL_37F11_:
	ld a, (ix+21)
	or a
	jr z, +
	ld a, (ix+17)
	ld l, a
	ld a, (_RAM_DAD4_)
	sub l
	jr c, +
	cp $18
	jr nc, +
	ld a, (ix+18)
	ld l, a
	ld a, (_RAM_DB1A_)
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
	ld a, (_RAM_DAD8_)
	sub l
	jr c, +
	cp $18
	jr nc, +
	ld a, (ix+18)
	ld l, a
	ld a, (_RAM_DB1C_)
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
	ld a, (_RAM_DADC_)
	sub l
	jr c, +
	cp $18
	jr nc, +
	ld a, (ix+18)
	ld l, a
	ld a, (_RAM_DB1E_)
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
	jr nz, _LABEL_37FF7_
	ld ix, _RAM_DCAB_
	call +
	ld ix, _RAM_DD2D_
+:
	ld a, (ix+46)
	or a
	jr nz, _LABEL_37FF7_
	ld a, (ix+21)
	or a
	jr z, _LABEL_37FF7_
	ld a, (ix+17)
	ld l, a
	ld a, (_RAM_DA60_SpriteTableXNs+112)
	sub l
	jr c, _LABEL_37FF7_
	cp $18
	jr nc, _LABEL_37FF7_
	ld a, (ix+18)
	ld l, a
	ld a, (_RAM_DB18_)
	sub l
	jr c, _LABEL_37FF7_
	cp $18
	jr nc, _LABEL_37FF7_
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
	ld ix, _RAM_DA60_SpriteTableXNs+112
	ld iy, _RAM_DB18_
	jp _LABEL_37B35_

_LABEL_37FF7_:
	ret

; Data from 37FF8 to 37FFF (8 bytes)
.db $FF $00 $00 $FF $FF $00 $00 $0D

.BANK 14
.ORG $0000

; Data from 38000 to 393CD (5070 bytes)
.incbin "Micro Machines_38000.inc"

	ret nz
	adc a, b
	ld ($475E), a
	sub c
	ld l, h
	add a, d
	add a, b
	call z, _LABEL_2620_
	ld h, b
	ld l, h
	ld (bc), a
	ld (bc), a
	jr nz, +
	ld b, b
	ld a, (hl)
	dec d
	add a, (hl)
	pop bc
	ld c, $F2
	ld e, b
	inc e
	add a, h
	pop de
	ld l, l
	nop
	inc b
	rlca
	adc a, (hl)
	jp m, _LABEL_1FBF_
	and l
	ld d, l
	rst $08	; _LABEL_8_
	push af
	ld e, d
	rla
	ld c, (hl)
	call po, $54D1	; Possibly invalid
	ld a, a
	ld bc, $C705
	ld d, c
	sbc a, h
	jp po, $CE38	; Possibly invalid
+:
	ld b, e
	inc d
	add a, b
	jp p, $1C6D
	ld b, (hl)
	ld ($6C9E), a
	jp p, $5DE8	; Possibly invalid
	adc a, a
	ld c, $31
	ld c, a
	jp p, $FA7F	; Possibly invalid
; Data from 3941A to 3B970 (9559 bytes)
.incbin "Micro Machines_3941a.inc" skip 0 read $3B32F-$3941A

_DATA_3B32F_DisplayCaseTilemapCompressed:
.incbin "Micro Machines_3941a.inc" skip $3B32F-$3941A read $3B37F-$3B32F

_DATA_3B37F_DisplayCaseTilesCompressed:
.incbin "Micro Machines_3941a.inc" skip $3B37F-$3941A read $3B971-$3B37F

_LABEL_3B971_RamCodeLoaderStage2:
  ; Copy more code into RAM...
	ld hl, _LABEL_3B97D_DecompressFromHLToC000	; Loading Code into RAM
	ld de, _RAM_D7BD_RamCode
	ld bc, $0392 ; A lot! 914 bytes
	ldir
	ret

; Executed in RAM at d7bd
_LABEL_3B97D_DecompressFromHLToC000:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
	ld de, _RAM_C000_DecompressionTemporaryBuffer
	call $D7C9	; Code is loaded from RAM_decompress
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at d7c9
; This is a copy (?) of the code at _LABEL_7B21_Decompress
RAM_decompress:
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

---:
      ld b, a
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

; Executed in RAM at d7ec
--:









      ld b, a
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
; Executed in RAM at d804
-:
        ld b, $00
        inc c
        ldi
; Executed in RAM at d809
+:
        ldir
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

--:
    ldi
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
; Executed in RAM at d85e
+:	
    jr z, -
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
-:
      ld c, a
      push hl
        ld l, e
        ld h, d
        dec hl
        ldi
        ldir
      pop hl
      ex af, af'
      jr _LABEL_3B9FD_get_next_mask_7bits

+:	  ld a, (hl)
      inc hl
      add a, $11
      jr nc, -
      inc b
      jr -

; Executed in RAM at d899
++:




      sub $0F
      jr nz, +
      ld a, (hl)
      inc hl
+:	  add a, $11
      ld b, a
      dec de
      ld a, (de)
      inc de
-:  	inc a
      ld (de), a
      inc de
      djnz -
    ex af, af'
--:	jr _LABEL_3B9FD_get_next_mask_7bits

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
-:    	dec hl
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

+:
      ld a, (hl)
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

+:
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	ld a, $08
	jr _b
  
  ; End of decompress code

; Data from 3BACF to 3BAF0 (34 bytes)
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
    ld a, $0c
    ld ($8000), a
    call _LABEL_30D36_MainVBlankImpl
    ld a, (_RAM_D742_VBlankSavedPageIndex)
    ld ($8000), a
+:  ld a, 1
    ld ($d6d3), a
    in a, ($bf) ; ack INT
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ei
	reti

; Executed in RAM at d966
_LABEL_3BB26_:
	ld a, $0C
	ld ($8000), a
	call _LABEL_30D36_MainVBlankImpl
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at d971
_LABEL_3BB31_Emit3bppTileDataToVRAM:
; hl = source
; de = count of rows to emit
; Write address must be set
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at d974
-:
	ld b, $03
	ld c, $BE
	otir          ; Emit 3 bytes
	xor a
	out ($BE), a  ; Fourth = 0
	dec de
	ld a, d
	or e
	jr nz, -
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at d985
_LABEL_3BB45_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at d988
-:
	ld b, $03
	ld c, $BE
	otir
	xor a
	out ($BE), a
	dec e
	jr nz, -
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at d997
_LABEL_3BB57_EmitTilemapRectangle:
; hl = data address
; de = VRAM address, must be already set
; Parameters in RAM
; Tile index $ff is converted to the blank tile from the font at index $0e
; - but if the high bit is set, it needs to be blank at $10e too...
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
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
	ld a, $0E           ; $ff -> $0e (blank tile)
	jp $D9AD	          ; Code is loaded from ++
+:add a, b            ; Else add offset
; Executed in RAM at d9ad
++:
	out ($BE), a        ; Emit tile index
	ld a, (_RAM_D69C_TilemapRectangleSequence_Flags)
	out ($BE), a        ; And flags/high bit
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
	call $DB00	; Code is loaded from _LABEL_3BCC0_VRAMAddressToDE
	jp $D99A	; Code is loaded from --

; Executed in RAM at d9d0
+:
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at d9d3
_LABEL_3BB93_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
	ld c, $03
; Executed in RAM at d9d8
-:
	ld a, (hl)
	out ($BE), a
	inc hl
	inc de
	dec c
	jr nz, -
	xor a
	out ($BE), a
	inc de
	ld c, $03
; Executed in RAM at d9e6
-:
	ld a, (hl)
	out ($BE), a
	inc hl
	inc de
	dec c
	jr nz, -
	xor a
	out ($BE), a
	inc de
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at d9f5
_LABEL_3BBB5_:
	ld a, $0A
	ld ($D741), a
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
	ld de, _RAM_D701_
	ld bc, $0018
; Executed in RAM at da03
-:
	ld a, (hl)
	cp $FF
	jr nz, +
	ld a, $53
; Executed in RAM at da0a
+:
	add a, $BB
	ld (de), a
	inc hl
	inc de
	dec c
	jr nz, -
	call $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2
	jp _LABEL_93CE_

; Executed in RAM at da18
_LABEL_3BBD8_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
	ld b, $00
; Executed in RAM at da1d
--:
	ld c, $BE
; Executed in RAM at da1f
-:
	ld a, (hl)
	out (c), a
	ld a, $01
	out (c), a
	inc hl
	dec e
	jr z, +
	ld a, e
	and $1F
	jr nz, -
	ld c, $30
	add hl, bc
	jp $DA1D	; Code is loaded from --

; Executed in RAM at da35
+:
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at da38
_LABEL_3BBF8_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at da3b
--:
	call $DB00	; Code is loaded from _LABEL_3BCC0_VRAMAddressToDE
; Executed in RAM at da3e
-:
	ld a, (hl)
	out ($BE), a
	ld a, $01
	out ($BE), a
	inc hl
	inc de
	inc de
	dec b
	jr z, 24
	dec c
	jr nz, -
	ld a, e
	add a, $2A
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld c, $0B
	ld a, l
	add a, $27
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	jp $DA3B	; Code is loaded from --

; Data from 3BC23 to 3BC28 (6 bytes)
.db $CD $48 $DB $C9 $CD $35

	in a, ($1E)
	ret p
; Executed in RAM at da6c
-:
	ld b, $03
	ld c, $BE
	otir
	xor a
	out ($BE), a
	dec e
	jr nz, -
	call $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2
	ret

; Executed in RAM at da7c
_LABEL_3BC3C_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
	ld e, $78
	ld b, $03
	ld c, $BE
	otir
; Data from 3BC47 to 3BC69 (35 bytes)
.db $AF $D3 $BE $1D $20 $F4 $22 $A6 $D6 $C3 $48 $DB $CD $35 $DB $1E
.db $50 $06 $03 $0E $BE $ED $B3 $AF $D3 $BE $1D $20 $F4 $22 $A6 $D6
.db $C3 $48 $DB

_LABEL_3BC6A_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
-:
	ld a, (hl)
	out ($BE), a
	rlc a
	and $01
	out ($BE), a
	inc hl
	dec c
	jr nz, -
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at dabd
_LABEL_3BC7D_DisplayCase_RestoreRectangle:
; Restores tilemap data from hl to de (must be already set)
; 5 tiles wide rectangles from 22 tiles wide source data
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
; Executed in RAM at dac0
--:
	ld c, $05   ; Width
; Executed in RAM at dac2
-:
	ld a, (hl) ; Emit a byte from (hl), high tileset
	out ($BE), a
	ld a, $01
	out ($BE), a
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
  call $DB00 ; Code is loaded from _LABEL_3BCC0_VRAMAddressToDE
  jp $dac0 ; actually --
  
  ; When done...
+:jr _LABEL_3BD08_BackToSlot2

; Executed in RAM at $daef
_LABEL_03BCAF_:
  call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
  ; Emit 3bpp tile data for e bytes
-:ld b, $03
  ld c, $be
  otir
  xor a
  out ($be), a ; Zero-padded
  dec e
  jr nz, -
  jr _LABEL_3BD08_BackToSlot2

; Executed in RAM at db00
_LABEL_3BCC0_VRAMAddressToDE:
	ld a, e
	out ($BF), a
	ld a, d
	out ($BF), a
	ret

; Executed in RAM at db07
_LABEL_3BCC7_VRAMAddressToHL:
	ld a, l
	out ($BF), a
	ld a, h
	out ($BF), a
	ret

; Data from 3BCCE to 3BCDB (14 bytes)
.db $CD $35 $DB $1A $C3 $3C $DB $CD $35 $DB $0A $C3 $3C $DB

; Executed in RAM at db1c
_LABEL_3BCDC_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
	ld a, c
	call $8CE8	; Possibly invalid
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Executed in RAM at db26
_LABEL_3BCE6_:
	call $DB35	; Code is loaded from _LABEL_3BCF5_RestorePagingFromD741
	call _LABEL_8D28_
	jp $DB48	; Code is loaded from _LABEL_3BD08_BackToSlot2

; Data from 3BCEF to 3BCF4 (6 bytes)
.db $CD $35 $DB $C3 $03 $A0

; Executed in RAM at db35
_LABEL_3BCF5_RestorePagingFromD741:
	ld a, (_RAM_D741_RAMDecompressorPageIndex)
	ld ($8000), a
	ret

; Data from 3BCFC to 3BD07 (12 bytes)
.db $32 $43 $D7 $3E $02 $32 $00 $80 $3A $43 $D7 $C9

; Executed in RAM at db48
_LABEL_3BD08_BackToSlot2:
	ld a, $02
	ld ($8000), a
	ret

; Data from 3BD0E to 3BFFF (754 bytes)
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00 $00 $FF $FF $00
.db $00 $0E

.BANK 15
.ORG $0000

; Data from 3C000 to 3FFFF (16384 bytes)
.incbin "Micro Machines_3c000.inc" skip 0 read $3ED49-$3C000 

_DATA_3ED49_SplashScreenCompressed:
.incbin "Micro Machines_3c000.inc" skip $3ED49-$3C000 read $3F753-$3ED49

_DATA_3F753_JonsSquinkyTennisCompressed:
.incbin "Micro Machines_3c000.inc" skip $3F753-$3C000 read $40000-$3F753
