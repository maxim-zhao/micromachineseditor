.section "Game sound effects" force
; API functions at start
PagedFunction_2B5D2_GameVBlankUpdateSoundTrampoline:
  jp _GameVBlankUpdateSound

PagedFunction_2B5D5_SilencePSG:
  SetPSGAttenuationImmediate 3, 0
  SetPSGAttenuationImmediate 0, 0
  SetPSGAttenuationImmediate 1, 0
  SetPSGAttenuationImmediate 2, 0
  ret

.ifdef UNNECESSARY_CODE
_Player1SFX_Unused:
  ld a, (_RAM_D97E_Player1SFX_Unused)
  ld (_RAM_D963_SFX_Player1.Trigger), a
  ret

_Player2SFX_Unused:
  ld a, (_RAM_D97F_Player2SFX_Unused)
  ld (_RAM_D974_SFX_Player2), a
  ret

_Engine1Lower_Unused:
  ; _RAM_D95B_EngineSound1.Tone -= 4
  ld hl, (_RAM_D95B_EngineSound1.Tone)
  ld bc, 4
  and a
  sbc hl, bc
  ld (_RAM_D95B_EngineSound1.Tone), hl
  ret

_Engine2Lower_Unused:
  ; _RAM_D96C_EngineSound2.Tone -= 4
  ld hl, (_RAM_D96C_EngineSound2.Tone)
  ld bc, 4
  and a
  sbc hl, bc
  ld (_RAM_D96C_EngineSound2.Tone), hl
  ret

_Engine1Higher_Unused:
  ; _RAM_D95B_EngineSound1.Tone += 1
  ld hl, (_RAM_D95B_EngineSound1.Tone)
  inc hl
  ld (_RAM_D95B_EngineSound1.Tone), hl
  ret
.endif

_GameVBlankUpdateSound:
  ; Generate some cycling numbers
  ld a, (_RAM_D957_Sound_ChopperEngineIndex)
  ld c, a
  inc a
  and $07 ; range 0..7
  ld (_RAM_D957_Sound_ChopperEngineIndex), a
  
  ld a, c
  and $03
  ld (_RAM_D956_Sound_ToneEngineSoundsIndex), a
  
  ; Update SFX #1
  ld ix, _RAM_D963_SFX_Player1.Trigger
  ld bc, _RAM_D94C_SoundChannels.1
  call _GetSFXData
  call _UpdateSFXChannel1
  
  ; And #2
  ld ix, _RAM_D974_SFX_Player2
  ld bc, _RAM_D94C_SoundChannels.2
  call _GetSFXData
  call _UpdateSFXChannel2
  
.ifdef UNNECESSARY_CODE
  ; Select between helicopter and regular engine sounds
  ld a, (_RAM_D95A_Sound_IsChopperEngine)
  or a
  jr nz, _ChopperEngine
.endif
  
  ; And engine sounds (only two)
  call _UpdateEngineSound1
  call _UpdateEngineSound2
  ; The third tone channel is used to make the engine sound a bit randomised
  jp _UpdateTone2WithRandomisedEngineTone ; and ret

_UpdateSFXChannel1:
  ld a, (_RAM_D963_SFX_Player1.Control)
  or a
  ret z
  
  ld a, (_RAM_D94C_SoundChannels.1.Attenuation)
  and PSG_ATTENUATION_MASK
  or PSG_ATTENUATION_CONTROL_MASK | (0 << PSG_CHANNEL_SHIFT)
  out (PORT_PSG), a
  
  ld a, (_RAM_D94C_SoundChannels.1.Tone.Lo)
  or PSG_TONE_CONTROL_MASK | (0 << PSG_CHANNEL_SHIFT)
  out (PORT_PSG), a
  
  ld a, (_RAM_D94C_SoundChannels.1.Tone.Hi)
  out (PORT_PSG), a
  
  ld a, (_RAM_D963_SFX_Player1.Control)
  cp $02
  ret nz

  xor a
  ld (_RAM_D963_SFX_Player1.Control), a
  ret

_UpdateSFXChannel2:
  ld a, (_RAM_D974_SFX_Player2.Control)
  or a
  ret z

  ld a, (_RAM_D94C_SoundChannels.2.Attenuation)
  and PSG_ATTENUATION_MASK
  or PSG_ATTENUATION_CONTROL_MASK | (1 << PSG_CHANNEL_SHIFT)
  out (PORT_PSG), a

  ld a, (_RAM_D94C_SoundChannels.2.Tone.Lo)
  or PSG_TONE_CONTROL_MASK | (1 << PSG_CHANNEL_SHIFT)
  out (PORT_PSG), a

  ld a, (_RAM_D94C_SoundChannels.2.Tone.Hi)
  out (PORT_PSG), a

  ld a, (_RAM_D974_SFX_Player2.Control)
  cp $02
  ret nz

  xor a
  ld (_RAM_D974_SFX_Player2.Control), a
  ret

.ifdef UNNECESSARY_CODE

_ChopperEngine:
  ; SFX noise overrides this
  ld a, (_RAM_D963_SFX_Player1.Noise)
  ld c, a
  ld a, (_RAM_D974_SFX_Player2.Noise)
  or c
  ret nz
  
  ld a, (_RAM_D957_Sound_ChopperEngineIndex)
  add a, a
  ld c, a
  ld b, $00
  ld hl, _ChopperEngineSoundData
  add hl, bc
  ld a, (hl)
  ; Table contains no 0s
  or a
  jr z, +
  SetPSGNoiseImmediate 0 ; Noise mode (two-byte write)
  ld a, (hl)
  out (PORT_PSG), a
+:inc hl
  ld a, (hl) ; Volume
  cpl ; -> attenuation
  and PSG_ATTENUATION_MASK
  or PSG_ATTENUATION_CONTROL_MASK | (PSG_CHANNEL_NOISE << PSG_CHANNEL_SHIFT) ; Noise channel volume
  out (PORT_PSG), a
  ld a, PSG_TONE_CONTROL_MASK | (PSG_CHANNEL_TONE2 << PSG_CHANNEL_SHIFT) | 0 ; Channel 2 tone -> 0
  out (PORT_PSG), a
  xor a
  out (PORT_PSG), a
  ret
.endif
  
; Repetitive code...
.macro UpdateEngineSound args Control, EngineSound, Channel, Tone
  ld hl, EngineSound
  ; SFX tones override this
  ld a, (Control)
  or a
  ret nz
  ; Load values from 0..1 to de, +4 to a
  ld e, (hl) ; Tone
  inc hl
  ld d, (hl) ; Tone
  inc hl
  ; Skipped unused byte
  inc hl
  ld a, (hl) ; Volume
  cpl
  and PSG_ATTENUATION_MASK ; To attenuation
  or PSG_ATTENUATION_CONTROL_MASK | (Channel << PSG_CHANNEL_SHIFT)
  out (PORT_PSG), a
  inc hl

  ; Next comes from +5..+8, rotating each frame
  ld a, (_RAM_D956_Sound_ToneEngineSoundsIndex)
  ld c, a
  ld b, $00
  add hl, bc
  ld l, (hl)
  ld h, $00
  add hl, de ; Add to tone
  ld a, l
  ; split to PSG 6+4 bits
  .repeat 4
  rl l
  rl h
  .endr
  and PSG_TONE_LO_MASK
  ld (Tone+BigEndianWord.Lo), a
  ; We don't actually emit the high bits
  ld a, PSG_TONE_CONTROL_MASK | (Channel << PSG_CHANNEL_SHIFT) | 0
  out (PORT_PSG), a
  ld a, h
  and PSG_TONE_HI_MASK
  ld (Tone+BigEndianWord.Hi), a
  out (PORT_PSG), a
  ret
.endm

_UpdateEngineSound1:
  UpdateEngineSound _RAM_D963_SFX_Player1.Control, _RAM_D95B_EngineSound1, PSG_CHANNEL_TONE0, _RAM_D952_EngineSound1ActualTone

_UpdateEngineSound2:
  UpdateEngineSound _RAM_D974_SFX_Player2.Control, _RAM_D96C_EngineSound2, PSG_CHANNEL_TONE1, _RAM_D954_EngineSound2ActualTone

_UpdateTone2WithRandomisedEngineTone:
  ld a, (_RAM_D956_Sound_ToneEngineSoundsIndex)
  and $01
  jp z, +
  
.macro RandomiseEngineSoundTone args Control, ActualTone
  ld a, (Control)
  or a
  ret nz
  ; If an SFX is not playing
  ; Randomly add 0..3 to the low bits of the tone
  ; Does not handle overflow!
  ld a, r
  and %00000111
  ld c, a
  ld a, (ActualTone + BigEndianWord.Lo)
  add a, c
  and PSG_TONE_LO_MASK
  or PSG_TONE_CONTROL_MASK | (PSG_CHANNEL_TONE2 << PSG_CHANNEL_SHIFT)
  out (PORT_PSG), a
  ld a, (ActualTone + BigEndianWord.Hi)
  and PSG_TONE_HI_MASK
  out (PORT_PSG), a
  ret
.endm 

  ; Every odd frame, do it for player 1
  RandomiseEngineSoundTone _RAM_D963_SFX_Player1.Control _RAM_D952_EngineSound1ActualTone

+:; Every even frame, do it for player 2
  RandomiseEngineSoundTone _RAM_D974_SFX_Player2.Control _RAM_D954_EngineSound2ActualTone

; Data from 2B791 to 2B7A0 (16 bytes)
_ChopperEngineSoundData:
; first is a noise channel mode control byte, or zero to not change it
; second is a volume (not attenuation, so $f = loudest)
; Chopper engine sound!
.repeat 2
.db PSG_NOISE_PERIODIC_FAST    $0F
.db PSG_NOISE_TONE2            $0B
.db PSG_NOISE_PERIODIC_SLOWEST $07
.db PSG_NOISE_PERIODIC_SLOWEST $03
.endr

_GetSFXData:
; ix points at an instance of SFXData
; bc points at an instance of SoundChannel
.define SFX_DATA_END $ff
  ld a, (ix+SFXData.Trigger)
  or a
  jr z, _CheckSFXControl
  
_LoadSFXPointers:
  ; If non-zero, look it up
  dec a ; Make 0-indexed
  add a, a ; Multiply by 6
  ld e, a
  add a, a
  add a, e
  ld e, a ; Look up
  ld d, 0
  ld hl, _SFXData
  add hl, de
  ; Point de at SFXData.VolumePointer
  push ix
  pop de
  inc de
  inc de
  ; And load 6 bytes (3 pointers) there
  push bc
    .repeat 5
    ldi
    .endr
  pop bc
  ; Skip the increments on the last byte (not necessary?)
  ld a, (hl)
  ld (de), a
  ; Clear the trigger
  xor a
  ld (ix+SFXData.Trigger), a
  ; And set the control byte to 1
  inc a
  ld (ix+SFXData.Control), a
  
_CheckSFXControl:
  ; Check the control byte
  ld a, (ix+SFXData.Control)
  or a
  ret z
  
_UpdateVolume:
  ; Get next volume byte
  ld l, (ix+SFXData.VolumePointer.Lo)
  ld h, (ix+SFXData.VolumePointer.Hi)
  ld a, (hl)
  inc hl
  ld (ix+SFXData.VolumePointer.Lo), l
  ld (ix+SFXData.VolumePointer.Hi), h
  ; Convert to attenuation
  cpl
  and PSG_ATTENUATION_MASK
  ld (bc), a
  ld (_RAM_D958_Sound_LastAttenuation), a
  
_UpdateTone:
  ; Next note
  ld l, (ix+SFXData.NotePointer.Lo)
  ld h, (ix+SFXData.NotePointer.Hi)
  ld a, (hl)
  inc hl
  cp SFX_DATA_END
  jr nz, +

_EndOfSFX:
.define VOLUME_MUTE $0f
  ld a, VOLUME_MUTE ; Mute volume
  ld (bc), a
  inc bc    ; Zero tone
  ld (bc), a
  inc bc
  ld (bc), a
  ld a, $02
  ld (ix+SFXData.Control), a
  ; Do not move pointer on
  jp _UpdateNoise

+:; Not end
  or a
  jr nz, +
  ; Zero note -> mute volume
  ld a, VOLUME_MUTE
  ld (bc), a
  jr ++

+:; Else get PSG values for note
  inc bc
  push hl
    ; Convert note index to PSG values
    add a, a
    ld e, a
    ld d, 0
    ld hl, _PSGNotes
    add hl, de
    ; Retrieve it
    ld e, (hl)
    ld a, e
.ifdef UNNECESSARY_CODE
    and $3F ; Unnecessary because we mask to $0f below - maybe meant to mask the high bits
.endif
    inc hl
    ld d, (hl)
    ; Shift left by 4 so we have the high 6/10 bits in d
    .repeat 4
    rl e
    rl d
    .endr
    ; And the low 4 bits are here
    and $0f
    ; Put them into the SoundChannel structure
    ld (bc), a
    inc bc
    ld a, d
    ld (bc), a
  pop hl
++:
  ; Save moved-on pointer
  ld (ix+SFXData.NotePointer.Lo), l
  ld (ix+SFXData.NotePointer.Hi), h

_UpdateNoise:
  ; Get noise data
  ld l, (ix+SFXData.NoisePointer.Lo)
  ld h, (ix+SFXData.NoisePointer.Hi)
  ld a, (hl)
  cp SFX_DATA_END
  jr nz, +
  
_EndOfNoise:
  ; Stop noise only if both noises are now zero
  inc a ; to zero
  ld (ix+SFXData.Noise), a
  ld a, (_RAM_D963_SFX_Player1.Noise)
  ld c, a
  ld a, (_RAM_D974_SFX_Player2.Noise)
  or c
  ret nz
  ; Mute noise
  SetPSGAttenuationImmediate PSG_CHANNEL_NOISE 0
.ifdef UNNECESSARY_CODE
  ; And set the mode
  SetPSGNoiseImmediate PSG_NOISE_PERIODIC_SLOWEST
  ; And follow it up with a second write - which sets the same thing redundantly
  xor a
  out (PORT_PSG), a
.endif
  ret

+:; Some noise data
  inc hl ; move pointer on
  or a
  jr z, + ; zero -> do nothing (no change)
  
  ; Non-zero
  ex af, af'
    ; Apply the tone volume to the noise channel
    ld a, (_RAM_D958_Sound_LastAttenuation)
    or PSG_ATTENUATION_CONTROL_MASK | (PSG_CHANNEL_NOISE << PSG_CHANNEL_SHIFT) ; Apply to channel 3
    out (PORT_PSG), a
    ; And select tone2 periodic noise
    SetPSGNoiseImmediate PSG_NOISE_PERIODIC_TONE2
  ex af, af'
  ; Followed by a second noise write (!) with the data value
  out (PORT_PSG), a
  
  ; Then set the noise flag for this channel
  ld a, $01
  ld (ix+SFXData.Noise), a

+:; Save the moved-on pointer
  ld (ix+SFXData.NoisePointer.Lo), l
  ld (ix+SFXData.NoisePointer.Hi), h
  ret

_PSGNotes:
.dw 0
  PSGNotes 0, 74

; Data from 2B911 to 2BFFF (1775 bytes)
_SFXData:
; Table of triplets of pointers into data per SFX
; Pointers point to various lengths of data following the table
; First pointer is the volume envelope, one byte per frame, $0 = silent, $f = loudest
; Second pointer is the note indexes, one byte per frame, $0 = no change, SFX_DATA_END = end
; Third pointer is the noise data, one byte per frame, $0 = no change, SFX_DATA_END = end
; Sometimes the noise points at _RAM_D97D_Sound_SFXNoiseData, which just holds $ff (and could be in ROM)
.dw _SFX_01_Volumes                     _SFX_01_Notes                     _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_02_HitGround_Volumes           _SFX_02_HitGround_Notes           _SFX_02_HitGround_Noise
.dw _SFX_03_Crash_Volumes               _SFX_03_Crash_Notes               _SFX_03_Crash_Noise
.dw _SFX_04_TankMiss_Volumes            _SFX_04_TankMiss_Notes            _SFX_04_TankMiss_Noise
.dw _SFX_05_Volumes                     _SFX_05_Notes                     _SFX_05_Noise
.dw _SFX_06_Volumes                     _SFX_06_Notes                     _SFX_06_Noise
.dw _SFX_07_EnterSticky_Volumes         _SFX_07_EnterSticky_Notes         _SFX_07_EnterSticky_Noise
.dw _SFX_08_Volumes                     _SFX_08_Notes                     _SFX_08_Noise
.dw _SFX_09_EnterPoolTableHole_Volumes  _SFX_09_EnterPoolTableHole_Notes  _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_0A_TankShoot_Volumes           _SFX_0A_TankShoot_Notes           _SFX_0A_TankShoot_Noise
.dw _SFX_0B_Volumes                     _SFX_0B_Notes                     _SFX_0B_Noise
.dw _SFX_0C_LeavePoolTableHole_Volumes  _SFX_0C_LeavePoolTableHole_Notes  _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_0D_Volumes                     _SFX_0D_Notes                     _SFX_0D_Noise
.dw _SFX_0E_FallToFloor_Volumes         _SFX_0E_FallToFloor_Notes         _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_0F_Skid1_Volumes               _SFX_0F_Skid1_Notes               _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_10_Skid2_Volumes               _SFX_10_Skid2_Notes               _SFX_10_Skid2_Noise
.dw _SFX_11_Volumes                     _SFX_11_Notes                     _SFX_11_Noise
.dw _SFX_12_WinOrCheat_Volumes          _SFX_12_WinOrCheat_Notes          _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_13_HeadToHeadWinPoint_Volumes  _SFX_13_HeadToHeadWinPoint_Notes  _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_14_Playoff_Volumes             _SFX_14_Playoff_Notes             _RAM_D97D_Sound_SFXNoiseData
.dw _SFX_15_HitFloor_Volumes            _SFX_15_HitFloor_Notes            _SFX_15_HitFloor_Noise
.dw _SFX_16_Respawn_Volumes             _SFX_16_Respawn_Notes             _SFX_16_Respawn_Noise

; Volumes tend to terminate with 0
; Notes and noise terminate with SFX_DATA_END and no-op with 0
; Streams tend to be the same length but don't have to be; volumes should be at least as long as the longest one - 1
_SFX_01_Volumes:  .db $0F $0E $0D $0C $0B $0A $08 $00
_SFX_01_Notes:    .db $18 $18 $18 $18 $18 $18 $18 SFX_DATA_END

_SFX_02_HitGround_Volumes: .db $0F $0C $09 $06 $03 $00
_SFX_02_HitGround_Notes:   .db $01 $05 $01 $05   0 SFX_DATA_END
_SFX_02_HitGround_Noise:   .db PSG_NOISE_TONE2 PSG_NOISE_FAST 0 0 SFX_DATA_END

_SFX_03_Crash_Volumes:  .db $0F $0E $0D $0C $0B $0A $09 $00
_SFX_03_Crash_Notes:    .db $06 $05 $04 $03 $02 $01   0 SFX_DATA_END
_SFX_03_Crash_Noise:    .db PSG_NOISE_FAST 0 PSG_NOISE_SLOW 0 PSG_NOISE_TONE2 0   0 SFX_DATA_END

_SFX_04_TankMiss_Volumes: .db $0F $0E $0D $0C $0B $0A $09 $08 $07 $00
_SFX_04_TankMiss_Notes:   .db $05   0   0 $04   0 $03   0   0 SFX_DATA_END
_SFX_04_TankMiss_Noise:   .db PSG_NOISE_MEDIUM 0 0 PSG_NOISE_FAST 0 PSG_NOISE_TONE2 0 0 SFX_DATA_END

_SFX_05_Volumes:  .db $0F $0F $0F $0E $0E $0D $0D $0D $0C $0C $0B $0B $0B $0A $0A $09 $09 $09 $08 $08 $08 $00
_SFX_05_Notes:    .db $01   0   0   0   0 $01   0   0   0   0 $01   0   0   0   0 $01   0   0   0   0 SFX_DATA_END
_SFX_05_Noise:    .db PSG_NOISE_MEDIUM 0 0 0 PSG_NOISE_FAST 0 0 0 0 PSG_NOISE_SLOW 0 0 0 0 PSG_NOISE_TONE2 0 0 0 0 SFX_DATA_END

_SFX_06_Volumes:  .db $0F $0F $0E $0E $0C $0C $0A $0A $08 $00
_SFX_06_Notes:    .db $1E $0A $0A $0C $0E $10 $12 $14   0 SFX_DATA_END
_SFX_06_Noise:    .db PSG_NOISE_FAST 0 PSG_NOISE_MEDIUM 0 PSG_NOISE_SLOW 0 PSG_NOISE_TONE2 0 SFX_DATA_END

_SFX_07_EnterSticky_Volumes: .db $0F $0F $0E $0E $0C $0C $0A $0A $08 $00
_SFX_07_EnterSticky_Notes:   .db $02 $04 $08 $10 $20   0   0   0   0 SFX_DATA_END
_SFX_07_EnterSticky_Noise:   .db PSG_NOISE_MEDIUM 0 0 0 PSG_NOISE_TONE2 0 0 0 SFX_DATA_END

_SFX_08_Volumes:  .db $0F $0F $0E $0E $0C $0C $0A $0A $08 $08 $07 $07 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $00
_SFX_08_Notes:    .db $18   0 $16   0 $14   0 $12   0 $10   0 $0E   0 $0C   0   0   0   0   0   0   0   0 SFX_DATA_END
_SFX_08_Noise:    .db PSG_NOISE_FAST 0 0 0 PSG_NOISE_MEDIUM 0 0 0 PSG_NOISE_SLOW 0 0 0 PSG_NOISE_TONE2 0 0 0 0 0 0 0 0 SFX_DATA_END

; Volumes are quite a bit longer
_SFX_09_EnterPoolTableHole_Volumes: .db $0F $0F $0F $0F $0E $0E $0E $0E $0D $0D $0D $0D $0C $0C $0C $0C $0B $0B $0B $0B $0A $0A $0A $0A $08 $08 $08 $08 $06 $06 $06 $06 $04 $04 $04 $04 $03 $03 $03 $03 $02 $02 $02 $02 $00
_SFX_09_EnterPoolTableHole_Notes:   .db $32 $31 $30 $2F $2E $2D $2C $2B $2A $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $1F $1E $1D $1C $1B $1A $19 $18 $17 $16 $15 $0A $09 $08 $07 SFX_DATA_END

_SFX_0A_TankShoot_Volumes:  .db $0F $0E $0D $0C $0A $09 $08 $07 $00
_SFX_0A_TankShoot_Notes:    .db $05 $04 $03 $02 $01   0   0 SFX_DATA_END
_SFX_0A_TankShoot_Noise:    .db PSG_NOISE_MEDIUM 0 PSG_NOISE_SLOW 0 PSG_NOISE_FAST 0 0 SFX_DATA_END

_SFX_0B_Volumes:  .db $0F $0D $0B $09 $07 $05 $03 $01 $00
_SFX_0B_Notes:    .db $14 $12 $10 $0E $0C $0A $08 $06 SFX_DATA_END
_SFX_0B_Noise:    .db PSG_NOISE_FAST 0 PSG_NOISE_MEDIUM 0 0 PSG_NOISE_TONE2 0 0 SFX_DATA_END

; Volumes are 1 byte shorter, but actually that doesn't matter
; since the note SFX_DATA_SFX_DATA_END mutes it anyway
_SFX_0C_LeavePoolTableHole_Volumes: .db $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F
_SFX_0C_LeavePoolTableHole_Notes:   .db $28 $2A $2C $2E $30 $32 $0A $0F $14 $19 $1E $23 $28 $2D $32 $37 SFX_DATA_END

_SFX_0D_Volumes:  .db $0F $0E $0C $0A $08 $06 $04 $02 $00
_SFX_0D_Notes:    .db $0A $09 $08 $07 $06 $05   0   0 SFX_DATA_END
_SFX_0D_Noise:    .db PSG_NOISE_FAST 0 PSG_NOISE_MEDIUM 0 PSG_NOISE_FAST 0 PSG_NOISE_SLOW 0 SFX_DATA_END

_SFX_0E_FallToFloor_Volumes:  .db $0F $0F $0F $0F $0E $0E $0E $0E $0D $0D $0D $0D $0C $0C $0C $0C $0B $0B $0B $0B $0A $0A $0A $0A $08 $08 $08 $08 $06 $06 $06 $06 $04 $04 $04 $04 $03 $03 $03 $03 $02 $02 $02 $02 $00
_SFX_0E_FallToFloor_Notes:    .db $22 $22 $22 $21 $21 $21 $20 $20 $20 $1F $1F $1F $1E $1E $1E $1D $1D $1D $1C $1C $1C $1B $1B $1B $1A $1A $1A $19 $19 $19 $18 $18 $18 $17 $17 $17 $16 $16 $16 $15 $15 $15 $14 $14 $14 SFX_DATA_END

_SFX_0F_Skid1_Volumes:  .db $0F $0F $0F $0F $0F $0F $0F $00
_SFX_0F_Skid1_Notes:    .db $28 $27 $28 $29 $28 $27 $28 SFX_DATA_END

_SFX_10_Skid2_Volumes:  .db $0F $0F $0F $0F $0F $0F $00
_SFX_10_Skid2_Notes:    .db $1E $1D $1E $1F $1E $1D SFX_DATA_END
_SFX_10_Skid2_Noise:    .db PSG_NOISE_TONE2 0 0 0 0 0 SFX_DATA_END

_SFX_11_Volumes:  .db $0F $0F $0E $0D $0C $0A $08 $06 $00
_SFX_11_Notes:    .db   0   0   0   0   0   0   0   0 SFX_DATA_END
_SFX_11_Noise:    .db PSG_NOISE_TONE2 0 PSG_NOISE_SLOW 0 PSG_NOISE_TONE2 0 0 0 SFX_DATA_END

; Not enough volumes?
_SFX_12_WinOrCheat_Volumes: .db $01 $01 $02 $02 $03 $03 $04 $04 $05 $05 $06 $06 $07 $07 $08 $08 $09 $09 $0A $0A $0B $0B $0C $0C $0D $0D $0E $0E $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0F $0E $0E $0D $0D $0C $0C $0B $0B $0A $0A $09 $09 $08 $08 $07 $07 $06 $06 $05 $05 $04 $04 $03 $03 $02 $02 $01 $01 $00
_SFX_12_WinOrCheat_Notes:   .db $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $28 $28 $28 $28 $14 $14 $14 $14 $32 $31 $30 $2F $2E $2D $2C $2B $2A $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $1F $1E $1D $1C $1B $1A $19 $18 $17 $16 $15 $14 $13 $12 $11 $10 $0F $0E $0D $0C $0B $0A SFX_DATA_END

_SFX_13_HeadToHeadWinPoint_Volumes: .db $0F $0F $0F $0F $0F $0F $0F $0F $0E $0E $0E $0E $0E $0E $0E $0E $0D $0D $0D $0D $0D $0D $0D $0D $0C $0C $0C $0C $0C $0C $0C $0C $0B $0B $0B $0B $0B $0B $0B $0B $0A $0A $0A $0A $0A $0A $0A $0A $08 $08 $08 $08 $08 $08 $08 $08 $06 $06 $06 $06 $06 $06 $06 $06 $04 $04 $04 $04 $04 $04 $04 $04 $02 $02 $02 $02 $02 $02 $02 $02 $00
_SFX_13_HeadToHeadWinPoint_Notes:   .db $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E $1E $20 $22 $24 $28 $2A $2C $2E SFX_DATA_END

_SFX_14_Playoff_Volumes:  .db $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $0F $0E $0D $0C $0B $0A $08 $06 $00
_SFX_14_Playoff_Notes:    .db $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 $28 $28 $28 $28 $20 $20 $20 $20 SFX_DATA_END

; Noise only...
_SFX_15_HitFloor_Volumes: .db $00 $04 $08 $0C $0F $0F $0F $00
_SFX_15_HitFloor_Notes:   .db   0   0   0   0   0   0   0 SFX_DATA_END
_SFX_15_HitFloor_Noise:   .db PSG_NOISE_FAST 0 PSG_NOISE_MEDIUM 0 PSG_NOISE_SLOW PSG_NOISE_TONE2 0 SFX_DATA_END

; Noise only...
_SFX_16_Respawn_Volumes:  .db $07 $08 $09 $0A $0B $0C $0D $0E $0F $0F $0F $0F $0F $00
_SFX_16_Respawn_Notes:    .db   0   0   0   0   0   0   0   0   0   0   0   0   0 SFX_DATA_END
_SFX_16_Respawn_Noise:    .db PSG_NOISE_TONE2 0 0 PSG_NOISE_SLOW 0 0 PSG_NOISE_MEDIUM 0 0 PSG_NOISE_FAST 0 0 0 SFX_DATA_END
.ends

