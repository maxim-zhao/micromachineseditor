.enum -2
ChannelState_FE_Control_ChannelPlayingTone       db
ChannelState_FF_Control_ChannelPlayingPercussion db
ChannelState_00_Control_StopMusic                db
.ende

.struct MenuSound
  TrackState db ; See ChannelState_* enum above, also used to signal a percussion instrument change
  MinimumAttenuation db ; Attenuation may not be lower (louder) than this, could be used for volume fades - unused in this game
  AdjustedNote db ; Note index after "adjustment" (note offsets)
  CurrentTone instanceof Word ; PSG tone for the current note
  InstrumentPointer instanceof Word ; Pointer to instrument data
  PercussionInstrument db ; If non-zero, the channel is playing a percussion instrument
  Unused_08 db
  ChannelDisabled db ; 1 = do not process channel, unused
  PercussionDisabled db ; Always 0, needs to be 0 for percussion to work?
  
  ; If the instrument is percussion (see PercussionInstrument), these are used:
  PercussionDataPointers .db ; The next three pointers are loaded together using this
  PercussionNotePointer instanceof Word ; Pointer to note data for percussion
  PercussionNoisePointer instanceof Word ; Pointer to noise data for percussion
  PercussionAttenuationPointer instanceof Word ; Pointer to attenuation data for percussion
  
  ; If the instrument is not eprcussion (see PercussionInstrument), these are used:
  InstrumentStartPointer instanceof Word ; Start of tone effects data
  InstrumentCurrentPointer instanceof Word ; Current position in tone effects data
  InstrumentDelayLength db ; Initial value for next one - frames per instrument entry
  InstrumentDelayCounter db ; Counter for the above
  InstrumentIsToneOffset db ; 1 -> instrument tone values apply to tone (PSG value); 0 = values apply to note (index)
  AttenuationDataStart instanceof Word ; initial value for following
  AttenuationDataPointer instanceof Word ; Pointer to attenuation data
  AttenuationCounter db ; Controls rate of walking through attenuation data
  Unused_29 db
  VibratoInitialDelay db ; Frames before vibrato starts
  VibratoSpeed db ; Tone steps per frame
  VibratoCounter db ; Counts frames before vibrato starts, then counts every second frame
  VibratoValue db ; Tone adjustment value
  VibratoDirection db ; Direction of change, 0 = positive
  PitchBendValue db ; Signed 8-bit tone adjustment
  PitchBendEnabled db ; Enabled flag for the previous
.endst

.struct OutputSoundData
  Tone0 dw
  Tone1 dw
  Tone2 dw
  NoiseModeControl db
  NoiseAttenuation db
  Attenuation0 db
  Attenuation1 db
  Attenuation2 db
  Unused dsb 4
.endst

.enum $D744 export
; Per-channel controls
_RAM_D744_MenuSound_Channel0 instanceof MenuSound
_RAM_D769_MenuSound_Channel1 instanceof MenuSound
_RAM_D78E_MenuSound_Channel2 instanceof MenuSound
.ende

; Overlaps with some game RAM...
.enum $D90F export
; These four counters don't actually count, but the code acts as if they do...
_RAM_D90F_MenuSound_Counter2 db ; Counter that is zero every 2 frames
_RAM_D910_MenuSound_Counter4 db ; Counter that is zero every 4 frames
_RAM_D911_MenuSound_Counter8 db ; Counter that is zero every 8 frames, not used
_RAM_D912_MenuSound_Counter16 db ; Counter that is zero every 16 frames, not really used (except it drives the above)

_RAM_D913_MenuSound_NoiseGlobalAttenuation db ; Read only, does have an effect
_RAM_D914_MenuSound_GlobalAttenuation db ; Read only, does have an effect
_RAM_D915_MenuSound_RowDurationOverride db ; Unused, does have an effect

; There are note offsets applied to tones. Tone0 is always offset down,
; tone1 one octave higher and tone2 left alone - but it's not clear why.
_RAM_D916_MenuSound_OffsetDownTone0 db
_RAM_D917_MenuSound_OffsetUpTone1 db
_RAM_D918_MenuSound_OffsetTone2_Always0 db

_RAM_D919_MenuSound_NoteOffset db ; Temporary storage of one of the above during some processing

_RAM_D91A_MenuSoundData instanceof OutputSoundData ; Output SN76489 control data

_RAM_D929_MenuSound_SequencePointer dw ; Points to the current sequence position

; For timing individual notes
_RAM_D92B_MenuSound_RowDurationCounter db
_RAM_D92C_MenuSound_RowDuration db

_RAM_D92D_MenuSound_PatternPointer dw ; Points to the current pattern position
_RAM_D92F_MenuSound_PatternRowCounter db ; How many "rows" are left in the current pattern

_RAM_D930_MenuSound_NoiseData db ; Temporary storage during some processing
.ende

.section "Music engine" force
LABEL_30CE8_Music_Start:
; a = music index (1+)
  or a
  jr nz, +
  ld a, Music_04_Silence ; 0 -> silence
+:
  dec a ; Subtract 1
  ld c, a
  ex af, af'
    ; Look up tone channel note offsets
    ld b, 0
    ld hl, _NoteOffsets
    add hl, bc
    ld a, (hl) ; -ve number
    ld (_RAM_D916_MenuSound_OffsetDownTone0), a
    add a, 12  ; One octave higher
    ld (_RAM_D917_MenuSound_OffsetUpTone1), a
    xor a      ; No offset
    ld (_RAM_D918_MenuSound_OffsetTone2_Always0), a
  ex af, af'

  ; Initialise sequence pointer
  add a, a
  ld c, a
  ld hl, _Sequences
  add hl, bc
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ld (_RAM_D929_MenuSound_SequencePointer), hl

  ; Init other stuff
  ; Default note length
  ld a, $06
  ld (_RAM_D92B_MenuSound_RowDurationCounter), a
  ld (_RAM_D92C_MenuSound_RowDuration), a
  ; Pattern counter ready to underflow
  ld a, 1
  ld (_RAM_D92F_MenuSound_PatternRowCounter), a
  ; Enable all channels
  ld (_RAM_D744_MenuSound_Channel0.ChannelDisabled), a
  ld (_RAM_D769_MenuSound_Channel1.ChannelDisabled), a
  ld (_RAM_D78E_MenuSound_Channel2.ChannelDisabled), a
  ret

LABEL_30D28_StopMusic:
  ld hl, _MusicStopData
  ld de, _RAM_D91A_MenuSoundData
  ld bc, _sizeof_OutputSoundData
  ldir
  jp _EmitToPSG

LABEL_30D36_MenuMusicFrameHandler:
  ; Replicate bits out from the source counter for various power of 2 counters.
  ; Some are used to slow down attenuation changes.
  ; Issue: it's never incremented, so they all stay at zero forever,
  ; and attenuation is always at full speed.
  ; "Fixing" it does change the sound, but not necessarily for the better.
  ; It'd be simpler (and faster) to have a single counter and mask it at use
  ld a, (_RAM_D912_MenuSound_Counter16)
  ld c, a
  and %00000001
  ld (_RAM_D90F_MenuSound_Counter2), a
  ld a, c
  and %00000011
  ld (_RAM_D910_MenuSound_Counter4), a
  ld a, c
  and %00000111
  ld (_RAM_D911_MenuSound_Counter8), a
  ld a, c
  and %00001111
  ld (_RAM_D912_MenuSound_Counter16), a

  ; Decrement a counter. This controls how often we process new data, giving the duration of any individual row in a pattern.
  ld a, (_RAM_D92B_MenuSound_RowDurationCounter)
  dec a
  ld (_RAM_D92B_MenuSound_RowDurationCounter), a
  jp nz, ++
  ; When it resets, set it to _RAM_D915_MenuSound_RowDurationOverride (if non-zero) or _RAM_D92C_MenuSound_RowDuration (otherwise)
  ld a, (_RAM_D915_MenuSound_RowDurationOverride)
  or a
  jr nz, +
  ld a, (_RAM_D92C_MenuSound_RowDuration)
+:ld (_RAM_D92B_MenuSound_RowDurationCounter), a

  ; Decrement another counter. This wraps every 64 "rows" to move the sequence on to the next pattern.
  ld a, (_RAM_D92F_MenuSound_PatternRowCounter)
  dec a
  and $3F
  ld (_RAM_D92F_MenuSound_PatternRowCounter), a
  jp nz, +

  ; When it hits zero:
  ; - Read value pointed by _RAM_D929_MenuSound_SequencePointer
  ld hl, (_RAM_D929_MenuSound_SequencePointer)
  ld a, (hl)
  ; - Increment _RAM_D929_MenuSound_SequencePointer
  inc hl
  ld (_RAM_D929_MenuSound_SequencePointer), hl
  ; - Look up value in _Patterns
  add a, a
  ld c, a
  ld b, 0
  ld hl, _Patterns
  add hl, bc
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ; - Convert to the real address
  ld bc, _PatternBase
  add hl, bc
  ; - Save to _RAM_D92D_MenuSound_PatternPointer
  ld (_RAM_D92D_MenuSound_PatternPointer), hl

+:; Process each channel's state
  ld ix, _RAM_D744_MenuSound_Channel0
  ld iy, _RAM_D91A_MenuSoundData.Attenuation0
  ld hl, (_RAM_D92D_MenuSound_PatternPointer)
  ld a, (_RAM_D916_MenuSound_OffsetDownTone0)
  call _ProcessPatternData
  call _ProcessPercussionData
  ld ix, _RAM_D769_MenuSound_Channel1
  ld iy, _RAM_D91A_MenuSoundData.Attenuation1
  ld a, (_RAM_D917_MenuSound_OffsetUpTone1)
  call _ProcessPatternData
  call _ProcessPercussionData
  ld ix, _RAM_D78E_MenuSound_Channel2
  ld iy, _RAM_D91A_MenuSoundData.Attenuation2
  ld a, (_RAM_D918_MenuSound_OffsetTone2_Always0)
  call _ProcessPatternData
  call _ProcessPercussionData
  ld (_RAM_D92D_MenuSound_PatternPointer), hl
  ; fall through

++:
  ; Convert state to PSG 
  ld iy, _RAM_D91A_MenuSoundData.Tone0
  ld ix, _RAM_D744_MenuSound_Channel0
  ld de, _RAM_D91A_MenuSoundData.Attenuation0
  call +
  ld iy, _RAM_D91A_MenuSoundData.Tone1
  ld ix, _RAM_D769_MenuSound_Channel1
  ld de, _RAM_D91A_MenuSoundData.Attenuation1
  call +
  ld iy, _RAM_D91A_MenuSoundData.Tone2
  ld ix, _RAM_D78E_MenuSound_Channel2
  ld de, _RAM_D91A_MenuSoundData.Attenuation2
  call +
  jp _EmitToPSG

+:
; ix points to the channel control structure
; iy points to the tone destination
; de points to the attenuation destination

  ; Check whether it's percussion, tone, disabled or something else
  ld a, (ix+MenuSound.TrackState)
  cp ChannelState_FF_Control_ChannelPlayingPercussion
  jp z, _ProcessChannel_Percussion
  cp ChannelState_FE_Control_ChannelPlayingTone
  ret z
  ld a, (ix+MenuSound.ChannelDisabled)
  or a
  ret nz

_ProcessChannel_Tone:
  ; Load pointer
  ld l, (ix+MenuSound.InstrumentCurrentPointer.Lo)
  ld h, (ix+MenuSound.InstrumentCurrentPointer.Hi)
  ; Decrement counter
  ld a, (ix+MenuSound.InstrumentDelayCounter)
  dec a
  jr nz, _NoInstrumentUpdate
  ; When it hits zero, load the next pointed value
  ld a, (hl)
  cp Instrument_End
  jr nz, +
  ; If Instrument_End, use AdjustedNote with no further changes
  ; The pointer is not updated so it sticks here
  ld a, (ix+MenuSound.AdjustedNote)
  jr ++

+:cp Instrument_Loop
  jr nz, +
  ; If Instrument_Loop, reload the pointer from InstrumentStartPointer and use the pointed value as a tone adjustment
  ld l, (ix+MenuSound.InstrumentStartPointer.Lo)
  ld h, (ix+MenuSound.InstrumentStartPointer.Hi)
  ld a, (hl)
+:
  ; Move the pointer on
  inc hl
  ld c, a
  ld a, (ix+MenuSound.InstrumentIsToneOffset)
  or a
  jr z, +
  ; Tone offset
  ; Emit tone + c
  ld b, $00
  push hl
    ld l, (ix+MenuSound.CurrentTone.Lo)
    ld h, (ix+MenuSound.CurrentTone.Hi)
    add hl, bc
    ld (iy+0), l
    ld (iy+1), h
    jr +++

+:; Note offset
  ld a, (ix+MenuSound.AdjustedNote)
  add a, c ; Emit note + c
++:
  add a, a ; Look up tone for note
  ld c, a
  ld b, $00
  push hl
    ld hl, _PSGNotes
    add hl, bc
    ld a, (hl)
    ; Emit to destination
    ld (iy+0), a
    inc hl
    ld a, (hl)
    ld (iy+1), a
+++:
  pop hl
  ld a, (ix+MenuSound.InstrumentDelayLength)
_NoInstrumentUpdate:
  ld (ix+MenuSound.InstrumentDelayCounter), a
  ld (ix+MenuSound.InstrumentCurrentPointer.Lo), l
  ld (ix+MenuSound.InstrumentCurrentPointer.Hi), h

  ; Get the attenuation pointer
  ld l, (ix+MenuSound.AttenuationDataPointer.Lo)
  ld h, (ix+MenuSound.AttenuationDataPointer.Hi)
  ; Decrement its counter
  ld a, (ix+MenuSound.AttenuationCounter)
  dec a
  jr nz, +

-:; Move pointer on by 2
  inc hl
  inc hl
  ; Get new attenuation counter
  ld a, (hl)
  ; Then on again and save the pointer
  inc hl
  ld (ix+MenuSound.AttenuationDataPointer.Lo), l
  ld (ix+MenuSound.AttenuationDataPointer.Hi), h

+:; Save the (new or decremented) counter
  ld (ix+MenuSound.AttenuationCounter), a

  ; Get the attenuation data, or control signal
  ld a, (hl)
  cp Instrument_End
  jr nz, +
  ; If it's the end then we use a counter of 1 (could have baked that into the data?)
  ld a, 1
  ld (ix+MenuSound.AttenuationCounter), a
  jr ++

+:cp Instrument_Loop
  jr nz, ++
  ; Reset the pointer
  ld l, (ix+MenuSound.AttenuationDataStart.Lo)
  ld h, (ix+MenuSound.AttenuationDataStart.Hi)
  jr -

++:
  ; Else it's an attenution function index
  and %00000111
  add a, a
  ; Get following byte as a parameter
  inc hl
  ld c, (hl) ; for later use by handler
  push de
    ld e, a
    ld d, $00
    ld hl, _AttenuationFunctions
    add hl, de
  pop de
  ld a, (_RAM_D914_MenuSound_GlobalAttenuation)
  ld b, a ; for later use by handler
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ld a, (de) ; Get current attenuation for later use (often ignored?)
  jp (hl)

_AttenuationFunctions:
.dw _AttenuationFunction_Flat _AttenuationFunction_Louder _AttenuationFunction_Quieter _AttenuationFunction_EndNote _AttenuationFunction_Quieter2 _AttenuationFunction_Quieter4 _AttenuationFunction_Louder2 _AttenuationFunction_Louder4

_AttenuationFunctionDone:
  ; Emit value as attenuation
  ld (de), a
  
  ; Get tone value
  ld l, (iy+0)
  ld h, (iy+1)
  ld a, (ix+MenuSound.VibratoCounter)
  cp -1 ; -1 -> no vibrato
  jr z, _ApplyPitchBend
  dec a
  ld (ix+MenuSound.VibratoCounter), a
  jp nz, _ApplyPitchBend

  ; When it reaches 0, set it back to 1, so it is always 25Hz
  inc a
  ld (ix+MenuSound.VibratoCounter), a

  ; Adjustment
  ; Read value
  ld l, (iy+0)
  ld h, (iy+1)
  ld c, (ix+MenuSound.VibratoSpeed)
  ld a, (ix+MenuSound.VibratoDirection)
  or a
  jp nz, ++
  ; Zero -> add
  ld a, (ix+MenuSound.VibratoValue)
  add a, c
  ; Flip the direction when it gets above 10
  cp 10
  jr c, +
  ; Flip direction
  ld a, (ix+MenuSound.VibratoDirection)
  xor 1
  ld (ix+MenuSound.VibratoDirection), a
  ; Set to 10
  ld a, 10
+:ld (ix+MenuSound.VibratoValue), a
  jp +++

++:
  ; 1 -> subract
  ld a, (ix+MenuSound.VibratoValue)
  sub c
  ; Flip the direction when it gets below 0
  jr nc, +
  ld a, (ix+MenuSound.VibratoDirection)
  xor 1
  ld (ix+MenuSound.VibratoDirection), a
  xor a
+:ld (ix+MenuSound.VibratoValue), a

+++:
  ; Add the result (0..10 plus some overshoot if vibrato is fast) to the tone
  ld c, a
  ld b, $00
  add hl, bc
  ; Fall through

_ApplyPitchBend:
  ; Add extra adjustment
  ld c, (ix+MenuSound.PitchBendValue)
  ; Sign extend
  bit 7, c
  ld b, $00
  jr z, +
  ld b, $FF
+:; Add to tone?
  add hl, bc
  ld (iy+0), l
  ld (iy+1), h
  ret

; Attenuation functions...

; Subtractive (flat or louder)
_AttenuationFunction_Flat:
  ld c, 0 ; No change
  jp +

_AttenuationFunction_Louder4:
  ; Only when the counter is 0 (should be every 4 frames, but it's buggy)
  ld a, (_RAM_D910_MenuSound_Counter4)
  or a
  jr nz, +
  ld a, (de)
  jp _AttenuationFunctionDone

_AttenuationFunction_Louder2:
  ; Only when the counter is 0 (should be every 2 frames, but it's buggy)
  ld a, (_RAM_D90F_MenuSound_Counter2)
  or a
  jr nz, +
  ld a, (de)
  jp _AttenuationFunctionDone

_AttenuationFunction_Louder:
+:ld a, (de) ; Get current attenuation
  sub c ; Subtract parameter value (i.e. get louder)
  jr nc, + ; Clamp to >= 0
  xor a
+:; Clamp to channel loudness
  cp (ix+MenuSound.MinimumAttenuation)
  jr nc, +
  ld a, (ix+MenuSound.MinimumAttenuation)
+:
  cp b ; Clamp to global loudness
  jp nc, _AttenuationFunctionDone
  ld a, b
  jp _AttenuationFunctionDone

; Additive (quieter), similar to above
_AttenuationFunction_Quieter4:
  ld a, (_RAM_D910_MenuSound_Counter4)
  or a
  jr z, +
  ld a, (de)
  jp _AttenuationFunctionDone

_AttenuationFunction_Quieter2:
  ld a, (_RAM_D90F_MenuSound_Counter2)
  or a
  jr z, +
  ld a, (de)
  jp _AttenuationFunctionDone

_AttenuationFunction_Quieter:
+:ld a, (de)
  add a, c
  cp PSG_ATTENUATION_SILENCE
  jp c, _AttenuationFunctionDone
  ld a, PSG_ATTENUATION_SILENCE
  jp _AttenuationFunctionDone

; Special case: disables the channel and silences it
_AttenuationFunction_EndNote:
  ld a, 1
  ld (ix+MenuSound.ChannelDisabled), a
  ld a, PSG_ATTENUATION_SILENCE
  jp _AttenuationFunctionDone


_EmitToPSG:
  ; Point at the data to use
  ld ix, _RAM_D91A_MenuSoundData

  ; Tone channel 0
  ld c, PSG_TONE_CONTROL_MASK | (PSG_CHANNEL_TONE0 << PSG_CHANNEL_SHIFT) ; $80
  call _EmitTone
  ld c, PSG_ATTENUATION_CONTROL_MASK | (PSG_CHANNEL_TONE0 << PSG_CHANNEL_SHIFT) ; $90
  ld a, (_RAM_D91A_MenuSoundData.Attenuation0)
  or c
  out (PORT_PSG), a

  ; Tone channel 1
  inc ix
  inc ix
  ld c, PSG_TONE_CONTROL_MASK | (PSG_CHANNEL_TONE1 << PSG_CHANNEL_SHIFT) ; $A0
  call _EmitTone
  ld c, PSG_ATTENUATION_CONTROL_MASK | (PSG_CHANNEL_TONE1 << PSG_CHANNEL_SHIFT) ; $B0
  ld a, (_RAM_D91A_MenuSoundData.Attenuation1)
  or c
  out (PORT_PSG), a

  ; Tone channel 2
  inc ix
  inc ix
  ld c, PSG_TONE_CONTROL_MASK | (PSG_CHANNEL_TONE2 << PSG_CHANNEL_SHIFT) ; $C0
  call _EmitTone
  ld c, PSG_ATTENUATION_CONTROL_MASK | (PSG_CHANNEL_TONE2 << PSG_CHANNEL_SHIFT) ; $D0
  ld a, (_RAM_D91A_MenuSoundData.Attenuation2)
  or c
  out (PORT_PSG), a

  ld a, (_RAM_D91A_MenuSoundData.NoiseModeControl)
  bit 7, a
  jr nz, +
  ; High bit unset -> change noise mode
  ; The infamous two-byte noise control write
  ld c, a
  ld a, PSG_TONE_CONTROL_MASK | (PSG_CHANNEL_NOISE << PSG_CHANNEL_SHIFT) ; $E0
  out (PORT_PSG), a
  ld a, c
  and PSG_NOISE_MODE_MASK
  out (PORT_PSG), a

+:; Set noise attenuation
  ld a, (_RAM_D91A_MenuSoundData.NoiseAttenuation)
  ld c, PSG_ATTENUATION_CONTROL_MASK | (PSG_CHANNEL_NOISE << PSG_CHANNEL_SHIFT) ; $F0
  or c
  out (PORT_PSG), a
  ret

_EmitTone:
; ix = pointer to PSG tone
; c = channel + type mask
  ; Get data at ix
  ld e, (ix+0)
  ld d, (ix+1)
  ; Low 4 bits ORed with C
  ld a, e
  and $0F
  or c
  out (PORT_PSG), a
  ; Then high bits
  .repeat 4
  rr d
  rr e
  .endr
  ld a, e
  out (PORT_PSG), a
  ret

_ProcessChannel_Percussion:
  ; Get note data
  ld l, (ix+MenuSound.PercussionNotePointer.Lo)
  ld h, (ix+MenuSound.PercussionNotePointer.Hi)
  ld a, (hl)
  cp Instrument_End
  jr nz, +
  ld a, ChannelState_FE_Control_ChannelPlayingTone
  ld (ix+MenuSound.TrackState), a
  xor a
  ld (ix+MenuSound.PercussionDisabled), a
  ret

+:inc hl
  ld (ix+MenuSound.PercussionNotePointer.Lo), l
  ld (ix+MenuSound.PercussionNotePointer.Hi), h
  ; Look up tone value for note
  add a, a
  ld c, a
  ld b, 0
  ld hl, _PSGNotes
  add hl, bc
  ld a, (hl)
  ; Push to iy
  ld (iy+0), a
  inc hl
  ld a, (hl)
  ld (iy+1), a

  ; Get noise data
  ld l, (ix+MenuSound.PercussionNoisePointer.Lo)
  ld h, (ix+MenuSound.PercussionNoisePointer.Hi)
  ld a, (hl)
  inc hl
  ld (ix+MenuSound.PercussionNoisePointer.Lo), l
  ld (ix+MenuSound.PercussionNoisePointer.Hi), h
  ; Push here for later
  ld (_RAM_D930_MenuSound_NoiseData), a

  ; Get attenuation data
  ld l, (ix+MenuSound.PercussionAttenuationPointer.Lo)
  ld h, (ix+MenuSound.PercussionAttenuationPointer.Hi)
  ld a, (hl)
  inc hl
  ld (ix+MenuSound.PercussionAttenuationPointer.Lo), l
  ld (ix+MenuSound.PercussionAttenuationPointer.Hi), h
  
  ; Process attenuation data
  ld b, a
  
  ; ??? Always 0
  ld a, (ix+MenuSound.PercussionDisabled)
  or a
  ld a, b
  jr nz, +
  cp (ix+MenuSound.MinimumAttenuation)
  jr nc, +
  ld a, (ix+MenuSound.MinimumAttenuation)
+:
  ld b, a
  ld a, (_RAM_D913_MenuSound_NoiseGlobalAttenuation)
  cp b
  jp nc, +
  ld a, b
+:
  ld (de), a ; Set channel attenuation
  ld b, a

  ; Process noise data
  ld a, (_RAM_D930_MenuSound_NoiseData)
  ; Set high bit on out of range values so they are ignored. None exist so this is unnecessary.
  ; This could be used to leave noise running.
  cp $09
  jr c, +
  set 7, a
+:
  ld (_RAM_D91A_MenuSoundData.NoiseModeControl), a
  ; Value 8 means we silence it
  cp 8
  ld a, b ; Else we use the tone channel's attenuation
  jr nz, +
  ld a, PSG_ATTENUATION_SILENCE
+:ld (_RAM_D91A_MenuSoundData.NoiseAttenuation), a
  ret

_ProcessPercussionData:
  ld a, (ix+MenuSound.TrackState)
  ; Do nothing unless in range 1..$fd, i.e. a value has been written
  cp ChannelState_FE_Control_ChannelPlayingTone
  ret nc
  or a
  ret z ; ChannelState_00_Control_StopMusic

  push hl
    ; Decrement and multiply by 6
    dec a
    add a, a
    ld c, a
    add a, a
    add a, c
    ; Look up pointers
    ld c, a
    ld b, 0
    ld hl, _PercussionDataPointers
    add hl, bc
    push ix
      ld b, 6 ; 3 pointers
-:    ld a, (hl)
      ld (ix+MenuSound.PercussionDataPointers), a
      inc ix
      inc hl
      djnz -
    pop ix
    ; Clear control value
    ld a, ChannelState_FF_Control_ChannelPlayingPercussion
    ld (ix+MenuSound.TrackState), a
  pop hl
  ret

_ProcessPatternData:
; ix = pointer to tone channel state struct
; iy = pointer to attenuation result
; hl = pointer to pattern data
  ; Save the note offset for the duration of this function
  ld (_RAM_D919_MenuSound_NoteOffset), a
  ; Copy global minimum attenuation to this channel
  ld a, (_RAM_D914_MenuSound_GlobalAttenuation)
  ld (ix+MenuSound.MinimumAttenuation), a
  ; And set PitchBendEnabled to false
  xor a
  ld (ix+MenuSound.PitchBendEnabled), a
  ; Fall through

_ProcessNextDataByte:
  ; Read next data byte
  ld a, (hl)
  ; Check high bit
  cp %10000000
  jp c, _ProcessNextDataByte_Note

_ProcessNextDataByte_Command:
  ; Bit is set -> it is a control byte
  inc hl
.ifdef UNNECESSARY_CODE
  ; Blank high bit
  sub $80
.endif
  ; Mask to low 3 bits and look up in _CommandPointers
  and %00000111
  add a, a
  ld c, a
  ld b, 0
  push hl
    ld hl, _CommandPointers
    add hl, bc
    ld e, (hl)
    inc hl
    ld d, (hl)
  pop hl
  ; And jump to the handler
  push de ; jp (de)
  ret

_Command_Nop:
  inc hl
  jp _ProcessNextDataByte

_CommandPointers:
; Points to handlers for each control value
.dw _Command_SetInstrument
.dw _Command_SetNoteDuration
.dw _Command_SetVolume ; Always used to silence a channel?
.dw _Command_EndPattern ; Unused
.dw _Command_JumpToPattern
.dw _Command_PitchBendUp
.dw _Command_PitchBendDown
.dw _Command_Nop ; Unused

_Command_SetNoteDuration:
  ; Next byte, 6 bits only
  ld a, (hl)
  and %00111111
  inc hl
  ; If it's zero then ignore it
  jp z, _ProcessNextDataByte
  ; Else decide if we are using it or _RAM_D915_MenuSound_RowDurationOverride (if it is set)
  ld c, a
  ld a, (_RAM_D915_MenuSound_RowDurationOverride)
  or a
  jr nz, +
  ld a, c
+:
.ifdef GAME_GEAR_CHECKS
  ; Increment if GG (60Hz compensation?)
  ld c, a
  ld a, (_RAM_DC40_IsGameGear)
  or a
  jr z, +
  inc c
+:
  ld a, c
.endif
  ; Save it as our interval length, and reset the counter
  ld (_RAM_D92B_MenuSound_RowDurationCounter), a
  ld (_RAM_D92C_MenuSound_RowDuration), a
  jp _ProcessNextDataByte

_ProcessNextDataByte_Note:
  ; Next data byte
  ld a, (hl)
  or a
  jp z, +++ ; zero -> do nothing

  ; Else it's a note
  ; Apply the offset
  ld c, a
  ld a, (_RAM_D919_MenuSound_NoteOffset)
  add a, c
  ; And save it to the struct
  ld (ix+MenuSound.AdjustedNote), a
  ; Process it
  add a, a
  push hl
    ld l, a ; Ready to look up tone later...
    ; Zero ChannelDisabled, PitchBendEnabled
    xor a
    ld (ix+MenuSound.ChannelDisabled), a
    ld (ix+MenuSound.PitchBendEnabled), a
    ; If PercussionInstrument is zero, process as a tone
    ld a, (ix+MenuSound.PercussionInstrument)
    or a
    jr z, ++
    
    ; Else check if PercussionDisabled is zero
    ; If it is, we set the percussion instrument as the track number for code to pick up later
    ld c, a
    ld a, (ix+MenuSound.PercussionDisabled)
    or a
    ld a, c
    jr nz, +
    ld (ix+MenuSound.TrackState), a
+:pop hl
  inc hl
  ret

++: ; Further processing of note data
    ; If PitchBendEnabled is 0, set PitchBendValue to 0
    ld a, (ix+MenuSound.PitchBendEnabled)
    or a
    jr nz, +
    ld (ix+MenuSound.PitchBendValue), a
+:  ; Check the track number
    ld h, 0
    ld a, (ix+MenuSound.TrackState)
    cp ChannelState_FE_Control_ChannelPlayingTone
    jr nz, +
    ; If it's ChannelState_FE_Control_ChannelPlayingTone then set it to 0 = ChannelState_00_Control_StopMusic
    ld (ix+MenuSound.TrackState), h
+:  ; Then we look up the note's tone and save to CurrentTone
    ld bc, _PSGNotes
    add hl, bc
    ld a, (hl)
    ld (ix+MenuSound.CurrentTone.Lo), a
    inc hl
    ld a, (hl)
    ld (ix+MenuSound.CurrentTone.Hi), a

    ; Attenuation next
    ; Now read a pointer pointed to by InstrumentPointer
    ; e.g. InstrumentPointer = _Instrument0
    ; so we get the pointer at _Instrument0 = _Instrument0_Tone
    ld l, (ix+MenuSound.InstrumentPointer.Lo)
    ld h, (ix+MenuSound.InstrumentPointer.Hi)
    ld c, (hl)
    inc hl
    ld b, (hl)
    ; - First byte to InstrumentIsToneOffset
    ld a, (bc)
    ld (ix+MenuSound.InstrumentIsToneOffset), a
    inc bc
    ; - Second to InstrumentDelayLength, InstrumentDelayCounter
    ld a, (bc)
    ld (ix+MenuSound.InstrumentDelayLength), a
    ld (ix+MenuSound.InstrumentDelayCounter), a
    inc bc
    ; And save the pointer to InstrumentStartPointer and InstrumentCurrentPointer
    ld (ix+MenuSound.InstrumentStartPointer.Lo), c
    ld (ix+MenuSound.InstrumentCurrentPointer.Lo), c
    ld (ix+MenuSound.InstrumentStartPointer.Hi), b
    ld (ix+MenuSound.InstrumentCurrentPointer.Hi), b
    ; Set AttenuationCounter = 1
    ld a, 1
    ld (ix+MenuSound.AttenuationCounter), a

    ; Then read the next byte pointed by the next pointer in the instrument
    ; e.g. _Instrument0_Attenuation
    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)
    ; Compare to channel and global minimum attenuations, use the largest value = quietest
    ld a, (bc)
    cp (ix+MenuSound.MinimumAttenuation)
    jr nc, +
    ld a, (ix+MenuSound.MinimumAttenuation)
+:  ld e, a
    ld a, (_RAM_D914_MenuSound_GlobalAttenuation)
    cp e
    jr nc, +
    ld a, e
+:  ; Emit as the attenuation
    ld (iy+0), a
    ; Decrement the pointer (?!) and save to AttenuationDataStart, AttenuationDataPointer
    dec bc
    ld (ix+MenuSound.AttenuationDataStart.Lo), c
    ld (ix+MenuSound.AttenuationDataPointer.Lo), c
    ld (ix+MenuSound.AttenuationDataStart.Hi), b
    ld (ix+MenuSound.AttenuationDataPointer.Hi), b
    ; Copy VibratoInitialDelay to VibratoCounter
    ld a, (ix+MenuSound.VibratoInitialDelay)
    ld (ix+MenuSound.VibratoCounter), a
    ; Zero VibratoValue, VibratoDirection
    xor a
    ld (ix+MenuSound.VibratoValue), a
    ld (ix+MenuSound.VibratoDirection), a
  pop hl
+++:
  inc hl
  ret

_Command_PitchBendUp:
  ; Subtract data from PitchBendValue
  ld c, (hl)
  ld a, (ix+MenuSound.PitchBendValue)
  sub c
  ld (ix+MenuSound.PitchBendValue), a
  jr +

_Command_PitchBendDown:
  ; Add data to PitchBendValue
  ld c, (hl)
  ld a, (ix+MenuSound.PitchBendValue)
  add a, c
  ld (ix+MenuSound.PitchBendValue), a
+:; Set PitchBendEnabled = 1
  ld a, 1
  ld (ix+MenuSound.PitchBendEnabled), a
  inc hl
  jp _ProcessNextDataByte

_Command_EndPattern:
.ifdef UNNECESSARY_CODE
  ; Set pattern counter to 1 so it will terminate immediately
  ld a, 1
  ld (_RAM_D92F_MenuSound_PatternRowCounter), a
  inc hl
  jp _ProcessNextDataByte
.endif

_Command_JumpToPattern:
  ; Sets the pattern pointer to the start of some other pattern.
  ; Used for looping.
  ; Data -> bc
  ld a, (hl)
  ld c, a
  ld b, 0
  ; Index into sequence pattern data (weird, would make more sense to just encode the pattern number?) and set _RAM_D929_MenuSound_SequencePointer to that pointer
  push hl
    ld hl, _SequencesBase
    add hl, bc
    ld (_RAM_D929_MenuSound_SequencePointer), hl
    ; Trigger a new pattern read
    ld a, 1
    ld (_RAM_D92F_MenuSound_PatternRowCounter), a
  pop hl
  inc hl
  ; Set all the ChannelDisabled to 1
  ld a, 1
  ld (_RAM_D744_MenuSound_Channel0.ChannelDisabled), a
  ld (_RAM_D769_MenuSound_Channel1.ChannelDisabled), a
  ld (_RAM_D78E_MenuSound_Channel2.ChannelDisabled), a
  ; Mute all the channels
  ld a, PSG_ATTENUATION_SILENCE
  ld (_RAM_D91A_MenuSoundData.Attenuation0), a
  ld (_RAM_D91A_MenuSoundData.Attenuation1), a
  ld (_RAM_D91A_MenuSoundData.Attenuation2), a
  jp _ProcessNextDataByte

_Command_SetVolume:
  ; Get byte, convert volume to attenuation and set as new minimum
  ld a, (hl)
  cpl
  and PSG_ATTENUATION_MASK
  ld (ix+MenuSound.MinimumAttenuation), a
  inc hl
  jp _ProcessNextDataByte

_Command_SetInstrument:
  push de
    ; Read 4-bit number as index into _Instruments
    ld a, (hl)
    and %00001111
    ld e, a
    add a, a
    ld c, a
    ld b, $00
    push hl
      ld hl, _Instruments
      add hl, bc
      ; read into bc and InstrumentPointer
      ld c, (hl)
      ld (ix+MenuSound.InstrumentPointer.Lo), c
      inc hl
      ld b, (hl)
      ld (ix+MenuSound.InstrumentPointer.Hi), b

      ; Set PercussionInstrument = 0
      ld (ix+MenuSound.PercussionInstrument), 0
      ; Check if first pointer is xxFF
      inc bc
      ld a, (bc)
.define IS_PERCUSSION $ff00
      cp >IS_PERCUSSION
      jr nz, +
      ; If it is, set PercussionInstrument = e = instrument index
      ld (ix+MenuSound.PercussionInstrument), e

+:    ; Move on to third value
      inc bc
      inc bc
      inc bc
      ; read into VibratoSpeed and VibratoInitialDelay
      ld a, (bc)
      ld (ix+MenuSound.VibratoSpeed), a
      inc bc
      ld a, (bc)
      ld (ix+MenuSound.VibratoInitialDelay), a
    pop hl
  pop de
  inc hl
  jp _ProcessNextDataByte

; Pointer Table from 31229 to 3124C (18 entries, indexed by unknown)
_Instruments:
; Points to set of pointers (and data) for each effect
.dw _Instrument0 ; Unused, silent
.dw _Instrument1
.dw _Instrument2
.dw _Instrument3 ; Unused
.dw _Instrument4
.dw _Instrument5
.dw _Instrument6 ; Silent instrument used for percussion
.dw _Instrument7
.dw _Instrument6 ; 8 -> 6, percussion
.dw _Instrument6 ; 9 -> 6, percussion - unused
.dw _Instrument10 ; Unused
.dw _Instrument6 ; 11 -> 6, percussion
.dw _Instrument12
.dw _Instrument13
.dw _Instrument7 ; 14 -> 7 - unused
.dw _Instrument7 ; 15 -> 7 - unused

; Pointed-to from above, a bit mixed up

.struct Instrument
  ToneControl dw
  AttenuationControl dw
  VibratoSpeed db
  VibratoDelay db
.endst

.dstruct _Instrument0      instanceof Instrument data _Instrument0_Tone,  _Instrument0_Attenuation,  -1, -1
.dstruct _Instrument7      instanceof Instrument data _Instrument7_Tone,  _Instrument3_Attenuation,  -1, -1
.dstruct _Instrument5      instanceof Instrument data _Instrument5_Tone,  _Instrument5_Attenuation,  -1, -1
.dstruct _Instrument12     instanceof Instrument data _Instrument12_Tone, _Instrument12_Attenuation,  2, 30
.dstruct _Instrument6      instanceof Instrument data IS_PERCUSSION,      _Instrument6_Attenuation,  -1, -1
.dstruct _Instrument3      instanceof Instrument data _Instrument3_Tone,  _Instrument3_Attenuation,  -1, -1
.dstruct _Instrument13     instanceof Instrument data _Instrument13_Tone, _Instrument4_Attenuation,  -1, -1
.dstruct _Instrument4      instanceof Instrument data _Instrument4_Tone,  _Instrument4_Attenuation,  -1, -1
.dstruct _Instrument1      instanceof Instrument data _Instrument1_Tone,  _Instrument1_Attenuation,   4,  6
.dstruct _Instrument10     instanceof Instrument data _Instrument10_Tone, _Instrument5_Attenuation,  -1, -1
.dstruct _UnusedInstrument instanceof Instrument data _Instrument5_Tone,  _Instrument2_Attenuation,   5,  6
.dstruct _Instrument2      instanceof Instrument data _Instrument2_Tone,  _Instrument2_Attenuation,   5,  6

; Pointed-to from above
; First byte -> InstrumentIsToneOffset
; Second byte -> InstrumentDelayLength, InstrumentDelayCounter
; Rest pointed by InstrumentStartPointer, InstrumentCurrentPointer
; - -1 = no more note adjustment
; - -2 = loop back to start
.enum -2
Instrument_Loop db ; -2
Instrument_End db ; -1
.ende
.enum 0
ToneEffect_NoteOffsets db ; 0
ToneEffect_ToneOffsets db ; 1
.ende

_Instrument0_Tone:
.db ToneEffect_NoteOffsets
.db 1, 0
.db Instrument_End

_Instrument5_Tone:
.db ToneEffect_ToneOffsets
.db 1, 0, 2, 0, 4, 0, 2, 0
.db Instrument_End

_Instrument12_Tone:
.db ToneEffect_NoteOffsets
.db 1, 0, 12, 0, 0, 0, 0, 0
.db Instrument_End

; Unused?
.db ToneEffect_NoteOffsets
.db 1, 0, 12, 0, 12, 0
.db Instrument_End

_Instrument3_Tone:
.db ToneEffect_NoteOffsets
.db 1, 0, 4, 7, 12, 0, 4, 7, 12, 0
.db Instrument_End

_Instrument13_Tone:
.db ToneEffect_NoteOffsets
.db 1, 0, 3, 7, 12
.db Instrument_Loop

_Instrument4_Tone:
.db ToneEffect_NoteOffsets
.db 1, 0, 4, 7, 12
.db Instrument_Loop

_Instrument2_Tone:
.db ToneEffect_ToneOffsets
.db 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
.db Instrument_End

_Instrument1_Tone:
.db ToneEffect_ToneOffsets
.db 1, 0, 4, 1, 3, 2
.db Instrument_End

_Instrument10_Tone:
.db ToneEffect_NoteOffsets
.db 1, 0, 24, 0, 24, 0
.db Instrument_End

_Instrument7_Tone:
.db ToneEffect_NoteOffsets
.db 1, 0, 12, 24, 0, 12, 24
.db Instrument_End

; Pointed to from above
; Attenuation envelopes?
; First byte is the initial attenuation
; Then there are pairs (?) of frame count, attenuation mode
; If the attenuation loops then it does so to the first pair
; Attenuation modes:
; 0: no change (same as 1(0))
; 1: get louder by parameter every frame
; 2: get quieter by parameter every frame
; 3: disable channel, mute
; 4: get quieter by parameter every second frame
; 5: get quieter by parameter every fourth frame
; 6: get louder by parameter every second frame
; 7: get louder by parameter every fourth frame
.enum 0
  Attenuation_Flat      db
  Attenuation_Louder1   db
  Attenuation_Quieter1  db
  Attenuation_EndNote   db
  Attenuation_Quieter2  db
  Attenuation_Quieter4  db
  Attenuation_Louder2   db
  Attenuation_Louder4   db  
.ende

; Numbers are "volume" (inverse of attenuation)
; Numbets shown are for when the attenuation counters are working properly - 
; which they don't! This means that the 2 and 4 variants act like the 1
; versions, so volume ramps go much faster than intended. This is indicated
; by the "->" numbers where present.

_Instrument0_Attenuation:
.db PSG_ATTENUATION_SILENCE
.db 0, Attenuation_EndNote, 0 ; Mute and disable channel
.db 0, Instrument_End ; End

_Instrument6_Attenuation:
.db $06                         ; 9
.db  2, Attenuation_Louder1,  1 ; AB
.db  6, Attenuation_Flat,     0 ; BBBBBB
.db 15, Attenuation_Quieter4, 1 ; BBBAAAA99998888         -> BA9876543210000
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

_Instrument3_Attenuation:
.db $00                         ; F
.db  6, Attenuation_Flat,     0 ; FFFFFF
.db 15, Attenuation_Quieter2, 1 ; FEEDDCCBBAA9988         -> EDCBA9876543210
.db 15, Attenuation_Quieter2, 1 ; 776655443322110         -> 000000000000000
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

_Instrument2_Attenuation:
.db $00                         ; F
.db  4, Attenuation_Flat, 0     ; FFFF
.db 15, Attenuation_Quieter4, 1 ; FFFEEEEDDDDCCCC         -> EDCBA9876543210
.db 15, Attenuation_Quieter4, 1 ; BBBBAAAA9999888         -> 000000000000000
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

; Unused instruments
.db $0F                         ; 0
.db 12, Attenuation_Louder1,  2 ; 2468ACEFFFFF
.db 15, Attenuation_Quieter4, 1 ; FFFEEEEDDDDCCCC         -> EDCBA9876543210
.db 15, Attenuation_Quieter4, 1 ; BBBBAAAA9999888         -> 000000000000000
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

.db $00                         ; F
.db  8, Attenuation_Flat,     0 ; FFFFFFFF
.db 15, Attenuation_Quieter2, 2 ; FDDBB9977553311         -> EDCBA9876543210
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

_Instrument5_Attenuation:
.db $00                         ; F
.db 10, Attenuation_Quieter2, 1 ; FEEDDCCBBA              -> EDCBA98765
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

; Junk data?
.db  0, Instrument_Loop

; Unused (empty) instrument
.db $00
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

_Instrument4_Attenuation:
.db $06                         ; 9
.db  6, Attenuation_Louder1, 1  ; ABCDEF
.db Instrument_Loop             ; FFFFFF forever?

; Unused (empty) instrument
.db $00
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

_Instrument12_Attenuation:  
.db $04                         ; B
.db  2, Attenuation_Louder1,  1 ; CD
.db 24, Attenuation_Flat,     0 ; DDDDDDDDDDDDDDDDDDDDDDDD
.db  7, Attenuation_Quieter4, 1 ; DDDCCCC                 -> CBA9876
.db 16, Attenuation_Flat,     0 ; CCCCCCCCCCCCCCCC        -> 6666666666666666
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

_Instrument1_Attenuation:   
.db $01                         ; E
.db 15, Attenuation_Quieter4, 1 ; EEEDDDDCCCCBBBB         -> DCBA98765432100
.db 15, Attenuation_Quieter4, 1 ; AAAA99998888777         -> 000000000000000
.db  0, Attenuation_EndNote,  0 ; Mute and disable channel
.db  0, Instrument_End          ; End

; Data from 3137A to 3141B (162 bytes)
_PSGNotes:
 .dw 0
  PSGNotes 0, 74

_NoteOffsets: ; Indexed by music index (minus 1)
; This is a note-index adjustment, not sure why? 
; Seems to just transpose the tracks relative to each other:
; tone0 is offset by this value
; tone1 is offset one octave above tone0
; tone2 keeps its original values
.db -10, -5, -2, -6, -6, -4, -4, -5, -3, -3, -4, -2

; Data from 3141C to 3150E (243 bytes)
; 6 bytes (3 pointers) per entry
; Most are unused as they correspond to non-noise instruments
_PercussionDataPointers:
;   Notes    Noise    Attenuation
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes9  _Noise8  _Attenuation8 ; 6 
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8 ; 8
.dw _Notes9  _Noise9  _Attenuation9 ; 9
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes11 _Noise11 _Attenuation11 ; 11
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8
.dw _Notes8  _Noise8  _Attenuation8

; No noise, just tone (8 triggers silencing the noise channel, as a side effect it also sets it to PSG_NOISE_PERIODIC_SLOWEST mode)
; Slide down one note per frame
; Full volume
_Notes8:        .db Fs3,  F3,  E3, Ds3,  D3, Cs3, Instrument_End
_Noise8:        .db   8,   8,   8,   8,   8,   8
_Attenuation8:  .db   0,   0,   0,   0,   0, PSG_ATTENUATION_SILENCE

; Slide down 2 notes per frame, higher than #8
; Noise fast -> slow then tone2 for even slower
; Full volume
_Notes11:       .db            Fs4,               E4,             D4,              C4,             As3,                     Gs3, Instrument_End
_Noise11:       .db PSG_NOISE_FAST, PSG_NOISE_MEDIUM, PSG_NOISE_SLOW, PSG_NOISE_TONE2, PSG_NOISE_TONE2,         PSG_NOISE_TONE2
_Attenuation11: .db              0,                0,              0,               0,               0, PSG_ATTENUATION_SILENCE

; No tone
; Noise data seems fairly nonsensical (no tone to follow)
; Volume drops off
; Unused in game
_Notes9:        .db              _,                        _,               _,                       _, Instrument_End
_Noise9:        .db PSG_NOISE_SLOW, PSG_NOISE_PERIODIC_TONE2, PSG_NOISE_TONE2,         PSG_NOISE_TONE2
_Attenuation9:  .db              0,                        2,               4, PSG_ATTENUATION_SILENCE

; Copied to _RAM_D91A_MenuSoundData
; Sound engine "off" state
.dstruct _MusicStopData instanceof OutputSoundData data 0, 0, 0 /* Tone0, 1, 2 */, PSG_NOISE_TONE2 /* NoiseModeControl */, PSG_ATTENUATION_SILENCE /* NoiseAttenuation */, PSG_ATTENUATION_SILENCE, PSG_ATTENUATION_SILENCE, PSG_ATTENUATION_SILENCE /* Attenuation0, 1, 2 */

; Data pointed into by following table
; Also looked up directly?
; One entry per music track, pointed to by _RAM_D929_MenuSound_SequencePointer
; Values are indexes into _Patterns
; Each references a "pattern" of music data
_SequencesBase:
_Sequence_TitleScreen: .db $00 $05 $02 $03 $02 $04 $06 $07 $02 $03 $02 $04 $09 $08 $0B $0B $0A $0A $0C $0D $0C $0E $00 $00
_Sequence_CharacterSelect: .db $0F $10 $11 $11 $12 $13 $11 $11 $14 $15 $16 $18 $17
_Sequence_Ending: .db $19 $1A $1B $1B $1C $1D
_Sequence_Silence: .db $1F
_Sequence_RaceStart: .db $20
_Sequence_Results: .db $21
_Sequence_Menus: .db $10 $22 $22 $23 $24
_Sequence_GameOver: .db $25
_Sequence_PlayerOut: .db $26
_Sequence_LostLife: .db $27
_Sequence_TwoPlayerResult: .db $28
_Sequence_TwoPlayerTournamentWinner: .db $29 $2A
; Points into the above
_Sequences:
.dw _Sequence_TitleScreen _Sequence_CharacterSelect _Sequence_Ending _Sequence_Silence _Sequence_RaceStart _Sequence_Results _Sequence_Menus _Sequence_GameOver _Sequence_PlayerOut _Sequence_LostLife _Sequence_TwoPlayerResult _Sequence_TwoPlayerTournamentWinner

; Data from 3150F to 33FFF (10993 bytes)
_Patterns:
; relative offsets from _PatternBase
; Presumably this extra indirection is due to the data being relocatable due to not being generated here...
.dw _Pattern00 - _PatternBase ; $0000
.dw _Pattern01 - _PatternBase ; $00c8
.dw _Pattern02 - _PatternBase ; $01ac
.dw _Pattern03 - _PatternBase ; $0294
.dw _Pattern04 - _PatternBase ; $0382
.dw _Pattern05 - _PatternBase ; $046C
.dw _Pattern06 - _PatternBase ; $0568
.dw _Pattern07 - _PatternBase ; $0652
.dw _Pattern08 - _PatternBase ; $0748
.dw _Pattern09 - _PatternBase ; $083A
.dw _Pattern0a - _PatternBase ; $0928
.dw _Pattern0b - _PatternBase ; $0A0C
.dw _Pattern0c - _PatternBase ; $0AF0
.dw _Pattern0d - _PatternBase ; $0BDA
.dw _Pattern0e - _PatternBase ; $0CC4
.dw _Pattern0f - _PatternBase ; $0DC0
.dw _Pattern10 - _PatternBase ; $0E88
.dw _Pattern11 - _PatternBase ; $0F6C
.dw _Pattern12 - _PatternBase ; $1050
.dw _Pattern13 - _PatternBase ; $1134
.dw _Pattern14 - _PatternBase ; $1222
.dw _Pattern15 - _PatternBase ; $1306
.dw _Pattern16 - _PatternBase ; $13F6
.dw _Pattern17 - _PatternBase ; $14F0
.dw _Pattern18 - _PatternBase ; $15DE
.dw _Pattern19 - _PatternBase ; $16C2
.dw _Pattern1a - _PatternBase ; $178E
.dw _Pattern1b - _PatternBase ; $185E
.dw _Pattern1c - _PatternBase ; $1946
.dw _Pattern1d - _PatternBase ; $1A34
.dw _Pattern1e - _PatternBase ; $1B24
.dw _Pattern1f - _PatternBase ; $1C1E
.dw _Pattern20 - _PatternBase ; $1C2A
.dw _Pattern21 - _PatternBase ; $1D16
.dw _Pattern22 - _PatternBase ; $1E02
.dw _Pattern23 - _PatternBase ; $1EE8
.dw _Pattern24 - _PatternBase ; $1FD4
.dw _Pattern25 - _PatternBase ; $20C8
.dw _Pattern26 - _PatternBase ; $21B4
.dw _Pattern27 - _PatternBase ; $223B
.dw _Pattern28 - _PatternBase ; $22C2
.dw _Pattern29 - _PatternBase ; $23AE
.dw _Pattern2a - _PatternBase ; $2498

.enum $80
I db ; Set instrument
D db ; Set note duration
V db ; Set volume
_UnusedCommand3_EndPattern db
J db ; Jump to pattern
BU db ; Pitch bend up
BD db ; Pitch bend down
_UnusedCommand7_Nop db
.ende

; Instrument
; ==========
; Set a value from 0-15, values come from the _Instruments table above.
; Many are repeats of 6 and 7.
; Most are rarely used in this game, they sound more like the weird music in Cosmic Spacehead,
; with extreme pitch modulation effects (argeggiation).
; Some seem not to do anything?
; Music track                         Channel 0   Channel 1   Channel 2
; Music_01_TitleScreen                5           1, 12       6, 8, 11
; Music_02_CharacterSelect            5           12, 7, 4    8, 11
; Music_03_Ending                     5           4, 13       8, 11
; Music_04_Silence                    
; Music_05_RaceStart                  5           2           8, 11
; Music_06_Results                    5           2           8, 11
; Music_07_Menus                      5           2, 4        8, 11
; Music_08_GameOver                   5           2           8, 11
; Music_09_PlayerOut                  5           7           8, 11
; Music_0A_LostLife                   5           7           8, 11
; Music_0B_TwoPlayerResult            5           2           8, 11
; Music_0C_TwoPlayerTournamentWinner  5           12          8, 11

; Note that pitch bends are a bit weird:
; Values are raw tone value adjustments, so hard to relate to actual note change
; - They apply cumulatively when they are in consecutive rows, so bending down 10 twice gets you -20
; - But everything is reset when a row doesn't bend, including the running total

; Note names for numbers
.enum 0
  _   db ; $00 ; No note, i.e. stop sound
  A2  db ; $01 ; Octave 2
  As2 db ; $02 
  B2  db ; $03 
  C3  db ; $04 ; Octave 3
  Cs3 db ; $05 
  D3  db ; $06
  Ds3 db ; $07
  E3  db ; $08
  F3  db ; $09
  Fs3 db ; $0a
  G3  db ; $0b
  Gs3 db ; $0c
  A3  db ; $0d
  As3 db ; $0e
  B3  db ; $0f
  C4  db ; $10 Octave 4
  Cs4 db ; $11
  D4  db ; $12
  Ds4 db ; $13
  E4  db ; $14
  F4  db ; $15
  Fs4 db ; $16
  G4  db ; $17
  Gs4 db
  A4  db
  As4 db
  B4  db
  C5  db ; Octave 5
  Cs5 db
  D5  db
  Ds5 db
  E5  db ; $20
  F5  db
  Fs5 db
  ; Higher notes aren't used...
.ende

; Base address for pattern data
_PatternBase:

; Title screen
_Pattern00:
;       Channel 1   Channel 2   Channel 3
.db I 5 D 4    D4   I 1    D4           _
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4           _
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            D4          D4           _
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4           _
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            C4          D4           _
.db             _         Fs4           _
.db            C4          A4           _
.db             _          D5           _
.db            C4          D4           _
.db             _          G4           _
.db            B3          B4           _
.db             _          D5           _
.db            B3          D4           _
.db             _         Fs4           _
.db            B3          A4           _
.db             _          D5   I 6    B3
.db            C4          D4           _
.db             _          G4          B3
.db            C4          B4           _
.db             _          D5          B3
.db            D4          D4           _
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4           _
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            D4          D4           _
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4           _
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            C4          D4           _
.db             _         Fs4           _
.db            C4          A4           _
.db             _          D5           _
.db            C4          D4           _
.db             _          G4           _
.db            B3          B4           _
.db             _          D5           _
.db            B3          D4           _
.db             _         Fs4           _
.db            B3          A4           _
.db             _          D5           _
.db            C4          D4           _
.db             _          G4           _
.db            C4          B4           _
.db             _          D5           _

_Pattern01:
.db I 5        D4   I 1    D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            D4          D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4          E4
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            C4          D4   I 8    E4
.db             _         Fs4           _
.db            C4          A4           _
.db             _          D5           _
.db            C4          D4   I 11   A4
.db             _          G4           _
.db            B3          B4   I 8    E4
.db             _          D5           _
.db            B3          D4           _
.db             _         Fs4           _
.db            B3          A4          E4
.db             _          D5           _
.db            C4          D4   I 11   A4
.db             _          G4           _
.db            C4          B4          A4
.db             _          D5          A4
.db            D4          D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            D4          D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4          E4
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            C4          D4   I 8    E4
.db             _         Fs4           _
.db            C4          A4           _
.db             _          D5           _
.db            C4          D4   I 11   A4
.db             _          G4           _
.db            B3          B4   I 8    E4
.db             _          D5           _
.db            B3          D4           _
.db             _         Fs4           _
.db            B3          A4          E4
.db             _          D5           _
.db            C4          D4   I 11   A4
.db             _          G4          A4
.db            C4          B4          A4
.db             _          D5          A4

_Pattern02:
.db     I 5    D4   I 12  Fs4   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4         Fs4   I 11   A4
.db             _           _           _
.db            D4         Fs4           _
.db             _           _           _
.db            D4         Fs4   I 8    E4
.db             _           _           _
.db            D4          E4          E4
.db             _           _           _
.db            D4         Fs4   I 11   A4
.db             _           _           _
.db            D4          G4           _
.db             _           _           _
.db            C4           _   I 8    E4
.db             _           _           _
.db            C4           _           _
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _           _
.db            C4           _          A4
.db             _           _          A4
.db            D4          C5   I 8    E4
.db             _           _           _
.db            D4          B4           _
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4          G4           _
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _          E4
.db             _           _           _
.db            D4          E4   I 11   A4
.db             _           _           _
.db            D4          G4           _
.db             _           _           _
.db            C4   BU 3    _   I 8    E4
.db             _   BU 3    _           _
.db            C4          A4           _
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _          A4
.db            C4           _          A4
.db             _           _          A4

 _Pattern03:
.db     I 5    D4   I 12  Fs4   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4         Fs4   I 11   A4
.db             _           _           _
.db            D4         Fs4           _
.db             _           _           _
.db            D4         Fs4   I 8    E4
.db             _           _           _
.db            D4          E4          E4
.db             _           _           _
.db            D4         Fs4   I 11   A4
.db             _           _           _
.db            D4          G4           _
.db             _           _           _
.db            C4           _   I 8    E4
.db             _           _           _
.db            C4           _           _
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _          A4
.db            C4           _           _
.db             _           _          A4
.db            D4          C5   I 8    E4
.db             _           _           _
.db            D4          B4           _
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4          G4           _
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _          E4
.db             _           _           _
.db            D4          E4   I 11   A4
.db             _           _           _
.db            D4          C5           _
.db             _           _           _
.db            C4   BU 3    _          A4
.db             _   BU 3    _           _
.db            C4          D5   I 8    E4
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _          A4
.db            B3           _   I 8    E4
.db             _           _          E4
.db            C4           _   I 11   A4
.db             _           _          A4
.db            C4           _   I 8    E4
.db             _           _          E4

_Pattern04:
.db     I 5    D4   I 12  Fs4   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4         Fs4   I 11   A4
.db             _           _           _
.db            D4         Fs4           _
.db             _           _           _
.db            D4         Fs4   I 8    E4
.db             _           _           _
.db            D4          E4          E4
.db             _           _           _
.db            D4         Fs4   I 11   A4
.db             _           _           _
.db            D4          G4           _
.db             _           _           _
.db            C4           _   I 8    E4
.db             _           _           _
.db            C4           _           _
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            C4           _   I 11   A4
.db             _           _          A4
.db            C4           _           _
.db             _           _          A4
.db            D4          C5   I 8    E4
.db             _           _           _
.db            D4          B4           _
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4          G4           _
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4          E4          E4
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            C4          D5          A4
.db             _          C5           _
.db            C4          A4   I 8    E4
.db             _          G4           _
.db            C4          A4   I 11   A4
.db             _          G4           _
.db            B3          F4   I 8    E4
.db             _          D4           _
.db            B3          F4   I 11   A4
.db             _          D4          A4
.db            B3          C4   I 8    E4
.db             _          A3          E4
.db            C4          C4   I 11   A4
.db             _          A3          A4
.db            C4          G3   I 8    E4
.db             _          F3          E4

_Pattern05:
.db     I 5    D4   I 1    D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            D4          D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4          E4
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            C4          D4   I 8    E4
.db             _         Fs4           _
.db            C4          A4           _
.db             _          D5           _
.db            C4          D4   I 11   A4
.db             _          G4           _
.db            B3          B4   I 8    E4
.db             _          D5           _
.db            B3          D4           _
.db             _         Fs4           _
.db            B3          A4          E4
.db             _          D5           _
.db            C4          D4   I 11   A4
.db             _          G4          A4
.db            C4          B4           _
.db             _          D5          A4
.db            D4          D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4           _
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            D4          D4   I 8    E4
.db             _         Fs4           _
.db            D4          A4          E4
.db             _          D5           _
.db            D4          D4   I 11   A4
.db             _          G4           _
.db            D4          B4           _
.db             _          D5           _
.db            C4          D4          A4
.db             _         Fs4           _
.db            C4          A4   I 8    E4
.db             _          D5           _
.db            C4          D4   I 11   A4
.db             _          G4           _
.db            B3          B4   I 8    E4
.db             _          D5           _
.db            B3 I 12 BD 10  D5 I 11  A4
.db             _   BD 10   _          A4
.db            B3   BD 10   _   I 8    E4
.db             _   BD 10   _          E4
.db            C4   BD 8    _   I 11   A4
.db             _   BD 8    _          A4
.db            C4   BD 6    _   I 8    E4
.db             _   BD 6    _          E4

_Pattern06:
.db     I 5    C4   I 12   G4   I 8    E4
.db             _           _           _
.db            C4           _           _
.db             _           _           _
.db            C4          G4   I 11   A4
.db             _           _           _
.db            C4          E4           _
.db             _           _           _
.db            C4          G4   I 8    E4
.db             _           _           _
.db            C4          A4          E4
.db             _           _           _
.db            C4          B4   I 11   A4
.db             _           _           _
.db            C4          A4           _
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4           _          E4
.db             _           _           _
.db            D4          G4   I 11   A4
.db             _           _          A4
.db            D4          A4           _
.db             _           _          A4
.db            G4          C5   I 8    E4
.db             _           _           _
.db            G4          B4           _
.db             _           _           _
.db            G4           _   I 11   A4
.db             _           _           _
.db            G4          G4           _
.db             _           _           _
.db            G4           _   I 8    E4
.db             _           _           _
.db            G4          E4          E4
.db             _           _           _
.db            G4           _   I 11   A4
.db             _           _           _
.db            E4          B4           _
.db             _           _           _
.db            D4          A4          A4
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _          A4
.db            D4           _   I 8    E4
.db             _           _          E4
.db            D4           _   I 11   A4
.db             _           _          A4
.db            D4           _   I 8    E4
.db             _           _          E4

_Pattern07:
.db     I 5    C4   I 12   G4   I 8    E4
.db             _           _           _
.db            C4           _           _
.db             _           _           _
.db            C4          G4   I 11   A4
.db             _           _           _
.db            C4          E4           _
.db             _           _           _
.db            C4          G4   I 8    E4
.db             _           _           _
.db            C4          A4          E4
.db             _           _           _
.db            C4          B4   I 11   A4
.db             _           _           _
.db            C4          A4           _
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4           _          E4
.db             _           _           _
.db            D4          G4   I 11   A4
.db             _           _          A4
.db            D4          A4           _
.db             _           _          A4
.db            G4          C5   I 8    E4
.db             _           _           _
.db            G4          B4           _
.db             _           _           _
.db            G4           _   I 11   A4
.db             _           _           _
.db            G4          G4           _
.db             _           _           _
.db            G4           _   I 8    E4
.db             _           _           _
.db            G4          E4          E4
.db             _           _           _
.db            G4           _   I 11   A4
.db             _           _           _
.db            D4          D4           _
.db             _           _           _
.db            A3   I 7    A4          A4
.db             _          E4           _
.db            A3          D4   I 8    E4
.db             _          E4           _
.db            A3          A4   I 11   A4
.db             _          E4           _
.db            A3          D4   I 8    E4
.db             _          E4           _
.db            A3          A4   I 11   A4
.db             _           _          A4
.db            A3          A4   I 8    E4
.db             _           _          E4
.db            A3 I 12 BD 10  A4 I 11  A4
.db             _   BD 10   _          A4
.db            A3   BD 10   _   I 8    E4
.db             _   BD 10   _          E4

_Pattern08:
.db     I 5    G3   V 0     _   I 8    E4
.db             _           _           _
.db            G3           _           _
.db             _           _           _
.db            G3           _   I 11   A4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _           _
.db            G3           _          E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _          A4
.db             _           _           _
.db             _   I 12   D4   I 8    E4
.db             _           _           _
.db             _          C4   I 11   A4
.db             _           _           _
.db             _         As3   I 8    E4
.db             _           _           _
.db             _          C4   I 11   A4
.db             _           _          A4
.db             _         As3           _
.db             _           _          A4
.db             _           _          A4
.db             _           _           _
.db             _   BD 8    _          A4
.db             _   BD 8    _           _
.db           As3   V 0     _   I 8    E4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db            G3           _   I 11   A4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _           _
.db            C4           _          E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _          A4
.db             _           _           _
.db             _          G4   I 8    E4
.db             _           _           _
.db             _          F4   I 11   A4
.db             _           _           _
.db             _          G4   I 8    E4
.db             _           _           _
.db             _          F4   I 11   A4
.db             _           _          A4
.db             _          G4   I 8    E4
.db             _          F4          E4
.db             _          D4   I 11   A4
.db             _          C4          A4
.db             _         As3   I 8    E4
.db             _          G3          E4

_Pattern09:
.db     I 5    G3   V 0     _   I 8    E4
.db             _           _           _
.db            G3           _           _
.db             _           _           _
.db            G3           _   I 11   A4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _           _
.db            G3           _          E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _          A4
.db             _           _          A4
.db             _   I 12   D4           _
.db             _           _          A4
.db             _          C4   I 8    E4
.db             _           _           _
.db             _         As3          E4
.db             _           _           _
.db             _          C4   I 11   A4
.db             _           _          A4
.db             _         As3           _
.db             _           _          A4
.db             _           _   I 8    E4
.db             _           _           _
.db             _   BD 8    _          E4
.db             _   BD 8    _           _
.db           As3   V 0     _          E4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db            G3           _   I 11   A4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _           _
.db            C4           _          E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _          E4
.db             _          F4           _
.db             _           _          E4
.db             _          E4   I 11   A4
.db             _           _           _
.db             _          F4           _
.db             _           _           _
.db             _          G4   I 8    E4
.db             _           _          E4
.db             _           _           _
.db             _           _          E4
.db             _           _   I 11   A4
.db             _   BU 8    _           _
.db             _   BU 8    _          A4
.db             _   BU 8    _          A4

_Pattern0a:
.db     I 5    E4   I 12   B4   I 8    E4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            E5          B4   I 11   A4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            E4          B4   I 8    E4
.db             _          G4           _
.db            E4          E4          E4
.db             _          B3           _
.db            E5          B4   I 11   A4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            A3         Cs5   I 8    E4
.db             _          A4           _
.db            A3          E4           _
.db             _         Cs4           _
.db            A4         Cs5   I 11   A4
.db             _          A4           _
.db            A3          E4   I 8    E4
.db             _         Cs4           _
.db            A3         Cs5           _
.db             _          A4           _
.db            A3          E4          E4
.db             _         Cs4           _
.db            A4         Cs5   I 11   A4
.db             _          A4           _
.db            A3          E4          A4
.db             _         Cs4          A4
.db            D4          D5   I 8    E4
.db             _          A4           _
.db            D4         Fs4           _
.db             _          D4           _
.db            D4          D5   I 11   A4
.db             _          A4           _
.db            D4         Fs4           _
.db             _          D4           _
.db            D4          D5   I 8    E4
.db             _          A4           _
.db            D4         Fs4          E4
.db             _          D4           _
.db            D4          D5   I 11   A4
.db             _          A4           _
.db            D4         Fs4           _
.db             _          D4           _
.db            A3         Cs5   I 8    E4
.db             _          A4           _
.db            A3          E4           _
.db             _         Cs4           _
.db            A4         Cs5   I 11   A4
.db             _          A4           _
.db            A3          E4   I 8    E4
.db             _         Cs4           _
.db            A3         Cs5           _
.db             _          A4           _
.db            A3          E4          E4
.db             _         Cs4           _
.db            A4         Cs5   I 11   A4
.db             _          A4          A4
.db            A3          E4          A4
.db             _         Cs4          A4

_Pattern0b:
.db     I 5    E4   I 12   B4   I 8    E4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            E5          B4   I 11   A4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            A3         Cs5   I 8    E4
.db             _          A4           _
.db            A3          E4          E4
.db             _         Cs4           _
.db            A4         Cs5   I 11   A4
.db             _          A4           _
.db            A3          E4           _
.db             _         Cs4           _
.db            E4          B4   I 8    E4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            E5          B4   I 11   A4
.db             _          G4           _
.db            E4          E4   I 8    E4
.db             _          B3           _
.db            D4          A4           _
.db             _         Fs4           _
.db            D4          D4          E4
.db             _          A3           _
.db            D5          A4   I 11   A4
.db             _         Fs4           _
.db            D4          D4          A4
.db             _          A3          A4
.db            E4          B4   I 8    E4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            E5          B4   I 11   A4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            A3         Cs5   I 8    E4
.db             _          A4           _
.db            A3          E4          E4
.db             _         Cs4           _
.db            A4         Cs5   I 11   A4
.db             _          A4           _
.db            A3          E4           _
.db             _         Cs4           _
.db            E4          B4   I 8    E4
.db             _          G4           _
.db            E4          E4           _
.db             _          B3           _
.db            E5          B4   I 11   A4
.db             _          G4           _
.db            E4          E4   I 8    E4
.db             _          B3           _
.db            D4          A4           _
.db             _         Fs4           _
.db            D4          D4          E4
.db             _          A3           _
.db            D5          A4   I 11   A4
.db             _         Fs4          A4
.db            D4          D4          A4
.db             _          A3          A4

_Pattern0c:
.db     I 5    E4   I 12   B4   I 8    E4
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E5           _   I 11   A4
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E4           _   I 8    E4
.db             _           _           _
.db            E4           _          E4
.db             _           _           _
.db            E5         Cs5   I 11   A4
.db             _           _           _
.db            E4          B4           _
.db             _           _           _
.db            A3         Cs5   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A4           _   I 11   A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A4          D5   I 11   A4
.db             _           _          A4
.db            A3         Cs5           _
.db             _           _          A4
.db            D4          D5   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4          E5           _
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _          E4
.db             _           _           _
.db            D4          D5   I 11   A4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            A3         Cs5          A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A4           _   I 11   A4
.db             _           _           _
.db            A3          B4   I 8    E4
.db             _           _           _
.db            A3           _   I 11   A4
.db             _           _          A4
.db            A3           _   I 8    E4
.db             _           _          E4
.db            A4          A4   I 11   A4
.db             _           _          A4
.db            A3           _   I 8    E4
.db             _           _          E4

_Pattern0d:
.db     I 5    E4   I 12   B4   I 8    E4
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E5           _   I 11   A4
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E4           _   I 8    E4
.db             _           _           _
.db            E4           _          E4
.db             _           _           _
.db            E5         Cs5   I 11   A4
.db             _           _           _
.db            E4          B4           _
.db             _           _           _
.db            A3         Cs5   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A4           _   I 11   A4
.db             _           _           _
.db            A3          B4   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A4          A4   I 11   A4
.db             _           _          A4
.db            A3           _           _
.db             _           _          A4
.db            D4          D5   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4           _   I 8    E4
.db             _           _           _
.db            D4           _          E4
.db             _           _           _
.db            D4          E5   I 11   A4
.db             _           _           _
.db            D4          D5           _
.db             _           _           _
.db            A3          A4          A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A4           _   I 11   A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3           _   I 11   A4
.db             _           _          A4
.db            A3           _   I 8    E4
.db             _           _          E4
.db            A4           _   I 11   A4
.db             _           _          A4
.db            A3           _   I 8    E4
.db             _           _          E4

_Pattern0e:
.db     I 5    E4   I 12   B4   I 8    E4
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E5          A4   I 11   A4
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E4          B4   I 8    E4
.db             _           _           _
.db            E4           _          E4
.db             _           _           _
.db            E5         Cs5   I 11   A4
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            A3          D5   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A4         Cs5   I 11   A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3          A4           _
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A4         Cs5   I 11   A4
.db             _           _          A4
.db            A3           _           _
.db             _           _          A4
.db            D4          D5   I 8    E4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4          E5   I 11   A4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            D4          D5   I 8    E4
.db             _           _           _
.db            D4           _          E4
.db             _           _           _
.db            D4         Cs5   I 11   A4
.db             _           _           _
.db            D4           _           _
.db             _           _           _
.db            A3          B4          A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A4          A4   I 11   A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3   BD 10   _   I 11   A4
.db             _   BD 10   _          A4
.db            A3   BD 10   _   I 8    E4
.db             _   BD 10   _          E4
.db            A4   BD 8    _   I 11   A4
.db             _   BD 8    _          A4
.db            A3   BD 6    _   I 8    E4
.db J _Sequence_TitleScreen - _SequencesBase
.db             _   BD 6    _          E4

; Character select
_Pattern0f:
.db I 5 D 6   Fs3   V 0     _           _
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _           _
.db            E3           _           _
.db           Fs3           _           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            E3           _           _
.db            D3           _           _
.db            E3           _           _
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _           _
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A3           _           _
.db           Fs3           _           _
.db            A3           _           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db           Cs4           _           _
.db             _           _           _
.db           Cs4           _           _
.db             _           _           _
.db           Cs4           _   I 11   A4
.db            E4           _          A4
.db           Fs4           _          A4
.db             _           _          A4

_Pattern10:
.db   I 5 D 6 Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db            E3           _   I 11   A4
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _           _
.db           Fs3           _   I 11   A4
.db            E3           _           _
.db           Fs3           _          A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _          E4
.db             _           _          E4
.db            A3           _   I 11   A4
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            E3           _   I 11   A4
.db            D3           _           _
.db            E3           _          A4
.db             _           _          A4
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db            E3           _   I 11   A4
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A3           _   I 11   A4
.db           Fs3           _           _
.db            A3           _          A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _          E4
.db             _           _          E4
.db            A3           _   I 11   A4
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _          E4
.db           Cs4           _   I 11   A4
.db            E4           _          A4
.db           Fs4           _          A4
.db             _           _          A4

_Pattern11:
.db     I 5   Fs3   I 12  Cs4   I 8    E4
.db             _          B3           _
.db           Fs3         Cs4          E4
.db             _           _          E4
.db            E3           _   I 11   A4
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _           _
.db           Fs3          E4   I 11   A4
.db            E3           _           _
.db           Fs3           _          A4
.db             _           _           _
.db            B3         Ds4   I 8    E4
.db             _           _           _
.db            B3           _          E4
.db             _           _          E4
.db            A3           _   I 11   A4
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            E3          E4   I 11   A4
.db            D3         Ds4           _
.db            E3         Cs4          A4
.db             _          B3          A4
.db           Fs3         Cs4   I 8    E4
.db             _          B3           _
.db           Fs3         Cs4          E4
.db             _           _          E4
.db            E3           _   I 11   A4
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A3         Gs4   I 11   A4
.db           Fs3           _           _
.db            A3           _          A4
.db             _           _           _
.db            B3         Fs4   I 8    E4
.db             _           _           _
.db            B3           _          E4
.db             _           _          E4
.db            A3           _   I 11   A4
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _          E4
.db           Cs4         Gs3   I 11   A4
.db            E4          B3          A4
.db           Fs4         Cs4          A4
.db             _          E4          A4

_Pattern12:
.db     I 5    D4   I 7    A3   I 8    E4
.db             _           _           _
.db            D4          A3          E4
.db             _          A3          E4
.db           Cs4          A3   I 11   A4
.db            D4         Gs3           _
.db             _           _           _
.db           Cs4          A3           _
.db            D4           _   I 8    E4
.db             _         Fs3           _
.db            D4           _          E4
.db             _         Fs3           _
.db           Cs4          A3   I 11   A4
.db            D4           _           _
.db             _         Cs4          A4
.db           Cs4           _           _
.db            E4          B3   I 8    E4
.db             _           _           _
.db            E4          B3          E4
.db             _          B3          E4
.db            D4         Cs4   I 11   A4
.db            E4          B3           _
.db             _           _           _
.db            D4         Fs4           _
.db            E4           _   I 8    E4
.db             _          E4           _
.db            E4           _          E4
.db             _          D4           _
.db            D4           _   I 11   A4
.db            E4         Cs4           _
.db             _          B3          A4
.db            D4          A3          A4
.db            D4          A3   I 8    E4
.db             _           _           _
.db            D4          A3          E4
.db             _         Gs3          E4
.db           Cs4          A3   I 11   A4
.db            D4          B3           _
.db             _         Cs4           _
.db           Cs4         Fs4           _
.db            D4           _   I 8    E4
.db             _          E4           _
.db            D4          D4          E4
.db             _          A3           _
.db           Cs4           _   I 11   A4
.db            D4           _           _
.db             _           _          A4
.db           Cs4           _           _
.db            B3         Gs4   I 8    E4
.db             _          E4           _
.db            B3         Gs4          E4
.db             _          E4          E4
.db            A3         Gs4   I 11   A4
.db            B3          E4           _
.db             _         Gs4           _
.db            A3          E4           _
.db            E3          D4   I 8    E4
.db             _          E4           _
.db            E3         Fs4          E4
.db             _          B3          E4
.db            D3           _   I 11   A4
.db            E3           _          A4
.db             _           _          A4
.db            E3           _          A4

_Pattern13:
.db   I 5      D4   I 7    A3   I 8    E4
.db             _           _           _
.db            D4          A3          E4
.db             _         Gs3          E4
.db           Cs4          A3   I 11   A4
.db            D4         Gs3           _
.db             _           _           _
.db           Cs4          A3           _
.db            D4           _   I 8    E4
.db             _         Fs3           _
.db            D4           _          E4
.db             _          A3           _
.db           Cs4           _   I 11   A4
.db            D4          B3           _
.db             _         Cs4          A4
.db           Cs4           _           _
.db            E4          B3   I 8    E4
.db             _           _           _
.db            E4          B3          E4
.db             _          A3          E4
.db            D4          B3   I 11   A4
.db            E4          A3           _
.db             _           _           _
.db            D4         Cs4           _
.db            E4           _   I 8    E4
.db             _          B3           _
.db            E4           _          E4
.db             _          A3           _
.db            D4           _   I 11   A4
.db            E4         Gs3          A4
.db             _         Fs3          A4
.db            D4           _          A4
.db            D4          A3   I 8    E4
.db             _           _           _
.db            D4          A3          E4
.db             _          B3          E4
.db           Cs4         Cs4   I 11   A4
.db            D4          B3           _
.db             _           _           _
.db           Cs4         Fs4           _
.db            D4           _   I 8    E4
.db             _          E4           _
.db            D4          D4          E4
.db             _          A3           _
.db           Cs4           _   I 11   A4
.db            D4           _           _
.db             _           _          A4
.db           Cs4           _           _
.db            B3          B3          A4
.db             _         Cs4   I 8    E4
.db            B3          D4   I 11   A4
.db             _          E4           _
.db            A3         Fs4          A4
.db            B3          E4   I 8    E4
.db             _         Fs4   I 11   A4
.db            A3          A4           _
.db            E3         Gs4          A4
.db             _         Fs4   I 8    E4
.db            E3          E4          E4
.db             _          B3   I 11   A4
.db            D3           _   I 8    E4
.db            E3           _          E4
.db             _           _   I 11   A4
.db            E3           _   I 8    E4
_Pattern14:
.db       I 5 Fs3   I 12  Fs3   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _           _
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _          A4
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _           _
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _          A4
.db             _           _          A4
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _           _
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _          A4
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _          A4
.db           Fs3           _          A4
.db             _           _          A4
_Pattern15:
.db       I 5 Fs3   I 12   E4   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3         Ds4          E4
.db             _           _           _
.db           Fs3          B3   I 11   A4
.db             _           _           _
.db           Fs3         Cs4          A4
.db             _          B3           _
.db           Fs3         Cs4   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _           _
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _          A4
.db             _           _          A4
.db           Fs3          E4   I 8    E4
.db             _           _           _
.db           Fs3         Ds4          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3          B3           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3         Cs4          E4
.db             _           _           _
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3         Fs4          A4
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3         Cs4          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3     BD 8  _          E4
.db             _     BD 8  _          E4
.db           Fs3     BD 8  _   I 11   A4
.db             _     BD 8  _          A4
.db           Fs3     BD 8  _          A4
.db             _     BD 8  _          A4
_Pattern16:
.db       I 5 Fs3   I 12   E4   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3         Ds4          E4
.db             _           _           _
.db           Fs3          B3   I 11   A4
.db             _           _           _
.db           Fs3         Cs4          A4
.db             _          B3           _
.db           Fs3         Cs4   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _          E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db           Fs3           _          E4
.db             _           _           _
.db           Fs3           _   I 11   A4
.db             _           _          A4
.db           Fs3           _          A4
.db             _           _          A4
.db            E4         Fs4   I 8    E4
.db             _           _           _
.db            E4         Fs4          E4
.db             _           _          E4
.db            E4         Cs4   I 11   A4
.db             _           _           _
.db           Ds4          E4           _
.db             _           _           _
.db           Ds4           _   I 8    E4
.db             _           _           _
.db           Ds4         Ds4          E4
.db             _           _           _
.db            E4          E4   I 11   A4
.db             _           _           _
.db            E4         As4          A4
.db             _           _           _
.db           Fs3           _          A4
.db             _           _   I 8    E4
.db           Fs3         Fs4   I 11   A4
.db             _           _           _
.db           Fs3           _          A4
.db             _           _   I 8    E4
.db           Fs3           _   I 11   A4
.db             _           _           _
.db           Fs3           _          A4
.db             _           _   I 8    E4
.db           Fs3     BD 8  _          E4
.db             _     BD 8  _   I 11   A4
.db           Fs3     BD 8  _   I 8    E4
.db             _     BD 8  _          E4
.db           Fs3     BD 8  _   I 11   A4
.db             _     BD 8  _   I 8    E4
_Pattern17:
.db       I 5 Cs4     I 4 Fs5   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _          E4
.db           Cs4         Fs5   I 11   A4
.db             _           _           _
.db           Cs4          E5           _
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _           _
.db           Cs4          E5   I 11   A4
.db             _           _           _
.db           Cs4         Cs5          A4
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _          E4
.db           Cs4           _   I 11   A4
.db             _           _           _
.db           Cs4           _           _
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _           _
.db           Cs4           _   I 11   A4
.db             _           _          A4
.db           Cs4           _          A4
.db             _           _          A4
.db           Cs4         Fs5   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _          E4
.db           Cs4         Fs5   I 11   A4
.db             _           _           _
.db           Cs4          E5           _
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _           _
.db           Cs4          E5   I 11   A4
.db             _           _           _
.db           Cs4          B4          A4
.db             _           _           _
.db           Cs4           _          A4
.db             _           _          A4
.db            D4           _   I 8    E4
.db             _           _   I 11   A4
.db           Ds4           _          A4
.db             _           _   I 8    E4
.db            E4           _   I 11   A4
.db             _           _          A4
.db            F4           _   I 8    E4
.db             _           _   I 11   A4
.db           Fs4           _          A4
.db             _           _   I 8    E4
.db            G4           _   I 11   A4
.db             _           _           _
.db           Gs4           _          A4
.db J _Sequence_CharacterSelect - _SequencesBase
.db             _           _           _

; Ending
_Pattern18:
.db     I 5   Cs4   I 4   Fs5   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _          E4
.db           Cs4         Fs5   I 11   A4
.db             _           _           _
.db           Cs4          E5           _
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _           _
.db           Cs4          E5   I 11   A4
.db             _           _           _
.db           Cs4         Cs5          A4
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _          E4
.db           Cs4           _   I 11   A4
.db             _           _           _
.db           Cs4           _           _
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _           _
.db           Cs4           _   I 11   A4
.db             _           _           _
.db           Cs4           _          A4
.db             _           _          A4
.db           Cs4         Fs5   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _          E4
.db           Cs4         Fs5   I 11   A4
.db             _           _           _
.db           Cs4          E5           _
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4         Fs5          E4
.db             _           _           _
.db           Cs4          E5   I 11   A4
.db             _           _           _
.db           Cs4          B4          A4
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _          E4
.db           Cs4           _   I 11   A4
.db             _           _           _
.db           Cs4           _           _
.db             _           _           _
.db           Cs4           _   I 8    E4
.db             _           _           _
.db           Cs4           _          E4
.db             _           _          E4
.db           Cs4           _   I 11   A4
.db             _           _          A4
.db           Cs4           _          A4
.db             _           _          A4

; Ending
_Pattern19:
.db     V 0     _ I 4 D 5  E4   V 0     _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _          E4           _
.db             _           _           _
.db             _          E4           _
.db             _           _           _
.db             _         Fs4           _
.db             _           _           _
.db             _          E4           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _          A3           _
.db             _           _           _
.db             _          A3           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _          B3           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _          E4           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _          E4           _
.db             _           _           _
.db             _          E4           _
.db             _           _           _
.db             _         Fs4           _
.db             _           _           _
.db             _          E4           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _          A3           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _          A3           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _   I 13  Cs4           _
.db             _           _           _
.db             _   I 4    B3           _
.db             _           _           _
.db             _          A3           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
_Pattern1a:
.db     I 5    E3   I 4    E4           _
.db             _           _           _
.db            E3           _           _
.db             _           _           _
.db            E3          E4           _
.db             _           _           _
.db            E3          E4           _
.db             _           _           _
.db            E3         Fs4           _
.db             _           _           _
.db            E3          E4           _
.db             _           _           _
.db            E3           _           _
.db             _           _           _
.db            E3           _           _
.db             _           _           _
.db            A3          A3           _
.db             _           _           _
.db            A3          A3           _
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            B3          B3           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            E4          E4           _
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E4          E4           _
.db             _           _           _
.db            E4          E4           _
.db             _           _           _
.db            E4         Fs4           _
.db             _           _           _
.db            E4          E4           _
.db             _           _           _
.db            E4           _           _
.db             _           _           _
.db            E4          A3           _
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A3          A3           _
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            B3   I 13  Cs4           _
.db             _           _           _
.db            B3   I 4    B3   I 11   A4
.db             _           _   I 8    E4
.db            A3          A3          E4
.db             _           _          E4
.db            A3           _   I 11   A4
.db             _           _   I 8    E4
.db            A3           _          E4
.db             _           _          E4
_Pattern1b:
.db     I 5    E3   I 4    E4   I 8    E4
.db             _           _           _
.db            E3           _          E4
.db             _           _           _
.db            E3          E4   I 11   A4
.db             _           _           _
.db            E3          E4   I 8    E4
.db             _           _           _
.db            E3         Fs4          E4
.db             _           _           _
.db            E3          E4          E4
.db             _           _           _
.db            E3           _   I 11   A4
.db             _           _           _
.db            E3           _   I 8    E4
.db             _           _           _
.db            A3          A3          E4
.db             _           _           _
.db            A3          A3          E4
.db             _           _           _
.db            A3           _   I 11   A4
.db             _           _           _
.db            B3          B3   I 8    E4
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _           _
.db            B3           _          A4
.db             _           _          A4
.db            E4          E4   I 8    E4
.db             _           _           _
.db            E4           _          E4
.db             _           _           _
.db            E4          E4   I 11   A4
.db             _           _           _
.db            E4          E4   I 8    E4
.db             _           _           _
.db            E4         Fs4          E4
.db             _           _           _
.db            E4          E4          E4
.db             _           _           _
.db            E4           _   I 11   A4
.db             _           _           _
.db            E4          A3   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A3          A3          E4
.db             _           _           _
.db            A3           _   I 11   A4
.db             _           _           _
.db            B3   I 13  Cs4   I 8    E4
.db             _           _           _
.db            B3   I 4    B3          E4
.db             _           _           _
.db            A3          A3          E4
.db             _           _           _
.db            A3           _   I 11   A4
.db             _           _          A4
.db            A3           _          A4
.db             _           _          A4
_Pattern1c:
.db     I 5    A3   I 4    A4   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _          A4           _
.db            A3          B4   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db           Gs3           _   I 11   A4
.db             _           _           _
.db            A3   I 13  Cs5           _
.db             _           _           _
.db            A3           _          A4
.db             _           _           _
.db            A3         Cs5   I 8    E4
.db             _           _           _
.db            A3   I 4    B4   I 11   A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3          A4   I 11   A4
.db             _           _          A4
.db           Gs3         Gs4           _
.db             _           _          A4
.db            A3          A4          A4
.db             _           _           _
.db            B3          B4          A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3          B4           _
.db             _           _           _
.db            B3          E5   I 11   A4
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            E4          E5          E4
.db             _           _           _
.db            E4          E5   I 11   A4
.db             _           _           _
.db            B3          B4           _
.db             _           _           _
.db            B3           _          A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _          A4
.db            A3          A4   I 8    E4
.db             _           _          E4
.db           Gs3         Gs4   I 11   A4
.db             _           _          A4
.db           Gs3          A4   I 8    E4
.db             _           _          E4
_Pattern1d:
.db     I 5    A3   I 4    A4   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _          A4           _
.db            A3          B4   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db           Gs3           _   I 11   A4
.db             _           _           _
.db            A3   I 13  Cs5           _
.db             _           _           _
.db            A3           _          A4
.db             _           _           _
.db            A3         Cs5   I 8    E4
.db             _           _           _
.db            A3   I 4    B4   I 11   A4
.db             _           _           _
.db            A3           _   I 8    E4
.db             _           _           _
.db            A3          A4   I 11   A4
.db             _           _          A4
.db           Gs3         Gs4           _
.db             _           _          A4
.db            A3          A4          A4
.db             _           _           _
.db            B3          B4          A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3          B4           _
.db             _           _           _
.db            B3          E5   I 11   A4
.db             _           _           _
.db            B3           _           _
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            E4          E5          E4
.db             _           _           _
.db            E4          E5   I 11   A4
.db             _           _           _
.db            B3          B4           _
.db             _           _           _
.db            B3           _          A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _           _
.db            B3           _   I 8    E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _          A4
.db            A3          A4   I 8    E4
.db             _           _          E4
.db           Gs3         Gs4   I 11   A4
.db             _           _          A4
.db           Gs3          A4   I 8    E4
.db J _Sequence_Ending - _SequencesBase + 2 ; Loop after intro
.db             _           _          E4

; Unused?
_Pattern1e:
.db     I 5    G3   V 0     _   I 8    E4
.db             _           _           _
.db            G3           _           _
.db             _           _           _
.db            G3           _   I 11   A4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _           _
.db            G3           _          E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _          A4
.db             _           _           _
.db             _   I 12   D4   I 8    E4
.db             _           _           _
.db             _          C4   I 11   A4
.db             _           _           _
.db             _         As3   I 8    E4
.db             _           _           _
.db             _          C4   I 11   A4
.db             _           _          A4
.db             _   BU 4  As3           _
.db             _   BD 8    _          A4
.db             _   BU 8    _          A4
.db             _   BD 8    _           _
.db             _   BU 8    _          A4
.db             _   BD 8    _           _
.db           As3   V 0     _   I 8    E4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db            G3           _   I 11   A4
.db             _           _           _
.db           As3           _           _
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _           _
.db            C4           _          E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _          A4
.db             _           _           _
.db             _          G4   I 8    E4
.db             _           _           _
.db             _          F4   I 11   A4
.db             _           _           _
.db             _          G4   I 8    E4
.db             _           _           _
.db             _          F4   I 11   A4
.db             _           _          A4
.db             _          G4   I 8    E4
.db             _          F4          E4
.db             _          D4   I 11   A4
.db             _          C4          A4
.db             _         As3   I 8    E4
.db             _          G3          E4

; Silence
_Pattern1f:
.db     V 0     _   V 0     _           _
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _

; Race start
_Pattern20:
.db I 5 D 5   Fs3   I 2   Fs3   I 8    E4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db            A3          A3   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            B3          B3   I 8    E4
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _           _
.db           Fs3         Fs3           _
.db             _           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db            A3          A3           _
.db             _           _           _
.db            A3           _   I 11   A4
.db             _           _           _
.db            C4          C4   I 8    E4
.db             _           _           _
.db            B3          B3           _
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _          A4
.db            B3           _           _
.db             _           _          A4
.db           Fs3         Fs3   I 8    E4
.db             _           _           _
.db           Fs3           _           _
.db             _           _           _
.db            A3          A3   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            B3          B3   I 8    E4
.db             _           _           _
.db            B3           _          E4
.db             _           _           _
.db            A3           _   I 11   A4
.db             _           _           _
.db            C4          C4           _
.db             _           _           _
.db            C4           _          A4
.db             _           _           _
.db            B3          B3   I 8    E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _           _
.db            A3          A3   I 8    E4
.db             _           _           _
.db           Fs3         Fs3   I 11   A4
.db             _           _          A4
.db             _           _   I 8    E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _          A4
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _

; Results
_Pattern21:
.db   I 5 D 5  A3   I 2    A3   I 8    E4
.db             _           _           _
.db            A3          A3           _
.db             _           _           _
.db            A3          C4   I 11   A4
.db             _          A3           _
.db            A3           _           _
.db             _          G3           _
.db            C4          C4   I 8    E4
.db             _           _           _
.db            C4          C4          E4
.db             _           _           _
.db            C4          E4   I 11   A4
.db             _          C4           _
.db            C4           _           _
.db             _          B3           _
.db            D4          D4   I 8    E4
.db             _           _           _
.db            D4          D4           _
.db             _           _           _
.db            D4          F4   I 11   A4
.db             _          D4           _
.db            D4           _   I 8    E4
.db             _          C4           _
.db            F3          F3           _
.db             _           _           _
.db            F3          F3          E4
.db             _           _           _
.db            F3          A3   I 11   A4
.db             _          F3          A4
.db            F3           _           _
.db             _          E3          A4
.db            A3          A3   I 8    E4
.db             _           _           _
.db            A3          A3           _
.db             _           _           _
.db            A3          C4   I 11   A4
.db             _          A3           _
.db            A3           _           _
.db             _          G3           _
.db            C4          C4   I 8    E4
.db             _           _           _
.db            C4          C4          E4
.db             _           _           _
.db            C4          E4   I 11   A4
.db             _          C4           _
.db            C4           _           _
.db             _          B3           _
.db            D4          D4          A4
.db             _           _           _
.db            D4          D4   I 8    E4
.db             _           _           _
.db            D4          F4   I 11   A4
.db             _          D4           _
.db            D4           _   I 8    E4
.db             _          G4           _
.db            A4          A4   I 11   A4
.db             _           _          A4
.db            A4          A4   I 8    E4
.db            A4           _           _
.db            A4          A4   I 11   A4
.db             _           _           _
.db             _           _          A4
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _

; Menus (starts with  C4 as an intro)
_Pattern22:
.db   I 5 D 6 Fs3   I 2   Cs4   I 8    E4
.db             _           _           _
.db           Fs3         Cs4          E4
.db             _           _          E4
.db            E3          B3   I 11   A4
.db           Fs3           _           _
.db             _           _           _
.db            E3           _           _
.db           Fs3         Cs4   I 8    E4
.db             _           _           _
.db           Fs3         Cs4          E4
.db             _           _           _
.db           Fs3          E4   I 11   A4
.db            E3           _           _
.db           Fs3           _          A4
.db             _           _           _
.db            B3         Fs4   I 8    E4
.db             _           _           _
.db            B3         Fs4          E4
.db             _           _          E4
.db            A3          E4   I 11   A4
.db            B3           _           _
.db             _           _           _
.db            A3           _           _
.db            B3         Fs4   I 8    E4
.db             _           _           _
.db            A3         Fs4          E4
.db             _           _           _
.db            E3          A4   I 11   A4
.db            D3           _           _
.db            E3           _          A4
.db             _           _          A4
.db           Fs3         Cs4   I 8    E4
.db             _           _           _
.db           Fs3         Cs4          E4
.db             _         Ds4          E4
.db            E3          E4   I 11   A4
.db           Fs3         Ds4           _
.db             _          B3           _
.db            E3           _           _
.db           Fs3           _   I 8    E4
.db             _           _           _
.db            A3         Fs4          E4
.db             _          E4           _
.db            A3         Fs4   I 11   A4
.db           Fs3         Gs4           _
.db            A3          A4          A4
.db             _         Gs4           _
.db            B3         Fs4   I 8    E4
.db             _          E4           _
.db            B3         Fs4          E4
.db             _           _          E4
.db            A3           _   I 11   A4
.db            B3           _           _
.db             _         Cs5           _
.db            A3          B4           _
.db           Cs4         Cs5   I 8    E4
.db             _          E5           _
.db           Cs4         Cs5          E4
.db             _          B4          E4
.db           Cs4         Cs5   I 11   A4
.db            E4           _          A4
.db           Fs4           _          A4
.db             _           _          A4
_Pattern23:
.db   I 5 D 6  D3   I 2    D4   I 8    E4
.db             _           _           _
.db            D3           _           _
.db             _          D4           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3          D4           _
.db             _           _           _
.db            D3         Cs4   I 8    E4
.db             _           _           _
.db            D3           _          E4
.db             _          B3           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3          A3           _
.db             _           _           _
.db            E3   I 4    E4   I 8    E4
.db             _           _           _
.db            E3           _           _
.db             _           _           _
.db            E4           _   I 11   A4
.db             _           _           _
.db            E3           _   I 8    E4
.db             _           _           _
.db            E3           _           _
.db             _           _           _
.db            E3           _          E4
.db             _           _           _
.db            E4   I 2    A3   I 11   A4
.db             _          B3           _
.db            E3         Cs4          A4
.db             _          D4          A4
.db            D3         Fs4   I 8    E4
.db             _           _           _
.db            D3           _           _
.db             _         Fs4           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3         Fs4           _
.db             _           _           _
.db            D3          E4   I 8    E4
.db             _           _           _
.db            D3           _          E4
.db             _          D4           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3         Cs4           _
.db             _           _           _
.db            B2     I 4   B3  I 8    E4
.db             _           _           _
.db            B2           _           _
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _           _
.db            B2           _   I 8    E4
.db             _           _           _
.db            B2           _           _
.db             _           _           _
.db            B2           _          E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _          A4
.db            B2           _          A4
.db             _           _          A4
_Pattern24:
.db   I 5 D 6  D3   I 2    D4   I 8    E4
.db             _           _           _
.db            D3           _           _
.db             _          D4           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3          D4           _
.db             _           _           _
.db            D3         Cs4   I 8    E4
.db             _           _           _
.db            D3           _          E4
.db             _          B3           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3          A3           _
.db             _           _           _
.db            E3   I 4    E4   I 8    E4
.db             _           _           _
.db            E3           _           _
.db             _           _           _
.db            E4           _   I 11   A4
.db             _           _           _
.db            E3           _   I 8    E4
.db             _           _           _
.db            E3           _           _
.db             _           _           _
.db            E3           _          E4
.db             _           _           _
.db            E4   I 2    A3   I 11   A4
.db             _          B3          A4
.db            E3         Cs4           _
.db             _          D4          A4
.db            D3         Fs4   I 8    E4
.db             _           _           _
.db            D3           _           _
.db             _         Fs4           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3         Fs4           _
.db             _           _           _
.db            D3          E4   I 8    E4
.db             _           _           _
.db            D3           _          E4
.db             _          D4           _
.db            D4           _   I 11   A4
.db             _           _           _
.db            D3         Cs4           _
.db             _           _           _
.db            B2   I 4    B3          A4
.db             _           _           _
.db            B2           _   I 8    E4
.db             _           _           _
.db            B3           _   I 11   A4
.db             _           _           _
.db            B2           _   I 8    E4
.db             _           _           _
.db            B2           _   I 11   A4
.db             _           _          A4
.db            B2           _   I 8    E4
.db             _           _          E4
.db            B3           _   I 11   A4
.db             _           _          A4
.db            B2           _   I 8    E4
.db J, _Sequence_Menus - _SequencesBase + 1
.db             _           _          E4

; Game over
_Pattern25:
.db   I 5 D 7  A3   I 2    A4   I 8    E4
.db             _           _           _
.db            A3          E4           _
.db             _           _           _
.db            A4          A4   I 11   A4
.db             _           _           _
.db            A3          B4           _
.db             _           _           _
.db            C4          C5   I 8    E4
.db             _           _           _
.db            C4          B4          E4
.db             _           _           _
.db            C5          A4   I 11   A4
.db             _           _           _
.db            C4          G4           _
.db             _           _           _
.db            D4          G4   I 8    E4
.db             _          A4           _
.db            D4          D5           _
.db             _          G4           _
.db            D5          A4   I 11   A4
.db             _          D5           _
.db            D4          G4   I 8    E4
.db             _          A4           _
.db            D4          D5           _
.db             _          G4           _
.db            D4          A4          E4
.db             _          D5           _
.db            D5          G4   I 11   A4
.db             _          A4          A4
.db            D4          D5           _
.db             _           _          A4
.db            A3          A4   I 8    E4
.db             _           _           _
.db            A3          E4           _
.db             _           _           _
.db            A4          A4   I 11   A4
.db             _           _           _
.db            A3          B4           _
.db             _           _           _
.db            C4          C5   I 8    E4
.db             _           _           _
.db            C4          B4          E4
.db             _           _           _
.db            C5          A4   I 11   A4
.db             _           _           _
.db            C4          G4           _
.db             _           _           _
.db            D3          G4          A4
.db             _         Fs4           _
.db            D3          D4   I 8    E4
.db             _          G4           _
.db            D4         Fs4   I 11   A4
.db             _          D4           _
.db            D3          G4   I 8    E4
.db             _         Fs4           _
.db            D3          D4   I 11   A4
.db             _          G4          A4
.db            D3         Fs4   I 8    E4
.db             _          D4           _
.db            D4          G4   I 11   A4
.db             _         Fs4           _
.db            D3          D4          A4
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _
; Player out
_Pattern26:
.db   I 5 D 7  E4   I 7    B4   I 8    E4
.db            E4          G4           _
.db             _          E4           _
.db            D4         As4           _
.db            D4          G4   I 11   A4
.db             _          E4           _
.db            E4          A4           _
.db            E4          G4           _
.db             _          E4   I 8    E4
.db            G4          D4           _
.db            G4          E4          E4
.db             _           _           _
.db            A4          A4   I 11   A4
.db             _           _           _
.db            G4          G4           _
.db             _           _           _
.db            A4          A3   I 8    E4
.db            A4          A3           _
.db             _           _           _
.db            G4          D4           _
.db            G4          D4   I 11   A4
.db             _           _           _
.db            E4          E4   I 8    E4
.db             _           _           _
.db            D4           _           _
.db            E4           _           _
.db            E4          E5          E4
.db             _           _           _
.db            E4          E5   I 11   A4
.db             _           _          A4
.db             _           _           _
.db             _           _          A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _

; Lost life
_Pattern27:
.db   I 5 D 7  D4   I 7    A4   I 8    E4
.db             _           _           _
.db            D4         Fs4           _
.db             _           _           _
.db            D4          D4   I 11   A4
.db             _           _           _
.db            D4          E4           _
.db             _           _           _
.db            A3          A4   I 8    E4
.db             _           _           _
.db            A3         Fs4          E4
.db             _           _           _
.db            A3          D4   I 11   A4
.db             _           _           _
.db            A3          E4           _
.db             _           _           _
.db            G3          G4   I 8    E4
.db             _           _           _
.db            G3         Fs4           _
.db             _           _           _
.db            A3          E4   I 11   A4
.db             _           _           _
.db            A3          D4   I 8    E4
.db             _           _           _
.db            D4          D4           _
.db             _           _           _
.db             _           _          E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db             _           _           _
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _

; Two player result
_Pattern28:
.db   I 5 D 5  D3   I 2    D4   I 8    E4
.db             _         Fs4           _
.db            D3          A4           _
.db             _          B4           _
.db            D4          D4   I 11   A4
.db             _         Fs4           _
.db            D3          A4           _
.db             _          B4           _
.db            D3          D4   I 8    E4
.db             _         Fs4           _
.db            D3          A4          E4
.db             _          B4           _
.db            D4          D4   I 11   A4
.db             _         Fs4           _
.db            D3          A4           _
.db             _          B4           _
.db            G3          D4   I 8    E4
.db             _          G4           _
.db            G3          A4           _
.db             _          C5           _
.db            G4          D4   I 11   A4
.db             _          G4           _
.db            G3          A4   I 8    E4
.db             _          C5           _
.db            G3          D4           _
.db             _          G4           _
.db            G3          A4          E4
.db             _          C5           _
.db            G4          D4   I 11   A4
.db             _          G4          A4
.db            G3          A4           _
.db             _          C5          A4
.db            A3          C5   I 8    E4
.db             _          B4           _
.db            A3          A4           _
.db             _          G4           _
.db            A4          C5   I 11   A4
.db             _          B4           _
.db            A3          A4           _
.db             _          G4           _
.db            G3          C5   I 8    E4
.db             _          B4           _
.db            G3          A4          E4
.db             _          G4           _
.db            G4          C5   I 11   A4
.db             _          B4           _
.db            G3          A4           _
.db             _          G4           _
.db            D4          A4          A4
.db             _           _           _
.db             _           _   I 8    E4
.db             _           _           _
.db            D4          D5   I 11   A4
.db             _           _           _
.db            D4          D5   I 8    E4
.db            D4          D5           _
.db            D4          D5   I 11   A4
.db             _           _          A4
.db             _           _   I 8    E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _          A4
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _

; Two player tournament winner
_Pattern29:
.db   I 5 D 5  A3   I 12   E4   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3         Fs4           _
.db             _           _           _
.db            A3          E4   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            D3          D4   I 8    E4
.db             _           _           _
.db            D3         Cs4           _
.db             _           _           _
.db            D4          B3   I 11   A4
.db             _           _           _
.db            D3          A3   I 8    E4
.db             _           _           _
.db            E3          E4           _
.db             _           _           _
.db            E3           _          E4
.db             _           _           _
.db            E4           _   I 11   A4
.db             _           _          A4
.db            E3           _           _
.db             _           _          A4
.db            A3          E4   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3         Fs4           _
.db             _           _           _
.db            A3          E4   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            D3          D4          A4
.db             _           _           _
.db            D3         Cs4   I 8    E4
.db             _           _           _
.db            D4          B3   I 11   A4
.db             _           _           _
.db            D3          A3   I 8    E4
.db             _           _           _
.db            E3          B3   I 11   A4
.db             _           _          A4
.db            E3           _   I 8    E4
.db             _           _           _
.db            E4           _   I 11   A4
.db             _           _           _
.db            E3           _          A4
.db             _           _           _
_Pattern2a:
.db   I 5 D 5  A3   I 12   E4   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3         Fs4           _
.db             _           _           _
.db            A3          E4   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            D3          D4   I 8    E4
.db             _           _           _
.db            D3         Cs4           _
.db             _           _           _
.db            D4          B3   I 11   A4
.db             _           _           _
.db            D3          A3   I 8    E4
.db             _           _           _
.db            E3          E4           _
.db             _           _           _
.db            E3           _          E4
.db             _           _           _
.db            E4           _   I 11   A4
.db             _           _          A4
.db            E3           _           _
.db             _           _          A4
.db            A3          E4   I 8    E4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3         Fs4           _
.db             _           _           _
.db            A3          E4   I 8    E4
.db             _           _           _
.db            A3           _          E4
.db             _           _           _
.db            A4         Cs4   I 11   A4
.db             _           _           _
.db            A3           _           _
.db             _           _           _
.db            D3          D4          A4
.db             _           _           _
.db            D3         Cs4   I 8    E4
.db             _           _           _
.db            D4          B3   I 11   A4
.db             _           _           _
.db            D3          A3   I 8    E4
.db             _           _           _
.db            A3          A4   I 11   A4
.db             _           _          A4
.db             _           _   I 8    E4
.db             _           _           _
.db             _           _   I 11   A4
.db             _           _           _
.db             _           _          A4
.db J _Sequence_Silence - _SequencesBase
.db             _           _           _

.ends