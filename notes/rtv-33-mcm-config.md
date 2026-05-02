# RTV-33 MCM config

RTV-33 adds an optional Mod Configuration Menu page for Lore Elements.

## Config schema

The config file lives at `user://MCM/rtv_lore_elements/config.ini`.

- `Float/lore_note_spawn_multiplier`: display name `Lore note spawn rate`,
  default `1.0`, range `0.0` to `20.0`, step `0.1`.
- `Keycode/lore_journal_hotkey`: display name `Journal hotkey`, default `KEY_J`,
  default type `Key`.

MCM is optional. If `res://ModConfigurationMenu/Scripts/Doink Oink/MCM_Helpers.tres`
is not available, Lore Elements keeps its default multiplier and journal hotkey.
If an existing config file is present, the mod still reads it before falling back
to defaults.

Both settings also register MCM `on_value_changed` callbacks. The save callback
remains the persisted source of truth, but in-menu changes update the active
spawn multiplier and journal input action immediately.

## Hook choice

The spawn multiplier uses post hooks on `LootContainer.FillBuckets()` and
`LootSimulation.FillBuckets()`. This keeps vanilla bucket filtering as the source
of truth for item flags, rarity, `limit`, and `exclude`, then adjusts only entries
whose `ItemData.file` matches a loaded Lore Elements note id.

The journal continues to use the existing `rtv_lore_open_journal` input action.
The MCM keycode setting is copied into that action so the reader and journal code
do not need a second input path.

## Multiplier semantics

The multiplier changes future bucket fills only. It does not rewrite already
generated or stored container contents.

- `0.0` removes lore notes from the generated bucket.
- `1.0` leaves the vanilla/registered bucket unchanged.
- Values below `1.0` keep each lore note with that probability.
- Values above `1.0` duplicate lore note references in the same rarity bucket.
  Integer portions add guaranteed copies; fractional portions add one more copy
  probabilistically.

The high end of the range is intentionally spammy for smoke tests where we want
to see notes quickly in fresh loot rolls. This intentionally treats bucket entry
count as the available per-item weight, because Road to Vostok's loot buckets do
not expose numeric item weights.

## Compatibility caveat

Loot Modifier overrides `LootContainer.gd` and `LootSimulation.gd`. It still uses
the same filled rarity buckets, so the Lore Elements multiplier should affect the
candidate buckets when Metro hooks are active, but final observed drop rates can
still differ because Loot Modifier replaces the generation probabilities and
minimum-loot behavior.
