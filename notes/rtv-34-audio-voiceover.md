# RTV-34 audio voiceover hooks

RTV-34 adds optional per-note voiceover plumbing without shipping production
voiceover content.

## Note schema

`data/notes.json` supports an optional `voiceover_id` field. Missing, `null`, or
empty string values mean the note opens silently. Non-string values are ignored
with a warning.

Voiceover assets use:

`res://rtv-lore-elements/assets/audio/voiceover/<voiceover_id>.wav`

The registry id is exactly `voiceover_id`.

## Registry and playback

Each valid voiceover loads with `AudioStreamWAV.load_from_file()` so raw WAVs in
the mounted VMZ work without Godot `.import` metadata. The loaded stream then
registers into `Registry.SOUNDS` with:

- `audioClips`: one loaded WAV stream.
- `volume`: `0.0`.
- `randomPitch`: `false`.

Reader playback fetches the registered event with
`_lib.get_entry(_lib.Registry.SOUNDS, voiceover_id)`, instantiates vanilla
`AudioInstance2D.tscn`, and calls `PlayInstance(audio_event)`.

## Format and bus choice

Voiceover uses WAV because vanilla `AudioEvent.audioClips` is typed as
`Array[AudioStreamWAV]`, and recovered vanilla voice assets are WAV files.

Voiceover uses the `SFX` bus. The recovered mixer exposes `Master`, `Ambient`,
`SFX`, `Music`, and `Radio`; there is no dedicated `Voice` or `Dialogue` bus.
The `Radio` bus applies radio filtering and is not appropriate for authored note
narration.

## Failure behavior

If a note declares a voiceover but the WAV is missing or unloadable, Lore
Elements logs one warning for that id and the reader opens silently. Notes
without `voiceover_id` do not warn.

## Smoke-test method

For local verification only, temporarily add a short WAV under
`assets/audio/voiceover/` and set one known note's `voiceover_id` to the WAV base
name. Package and install the VMZ, open the note, and verify:

- The clip plays once on reader open.
- Closing the reader stops playback.
- Previous/Next page transitions stop playback and do not restart it.
- A missing `voiceover_id` warns once and leaves the reader usable.

Remove the temporary WAV and JSON edit before committing, unless the clip is a
real production asset.
